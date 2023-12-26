#!/system/bin/sh

# Copyright (C) 2021 MistyRain <1740621736@qq.com>

. $ASL_CLI/asl_print.sh

function extract_rootfs() {
    local rootfs_file="$1"
    local output_dir="$2"
    local file_suffix=$(basename $rootfs_file)
    case "${file_suffix#*.}" in
        "7z" | "zip" | "rar")
            pv "$rootfs_file" | 7zz x -so -si -ttar | pv -s $(stat -c "%s" "$rootfs_file") | tar xf - -C "$output_dir"
            ;;
        "tar")
            pv "$rootfs_file" | tar -xp -C "$output_dir"
            ;;
        "tar.xz")
            pv "$rootfs_file" | tar -xJp -C "$output_dir"
            ;;
        "tar.gz")
            pv "$rootfs_file" | tar -xzp -C "$output_dir"
            ;;
        "tar.bz2")
            pv "$rootfs_file" | tar -xjp -C "$output_dir"
            ;;
        "tar.Z")
            pv "$rootfs_file" | tar -xZp -C "$output_dir"
            ;;
    esac
}
