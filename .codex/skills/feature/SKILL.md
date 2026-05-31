---
name: feature
description: Orchestrateur du workflow complet : conception → plan → dev → durcissement → review → commit → push, avec gates de validation.
---

# feature (Codex)

Source unique de la procédure : `.claude/skills/feature/SKILL.md`.

Avant d'agir, lis `AGENTS.md` (standards d'équipe → `.claude/CLAUDE.md`), puis ouvre et suis intégralement `.claude/skills/feature/SKILL.md`.

Frontière de portabilité (cf. AGENTS.md) : pas de subagents ni de hooks sous Codex → audits en passe inline, `make check-fast` avant tout commit, jamais de commit sur `main`.
