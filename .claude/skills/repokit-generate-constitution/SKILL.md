---
name: "repokit-generate-constitution"
description: 專案庫工具，依據輸入內容生成指定的憲章文件
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

+ CONSTITUTION_FILENAME 為 {{ARGUMENTS}} 中的憲章文件檔名。
+ CONSTITUTION_DESC 為 {{ARGUMENTS}} 中的原則名稱。

---

### 2. 載入憲章

+ CONSTITUTION_PATH : `.codekit/memory/constitution/{{CONSTITUTION_FILENAME}}`
+ CONSTITUTION_TEMPLATE_PATH : `.claude/templates/constitution-template.md`
+ 讀取憲章檔案 `{{CONSTITUTION_TEMPLATE_PATH}}`。
  - 辨識所有形如 `[ALL_CAPS_IDENTIFIER]` 的預留符標記。
  - **重要提示**：使用者可能需要比範本中使用的原則數量更少或更多的原則。請遵循實際的原則數量更新文檔。
+ 讀取舊版憲章 `{{CONSTITUTION_FILE_PATH}}`，若檔案存在。
  - 舊版憲章做為條目與內容的參考基礎。

---

### 3. 收集與推導預留符的值：

+ 預留符標記基於 {{CONSTITUTION_DESC}} 內容解釋。
  - 詳盡列舉各原則的條目。
+ 對於治理日期：`RATIFICATION_DATE` 為原始通過日期 ( 如果未知，請詢問或標記為待辦事項 )，`LAST_AMENDED_DATE` 為當前日期 ( 果進行了更改 )，否則保留先前的日期。
+ `CONSTITUTION_VERSION` 必須依照語意版本控制規則遞增：
  - 主要版本：治理與原則發生不可兼容或重新定義的變更。
  - 次要版本：新增了原則或章節，亦或大幅擴展與補充了具體的指導方針。
  - 補丁版本：澄清、措詞、拼字錯誤修復、非語意改進。
+ 如果版本號遞增類型不明確，請在最終確定之前提出理由。

---

### 3. 更新憲章內容

+ 將所有預留符標記更換為具體文字 ( 除尚未定義的範本插槽外，不得保留任何帶有括號的標記；如有保留，需明確說明理由 )。
+ 保留標題層級結構，替換後可刪除註釋，除非註釋仍能提供澄清性的指引。
+ 確保每個原則包括以下部分：
  - 簡潔的標題行 ( Succinct name line )。
  - 段落或項目清單以概括必須遵守的鐵律 ( Paragraph or bullet list capturing non-negotiable rules )。
  - 若原則模糊不明顯，請解釋明確的理由 ( Explicit rationale if not obvious )。
+ 確保治理段落 ( Governance section ) 列出修訂程序、版本控制政策和合規性審查預期。
  - 若更新的憲章內容與舊版憲章，在條目與內容有新增、刪減，應該根據差異調整本次版本編號，並說明變更內容。

---

### 4. 輸出憲章

+ 將完成的憲法寫回 `{{CONSTITUTION_FILE_PATH}}`，覆蓋原本內容。

---

### 5. 總結

+ 輸出 `✅ 執行完畢`
