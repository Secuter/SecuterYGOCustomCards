--Fire Core Omega Dragon
--Scripted by Secuter
if not SECUTER_IMPORTED then Duel.LoadScript("secuter_utility.lua") end
local s,id=GetID()
function s.initial_effect(c)
	--spsummon + destroy
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--destroy
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.descon)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
--spsummon
function s.desfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAttribute(ATTRIBUTE_FIRE) and (c:IsLocation(LOCATION_HAND) or c:IsFaceup())
end
function s.desfilter2(c)
	return c:IsType(TYPE_MONSTER) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsFaceup() and c:GetSequence()<5
end
function s.mzfilter(c)
	return c:IsLocation(LOCATION_MZONE) and c:GetSequence()<5
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local g=nil
	if ft>-1 then
		g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_ONFIELD+LOCATION_HAND,0,c)
	else
		g=Duel.GetMatchingGroup(s.desfilter2,tp,LOCATION_MZONE,0,c)
	end
	if chk==0 then return ft>-2 and g:GetCount()>=2
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and (ft~=0 or g:IsExists(s.mzfilter,1,nil)) end
	if (g:GetCount()==2 and g:FilterCount(Card.IsLocation,nil,LOCATION_HAND)==1) or not g:IsExists(Card.IsLocation,1,nil,LOCATION_HAND) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,2,0,0)
	else
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,2,tp,0)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	Duel.SetChainLimit(s.chlimit)
end
function s.chlimit(e,ep,tp)
	return tp==ep and not e:IsActiveType(TYPE_MONSTER)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local g=nil
	if ft>-1 then
		g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_ONFIELD+LOCATION_HAND,0,c)
	else
		g=Duel.GetMatchingGroup(s.desfilter2,tp,LOCATION_MZONE,0,c)
	end
	if g:GetCount()<2 then return end
	local g1=nil
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	if ft==0 then
		g1=g:FilterSelect(tp,s.mzfilter,1,1,nil)
	else
		g1=g:Select(tp,1,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g2=g:Select(tp,1,1,g1:GetFirst())
	g1:Merge(g2)
	if c:IsRelateToEffect(e) and Duel.Destroy(g1,REASON_EFFECT)==2 then
		if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
			local dg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
			if #dg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
				local des=dg:Select(tp,1,2,nil)
				Duel.HintSelection(des)
				Duel.BreakEffect()
				Duel.Destroy(des,REASON_EFFECT)
			end
		end
	end
end
--destroy
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) end
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
