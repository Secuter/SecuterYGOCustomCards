--Abyss Challenger 
--Scripted by Secuter
local s,id=GetID()
function s.initial_effect(c)
    --Activate
    local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.con)
    e1:SetCost(s.cost)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end
s.listed_series={0x217}
function s.con(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsSetCard,0x217),tp,LOCATION_MZONE,0,1,nil) then return false end
	return Duel.IsChainNegatable(ev)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetDecktopGroup(tp,3)
    if chk==0 then return g:FilterCount(Card.IsAbleToRemoveAsCost,nil,POS_FACEDOWN)==3
        and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=4 end
    Duel.DisableShuffleCheck()
    Duel.Remove(g,POS_FACEDOWN,REASON_COST)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(aux.FilterFaceupFunction(Card.IsSetCard,0x217),tp,LOCATION_MZONE,0,nil)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) and g:GetClassCount(Card.GetCode)>=3 then
        Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)
	end
end