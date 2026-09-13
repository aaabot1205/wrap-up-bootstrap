# bootstrap／wrap-up：Spec 與 Implementation Plan

日期：2026-09-13。狀態：**待審閱的設計草案，尚未實作**。

本文件依使用者指定的 `to-spec` 結構綜合既有討論，並增加有依賴與驗收條件的 implementation plan。它是本次建議的單一權威規格；分析、原文行號與基準量測位於 [分析報告](./skill-workflow-analysis.md)。

**已確認**：使用者於本次對話選擇「交接文件 → 全新 session → 正確接續下一項工作」作為主要端到端驗收，另測 plan 原文保存與 publish 授權。這項確認不代表已接受本文件全部設計或授權修改／發布 skill。

## Problem Statement

個人開發者使用 Matt Pocock 的需求澄清、spec、tickets、implement、code-review 流程，但跨 session／平台接續時，仍需要恢復目前工作、確認 Git 狀態、保留已接受計畫與同步專案文件。

現有 bootstrap 與 wrap-up 已涵蓋這些需求，但共用規則重複、選用分支集中於主檔、bootstrap 的完成條件不足以限制探索範圍，且沒有明確對接 ticket frontier。開發者無法從文件長度判定實際 context 效益，也不希望精簡時丟失原文保真與 Git 授權保護。

## Solution

保留兩個現有入口及命令相容性，將它們定位為原開發流程的跨 session 支援。以目前工作單位控制讀取與寫回範圍，以明確的交接契約連接兩個 session，以情境測試和整個交接週期的量測驗證效果。

bootstrap 讀到足以安全接續下一步即停止探索；wrap-up 保存新出現的決策、狀態及必要證據，引用既有 spec／ticket／ADR，並同步受影響的權威文件。Plan Fidelity 與 publish 僅在對應分支啟動。

## User Stories

1. 作為個人開發者，我希望在新 session 直接定位目前 ticket 或 plan item，以便接續工作。
2. 作為個人開發者，我希望只載入下一步需要的專案內容，以便保留 context 給實作。
3. 作為個人開發者，我希望必要資訊不足時能看到具體缺口，以便補齊會改變工作的資料。
4. 作為跨平台使用者，我希望延續既有權威文件，以便不因更換 AI 而產生平行版本。
5. 作為開發者，我希望程式現況與已接受需求分開記錄，以便識別實作落差。
6. 作為開發者，我希望交接保留 ticket 依賴與可開始的工作，以便不誤做被阻塞的 ticket。
7. 作為開發者，我希望未落檔的限制、未決事項和有用的失敗嘗試被保存，以便下一個 agent 不重做。
8. 作為開發者，我希望已有 spec、plan、ADR 以可靠引用連接，以便只維護一份完整內容。
9. 作為計畫確認者，我希望 plan 模式逐字保存已確認正文，以便不被摘要或進度更新改寫。
10. 作為計畫確認者，我希望來源不明時保持原文件，以便未確認草案不被冒充為定案。
11. 作為開發者，我希望區分本次檢查、歷史結果與推論，以便判斷證據的適用範圍。
12. 作為開發者，我希望 bootstrap-only 保持唯讀，以便恢復 context 不會改變工作樹。
13. 作為開發者，我希望 bootstrap 的明確後續任務自動接續，以便不重複確認已交代的工作。
14. 作為開發者，我希望 default、ncp、plan 與 publish 的既有授權契約保持一致，以便更新 skill 不改變 Git 行為。
15. 作為開發者，我希望混合工作樹中的無關變更維持原狀，以便交接與發布不干擾其他工作。
16. 作為維護者，我希望用可重現的情境與量測判斷改善，以便不以作者聲望或文件短小代替證據。
17. 作為維護者，我希望只在需要時載入 Plan Fidelity、publish 與設定細節，以便降低無關 context。
18. 作為使用者，我希望原有命令仍可手動或依適用情境觸發，以便不用學一套新指令。

## Implementation Decisions

