# Plan: StatusLine de barras de progreso de tokens para Claude Code

## Contexto

El usuario quiere, debajo del área de chat de Claude Code (CLI), un `statusLine` personalizado con:

1. Barra de progreso del % de tokens de sesión (ventana de 5 horas) hasta que se resetea.
2. Barra de progreso del % de tokens semanales (ventana de 7 días) hasta que se resetea.
3. Barra de progreso del % de la ventana de contexto usada en la conversación actual.
4. Debajo de las barras, la hora exacta de reseteo de cada límite (sesión y semanal), indicando el día si el reseteo cae en una fecha distinta a hoy.

Se confirmó la viabilidad técnica consultando la documentación oficial de `statusLine` de Claude Code (v2.1.90+):

- El script de `statusLine` recibe un JSON por stdin con, entre otros, los campos `context_window.used_percentage` (siempre disponible tras la 1ª llamada API), y `rate_limits.five_hour` / `rate_limits.seven_day`, cada uno con `used_percentage` y `resets_at` (Unix epoch).
- `rate_limits` **solo está presente en suscripciones Claude.ai Pro/Max** — ausente en API keys de terceros (Bedrock/Vertex/Foundry) y en el plan gratuito. El script debe degradar con gracia si faltan esos campos.
- `context_window` puede ser `null` antes de la primera llamada a la API y de nuevo tras `/compact`, hasta la siguiente llamada.
- El `statusLine` admite salida multilínea: cada `echo` del script produce una fila distinta en el área de estado, sin límite documentado de líneas.

Este documento planifica el alcance; no se implementa código todavía.

## Diseño

### 1. Nuevo `scripts/statusline.sh`

Script bash + `jq` (coherente con la preferencia del usuario de usar `jq` para datos), invocado por Claude Code con el JSON de contexto por stdin. Responsabilidades:

- Leer y parsear el JSON de entrada con `jq`, con manejo defensivo de campos ausentes (`// empty`, `// 0`).
- Calcular y renderizar 3 barras de progreso (ancho fijo, caracteres tipo `█`/`░`) para: sesión (5h), semanal (7d) y contexto.
- Si `rate_limits.five_hour` o `rate_limits.seven_day` no están presentes (cuenta no Pro/Max, o aún sin primera respuesta), sustituir esa barra por un indicador de "no disponible" en vez de omitirla silenciosamente o fallar.
- Convertir `resets_at` (epoch) a hora local legible, e indicar si el reseteo es "hoy" o el nombre/fecha del día siguiente cuando no coincide con la fecha actual.
- Imprimir 5 líneas: 3 de barras + 2 de horas de reseteo (sesión y semanal). Si `context_window` es `null`, mostrar la barra de contexto en un estado neutro en vez de romper el script.

### 2. Integración con el instalador (`scripts/install-ai-agents.sh`)

- Añadir una función `asegurar_jq()` (mismo patrón que `asegurar_gum()`/`asegurar_homebrew()`) que instale `jq` vía Homebrew si no está disponible.
- Al final de `instalar_claude_code()`, tras confirmar que `claude` está instalado, ofrecer registrar `scripts/statusline.sh` como `statusLine` en `~/.claude/settings.json`:
  - Fusión no destructiva con `jq` (leer el `settings.json` existente si existe, o partir de `{}`, y hacer merge de la clave `statusLine` sin tocar el resto de claves del usuario).
  - La ruta del script en `command` debe ser absoluta (resuelta desde `DIRECTORIO_SCRIPT`), para que funcione desde cualquier `cwd`.

### 3. Configuración visual

- Ancho de barra, caracteres de relleno y umbrales de color (si se usan colores ANSI) se definen como constantes al inicio de `scripts/statusline.sh`, no hardcodeadas dentro de la lógica de render.

## Restricciones / alcance

- `jq` pasa a ser una dependencia nueva del instalador (antes `install-ai-agents.sh` no dependía de él); debe instalarse igual que `gum`, con verificación previa (`asegurar_jq`).
- No se sobrescribe un `~/.claude/settings.json` existente del usuario: solo se fusiona/añade la clave `statusLine`.
- El script debe funcionar sin romperse cuando falten `rate_limits` (no Pro/Max) o `context_window` sea `null` — nunca debe fallar con código de salida distinto de 0, ya que Claude Code lo ejecuta en cada render del prompt.
- Sigue las convenciones del repo: bash con `set -euo pipefail`, nombres de función en español, sin comentarios explicativos en el código, documentación en español.

## Archivos afectados

- Nuevo: `scripts/statusline.sh`.
- Modificado: `scripts/install-ai-agents.sh` (nueva función `asegurar_jq()`, y registro opcional del statusLine tras instalar Claude Code).
- Modificado: `README.md` (documentar el nuevo statusLine y qué muestra).

## Próximos pasos (TODO)

- [x] Definir el formato visual exacto de las barras (ancho en caracteres, caracteres de relleno, si se usan colores ANSI y sus umbrales) — barra de 20 caracteres `█`/`░`, sin color ANSI.
- [x] Implementar `scripts/statusline.sh` con `jq`, manejo defensivo de campos ausentes y de `null`.
- [x] Implementar la conversión de `resets_at` (epoch) a hora local + indicador de "hoy"/fecha distinta (vía `jq strftime`, `LC_NUMERIC=C` para evitar bugs de locale con decimales).
- [x] Añadir `asegurar_jq()` a `scripts/install-ai-agents.sh` y el registro no destructivo en `~/.claude/settings.json` tras `instalar_claude_code()`.
- [ ] Probar en una sesión real de Claude.ai Pro/Max para confirmar la aparición de `rate_limits` tras la primera respuesta (pendiente: requiere ejecución interactiva del usuario).
- [x] Probar el caso degradado: JSON sin `rate_limits` y `context_window` ausente/`null` (probado con JSON simulado, script nunca falla, exit code 0).
- [x] Documentar el statusLine en `README.md`.
