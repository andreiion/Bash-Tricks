#!/usr/bin/env bash

export txtblk='\e[0;30m' # Black - Regular
export txtred='\e[0;31m' # Red
export txtgrn='\e[0;32m' # txtgrn
export txtylw='\e[0;33m' # Yellow
export txtblu='\e[0;34m' # txtblu
export txtpur='\e[0;35m' # Purple
export txtcyn='\e[0;36m' # Cyan
export txtwht='\e[0;37m' # White
export bldblk='\e[1;30m' # Black - Bold
export bldred='\e[1;31m' # Red
export bldgrn='\e[1;32m' # Green
export bldylw='\e[1;33m' # Yellow
export bldblu='\e[1;34m' # Blue
export bldpur='\e[1;35m' # Purple
export bldcyn='\e[1;36m' # Cyan
export bldwht='\e[1;37m' # White
export clr='\e[0m'       # Text Reset

# Ask the user if they want to proceed, defaulting to Yes.
# Choosing no exits the program. The arguments are printed as a question.
lib::run::ask() {
  local question="$*"

  printf "${txtcyn}${question} [Y/n] ${clr}"
  read a
  if [[ ${a} == 'y' || ${a} == 'Y' || ${a} == '' ]]; then
    return 0
  else
    printf "${txtred}Aborting.${clr}\n"
    exit 1
  fi
}

lib::osx::display::change-underscan() {
  set +e
  local amount_percentage="$1"
  if [[ -z "${amount_percentage}" ]] ; then
    printf "${txtylw}USAGE:\n"
    printf "    ${txtgrn}%s ${txtblu}%s\n"      $0 percentage-change
    echo
    printf "${txtylw}EXAMPLES:\n"
    printf "    ${txtpur}%s ${txtblu}%s\n"      "# eg: shrink screen by 5% (if menu is off the screen)"
    printf "    ${txtgrn}%s ${txtblu}%s\n"      $0  5
    printf "    ${txtpur}%s ${txtpur}%s\n"      "# eg: expand screen by 5% (if there is a black border)"
    printf "    ${txtgrn}%s ${txtblu}%s\n"      $0 -5
    exit 1
  fi

  local file="/var/db/.com.apple.iokit.graphics"
  local backup="/tmp/.com.apple.iokit.graphics.bak"

  local amount=$(( 100 * ${amount_percentage} ))

  echo 'This utility allows you to change underscan/overscan'
  echo 'on monitors that do not offer that option via GUI.'
  
  lib::run::ask 'Continue? '

  echo "First we need to identify your monitor."
  echo "Please make sure that the external monitor is plugged in."

  lib::run::ask "Is it plugged in?"

  echo "Making a backup of your current graphics settings..."
  printf "${txtgrn}Please enter your password, if asked: ${clr}\n"
  bash -c 'set -e; sudo ls -1 > /dev/null; set +e'
  sudo rm -f "${backup}"
  set -e
  sudo cp "${file}" "${backup}"
  set +e
  
  printf "OK, great — sudo is working.\n"
  printf "Next, please perform the following step:\n\n"

  printf "Please ${txtgrn}change the resolution on the problem monitor.${clr}\n\n"

  printf "    NOTE: it's not important what resolution you choose,\n"
  printf "    as long as it's different than what you had previously...\n\n"

  printf "Then close the Display Preferences... \n"

  open /System/Library/PreferencePanes/Displays.prefPane

  sleep 2

  lib::run::ask "Have you changed the monitor resolution, and quit Display Settings?"

  local line=$(sudo diff "${file}" "${backup}" 2>/dev/null | head -1 | /usr/bin/env ruby -ne 'puts $_.to_i')
  
  value=
  line_pscn_key=
  line_pscn_value=

  if [[ "${line}" -gt 0 ]]; then
    line_pscn_key=$(( $line - 4 ))
    line_pscn_value=$(( $line_pscn_key + 1 ))
    ( awk "NR==${line_pscn_key}{print;exit}" "${file}" | grep -q pscn ) && {
      value=$(awk "NR==${line_pscn_value}{print;exit}" "${file}" | awk 'BEGIN{FS="[<>]"}{print $3}')
    }
  else
    printf "${bldred}Error — it does not appear that anything changed, sorry.${clr}\n"
    printf "Perhaps try again, but unplug the monitor after the change?\n"
    return -1
  fi

  if [[ -n ${value} ]]; then
    local new_value=$(( $value - ${amount} ))
    sudo sed -i.backup "${line_pscn_value}s/${value}/${new_value}/g" "${file}"
    echo
    printf "${bldblu}Congratulations!${clr}\n\n"
    echo "Your display underscan value has been changed."
    echo
    printf "    Previous Value: ${txtpur}${value}${clr}\n"
    printf "    New value     : ${txtgrn}${new_value}${clr}\n"
    echo
    printf "${bldblu}IMPORTANT!${clr}\n"
    printf "${bldgrn}You must restart your computer for the settings to take affect.${clr}\n\n"
  else
    printf "${bldred}WARNING:${clr}\nUnable to find the display scan value to change.\n\n"
    echo "Could it be that you haven't restarted since your last run?"
    echo
    echo "Feel free to edit file directly, using, eg:"
    echo "    $ ${txtgrn}vim ${file} +${line_pscn_value}${clr}\n\n"
  fi
}

lib::osx::display::change-underscan "$1"
