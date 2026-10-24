#!/usr/bin/env bash
# DLSS Unlocked - install / upgrade / uninstall helper for the standalone zip (Linux / Proton).
set -eu

usage() {
    cat <<'EOF'
Usage: bash install.sh <install|upgrade|uninstall> <game_exe_dir> [options]

  install, upgrade   Copy this package into the game folder (next to the game .exe).
                     Files from a previous install are removed first, so no stale files remain.
  uninstall          Remove everything a previous install added and restore backed-up files.

Options:
  --proxy dxgi|version|winmm   DLL name OptiScaler is installed as (default: dxgi)
  --repatch                    Also install the patched REFramework as dinput8.dll (RE Engine games)
  --reset-config               Overwrite an existing OptiScaler.ini (kept by default on upgrade)
EOF
}

die() { echo "error: $*" >&2; exit 1; }

[ $# -ge 1 ] && { [ "$1" = -h ] || [ "$1" = --help ]; } && { usage; exit 0; }
[ $# -ge 2 ] || { usage >&2; exit 1; }

cmd=$1; game=$2; shift 2
proxy=dxgi; repatch=0; reset=0
while [ $# -gt 0 ]; do
    case $1 in
        --proxy) [ $# -ge 2 ] || die "--proxy needs a value"; proxy=$2; shift ;;
        --repatch) repatch=1 ;;
        --reset-config) reset=1 ;;
        *) die "unknown option: $1" ;;
    esac
    shift
done
case $proxy in dxgi|version|winmm) ;; *) die "--proxy must be dxgi, version or winmm" ;; esac
case $cmd in install|upgrade|uninstall) ;; *) die "unknown command: $cmd" ;; esac
[ -d "$game" ] || die "game folder not found: $game"

src=$(cd "$(dirname "$0")" && pwd)
game=$(cd "$game" && pwd)
manifest="$game/.dlss-unlocked.manifest"
bak=.dlss-unlocked.bak

remove_old() { # delete files listed in the manifest; restore backups when $1 = restore
    [ -f "$manifest" ] || return 0
    while IFS= read -r f; do
        [ -n "$f" ] || continue
        [ "$f" = OptiScaler.ini ] && [ "$1" = keep-ini ] && continue
        rm -f "$game/$f"
        [ "$1" = restore ] && [ -e "$game/$f$bak" ] && mv "$game/$f$bak" "$game/$f"
    done <"$manifest"
    # drop directories left empty, deepest first
    while IFS= read -r f; do
        d=$(dirname "$f")
        while [ "$d" != . ]; do echo "$d"; d=$(dirname "$d"); done
    done <"$manifest" | sort -ru | while IFS= read -r d; do rmdir "$game/$d" 2>/dev/null || true; done
}

if [ "$cmd" = uninstall ]; then
    [ -f "$manifest" ] || die "nothing to uninstall (no $manifest)"
    remove_old restore
    rm -f "$manifest"
    echo "Uninstalled from $game"
    exit 0
fi

remove_old "$([ $reset = 1 ] && echo none || echo keep-ini)"
new=$(mktemp); trap 'rm -f "$new"' EXIT

while IFS= read -r -d '' path; do
    rel=${path#"$src"/}
    case $rel in
        install.sh) continue ;;
        dxgi.dll) dest=$proxy.dll ;;
        REPatch/dinput8.dll) [ $repatch = 1 ] || continue; dest=dinput8.dll ;;
        REPatch/*) continue ;;
        *) dest=$rel ;;
    esac
    echo "$dest" >>"$new"
    if [ -e "$game/$dest" ]; then
        # kept config from a previous install stays as is
        [ "$dest" = OptiScaler.ini ] && [ -f "$manifest" ] && [ $reset = 0 ] && continue
        mv -n "$game/$dest" "$game/$dest$bak" # someone else's file: back it up
    fi
    mkdir -p "$game/$(dirname "$dest")"
    cp "$path" "$game/$dest"
done < <(find "$src" -type f -print0)

[ -s "$new" ] || die "no payload found next to install.sh"
mv "$new" "$manifest"

echo "Installed to $game (proxy: $proxy.dll)"
echo "Steam launch options:"
echo "  WINEDLLOVERRIDES=\"$proxy=n,b\" PROTON_ENABLE_NVAPI=1 PROTON_NVIDIA_NVCUDA=1 %command%"
