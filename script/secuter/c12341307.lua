--Normal Dragons Link
--Scripted by Secuter
local s,id=GetID()
function s.initial_effect(c)
	--xyz summon
	Link.AddProcedure(c,nil,2,2,s.matcheck)
	c:EnableReviveLimit()
	--add
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.con)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
	--extra summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	e2:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e2:SetLabelObject(c)
	e2:SetCondition(s.sumcon)
	e2:SetValue(s.sumval)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_NORMAL))
	c:RegisterEffect(e2)
end
function s.lfilter(c,lc,sumtype,tp)
	return c:IsType(TYPE_NORMAL,lc,sumtype,tp) and not c:IsType(TYPE_TOKEN,lc,sumtype,tp)
end
function s.matcheck(g,lc,sumtype,tp)
	return g:IsExists(s.lfilter,1,nil,lc,sumtype,tp)
end

function s.con(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function s.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsType(TYPE_NORMAL) and c:IsAbleToHand()
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

function s.sumcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabelObject():IsLocation(LOCATION_MZONE)
end
function s.sumval(e,c)
	local c=e:GetLabelObject()
	local sumzone=c:GetLinkedZone()
	local relzone=-bit.lshift(1,c:GetSequence())
	return 0,sumzone,relzone
end