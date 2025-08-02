--Bulwark Champion Irontheus
--Scripted by Secuter
if not SECUTER_IMPORTED then Duel.LoadScript("secuter_utility.lua") end
local s,id=GetID()
s.ArmorAtk=900
s.ArmorDef=900
s.Armor=true
function s.initial_effect(c)
	Armor.AddProcedure(c,s,nil,true)
	Link.AddProcedure(c,nil,3,nil,s.matcheck)
	c:EnableReviveLimit()
    --atk(quick ef)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
    --negate
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_NEGATE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.negcon)
	e2:SetTarget(s.negtg)
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2)
	--attach
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_ATTACH_ARMOR)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,1})
	e3:SetTarget(s.attg)
	e3:SetOperation(s.atop)
	c:RegisterEffect(e3)
	--to hand
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_XMATERIAL+EFFECT_TYPE_IGNITION)
	e4:SetProperty(EFFECT_FLAG_NO_TURN_RESET+EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG2_ARMOR)
	e4:SetCountLimit(1,{id,2})
	e4:SetCondition(Armor.Condition)
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)
end
s.listed_names={id}
function s.matcheck(g,lnkc,sumtype,tp)
	return g:IsExists(Card.IsArmor,1,nil)
end

--atk
function s.atkfilter(c)
    return c:IsArmor() or c:IsArmorizing()
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsLinkSummoned() then return end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_BASE_ATTACK)
	e1:SetValue(c:GetMaterial():FilterCount(s.atkfilter,nil)*900)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE)
	c:RegisterEffect(e1)
end

--negate
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
	return ep~=tp and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
        and c and re:GetHandler():IsAttackBelow(c:GetAttack())
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c and c:IsRelateToEffect(e) and re:GetHandler():IsAttackBelow(c:GetAttack()) then
	    Duel.NegateActivation(ev)
    end
end

--attach
function s.tgfilter(c,tp)
	return c:IsFaceup() and Duel.IsExistingMatchingCard(Armor.AttachCheck,tp,LOCATION_GRAVE,0,1,nil,c)
end
function s.attg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	Duel.SetOperationInfo(0,CATEGORY_ATTACH_ARMOR,nil,1,tp,LOCATION_GRAVE)
end
function s.atop(e,tp,eg,ep,ev,re,r,rp)
    local g1=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_MZONE,0,nil,tp)
    local g2=Duel.GetMatchingGroup(Card.IsArmor,tp,LOCATION_GRAVE,0,nil)
    while g1:IsExists(s.tgfilter,1,nil,tp) do
	    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTACHARMOR)
        local tc=g1:FilterSelect(tp,s.tgfilter,1,1,nil,tp):GetFirst()
        if tc then
	        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ARMORTARGET)
            local ac=g2:FilterSelect(tp,Armor.AttachCheck,1,1,nil,tc):GetFirst()
			Armor.Attach(tc,ac,e)
            g2:RemoveCard(ac)
        end
        g1:RemoveCard(tc)
    end
end

--to hand
function s.thfilter(c)
	return c:IsArmor() and not c:IsCode(id) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end