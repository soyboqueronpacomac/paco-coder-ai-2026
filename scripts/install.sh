#!/usr/bin/env bash
set -uo pipefail

DIRECTORIO_SCRIPT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

ejecutar_shell() {
  echo "== Asistente de shell =="
  "$DIRECTORIO_SCRIPT/install-shell.sh"
}

ejecutar_terminal() {
  echo "== Asistente de emuladores de terminal =="
  "$DIRECTORIO_SCRIPT/install-terminal.sh"
}

main() {
  echo "¿Qué quieres configurar?"
  read -r -p "[shell/terminal/ambos] " opcion

  case "$opcion" in
    shell)
      ejecutar_shell
      ;;
    terminal)
      ejecutar_terminal
      ;;
    ambos)
      ejecutar_shell
      ejecutar_terminal
      ;;
    *)
      echo "Opción no reconocida: $opcion" >&2
      exit 1
      ;;
  esac
}

main
