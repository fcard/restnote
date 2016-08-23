#!/bin/bash
set -e                 # halt on error
set +m                 #
shopt -s lastpipe      # flexible while loops (maintain scope)
shopt -s extglob       # regular expressions
path="$(pwd)"
selfpath="$( dirname "$(readlink -f "$0")" )"
tmpfile="/tmp/$(basename $0).tmp.$(whoami)"



VERSION="0.1.1"

VersionLocation=~/.restnote/VERSION

if [[ -d ~/.restnote ]]; then
  if [[ -e "$VersionLocation" ]]; then
    INSTALLED_VERSION="$(cat < "$VersionLocation")"
  else
    INSTALLED_VERSION="0.1.0"
  fi
else
  INSTALLED_VERSION="0.0.0"
fi

if [[ ! "$(uname -o)" == "GNU/Linux" ]]; then
  echo -e "\nCurrently only Linux is supported.\n"
  exit 1
fi

export AutoYes=false
if [[ "$1" == "-y" ]]; then
  AutoYes=true
fi

ask(){
  local prompt="$1"
  local default="$2"
  if [[ "$AutoYes" == true ]]; then
    return 0
  else
    local choices="[Y/n]"
    if [[ "$default" == y || "$default" == "" ]]; then
      choices="[Y/n]"
    elif [[ "$default" == n ]]; then
      choices="[y/N]"
    else
      echo "Invalid default argument to ask: $default"
      exit 1
    fi
    res="$(printf "$prompt $choices")"
    read -p "$res " answer
    if [[ "$answer" =~ ([Yy](es)?|YES) ]]; then
      return 0
    elif [[ "$answer" =~ ([Nn]o?|NO) ]]; then
      return 1
    elif [[ "$answer" == "" ]]; then
      if [[ "$default" == y ]]; then
        return 0
      else
        return 1
      fi
    else
      ask "$prompt" "$default"
    fi
  fi
}

add_nw_node_links(){
  if [[ -x "$(command -v node)" ]]; then
    ln -s "$(command -v node)" ~/.restnote/bin/node
  else
    ln -s ~/.restnote/node-*/bin/node ~/.restnote/bin/node
  fi
  if [[ -x "$(command -v nw)" ]]; then
    ln -s "$(command -v nw)" ~/.restnote/bin/nw
  else
    ln -s ~/.restnote/node_modules/nw/bin/nw ~/.restnote/bin/nw
  fi
}


if [[ ! "$VERSION" == "0.0.0" ]]; then
  if [[ "$INSTALLED_VERSION" == "$VERSION" ]]; then
    if ask "\nDo you want to reinstall the restnote dependencies?" n; then
      echo
    else
      exit 0
    fi
  elif [[ "$INSTALLED_VERSION" == "0.1.0" ]]; then
    echo "Upgrading..."
    add_nw_node_links
    echo "Done!"
    echo "$VERSION" > "$VersionLocation"
    exit 0
  fi
else
  echo -e "\nThe following programs will be installed:"
  echo -e "Globally:"
  if [[ ! -x "$(command -v jupyter)" ]]; then
    echo "  jupyter"
  fi
  if [[ ! -x "$(command -v restview)" ]]; then
    echo "  restview"
  fi
  echo -e "Locally (at $HOME/.rstnote)"
  if [[ ! -x "$(command -v python3)" ]]; then
    echo "  python3"
  fi
  if [[ ! -x "$(command -v pip3)" ]]; then
    echo "  pip3"
  fi
  if [[ ! -x "$(command -v node)" ]]; then
    echo "  nodejs"
  fi
  if [[ ! -x "$(command -v nw)" ]]; then
    echo "  nw"
  fi
  echo "  restnote"
  echo "If you want to install any of them yourself please do so before proceeding."
  if ask "continue?" y; then
    echo
  else
    exit 0
  fi
fi


echo -e "\nInstalling dependencies...\n"
cd ~

if [[ -d .restnote ]]; then
  rm -r .restnote
fi

mkdir .restnote || exit 1
cd .restnote

echo "0.0.0" > "$VersionLocation"

if [[ ! -d bin ]]; then
  mkdir bin || exit 1
fi

