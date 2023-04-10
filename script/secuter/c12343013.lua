--Hailshift Dragon
--Scripted by Secuter
if not EXCHANGE_IMPORTED then Duel.LoadScript("proc_exchange.lua") end
local s,id=GetID()
s.Exchange=true
function s.initial_effect(c)
	Exchange.Enable(c,s,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_WATER))
	--exchange summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.descon)
	e1:SetCost(s.descost)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	--to hand
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
s.listed_names={id}
s.listed_series={0x224}
--destroy
function s.descon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_TYPE_EXCHANGE
end
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	return true
end
function s.cfilter(c)
	return c:IsSetCard(0x224) and c:IsAbleToRemoveAsCost()
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=math.min(2,Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD))
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		return ct>0 and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,1,ct,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)	
	local og=Duel.GetOperatedGroup()
	e:SetLabel(#og)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,#og,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	if #sg<ct then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=sg:Select(tp,ct,ct,nil)
	Duel.Destroy(g,REASON_EFFECT)
end
--to hand
function s.filter(c,tp)
	return c:GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_TYPE_EXCHANGE and c:IsSummonPlayer(tp)
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.filter,1,nil,e:GetHandlerPlayer())
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end