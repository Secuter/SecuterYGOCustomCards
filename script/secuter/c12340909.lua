--Asura Link
--Scripted by Secuter
local s,id=GetID()
function s.initial_effect(c)
	--link summon
	c:EnableReviveLimit()
	Link.AddProcedure(c,aux.True,1,2,s.lcheck)
	--gain attributes
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MATERIAL_CHECK)
	e1:SetValue(s.matcheck)
	c:RegisterEffect(e1)
	--atk
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
	--special summon
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
s.listed_series={0x218}
function s.lfilter(c)
	return c:IsLevelAbove(7) and (c:IsSummonType(SUMMON_TYPE_NORMAL) or c:IsSummonType(SUMMON_TYPE_TRIBUTE))
end
function s.lcheck(g,lc)
	return g:IsExists(s.lfilter,1,nil)
end

function s.matcheck(e,c)
	local g=c:GetMaterial()
	for i=0,10 do
		local t = 2^i
		if g:IsExists(Card.IsAttribute,1,nil,t) then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_ADD_ATTRIBUTE)
			e1:SetValue(t)
			e1:SetReset(RESET_EVENT+0xff0000)
			c:RegisterEffect(e1)
		end
	end
end

function s.atkval(e,c)
	local tp=e:GetHandlerPlayer()
	local g=Duel.GetMatchingGroup(Card.IsLinked,tp,LOCATION_MZONE,0,nil)
	local ct=0
	for i=0,10 do
		local t=2^i
		if g:IsExists(Card.IsAttribute,1,nil,t) then
			ct=ct+1
		end
	end
	return ct*400
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetReasonPlayer()~=tp and c:IsReason(REASON_EFFECT) and c:IsPreviousPosition(POS_FACEUP)
		and c:GetPreviousControler()==c:GetOwner()
end
function s.spfilter(c,e,tp,attr)
	return c:IsSetCard(0x218) and bit.band(c:GetAttribute(),attr)==c:GetAttribute() and c:GetAttribute()>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local attr=e:GetHandler():GetPreviousAttributeOnField()
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.spfilter(chkc,e,tp,attr) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,attr) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,attr)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end