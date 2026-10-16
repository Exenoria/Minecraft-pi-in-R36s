#!/bin/bash
# Minecraft PE - DIAGNOSTICO (no usa PortMaster). Ejecutalo una vez desde Ports.
# Despues mira  minecraftpe/diagnostico.txt  (o diagnostico.txt junto a este script)

SCRIPTDIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd)"
GAMEDIR="$SCRIPTDIR/minecraftpe"
[ -d "$GAMEDIR" ] || GAMEDIR="/roms2/ports/minecraftpe"
OUT="$GAMEDIR/diagnostico.txt"
[ -d "$GAMEDIR" ] || OUT="$SCRIPTDIR/diagnostico.txt"

[ -w /dev/tty0 ] || sudo chmod 666 /dev/tty0 2>/dev/null
printf "\033c\n  Minecraft PE: diagnostico en curso (25 s)...\n" > /dev/tty0 2>/dev/null

{
  echo "=== DIAGNOSTICO $(date) ==="
  echo "script=$0 SCRIPTDIR=$SCRIPTDIR GAMEDIR=$GAMEDIR usuario=$(id -un) bash=$BASH_VERSION"
  uname -a
  grep -E "PRETTY_NAME" /etc/os-release
  ldd --version 2>&1 | head -1
  echo "--- contenido de la carpeta de ports"
  ls -la "$SCRIPTDIR"
  echo "--- contenido de la carpeta del juego"
  ls -la "$GAMEDIR"
  echo "--- binario"
  ls -la "$GAMEDIR/minecraftpe" 2>&1
  echo "cabecera ELF (debe empezar por 7f 45 4c 46 y tener b7 00 en la posicion 19-20):"
  head -c 20 "$GAMEDIR/minecraftpe" 2>/dev/null | od -An -tx1
  echo "--- montaje de la tarjeta (mira si dice noexec)"
  df -P "$GAMEDIR" 2>&1 | tail -1
  mount 2>&1 | grep -E "roms|ports" | head -5
  echo "--- librerias del binario"
  ldd "$GAMEDIR/minecraftpe" 2>&1
  echo "--- SDL2 del sistema"
  find /usr /lib -name 'libSDL2-2.0.so*' 2>/dev/null | head
  echo "--- pantalla / GPU"
  ls -la /dev/dri 2>&1
  cat /sys/class/graphics/fb0/virtual_size 2>&1
  ls /usr/lib/aarch64-linux-gnu 2>/dev/null | grep -iE 'mali|libgbm|libEGL|libGLES|libdrm' | head -12
  echo "--- PortMaster"
  ls -d /opt/system/Tools/PortMaster /opt/tools/PortMaster 2>&1
  echo "--- dmesg (ultimas lineas)"
  dmesg 2>/dev/null | tail -8
} > "$OUT" 2>&1

{
  echo
  echo "=== EJECUCION DEL JUEGO (maximo 20 s) ==="
  if [ -f "$GAMEDIR/minecraftpe" ]; then
    cd "$GAMEDIR" && chmod +x ./minecraftpe 2>/dev/null
    MCPE_HOME="$GAMEDIR" MCPE_SAVE="$GAMEDIR/savedata" timeout 20 ./minecraftpe 2>&1
    echo "codigo de salida: $?  (124 = seguia funcionando cuando se corto a los 20 s)"
  else
    echo "NO HAY archivo minecraftpe en $GAMEDIR"
  fi
} >> "$OUT" 2>&1

sync
printf "\033c" > /dev/tty0 2>/dev/null
