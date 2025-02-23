--Transcendent Keystone
--Scripted by Secuter
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.thfilter(c)
	return c:IsMonster() and c:IsExchange() and c:IsAbleToHand()
end
function s.filter(c,e,tp)
	return c:IsFaceup() and c:IsExchange() and c:IsAbleToHand()
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp,c:GetCode())
end
function s.spfilter(c,e,tp,code)
	return c:IsExchange() and not c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,true,true,POS_FACEUP)
end
function s.tdfilter(c)
	return c:IsExchange() and c:IsMonster() and c:IsAbleToDeck()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return (e:GetLabel()==2 and chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc,e,tp))
        or (e:GetLabel()==3 and chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.tdfilter(chkc)) end
	local bc=Duel.GetBattleMonster(tp)
	local b3_event,_,event_p,event_v,event_reff=Duel.CheckEvent(EVENT_CHAINING,true)
	local tg=b3_event and Duel.GetChainInfo(event_v,CHAININFO_TARGET_CARDS) or nil
	--search
	local b1=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	--exchange summon
	local b2=Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil,e,tp)
	--shuffle & draw
	local b3=Duel.IsPlayerCanDraw(tp,1)
        and Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_GRAVE,0,3,nil)
	if chk==0 then return b1 or b2 or b3 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)},
		{b3,aux.Stringid(id,3)})
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		e:SetProperty(0)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	elseif op==2 then
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
        local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
        Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
        Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	elseif op==3 then
		e:SetCategory(CATEGORY_DRAW)
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
        local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_GRAVE,0,3,3,nil)
        Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
        Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local op,event_v=e:GetLabel()
	if op==1 then
		--search
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	elseif op==2 then
        --exchange summon
        local tc=Duel.GetFirstTarget()
        if tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_HAND)
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp,tc:GetCode()) then
            local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp,tc:GetCode())
            if #g>0 then
                Duel.SpecialSummon(g,SUMMON_TYPE_EXCHANGE,tp,tp,false,false,POS_FACEUP)
            end
        end
	elseif op==3 then
        --shuffle & draw
        local tg=Duel.GetTargetCards(e)
        if #tg>0 then
            Duel.SendtoDeck(tg,nil,0,REASON_EFFECT)
            local og=Duel.GetOperatedGroup()
            if #og>0 then
                Duel.Draw(tp,1,REASON_EFFECT)
            end
        end
	end
end