--Armor S/T
--Scripted by Secuter
local s,id=GetID()
if not ARMOR_IMPORTED then Duel.LoadScript("proc_armor.lua") end
s.ArmorAtk=300
s.ArmorDef=300
s.IsArmor=true
function s.initial_effect(c)
	--Armor
	Armor.AddProcedure(c,s)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_ATTACH_ARMOR)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_names={id}

function s.tfilter(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and not c:IsType(TYPE_XYZ)
		and Duel.IsExistingTarget(s.afilter,tp,LOCATION_GRAVE,0,1,nil,c) 
end
function s.afilter(c,tc)
	return Armor.AttachCheck(c,tc) and c:GetCode()~=id
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(s.tfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ARMORTARGET)
	local g1=Duel.SelectTarget(tp,s.tfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTACHARMOR)
	e:SetLabelObject(g1:GetFirst())
	local g2=Duel.SelectTarget(tp,s.afilter,tp,LOCATION_GRAVE,0,1,2,nil,g1:GetFirst())
	Duel.SetOperationInfo(0,CATEGORY_ATTACH_ARMOR,g2,g2:GetCount(),0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc1=e:GetLabelObject()
	local ex,g=Duel.GetOperationInfo(0,CATEGORY_ATTACH_ARMOR)
	local tc2=g:GetFirst()
	while tc2 do
		if tc1:IsRelateToEffect(e) and tc2:IsRelateToEffect(e) then
			Armor.Attach(tc1,tc2,e)
		end
		tc2=g:GetNext()
	end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_OATH)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.ftarget)
	e1:SetLabel(tc1:GetFieldID())
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.ftarget(e,c)
	return e:GetLabel()~=c:GetFieldID()
end