--Runic Encription
--Scripted by Secuter
if not SECUTER_IMPORTED then Duel.LoadScript("secuter_utility.lua") end
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
--search
function s.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsRunic() and c:IsAbleToDeck() and not c:IsPublic()
end
function s.thfilter(c)
	return c:IsAbleToHand() and c:IsType(TYPE_MONSTER) and c:IsRunic()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND,0,1,e:GetHandler())
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local rg=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_HAND,0,1,1,nil)
	if rg:GetFirst() then
		Duel.ConfirmCards(1-tp,rg)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local tg=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if tg:GetFirst() then
			Duel.SendtoHand(tg,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,tg)
			Duel.BreakEffect()
			Duel.SendtoDeck(rg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
end
