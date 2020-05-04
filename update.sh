# pretty print
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
get_sudo() {
  sudo echo &> /dev/null
}


update() {
  get_sudo

  msg_title "Start global update"

  msg_heading "Update packages via apt-get"
  msg_step "Update packages"
  output_box sudo apt-get update
  msg_step "Upgrade packages"
  output_box sudo apt-get -y upgrade

  msg_heading "Update asdf-vm"
  msg_step "Fetch from git"
  output_box asdf update --head

  msg_heading "Update AWS Cli v2"
  msg_step "Fetch from online"
  curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" \
    -o "awscliv2.zip"
  mute unzip awscliv2.zip
  msg_step "Update via script"
  output_box sudo ./aws/install --update
  msg_step "Clean up"
  rm -rf ./aws

  msg_heading "Update via snap"
  msg_step "Update snap packages"
  output_box sudo snap refresh

  msg_heading "Update zinit, zinit plugins"
  msg_step "Update zinit"
  output_box zinit self-update
  msg_step "Update zinit plugins"
  output_box zinit update
}
