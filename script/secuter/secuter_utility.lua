SECUTER_IMPORTED = true

--[[
Add this at the start of all cards that use custom functions
if not SECUTER_IMPORTED then Duel.LoadScript("secuter_utility.lua") end
]]

--------------------------------------------
-- Import constants
--------------------------------------------

if not SECUTER_CONSTANTS_IMPORTED then Duel.LoadScript("secuter_constants.lua") end

--------------------------------------------

-- Utility functions

function Auxiliary.GetZonesCount(zones)
    local ct=0
    local i=1
    repeat
        if i&zones==i then ct=ct+1 end
        i=i*2
    until i > zones
    return ct
end

-- Debug functions

local player_log = {}
function Debug.UniqueMessage(tp, string, id)
    string = tostring(string)
    if tp~=nil and not player_log[tp] or player_log[tp]~=string then
        player_log[tp]=string
        if id then
            Debug.Message("tp"..tp.."-"..id..": "..string)
        else
            Debug.Message("tp"..tp..": "..string)
        end
    end
end

function Auxiliary.DecToHex(num)
    local hexstr = '0123456789abcdef'
    local s = ''
    while num > 0 do
        local mod = math.fmod(num, 16)
        s = string.sub(hexstr, mod+1, mod+1) .. s
        num = math.floor(num / 16)
    end
    if s == '' then s = '0' end
    return s
end
function Auxiliary.Dec2Hex(num)
    return Auxiliary.DecToHex(num)
end

function Auxiliary.HexToDec(num)
    return tonumber("0x"..num)
end
function Auxiliary.Hex2Dec(num)
    return tonumber("0x"..num)
end

function Auxiliary.GetSubId(id, add)
    return aux.HexToDec(aux.DecToHex(id)..add)
end

local TYPES = {}
TYPES[TYPE_MONSTER] = "MONSTER"
TYPES[TYPE_SPELL] = "SPELL"
TYPES[TYPE_TRAP] = "TRAP"
TYPES[TYPE_NORMAL] = "NORMAL"
TYPES[TYPE_EFFECT] = "EFFECT"
TYPES[TYPE_FUSION] = "FUSION"
TYPES[TYPE_RITUAL] = "RITUAL"
TYPES[TYPE_TRAPMONSTER] = "TRAPMONSTER"
TYPES[TYPE_SPIRIT] = "SPIRIT"
TYPES[TYPE_UNION] = "UNION"
TYPES[TYPE_GEMINI] = "GEMINI"
TYPES[TYPE_TUNER] = "TUNER"
TYPES[TYPE_SYNCHRO] = "SYNCHRO"
TYPES[TYPE_TOKEN] = "TOKEN"
TYPES[TYPE_MAXIMUM] = "MAXIMUM"
TYPES[TYPE_QUICKPLAY] = "QUICKPLAY"
TYPES[TYPE_CONTINUOUS] = "CONTINUOUS"
TYPES[TYPE_EQUIP] = "EQUIP"
TYPES[TYPE_FIELD] = "FIELD"
TYPES[TYPE_COUNTER] = "COUNTER"
TYPES[TYPE_FLIP] = "FLIP"
TYPES[TYPE_TOON] = "TOON"
TYPES[TYPE_XYZ] = "XYZ"
TYPES[TYPE_PENDULUM] = "PENDULUM"
TYPES[TYPE_SPSUMMON] = "SPSUMMON"
TYPES[TYPE_LINK] = "LINK"
TYPES[TYPE_SKILL] = "SKILL"
TYPES[TYPE_ACTION] = "ACTION"
TYPES[TYPE_PLUS] = "PLUS"
TYPES[TYPE_MINUS] = "MINUS"
TYPES[TYPE_ARMOR] = "ARMOR"
function Auxiliary.DecodeType(type)
    local out
    for i,v in pairs(TYPES) do
        if i&type==i then
            if out then out = out.."|"..TYPES[i]
            else out = TYPES[i] end
        end
    end
    return out or "NONE"
end

