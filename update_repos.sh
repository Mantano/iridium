#!/bin/bash
folders=("."
  "mno_commons_dart"
  "mno_lcp_dart"
  "mno_lcp_native"
  "mno_opds_dart"
  "mno_navigator_flutter"
  "mno_server_dart"
  "mno_shared_dart"
  "mno_streamer_dart"
)
for i in "${folders[@]}"; do
  echo "Git pull $i"
  git -C $i pull
done
