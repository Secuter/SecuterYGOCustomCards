--Armor S/T
--Scripted by Secuter
if not SECUTER_IMPORTED then Duel.LoadScript("secuter_utility.lua") end
local s,id=GetID()
s.ArmorAtk=0
s.ArmorDef=0
s.Armor=true
function s.initial_effect(c)
	--Armor
	Armor.AddProcedure(c,s)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_ATTACH_ARMOR)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--to grave
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
end
s.listed_names={id}
function s.armor_value(e,c)
	return e:GetHandler():GetOverlayCount()*100
end

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
	local g2=Duel.SelectTarget(tp,s.afilter,tp,LOCATION_GRAVE,0,1,1,nil,g1:GetFirst())
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

function s.tgfilter(c)
	return c:IsFaceup() and c:IsArmor() and not c:IsCode(id)
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and s.tgfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_REMOVED,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoGrave(tc,REASON_EFFECT+REASON_RETURN)
	end
end
