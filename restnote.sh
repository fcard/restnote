#!/bin/bash
set -e                 # halt on error
set +m                 #
shopt -s lastpipe      # flexible while loops (maintain scope)
shopt -s extglob       # regular expressions
path="$(pwd)"
selfpath="$( dirname "$(readlink -f "$0")" )"
tmpfile="/tmp/$(basename $0).tmp.$(whoami)"



if [[ -d "$HOME/.restnote/" ]]; then
  PATH="$PATH:$HOME/.restnote/bin" nw "$selfpath/src"
else
  echo -e "\nYou need to run deps.sh before you can use the program!\n"
fi

# wait for all async child processes (because "await ... then" is used in powscript)
[[ $ASYNC == 1 ]] && wait


# cleanup tmp files
if ls /tmp/$(basename $0).tmp.$(whoami)* &>/dev/null; then
  for f in /tmp/$(basename $0).tmp.$(whoami)*; do rm $f; done
fi

exit 0

