#!/bin/bash
# Copyright (c) 2022 Mantano. All rights reserved.
# Unauthorized copying of this file, via any medium is strictly prohibited.
# Proprietary and confidential.

folders=(
  "components/commons"
  "components/shared"
  "components/webview"
  "components/server"
  "components/streamer"
  "components/opds"
  "components/navigator"
  "components/lcp"
  "reader_widget"
  "demo-app"
)
for i in "${folders[@]}"; do
  echo "flutter pub get $i"
  (cd "$i" || exit; flutter pub get)
done
