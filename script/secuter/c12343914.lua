--Irradiance Resonance
--Scripted by Secuter
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={0x22C}
--spsummon
function s.chkfilter(c,e,tp)
	return c:IsSetCard(0x22C) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
		and Duel.IsExistingMatchingCard(s.codefilter,tp,LOCATION_GRAVE,0,1,c,e,tp,c:GetCode())
end
function s.codefilter(c,e,tp,code)
	return c:IsCode(code) and c:IsSetCard(0x22C) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ct=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>=2
		and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
		and Duel.IsExistingMatchingCard(s.chkfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end	
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_GRAVE,0,nil,e,tp)	
	local sg=aux.SelectUnselectGroup(g,e,tp,2,ct,s.spcheck,1,tp,HINTMSG_SPSUMMON)
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,sg,2,tp,LOCATION_GRAVE)
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x22C) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
function s.spcheck(g,tc,sumtype,tp)
	return g:GetClassCount(Card.GetCode)==1
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if not g then return end
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	if #sg>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>=#sg then
		if #sg>0 and Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return end
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end