# Plan: Script wrapper install.sh para los asistentes de instalación

## Contexto

Ya existen dos asistentes de instalación independientes: `scripts/install-shell.sh` (issue #1) y `scripts/install-terminal.sh` (issue #2). Ambos planes previos establecen explícitamente que no deben mezclar responsabilidades entre sí.

El usuario quiere comodidad de "un solo comando" sin romper esa separación. La solución acordada es un script fino `scripts/install.sh` que actúa como punto de entrada único, invocando a los scripts existentes sin duplicar ni mezclar su lógica interna.

## Objetivo

Añadir `scripts/install.sh` que:

- Muestra un menú preguntando al usuario qué quiere configurar: shell, emulador de terminal, o ambos.
- Según la elección, invoca `scripts/install-shell.sh`, `scripts/install-terminal.sh`, o ambos en secuencia.
- No reimplementa la lógica de detección/instalación de cada asistente: solo delega en los scripts existentes.

## Mecanismo propuesto

- `scripts/install.sh` presenta un menú (p. ej. `shell` / `terminal` / `ambos`).
- Según la respuesta, ejecuta el/los script(s) correspondiente(s) con `./scripts/install-shell.sh` y/o `./scripts/install-terminal.sh`.
- El `README.md` se actualiza para documentar `scripts/install.sh` como el punto de entrada recomendado, dejando también documentados los scripts individuales para uso directo.

## Restricciones / alcance

- Esta tarea es solo de planificación: no se escribe `scripts/install.sh` ni se modifica `README.md` todavía.
- El wrapper no debe duplicar lógica de detección de shell ni de emuladores de terminal; su única responsabilidad es orquestar la llamada a los scripts existentes.
- No se modifican `scripts/install-shell.sh` ni `scripts/install-terminal.sh`.

## Próximos pasos (TODO)

- [ ] Diseñar el texto exacto del menú y las opciones válidas.
- [ ] Definir qué pasa si uno de los dos scripts invocados falla (¿se detiene el wrapper o continúa con el siguiente?).
- [ ] Implementar `scripts/install.sh`.
- [ ] Actualizar `README.md` para documentar el nuevo punto de entrada.
- [ ] Probar el wrapper en macOS con las tres opciones del menú (shell, terminal, ambos).
