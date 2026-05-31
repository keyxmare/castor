---
name: plan
description: Phase de planification : découpe l'approche validée en étapes ordonnées (fichiers, done, tests) et crée la liste de tâches. S'arrête pour validation.
---

# plan (Codex)

Source unique de la procédure : `.claude/skills/plan/SKILL.md`.

Avant d'agir, lis `AGENTS.md` (standards d'équipe → `.claude/CLAUDE.md`), puis ouvre et suis intégralement `.claude/skills/plan/SKILL.md`.

Frontière de portabilité (cf. AGENTS.md) : pas de subagents ni de hooks sous Codex → audits en passe inline, `make check-fast` avant tout commit, jamais de commit sur `main`.
