--Dragon of the Back Comet
--Scripted by Secuter
local s,id=GetID()
function s.initial_effect(c)
	-- spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE+CATEGORY_TODECK+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetHintTiming(0,TIMING_MAIN_END+TIMING_CHAIN_END+TIMING_DRAW+TIMING_TOHAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	-- check
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_TO_HAND)
		ge1:SetCondition(s.regcon)
		ge1:SetOperation(s.regop)
		Duel.RegisterEffect(ge1,0)
	end)
end
-- check
function s.cfilter(c,tp)
	return c:IsControler(tp) and c:IsPreviousLocation(LOCATION_DECK) and c:IsReason(REASON_EFFECT)
end
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp) or eg:IsExists(s.cfilter,1,nil,1-tp)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	for tc in aux.Next(eg) do
		if s.cfilter(tc,tp) then Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1) end
		if s.cfilter(tc,1-tp) then Duel.RegisterFlagEffect(1-tp,id,RESET_PHASE+PHASE_END,0,1) end
	end
end
-- spsummon
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(1-tp,id)>=5 and Duel.IsMainPhase()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local hg=Duel.GetFieldGroup(1-tp,0,LOCATION_HAND)
	local ct=#hg
	local dg=Duel.GetDecktopGroup(1-tp,ct)
	if chk==0 then return Duel.GetMZoneCount(tp,g,tp)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and ct>0 and dg:FilterCount(Card.IsAbleToRemove,nil,tp,POS_FACEDOWN)==ct
		and hg:FilterCount(Card.IsAbleToDeck,nil)==ct end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,dg,ct,1-tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,hg,ct,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.GetMZoneCount(tp,g,tp)>0 and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then		
		local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
		local hg=Duel.GetFieldGroup(p,LOCATION_HAND,0)
		local ct=#hg
		local dg=Duel.GetDecktopGroup(p,ct)	
		if ct>0 and dg:FilterCount(Card.IsAbleToRemove,nil,tp,POS_FACEDOWN)==ct and Duel.Remove(dg,POS_FACEDOWN,REASON_EFFECT)==ct then
			Duel.BreakEffect()
			local og=Duel.GetOperatedGroup()
			if Duel.SendtoDeck(hg,p,2,REASON_EFFECT)>0 then
				local e1=Effect.CreateEffect(c)
				e1:SetCategory(CATEGORY_TOHAND)
				e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
				e1:SetCode(EVENT_PHASE+PHASE_END)
				e1:SetCountLimit(1)
				e1:SetLabelObject(og)
				e1:SetOperation(s.thop)
				e1:SetReset(RESET_PHASE+PHASE_END)
				Duel.RegisterEffect(e1,tp)
			end
		end
	end
end
function s.filter(c)
	return c:IsRelateToEffect(e) and c:IsLocation(LOCATION_REMOVED) and c:IsFacedown()
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject():Filter(s.filter,nil,e)
	if #g>0 then
		Duel.SendtoHand(g,p,REASON_EFFECT)
	end
end