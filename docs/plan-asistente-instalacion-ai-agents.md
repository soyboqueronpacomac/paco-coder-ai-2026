# Plan: Manifiesto de configuración + asistente de agentes de IA (estilo Gentleman.Dots)

## Contexto

El instalador de PacoCoderAi (`scripts/install.sh` + `install-shell.sh`, `install-terminal.sh`, `install-multiplexer.sh`, `install-prompt.sh`, `install-devtools.sh`) ya replica el estilo TUI de [Gentleman.Dots](https://github.com/Gentleman-Programming/Gentleman.Dots) usando `gum`. El usuario quiere dos cosas más, inspiradas en ese mismo proyecto (que en su repo hermano `gentle-ai` configura agentes de IA como Claude Code, OpenCode, Gemini CLI):

1. Un **archivo de configuración**, con doble función (confirmado por el usuario):
   - **Manifiesto de opciones soportadas**: hoy cada script tiene sus listas hardcodeadas (`SHELLS_SOPORTADOS`, `EMULADORES_SOPORTADOS`, `MULTIPLEXORES_SOPORTADOS`, `HERRAMIENTAS_SOPORTADAS`). Se centralizan en un único archivo fuente de verdad.
   - **Registro de selecciones del usuario**: cada vez que se ejecuta `install.sh`, se guarda qué eligió el usuario, para tener un registro reproducible de su entorno.
2. Un **nuevo asistente de agentes de IA** (`scripts/install-ai-agents.sh`), con selección múltiple o ninguna (checklist `gum choose --no-limit`) entre: **Claude Code, Codex CLI, Gemini CLI y OpenCode**.

Este documento planifica el alcance; no se implementa código todavía.

## Diseño

### 1. Manifiesto de opciones (`scripts/config.sh`)

Un archivo bash-sourceable (sin nuevas dependencias como `yq`/`jq`, consistente con el resto del proyecto) con las listas de opciones soportadas:

```bash
SHELLS_SOPORTADOS=("zsh" "bash" "fish")
EMULADORES_SOPORTADOS="alacritty kitty wezterm hyper ghostty"
MULTIPLEXORES_SOPORTADOS="tmux zellij herdr ninguno"
HERRAMIENTAS_SOPORTADAS="node bun go php composer laravel herd"
AGENTES_IA_SOPORTADOS="claude-code codex gemini-cli opencode"
```

Cada script (`install-shell.sh`, `install-terminal.sh`, `install-multiplexer.sh`, `install-devtools.sh`, el nuevo `install-ai-agents.sh`, y `scripts/install.sh` para sus categorías) hace `source "$DIRECTORIO_SCRIPT/config.sh"` en vez de declarar su propia lista. La lógica de detección/instalación de cada script no cambia, solo el origen de las listas.

### 2. Registro de selecciones (generado por `install.sh`)

Al terminar de ejecutar las categorías marcadas en el checklist principal, `scripts/install.sh` escribe un archivo YAML con lo elegido en esa ejecución:

- Ruta: `${XDG_CONFIG_HOME:-$HOME/.config}/pacocoderai/config.yml`.
- Contenido: fecha de ejecución y lista de categorías marcadas (shell/terminal/multiplexor/prompt/devtools/ai-agents) con lo que se seleccionó dentro de cada una, cuando el sub-script lo devuelva.
- Es un archivo de solo escritura desde estos scripts (no necesita ser re-parseado por bash), pensado como registro legible para el usuario.

### 3. Nuevo `scripts/install-ai-agents.sh`

Mismo patrón que `install-devtools.sh`:
- `asegurar_homebrew()`, `asegurar_gum()`.
- Sourcea `AGENTES_IA_SOPORTADOS` desde `config.sh`.
- Checklist `gum choose --no-limit` — selección vacía es válida (ningún agente).
- Una función `instalar_<agente>()` por cada uno, usando el instalador oficial de cada herramienta (a confirmar el comando exacto de cada una durante la implementación: probablemente `npm install -g` para Claude Code/Codex/Gemini CLI, dado que ya existe `install-devtools.sh` con Node vía `fnm`; OpenCode probablemente vía Homebrew o su instalador curl oficial).

### 4. Integración en `scripts/install.sh`

Se añade `ai-agents` como sexta categoría en `CATEGORIAS_SOPORTADAS` (junto a shell/terminal/multiplexor/prompt/devtools), ejecutando `install-ai-agents.sh` igual que las demás.

## Restricciones / alcance

- No se añaden nuevas dependencias de parseo (no `yq`/`jq`); el manifiesto es bash puro, el registro es YAML de solo escritura.
- La migración a `config.sh` no debe cambiar el comportamiento actual de los scripts existentes — mismos valores, mismo orden.
- Mismo principio de responsabilidad única: `install-ai-agents.sh` no reimplementa lógica de otros asistentes.

## Archivos afectados

- Nuevo: `scripts/config.sh`, `scripts/install-ai-agents.sh`.
- Modificados: `scripts/install-shell.sh`, `scripts/install-terminal.sh`, `scripts/install-multiplexer.sh`, `scripts/install-devtools.sh`, `scripts/install.sh` (sourcear `config.sh` + nueva categoría + escritura del registro), `README.md` (documentar la nueva categoría y el archivo de registro generado).

## Próximos pasos (TODO)

- [ ] Crear `scripts/config.sh` con las listas de opciones soportadas.
- [ ] Migrar `install-shell.sh`, `install-terminal.sh`, `install-multiplexer.sh`, `install-devtools.sh`, `install.sh` para sourcear `config.sh` en vez de declarar sus propias listas.
- [ ] Investigar y confirmar el comando de instalación oficial de cada agente de IA (Claude Code, Codex CLI, Gemini CLI, OpenCode).
- [ ] Implementar `scripts/install-ai-agents.sh` (checklist gum, selección múltiple o ninguna).
- [ ] Añadir `ai-agents` al checklist principal de `scripts/install.sh`.
- [ ] Implementar el registro de selecciones: `install.sh` escribe `${XDG_CONFIG_HOME:-$HOME/.config}/pacocoderai/config.yml` con las categorías/herramientas elegidas en la ejecución.
- [ ] Actualizar `README.md` con la nueva categoría y el archivo de configuración generado.
- [ ] Probar en macOS: manifiesto compartido, instalación de al menos un agente IA, y generación correcta del archivo de registro.
