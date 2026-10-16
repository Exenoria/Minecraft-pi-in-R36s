# Minecraft-Pi-Edition-0.1.1-in-R36s
It is a native version of Minecraft for the R36S/es una versión de minecraft nativa para la r36s
# Clarification / English

This is made with non-premium Claude AI, so this could be considered vider code for being made with AI, I only compiled the binary to make the game work.
If you still want to ignore this, you can move on. The code comes from the leaked 2013 version of Minecraft Pocket Edition for both Android and iOS, by user Matt-SSMG64. Credit goes to him for archiving the game code ([https://github.com/SSMG64/PocketEdition](https://github.com/SSMG64/PocketEdition)).

## Credits and Acknowledgments

* **Original base code:** Minecraft: Pocket Edition (v0.6.1 / 0.6.2 - 2013)
* **Original developers:** Mojang Studios / Mojang AB
* **Trademark and intellectual property owner:** Microsoft Corporation / Mojang AB
* **Attribution notice:** This project modifies components of the historical version of Minecraft Pocket Edition for educational purposes, reverse engineering, and the creation of an unofficial version.
* **Modifications / Port:** Created by [Exenoria]

# Minecraft PE for R36S

This repository contains a Minecraft Pocket Edition port prepared to run on an R36S console via Ports/PortMaster. It includes the launchers, the `aarch64` game binary, resources, and the source code needed to compile it.

> The package is prepared for the R36S. There is no guarantee that the binary will work on other devices or systems.
> Open source code

---

# COMPILE ON PC (one-time only)

---

1. Install Docker (Windows/Mac: "Docker Desktop"; Linux: docker) and open it.
2. Open the `1_COMPILAR_EN_PC` folder and run:
Windows:             double-click `build.sh` (or `build.bat`) -> *[Note: use `build.bat` for Windows]*
Linux / Mac / WSL:   `./build.sh`
(the first time it downloads ~500 MB of tools; after that it takes a few
minutes).
3. Once finished, it creates the file:
`2_COPIAR_A_LA_CONSOLA/minecraftpe/minecraftpe`
(Alternative without Docker: the `.github/workflows/build-r36s.yml` file compiles on GitHub; or any aarch64 machine with `make CROSS=`.)

---

# COPY TO CONSOLE

---

## Copy the CONTENTS of the `2_COPIAR_A_LA_CONSOLA` folder, meaning:
`Minecraft PE.sh`
`minecraftpe/`         (with `data/`, `controls.cfg`, and the `minecraftpe` binary)
to the `/roms2/ports/` folder on your SD2. Reboot EmulationStation and
open **Ports > Minecraft PE**.

# COPY TO CONSOLE

---

Copy the CONTENTS of the `2_COPIAR_A_LA_CONSOLA` folder, meaning:
`Minecraft PE.sh`
`minecraftpe/`         (with `data/`, `controls.cfg`, and the `minecraftpe` binary)
to the `/roms2/ports/` folder on your SD2. Reboot EmulationStation and
open **Ports > Minecraft PE**.

---

# CONTROLS

---

IN-GAME
Left Stick .............. move
Right Stick ............. look
R2 (hold) ............... break blocks
L2 ...................... place block / use
A ....................... jump (double tap = fly; in flight, A goes up)
B ....................... sneak (in flight: go down)
X ....................... open/close inventory (choose blocks)
L1 / R1 (or D-pad <- ->) previous / next hotbar slot
Start ................... pause (Back to game / Quit to title)
Select + Start .......... exit game (saves world)

IN MENUS
D-pad up/down + A ........ navigate buttons and accept
Move a stick ............ cursor appears: A = click, B = back
Choose an existing world: move the cursor over the world and press A.
Inventory: move the cursor over a block and press A; it is placed in the
selected hotbar slot.

First time: Start Game > (Create new) create the world "world".

---

# SETTINGS (minecraftpe/controls.cfg - editable with any text editor)

---

```
look_speed       camera speed
deadzone         stick deadzone (increase if the camera "drifts on its own")
swap_ab          1 = swaps A and B (if jump/accept feels reversed)
swap_xy          1 = swaps X and Y
view_distance    0 far, 1 normal, 2 short (default), 3 minimum
                 (if it stutters, set to 3)

```

Worlds are saved in `minecraftpe/savedata/` (copy this folder to
make a backup).

---

# TROUBLESHOOTING

---

* Check `minecraftpe/log.txt`: everything the game writes is logged here.
If it doesn't boot, send this file to Claude along with what you saw.
* "minecraftpe binary missing": you didn't do STEP 1 or didn't copy the
`minecraftpe` file to the console.
* Swapped buttons: `swap_ab=1` / `swap_xy=1` in `controls.cfg`.
* No sound: in `log.txt` look for the line starting with "Audio:".

IF IT DOES NOT OPEN (black screen)

1. Open Minecraft PE once and eject the SD card. Check on your PC:
`/roms2/ports/minecraftpe_boot.txt`  -> if it exists, the launcher DID run
`/roms2/ports/minecraftpe/log.txt`    -> everything that happened inside the game
2. If there is nothing or it remains black: open **Ports > "Minecraft PE DIAG"** (takes about
25 seconds) and send me the file `minecraftpe/diagnostico.txt`

# Installation

COPY THESE 3 ITEMS to SD2, inside the `/roms2/ports/` folder:
`Minecraft PE.sh`
`Minecraft PE DIAG.sh`
`minecraftpe/`            (full folder)

It must look EXACTLY like this on the card:
`/roms2/ports/Minecraft PE.sh`
`/roms2/ports/Minecraft PE DIAG.sh`
`/roms2/ports/minecraftpe/minecraftpe`        <- the game (no extension: this is normal)
`/roms2/ports/minecraftpe/controls.cfg`
`/roms2/ports/minecraftpe/data/...`

# Source Code Guide

The C++ code is in `minecraftpe/data/src/`; graphic and language resources are in `minecraftpe/data/images/` and `minecraftpe/data/lang/`. The R36S package compilation defines `R36S_PORT` and uses SDL2.

### Execution Flow

1. `src/main.cpp` is the compilation entry point. Depending on platform macros, it includes the appropriate implementation; for `R36S_PORT`, it selects `src/main_sdl2.h`.
2. `main_sdl2.h` changes to the game directory, reads `controls.cfg`, initializes SDL2 and the graphics context, loads the GLES 1 emulation over GLES 2, and opens the gamepad.
3. The SDL layer creates a `NinecraftApp` instance, configures data paths, and enters the main loop. Each iteration processes events, converts gamepad inputs into game keyboard/mouse inputs, and calls `update()`.
4. `NinecraftApp` initializes block, item, and biome registries, configures language, graphics, and storage, and delegates the common cycle to `Minecraft`.
5. `Minecraft::update()` processes network events, runs simulation ticks, and updates lighting, sound, and rendering. Upon exit, the SDL layer saves the active level.

### Main Modules

* `src/client/`: client application state and logic; options, player, game modes, UI, particles, and renderer.
* `src/world/`: entities, items, inventory, physics, levels, blocks, and world storage.
* `src/network/` and `src/raknet/`: packets, connections, and network/multiplayer event handling.
* `src/server/`: server components and server world players.
* `src/platform/`: platform abstractions, clock, registries, audio, and input. The specific R36S adaptation is mainly in `main_sdl2.h`.
* `src/locale/` and `src/nbt/`: language loading and NBT data types/parsing.
* `src/gles1_shim.cpp` and `src/gles1_shim.h`: GLES 1 call compatibility over the GLES 2 context used by the port.
* `src/NinecraftApp.cpp` and `src/client/Minecraft.cpp`: application initialization and shared game cycle, respectively.

### Where to Start Making Changes

* Gamepad controls, SDL events, graphics context, or `controls.cfg` reading: `src/main_sdl2.h`.
* Port initialization, saving, or lifecycle: `src/NinecraftApp.cpp`.
* Ticks, options, world selection, and client flow: `src/client/Minecraft.cpp` and `src/client/Minecraft.h`.
* World and entity rendering: `src/client/renderer/`.
* Game rules, blocks, entities, or physics: look first for the corresponding component under `src/world/`.
* Compilation: `sources.txt` lists the `.cpp` files that the `Makefile` turns into objects. If you add a new `.cpp`, include it there.

The `Makefile` does not generate automatic header dependencies. After changing a `.h` file, run `make clean` before compiling to ensure that objects including it are rebuilt.

## Installation on the R36S

1. Unpack the package on your computer.
2. Copy these items directly to `/roms2/ports/` on the SD card:
* `Minecraft PE.sh`
* `Minecraft PE DIAG.sh`
* The complete `minecraftpe/` folder


3. Verify the paths look like this:
```text
/roms2/ports/Minecraft PE.sh
/roms2/ports/Minecraft PE DIAG.sh
/roms2/ports/minecraftpe/minecraftpe
/roms2/ports/minecraftpe/controls.cfg
/roms2/ports/minecraftpe/data/...

```


4. Copy the package's contents, not an extra parent container folder.
5. Reboot EmulationStation and open **Ports > Minecraft PE**.

If you edit any of the `.sh` files on Windows, save them with Unix line endings (LF). CRLF endings can prevent the launcher from running.

## Controls and Settings

Controls depend on the system/PortMaster configuration and the game. Settings specific to this package are in `minecraftpe/controls.cfg`; they can be changed with a text editor and do not require recompilation.

* `look_speed`: camera turning speed with the right stick.
* `cursor_speed`: cursor speed in menus.
* `deadzone`: stick deadzone. Increase it if the character or camera moves without touching the stick. The recommended range in the file is from `0.05` to `0.5`.
* `swap_ab`: swaps A and B (`1` enabled, `0` disabled).
* `swap_xy`: swaps X and Y (`1` enabled, `0` disabled).
* `view_distance`: render distance: `0` far, `1` normal, `2` short, and `3` minimum. Use a higher value to reduce graphical load.

## Diagnostics

If a black screen appears or the game fails to launch:

1. Run **Ports > Minecraft PE** once and shut down the console properly.
2. Check on the SD card:
* `/roms2/ports/minecraftpe_boot.txt`: indicates that the normal launcher managed to execute.
* `/roms2/ports/minecraftpe/log.txt`: game output and errors. Overwritten on each startup.


3. If there are no logs or the issue persists, run **Ports > Minecraft PE DIAG**. The process takes about 25 seconds.
4. Share `/roms2/ports/minecraftpe/diagnostico.txt`. If the game folder does not exist, the script attempts to save `diagnostico.txt` next to the launcher.

Diagnostics include system data, architecture, card mounting, libraries, SDL2, graphics devices, and the result of a short executable test. Exit code `124` in that test means it was still running when it hit the 20-second timeout limit; it is not a game error by itself.

## User Data

The launcher sets `MCPE_HOME` to the `minecraftpe/` folder and `MCPE_SAVE` to `minecraftpe/savedata/`. Game data created during execution is saved there. Keep that folder when updating the binary if you want to keep your local data.
# Aclaracion/español
esto esta echo con la ia de claude no premium, asi que esto se podría considerar vider code por ser echa con ia, yo solo compile el vianrio para que funcionara el juego
si aun asi ignora esto puede segur adelante, el código es del a versión filtrada de Minecraft Pocket Editión de 2013 para Android como para iOS, del usuario Matt-SSMG64 crédito a le por archivar el código del
juego (https://github.com/SSMG64/PocketEdition) 

## Créditos y Reconocimientos

* **Código base original:** Minecraft: Pocket Edition (v0.6.1 / 0.6.2 - 2013)
* **Desarrolladores originales:** Mojang Studios / Mojang AB
* **Propietario de la marca y propiedad intelectual:** Microsoft Corporation / Mojang AB
* **Aviso de atribución:** Este proyecto modifica componentes de la versión histórica de Minecraft Pocket Edición con fines educativos, de ingeniería inversa y elaboración de una versión no oficila.
* **Modificaciones / Port:** Realizado por [Exenoria]
  
# Minecraft PE para R36S

Este repositorio contiene un port de Minecraft Pocket Edition preparado para ejecutarse en una consola R36S mediante Ports/PortMaster. Incluye los lanzadores, el binario `aarch64` del juego, los recursos y el código fuente necesario para compilarlo.

> El paquete está preparado para la R36S. No se garantiza que el binario funcione en otros dispositivos o sistemas.
> code open soucer
---------------------------------------------------------------------
# COMPILAR EN EL PC (una sola vez)
---------------------------------------------------------------------
1. Instala Docker (Windows/Mac: "Docker Desktop"; Linux: docker) y abrelo.
2. Abre la carpeta 1_COMPILAR_EN_PC y ejecuta:
        Windows:               doble clic en  build.bat
        Linux / Mac / WSL:     ./build.sh
     (la primera vez descarga ~500 MB de herramientas; despues tarda pocos
      minutos).
3. Al terminar se crea el archivo:
2_COPIAR_A_LA_CONSOLA/minecraftpe/minecraftpe
(Alternativa sin Docker: el archivo .github/workflows/build-r36s.yml compila en GitHub; o cualquier maquina aarch64 con "make CROSS=".)
---------------------------------------------------------------------
# COPIAR A LA CONSOLA
---------------------------------------------------------------------
  Copia el CONTENIDO de la carpeta 2_COPIAR_A_LA_CONSOLA, es decir:
        Minecraft PE.sh
        minecraftpe/        (con data/, controls.cfg y el binario minecraftpe)
  a la carpeta  /roms2/ports/  de tu SD2. Reinicia EmulationStation y
  abre Ports > Minecraft PE.
---------------------------------------------------------------------
# COPIAR A LA CONSOLA
---------------------------------------------------------------------
  Copia el CONTENIDO de la carpeta 2_COPIAR_A_LA_CONSOLA, es decir:
        Minecraft PE.sh
        minecraftpe/        (con data/, controls.cfg y el binario minecraftpe)
  a la carpeta  /roms2/ports/  de tu SD2. Reinicia EmulationStation y
  abre Ports > Minecraft PE.

---------------------------------------------------------------------
# CONTROLES
---------------------------------------------------------------------
  EN JUEGO
    Stick izquierdo ......... moverte
    Stick derecho ........... mirar
    R2 (mantener) ........... romper bloques
    L2 .................... .. colocar bloque / usar
    A ....................... saltar  (doble toque = volar; en vuelo A sube)
    B ....................... agacharse (en vuelo: bajar)
    X ....................... abrir/cerrar inventario (elegir bloques)
    L1 / R1  (o cruceta <- ->) casilla anterior / siguiente de la barra
    Start ................... pausa (Back to game / Quit to title)
    Select + Start .......... salir del juego (guarda el mundo)

  EN MENUS
    Cruceta arriba/abajo + A  moverte entre botones y aceptar
    Mover un stick ........... aparece el cursor: A = clic, B = atras
    Elegir un mundo ya creado: mueve el cursor sobre el mundo y pulsa A.
    Inventario: mueve el cursor sobre un bloque y pulsa A; se pone en la
    casilla seleccionada de la barra.

  La primera vez: Start Game > (Create new) crea el mundo "world".

---------------------------------------------------------------------
# AJUSTES  (minecraftpe/controls.cfg - editable con cualquier editor de texto)
---------------------------------------------------------------------
    look_speed     velocidad de la camara
    deadzone       zona muerta de los sticks (sube si la camara "se va sola")
    swap_ab        1 = intercambia A y B (si saltar/aceptar queda al reves)
    swap_xy        1 = intercambia X e Y
    view_distance  0 lejos, 1 normal, 2 corta (por defecto), 3 minima
                   (si va a tirones, pon 3)

  Los mundos se guardan en  minecraftpe/savedata/  (copia esa carpeta para
  hacer una copia de seguridad).

---------------------------------------------------------------------
# SI ALGO FALLA
---------------------------------------------------------------------
  - Mira  minecraftpe/log.txt  : ahi queda todo lo que escribe el juego.
    Si no arranca, mandale ese archivo a Claude junto con lo que viste.
  - "falta el binario minecraftpe": no hiciste el PASO 1 o no copiaste el
    archivo minecraftpe a la consola.
  - Botones cambiados: swap_ab=1 / swap_xy=1 en controls.cfg.
  - Sin sonido: en log.txt busca la linea que empieza por "Audio:".
    
SI NO ABRE (pantalla negra)
  1. Abre Minecraft PE una vez y saca la SD. Mira en el PC:
       /roms2/ports/minecraftpe_boot.txt   -> si existe, el lanzador SI se ejecuto
       /roms2/ports/minecraftpe/log.txt    -> todo lo que paso dentro del juego
  2. Si no hay nada o sigue negro: abre Ports > "Minecraft PE DIAG" (tarda unos
     25 segundos) y mandame el archivo  minecraftpe/diagnostico.txt
# instalacion
COPIA ESTOS 3 ELEMENTOS a la SD2, dentro de la carpeta  /roms2/ports/
    Minecraft PE.sh
    Minecraft PE DIAG.sh
    minecraftpe/            (carpeta completa)

Tiene que quedar EXACTAMENTE asi en la tarjeta:
    /roms2/ports/Minecraft PE.sh
    /roms2/ports/Minecraft PE DIAG.sh
    /roms2/ports/minecraftpe/minecraftpe        <- el juego (sin extension: es normal)
    /roms2/ports/minecraftpe/controls.cfg
    /roms2/ports/minecraftpe/data/...


# Guía del código fuente

El código C++ está en `minecraftpe/data/src/`; los recursos gráficos y de idioma están en `minecraftpe/data/images/` y `minecraftpe/data/lang/`. La compilación del paquete R36S define `R36S_PORT` y usa SDL2.

### Recorrido de ejecución

1. `src/main.cpp` es el punto de entrada de compilación. Según las macros de plataforma, incluye la implementación adecuada; para `R36S_PORT`, selecciona `src/main_sdl2.h`.
2. `main_sdl2.h` cambia al directorio del juego, lee `controls.cfg`, inicializa SDL2 y el contexto gráfico, carga la emulación GLES 1 sobre GLES 2 y abre el mando.
3. La capa SDL crea una instancia de `NinecraftApp`, configura las rutas de datos y entra en el bucle principal. Cada vuelta procesa eventos, convierte el mando en entradas de teclado/ratón del juego y llama a `update()`.
4. `NinecraftApp` inicializa los registros de bloques, objetos y biomas, configura idioma, gráficos y almacenamiento, y delega el ciclo común a `Minecraft`.
5. `Minecraft::update()` procesa eventos de red, ejecuta los ticks de simulación, actualiza iluminación, sonido y renderizado. Al salir, la capa SDL guarda el nivel activo.

### Módulos principales

- `src/client/`: estado y lógica de la aplicación cliente; opciones, jugador, modos de juego, interfaz, partículas y renderizador.
- `src/world/`: entidades, objetos, inventario, física, niveles, bloques y almacenamiento de mundos.
- `src/network/` y `src/raknet/`: paquetes, conexiones y manejo de eventos de red/multijugador.
- `src/server/`: componentes del servidor y jugadores del mundo servidor.
- `src/platform/`: abstracciones de plataforma, reloj, registros, audio e input. La adaptación concreta para R36S está principalmente en `main_sdl2.h`.
- `src/locale/` y `src/nbt/`: carga de idioma y tipos/lectura de datos NBT.
- `src/gles1_shim.cpp` y `src/gles1_shim.h`: compatibilidad de llamadas GLES 1 sobre el contexto GLES 2 usado por el port.
- `src/NinecraftApp.cpp` y `src/client/Minecraft.cpp`: inicialización de la aplicación y ciclo de juego compartido, respectivamente.

### Dónde empezar un cambio

- Controles del mando, eventos SDL, contexto gráfico o lectura de `controls.cfg`: `src/main_sdl2.h`.
- Inicialización, guardado o ciclo de vida del port: `src/NinecraftApp.cpp`.
- Ticks, opciones, selección de mundo y flujo del cliente: `src/client/Minecraft.cpp` y `src/client/Minecraft.h`.
- Dibujo del mundo y entidades: `src/client/renderer/`.
- Reglas de juego, bloques, entidades o física: busca primero el componente correspondiente bajo `src/world/`.
- Compilación: `sources.txt` lista los `.cpp` que el `Makefile` convierte en objetos. Si añades un nuevo `.cpp`, inclúyelo allí.

El `Makefile` no genera dependencias automáticas de cabeceras. Después de cambiar un archivo `.h`, ejecuta `make clean` antes de compilar para asegurar que se reconstruyan los objetos que lo incluyen.

## Instalación en la R36S

1. Descomprime el paquete en el ordenador.
2. Copia estos elementos directamente a `/roms2/ports/` de la tarjeta SD:
   - `Minecraft PE.sh`
   - `Minecraft PE DIAG.sh`
   - La carpeta completa `minecraftpe/`
3. Comprueba que las rutas queden así:

   ```text
   /roms2/ports/Minecraft PE.sh
   /roms2/ports/Minecraft PE DIAG.sh
   /roms2/ports/minecraftpe/minecraftpe
   /roms2/ports/minecraftpe/controls.cfg
   /roms2/ports/minecraftpe/data/...
   ```

4. Copia el contenido del paquete, no una carpeta contenedora adicional.
5. Reinicia EmulationStation y abre **Ports > Minecraft PE**.

Si editas cualquiera de los archivos `.sh` en Windows, guárdalo con finales de línea Unix (LF). Los finales CRLF pueden impedir que el lanzador se ejecute.

## Controles y ajustes

Los controles dependen de la configuración del sistema/PortMaster y del juego. Los ajustes específicos de este paquete están en `minecraftpe/controls.cfg`; se pueden cambiar con un editor de texto y no requieren recompilar.

- `look_speed`: velocidad de giro de la cámara con el stick derecho.
- `cursor_speed`: velocidad del cursor en los menús.
- `deadzone`: zona muerta de los sticks. Auméntala si el personaje o la cámara se mueven sin tocar el stick. El rango recomendado en el archivo es de `0.05` a `0.5`.
- `swap_ab`: intercambia A y B (`1` activado, `0` desactivado).
- `swap_xy`: intercambia X e Y (`1` activado, `0` desactivado).
- `view_distance`: distancia de dibujado: `0` lejos, `1` normal, `2` corta y `3` mínima. Usa un valor más alto para reducir la carga gráfica.

## Diagnóstico

Si aparece una pantalla negra o el juego no inicia:

1. Ejecuta **Ports > Minecraft PE** una vez y apaga la consola correctamente.
2. Revisa en la tarjeta SD:
   - `/roms2/ports/minecraftpe_boot.txt`: indica que el lanzador normal llegó a ejecutarse.
   - `/roms2/ports/minecraftpe/log.txt`: salida y errores del juego. Se sobrescribe en cada inicio.
3. Si no hay registros o el problema continúa, ejecuta **Ports > Minecraft PE DIAG**. El proceso tarda unos 25 segundos.
4. Comparte `/roms2/ports/minecraftpe/diagnostico.txt`. Si no existe la carpeta del juego, el script intenta guardar `diagnostico.txt` junto al lanzador.

El diagnóstico incluye datos del sistema, arquitectura, montaje de la tarjeta, bibliotecas, SDL2, dispositivos gráficos y el resultado de una prueba breve del ejecutable. El código de salida `124` en esa prueba significa que seguía ejecutándose al alcanzar el límite de 20 segundos; no es por sí solo un error del juego.

## Datos de usuario

El lanzador establece `MCPE_HOME` en la carpeta `minecraftpe/` y `MCPE_SAVE` en `minecraftpe/savedata/`. Los datos del juego que se creen durante la ejecución se guardan ahí. Conserva esa carpeta al actualizar el binario si deseas mantener los datos locales.
