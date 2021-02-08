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

  if [[ -d "$HOME/.aws" ]]; then
    msg_heading "Update AWS Cli v2"
    msg_step "Fetch from online"
    curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" \
      -o "awscliv2.zip"
    mute unzip awscliv2.zip
    msg_step "Update via script"
    output_box sudo ./aws/install --update
    msg_step "Clean up"
    rm -rf ./aws
    rm -rf awscliv2.zip
  fi

  if [[ -d "$HOME/snap" ]]; then
    msg_heading "Update via snap"
    msg_step "Update snap packages"
    output_box sudo snap refresh
  fi

  if [[ -f "/usr/bin/yarn" ]]; then
    msg_heading "Update via yarn"
    msg_step "Update yarn packages"
    output_box yarn global upgrade
  fi

  if [[ -f "$HOME/.poetry/bin/poetry" ]]; then
    msg_heading "Update via poetry"
    msg_step "Update poetry"
    output_box poetry self update
  fi

  if [[ -d "$HOME/.zinit" ]]; then
    msg_heading "Update zinit, zinit plugins"
    msg_step "Update zinit and plugins"
    output_box zinit update
  fi

  if [[ -d "$HOME/.config/ulauncher/user-themes/one-dark-ulauncher" ]]; then
    msg_heading "Update ulauncher theme"
    msg_step "Fetch from git"
    output_box git -C ~/.config/ulauncher/user-themes/one-dark-ulauncher \
      pull origin master
  fi

  msg_heading "Update spicetify-cli"
  msg_step "Executing scripts"
  {
    curl -fsSL https://raw.githubusercontent.com/khanhas/spicetify-cli/master/install.sh | sh
  } | output_box cat

  # Update miscellaneous
  msg_heading "Update miscellaneous"


  # Update global theme
  msg_step "Update global theme"
  msg_normal "download theme from git"
  mute git clone https://github.com/vinceliuice/Qogir-kde.git ./temp-git

  msg_normal "install"
  cd temp-git || exit
  output_box ./install.sh
  cd ..

  msg_normal "clean up"
  rm -rf temp-git


  # Update apple-cursor
  msg_step "Update apple-cursor"
  curl -sL \
    https://github.com/ful1e5/apple_cursor/releases/latest/download/macOSBigSur.tar.gz \
    -o "apple-cursor.tar.gz"

  rm -rf ~/.icons/apple-cursor
  mkdir -p ~/.icons/apple-cursor
  tar -xf apple-cursor.tar.gz -C ~/.icons/apple-cursor --strip-components=1
  rm -rf apple-cursor.tar.gz


  # Update la capitaine icon theme
  msg_step "Update la capitaine icon theme"
  msg_normal "clone from git"
  mute git clone https://github.com/keeferrourke/la-capitaine-icon-theme.git \
    ./temp-git

  msg_normal "build la-capitaine-icon-theme"
  cd temp-git || exit
  echo y | mute ./configure
  cd ..

  msg_normal "copy to icon directory"
  rm -rf ~/.local/share/icons/la-capitaine-icon-theme
  mkdir -p ~/.local/share/icons
  cp -r temp-git ~/.local/share/icons/la-capitaine-icon-theme

  # fix inherits theme
  sed -i -Ee "s|^Inherits=.*|Inherits=breeze|g" \
    ~/.local/share/icons/la-capitaine-icon-theme/index.theme

  # fix st terminal icon
  ln -s \
    "$HOME/.local/share/icons/la-capitaine-icon-theme/apps/scalable/utilities-terminal.svg" \
    "$HOME/.local/share/icons/la-capitaine-icon-theme/apps/scalable/st.svg"

  msg_normal "clean up"
  rm -rf temp-git


  # Update latte applets
  msg_step "Update latte applets, kwin scripts"
  msg_normal "download psifidotos/applet-latte-spacer"
  mute git clone https://github.com/psifidotos/applet-latte-spacer.git \
    ./temp-git
  mute plasmapkg2 -i temp-git
  rm -rf temp-git

  # psifidotos/applet-window-title
  msg_normal "download psifidotos/applet-window-title"
  mute git clone https://github.com/psifidotos/applet-window-title.git \
    ./temp-git
  mute plasmapkg2 -i temp-git
  rm -rf temp-git

  # varlesh/org.kde.plasma.digitalclock.wl
  msg_normal "download psifidotos/org.kde.plasma.digitalclock.wl"
  mute git clone https://github.com/varlesh/org.kde.plasma.digitalclock.wl.git \
    ./temp-git
  mute plasmapkg2 -i temp-git
  rm -rf temp-git

  # psifidotos/kwinscript-window-colors
  msg_normal "download psifidotos/kwinscript-window-colors"
  mute git clone https://github.com/psifidotos/kwinscript-window-colors.git \
    ./temp-git
  mute plasmapkg2 -i temp-git
  rm -rf temp-git


  # Update applet window appmenu
  msg_step "Update applet window appmenu"
  msg_normal "clone from git"
  mute git clone https://github.com/psifidotos/applet-window-appmenu.git \
    ./temp-git
  msg_normal "build and install"
  cd temp-git || exit
  output_box silent sh install.sh
  cd ..
  msg_normal "clean up"
  rm -rf temp-git


  # Update applet window buttons
  msg_step "Update applet window buttons"
  msg_normal "clone from git"
  mute git clone https://github.com/psifidotos/applet-window-buttons.git \
    ./temp-git
  msg_normal "build and install"
  cd temp-git || exit
  output_box silent sh install.sh
  cd ..
  msg_normal "clean up"
  rm -rf temp-git


  # Update xft (emoji support)
  mute git clone https://gitlab.freedesktop.org/xorg/lib/libxft.git ./temp-git

  msg_normal "install xft"
  cd temp-git || exit
  wget -qO- \
    'https://gitlab.freedesktop.org/xorg/lib/libxft/merge_requests/1.patch' \
    | patch -p1
  {
    silent autoreconf --force --install
    silent ./configure
    silent make
    silent sudo make install
  } | output_box cat

  msg_normal "linking symlink"
  sudo ln -sfn /usr/local/lib/libXft.so.2.3.3 \
    /usr/lib/x86_64-linux-gnu/libXft.so.2.3.3

  msg_normal "clean up"
  sudo ldconfig
  cd ..
  rm -rf temp-git


  # Update st terminal
  msg_step "Update st terminal"
  msg_normal "download theme from git"
  mute git clone https://github.com/LukeSmithxyz/st.git ./temp-git

  msg_normal "install"
  cd temp-git || exit
  output_box silent sudo make install
  cd ..

  msg_normal "clean up"
  sudo rm -rf temp-git


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
