--Normal
--Scripted by Secuter
if not SECUTER_IMPORTED then Duel.LoadScript("secuter_utility.lua") end
local s,id=GetID()
s.Reunion=true
function s.initial_effect(c)
	c:EnableReviveLimit()
	Reunion.AddProcedure(c,nil,2,99)
end
