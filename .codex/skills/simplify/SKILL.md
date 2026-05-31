---
name: simplify
description: Nettoie le code mort et simplifie le diff en cours sans changer le comportement (qualité, pas chasse aux bugs).
---

# simplify (Codex)

Source unique de la procédure : `.claude/skills/simplify/SKILL.md`.

Avant d'agir, lis `AGENTS.md` (standards d'équipe → `.claude/CLAUDE.md`), puis ouvre et suis intégralement `.claude/skills/simplify/SKILL.md`.

Frontière de portabilité (cf. AGENTS.md) : pas de subagents ni de hooks sous Codex → audits en passe inline, `make check-fast` avant tout commit, jamais de commit sur `main`.
