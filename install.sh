#!/usr/bin/env bash

set -e

export DOTDIR="$( cd "$( dirname "$0" )" && pwd )"

backup () {
  local file=$1
  cp -r "$file" "$file.bak"
}

install_symlink() {
  local target_file=$1
  local source_file=$2
  echo "installing ${source_file} to ${target_file}"

  if [ -e "$target_file" ]; then
    if [ "`readlink $target_file`" = "$source_file" ]; then
      return
    fi
    backup "$target_file" && rm -rf $target_file
  fi

  ln -sf "$source_file" "$target_file"
}

####

for dotfile in `ls | grep -vE "install|sshconfig|README"`; do
  install_symlink "$HOME/.${dotfile}" $DOTDIR/$dotfile
done

install_symlink "$HOME/.ssh/config" "$DOTDIR/sshconfig"

if which git > /dev/null; then
  git submodule update --init
  git submodule update #Was being buggy for some reason so added this
  git config --global core.excludesfile $HOME/.gitignore
else
  echo "Please install git and run 'git submodule update --init'"
fi
