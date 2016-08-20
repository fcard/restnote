#!/usr/bin/env sh

RstNotePath="$(readlink -m "$(dirname $0)/..")"

docker build -t rstnote "$RstNotePath"
docker run -it rstnote
