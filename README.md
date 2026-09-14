# Wrap-up and Bootstrap Skills

This project maintains two global, cross-platform Agent Skills for Codex, Claude Code, and Google Antigravity:

- `wrap-up`: close a project phase, reconcile durable documentation, and verify the work; publish only when explicitly requested.
- `bootstrap`: reconstruct reliable project context in a new session and optionally begin a supplied follow-on task.

The current implementation is usable. The remaining reliability, safety, project-context, and operating-system improvements are organized in `IMPLEMENTATION_PLAN.md` so they can be delivered incrementally without destabilizing the working baseline.

Current release: `2.4.0` (`v2.4.0`). Previous release: `2.3.0` (`v2.3.0`); `v2.2.1` remains the Antigravity discovery correction, `v2.2.0` remains the Plan Fidelity release, and the recoverable Version 1 baseline remains `1.0.0` (`v1.0.0`). Version 2.4 substantially improves fresh-session continuity, gap-driven reading, conditional skill packaging, evidence-qualified handoff, and isolated safety coverage.

## Version 2 command contract

- `bootstrap` gathers project context without editing during the bootstrap phase and may then begin a supplied follow-on task.
- `wrap-up` reconciles documentation and verifies the completed phase without staging, committing, or pushing.
- `wrap-up plan` additionally preserves the latest explicitly user-confirmed plan verbatim in the canonical plan document and remains non-publishing.
- `wrap-up publish` adds a safeguarded, scoped commit and push after successful required verification.
- `wrap-up plan publish` combines Plan Fidelity with the independently authorized publish workflow.
- `wrap-up ncp` remains a compatibility alias for the non-publishing default.

Published `v1.x` users retain the older default-publishing contract. When migrating to Version 2, add `publish` to automation or prompts that are intended to commit and push. A plain `wrap-up` now stops after documentation reconciliation and verification.

Before publishing, the skill inspects the branch, upstream, remote, unstaged and staged diffs; establishes an explicit phase-owned path list; and blocks ambiguous, unrelated, or likely sensitive files. Failed mandatory checks block publication unless the user sees the failure and explicitly overrides it. The workflow never force-pushes, resets, discards work, or uses broad staging shortcuts.

`plan` is a standalone, case-insensitive functional flag, not publishing authorization. Plan Fidelity uses the configured `PROJECT_CONTEXT.yaml` plan path when available, otherwise updates the existing canonical plan in place or falls back to root-level `IMPLEMENTATION_PLAN.md`. It copies only an explicitly user-confirmed exact source, preserves wording and structure character-for-character, keeps progress and evidence outside the confirmed-plan body, and reports `Blocked` instead of reconstructing unavailable text or accepting an unconfirmed AI proposal.

## Optional project context

A repository may copy `PROJECT_CONTEXT.example.yaml` to a root-level `PROJECT_CONTEXT.yaml` and tailor it to identify authoritative documents, verification commands, the default branch, publishing policy, cautions, and discovery exclusions. The contract is optional and versioned by `schema_version`; projects without it continue using automatic discovery.

All configured paths are relative to the repository root. A valid file guides routing and policy but never proves that work is implemented or verified. Invalid or unsupported configuration is reported explicitly, then the skills fall back to automatic discovery where safe.

`git.publish_policy` supports `skill-default`, `explicit`, and `never`. Current user instructions still take precedence, and neither skill switches branches merely to match the configured default.

## Evidence contract

Both skills qualify material project claims with five exact labels:

- `Verified`: a check executed in the current session, with the command or check and result recorded;
- `Observed`: current Git, configuration, source, or file state inspected directly;
- `Assumption`: an inference that still needs a stated confirmation method;
- `Not run`: an expected check that was skipped or unavailable, with the reason recorded;
- `Blocked`: incomplete work or verification, with its blocker and recovery action.

A previous session's passing result is historical `Observed` evidence until rerun. One narrow passing check never verifies a broader milestone, and unresolved contradictions remain visible as competing labeled claims.

The regression matrix covers every directed takeover among Codex, Claude Code, and Antigravity. `test-regressions.ps1` validates the six fixture definitions, prepares isolated Git workspaces, and checks that receiving sessions update the existing status, spec, and handoff files without publishing or creating platform-specific replacements.

The Plan Fidelity matrix separately covers the same six directions. `test-plan-fidelity.ps1` validates and prepares both confirmed-source and unconfirmed-only cases, then compares the bounded canonical plan body directly with fixture source text, rejects draft sentinels, checks separate evidence records, and confirms that `wrap-up plan` did not publish.

## Design contract

Project documents belong to the project, not to the AI that created them. Every supported platform must discover and continue the existing source of truth even when another platform chose its filename or last updated it. The skills therefore search by document purpose and repository conventions rather than imposing separate ChatGPT, Claude, or Gemini documentation sets.

