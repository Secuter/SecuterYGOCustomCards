--Armor
--Scripted by Secuter
local s,id=GetID()
if not ARMOR_IMPORTED then Duel.LoadScript("proc_armor.lua") end
s.ArmorAtk=500
s.ArmorDef=500
s.IsArmor=true
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Armor
	Armor.AddProcedure(c,s)
	--spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACH_ARMOR)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--attach
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_ATTACH_ARMOR)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(s.attg)
	e2:SetOperation(s.atop)
	c:RegisterEffect(e2)
end
--[[function s.ArmorValue(e,c)
	if e:GetHandler():GetFlagEffect(id)~=0 then
		return 1500
	else
		return s.ArmorAtk --500
	end
end]]

function s.spfilter(c,e,tp)
	return c.IsArmor and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,true,false,POS_FACEUP_DEFENSE)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFieldID() == ev
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
function s.filter(c,ar)
	return c:IsFaceup() and Armor.AttachCheck(ar,c)
end
function s.attg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc,c) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,c,c)
		and e:GetHandler():GetFlagEffect(id)==0 end
	e:GetHandler():RegisterFlagEffect(id,RESET_CHAIN,0,1)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ARMORTARGET)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,c,c)
	Duel.SetOperationInfo(0,CATEGORY_ATTACH_ARMOR,g,1,0,0)
end
function s.atop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
		if c:GetOverlayCount()>0 then
			Duel.SendtoGrave(c:GetOverlayGroup(),REASON_RULE)
		end
		c:CancelToGrave()
		Armor.Attach(tc,c,e)
		c:RegisterFlagEffect(EFFECT_ARMORATK_REP,RESET_EVENT|RESETS_STANDARD,0,1,1500)
	end
end