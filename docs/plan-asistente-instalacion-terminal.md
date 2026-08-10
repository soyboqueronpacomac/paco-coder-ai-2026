# Plan: Asistente de instalación de emuladores de terminal en README

## Contexto

El `README.md` del proyecto necesita una sección que guíe al usuario a través de un asistente de instalación de emuladores de terminal. Actualmente el repositorio no tiene documentación de instalación ni script asociado. Este documento solo planifica la funcionalidad; no se implementa código todavía.

Este plan es independiente del asistente de instalación de shell (ver `docs/plan-asistente-instalacion-shell.md`): ambos coexisten como asistentes separados.

## Objetivo

Añadir al `README.md` una sección que documente un asistente de instalación capaz de:

- Detectar el emulador de terminal actual del usuario (cuando sea posible detectarlo).
- Mostrarle al usuario qué emulador se ha detectado.
- Preguntarle si quiere mantener el emulador detectado o instalar otro de los soportados.

## Mecanismo propuesto

- Un script `scripts/install-terminal.sh`, referenciado desde el `README.md`, que implementa la detección y el menú de elección.
- El `README.md` documenta cómo invocar el script (p. ej. `./scripts/install-terminal.sh`) y qué esperar de su ejecución.

## Emuladores soportados

- Alacritty
- Kitty
- WezTerm
- Hyper
- Ghostty

Todos multiplataforma (macOS/Linux, con soporte de Windows variable según el emulador).

## Restricciones / alcance

- Esta tarea es solo de planificación: no se escribe `scripts/install-terminal.sh` ni se modifica `README.md` todavía.
- El script deberá limitarse a detectar y ofrecer instalación del emulador de terminal; no debe mezclar responsabilidades de instalación de otras dependencias del proyecto, incluido el asistente de shell.

## Próximos pasos (TODO)

- [ ] Diseñar el flujo exacto de preguntas del script (qué se pregunta primero, qué pasa si el emulador detectado no está en la lista soportada).
- [ ] Definir cómo se detecta el emulador de terminal actual en cada sistema operativo (variables de entorno como `TERM_PROGRAM`, procesos padre, etc.).
- [ ] Definir cómo se instala cada emulador soportado (gestor de paquetes por sistema operativo: Homebrew, apt, winget, etc.).
- [ ] Implementar `scripts/install-terminal.sh`.
- [ ] Añadir la sección correspondiente al `README.md`.
- [ ] Probar el asistente en macOS con al menos dos de los emuladores soportados.
