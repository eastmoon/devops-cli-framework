# 開發運維框架初始化腳本 (devops-cli-fwk-initial.sh)
#
# 本檔案依據下列提示詞撰寫，並保留原提示詞之段落結構，僅作兩處用詞詮釋，
# 段落層次未變更：
#   1. 將 "do-cli-fwk" 之縮寫統一詮釋為與後續段落一致的 "devops-cli-fwk"。
#   2. 第 3 節將原「移動 do.sh、do.ini」詮釋為「複製 do.sh、do.ini」：
#      框架快取目錄在「已存在快取、僅需檢查版本」情境下不會重新解壓縮，
#      若複製後即刪除來源檔案，該快取將無法支援下一次部署，故以複製取代
#      移動，使快取內容可重複使用。
#
# ## 引導
#
# + 軟體設計憲章 : .codekit/memory/constitution/software-design.md
# + 虛擬碼憲章 : .codekit/memory/constitution/coding-pseudocode.md
# + 程式編碼指南 : .codekit/memory/guideline/coding.md
#
# ## 初始化邏輯
#
# ### 1. 確認專案目錄
#
# + 若無指定，專案目錄為根目錄
# + 若有指定，專案目錄為指定位置
# + 專案目錄只能是當前專案根目錄或子目錄，若不在此範圍內，應顯示錯誤並停止流程
#
# ### 2. 確認框架內容
#
# + 若專案目錄的快取目錄 ./cache 內，不存在 devops-cli-fwk 目錄，自開發運維框架取得最新的版本內容。
#     - 開發運維框架最新版本網址 : https://github.com/eastmoon/devops-cli-framework/releases
#     - 下載檔案為 devops-cli-framework.tgz，存放於 cache 目錄
# + 若專案目錄的快取目錄 ./cache 內，存在 devops-cli-fwk 目錄，確認版本是否為最新版本
#     - 若非最新版本，顯示警告訊息 「開發運維框架有可更新的版本，若要更新請移除快取目錄」
#
# ### 3. 建置框架
#
# + 若 cache 存在 devops-cli-framework.tgz 檔案，表示有新版本。
# + 若 cache 存在 devops-cli-fwk 目錄，移除舊目錄。
# + 使用 tar 解壓縮 tar.gz 格式的 devops-cli-framework.tgz 檔案，內容存放於 cache/devops-cli-fwk 目錄
# + 自 cache/devops-cli-fwk 複製 do.sh、do.ini 兩個檔案，至專案目錄
#     - 若專案目錄存在 do.sh 檔案，覆蓋該檔案
#     - 若專案目錄存在 do.ini 檔案，合併兩個檔案的資訊
#         + 若存在相同鍵 ( key )，則以舊檔案的值 ( value )
#     - 若專案目錄不存在 do.ini 檔案，調整參數
#         + 將 CLI_SHELL_DIRECTORY=${CLI_DIRECTORY}/kind 改為 CLI_SHELL_DIRECTORY=${CLI_DIRECTORY}/cache/devops-cli-fwk/kind
#         + 將 CLI_UTILS_DIRECTORY=${CLI_DIRECTORY}/utils 改為 CLI_UTILS_DIRECTORY=${CLI_DIRECTORY}/cache/devops-cli-fwk/utils
#         + 將 DEFAULT_CONFIG_SHELL_PATH=${CLI_DIRECTORY}/shell 改為 DEFAULT_CONFIG_SHELL_PATH=${CLI_DIRECTORY}/conf/devops
# + 建立格式為 LF 的空白檔案 do.rc
#
# ## 輸出
#
# 對應虛擬碼 : .claude/shell/devops-cli-fwk-initial.psc
#
# 用法 : devops-cli-fwk-initial.sh [專案目錄]
#   未帶參數時，專案目錄預設為執行本腳本時的目前工作目錄。
#
# 退出碼 (Exit Code) 定義：
#   0 : 執行成功
#   1 : 專案目錄不合法（不在目前專案根目錄或其子目錄範圍內），或參數使用方式錯誤
#   2 : 缺少必要指令（curl、tar 或 realpath）
#   3 : 下載開發運維框架失敗
#   4 : 解壓縮開發運維框架失敗

#!/bin/bash
set -euo pipefail

# ------------------- 常數宣告 -------------------

