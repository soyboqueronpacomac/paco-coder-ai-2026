# PacoCoderAi

## Instalación

### Shell

El proyecto incluye un asistente para detectar tu shell actual y, opcionalmente, instalar otro.

```bash
./scripts/install-shell.sh
```

El script:

1. Detecta el shell actual (variable `$SHELL`).
2. Pregunta si quieres mantenerlo o instalar otro.
3. Si eliges instalar otro, muestra los shells soportados: `zsh`, `bash`, `fish`.
4. En macOS, instala Homebrew primero si no está presente.
5. Instala el shell elegido con el gestor de paquetes disponible (`brew` en macOS, `apt` en Linux).
6. Pregunta si quieres establecerlo como shell por defecto.

### Emuladores de terminal

El proyecto incluye un asistente para detectar tu emulador de terminal actual y, opcionalmente, instalar otro.

```bash
./scripts/install-terminal.sh
```

El script:

1. Detecta el emulador de terminal actual.
2. Pregunta si quieres mantenerlo o instalar otro.
3. Si eliges instalar otro, muestra los emuladores soportados: `alacritty`, `kitty`, `wezterm`, `hyper`, `ghostty`.
4. En macOS, instala Homebrew primero si no está presente.
5. Instala el emulador elegido con `brew install --cask` (solo macOS por ahora).
