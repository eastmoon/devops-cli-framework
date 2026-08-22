# Linux Shell Script 程式碼摘要指南 (Summarizing Guideline)

> 適用語言 (PROGRAM_LANGUAGE)：Linux Shell Script（`sh` / `bash`）
> 本指南依據「程式摘要憲章」(.codekit/memory/constitution/summarizing-guideline.md) 之七大原則（I. 程式理解、II. 軟體逆向工程、III. 程式碼摘要、IV. 意圖提升、V. 去噪與抽象化、VI. 語意分塊、VII. 領域詞彙映射），並依循「程式語言指南」(.codekit/memory/guideline/coding.md) 所定義之 Shell Script 撰寫慣例（函式、獨立腳本檔案、`source` 模組化、環境變數、`set -euo pipefail`、退出碼慣例、`trap`／`local`／`readonly` 等機制），將摘要原則逐條詮釋為適用於 Shell Script 之具體判讀規則。
>
> Shell Script 不具備類別、介面、例外拋出等物件導向機制；本指南所有判讀方式皆以函式 (function)、獨立腳本檔案 (`.sh`)、退出碼 (exit code)、`trap`、`set` 選項等 Shell 原生機制為基礎，不得假設 Shell 具有此類結構，亦不得於摘要中使用「拋出例外」「實例化物件」等不對應 Shell 實際行為之措辭。

## 程式碼摘要規則 (Code Rules)

以下逐條保留「程式摘要憲章」之原則名稱與鐵律，並針對 Shell Script 補充其在解讀時的具體判讀方式與風格。

### I. 程式理解 (Program Comprehension)

摘要之根本目的在於協助讀者建立與程式實際行為一致的心智模型，而非單純轉譯程式碼文字。

#### I.1 建立正確心智模型 (Building an Accurate Mental Model)
- 鐵律：摘要須協助讀者形成與程式實際行為一致的心智模型，內容不得與程式碼實際邏輯有出入。
- Shell 判讀方式：摘要函式行為時，須對照其**實際**退出碼語意（成功 `0`、失敗 `1`–`125`，依「程式語言指南」II.7）與 stdout／stderr 輸出內容，不得僅憑函式名稱臆測行為；若腳本頂部宣告 `set -euo pipefail`，摘要中涉及錯誤處理之描述須反映「指令失敗即終止、未定義變數即報錯、管線任一階段失敗即整體失敗」之實際語意。
- 判讀提醒：若函式以 `cmd || true` 且未記錄任何訊息即忽略失敗，摘要不得美化為「失敗時會記錄警告並重試」，須如實反映其吞噬失敗之行為。

#### I.2 由上而下的理解順序 (Top-Down Comprehension Order)
- 鐵律：摘要應遵循由整體到細節的呈現順序，先陳述高階目的，再視需要展開細節。
- Shell 判讀方式：對應「程式語言指南」I.9「單一抽象層次」，`main` 函式或腳本頂層流程讀起來像步驟目錄；摘要應先概括 `main` 依序呼叫 `parse_args`／`validate_env`／`run_deploy` 等高階函式所達成之整體目的，再視需要逐層展開至個別函式，最後才進入 `sed`／`awk` 等低階實作細節。

#### I.3 認知負荷最小化 (Minimizing Cognitive Load)
- 鐵律：摘要之長度與資訊密度須控制在讀者可負荷之範圍內，避免一次性堆疊過多細節。
- Shell 判讀方式：比照「程式語言指南」I.2「函式體以能在單一畫面內閱讀完畢為原則」之精神，單一函式之摘要以簡短數句為度；若邏輯已依 I.5 抽出至 `lib/`、`shell/utils/` 等共用目錄並以 `source` 引入，摘要共用函式呼叫處時無須重複展開其內部實作，僅需標示引用目的。

### II. 軟體逆向工程 (Software Reverse Engineering)

在缺乏原始設計文件時，摘要須扮演「從既有實作還原設計意圖」的橋樑角色。