readonly CACHE_DIRNAME="cache"
readonly FRAMEWORK_CACHE_DIRNAME="devops-cli-fwk"
readonly FRAMEWORK_ARCHIVE_NAME="devops-cli-framework.tgz"
readonly FRAMEWORK_RELEASES_URL="https://github.com/eastmoon/devops-cli-framework/releases"
readonly FRAMEWORK_VERSION_MARKER=".version"
readonly CLI_ENTRY_FILENAME="do.sh"
readonly CLI_CONFIG_FILENAME="do.ini"
readonly CLI_RC_FILENAME="do.rc"
readonly DEFAULT_CONFIG_SHELL_SUBPATH="conf/devops"
readonly UPDATE_WARNING_MESSAGE="開發運維框架有可更新的版本，若要更新請移除快取目錄"
readonly DOWNLOAD_TIMEOUT_SEC=30

readonly EXIT_INVALID_PROJECT_DIR=1
readonly EXIT_MISSING_DEPENDENCY=2
readonly EXIT_DOWNLOAD_FAILED=3
readonly EXIT_EXTRACT_FAILED=4

# ------------------- 全域狀態 -------------------

PROJECT_DIR_INPUT=""
TEMP_PATHS=()

# ------------------- 共用工具函式 -------------------

function log_info() {
    printf '[INFO] %s\n' "$*"
}

function log_warn() {
    printf '[WARN] %s\n' "$*" >&2
}

function log_error() {
    printf '[ERROR] %s\n' "$*" >&2
}

function register_temp_path() {
    TEMP_PATHS+=("$1")
}

# 清理暫存資源；使用 ${TEMP_PATHS[@]-} 而非 [@] 是為了相容 bash 4.4 以前
# 版本在 "set -u" 下對空陣列展開會報 unbound variable 的行為。
# 開頭立即保存 $?、結尾以 exit 明確回寫，避免清理動作本身的結束碼
# 覆蓋腳本原本應回報的結束碼（EXIT trap 的常見陷阱）。
function cleanup() {
    local exit_status=$?
    local path
    for path in "${TEMP_PATHS[@]-}"; do
        [ -n "${path}" ] && [ -e "${path}" ] && rm -rf "${path}"
    done
    exit "${exit_status}"
}
trap cleanup EXIT

function require_command() {
    local name="$1"
    if ! command -v "${name}" >/dev/null 2>&1; then
        log_error "缺少必要指令: ${name}"
        exit "${EXIT_MISSING_DEPENDENCY}"
    fi
}

# 使用 "realpath -m" 而非 "cd && pwd -P"：初始化腳本之目標專案目錄可能尚未
# 建立，"-m" 容許路徑之尾端節點不存在，僅作字面正規化（解析 "."、".." 與
# 符號連結），使目錄範圍檢查不因目錄尚未建立而誤判失敗。
function to_absolute_path() {
    local dir_path="$1"
    realpath -m -- "${dir_path}"
}

# ------------------- 步驟一：確認專案目錄 -------------------

function parse_args() {
    if [ "$#" -gt 1 ]; then
        log_error "僅接受一個選用參數（專案目錄），實際收到 $# 個參數"
        exit "${EXIT_INVALID_PROJECT_DIR}"
    fi
    PROJECT_DIR_INPUT="${1:-}"
}

function is_dir_within_root() {
    local candidate_dir="$1" root_dir="$2"
    local resolved_candidate resolved_root
    resolved_candidate=$(to_absolute_path "${candidate_dir}") || return 1
    resolved_root=$(to_absolute_path "${root_dir}") || return 1
    case "${resolved_candidate}" in
        "${resolved_root}"|"${resolved_root}"/*)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

function resolve_project_dir() {
    local root_dir="$1" input_dir="$2"
    local candidate
    if [ -z "${input_dir}" ]; then
        candidate="${root_dir}"
    else
        candidate="${input_dir}"
    fi
    if ! is_dir_within_root "${candidate}" "${root_dir}"; then
        log_error "專案目錄須為目前專案根目錄（${root_dir}）或其子目錄，實際為: ${candidate}"
        exit "${EXIT_INVALID_PROJECT_DIR}"
    fi
    local resolved
    resolved=$(to_absolute_path "${candidate}")
    mkdir -p "${resolved}"
    printf '%s' "${resolved}"
}

# ------------------- 步驟二：確認框架內容 -------------------

# 以 GitHub 「/releases/latest」重新導向後的網址取得最新版本標籤，
# 避免額外依賴 GitHub API 或 jq 解析 JSON。
function get_latest_release_tag() {
    local effective_url
    effective_url=$(curl -fsSL --max-time "${DOWNLOAD_TIMEOUT_SEC}" \
        -o /dev/null -w '%{url_effective}' "${FRAMEWORK_RELEASES_URL}/latest") || return 1
    case "${effective_url}" in
        */tag/*)
            printf '%s' "${effective_url##*/tag/}"
            ;;
        *)
            return 1
            ;;
    esac
}

