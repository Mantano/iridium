#!/bin/bash
folders=("."
)
for i in "${folders[@]}"; do
  echo "Git pull $i"
  git -C $i pull
done