#### II.1 從實作反推設計意圖 (Recovering Design Intent from Implementation)
- 鐵律：摘要須嘗試從程式碼結構、命名與呼叫關係反推其背後的設計決策與意圖，而非僅描述表面的程式碼排列。
- Shell 判讀方式：依「程式語言指南」設計限制章節之詮釋反推意圖——若腳本以 `case "$subcommand" in ...)` 或 `"cmd_${subcommand}"` 動態分派模式組織（對應 OCP），可推斷其設計意圖為「開放新增子指令、封閉既有邏輯修改」；若腳本拆分為 `lib/log.sh`、`lib/validate.sh`、`deploy.sh`（對應 ISP／SoC），可推斷各檔案分別承擔獨立關注點，而非隨意的檔案切割。

#### II.2 領域概念識別 (Domain Concept Recovery)
- 鐵律：摘要須識別並標示程式碼中隱含的領域概念（如業務規則、狀態轉換），而非僅描述技術結構。
- Shell 判讀方式：依「程式語言指南」I.1 命名慣例（`UPPER_SNAKE_CASE` 環境變數、`is_`／`has_`／`should_` 前綴之布林函式）反推領域狀態與規則，例如 `is_authorized`、`DEPLOY_ENV=production` 揭示「授權檢查」「部署環境切換」等業務概念，摘要須以此類領域語彙呈現，而非僅描述「檢查一個布林變數」。

#### II.3 保留不確定性標註 (Preserving Uncertainty)
- 鐵律：若程式碼證據不足以確定其原始意圖，摘要須明確標示為推測，不得將推測結果陳述為確定事實。
- Shell 判讀方式：當腳本違反「程式語言指南」I.1「同一概念須使用一致變數名稱」（如同一設定路徑於不同腳本中分別命名為 `CONF`／`CFG_FILE`／`CONFIG_PATH`），或退出碼語意未於腳本頭部註解文件化（違反 II.7 之要求）時，摘要須明確標註「推測用途為...」，不得逕自論斷其設計原意。

### III. 程式碼摘要 (Source Code Summarization)

以精簡自然語言描述程式碼片段之功能、目的與脈絡，供人類讀者快速掌握程式碼用途而不必閱讀完整實作。

#### III.1 目的與功能優先 (Purpose-and-Function-First)
- 鐵律：摘要須優先描述程式碼片段之目的與對外提供的功能，不得以次要資訊喧賓奪主。
- Shell 判讀方式：以「輸入 → 輸出」框架描述函式對外功能——輸入對應位置參數 (`$@`)、環境變數或透過 `local` 傳入之區域變數；輸出對應 `echo`／`printf` 寫入 stdout 之結果，或以 `return`／`exit` 表示之退出碼（依「程式語言指南」I.2 函式設計慣例：函式不應以全域變數作為輸出參數）。

#### III.2 脈絡涵蓋 (Contextual Coverage)
- 鐵律：摘要須涵蓋程式碼運作所需之關鍵脈絡（如觸發時機、依賴之外部資源、呼叫前提），避免脫離脈絡的片段描述。
- Shell 判讀方式：脈絡須包含——前置條件（依 II.1／II.3，如 `${VAR:?}` 要求之必要變數、`command -v` 確認之必要外部指令）、外部相依（依 II.6／II.9，如 `curl --max-time` 逾時設定、`jq` 等第三方工具）、觸發時機（如是否經 `trap` 於 `EXIT`／`INT`／`TERM` 時被呼叫）。

#### III.3 精簡與完整之平衡 (Balancing Conciseness and Completeness)
- 鐵律：摘要須以最精簡之自然語言達成完整表意，禁止為求精簡而遺漏影響讀者理解之關鍵資訊。
- Shell 判讀方式：精簡處理可省略之細節（如標準的 `local` 變數宣告本身），但不得省略影響行為判讀之退出碼語意（依 II.7）與明確副作用（依 I.10，如函式是否會 `update_config`／`remove_lockfile`）；副作用與失敗模式屬於「完整」之底線，不因精簡而犧牲。

### IV. 意圖提升 (Intent Elevation / What over How)

摘要須陳述程式碼「做什麼／為何存在」，而非逐步複述「如何實作」。

