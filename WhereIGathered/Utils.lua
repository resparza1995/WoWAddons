-- Utils.lua
local addonName, addonTable = ...
local Utils = addonTable.Utils

-- Wrapper seguro para obtener el nombre del hechizo (compatible con WoW 11.0+ Midnight y anteriores)
function Utils.GetSpellName(spellID)
    if not spellID then return "" end
    if C_Spell and C_Spell.GetSpellInfo then
        local info = C_Spell.GetSpellInfo(spellID)
        return info and info.name or ""
    elseif _G.GetSpellInfo then
        return _G.GetSpellInfo(spellID) or ""
    end
    return ""
end
