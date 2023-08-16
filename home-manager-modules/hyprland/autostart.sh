#!/usr/bin/env bash

waybar &
sleep 0.5 && swww init &
# dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP &
sleep 5 && megasync &
easyeffects --gapplication-service &
# /usr/lib/kdeconnectd &
wl-clip-persist --clipboard regular &
copyq --start-server &
mako &
# syncthing-tray &
wlsunset -s 18:00 -S 8:00 -t 4500