#### IV.1 禁止逐行複述 (No Line-by-Line Restatement)
- 鐵律：摘要禁止逐行翻譯程式碼語法，而須描述其達成的業務目的。
- Shell 判讀方式：例如 `for f in "${LOG_DIR}"/*.log; do ...; done` 不得摘要為「這個迴圈跑過 LOG_DIR 底下的每個 .log 檔案」，而應描述為「彙整部署紀錄檔以產出每日部署報表」；`[[ $rc -ne 0 ]] && exit 1` 不得逐字翻譯為「如果 rc 不等於 0 就結束」，而應描述為「前置指令失敗時中止腳本」。

#### IV.2 聚焦行為契約 (Focus on Behavioral Contract)
- 鐵律：摘要層級須高於程式碼的控制流程層級，聚焦於函式對外承諾的行為契約，而非內部如何達成該承諾。
- Shell 判讀方式：行為契約 = 參數與環境變數輸入、退出碼語意（成功／失敗分類）、stdout 輸出格式、明確副作用；對應「程式語言指南」III.LSP，同一類用途函式（所有 `validate_*`、所有 `deploy_target_*`）遵循一致契約，摘要應以「契約」層級描述，不必逐一比較各函式內部 `if`／`case` 分支差異。

#### IV.3 不重複顯而易見的實作 (No Restating the Obvious)
- 鐵律：若程式碼命名或結構本身已能表達實作方式，摘要不得重複贅述該顯而易見的實作細節。
- Shell 判讀方式：若函式名稱已依「程式語言指南」I.1 清楚表意（如 `remove_lockfile`、`validate_config`），摘要無須贅述「此函式會刪除鎖檔」「此函式會驗證設定」等與函式名稱同義反覆之敘述，應直接說明其在整體流程中的角色與觸發條件。

### V. 去噪與抽象化 (De-noising and Abstraction)

摘要須濾除與核心功能無關的雜訊，並將具體實作抽象為概念層級描述。

#### V.1 濾除輔助性程式碼 (Filtering Auxiliary Code)
- 鐵律：日誌記錄、效能監控埋點、防禦性檢查等輔助性程式碼，除非為該片段之核心關注點，否則不納入摘要。
- Shell 判讀方式：`log_info`／`log_debug` 呼叫、`set -x`／`set +x` 除錯開關、純粹之進度輸出（`echo "Step 1..."`）視為輔助性程式碼予以濾除；但若摘要對象本身即為「記錄機制」或「除錯流程」，則此類程式碼轉為核心關注點，不適用本條濾除。

#### V.2 實作細節概念化 (Conceptualizing Implementation Details)
- 鐵律：具體的變數名稱、迴圈計數器、暫存變數等實作細節，不得直接出現於摘要中，須以其代表的概念取代。
- Shell 判讀方式：迴圈中之 `i`、`tmp`、`$1`／`$2` 等區域變數或位置參數，摘要中須轉譯為其代表概念（如「重試次數」「目標主機」），不得直接引用變數字面名稱；`local -a copy=("${arr[@]}")` 之區域複本手法，摘要應描述為「避免修改呼叫端傳入之陣列」的意圖，而非描述其陣列複製語法本身。

#### V.3 樣板程式碼視為雜訊 (Boilerplate as Noise)
- 鐵律：重複出現的樣板程式碼（如標準的錯誤處理框架、標準的資源釋放流程）視為雜訊，僅在其偏離標準模式時才需說明。
- Shell 判讀方式：依「程式語言指南」II.8／II.9 之標準模式——`trap 'cleanup' EXIT` 搭配 `mktemp`、`command -v tool_name >/dev/null 2>&1 || exit 1` 之依賴檢查——屬於專案慣用樣板，摘要通常僅需一句帶過（如「依標準流程確保暫存資源釋放」），僅當該樣板被省略、簡化或以非標準方式實作時，才需特別指出此偏離。

### VI. 語意分塊 (Semantic Chunking)

摘要須依程式碼的語意邊界分段，而非依實體邊界（如檔案、行數）機械切割。

#### VI.1 依功能單元劃分 (Division by Functional Unit)
- 鐵律：分塊依「功能單元」劃分，不得在語意未完整表達之處中斷。
- Shell 判讀方式：對應「程式語言指南」設計限制之 SRP 與 SoC，分塊邊界應對齊「一個腳本檔案對應一項職責」（如 `deploy.sh` 一個分塊、`validate.sh` 另一個分塊）或「同一目錄下圍繞同一職責之函式群組」（如 `cmd_*` 分派函式群為一個分塊），不得依檔案行數或空白行機械切割，切斷同一函式或同一子指令群組之語意。

