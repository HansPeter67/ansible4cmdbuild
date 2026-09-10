# Operating instructions

This document explains how to use the repository to collect inventory data from managed hosts and sync it into CMDBuild.

## 1. Prerequisites

Install the following on the Ansible control node:

- `ansible-playbook`
- `bash`
- `jq`
- `curl`

Optional but recommended:

- `systemd` or `cron` for scheduling
- `shellcheck` for script validation
- `yq` is **not required** in the current bash-only flow

You also need:

- a reachable CMDBuild instance
- a CMDBuild username and password
- SSH or WinRM access to the managed hosts

## 2. Configure Ansible inventory

Copy the example inventory file:

```bash
cp ansible/inventory.ini.example ansible/inventory.ini
```

Edit `ansible/inventory.ini` and set:

- hostnames or IP addresses
- `ansible_user`
- SSH key or password variables if needed
- Windows access variables if applicable

## 3. Configure CMDBuild sync settings

Edit `config/cmdbuild.env` and set at least:

- `CMDBUILD_BASE_URL`
- `CMDBUILD_SCOPE`
- `CMDBUILD_USERNAME`
- `CMDBUILD_PASSWORD`
- `CMDBUILD_CLASS_NAME`
- `CMDBUILD_UNIQUE_KEY`

For safe testing, set:

```bash
CMDBUILD_DRY_RUN=true
```

## 4. Collect inventory

Run the export script:

```bash
./scripts/export_inventory.sh
```

What it does:

- runs `ansible-playbook`
- gathers host facts
- writes one JSON file per host into `out/`
- removes any older staged JSON files before export
- prints the export location

Typical output files:

```text
out/server1.example.com.json
out/server2.example.com.json
```

## 5. Review the generated inventory

Inspect a JSON file before syncing:

```bash
jq . out/server1.example.com.json
```

Check that the data contains the expected fields such as:

- hostname
- fqdn
- OS details
- IP addresses
- CPU and memory
- timestamp

## 6. Sync inventory into CMDBuild

Run the sync script with the JSON file:

```bash
./scripts/sync_to_cmdbuild.sh out/server1.example.com.json
```

Or run the wrapper to sync all generated JSON files:

```bash
./scripts/export_and_sync.sh
```

What it does:

- loads `config/cmdbuild.env`
- logs in to CMDBuild with username/password
- extracts the `sessionId` from the login response
- sends requests with the `Cmdbuild-authorization` header
- if all syncs succeed, removes the staged JSON files afterward
- if a sync fails, keeps the staged JSON files for investigation
- honors dry-run mode if enabled

## 7. Dry-run mode

To test without sending data:

```bash
export CMDBUILD_DRY_RUN=true
./scripts/sync_to_cmdbuild.sh out/server1.example.com.json
```

This prints the payload instead of sending it.

## 8. Scheduling

### Cron example

Run export and sync every night at 02:00:

```cron
0 2 * * * /path/to/ansible4cmdbuild/scripts/export_and_sync.sh >> /var/log/cmdbuild-export.log 2>&1
```

### Systemd timer approach

You can also create:

- a service to run the wrapper script
- a timer to trigger it on schedule

## 9. Recommended operating flow

1. Export inventory from hosts
2. Review the JSON output
3. Sync to CMDBuild in dry-run mode first
4. Enable live sync after verification
5. Repeat on a schedule

## 10. Troubleshooting

### Inventory export fails

Check:

- SSH/WinRM connectivity
- Ansible inventory syntax
- host variables
- `ansible-playbook` installation

### Sync fails

Check:

- `CMDBUILD_USERNAME`
- `CMDBUILD_PASSWORD`
- `CMDBUILD_BASE_URL`
- CMDBuild scope and API path
- `curl` and `jq` availability
- whether the target endpoint exists in your CMDBuild setup

### Empty or incomplete JSON

Check:

- whether facts gathering is enabled
- whether the target host is reachable
- whether Ansible can become the remote user if needed

## 11. Security notes

- do not commit secrets into the repository
- store credentials in a secure secret manager if possible
- prefer HTTPS
- restrict write access to the CMDBuild credentials
- use least privilege for Ansible access
