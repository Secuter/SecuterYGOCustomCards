--The First Relinquished
--Scripted by Secuter
if not ECHO_IMPORTED then Duel.LoadScript("proc_echo.lua") end
local s,id=GetID()
s.Echo=true
function s.initial_effect(c)
	--echo summon
	Echo.AddProcedure(c,s.efilter)
	c:EnableReviveLimit()
	--equip
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.eqcon1)
	e1:SetTarget(s.eqtg)
	e1:SetOperation(s.eqop)
	c:RegisterEffect(e1)
	aux.AddEREquipLimit(c,nil,function(ec,_,tp) return ec:IsControler(1-tp) end,s.equipop,e1)
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCondition(s.eqcon2)
	c:RegisterEffect(e2)
	--atk/def
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.adcon)
	e3:SetValue(s.atkval)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_UPDATE_DEFENSE)
	e4:SetValue(s.defval)
	c:RegisterEffect(e4)
end
s.listed_series={SET_RELINQUISHED}
function s.efilter(c,sc,sumtype,tp)
	return c:IsLevel(1) or c:IsRank(1) or c:IsLink(1)
end
--equip
function s.eqcon1(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():GetEquipGroup():IsExists(Card.IsSetCard,1,nil,SET_RELINQUISHED)
end
function s.eqcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetEquipGroup():IsExists(Card.IsSetCard,1,nil,SET_RELINQUISHED)
end
function s.filter(c)
	return c:IsAbleToChangeControler() and c:IsFaceup()
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.filter(chkc) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(s.filter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsMonster() and tc:IsControler(1-tp) then
		s.equipop(c,e,tp,tc)
	end
end
function s.equipop(c,e,tp,tc)
	c:EquipByEffectAndLimitRegister(e,tp,tc,id) 
end
--atk
function s.eqfilter(c)
	return c:GetFlagEffect(id)~=0 
end
function s.adcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=c:GetEquipGroup():Filter(s.eqfilter,nil)
	return #g>0
end
function s.atkval(e,c)
	local c=e:GetHandler()
	local g=c:GetEquipGroup():Filter(s.eqfilter,nil)
	local atk=0
	local tc=g:GetFirst()
	while tc do
		if tc:GetOriginalType()&TYPE_MONSTER==TYPE_MONSTER then atk=atk+tc:GetTextAttack() end
		tc=g:GetNext()
	end
	return atk
end
function s.defval(e,c)
	local c=e:GetHandler()
	local g=c:GetEquipGroup():Filter(s.eqfilter,nil)
	local def=0
	local tc=g:GetFirst()
	while tc do
		if tc:GetOriginalType()&TYPE_MONSTER==TYPE_MONSTER then def=def+tc:GetTextDefense() end
		tc=g:GetNext()
	end
	return def
end