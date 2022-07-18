-- Divine ST
--Scripted by Secuter
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--cannot be target
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCondition(s.limcond)
	e2:SetValue(s.atlimit)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(s.atlimit)
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
	--special summon
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(s.spcon)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
end
s.listed_series={0x213}
function s.imfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_DIVINE) and c:IsLevel(12)
end
function s.limcond(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.imfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil) 
end
function s.atlimit(e,c)
	return c:IsFaceup() and c:IsSetCard(0x213)
end

function s.cfilter(c,e,tp,rp)
	return c:IsPreviousPosition(POS_FACEUP) and c:GetPreviousControler()==tp
		and (c:GetPreviousRaceOnField()&RACE_DIVINE)~=0 and (c:GetPreviousLevelOnField()&12)~=0
		and (c:IsReason(REASON_BATTLE) or (rp~=tp and c:IsReason(REASON_EFFECT)))
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,c:GetAttribute())
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,e,tp,rp)
end
function s.spfilter(c,e,tp,attr)
	return c:IsRace(RACE_DIVINE) and c:IsLevel(12) and c:GetAttribute()~=attr and c:IsCanBeSpecialSummoned(e,0,tp,true,false,POS_FACEUP_DEFENSE)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)	
	local sg=eg:Filter(s.cfilter,nil,e,tp,rp)
	if sg:GetCount()==1 then
		local tc=sg:GetFirst()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,tc:GetAttribute())
		if #g>0 and Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP_DEFENSE) and e:GetHandler():IsAbleToGrave() then
			Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT)
		end
	else
		local tc=sg:GetFirst()
		if not tc then return end
		local attr=tc:GetAttribute()
		tc=sg:GetNext()
		if tc then
			attr=bit.bor(attr,tc:GetAttribute())
		end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,attr)
		if #g>0 and Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP_DEFENSE) and e:GetHandler():IsAbleToGrave() then
			Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT)
		end
	end
end