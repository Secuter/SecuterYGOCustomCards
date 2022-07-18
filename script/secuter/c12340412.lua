--Hydra
--Scripted by Secuter
local s,id=GetID()
function s.initial_effect(c)
	--xyz summon
	Xyz.AddProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_REPTILE),6,2,s.ovfilter,aux.Stringid(id,0))
	c:EnableReviveLimit()
	--indestructable
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetCondition(s.cond)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
s.listed_names={id}
function s.ovfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_REPTILE) and c:IsType(TYPE_XYZ) and c:IsRankBelow(6) and c:GetCode()~=id
end

function s.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_REPTILE)
end
function s.nfilter(c)
	return c:IsType(TYPE_MONSTER) and c:GetRace()~=RACE_REPTILE
end
function s.cond(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetOverlayCount()>0
        and Duel.GetMatchingGroupCount(s.filter,tp,LOCATION_GRAVE,0,nil)>0
        and not Duel.IsExistingMatchingCard(s.nfilter,tp,LOCATION_GRAVE,0,1,nil)
end