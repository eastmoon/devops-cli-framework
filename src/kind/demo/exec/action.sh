echo "> Exec : ${@}"
echo ATTR_STOP_CLI_PARSER : ${ATTR_STOP_CLI_PARSER}
echo VALUE : ${ATTR_VALUE}
[ ! -z ${ATTR_BOOLEAN_TRUE} ] && echo "BOOLEAN-TRUE exist" || echo "BOOLEAN-TRUE not exist"
[ ! -z ${ATTR_BOOLEAN_FALSE} ] && echo "BOOLEAN-FALSE exist" || echo "BOOLEAN-FALSE not exist"

echo "> Parse parameter"
for v in "${@}"; do
    echo "[+] ${v}"
done
