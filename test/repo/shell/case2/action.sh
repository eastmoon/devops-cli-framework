echo "CLI_REPO_NAME : ${CLI_REPO_NAME}"
echo "CLI_REPO_DIR : ${CLI_REPO_DIR}"
echo ""
echo "Show repository content with BASH container."
# Git Bash 底層依賴的是 MSYS2 系統，它為了讓 Windows 原生程式能吃得懂 Linux 格式的路徑，會預設開啟路徑轉換功能。
# 使用 MSYS_NO_PATHCONV 關閉自動路徑轉換功能
export MSYS_NO_PATHCONV=1
# 後續所有的 docker 指令都不會被擅自竄改路徑
docker run --rm \
    -v ${CLI_REPO_DIR}:/app \
    -w /app \
    bash -c "ls -al"
