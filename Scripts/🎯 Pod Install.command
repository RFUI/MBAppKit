#!/bin/sh
cd "$(dirname "$0")/.."
echo $PWD
pod install --verbose
./Scripts/sort_projects.sh
say "install done"
