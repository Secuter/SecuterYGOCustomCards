--Armor Magician's Bloodmancy
--Scripted by Secuter
if not SECUTER_IMPORTED then Duel.LoadScript("secuter_utility.lua") end
local s,id=GetID()
s.ArmorAtk=0
s.ArmorDef=0
s.Armor=true
function s.initial_effect(c)
	--Armor
	Armor.AddProcedure(c,s)
	--intarget
	local a1=Effect.CreateEffect(c)
	a1:SetType(EFFECT_TYPE_XMATERIAL)
	a1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	a1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	a1:SetCondition(Armor.Condition)
	a1:SetValue(aux.tgoval)
	c:RegisterEffect(a1)
	--attach
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATTACH_ARMOR)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.attg)
	e1:SetOperation(s.atop)
	c:RegisterEffect(e1)
	--attach #2
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_ATTACH_ARMOR)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.attg2)
	e2:SetOperation(s.atop2)
	c:RegisterEffect(e2)
end
s.listed_names={id}
s.listed_series={SET_ARMOR_MAGICIAN}
--attach armor
function s.atfilter(c,sc)
	return c:IsSetCard(SET_ARMOR_MAGICIAN) and Armor.AttachCheck(c,sc)
end
function s.tgfilter(c,tp)
	return c:IsSetCard(SET_ARMOR_MAGICIAN) and c:IsFaceup() and Duel.IsExistingMatchingCard(s.atfilter,tp,LOCATION_GRAVE,0,1,nil,c)
end
function s.attg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.tgfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_MZONE,0,1,c,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ARMORTARGET)
	local g=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_MZONE,0,1,1,c,tp)
	Duel.SetOperationInfo(0,CATEGORY_ATTACH_ARMOR,nil,1,tp,LOCATION_GRAVE)
end
function s.atop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTACHARMOR)
		local g=Duel.SelectMatchingCard(tp,s.atfilter,tp,LOCATION_GRAVE,0,1,3,nil,tc)
		if #g>0 then
			Armor.Attach(tc,g,e)
		end
	end
end
--attach #2
function s.atfilter2(c,sc)
	return c:IsSetCard(SET_ARMOR_MAGICIAN) and not c:IsCode(id) and Armor.AttachCheck(c,sc) and (c:IsFaceup() or not c:IsLocation(LOCATION_REMOVED))
end
function s.tgfilter2(c,tp)
	return c:IsSetCard(SET_ARMOR_MAGICIAN) and c:IsFaceup() and Duel.IsExistingMatchingCard(s.atfilter2,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,c)
end
function s.attg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.tgfilter2(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter2,tp,LOCATION_MZONE,0,1,c,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ARMORTARGET)
	local g=Duel.SelectTarget(tp,s.tgfilter2,tp,LOCATION_MZONE,0,1,1,c,tp)
	Duel.SetOperationInfo(0,CATEGORY_ATTACH_ARMOR,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
function s.atop2(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTACHARMOR)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.atfilter2),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,tc)
		if #g>0 then
			Armor.Attach(tc,g,e)
		end
	end
end
