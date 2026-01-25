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

# Command-line-interface main entrypoint.
function main() {
    # Parse assign variable which input into main function
    # It will parse input assign variable and stop at first command ( COMMAND ), and re-group two list variable, option list before command ( COMMAND_BC_AGRS ), option list after command ( COMMAND_AC_AGRS ).
    argv-parser "${@}"
    # Run main function option, which option control come from "option list before command" ( COMMAND_BC_AGRS ).
    main-args "${COMMAND_BC_AGRS[@]}"
    # Execute command
    if [[ -n ${COMMAND} && "${COMMAND}" != "" ]];
    then
        # If exist command, then re-group breadcrumb that is a string struct by command.
        BREADCRUMB="${BREADCRUMB}/${COMMAND}"
        # And if exist a shell file has a name same with breadcrumb, then it is a target file we need to run.
        local result=$(check-command ${BREADCRUMB})
        if [ ! -z ${result} ];
        then
            # Generate shell file full path.
            SHELL_CONFIG="${result}/main.yml"
            SHELL_FILE="${result}/main.sh"
            # Run main function attribute option, which option control come from shell file attribute ( #@ATTRIBUTE=VALUE ).
            main-attr
            # If attribute ( stop-cli-parser ) not exist, then run main function with "option list after command" ( COMMAND_AC_AGRS ).
            # Main function will run at nested structure, it will search full command breadcrumb come from use input assign variable.
            #
            # If attribute ( stop-cli-parser ) exist, it mean stop search full command breadcrumb,
            # and execute current shell file, and "option list after command" ( COMMAND_AC_AGRS ) become shell file assign variable .
            if [ -z ${ATTR_STOP_CLI_PARSER} ];
            then
                main "${COMMAND_AC_AGRS[@]}"
            else
                COMMAND_ARGS=("${COMMAND_AC_AGRS[@]}")
                argv-parser "${COMMAND_ARGS[@]}"
                main-args "${COMMAND_BC_AGRS[@]}"
                main-exec "${COMMAND_ARGS[@]}"
            fi
        else
            # If not exist a shell file, then show help content which in cli file or current shell file
            [ -z ${SHELL_CONFIG} ] &&  cli-help || call-command-help
        fi
    else
        # If not exist command, it mean current main function input assign variable only have option, current breadcrumb variable was struct by full command,
        # then execute function ( in cli or shell file ) with breadcrumb variable.
        main-exec
    fi
}

# Main function, args running function.
function main-args() {
    for arg in "${@}"
    do
        IFS='=' read -ra ADDR <<< "${arg}"
        key=${ADDR[0]}
        value=${ADDR[1]}
        [ -z ${SHELL_CONFIG} ] && eval cli-args ${key} "${value}" || call-command-args ${key} "${value}"
        common-args ${key} "${value}"
    done
}

# Main function, attribute running function.
function main-attr() {
    if [[ -n ${SHELL_CONFIG} && -e ${SHELL_CONFIG} ]]; then
        g="attr"
        if [ $(yq ".${g} | length" ${SHELL_CONFIG}) -gt 0 ]; then
            for k in `yq ".${g}.[] | key" ${SHELL_CONFIG}`; do
                v=$(yq ".${g}.${k}" ${SHELL_CONFIG})
                export ATTR_${k//-/_}="${v}"
            done
        fi
    fi
}

# Main function, target function execute.
function main-exec() {
    if [ -z ${SHELL_FILE} ]; then
        if [ -z ${SHOW_HELP} ]; then
            eval cli
        else
            eval cli-help
        fi
    else
        if [ -z ${SHOW_HELP} ]; then
            call-command-action "${@}"
        else
            call-command-help
        fi
    fi
}

# Parse args variable
# it will search input assign variable, then find first command ( COMMAND ), option list before command ( COMMAND_BC_AGRS ), and option list after command ( COMMAND_AC_AGRS ).
function argv-parser() {
    COMMAND=""
    COMMAND_BC_AGRS=()
    COMMAND_AC_AGRS=()
    is_find_cmd=0
    for arg in "${@}"; do
        if [ ${is_find_cmd} -eq 0 ]; then
            if [[ ${arg} =~ -+[a-zA-Z1-9]* ]]; then
                COMMAND_BC_AGRS+=("${arg}")
            else
                COMMAND="${arg}"
                is_find_cmd=1
            fi
        else
            COMMAND_AC_AGRS+=("${arg}")
        fi
    done
}

# Parse ini configuration file
# A variable in ini configuration file, will setting variable by common-ini function.
function ini-parser() {
    if [ -e ${CLI_INI_FILENAME} ] && [ $(command -v yq | wc -l) -gt 0 ]; then
        s="command-line-interface"
        if [ $(yq ".${s}.[] | key" ${CLI_INI_FILENAME} | wc -l) -gt 0 ]; then
            for k in `yq ".${s}.[] | key" ${CLI_INI_FILENAME}`; do
                v=$(yq ".${s}.${k}" ${CLI_INI_FILENAME})
                eval v="${v}"
                export ${k}="${v}"
            done
        else
            echo "Section ${s} not find in ${CLI_INI_FILENAME}."
        fi
    fi
}

# ------------------- command-line-interface common args and attribute method -------------------

# Common - args process
function common-args() {
    key=${1}
    value=${2}
    case ${key} in
        "--help")
            SHOW_HELP=1
            ;;
        "-h")
            SHOW_HELP=1
            ;;
        "--rc")
            [ -e ${value} ] && rc-parser ${value} || true
            ;;
    esac
}

# ------------------- Main method -------------------

function cli() {
    cli-help
}

function cli-args() {
    return 0
}

function cli-help() {
    echo "This is a docker control script with project ${PROJECT_NAME}"
    echo "If not input any command, at default will show HELP"
    echo ""
    echo "Options:"
    echo "    --help, -h        Show more information with CLI."
    echo "    --rc              Setting CLI rc file ( Default ${CLI_FILENAME}.rc )"
    command-description
}

# ------------------- execute script -------------------
# parser configuration file
ini-parser

# import libraries
if [ ! -z ${CLI_UTILS_DIRECTORY} ] && [ -d ${CLI_UTILS_DIRECTORY} ]; then
    for lib in $(find ${CLI_UTILS_DIRECTORY} -type f -iname "*.sh" | sort); do
        source ${lib}
    done
fi
# execute main process function
main "${@}"
