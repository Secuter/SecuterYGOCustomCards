--Crearmor Blocking Lion
--Scripted by Secuter
local s,id=GetID()
if not ARMOR_IMPORTED then Duel.LoadScript("proc_armor.lua") end
s.ArmorAtk=300
s.ArmorDef=0
s.Armor=true
function s.initial_effect(c)
	--Armor
	Armor.AddProcedure(c,s)
	--spsummon itself & attach
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_ATTACH_ARMOR)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--spsummon
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(s.spcost2)
	e3:SetTarget(s.sptg2)
	e3:SetOperation(s.spop2)
	c:RegisterEffect(e3)
	--attach itself
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_ATTACH_ARMOR)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCountLimit(1,{id,1})
	e4:SetCondition(s.atcon)
	e4:SetTarget(s.attg)
	e4:SetOperation(s.atop)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_REMOVE)
	e5:SetCondition(s.rmcon)
	c:RegisterEffect(e5)
end
s.listed_series={0x22B}
--spsummon itself & attach
function s.atfilter(c,sc)
	return Armor.AttachCheck(c,sc) and c:IsFaceup() and not c:IsCode(id)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_ONFIELD) and s.atfilter(chkc,c) end
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.atfilter,tp,LOCATION_ONFIELD,0,1,nil,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTACHARMOR)
	local g=Duel.SelectTarget(tp,s.atfilter,tp,LOCATION_ONFIELD,0,1,1,nil,c)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_ATTACH_ARMOR,g,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		local tc=Duel.GetFirstTarget()
		if tc and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
			Duel.BreakEffect()
			if tc:GetOverlayCount()>0 then
				Duel.SendtoGrave(tc:GetOverlayGroup(),REASON_RULE)
			end
			Armor.Attach(c,tc,e)
		end
	end
end
--spsummon
function s.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.spfilter2(c,e,tp)
	return c:IsSetCard(0x22B) and c:IsLevelBelow(4) and not c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter2(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.spfilter2,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.spfilter2,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
--attach
function s.atcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and (r&REASON_ARMORIZING)==REASON_ARMORIZING
end
function s.atfilter(c,ar)
	return c:IsSetCard(0x22B) and c:IsFaceup() and Armor.AttachCheck(ar,c)
end
function s.attg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.atfilter(chkc,c) end
	if chk==0 then return Duel.IsExistingTarget(s.atfilter,tp,LOCATION_MZONE,0,1,nil,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ARMORTARGET)
	local g=Duel.SelectTarget(tp,s.atfilter,tp,LOCATION_MZONE,0,1,1,nil,c)
	Duel.SetOperationInfo(0,CATEGORY_ATTACH_ARMOR,c,1,0,0)
end
function s.atop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
		Armor.Attach(tc,c,e)
	end
end
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_REMOVED) and (r&REASON_ARMORIZING)==REASON_ARMORIZING
end