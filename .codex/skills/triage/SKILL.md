---
name: triage
description: Part d'une erreur Sentry (MCP), la comprend et la reproduit, écrit un test de non-régression rouge, puis enchaîne le fix via feature.
---

# triage (Codex)

Source unique de la procédure : `.claude/skills/triage/SKILL.md`.

Avant d'agir, lis `AGENTS.md` (standards d'équipe → `.claude/CLAUDE.md`), puis ouvre et suis intégralement `.claude/skills/triage/SKILL.md`.

Frontière de portabilité (cf. AGENTS.md) : pas de subagents ni de hooks sous Codex → audits en passe inline, `make check-fast` avant tout commit, jamais de commit sur `main`.
