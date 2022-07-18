--External Worlds Link 3
--Scripted by Secuter
local s,id=GetID()
function s.initial_effect(c)
	--link summon
	c:EnableReviveLimit()
	Link.AddProcedure(c,nil,3,nil,s.linkcheck)
	--material check
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MATERIAL_CHECK)
	e1:SetValue(s.val)
	c:RegisterEffect(e1)
	--show attributes
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(s.regcon)
	e2:SetOperation(s.regop)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	--immune
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(s.immval)
	e3:SetLabelObject(e1)
	c:RegisterEffect(e3)
	--spsummon
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCost(s.spcost)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	e4:SetLabelObject(e1)
	c:RegisterEffect(e4)
end
function s.linkcheck(g,lc,tp)
	return g:GetClassCount(Card.GetAttribute)==g:GetCount()
end
--material check
function s.val(e,c)
	local attr=0
	local g=c:GetMaterial()
	for tc in aux.Next(g) do
		attr=(attr|tc:GetOriginalAttribute())
	end
	e:SetLabel(attr)
end
--show attributes
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local attr=e:GetLabelObject():GetLabel()
	for _,str in aux.GetAttributeStrings(attr) do
		c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,str)
	end
end
--immune
function s.immval(e,te)
	return te:IsActiveType(TYPE_MONSTER) and te:GetHandler():IsAttribute(e:GetLabelObject():GetLabel())
end
--spsummon
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	Duel.Release(e:GetHandler(),REASON_COST)
end
function s.spfilter(c,e,tp,attr)
	return c:IsFaceup() and c:IsCanBeEffectTarget(e) and c:IsAttribute(attr) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) 
end
function s.spcheck(sg,e,tp,mg)
	local attr_all=e:GetLabelObject():GetLabel()
    local attr={}
	local cc=0
	for i=0,10 do
		local t = 2^i
		if bit.band(attr_all,t)==t then
			if chk==0 and not g:IsExists(s.spfilter,1,nil,e,tp,t) then return false end
			attr[cc]=t
			cc=cc+1
		end
	end
	return sg:IsExists(Card.IsAttribute,1,nil,attr[0]) and sg:IsExists(Card.IsAttribute,1,nil,attr[1]) and sg:IsExists(Card.IsAttribute,1,nil,attr[2])
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 and (Duel.GetLocationCount(tp,LOCATION_MZONE)<3 or Duel.IsPlayerAffectedByEffect(tp,59822133)) then return false end
	local attr_all=e:GetLabelObject():GetLabel()
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_REMOVED,0,nil,e,tp,attr_all)
    local attr={}
	local cc=0
	for i=0,10 do
		local t = 2^i
		if bit.band(attr_all,t)==t then
			if chk==0 and not g:IsExists(s.spfilter,1,nil,e,tp,t) then return false end
			attr[cc]=t
			cc=cc+1
		end
	end
    if chk==0 then return cc==3 end	
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_REMOVED,0,nil,e,tp,attr_all)
	local sg=aux.SelectUnselectGroup(g,e,tp,3,3,s.spcheck,1,tp,HINTMSG_SPSUMMON)
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,sg,3,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if ft<=0 or g:GetCount()==0 or (g:GetCount()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133)) then return end
	if g:GetCount()<=ft then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=g:Select(tp,ft,ft,nil)
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		g:Sub(sg)
		Duel.SendtoGrave(g,REASON_RULE)
	end
end