#!/usr/bin/env bash

shopt -s nocasematch

pid=$$

while [ "$pid" -ne 1 ]; do
    parent=$(ps -o ppid= -p "$pid" | tr -d ' ')
    pcmd=$(ps -o command= -p "$parent" | tr -d ' ')

    if [[ "$pcmd" == *"code"* ]]; then
        exec code --wait --reuse-window "$@"
    elif [[ "$pcmd" == *"cursor"* ]]; then
        exec cursor --wait --reuse-window "$@"
    fi

    pid=$parent
done

exec code --wait "$@"
