--Dark King Servant
--Scripted by Secuter
if not SECUTER_IMPORTED then Duel.LoadScript("secuter_utility.lua") end
local s,id=GetID()
function s.initial_effect(c)
	--ritual material from grave
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_EXTRA_RITUAL_MATERIAL)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCondition(s.excon)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--ritual cost
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_RITUAL_LEVEL)
	e2:SetValue(s.rlevel)
	c:RegisterEffect(e2)
end
s.listed_series={SET_DARK_KING}
function s.excon(e)
	return not Duel.IsPlayerAffectedByEffect(e:GetHandlerPlayer(),69832741)
end

function s.rlevel(e,c)
	local lv=e:GetHandler():GetLevel()
	if c:IsSetCard(SET_DARK_KING) then
		local clv=c:GetLevel()
		return lv*65536+clv
	else return lv end
end