function download_latest_framework() {
    local cache_dir="$1"
    mkdir -p "${cache_dir}"
    local archive_path="${cache_dir}/${FRAMEWORK_ARCHIVE_NAME}"
    local temp_path
    temp_path=$(mktemp "${cache_dir}/.${FRAMEWORK_ARCHIVE_NAME}.XXXXXX")
    register_temp_path "${temp_path}"
    local download_url="${FRAMEWORK_RELEASES_URL}/latest/download/${FRAMEWORK_ARCHIVE_NAME}"
    if ! curl -fsSL --max-time "${DOWNLOAD_TIMEOUT_SEC}" -o "${temp_path}" "${download_url}"; then
        log_error "下載開發運維框架失敗: ${download_url}"
        exit "${EXIT_DOWNLOAD_FAILED}"
    fi
    mv -f "${temp_path}" "${archive_path}"
}

# 僅顯示警告，網路無法連線或版本無法確認時不視為錯誤，不中止流程。
function warn_if_framework_outdated() {
    local framework_cache_dir="$1"
    local version_marker="${framework_cache_dir}/${FRAMEWORK_VERSION_MARKER}"
    local local_tag="" latest_tag
    [ -f "${version_marker}" ] && local_tag=$(cat "${version_marker}")
    if latest_tag=$(get_latest_release_tag) && [ -n "${latest_tag}" ] && [ "${latest_tag}" != "${local_tag}" ]; then
        log_warn "${UPDATE_WARNING_MESSAGE}"
    fi
    return 0
}

function ensure_framework_content() {
    local cache_dir="$1" framework_cache_dir="$2"
    if [ ! -d "${framework_cache_dir}" ]; then
        download_latest_framework "${cache_dir}"
    else
        warn_if_framework_outdated "${framework_cache_dir}"
    fi
}

# ------------------- 步驟三：建置框架 -------------------

function write_framework_version_marker() {
    local framework_dir="$1"
    local latest_tag
    if latest_tag=$(get_latest_release_tag); then
        printf '%s\n' "${latest_tag}" > "${framework_dir}/${FRAMEWORK_VERSION_MARKER}"
    fi
}

function extract_framework_archive() {
    local archive_path="$1" framework_cache_dir="$2"
    if [ -d "${framework_cache_dir}" ]; then
        rm -rf "${framework_cache_dir}"
    fi
    local staging_dir
    staging_dir=$(mktemp -d "$(dirname "${framework_cache_dir}")/.devops-cli-fwk-extract.XXXXXX")
    register_temp_path "${staging_dir}"
    if ! tar -xzf "${archive_path}" -C "${staging_dir}"; then
        log_error "解壓縮開發運維框架失敗: ${archive_path}"
        exit "${EXIT_EXTRACT_FAILED}"
    fi
    write_framework_version_marker "${staging_dir}"
    mv -f "${staging_dir}" "${framework_cache_dir}"
}

function rewrite_default_shell_paths() {
    local config_file="$1"
    local kind_dir_value="\${CLI_DIRECTORY}/${CACHE_DIRNAME}/${FRAMEWORK_CACHE_DIRNAME}/kind"
    local utils_dir_value="\${CLI_DIRECTORY}/${CACHE_DIRNAME}/${FRAMEWORK_CACHE_DIRNAME}/utils"
    local default_config_shell_path_value="\${CLI_DIRECTORY}/${DEFAULT_CONFIG_SHELL_SUBPATH}"
    sed -i "s#^CLI_SHELL_DIRECTORY=.*#CLI_SHELL_DIRECTORY=${kind_dir_value}#" "${config_file}"
    sed -i "s#^CLI_UTILS_DIRECTORY=.*#CLI_UTILS_DIRECTORY=${utils_dir_value}#" "${config_file}"
    sed -i "s#^DEFAULT_CONFIG_SHELL_PATH=.*#DEFAULT_CONFIG_SHELL_PATH=${default_config_shell_path_value}#" "${config_file}"
}

function ensure_ini_section_exists() {
    local file="$1" section="$2"
    if ! grep -qxF "${section}" "${file}"; then
        printf '\n%s\n' "${section}" >> "${file}"
    fi
}

