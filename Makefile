.PHONY: ping

HOSTNAME=dark-nas

setup-plex:
	ansible-playbook -i ${HOSTNAME}, -K setup-plex.yaml

setup-plex-hama:
	ansible-playbook -i ${HOSTNAME}, -K setup-plex-hama.yaml

setup-plex-shoko:
	ansible-playbook -i ${HOSTNAME}, -K setup-plex-shoko.yaml

setup-ntfy:
	ansible-playbook -i ${HOSTNAME}, -K setup-ntfy.yml

setup-plex-traefik:
	ansible-playbook -i ${HOSTNAME}, -K setup-plex-traefik.yml

ping:
	ansible -i ${HOSTNAME}, -m ping all
