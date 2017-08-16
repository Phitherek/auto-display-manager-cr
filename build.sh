#!/bin/sh

mkdir -p bin
cd bin
echo "Building AutoDisplayManager Configurator in release mode..."
crystal build ../src/autodm-config.cr --release
echo "Building AutoDisplayManager in release mode..."
crystal build ../src/autodm.cr --release
echo "Build complete!"
cd ..
