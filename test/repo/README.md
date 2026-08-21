# 專案結構

開發運維框架用於專案有兩個命題：

+ 自訂命令，此部分參考[擴展結構](../extends)的說明
+ 動態配置參數並執行環境工具，指令可以提供參數並控制第三方命令工具 ( 例如 Docker )

## 替換執行參數檔

```
bash do.sh --rc=/usr/local/repo/shell/demo.rc env
```

以上範本將原本使用 ```do.rc``` 換成在指定目錄的 ```demo.rc``` 檔案，原則上可用的檔案應該都在 ```do.bat``` 啟動容器時掛載的目錄 ```-v %cd%:/usr/local/repo```。

## 執行容器

```
bash do.sh case1
```

以上範本為 [test/repo/shell/case1](./test/repo/shell/case1)，框架容器本身具有 docker cli，且在 ```do.bat``` 掛載 docker.sock 確保內部容器可以調用外部容器的服務，從而建立基於容器運行的指令操作。

## 容器目錄掛載

```
bash do.sh case2
```

以上範本為 [test/repo/shell/case2](./test/repo/shell/case2)，框架容器本身是一個封裝，倘若要調用第三方容器運行，則必需提供正確 HOST 目錄才能確保被啟用的容器擁有正確的路徑設定。

因此在 ```do.ini``` 需額外提供需要的資訊變數，

```
; Current control repository name.
CLI_REPO_NAME=${PROJECT_NAME}
; Current control repository at which directory in devsop framework container.
CLI_REPO_DIR=${CLI_DIRECTORY}
```

而這些變數可以透過 ```do.bat env``` 確認，並在執行命令時加以利用，確保被調用的容器使用正確的路徑資訊。
