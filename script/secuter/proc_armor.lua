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
EVENT_ATTACH_ARMOR		= 1300
armor_log_only_once		= true
attach_log_only_once	= true
if not aux.ArmorProcedure then
	aux.ArmorProcedure = {}
	Armor = aux.ArmorProcedure
end
if not Armor then
	Armor = aux.ArmorProcedure
end
--[[
Add this at the start of the card script to add Armor/Armorizing procedure and constants
if not ARMOR_IMPORTED then Duel.LoadScript("proc_armor.lua") end
Condition if Armorizing summoned
    return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_TYPE_ARMORIZING
Condition if card is related with an effect triggered by EVENT_ATTACH_ARMOR
	e:GetHandler():GetFieldID() == ev
]]
-- attach armor function
function Armor.AttachCheck(ar,c)
	return ar.IsArmor and not c:IsType(TYPE_XYZ) and (ar.AttachFilter == nil or ar.AttachFilter(c))
end
function Armor.Attach(c,ar,e)
	-- Armor.Attach(Card target, Card|Group armor, Effect e)
	if not e and attach_log_only_once then
		Debug.Message("proc_armor.lua has been updated!\nNow you have to call Armor.Attach passing the effect as well, eg. Armor.Attach(tc,c,e) instead of Armor.Attach(tc,c).\nThe new function is Armor.Attach(Card target, Card|Group armor, Effect e)")
		attach_log_only_once = false
	end
	local tp=e:GetHandlerPlayer()
	Duel.Overlay(c,ar)
	if c and (ar or #ar) and e then
		Duel.RaiseEvent(c,EVENT_ATTACH_ARMOR,e,0,tp,tp,c:GetFieldID())
	end
end
function Card.AttachArmor(c,ar,e)
	Armor.Attach(c,ar,e)
end
--add procedure to armor cards
function Armor.AddProcedure(c,s,opp,attach_when_des)
	-- c => the card
	-- s => the card script, obtained with "local s,id=GetID()" (for now, if not set, gives a warning and doesn't activate the update atk/def effects)
	-- opp (optional) => if true it can attach itself to opponent's monsters with the default procedure
	-- attach_when_des (optional) => if true activates the effect to attach the monster as armor when it's destroyed (used in Extra Deck Armor monsters)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(1183)
	e1:SetCategory(CATEGORY_ATTACH_ARMOR)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetTarget(Armor.Target(opp))
	e1:SetOperation(Armor.Operation)
	c:RegisterEffect(e1)
	if s then
		local a1=Effect.CreateEffect(c)
		a1:SetType(EFFECT_TYPE_XMATERIAL)
		a1:SetCode(EFFECT_UPDATE_ATTACK)
		a1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		a1:SetCondition(Armor.Condition)
		a1:SetValue(s.ArmorAtk)
		c:RegisterEffect(a1)
		local a2=a1:Clone()
		a2:SetCode(EFFECT_UPDATE_DEFENSE)
		a2:SetValue(s.ArmorDef)
		c:RegisterEffect(a2)
	else
		if armor_log_only_once then
			Debug.Message("proc_armor.lua has been updated!\nNow you have to use Armor.AddProcedure(c,s) instead of Armor.AddProcedure(c) and the ATK/DEF boost armor effects are added directly by the AddProcedure, you don't have to put them into the card effect anymore otherwise they get duplicated.")
			armor_log_only_once = false
		end
	end
	if attach_when_des then
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(1187)
		e2:SetCategory(CATEGORY_ATTACH_ARMOR)
		e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
		e2:SetCode(EVENT_DESTROYED)
		e2:SetProperty(EFFECT_FLAG_DELAY)
		e2:SetTarget(Armor.AttWDesCondition)
		e2:SetTarget(Armor.AttWDesTarget)
		e2:SetOperation(Armor.AttWDesOperation)
		c:RegisterEffect(e2)
	end
end
function Armor.Filter(c,e,tp)
	return not c:IsType(TYPE_XYZ) and c:IsFaceup()
		and (e:GetHandler().AttachFilter == nil or e:GetHandler().AttachFilter(c))
end
function Armor.Target(opp)
	return function(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
		local oppzone = opp and LOCATION_MZONE or 0
		if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() and (opp or chkc:IsController(tp)) and Armor.Filter(chkc,e,tp) end
		if chk==0 then return Duel.IsExistingTarget(Armor.Filter,tp,LOCATION_MZONE,oppzone,1,nil,e,tp) end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ARMORTARGET)
		local g=Duel.SelectTarget(tp,Armor.Filter,tp,LOCATION_MZONE,oppzone,1,1,nil,e,tp)
		Duel.SetOperationInfo(0,CATEGORY_ATTACH_ARMOR,g,1,0,0)
	end
end
function Armor.Operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		if c:IsType(TYPE_SPELL+TYPE_TRAP) then c:CancelToGrave() end
		Armor.Attach(tc,Group.FromCards(c),e)
	end
end
function Armor.Condition(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsType(TYPE_XYZ)
end
-- Attach itself to a monster as armor when destroyed (used in Extra Deck Armor monsters)
function Armor.AttWDesCondition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup()
end
function Armor.AttWDesFilter(c,ar)
	return Armor.AttachCheck(ar,c)
end
function Armor.AttWDesTarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Armor.AttWDesFilter,tp,LOCATION_MZONE,0,1,nil,e:GetHandler()) end
	Duel.SetOperationInfo(0,CATEGORY_ATTACH_ARMOR,e:GetHandler(),1,0,0)
end
function Armor.AttWDesOperation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ARMORTARGET)
		local tc=Duel.SelectMatchingCard(tp,Armor.AttWDesFilter,tp,LOCATION_MZONE,0,1,1,nil,c):GetFirst()
		if tc then
			Armor.Attach(tc,c,e)
		end
	end
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

--Exarmorizing Summon
--Parameters:
-- c: card
-- ct: number of monster materials X
-- f1: optional, filter for monster material
-- min: min number of armors for each material
-- f2: optional, filter for armor materials
if not aux.ExarmorizingProcedure then
	aux.ExarmorizingProcedure = {}
	Exarmorizing = aux.ExarmorizingProcedure
end
if not Exarmorizing then
	Exarmorizing = aux.ExarmorizingProcedure
end
function Exarmorizing.AddProcedure(c,ct,f1,min,f2)
	if c.armorizing_type==nil then
		local mt=c:GetMetatable()
		mt.armorizing_type=1
		mt.armorizing_parameters={c,ct,f1,min,f2}
	end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetDescription(1185)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(Exarmorizing.Condition(ct,f1,min,f2))
	e1:SetTarget(Exarmorizing.Target(ct,f1,min,f2))
	e1:SetOperation(Exarmorizing.Operation)
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

function Exarmorizing.MatFilter(c,sc,tp,f1,min,f2)
	local g=Group.CreateGroup()
	g:AddCard(c)
	return c:IsFaceup() and not c:IsType(TYPE_XYZ)
		and c:GetOverlayCount()>=min
		and (not f2 or c:GetOverlayGroup():IsExists(f2,min,nil,e,tp))
		and (not f1 or f1(c,sc,SUMMON_TYPE_SPECIAL,tp))
        and Duel.GetLocationCountFromEx(tp,tp,g,sc)>0
end
function Exarmorizing.Condition(ct,f1,min,f2)
	return	function(e,c)
				if c==nil then return true end
				if c:IsType(TYPE_PENDULUM) and c:IsFaceup() then return false end
				local tp=c:GetControler()
				
				return Duel.IsExistingMatchingCard(Exarmorizing.MatFilter,tp,LOCATION_MZONE,0,ct,nil,c,tp,f1,mina,f2)
				--local g=Duel.GetMatchingGroup(Exarmorizing.MatFilter,tp,LOCATION_MZONE,0,nil,c,tp,f1,mina,f2)
				--return aux.SelectUnselectGroup(g,e,tp,1,1,nil,0,c)
            end
end
function Exarmorizing.Target(ct,f1,min,f2)
	return	function(e,tp,eg,ep,ev,re,r,rp,chk)
                local c=e:GetHandler()
				local tp=e:GetHandlerPlayer()
                
                Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_AMATERIAL)
				local rg=Duel.GetMatchingGroup(Exarmorizing.MatFilter,tp,LOCATION_MZONE,0,nil,c,tp,f1,mina,f2)
				local mg=aux.SelectUnselectGroup(rg,e,tp,ct,ct,nil,1,tp,HINTMSG_SELECT,nil,nil,true,c)
                
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
function Exarmorizing.Operation(e,tp,eg,ep,ev,re,r,rp,c,smat,mg)
	local g=e:GetLabelObject()
	c:SetMaterial(g)
	Duel.SendtoGrave(g,REASON_MATERIAL+REASON_ARMORIZING)
	g:DeleteGroup()
end