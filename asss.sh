#!/bin/bash

umask "077"
set -o pipefail
set +x
set -f

PREFIX="${ASS_DIRECTORY:-$HOME/.ass}"
TIMEOUT="${ASS_COPY_TIME:-15}"
KEYFILE="${ASS_AGE_KEYFILE:-$PREFIX/.key.age}"

recipientfile="$PREFIX/.recipient.txt"

PROGRAM="${0##*/}"

help() {
  cat <<EOF
Age Secret Store is simple password manager inspired by pass which use Age <https://github.com/FiloSottile/age> as encryption. Usage:
  $PROGRAM init [--no-password -n] [--keyfile -k <keyfile>]
      Create new Age Secret Storage. If you not use password protected keys you should use -n flag. Keys are automatically generated if not exist. Define custom key location (existing or not) via -k.
  $PROGRAM add [--generate-password -g] [--symbol-disable -s] [--length -l <number>] [--recipient -r <recipient>] <names>
      Add new entries. Optionally generate random passwords with given length or no special symbols. You can define additional recipients.
  $PROGRAM ls
      List entries.
  $PROGRAM show [--keyfile -k <keyfile>] <name>
      Decrypt entry and print to stdout. Define key file if needed.
  $PROGRAM cp [--keyfile -k <keyfile>] <name>
      Decrypt entry and copy to clipboard. Clipboard will be cleared in $TIMEOUT seconds. You can define custom time in ASS_COPY_TIME. Currently work only with klipper and wl-clipboard.
  $PROGRAM rm <names>
      Remove entries.
  $PROGRAM passgen [--symbol-disable -s] [--length -l <number>] [--copy -c]
      Generate random password. Optionally define password length (default 20) or disable special symbols. Copy without printing to stdout.
  $PROGRAM destroy
      Remove password storage.
  $PROGRAM help
      Show this help.
Environment variables:
  ASS_DIRECTORY – location of Age Secret Storage, default: ~/.ass
  ASS_AGE_KEYFILE – secret age key, default: ASS_DIRECTORY/.key.age
  ASS_COPY_TIME – copy timeout, default: 15
EOF
}

init() {
  local nopass
  clear
  gum style --foreground 333 --border-foreground 212 --border double --align center --width 50 --margin "1 2" --padding "2 4" 'Age Secret Store' 'No more pain in ass!'
  if ! gum confirm "You don't have Age Secret Store. Create new?"
  then
    killme "ERROR: You must create Age Secret Store to use this program."
  fi
  gum confirm "Create password protected keyfile?"
  nopass="$?"
  if [[ ! -e "$PREFIX" ]]
  then
    mkdir -p "$PREFIX"
  else
    killme "ERROR: $PREFIX exist. Remove $PREFIX or choose other location in ASS_DIRECTORY."
  fi
  if [[ -e "$KEYFILE" ]]
  then
    if [[ "$nopass" == 0 ]]
    then
      age -d "$KEYFILE" | age-keygen -y > "$recipientfile" || exit 1
    else
      age-keygen -y "$KEYFILE" > "$recipientfile" || exit 1
    fi
  else
    mkdir -p "$(dirname "$KEYFILE")"
    if [[ "$nopass" == 0 ]]
    then
      age-keygen 2> "$recipientfile" | age -a -p > "$KEYFILE"
      cut -f 2 -d ':' "$recipientfile" | tr -d " " | tee "$recipientfile" > /dev/null
    else
      age-keygen -o "$KEYFILE" 2> /dev/null
      age-keygen -y "$KEYFILE" > "$recipientfile"
    fi
  fi
  gum style --foreground 333 "Age Secret Store initialized succesfully"
  gum input
}

add() {
  # TODO implement this
  local passgen
  # local options passgen=0 pwgenopts="" length=20 recipients=""
  # options="$(getopt -o gsl:r: -l generate-password,symbol-disable,length:,recipient: -n "$PROGRAM" -- "$@")"
  # eval set -- "$options"
  # while true
  # do
  #   case "$1" in
  #     -g|--generate-password) passgen=1; shift ;;
  #     -s|--symbol-disable) pwgenopts="$1"; shift ;;
  #     -l|--length) length="$1 $2"; shift 2 ;;
  #     -r|--recipient) recipients+="-r $2 "; shift 2;;
  #     --) shift; break
  #   esac
  # done
  # [[ -e "$PREFIX" ]] || killme "ERROR: Age Secret Storage not exist."
  # while [[ -n "$1" ]]
  # do
  passgen=0
  entry=$(gum input --placeholder "Enter entry name")
  if [[ -e "$PREFIX/$entry" ]]
  then
    if ! gum confirm "$(gum style --foreground=333 "$entry") exist, do you want overwrite it?"
    then
      return
    fi
  fi
  if [[ "$passgen" == 0 ]]
  then
    password=$(gum input --placeholder "Enter password for $entry" --password)
    password_again=$(gum input --placeholder "Retype password for $entry" --password)
    if [[ "$password" == "$password_again" ]]
    then
      mkdir -p "$PREFIX/$(dirname "$entry")"
      echo "$password" | age -e -R "$recipientfile" $recipients > "$PREFIX/$entry" || exit 1
    else
      gum style --foreground f00 --bold "Passwords do not match. Entry not added."
      gum input
      return
    fi
  else
    mkdir -p "$PREFIX/$(dirname "$entry")"
    passgen $pwgenopts $length | age -e -R "$recipientfile" $recipients > "$PREFIX/$entry" || exit 1
  fi
  echo "Password for $(gum style --foreground 333 "$entry") added."
  gum input
}

