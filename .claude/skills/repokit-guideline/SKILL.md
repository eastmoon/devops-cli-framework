---
name: "repokit-guideline"
description: 專案庫工具，生成本專案所需指南文件。
tools: Agent
user-invocable: true
disable-model-invocation: false
---

## 輸入

```text
$ARGUMENTS
```

+ 如果輸入不為空，在繼續操作之前，**必須**考慮使用者輸入。
+ 專案資訊檔 : `README.md`
+ PROGRAM_LANGUAGE 為 {{ARGUMENTS}} 的程式語言名稱。
  - 若 {{PROGRAM_LANGUAGE}} 不存在 → PROGRAM_LANGUAGE = **專案資訊檔** 中 **專案資訊** 章節的 **程式語言**
  - 若 {{PROGRAM_LANGUAGE}} 仍然不存在 → 停止進程 → 列印 `⛔ 程式語言未被指定。`

---

## 宣告

+ 指南生成 : `.claude/skills/codekit-generate-guideline/SKILL.md`

---  

## 任務

+ 請依序執行以下任務。
+ 以下各任務皆為 Subagent，必需為互相獨立且不干擾對方。

---

### 1. 生成程式語言指南

<coding-guideline-requirement>
請基於以下內容，寫入指南文件 coding.md  檔案 :

# 參考文件
+ 程式設計憲章 : `.codekit/memory/constitution/software-design.md`
  - 若程式摘要憲章檔案不存在 -> 停止進程 -> 列印 `⛔ 軟體設計憲章尚未建立。`
+ 程式指南憲章 : `.codekit/memory/constitution/coding-guideline.md`
  - 若程式指南憲章檔案不存在 -> 停止進程 -> 列印 `⛔ 程式指南憲章尚未建立。`

# 詮釋指南
+ CODEING_RULES 詮釋內容規範如下
  - 遵守 **程式指南憲章** 內容為條目。
  - 基於 **{{PROGRAM_LANGUAGE}} 程式語言** 增加條目內容的細節，使其符合程式語言的撰寫風格。
  - 不可出現違反 **{{PROGRAM_LANGUAGE}} 程式語言** 語法規則的原則細節。
+ DESIGN_CONSTRAINTS 詮釋內容規範如下
  - 遵守 **程式設計憲章** 內容為條目。
  - 基於 **{{PROGRAM_LANGUAGE}} 程式語言** 語法規則。
  - 詮釋憲法指引下的撰寫原則細節。
</coding-guideline-requirement>

+ 執行**指南生成**生成工具，並以 **coding-guideline-requirement** 為輸入。

---

### 2. 生成程式碼摘要指南

<summarizing-guideline-requirement>
請基於以下內容，寫入指南文件 summarizing.md  檔案 :

# 參考文件
+ 程式摘要憲章 : `.codekit/memory/constitution/summarizing-guideline.md`
  - 若程式摘要憲章檔案不存在 -> 停止進程 -> 列印 `⛔ 程式摘要憲章尚未建立。`
+ 程式語言指南 : `.codekit/memory/guideline/coding.md`
  - 若程式語言指南檔案不存在 -> 停止進程 -> 列印 `⛔ 程式語言指南檔案尚未建立。`

# 詮釋指南
+ CODE_RULES 詮釋內容規範如下
  - 遵守 **程式摘要憲章** 內容為條目。
  - 基於 **程式語言指南** 增加條目內容的細節，使其符合程式語言的解讀風格。
  - 不可出現違反 **程式語言指南** 語法規則的原則細節。
+ INTERPRETING_CONSTRAINTS
  - 基於 **程式摘要憲章** 內容為原則。
  - 條列 **程式語言指南** 摘要時的**注意規範**，並附上程式碼做為參考。
</summarizing-guideline-requirement>

+ 執行**指南生成**工具，並以 **summarizing-guideline-requirement** 為輸入。


---
