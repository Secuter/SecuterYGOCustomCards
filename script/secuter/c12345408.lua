--Worldless Summoning
--Scripted by Secuter
local s,id=GetID()
function s.initial_effect(c)
	--send to grave
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DECKDES+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.tgcost)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
	--spsummon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
s.listed_series={0x20F}
--send to grave
function s.thfilter(c)
	return c:IsSetCard(0x20F) and c:IsRace(RACE_DRAGON) and c:IsAbleToHand()
end
function s.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND,0,1,e:GetHandler(),tp) end
	Duel.DiscardHand(tp,s.filter,1,1,REASON_COST+REASON_DISCARD,e:GetHandler(),tp)
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,5) end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,5)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.DiscardDeck(tp,5,REASON_EFFECT)>0 and Duel.GetOperatedGroup():IsExists(Card.IsLocation,1,nil,LOCATION_GRAVE) then
		local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
		if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.BreakEffect()
			local sg=g:Select(tp,1,1,nil)
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,sg)
		end
	end
end
--spsummon
function s.cfilter(c)
	return c:IsSetCard(0x20F) and c:IsRace(RACE_DRAGON) and c:GetOriginalLevel()==8 and c:IsAbleToDeck()
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x20F) and c:IsLevelBelow(3) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>=2
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,1,nil) 
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,2,nil,e,tp)
		and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND|LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_HAND|LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,nil)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local tc=g:Select(tp,1,1,nil):GetFirst()
		if Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_DECK|LOCATION_EXTRA)
		and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>=2 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND|LOCATION_GRAVE,0,nil,e,tp)
			if #sg>=2 then
				local tg=sg:Select(tp,2,2,nil)
				if #tg>0 then
					Duel.SpecialSummon(tg,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
				end
			end
		end
	end
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,3))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	aux.addTempLizardCheck(c,tp,s.lizfilter)
end
function s.splimit(e,c)
	return not c:IsSetCard(0x20F) and c:IsLocation(LOCATION_EXTRA)
end
function s.lizfilter(e,c)
	return not c:IsSetCard(0x20F)
end