#### VI.2 分塊獨立可理解 (Chunk-Level Independence)
- 鐵律：單一分塊之摘要須能獨立表達完整意涵，不依賴讀者同時參照其他分塊才能理解。
- Shell 判讀方式：對應「程式語言指南」VI 高內聚低耦合，模組（腳本檔案）間僅透過明確函式介面（`source` 後呼叫具名函式）溝通；分塊摘要比照此原則，只需交代該分塊對外之輸入（參數／環境變數）與輸出（stdout／退出碼）介面，即可獨立理解，不須讀者連帶閱讀其 `source` 之其他檔案內部實作。

#### VI.3 巢狀結構由外而內展開 (Outside-In Expansion for Nested Structures)
- 鐵律：巢狀結構之摘要，須先總結最外層之整體目的，再視需要展開內層分塊。
- Shell 判讀方式：`main` 呼叫 `run_deploy`，`run_deploy` 再呼叫 `deploy_target_k8s`／`deploy_target_vm`（依 OCP 之子指令擴充模式）——摘要須先總結 `main` 之整體目的（「協調部署流程」），再依需要展開 `run_deploy` 依目標環境分派之邏輯，最後才視讀者需求展開個別 `deploy_target_*` 之實作。

### VII. 領域詞彙映射 (Domain Vocabulary Mapping)

摘要用語須對應至該軟體所屬業務領域之既有詞彙，而非直接沿用程式碼中的技術命名。

#### VII.1 技術命名轉譯 (Technical-to-Domain Translation)
- 鐵律：程式碼中的技術性命名須轉譯為該業務領域慣用之詞彙。
- Shell 判讀方式：`lower_snake_case` 函式名稱（依「程式語言指南」I.1）須轉譯為業務語彙，例如 `deploy_target_k8s()` 轉譯為「部署至 Kubernetes 叢集」而非「呼叫 deploy target k8s 函式」；`is_authorized()` 轉譯為「檢查操作者是否具備權限」而非「呼叫 is authorized」。

#### VII.2 詞彙一致性 (Terminology Consistency)
- 鐵律：同一領域概念於摘要全文中須使用一致的詞彙，不得因程式碼中命名不一致而在摘要中出現多種說法指稱同一概念。
- Shell 判讀方式：即便程式碼違反「程式語言指南」I.1「同一概念須使用一致變數名稱」之規則（如 `CONF`／`CFG_FILE`／`CONFIG_PATH` 混用指稱同一設定檔路徑），摘要仍須自行統一為單一詞彙（如全文統一稱「設定檔路徑」），不得原樣照搬程式碼中不一致之命名到摘要中。

#### VII.3 以現行領域詞彙為準 (Current Domain Terminology Precedence)
- 鐵律：若程式碼命名與領域詞彙有落差，摘要應以現行領域詞彙為準，不遷就過時命名。
- Shell 判讀方式：對應「程式語言指南」OCP 條目「已發布函式簽章變更須先標記棄用、提供相容包裝函式」，若腳本中存在因相容性保留之舊命名包裝函式（如 `old_deploy_vm()` 包裝新版 `deploy_target_vm()`），摘要須以現行版本 `deploy_target_vm` 所代表之現行領域詞彙為準，並可註明該舊名稱為相容性保留之棄用包裝，而非以舊名稱之字面意義描述其業務用途。

## 解讀時的注意規範 (Interpreting Constraints)

以下規範以「程式摘要憲章」為原則基礎，列出在摘要「程式語言指南」所定義之 Shell Script 程式碼時應遵守之具體注意事項，每條均附簡短程式碼片段作為參考範例。

### 1. 辨識並濾除純粹的日誌輸出與除錯開關
純粹的進度日誌、`set -x`／`set +x` 除錯開關屬輔助性程式碼（對應 V.1），除非摘要對象即為記錄機制本身，否則應濾除，不得逐行轉譯為摘要內容。

