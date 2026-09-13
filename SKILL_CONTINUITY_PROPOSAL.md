# Skill continuity：本輪架構對接提案

日期：2026-09-13。狀態：已核准並進入候選實作；本文件保留原架構對應與 planning boundary，執行結果見 [SKILL_CONTINUITY_EVIDENCE.md](SKILL_CONTINUITY_EVIDENCE.md)。

## 來源與權威邊界

- 本 repo 的 [bootstrap](bootstrap/SKILL.md) 與 [wrap-up](wrap-up/SKILL.md) 是修改入口；全域副本只用於後續安裝驗證。
- [既有計畫](IMPLEMENTATION_PLAN.md) 的歷史、正式項目與已確認正文保持原樣。本文件是本輪變更提案，不是對舊計畫的替換，也不是已接受的 ADR。
- [外部原計畫完整快照](.scratch/skill-continuity/sources/skill-continuity-implementation-plan.md) 保留 IP-01～IP-06、D1～D7、T1～T4、S01～S16、AC-01～AC-12 的原文；[分析快照](.scratch/skill-continuity/sources/skill-workflow-analysis.md) 保留建議依據。兩份快照均逐位元組複製，原有相對引用仍可解析。
- 原始來源目錄：`C:\Users\User\Documents\Codex\2026-09-12\new-chat\outputs`。該路徑只記錄 provenance；執行與查閱使用上述 repo-relative 快照。
- `Verified`：來源快照 SHA256：原計畫 `D7C061301D076EEF709A96237DA354626D026AFE07C7A4DE682089EED8158C43`；分析 `CDA545DA92A1841EACED0D339E09E4FE3BC8134379B1554C11D5FE3A2C317E86`。既有 IMPLEMENTATION_PLAN.md 的原始 19,185 bytes 保持不變，SHA256 為 `F56782E685FA0C0F44A48261EA4931C6BA00C450F1ED03D1A7A32A3129E6B107`；本輪只在其後附加引用。
- 原計畫只記錄使用者確認主要端到端驗收接縫，沒有確認全部設計。本輪使用者授權架構適配與 ticket 準備，要求先確認拆分才保存 tickets。外部文件自稱的「單一權威規格」僅適用於原分析任務；本 repo 的 [D-001～D-007](DECISIONS.md) 與 [AGENTS.md](AGENTS.md) 仍有優先權。
- 本 repo 未發現既有本機 tracker。確認後沿用 to-tickets 的 `.scratch/skill-continuity/issues/<NN>-<slug>.md`，每張一檔；採其 `ready-for-agent` 狀態與明列 blocking edges。此狀態不代表可以跳過 blockers，也不授權實作、安裝或發布。尚未建立 issues 目錄或 ticket 檔。

## 唯讀 bootstrap 基線

- `Observed`：工作目錄 `C:\dev\wrap-up-bootstrap`；HEAD `a902c18`，分支 `main`，upstream `origin/main`；`VERSION` 為 `2.3.0`，release tag `v2.3.0` 指向 `db96117`。HEAD 的新增工作是 D-007 隔離 updater 測試。
- `Verified`：本輪編輯前 `git status --short --branch` 無變更，`git rev-list --left-right --count HEAD...origin/main` 為 `0/0`。未 fetch，這是本機 remote-tracking 狀態。
- `Observed`：不存在 root `PROJECT_CONTEXT.yaml`，沿用自動探索與 Version 2 非發布預設。example 的 verification、exclusions、default_branch 並未成為本 repo 的啟用設定。
- `Verified`：`powershell -NoProfile -ExecutionPolicy Bypass -File .\verify.ps1 -CanonicalOnly`：8 passed、0 warnings、0 failed；兩套 fixture runner 的 `-Mode Validate` 各確認六個方向。
- `Observed`：Phases 0～4、Plan Fidelity、Antigravity current/legacy 安裝與 D-006 已有實作與歷史驗證紀錄；`Phase 5: Cross-operating-system distribution` 延後，不納入本輪。
- `Not run`：fresh-agent `Prepare → 行為執行 → Check`、A/B/C、Skill Creator、完整 schema validation、安裝／升級及全域 hash 驗證。本輪沒有改其受測行為；結構檢查不等於行為驗證。
- `Verified`：兩個 canonical SKILL.md 的 SHA256 與外部分析所記基準一致：bootstrap `FD73C5DF76FA27B59AC276EB8768A7A478F6ADA367016A5123BF7C02D4D4C95B`；wrap-up `BED2C4B1302B12B14FF28DCD5E8A2F53C18A840FC095ED24548D999FC3753A1F`。這支持重用來源分析，但不是行為 baseline。

