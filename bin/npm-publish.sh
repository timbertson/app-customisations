#!/bin/bash
set -eu

[ "$#" -eq 1 ] || (echo "exactly 1 arg expected">&2; exit 1)
version="$1"

git show-ref "$version"
echo "CONFIRM: publish version $version"
read f

set -x

git archive --format=tgz --prefix='contents/' "$version" > npm-publish.tgz
npm publish npm-publish.tgz
