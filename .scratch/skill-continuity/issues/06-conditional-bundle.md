# 06: 按條件載入分支並維持完整封裝

**What to build:** 選用分支按條件載入且每個 skill 的安裝封裝足以完整執行。

**Blocked by:** 05: 讓 wrap-up 交接支援全新 session 接續.

**Status:** complete

**Source:** IP-04; user-approved breakdown, 2026-09-13; Skill continuity architecture adaptation proposal.

- [x] 以 baseline trace 證明需要重整；沒有可觀察效益則 no-op。
- [x] 必需 references 可由入口定位，缺檔有明確失敗，verifier 不只拼接所有文字。
- [x] S16 單/雙 skill、current/legacy 安裝、hash/idempotency 與兩個 consumers 回歸通過。

## Evidence

Evidence: see [SKILL_CONTINUITY_EVIDENCE.md](../../../SKILL_CONTINUITY_EVIDENCE.md). Raw traces and isolated runs remain local under sibling `evidence/` and `runs/` directories. Unavailable runtime-token and host-native checks are recorded there as `Not run`.