show() {
  local choice
  [[ -e "$KEYFILE" ]] || killme "ERROR: Keyfile not exist."
  if [[ -z "$(find -L "$PREFIX" \( -name ".*" \) -o -type f -print 2>/dev/null)" ]]
  then
    gum style --foreground f00 --bold "Age Secret Store is empty!"
  else
    choice=$(find -L "$PREFIX" \( -name ".*" \) -o -type f -print 2>/dev/null | sed -e "s#${PREFIX}/\{0,1\}##" | sort | gum filter)
    gum style --foreground=333 "$(age -d -i "$KEYFILE" "$PREFIX/$choice")" || exit 1
  fi
  gum input
}

copy() {
  local choice
  [[ -e "$KEYFILE" ]] || killme "ERROR: Keyfile not exist."
  if [[ -z "$(find -L "$PREFIX" \( -name ".*" \) -o -type f -print 2>/dev/null)" ]]
  then
    gum style --foreground f00 --bold "Age Secret Store is empty!"
    gum input
  else
    choice=$(find -L "$PREFIX" \( -name ".*" \) -o -type f -print 2>/dev/null | sed -e "s#${PREFIX}/\{0,1\}##" | sort | gum filter)
    just_copy "$(age -d -i "$KEYFILE" "$PREFIX/$choice")" "$choice" || exit 1
  fi
}

just_copy() {
  local options copycommand clearcommand protect=0 tmout="$TIMEOUT"
  options="$(getopt -o p -l protect -n "$PROGRAM" -- "$@")"
  eval set -- "$options"
  while true
  do
    case "$1" in
      -p|--protect) protect=1; shift ;;
      --) shift; break
    esac
  done
  # set clipboard commands
  if [[ "$XDG_SESSION_DESKTOP" == KDE ]]
  then
    copycommand="qdbus org.kde.klipper /klipper org.kde.klipper.klipper.setClipboardContents"
    clearcommand="qdbus org.kde.klipper /klipper org.kde.klipper.klipper.clearClipboardHistory"
  elif [[ "$XDG_SESSION_TYPE" == wayland ]]
  then
    copycommand="wl-copy"
    clearcommand="wl-copy -c"
  elif [[ "$XDG_SESSION_TYPE" == x11 ]]
  then
    copycommand="xclip -selection clipboard"
    clearcommand="xsel -cb"
  fi
  command -v $copycommand &> /dev/null || killme "ERROR: Clipboard unupported"
  command -v $clearcommand &> /dev/null || killme "ERROR: Clipboard unupported"
  # copying & timeout
  eval $copycommand "$1"
  while [[ "$tmout" -ge 1 ]]
  do
    if [[ "$protect" == 0 ]]
    then
      echo -ne "$(gum style --foreground 212 "$2") copied, clipboard will reset in $(gum style --foreground 333 "$tmout") second\033[0K\r"
    else
      echo -ne "Password copied, clipboard will reset in $(gum style --foreground 333 "$tmout") second\033[0K\r"
    fi
    sleep 1
    (( tmout-- ))
  done
  eval $clearcommand
  echo -e "$(gum style --foreground f00 --bold "Clipboard cleared")\033[0K\r"
}

remove() {
  if [[ -z "$(find -L "$PREFIX" \( -name ".*" \) -o -type f -print 2>/dev/null)" ]]
  then
    gum style --foreground f00 --bold "Age Secret Store is empty! Cannot remove anything!"
    gum input
  else
    choice=$(find -L "$PREFIX" \( -name ".*" \) -o -type f -print 2>/dev/null | sed -e "s#${PREFIX}/\{0,1\}##" | sort | gum filter)
    # TODO
    if gum confirm "Are you sure you want remove $choice"
    then
      assfile="$PREFIX/$choice"
      rm -f "$assfile"
      rmdir --ignore-fail-on-non-empty -p "${assfile%/*}" 2> /dev/null
      gum style --foreground f00 --bold "Entry removed!"
      gum input
    fi
  fi
}

list() {
  gum style --bold "Age Secret Store"
  tree -N -C -l --noreport "$PREFIX" | tail -n +2
  gum input
}

# TODO implement this
passgen() {
  local options length=20 pwgenopts="-y" clip=0
  options="$(getopt -o csl: -l clip,syblol-disable,length: -n "$PROGRAM" -- "$@")"
  eval set -- "$options"
  while true
  do
    case "$1" in
      -s|--symbol-disable) pwgenopts=""; shift ;;
      -l|--length) length="$2"; shift 2 ;;
      -c|--clip) clip=1; shift ;;
      --) shift; break
    esac
  done
  [[ $length =~ ^[0-9]+$ ]] || killme "Password length must be a number."
  if [[ "$clip" == 0 ]]
  then
    pwgen -1s $pwgenopts $length
  else
    just_copy -p "$(pwgen -1s $pwgenopts $length)"
  fi
  exit 0
}

killme() {
  >&2 gum style --foreground f00 --bold "$1"
  exit 1
}

############# Main program #####################

[[ -e "$PREFIX" ]] || init
while true
do
  clear
  gum style --foreground 333 --border-foreground 212 --border double --align center --width 50 --margin "1 2" --padding "2 4" 'Age Secret Store' 'No more pain in ass!'
  case $(gum choose "add" "show" "copy" "remove" "list" "destroy" "exit")
  in
    add) add ;;
    show) show ;;
    copy) copy ;;
    remove) remove ;;
    list) list ;;
    destroy)
      gum confirm "Are you absolutely sure you want remove all Age Secret Store?" && rm -r -f -v "$PREFIX" && exit 0 || echo "Operation cancelled."
      ;;
    # TODO
    # passgen) shift; passgen "$@" ;;
    # help) shift; help ;;
    *) clear; exit 0
  esac
done