## IP 工作包與既有架構

以下「已具備」是原始碼及文件的 `Observed` 能力；只有上節本次執行的檢查可稱 `Verified`。

| 原工作包（保留正式交付文字） | 已具備，可直接沿用 | 需要擴充 | 確實缺少 |
|---|---|---|---|
| IP-01：凍結現版、情境與 oracle，取得 A/B baseline | Git revision/tag/hash；兩個 runner 的 Validate/Prepare/Check、安全路徑解析、shared templates、六方向 manifests；隔離安裝與本機 bare origin 方法 | 為既有 fixtures 加情境變體、受測前後 snapshots、失敗 checker 自測；為目前 updater tag 選擇補適用性檢查 | 無 skill／現版分組、兩個真正獨立 session 串接、環境與 raw traces 紀錄、讀取必要性 oracle、成本欄位及基線報告 |
| IP-02：bootstrap 依工作單位接續 | bootstrap §1～7 的唯讀、follow-on、路由、formal ID、evidence labels、環境 literal 衝突 | 以工作單位判定擴讀與停止；接受 ticket-only 的正式 ID/標題；區分 current behavior 與 accepted intent；保留所有必要 Git/規範/驗收資訊 | 明確 frontier/blocking edges 判斷與最小充分 context 的行為 oracle；S01/S03/S04/S12/S13 的重複觀察 |
| IP-03：wrap-up 交接可被新 session 正確使用 | wrap-up 文件就地更新、未完成事項、D-006 provenance/pruning；takeover 的 stale-state、pending approval；Plan Fidelity 的 confirmed/unconfirmed sources | 讓 producer 的交接真的成為 fresh receiver 唯一持久輸入；加入 mixed staged/untracked、未落檔限制、review fixed point、引用 unknown；補保真負例與重複保存 | end-to-end frontier 正確性、未提交 review 範圍的驗收、完整 plan/spec 未被壓縮的跨 session 證據 |
| IP-04：按分支載入參考、縮短 description、處理共用規則 | 兩個 skill 的獨立目錄與 OpenAI metadata；install.ps1 遞迴複製、verify.ps1 遞迴 hash、test-installation.ps1 的隔離/idempotency | 同一 slice 中調整必要 references、條件指標、verifier 的入口可達契約檢查及 packaging 測試；發現測試與 UI 對齊 | 條件式載入 traces、單 skill 的完整封裝／缺依賴測試、正負觸發情境；目前沒有 references 目錄 |
| IP-05：mode／Git 相容性與完整效能報告 | Plan Fidelity source-derived body 比對、non-publish Git assertions；既有 D-001/D-004 safeguards；updater 的本機 bare remote 模式 | 完整 mode/policy/case matrix、預先 staged preservation、成功 publish 的 remote ref 與 scoped commit assertions；Unicode/換行負例與 replay；至少五次可比較重複 | 現行 tracked suite 沒有 wrap-up publish 完整 runner，沒有 A/B/C 週期成本報告、快取/工具/輸出分項量測 |
| IP-06：可審閱變更、驗證報告、安裝／回復說明 | verifier/frontmatter/UI；INSTALL.md；雙 Antigravity 路徑；backup/hash/idempotency；D-007 updater regression | 整合 AC→scenario→raw evidence→結果、精確 diff/review 範圍、references 安裝與回復說明、STATUS/HANDOFF 同步 | 本輪候選驗收報告與可恢復快照；正式全域部署及 Git 發布仍須另行授權 |

