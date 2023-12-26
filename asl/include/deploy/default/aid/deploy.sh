#!/system/bin/sh

# Copyright (C) 2021 MistyRain <1740621736@qq.com>

. $ASL_CLI/asl_print.sh
. $ASL_CLI/functions.sh
this_path=$(cd `dirname $0`;pwd)
container_name="$1"

temporarily_container_exec $container_name groupadd aid_system -g 1000 || temporarily_container_exec $container_name groupadd aid_system -g 1074
temporarily_container_exec $container_name groupadd aid_radio -g 1001
temporarily_container_exec $container_name groupadd aid_bluetooth -g 1002
temporarily_container_exec $container_name groupadd aid_graphics -g 1003
temporarily_container_exec $container_name groupadd aid_input -g 1004
temporarily_container_exec $container_name groupadd aid_audio -g 1005
temporarily_container_exec $container_name groupadd aid_camera -g 1006
temporarily_container_exec $container_name groupadd aid_log -g 1007
temporarily_container_exec $container_name groupadd aid_compass -g 1008
temporarily_container_exec $container_name groupadd aid_mount -g 1009
temporarily_container_exec $container_name groupadd aid_wifi -g 1010
temporarily_container_exec $container_name groupadd aid_adb -g 1011
temporarily_container_exec $container_name groupadd aid_install -g 1012
temporarily_container_exec $container_name groupadd aid_media -g 1013
temporarily_container_exec $container_name groupadd aid_dhcp -g 1014
temporarily_container_exec $container_name groupadd aid_sdcard_rw -g 1015
temporarily_container_exec $container_name groupadd aid_vpn -g 1016
temporarily_container_exec $container_name groupadd aid_keystore -g 1017
temporarily_container_exec $container_name groupadd aid_usb -g 1018
temporarily_container_exec $container_name groupadd aid_drm -g 1019
temporarily_container_exec $container_name groupadd aid_mdnsr -g 1020
temporarily_container_exec $container_name groupadd aid_gps -g 1021
temporarily_container_exec $container_name groupadd aid_media_rw -g 1023
temporarily_container_exec $container_name groupadd aid_mtp -g 1024
temporarily_container_exec $container_name groupadd aid_drmrpc -g 1026
temporarily_container_exec $container_name groupadd aid_nfc -g 1027
temporarily_container_exec $container_name groupadd aid_sdcard_r -g 1028
temporarily_container_exec $container_name groupadd aid_clat -g 1029
temporarily_container_exec $container_name groupadd aid_loop_radio -g 1030
temporarily_container_exec $container_name groupadd aid_media_drm -g 1031
temporarily_container_exec $container_name groupadd aid_package_info -g 1032
temporarily_container_exec $container_name groupadd aid_sdcard_pics -g 1033
temporarily_container_exec $container_name groupadd aid_sdcard_av -g 1034
temporarily_container_exec $container_name groupadd aid_sdcard_all -g 1035
temporarily_container_exec $container_name groupadd aid_logd -g 1036
temporarily_container_exec $container_name groupadd aid_shared_relro -g 1037
temporarily_container_exec $container_name groupadd aid_dbus -g 1038
temporarily_container_exec $container_name groupadd aid_tlsdate -g 1039
temporarily_container_exec $container_name groupadd aid_media_ex -g 1040
temporarily_container_exec $container_name groupadd aid_audioserver -g 1041
temporarily_container_exec $container_name groupadd aid_metrics_coll -g 1042
temporarily_container_exec $container_name groupadd aid_metricsd -g 1043
temporarily_container_exec $container_name groupadd aid_webserv -g 1044
temporarily_container_exec $container_name groupadd aid_debuggerd -g 1045
temporarily_container_exec $container_name groupadd aid_media_codec -g 1046
temporarily_container_exec $container_name groupadd aid_cameraserver -g 1047
temporarily_container_exec $container_name groupadd aid_firewall -g 1048
temporarily_container_exec $container_name groupadd aid_trunks -g 1049
temporarily_container_exec $container_name groupadd aid_nvram -g 1050
temporarily_container_exec $container_name groupadd aid_dns -g 1051
temporarily_container_exec $container_name groupadd aid_dns_tether -g 1052
temporarily_container_exec $container_name groupadd aid_webview_zygote -g 1053
temporarily_container_exec $container_name groupadd aid_vehicle_network -g 1054
temporarily_container_exec $container_name groupadd aid_media_audio -g 1055
temporarily_container_exec $container_name groupadd aid_media_video -g 1056
temporarily_container_exec $container_name groupadd aid_media_image -g 1057
temporarily_container_exec $container_name groupadd aid_tombstoned -g 1058
temporarily_container_exec $container_name groupadd aid_media_obb -g 1059
temporarily_container_exec $container_name groupadd aid_ese -g 1060
temporarily_container_exec $container_name groupadd aid_ota_update -g 1061
temporarily_container_exec $container_name groupadd aid_automotive_evs -g 1062
temporarily_container_exec $container_name groupadd aid_lowpan -g 1063
temporarily_container_exec $container_name groupadd aid_hsm -g 1064
temporarily_container_exec $container_name groupadd aid_reserved_disk -g 1065
temporarily_container_exec $container_name groupadd aid_statsd -g 1066
temporarily_container_exec $container_name groupadd aid_incidentd -g 1067
temporarily_container_exec $container_name groupadd aid_secure_element -g 1068
temporarily_container_exec $container_name groupadd aid_lmkd -g 1069
temporarily_container_exec $container_name groupadd aid_llkd -g 1070
temporarily_container_exec $container_name groupadd aid_iorapd -g 1071
temporarily_container_exec $container_name groupadd aid_gpu_service -g 1072
temporarily_container_exec $container_name groupadd aid_network_stack -g 1073
temporarily_container_exec $container_name groupadd aid_shell -g 2000
temporarily_container_exec $container_name groupadd aid_cache -g 2001
temporarily_container_exec $container_name groupadd aid_diag -g 2002
temporarily_container_exec $container_name groupadd aid_oem_reserved_start -g 2900
temporarily_container_exec $container_name groupadd aid_oem_reserved_end -g 2999
temporarily_container_exec $container_name groupadd aid_net_bt_admin -g 3001
temporarily_container_exec $container_name groupadd aid_net_bt -g 3002
temporarily_container_exec $container_name groupadd aid_inet -g 3003
temporarily_container_exec $container_name groupadd aid_net_raw -g 3004
temporarily_container_exec $container_name groupadd aid_net_admin -g 3005
temporarily_container_exec $container_name groupadd aid_net_bw_stats -g 3006
temporarily_container_exec $container_name groupadd aid_net_bw_acct -g 3007
temporarily_container_exec $container_name groupadd aid_readproc -g 3009
temporarily_container_exec $container_name groupadd aid_wakelock -g 3010
temporarily_container_exec $container_name groupadd aid_uhid -g 3011
temporarily_container_exec $container_name groupadd aid_everybody -g 9997
temporarily_container_exec $container_name groupadd aid_misc -g 9998
temporarily_container_exec $container_name groupadd aid_nobody -g 9999
temporarily_container_exec $container_name groupadd aid_app_start -g 10000
temporarily_container_exec $container_name groupadd aid_app_end -g 19999
temporarily_container_exec $container_name groupadd aid_cache_gid_start -g 20000
temporarily_container_exec $container_name groupadd aid_cache_gid_end -g 29999
temporarily_container_exec $container_name groupadd aid_ext_gid_start -g 30000
temporarily_container_exec $container_name groupadd aid_ext_gid_end -g 39999
temporarily_container_exec $container_name groupadd aid_ext_cache_gid_start -g 40000
temporarily_container_exec $container_name groupadd aid_ext_cache_gid_end -g 49999
temporarily_container_exec $container_name groupadd aid_shared_gid_start -g 50000
temporarily_container_exec $container_name groupadd aid_shared_gid_end -g 59999
#groupadd aid_overflowuid -g 65534 2>/dev/null || groupadd aid_overflowuid -g 65535
#添加65534 group将导致opensuse的system-user-nobody配置失败。
temporarily_container_exec $container_name groupadd aid_isolated_start -g 99000
temporarily_container_exec $container_name groupadd aid_isolated_end -g 99999
temporarily_container_exec $container_name groupadd aid_user_offset -g 100000
#temporarily_container_exec $container_name #usermod -a -G aid_bt,aid_bt_net,aid_inet,aid_net_raw,aid_admin root
if [ "$CREATE_USER" = "true" ]; then
    temporarily_container_exec $container_name usermod -a -G aid_system,aid_radio,aid_bluetooth,aid_graphics,aid_input,aid_audio,aid_camera,aid_log,aid_compass,aid_mount,aid_wifi,aid_adb,aid_install,aid_media,aid_dhcp,aid_sdcard_rw,aid_vpn,aid_keystore,aid_usb,aid_drm,aid_mdnsr,aid_gps,aid_media_rw,aid_mtp,aid_drmrpc,aid_nfc,aid_sdcard_r,aid_clat,aid_loop_radio,aid_media_drm,aid_package_info,aid_sdcard_pics,aid_sdcard_av,aid_sdcard_all,aid_logd,aid_shared_relro,aid_dbus,aid_tlsdate,aid_media_ex,aid_audioserver,aid_metrics_coll,aid_metricsd,aid_webserv,aid_debuggerd,aid_media_codec,aid_cameraserver,aid_firewall,aid_trunks,aid_nvram,aid_dns,aid_dns_tether,aid_webview_zygote,aid_vehicle_network,aid_media_audio,aid_media_video,aid_media_image,aid_tombstoned,aid_media_obb,aid_ese,aid_ota_update,aid_automotive_evs,aid_lowpan,aid_hsm,aid_reserved_disk,aid_statsd,aid_incidentd,aid_secure_element,aid_lmkd,aid_llkd,aid_iorapd,aid_gpu_service,aid_network_stack,aid_shell,aid_cache,aid_diag,aid_oem_reserved_start,aid_oem_reserved_end,aid_net_bt_admin,aid_net_bt,aid_inet,aid_net_raw,aid_net_admin,aid_net_bw_stats,aid_net_bw_acct,aid_readproc,aid_wakelock,aid_uhid,aid_everybody,aid_misc,aid_nobody,aid_app_start,aid_app_end,aid_cache_gid_start,aid_cache_gid_end,aid_ext_gid_start,aid_ext_gid_end,aid_ext_cache_gid_start,aid_ext_cache_gid_end,aid_shared_gid_start,aid_shared_gid_end,aid_isolated_start,aid_isolated_end,aid_user_offset $USER_NAME
