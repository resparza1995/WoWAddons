-- Routing.lua
local addonName, addonTable = ...
local Routing = addonTable.Routing
local Core = addonTable.Core

Routing.activeRoute = nil
Routing.currentTargetIndex = nil
Routing.currentRouteMapID = nil

function Routing:Init()
    -- No se necesita inicialización especial por ahora
end

function Routing:IsActive()
    return self.activeRoute ~= nil and self.currentTargetIndex ~= nil and self.currentTargetIndex <= #self.activeRoute
end

function Routing:GetCurrentTarget()
    if self:IsActive() then
        return self.activeRoute[self.currentTargetIndex]
    end
    return nil
end

function Routing:GenerateRoute()
    local mapID = C_Map.GetBestMapForUnit("player")
    if not mapID or not WhereIGatheredDB or not WhereIGatheredDB[mapID] or #WhereIGatheredDB[mapID] == 0 then
        print("|cff00ccffWhereIGathered:|r No hay nodos guardados en este mapa para trazar una ruta.")
        return
    end
    
    local playerX, playerY = nil, nil
    if Core.HBD then
        playerX, playerY = Core.HBD:GetPlayerZonePosition()
    end
    
    if not playerX or not playerY then
        local position = C_Map.GetPlayerMapPosition(mapID, "player")
        if position then
            playerX, playerY = position:GetXY()
        end
    end
    
    if not playerX or not playerY then
        print("|cffcc0000WhereIGathered: No se pudo obtener la posición del jugador para iniciar la ruta.|r")
        return
    end
    
    -- Clonar la lista de nodos de la zona actual
    local unvisited = {}
    for i, node in ipairs(WhereIGatheredDB[mapID]) do
        table.insert(unvisited, { x = node.x, y = node.y, type = node.type })
    end
    
    local route = {}
    local currX, currY = playerX, playerY
    
    -- Algoritmo Nearest Neighbor (Vecino Más Cercano)
    while #unvisited > 0 do
        local closestIndex = 1
        local minDistance = 99999999
        
        for i, node in ipairs(unvisited) do
            local dist = nil
            if Core.HBD then
                dist = Core.HBD:GetZoneDistance(mapID, currX, currY, node.x, node.y)
            end
            
            -- Fallback a distancia euclidiana si HBD no devuelve distancia
            if not dist then
                dist = math.sqrt((node.x - currX)^2 + (node.y - currY)^2)
            end
            
            if dist < minDistance then
                minDistance = dist
                closestIndex = i
            end
        end
        
        -- Añadir el nodo más cercano a la ruta ordenada
        local nextNode = table.remove(unvisited, closestIndex)
        table.insert(route, nextNode)
        
        -- Actualizar posición actual para la siguiente búsqueda
        currX, currY = nextNode.x, nextNode.y
    end
    
    self.activeRoute = route
    self.currentTargetIndex = 1
    self.currentRouteMapID = mapID
    
    print("|cff00ccffWhereIGathered:|r Ruta de recolección generada con |cff00ff00" .. #route .. "|r nodos.")
    
    -- Inicializar brújula
    if addonTable.Compass.Show then
        addonTable.Compass:Show()
    end
    
    -- Actualizar pines para destacar el objetivo
    if addonTable.MapPins.UpdatePins then
        addonTable.MapPins:UpdatePins()
    end
end

function Routing:AdvanceRoute()
    if not self:IsActive() then return end
    
    self.currentTargetIndex = self.currentTargetIndex + 1
    if self.currentTargetIndex > #self.activeRoute then
        print("|cff00ccffWhereIGathered:|r ¡Has completado la ruta de recolección!")
        self:ClearRoute()
    else
        print("|cff00ccffWhereIGathered:|r Siguiente nodo: |cff00ff00" .. self.currentTargetIndex .. "/" .. #self.activeRoute .. "|r")
        if addonTable.Compass.UpdateTarget then
            addonTable.Compass:UpdateTarget()
        end
        if addonTable.MapPins.UpdatePins then
            addonTable.MapPins:UpdatePins()
        end
    end
end

function Routing:SkipNode()
    if not self:IsActive() then return end
    print("|cff00ccffWhereIGathered:|r Nodo saltado.")
    self:AdvanceRoute()
end

function Routing:ClearRoute()
    self.activeRoute = nil
    self.currentTargetIndex = nil
    self.currentRouteMapID = nil
    
    if addonTable.Compass.Hide then
        addonTable.Compass:Hide()
    end
    if addonTable.MapPins.UpdatePins then
        addonTable.MapPins:UpdatePins()
    end
end

function Routing:OnZoneChanged()
    -- Si cambiamos de zona, cancelamos la ruta para evitar que apunte a coordenadas incorrectas
    if self:IsActive() then
        local currentMapID = C_Map.GetBestMapForUnit("player")
        if currentMapID ~= self.currentRouteMapID then
            print("|cff00ccffWhereIGathered:|r Cambio de zona detectado. Ruta desactivada.")
            self:ClearRoute()
        end
    end
end
