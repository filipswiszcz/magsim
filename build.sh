#!/bin/bash

set -e

MODE=$1

case "$MODE" in
    dev)
        FLAGS=(-g -O0 -Wall -Wextra -std=c++17 -pthread)
        ;;
    release)
        FLAGS=(-O3 -Wall -Wextra -std=c++17 -pthread)
        ;;
    *)
        echo "BUILD OPTIONS: dev, release"
        exit 1
        ;;
esac

CXX="g++"

rm -rf build
mkdir -p bin build

"$CXX" "${FLAGS[@]}" \
    -I./lib \
    src/*.cpp \
    -lcurl \
    -o build/device

cp -f build/device bin/

echo "BUILD COMPLETE"