--Abysmal Hidden Reef
--Scripted by Secuter
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_names={CARD_UMI}
function s.synfilter(c,mg,tp,chk)
	return c:IsAttribute(ATTRIBUTE_WATER) and (not chk or Duel.GetLocationCountFromEx(tp,tp,mg,c)>0) and (not mg or c:IsSynchroSummonable(mg))
end
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_SEASERPENT) and c:IsCanBeEffectTarget(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.rescon(syng)
	return function(sg,e,tp,mg)
		return syng:IsExists(IsSynchroSummonable,1,nil,sg)
	end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local syng=Duel.GetMatchingGroup(s.synfilter,tp,LOCATION_EXTRA,0,nil,nil,tp)
	local cancelcon=s.rescon(syng)
	if chkc then return chkc:IsControler(tp) and c:IsLocation(LOCATION_GRAVE) and c:IsRace(RACE_SEASERPENT) and chkc:IsCanBeSpecialSummoned(e,0,tp,false,false) and cancelcon(Group.FromCards(chkc)) end
	local mg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
	local min=math.min(math.min(Duel.GetLocationCount(tp,LOCATION_MZONE),Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) and 1 or 99),1)
	local ct=1
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if Duel.IsEnvironment(CARD_UMI) and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ct=2 end
	if ft<ct then ct=ft end
	if chk==0 then return ct>0 and Duel.IsPlayerCanSpecialSummonCount(tp,1)
		and aux.SelectUnselectGroup(mg,e,tp,1,ct,cancelcon,0) end
	local sg=aux.SelectUnselectGroup(mg,e,tp,1,ct,cancelcon,chk,tp,HINTMSG_SPSUMMON,cancelcon)
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,sg,#sg,0,0)
end
function s.relfilter(c,e,tp)
	return c:IsRelateToEffect(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetTargetCards(e):Filter(s.relfilter,nil,e,tp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<#g or #g==0 or (Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) and #g>1) then return end
	for tc in aux.Next(g) do
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		tc:RegisterEffect(e2)
	end
	Duel.SpecialSummonComplete()
	Duel.BreakEffect()	
	local syng=Duel.GetMatchingGroup(s.synfilter,tp,LOCATION_EXTRA,0,nil,g,tp,true)
	if #syng>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=syng:Select(tp,1,1,nil)
		Duel.SynchroSummon(tp,sg:GetFirst(),tc)
	end
end
