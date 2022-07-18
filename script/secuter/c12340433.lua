--Crystallion Hydra (Echo)
--Scripted by Secuter
if not ECHO_IMPORTED then Duel.LoadScript("proc_echo.lua") end
local s,id=GetID()
s.IsEcho=true
function s.initial_effect(c)
	--echo summon
	Echo.AddProcedure(c,s.efilter,s.eop)
	c:EnableReviveLimit()
	--spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--xyz attacks twice
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_XMATERIAL)
	--e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
	e2:SetValue(1)
	e2:SetCondition(s.xyzcon)
	c:RegisterEffect(e2)
	--xyz intarget
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_XMATERIAL)
	--e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetCondition(s.xyzcon)
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
end
s.listed_series={0x206}
function s.efilter(c,sc,sumtype,tp)
	return c:IsType(TYPE_XYZ,sc,sumtype,tp) and c:IsRank(6)
end
function s.eop(c,e,tp,tc)
	--immune
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP+EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_OWNER_RELATE+EFFECT_IMMUNE_EFFECT)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetTarget(s.immtg)
	e1:SetValue(s.immfilter)
	e1:SetLabel(tc:GetOriginalCodeRule())
	c:RegisterEffect(e1)
end
--immune
function s.immtg(e,c)
	local code=e:GetLabel()
	local code1,code2=c:GetOriginalCodeRule()
	return c:IsType(TYPE_XYZ) and (code1==code or code2==code)
end
function s.immfilter(e,re)
	return re:GetOwnerPlayer()~=e:GetHandlerPlayer()
end
--spsummon
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_TYPE_ECHO
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x206) and c:IsRace(RACE_REPTILE)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
--attack twice
function s.xyzcon(e)
	return e:GetHandler():GetOriginalRace()==RACE_REPTILE
end