不新建替代 PROJECT_CONTEXT schema、不強制專案新增設定，也不將 tickets 納入 required schema fields。工作身分與依賴使用既有 plan/spec/tracker 及 handoff 的語義即可。

## 驗證接縫與 fixtures 適配

保留 `test-regressions.ps1` / `tests/fixtures/takeover/` 與 `test-plan-fidelity.ps1` / `tests/fixtures/plan-fidelity/` 的既有責任和全部六方向。兩個 validator 目前要求 fixture root 恰為六個方向加 template；新情境不可直接混入同層而破壞該契約。優先在 manifest/template 與 runner 增加可選變體；只有雙 session orchestration、run manifest、trace/metrics 需要新增薄層支援。先用一個最小案例跑通，不先做通用框架或全面抽共用 helper。

既有 takeover checker 要求恰好修改 status/spec/handoff，適合 closeout，但不能直接作 bootstrap-only oracle。保留其原有 closeout 驗收；bootstrap-only 另比對完整工作樹、index、branch/HEAD、refs 前後快照。對 mixed staged 工作，驗收「與開始時相同」，不可錯用「index 必須空」。fixture 的 verify 會寫 `.test-artifacts`，因此只能在 producer/已授權 follow-on 執行，不能為了取得 Verified 破壞 bootstrap 唯讀階段。

| 情境 | 既有支點 | 本輪必要補充與驗收 |
|---|---|---|
| S01、S03 | bootstrap formal plan identity；takeover pending approval | 指定工作、大量無關文件、blocked/frontier、ticket-only/no formal ID；用必要性 oracle 審閱實際讀取與下一步 |
| S02、S15 | 文件更新範圍、evidence、Git status/diff | 混合 tracked/untracked/staged 快照、未完成工作、fixed point 加未提交範圍；文件檢查不冒充 code review |
| S04、S05 | takeover stale state、required durable-v3 spec、D-003/D-006 | 增加實作真的違反 accepted spec 的負例；保留 intended behavior，記錄實作落差；跨平台引用及過時環境 literal |
| S06、S07 | source-derived confirmed/unconfirmed body 與標記邊界 | 增加 whitespace/CRLF/LF/Unicode/checkbox、缺來源/摘要/邊界歧義；前後兩次保存、provenance 不累積；先驗證 checker 能拒絕字元序列差異（含 Ordinal 比較需求），不得 normalize 讓失敗消失 |
| S08、S09、S10、S14 | non-publish refs/index；wrap-up 授權／scope 政策；歷史 Phase 3 紀錄 | 正式重建 mode 與 publish 成敗案例；本機 bare remote，真實 commit/remote refs；deadline 壓力、未通過 mandatory check、無關 staged、branch mismatch、never policy、明確 override 邊界 |
| S11 | schema v1/example、路徑解析 helper、歷史 Phase 2 測試 | 缺設定/合法/壞 schema/逃逸/缺文件/排除衝突的 agent 行為；schema 的 pathList 只是字串約束，不可當成已做路徑安全與存在性驗證 |
| S12、S13 | D-003 歷史證據與 follow-on 契約 | 歷史 pass 保留命令/revision/時間；只跑本輪必要 checks；無 follow-on 停止、有 follow-on 接續、比較 skill 不誤觸 |
| S16 | 目錄式安裝、遞迴 copy/hash、四個 skill roots | 在隔離環境測完整單 skill、雙 skill 與刪除必要 reference 的失敗；保留 current/legacy Antigravity 獨立 assertion |

所有 agent 行為測試先保留真實輸出，checker 的字串/marker 只是局部證據；被規則標記的結果必須人工審閱。`Validate`、機械修改 fixture 或平台角色扮演不能替代 fresh-session 接續，也不能被報成 host-native 跨平台測試。

## 具體衝突與建議處理