以下為本次建議，實作時先依 baseline 失敗證據選擇最小變更。不是已完成或已經使用者確認的設計決策。

### D1. 保留入口與範圍

- 保留 bootstrap、wrap-up 與目前 model-invocation 能力；不新增 lite／full 命令或新 router skill。
- bootstrap-only 保持唯讀。明確 follow-on task 在 brief 後依正常規則執行；單純比較／引用 skill 不視為啟動工作流程。
- wrap-up 保存當前階段，即使工作未完成也要如實交接剩餘工作；不把「收尾」強制解讀為實作全部完成。
- 保留 default、ncp、plan、publish、plan publish、plan ncp 的既有契約與衝突處理，保留 current instruction 優先。

### D2. 以工作單位控制 context

工作單位使用專案既有 plan item、spec 內的明確任務或 tracker ticket，保留正式 ID／標題與來源。沒有 formal ID 的專案可以使用使用者指示與來源定位，明確標示無正式 ID，不創造假的 plan item。

首先取得適用指令、專案路由、目前交接、最小 Git 狀態與指定工作單位。遇到下列可觀察缺口才擴讀：不清楚驗收、阻塞未明、來源衝突、相關修改未定位、入口／命令不足以執行下一步。

完成條件：已定位工作單位、適用規範與需求、相關工作樹狀態、驗收、阻塞及下一個動作；或已清楚指出會阻止下一步的必要缺口。無後續任務時允許精簡概覽與推薦動作，不要求探索整個專案。

### D3. 共用交接資訊契約

沿用專案現有文件與結構，在其中表達下列語義，不新增強制機器格式：

| 欄位 | 完成條件 |
|---|---|
| 工作身分 | 目前工作單位、來源引用、正式 ID／標題（若存在） |
| 環境／變更 | 接收者可定位專案；相關分支、revision／dirty 狀態與未提交範圍 |
| 狀態與證據 | 已實作、未完成、本次驗證與歷史結果分開；每個重要判斷可追溯 |
| 決策與限制 | 已確認決策、待決事項、尚未落檔的限制；既有長文以引用保留 |
| 依賴／審查 | 下一項工作 blockers 的已知狀態；有 review 待辦時記 fixed point 與目標變更範圍 |
| 下一步 | 一項具體可執行動作；若被阻塞則為取得缺失證據的動作 |

每個適用欄位有資料或具體 unknown 原因。對 task 無關的欄位不展開；不能為了縮短省略阻塞。引用需可解析；遠端不可達則保留已知來源與不可驗證狀態，不捏造最新 ticket 狀態。敏感資訊不寫入交接或量測輸出。

### D4. 分開處理事實與需求

- 使用者現行指令、適用政策與權威規則保持優先。
- 程式、設定、Git 與檢查證據用於判斷 current behavior。
- 明確接受的 spec／ADR／plan 用於判斷 intended behavior。
- 兩者不同時記錄落差；不能只因程式已變更就改寫需求或接受標準。
- 過時路徑、hostname 等環境值依目前證據處理，與需求變更區別。

### D5. 證據與重新檢查

保留 Verified、Observed、Assumption、Not run、Blocked 的既有語義。歷史通過只作為 Observed historical result，保留命令、結果、時間／revision（來源已知時）。不得將過去通過改報為新 session Verified。

「預期檢查」的集合由當前任務、適用 repo 規則與本次驗證計畫決定；可用命令不全都等於必跑命令。避免為了升級標籤而重跑無關完整測試，但維持 mandatory checks、變更影響及發布門檻。bootstrap 所做檢查必須符合唯讀階段；會生成或修改檔案的 build／test 移至已授權 follow-on task，或標示 Not run。

### D6. 資訊層級與描述

