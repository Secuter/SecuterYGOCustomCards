--External Worlds Lord
--Scripted by Secuter
if not SECUTER_IMPORTED then Duel.LoadScript("secuter_utility.lua") end
local s,id=GetID()
function s.initial_effect(c)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.cond)
	c:RegisterEffect(e1)
	--cannot be battle target
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetValue(s.tg)
	c:RegisterEffect(e2)
end
s.listed_series={SET_EXTERNAL_WORLDS}

function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(SET_EXTERNAL_WORLDS)
end
function s.filter2(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DARK)
end
function s.cond(e,c)
	if c==nil then return true end
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		and	Duel.IsExistingMatchingCard(s.filter,c:GetControler(),LOCATION_MZONE,0,1,nil)
		and Duel.GetMatchingGroupCount(s.filter2,c:GetControler(),LOCATION_MZONE,0,nil)==0
end

function s.tg(e,c)
	return c~=e:GetHandler() and c:IsFaceup() and c:IsSetCard(SET_EXTERNAL_WORLDS)
end
