# 開發運維命令介面框架

基於 [Command-line-interface-application](https://github.com/eastmoon/command-line-interface-application) 延伸設計的開發運維命令架構與實務框架。

## 簡介

設計 DevOps 的運作流程，必然包含持續整合與持續部屬兩項設計，而依據公司、團隊選擇的開發環境架構則會依存不同的持續整合、持續部屬框架，例如 Gitlab、Jenkins、Ansible。

而在持續整合框架中，則必需讓程式碼進入持續整合流程中才可確認實際執行成果是否符合預期，在多數案例中，框架相關的指令變更次數極少，也因此延伸以下問題：

1. 變動機率小，導致維護技術不易學習與訓練。
2. 開發人員實際環境與整合編譯環境不一致。
3. 開發人員環境建置複雜。
4. 僅能於整合環境測試與修復整合異常。

考量上述問題，最初歸納出專案庫命令介面 ( Repository Command-Line interface ) 的架構概念。

**持續整合框架著重整合的流程，專案庫命令介面面著重專案庫整合的流程，並制定統一的命令介面供持續整合框架運用。**

+ 持續整合管理單一或複數專案的整合流程
+ 專案庫的編譯與發佈流程應歸納於專案內
+ 專案庫命令介面將專案編譯與發佈流程封裝於命令內
    - 封裝應包括專案執行環境建置
    - 封裝應包括專案編譯指令操作
    - 封裝應包括專案發佈於產品環境的額外資訊或資源
+ 持續整合框架基於流程需要執行相應的命令

```
DevOps CI -- execute --> Repository CLI -- execute --> npm、copy etc.
```

而在持續部屬框架的運用上，也同樣存在上述問題，然而 IT、OP 人員基於 IaC ( Infrastructure as Code ) 原則記錄的部屬過程，容易在缺乏完善記錄規範與監管下，導致部屬環境與流程難以維護。

為解決持續部屬的問題，需基於專案庫為單位的 IaC 設計，並導入專案庫命令介面概念來解決環境建置、重啟、關閉等狀態。

考慮持續部屬與持續整合的問題，進一步將專案庫命令介面架構概念，延伸為開發運維命令介面 ( DevOps Command-Line interface ) 架構概念。

**開發運維命令介面以專案庫為單位，將發佈、運維等流程封裝於命令介面內，讓開發運維框架可基於統一命令入口運用。**

## 架構設計

### 容器化

+ 擴大可用作業系統環境
+ 避免生命週期腳本修改
+ 減少導入複雜度，現有導入機制需將生命週期腳本匯入，但因過度複雜容易誤解

本專案提供以下開發運維專案指令：

+ 開發環境：```do dev```，執行此指令會基於 Docker 啟動框架容器並進入其中
+ 發佈框架：```do pub```，執行此指令會將框架彙整自 ```cache/publish``` 目錄中
+ 封裝框架：```do pack```，執行此指令會同時執行 ```do pub``` 並依據將發佈內容編譯為 devops-cli-fw:latest 映像檔

### 框架結構

```
devops-cli
    └ kind
    └ shell
    └ utils
    └ do.sh
    └ do.ini
    └ do.rc
    └ do.yml
```

+ 進入點 ```do.sh```，框架封裝的容器會建立可執行腳本並透過此進入點運行框架。
    - ```do.ini``` 定義用於框架流程的全域變數。
    - ```do.rc``` 定義框架命令執行時的執行階段變數，主要用於命令邏輯需要。
        + 執行階段變數採用疊加擴增，重複名稱的變數會被後執行的 ```do.rc``` 檔覆蓋
        + 第一執行，類型命令集中的 ```do.rc```，此變數為提供給命令集中執行邏輯所需要
        + 第二執行，框架目錄中的 ```do.rc```，主要用於自訂邏輯使用或覆蓋命令集變數
        + 第三執行，框架執行若提供 ```--rc```，則額外執行該檔案，用於覆蓋前兩個產生的變數
    - ```do.yml``` 定義框架參數
        + 原則上與 ```do.ini``` 用途相似，但影響變數會依據邏輯改變數量。
        + 參數皆有預設值，若執行階段提供該檔案，可用來變更運作參數。
+ ```utils``` 為框架工具程式目錄。
+ ```kind``` 為基於類型區分的命令集目錄。
    - 預設執行 ```default``` 的命令集，若要更換使用 ```do.yml```。
    - 框架開發應優先彙整命令於此目錄，並依據用途區分。
+ ```shell``` 為客製化命令集目錄。
    - 提供專案自身的命令、擴展或覆蓋類型命令中的邏輯。
    - 框架開發時不應使用此目錄，該目錄提供給專案執行框架時掛載。
    - 預設位置如結構圖所示，若要替換目錄位置使用 ```do.yml```

### 跨平台

本專案框架完成容器化封裝後，會在 Docker 的映像檔清單中；實務運用則依據作業系統環境執行啟動腳本，讓啟動腳本基於映像檔啟動容器並執行相應指令。

跨平台的操作，相應內容參考 ```test``` 目錄，其中包括以下內容：

+ 啟動腳本 ```do``` 具有 bat、sh、pl、zsh 等附檔名版本，以對應在不同作業系統下的容器啟動程序
+ 提供 ```do.yml``` 設定框架運作參數
+ 提供 ```do.rc``` 設定命令執行的自訂變數
+ 提供 ```shell``` 目錄建置、擴展、覆蓋可運行命令

若要提供額外的執行階段變數，可放置於 ```shell``` 目錄，例如 ```shell/demo.rc```，並於命令執行時提供 ```do --rc=/usr/local/devops/shell/demo.rc env```，以此覆蓋 ```do.rc``` 中的變數。

### 框架配置檔

本專案框架完成容器化封裝後，會將開發完成的命令集分存於容器供開發者運用，對此可透過 ```do.yml``` 配置相關框架資訊。

+ 設定 path 指定專案客製的腳本集目錄
  - 預設為 ```/usr/local/devops/shell```
+ 設定 kind 使用指定範本
  - 範本不指定則使用預設 ( default ) 範本
  - 範本包括至少一個命令
  - 範本預設在 ```/usr/local/devops-cli/kind``` 下

### 命令結構

本專案依據 [Command-line-interface-application](https://github.com/eastmoon/command-line-interface-application) 為基礎，考量命令檔精簡化，與避免開發人員撰寫邏輯於適當位置，將命令檔改為命令目錄，並於目錄中設計以下檔案類型：

+ ```main.yml```，命令資訊與屬性配置檔，若無此檔則該目錄內容不被視為命令。
+ ```main.sh```，命令流程檔，用來撰寫工作流執行的管理。
+ ```preaction.sh```、```action.sh```、```postaction.sh```，命令執行的工作流檔，撰寫開發運維流程腳本內容於此。

命令配置檔 ```main.yml``` 結構如下：

```
desc: "short description with command."
attr:
  VAL: 4321
  OP: 0
args:
  --val:
    var: VAL
    type: string
    desc: "val description"
  --op:
    var: OP
    type: bool
    desc: "op description"
```

+ ```desc``` 為命令的描述
+ ```attr``` 為命令執行時會建立的屬性變數與預設值
    - 設定 ```STOP-CLI-PARSER``` 變數會中斷框架解析命令的過程，並將未解晰的內容以參數方式傳遞給 ```main.sh``` 或工作流 ```action.sh``` 中
+ ```args``` 為命令提供的選項參數
    - ```--val```、```-op``` 為選項參數名，用於 ```do [cmd] --val=1234``` 中
    - ```desc``` 為此選項的描述
    - ```var``` 為此選項參數提供時會覆蓋的屬性變數名稱
    - ```type``` 為此選項的類型，主要分為 string 與 bool 兩類
        + string：例如 ```--val=1234``` 會將 1234 寫入屬性變數
        + bool：例如 ```--op``` 會將數值 1 寫入屬性變數

#### 命令檢索

開發運維框架在搜尋命令時，主要流程如下:

```
do.sh -- search --> main.yml
```

因此若不存在 ```main.yml``` 檔案，則該目錄不會視為一個命令結構

#### 命令資訊

開發運維框架在取得命令資訊時，主要流程如下:

```
do.sh -- read --> main.yml
```

例如 ```do env --help```，會參考 ```env``` 命令的 ```main.yml``` 建立資訊，並搜尋 ```env``` 目錄的子目錄作為子命令。

#### 命令執行

開發運維框架在執行命令時，主要流程如下:

1. 讀取 ```main.yml``` 的 ```attr``` 建立屬性變數。
2. 讀取 ```main.yml``` 的 ```args``` 解析參數並覆蓋或增加屬性變數
3. 若存在 ```main.sh``` 則執行該檔案，若不存在 ```main.sh``` 則執行標準工作流 action
4. 若執行工作流 ( workflow ) action，則會依照工作流名稱依據執行 ```preaction.sh```、```action.sh```、```postaction.sh``` 腳本檔

需要注意，開發人員可依據需要更換 ```main.sh``` 的內容，亦可替換想要執行的工作流名稱。

### 命令執行

利用開發運維框架的專案，共有以下命令可使用：

+ 由 ```do.yml``` 設定類型 ( kind ) 所提供的命令
+ 由 ```do.yml``` 設定的客製目錄 ( path ) 中所提供的命令

原則上，這兩類命令執行其先後關係：

1. 專案客製的命令
2. 框架類型的命令

以下舉例來說明：

#### 類型中的命令

這類命令應封裝於框架容器中

```
/usr/local/devops/kind/[kind-name]
    └ env
        └ main.yml
```

執行 ```do --help``` 則會顯示 ```env``` 命令資訊，並可用 ```do env``` 執行該命令。

#### 專案客製的命令

這類命令應於框架容器執行時掛載

```
/usr/local/devops/shell
    └ new
        └ main.yml
```

執行 ```do --help``` 則會顯示 ```new``` 命令資訊，並可用 ```do new``` 執行該命令。

#### 預設命令流程

倘若命令目錄不提供 ```main.sh``` 檔案則會執行標準工作流 action，會依據執行 ```preaction.sh```、```action.sh```、```postaction.sh``` 腳本檔。

```
/usr/local/devops/shell
    └ new
        └ main.yml
        └ action.sh
```

執行 ```do new``` 命令，會先執行 ```main.yml``` 建立屬性後，執行標準工作流中可以找到的 ```action.sh``` 檔案。

#### 專案覆蓋類型命令

若類型命令內容不適當，可以使用客製命令覆蓋。

```
/usr/local/devops/kind/[kind-name]
    └ env
        └ main.sh
/usr/local/devops/shell
    └ env
        └ main.sh
```

在上述結構中，會優先執行客製 ```main.sh``` 檔案，而忽略類型中的 ```main.sh``` 檔案；這個邏輯同樣適用 ```preaction.sh```、```action.sh```、```postaction.sh``` 三個工作流檔案。

#### 專案擴展類型命令

若類型命令若有不足之處，或需要添加額外行為時使用，可使用 super 函數。

```
/usr/local/devops/kind/[kind-name]
    └ env
        └ main.sh
/usr/local/devops/shell
    └ new
        └ main.sh
```

依據命令覆蓋原則，框架會執行客製 ```main.sh``` 檔案，但倘若如下所示，在檔案中執行 super 函數，則會在完成 echo 動作後，執行類型中的 ```main.sh``` 檔案。

```
# shell/new/main.sh
echo "Run custom main script"
super
```

若類型中並無 ```main.sh``` 檔案，則會執行標準工作流。

利用 super 函數擴展行為，此邏輯同樣適用 ```preaction.sh```、```action.sh```、```postaction.sh``` 三個工作流檔案。

### 測試

+ 階層結構
```
devops-cli --help
devops-cli demo --help
devops-cli demo dev --help
```

+ 參數替換
```
devops-cli env --op
devops-cli env --val=5678
devops-cli env --val="1234 5678"
```

+ 執行命令，測試中斷屬性 ```STOP-CLI-PARSER```
```
devops-cli exec demo -e="1234 5678" tmp
```

+ 執行預設工作流命令，不提供 ```main.sh```
```
## 執行
devops-cli demo dev
## 輸出
[+] pre-ction script
[+] action script
[+] post-ction script
```

+ 執行擴展工作流命令，不提供 ```main.sh```，在類型提供 ```action.sh```，客製提供 ```postaction.sh```
```
## 執行
devops-cli demo dup
## 輸出
[+] action script in kind
[+] post-action script in shell
```

+ 執行覆蓋命令配置檔，客製提供 ```main.yml```，覆蓋類型的 ```main.yml```
```
## 執行
devops-cli demo dup --help
## 輸出
This is a Command Line Interface with project devops
Replace legacy shell command.

Options:
    --help, -h        Show more command information.

Run 'do [COMMAND] --help' for more information.
```

+ 執行客製命令，在類型中不存在的命令
```
devops-cli demo new
```

+ 執行客製擴展類型命令，在客製命令中使用 super 函數
```
## 執行
devops-cli demo
## 輸出
--- custom main script ---
--- main script ---
[+] pre-ction script
[+] custom action script
[+] action script
[+] post-ction script
```

## 參考
