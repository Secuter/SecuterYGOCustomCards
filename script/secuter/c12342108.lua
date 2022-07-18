--Normal
--Scripted by Secuter
local s,id=GetID()
s.IsReunion=true
if not REUNION_IMPORTED then Duel.LoadScript("proc_reunion.lua") end
function s.initial_effect(c)
	c:EnableReviveLimit()
	Reunion.AddProcedure(c,nil,2,99)
end