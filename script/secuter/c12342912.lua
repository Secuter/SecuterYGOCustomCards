--Eternal Storm Network
--Scripted by Secuter
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={0x221}
function s.thfilter(c)
	return c:IsSetCard(0x221) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) and Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)>1
		and Duel.IsPlayerCanSpecialSummonMonster(tp,12342999,0x221,TYPES_TOKEN,300,300,1,RACE_THUNDER,ATTRIBUTE_WIND,POS_FACEUP_DEFENSE,1-tp)
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) or Duel.GetLocationCount(1-tp,LOCATION_MZONE)<2
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,12342999,0x221,TYPES_TOKEN,300,300,1,RACE_THUNDER,ATTRIBUTE_WIND,POS_FACEUP_DEFENSE,1-tp) then return end
	for i=1,2 do
		local token=Duel.CreateToken(tp,12342999)
		Duel.SpecialSummonStep(token,0,tp,1-tp,false,false,POS_FACEUP_DEFENSE)
	end
	Duel.SpecialSummonComplete()
	local sg=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	if #sg>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		sg=sg:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end