#!/bin/bash

PREVIOUS_VERSION=$(git show HEAD~1:package.json | jq -r .version)
CURRENT_VERSION=$(jq -r .version package.json)

if [[ "$PREVIOUS_VERSION" == "$CURRENT_VERSION" ]]; then
    echo "version="
else
    echo "version=$CURRENT_VERSION"
fi >>"$GITHUB_OUTPUT"
