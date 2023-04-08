--Armor S/T
--Scripted by Secuter
local s,id=GetID()
if not ARMOR_IMPORTED then Duel.LoadScript("proc_armor.lua") end
s.ArmorAtk=0
s.ArmorDef=600
s.Armor=true
function s.initial_effect(c)
	--Armor
	Armor.AddProcedure(c,s)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--indes
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.indtg)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	--attach
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_ATTACH_ARMOR)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e3:SetCondition(aux.exccon)
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(s.target)
	e3:SetOperation(s.activate)
	c:RegisterEffect(e3)
end
function s.indtg(e,c)
	return c:GetOverlayCount()>0 and not c:IsType(TYPE_XYZ)
end

function s.tfilter(c,e,tp)
	return Duel.IsExistingTarget(s.afilter,tp,LOCATION_GRAVE,0,1,e:GetHandler(),c) 
end
function s.afilter(c,tc)
	return Armor.AttachCheck(c,tc) and c:GetCode()~=id
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(s.tfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ARMORTARGET)
	local g1=Duel.SelectTarget(tp,s.tfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTACHARMOR)
	e:SetLabelObject(g1:GetFirst())
	local g2=Duel.SelectTarget(tp,s.afilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler(),g1:GetFirst())
	Duel.SetOperationInfo(0,CATEGORY_ATTACH_ARMOR,g2,1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc1=e:GetLabelObject()
	local ex,g=Duel.GetOperationInfo(0,CATEGORY_ATTACH_ARMOR)
	local tc2=g:GetFirst()
	if tc1:IsRelateToEffect(e) and tc2:IsRelateToEffect(e) then
		Armor.Attach(tc1,tc2,e)
	end
end