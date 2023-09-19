--Tempest
--Scripted by Secuter
if not SECUTER_IMPORTED then Duel.LoadScript("secuter_utility.lua") end
local s,id=GetID()
function s.initial_effect(c)
	--indes
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(s.con)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1,false,1)
	--act in hand
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(s.handcon)
	c:RegisterEffect(e2)
end
s.listed_series={SET_FLUID}

function s.filter(c,tp)
	return  c:IsSetCard(SET_FLUID) and c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE)
end
function s.con(e,tp,eg,ep,ev,re,r,rp)
	--if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	--local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	--return tg and tg:GetCount()==1 and tg:IsExists(s.tfilter,1,nil,tp) and Duel.IsChainNegatable(ev)
	if rp==tp or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return g and g:IsExists(s.filter,1,nil,tp)
		and Duel.IsChainNegatable(ev) and (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE))
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.etarget)
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	Duel.RegisterEffect(e2,tp)
end
function s.etarget(e,c)
	return c:IsFaceup() and c:IsSetCard(SET_FLUID)
end

function s.handfilter(c)
	return c:IsFacedown() or not c:IsSetCard(SET_FLUID)
end
function s.handcon(e)
	return not Duel.IsExistingMatchingCard(s.handfilter,tp,LOCATION_MZONE,0,1,nil)
end
