-- Divine Field
--Scripted by Secuter
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--chain limit
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_SZONE)
	e2:SetOperation(s.chainop)
	c:RegisterEffect(e2)
	--extra summon
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	e3:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e3:SetTarget(s.sumfilter)
	c:RegisterEffect(e3)
end
function s.cfilter(c)
	return c:IsRace(RACE_DIVINE) and c:IsLevel(12) and not c:IsPublic()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	if Duel.IsPlayerCanDraw(tp,1) and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		local dt=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
		if dt==0 then return end
		local sg=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_HAND,0,nil)
		if #sg==0 then return end
		local g=Group.CreateGroup()
		repeat
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
			local tc=sg:Select(tp,1,1,nil):GetFirst()
			g:AddCard(tc)
			sg:Remove(Card.IsCode,nil,tc:GetCode())
		until #sg==0 or dt==#g or not Duel.SelectYesNo(tp,210)	
		Duel.ConfirmCards(1-tp,g)
		Duel.ShuffleHand(tp)
		local ct=#g
		Duel.Draw(tp,ct,REASON_EFFECT)
	end
end

function s.chainop(e,tp,eg,ep,ev,re,r,rp)
	if re:GetHandler():IsRace(RACE_DIVINE) and re:GetHandler():IsLevel(12) then
		Duel.SetChainLimit(s.chainlm)
	end
end
function s.chainlm(e,rp,tp)
	return tp==rp
end

function s.sumfilter(e,c)
	return c:IsRace(RACE_DIVINE) and c:IsLevel(12)
end