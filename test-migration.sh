#!/bin/bash

set -e

log_dir=$(date -u +%Y%m%dT%H%M%S)
mkdir "$log_dir"
go work use ../librarian
packages=$(cat packages-to-migrate.txt)
echo "Results are in $log_dir"
# Clean up any aborted previous generation
git reset --hard > /dev/null
git clean -d -f > /dev/null

for pkg in $packages
do
  echo "$(date -u +%H:%M:%S) Generating $pkg"
  mkdir -p "$log_dir/$pkg"
  go run ../librarian/cmd/librarian generate "$pkg" > "$log_dir"/"$pkg"/log.txt 2>&1
  git status > "$log_dir"/"$pkg"/status.txt
  git diff > "$log_dir"/"$pkg"/diff.txt
  git reset --hard > /dev/null
  git clean -d -f > /dev/null
done
