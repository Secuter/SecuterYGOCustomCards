--Dark King Servant
--Scripted by Secuter
local s,id=GetID()
function s.initial_effect(c)
	--ritual material from grave
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EXTRA_RITUAL_MATERIAL)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--ritual cost
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_RITUAL_LEVEL)
	e2:SetValue(s.rlevel)
	c:RegisterEffect(e2)
end
s.listed_series={0x205}

function s.rlevel(e,c)
	local lv=e:GetHandler():GetLevel()
	if c:IsSetCard(0x205) then
		local clv=c:GetLevel()
		return lv*65536+clv
	else return lv end
end