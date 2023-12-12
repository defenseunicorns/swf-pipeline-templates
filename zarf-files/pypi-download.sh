#!/bin/bash

VERSION="${1:-3.12.1}"

mkdir -p pypi/$VERSION

if command -v pip3 >/dev/null 2>&1; then
    pip3 download -d ./pypi/$VERSION --python-version=$VERSION --only-binary=:all: twine check-wheel-contents
elif command -v pip >/dev/null 2>&1; then
    pip download -d ./pypi/$VERSION --python-version=$VERSION --only-binary=:all: twine check-wheel-contents
else
    echo "pip is not installed or not on PATH"
    exit 1
fi
