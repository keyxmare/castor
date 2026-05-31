#!/usr/bin/env bash
set -euo pipefail

CASTOR_REPO="${CASTOR_REPO:-https://github.com/keyxmare/castor.git}"
CASTOR_REF="${CASTOR_REF:-main}"
CASTOR_URL="${CASTOR_URL:-http://localhost}"
HEALTH_TIMEOUT="${CASTOR_HEALTH_TIMEOUT:-300}"

PROJECT_DIR="${1:-${CASTOR_DIR:-castor}}"

die() {
  echo "✗ $1" >&2
  exit 1
}

need() {
  command -v "$1" >/dev/null 2>&1 || die "$2"
}

clone_project() {
  if [ -d "$PROJECT_DIR/.git" ]; then
    echo "→ Dossier '$PROJECT_DIR' déjà cloné, réutilisation."
  elif [ -e "$PROJECT_DIR" ]; then
    die "'$PROJECT_DIR' existe déjà sans être un clone git. Choisis un autre nom : … | bash -s -- <nom>"
  else
    echo "→ Clone de $CASTOR_REPO ($CASTOR_REF) dans '$PROJECT_DIR'…"
    git clone --branch "$CASTOR_REF" "$CASTOR_REPO" "$PROJECT_DIR"
    if [ -z "${CASTOR_KEEP_GIT:-}" ]; then
      rm -rf "$PROJECT_DIR/.git"
      git init -q "$PROJECT_DIR"
      echo "→ Historique du scaffold retiré, dépôt git neuf (CASTOR_KEEP_GIT=1 pour le conserver)."
    fi
  fi
}

assert_docker() {
  need docker "Docker est requis. Installe Docker Desktop : https://www.docker.com/get-started"
  docker info >/dev/null 2>&1 || die "Le démon Docker ne tourne pas. Démarre Docker puis relance."
  docker compose version >/dev/null 2>&1 || die "Le plugin 'docker compose' (Compose v2) est requis."
}

HEALTH_CODE=000

probe_health() {
  local response
  response=$(curl -sS -m 5 -w '\n%{http_code}' "$CASTOR_URL/api/health" 2>/dev/null) || { HEALTH_CODE=000; return 1; }
  HEALTH_CODE=${response##*$'\n'}
  [ "$HEALTH_CODE" = "200" ] && printf '%s' "${response%$'\n'*}" | grep -q '"database"'
}

report_health_failure() {
  echo >&2
  case "$HEALTH_CODE" in
    000) echo "✗ Application injoignable sur $CASTOR_URL après ${HEALTH_TIMEOUT}s (aucune réponse)." >&2 ;;
    5*)  echo "✗ L'application répond en HTTP $HEALTH_CODE sur /api/health après ${HEALTH_TIMEOUT}s." >&2
         echo "  Cause fréquente : dépendances backend manquantes ou échec du boot Symfony." >&2 ;;
    *)   echo "✗ Healthcheck KO (HTTP $HEALTH_CODE) après ${HEALTH_TIMEOUT}s." >&2 ;;
  esac
  echo "  Derniers logs php :" >&2
  docker compose logs --no-color --tail=30 php >&2 2>/dev/null || true
  echo "  Plus de logs : (cd $PROJECT_DIR && make logs)" >&2
  exit 1
}

wait_for_health() {
  need curl "curl est requis pour vérifier la disponibilité de l'application."
  echo "→ Attente de l'application sur $CASTOR_URL/api/health (jusqu'à ${HEALTH_TIMEOUT}s)…"
  local elapsed=0
  until probe_health; do
    [ "$elapsed" -lt "$HEALTH_TIMEOUT" ] || report_health_failure
    sleep 3
    elapsed=$((elapsed + 3))
    printf '.'
  done
  echo
}

open_app() {
  [ -z "${CASTOR_NO_OPEN:-}" ] || return 0
  if command -v open >/dev/null 2>&1; then
    open "$CASTOR_URL" >/dev/null 2>&1 || true
  elif command -v xdg-open >/dev/null 2>&1; then
    xdg-open "$CASTOR_URL" >/dev/null 2>&1 || true
  fi
}

print_links() {
  cat <<EOF

✅ $PROJECT_DIR tourne.
   → $CASTOR_URL              front Nuxt (/api proxifié)
   → $CASTOR_URL/api/health   healthcheck applicatif
   → $CASTOR_URL/api/greeting endpoint d'exemple

Pour continuer :  cd $PROJECT_DIR
Nouveau projet ?  ouvre Claude Code et lance /castor-init $PROJECT_DIR
EOF
}

assert_project_dir() {
  case "$PROJECT_DIR" in
    ""|.|..) die "Nom de projet invalide : '$PROJECT_DIR'." ;;
    *[!A-Za-z0-9._-]*) die "Nom de projet invalide : '$PROJECT_DIR' (lettres, chiffres, '.', '_', '-')." ;;
  esac
}

main() {
  assert_project_dir
  need git "git est requis pour cloner le projet : https://git-scm.com/downloads"
  clone_project
  cd "$PROJECT_DIR"
  assert_docker
  need make "make est requis (macOS : xcode-select --install ; Debian/Ubuntu : apt-get install make)."
  [ -f .env ] || cp .env.dist .env
  echo "→ Build, installation des dépendances et démarrage de la stack (quelques minutes au 1er lancement)…"
  make build
  make install
  make up
  wait_for_health
  open_app
  print_links
}

main "$@"
