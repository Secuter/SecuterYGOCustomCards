--Mace of the Phantom Riders
--Scripted by Secuter
if not SECUTER_IMPORTED then Duel.LoadScript("secuter_utility.lua") end
local s,id=GetID()
function s.initial_effect(c)
	aux.AddEquipProcedure(c)
	--atk
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetCondition(s.eqcon)
	e1:SetValue(500)
	c:RegisterEffect(e1)
    --intarget
    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetCondition(s.eqcon)
    e2:SetValue(aux.tgoval)
    c:RegisterEffect(e2)
    --level 1
    local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_LEVEL)
	e3:SetCondition(s.discon)
    e3:SetValue(1)
    c:RegisterEffect(e3)
    --remove attribute
    local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_REMOVE_ATTRIBUTE)
	e4:SetCondition(s.discon)
    e4:SetValue(function(e) return e:GetHandler():GetAttribute() end)
    c:RegisterEffect(e4)
    --remove type
    local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_EQUIP)
	e5:SetCode(EFFECT_REMOVE_RACE)
	e5:SetCondition(s.discon)
    e5:SetValue(function(e) return e:GetHandler():GetRace() end)
    c:RegisterEffect(e5)
	--search
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,0))
	e6:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e6:SetType(EFFECT_TYPE_IGNITION)
	e6:SetRange(LOCATION_SZONE)
	e6:SetCountLimit(1,id)
	e6:SetCondition(s.thcon)
	e6:SetTarget(s.thtg)
	e6:SetOperation(s.thop)
	c:RegisterEffect(e6)
end
s.listed_series={SET_PHANTOM_RIDERS}
function s.eqcon(e,c)
	return e:GetHandler():GetEquipTarget():IsSetCard(SET_PHANTOM_RIDERS)
end
function s.discon(e,c)
	return not e:GetHandler():GetEquipTarget():IsSetCard(SET_PHANTOM_RIDERS)
end

--search
function s.thcon(e,c)
	return e:GetHandler():GetEquipTarget():IsControler(e:GetHandlerPlayer())
end
function s.thfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_WARRIOR) and c:IsLevelAbove(5) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end