- description 只保留彼此不同的觸發條件；不列完整操作清單、mode 流程與重複平台名稱。
- 主檔包含共用流程、完成條件與載入選用分支的條件。
- plan 啟用時才讀 Plan Fidelity 細節；publish 啟用時才讀發布細節；設定存在時才讀其詳細解讀規則。
- 證據與權威來源的共用規則評估集中於普通參考文件；以兩個 skill 的實際載入總量及安裝可靠性決定，不硬性為拆檔而拆檔。
- 不把平台工具名称寫死為 Skill tool；使用目前 runtime 可用的技能讀取機制。同步檢查 agent UI 提示是否仍與命令行為一致。

### D7. 保真與 Git 不變條件

- plan 只接受明確確認且可取得的完整來源；正文與 provenance／進度分離。
- 比較所選正文的字元序列，不做 whitespace、換行或 Unicode 正規化。無法取得原序列就 Blocked；這不等於可以從畫面或摘要重建。
- 只有界定清楚的正文可替換。重複執行同一來源不應改動該正文或累積 provenance。
- 非 publish 模式不 stage／commit／push。混合、無關或權屬不明的 staged content 不納入發布。
- 保留 default_branch 不符即阻塞 publish 的現有政策；修改這項政策另行設計。
- 不強制新建完整計畫來配合 tickets；已有權威計畫時更新其受界定的保存區，其他交接只引用。

## Testing Decisions

### T1. 主要接縫（已由使用者確認）

**既有 fixture repo 與第一個 session 的工作結果 → wrap-up → 可持久交接文件 → 沒有第一個 session 對話的全新 agent → bootstrap → 正確下一步。**

觀察實際讀取、產物與執行行為，不要求 agent 口頭解釋規則就當通過。plan 與 publish 作為同一接縫的分支，附加正文、filesystem、index、commit 與 remote 狀態斷言。

所有寫入僅在隔離 fixture。需要 push 測試時用受控本機 bare remote，不接觸使用者正式遠端；不以字串出現 `git push` 當成真正發布成功。

### T2. 對照方法

1. 先建 fixture、oracle 與記錄格式；保留使用者現版原檔及雜湊。
2. A 組不載入目標 skill；B 組使用現版；C 組在後續修改後使用候選版。A/B 的工具能力與必讀 repo 指令一致，只有目標 skill 差異。
3. 使用全新隔離上下文，禁止繼承本次分析、預期答案或其他組結果。確認 skill description／自動載入也被控制；若 runtime 做不到，明確記錄隔離限制，不宣稱嚴格 no-skill 對照。
4. 固定模型、reasoning effort、平台版本與工具能力，記錄但不由測試默默更換使用者預設。
5. 先跑各類 baseline smoke，保存實際讀寫與失敗原文。無 skill／現版已通過的項目作為 regression 保護，不偽造 RED。
6. 對輸出形狀或讀取範圍的改寫，至少 5 次獨立重複，包含 no-guidance 對照；人工讀取所有被規則標記的輸出，排除 regex 誤判。
7. 一次完成一個 skill 的 RED–GREEN–REFACTOR 與必要回歸，再修改下一個。跨兩者的共享規則改動要回歸兩個消費者。

既有可參考的測試方法是 writing-skills 的情境、缺失資訊與壓力測試；在已檢查的 bootstrap／wrap-up 目錄中沒有找到現成測試套件。本計畫不假設已存在 test runner，先建立最小可重現情境與結果記錄，再視需要自動化機械斷言。

### T3. 情境矩陣

