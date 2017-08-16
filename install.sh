#!/bin/sh

if [ -z "$PREFIX" ]; then
	PREFIX="/usr/local"
fi

echo "Installing AutoDisplayManager to prefix $PREFIX..."
cp bin/* "$PREFIX/bin"
echo "AutoDisplayManager installed!"
