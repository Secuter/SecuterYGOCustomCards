--Hydra Barrage
--Scripted by Secuter
if not SECUTER_IMPORTED then Duel.LoadScript("secuter_utility.lua") end
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target1)
	e1:SetOperation(s.activate1)
	e1:SetLabel(1)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e2:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e2:SetCost(s.cost)
	e2:SetTarget(s.target2)
	e2:SetOperation(s.activate2)
	e2:SetLabel(2)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_ACTIVATE)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e3:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e3:SetCost(s.cost)
	e3:SetTarget(s.target3)
	e3:SetOperation(s.activate3)
	e3:SetLabel(3)
	c:RegisterEffect(e3)
end
s.listed_series={SET_HYDRA}
s.check=false

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	s.check=true
	if chk==0 then return true end
end
function s.filter1(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToRemove()
end
function s.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=e:GetLabel()
	local mg=Duel.GetOverlayGroup(tp,1,0)
	if chk==0 then
		if not s.check then return false end
		s.check=false
		return #mg>=ct and Duel.IsExistingMatchingCard(s.filter1,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVEXYZ)
	local sg=mg:Select(tp,ct,ct,nil)
	Duel.SendtoGrave(sg,REASON_COST)
	local g=Duel.GetMatchingGroup(s.filter1,tp,0,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function s.activate1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.filter1,tp,0,LOCATION_ONFIELD,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
function s.filter2(c)
	return c:IsAbleToRemove()
end
function s.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=e:GetLabel()
	local mg=Duel.GetOverlayGroup(tp,1,0)
	if chk==0 then
		if not s.check then return false end
		s.check=false
		return #mg>=ct and Duel.IsExistingMatchingCard(s.filter2,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVEXYZ)
	local sg=mg:Select(tp,ct,ct,nil)
	Duel.SendtoGrave(sg,REASON_COST)
	local g=Duel.GetMatchingGroup(s.filter2,tp,0,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function s.activate2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.filter2,tp,0,LOCATION_MZONE,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
function s.target3(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=e:GetLabel()
	local mg=Duel.GetOverlayGroup(tp,1,0)
	if chk==0 then
		if not s.check then return false end
		s.check=false
		return #mg>=ct end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVEXYZ)
	local sg=mg:Select(tp,ct,ct,nil)
	Duel.SendtoGrave(sg,REASON_COST)
end
function s.activate3(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_REPTILE))
	e1:SetValue(s.efilter)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.efilter(e,re)
	return e:GetOwnerPlayer()~=re:GetOwnerPlayer() and re:IsActiveType(TYPE_SPELL)
end
