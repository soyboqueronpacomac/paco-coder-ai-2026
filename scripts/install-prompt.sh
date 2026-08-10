#!/usr/bin/env bash
set -euo pipefail

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

instalar_starship() {
  if command -v starship >/dev/null 2>&1; then
    echo "Starship ya está instalado."
    return 0
  fi

  if ! es_macos; then
    echo "Instalación automática solo soportada en macOS por ahora. Instala Starship manualmente." >&2
    return 1
  fi

  asegurar_homebrew
  brew install starship
}

configurar_starship() {
  local shell_actual
  shell_actual=$(basename "${SHELL:-}")

  local archivo_config linea_init
  case "$shell_actual" in
    zsh)
      archivo_config="$HOME/.zshrc"
      linea_init='eval "$(starship init zsh)"'
      ;;
    bash)
      archivo_config="$HOME/.bashrc"
      linea_init='eval "$(starship init bash)"'
      ;;
    fish)
      archivo_config="$HOME/.config/fish/config.fish"
      linea_init='starship init fish | source'
      ;;
    *)
      echo "No se pudo determinar el archivo de configuración para $shell_actual." >&2
      return 1
      ;;
  esac

  if [[ -f "$archivo_config" ]] && grep -qF "starship init" "$archivo_config"; then
    echo "Starship ya está configurado en $archivo_config."
    return 0
  fi

  echo "$linea_init" >> "$archivo_config"
  echo "Starship configurado en $archivo_config."
}

main() {
  asegurar_gum

  if ! gum confirm --default=false "¿Instalar y configurar Starship?"; then
    echo "No se realizan cambios."
    exit 0
  fi

  instalar_starship
  configurar_starship
}

main
