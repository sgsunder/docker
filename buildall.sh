#!/bin/sh
find . -type d -maxdepth 1 -mindepth 1 -print \
    | grep -v ".git" \
    | sed -e "s;./;;g" \
    | xargs -n 1 -I {} \
        docker build -t "sgsunder/{}:latest" "$(git rev-parse --show-toplevel)/{}"
