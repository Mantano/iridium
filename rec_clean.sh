#!/bin/bash
# Copyright (c) 2022 Mantano. All rights reserved.
# Unauthorized copying of this file, via any medium is strictly prohibited.
# Proprietary and confidential.

folders=("components/commons"
  "components/lcp"
  "components/navigator"
  "components/opds"
  "components/server"
  "components/shared"
  "components/streamer"
  "reader_widget"
  "demo-app"
)
for i in "${folders[@]}"; do
  echo "flutter clean $i"
  (cd "$i" || exit; flutter clean)
done
