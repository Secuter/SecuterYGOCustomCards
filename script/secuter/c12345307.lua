--Armor Magician Spellbreaker
--Scripted by Secuter
if not SECUTER_IMPORTED then Duel.LoadScript("secuter_utility.lua") end
local s,id=GetID()
s.ArmorAtk=500
s.ArmorDef=0
s.Armor=true
function s.initial_effect(c)
	--Armor
	Armor.AddProcedure(c,s)
	--spsummon procedure
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--attach
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_ATTACH_ARMOR)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_ATTACH_ARMOR)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.atcon)
	e2:SetTarget(s.attg)
	e2:SetOperation(s.atop)
	c:RegisterEffect(e2)
	--send to grave or banish
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(0,TIMING_MAIN_END)
	e3:SetCountLimit(1,{id,2})
	e3:SetCondition(s.tgcon)
	e3:SetCost(s.tgcost)
	e3:SetTarget(s.tgtg)
	e3:SetOperation(s.tgop)
	c:RegisterEffect(e3)
end
s.listed_names={id}
s.listed_series={SET_ARMOR_MAGICIAN}
--spsummon procedure
function s.cfilter(c)
	return c:IsFaceup() and not c:IsType(TYPE_XYZ)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local tp=e:GetHandlerPlayer()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return false end
	local g=Group.CreateGroup()
	local mg=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,0,nil)
	for tc in aux.Next(mg) do
		g:Merge(tc:GetOverlayGroup())   
	end
	return #g>0
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local g=Group.CreateGroup()
	local mg=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,0,nil)
	for tc in aux.Next(mg) do
		g:Merge(tc:GetOverlayGroup())
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVEXYZ)
	local sg=g:Select(tp,1,1,nil)
	Duel.SendtoGrave(sg,REASON_COST)
end
--attach
function s.atcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFieldID() == ev
end
function s.atfilter(c,tc)
	return c:IsSetCard(SET_ARMOR_MAGICIAN) and not c:IsCode(id) and Armor.AttachCheck(c,tc) and (c:IsFaceup() or not c:IsLocation(LOCATION_REMOVED))
end
function s.attg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(s.atfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e:GetHandler()) end
	Duel.SetOperationInfo(0,CATEGORY_ATTACH_ARMOR,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
function s.atop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTACHARMOR)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.atfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,c)
		if #g>0 then
			Armor.Attach(c,g,e)
		end
	end
end
--send to grave or banish
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsMainPhase()
end
function s.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.tgfilter(c)
	return c:IsSetCard(SET_ARMOR_MAGICIAN) and not c:IsCode(id) and (c:IsAbleToGrave() or c:IsAbleToRemove())
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
    local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		local thchk=tc:IsAbleToGrave()
        local rmchk=tc:IsAbleToRemove()
		local op=0
		if thchk and rmchk then
			op=Duel.SelectOption(tp,aux.Stringid(id,3),aux.Stringid(id,4))
		elseif thchk then
			op=0
		elseif rmchk then
			op=1
		end
		if op==0 then
            Duel.SendtoGrave(tc,REASON_EFFECT)
        else
            Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
        end
    end
end
