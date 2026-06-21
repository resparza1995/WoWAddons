# Mis Addons de World of Warcraft

Este directorio contiene la colección de addons personalizados desarrollados para **World of Warcraft (WoW) Midnight (12.0+)**.

## Proyectos Activos

### 📌 [WhereIGathered](file:///e:/code-workspaces/WoWAddons/WhereIGathered)
Un addon ligero y altamente optimizado que registra automáticamente la posición exacta del personaje cada vez que minas una mena o recoges una planta, mostrando un icono fijo (veta o planta) en el minimapa y en el mapa del mundo.

*   **Autor:** fytta
*   **Compatibilidad:** WoW Midnight (Versión de interfaz: `120000`)
*   **Características Principales:**
    *   **Registro Automático:** Captura el evento de recolección y guarda las coordenadas 2D.
    *   **Optimización Activa:** Solo carga e inicializa los pines correspondientes a la zona actual del jugador (para el minimapa) y la zona que estás visualizando (para el mapa del mundo).
    *   **Gestión Eficiente:** Utiliza la librería comunitaria `HereBeDragons` y un sistema de reciclaje de frames (*Frame Pooling*) para asegurar que el uso de CPU y memoria sea mínimo y evitar micro-tirones.
    *   **Control por Chat:** Comando `/wig` o `/whereigathered` para activar/desactivar visualmente todos los iconos.

---

## Cómo Probar y Desplegar los Addons

Para probar los cambios en el juego, los addons deben copiarse en la carpeta de instalación de World of Warcraft.

### Rutas de Instalación
*   **Directorio del Juego:** `D:\Battle.net\World of Warcraft`
*   **Carpeta de Addons (Retail):** `D:\Battle.net\World of Warcraft\_retail_\Interface\AddOns`

### Script de Despliegue Rápido (PowerShell)
Puedes utilizar este comando rápido en PowerShell para copiar un addon directamente a tu carpeta de WoW tras realizar cambios:

```powershell
# Ejemplo para WhereIGathered
New-Item -ItemType Directory -Force -Path "D:\Battle.net\World of Warcraft\_retail_\Interface\AddOns\WhereIGathered"
Copy-Item -Path "E:\code-workspaces\WoWAddons\WhereIGathered\*" -Destination "D:\Battle.net\World of Warcraft\_retail_\Interface\AddOns\WhereIGathered" -Recurse -Force
```

Una vez copiado, si el juego está abierto, escribe `/reload` en el chat del juego para aplicar las modificaciones de archivos `.lua`. Si has agregado archivos nuevos (ej. imágenes o archivos `.toc`), reinicia el juego o vuelve a la pantalla de selección de personajes.
