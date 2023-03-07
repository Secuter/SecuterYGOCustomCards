--Anuak Dragonflare
--Scripted by Secuter
local s,id=GetID()
s.IsReunion=true
if not REUNION_IMPORTED then Duel.LoadScript("proc_reunion.lua") end
function s.initial_effect(c)
	c:EnableReviveLimit()
	--reunion summon
	Reunion.AddProcedure(c,s.mfilter,2,99,nil,nil,LOCATION_MZONE+LOCATION_GRAVE,REUNION_MAT_REMOVE,LOCATION_GRAVE,false,s.mfilter)
	--gain attributes
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_ADD_ATTRIBUTE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(ATTRIBUTE_EARTH|ATTRIBUTE_WATER|ATTRIBUTE_FIRE|ATTRIBUTE_WIND)
	c:RegisterEffect(e1)
	--ATK/DEF increase
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	--shuffle into deck
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.tdtg)
	e3:SetOperation(s.tdop)
	c:RegisterEffect(e3)
	--spsummon
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL+EFFECT_FLAG_CARD_TARGET)
	e5:SetCode(EVENT_LEAVE_FIELD)
	e5:SetCountLimit(1,{id,1})
	e5:SetCondition(s.spcon)
	e5:SetTarget(s.sptg)
	e5:SetOperation(s.spop)
	c:RegisterEffect(e5)
end
s.listed_names={id}
s.material_setcode={0x208}
function s.mfilter(c,sc,sumtype,tp)
	return c.IsReunion and (c:IsLocation(LOCATION_MZONE) or c:IsSetCard(0x208,sc,sumtype,tp))
end
--atk increase
function s.atkval(e,c)
	local tp=e:GetHandlerPlayer()
	local att=0
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_REMOVED,0,nil)
	local tc=g:GetFirst()
	for tc in aux.Next(g) do
		att=(att|tc:GetAttribute())
	end
	local ct=0
	while att~=0 do
		if (att&0x1)~=0 then ct=ct+1 end
		att=(att>>1)
	end
	return ct*300
end
--to deck
function s.tdfilter1(c)
	return c.IsReunion and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsAbleToDeck()
end
function s.tdfilter2(c,att)
	return c:IsFaceup() and c:IsAttribute(att) and c:IsAbleToDeck()
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tdfilter1,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil) end
	local g=Duel.GetMatchingGroup(s.tdfilter1,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g1=Duel.SelectMatchingCard(tp,s.tdfilter1,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,1,nil)
	if #g1>0 then
		local g2=Duel.GetMatchingGroup(s.tdfilter2,tp,0,LOCATION_MZONE,nil,g1:GetFirst():GetAttribute())
		g1:Merge(g2)
		Duel.SendtoDeck(g1,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
--spsummon
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
    return c:GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_TYPE_REUNION
	  and c:IsPreviousLocation(LOCATION_MZONE) and rp==1-tp and c:IsPreviousControler(tp)
end
function s.spfilter(c,e,tp)
	return c.IsReunion and not c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>=2
		and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,2,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,2,2,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.GetTargetCards(e)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft>1 and Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	if ft<#sg then return end
	Duel.SpecialSummon(sg,0,tp,tp,true,false,POS_FACEUP_DEFENSE)
end