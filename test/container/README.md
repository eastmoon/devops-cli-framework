# 容器封裝

容器封裝主要用途如下：

+ 類型 ( kind ) 腳本封裝於容器內。
+ 腳本執行環境需要工具，可封裝於 Dockerfile 中。
+ 藉由 Docker-in-Docker 透過服務控制服務，無需在本機中保留程式。
  - **注意**，若使用 "//var/run/docker.sock:/var/run/docker.sock" 會有資訊安全風險，若要使用應確保僅於開發環境，而非產品環境。

## 取得封裝檔案

採用以下方式取得封裝檔案

+ 執行 `do.bat pack` 發佈內容並封裝
+ 自 [devops-cli-framework : latest](https://github.com/eastmoon/devops-cli-framework/releases/latest) 頁面下載封裝檔
  - `devops-cli-framework_bash`，封裝自 Bash 容器內，僅提供基本命令測試
  - `devops-cli-framework_docker-cli`，封裝自 Docker CLI 容器內，可提供命令控制容器環境 ( 需掛載相應的 Docker Daemon Socket )

## 編譯映像檔

+ 解壓縮
```
tar -zxvf devops-cli-framework_bash.tgz -C devops-cli-fwk
```

+ 編譯映像檔
```
docker build -t devops-cli-fwk:bash .\devops-cli-fwk
```

## 執行

本次使用當前目錄內容執行，若要需額外測試，可建立新目錄後提供相應檔案執行。

+ 建立 [`do.yml`](./do.yml) 配置檔與內容
+ 建立 [`do.rc`](./do.rc) 配置檔與內容
+ 執行啟動器 [do.bat](./do.bat) / [do.sh](./do.sh)
```
# Windows
do.bat env
# Linux
bash do.sh env
```
