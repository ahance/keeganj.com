#!/bin/sh
set -eux

# zola check # Fails on linkedin link.
zola build
git add .
git commit -m "$1"
git push