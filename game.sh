#!/bin/sh
echo -ne '\033c\033]0;Untitled Project 2\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/game.x86_64" "$@"
