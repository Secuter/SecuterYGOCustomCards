--Asura Field
--Scripted by Secuter
if not SECUTER_IMPORTED then Duel.LoadScript("secuter_utility.lua") end
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--activate limit
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCondition(s.cedcon)
	e2:SetOperation(s.cedop)
	c:RegisterEffect(e2)
	--cannot disable summon
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCode(EVENT_SUMMON)
	e3:SetOperation(s.chainop)
	c:RegisterEffect(e3)
	--atk
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetRange(LOCATION_FZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetCondition(s.effcon)
	e4:SetValue(s.atkval)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e5)
	--spsummon
	local e6=Effect.CreateEffect(c)
	e6:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e6:SetDescription(aux.Stringid(id,0))
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e6:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e6:SetCode(EVENT_TO_GRAVE)
	e6:SetCountLimit(1,id)
	e6:SetCondition(s.spcon)
	e6:SetTarget(s.sptg)
	e6:SetOperation(s.spop)
	c:RegisterEffect(e6)
end
s.listed_series={SET_ASURA}
--anti chain
function s.cedcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:GetFirst():IsSetCard(SET_ASURA) and eg:GetFirst():IsLevelAbove(7)
end
function s.cedop(e,tp,eg,ep,ev,re,r,rp)
	Duel.SetChainLimitTillChainEnd(s.chlimit)
end
function s.chlimit(re,rp,tp)
	return re:GetHandler():IsSetCard(SET_ASURA)
end

--anti negate
function s.chainop(e,tp,eg,ep,ev,re,r,rp)
	local rc=eg:GetFirst()
	if rc:IsSetCard(SET_ASURA) and rc:IsLevelAbove(7) and (rc:GetSummonType()==SUMMON_TYPE_NORMAL or rc:GetSummonType()==SUMMON_TYPE_TRIBUTE) then
		Duel.SetChainLimit(s.chainlm)
	end
end
function s.chainlm(e,rp,tp)
	return false
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_FZONE) and c:IsPreviousPosition(POS_FACEUP)
		and rp~=tp and bit.band(r,REASON_EFFECT)==REASON_EFFECT
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_ASURA) and c:IsLevelAbove(7) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

function s.target(e,c)
	return c:IsLevelAbove(7) and c:IsSummonType(SUMMON_TYPE_NORMAL)
end
function s.effect(e,re)
	return re:IsActiveType(TYPE_MONSTER) and not re:GetHandler():IsAttribute(e:GetHandler():GetAttribute())
end
function s.battle(e,c)
	return not c:IsAttribute(e:GetHandler():GetAttribute())
end

function s.effcon(e)
	local tp=e:GetHandlerPlayer()
	local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_MZONE,0,nil,TYPE_MONSTER)
	local ct=0
	for i=0,10 do
		local t=2^i
		if g:IsExists(Card.IsAttribute,1,nil,t) then
			ct=ct+1
		end
	end
	return ct>=2
end
function s.atkval(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsType,e:GetHandlerPlayer(),LOCATION_MZONE,0,nil,TYPE_MONSTER)
	local ct=0
	for i=0,10 do
		local t=2^i
		if g:IsExists(Card.IsAttribute,1,nil,t) then
			ct=ct+1
		end
	end
	return ct*200
end
