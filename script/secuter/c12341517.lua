--Armor S/T
--Scripted by Secuter
local s,id=GetID()
if not ARMOR_IMPORTED then Duel.LoadScript("proc_armor.lua") end
s.ArmorAtk=200
s.ArmorDef=200
s.IsArmor=true
function s.initial_effect(c)
	c:EnableCounterPermit(0x304)
	--Armor
	Armor.AddProcedure(c)
	local a1=Effect.CreateEffect(c)
	a1:SetType(EFFECT_TYPE_XMATERIAL)
	a1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	a1:SetCode(EFFECT_UPDATE_ATTACK)
	a1:SetCondition(Armor.Condition)
	a1:SetValue(s.ArmorAtk)
	c:RegisterEffect(a1)
	local a2=a1:Clone()
	a2:SetCode(EFFECT_UPDATE_DEFENSE)
	a2:SetValue(s.ArmorDef)
	c:RegisterEffect(a2)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--increase atk
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_ONFIELD,LOCATION_ONFIELD)
	e2:SetTarget(s.target)
	e2:SetValue(s.value)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	--add
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_SZONE)
	--e4:SetCountLimit(1,id)
	e4:SetCost(s.thcost)
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)
	--add counter
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_CHAIN_SOLVED)
	e5:SetRange(LOCATION_SZONE)
	e5:SetOperation(s.ctop)
	c:RegisterEffect(e5)
end
function s.cfilter1(c,re)
	return c:IsRelateToEffect(re) --and c:GetFlagEffect(FLAG_ARMOR_RESOLVED)==1
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp and re:IsHasCategory(CATEGORY_ATTACH_ARMOR)
	and Duel.IsExistingMatchingCard(s.cfilter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,re) then
		e:GetHandler():AddCounter(0x304,1)
	end
end

function s.target(e,c)
	return c:IsType(TYPE_MONSTER) and c:GetOverlayCount()>0 and not c:IsType(TYPE_XYZ)
end
function s.value(e,c)
	local oc=e:GetHandler()
	return oc:GetCounter(0x304)*100
end

function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x304,4,REASON_COST) end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
    e:GetHandler():RemoveCounter(tp,0x304,4,REASON_COST)
end
function s.thfilter(c)
	return c.IsArmor
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end