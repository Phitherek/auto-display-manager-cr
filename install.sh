#!/bin/sh

if [ -z "$PREFIX" ]; then
	PREFIX="/usr/local"
fi

echo "Installing AutoDisplayManager to prefix $PREFIX..."
mkdir -p "$PREFIX/bin"
cp bin/* "$PREFIX/bin"
echo "AutoDisplayManager installed!"
