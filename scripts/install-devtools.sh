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

instalar_node() {
  asegurar_homebrew
  if ! command -v fnm >/dev/null 2>&1; then
    brew install fnm
  fi
  fnm install --lts
  echo "Node LTS instalado vía fnm. Añade 'eval \"\$(fnm env)\"' a tu shell rc si no lo tienes ya."
}

instalar_bun() {
  if command -v bun >/dev/null 2>&1; then
    echo "Bun ya está instalado."
    return 0
  fi
  asegurar_homebrew
  brew install bun
}

instalar_go() {
  if command -v go >/dev/null 2>&1; then
    echo "Go ya está instalado."
    return 0
  fi
  asegurar_homebrew
  brew install go
}

instalar_php() {
  if command -v php >/dev/null 2>&1; then
    echo "PHP ya está instalado."
    return 0
  fi
  asegurar_homebrew
  brew install php
}

instalar_composer() {
  if command -v composer >/dev/null 2>&1; then
    echo "Composer ya está instalado."
    return 0
  fi
  asegurar_homebrew
  brew install composer
}

instalar_laravel() {
  if ! command -v php >/dev/null 2>&1; then
    echo "Laravel requiere PHP. Instalando PHP primero..."
    instalar_php
  fi
  if ! command -v composer >/dev/null 2>&1; then
    echo "Laravel requiere Composer. Instalando Composer primero..."
    instalar_composer
  fi

  if command -v laravel >/dev/null 2>&1; then
    echo "Laravel ya está instalado."
    return 0
  fi

  composer global require laravel/installer
  echo "Laravel instalado. Añade el bin global de Composer (p. ej. ~/.composer/vendor/bin) a tu PATH si no lo tienes ya."
}

instalar_herd() {
  asegurar_homebrew
  if brew list --cask herd >/dev/null 2>&1; then
    echo "Herd ya está instalado."
    return 0
  fi
  brew install --cask herd
}

instalar_herramienta() {
  case "$1" in
    node) instalar_node ;;
    bun) instalar_bun ;;
    go) instalar_go ;;
    php) instalar_php ;;
    composer) instalar_composer ;;
    laravel) instalar_laravel ;;
    herd) instalar_herd ;;
    *) echo "Herramienta no reconocida: $1" >&2 ;;
  esac
}

main() {
  if ! es_macos; then
    echo "Instalación automática solo soportada en macOS por ahora." >&2
    exit 1
  fi

  asegurar_gum

  local seleccion
  seleccion=$(gum choose --no-limit $HERRAMIENTAS_SOPORTADAS)

  if [[ -z "$seleccion" ]]; then
    echo "No se seleccionó ninguna herramienta. No se realizan cambios."
    exit 0
  fi

  while IFS= read -r herramienta; do
    instalar_herramienta "$herramienta"
  done <<< "$seleccion"
}

main
