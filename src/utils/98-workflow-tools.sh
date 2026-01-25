# ------------------- Common Command method -------------------
function super() {
    local CALLER_DIR=$(caller | awk '{print $2}')
    local IS_CALL_STANDARD=1
    if [[ "${CALLER_DIR}" =~ "${CONFIG_SHELL_PATH}" ]]; then
        local TARGET_SOURCE_FILE=${CALLER_DIR/${CONFIG_SHELL_PATH}/${CONFIG_KIND_PATH}}
        if [ -e ${TARGET_SOURCE_FILE} ]; then
            source ${TARGET_SOURCE_FILE} "${@}"
            local IS_CALL_STANDARD=
        fi
    fi
    [ ! -z ${IS_CALL_STANDARD} ] && call-standard-action "${@}" || true
}

function call-standard-action() {
    workflow action "${@}"
}

function call-source() {
    local TARGET_SOURCE_FILE=${1/${CONFIG_SHELL_PATH}/${CONFIG_KIND_PATH}}
    local TARGET_CONFIG_FILE=${1/${CONFIG_KIND_PATH}/${CONFIG_SHELL_PATH}}
    local TARGET_ARGV=("${@:2}")
    if [ -e ${TARGET_CONFIG_FILE} ]; then
        source ${TARGET_CONFIG_FILE} "${TARGET_ARGV[@]}"
    elif [ -e ${TARGET_SOURCE_FILE} ]; then
        source ${TARGET_SOURCE_FILE} "${TARGET_ARGV[@]}"
    else
        return 1
    fi
}

function workflow() {
    local TARGET_FUNC=${1}
    local TARGET_ARGV=("${@:2}")
    local CALLER_DIR=${SHELL_FILE%/*}
    call-source "${CALLER_DIR}/pre${TARGET_FUNC}.sh" "${TARGET_ARGV[@]}" || true
    call-source "${CALLER_DIR}/${TARGET_FUNC}.sh" "${TARGET_ARGV[@]}" || true
    call-source "${CALLER_DIR}/post${TARGET_FUNC}.sh" "${TARGET_ARGV[@]}" || true
}
