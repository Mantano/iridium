#!/bin/bash
folders=("commons"
  "navigator"
  "server"
  "shared"
  "streamer"
  "webview"
)
for i in "${folders[@]}"; do
  echo "flutter pub get $i"
  (cd "$i" || exit; flutter pub get)
done
