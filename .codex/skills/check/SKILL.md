---
name: check
description: Gates qualité (format → lint → analyse statique → typecheck → tests) dans Docker. S'arrête à la première erreur. Pré-requis du commit.
---

# check (Codex)

Source unique de la procédure : `.claude/skills/check/SKILL.md`.

Avant d'agir, lis `AGENTS.md` (standards d'équipe → `.claude/CLAUDE.md`), puis ouvre et suis intégralement `.claude/skills/check/SKILL.md`.

Frontière de portabilité (cf. AGENTS.md) : pas de subagents ni de hooks sous Codex → audits en passe inline, `make check-fast` avant tout commit, jamais de commit sur `main`.
