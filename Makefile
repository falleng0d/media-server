.PHONY: ping

HOSTNAME=dark-nas

setup-plex:
	ansible-playbook -i ${HOSTNAME}, -K setup-plex.yaml

setup-plex-hama:
	ansible-playbook -i ${HOSTNAME}, -K setup-plex-hama.yaml

setup-plex-shoko:
	ansible-playbook -i ${HOSTNAME}, -K setup-plex-shoko.yaml

ping:
	ansible -i ${HOSTNAME}, -m ping all
