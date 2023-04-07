--Armorizing Curse
--Scripted by Secuter
local s,id=GetID()
if not ARMOR_IMPORTED then Duel.LoadScript("proc_armor.lua") end
s.ArmorAtk=-1000
s.ArmorDef=-1000
s.IsArmor=true
function s.initial_effect(c)
	--Armor
	Armor.AddProcedure(c,s,true)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--reduce armor atk/def
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_ARMORATK_REP)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(1,1)
	e2:SetValue(-1000)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_ARMORDEF_REP)
	c:RegisterEffect(e3)
end