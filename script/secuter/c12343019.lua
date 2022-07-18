--Hailshift Hailstorm
--Scripted by Secuter
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetCondition(s.cond1)
	e1:SetCost(s.cost1)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCondition(s.cond2)
	e2:SetCost(s.cost2)
	c:RegisterEffect(e2)
	--act in hand
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	c:RegisterEffect(e3)
end
s.listed_series={0x224}
function s.cond1(e)
	return Duel.GetFlagEffect(e:GetHandlerPlayer(),id)==0 and Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsSetCard,0x224),e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
function s.cond2(e)
	return Duel.GetFlagEffect(e:GetHandlerPlayer(),id)==0	and Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_MZONE,0)==0
end
function s.cfilter(c)
	return c:IsSetCard(0x224) and c:IsType(TYPE_MONSTER) and not c:IsPublic()
end
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	--activate from hand OPT
	if e:GetHandler():IsStatus(STATUS_ACT_FROM_HAND) then
		Duel.RegisterFlagEffect(tp,id,RESET_CHAIN,0,1)
	end
end
function s.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil) end
	--activate from hand OPT
	if e:GetHandler():IsStatus(STATUS_ACT_FROM_HAND) then
		Duel.RegisterFlagEffect(tp,id,RESET_CHAIN,0,1)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	Duel.ConfirmCards(1-tp,g)
	Duel.ShuffleHand(tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() end
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--activate from hand OPT
	if e:GetHandler():IsStatus(STATUS_ACT_FROM_HAND) then
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	end
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end