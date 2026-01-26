echo "-----"
echo "In this demo case."
echo "User can usage main.yml configuration 'attr' key and value, devops framework will use it to declare attribute variable."
echo "-----"
echo ""

## STOP_CLI_PARSER is specify attribute, that will stop devops framework parser to find next sub-command.
echo "> Exec : ${@}"
echo ATTR_STOP_CLI_PARSER : ${ATTR_STOP_CLI_PARSER}

## Show all custom attribute and current value.
echo VALUE : ${ATTR_VALUE}
[ ! -z ${ATTR_BOOLEAN_TRUE} ] && echo "BOOLEAN-TRUE exist" || echo "BOOLEAN-TRUE not exist"
[ ! -z ${ATTR_BOOLEAN_FALSE} ] && echo "BOOLEAN-FALSE exist" || echo "BOOLEAN-FALSE not exist"

## Show all non-parser parameter, when STOP_CLI_PARSER  was setting.
echo "> Parse parameter"
for v in "${@}"; do
    echo "[+] ${v}"
done
