# ------------------- Common Command method -------------------

function find-command() {
    ## Declare path varialbe
    local TARGET_KIND_PATH=${CONFIG_KIND_PATH}
    [ ! -z ${1} ] && TARGET_KIND_PATH=${CONFIG_KIND_PATH}/${1}
    local TARGET_SHELL_PATH=${TARGET_KIND_PATH/${CONFIG_KIND_PATH}/${CONFIG_SHELL_PATH}}
    ## Search command with YAML configuration file.
    ### Find in kind directory, and if file has same command folder in custom shell directory, ignore it.
    if [ -e ${TARGET_KIND_PATH} ]; then
        for file in $(find ${TARGET_KIND_PATH} -mindepth 2 -maxdepth 2 -type f -name "main.yml"); do
            if [ ! -z ${file} ] && [ ! -e ${file/${CONFIG_KIND_PATH}/${CONFIG_SHELL_PATH}} ]; then
                echo ${file}
            fi
        done
    fi
    ### Find in custom shell directory.
    if [ -e ${TARGET_SHELL_PATH} ]; then
        find ${TARGET_SHELL_PATH} -mindepth 2 -maxdepth 2 -type f -name "main.yml"
    fi
}

function check-command() {
    ## Declare path varialbe
    local TARGET_KIND_PATH=${CONFIG_KIND_PATH}
    [ ! -z ${1} ] && TARGET_KIND_PATH=${CONFIG_KIND_PATH}/${1}
    local TARGET_SHELL_PATH=${TARGET_KIND_PATH/${CONFIG_KIND_PATH}/${CONFIG_SHELL_PATH}}
    ##
    if [ -d ${TARGET_SHELL_PATH} ] && [ -e ${TARGET_SHELL_PATH}/main.yml ]; then
        echo ${TARGET_SHELL_PATH/\/\//\/}
    elif [ -d ${TARGET_KIND_PATH} ] && [ -e ${TARGET_KIND_PATH}/main.yml ]; then
        echo ${TARGET_KIND_PATH/\/\//\/}
    fi
}

function call-command-action() {
    call-source ${SHELL_FILE} "${@}" || (
        call-standard-action "${@}"
    )
}

function call-command-args() {
    local key=${1}
    local value=${2}
    g="args"
    if [ $(yq ".${g}.${key} | length" ${SHELL_CONFIG}) -gt 0 ]; then
        v=$(yq ".${g}.${key}.var" ${SHELL_CONFIG})
        t=$(yq ".${g}.${key}.type" ${SHELL_CONFIG})
        if [ "${t}" == "bool" ]; then
            export ATTR_${v//-/_}=1
        else
            export ATTR_${v//-/_}="${value}"
        fi
    fi
}

function call-command-help() {
    if [ -e ${SHELL_CONFIG} ]; then
        ## Base description
        echo "This is a Command Line Interface with project ${PROJECT_NAME}"
        echo "$(yq '.desc' ${SHELL_CONFIG})"
        echo ""
        echo "Options:"
        printf "    %-10s        %-40s\n" "--help, -h" "Show more command information."
        ## Show options in configuration YAML file
        g="args"
        if [ $(yq ".${g} | length" ${SHELL_CONFIG}) -gt 0 ]; then
            for k in `yq ".${g}.[] | key" ${SHELL_CONFIG}`; do
                v=$(yq ".${g}.${k}.desc" ${SHELL_CONFIG})
                printf "    %-10s        %-40s\n" "${k}" "${v}"
            done
        fi
        ## Show sub-command
        local COMMAND_NAME=${SHELL_CONFIG%/*}
        local COMMAND_NAME=${COMMAND_NAME##*/}
        command-description ${COMMAND_NAME}
    fi
}

function command-description() {
    local TARGET_COMMAND=($(find-command ${1}))
    if [ ${#TARGET_COMMAND[@]} -gt 0 ]; then
        echo ""
        echo "Command: "
        for file in ${TARGET_COMMAND[@]}; do
            local COMMAND_NAME=${file%/*}
            local COMMAND_NAME=${COMMAND_NAME##*/}
            if [ -n "${COMMAND_NAME}" ]; then
                printf "    %-10s        %-40s\n" "${COMMAND_NAME}" "$(yq '.desc' ${file})"
            fi
        done
    fi
    echo ""
    echo "Run '${CLI_FILENAME##*/} [COMMAND] --help' for more information."
}
