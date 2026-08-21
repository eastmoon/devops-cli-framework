#!/bin/bash
set -e

# Git Bash 底層依賴的是 MSYS2 系統，它為了讓 Windows 原生程式能吃得懂 Linux 格式的路徑，會預設開啟路徑轉換功能。
# 使用 MSYS_NO_PATHCONV 關閉自動路徑轉換功能
export MSYS_NO_PATHCONV=1

# ------------------- execute script -------------------

PROJECT_NAME=${PWD##*/}
docker run --rm \
  -e CLI_REPO_NAME=${PROJECT_NAME} \
  -e CLI_REPO_DIR="/usr/local/repo" \
  -v ${PWD}:/usr/local/repo \
  -v ${PWD}/do.rc:/usr/local/devops/do.rc:ro \
  -v ${PWD}/do.yml:/usr/local/devops/do.yml:ro \
  devops-cli-fwk:bash "${@}"
