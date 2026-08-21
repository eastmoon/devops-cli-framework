## Declare variable.
local cli_vars=()
local attr_vars=()
local conf_vars=()
## Retrieve variable name
for ln in `compgen -v`
do
    [[ ${ln:0:4} == 'CLI_' ]] && cli_vars+=("${ln}") || true
    [[ ${ln:0:5} == 'ATTR_' ]] && attr_vars+=("${ln}") || true
    [[ ${ln:0:7} == 'CONFIG_' ]] && conf_vars+=("${ln}") || true
done
## Show variable
echo "> Show all command-line interface global variable."
for v in ${cli_vars[@]}; do
    echo ${v}=${!v}
done
echo ""
echo "> Show all configuration YAML variable."
for v in ${conf_vars[@]}; do
    echo ${v}=${!v}
done
echo ""
echo "> Show all script attribute variable."
for v in ${attr_vars[@]}; do
    echo ${v}=${!v}
done
echo ""
rc_file=""
[[ ! -z ${CLI_RC_FILENAME} && -e ${CLI_RC_FILENAME} ]] && rc_file="${rc_file} ${CLI_RC_FILENAME}"
[[ ! -z ${CONFIG_KIND_RC_FILENAME} && -e ${CONFIG_KIND_RC_FILENAME} ]] && rc_file="${rc_file} ${CONFIG_KIND_RC_FILENAME}"
[[ ! -z ${CLI_OPTIONS_RC_FILENAME} && -e ${CLI_OPTIONS_RC_FILENAME} ]] && rc_file="${rc_file} ${CLI_OPTIONS_RC_FILENAME}"
echo "> Show all runtime configuration (${rc_file} ) variable."
if [[ -n ${RC_VARS} ]]; then
    for v in ${RC_VARS[@]}; do
        echo ${v}=${!v}
      done
fi