```sh
deploy_service() {
  local target="$1"
  log_info "Starting deployment to ${target}"   # 輔助性輸出，摘要應濾除
  set -x                                        # 除錯開關，摘要應濾除
  kubectl apply -f "manifests/${target}.yaml"
  set +x
  log_info "Deployment to ${target} finished"   # 輔助性輸出，摘要應濾除
}
```
摘要應寫為「將指定目標之 manifest 套用至叢集以完成部署」，而非逐句轉述 `log_info`／`set -x` 呼叫。

### 2. 將 `trap ... EXIT` 概念化為資源釋放意圖，而非逐字複述訊號註冊語法
`trap` 註冊之清理函式代表「無論正常結束或中途失敗皆須釋放資源」之設計意圖（對應憲章 V.2 實作細節概念化），摘要應描述其意圖而非複述 `trap` 指令語法本身。

```sh
main() {
  local tmp_dir
  tmp_dir="$(mktemp -d)"
  trap 'rm -rf "${tmp_dir}"' EXIT INT TERM
  process_files "${tmp_dir}"
}
```
摘要應寫為「使用暫存目錄處理檔案，並確保腳本結束（含異常中止）時自動清除暫存資源」，不得寫成「註冊一個在 EXIT、INT、TERM 訊號觸發時執行 rm -rf 的 trap」。

### 3. 將 `local` 概念化為作用域隔離設計意圖
`local` 宣告代表函式刻意將變數限制於自身作用域、避免污染全域命名空間（對應憲章 II.1 從實作反推設計意圖），摘要應著重其隔離用意而非逐一列舉宣告了哪些區域變數。

```sh
parse_args() {
  local opt
  while getopts "e:v" opt; do
    case "${opt}" in
      e) DEPLOY_ENV="${OPTARG}" ;;
      v) VERBOSE=1 ;;
    esac
  done
}
```
摘要應寫為「解析命令列選項並寫入對應之全域設定變數，解析過程使用之暫存狀態不外洩至呼叫端」，不需逐一提及 `local opt` 這個變數宣告本身。

### 4. 將 `readonly` 概念化為不可變性契約，而非單純的語法標記
`readonly` 宣告代表該值為「定義後不應變動的設定常數」（對應憲章 II.2 領域概念識別／V.2 概念化），摘要應將其解讀為對外承諾的不可變契約值，並可視為該腳本行為邊界的一部分。

```sh
readonly DEFAULT_TIMEOUT_SEC=30
readonly MAX_RETRY=3
```
摘要應寫為「腳本以固定的逾時秒數與最大重試次數作為執行邊界」，而非「宣告兩個 readonly 變數」。

### 5. 從函式與檔案命名反推其在框架中的職責（對應 SRP／SoC）
依「程式語言指南」I.SRP／VII.SoC，函式或腳本檔案命名通常直接反映其單一職責；摘要應依命名與所在目錄（如 `lib/`、`cmd/`、`deploy.sh`）反推該單元在整體框架中的角色定位，而非僅描述其內部指令序列。

```sh
# 檔案: lib/validate.sh
validate_config() { ... }
validate_env()    { ... }

# 檔案: deploy.sh
source "lib/validate.sh"
main() {
  validate_config
  validate_env
  deploy_target_vm
}
```
摘要應指出「`lib/validate.sh` 專責設定與環境驗證，`deploy.sh` 透過 `source` 引入後於主流程中協調驗證與部署」，將檔案劃分本身視為職責邊界的證據。

### 6. 將 `set -euo pipefail` 視為腳本層級之前提脈絡，僅需於摘要開頭陳述一次
`set -euo pipefail`（對應憲章 III.2 脈絡涵蓋）是影響整支腳本錯誤處理行為的全域前提，摘要應於腳本整體描述中提及一次即可，不需在每個受影響的個別指令摘要中重複解釋「此指令失敗會終止腳本」。

```sh
#!/usr/bin/env bash
set -euo pipefail

fetch_data() { curl --max-time 10 "$1"; }
transform()  { jq '.items[]'; }
```
摘要應於腳本層級註明「腳本採快速失敗策略，任一指令或管線階段失敗即終止」，其後對 `fetch_data`／`transform` 的摘要無須逐一重複此前提。

### 7. 將退出碼與 `${VAR:?msg}`／`${VAR:-default}` 語法解讀為行為契約，而非逐字語法翻譯
依「程式語言指南」II.1／II.7，退出碼與參數展開語法代表明確的輸入驗證與失敗語意契約；摘要應轉譯為契約描述，而非重述 Shell 語法本身。

