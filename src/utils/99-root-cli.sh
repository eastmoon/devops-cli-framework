
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
