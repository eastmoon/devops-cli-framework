---
name: "repokit-constitution"
description: 專案庫工具，生成本專案所需憲章文件。
tools: Agent
user-invocable: true
disable-model-invocation: false
---

## 宣告

+ 憲章生成 : `.claude/skills/codekit-generate-constitution/SKILL.md`

---  

## 任務

+ 請依序執行以下任務。
+ 以下各任務皆為 Subagent，必需為互相獨立且不干擾對方。

---

### 1. 軟體設計憲章

<software-design-requirement>
  請基於以下內容，寫入憲章文件 software-design.md  檔案 :
  + 核心原則 : 依據 **SOLID**、**高內聚，低耦合 (High Cohesion, Low Coupling)**、**隔離關注點 (Separation of Concerns, SoC)** 原則的條目展開為子章節，並詳細詮釋各條目內容。
  + 原則取捨 : 依據前述詮釋的內容，請解釋原則間衝突的取捨規範。
  + 合規要求 : 依據前述詮釋的內容，如何合乎憲章規範。
</software-design-requirement>

+ 執行**憲章生成**工具，並以 **software-design-requirement** 為輸入。

---

### 2. 編寫虛擬碼憲章

<coding-pseudocode-requirement>
  請基於以下內容，寫入憲章文件 coding-pseudocode.md  檔案 :
  + 核心原則 : 依據 **保持「語言無關性」 ( Language Agnostic )**、**結構清晰，善用縮進 ( Indentation )**、**高度抽象化，隱藏實作細節**、**命名具備語意化 ( Semantic Naming )** 原則的條目展開為子章節，並詳細詮釋各條目內容。
  + 原則取捨 : 依據前述詮釋的內容，請解釋原則間衝突的取捨規範。
  + 合規要求 : 依據前述詮釋的內容，如何合乎憲章規範。
</coding-pseudocode-requirement>

+ 執行**憲章生成**工具，並以 **coding-pseudocode-requirement** 為輸入。

---

### 3. 程式編寫指南憲章

<coding-guideline-requirement>
  請基於以下內容，寫入憲章文件 coding-guideline.md 檔案 :
  + 核心原則 : 依據 **整潔程式碼 ( Clean Code )**、**防禦性程式設計 ( Defensive Programming )** 原則的條目展開為子章節，並詳細詮釋各條目內容。
  + 原則取捨 : 依據前述詮釋的內容，請解釋原則間衝突的取捨規範。
  + 合規要求 : 依據前述詮釋的內容，如何合乎憲章規範。
</coding-guideline-requirement>

+ 執行**憲章生成**工具，並以 **coding-guideline-requirement** 為輸入。

---

### 4. 程式摘要指南憲章

<summarizing-guideline-requirement>
  請基於以下內容，寫入憲章文件 summarizing-guideline.md 檔案 :
  + 核心原則 : 依據 **程式理解 ( Program Comprehension )**、**軟體逆向工程 ( Software Reverse Engineering )**、**程式碼摘要 ( Source Code Summarization )** 原則的條目展開為子章節，並詳細詮釋各條目內容。
  + 核心原則 : 補充 **意圖提升 (Intent Elevation / What over How)**、**去噪與抽象化 (De-noising and Abstraction)**、**語意分塊 (Semantic Chunking)**、**領域詞彙映射 (Domain Vocabulary Mapping)** 原則。
  + 原則取捨 : 依據前述詮釋的內容，請解釋原則間衝突的取捨規範。
  + 合規要求 : 依據前述詮釋的內容，如何合乎憲章規範。
</summarizing-guideline-requirement>

+ 執行**憲章生成**工具，並以 **summarizing-guideline-requirement** 為輸入。

---