fi
temporarily_container_exec $container_name usermod -a -G aid_system,aid_radio,aid_bluetooth,aid_graphics,aid_input,aid_audio,aid_camera,aid_log,aid_compass,aid_mount,aid_wifi,aid_adb,aid_install,aid_media,aid_dhcp,aid_sdcard_rw,aid_vpn,aid_keystore,aid_usb,aid_drm,aid_mdnsr,aid_gps,aid_media_rw,aid_mtp,aid_drmrpc,aid_nfc,aid_sdcard_r,aid_clat,aid_loop_radio,aid_media_drm,aid_package_info,aid_sdcard_pics,aid_sdcard_av,aid_sdcard_all,aid_logd,aid_shared_relro,aid_dbus,aid_tlsdate,aid_media_ex,aid_audioserver,aid_metrics_coll,aid_metricsd,aid_webserv,aid_debuggerd,aid_media_codec,aid_cameraserver,aid_firewall,aid_trunks,aid_nvram,aid_dns,aid_dns_tether,aid_webview_zygote,aid_vehicle_network,aid_media_audio,aid_media_video,aid_media_image,aid_tombstoned,aid_media_obb,aid_ese,aid_ota_update,aid_automotive_evs,aid_lowpan,aid_hsm,aid_reserved_disk,aid_statsd,aid_incidentd,aid_secure_element,aid_lmkd,aid_llkd,aid_iorapd,aid_gpu_service,aid_network_stack,aid_shell,aid_cache,aid_diag,aid_oem_reserved_start,aid_oem_reserved_end,aid_net_bt_admin,aid_net_bt,aid_inet,aid_net_raw,aid_net_admin,aid_net_bw_stats,aid_net_bw_acct,aid_readproc,aid_wakelock,aid_uhid,aid_everybody,aid_misc,aid_nobody,aid_app_start,aid_app_end,aid_cache_gid_start,aid_cache_gid_end,aid_ext_gid_start,aid_ext_gid_end,aid_ext_cache_gid_start,aid_ext_cache_gid_end,aid_shared_gid_start,aid_shared_gid_end,aid_isolated_start,aid_isolated_end,aid_user_offset root
temporarily_container_exec $container_name usermod -g aid_inet _apt 2>/dev/null
temporarily_container_exec $container_name usermod -a -G aid_inet,aid_net_raw portage 2>/dev/null
