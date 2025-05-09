#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

SEARCH="$1"

mapfile -t TAGS < <(git tag --sort version:refname)

LOW=0
HIGH=$((${#TAGS[@]} - 1))
TAG=""

echo "Binary searching ${#TAGS[@]} tags for '$SEARCH'..."

while [ $LOW -le $HIGH ]; do
    mid=$(( (LOW + HIGH) / 2 ))
    tag="${TAGS[$mid]}"

    echo "Checking tag: $tag"

    if git grep -q "$SEARCH" "$tag"; then
        TAG="$tag"
        HIGH=$((mid - 1))
    else
        LOW=$((mid + 1))
    fi
done

if [ -n "$TAG" ]; then
    echo "Earliest tag containing '$SEARCH': $TAG"
else
    echo "String '$SEARCH' not found in any tag"
fi
