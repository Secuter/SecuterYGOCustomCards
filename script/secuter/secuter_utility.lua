SECUTER_IMPORTED = true

--[[
if not SECUTER_IMPORTED then Duel.LoadScript("secuter_utility.lua") end
]]

if not SECUTER_CONSTANTS_IMPORTED then Duel.LoadScript("secuter_constants.lua") end
if not ECHO_IMPORTED then Duel.LoadScript("proc_echo.lua") end
if not REUNION_IMPORTED then Duel.LoadScript("proc_reunion.lua") end
if not ARMOR_IMPORTED then Duel.LoadScript("proc_armor.lua") end
if not IGNITION_IMPORTED then Duel.LoadScript("proc_ignition.lua") end
if not REVERSE_XYZ_IMPORTED then Duel.LoadScript("proc_reverse_xyz.lua") end
if not RUNIC_IMPORTED then Duel.LoadScript("proc_runic.lua") end
if not EXCHANGE_IMPORTED then Duel.LoadScript("proc_exchange.lua") end
if not SYNCHRO_EXTRA_MATERIAL_IMPORTED then Duel.LoadScript("proc_synchro_extra_material.lua") end
if not UNION_EXTRA_IMPORTED then Duel.LoadScript("proc_union_extra.lua") end
if not QUICKWARP_IMPORTED then Duel.LoadScript("proc_quickwarp.lua") end

-- utility functions
function Auxiliary.GetZonesCount(zones)
    local ct=0
    local i=1
    repeat
        if i&zones==i then ct=ct+1 end
        i=i*2
    until i > zones
    return ct
end