local ATTRIBUTES = {}
ATTRIBUTES[ATTRIBUTE_EARTH] = "EARTH"
ATTRIBUTES[ATTRIBUTE_WATER] = "WATER"
ATTRIBUTES[ATTRIBUTE_FIRE] = "FIRE"
ATTRIBUTES[ATTRIBUTE_WIND] = "WIND"
ATTRIBUTES[ATTRIBUTE_LIGHT] = "LIGHT"
ATTRIBUTES[ATTRIBUTE_DARK] = "DARK"
ATTRIBUTES[ATTRIBUTE_DIVINE] = "DIVINE"
function Auxiliary.DecodeAttribute(attr)
    local out
    for i,v in pairs(ATTRIBUTES) do
        if i&attr==i then
            if out then out = out.."|"..ATTRIBUTES[i]
            else out = ATTRIBUTES[i] end
        end
    end
    return out or "NONE"
end

local RACES = {}
RACES[RACE_WARRIOR] = "WARRIOR"
RACES[RACE_SPELLCASTER] = "SPELLCASTER"
RACES[RACE_FAIRY] = "FAIRY"
RACES[RACE_FIEND] = "FIEND"
RACES[RACE_ZOMBIE] = "ZOMBIE"
RACES[RACE_MACHINE] = "MACHINE"
RACES[RACE_AQUA] = "AQUA"
RACES[RACE_PYRO] = "PYRO"
RACES[RACE_ROCK] = "ROCK"
RACES[RACE_WINGEDBEAST] = "WINGEDBEAST"
RACES[RACE_PLANT] = "PLANT"
RACES[RACE_INSECT] = "INSECT"
RACES[RACE_THUNDER] = "THUNDER"
RACES[RACE_DRAGON] = "DRAGON"
RACES[RACE_BEAST] = "BEAST"
RACES[RACE_BEASTWARRIOR] = "BEASTWARRIOR"
RACES[RACE_DINOSAUR] = "DINOSAUR"
RACES[RACE_FISH] = "FISH"
RACES[RACE_SEASERPENT] = "SEASERPENT"
RACES[RACE_REPTILE] = "REPTILE"
RACES[RACE_PSYCHIC] = "PSYCHIC"
RACES[RACE_DIVINE] = "DIVINE"
RACES[RACE_CREATORGOD] = "CREATORGOD"
RACES[RACE_WYRM] = "WYRM"
RACES[RACE_CYBERSE] = "CYBERSE"
RACES[RACE_ILLUSION] = "ILLUSION"
RACES[RACE_CYBORG] = "CYBORG"
RACES[RACE_MAGICALKNIGHT] = "MAGICALKNIGHT"
RACES[RACE_HIGHDRAGON] = "HIGHDRAGON"
RACES[RACE_OMEGAPSYCHIC] = "OMEGAPSYCHIC"
RACES[RACE_CELESTIALWARRIOR] = "CELESTIALWARRIOR"
RACES[RACE_GALAXY] = "GALAXY"
RACES[RACE_YOKAI] = "YOKAI"
function Auxiliary.DecodeRace(race)
    local out
    for i,v in pairs(RACES) do
        if i&race==i then
            if out then out = out.."|"..RACES[i]
            else out = RACES[i] end
        end
    end
    return out or "NONE"
end

local REASONS = {}
REASONS[REASON_DESTROY] = "DESTROY"
REASONS[REASON_RELEASE] = "RELEASE"
REASONS[REASON_TEMPORARY] = "TEMPORARY"
REASONS[REASON_MATERIAL] = "MATERIAL"
REASONS[REASON_SUMMON] = "SUMMON"
REASONS[REASON_BATTLE] = "BATTLE"
REASONS[REASON_EFFECT] = "EFFECT"
REASONS[REASON_COST] = "COST"
REASONS[REASON_ADJUST] = "ADJUST"
REASONS[REASON_LOST_TARGET] = "LOST_TARGET"
REASONS[REASON_RULE] = "RULE"
REASONS[REASON_SPSUMMON] = "SPSUMMON"
REASONS[REASON_DISSUMMON] = "DISSUMMON"
REASONS[REASON_FLIP] = "FLIP"
REASONS[REASON_DISCARD] = "DISCARD"
REASONS[REASON_RDAMAGE] = "RDAMAGE"
REASONS[REASON_RRECOVER] = "RRECOVER"
REASONS[REASON_RETURN] = "RETURN"
REASONS[REASON_FUSION] = "FUSION"
REASONS[REASON_SYNCHRO] = "SYNCHRO"
REASONS[REASON_RITUAL] = "RITUAL"
REASONS[REASON_XYZ] = "XYZ"
REASONS[REASON_REPLACE] = "REPLACE"
REASONS[REASON_DRAW] = "DRAW"
REASONS[REASON_REDIRECT] = "REDIRECT"
REASONS[REASON_EXCAVATE] = "EXCAVATE"
REASONS[REASON_LINK] = "LINK"
REASONS[REASON_REVEAL] = "REVEAL"
REASONS[REASON_REUNION] = "REUNION"
REASONS[REASON_IGNITION] = "IGNITION"
REASONS[REASON_ARMORIZING] = "ARMORIZING"
REASONS[REASON_ECHO] = "ECHO"
REASONS[REASON_WANDERING] = "WANDERING"
function Auxiliary.DecodeReason(reason)
    local out
    for i,v in pairs(REASONS) do
        if i&reason==i then
            if out then out = out.."|"..REASONS[i]
            else out = REASONS[i] end
        end
    end
    return out or "NONE"
