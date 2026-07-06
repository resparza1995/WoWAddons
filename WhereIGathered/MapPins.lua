-- MapPins.lua
local addonName, addonTable = ...
local MapPins = addonTable.MapPins
local Core = addonTable.Core
local Routing = addonTable.Routing

local minimapPinPool = {}
local worldmapPinPool = {}

local function AcquireMinimapPin()
    for _, pin in ipairs(minimapPinPool) do
        if not pin.inUse then
            pin.inUse = true
            return pin
        end
    end
    
    local pin = CreateFrame("Frame", nil, Minimap)
    pin:SetSize(12, 12)
    
    pin.texture = pin:CreateTexture(nil, "ARTWORK")
    pin.texture:SetAllPoints()
    
    -- Textura de borde/resaltado para el nodo objetivo
    pin.border = pin:CreateTexture(nil, "OVERLAY")
    pin.border:SetTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight") -- Círculo dorado brillante
    pin.border:SetAllPoints()
    pin.border:Hide()
    
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
    
    pin.texture = pin:CreateTexture(nil, "ARTWORK")
    pin.texture:SetAllPoints()
    
    pin.border = pin:CreateTexture(nil, "OVERLAY")
    pin.border:SetTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight")
    pin.border:SetAllPoints()
    pin.border:Hide()
    
    pin.inUse = true
    table.insert(worldmapPinPool, pin)
    return pin
end

local function ReleaseAllPins()
    if Core.HBDPins then
        Core.HBDPins:RemoveAllMinimapIcons(addonName)
        Core.HBDPins:RemoveAllWorldMapIcons(addonName)
    end
    for _, pin in ipairs(minimapPinPool) do
        pin.inUse = false
        pin.border:Hide()
        pin:Hide()
    end
    for _, pin in ipairs(worldmapPinPool) do
        pin.inUse = false
        pin.border:Hide()
        pin:Hide()
    end
end

function MapPins:Init()
    if WorldMapFrame then
        hooksecurefunc(WorldMapFrame, "OnMapChanged", function() self:UpdatePins() end)
        WorldMapFrame:HookScript("OnShow", function() self:UpdatePins() end)
        WorldMapFrame:HookScript("OnHide", function() self:UpdatePins() end)
    end
    self:UpdatePins()
end

function MapPins:UpdatePins()
    if not Core.HBD or not Core.HBDPins then return end
    
    ReleaseAllPins()
    
    if not WhereIGatheredDB or WhereIGatheredDB.showPins == false then return end
    
    -- Obtener el mapa actual del jugador para el Minimapa
    local playerMapID = C_Map.GetBestMapForUnit("player")
    
    -- Comprobar si hay una ruta activa y obtener el nodo actual
    local targetNode = Routing:GetCurrentTarget()
    
    -- Cargar pines en el Minimapa (solo para el mapa actual del jugador)
    if playerMapID and WhereIGatheredDB[playerMapID] then
        for _, node in ipairs(WhereIGatheredDB[playerMapID]) do
            if node.x and node.y and node.type then
                local mPin = AcquireMinimapPin()
                mPin.texture:SetTexture(node.type == "mine" and "Interface\\Icons\\Trade_mining" or "Interface\\Icons\\Trade_herbalism")
                
                -- Verificar si es el nodo objetivo activo
                local isTarget = (targetNode and targetNode.x == node.x and targetNode.y == node.y)
                if isTarget then
                    mPin:SetSize(22, 22) -- Duplicar tamaño para que destaque
                    mPin.border:Show()   -- Mostrar destello/borde dorado
                else
                    mPin:SetSize(12, 12)
                    mPin.border:Hide()
                end
                
                Core.HBDPins:AddMinimapIconMap(addonName, mPin, playerMapID, node.x, node.y, true, false)
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
                    
                    -- Verificar si es el nodo objetivo activo
                    local isTarget = (targetNode and targetNode.x == node.x and targetNode.y == node.y)
                    if isTarget then
                        wPin:SetSize(22, 22)
                        wPin.border:Show()
                    else
                        wPin:SetSize(12, 12)
                        wPin.border:Hide()
                    end
                    
                    Core.HBDPins:AddWorldMapIconMap(addonName, wPin, worldMapID, node.x, node.y)
                end
            end
        end
    end
end
