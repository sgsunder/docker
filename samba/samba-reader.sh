#!/usr/bin/env sh
sh -c "/usr/bin/samba.sh $(cat /run/secrets/samba_config | tr '\n' ' ')"
