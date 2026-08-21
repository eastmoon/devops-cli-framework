# 擴展結構

開發運維框架有兩個命令來源，類型 (kind)、自訂 ( custom ) 命令。

+ 類型 (kind) 來源於 `src` 目錄中，當專案發佈、封裝後會預設於框架中的命令
+ 自訂 (custom) 來源於本地指定目錄中，當啟動開發運維腳本時，會將此目錄內的腳本納入其中
  - 設定 ```do.ini``` 中的 `DEFAULT_CONFIG_SHELL_PATH` 變數，調整指定目錄位置
  - 設定 ```do.yml``` 中的 `path: [目錄位置]` 變數，調整指定目錄位置

## 新增命令

```
## 執行
bash do.sh new
```

以上範本為 [shell/new](./shell/new)，配置設定 ```do.yml``` 的 ```kind``` 決定會使用框架中提供的類型為基礎，而 ```path``` 指向的目錄若再 ```do.bat``` 有掛載本地目錄，則該目錄的指令會添加或覆蓋原有的命令。

## 覆蓋命令

```
## 執行
bash do.sh case1
## 輸出
--- custom main script ---
--- main script ---
[+] pre-ction script
[+] custom action script
[+] action script
[+] post-ction script
```

以上範本為 [shell/case1](./shell/case1)，在未提供覆蓋前 ```do.bat case1``` 的執行結果應如前述階層結構所述，但在此因為掛載擴展命令且命令目錄相同，框架會優先使用擴展的內容，若此擴展腳本執行 ```super``` 函數則會呼叫框架內原本的腳本。

## 覆蓋與擴展腳本

請至 [test/base](../test/base) 目錄執行一下指令。

```
## 執行
bash do.sh case1 onlyaction
## 輸出
[+] action script
```

回到 [test/extends](./test/extends) 目錄執行一下指令。

```
## 執行
bash do.sh case1 onlyaction
## 輸出
[+] action script
[+] post-action script in shell
```

也可分別在不同目錄執行 ```do.bat case1 onlyaction -h```。

以上範本分別為：

+ [kind/demo/case1/onlyaction](../../src/kind/demo/case1/onlyaction)
+ [shell/case1/onlyaction](./shell/case1/onlyaction)

擴展指令的特徵除了新增、覆蓋外就是利用擴大原本未添加的行為，例如範本中框架類型在 ```onlyaction``` 僅有 ```action.sh```，而在擴展的 ```onlyaction``` 新增了 ```postaction.sh``` 並修改 ```main.yml``` 來覆蓋說明的描述內容。
