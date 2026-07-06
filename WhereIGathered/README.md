# WhereIGathered

**WhereIGathered** es un addon ligero y moderno para World of Warcraft (preparado para Midnight/TWW) que registra y dibuja automáticamente en el minimapa y en el mapa del mundo los nodos de minería y herboristería que recolectas con tu personaje, creando una base de datos local y personal.

Además, cuenta con un sistema de navegación inteligente que te guía por la ruta óptima de recolección en tu zona actual.


## Características Principales

*   **Captura Automática:** Escucha tus hechizos de recolección en tiempo real y guarda la posición exacta.
*   **Base de Datos Local:** Los datos se guardan en tus `SavedVariables` personales, garantizando que tu base de datos de recolección sea privada y persistente.
*   **Filtrado de Falsos Nodos:** Excluye automáticamente la herbología en cadáveres (como los de Midnight) para evitar registrar coordenadas inválidas.
*   **Limpieza de Duplicados:** Algoritmo integrado para detectar y eliminar automáticamente registros duplicados o muy cercanos.
*   **Optimización de Rutas:** Algoritmo **Nearest Neighbor (Vecino Más Cercano)** que calcula la ruta de recolección óptima a partir de tu ubicación actual utilizando distancias físicas reales en yardas.
*   **Brújula HUD Premium:** Una flecha flotante y dinámica que rota según la dirección a la que mira tu personaje y te muestra la distancia exacta al siguiente nodo.
*   **Resaltado Inteligente en Mapas:** El pin objetivo de la ruta activa se dibuja el doble de grande y con un borde dorado brillante pulsante en el Minimapa y en el Mapa del Mundo.

## Interacción con la Brújula HUD

*   **Mover el HUD:** Mantén presionado **Click Izquierdo** sobre la brújula y arrástrala a cualquier parte de tu pantalla. Su posición se guardará automáticamente para futuras sesiones.
*   **Saltar Nodo:** Haz **Click Derecho** sobre la brújula para omitir el nodo actual y apuntar directamente al siguiente.
*   **Avance Automático:** Al acercarte a menos de **30 yardas** de tu nodo objetivo actual, la brújula avanzará de manera automática al siguiente punto de la ruta.

## Comandos de Chat

Usa `/wig` o `/whereigathered` en el chat seguido de una opción:

*   `/wig` (sin argumentos): Alterna la visibilidad de todos los iconos de recolección en los mapas.
*   `/wig route`: Genera y activa la ruta de recolección para tu zona actual, mostrando la brújula en pantalla.
*   `/wig route stop`: Detiene la ruta activa y oculta la brújula.
*   `/wig route skip`: Salta el nodo actual de la ruta (equivalente al click derecho en la brújula).
*   `/wig stats`: Muestra estadísticas detalladas sobre el número de nodos guardados en cada mapa.
*   `/wig cleanup`: Elimina nodos duplicados o extremadamente cercanos de la base de datos para optimizar el rendimiento.
*   `/wig reset`: Elimina los registros de recolección **solo del mapa/zona actual**.
*   `/wig reset all`: Elimina **toda la base de datos** del addon.
*   `/wig help`: Muestra una guía interactiva con la lista de comandos disponibles en el chat.

## Instalación

1.  Descarga o clona el repositorio.
2.  Copia la carpeta en tu directorio de addons de World of Warcraft:
    `World of Warcraft\_retail_\Interface\AddOns\WhereIGathered`
3.  Asegúrate de que la carpeta de destino se llama exactamente `WhereIGathered`.
4.  *Nota*: Si añades el addon por primera vez o tras esta actualización modular, es recomendable reiniciar el juego por completo (o ir a la pantalla de selección de personaje) para que el cliente de WoW registre los nuevos archivos descritos en el archivo `.toc`.

## Estructura Modular y Código

El addon ha sido estructurado siguiendo los mejores estándares de desarrollo de WoW, dividido en los siguientes módulos cargados secuencialmente:
*   `Init.lua`: Inicialización de espacios de nombres.
*   `Utils.lua`: Wrappers seguros y compatibles para funciones de la API de WoW.
*   `Core.lua`: Inicialización del addon, persistencia de datos y escucha de eventos principales.
*   `Recorder.lua`: Registro y validación de recolección.
*   `Routing.lua`: Heurísticas del algoritmo de vecino más cercano y estado de rutas.
*   `Compass.lua`: Creación, animaciones y comportamiento del HUD de la brújula.
*   `MapPins.lua`: Renderizado y resaltado de pines a través de la librería `HereBeDragons-Pins-2.0`.
*   `SlashCommands.lua`: Procesamiento de comandos de consola.

## Screenshots
### Wig commands
<img width="429" height="163" alt="wig-commands" src="https://github.com/user-attachments/assets/63b9605f-bf09-4c09-a54e-b465997605b5" />

### Wig route
<img width="551" height="357" alt="wig route" src="https://github.com/user-attachments/assets/bf8f586b-7082-4a90-ae4b-20859305e320" />

### Wig nodes
<img width="390" height="315" alt="wig-nodes" src="https://github.com/user-attachments/assets/13f58dda-c1fd-439a-b8ba-b361250f3793" />


