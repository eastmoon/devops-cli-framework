# Parse runtime configuration file
# A variable in runtime configuration file, will all setting in global variable, before main action execute.
export RC_VARS=()
function rc-parser() {
    local RC_FILENAME=${1}
    if [ -e ${RC_FILENAME} ]; then
        while read -r line; do
            if [[ ! ${line} =~ ^# ]]; then
                IFS='=' read -ra ADDR <<< "${line}"
                key=${ADDR[0]}
                value=${ADDR[1]}
                if [ "${key}" != "" ]; then
                    [[ "${RC_VARS[@]}" =~ "${key}" ]] || RC_VARS+=("${key}")
                    export ${key}="${value}"
                fi
            fi
        done < ${RC_FILENAME}
    fi
}

# Execute runtime configuration file
[ ! -z ${CONFIG_KIND_RC_FILENAME} ] && rc-parser ${CONFIG_KIND_RC_FILENAME} || true
[ ! -z ${CLI_RC_FILENAME} ] && rc-parser ${CLI_RC_FILENAME} || true
