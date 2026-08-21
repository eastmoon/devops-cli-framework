# Parse configuration YAML file
## Configuration default value
CONFIG_KIND=default
CONFIG_SHELL_PATH=${CLI_DIRECTORY}/shell
## Replace configuration from YAML file
if [ -e ${CLI_CONFIG_FILENAME} ]; then
    for key in `yq ".[] | key" ${CLI_CONFIG_FILENAME}`; do
        case ${key} in
            "kind")
                CONFIG_KIND=`yq ".${key}" ${CLI_CONFIG_FILENAME}`
                ;;
            "path")
                CONFIG_SHELL_PATH=`yq ".${key}" ${CLI_CONFIG_FILENAME}`
                ;;
        esac
    done
else
    [ ! -z ${DEFAULT_CONFIG_KIND} ] && CONFIG_KIND=${DEFAULT_CONFIG_KIND} || true
    [ ! -z ${DEFAULT_CONFIG_SHELL_PATH} ] && CONFIG_SHELL_PATH=${DEFAULT_CONFIG_SHELL_PATH} || true
fi
## Setting other configuration variable.
CONFIG_KIND_PATH=${CLI_SHELL_DIRECTORY}/${CONFIG_KIND}
CONFIG_KIND_RC_FILENAME=${CLI_SHELL_DIRECTORY}/${CONFIG_KIND}/kind.rc
