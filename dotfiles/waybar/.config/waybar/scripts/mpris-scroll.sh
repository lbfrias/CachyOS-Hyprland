#!/usr/bin/env bash
# --------------------------------------
# Waybar Custom MPRIS Module with Infinite Scrolling + Proper Dot Spacing
# (Hide only when all players stopped)
# --------------------------------------

SCROLL_SPEED=${1:-0.2}
VISIBLE_CHARS=${2:-30}

declare -A ICONS=( ["spotify"]="󰓇" )
DEFAULT_ICON="󰎈"

declare -A STATUS_ICONS=(
  ["Playing"]="󰏤"
  ["Paused"]="󰐊"
  ["Stopped"]="󰓛"
)

escape_pango() {
  local input="$1"
  input="${input//&/&amp;}"
  input="${input//</&lt;}"
  input="${input//>/&gt;}"
  input="${input//\"/&quot;}"
  echo "$input"
}

format_time() {
  local total=$1
  local h=$((total / 3600))
  local m=$(( (total % 3600) / 60 ))
  local s=$((total % 60))
  if (( h > 0 )); then
    printf "%d:%02d:%02d" "$h" "$m" "$s"
  else
    printf "%02d:%02d" "$m" "$s"
  fi
}

stop_scroller() { pkill -P $$ >/dev/null 2>&1 || true; }
reset_state() { last_meta=""; last_player=""; }

last_meta=""
last_player=""

while true; do
  mapfile -t players < <(playerctl -l 2>/dev/null)
  mapfile -t statuses < <(playerctl -a status 2>/dev/null)

  # 🧩 Determine which player to show
  chosen_player=""

  # 1️⃣ Prefer a Playing player
  for i in "${!players[@]}"; do
    if [[ "${statuses[$i]}" == "Playing" ]]; then
      chosen_player="${players[$i]}"
      break
    fi
  done

  # 2️⃣ If none playing, fallback to last known (if still active)
  if [[ -z "$chosen_player" && -n "$last_player" ]]; then
    for i in "${!players[@]}"; do
      if [[ "${players[$i]}" == "$last_player" && "${statuses[$i]}" != "Stopped" ]]; then
        chosen_player="$last_player"
        break
      fi
    done
  fi

  # 3️⃣ If still none, pick the first active (Paused or Playing)
  if [[ -z "$chosen_player" ]]; then
    for i in "${!players[@]}"; do
      if [[ "${statuses[$i]}" != "Stopped" ]]; then
        chosen_player="${players[$i]}"
        break
      fi
    done
  fi

  # 🧱 Hide completely only if all players are stopped
  all_stopped=1
  for s in "${statuses[@]}"; do
    [[ "$s" != "Stopped" ]] && all_stopped=0 && break
  done
  if (( all_stopped )); then
    stop_scroller
    reset_state
    echo '{"text": ""}'
    sleep 2
    continue
  fi

  # Nothing valid selected
  if [[ -z "$chosen_player" ]]; then
    stop_scroller
    reset_state
    echo '{"text": ""}'
    sleep 2
    continue
  fi

  player="$chosen_player"

  artist=$(playerctl -p "$player" metadata artist 2>/dev/null)
  title=$(playerctl -p "$player" metadata title 2>/dev/null)
  album=$(playerctl -p "$player" metadata album 2>/dev/null)
  status=$(playerctl -p "$player" status 2>/dev/null)

  meta_parts=()
  [[ -n "$title" ]]  && meta_parts+=("$title")
  [[ -n "$artist" ]] && meta_parts+=("$artist")
  [[ -n "$album" ]]  && meta_parts+=("$album")

  if ((${#meta_parts[@]} == 0)); then
    stop_scroller
    reset_state
    echo '{"text": ""}'
    sleep 2
    continue
  fi

  meta=$(printf ' - %s' "${meta_parts[@]}")
  meta=${meta:3}

  if [[ "$meta" != "$last_meta" || "$player" != "$last_player" ]]; then
    last_meta="$meta"
    last_player="$player"

    stop_scroller
    icon=${ICONS[$player]:-$DEFAULT_ICON}
    tooltip=$(escape_pango "$meta")

    scroll_text="$meta • "
    scroll_len=${#scroll_text}
    scroll_pos=0

    while true; do
      status=$(playerctl -p "$player" status 2>/dev/null)
      [[ "$status" == "Stopped" ]] && break

      # Visible segment logic
      if (( VISIBLE_CHARS == 0 || ${#meta} <= VISIBLE_CHARS )); then
        segment="$meta"
      else
        if (( scroll_pos + VISIBLE_CHARS <= scroll_len )); then
          segment="${scroll_text:scroll_pos:VISIBLE_CHARS}"
        else
          part1="${scroll_text:scroll_pos}"
          part2="${scroll_text:0:VISIBLE_CHARS - ${#part1}}"
          segment="$part1$part2"
        fi
      fi

      pos=$(playerctl -p "$player" position 2>/dev/null | awk '{printf "%.0f", $1}')
      pos=${pos:-0}

      raw_len=$(playerctl -p "$player" metadata mpris:length 2>/dev/null)
      raw_len=${raw_len:-0}
      len=$(( raw_len / 1000000 ))
      is_live=0
      [[ "$raw_len" == "9223372036854775807" || "$raw_len" == "18446744073709551615" ]] && is_live=1

      status_icon=${STATUS_ICONS[$status]:-${STATUS_ICONS[Stopped]}}
      if (( is_live )); then
        footer="$status_icon 🔴 Live"
      else
        footer="$status_icon $(format_time "$pos")/$(format_time "$len")"
      fi

      echo "{\"text\": \"$(escape_pango "$icon $segment")\\n$(escape_pango "$footer")\", \"tooltip\": \"$tooltip\"}"

      if (( VISIBLE_CHARS > 0 && ${#meta} > VISIBLE_CHARS )); then
        ((scroll_pos++))
        ((scroll_pos = scroll_pos % scroll_len))
      fi

      sleep "$SCROLL_SPEED"
    done &
  fi

  sleep 1
done
