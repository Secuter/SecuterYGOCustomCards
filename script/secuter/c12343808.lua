--Crearmor Armorsoul Fighter
--Scripted by Secuter
if not ARMOR_IMPORTED then Duel.LoadScript("proc_armor.lua") end
local s,id=GetID()
s.ArmorAtk=300
s.ArmorDef=0
s.Armor=true
function s.initial_effect(c)
	--armor
	Armor.AddProcedure(c,s,nil,true)
	--link summon
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0x22B),2,2)
	c:EnableReviveLimit()
	--intarget
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_XMATERIAL)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetCondition(Armor.Condition)
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	--attach
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_ATTACH_ARMOR)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.atcon)
	e3:SetTarget(s.attg)
	e3:SetOperation(s.atop)
	c:RegisterEffect(e3)
	--attach #2
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_ATTACH_ARMOR)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,{id,1})
	e4:SetCondition(aux.zptcon(s.tgfilter3))
	e4:SetTarget(s.attg3)
	e4:SetOperation(s.atop3)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_SUMMON_SUCCESS)
	c:RegisterEffect(e5)
	local e6=e4:Clone()
	e6:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e6)
end
s.listed_series={0x22B}
s.material_setcode={0x22B}
--attach
function s.atcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()&SUMMON_TYPE_LINK>0
end
function s.atfilter(c,sc)
	return c:IsSetCard(0x22B) and Armor.AttachCheck(c,sc)
end
function s.attg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.atfilter,tp,LOCATION_MZONE,0,1,nil,c) end
	Duel.SetOperationInfo(0,CATEGORY_ATTACH_ARMOR,nil,1,tp,LOCATION_DECK)
end
function s.atop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and not c:IsImmuneToEffect(e) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTACHARMOR)
		local g=Duel.SelectMatchingCard(tp,s.atfilter,tp,LOCATION_DECK,0,1,1,nil,c)
		if #g>0 then
			Armor.Attach(c,g,e)
		end
	end
end
--attach #2
function s.tgfilter3(c,tp)
	return c:IsFaceup() and Duel.IsExistingMatchingCard(s.atfilter,tp,LOCATION_GRAVE,0,1,nil,c)
end
function s.attg3(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local lg=c:GetLinkedGroup()
	local g=lg&eg
	if chkc then return lg:IsContains(chkc) and s.tgfilter3(chkc,tp) end
	if chk==0 then return lg:IsExists(s.tgfilter3,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local sg=g:FilterSelect(tp,s.tgfilter3,1,1,nil,tp)
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_ATTACH_ARMOR,nil,1,tp,LOCATION_GRAVE)
end
function s.atop3(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTACHARMOR)
		local g=Duel.SelectMatchingCard(tp,s.atfilter,tp,LOCATION_GRAVE,0,1,1,nil,tc)
		if #g>0 then
			Armor.Attach(tc,g,e)
		end
	end
end