#!/bin/bash

set -e

if [ "$(uname)" == "Linux" ]; then
    LIBS=(-lglfw -lGLEW -lGL -lX11 -lpthread -ldl)
    CXX="g++"
elif [ "$(uname)" == "Darwin" ]; then
    LIBS=(-lglfw -framework OpenGL -framework Cocoa -framework IOKit -framework CoreVideo)
    CXX="clang++"
else
    echo "UNSUPPORTED OS"
    exit 1
fi

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

rm -rf build
mkdir -p bin build

"$CXX" "${FLAGS[@]}" \
    -I./lib \
    src/*.cpp \
    "${LIBS[@]}" \
    -o build/device

if [ "$MODE" = "release" ]; then
    cp -f build/device bin/
    if [ -d "res" ]; then
        if command -v rsync >/dev/null 2>&1; then
            rsync -av --delete res/ bin/res/ >/dev/null
        else
            cp -R res bin/res
        fi
    fi
else
    ln -sf ../build/device bin/device
    if [ -d "res" ]; then
        ln -s ../res bin/res
    fi
fi

echo "BUILD COMPLETE"