--Cracking Chain
--Scripted by Secuter
if not SECUTER_IMPORTED then Duel.LoadScript("secuter_utility.lua") end
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--atk
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(aux.NOT(aux.TargetBoolFunction(Card.IsCracking)))
	e2:SetValue(-500)
	c:RegisterEffect(e2)
	--disable
	local e3=Effect.CreateEffect(c)
	e3:SetCode(EFFECT_DISABLE)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTarget(s.distg)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetCode(EVENT_CHAIN_SOLVING)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCondition(s.discon)
	e4:SetOperation(s.disop)
	c:RegisterEffect(e4)
end
s.listed_series={SET_CRACKING}
function Card.IsCracking(c,tc,sumtype,tp) return c:IsSetCard(SET_CRACKING,tc,sumtype,tp) or c:IsCode(60349525) or c:IsCode(32835363) or c:IsCode(98864751) end
function Card.IsCrackingOrWyvern(c,tc,sumtype,tp) return c:IsSetCard(SET_CRACKING,tc,sumtype,tp) or c:IsCode(60349525) or c:IsCode(32835363) or c:IsCode(98864751) or c:IsCode(23850421) end
--disable
function s.distg(e,c)
	return c:IsAttack(0)
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsAttack(0)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	Duel.NegateEffect(ev)
end
