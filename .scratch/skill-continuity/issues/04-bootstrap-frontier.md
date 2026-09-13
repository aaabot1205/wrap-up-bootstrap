# 04: 讓 bootstrap 正確定位可開始的工作

**What to build:** 恢復正式工作身分，依 blocker 證據選 frontier，取得足夠資訊後停止探索。

**Blocked by:** 02: 建立工作接續與需求落差 baseline; 03: 建立保真、Git、設定與安裝 baseline.

**Status:** complete

**Source:** IP-02; user-approved breakdown, 2026-09-13; Skill continuity architecture adaptation proposal.

- [x] 只針對 baseline 實際失敗作最小修改；無缺口則 no-op 並保留證據。
- [x] S01、S03～S05、S11～S13 回歸，保留唯讀與 follow-on、accepted intent 及必讀規範。
- [x] Skill Creator、canonical verifier、適用六方向 forward tests 通過；五次 wording 微測試保留結果。

## Evidence

Evidence: see [SKILL_CONTINUITY_EVIDENCE.md](../../../SKILL_CONTINUITY_EVIDENCE.md). Raw traces and isolated runs remain local under sibling `evidence/` and `runs/` directories. Unavailable runtime-token and host-native checks are recorded there as `Not run`.
