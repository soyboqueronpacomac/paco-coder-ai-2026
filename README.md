# PacoCoderAi

## Instalación

Instalador único al estilo [Gentleman.Dots](https://github.com/Gentleman-Programming/Gentleman.Dots), con una interfaz interactiva construida con [`gum`](https://github.com/charmbracelet/gum) (se instala automáticamente vía Homebrew si falta).

Punto de entrada recomendado:

```bash
./scripts/install.sh
```

Muestra un checklist (`gum choose --no-limit`) con las categorías disponibles — `shell`, `terminal`, `multiplexor`, `prompt`, `devtools` — y ejecuta en secuencia el asistente de cada categoría marcada. También puedes ejecutar cada asistente por separado.

### Shell

```bash
./scripts/install-shell.sh
```

1. Detecta el shell actual (variable `$SHELL`).
2. Pregunta con `gum confirm` si quieres instalar/cambiar (por defecto, "No" = mantener el actual).
3. Si confirmas, te deja elegir con `gum choose` un shell de la lista: `zsh`, `bash`, `fish`.
4. En macOS, instala Homebrew primero si no está presente.
5. Instala el shell elegido con el gestor de paquetes disponible (`brew` en macOS, `apt` en Linux).
6. Pregunta si quieres establecerlo como shell por defecto.

### Emuladores de terminal

```bash
./scripts/install-terminal.sh
```

1. Detecta el emulador de terminal actual.
2. Pregunta con `gum confirm` si quieres instalar/cambiar (por defecto, "No" = mantener el actual).
3. Si confirmas, te deja elegir con `gum choose` un emulador de la lista: `alacritty`, `kitty`, `wezterm`, `hyper`, `ghostty`.
4. En macOS, instala Homebrew primero si no está presente.
5. Instala el emulador elegido con `brew install --cask` (solo macOS por ahora).

### Multiplexor de terminal

```bash
./scripts/install-multiplexer.sh
```

Elige con `gum choose` entre `tmux`, `zellij`, `herdr` o `ninguno`, e instala la opción elegida vía Homebrew (solo macOS por ahora).

### Prompt

```bash
./scripts/install-prompt.sh
```

Pregunta con `gum confirm` si quieres instalar y configurar [Starship](https://starship.rs/). Si confirmas, lo instala vía Homebrew y añade la línea de inicialización al rc de tu shell actual (sin duplicarla si ya está presente).

### Herramientas de desarrollo

```bash
./scripts/install-devtools.sh
```

Checklist (`gum choose --no-limit`) para instalar, en cualquier combinación: Node LTS (vía `fnm`), Bun, Go, PHP, Composer, Laravel y Herd. Si eliges Laravel sin PHP ni Composer, se instalan automáticamente como prerequisitos.
