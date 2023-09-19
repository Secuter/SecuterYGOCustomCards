--Demon Rival Vault
--Scripted by Secuter
if not SECUTER_IMPORTED then Duel.LoadScript("secuter_utility.lua") end
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--recover
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.thcon)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
s.listed_names={id}
s.listed_series={SET_DEMON_RIVAL}
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_DEMON_RIVAL) and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE))
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,2,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_GRAVE+LOCATION_REMOVED)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 or Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,2,2,nil,e,tp)
	if #g==2 then
        local result=true
        for tc in aux.Next(g) do
            if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
                local e1=Effect.CreateEffect(c)
                e1:SetType(EFFECT_TYPE_SINGLE)
                e1:SetCode(EFFECT_DISABLE)
                e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
                e1:SetReset(RESET_EVENT+RESETS_STANDARD)
                tc:RegisterEffect(e1)
                local e2=e1:Clone()
                e2:SetCode(EFFECT_DISABLE_EFFECT)
                tc:RegisterEffect(e2)
            else
                result=false
            end
        end
        Duel.SpecialSummonComplete()
        if result then            
            local off=1
            local ops={}
            local opval={}
            local linkg=Duel.GetMatchingGroup(s.linkfilter,tp,LOCATION_EXTRA,0,nil,g,tp)
            local xyzg=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_EXTRA,0,nil,g,tp)
            --link summon
            if #linkg>0 then
                ops[off]=aux.Stringid(id,0)
                opval[off-1]=1
                off=off+1
            end
            if #xyzg>0 then
            --xyz summon
                ops[off]=aux.Stringid(id,1)
                opval[off-1]=2
                off=off+1
            end
            --none
            ops[off]=aux.Stringid(id,2)
            opval[off-1]=3
            off=off+1		
            if off<2 then return end
            local op=Duel.SelectOption(tp,table.unpack(ops))
            if opval[op]==2 then
                Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
                local xyz=xyzg:Select(tp,1,1,nil):GetFirst()
                Duel.XyzSummon(tp,xyz,nil,g)
            elseif opval[op]==1 then
                Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
                local link=linkg:Select(tp,1,1,nil):GetFirst()
                Duel.LinkSummon(tp,link,nil,g,#g,#g)
            end        
        end
	end
end
function s.xyzfilter(c,mg,tp)
	return c:IsSetCard(SET_DEMON_RIVAL) and c:IsXyzSummonable(nil,mg,2,2) and Duel.GetLocationCountFromEx(tp,tp,mg,c)>0 
end
function s.linkfilter(c,mg,tp)
	return c:IsSetCard(SET_DEMON_RIVAL) and c:IsLinkSummonable(nil,mg,2,2) and Duel.GetLocationCountFromEx(tp,tp,mg,TYPE_LINK)>0
end

function s.thfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER)
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSummonLocation,LOCATION_EXTRA),tp,0,LOCATION_MZONE,1,nil)
end
function s.thchk(c)
	return c:IsSetCard(SET_DEMON_RIVAL) and not c:IsCode(id) and c:IsAbleToHand()
end
function s.check(sg,e,tp,mg)
	return sg:IsExists(s.thchk,1,nil) and sg:GetClassCount(Card.GetCode)==#sg
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chkc then return false end
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
	if chk==0 then return aux.SelectUnselectGroup(g,e,tp,3,3,s.check,0) end
	local sg=aux.SelectUnselectGroup(g,e,tp,3,3,s.check,1,tp,HINTMSG_TARGET)
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,sg,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,sg,2,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if #g==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local sg=g:FilterSelect(tp,s.thchk,1,1,nil,e,tp):GetFirst()
	if sg then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
		g:RemoveCard(sg)
	end
	Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
	local og=Duel.GetOperatedGroup()
	local g1=og:Filter(Card.IsControler,nil,tp):Filter(Card.IsLocation,nil,LOCATION_DECK)
	local g2=og:Filter(Card.IsControler,nil,1-tp):Filter(Card.IsLocation,nil,LOCATION_DECK)
	if #g1>0 then
		Duel.SortDeckbottom(tp,tp,#g1)
	end
	if #g2>0 then
		Duel.SortDeckbottom(tp,1-tp,#g2)
	end
end
