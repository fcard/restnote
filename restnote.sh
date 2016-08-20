#!/bin/bash
set -e                 # halt on error
set +m                 #
shopt -s lastpipe      # flexible while loops (maintain scope)
shopt -s extglob       # regular expressions
path="$(pwd)"
selfpath="$( dirname "$(readlink -f "$0")" )"
tmpfile="/tmp/$(basename $0).tmp.$(whoami)"



if [[ -d ~/.rstnote/ ]]; then
  cd "$(dirname "$0")/src"
  if [[ ! -x "$(command -v nw)" ]]; then
    NW=~/.restnote/node_modules/nwjs/nw
  else
    NW=nw
  fi
  PATH="$PATH:$HOME/.restnote/bin" "$NW" .
else
  echo -e "\nYou need to run deps.sh before you can use the program!\n"
fi

# wait for all async child processes (because "await ... then" is used in powscript)
[[ $ASYNC == 1 ]] && wait


# cleanup tmp files
if ls /tmp/$(basename $0).tmp.fabio* &>/dev/null; then
  for f in /tmp/$(basename $0).tmp.fabio*; do rm $f; done
fi

exit 0