function ini_section_has_key() {
    local file="$1" section="$2" key="$3"
    awk -v section="${section}" -v key="${key}" '
        $0 == section { in_section = 1; next }
        /^\[/ { in_section = 0 }
        in_section && index($0, key "=") == 1 { found = 1 }
        END { exit(found ? 0 : 1) }
    ' "${file}"
}

function append_ini_key_to_section() {
    local file="$1" section="$2" key_value_line="$3"
    local tmp
    tmp=$(mktemp "${file}.XXXXXX")
    register_temp_path "${tmp}"
    awk -v section="${section}" -v newline="${key_value_line}" '
        { print }
        $0 == section && !injected { print newline; injected = 1 }
    ' "${file}" > "${tmp}"
    mv -f "${tmp}" "${file}"
}

# 逐行掃描來源設定檔；分區標頭沿用來源分區，鍵值衝突時保留目標檔案（舊檔）原值。
function merge_cli_config_file() {
    local source_file="$1" target_file="$2"
    local merged_file
    merged_file=$(mktemp "${target_file}.XXXXXX")
    register_temp_path "${merged_file}"
    cp -f "${target_file}" "${merged_file}"

    local current_section="" line key
    while IFS= read -r line || [ -n "${line}" ]; do
        case "${line}" in
            ';'*|'')
                continue
                ;;
            '['*']')
                current_section="${line}"
                ensure_ini_section_exists "${merged_file}" "${current_section}"
                ;;
            *=*)
                key="${line%%=*}"
                if ! ini_section_has_key "${merged_file}" "${current_section}" "${key}"; then
                    append_ini_key_to_section "${merged_file}" "${current_section}" "${line}"
                fi
                ;;
        esac
    done < "${source_file}"

    mv -f "${merged_file}" "${target_file}"
}

# 以複製而非搬移方式部署，使框架快取目錄（framework_cache_dir）在
# 「已存在快取、僅需檢查版本」的重複執行情境下，仍保留完整、可再次部署的
# do.sh／do.ini 來源，不因單次部署而失效。
function deploy_cli_entry_script() {
    local framework_cache_dir="$1" project_dir="$2"
    local source_file="${framework_cache_dir}/${CLI_ENTRY_FILENAME}"
    local target_file="${project_dir}/${CLI_ENTRY_FILENAME}"
    cp -f "${source_file}" "${target_file}"
}

function deploy_cli_config_file() {
    local framework_cache_dir="$1" project_dir="$2"
    local source_file="${framework_cache_dir}/${CLI_CONFIG_FILENAME}"
    local target_file="${project_dir}/${CLI_CONFIG_FILENAME}"
    if [ -f "${target_file}" ]; then
        merge_cli_config_file "${source_file}" "${target_file}"
    else
        local staged_file
        staged_file=$(mktemp "${project_dir}/.${CLI_CONFIG_FILENAME}.XXXXXX")
        register_temp_path "${staged_file}"
        cp -f "${source_file}" "${staged_file}"
        rewrite_default_shell_paths "${staged_file}"
        mv -f "${staged_file}" "${target_file}"
    fi
}

# 建立零位元組空白檔案；零位元組檔案無斷行內容，天生即符合 LF 格式之要求，
# 亦可避免部分編輯器／工具在建立新檔時注入 CRLF 換行。
function ensure_runtime_config_file() {
    local project_dir="$1"
    local rc_file="${project_dir}/${CLI_RC_FILENAME}"
    if [ ! -f "${rc_file}" ]; then
        : > "${rc_file}"
    fi
}

function build_framework() {
    local project_dir="$1" cache_dir="$2" framework_cache_dir="$3"
    local archive_path="${cache_dir}/${FRAMEWORK_ARCHIVE_NAME}"
    if [ -f "${archive_path}" ]; then
        extract_framework_archive "${archive_path}" "${framework_cache_dir}"
        rm -f "${archive_path}"
    fi
    deploy_cli_entry_script "${framework_cache_dir}" "${project_dir}"
    deploy_cli_config_file "${framework_cache_dir}" "${project_dir}"
    ensure_runtime_config_file "${project_dir}"
}

# ------------------- 主流程 -------------------

function main() {
    parse_args "$@"
    require_command curl
    require_command tar
    require_command realpath

    local root_dir project_dir cache_dir framework_cache_dir
    root_dir=$(pwd -P)
    project_dir=$(resolve_project_dir "${root_dir}" "${PROJECT_DIR_INPUT}")
    cache_dir="${project_dir}/${CACHE_DIRNAME}"
    framework_cache_dir="${cache_dir}/${FRAMEWORK_CACHE_DIRNAME}"

    ensure_framework_content "${cache_dir}" "${framework_cache_dir}"
    build_framework "${project_dir}" "${cache_dir}" "${framework_cache_dir}"

    log_info "開發運維框架初始化完成: ${project_dir}"
}

# ------------------- 執行腳本 -------------------

main "${@}"
