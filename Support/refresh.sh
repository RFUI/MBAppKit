#!/bin/bash

export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8

cd ..
echo $PWD
pod install --no-ansi
./Scripts/sort_projects.sh
