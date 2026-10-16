#!/bin/bash
# Minecraft Pocket Edition (Pi Edition) - port nativo para R36S / PortMaster
# Este archivo y la carpeta "minecraftpe" van JUNTOS en /roms2/ports/

SCRIPTDIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd)"
# Miga de pan: si existe minecraftpe_boot.txt, este lanzador SI se ejecuto
BOOT="$SCRIPTDIR/minecraftpe_boot.txt"
echo "$(date) - lanzador iniciado en: $SCRIPTDIR" > "$BOOT" 2>/dev/null

XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}

if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
elif [ -d "$XDG_DATA_HOME/PortMaster/" ]; then
  controlfolder="$XDG_DATA_HOME/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

source $controlfolder/control.txt
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls

# Carpeta del juego: junto a este script; si no, por $directory; si no, /roms2
GAMEDIR="$SCRIPTDIR/minecraftpe"
[ -d "$GAMEDIR" ] || GAMEDIR="/$directory/ports/minecraftpe"
[ -d "$GAMEDIR" ] || GAMEDIR="/roms2/ports/minecraftpe"
echo "GAMEDIR=$GAMEDIR  directory=$directory  CFW=$CFW_NAME  arch=$DEVICE_ARCH" >> "$BOOT" 2>/dev/null

if ! cd "$GAMEDIR"; then
  echo "ERROR: no existe la carpeta del juego: $GAMEDIR" >> "$BOOT"
  exit 1
fi

# todo lo que escribe el juego va a log.txt (se sobrescribe en cada arranque)
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# mensajes en pantalla (para no quedarse con la pantalla negra sin saber por que)
[ -w /dev/tty0 ] || $ESUDO chmod 666 /dev/tty0 2>/dev/null
msg() { echo "$1"; printf "\033c\n  %s\n" "$1" > /dev/tty0 2>/dev/null; }
finish() {
  sync
  if type pm_finish >/dev/null 2>&1; then pm_finish; fi
  printf "\033c" > /dev/tty0 2>/dev/null
}

echo "=== Minecraft PE (R36S) $(date) ==="
echo "GAMEDIR=$GAMEDIR directory=$directory CFW=$CFW_NAME arch=$DEVICE_ARCH usuario=$(id -un)"
echo "kernel: $(uname -srm)"
echo "glibc: $(ldd --version 2>&1 | head -1)"
echo "binario: $(ls -la "$GAMEDIR/minecraftpe" 2>&1)"
echo "montaje: $(df -P "$GAMEDIR" 2>/dev/null | tail -1)"
echo "SDL2: $(ls /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so* /usr/lib/libSDL2-2.0.so* 2>/dev/null | tr '\n' ' ')"
echo "dri: $(ls /dev/dri 2>&1 | tr '\n' ' ')"

if [ ! -f "$GAMEDIR/minecraftpe" ]; then
  msg "FALTA el archivo minecraftpe en $GAMEDIR"
  echo "Copia el binario compilado (sin extension) a esa carpeta, junto a 'data'."
  sleep 8
  finish
  exit 1
fi

export MCPE_HOME="$GAMEDIR"
export MCPE_SAVE="$GAMEDIR/savedata"
export LD_LIBRARY_PATH="$GAMEDIR/libs.aarch64:$LD_LIBRARY_PATH"
[ -n "$sdl_controllerconfig" ] && export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

$ESUDO chmod +x "$GAMEDIR/minecraftpe"
echo "librerias que faltan: $(ldd "$GAMEDIR/minecraftpe" 2>&1 | grep -i 'not found' | tr '\n' ' ')"
if type pm_platform_helper >/dev/null 2>&1; then pm_platform_helper "$GAMEDIR/minecraftpe" >/dev/null 2>&1; fi

msg "Minecraft PE: iniciando..."
"$GAMEDIR/minecraftpe"
RC=$?
echo "minecraftpe termino con codigo: $RC"
if [ "$RC" -ne 0 ]; then
  msg "Minecraft PE fallo (codigo $RC). Mira minecraftpe/log.txt en la SD"
  sleep 8
fi

finish
