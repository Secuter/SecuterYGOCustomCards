--Dark Sovereign Outbreak
--Scripted by Secuter
local s,id=GetID()
s.IsRunic=true
s.RunicEffect={}
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_ATTACK,TIMINGS_CHECK_MONSTER_E+TIMING_ATTACK)
	e1:SetCost(s.descost)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	--Runic Effect
	local re=Effect.CreateEffect(c)
	re:SetDescription(aux.Stringid(id,0))
	re:SetCategory(CATEGORY_TOGRAVE)
	re:SetProperty(EFFECT_FLAG_CARD_TARGET)
	re:SetTarget(s.tgtg)
	re:SetOperation(s.tgop)
	s.RunicEffect=re
end
--destroy
function s.cfilter(c)
	return c:IsMonster() and c:IsAttribute(ATTRIBUTE_DARK) and c:GetBaseAttack()>=1000
end
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	if chk==0 then return true end
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	if chk==0 then
		if e:GetLabel()==0 then return false end
		e:SetLabel(0)
		return Duel.CheckReleaseGroup(tp,s.cfilter,1,nil) and
		       Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,e:GetHandler())
	end
	local tg=Duel.SelectReleaseGroupCost(tp,s.costfilter,1,1,false,nil,nil)
	local tc=tg:GetFirst():GetBaseAttack()//1000
	Duel.Release(tg,REASON_COST)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,tc,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end
--send to gy
function s.filter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DARK) and c:GetBaseAttack()>=2000
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc~=e:GetHandler() end
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) 
		and Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,0,0)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,id)~=0 then return end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) then return end
	local ct=tc:GetBaseAttack()//2000
	local g=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,0,LOCATION_ONFIELD,nil)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local sg=g:Select(tp,1,ct,nil)
		Duel.HintSelection(sg)
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
end