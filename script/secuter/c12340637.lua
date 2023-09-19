--Anuak The Apocryphos
--Scripted by Secuter
if not SECUTER_IMPORTED then Duel.LoadScript("secuter_utility.lua") end
local s,id=GetID()
s.Reunion=true
function s.initial_effect(c)
	c:EnableReviveLimit()
	Reunion.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_ANUAK),2,99,s.rcheck)
	--negate special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_SPSUMMON)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.discon)
	e1:SetCost(s.discost)
	e1:SetTarget(s.distg)
	e1:SetOperation(s.disop)
	c:RegisterEffect(e1)
	--spsummon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.spcon2)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e3)
end
s.listed_names={id}
s.listed_series={SET_ANUAK}
s.material_setcode={SET_ANUAK}
--reunion
function s.rcheck(g,lc,sumtype,tp)
	return g:IsExists(Card.IsAttribute,1,nil,ATTRIBUTE_LIGHT)
		and g:IsExists(Card.IsAttribute,1,nil,ATTRIBUTE_DARK)
end
--negate summon
function s.filter(c)
	return c:IsSummonLocation(LOCATION_EXTRA)
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return tp~=ep and Duel.GetCurrentChain()==0 and eg:IsExists(s.filter,1,nil)
end
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	Duel.Release(e:GetHandler(),REASON_COST)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,#eg,0,0)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,eg,#eg,0,0)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateSummon(eg)
	if #eg>0 and Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)~=0 then
		local og=Duel.GetOperatedGroup()
		og:KeepAlive()
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetLabelObject(og)
		e1:SetOperation(s.spop)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.spfilter(c,e,tp)
	return c:IsLocation(LOCATION_REMOVED) and c:IsCanBeSpecialSummoned(e,0,tp,true,true,POS_FACEUP,tp)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tg=e:GetLabelObject():Filter(s.spfilter,nil,e,tp)
	if #tg>0 then
		local lc=Duel.GetLocationCount(tp,LOCATION_MZONE)
		if #tg>lc then
			tg=tg:Select(tp,lc,lc,nil)
		end
		Duel.SpecialSummon(tg,0,tp,tp,true,true,POS_FACEUP)
	end
end
--spsummon
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp~=tp and c:IsPreviousControler(tp) and c:GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_TYPE_REUNION
end
function s.spfilter2(c,e,tp)
	return c:IsSetCard(SET_ANUAK) and c:GetCode()~=id and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_REMOVED)
end
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
