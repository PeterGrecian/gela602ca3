#!/bin/bash

branch=$(git rev-parse --abbrev-ref HEAD)
remote=$(git config --get remote.origin.url)
commit=$(git log -1 --oneline | awk '{print $1}')

echo "{\"gitinfo\" : \"$remote $branch $commit\"}"