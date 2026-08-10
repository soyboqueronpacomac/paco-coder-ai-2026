#!/usr/bin/env bash
set -euo pipefail

MULTIPLEXORES_SOPORTADOS="tmux zellij herdr ninguno"

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

instalar_multiplexor() {
  local multiplexor_elegido="$1"

  if [[ "$multiplexor_elegido" == "ninguno" ]]; then
    echo "No se instala ningún multiplexor."
    return 0
  fi

  if ! es_macos; then
    echo "Instalación automática solo soportada en macOS por ahora. Instala $multiplexor_elegido manualmente." >&2
    return 1
  fi

  asegurar_homebrew

  if command -v "$multiplexor_elegido" >/dev/null 2>&1; then
    echo "$multiplexor_elegido ya está instalado."
    return 0
  fi

  brew install "$multiplexor_elegido"
}

main() {
  asegurar_gum

  local multiplexor_elegido
  multiplexor_elegido=$(gum choose $MULTIPLEXORES_SOPORTADOS)

  instalar_multiplexor "$multiplexor_elegido"
}

main
