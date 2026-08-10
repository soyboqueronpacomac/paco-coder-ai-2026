#!/usr/bin/env bash
set -uo pipefail
export LC_NUMERIC=C

ANCHO_BARRA=20
CARACTER_LLENO="█"
CARACTER_VACIO="░"
ETIQUETA_NO_DISPONIBLE="n/d (requiere Claude Pro/Max)"

entrada="$(cat)"

repetir() {
  local caracter="$1" veces="$2"
  if [[ "$veces" -le 0 ]]; then
    return 0
  fi
  printf "%.0s${caracter}" $(seq 1 "$veces")
}

renderizar_barra() {
  local etiqueta="$1" porcentaje="$2"
  if [[ -z "$porcentaje" || "$porcentaje" == "null" ]]; then
    printf '%s [%s]\n' "$etiqueta" "$ETIQUETA_NO_DISPONIBLE"
    return 0
  fi

  local llenos vacios
  llenos=$(awk -v p="$porcentaje" -v a="$ANCHO_BARRA" 'BEGIN { l = int((p / 100) * a + 0.5); if (l > a) l = a; if (l < 0) l = 0; print l }')
  vacios=$((ANCHO_BARRA - llenos))
  printf '%s [%s%s] %5.1f%%\n' "$etiqueta" "$(repetir "$CARACTER_LLENO" "$llenos")" "$(repetir "$CARACTER_VACIO" "$vacios")" "$porcentaje"
}

formatear_reseteo() {
  local etiqueta="$1" epoch="$2"
  if [[ -z "$epoch" || "$epoch" == "null" ]]; then
    printf '%s: n/d\n' "$etiqueta"
    return 0
  fi

  local fecha_reseteo fecha_hoy hora_reseteo dia_semana
  fecha_reseteo=$(jq -rn --argjson e "$epoch" '$e | localtime | strftime("%Y-%m-%d")' 2>/dev/null) || true
  fecha_hoy=$(date +%Y-%m-%d)
  hora_reseteo=$(jq -rn --argjson e "$epoch" '$e | localtime | strftime("%H:%M")' 2>/dev/null) || true

  if [[ -z "$fecha_reseteo" || -z "$hora_reseteo" ]]; then
    printf '%s: n/d\n' "$etiqueta"
  elif [[ "$fecha_reseteo" == "$fecha_hoy" ]]; then
    printf '%s: %s (hoy)\n' "$etiqueta" "$hora_reseteo"
  else
    dia_semana=$(jq -rn --argjson e "$epoch" '$e | localtime | strftime("%A %d/%m")' 2>/dev/null) || true
    printf '%s: %s (%s)\n' "$etiqueta" "$hora_reseteo" "${dia_semana:-$fecha_reseteo}"
  fi
}

contexto_pct=$(jq -r '.context_window.used_percentage // empty' <<< "$entrada" 2>/dev/null) || true
sesion_pct=$(jq -r '.rate_limits.five_hour.used_percentage // empty' <<< "$entrada" 2>/dev/null) || true
sesion_reset=$(jq -r '.rate_limits.five_hour.resets_at // empty' <<< "$entrada" 2>/dev/null) || true
semanal_pct=$(jq -r '.rate_limits.seven_day.used_percentage // empty' <<< "$entrada" 2>/dev/null) || true
semanal_reset=$(jq -r '.rate_limits.seven_day.resets_at // empty' <<< "$entrada" 2>/dev/null) || true

renderizar_barra "Sesión (5h) " "$sesion_pct"
renderizar_barra "Semanal (7d)" "$semanal_pct"
renderizar_barra "Contexto    " "$contexto_pct"
formatear_reseteo "Reset sesión " "$sesion_reset"
formatear_reseteo "Reset semanal" "$semanal_reset"

exit 0
