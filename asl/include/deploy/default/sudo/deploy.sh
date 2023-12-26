#!/system/bin/sh

# Copyright (C) 2021 MistyRain <1740621736@qq.com>

. $ASL_CLI/asl_print.sh
. $ASL_CLI/functions.sh
this_path=$(cd `dirname $0`;pwd)
container_name="$1"

sudo_str="${USER_NAME} ALL=(ALL:ALL) NOPASSWD:ALL"
if ! grep -q "${sudo_str}" "$ASL_CONTAINER/$container_name/etc/sudoers"; then
    chmod 640 "$ASL_CONTAINER/$container_name/etc/sudoers"
    echo ${sudo_str} >> "$ASL_CONTAINER/$container_name/etc/sudoers"
    chmod 440 "$ASL_CONTAINER/$container_name/etc/sudoers"
fi
if [ -e "$ASL_CONTAINER/$container_name/etc/profile.d" ]; then
    echo '[ -n "$PS1" -a "$(whoami)" = "'${USER_NAME}'" ] || return 0' > "$ASL_CONTAINER/$container_name/etc/profile.d/sudo.sh"
    echo 'alias su="sudo su"' >> "$ASL_CONTAINER/$container_name/etc/profile.d/sudo.sh"
fi

