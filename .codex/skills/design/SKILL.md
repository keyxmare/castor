---
name: design
description: Phase de conception : explore l'existant et propose une approche technique argumentée (ADR si notable) avant tout code. S'arrête pour validation.
---

# design (Codex)

Source unique de la procédure : `.claude/skills/design/SKILL.md`.

Avant d'agir, lis `AGENTS.md` (standards d'équipe → `.claude/CLAUDE.md`), puis ouvre et suis intégralement `.claude/skills/design/SKILL.md`.

Frontière de portabilité (cf. AGENTS.md) : pas de subagents ni de hooks sous Codex → audits en passe inline, `make check-fast` avant tout commit, jamais de commit sur `main`.
