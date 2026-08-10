#!/usr/bin/env bash
set -euo pipefail

DIRECTORIO_SCRIPT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIRECTORIO_SCRIPT/config.sh"

detectar_shell_actual() {
  basename "${SHELL:-desconocido}"
}

shell_soportado() {
  local candidato="$1"
  for s in "${SHELLS_SOPORTADOS[@]}"; do
    [[ "$s" == "$candidato" ]] && return 0
  done
  return 1
}

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

gestor_paquetes() {
  if es_macos; then
    asegurar_homebrew >&2
    echo "brew"
  elif command -v apt-get >/dev/null 2>&1; then
    echo "apt"
  else
    echo "ninguno"
  fi
}

instalar_shell() {
  local shell_elegido="$1"
  if command -v "$shell_elegido" >/dev/null 2>&1; then
    echo "$shell_elegido ya está instalado."
    return 0
  fi

  local gestor
  gestor=$(gestor_paquetes)
  case "$gestor" in
    brew)
      brew install "$shell_elegido"
      ;;
    apt)
      sudo apt-get update && sudo apt-get install -y "$shell_elegido"
      ;;
    *)
      echo "No se encontró un gestor de paquetes soportado (brew o apt). Instala $shell_elegido manualmente."
      return 1
      ;;
  esac
}

ofrecer_shell_por_defecto() {
  local shell_elegido="$1"
  local ruta_shell
  ruta_shell=$(command -v "$shell_elegido")

  read -r -p "¿Quieres establecer $shell_elegido como shell por defecto? [y/N] " respuesta
  if [[ "$respuesta" =~ ^[Yy]$ ]]; then
    chsh -s "$ruta_shell"
    echo "Shell por defecto actualizado a $shell_elegido. Reinicia la sesión para aplicarlo."
  fi
}

main() {
  local shell_actual
  shell_actual=$(detectar_shell_actual)
  echo "Shell detectado: $shell_actual"

  asegurar_gum

  if ! gum confirm --default=false "¿Instalar o cambiar shell?"; then
    echo "Manteniendo $shell_actual. No se realizan cambios."
    exit 0
  fi

  local shell_elegido
  shell_elegido=$(gum choose "${SHELLS_SOPORTADOS[@]}")

  if ! shell_soportado "$shell_elegido"; then
    echo "Shell no soportado: $shell_elegido" >&2
    exit 1
  fi

  instalar_shell "$shell_elegido"
  ofrecer_shell_por_defecto "$shell_elegido"
}

main
