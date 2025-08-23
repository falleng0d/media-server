.PHONY: ping

setup-plex:
	ansible-playbook -i dark-nas, -K setup-plex.yaml

setup-plex-hama:
	ansible-playbook -i dark-nas, -K setup-plex-hama.yaml

setup-plex-shoko:
	ansible-playbook -i dark-nas, -K setup-plex-shoko.yaml

ping:
	ansible -i dark-nas, -m ping all
