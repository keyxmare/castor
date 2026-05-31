---
name: test
description: Écrit et lance les tests du périmètre en cours via Docker (PHPUnit, Vitest, Playwright). Red-green pour un bug.
---

# test (Codex)

Source unique de la procédure : `.claude/skills/test/SKILL.md`.

Avant d'agir, lis `AGENTS.md` (standards d'équipe → `.claude/CLAUDE.md`), puis ouvre et suis intégralement `.claude/skills/test/SKILL.md`.

Frontière de portabilité (cf. AGENTS.md) : pas de subagents ni de hooks sous Codex → audits en passe inline, `make check-fast` avant tout commit, jamais de commit sur `main`.
