# 07: 精簡 description 並驗證觸發與 UI

**What to build:** 必要入口仍能被發現，單純比較或引用不誤啟動，UI 與命令一致。

**Blocked by:** 05: 讓 wrap-up 交接支援全新 session 接續.

**Status:** complete

**Source:** IP-04; user-approved breakdown, 2026-09-13; Skill continuity architecture adaptation proposal.

- [x] 保留 model-invocation 與僅 name/description frontmatter。
- [x] S13 正負觸發實測、五次獨立 wording 樣本與對照；無缺口則 no-op。
- [x] description/UI/verifier 同步且不丟失既有 mode 契約。

## Evidence

Evidence: see [SKILL_CONTINUITY_EVIDENCE.md](../../../SKILL_CONTINUITY_EVIDENCE.md). Raw traces and isolated runs remain local under sibling `evidence/` and `runs/` directories. Unavailable runtime-token and host-native checks are recorded there as `Not run`.
