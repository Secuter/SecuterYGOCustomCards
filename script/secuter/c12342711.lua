--Yoccol Power Blast
--Scripted by Secuter
if not SECUTER_IMPORTED then Duel.LoadScript("secuter_utility.lua") end
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--return to hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_TOEXTRA)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_YOCCOL}
--destroy
function s.filter(c)
	return c:IsSetCard(SET_YOCCOL) and c:IsType(TYPE_RITUAL+TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.FaceupFilter(s.filter),tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local ct=0
	local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsSetCard,SET_YOCCOL),tp,LOCATION_MZONE,0,nil)
	if g:IsExists(Card.IsType,1,nil,TYPE_RITUAL) then ct=ct+1 end
	if g:IsExists(Card.IsType,1,nil,TYPE_FUSION) then ct=ct+1 end
	if g:IsExists(Card.IsType,1,nil,TYPE_SYNCHRO) then ct=ct+1 end
	if g:IsExists(Card.IsType,1,nil,TYPE_XYZ) then ct=ct+1 end
	if ct==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,ct,nil)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.Destroy(g,REASON_EFFECT)
	end
end
--return to hand
function s.tdfilter(c,e)
	return c:IsSetCard(SET_YOCCOL) and c:IsType(TYPE_MONSTER) and c:IsType(TYPE_RITUAL+TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ) and c:IsCanBeEffectTarget(e) and c:IsAbleToDeck()
end
function s.rescon(sg,e,tp,mg)
	local ct=0
	if sg:IsExists(Card.IsType,1,nil,TYPE_RITUAL) then ct=ct+1 end
	if sg:IsExists(Card.IsType,1,nil,TYPE_FUSION) then ct=ct+1 end
	if sg:IsExists(Card.IsType,1,nil,TYPE_SYNCHRO) then ct=ct+1 end
	if sg:IsExists(Card.IsType,1,nil,TYPE_XYZ) then ct=ct+1 end
	return aux.ChkfMMZ(1)(sg,e,tp,mg) and ct==#sg
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_GRAVE,0,nil,e)
	if chk==0 then return e:GetHandler():IsAbleToHand() and aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,0) end
	local sg=aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,1,tp,HINTMSG_TODECK)
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,sg,2,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tg=Duel.GetTargetCards(e)
	if #tg>0 then
		Duel.SendtoDeck(tg,nil,0,REASON_EFFECT)
		local og=Duel.GetOperatedGroup()
		if #og>0 then
			if og:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end	
			if c:IsRelateToEffect(e) then
				Duel.SendtoHand(c,nil,REASON_EFFECT)
			end
		end
	end
end
