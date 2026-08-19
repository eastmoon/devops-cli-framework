#
# Copyright 2022 the original author jacky.eastmoon
#
# All commad module need 3 method :
# [command]        : Command script
# [command]-args   : Command script options setting function
# [command]-help   : Command description
# Basically, CLI will not use "--options" to execute function, "--help, -h" is an exception.
# But, if need exception, it will need to thinking is common or individual, and need to change BREADCRUMB variable in [command]-args function.
#
# Ref : https://www.cyberciti.biz/faq/category/bash-shell/
# Ref : https://tldp.org/LDP/abs/html/string-manipulation.html
# Ref : https://blog.longwin.com.tw/2017/04/bash-shell-script-get-self-file-name-2017/

# ------------------- shell setting -------------------

#!/bin/bash
set -e

# ------------------- declare CLI variable -------------------

CLI_DIRECTORY=${PWD}
CLI_FILE=${BASH_SOURCE##*/}
CLI_FILENAME=${CLI_FILE%.*}
CLI_FILEEXTENSION=${CLI_FILE##*.}
CLI_INI_FILENAME=${CLI_DIRECTORY}/${CLI_FILENAME}.ini
CLI_RC_FILENAME=${CLI_DIRECTORY}/${CLI_FILENAME}.rc
CLI_CONFIG_FILENAME=${CLI_DIRECTORY}/${CLI_FILENAME}.yml
SHELL_CONFIG=
SHELL_FILE=

# ------------------- declare variable -------------------

BREADCRUMB=""
COMMAND=""
COMMAND_BC_AGRS=()
COMMAND_AC_AGRS=()
SHOW_HELP=
PROJECT_NAME=${PWD##*/}

# ------------------- declare function -------------------

# Parse ini configuration file
# A variable in ini configuration file, will setting variable by common-ini function.
function ini-parser() {
    if [ -e ${CLI_INI_FILENAME} ] && [ $(command -v sed | wc -l) -gt 0 ]; then
        s="command-line-interface"
        section_content=$(sed -n "/^\[${s}\]/,/^\[/{/^\[/d;/^;/d;/^$/d;p}" ${CLI_INI_FILENAME})
        if [ ! -z "${section_content}" ]; then
            while IFS='=' read -r k v; do
                eval v="${v}"
                export ${k}="${v}"
            done <<< "${section_content}"
        else
            echo "Section ${s} not find in ${CLI_INI_FILENAME}."
        fi
    fi
}

# ------------------- execute script -------------------
# parser configuration file
ini-parser
[ ! -z ${CLI_SHELL_DIRECTORY} ] && CLI_SHELL_DIRECTORY=$(realpath "$CLI_SHELL_DIRECTORY") || true
[ ! -z ${CLI_UTILS_DIRECTORY} ] && CLI_UTILS_DIRECTORY=$(realpath "$CLI_UTILS_DIRECTORY") || true

# import libraries
if [ ! -z ${CLI_UTILS_DIRECTORY} ] && [ -d ${CLI_UTILS_DIRECTORY} ]; then
    for lib in $(find ${CLI_UTILS_DIRECTORY} -type f -iname "*.sh" | sort); do
        source ${lib}
    done
fi

# execute main process function
main "${@}"
