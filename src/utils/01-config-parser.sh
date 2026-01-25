# Parse configuration YAML file
## Configuration default value
CONFIG_KIND=default
CONFIG_SHELL_PATH=${CLI_DIRECTORY}/shell
CONFIG_KIND_PATH=${CLI_SHELL_DIRECTORY}/${CONFIG_KIND}
CONFIG_KIND_RC_FILENAME=${CLI_SHELL_DIRECTORY}/${CONFIG_KIND}/do.rc
## Replace configuration from YAML file
if [ -e ${CLI_CONFIG_FILENAME} ]; then
    for key in `yq ".[] | key" ${CLI_CONFIG_FILENAME}`; do
        case ${key} in
            "kind")
                CONFIG_KIND=`yq ".${key}" ${CLI_CONFIG_FILENAME}`
                CONFIG_KIND_PATH=${CLI_SHELL_DIRECTORY}/${CONFIG_KIND}
                CONFIG_KIND_RC_FILENAME=${CLI_SHELL_DIRECTORY}/${CONFIG_KIND}/do.rc
                ;;
            "path")
                CONFIG_SHELL_PATH=`yq ".${key}" ${CLI_CONFIG_FILENAME}`
                ;;
        esac
    done
fi
