ARMOR_IMPORTED			= true
CATEGORY_ATTACH_ARMOR	= 0x20000000
REASON_ARMORIZING		= 0x40000000
SUMMON_TYPE_ARMORIZING	= 0x40
EFFECT_FLAG2_ARMOR		= 0x20000000
HINTMSG_AMATERIAL       = 602
HINTMSG_REMOVEARMOR     = 603
HINTMSG_REMOVEARMORFROM = 604
HINTMSG_ARMORTARGET     = 605
HINTMSG_ATTACHARMOR     = 606
if not aux.ArmorProcedure then
	aux.ArmorProcedure = {}
	Armor = aux.ArmorProcedure
end
if not Armor then
	Armor = aux.ArmorProcedure
end
--[[
add at the start of the script to add Armor/Armorizing procedure
if not ARMOR_IMPORTED then Duel.LoadScript("proc_armor.lua") end
condition if Armorizing summoned
    return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_TYPE_ARMORIZING
]]
--attach armor function
function Armor.AttachCheck(ar,c)
	return ar.IsArmor and not c:IsType(TYPE_XYZ) and (ar.AttachFilter == nil or ar.AttachFilter(c))
end
function Armor.Attach(c,ar)
	Duel.Overlay(c,ar)
end
--add procedure to armor cards
function Armor.AddProcedure(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(1183)
	e1:SetCategory(CATEGORY_ATTACH_ARMOR)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetTarget(Armor.Target)
	e1:SetOperation(Armor.Operation)
	c:RegisterEffect(e1)
end
function Armor.Filter(c,e,tp)
	return not c:IsType(TYPE_XYZ) and c:IsFaceup()
		and (e:GetHandler().AttachFilter == nil or e:GetHandler().AttachFilter(c))
end
function Armor.Target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() and Armor.Filter(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(Armor.Filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ARMORTARGET)
	local g=Duel.SelectTarget(tp,Armor.Filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_ATTACH_ARMOR,g,1,0,0)
end
function Armor.Operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		if c:IsType(TYPE_SPELL+TYPE_TRAP) then c:CancelToGrave() end
		Armor.Attach(tc,Group.FromCards(c))
	end
end
function Armor.Condition(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsType(TYPE_XYZ)
end

--Armorizing Summon
--Parameters:
-- c: card
-- f1: optional, filter for monster material
-- min: min number of armor materials
-- f2: optional, filter for armor materials
if not aux.ArmorizingProcedure then
	aux.ArmorizingProcedure = {}
	Armorizing = aux.ArmorizingProcedure
end
if not Armorizing then
	Armorizing = aux.ArmorizingProcedure
end
function Armorizing.AddProcedure(c,f1,min,f2)
	if c.armorizing_type==nil then
		local mt=c:GetMetatable()
		mt.armorizing_type=1
		mt.armorizing_parameters={c,f1,min,f2}
	end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetDescription(1184)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(Armorizing.Condition(f1,min,f2))
	e1:SetTarget(Armorizing.Target(f1,min,f2))
	e1:SetOperation(Armorizing.Operation)
	e1:SetValue(SUMMON_TYPE_ARMORIZING)
	c:RegisterEffect(e1)
	--remove fusion type
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_REMOVE_TYPE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetRange(LOCATION_ALL)
	e0:SetValue(TYPE_FUSION)
	c:RegisterEffect(e0)
end

function Armorizing.MatFilter(c,sc,tp,f1,min,f2)
	local g=Group.CreateGroup()
	g:AddCard(c)
	return c:IsFaceup() and not c:IsType(TYPE_XYZ)
		and c:GetOverlayCount()>=min
		and (not f2 or c:GetOverlayGroup():IsExists(f2,min,nil,e,tp))
		and (not f1 or f1(c,sc,SUMMON_TYPE_SPECIAL,tp))
        and Duel.GetLocationCountFromEx(tp,tp,g,sc)>0
end
function Armorizing.Condition(f1,min,f2)
	return	function(e,c)
				if c==nil then return true end
				if c:IsType(TYPE_PENDULUM) and c:IsFaceup() then return false end
				local tp=c:GetControler()
				
				return Duel.IsExistingMatchingCard(Armorizing.MatFilter,tp,LOCATION_MZONE,0,1,nil,c,tp,f1,min,f2)
				--local g=Duel.GetMatchingGroup(Armorizing.MatFilter,tp,LOCATION_MZONE,0,nil,f1,c,tp,armor)
				--return aux.SelectUnselectGroup(g,e,tp,1,1,nil,0,c)
            end
end
function Armorizing.Target(f1,min,f2)
	return	function(e,tp,eg,ep,ev,re,r,rp,chk)
                local c=e:GetHandler()
				local tp=e:GetHandlerPlayer()
                
                Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_AMATERIAL)
				local rg=Duel.GetMatchingGroup(Armorizing.MatFilter,tp,LOCATION_MZONE,0,nil,c,tp,f1,min,f2)
				local mg=aux.SelectUnselectGroup(rg,e,tp,1,1,nil,1,tp,HINTMSG_SELECT,nil,nil,true,c)
                
				if #mg>0 then
					local sg=mg:GetFirst():GetOverlayGroup()
					sg:Merge(mg)
							  
					sg:KeepAlive()
					e:SetLabelObject(sg)
					return true
				else
					return false
				end
            end
end
function Armorizing.Operation(e,tp,eg,ep,ev,re,r,rp,c,smat,mg)
	local g=e:GetLabelObject()
	c:SetMaterial(g)
	Duel.SendtoGrave(g,REASON_MATERIAL+REASON_ARMORIZING)
	g:DeleteGroup()
end
-- Armorizing Summon by card effect
function Card.IsArmorizingSummonable(c,e,tp,must_use,mg)
	return c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SPECIAL,tp,false,false)
		and c.IsArmorizing and c:ArmorizingRule(e,tp,must_use,mg)
end
function Card.ArmorizingRule(c,e,tp,mustg,g)
	if c==nil then return true end
	if c:IsType(TYPE_PENDULUM) and c:IsFaceup() then return false end
	local mt=c:GetMetatable()
	local f1=mt.armorizing_parameters[2]
	local min=mt.armorizing_parameters[3]
	local f2=mt.armorizing_parameters[4]
	
	if not g then
		g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	end	
	return g:IsExists(Armorizing.MatFilter,1,nil,c,tp,f1,min,f2)
end
function Armorizing.FilterMustBeMat(mg1,mg2,mustg)
	local tc=mustg:GetFirst()
	while tc do
		if not mg1:IsContains(tc) and not mg2:IsContains(tc) then return false end
		tc=mustg:GetNext()
	end
	return true
end
function Duel.ArmorizingSummon(tp,c,mustg,g)
	local mt=c:GetMetatable()
	local f1=mt.armorizing_parameters[2]
	local min=mt.armorizing_parameters[3]
	local f2=mt.armorizing_parameters[4]
		
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_AMATERIAL)
	if not g then
		g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	end
	local rg=g:Filter(Armorizing.MatFilter,nil,c,tp,f1,min,f2)
	local mg=aux.SelectUnselectGroup(rg,e,tp,1,1,nil,1,tp,HINTMSG_SELECT,nil,nil,true,c)
	
	if #mg>0 then
		local sg=mg:GetFirst():GetOverlayGroup()
		sg:Merge(mg)
		c:SetMaterial(sg)
		Duel.SendtoGrave(sg,REASON_MATERIAL+REASON_ARMORIZING)
		Duel.SpecialSummon(c,SUMMON_TYPE_ARMORIZING,tp,tp,false,false,POS_FACEUP)
		c:CompleteProcedure()
	end
end