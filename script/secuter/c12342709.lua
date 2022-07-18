--Yoccol Invasion Vessel
--Scripted by Secuter
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--atk up
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.atktg)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
end
s.listed_series={0x21F}
--search
function s.filter(c)
	return c:IsSetCard(0x21F) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end
--atk
function s.atktg(e,c)
	return c:IsSetCard(0x21F)
end
function s.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x21F)
end
function s.atkval(e,c)
	local tp=e:GetHandlerPlayer()
	local ct=0
	local g=Duel.GetMatchingGroup(s.atkfilter,tp,LOCATION_MZONE,0,nil)
	if #g==0 then return 0 end
	if g:IsExists(Card.IsType,1,nil,TYPE_RITUAL) then ct=ct+1 end
	if g:IsExists(Card.IsType,1,nil,TYPE_FUSION) then ct=ct+1 end
	if g:IsExists(Card.IsType,1,nil,TYPE_SYNCHRO) then ct=ct+1 end
	if g:IsExists(Card.IsType,1,nil,TYPE_XYZ) then ct=ct+1 end
	return ct*500
end