#!/bin/bash
# Copyright (c) 2022 Mantano. All rights reserved.
# Unauthorized copying of this file, via any medium is strictly prohibited.
# Proprietary and confidential.

for dir in $(find . -name pubspec.yaml -exec dirname {} \;); do
  echo "Running 'flutter pub upgrade && flutter pub get' in directory: $dir"
  # change into the directory and run "flutter pub get"
  (cd "$dir" && flutter pub get)
done
