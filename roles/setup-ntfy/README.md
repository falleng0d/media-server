# ntfy Setup Role

This Ansible role configures ntfy server with authentication and generates the necessary configuration files for Docker deployment.

## Prerequisites

- Ansible installed on the control machine
- Target host with Docker and docker-compose available
- Appropriate permissions to write to the configuration directory

## What This Role Does

1. **Creates ntfy configuration directory** (default: `/docker/ntfy`)
2. **Generates server.yml** from Jinja2 template with your custom settings
3. **Creates user setup script** for managing ntfy users
4. **Configures authentication** with secure defaults
5. **Sets up proper file permissions** for Docker containers

## Usage

### Basic Usage

```bash
ansible-playbook -i inventory -K setup-ntfy.yml
```

### With Custom Variables

Create a variables file or override in your playbook:

```yaml
---
- name: Configure ntfy server
  hosts: all
  become: true
  vars:
    ntfy_base_url: "https://ntfy.yourdomain.com"
    ntfy_admin_username: "admin"
    ntfy_admin_password: "secure_password"
    ntfy_behind_proxy: true
    ntfy_users:
      - username: "user1"
        password: "password1"
        role: "user"
  roles:
    - role: setup-ntfy
```

## Configuration Variables

### Basic Settings
- `ntfy_config_dir`: Configuration directory (default: `/docker/ntfy`)
- `ntfy_base_url`: External URL for the ntfy server
- `ntfy_listen_http`: HTTP listen address (default: `:80`)

### Authentication
- `ntfy_auth_default_access`: Default access level (default: `deny-all`)
- `ntfy_enable_login`: Enable login functionality (default: `true`)
- `ntfy_enable_signup`: Enable user registration (default: `false`)
- `ntfy_admin_username`: Default admin username (default: `admin`)
- `ntfy_admin_password`: Admin password (prompted if empty)
- `ntfy_users`: List of additional users to create

### Advanced Settings
- `ntfy_cache_duration`: Message cache duration (default: `12h`)
- `ntfy_attachment_cache_dir`: Attachment storage directory
- `ntfy_visitor_request_limit_burst`: Rate limiting settings
- `ntfy_smtp_*`: SMTP configuration for email notifications
- `ntfy_web_push_*`: Web push notification settings

## File Structure

After running this role, you'll have:

```
/docker/ntfy/
├── server.yml          # Main configuration file
└── setup-users.sh      # User management script
```

## Docker Integration

Update your docker-compose.yml to use the generated configuration:

```yaml
services:
  ntfy:
    image: binwiederhier/ntfy
    command: serve
    volumes:
      - /docker/ntfy:/etc/ntfy
      - /var/cache/ntfy:/var/lib/ntfy
    ports:
      - 3434:80
```

## User Management

### Initial Setup
1. Run the Ansible role to generate configuration
2. Start the ntfy container
3. Run the user setup script from the host: `/docker/ntfy/setup-users.sh`
   - The script automatically finds the running ntfy container
   - No need to copy files or exec into the container

### Manual User Management
```bash
# Add user
docker exec -it <container> ntfy user add username

# Add admin user
docker exec -it <container> ntfy user add --role=admin adminuser

# Change password
docker exec -it <container> ntfy user change-pass username

# List users
docker exec -it <container> ntfy user list
```

## Security Considerations

- Default configuration denies all access (`auth-default-access: deny-all`)
- User registration is disabled by default (`enable-signup: false`)
- Strong rate limiting is configured to prevent abuse
- Configuration files are created with appropriate permissions

## Customization

Copy `vars/main.yml.template` to `vars/main.yml` and customize:

```bash
cp roles/setup-ntfy/vars/main.yml.template roles/setup-ntfy/vars/main.yml
# Edit vars/main.yml with your settings
```

## Examples

### Private Instance with Multiple Users
```yaml
ntfy_base_url: "https://ntfy.example.com"
ntfy_admin_username: "admin"
ntfy_admin_password: "secure_admin_pass"
ntfy_users:
  - username: "alice"
    password: "alice_password"
    role: "user"
  - username: "bob"
    password: "bob_password"
    role: "user"
  - username: "moderator"
    password: "mod_password"
    role: "admin"
```

### Public Instance with Email Support
```yaml
ntfy_base_url: "https://ntfy.example.com"
ntfy_auth_default_access: "read-write"
ntfy_enable_signup: true
ntfy_smtp_sender_addr: "smtp.gmail.com:587"
ntfy_smtp_sender_user: "notifications@example.com"
ntfy_smtp_sender_pass: "app_password"
ntfy_smtp_sender_from: "ntfy@example.com"
```
