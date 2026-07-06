-- Compass.lua
local addonName, addonTable = ...
local Compass = addonTable.Compass
local Core = addonTable.Core
local Routing = addonTable.Routing

local frame = nil
local arrow = nil
local textDistance = nil
local textNode = nil
local updateInterval = 0.05 -- 20 FPS para suavidad

function Compass:Init()
    if frame then return end
    
    -- Crear el frame principal
    frame = CreateFrame("Frame", "WhereIGatheredCompassFrame", UIParent, "BackdropTemplate")
    frame:SetSize(70, 70)
    
    -- Configurar arrastre y posición
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    
    local pos = WhereIGatheredDB.compassPosition
    if pos and pos.y == 100 and pos.x == 0 and pos.point == "CENTER" then
        pos.y = 180
    end
    pos = pos or { point = "CENTER", x = 0, y = 180 }
    frame:ClearAllPoints()
    frame:SetPoint(pos.point, UIParent, pos.point, pos.x, pos.y)
    
    frame:SetScript("OnDragStart", function(self)
        self:StartMoving()
    end)
    
    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local point, _, _, x, y = self:GetPoint()
        WhereIGatheredDB.compassPosition = { point = point, x = x, y = y }
    end)
    
    -- Click derecho para saltar el nodo actual
    frame:SetScript("OnMouseUp", function(self, button)
        if button == "RightButton" then
            Routing:SkipNode()
        end
    end)
    
    -- Tooltip explicativo
    frame:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
        GameTooltip:AddLine("|cff00ccffWhereIGathered: Brújula|r")
        GameTooltip:AddLine("Arrastra con |cff00ff00Click Izquierdo|r para mover.")
        GameTooltip:AddLine("Haz |cffff9900Click Derecho|r para saltar este nodo.")
        GameTooltip:Show()
    end)
    frame:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)
    
    -- 1. Borde Dorado (Círculo exterior)
    local border = frame:CreateTexture(nil, "BACKGROUND")
    border:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask") -- Máscara circular
    border:SetSize(66, 66)
    border:SetPoint("CENTER", frame, "CENTER", 0, 0)
    border:SetVertexColor(0.85, 0.65, 0.12, 0.95) -- Dorado premium mate
    
    -- 2. Fondo Oscuro (Círculo interior)
    local bg = frame:CreateTexture(nil, "BACKGROUND", nil, 1)
    bg:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask") -- Máscara circular
    bg:SetSize(60, 60)
    bg:SetPoint("CENTER", frame, "CENTER", 0, 0)
    bg:SetVertexColor(0.08, 0.08, 0.1, 0.88) -- Gris oscuro azulado traslúcido
    
    -- Flecha de navegación en el centro
    arrow = frame:CreateTexture(nil, "ARTWORK")
    arrow:SetTexture("Interface\\Minimap\\MiniMap-DeadArrow")
    arrow:SetSize(42, 42)
    arrow:SetPoint("CENTER", frame, "CENTER", 0, 0)
    
    -- Texto de Distancia
    textDistance = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    local fontName, fontSize, fontFlags = textDistance:GetFont()
    textDistance:SetFont(fontName, 15, "OUTLINE")
    textDistance:SetPoint("BOTTOM", frame, "BOTTOM", 0, -18)
    textDistance:SetTextColor(1, 1, 1, 1) -- Blanco
    
    -- Texto del Nombre del Nodo
    textNode = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    local fontNameN, fontSizeN, fontFlagsN = textNode:GetFont()
    textNode:SetFont(fontNameN, 11, "OUTLINE")
    textNode:SetPoint("TOP", frame, "TOP", 0, 14)
    textNode:SetTextColor(0, 0.8, 1, 1) -- Azul brillante
    
    frame:Hide()
    
    -- Loop de actualización
    local elapsedTimer = 0
    frame:SetScript("OnUpdate", function(self, elapsed)
        elapsedTimer = elapsedTimer + elapsed
        if elapsedTimer >= updateInterval then
            elapsedTimer = 0
            Compass:UpdateUpdateLoop()
        end
    end)
end

function Compass:Show()
    if not frame then self:Init() end
    frame:Show()
    self:UpdateTarget()
end

function Compass:Hide()
    if frame then
        frame:Hide()
    end
end

function Compass:UpdateTarget()
    if not frame or not frame:IsShown() then return end
    
    local target = Routing:GetCurrentTarget()
    if not target then
        self:Hide()
        return
    end
    
    local nodeLabel = (target.type == "mine" and "Mina" or "Planta")
    local total = #Routing.activeRoute
    local index = Routing.currentTargetIndex
    textNode:SetText(string.format("%s (%d/%d)", nodeLabel, index, total))
end

function Compass:UpdateUpdateLoop()
    if not Routing:IsActive() then
        self:Hide()
        return
    end
    
    local mapID = C_Map.GetBestMapForUnit("player")
    if not mapID then return end
    
    local px, py = nil, nil
    if Core.HBD then
        px, py = Core.HBD:GetPlayerZonePosition()
    end
    
    if not px or not py then
        local position = C_Map.GetPlayerMapPosition(mapID, "player")
        if position then
            px, py = position:GetXY()
        end
    end
    
    if not px or not py then return end
    
    local target = Routing:GetCurrentTarget()
    if not target then return end
    
    local distance = nil
    local deltaX, deltaY = nil, nil
    
    if Core.HBD then
        distance, deltaX, deltaY = Core.HBD:GetZoneDistance(mapID, px, py, target.x, target.y)
    end
    
    -- Fallback si HereBeDragons no puede calcular distancias
    if not distance or not deltaX or not deltaY then
        deltaX = target.x - px
        deltaY = py - target.y
        distance = math.sqrt(deltaX^2 + deltaY^2) * 10000 -- Distancia aprox
    end
    
    -- Mostrar la distancia en yardas
    textDistance:SetText(string.format("%.0f yd", distance))
    
    -- Si estamos a menos de 30 yardas, ¡hemos llegado! (Aumentado a 30 para mayor comodidad en monturas rápidas)
    if distance <= 30 then
        Routing:AdvanceRoute()
        return
    end
    
    -- Calcular la rotación
    local playerFacing = GetPlayerFacing()
    if not playerFacing then return end
    
    local angleToTarget = math.atan2(deltaX, deltaY)
    local rotation = -playerFacing - angleToTarget
    arrow:SetRotation(rotation)
end
