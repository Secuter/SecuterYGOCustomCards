--Fluidsphere Sanctuary
--Scripted by Secuter
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--extra summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e2:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCondition(s.con(1))
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x3204))
	c:RegisterEffect(e2)
	--indes
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetTargetRange(LOCATION_SZONE,0)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCondition(s.con(2))
	e3:SetTarget(s.indtg)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	--cannot set
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_SSET)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetTargetRange(0,1)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCondition(s.con(3))
	--e4:SetTarget(aux.TRUE)
	c:RegisterEffect(e4)
	--intarget
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e5:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e5:SetTargetRange(LOCATION_MZONE,0)
	e5:SetRange(LOCATION_FZONE)
	e5:SetCondition(s.con(4))
	e5:SetTarget(s.immtg)
	e5:SetValue(aux.tgoval)
	c:RegisterEffect(e5)
	--sp limit
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e6:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e6:SetTargetRange(0,1)
	e6:SetRange(LOCATION_FZONE)
	e6:SetCondition(s.con(5))
	e6:SetTarget(s.splimit)
	c:RegisterEffect(e6)
	local e7=aux.createContinuousLizardCheck(c,LOCATION_FZONE,nil,0xff,0xff)
	e7:SetCondition(s.con(5))
	c:RegisterEffect(e7)
end
s.listed_series={0x3204}
function s.con(ct)
	return function (e,tp,eg,ep,ev,re,r,rp)
		local g=Duel.GetMatchingGroup(aux.FilterFaceupFunction(Card.IsType,TYPE_CONTINUOUS),e:GetHandlerPlayer(),LOCATION_SZONE,0,nil)
		return g:GetClassCount(Card.GetCode)>=ct
	end
end
--indes
function s.indtg(e,c)
	return c:IsFaceup() and c:IsType(TYPE_CONTINUOUS)
end
--intarget
function s.immtg(e,c)
	return c:IsSetCard(0x3204)
end
--sp limit
function s.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA)
end