# CMDBuild + Ansible architecture

## Flow

Managed hosts
→ Ansible control node
→ inventory collection playbook
→ normalization
→ CMDBuild sync script
→ CMDBuild API or import endpoint
→ CMDBuild database

## Responsibilities

### Ansible
- collect facts
- run periodic checks
- gather host metadata

### Bash scripts
- export inventory
- normalize/prepare payloads
- push updates to CMDBuild

### CMDBuild
- store CIs
- manage relationships
- provide workflows and access control

## Notes
- Prefer HTTPS for CMDBuild access
- Store API tokens securely
- Keep inventory keys stable
- Use hostname, UUID, or serial number as identity
