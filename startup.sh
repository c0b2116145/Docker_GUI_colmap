#!/bin/bash

# Xvfb :0 -screen 0 1280x720x24 &

# startxfce4 &

# xfce4-clipman &

# if [ -n "$VNC_PASSWORD" ]; then
#     echo -n "$VNC_PASSWORD" > /.password1
#     x11vnc -storepasswd $(cat /.password1) /.password2
#     chmod 400 /.password*
#     x11vnc -display :0 -rfbauth /.password2 -forever -usepw -shared -xkb -noxdamage -noxrecord -noxfixes -reopen -rfbport 5900 -bg
#     export VNC_PASSWORD=
# else
#     # passwordless
#     x11vnc -display :0 -forever -shared -nopw -xkb -noxdamage -noxrecord -noxfixes -reopen -rfbport 5900 -bg
# fi

# /opt/noVNC/utils/novnc_proxy --vnc localhost:5900 --listen 0.0.0.0:6080

set -e

# xrdp sesman の起動
/usr/sbin/xrdp-sesman 

# xrdp サーバーの起動（--nodaemonでフォアグラウンド）
exec /usr/sbin/xrdp --nodaemon

