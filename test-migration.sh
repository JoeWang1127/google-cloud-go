#!/bin/bash

set -e

log_dir=$(date -u +%Y%m%dT%H%M%S)
mkdir "$log_dir"
packages=$(cat packages-to-migrate.txt)
echo "Results are in $log_dir"
# Clean up any aborted previous generation
git reset --hard > /dev/null
git clean -d -f > /dev/null
echo "Build librarian binary"
go build -C ../librarian -o ../google-cloud-go/librarian ./cmd/librarian
for pkg in $packages
do
  echo "$(date -u +%H:%M:%S) Generating $pkg"
  mkdir -p "$log_dir/$pkg"
  ./librarian generate "$pkg" > "$log_dir"/"$pkg"/log.txt 2>&1
  git status > "$log_dir"/"$pkg"/status.txt
  git diff > "$log_dir"/"$pkg"/diff.txt
  git restore "$pkg"
  git restore "internal/generated/snippets/$pkg"
done

echo "Remove librarian binary"
rm librarian