---
name: commit
description: Crée un commit Conventional Commits des changements en cours. Lancer check d'abord ; jamais de commit si un gate échoue.
---

# commit (Codex)

Source unique de la procédure : `.claude/skills/commit/SKILL.md`.

Avant d'agir, lis `AGENTS.md` (standards d'équipe → `.claude/CLAUDE.md`), puis ouvre et suis intégralement `.claude/skills/commit/SKILL.md`.

Frontière de portabilité (cf. AGENTS.md) : pas de subagents ni de hooks sous Codex → audits en passe inline, `make check-fast` avant tout commit, jamais de commit sur `main`.
