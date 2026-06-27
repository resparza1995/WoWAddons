-- WhereIGathered.lua
local addonName, addonTable = ...

-- Referencias a las librerías de HereBeDragons
local HBD, HBDPins
local minimapPinPool = {}
local worldmapPinPool = {}

-- Helper para obtener nombre del hechizo compatible con 11.0+ (Midnight) y versiones anteriores
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

-- ==========================================
-- Gestión de Pines (HereBeDragons)
-- ==========================================

local function AcquireMinimapPin()
    for _, pin in ipairs(minimapPinPool) do
        if not pin.inUse then
            pin.inUse = true
            return pin
        end
    end
    local pin = CreateFrame("Frame", nil, Minimap)
    pin:SetSize(12, 12)
    pin.texture = pin:CreateTexture(nil, "OVERLAY")
    pin.texture:SetAllPoints()
    pin.inUse = true
    table.insert(minimapPinPool, pin)
    return pin
end

local function AcquireWorldmapPin()
    for _, pin in ipairs(worldmapPinPool) do
        if not pin.inUse then
            pin.inUse = true
            return pin
        end
    end
    local pin = CreateFrame("Frame", nil, WorldMapFrame)
    pin:SetSize(12, 12)
    pin.texture = pin:CreateTexture(nil, "OVERLAY")
    pin.texture:SetAllPoints()
    pin.inUse = true
    table.insert(worldmapPinPool, pin)
    return pin
end

local function ReleaseAllPins()
    if HBDPins then
        HBDPins:RemoveAllMinimapIcons(addonName)
        HBDPins:RemoveAllWorldMapIcons(addonName)
    end
    for _, pin in ipairs(minimapPinPool) do
        pin.inUse = false
        pin:Hide()
    end
    for _, pin in ipairs(worldmapPinPool) do
        pin.inUse = false
        pin:Hide()
    end
end

local function UpdatePins()
    if not HBD or not HBDPins then return end
    
    ReleaseAllPins()
    
    if not WhereIGatheredDB or WhereIGatheredDB.showPins == false then return end
    
    -- Obtener el mapa actual del jugador para el Minimapa
    local playerMapID = C_Map.GetBestMapForUnit("player")
    
    -- Cargar pines en el Minimapa (solo para el mapa actual del jugador)
    if playerMapID and WhereIGatheredDB[playerMapID] then
        for _, node in ipairs(WhereIGatheredDB[playerMapID]) do
            if node.x and node.y and node.type then
                local mPin = AcquireMinimapPin()
                mPin.texture:SetTexture(node.type == "mine" and "Interface\\Icons\\Trade_mining" or "Interface\\Icons\\Trade_herbalism")
                HBDPins:AddMinimapIconMap(addonName, mPin, playerMapID, node.x, node.y, true, false)
            end
        end
    end
    
    -- Cargar pines en el Mapa del Mundo (solo para el mapa que se está visualizando)
    if WorldMapFrame and WorldMapFrame:IsShown() then
        local worldMapID = WorldMapFrame:GetMapID()
        if worldMapID and WhereIGatheredDB[worldMapID] then
            for _, node in ipairs(WhereIGatheredDB[worldMapID]) do
                if node.x and node.y and node.type then
                    local wPin = AcquireWorldmapPin()
                    wPin.texture:SetTexture(node.type == "mine" and "Interface\\Icons\\Trade_mining" or "Interface\\Icons\\Trade_herbalism")
                    HBDPins:AddWorldMapIconMap(addonName, wPin, worldMapID, node.x, node.y)
                end
            end
        end
    end
end

-- ==========================================
-- Captura de Eventos (Recolección)
-- ==========================================

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
eventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
eventFrame:RegisterEvent("ZONE_CHANGED")
eventFrame:RegisterEvent("ZONE_CHANGED_INDOORS")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

eventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local loadedAddon = ...
        if loadedAddon == addonName then
            -- Inicializar base de datos
            WhereIGatheredDB = WhereIGatheredDB or {}
            if WhereIGatheredDB.showPins == nil then
                WhereIGatheredDB.showPins = true
            end
            
            -- Intentar cargar HereBeDragons
            HBD = LibStub("HereBeDragons-2.0", true)
            HBDPins = LibStub("HereBeDragons-Pins-2.0", true)
            
            if HBD and HBDPins then
                print("|cff00ccffWhereIGathered|r cargado correctamente con HereBeDragons.")
                
                -- Ganchos para actualizar cuando se abre/cierra o cambia el mapa del mundo
                if WorldMapFrame then
                    hooksecurefunc(WorldMapFrame, "OnMapChanged", UpdatePins)
                    WorldMapFrame:HookScript("OnShow", UpdatePins)
                    WorldMapFrame:HookScript("OnHide", UpdatePins)
                end
                
                UpdatePins()
            else
                print("|cffcc0000WhereIGathered: Error al inicializar HereBeDragons.|r")
            end
        end
    elseif event == "ZONE_CHANGED_NEW_AREA" or event == "ZONE_CHANGED" or event == "ZONE_CHANGED_INDOORS" or event == "PLAYER_ENTERING_WORLD" then
        UpdatePins()
    elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
        local unitTarget, castGUID, spellID = ...
        if unitTarget == "player" then
            -- Excluir herbología de cadáveres de Midnight (spell ID 32605)
            -- Estos no son nodos de recolección típicos y no deberían registrarse en la BD
            if spellID == 32605 then
                return
            end
            
            local spellName = GetSpellName(spellID)
            local nodeType = nil
            
            local spellNameLower = spellName:lower()
            -- Detección de Minería
            if spellNameLower:find("miner") or spellNameLower:find("mining") then
                nodeType = "mine"
            -- Detección de Herboristería (Añadidas variantes en español como 'recolect', 'hierba', 'planta')
            elseif spellNameLower:find("herbo") or spellNameLower:find("herb") or spellNameLower:find("recolect") or spellNameLower:find("gather") or spellNameLower:find("hierba") or spellNameLower:find("planta") then
                nodeType = "herb"
            end
            
            -- Fallbacks por ID de hechizo conocidos
            if spellID == 32606 or spellID == 2575 then
                nodeType = "mine"
            elseif spellID == 2366 then
                nodeType = "herb"
            end
            
            if nodeType then
                local uiMapID = C_Map.GetBestMapForUnit("player")
                if uiMapID then
                    local position = C_Map.GetPlayerMapPosition(uiMapID, "player")
                    if position then
                        local x, y = position:GetXY()
                        if x and y then
                            WhereIGatheredDB[uiMapID] = WhereIGatheredDB[uiMapID] or {}
                            
                            -- Verificar si ya existe un nodo cercano (dentro de 0.01 de distancia)
                            local nodeExists = false
                            local DUPLICATE_THRESHOLD = 0.01
                            for _, existingNode in ipairs(WhereIGatheredDB[uiMapID]) do
                                local distance = math.sqrt((x - existingNode.x)^2 + (y - existingNode.y)^2)
                                if distance < DUPLICATE_THRESHOLD then
                                    nodeExists = true
                                    break
                                end
                            end
                            
                            if not nodeExists then
                                table.insert(WhereIGatheredDB[uiMapID], {
                                    x = x,
                                    y = y,
                                    type = nodeType
                                })
                                print("|cff00ff00WhereIGathered:|r " .. (nodeType == "mine" and "Veta" or "Planta") .. " guardada en tu base de datos.")
                                UpdatePins()
                            else
                                print("|cffff9900WhereIGathered:|r Este nodo ya está registrado.")
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- ==========================================
-- Comandos de Chat (/wig)
-- ==========================================

-- ==========================================
-- Limpieza de Duplicados
-- ==========================================

local function RemoveDuplicates()
    if not WhereIGatheredDB then return end
    
    local totalDuplicates = 0
    local DUPLICATE_THRESHOLD = 0.01
    
    for mapID, nodes in pairs(WhereIGatheredDB) do
        if mapID ~= "showPins" and type(nodes) == "table" then
            local cleanedNodes = {}
            
            for _, node in ipairs(nodes) do
                local isDuplicate = false
                -- Verificar si este nodo es duplicado de uno ya procesado
                for _, cleanNode in ipairs(cleanedNodes) do
                    local distance = math.sqrt((node.x - cleanNode.x)^2 + (node.y - cleanNode.y)^2)
                    if distance < DUPLICATE_THRESHOLD then
                        isDuplicate = true
                        totalDuplicates = totalDuplicates + 1
                        break
                    end
                end
                -- Si no es duplicado, lo añadimos
                if not isDuplicate then
                    table.insert(cleanedNodes, node)
                end
            end
            
            WhereIGatheredDB[mapID] = cleanedNodes
        end
    end
    
    return totalDuplicates
end

-- ==========================================
-- Comandos de Chat (/wig)
-- ==========================================

SLASH_WHEREIGATHERED1 = "/wig"
SLASH_WHEREIGATHERED2 = "/whereigathered"
SlashCmdList["WHEREIGATHERED"] = function(msg)
    if not WhereIGatheredDB then return end
    
    local command = msg:lower():trim()
    
    if command == "reset" then
        -- Resetear solo el mapa actual
        local currentMapID = C_Map.GetBestMapForUnit("player")
        if currentMapID and WhereIGatheredDB[currentMapID] then
            WhereIGatheredDB[currentMapID] = {}
            print("|cff00ccffWhereIGathered:|r Registros del mapa actual eliminados.")
            UpdatePins()
        else
            print("|cff00ccffWhereIGathered:|r No hay registros en este mapa.")
        end
    elseif command == "reset all" then
        -- Resetear todos los registros (excepto showPins)
        for key in pairs(WhereIGatheredDB) do
            if key ~= "showPins" then
                WhereIGatheredDB[key] = nil
            end
        end
        print("|cff00ccffWhereIGathered:|r Todos los registros han sido eliminados.")
        UpdatePins()
    elseif command == "cleanup" then
        -- Limpiar duplicados
        local duplicatesRemoved = RemoveDuplicates()
        print("|cff00ccffWhereIGathered:|r Limpieza completada. Se eliminaron |cffff9900" .. duplicatesRemoved .. "|r duplicados.")
        UpdatePins()
    elseif command == "stats" then
        -- Mostrar estadísticas
        local totalNodes = 0
        local mapCount = 0
        for mapID, nodes in pairs(WhereIGatheredDB) do
            if mapID ~= "showPins" and type(nodes) == "table" then
                mapCount = mapCount + 1
                totalNodes = totalNodes + #nodes
            end
        end
        print("|cff00ccffWhereIGathered:|r Estadísticas: |cff00ff00" .. totalNodes .. "|r nodos en |cff00ff00" .. mapCount .. "|r mapas.")
    else
        -- Toggle de visibilidad (comportamiento por defecto)
        WhereIGatheredDB.showPins = not WhereIGatheredDB.showPins
        if WhereIGatheredDB.showPins then
            print("|cff00ccffWhereIGathered:|r Iconos MOSTRADOS.")
        else
            print("|cff00ccffWhereIGathered:|r Iconos OCULTOS.")
        end
        UpdatePins()
    end
end
