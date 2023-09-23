--Auranth, the Dark King Heir
--Scripted by Secuter
if not SECUTER_IMPORTED then Duel.LoadScript("secuter_utility.lua") end
local s,id=GetID()
function s.initial_effect(c)
	Pendulum.AddProcedure(c)
    --sp summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
s.is_ritual_summonable=Ritual.Target({handler=c,filter=aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_DARK),location=LOCATION_HAND|LOCATION_GRAVE,matfilter=s.matfilter})
s.ritual_summon=Ritual.Operation({handler=c,filter=aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_DARK),location=LOCATION_HAND|LOCATION_GRAVE,matfilter=s.matfilter})
function s.matfilter(c,e,tp)
	return c:IsLocation(LOCATION_ONFIELD) and c:IsAttribute(ATTRIBUTE_DARK)
end
--sp summon
function s.cfilter(c,tp)
	return c:IsControler(tp) and c:IsSummonType(SUMMON_TYPE_RITUAL) and c:IsAttribute(ATTRIBUTE_DARK)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg and eg:IsExists(s.cfilter,1,nil,tp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(10)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1,true)
		--ritual summon
		local g=Duel.GetMatchingGroup(s.rfilter,tp,LOCATION_GRAVE,0,nil)
		if s.is_ritual_summonable(e,tp,eg,ep,ev,re,r,rp,0) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.BreakEffect()
            s.ritual_summon(e,tp,eg,ep,ev,re,r,rp)
        end
	end
end
