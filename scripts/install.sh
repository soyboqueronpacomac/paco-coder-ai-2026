#!/usr/bin/env bash
set -uo pipefail

DIRECTORIO_SCRIPT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIRECTORIO_SCRIPT/config.sh"

CATEGORIAS_SOPORTADAS="shell terminal multiplexor prompt devtools ai-agents"

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
    ai-agents)
      echo "== Asistente de agentes de IA =="
      "$DIRECTORIO_SCRIPT/install-ai-agents.sh"
      ;;
    *)
      echo "Categoría no reconocida: $1" >&2
      ;;
  esac
}

escribir_registro() {
  local categorias="$1"
  local directorio_config="${XDG_CONFIG_HOME:-$HOME/.config}/pacocoderai"
  local archivo_config="$directorio_config/config.yml"

  mkdir -p "$directorio_config"

  {
    echo "fecha: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo "categorias:"
    while IFS= read -r categoria; do
      echo "  - $categoria"
    done <<< "$categorias"
  } > "$archivo_config"

  echo "Registro guardado en $archivo_config"
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

  escribir_registro "$seleccion"
}

main
