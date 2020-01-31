#!/bin/sh
cd "$(dirname "$0")/.."
echo $PWD
pod update --verbose
./Scripts/sort_projects.sh
say "update done"
