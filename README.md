# Dark NAS Automation

## Setup Ansible (Host)

### Install

```bash
sudo apt update
sudo apt install software-properties-common
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install ansible
```

### Config

```bash
ansible-config init --disabled -t all > ansible.cfg
mv ansible.cfg /etc/ansible/ansible.cfg
cat /etc/ansible/ansible.cfg
```

# Execute Playbook

```bash
ansible-playbook -i inventory -l dark-nas -K playbook.yml
```

# Dry Run

```bash
ansible-playbook -i inventory -l dark-nas playbook.yml --check
```

# Test Connection

```bash
ansible -i inventory -l dark-nas -m ping all
```
