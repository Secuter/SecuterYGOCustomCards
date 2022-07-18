--Dark Sovereign Return
--Scripted by Secuter
local s,id=GetID()
s.IsRunic=true
s.RunicEffect={}
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Runic Effect
	local re=Effect.CreateEffect(c)
	re:SetDescription(aux.Stringid(id,0))
	re:SetCategory(CATEGORY_SPECIAL_SUMMON)
	re:SetTarget(s.sptg)
	re:SetOperation(s.spop)
	s.RunicEffect=re
end
s.listed_series={0x230}
--xyz
function s.matfilter(c,e,tp)
	return (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsSetCard(0x230) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.xyzfilter(c,tp,mg)
	return c:IsAttribute(ATTRIBUTE_DARK) and Duel.GetLocationCountFromEx(tp,tp,mg,c)>0 and c:IsXyzSummonable(nil,mg,2,2)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then
		if not Duel.IsPlayerCanSpecialSummonCount(tp,2)
			or Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
			or Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return false end	
		local mg=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_REMOVED+LOCATION_GRAVE,0,nil,e,tp)
		return Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil,tp,mg)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,0,LOCATION_REMOVED+LOCATION_GRAVE)
end
function s.rescon(sg,e,tp,mg)
	return Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil,tp,sg)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	local mg=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_REMOVED+LOCATION_GRAVE,0,nil,e,tp)
	local sg=aux.SelectUnselectGroup(mg,e,tp,2,2,s.rescon,1,tp,HINTMSG_SPSUMMON,nil,nil,false)
	if #sg<2 then return end
	local tc1=sg:GetFirst()
	local tc2=sg:GetNext()
	Duel.SpecialSummonStep(tc1,0,tp,tp,false,false,POS_FACEUP)
	Duel.SpecialSummonStep(tc2,0,tp,tp,false,false,POS_FACEUP)
	--Negate their effects
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc1:RegisterEffect(e1)
	local e2=e1:Clone()
	tc2:RegisterEffect(e2)
	local e3=Effect.CreateEffect(e:GetHandler())
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_DISABLE_EFFECT)
	e3:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc1:RegisterEffect(e3)
	local e4=e3:Clone()
	tc2:RegisterEffect(e4)
	Duel.SpecialSummonComplete()
	Duel.BreakEffect()
	local xyzg=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_EXTRA,0,nil,tp,sg)
	if #xyzg>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local xyz=xyzg:Select(tp,1,1,nil):GetFirst()
		Duel.XyzSummon(tp,xyz,nil,sg)
	end
end
--sp summon
function s.spfilter(c,e,tp)
	return (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsSetCard(0x230) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,id)~=0 then return end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end