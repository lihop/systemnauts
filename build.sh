#!/bin/sh
set -e

# Get the absolute path to the directory this script is in.
PROJECT_DIR="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# Run script inside a nix shell if it is available.
if command -v nix-shell && [ $NIX_PATH ] && [ -z $IN_NIX_SHELL ]; then
	cd ${PROJECT_DIR}
	NIX_PATH=./:$NIX_PATH
	nix-shell --pure --run "bash ./build.sh"
	exit
fi

# Build the Godot engine.
GODOT_ENGINE_DIR=${PROJECT_DIR}/thirdparty/godot
if [ ! -d $GODOT_XTERM_DIR ]; then
	cd $PROJECT_DIR
	git submodule update --init --recursive -- $GODOT_XTERM_DIR
fi
cd $GODOT_ENGINE_DIR
rm -rf ./bin/*.so
if [ ! -f ./modules/mono/glue/mono_glue.gen.cpp ]; then
	# Generate Mono glue.
	if [ ! -z "$DISPLAY" ];	then
		scons target=release_debug platform=x11 tools=yes module_mono_enabled=yes mono_glue=no mono_prefix=$MONO_PREFIX -j$(nproc)
		./bin/godot.x11.opt.tools.64.mono --generate-mono-glue modules/mono/glue
	fi
	rm -rf ./bin/*.so
fi
if [ ! -z "$DISPLAY" ]; then
	scons target=release_debug platform=x11 tools=yes module_mono_enabled=yes mono_prefix=$MONO_PREFIX -j$(nproc)
fi
rm -rf ./bin/*.so

# Build thirdparty dependencies.
cd $PROJECT_DIR
cd thirdparty/godotdetour
if [ ! -f godot-cpp/bin/libgodot-cpp.linux.release.64.a ]; then
	cd godot-cpp
	if [ ! -z "$DISPLAY" ]; then
		scons platform=linux generate_bindings=yes bits=64 target=release -j$(nproc)
	else
		scons platform=server generate_bindings=yes bits=64 target=release -j$(nproc)
	fi
	cd ..
fi
scons platform=linux target=release -j$(nproc)

cd $PROJECT_DIR
cd thirdparty/godot-xterm/addons/godot_xterm/native
./build.sh

# Build solution.
cd $PROJECT_DIR/game
dotnet msbuild /t:restore
dotnet msbuild
