#!/usr/bin/env sh

RestNotePath="$(readlink -m "$(dirname $0)/../")"
powscript --compile "$RestNotePath/shell/deps.pow" > "$RestNotePath/deps.sh"
powscript --compile "$RestNotePath/shell/restnote.pow" > "$RestNotePath/restnote.sh"

chmod +x "$RestNotePath/deps.sh"
chmod +x "$RestNotePath/restnote.sh"
