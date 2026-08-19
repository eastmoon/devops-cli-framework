# Minimal yq-compatible shim, implemented with sed.
# Provides a "yq" function covering the dot-path forms used across this CLI:
#   yq ".KEY" FILE                  -> top-level scalar value
#   yq ".SECTION.KEY" FILE          -> value nested one level ( YAML 2-space indent )
#   yq ".SECTION.KEY.SUBKEY" FILE   -> value nested two levels ( YAML 2-space indent )
#   yq ".[] | key" FILE             -> top-level keys
#   yq ".SECTION.[] | key" FILE     -> immediate child keys of SECTION
#   yq ".SECTION | length" FILE     -> count of immediate child keys of SECTION
#   yq ".SECTION.KEY | length" FILE -> count of immediate child keys of SECTION.KEY
# Nested YAML mappings are assumed to use 2-space indentation.

function yq-section-body() {
    local file="${1}"
    local section="${2}"
    sed -n "/^${section}:/,/^[^[:space:]]/{/^${section}:/d;/^[^[:space:]]/d;/^[[:space:]]*$/d;p}" "${file}"
}

function yq-nested-body() {
    local body="${1}"
    local key="${2}"
    echo "${body}" | sed -n "/^[[:space:]]\{1,\}${key}:/,/^[[:space:]]\{0,2\}[^[:space:]]/{/^[[:space:]]\{1,\}${key}:/d;/^[[:space:]]\{0,2\}[^[:space:]]/d;/^[[:space:]]*$/d;p}"
}

function yq-value() {
    local file="${1}"
    local depth="${2}"
    case ${depth} in
        1)
            local key="${3}"
            sed -n "s/^${key}:[[:space:]]*//p" "${file}" | sed -e 's/^"\(.*\)"$/\1/' | head -n1
            ;;
        2)
            local section="${3}"
            local key="${4}"
            local body
            body=$(yq-section-body "${file}" "${section}")
            echo "${body}" | sed -n "s/^[[:space:]]*${key}:[[:space:]]*//p" | sed -e 's/^"\(.*\)"$/\1/' | head -n1
            ;;
        3)
            local section="${3}"
            local key="${4}"
            local subkey="${5}"
            local body nested
            body=$(yq-section-body "${file}" "${section}")
            nested=$(yq-nested-body "${body}" "${key}")
            echo "${nested}" | sed -n "s/^[[:space:]]*${subkey}:[[:space:]]*//p" | sed -e 's/^"\(.*\)"$/\1/' | head -n1
            ;;
    esac
}

function yq-keys() {
    local file="${1}"
    local depth="${2}"
    case ${depth} in
        0)
            sed -n 's/^\([A-Za-z0-9_-]\{1,\}\):.*/\1/p' "${file}"
            ;;
        1)
            local section="${3}"
            local body
            body=$(yq-section-body "${file}" "${section}")
            echo "${body}" | sed -n 's/^[[:space:]]*\([A-Za-z0-9_-]\{1,\}\):.*/\1/p'
            ;;
        2)
            local section="${3}"
            local key="${4}"
            local body nested
            body=$(yq-section-body "${file}" "${section}")
            nested=$(yq-nested-body "${body}" "${key}")
            echo "${nested}" | sed -n 's/^[[:space:]]*\([A-Za-z0-9_-]\{1,\}\):.*/\1/p'
            ;;
    esac
}

function yq() {
    local file="${2}"
    local expr="${1}"
    local mode="value"

    if [[ "${expr}" == *"|"* ]]; then
        local modifier="${expr#*|}"
        modifier=$(echo "${modifier}" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')
        expr="${expr%%|*}"
        case "${modifier}" in
            key)    mode="key" ;;
            length) mode="length" ;;
        esac
    fi

    expr=$(echo "${expr}" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')
    expr="${expr#.}"
    [ "${expr}" == "[]" ] && expr=""
    expr="${expr%.[]}"

    local seg=()
    if [ -n "${expr}" ]; then
        IFS='.' read -ra seg <<< "${expr}"
    fi
    local depth=${#seg[@]}

    case "${mode}" in
        value)
            case ${depth} in
                1) yq-value "${file}" 1 "${seg[0]}" ;;
                2) yq-value "${file}" 2 "${seg[0]}" "${seg[1]}" ;;
                3) yq-value "${file}" 3 "${seg[0]}" "${seg[1]}" "${seg[2]}" ;;
            esac
            ;;
        key)
            case ${depth} in
                0) yq-keys "${file}" 0 ;;
                1) yq-keys "${file}" 1 "${seg[0]}" ;;
            esac
            ;;
        length)
            case ${depth} in
                1) yq-keys "${file}" 1 "${seg[0]}" | sed '/^$/d' | wc -l ;;
                2) yq-keys "${file}" 2 "${seg[0]}" "${seg[1]}" | sed '/^$/d' | wc -l ;;
            esac
            ;;
    esac
}
