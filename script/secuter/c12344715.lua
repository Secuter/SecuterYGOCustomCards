--Blessing of the Primeval Forest
--Scripted by Secuter
if not SECUTER_IMPORTED then Duel.LoadScript("secuter_utility.lua") end
local s,id=GetID()
function s.initial_effect(c)
	--change position + search
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_PRIMEVAL_FOREST}
--change position + search
function s.thfilter(c,cid)
	return c:IsSetCard(SET_PRIMEVAL_FOREST) and c:IsType(TYPE_MONSTER) and not c:IsCode(cid) and c:IsAbleToHand()
end
function s.filter(c,tp)
	return c:IsSetCard(SET_PRIMEVAL_FOREST) and c:IsCanTurnSet()
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,c:GetCode())
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
	local tc=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil,tp):GetFirst()
	e:SetLabel(tc:GetCode())
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and not tc:IsPosition(POS_FACEDOWN_DEFENSE) and Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)>0 then
		local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil,e:GetLabel())
		if #g>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local tg=g:Select(tp,1,1,nil)
			if tg then
				Duel.SendtoHand(tg,tp,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,tg)
			end
		end
	end
end
