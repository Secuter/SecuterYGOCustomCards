--Worldless Shock
--Scripted by Secuter
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
	--to deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE|LOCATION_REMOVED)
	e2:SetCountLimit(1)
	e2:SetCondition(s.tdcon)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
end
s.listed_series={0x20F}
--to grave
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsAbleToGrave() end
	local free=Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil) and 1 or -1
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToGrave,tp,0,LOCATION_MZONE,1,nil)
		and (free==1 or Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil)) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectTarget(tp,Card.IsAbleToGrave,tp,0,LOCATION_MZONE,1,1,nil)
	e:SetLabel(free)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoGrave(tc,REASON_EFFECT)
	end
	if e:GetLabel()~=1 then
		Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD,nil)
	end
end
function s.filter(c)
	return c:IsSetCard(0x20F) and c:GetOriginalLevel()==8 and c:IsRace(RACE_DRAGON) and c:IsFaceup()
end
--to deck
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsTurnPlayer(tp) and Duel.IsMainPhase() and aux.exccon(e) and (e:GetHandler():IsFaceup() or not e:GetHandler():IsLocation(LOCATION_REMOVED))
end
function s.tdfilter(c,e)
	return c:IsSetCard(0x20F) and c:IsType(TYPE_MONSTER|TYPE_SPELL) and c:IsCanBeEffectTarget(e) and c:IsAbleToDeck() and (c:IsFaceup() or not c:IsLocation(LOCATION_REMOVED))
end
function s.class(c)
	return c:GetType()&0x3
end
function s.check(sg,e,tp)
	return sg:GetClassCount(s.class)==#sg
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return false end
	local sg=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,nil,e)
	if chk==0 then return c:IsAbleToDeck() and #sg>0
		and aux.SelectUnselectGroup(sg,e,tp,2,2,s.check,0)
		and Duel.IsPlayerCanDraw(tp,1) end
	local g=aux.SelectUnselectGroup(sg,e,tp,2,2,s.check,1,tp,HINTMSG_TODECK)
	Duel.SetTargetCard(g)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,2,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,c,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)	
	local c=e:GetHandler()
	local tg=Duel.GetTargetCards(e)
	if c:IsRelateToEffect(e) or #tg>0 then
		if c:IsRelateToEffect(e) then tg:AddCard(c) end
		if Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 and tg:FilterCount(Card.IsLocation,nil,LOCATION_DECK|LOCATION_EXTRA)==3 then
			Duel.BreakEffect()
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end