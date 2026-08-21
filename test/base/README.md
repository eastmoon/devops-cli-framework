# 基礎結構

基礎結構在說明開發運維框架，命令運行的基本邏輯。

## 階層結構

以下範本為 [kind/demo/case1](../../src/kind/demo/case1)，其為標準命令結構，執行時會先執行 ```main.sh``` 並基於 ```super``` 函數執行標準流程，依序運行 ```preaction.sh```、```action.sh```、```postaction.sh```。

```
## 執行
bash do.sh case1
## 輸出
--- main script ---
[+] pre-action script
[+] action script
[+] post-action script
```

以下範本為 [kind/demo/case1/sub](../../src/kind/demo/case1/sub)，其為簡略命令結構，執行時因為不存在 ```main.sh```，直接執行標準流程，並依序運行 ```preaction.sh```、```action.sh```、```postaction.sh```。

```
## 執行
bash do.sh case1 sub
## 輸出
[+] pre-action script
[+] action script
[+] post-action script
```

## 預設變數

以下範本為 [kind/demo/case2](../../src/kind/demo/case2)，配置設定 ```main.yml``` 的 ```attr``` 可以宣告該命令的屬性變數。

```
bash do.sh case2
```

## 中斷命令解析

以下範本為 [kind/demo/case2](../../src/kind/demo/case2)，配置設定 ```main.yml``` 的 ```attr``` 包括特殊屬性 ```STOP-CLI-PARSER```，此屬性會中斷框架解析流程，將未解析的命令、參數傳遞給此命令。

```
bash do.sh case2 -e="1234 5678" tmp
```

## 參數替換

以下範本為 [kind/demo/case3](../../src/kind/demo/case3)，配置設定 ```main.yml``` 的 ```args``` 可以宣告該命令的會解析的參數，原則上 ```args``` 解析的值會存入 ```attr``` 中宣告的一個屬性變數。

```
bash do.sh case3
bash do.sh case3 --op
bash do.sh case3 --val=5678
bash do.sh case3 --val="1234 5678"
```
