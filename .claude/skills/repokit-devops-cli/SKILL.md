---
name: "repokit-devops-cli"
description: 專案庫工具，依據輸入內容初始化開發運維框架並建立指定的開發運維命令
user-invocable: true
disable-model-invocation: false
---

## 輸入

```text
$ARGUMENTS
```

+ 如果使用者輸入為空 -> 停止進程 -> 列印 `⛔ 對話輸入不能為空。`
+ 如果輸入不為空，在繼續操作之前，**必須**考慮使用者輸入。

---

## 步驟

### 1. 確認輸入

+ REPOITORY_NAME 為 {{ARGUMENTS}} 中的目標專案名稱，可為空。
  - 若為空，目標專案目錄為根目錄。
  - 若不為空，目標專案目錄為根目錄中的子目錄，其名稱即為 REPOITORY_NAME。
+ PROJECT_DIR 為目標專案目錄之路徑：若 REPOITORY_NAME 為空則為根目錄；若不為空則為根目錄下、以 REPOITORY_NAME 為名稱之子目錄。
+ COMMAND_NAME 為 {{ARGUMENTS}} 中的命令名稱。
+ COMMAND_DESC 為 {{ARGUMENTS}} 中的命令描述。

---

### 2. 載入原則文件

+ PSEUDOCODE_CONSTITUTION_PATH: `.codekit/memory/constitution/coding-pseudocode.md`
+ CODING_GUIDELINE_PATH: `.codekit/memory/guideline/coding.md`
+ 讀取 `{{PSEUDOCODE_CONSTITUTION_PATH}}`，做為後續虛擬碼撰寫之原則與風格依據。
+ 讀取 `{{CODING_GUIDELINE_PATH}}`，做為後續程式碼撰寫之原則與風格依據。

---

### 3. 初始化開發運維框架

+ 執行腳本 `.claude/shell/devops-cli-fwk-initial.sh {{PROJECT_DIR}}`
+ 若腳本執行結果非成功 ( exit code 非 0 ) -> 停止進程 -> 列印 `⛔ 顯示腳本輸出之錯誤訊息`

---

### 4. 建立開發運維命令

+ 執行腳本 `.claude/shell/devops-cli-fwk-new-command.sh {{COMMAND_NAME}} {{PROJECT_DIR}}`
  - 第二參數 {{PROJECT_DIR}} 務必帶入，確保命令目錄建立於目標專案目錄之下，而非執行腳本時之目前工作目錄。
+ 若腳本執行結果非成功 ( exit code 非 0 ) -> 停止進程 -> 列印 `⛔ 顯示腳本輸出之錯誤訊息`
+ COMMAND_DIR 為腳本建立之命令目錄路徑 ( `{{PROJECT_DIR}}/conf/devops/{{COMMAND_NAME}}` )

---

### 5. 詮釋命令描述

+ 依 {{COMMAND_DESC}} 內容，辨識下列章節是否存在，未出現之章節於後續步驟中略過對應之更新：
  - **描述**
  - **屬性**
  - **選項**
  - **前處理**
  - **處理**
  - **後處理**
+ 詮釋各章節內容時，務必依 {{COMMAND_DESC}} 之原文為準，不可自行推論未明確描述之內容。

---

### 6. 更新 main.yml 屬性

+ MAIN_YML_PATH: `{{COMMAND_DIR}}/main.yml`
+ 若 {{COMMAND_DESC}} 存在**描述**章節：
  - 將該章節內容做為 `desc` 之值，覆蓋 `{{MAIN_YML_PATH}}` 內既有 `desc` 欄位。
+ 若 {{COMMAND_DESC}} 存在**屬性**章節：
  - 逐項解析章節中列出之屬性條目。
  - 條目格式為單一識別字 ( 如 `STOP-CLI-PARSER` ) 時，寫入 `attr.{{識別字}} : 1`。
  - 條目格式為 `識別字 = 值` ( 如 `VALUE = 123` ) 時，寫入 `attr.{{識別字}} : {{值}}`。
+ 若 {{COMMAND_DESC}} 存在**選項**章節：
  - 逐項解析章節中列出之選項條目，條目格式為 `旗標, variable: 變數名稱, type : 型別, description : 描述文字` ( 如 `--val, variable: VALUE, type : string, description : val description` )。
  - 依序寫入 `args.{{旗標}}.var : {{變數名稱}}`、`args.{{旗標}}.type : {{型別}}`、`args.{{旗標}}.desc : "{{描述文字}}"`。
+ 將更新後之內容寫回 `{{MAIN_YML_PATH}}`，保持 LF 格式。

---

### 7. 更新前處理腳本

+ 若 {{COMMAND_DESC}} 不存在**前處理**章節 -> 略過本步驟。
+ PREACTION_PSC_PATH: `{{COMMAND_DIR}}/preaction.psc`
+ PREACTION_SH_PATH: `{{COMMAND_DIR}}/preaction.sh`
+ 依 PSEUDOCODE_CONSTITUTION_PATH 之原則與撰寫風格，將**前處理**章節之流程描述撰寫為虛擬碼，寫入 `{{PREACTION_PSC_PATH}}`。
+ 依 CODING_GUIDELINE_PATH 之原則與撰寫風格，將 `{{PREACTION_PSC_PATH}}` 之虛擬碼轉譯為程式碼，寫入 `{{PREACTION_SH_PATH}}`，覆蓋原有預留內容。

---

### 8. 更新處理腳本

+ 若 {{COMMAND_DESC}} 不存在**處理**章節 -> 略過本步驟。
+ ACTION_PSC_PATH: `{{COMMAND_DIR}}/action.psc`
+ ACTION_SH_PATH: `{{COMMAND_DIR}}/action.sh`
+ 依 PSEUDOCODE_CONSTITUTION_PATH 之原則與撰寫風格，將**處理**章節之流程描述撰寫為虛擬碼，寫入 `{{ACTION_PSC_PATH}}`。
+ 依 CODING_GUIDELINE_PATH 之原則與撰寫風格，將 `{{ACTION_PSC_PATH}}` 之虛擬碼轉譯為程式碼，寫入 `{{ACTION_SH_PATH}}`，覆蓋原有預留內容。

---

### 9. 更新後處理腳本

+ 若 {{COMMAND_DESC}} 不存在**後處理**章節 -> 略過本步驟。
+ POSTACTION_PSC_PATH: `{{COMMAND_DIR}}/postaction.psc`
+ POSTACTION_SH_PATH: `{{COMMAND_DIR}}/postaction.sh`
+ 依 PSEUDOCODE_CONSTITUTION_PATH 之原則與撰寫風格，將**後處理**章節之流程描述撰寫為虛擬碼，寫入 `{{POSTACTION_PSC_PATH}}`。
+ 依 CODING_GUIDELINE_PATH 之原則與撰寫風格，將 `{{POSTACTION_PSC_PATH}}` 之虛擬碼轉譯為程式碼，寫入 `{{POSTACTION_SH_PATH}}`，覆蓋原有預留內容。

---

### 10. 總結

+ 輸出 `✅ 執行完畢`
