# WhereIGathered

**WhereIGathered** es un addon ligero para World of Warcraft (preparado para Midnight/TWW) que registra y dibuja automáticamente en el minimapa y en el mapa del mundo los nodos de minería y herboristería que recolectas con tu personaje, creando una base de datos local y personal.

## Características
- **Captura Automática:** Escucha tus hechizos de recolección en tiempo real y guarda la posición exacta.
- **Base de Datos Local:** Los datos se guardan en tus `SavedVariables`, por lo que solo tú tienes acceso a tu ruta óptima.
- **Iconos Distintivos:** Diferencia entre vetas de minería (icono de pico/mena) y plantas de herboristería (icono de hoja).
- **Integración Nativa:** Utiliza `HereBeDragons` para asegurar que los iconos del minimapa sigan tus movimientos de manera precisa y rotan con el mapa.

## Comandos
- `/wig` o `/whereigathered`: Muestra u oculta todos los iconos de recolección de los mapas instantáneamente.

## Instalación
1. Descarga el repositorio.
2. Cópialo en tu carpeta de instalación de WoW: `World of Warcraft\_retail_\Interface\AddOns\WhereIGathered`
3. ¡Asegúrate de que la carpeta se llama exactamente `WhereIGathered`!

## Dependencias Incluidas
Este addon ya incluye las librerías necesarias en la carpeta `libs/` para funcionar "Out of the box":
- [LibStub](https://github.com/lua-wow/LibStub)
- [CallbackHandler-1.0](https://github.com/lua-wow/CallbackHandler)
- [HereBeDragons-2.0](https://github.com/Nevcairiel/HereBeDragons)
