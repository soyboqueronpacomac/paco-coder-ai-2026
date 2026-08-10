# PacoCoderAi

## Instalación

Punto de entrada recomendado: un único asistente que te deja elegir qué configurar.

```bash
./scripts/install.sh
```

Pregunta si quieres configurar `shell`, `terminal`, o `ambos`, y ejecuta el/los asistente(s) correspondiente(s) descritos abajo. También puedes ejecutar cada asistente por separado.

### Shell

El proyecto incluye un asistente para detectar tu shell actual y, opcionalmente, instalar otro.

```bash
./scripts/install-shell.sh
```

El script:

1. Detecta el shell actual (variable `$SHELL`).
2. Pregunta `¿Instalar o cambiar shell? [S/n]` (Enter vacío o `n` mantiene el actual).
3. Si respondes `S`, instala `fzf` si falta y te deja elegir un shell de una lista interactiva: `zsh`, `bash`, `fish`.
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
2. Pregunta `¿Instalar o cambiar emulador? [S/n]` (Enter vacío o `n` mantiene el actual).
3. Si respondes `S`, instala `fzf` si falta y te deja elegir un emulador de una lista interactiva: `alacritty`, `kitty`, `wezterm`, `hyper`, `ghostty`.
4. En macOS, instala Homebrew primero si no está presente.
5. Instala el emulador elegido con `brew install --cask` (solo macOS por ahora).
