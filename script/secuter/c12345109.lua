--Aetherock First Mountain
--Scripted by Secuter
if not SECUTER_IMPORTED then Duel.LoadScript("secuter_utility.lua") end
local s,id=GetID()
function s.initial_effect(c)
    --xyz summon
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_AETHEROCK}
--xyz summon
function s.mfilter(c,e)
	return (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsRace(RACE_ROCK)
        and (c:IsLevel(4) or c:IsRank(4)) and c:IsCanBeEffectTarget(e)
end
function s.mfilter4(c,e,tp,sc,pg)
	--local pg=aux.GetMustBeMaterialGroup(tp,Group.FromCards(c),tp,nil,nil,REASON_XYZ)
	return (#pg<=0 or (#pg==1 and pg:IsContains(c))) and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
		and c:IsRace(RACE_ROCK) and (c:IsLevel(4) or c:IsRank(4)) and (not sc or c:IsCanBeXyzMaterial(sc,tp)) and c:IsCanBeEffectTarget(e)
end
function s.mfilter5(c,e,tp,sc,pg)
	--local pg=aux.GetMustBeMaterialGroup(tp,Group.FromCards(c),tp,nil,nil,REASON_XYZ)
	return (#pg<=0 or (#pg==1 and pg:IsContains(c))) and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
		and c:IsRace(RACE_ROCK) and c:IsRank(4) and (not sc or c:IsCanBeXyzMaterial(sc,tp)) and c:IsCanBeEffectTarget(e)
end
function s.xyzfilter4(c,e,tp,mg,pg,chk)
	if c.rum_limit and not c.rum_limit(mg,e) or Duel.GetLocationCountFromEx(tp,tp,mg,c)<=0 then return false end
	local g=chk
        and Duel.GetMatchingGroup(s.mfilter4,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil,e,tp,nil,pg)
        or Duel.GetMatchingGroup(aux.NecroValleyFilter(s.mfilter4),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil,e,tp,nil,pg)
	return c:IsSetCard(SET_AETHEROCK) and c:IsRank(4) and g:GetClassCount(Card.GetCode)>=3
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
end
function s.xyzfilter5(c,e,tp,mg,pg,chk)
	if c.rum_limit and not c.rum_limit(mg,e) or Duel.GetLocationCountFromEx(tp,tp,mg,c)<=0 then return false end
	local g=chk
        and Duel.GetMatchingGroup(s.mfilter5,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil,e,tp,nil,pg)
        or Duel.GetMatchingGroup(aux.NecroValleyFilter(s.mfilter5),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil,e,tp,nil,pg)
	return c:IsSetCard(SET_AETHEROCK) and c:IsRank(5) and g:GetClassCount(Card.GetCode)>=3
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
end
function s.check(sg,e,tp,mg)
    local c=e:GetHandler()
	local pg=aux.GetMustBeMaterialGroup(tp,Group.FromCards(c),tp,nil,nil,REASON_XYZ)
	return sg:GetClassCount(Card.GetCode)==#sg
        and (Duel.IsExistingMatchingCard(s.xyzfilter4,tp,LOCATION_EXTRA,0,1,nil,e,tp,sg,pg,true)
        or (#sg:Filter(Card.IsType,nil,TYPE_XYZ)==3 and Duel.IsExistingMatchingCard(s.xyzfilter5,tp,LOCATION_EXTRA,0,1,nil,e,tp,sg,pg,true)))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local g=Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil,e)
	if chk==0 then return aux.SelectUnselectGroup(g,e,tp,3,3,s.check,0,tp,HINTMSG_XMATERIAL) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local sg=aux.SelectUnselectGroup(g,e,tp,3,3,s.check,1,tp,HINTMSG_XMATERIAL)
	Duel.SetTargetCard(sg)
	e:SetLabel(#sg:Filter(Card.IsType,nil,TYPE_XYZ))
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,sg,#sg,0,0)
end
function s.xyzfilter(c,e,tp,ct)
	return c:IsSetCard(SET_AETHEROCK) and (c:IsRank(4) or (ct==3 and c:IsRank(5)))
        and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0 and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
end
function s.groupcontains(sg,g)
	local tc=g:GetFirst()
	while tc do
		tc=g:GetNext()
		if not sg:IsContains(tc) then return false end
	end
	return true
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	local pg=aux.GetMustBeMaterialGroup(tp,sg,tp,nil,nil,REASON_XYZ)
	if #tg>0 and (#pg==0 or s.groupcontains(pg,tg)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=Duel.SelectMatchingCard(tp,s.xyzfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,e:GetLabel())
		local sc=sg:GetFirst()
		if sc then
			sc:SetMaterial(tg)
			Duel.Overlay(sc,tg)
			Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
			sc:CompleteProcedure()
		end
	end
end