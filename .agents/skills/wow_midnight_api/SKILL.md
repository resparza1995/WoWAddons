---
name: wow_midnight_api
description: Directrices y mejores prácticas para desarrollar addons de World of Warcraft para la expansión Midnight utilizando Lua y la API de Blizzard.
---

# Guía de Desarrollo de Addons para WoW Midnight

## Principios Básicos de Lua en WoW
- El cliente de WoW utiliza una versión modificada de Lua 5.1.
- **Rendimiento:** Localiza siempre las variables globales (ej. `local print = print`) en el ámbito de tu archivo para mejorar el rendimiento.
- Evita realizar cálculos pesados en eventos `OnUpdate`. Utiliza programación orientada a eventos siempre que sea posible.

## Espacio de Nombres C_
- Las APIs modernas de Blizzard están encapsuladas en tablas `C_` (ej. `C_Map`, `C_Timer`, `C_UIWidgetManager`). Evita usar las funciones globales antiguas equivalentes si existe una versión en `C_`.

## Manejo de Eventos
- Crea un `Frame` oculto para registrar y escuchar eventos.
- Eventos útiles para profesiones y recolección:
  - `UNIT_SPELLCAST_SUCCEEDED`: Para detectar cuando terminas de lanzar el hechizo de recolección (minería/herboristería).
  - `LOOT_OPENED` / `LOOT_READY`: Para detectar cuando se abre la ventana de botín y confirmar qué objeto se despojó.
  - `CHAT_MSG_LOOT`: Alternativa para leer el registro de chat y ver qué se recolectó.

## API de Mapas y Posicionamiento
- Para obtener el mapa actual del jugador: `local uiMapID = C_Map.GetBestMapForUnit("player")`
- Para obtener las coordenadas (x, y) del jugador: `local position = C_Map.GetPlayerMapPosition(uiMapID, "player")`. 
  > [!IMPORTANT]
  > Esto retorna una tabla de tipo `Vector2DMixin`. Debes extraer las coordenadas flotantes utilizando `local x, y = position:GetXY()`. Intentar usar `.x` o `.y` directamente fallará o devolverá `nil` en versiones modernas.
- Para dibujar en el mapa, es muy recomendable utilizar librerías comunitarias como **HereBeDragons (HBD)** para manejar la proyección de coordenadas en los mapas del mundo y el minimapa, ya que la API nativa de Blizzard para pines puede ser compleja y propensa a errores entre parches.

## Mejores Prácticas de Rendimiento (Pines y Memoria)
- **Reciclaje de Frames (Frame Pooling):** Dado que en WoW Lua no se pueden destruir o liberar widgets creados, si dibujas elementos repetidamente (como iconos en mapas) debes implementar una cola o pool de reciclaje en lugar de usar `CreateFrame` constantemente. Esto previene fugas de memoria y tirones del recolector de basura de WoW.
- **Filtro por Mapa Activo (Zone Filtering):** Al pintar pines en el mapa, no cargues toda tu base de datos global de coordenadas de golpe. 
  - Para el **Minimapa**: Carga únicamente los pines de la zona actual del jugador (`C_Map.GetBestMapForUnit("player")`). Actualízalos escuchando los eventos `ZONE_CHANGED_NEW_AREA`, `ZONE_CHANGED`, `ZONE_CHANGED_INDOORS` y `PLAYER_ENTERING_WORLD`.
  - Para el **Mapa del Mundo**: Carga los pines correspondientes al mapa visible actual (`WorldMapFrame:GetMapID()`). Utiliza `hooksecurefunc(WorldMapFrame, "OnMapChanged", UpdatePins)` y las capturas `OnShow` y `OnHide` para actualizar/liberar pines de forma eficiente.

## Persistencia de Datos (SavedVariables)
- Registra tu base de datos en el archivo `.toc` usando `## SavedVariables:` (global) o `## SavedVariablesPerCharacter:` (por personaje).
- Inicializa tu tabla en el evento `ADDON_LOADED` o `PLAYER_LOGIN`.
- Estructura de base de datos recomendada para coordenadas:
  ```lua
  MyAddonDB = {
      [uiMapID] = {
          { x = 0.453, y = 0.871, nodeType = "Mena de hierro" },
      }
  }
  ```

## Cambios y Deprecaciones en Midnight / TWW
- **Deprecación de `GetSpellInfo`:** La función global `GetSpellInfo` fue eliminada en Patch 11.0+. Ahora debes utilizar el wrapper seguro de `C_Spell.GetSpellInfo`:
  ```lua
  local function GetSpellName(spellID)
      if not spellID then return "" end
      if C_Spell and C_Spell.GetSpellInfo then
          local info = C_Spell.GetSpellInfo(spellID)
          return info and info.name or ""
      elseif _G.GetSpellInfo then
          return _G.GetSpellInfo(spellID) or ""
      end
      return ""
  end
  ```
- Asegúrate de actualizar la versión de la interfaz (TOC Version) en tu archivo `.toc` al número correspondiente al parche de Midnight (ej. `120000`).

