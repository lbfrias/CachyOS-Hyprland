#!/usr/bin/env bash
# --------------------------------------
# Waybar MPRIS Album Art (Hide only when all players stopped)
# --------------------------------------

ART_DIR="/tmp/waybar_mpris_art"
mkdir -p "$ART_DIR"
LAST_PLAYER_FILE="$ART_DIR/last_player"

escape_pango() {
    local input="$1"
    input="${input//&/&amp;}"
    input="${input//</&lt;}"
    input="${input//>/&gt;}"
    input="${input//\"/&quot;}"
    echo "$input"
}

sanitize() { echo "$1" | tr -c '[:alnum:]' '_'; }
hash_string() { echo -n "$1" | md5sum | awk '{print $1}'; }

# --- Detect players and statuses ---
mapfile -t players < <(playerctl -l 2>/dev/null)
mapfile -t statuses < <(playerctl -a status 2>/dev/null)

declare -A current_cache_files
declare -A player_to_file

# --- Build cache for each active player ---
for i in "${!players[@]}"; do
    player="${players[$i]}"
    status="${statuses[$i]}"

    # Skip stopped players and clear old art
    if [[ "$status" == "Stopped" ]]; then
        find "$ART_DIR" -type f -name "$(sanitize "$player")_*" -delete
        continue
    fi

    title=$(playerctl -p "$player" metadata title 2>/dev/null)
    artist=$(playerctl -p "$player" metadata artist 2>/dev/null)
    album=$(playerctl -p "$player" metadata album 2>/dev/null)
    art_url=$(playerctl -p "$player" metadata mpris:artUrl 2>/dev/null)

    [[ -z "$art_url" ]] && continue

    meta_parts=()
    [[ -n "$title" ]] && meta_parts+=("$title")
    [[ -n "$artist" ]] && meta_parts+=("$artist")
    [[ -n "$album" ]] && meta_parts+=("$album")

    tooltip=$(printf ' - %s' "${meta_parts[@]}")
    tooltip=${tooltip:3}
    tooltip=$(escape_pango "$tooltip")

    track_hash=$(hash_string "$title$artist$album$art_url")
    safe_player=$(sanitize "$player")
    cached_file="$ART_DIR/${safe_player}_${track_hash}.png"

    if [[ ! -f "$cached_file" ]]; then
        tmpfile=$(mktemp "$ART_DIR/tmp.XXXXXX")
        curl -sSL "$art_url" -o "$tmpfile" && mv "$tmpfile" "$cached_file"
    fi

    current_cache_files["$cached_file"]="$tooltip"
    player_to_file["$player"]="$cached_file"
done

# --- Clean up unused cache ---
shopt -s nullglob
for f in "$ART_DIR"/*.png; do
    [[ -z "${current_cache_files[$f]}" ]] && rm -f "$f"
done
shopt -u nullglob

# --- Determine which player to show ---
last_player=""
[[ -f "$LAST_PLAYER_FILE" ]] && last_player=$(<"$LAST_PLAYER_FILE")

chosen_player=""

# 1️⃣ Prefer first player that is Playing
for i in "${!players[@]}"; do
    player="${players[$i]}"
    status="${statuses[$i]}"
    if [[ "$status" == "Playing" ]]; then
        chosen_player="$player"
        break
    fi
done

# 2️⃣ If none playing, fallback to last known if still active
if [[ -z "$chosen_player" && -n "$last_player" ]]; then
    for i in "${!players[@]}"; do
        if [[ "${players[$i]}" == "$last_player" && "${statuses[$i]}" != "Stopped" ]]; then
            chosen_player="$last_player"
            break
        fi
    done
fi

# 3️⃣ Otherwise, use first player with metadata/art
if [[ -z "$chosen_player" ]]; then
    for player in "${players[@]}"; do
        [[ -n "${player_to_file[$player]}" ]] && { chosen_player="$player"; break; }
    done
fi

# 🧩 NEW: hide completely only if all players are stopped
all_stopped=1
for s in "${statuses[@]}"; do
    [[ "$s" != "Stopped" ]] && all_stopped=0 && break
done
if (( all_stopped )); then
    echo -e "\n"
    exit 0
fi

# --- Save and output ---
[[ -n "$chosen_player" ]] && echo "$chosen_player" > "$LAST_PLAYER_FILE"

if [[ -n "$chosen_player" ]]; then
    file="${player_to_file[$chosen_player]}"
    tooltip="${current_cache_files[$file]}"
    echo -e "$file\n$tooltip"
else
    echo -e "\n"
fi
