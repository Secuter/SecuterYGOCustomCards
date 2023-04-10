--Armorizing God Kirthas
--Scripted by Secuter
local s,id=GetID()
if not ARMOR_IMPORTED then Duel.LoadScript("proc_armor.lua") end
s.ArmorAtk=800
s.ArmorDef=800
s.Armor=true
s.Armorizing=true
s.Exarmorizing=true
s.Shells=6
function s.initial_effect(c)
	Armor.AddProcedure(c,s,nil,true)
	Armorizing.AddProcedure(c,s.matfilter,1,nil,3)
	c:EnableReviveLimit()
	--spsummon from armor
	local a1=Effect.CreateEffect(c)
	a1:SetDescription(aux.Stringid(id,0))
	a1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_ATTACH_ARMOR)
	a1:SetType(EFFECT_TYPE_XMATERIAL+EFFECT_TYPE_IGNITION)
	a1:SetProperty(EFFECT_FLAG2_ARMOR)
	a1:SetCountLimit(1,id)
	a1:SetCondition(s.spcon)
	a1:SetTarget(s.sptg)
	a1:SetOperation(s.spop)
	c:RegisterEffect(a1)
	--cannot disable armorizing summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCondition(s.effcon)
	c:RegisterEffect(e1)
	--immune
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.efilter)
	c:RegisterEffect(e2)
	--atk/def
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(s.adval)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e4)
	--attach
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetCategory(CATEGORY_ATTACH_ARMOR)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_PHASE+PHASE_END)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1)
	e5:SetTarget(s.attg)
	e5:SetOperation(s.atop)
	c:RegisterEffect(e5)
	--disable
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,2))
	e6:SetCategory(CATEGORY_DISABLE)
	e6:SetType(EFFECT_TYPE_QUICK_O)
	e6:SetCode(EVENT_FREE_CHAIN)
	e6:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCountLimit(2,{id,1})
	e6:SetTarget(s.distg)
	e6:SetOperation(s.disop)
	c:RegisterEffect(e6)
end
--mats
function s.matfilter(c)
	return c:IsArmor() and (c:GetOverlayCount()>=2 or c:IsArmorizing())
end
--spsummon from armor
function s.spcon(e)
	return Armor.Condition(e) and e:GetHandler():GetOverlayCount()>=3
end
function s.spfilter(c,e,tp,tc,g)
	g:RemoveCard(c)
	return c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Armor.AttachCheck(tc,c) and not g:IsExists(aux.NOT(Armor.AttachCheck),1,nil,c)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local g=c:GetOverlayGroup()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and g:IsExists(s.spfilter,1,nil,e,tp,c,g) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_OVERLAY)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	local c=e:GetHandler()
	local g=c:GetOverlayGroup()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=g:FilterSelect(tp,s.spfilter,1,1,nil,e,tp,c,g):GetFirst()
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
		g:RemoveCard(tc)
		g:AddCard(c)
		Duel.Overlay(tc,g,true)
	end
end
--cannot negate sp
function s.effcon(e)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_TYPE_ARMORIZING
end
--immune
function s.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end
--atk/def
function s.adfilter(c)
	return c:IsFaceup() and not c:IsType(TYPE_XYZ)
end
function s.adval(e,c)
	local g=Duel.GetMatchingGroup(s.adfilter,e:GetHandlerPlayer(),LOCATION_MZONE,LOCATION_MZONE,nil)
	local ct=0
	local tc=g:GetFirst()
	while tc do
		ct=ct+tc:GetOverlayCount()
		tc=g:GetNext()
	end
	return ct*800
end
--attach
function s.filter(c)
	return c:IsFaceup() and c:IsArmorizing()
end
function s.atfilter(c,tc)
	return Armor.AttachCheck(c,tc) and (c:IsFaceup() or not c:IsLocation(LOCATION_REMOVED))
end
function s.attg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsArmorizing),tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		and Duel.IsExistingMatchingCard(s.atfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e:GetHandler()) end
	Duel.SetOperationInfo(0,CATEGORY_ATTACH_ARMOR,nil,1,tp,LOCATION_DECK)
end
function s.atop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsArmorizing),tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if c:IsRelateToEffect(e) and not c:IsImmuneToEffect(e) and ct>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTACHARMOR)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.atfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,ct,nil,c)
		if #g>0 then
			Armor.Attach(c,g,e)
		end
	end
end
--disable
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and chkc:IsNegatable() end
	local ct=e:GetHandler():GetOverlayCount()
	if chk==0 then return ct>0 and Duel.IsExistingTarget(Card.IsNegatable,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
	local g=Duel.SelectTarget(tp,Card.IsNegatable,tp,0,LOCATION_ONFIELD,1,ct,nil)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,#g,0,0)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local dg=Duel.GetTargetCards(e)
	if #dg==0 then return end
	local c=e:GetHandler()
	for tc in dg:Iter() do
		if (tc:IsFaceup() and not tc:IsDisabled()) or tc:IsType(TYPE_TRAPMONSTER) then
			Duel.NegateRelatedChain(tc,RESET_TURN_SET)
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2)
			if tc:IsType(TYPE_TRAPMONSTER) then
				local e3=Effect.CreateEffect(c)
				e3:SetType(EFFECT_TYPE_SINGLE)
				e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
				e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				tc:RegisterEffect(e3)
			end
		end
	end
end