if [[ ! -x "$(command -v xz)" ]]; then
  echo "Downloading xz..."
  wget "http://tukaani.org/xz/xz-5.2.2.tar.gz" -O "xz.tar.gz"
  tar -xvf "xz.tar.gz"
  cd xz-*
  ./configure
  make
  cd ..
  XZ=~/xz-*/src/xz/xz
else
  XZ="xz"
fi

if [[ ! -x "$(command -v npm)" ]]; then
  if [[ ! -d ./node-v* ]]; then
    echo "Downloading node.js..."
    wget "https://nodejs.org/dist/v6.3.0/node-v6.3.0-linux-x64.tar.xz" -O "node.tar.xz"
    "$XZ" -d "node.tar.xz"
    tar -xvf "node.tar"
    rm "node.tar"
  fi
  if [[ ! -d ./node_modules/nw ]]; then
    echo -e "\nInstalling nw.js locally... (might take a while)"
    mkdir "node_modules"
    ./node-v*/bin/node ./node-v*/bin/npm install "nw"
  fi
fi

installpip="no"
installjupyter="no"
installrestview="no"

if [[ ! -x "$(command -v 'restview')" ]]; then
  installpip="yes"
  installrestview="yes"
fi

if [[ ! -x "$(command -v 'jupyter')" ]]; then
  installpip="yes"
  installjupyter="yes"
fi

if [[ -x "$(command -v 'pip3')" ]]; then
  installpip="no"
fi

PYTHON_BINDIR=""

if [[ "$installpip" == "yes" ]]; then
  if [[ ! -x "$(command -v 'python3')" ]]; then
    echo -e "\nDownloading python 3 with pip..."
    wget "https://www.python.org/ftp/python/3.5.2/Python-3.5.2.tar.xz" -O "python3.tar.xz"
    "$XZ" -d "python3.tar.xz"
    tar -xvf "python3.tar"
    rm "python3.tar"
    mkdir python3
    cd ./Py*
    echo -e "\nBuilding python 3..."
    ./configure
    make
    make altinstall prefix="~/.restnote/python3" exec-prefix="~/.restnote/python3"
    cd ..
    echo -e "\nInstalling pip locally..."
    ./python3/bin/python3.5 -m ensurepip
    echo -e "#!/usr/bin/env sh\n\n~/.restnote/python3/bin/python3.5 -m pip \$@" > pip.sh
    PYTHON_BINDIR=~/.restnote/python3/bin
  else
    echo -e "\nDownloading pip..."
    wget "https://bootstrap.pypa.io/get-pip.py" -O "get-pip.py"
    echo -e "\nInstalling pip locally..."
    python3 get-pip.py
    echo -e "#!/usr/bin/env sh\n\npython3 -m pip \$@" > pip.sh
    PYTHON_BINDIR="$(dirname "$(command -v python3)")"
  fi
  ##
else
  PYTHON_BINDIR="$(pip3 -V | grep -o -P "/.*/(?=lib)" | echo "$(cat)bin")"
  echo -e "#!/usr/bin/env sh\n\npip3 \$@" > pip.sh
fi

chmod +x pip.sh

if [[ "$installjupyter" == "yes" ]]; then
  echo -e "\nInstalling jupyter..."
  ./pip.sh install jupyter
fi

if [[ "$installrestview" == "yes" ]]; then
  echo -e "\nInstalling restview..."
  ./pip.sh install restview
fi

ln -s "${PYTHON_BINDIR}/restview" ~/.restnote/bin/restview
ln -s "${PYTHON_BINDIR}/jupyter"  ~/.restnote/bin/jupyter
ln -s "$(readlink -m "$(dirname "$0")")/restnote.sh"  ~/.restnote/bin/restnote
add_nw_node_links

echo "$VERSION" > "$VersionLocation"

echo -e "\nInstallation sucessful! You may now run restnote with '$(dirname "$0")/restnote.sh'"

exit 0

# wait for all async child processes (because "await ... then" is used in powscript)
[[ $ASYNC == 1 ]] && wait


# cleanup tmp files
if ls /tmp/$(basename $0).tmp.$(whoami)* &>/dev/null; then
  for f in /tmp/$(basename $0).tmp.$(whoami)*; do rm $f; done
fi

exit 0