1. **分析位置與測試假設**：外部 T2「沒有找到現成測試套件」只描述已安裝 skill 目錄。本 repo 已有四個 test scripts、verify 與 schema；改採上表擴充，避免建立平行測試系統。
2. **事實與需求**：bootstrap §5 把 observable source/tests 排在 accepted spec 前面，外部 D4 要分開 current/intended。建議明確限定優先序用於事實查證，需求仍由 accepted spec/ADR 決定；D-003 不需要降級，D-006 的環境值處理也保留。新負例必須證明接手者不會把 bug 改寫成需求。任何真正的需求變更另留決策，不在本提案宣告已接受。
3. **精簡與 mandatory reads**：外部 D2 不能跳過適用 AGENTS、明確要求完整讀取的來源、有效 PROJECT_CONTEXT 路由與必要 Git 安全資訊。停止條件只限制無關探索，不移除必讀來源；本次使用者明確要求完整讀原計畫即優先。
4. **抽離文字與 verifier**：`Test-RegressionArtifacts` 在 SKILL.md 內搜尋精確契約片段；description verifier 亦要求 mode 關鍵字。直接搬出主檔會造成結構失敗。需在相同 slice 讓 verifier 檢查安全、存在、入口可達的必要 references，保持語義門檻和負例；不能改成任意拼接所有檔案就算契約可達。description 正負發現測試與 UI 同步。
5. **共用 reference 與獨立安裝**：installer 只遞迴安裝兩個 skill 目錄；repo root 的 shared file 不會自動被安裝。優先各 skill 自足，短共用契約可重複；若量測支持單一來源，再設計明確封裝。沒有 trace 效益就 no-op，不先新增第三個 router/skill 或跨目錄強制依賴。
6. **全域同步時機**：AGENTS 要求行為改動後同步及 hash；D-004 又明確容許 canonical-only 開發，安裝另行授權。依本輪指示先 canonical-only＋隔離安裝；正式全域同步列為另行授權的部署 gate，未做時不稱全域部署完成。維持 D-005 八份 current/compatibility skill copies。
7. **updater gate 的現況**：`Observed`：test-update.ps1 目前按 tag 建立時間選最近可達且 commit 不等於 HEAD 的 tag，未先排除相同 VERSION。HEAD `a902c18` 會選到 `v2.3.0`，而兩端 VERSION 都是 `2.3.0`。`Assumption`：依腳本的版本差異 assertion，完整執行會在實際 update 前拒絕；本輪未執行，故不是實測失敗。建議在 baseline 前以隔離重現後，選最近可達且 release version 不同的前版（目前候選為 `v2.2.1`），保留 D-007 的真實 fast-forward、backup/hash、dirty/ahead refusal；測试工具變更不 bump VERSION。AGENTS 的「宣稱升級已驗證前必跑」優先於 D-007 consequences 中較寬鬆的免重跑文字。測試對象是 committed HEAD，未提交候選不得冒用其結果；候選封裝先用隔離 source snapshot 安裝檢查。
8. **舊文件現況**：STATUS 的 current-release 句仍為 `2.2.1`；計畫的 Next implementation action 仍要求 Antigravity restart 確認，但後續 HANDOFF 已記錄使用者確認完成。本輪更新 current state，舊計畫只在末尾附加日期化的本輪引用／現況更正，不改舊正文或歷史。
9. **提案編號與依賴**：外部 D1～D7 不是 repo D-001～D-007，不重用 ADR ID。IP 編號與其 gate 順序保留；ticket 拆分只把同一 IP 中可獨立驗收的支線拆開，IP-02/IP-03 只有實際失敗才修 skill，否則留下 no-op 證據。
10. **成本目標**：20% 是外部 T4 的待確認設計目標。建議採為候選驗收 gate，保留至少五次獨立輸出/讀取微測試；每個安全/保真案例須每次通過、正確率不下降。沒有可比較 token 資料就標 Not run；僅有字元不可聲稱節省 token。即使候選 no-op，也不能聲稱達標。

