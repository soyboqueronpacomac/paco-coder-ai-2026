#!/usr/bin/env bash
set -uo pipefail

DIRECTORIO_SCRIPT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CATEGORIAS_SOPORTADAS="shell terminal multiplexor prompt devtools"

asegurar_homebrew() {
  if command -v brew >/dev/null 2>&1; then
    return 0
  fi
  echo "Homebrew no está instalado. Instalando..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
}

asegurar_gum() {
  if command -v gum >/dev/null 2>&1; then
    return 0
  fi
  echo "gum no está instalado. Instalando..."
  asegurar_homebrew
  brew install gum
}

ejecutar_categoria() {
  case "$1" in
    shell)
      echo "== Asistente de shell =="
      "$DIRECTORIO_SCRIPT/install-shell.sh"
      ;;
    terminal)
      echo "== Asistente de emuladores de terminal =="
      "$DIRECTORIO_SCRIPT/install-terminal.sh"
      ;;
    multiplexor)
      echo "== Asistente de multiplexor de terminal =="
      "$DIRECTORIO_SCRIPT/install-multiplexer.sh"
      ;;
    prompt)
      echo "== Asistente de prompt =="
      "$DIRECTORIO_SCRIPT/install-prompt.sh"
      ;;
    devtools)
      echo "== Asistente de herramientas de desarrollo =="
      "$DIRECTORIO_SCRIPT/install-devtools.sh"
      ;;
    *)
      echo "Categoría no reconocida: $1" >&2
      ;;
  esac
}

main() {
  asegurar_gum

  local seleccion
  seleccion=$(gum choose --no-limit $CATEGORIAS_SOPORTADAS)

  if [[ -z "$seleccion" ]]; then
    echo "No se seleccionó ninguna categoría. No se realizan cambios."
    exit 0
  fi

  while IFS= read -r categoria; do
    ejecutar_categoria "$categoria"
  done <<< "$seleccion"
}

main
