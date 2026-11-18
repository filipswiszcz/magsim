#!/bin/bash

set -e

MODE=$1
TARGET=$2

if [ "$TARGET" == "web" ]; then
    LIBS=(-s USE_GLFW=3 -s MIN_WEBGL_VERSION=2 -s MAX_WEBGL_VERSION=2)
    CXX="em++"
    OUT="build/index.html"
else
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
    OUT="build/device"
fi

case "$MODE" in
    dev)
        FLAGS=(-g -O0 -Wall -Wextra -std=c++17)
        ;;
    release)
        FLAGS=(-O3 -Wall -Wextra -std=c++17)
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
    -I./lib/imgui \
    -I./lib/imgui/backends \
    src/*.cpp \
    lib/imgui/*.cpp \
    lib/imgui/backends/imgui_impl_glfw.cpp \
    lib/imgui/backends/imgui_impl_opengl3.cpp \
    "${LIBS[@]}" \
    -o "$OUT"

if [ "$TARGET" == "web" ]; then
    echo "WEB BUILD COMPLETE"
    exit 0
fi

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