```sh
run_deploy() {
  local target="${1:?缺少部署目標}"
  local env="${DEPLOY_ENV:-staging}"
  deploy_target_vm "${target}" "${env}" || exit 2
}
```
摘要應寫為「部署目標為必要輸入，缺少時立即報錯終止；部署環境未指定時預設為 staging；部署失敗時以特定退出碼 2 表示部署階段錯誤」，而非「使用 `${1:?}` 展開語法並在失敗時 exit 2」。

### 8. 將 `source` 引入視為模組邊界，摘要跨檔案依賴時以模組職責描述取代逐一列舉被引入函式
依「程式語言指南」I.5／VI 高內聚低耦合，`source` 代表模組間的明確依賴關係；摘要應描述「此腳本依賴哪個模組提供的哪類能力」，而非逐一列出被引入檔案中定義的每個函式名稱。

```sh
source "${SCRIPT_DIR}/lib/log.sh"
source "${SCRIPT_DIR}/lib/http.sh"
```
摘要應寫為「本腳本依賴共用的日誌模組與 HTTP 呼叫模組」，不需列出 `lib/http.sh` 內定義的每一個函式簽章。

### 9. 將 `command -v` 依賴檢查解讀為抵禦第三方依賴的邊界防護意圖
依「程式語言指南」II.9，執行外部指令前的存在性檢查代表「不假設執行環境已安裝該工具」之防禦意圖，摘要應描述此防護目的，而非逐句翻譯條件判斷語法。

```sh
command -v jq >/dev/null 2>&1 || { echo "缺少必要指令: jq" >&2; exit 1; }
```
摘要應寫為「執行前確認 jq 工具已安裝，缺少時明確報錯並中止，避免後續解析階段以難以理解的方式失敗」。

### 10. 將 `case "$subcommand" in ...)` 或 `cmd_${subcommand}` 動態分派模式解讀為可擴充的子指令架構
依「程式語言指南」OCP 條目，此類分派模式代表「新增子指令不須修改既有分支」之開放封閉設計；摘要應點出此架構特性，而非逐一列舉每個分支對應的指令內容。

```sh
main() {
  local subcommand="$1"; shift
  case "${subcommand}" in
    deploy)   cmd_deploy "$@" ;;
    rollback) cmd_rollback "$@" ;;
    *) echo "未知子指令: ${subcommand}" >&2; exit 1 ;;
  esac
}
```
摘要應寫為「以子指令分派架構組織功能，新增子指令僅需新增對應 `cmd_*` 函式與分派項目」，而非逐一複述 `case` 內每個分支的指令內容。

## Governance

- 修訂程序：修訂者提出變更原因、受影響之原則或注意規範項目，經專案負責人核准後生效並記錄於版本歷程。
- 版本控制政策：採語意化版本 (Semantic Versioning)。
  - 主版本：CODE_RULES 對應之七大摘要原則或 INTERPRETING_CONSTRAINTS 群組發生增刪或重新定義，屬不相容變更。
  - 次版本：新增具體判讀規則、注意規範項目或範例，或大幅擴充既有條目之指導方針。
  - 修訂版：措辭澄清、錯字修正等非語意性變更。
- 合規性審查：依本指南產出之程式碼摘要，須依「程式摘要憲章」之「合規要求」章節（心智模型判準、逆向還原判準、摘要核心判準、意圖層級判準、去噪判準、分塊判準、詞彙映射判準）逐項核對，並額外確認是否符合本指南「解讀時的注意規範」所列之 Shell Script 特定判讀方式；違反者須修正後始得採用。
- 語言邊界：本指南所有規則之詮釋皆以 Linux Shell Script（`sh`／`bash`）語法與「程式語言指南」所定義之慣例為邊界，不得於摘要判讀中引入類別、介面、例外拋出等 Shell 不具備之語言機制；如遇摘要情境無法直接對應本指南條目，須以退出碼、`trap`、函式與腳本檔案邊界等 Shell 慣用機制重新詮釋，不得直接照搬物件導向語言之措辭。

**Version**: 1.0.0 | **Ratified**: 2026-08-19 | **Last Amended**: 2026-08-19
