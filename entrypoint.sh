#!/bin/sh
set -eu

START_DIR="${START_DIR:-/home/coder/project}"

mkdir -p $START_DIR

sudo chown coder:coder $START_DIR
sudo chmod 775 $START_DIR

exec dumb-init /usr/bin/code-server "$@"