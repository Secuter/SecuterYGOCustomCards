--Undead Eagle Overseer Stormcaller
--Scripted by Secuter
local s,id=GetID()
function s.initial_effect(c)
	--negate S/T
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.con1)
	e1:SetTarget(s.negtg)
	e1:SetOperation(s.negop)
	c:RegisterEffect(e1)
	--negate mon
	local e2=e1:Clone()
	e2:SetCondition(s.con2)
	c:RegisterEffect(e2)
end
--negate S/T
function s.filter1(c)
	return c:IsFaceup() and c:IsRace(RACE_ZOMBIE)
end
function s.con1(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_MZONE,0,1,nil)
		and re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and Duel.IsChainNegatable(ev)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
--negate mon
function s.filter2(c)
	return c:IsFaceup() and c:IsRace(RACE_WINGEDBEAST)
end
function s.con2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_MZONE,0,1,nil)
		and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
end