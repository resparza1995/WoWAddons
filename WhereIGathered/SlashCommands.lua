-- SlashCommands.lua
local addonName, addonTable = ...
local Routing = addonTable.Routing
local Recorder = addonTable.Recorder
local MapPins = addonTable.MapPins

SLASH_WHEREIGATHERED1 = "/wig"
SLASH_WHEREIGATHERED2 = "/whereigathered"

SlashCmdList["WHEREIGATHERED"] = function(msg)
    if not WhereIGatheredDB then return end
    
    local parts = {}
    for word in msg:gmatch("%S+") do
        table.insert(parts, word:lower())
    end
    
    local command = parts[1] or ""
    local subcommand = parts[2] or ""
    
    if command == "route" then
        if subcommand == "stop" or subcommand == "clear" then
            Routing:ClearRoute()
        elseif subcommand == "skip" then
            Routing:SkipNode()
        elseif subcommand == "" then
            Routing:GenerateRoute()
        else
            print("|cff00ccffWhereIGathered: Comando de ruta desconocido.|r")
            print("  |cff00ff00/wig route|r - Inicia/genera la ruta óptima.")
            print("  |cff00ff00/wig route stop|r - Detiene la ruta activa.")
            print("  |cff00ff00/wig route skip|r - Salta el nodo actual.")
        end
    elseif command == "reset" then
        if subcommand == "all" then
            for key in pairs(WhereIGatheredDB) do
                if key ~= "showPins" and key ~= "compassPosition" then
                    WhereIGatheredDB[key] = nil
                end
            end
            print("|cff00ccffWhereIGathered:|r Todos los registros han sido eliminados.")
            Routing:ClearRoute()
        else
            local currentMapID = C_Map.GetBestMapForUnit("player")
            if currentMapID and WhereIGatheredDB[currentMapID] then
                WhereIGatheredDB[currentMapID] = nil
                print("|cff00ccffWhereIGathered:|r Registros del mapa actual eliminados.")
                Routing:ClearRoute()
            else
                print("|cff00ccffWhereIGathered:|r No hay registros en este mapa.")
            end
        end
        MapPins:UpdatePins()
    elseif command == "cleanup" then
        local duplicatesRemoved = Recorder.RemoveDuplicates()
        print("|cff00ccffWhereIGathered:|r Limpieza completada. Se eliminaron |cffff9900" .. duplicatesRemoved .. "|r duplicados.")
        MapPins:UpdatePins()
    elseif command == "stats" then
        local totalNodes = 0
        local mapCount = 0
        for mapID, nodes in pairs(WhereIGatheredDB) do
            if mapID ~= "showPins" and mapID ~= "compassPosition" and type(nodes) == "table" then
                mapCount = mapCount + 1
                totalNodes = totalNodes + #nodes
            end
        end
        print("|cff00ccffWhereIGathered:|r Estadísticas: |cff00ff00" .. totalNodes .. "|r nodos en |cff00ff00" .. mapCount .. "|r mapas.")
    elseif command == "help" then
        print("|cff00ccffWhereIGathered - Comandos de chat:|r")
        print("  |cff00ff00/wig|r - Muestra u oculta los iconos de recolección en los mapas.")
        print("  |cff00ff00/wig route|r - Inicia/genera la ruta óptima de recolección para la zona.")
        print("  |cff00ff00/wig route stop|r - Detiene la ruta activa y oculta la brújula.")
        print("  |cff00ff00/wig route skip|r - Salta el nodo actual y pasa al siguiente.")
        print("  |cff00ff00/wig stats|r - Muestra el número total de nodos guardados.")
        print("  |cff00ff00/wig cleanup|r - Limpia los nodos duplicados en la base de datos.")
        print("  |cff00ff00/wig reset|r - Elimina los nodos registrados de la zona actual.")
        print("  |cff00ff00/wig reset all|r - Elimina todos los nodos del addon.")
    else
        -- Toggle de visibilidad
        WhereIGatheredDB.showPins = not WhereIGatheredDB.showPins
        if WhereIGatheredDB.showPins then
            print("|cff00ccffWhereIGathered:|r Iconos MOSTRADOS.")
        else
            print("|cff00ccffWhereIGathered:|r Iconos OCULTOS.")
        end
        MapPins:UpdatePins()
    end
end
