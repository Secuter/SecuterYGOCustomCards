--Armor Magician Knight
--Scripted by Secuter
if not SECUTER_IMPORTED then Duel.LoadScript("secuter_utility.lua") end
local s,id=GetID()
s.ArmorAtk=500
s.ArmorDef=0
s.Armor=true
function s.initial_effect(c)
	--Armor
	Armor.AddProcedure(c,s)
    --attach
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATTACH_ARMOR)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.attg)
	e1:SetOperation(s.atop)
	c:RegisterEffect(e1)
	--attach #2
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_ATTACH_ARMOR)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.atcon2)
	e2:SetTarget(s.attg2)
	e2:SetOperation(s.atop2)
	c:RegisterEffect(e2)
end
s.listed_names={id}
s.listed_series={SET_ARMOR_MAGICIAN}
--attach
function s.attg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and Armor.AttachCheck(chkc,e:GetHandler()) end
	if chk==0 then return Duel.IsExistingTarget(Armor.AttachCheck,tp,LOCATION_GRAVE,0,1,nil,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTACHARMOR)
	local g=Duel.SelectTarget(tp,Armor.AttachCheck,tp,LOCATION_GRAVE,0,1,1,nil,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_ATTACH_ARMOR,g,1,0,0)
end
function s.atop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
		Armor.Attach(c,tc,e)
	end
end
--attach #2
function s.atcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and bit.band(r,REASON_ARMORIZING)==REASON_ARMORIZING
end
function s.atfilter2(c,sc)
	return c:IsSetCard(SET_ARMOR_MAGICIAN) and not c:IsCode(id) and Armor.AttachCheck(c,sc) and (c:IsFaceup() or not c:IsLocation(LOCATION_REMOVED))
end
function s.tgfilter(c,tp)
	return c:IsSetCard(SET_ARMOR_MAGICIAN) and c:IsFaceup() and Duel.IsExistingMatchingCard(s.atfilter2,tp,LOCATION_REMOVED+LOCATION_GRAVE,0,1,nil,c)
end
function s.attg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.tgfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_MZONE,0,1,c,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ARMORTARGET)
	local g=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_MZONE,0,1,1,c,tp)
	Duel.SetOperationInfo(0,CATEGORY_ATTACH_ARMOR,nil,1,tp,LOCATION_REMOVED+LOCATION_GRAVE)
end
function s.atop2(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTACHARMOR)
		local g=Duel.SelectMatchingCard(tp,s.atfilter2,tp,LOCATION_REMOVED+LOCATION_GRAVE,0,1,1,nil,tc)
		if #g>0 then
			Armor.Attach(tc,g,e)
		end
	end
end
