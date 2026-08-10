# Plan: Asistente de instalación completo al estilo Gentleman.Dots

## Contexto

El proyecto ya tiene tres scripts de instalación independientes: `scripts/install-shell.sh` (shell), `scripts/install-terminal.sh` (emulador de terminal) y `scripts/install.sh` (wrapper que hoy deja elegir entre shell/terminal/ambos, usando `fzf` para las listas de selección).

El usuario quiere ampliar esto a un asistente único inspirado en [Gentleman.Dots](https://github.com/Gentleman-Programming/Gentleman.Dots): un instalador TUI que cubre más categorías (SO, shell, terminal, multiplexor, prompt, herramientas de desarrollo) desde un solo punto de entrada, con una interfaz visual más cuidada que simples prompts de `read`.

Este documento solo planifica el alcance y el mecanismo; no se implementa código todavía.

## Objetivo

`scripts/install.sh` pasa a ser el instalador completo del proyecto, con estas categorías:

1. **Sistema operativo**: detección automática (macOS/Linux), mostrada informativamente — no es un paso de elección del usuario.
2. **Shell**: zsh, bash, fish (elegir uno) — delega en `scripts/install-shell.sh`.
3. **Emulador de terminal**: alacritty, kitty, wezterm, hyper, ghostty (elegir uno) — delega en `scripts/install-terminal.sh`.
4. **Multiplexor de terminal**: tmux, zellij, herdr, o ninguno (elegir uno) — nuevo `scripts/install-multiplexer.sh`.
5. **Prompt**: Starship (instalar y configurar) — nuevo `scripts/install-prompt.sh`.
6. **Herramientas de desarrollo** (selección múltiple / checklist): Node LTS vía `fnm`, Bun, Go, PHP, Composer, Laravel, Herd — nuevo `scripts/install-devtools.sh`.

## Mecanismo propuesto

- Toda la interacción del asistente se unifica en **`gum`** (charmbracelet), sustituyendo el uso actual de `fzf` en `install-shell.sh` e `install-terminal.sh`. Cada script gana una función `asegurar_gum()` (mismo patrón que `asegurar_homebrew()`), y las funciones `asegurar_fzf()` existentes se eliminan.
- Las confirmaciones tipo `[S/n]` (instalar/mantener) se sustituyen por `gum confirm`, con "No" (mantener) como opción por defecto, manteniendo el comportamiento ya acordado.
- Las selecciones de una sola opción (shell, emulador, multiplexor) usan `gum choose`.
- La selección de herramientas de desarrollo usa `gum choose --no-limit` (checklist multi-selección), ya que el usuario puede querer instalar varias a la vez.
- `scripts/install.sh` presenta primero un menú principal (checklist con `gum choose --no-limit`) para elegir qué categorías configurar en esta ejecución (shell / terminal / multiplexor / prompt / herramientas de desarrollo), y luego invoca en secuencia el script correspondiente a cada categoría marcada — sin reimplementar la lógica de cada uno (mismo principio de responsabilidad única ya aplicado a shell/terminal).
- Dependencias entre herramientas de desarrollo (p. ej. Laravel requiere Composer y PHP) se resuelven instalando primero sus prerequisitos si el usuario marcó Laravel sin marcar PHP/Composer.

## Restricciones / alcance

- Esta tarea es solo de planificación: no se escribe código todavía.
- `scripts/install-shell.sh` e `scripts/install-terminal.sh` se modifican solo en su mecanismo de selección (fzf → gum); su lógica de detección/instalación no cambia.
- Los nuevos scripts (`install-multiplexer.sh`, `install-prompt.sh`, `install-devtools.sh`) siguen el mismo patrón de los existentes: autocontenidos, con su propia `asegurar_homebrew()`/`asegurar_gum()`, sin mezclar responsabilidades entre categorías.
- Instalación soportada inicialmente solo en macOS vía Homebrew (igual que `install-terminal.sh`); Linux queda para una iteración futura si aplica.
- Este plan sustituye el mecanismo de menú descrito en `docs/plan-asistente-instalacion-wrapper.md` (que usaba una elección simple shell/terminal/ambos sin `gum`). Al implementar, ese documento y `docs/plan-asistente-instalacion-shell.md` / `docs/plan-asistente-instalacion-terminal.md` deben actualizarse para reflejar `gum` en vez de `fzf`.

## Próximos pasos (TODO)

- [ ] Diseñar el texto exacto del menú principal y de cada checklist/selección con `gum`.
- [ ] Migrar `install-shell.sh` e `install-terminal.sh` de `fzf`/`[S/n]` manual a `gum choose`/`gum confirm`.
- [ ] Implementar `scripts/install-multiplexer.sh` (tmux, zellij, herdr).
- [ ] Implementar `scripts/install-prompt.sh` (Starship).
- [ ] Implementar `scripts/install-devtools.sh` (Node LTS vía fnm, Bun, Go, PHP, Composer, Laravel, Herd), resolviendo dependencias entre herramientas (Laravel → Composer/PHP).
- [ ] Reescribir `scripts/install.sh` como checklist principal que orquesta las categorías marcadas.
- [ ] Actualizar `README.md` y los planes existentes (`plan-asistente-instalacion-wrapper.md`, `plan-asistente-instalacion-shell.md`, `plan-asistente-instalacion-terminal.md`) para reflejar el nuevo mecanismo.
- [ ] Probar el asistente completo en macOS, incluyendo dependencias entre herramientas de desarrollo.
