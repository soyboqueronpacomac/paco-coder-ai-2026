#!/usr/bin/env bash
set -euo pipefail

DIRECTORIO_SCRIPT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIRECTORIO_SCRIPT/config.sh"

es_macos() {
  [[ "$(uname -s)" == "Darwin" ]]
}

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

requerir_npm() {
  if ! command -v npm >/dev/null 2>&1; then
    echo "Esta herramienta requiere Node/npm. Instálalo primero con ./scripts/install-devtools.sh (elige 'node')." >&2
    return 1
  fi
}

instalar_claude_code() {
  if command -v claude >/dev/null 2>&1; then
    echo "Claude Code ya está instalado."
    return 0
  fi
  requerir_npm
  npm install -g @anthropic-ai/claude-code
}

instalar_codex() {
  if command -v codex >/dev/null 2>&1; then
    echo "Codex CLI ya está instalado."
    return 0
  fi
  requerir_npm
  npm install -g @openai/codex
}

instalar_gemini_cli() {
  if command -v gemini >/dev/null 2>&1; then
    echo "Gemini CLI ya está instalado."
    return 0
  fi
  requerir_npm
  npm install -g @google/gemini-cli
}

instalar_opencode() {
  if command -v opencode >/dev/null 2>&1; then
    echo "OpenCode ya está instalado."
    return 0
  fi

  if ! es_macos; then
    echo "Instalación automática solo soportada en macOS por ahora. Instala OpenCode manualmente." >&2
    return 1
  fi

  asegurar_homebrew
  brew install sst/tap/opencode
}

instalar_agente() {
  case "$1" in
    claude-code) instalar_claude_code ;;
    codex) instalar_codex ;;
    gemini-cli) instalar_gemini_cli ;;
    opencode) instalar_opencode ;;
    *) echo "Agente no reconocido: $1" >&2 ;;
  esac
}

main() {
  asegurar_gum

  local seleccion
  seleccion=$(gum choose --no-limit $AGENTES_IA_SOPORTADOS)

  if [[ -z "$seleccion" ]]; then
    echo "No se seleccionó ningún agente. No se realizan cambios."
    exit 0
  fi

  while IFS= read -r agente; do
    instalar_agente "$agente"
  done <<< "$seleccion"
}

main
