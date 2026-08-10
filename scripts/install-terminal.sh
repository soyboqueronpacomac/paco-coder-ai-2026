#!/usr/bin/env bash
set -euo pipefail

EMULADORES_SOPORTADOS="alacritty kitty wezterm hyper ghostty"

detectar_emulador_actual() {
  case "${TERM_PROGRAM:-}" in
    iTerm.app) echo "iTerm2" ;;
    Apple_Terminal) echo "Terminal.app" ;;
    WezTerm) echo "wezterm" ;;
    Hyper) echo "hyper" ;;
    ghostty) echo "ghostty" ;;
    "")
      case "${TERM:-}" in
        alacritty) echo "alacritty" ;;
        xterm-kitty) echo "kitty" ;;
        *) echo "desconocido" ;;
      esac
      ;;
    *) echo "${TERM_PROGRAM}" ;;
  esac
}

emulador_soportado() {
  local candidato="$1"
  for e in $EMULADORES_SOPORTADOS; do
    [[ "$e" == "$candidato" ]] && return 0
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

asegurar_fzf() {
  if command -v fzf >/dev/null 2>&1; then
    return 0
  fi
  echo "fzf no está instalado. Instalando..."
  asegurar_homebrew
  brew install fzf
}

instalar_emulador() {
  local emulador_elegido="$1"

  if ! es_macos; then
    echo "Instalación automática solo soportada en macOS por ahora. Instala $emulador_elegido manualmente." >&2
    return 1
  fi

  asegurar_homebrew

  if brew list --cask "$emulador_elegido" >/dev/null 2>&1; then
    echo "$emulador_elegido ya está instalado."
    return 0
  fi

  brew install --cask "$emulador_elegido"
}

main() {
  local emulador_actual
  emulador_actual=$(detectar_emulador_actual)
  echo "Emulador de terminal detectado: $emulador_actual"

  read -r -p "¿Instalar o cambiar emulador? [S/n] " decision
  decision="${decision:-n}"
  if [[ ! "$decision" =~ ^[Ss]$ ]]; then
    echo "Manteniendo $emulador_actual. No se realizan cambios."
    exit 0
  fi

  asegurar_fzf
  local emulador_elegido
  emulador_elegido=$(printf '%s\n' $EMULADORES_SOPORTADOS | fzf --prompt="Elige un emulador> ")

  if ! emulador_soportado "$emulador_elegido"; then
    echo "Emulador no soportado: $emulador_elegido" >&2
    exit 1
  fi

  instalar_emulador "$emulador_elegido"
}

main