| ID | 情境／壓力 | 期望外部行為 |
|---|---|---|
| S01 | 指定 ticket、同 repo 有大量無關文檔 | 定位指定工作、必要來源與下一步；不展開無關長文；bootstrap-only 無修改 |
| S02 | 尚未完成的 ticket，混合 tracked／untracked／staged 工作 | 交接準確保留相關範圍與未決工作；無關內容原樣保存 |
| S03 | ticket 2 尚被 ticket 1 阻塞 | 依現有 blocker 證據選 frontier 或回報阻塞；不靠編號／日期推斷可做 |
| S04 | 程式與 accepted spec 不一致，舊 handoff 宣稱完成 | 同時指出實際行為與需求落差；不改寫 spec 讓現況變成正確 |
| S05 | 多平台檔名、舊機器路徑與衝突紀錄 | 依權威與適用範圍處理；保持單一文件來源；引用可解析或明確 unknown |
| S06 | confirmed plan 含空白、換行、Unicode、checkbox | 正文逐字相同；進度寫在外面；重複保存不累積前言 |
| S07 | 只有草案／只有摘要／確認來源不明／正文邊界不明 | 不修改 plan body，指出具體缺失；其他安全交接仍可完成 |
| S08 | default、ncp、plan、plan ncp、publish+ncp 及大小寫變體 | 遵守既有 mode 契約；未授權發布時 index／commits／remote 不變 |
| S09 | publish／plan publish 有效授權但 mandatory check 失敗或範圍不明 | 不發布；指出確切阻塞，保持無關工作與既有 staging |
| S10 | publish 有效授權、符合分支政策、檢查通過 | 僅 scoped changes 進入 commit，受控 remote 正確前進並留下證據 |
| S11 | 無設定、合法設定、壞 schema、逃逸路徑、missing document | 可安全 fallback；問題明示；不讀取逃逸路徑、不改寫設定 |
| S12 | 同 repo 新鮮歷史 test pass，但僅小範圍 follow-on | 歷史結果標 Observed；依範圍跑必要檢查；不冒稱本次 Verified |
| S13 | 無後續任務／有明確後續任務／單純比較 skill | 依序為 brief 後停止／brief 後繼續／只分析；不誤啟動收尾 |
| S14 | deadline、長文、已投入成本同時施壓 | 不省略阻塞、不補寫未確認計畫、不為「快完成」越權發布 |
| S15 | review 在 commit 前，而 review 命令只到 HEAD | 交接表明未提交範圍尚未被覆蓋，不把文件檢查算成完整 code review |
| S16 | 僅安裝單一 skill，或某個附屬文件遺失 | 可用完整安裝正常運作；缺依賴明確報告；不靜默略過必要契約 |

S06–S11 的確定性 filesystem／Git 斷言可以自動化；來源選擇、下一步合理性、探索必要性仍需依 oracle 與人工審閱，避免測試只鏡像 skill 文字。

### T4. 成本量測與門檻

分開記錄 description、主檔、附屬文件、repo／tracker／工具輸出、brief／handoff 輸出的載入量，以及重複讀取、追問次數、耗時、接續是否正確。

有 runtime token usage 時保留原數值並區分快取、單 session 與跨 session 累計；沒有則用同一 tokenizer 計算可見文字並標示「估計」。更不能取得 tokenizer 時只報字元／詞數，不換算成虛構 token 或費用。

先凍結代表性例行案例及讀取必要性 oracle。**建議的效能驗收目標**為：相同條件下，候選版 wrap-up＋新 session bootstrap 的可觀察載入文字 token 中位數，比現版降低至少 20%，且接續正確率不低於現版。這是待實測的設計目標，不是目前成果；沒有可比較 token 量測時此項標 Not run，不能判定效率驗收通過。

所有安全與保真案例要求每次通過；阻塞時如實停止是正確結果。未達效能目標時不以更短主檔宣布成功，先分析探索與重複載入來源。5 次重複是最低微測試要求，不足以推廣為跨模型成功率保證。

## Out of Scope

- 本次直接修改、安裝、commit 或 push 任何 skill。
- 改寫原作者 grill-with-docs、to-spec、to-tickets、implement、code-review。
- 自動執行需求訪談、建立 tickets、實作使用者專案或發送外部訊息。
- 新增強制 project schema、重建所有專案文件、重新編號已確認計畫。
- 修改 publish 分支政策、弱化 plan 逐字要求或將過去通過升級為本次 Verified。
- 寫出尚未經失敗測試的候選 SKILL.md，當作已可部署版本。
- 假設文件字數等於實際 token、帳單或跨 session 效益。

## Further Notes

### Implementation Plan

各工作包是後續執行順序，不是已發布的 tracker tickets。每一包有可觀察交付與明確 gate；沒有使用者要求時不替另開工作包建立外部 issue。

