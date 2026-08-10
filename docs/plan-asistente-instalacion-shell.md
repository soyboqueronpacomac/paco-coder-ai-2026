# Plan: Asistente de instalación de shell en README

## Contexto

El `README.md` del proyecto necesita una sección que guíe al usuario a través de un asistente de instalación de shell. Actualmente el repositorio no tiene documentación de instalación ni script asociado. Este documento solo planifica la funcionalidad; no se implementa código todavía.

Este plan es independiente del asistente de instalación de emuladores de terminal (ver `docs/plan-asistente-instalacion-terminal.md`): ambos coexisten como asistentes separados.

## Objetivo

Añadir al `README.md` una sección que documente un asistente de instalación capaz de:

- Detectar el shell actual del usuario leyendo la variable de entorno `$SHELL`.
- Mostrarle al usuario qué shell se ha detectado.
- Preguntarle si quiere mantener el shell detectado o instalar/configurar otro de los soportados.

## Mecanismo propuesto

- Un script `scripts/install-shell.sh`, referenciado desde el `README.md`, que implementa la detección y el menú de elección.
- El `README.md` documenta cómo invocar el script (p. ej. `./scripts/install-shell.sh`) y qué esperar de su ejecución.

## Shells soportados

- zsh
- bash
- fish

## Restricciones / alcance

- Esta tarea es solo de planificación: no se escribe `scripts/install-shell.sh` ni se modifica `README.md` todavía.
- El script deberá limitarse a detectar y ofrecer instalación/configuración del shell; no debe mezclar responsabilidades de instalación de otras dependencias del proyecto, incluido el asistente de emuladores de terminal.

## Próximos pasos (TODO)

- [ ] Diseñar el flujo exacto de preguntas del script (qué se pregunta primero, qué pasa si el shell detectado no está en la lista soportada).
- [ ] Definir cómo se instala/configura cada shell soportado (gestor de paquetes por sistema operativo).
- [ ] Implementar `scripts/install-shell.sh`.
- [ ] Añadir la sección correspondiente al `README.md`.
- [ ] Probar el asistente en macOS con zsh, bash y fish.
