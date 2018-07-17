#!/usr/bin/env bash
#===============================================================================
#          FILE: samba.sh
#
#         USAGE: ./samba.sh
#
#   DESCRIPTION: Entrypoint for samba docker container
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: David Personette (dperson@gmail.com),
#  ORGANIZATION:
#       CREATED: 09/28/2014 12:11
#      REVISION: 1.0
#===============================================================================

set -o nounset                              # Treat unset variables as an error

### initsmbconf: initialize the smb.conf file
# Arguments:
#   none)
# Return: result
initsmbconf() { local file=/etc/samba/smb.conf
    echo "[global]" > $file
    echo "   workgroup = MYGROUP" >> $file
    echo "   server string = Samba Server" >> $file
    echo "   server role = standalone server" >> $file
    echo "   log file = /dev/stdout" >> $file
    echo "   max log size = 50" >> $file
    echo "   dns proxy = no" >> $file
    echo "   pam password change = yes" >> $file
    echo "   map to guest = bad user" >> $file
    echo "   usershare allow guests = yes" >> $file
    echo "   create mask = 0664" >> $file
    echo "   force create mode = 0664" >> $file
    echo "   directory mask = 0775" >> $file
    echo "   force directory mode = 0775" >> $file
    echo "   force user = smbuser" >> $file
    echo "   force group = users" >> $file
    echo "   follow symlinks = yes" >> $file
    echo "   load printers = no" >> $file
    echo "   printing = bsd" >> $file
    echo "   printcap name = /dev/null" >> $file
    echo "   disable spoolss = yes" >> $file
    echo "   socket options = TCP_NODELAY" >> $file
    echo "   strict locking = no" >> $file
    echo "   vfs objects = recycle" >> $file
    echo "   recycle:keeptree = yes" >> $file
    echo "   recycle:versions = yes" >> $file
    echo "   min protocol = SMB2" >> $file
    echo "" >> $file
    echo "" >> $file
    chmod +x $file
}


### charmap: setup character mapping for file/directory names
# Arguments:
#   chars) from:to character mappings separated by ','
# Return: configured character mapings
charmap() { local chars="$1" file=/etc/samba/smb.conf
    grep -q catia $file || sed -i '/TCP_NODELAY/a \
\
    vfs objects = catia\
    catia:mappings =\

                ' $file

    sed -i '/catia:mappings/s/ =.*/ = '"$chars" $file
}

### global: set a global config option
# Arguments:
#   option) raw option
# Return: line added to smb.conf (replaces existing line with same key)
global() { local key="${1%%=*}" value="${1#*=}" file=/etc/samba/smb.conf
    if grep -qE '^;*\s*'"$key" "$file"; then
        sed -i 's|^;*\s*'"$key"'.*|   '"${key% } = ${value# }"'|' "$file"
    else
        sed -i '/\[global\]/a \   '"${key% } = ${value# }" "$file"
    fi
}

### import: import a smbpasswd file
# Arguments:
#   file) file to import
# Return: user(s) added to container
import() { local file="$1" name id
    while read name id; do
        grep -q "^$name:" /etc/passwd || adduser -D -H -u "$id" "$name"
    done < <(cut -d: -f1,2 $file | sed 's/:/ /')
    pdbedit -i smbpasswd:$file
}

### perms: fix ownership and permissions of share paths
# Arguments:
#   none)
# Return: result
perms() { local i file=/etc/samba/smb.conf
    for i in $(awk -F ' = ' '/   path = / {print $2}' $file); do
        chown -Rh smbuser. $i
        find $i -type d ! -perm 775 -exec chmod 775 {} \;
        find $i -type f ! -perm 0664 -exec chmod 0664 {} \;
    done
}

### recycle: disable recycle bin
# Arguments:
#   none)
# Return: result
recycle() { local file=/etc/samba/smb.conf
    sed -i '/recycle/d; /vfs/d' $file
}