See `INSTALL.md` for installation, invocation, disabling, and re-enabling instructions.

## Project layout

- `wrap-up/SKILL.md`: portable wrap-up workflow.
- `bootstrap/SKILL.md`: portable session bootstrap workflow.
- `agents/openai.yaml` inside each skill: optional Codex/ChatGPT UI metadata; other hosts can ignore it.
- `global-rules/`: portable source copies of the response-language and bilingual GitHub README preferences for all three platforms.
- `install.ps1`: idempotent Windows installer for all skills and global rules.
- `verify.ps1`: canonical-contract plus optional installation, hash, managed-rule, frontmatter, metadata, evidence-contract, fixture-matrix, and restart-guidance checks; `-CanonicalOnly` skips installed-copy checks.
- `update.ps1`: guarded fast-forward update, backed-up installation, verification, and version-transition reporting.
- `test-regressions.ps1`: validate, prepare, and check the six-direction cross-platform takeover matrix.
- `tests/fixtures/takeover/`: shared raw fixture templates plus one manifest for each directed platform pair.
- `test-plan-fidelity.ps1`: validate, prepare, and check the six-direction Plan Fidelity matrix.
- `test-skill-packaging.ps1`: copy each skill independently, resolve its linked references, and reject a missing required reference.
- `wrap-up/references/`: conditionally loaded project-context, Plan Fidelity, and publishing contracts packaged with `wrap-up`.
- `tests/fixtures/plan-fidelity/`: generic verbatim-preservation and unconfirmed-draft fixtures.
- `test-installation.ps1`: isolated Windows regression for installation paths, backups, unrelated-skill preservation, verification, and idempotency.
- `PROJECT_CONTEXT.schema.json`: machine-readable Version 1 contract for optional project context.
- `PROJECT_CONTEXT.example.yaml`: documented repository-root configuration example.
- `VERSION`: current source version; release tags identify published baselines.
- `DECISIONS.md`: accepted compatibility and publishing-policy decisions.
- `IMPLEMENTATION_PLAN.md`: phased roadmap from the usable baseline to a versioned, verifiable, safer, and cross-OS system.
- `STATUS.md`: current implementation and verification state.
- `HANDOFF.md`: concise context for the next maintenance session.
- `AGENTS.md`: maintenance rules for any AI agent working in this directory.

## Install on another Windows machine

After authenticating GitHub CLI as `aaabot1205`, run:

```powershell
gh repo clone aaabot1205/wrap-up-bootstrap C:\dev\wrap-up-bootstrap
powershell -NoProfile -ExecutionPolicy Bypass -File C:\dev\wrap-up-bootstrap\install.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File C:\dev\wrap-up-bootstrap\verify.ps1
```

The installer preserves unrelated global instructions and skills, installs Antigravity skills into the current `~/.gemini/config/skills/` discovery root and the legacy `~/.gemini/antigravity/skills/` compatibility root, and creates timestamped backups before changing an existing file. Start new sessions in all three platforms afterward.

Alternatively, open Codex on the new machine and paste this single request:

```text
Authenticate GitHub as aaabot1205 if needed, clone the private repository aaabot1205/wrap-up-bootstrap to C:\dev\wrap-up-bootstrap, run its install.ps1, verify all eight current and compatibility skill installations and three global preference rule files, then report any platform that needs a restart.
```

## Update an existing Windows installation

