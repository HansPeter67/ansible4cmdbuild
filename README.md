# ansible4cmdbuild

Ansible-based inventory sync for CMDBuild.

## What this repository does

This project collects host inventory data with Ansible, stores it as JSON on the control node, and then sends that JSON to CMDBuild using Bash scripts.

## Repository layout

- `ansible/` - Ansible inventory and playbooks
- `config/` - environment-style configuration for CMDBuild sync
- `scripts/` - Bash scripts for export and synchronization
- `docs/` - architecture and operating instructions

## Quick start

1. Copy `ansible/inventory.ini.example` to `ansible/inventory.ini` and edit host names and access variables.
2. Copy `config/cmdbuild.env` and adjust it for your CMDBuild instance.
3. Run the inventory export script:
   ```bash
   ./scripts/export_inventory.sh
   ```
4. Sync the latest inventory file into CMDBuild:
   ```bash
   ./scripts/sync_to_cmdbuild.sh out/inventory-YYYYMMDDHHMMSS.json
   ```

## Notes

- Keep `CMDBUILD_TOKEN` private.
- Use HTTPS for CMDBuild.
- Start with `CMDBUILD_DRY_RUN=true` when testing.
