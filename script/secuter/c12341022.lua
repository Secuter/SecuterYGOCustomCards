--Blasting Armorizing Dragon
--Scripted by Secuter
if not SECUTER_IMPORTED then Duel.LoadScript("secuter_utility.lua") end
local s,id=GetID()
s.ArmorAtk=700
s.ArmorDef=700
s.Armor=true
s.Armorizing=true
s.Exarmorizing=true
s.Shells=3
function s.initial_effect(c)
	Armor.AddProcedure(c,s,nil,true)
	Armorizing.AddProcedure(c,s.matfilter,1,nil,3)
	c:EnableReviveLimit()
	--attacks twice
	local a1=Effect.CreateEffect(c)
	a1:SetType(EFFECT_TYPE_XMATERIAL)
	a1:SetCode(EFFECT_ATTACK_ALL)
	a1:SetValue(1)
	a1:SetCondition(Armor.Condition)
	c:RegisterEffect(a1)
    --attach
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATTACH_ARMOR)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.atcon)
	e1:SetTarget(s.attg)
	e1:SetOperation(s.atop)
	c:RegisterEffect(e1)
	--negate
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_NEGATE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(s.negcost)
	e2:SetCondition(s.negcon)
	e2:SetTarget(s.negtg)
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2)
end
function s.matfilter(c)
	return c:IsArmor()
end
--attach
function s.atcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_TYPE_ARMORIZING
end
function s.atfilter(c,sc)
	return Armor.AttachCheck(c,sc) and (c:IsFaceup() or not c:IsLocation(LOCATION_REMOVED))
end
function s.attg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.atfilter(chkc,e:GetHandler()) end
	local ct=e:GetHandler():GetMaterial():FilterCount(Card.IsArmorizing,nil)
	if chk==0 then return ct>0 and Duel.IsExistingTarget(s.atfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTACHARMOR)
	local g=Duel.SelectTarget(tp,s.atfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,ct,nil,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_ATTACH_ARMOR,g,#g,0,0)
end
function s.atop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		local g=Duel.GetTargetCards(e)
		if #g>0 then
			Armor.Attach(c,g,e)
		end
	end
end
--negate
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return rp~=tp and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ct=Duel.GetFlagEffectLabel(tp,id) or 0
	if chk==0 then return ct<c:GetOverlayCount() end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,1,0,ct+1)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetHandler():IsRelateToEffect(re) then
		Duel.SendtoGrave(eg,REASON_EFFECT)
	end
end
