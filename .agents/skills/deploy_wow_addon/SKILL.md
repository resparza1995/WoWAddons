---
name: deploy_wow_addon
description: Skill para automatizar el despliegue y copia del addon al directorio de instalación de World of Warcraft para probar los cambios en el juego.
---

# Despliegue de Addon de WoW (Deploy)

## Objetivo
Cada vez que se solicite "desplegar el addon" o se realicen cambios significativos que necesiten ser probados en el juego, se utilizará esta skill para copiar el contenido de nuestro espacio de trabajo al directorio de addons de World of Warcraft.

## Rutas y Directorios
- **Directorio de Desarrollo (Origen):** `E:\code-workspaces\WoWAddons\<addon_name>` (Reemplazar `<addon_name>` por el nombre del addon actual, ej. `WhereIGathered`).
- **Directorio de WoW (Base):** `D:\Battle.net\World of Warcraft`
- **Subcarpeta de Versión:** Por defecto `_retail_` (ajustable a `_beta_` o `_ptr_` según la versión activa de Midnight).
- **Directorio Final de Destino:** `D:\Battle.net\World of Warcraft\_retail_\Interface\AddOns\<addon_name>`

## Instrucciones de Despliegue (PowerShell)

Para desplegar los cambios al juego, utiliza la herramienta `run_command` reemplazando `<addon_name>` por el nombre de la subcarpeta del addon en el que estés trabajando:

1. Asegúrate de que el directorio de destino existe:
```powershell
New-Item -ItemType Directory -Force -Path "D:\Battle.net\World of Warcraft\_retail_\Interface\AddOns\<addon_name>"
```

2. Copia todos los archivos del addon (sobrescribiendo los existentes):
```powershell
Copy-Item -Path "E:\code-workspaces\WoWAddons\<addon_name>\*" -Destination "D:\Battle.net\World of Warcraft\_retail_\Interface\AddOns\<addon_name>" -Recurse -Force
```

> [!NOTE]
> En World of Warcraft, para que el juego reconozca archivos completamente nuevos (como un `.toc` recién creado, imágenes, archivos XML o carpetas de librerías), es necesario reiniciar el cliente de juego o volver a la pantalla de selección de personajes. Si solo se modifican archivos `.lua` o `.xml` ya cargados por el cliente, el comando `/reload` en el chat del juego aplicará los cambios de forma instantánea.

