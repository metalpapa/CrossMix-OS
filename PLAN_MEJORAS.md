# Plan de mejoras - CrossMix-OS (fork metalpapa, rama `perf-fixes`)

> Estado: **implementado**. Los 8 cambios de la Categoria A fueron aplicados
> en la rama `perf-fixes`, en 5 commits atomicos, listos para revisar y
> eventualmente mandar como Pull Request al repo original (`cizia64/CrossMix-OS`).

## Commits de la rama `perf-fixes`

1. `8b98a1b5` - Gating de avahi-daemon (nuevo flag `"Avahi"` en crossmix.json,
   default 1 = sin cambio de comportamiento) + se saco `bc` del loop de espera
   de VNC en `°post_starts.sh` (ahora aritmetica entera nativa).
2. `0ea9b36e` - Se unifico el estado de SSH en una sola fuente de verdad
   (`crossmix.json["SSH"]`, leida por `ex_init.sh`). Se elimino el mecanismo
   paralelo basado en `sed` sobre `ex_config` que nunca se sincronizaba con
   el json. Se saco un comentario `# Currently broken` que parecia obsoleto.
3. `c9383a5f` - Menos forks de proceso en `patch_ra_cfg.sh`: se elimino un
   `grep` duplicado y se reemplazaron 3 chequeos `echo | grep -q` por `case`
   nativo de ash. Verificado con una prueba antes/despues: salida identica
   byte a byte.
4. `d444cfdd` - En `mainui_state_update.sh`: se escaparon las comillas simples
   antes de interpolarlas en SQL (bug de robustez) y se saco el `sleep 0.1`
   fijo despues del `sync` (redundante, `sync` ya bloquea hasta terminar).
5. `098b4a88` - En `infoscreen.sh` (el popup de feedback usado en todo el
   sistema): se cambio un `basename "$(...)"` por expansion de parametros
   nativa, se hizo perezosa la busqueda de fuente del tema (solo corre si no
   se paso `-ff`, aunque hoy nada usa `-ff` en el codebase), y se redujo el
   `sleep 1` fijo antes de cualquier temporizador a `0.2`.

## Verificacion realizada

- Cada archivo fue chequeado con `sh -n` / `bash -n` (sintaxis valida).
- `patch_ra_cfg.sh` se probo funcionalmente con GNU sed (equivalente al sed
  de busybox) contra un caso sintetico: salida identica al script original.
- La sustitucion de escape de comillas en `mainui_state_update.sh` se probo
  por separado, confirmando el doblado correcto de comillas simples.
- Todos los cambios fueron re-verificados contra el codigo REAL de este fork
  (no contra la release v1.3.0 original), ya que el fork esta mas adelantado
  en desarrollo. Dos hallazgos originales ya estaban resueltos upstream y un
  tercero (Categoria B) quedo obsoleto por eliminacion de archivo -- ver
  historial de esta conversacion para el detalle de esa comparacion.

## Pendiente / decision del usuario

- Revisar el diff completo (`git diff main...perf-fixes`) antes de hacer push.
- Decidir si se pushea la rama al fork y se abre el PR hacia
  `cizia64/CrossMix-OS`, o si primero se prueba en el dispositivo real.
- Los siguientes puntos quedaron deliberadamente descartados/aparcados:
  loop de 5s del boton FN (firmware stock cerrado, alto riesgo), y el driver
  de audio `oss` en RetroArch (falta libasound para probar sin riesgo).