Run the guarded updater from a clean checkout whose current named branch has an upstream and no unpublished local commits:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File C:\dev\wrap-up-bootstrap\update.ps1
```

The updater fetches the configured upstream, permits only a fast-forward, refuses dirty, detached, untracked, ahead, or divergent local state, then runs `install.ps1` and `verify.ps1`. Run it directly without a preceding `git pull` so it can report the actual version transition. Changed existing global files receive timestamped side-by-side backups. If the checkout is already current, the final report says that the version is unchanged and confirms that installation and verification completed.

---

# Wrap-up 與 Bootstrap Skills（繁體中文）

本專案維護兩個供 Codex、Claude Code 與 Google Antigravity 使用的全域、跨平台 Agent Skills：

- `wrap-up`：結束專案階段、同步持久化文件並驗證成果；只有在明確要求時才會發布。
- `bootstrap`：在新 session 中重建可靠的專案脈絡，並可選擇直接開始指定的後續工作。

目前實作已可正常使用。其餘可靠性、安全性、專案脈絡與作業系統支援改善，均整理於 `IMPLEMENTATION_PLAN.md`，可在不影響現有穩定基準的前提下逐步完成。

目前 release：`2.4.0`（`v2.4.0`）。前一個 release：`2.3.0`（`v2.3.0`）；`v2.2.1` 仍是 Antigravity discovery 修正版，`v2.2.0` 仍是 Plan Fidelity release，而可還原的 Version 1 基準仍為 `1.0.0`（`v1.0.0`）。Version 2.4 大幅改善 fresh-session continuity、gap-driven reading、條件式 skill 封裝、具證據標籤的 handoff，以及隔離安全驗證。

## Version 2 指令契約

- `bootstrap` 會在 bootstrap 階段以唯讀方式蒐集專案脈絡，之後可開始使用者指定的後續工作。
- `wrap-up` 會同步專案文件並驗證已完成的階段，但不會 stage、commit 或 push。
- `wrap-up plan` 會額外把最後一份經使用者明確確認的計畫逐字保存到 canonical plan document，且仍維持非發布。
- `wrap-up publish` 會在必要驗證成功後，執行具安全防護且範圍明確的 commit 與 push。
- `wrap-up plan publish` 會同時啟用 Plan Fidelity 與獨立授權的 publish workflow。
- `wrap-up ncp` 保留為非發布預設模式的相容別名。

已發布的 `v1.x` 使用者仍適用舊版的預設發布契約。遷移至 Version 2 時，原本預期 commit 與 push 的自動化或 prompt 必須加入 `publish`。未加參數的 `wrap-up` 現在會在文件同步與驗證完成後停止。

發布前，skill 會檢查 branch、upstream、remote、unstaged 與 staged diffs，建立明確的本階段檔案清單，並阻擋範圍不明、無關或疑似包含敏感資料的檔案。必要驗證失敗時，除非使用者已看到失敗內容並明確允許 override，否則不得發布。此流程絕不 force-push、reset、捨棄工作或使用廣泛 staging shortcut。

`plan` 是 standalone、case-insensitive 的功能旗標，不代表 publishing authorization。Plan Fidelity 會優先使用 `PROJECT_CONTEXT.yaml` 設定的 plan path，否則原地更新既有 canonical plan，沒有既有慣例時才回退至根目錄 `IMPLEMENTATION_PLAN.md`。它只會複製已有精確原文且經使用者明確確認的計畫，逐字保留措辭與結構，把 progress 與 evidence 留在 confirmed-plan body 外；若精確原文不可得或只有未確認的 AI proposal，則回報 `Blocked`，不自行重建或採用草案。

## 選用的專案脈絡設定

Repository 可以將 `PROJECT_CONTEXT.example.yaml` 複製為根目錄下的 `PROJECT_CONTEXT.yaml`，並依需求設定 authoritative documents、verification commands、default branch、publishing policy、cautions 與 discovery exclusions。此契約為選用功能，並透過 `schema_version` 管理版本；未提供此檔案的專案會繼續使用自動探索。

所有設定路徑都必須相對於 repository root。有效設定只負責引導文件與 policy routing，不能作為功能已實作或已驗證的證據。若設定無效或版本不受支援，skills 會明確報告問題，並在安全範圍內回退至自動探索。

`git.publish_policy` 支援 `skill-default`、`explicit` 與 `never`。使用者目前的指示仍具有最高優先順序，兩個 skills 也不會只為了符合 configured default 而切換 branch。

## 證據契約

兩個 skills 都使用以下五個固定 label 來標示重要專案敘述：

- `Verified`：本次 session 已實際執行檢查，並記錄 command 或 check 與結果；
- `Observed`：直接檢視目前 Git、configuration、source 或檔案所得的狀態；
- `Assumption`：仍未驗證的推論，並附上可確認或否定它的方法；
- `Not run`：預期的檢查未執行，並記錄略過或無法執行的原因；
- `Blocked`：工作或驗證尚未完成，並記錄 blocker 與恢復方式。

前一個 session 的通過結果，在重新執行前只能視為歷史 `Observed` 證據。單一且範圍狹窄的檢查不能驗證更廣泛的 milestone；若目前證據不足以解決矛盾，則必須保留互相競爭且附有 label 的敘述。

Regression matrix 涵蓋 Codex、Claude Code 與 Antigravity 之間每一個有方向性的 takeover 組合。`test-regressions.ps1` 會驗證六份 fixture 定義、建立隔離的 Git workspaces，並檢查接手的 session 是否沿用既有 status、spec 與 handoff 文件，同時不發布或建立平台專屬的替代文件。

Plan Fidelity matrix 另行涵蓋相同六個方向。`test-plan-fidelity.ps1` 會驗證並建立 confirmed-source 與 unconfirmed-only cases，之後直接比對 bounded canonical plan body 與 fixture source text、拒絕 draft sentinel、檢查分離的 evidence records，並確認 `wrap-up plan` 沒有發布。

## 設計契約

專案文件屬於專案，而非建立文件的 AI。即使既有 source of truth 是由另一個平台命名或最後更新，每個受支援平台都必須找到並延續它。因此，skills 會依文件用途與 repository conventions 搜尋，而不會強制建立彼此獨立的 ChatGPT、Claude 或 Gemini 文件組。

安裝、呼叫、停用與重新啟用方式請參閱 `INSTALL.md`。

## 專案結構

- `wrap-up/SKILL.md`：可攜式 wrap-up workflow。
- `bootstrap/SKILL.md`：可攜式 session bootstrap workflow。
- 每個 skill 中的 `agents/openai.yaml`：選用的 Codex/ChatGPT UI metadata；其他 hosts 可忽略。
- `global-rules/`：三個平台之回應語言與 GitHub README 中英雙版本偏好的可攜式 source copies。
- `install.ps1`：安裝所有 skills 與 global rules 的 idempotent Windows installer。
- `verify.ps1`：檢查 canonical contract，以及可選的安裝、hash、managed rules、frontmatter、metadata、evidence contract、fixture matrix 與 restart guidance；`-CanonicalOnly` 會略過 installed-copy checks。
- `update.ps1`：具防護的 fast-forward update、備份安裝、驗證與版本轉換報告。
- `test-regressions.ps1`：驗證、準備及檢查六方向 cross-platform takeover matrix。
- `tests/fixtures/takeover/`：共用原始 fixture templates，以及每個平台方向的一份 manifest。
- `test-plan-fidelity.ps1`：驗證、準備及檢查六方向 Plan Fidelity matrix。
- `test-skill-packaging.ps1`：獨立複製每個 skill、解析其 references，並拒絕缺少必要 reference 的 package。
- `wrap-up/references/`：隨 `wrap-up` 封裝並按條件載入的 project-context、Plan Fidelity 與 publishing contracts。
- `tests/fixtures/plan-fidelity/`：通用的逐字保存與 unconfirmed-draft fixtures。
- `test-installation.ps1`：隔離的 Windows installation regression，涵蓋安裝路徑、備份、無關 skill 保存、驗證與 idempotency。
- `PROJECT_CONTEXT.schema.json`：選用 project context Version 1 契約的 machine-readable schema。
- `PROJECT_CONTEXT.example.yaml`：附有說明的 repository-root 設定範例。
- `VERSION`：目前 source version；release tags 用來標示已發布的 baselines。
- `DECISIONS.md`：已接受的相容性與 publishing-policy decisions。
- `IMPLEMENTATION_PLAN.md`：從可用基準演進至具版本、可驗證、更安全且支援跨 OS 系統的 phased roadmap。
- `STATUS.md`：目前實作與驗證狀態。
- `HANDOFF.md`：供下一個維護 session 使用的精簡脈絡。
- `AGENTS.md`：所有 AI agent 在此目錄工作時必須遵守的維護規則。

## 在另一台 Windows 電腦安裝

以 `aaabot1205` 完成 GitHub CLI 驗證後，執行：

```powershell
gh repo clone aaabot1205/wrap-up-bootstrap C:\dev\wrap-up-bootstrap
powershell -NoProfile -ExecutionPolicy Bypass -File C:\dev\wrap-up-bootstrap\install.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File C:\dev\wrap-up-bootstrap\verify.ps1
```

Installer 會保留無關的全域 instructions 與 skills，將 Antigravity skills 安裝至現行 `~/.gemini/config/skills/` discovery root 及舊版 `~/.gemini/antigravity/skills/` 相容路徑，並在變更既有檔案前建立附 timestamp 的備份。完成後請在三個平台開始新 session 或重新啟動。

也可以在新電腦開啟 Codex，貼上以下單一要求：

```text
需要時先以 aaabot1205 驗證 GitHub，將 private repository aaabot1205/wrap-up-bootstrap clone 到 C:\dev\wrap-up-bootstrap，執行 install.ps1，驗證八個現行及相容 skill installations 與三份 global preference rule files，最後報告哪些平台需要重新啟動。
```

## 更新既有 Windows 安裝

請從 worktree clean、目前 named branch 已設定 upstream，且沒有尚未發布 local commits 的 checkout 執行 guarded updater：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File C:\dev\wrap-up-bootstrap\update.ps1
```

Updater 會 fetch configured upstream，只允許 fast-forward，並拒絕 dirty、detached、untracked、ahead 或 divergent local state，之後才執行 `install.ps1` 與 `verify.ps1`。請直接執行 updater，不要先執行 `git pull`，讓它能報告實際的版本轉換。內容不同的既有 global files 會取得附 timestamp 的 side-by-side backups；如果 checkout 已是最新版，最終報告會說明版本未變，並確認安裝與驗證已完成。
