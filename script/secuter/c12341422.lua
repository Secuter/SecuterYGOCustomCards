--Ancient Oracle Extra
--Scripted by Secuter
local s,id=GetID()
function s.initial_effect(c)
	--link summon
	c:EnableReviveLimit()
	Link.AddProcedure(c,aux.True,2,2,s.lcheck)
	--direct attack
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetCondition(s.effcon)
	e1:SetTarget(s.tgtg)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--atk up
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DECKDES+CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.con)
	e2:SetTarget(s.tg)
	e2:SetOperation(s.op)
	c:RegisterEffect(e2)
end
s.listed_names={12341414}
s.listed_series={0x211}
s.material_setcode={0x211}
function s.lcheck(g,lc)
	return g:IsExists(Card.IsSetCard,1,nil,0x211)
end

function s.cfilter(c)
	return c:IsFaceup() and c:IsCode(12341414)
end
function s.effcon(e)
	return Duel.IsExistingMatchingCard(s.cfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil)
end
function s.tgtg(e,c)
	return e:GetHandler():GetLinkedGroup():IsContains(c)
end

function s.con(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,3) end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,3)
end
function s.filter(c)
	return c:IsLocation(LOCATION_GRAVE) and c:IsSetCard(0x211)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.DiscardDeck(tp,3,REASON_EFFECT)
	local dg=Duel.GetOperatedGroup()
	local ct=dg:FilterCount(s.filter,nil)
	if ct>0 then
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetTargetRange(LOCATION_MZONE,0)
        e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x211))
        e1:SetValue(ct*300)
        e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN)
        Duel.RegisterEffect(e1,tp)
    end
end