## 執行 gate 與證據保存

本輪只呈現 slices，待使用者確認才保存逐張 tickets；不啟動 baseline agent、不改 SKILL.md、不變更安裝或 Git 狀態。完整來源快照及本提案可以先保存。

後續 IP-01 先固定 canonical revision/完整 skill 目錄 hashes、模型/effort、host/runtime 版本、工具能力、必讀規則及全部 S01～S16 oracle，再跑最小雙 session A/B smoke。其餘 A/B 案例可分接續語義與保真/Git/設定兩條支線；兩者完成才進 IP-02。平台/模型不默默更換，source session 對話與 oracle 不傳給 receiver；隔離不成立就記限制，不能宣稱嚴格 no-skill 對照。

結果使用外置的 run manifest、raw traces、快照與量測，不把 oracle/對照輸出放進受測 agent 可讀的 fixture。可解析引用的下一步、blocker、需求落差需要人工判讀。所有測試寫入與 publish 只作用於隔離 fixture 及受控本機 bare remote。

每個行為 slice 連同自己的情境、反例、驗收與必要文件更新交付，且只在實測 RED 後做最小修改；無需修正時以回歸證據結案。兩個 skill 依 IP-02→IP-03 完成各自回歸後才作 IP-04 結構重整，不先開全面 refactor。

IP-04 可分「條件分支與可安裝封裝」和「description 發現與 UI」兩條可驗收支線；彼此無邏輯 blocker，共用檔案的合併需保留各自驗收結果。兩者完成後，IP-05 的候選安全回歸與成本量測可獨立執行；IP-06 需取得兩份結果。任一失敗如實標記，完整達標前不宣稱候選驗收成功。

## 驗收與工具門檻

| 驗收範圍 | AC 映射 | 必要證據 |
|---|---|---|
| 工作身分、frontier、current/intended、接續與 review 範圍 | AC-01、AC-03～AC-05、AC-07、AC-08 | S01～S05、S12～S15 的雙 session traces、快照、人工 oracle 判定 |
| Plan Fidelity、Git/policy、設定 fallback | AC-02、AC-03、AC-06～AC-08 | S06～S11、S14 的來源導出正文比較、不可變快照、local/remote refs 與 staged scope |
| 條件載入、發現與安裝 | AC-09、AC-12 | S13、S16、實際讀檔 traces、負例缺檔、isolated install/hash/idempotency、frontmatter/UI |
| A/B/C、效率及整體正確性 | AC-10、AC-11 | 固定條件與 raw evidence；五次以上微測試、同口徑中位數、正確率、例外與未驗收項 |

- 改 skill：Skill Creator `quick_validate.py`；`verify.ps1 -CanonicalOnly`；takeover `-Mode Validate`。改 continuity/evidence：新 Prepare、全部六方向 fresh forward-test 後再 Check。
- 改 Plan Fidelity：其 `-Mode Validate`、全六方向新 workspaces/forward-test/Check；保留 source-derived expected text，不 hardcode 本輪真實計畫。
- 改安裝行為／路徑／附屬封裝：`test-installation.ps1` 與必要缺依賴負例；改 install/update 邏輯或宣稱 release upgrade 已驗證前跑 `test-update.ps1`。結果須註明受測 revision。
- 改 schema 時才擴其驗證；保留 schema v1 可選與自動 fallback。本提案沒有要求新增 production schema。
- 每個 slice 執行相關 PowerShell AST parsing、`git diff --check` 及文件引用檢查；更新 STATUS/HANDOFF。主要 README 若有實質更新，英文先、繁中後且兩版完整。
- 正式同步後才執行 live `verify.ps1` 並比對八份安裝與附屬檔 hashes；此 gate 等待另行安裝授權，不以隔離安裝冒充完成。

## 本階段下一步

Tickets、implementation、review 與全域安裝均已完成。此工作形成 `2.4.0` release；目前 next action 是完成已授權的 release commit、annotated tag 與 pushes，之後驗證 refs。
