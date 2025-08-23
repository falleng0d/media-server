# Plex Shoko Relay Setup Role

This Ansible role automatically configures Plex Media Server with Shoko Relay for anime metadata management.

## Prerequisites

- Plex Media Server installed and running on the target host
- Shoko Server running and accessible
- Ansible with appropriate permissions to manage Plex

## Architecture

This role is designed for the following setup:
- **Plex Media Server**: Running directly on the host system
- **Shoko Server**: Running in Docker container with port 8111 exposed to host
- **Connection**: Plex connects to Shoko via `localhost:8111`

## What This Role Does

1. **Stops Plex** temporarily during installation
2. **Downloads and installs** Shoko Relay bundle from GitHub
3. **Configures scanners** with your Shoko server connection details
4. **Sets up proper permissions** for Plex user
5. **Verifies Shoko connectivity** before configuration
6. **Starts Plex** after successful setup

## Usage

### Basic Usage

```bash
ansible-playbook -i inventory -K setup-plex-shoko.yml
```

### With Custom Variables

Create a variables file or override in your playbook:

```yaml
---
- name: Configure Plex with Shoko Relay
  hosts: all
  become: true
  vars:
    shoko_username: "your_username"
    shoko_password: "your_password"
    single_season_ordering: true
    include_specials: false
  roles:
    - role: setup-plex-shoko
```

## Configuration Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `shoko_host` | `127.0.0.1` | Shoko server hostname/IP |
| `shoko_port` | `8111` | Shoko server port |
| `shoko_username` | `Default` | Shoko username |
| `shoko_password` | `""` | Shoko password |
| `single_season_ordering` | `false` | Put all episodes in Season 1 |
| `include_specials` | `true` | Include special episodes |
| `include_other` | `true` | Include other episode types |
| `plex_base_dir` | `/var/lib/plexmediaserver/Library/Application Support/Plex Media Server` | Plex data directory |
| `plex_service_name` | `plexmediaserver` | Plex service name |

## Scanner Options Explained

- **SingleSeasonOrdering**: When `true`, all normal episodes go into Season 1, specials into Season 0
- **IncludeSpecials**: When `true`, files marked as specials in Shoko appear in Season 0
- **IncludeOther**: When `true`, files marked as "other" in Shoko appear in Season 0

## Troubleshooting

### Shoko Server Not Accessible
If the role fails with connectivity issues:
1. Verify Shoko container is running: `docker ps | grep shoko`
2. Check port mapping: `docker port <shoko_container_name>`
3. Test connectivity: `curl http://localhost:8111/api/init/status`

### Permission Issues
If you encounter permission errors:
1. Ensure the `plex` user exists on the system
2. Verify Plex service is running as the `plex` user
3. Check that the role is run with appropriate sudo privileges (`-K` flag)

### Scanner Not Appearing in Plex
1. Restart Plex Media Server completely
2. Check that files are in the correct locations with proper ownership
3. Verify the scanner configuration file syntax

## Post-Installation

After running this role:
1. **Restart Plex** (done automatically by the role)
2. **Create a new library** in Plex
3. **Select "Shoko Relay Scanner"** as the scanner
4. **Choose "Shoko Relay"** as the metadata agent
5. **Configure library settings** as needed

## Related Documentation

- [Shoko Documentation](https://docs.shokoanime.com/plex/installing-agents-scanners)
- [Shoko Relay GitHub](https://github.com/natyusha/ShokoRelay.bundle)