end

local SUMMON_TYPES = {}
SUMMON_TYPES[SUMMON_TYPE_NORMAL] = "NORMAL"
SUMMON_TYPES[SUMMON_TYPE_TRIBUTE] = "TRIBUTE"
SUMMON_TYPES[SUMMON_TYPE_GEMINI] = "GEMINI"
SUMMON_TYPES[SUMMON_TYPE_FLIP] = "FLIP"
SUMMON_TYPES[SUMMON_TYPE_SPECIAL] = "SPECIAL"
SUMMON_TYPES[SUMMON_TYPE_FUSION] = "FUSION"
SUMMON_TYPES[SUMMON_TYPE_RITUAL] = "RITUAL"
SUMMON_TYPES[SUMMON_TYPE_SYNCHRO] = "SYNCHRO"
SUMMON_TYPES[SUMMON_TYPE_XYZ] = "XYZ"
SUMMON_TYPES[SUMMON_TYPE_PENDULUM] = "PENDULUM"
SUMMON_TYPES[SUMMON_TYPE_LINK] = "LINK"
SUMMON_TYPES[SUMMON_TYPE_MAXIMUM] = "MAXIMUM"
SUMMON_TYPES[SUMMON_TYPE_REUNION] = "REUNION"
SUMMON_TYPES[SUMMON_TYPE_IGNITION] = "IGNITION"
SUMMON_TYPES[SUMMON_TYPE_ARMORIZING] = "ARMORIZING"
SUMMON_TYPES[SUMMON_TYPE_ECHO] = "ECHO"
SUMMON_TYPES[SUMMON_TYPE_EXCHANGE] = "EXCHANGE"
SUMMON_TYPES[SUMMON_TYPE_WANDERING] = "WANDERING"
function Auxiliary.DecodeSummonType(summon)
    local out
    for i,v in pairs(SUMMON_TYPES) do
        if i&summon==i then
            if out then out = out.."|"..SUMMON_TYPES[i]
            else out = SUMMON_TYPES[i] end
        end
    end
    return out or "NONE"
end

--------------------------------------------
-- Import modules
--------------------------------------------

if not ECHO_IMPORTED then Duel.LoadScript("proc_echo.lua") end
if not REUNION_IMPORTED then Duel.LoadScript("proc_reunion.lua") end
if not ARMOR_IMPORTED then Duel.LoadScript("proc_armor.lua") end
if not IGNITION_IMPORTED then Duel.LoadScript("proc_ignition.lua") end
if not REVERSE_XYZ_IMPORTED then Duel.LoadScript("proc_reverse_xyz.lua") end
if not RUNIC_IMPORTED then Duel.LoadScript("proc_runic.lua") end
if not EXCHANGE_IMPORTED then Duel.LoadScript("proc_exchange.lua") end
if not SYNCHRO_EXTRA_MATERIAL_IMPORTED then Duel.LoadScript("proc_synchro_extra_material.lua") end
if not UNION_EXTRA_IMPORTED then Duel.LoadScript("proc_union_extra.lua") end
if not WANDERING_IMPORTED then Duel.LoadScript("proc_wandering.lua") end

--------------------------------------------