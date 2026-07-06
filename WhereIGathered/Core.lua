-- Core.lua
local addonName, addonTable = ...
local Core = addonTable.Core

Core.HBD = nil
Core.HBDPins = nil

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
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
            if WhereIGatheredDB.compassPosition == nil then
                WhereIGatheredDB.compassPosition = { point = "CENTER", x = 0, y = 180 }
            end
            
            -- Intentar cargar HereBeDragons
            Core.HBD = LibStub("HereBeDragons-2.0", true)
            Core.HBDPins = LibStub("HereBeDragons-Pins-2.0", true)
            
            if Core.HBD and Core.HBDPins then
                print("|cff00ccffWhereIGathered|r cargado correctamente.")
                
                -- Inicializar módulos
                if addonTable.Recorder.Init then addonTable.Recorder:Init() end
                if addonTable.Routing.Init then addonTable.Routing:Init() end
                if addonTable.Compass.Init then addonTable.Compass:Init() end
                if addonTable.MapPins.Init then addonTable.MapPins:Init() end
            else
                print("|cffcc0000WhereIGathered: Error al inicializar HereBeDragons.|r")
            end
        end
    elseif event == "ZONE_CHANGED_NEW_AREA" or event == "ZONE_CHANGED" or event == "ZONE_CHANGED_INDOORS" or event == "PLAYER_ENTERING_WORLD" then
        if Core.HBD and Core.HBDPins then
            if addonTable.MapPins.UpdatePins then
                addonTable.MapPins:UpdatePins()
            end
            if addonTable.Routing.OnZoneChanged then
                addonTable.Routing:OnZoneChanged()
            end
        end
    end
end)
