# 01: 凍結基線並跑通最小雙 session 對照

**What to build:** 固定 revision、完整 skill hashes、環境與 oracle，跑通 A/B 的 wrap-up → fresh bootstrap，保存 raw traces 與前後快照。

**Blocked by:** None (can start immediately).

**Status:** complete

**Source:** IP-01; user-approved breakdown, 2026-09-13; Skill continuity architecture adaptation proposal.

- [x] 保存現版可恢復來源、模型/effort/runtime/工具與分組條件。
- [x] producer 與 receiver 使用獨立 context；receiver 不取得前段對話或 oracle。
- [x] 最小 A/B smoke 有真實執行、快照及可見載入量；嚴格 no-skill 隔離做不到時記明限制。

## Evidence

Evidence: see [SKILL_CONTINUITY_EVIDENCE.md](../../../SKILL_CONTINUITY_EVIDENCE.md). Raw traces and isolated runs remain local under sibling `evidence/` and `runs/` directories. Unavailable runtime-token and host-native checks are recorded there as `Not run`.
