# 03: 建立保真、Git、設定與安裝 baseline

**What to build:** 以真實正文、index、refs 與安裝快照取得 S06～S11、S16 baseline，處理 updater 測試的前版選擇。

**Blocked by:** 01: 凍結基線並跑通最小雙 session 對照.

**Status:** complete

**Source:** IP-01; user-approved breakdown, 2026-09-13; Skill continuity architecture adaptation proposal.

- [x] 覆蓋 plan 正文、draft/缺來源、mode/policy、設定 fallback 與隔離安裝；未實測者標示原因。
- [x] 隔離重現 updater 相同 VERSION 的失敗後作最小修正；保留 fast-forward、backup/hash、dirty/ahead refusal。
- [x] 機械 checker 必須拒絕未執行與受損產物，預期正文由 fixture source 導出。

## Evidence

Evidence: see [SKILL_CONTINUITY_EVIDENCE.md](../../../SKILL_CONTINUITY_EVIDENCE.md). Raw traces and isolated runs remain local under sibling `evidence/` and `runs/` directories. Unavailable runtime-token and host-native checks are recorded there as `Not run`.
