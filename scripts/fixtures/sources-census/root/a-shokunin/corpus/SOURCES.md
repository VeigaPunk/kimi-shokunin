# SOURCES — where a learns

## Registry

| id | source | kind | tier | scope | anchor | teaches | status | opened | recheck | used-by |
|---|---|---|---|---|---|---|---|---|---|---|
| S001 | Good spec — https://a.example/spec | spec | A | spec s | §1 @ v2 | the spec text | mined | 2026-07-01 | 180d | corpus/knowledge/real.md |
| S002 | Old paper — https://b.example/p | paper | B | p | §2 @ 2020 | old paper | queued | 2026-06-01 | 90d | — |
| S003 | Dup base — https://c.example/x | docs | B | x | y | base row | queued | 2026-10-01 | 90d | — |
| S003 | Dup id — https://c.example/y | docs | B | x | y | dup id row | queued | 2026-10-01 | 90d | — |
| S004 | Dup url — https://c.example/x | docs | B | x | y | dup url row | queued | 2026-10-01 | 90d | — |
| S005 | Bad kind — https://e.example | wiki | B | x | y | bad kind row | queued | 2026-10-01 | 90d | — |
| S006 | Bad tier — https://f.example | docs | Z | x | y | bad tier row | queued | 2026-10-01 | 90d | — |
| S007 | Watch status — https://g.example | docs | B | x | y | watch not a status | watch | 2026-10-01 | 90d | — |
| S008 | Future opened — https://h.example | docs | B | x | y | future opened | queued | 2027-01-01 | 90d | — |
| S009 | Bad recheck — https://i.example | docs | B | x | y | bad recheck | queued | 2026-10-01 | 2026-02-30 | — |
| S010 | Forum — https://j.example | community | A | x | y | community at A | queued | 2026-10-01 | 90d | — |
| S011 | Dangling — https://k.example | paper | B | x | y | dangling used-by | mined | 2026-10-01 | 90d | corpus/knowledge/ghost.md |
| S012 | TierC mined — https://l.example | community | C | x | y | tierC mined | mined | 2026-10-01 | 90d | corpus/knowledge/real.md |
| S013 | Mined unused — https://m.example | docs | B | x | y | mined unused | mined | 2026-10-01 | 90d | — |
| S014 | Malformed | docs | B | x | queued |
| S015 | Rej — https://n.example | docs | B | x | y | no | rejected | 2026-10-01 | on-release | — |
| S016 | Shared canon — https://SHARED.example/canon/ | spec | A | x | y | shared canon | queued | 2026-10-01 | annual | — |
| s017 | Bad id — https://e02.example | docs | B | e02 | §1 @ v1 | lower-case id | queued | 2026-10-01 | 90d | — |

## Paths

- x — S001 → S003: spec first.

## Leads (unopened)

- https://lead.example — not opened.