### share: Add share
# Arguments:
#   share) share name
#   path) path to share
#   browsable) 'yes' or 'no'
#   readonly) 'yes' or 'no'
#   guest) 'yes' or 'no'
#   users) list of allowed users
#   admins) list of admin users
#   writelist) list of users that can write to a RO share
#   comment) description of share
# Return: result
share() { local share="$1" path="$2" browsable="${3:-yes}" ro="${4:-yes}" \
                guest="${5:-yes}" users="${6:-""}" admins="${7:-""}" \
                writelist="${8:-""}" comment="${9:-""}" file=/etc/samba/smb.conf
    sed -i "/\\[$share\\]/,/^\$/d" $file
    echo "[$share]" >>$file
    echo "   path = $path" >>$file
    echo "   browsable = $browsable" >>$file
    echo "   read only = $ro" >>$file
    echo "   guest ok = $guest" >>$file
    echo -n "   veto files = /._*/.apdisk/.AppleDouble/.DS_Store/" >>$file
    echo -n ".TemporaryItems/.Trashes/desktop.ini/ehthumbs.db/" >>$file
    echo "Network Trash Folder/Temporary Items/Thumbs.db/" >>$file
    echo "   delete veto files = yes" >>$file
    [[ ${users:-""} && ! ${users:-""} =~ all ]] &&
        echo "   valid users = $(tr ',' ' ' <<< $users)" >>$file
    [[ ${admins:-""} && ! ${admins:-""} =~ none ]] &&
        echo "   admin users = $(tr ',' ' ' <<< $admins)" >>$file
    [[ ${writelist:-""} && ! ${writelist:-""} =~ none ]] &&
        echo "   write list = $(tr ',' ' ' <<< $writelist)" >>$file
    [[ ${comment:-""} && ! ${comment:-""} =~ none ]] &&
        echo "   comment = $(tr ',' ' ' <<< $comment)" >>$file
    echo "" >>$file
    [[ -d $path ]] || mkdir -p $path
}

### smb: disable SMB2 minimum
# Arguments:
#   none)
# Return: result
smb() { local file=/etc/samba/smb.conf
    sed -i '/min protocol/d' $file
}

### user: add a user
# Arguments:
#   name) for user
#   password) for user
#   id) for user
#   group) for user
# Return: user added to container
user() { local name="$1" passwd="$2" id="${3:-""}" group="${4:-""}"
    [[ "$group" ]] && { grep -q "^$group:" /etc/group || addgroup "$group"; }
    grep -q "^$name:" /etc/passwd ||
        adduser -D -H ${group:+-G $group} ${id:+-u $id} "$name"
    echo -e "$passwd\n$passwd" | smbpasswd -s -a "$name"
}

### workgroup: set the workgroup
# Arguments:
#   workgroup) the name to set
# Return: configure the correct workgroup
workgroup() { local workgroup="$1" file=/etc/samba/smb.conf
    sed -i 's|^\( *workgroup = \).*|\1'"$workgroup"'|' $file
}

### widelinks: allow access wide symbolic links
# Arguments:
#   none)
# Return: result
widelinks() { local file=/etc/samba/smb.conf \
            replace='\1\n   wide links = yes\n   unix extensions = no'
    sed -i 's/\(follow symlinks = yes\)/'"$replace"'/' $file
}

# Create an smb.conf file
initsmbconf

# Set Permissions
[[ "${PUID:-""}" =~ ^[0-9]+$ ]] && usermod -u $PUID -o smbuser
[[ "${PGID:-""}" =~ ^[0-9]+$ ]] && groupmod -g $PGID -o users

# Read Configuration Variables
[[ "${CHARMAP:-""}" ]] && charmap "$CHARMAP"
for varname in $(env | awk -F "=" '{print $1}' | grep -i "GLOBAL_*"); do
  eval "input=\$$varname"
  global "$input"
done
[[ "${IMPORT:-""}" ]] && import "$IMPORT"
[[ "${PERMISSIONS:-""}" ]] && perms
[[ "${RECYCLE:-""}" ]] && recycle
for varname in $(env | awk -F "=" '{print $1}' | grep -i "SHARE_*"); do
  eval "input=\$$varname"
  eval share $(sed 's/^/"/; s/$/"/; s/;/" "/g' <<< $input)
done
[[ "${SMB:-""}" ]] && smb
for varname in $(env | awk -F "=" '{print $1}' | grep -i "USER_*"); do
  eval "input=\$$varname"
  eval user $(sed 's/^/"/; s/$/"/; s/;/" "/g' <<< $input)
done
[[ "${WORKGROUP:-""}" ]] && workgroup "$WORKGROUP"
[[ "${WIDELINKS:-""}" ]] && widelinks

# Start the samba service
[[ ${NMBD:-""} ]] && ionice -c 3 nmbd -D
exec ionice -c 3 smbd -FS </dev/null
