--Aquaraid Sprawling Terror
--Scripted by Secuter
if not SECUTER_IMPORTED then Duel.LoadScript("secuter_utility.lua") end
local s,id=GetID()
function s.initial_effect(c)
	-- link summon
	c:EnableReviveLimit()
	Link.AddProcedure(c,s.matfilter,2)
	-- cannot be targeted
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.efilter)
	c:RegisterEffect(e1)
	-- indes effect
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(aux.indoval)
	c:RegisterEffect(e2)
	-- atk
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(s.atkval)
	c:RegisterEffect(e3)
	-- negate
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e4:SetCode(EVENT_CHAINING)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id)
	e4:SetCondition(s.negcon)
	e4:SetTarget(s.negtg)
	e4:SetOperation(s.negop)
	c:RegisterEffect(e4)
end
function s.matfilter(c,lc,sumtype,tp)
	return c:IsAttribute(ATTRIBUTE_WATER,lc,sumtype,tp)
end
-- target
function s.efilter(e,re,rp)
	return aux.tgoval(e,re,rp) and re:IsActiveType(TYPE_MONSTER)
end
-- indes
function s.indfilter(e,re,rp)
	return aux.indoval(e,re,rp) and re:IsActiveType(TYPE_MONSTER)
end
-- atk
function s.atkfilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end
function s.atkval(e,c)
	local tp=e:GetHandlerPlayer()
	local ct=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsAttribute,ATTRIBUTE_WATER),tp,LOCATION_MZONE,0,nil):GetClassCount(Card.GetRace)
	return ct*200
end
-- negate
function s.filter(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_NORMAL) and c:IsAttribute(ATTRIBUTE_WATER)
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,LOCATION_GRAVE,0)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and ep==1-tp
		and re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and Duel.IsChainNegatable(ev)
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
