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
echo "> Show all runtime configuration (${CLI_RC_FILENAME}) variable."
if [[ -n ${RC_VARS} ]]; then
    for v in ${RC_VARS[@]}; do
        echo ${v}=${!v}
      done
fi
