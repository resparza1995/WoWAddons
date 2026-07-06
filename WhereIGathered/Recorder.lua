-- Recorder.lua
local addonName, addonTable = ...
local Recorder = addonTable.Recorder
local Core = addonTable.Core
local Utils = addonTable.Utils

local DUPLICATE_THRESHOLD = 0.01 -- Distancia de mapa relativa (~50-100m)

function Recorder:Init()
    local frame = CreateFrame("Frame")
    frame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
    frame:SetScript("OnEvent", function(self, event, ...)
        if event == "UNIT_SPELLCAST_SUCCEEDED" then
            local unitTarget, castGUID, spellID = ...
            if unitTarget == "player" then
                -- Excluir herbología de cadáveres de Midnight (spell ID 32605)
                if spellID == 32605 then
                    return
                end
                
                local spellName = Utils.GetSpellName(spellID)
                local nodeType = nil
                
                local spellNameLower = spellName:lower()
                -- Detección de Minería
                if spellNameLower:find("miner") or spellNameLower:find("mining") then
                    nodeType = "mine"
                -- Detección de Herboristería (variantes en español/inglés)
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
                                
                                -- Verificar si ya existe un nodo cercano
                                local nodeExists = false
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
                                    if addonTable.MapPins.UpdatePins then
                                        addonTable.MapPins:UpdatePins()
                                    end
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
end

function Recorder.RemoveDuplicates()
    if not WhereIGatheredDB then return 0 end
    
    local totalDuplicates = 0
    
    for mapID, nodes in pairs(WhereIGatheredDB) do
        if mapID ~= "showPins" and mapID ~= "compassPosition" and type(nodes) == "table" then
            local cleanedNodes = {}
            
            for _, node in ipairs(nodes) do
                local isDuplicate = false
                for _, cleanNode in ipairs(cleanedNodes) do
                    local distance = math.sqrt((node.x - cleanNode.x)^2 + (node.y - cleanNode.y)^2)
                    if distance < DUPLICATE_THRESHOLD then
                        isDuplicate = true
                        totalDuplicates = totalDuplicates + 1
                        break
                    end
                end
                if not isDuplicate then
                    table.insert(cleanedNodes, node)
                end
            end
            
            WhereIGatheredDB[mapID] = cleanedNodes
        end
    end
    
    return totalDuplicates
end