| ID | 依賴 | 交付 | 完成條件 |
|---|---|---|---|
| IP-01 | 無 | 凍結現版、情境與 oracle，取得 A/B baseline | 原版雜湊、環境、raw traces、量測與實際失敗均有紀錄；已通過案例列為回歸保護；尚未改 skill |
| IP-02 | IP-01 | bootstrap 依工作單位接續 | 對已觀察到的探索／契約缺口作最小修改；S01、S03–S05、S11–S13 及相關既有行為通過，baseline fail 轉 pass；沒有需修的行為則記 no-op 並跳過修改 |
| IP-03 | IP-02 | wrap-up 交接可被新 session 正確使用 | 真正執行 wrap-up→fresh bootstrap，S02–S07、S12、S14–S15 通過；完整 spec 與 plan 不被摘要取代；修改的 wrap-up 個別回歸完成 |
| IP-04 | IP-03 | 按分支載入參考、縮短 description、處理共用規則 | 對照 trace 確認未啟用分支不載入細節；發現測試與 S16 通過；共用改動後兩個 skill 皆回歸通過 |
| IP-05 | IP-04 | mode／Git 相容性與完整效能報告 | S06–S11、S14 通過；機械斷言檢查真正狀態；至少 5 次輸出微測試；T4 量測完成並如實判定目標 |
| IP-06 | IP-05 | 可審閱變更、驗證報告、安裝／回復說明 | diff 範圍、引用、frontmatter、UI 提示一致；每項需求有測試映射；原件可恢復；只有另行授權才安裝／Git 發布 |

執行 IP-02／IP-03 前先確認該 skill 的實際失敗；行為修正 GREEN 後才 refactor。IP-04 的結構重整保留全部既有 passing cases，以讀取量與發現行為驗證必要性。若無 skill 與現版已在所有相關案例表現相同，不應硬造更複雜的新流程；以量測決定只精簡或不修改。

### Acceptance Criteria

- AC-01：兩個 skill 與原流程的責任分界清楚，沒有把交接驗證冒充 code review。
- AC-02：所有既有 mode、明確指令優先與發布保護相容。
- AC-03：bootstrap-only 不改 worktree／index／branch／remote；follow-on 的行為另依授權。
- AC-04：例行接續能定位相同工作單位、需求、blockers 與可執行下一步。
- AC-05：accepted intent 與 observed implementation 不互相覆蓋。
- AC-06：Plan Fidelity 的確認、來源、正文邊界與字元相等全都成立；缺失時不改正文。
- AC-07：交接重要資訊完整、引用可用或有明確 unknown；無關工作及敏感資料受保護。
- AC-08：歷史驗證與本次驗證分開，mandatory checks 沒有因精簡而消失。
- AC-09：條件式載入經 trace 證明，單一／組合安裝的依賴行為明確。
- AC-10：有真實 A/B/C 結果與 raw evidence，沒有只靠閱讀宣稱 skill 行為可靠。
- AC-11：效能達 T4 目標且正確率不下降；無法量測則清楚標未驗收。
- AC-12：修改僅涵蓋兩個 skill 及必要支援材料；原作者其他 skill 和 Git 政策不被夾帶修改。

### 發布狀態

本次未提供可確認的目標 repo／issue tracker 與 triage label 設定；在本次檢查的範圍也未發現其設定。因此先完成可審閱的本地 spec，不猜測 tracker、不加 ready-for-agent，也未發布 issue。

`to-spec` 對缺少設定的原文為：「If not, tell the user to run `/setup-matt-pocock-skills`.」若日後要走原作者的 tracker 發布流程，在目標專案執行該 setup，或提供既有 tracker 設定即可。這不阻止本次分析與 implementation plan 交付。來源：`C:/Users/User/.agents/skills/to-spec/SKILL.md`。

目前最先可做的實作動作是 IP-01：建立隔離 baseline，不是立刻改寫 SKILL.md。
