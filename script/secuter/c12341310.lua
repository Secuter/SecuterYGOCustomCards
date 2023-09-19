--Blue-Eyes Dino Dragon
--Scripted by Secuter
if not SECUTER_IMPORTED then Duel.LoadScript("secuter_utility.lua") end
local s,id=GetID()
s.ReverseXyz=true
function s.initial_effect(c)
	c:EnableReviveLimit()
	ReverseXyz.AddProcedure(c,4,aux.FilterBoolFunctionEx(Card.IsRace,RACE_DRAGON),aux.FilterBoolFunctionEx(Card.IsRace,RACE_DRAGON))
	--normal monster
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_ONFIELD+LOCATION_GRAVE)
	e1:SetCode(EFFECT_ADD_TYPE)
	e1:SetValue(TYPE_NORMAL)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_REMOVE_TYPE)
	e2:SetValue(TYPE_EFFECT)
	c:RegisterEffect(e2)
end
