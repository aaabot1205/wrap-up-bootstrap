# 08: 驗收候選版保真與 Git 相容性

**What to build:** 完整驗收候選的 mode/policy、重複保存、字元保真、staging 及隔離發布成敗。

**Blocked by:** 06: 按條件載入分支並維持完整封裝; 07: 精簡 description 並驗證觸發與 UI.

**Status:** complete

**Source:** IP-05; user-approved breakdown, 2026-09-13; Skill continuity architecture adaptation proposal.

- [x] S06～S11、S14 以正文/工作樹/index/local與remote refs 斷言，不用口述成功。
- [x] 六個跨平台方向保留且適用 fresh forward-test 全數完成。
- [x] 安全/保真每次通過；未覆蓋 runtime 或場景如實標明，不宣稱全面成功。

## Evidence

Evidence: see [SKILL_CONTINUITY_EVIDENCE.md](../../../SKILL_CONTINUITY_EVIDENCE.md). Raw traces and isolated runs remain local under sibling `evidence/` and `runs/` directories. Unavailable runtime-token and host-native checks are recorded there as `Not run`.
