--Hailshift Champion
--Scripted by Secuter
if not EXCHANGE_IMPORTED then Duel.LoadScript("proc_exchange.lua") end
local s,id=GetID()
s.IsExchange=true
function s.initial_effect(c)
	Exchange.Enable(c,s,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_WATER))
	--spsummon itself
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--spsummon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetCondition(aux.bdcon)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.hsptg)
	e2:SetOperation(s.hspop)
	c:RegisterEffect(e2)
end
s.listed_names={id}
s.listed_series={0x224}
--spsummon itself
function s.filter(c,tp,ft)
	return c:IsControler(tp) and c:IsSetCard(0x224) and c:IsAbleToHand() and (ft>0 or c:GetSequence()<5)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local tp=e:GetHandlerPlayer()
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	return eg:IsExists(s.filter,1,nil,tp,ft)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local g=eg:Filter(s.filter,nil,tp,ft)
	if #g<=0 then return end
	local tc=g:Select(tp,1,1,nil):GetFirst()
	if tc and Duel.SendtoHand(tc,tp,REASON_EFFECT)>0 and Duel.GetOperatedGroup():GetFirst():IsLocation(LOCATION_HAND) and c:IsRelateToEffect(e) then
		if Duel.SpecialSummon(c,SUMMON_TYPE_EXCHANGE,tp,tp,false,false,POS_FACEUP)>0 then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(tc:GetAttack())
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			c:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_UPDATE_DEFENSE)
			e2:SetValue(tc:GetDefense())
			c:RegisterEffect(e2)
		end
	end
end
--spsummon
function s.hspfilter(c,e,tp)
	return c:IsSetCard(0x224) and not c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.hsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.hspfilter,tp,LOCATION_HAND,0,1,e:GetHandler(),e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.hspop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.hspfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,SUMMON_TYPE_EXCHANGE,tp,tp,false,false,POS_FACEUP)
	end
end