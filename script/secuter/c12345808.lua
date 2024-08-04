--Spear of the Phantom Riders
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
    --atk/def
    local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_SET_BASE_ATTACK)
	e3:SetCondition(s.discon)
    e3:SetValue(function(e) return e:GetHandler():GetEquipTarget():GetTextAttack()/2 end)
    c:RegisterEffect(e3)
    local e4=e3:Clone()
	e4:SetCode(EFFECT_SET_BASE_DEFENSE)
    e4:SetValue(function(e) return e:GetHandler():GetEquipTarget():GetTextDefense()/2 end)
    c:RegisterEffect(e4)
    --double dmg
    local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_EQUIP)
	e5:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e5:SetCondition(aux.AND(s.discon,s.damcon))
	e5:SetValue(aux.ChangeBattleDamage(1,DOUBLE_DAMAGE))
    c:RegisterEffect(e5)
	--set
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,0))
	e6:SetType(EFFECT_TYPE_IGNITION)
	e6:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
	e6:SetRange(LOCATION_SZONE)
	e6:SetCountLimit(1,id)
	e6:SetCondition(s.setcon)
	e6:SetTarget(s.settg)
	e6:SetOperation(s.setop)
	c:RegisterEffect(e6)
end
s.listed_series={SET_PHANTOM_RIDERS}
function s.eqcon(e,c)
	return e:GetHandler():GetEquipTarget():IsSetCard(SET_PHANTOM_RIDERS)
end
function s.discon(e,c)
	return not e:GetHandler():GetEquipTarget():IsSetCard(SET_PHANTOM_RIDERS)
end

--double dmg
function s.damcon(e)
	local tc=e:GetHandler():GetEquipTarget():GetBattleTarget()
	return tc and tc:IsSetCard(SET_PHANTOM_RIDERS)
end

--set
function s.setcon(e,c)
	return e:GetHandler():GetEquipTarget():IsControler(e:GetHandlerPlayer())
end
function s.setfilter(c)
	return c:IsSetCard(SET_PHANTOM_RIDERS) and c:IsTrap() and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		local tc=g:GetFirst()
		Duel.SSet(tp,tc)
	end
end