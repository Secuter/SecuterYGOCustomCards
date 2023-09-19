--Amorphiend Lost Home
--Scripted by Secuter
if not SECUTER_IMPORTED then Duel.LoadScript("secuter_utility.lua") end
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--chain limit
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_FZONE)
	e2:SetOperation(s.chainop)
	c:RegisterEffect(e2)
end
s.listed_names={12344100}
s.listed_series={SET_AMORPHIEND}
--search
function s.thfilter(c)
	return c:IsCode(12344100) and c:IsAbleToHand()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local tg=Duel.GetFirstMatchingCard(s.thfilter,tp,LOCATION_DECK,0,nil)
	if tg and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tg)
	end
end
--chain limit
function s.filter(c)
	return c:IsType(TYPE_EQUIP) and c:IsSetCard(SET_AMORPHIEND)
end
function s.chainop(e,tp,eg,ep,ev,re,r,rp)
	if re:GetHandler():GetEquipGroup():IsExists(s.filter,1,nil) then
		Duel.SetChainLimit(s.chainlm)
	end
end
function s.chainlm(e,rp,tp)
	return tp==rp
end
