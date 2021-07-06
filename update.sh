#!/bin/zsh

update() {
  msg() {
    declare -A weights=(
      ["normal"]="0;"
      ["bold"]="1;"
    )

    declare -A colors=(
      ["black"]="30m"
      ["red"]="31m"
      ["green"]="32m"
      ["yellow"]="33m"
      ["blue"]="34m"
      ["purple"]="35m"
      ["cyan"]="36m"
      ["white"]="37m"
    )

    local weight="${weights[$1]}"
    local color="${colors[$2]}"
    # shellcheck disable=SC2124
    local message="${@:3}"

    echo "\e[${weight}${color}${message}\e[0m"
  }

  # pretty print title
  msg_title() {
    msg bold blue "\n$*"
  }

  # pretty print heading
  msg_heading() {
    msg bold green "> $*"
  }

  # pretty print step
  msg_step() {
    msg normal yellow "  - $*"
  }

  # print line without style
  msg_normal() {
    echo "    • $*"
  }

  # output box (highlight the area)
  output_box() {
    echo "============================================================"
    "$@"
    echo "============================================================"
    echo ""
  }

  # Silent (stdout)
  silent() {
    "$@" > /dev/null
  }

  # Mute (stdout, stderr)
  mute() {
    "$@" &> /dev/null
  }

  # Get sudo permission at first
  sudo echo &> /dev/null

  msg_title "Start global update"

  if [[ -d "$HOME/.cfg" ]]; then
    msg_heading "Update dotfiles submodule"
    msg_step "Update submodule"
    git --git-dir="$HOME/.cfg/" --work-tree="$HOME" \
      submodule update --remote --recursive
  fi

  if [[ -f "/usr/bin/apt-get" ]]; then
    msg_heading "Update packages via apt-get"
    msg_step "Update packages"
    output_box sudo apt-get update
    msg_step "Upgrade packages"
    output_box sudo apt-get -y upgrade
  fi

  if [[ -d "$HOME/.zinit" ]]; then
    msg_heading "Update zinit, zinit plugins"
    msg_step "Update zinit and plugins"
    output_box zinit update
  fi

  # Update miscellaneous
  msg_heading "Update miscellaneous"


  # Update apple-cursor
  msg_step "Update apple-cursor"
  curl -sL \
    https://github.com/ful1e5/apple_cursor/releases/latest/download/macOSBigSur.tar.gz \
    -o "apple-cursor.tar.gz"

  rm -rf ~/.icons/apple-cursor
  mkdir -p ~/.icons/apple-cursor
  tar -xf apple-cursor.tar.gz -C ~/.icons/apple-cursor --strip-components=1
  rm -rf apple-cursor.tar.gz


  # clean up local functions
  unfunction msg
  unfunction msg_title
  unfunction msg_heading
  unfunction msg_step
  unfunction msg_normal
  unfunction output_box
  unfunction silent
  unfunction mute
}
