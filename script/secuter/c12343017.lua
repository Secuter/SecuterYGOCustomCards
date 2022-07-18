--Hailshift Plateau
--Scripted by Secuter
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--atk gain
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCondition(s.condition)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x224))
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)	
	--activate
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_FZONE)
	e3:SetHintTiming(0,TIMING_MAIN_END)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.accon)
	e3:SetCost(s.accost)
	e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)return Duel.IsExistingMatchingCard(s.acfilter,tp,LOCATION_DECK,0,1,nil,tp)end)
	e3:SetOperation(s.acop)
	c:RegisterEffect(e3)
end
s.listed_names={12343018}
s.listed_series={0x224}
function s.condition(e)
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_EXTRA,0)==0
end
function s.atkval(e,c)
	return Duel.GetMatchingGroupCount(Card.IsFacedown,e:GetHandlerPlayer(),0,LOCATION_EXTRA,nil)*100
end
--activate
function s.accon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
function s.accost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
function s.acfilter(c,tp)
	return c:IsCode(12343018) and c:GetActivateEffect() and c:GetActivateEffect():IsActivatable(tp,true,true)
end
function s.acop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstMatchingCard(s.acfilter,tp,LOCATION_DECK,0,nil,tp)
	aux.PlayFieldSpell(tc,e,tp,eg,ep,ev,re,r,rp)
end