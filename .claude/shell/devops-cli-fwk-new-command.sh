#!/usr/bin/env bash
#
# 輸入
#   + 命令名稱
#   + 專案目錄（可為空）
#
# 引導
#   + 軟體設計憲章: .codekit/memory/constitution/software-design.md
#   + 虛擬碼憲章: .codekit/memory/constitution/coding-pseudocode.md
#   + 程式編碼指南: .codekit/memory/guideline/coding.md
#
# 初始化邏輯
#
#   1. 確認專案目錄
#      + 若未指定，專案目錄採用目前專案根目錄
#      + 若已指定，專案目錄採用指定位置
#      + 專案目錄僅能為目前專案根目錄本身或其子目錄，超出此範圍須顯示錯誤並停止流程
#
#   2. 確認框架內容
#      + 若專案目錄之快取目錄 ./cache 內不存在 devops-cli-fwk 目錄
#        - 停止流程
#        - 顯示錯誤訊息「開發運維框架尚未安裝」
#
#   3. 建置命令
#      + 建立 conf/devops 目錄（若尚未存在）
#      + 於 conf/devops 目錄中建立命令名稱目錄
#      + 於命令名稱目錄建立格式為 LF 的 main.yml，內容如下：
#          desc: "New shell command."
#      + 於命令名稱目錄建立格式為 LF 的 postaction.sh，內容如下：
#          # 後處理腳本，執行前需確認的內容撰寫於此。
#      + 於命令名稱目錄建立格式為 LF 的 action.sh，內容如下：
#          # 處理腳本，主要執行的內容撰寫於此。
#      + 於命令名稱目錄建立格式為 LF 的 preaction.sh，內容如下：
#          # 前處理腳本，執行後需確認的內容撰寫於此。
#
# 輸出
#   + 虛擬碼: .claude/shell/devops-cli-fwk-new-command.psc
#       - 依循虛擬碼憲章之原則與撰寫風格
#       - 依循初始化邏輯訂定流程
#   + 程式碼: .claude/shell/devops-cli-fwk-new-command.sh
#       - 依循軟體設計憲章之設計原則
#       - 依循程式編碼指南之撰寫風格與注意事項
#       - 依循虛擬碼訂定流程
#       - 將本提示詞內容寫入檔案開頭註解（措辭得詮釋，但段落格式不得變更）
#
# Exit codes:
#   0: 成功
#   1: 參數錯誤、指定專案目錄不存在或超出允許範圍
#   2: 開發運維框架尚未安裝
#
set -euo pipefail

readonly DEVOPS_CONF_DIRNAME="conf/devops"
readonly FRAMEWORK_CACHE_MARKER_RELPATH="cache/devops-cli-fwk"

readonly MAIN_YML_FILENAME="main.yml"
readonly POSTACTION_FILENAME="postaction.sh"
readonly ACTION_FILENAME="action.sh"
readonly PREACTION_FILENAME="preaction.sh"

readonly MAIN_YML_DEFAULT_CONTENT='desc: "New shell command."'
readonly POSTACTION_DEFAULT_CONTENT='# 後處理腳本，執行前需確認的內容撰寫於此。'
readonly ACTION_DEFAULT_CONTENT='# 處理腳本，主要執行的內容撰寫於此。'
readonly PREACTION_DEFAULT_CONTENT='# 前處理腳本，執行後需確認的內容撰寫於此。'

log_error() {
  local error_message="$1"
  echo "ERROR: ${error_message}" >&2
}

is_path_within_root() {
  local candidate_path="$1"
  local root_path="$2"

  case "${candidate_path}" in
    "${root_path}" | "${root_path}"/*)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

validate_command_name() {
  local command_name="$1"

  if [[ -z "${command_name}" ]]; then
    log_error "缺少必要參數: 命令名稱"
    exit 1
  fi
}

resolve_project_root() {
  local requested_dir="$1"
  local current_project_root="$2"

  if [[ -z "${requested_dir}" ]]; then
    printf '%s\n' "${current_project_root}"
    return 0
  fi

  local absolute_dir
  if ! absolute_dir="$(cd -- "${requested_dir}" 2>/dev/null && pwd -P)"; then
    log_error "指定專案目錄不存在: ${requested_dir}"
    exit 1
  fi

  if ! is_path_within_root "${absolute_dir}" "${current_project_root}"; then
    log_error "指定專案目錄超出允許範圍: ${requested_dir}"
    exit 1
  fi

  printf '%s\n' "${absolute_dir}"
}

ensure_framework_installed() {
  local project_root="$1"

  if [[ ! -d "${project_root}/${FRAMEWORK_CACHE_MARKER_RELPATH}" ]]; then
    log_error "開發運維框架尚未安裝"
    exit 2
  fi
}

write_lf_file() {
  local target_file="$1"
  local file_content="$2"

  printf '%s\n' "${file_content}" >"${target_file}"
}

scaffold_command() {
  local project_root="$1"
  local command_name="$2"

  local devops_conf_dir="${project_root}/${DEVOPS_CONF_DIRNAME}"
  mkdir -p -- "${devops_conf_dir}"

  local command_dir="${devops_conf_dir}/${command_name}"
  mkdir -p -- "${command_dir}"

  write_lf_file "${command_dir}/${MAIN_YML_FILENAME}" "${MAIN_YML_DEFAULT_CONTENT}"
  write_lf_file "${command_dir}/${POSTACTION_FILENAME}" "${POSTACTION_DEFAULT_CONTENT}"
  write_lf_file "${command_dir}/${ACTION_FILENAME}" "${ACTION_DEFAULT_CONTENT}"
  write_lf_file "${command_dir}/${PREACTION_FILENAME}" "${PREACTION_DEFAULT_CONTENT}"

  printf '%s\n' "${command_dir}"
}

main() {
  local command_name="${1:-}"
  local project_dir_arg="${2:-}"

  validate_command_name "${command_name}"

  local current_project_root
  current_project_root="$(pwd -P)"

  local project_root
  project_root="$(resolve_project_root "${project_dir_arg}" "${current_project_root}")"

  ensure_framework_installed "${project_root}"

  local created_command_dir
  created_command_dir="$(scaffold_command "${project_root}" "${command_name}")"

  echo "命令骨架已建立: ${created_command_dir}"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
