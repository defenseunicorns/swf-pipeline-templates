#!/bin/bash

GLPAT="$1"

GLURL="$2"

VERSION="${3:-3.12.1}"

PYPI_PROJ_ID=$(./glab api projects |
            ./jq '.[] | [.id, .name, .path, .visibility] | @sh' |
            sed 's/"//g' |
            sed "s/'//g" |
            sed "s/ /,/g" |
            grep pypi-intake |
            cut -d ',' -f1)

GLUSR="root"

mkdir -p pypi/$VERSION

if command -v pip3 >/dev/null 2>&1; then
    PIP_COMMAND="pip3"
elif command -v pip >/dev/null 2>&1; then
    PIP_COMMAND="pip"
else
    echo "pip is not installed or not on PATH"
    exit 1
fi

if command -v python3 >/dev/null 2>&1; then
    PYTHON_COMMAND="python3"
elif command -v python >/dev/null 2>&1; then
    PYTHON_COMMAND="python"
else
    echo "python is not installed or not on PATH"
    exit 1
fi

$PIP_COMMAND install pypi/${VERSION}/*.whl

TWINE_PASSWORD=$GLPAT \
  TWINE_USERNAME=$GLUSR \
  $PYTHON_COMMAND -m twine upload \
  --skip-existing \
  --repository-url https://${GLURL}/api/v4/projects/${PYPI_PROJ_ID}/packages/pypi pypi/${VERSION}/*.whl