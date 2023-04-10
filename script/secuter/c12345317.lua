--Armor Magician Spellbound Dreamer
--Scripted by Secuter
local s,id=GetID()
if not ARMOR_IMPORTED then Duel.LoadScript("proc_armor.lua") end
s.ArmorAtk=1500
s.ArmorDef=0
s.Armor=true
s.Armorizing=true
s.Exarmorizing=true
s.Shells=2
function s.initial_effect(c)
	Armor.AddProcedure(c,s,nil,true)
	Armorizing.AddProcedure(c,s.matfilter,1,nil,2)
	c:EnableReviveLimit()
    --attach
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATTACH_ARMOR)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.atcon)
	e1:SetTarget(s.attg)
	e1:SetOperation(s.atop)
	c:RegisterEffect(e1)
	--negate special summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_SPSUMMON)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.discon)
	e2:SetCost(s.discost)
	e2:SetTarget(s.distg)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
end
function s.matfilter(c,lc,sumtype,tp)
	return c:IsRace(RACE_SPELLCASTER,lc,sumtype,tp)
end
--attach
function s.atcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_TYPE_ARMORIZING
end
function s.atfilter(c,sc)
	return c:IsSpellTrap() and Armor.AttachCheck(c,sc)
end
function s.class(c)
	return c:GetType()&(TYPE_SPELL|TYPE_TRAP)
end
function s.check(sg,e,tp)
	return sg:GetClassCount(s.class)==#sg
end
function s.attg(e,tp,eg,ep,ev,re,r,rp,chk)
	local sg=Duel.GetMatchingGroup(s.atfilter,tp,LOCATION_DECK,0,nil,e:GetHandler())
	if chk==0 then return #sg>0	and aux.SelectUnselectGroup(sg,e,tp,2,2,s.check,0) end
	Duel.SetOperationInfo(0,CATEGORY_ATTACH_ARMOR,nil,2,tp,LOCATION_DECK)
end
function s.atop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local sg=Duel.GetMatchingGroup(s.atfilter,tp,LOCATION_DECK,0,nil,c)
	if c:IsRelateToEffect(e) then
		local g=aux.SelectUnselectGroup(sg,e,tp,2,2,s.check,1,tp,HINTMSG_ATTACHARMOR)
		if #g==2 then
			c:AttachArmor(g,e)
		end
	end
end
--negate sp
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return tp~=ep and Duel.GetCurrentChain()==0
end
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not eg:IsExists(aux.NOT(Card.IsAbleToRemove),1,nil,tp) end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,#eg,0,0)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,eg,#eg,0,0)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateSummon(eg)
	Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)
end