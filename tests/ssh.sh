#!/bin/bash

shift 1

user="$1"
machine="$2"
shift 2

echo ssh -l "$user" "$machine" "cd \"$PWD\"; hostname ; pwd ; ""$@"
ssh -l "$user" "$machine" "cd \"$PWD\"; hostname ; pwd ; ""$@" &
