--Abyss Challenger Entrance (FIELD)
--Scripted by Secuter
local s,id=GetID()
function s.initial_effect(c)
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e1:SetCost(s.cost)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
	--remove
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCondition(s.rmcon)
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)
end
s.listed_series={0x217}
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetDecktopGroup(tp,3)
    if chk==0 then return g:FilterCount(Card.IsAbleToRemoveAsCost,nil,POS_FACEDOWN)==3
        and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=4 end
    Duel.DisableShuffleCheck()
    Duel.Remove(g,POS_FACEDOWN,REASON_COST)
end
function s.thfilter(c)
	return c:IsSetCard(0x217) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetAttacker()
	local dc=Duel.GetAttackTarget()
	return tc:IsSetCard(0x217) or (dc and dc:IsFaceup() and dc:IsSetCard(0x217))
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local g1=Duel.GetDecktopGroup(tp,1)
    local g2=Duel.GetDecktopGroup(1-tp,1)
    if chk==0 then return g1:FilterCount(Card.IsAbleToRemove,nil,POS_FACEDOWN)==1
        and g2:FilterCount(Card.IsAbleToRemove,nil,POS_FACEDOWN)==1 end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g1,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g2,1,1-tp,LOCATION_DECK)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
    local g1=Duel.GetDecktopGroup(tp,1)
    local g2=Duel.GetDecktopGroup(1-tp,1)
	if #g1>0 and #g2>0 then
        g1:Merge(g2)
        Duel.DisableShuffleCheck()
        Duel.Remove(g1,POS_FACEDOWN,REASON_EFFECT)
    end
end