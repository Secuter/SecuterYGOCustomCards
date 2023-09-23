REASON_ECHO			= 0x40000000
SUMMON_TYPE_ECHO	= 0x40
HINTMSG_EMATERIAL	= 602
EFFECT_ECHO_EQUIPPED= 12349900
ECHO_IMPORTED		= true

--[[
 - Add at the start of the script to add Echo procedure
 - Condition if Echo summoned
    return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_TYPE_ECHO
 - Example for the 'op' to pass in input to gain atk equal to the equipped monster
function s.eop(c,e,tp,tc)
	if tc:GetTextAttack()>0 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_EQUIP)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_OWNER_RELATE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(tc:GetTextAttack())
		tc:RegisterEffect(e1)
	end
end
]]

if not aux.EchoProcedure then
	aux.EchoProcedure = {}
	Echo = aux.EchoProcedure
end
if not Echo then
	Echo = aux.EchoProcedure
end

-- utility functions
function Card.IsEcho(c)
	return c.Echo
end

--Echo Summon
--Parameters:
-- c: card
-- f: filter material
-- op: effect applied while the Echo material is equipped
function Echo.AddProcedure(c,f,op)
	if c.echo_type==nil then
		local mt=c:GetMetatable()
		mt.echo_type=1
		mt.echo_parameters={c,f,op}
	end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetDescription(1186)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(Echo.Condition(f))
	e1:SetTarget(Echo.Target(f))
	e1:SetOperation(Echo.Operation(op))
	e1:SetValue(SUMMON_TYPE_ECHO)
	c:RegisterEffect(e1)
end

function Card.HasEquip(c,ec)
	local g=c:GetEquipGroup()
	local tc=g:GetFirst()
	while tc do
		if tc and tc==ec then return true end
		tc=g:GetNext()
	end
	return false
end
function Echo.MatFilter(c,sc,tp,ft,f)
	local g=Group.CreateGroup()
	g:AddCard(c)
	return c:IsFaceup() and not c:IsForbidden()
		and (not f or f(c,sc,SUMMON_TYPE_SPECIAL,tp))
		and (ft>0 or (c:IsControler(tp) and c:GetSequence()<5))
end
function Echo.Condition(f)
	return	function(e,c)
				if c==nil then return true end
				local tp=c:GetControler()
				if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return false end
				local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
				
				return ft>-1 and Duel.IsExistingMatchingCard(Echo.MatFilter,tp,LOCATION_MZONE,0,1,nil,c,tp,ft,f)
            end
end
function Echo.Target(f)
	return	function(e,tp,eg,ep,ev,re,r,rp,chk)
                local c=e:GetHandler()
				local tp=e:GetHandlerPlayer()
				if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return false end
				local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
				if ft<=-1 then return false end
				
                Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EMATERIAL)
				local rg=Duel.GetMatchingGroup(Echo.MatFilter,tp,LOCATION_MZONE,0,nil,c,tp,ft,f)
				local sg=aux.SelectUnselectGroup(rg,e,tp,1,1,nil,1,tp,HINTMSG_EMATERIAL,nil,nil,true,c)
                
				if #sg>0 then
					sg:KeepAlive()
					e:SetLabelObject(sg)
					return true
				else
					return false
				end
            end
end
function Echo.Operation(op)
	return	function(e,tp,eg,ep,ev,re,r,rp,c,smat,mg)
				if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
				local g=e:GetLabelObject()
				c:SetMaterial(g)
				local tc=g:GetFirst()
				if tc:GetOverlayCount()>0 then
					Duel.SendtoGrave(tc:GetOverlayGroup(),REASON_RULE)
				end
				Duel.Overlay(c,tc) -- temporary overlay the card to free the monster zone
				--equip
				local e1=Effect.CreateEffect(c)
				e1:SetCategory(CATEGORY_EQUIP)
				e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetCode(EVENT_SPSUMMON_SUCCESS)
				e1:SetRange(LOCATION_MZONE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD&~RESET_TOFIELD)
				e1:SetCondition(Echo.EquipCon(e))
				e1:SetOperation(Echo.EquipOperation(tc,op))
				c:RegisterEffect(e1)
			end
end
function Echo.EquipCon(eff)
	return	function(e,tp,eg,ep,ev,re,r,rp)
				return re==eff and e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_TYPE_ECHO
			end
end
function Echo.EquipVal(ec,c,tp)
	if e:GetHandler():GetFlagEffect(EFFECT_ECHO_EQUIPPED)~=0 then return false end
	local mt=c:GetMetatable()
	local f=mt.echo_parameters[2]
	return ec:IsControler(tp) and (not f or f(ec,c,SUMMON_TYPE_SPECIAL,tp))
end
function Echo.EquipOperation(tc,op)
	return	function(e,tp,eg,ep,ev,re,r,rp)
				local c=e:GetHandler()
				c:RegisterFlagEffect(EFFECT_ECHO_EQUIPPED,RESET_EVENT,0,0)
				if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or c:IsFacedown() then return end
				Echo.EquipEquip(c,e,tp,tc,op)
			end
end
function Echo.EquipEquip(c,e,tp,tc,op)
	if not c:EquipByEffectAndLimitRegister(e,tp,tc,nil,true) then return false end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetValue(true)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e1)
	if op then op(c,e,tp,tc) end
	return true
end
-- Echo Summon by card effect
function Card.IsEchoSummonable(c,e,tp,mustg,mg)
	return c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SPECIAL,tp,true,false)
		and c:IsEcho() and c:EchoRule(e,tp,mustg,mg)
end
function Card.EchoRule(c,e,tp,mustg,mg)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return false end
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local mt=c:GetMetatable()
	local f=mt.echo_parameters[2]
    local rg=nil
	if mg then
		rg=mg:Filter(Card.IsLocation,nil,LOCATION_MZONE):Filter(Echo.MatFilter,nil,c,tp,ft,f)
	else
		rg=Duel.GetMatchingGroup(Echo.MatFilter,tp,LOCATION_MZONE,0,nil,c,tp,ft,f)
	end
    return #rg>0 and (not mustg or Echo.FilterMustBeMat(rg,mustg))
end
function Echo.FilterMustBeMat(mg,mustg)
	local tc=mustg:GetFirst()
	while tc do
		if not mg:IsContains(tc) then return false end
		tc=mustg:GetNext()
	end
	return true
end
function Duel.EchoSummon(tp,c,mustg,mg)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=-1 then return end
	local mt=c:GetMetatable()
	local f=mt.echo_parameters[2]
	local op=mt.echo_parameters[3]
    local rg=nil
	if mg then
		rg=mg:Filter(Card.IsLocation,nil,LOCATION_MZONE):Filter(Echo.MatFilter,nil,c,tp,ft,f)
	else
		rg=Duel.GetMatchingGroup(Echo.MatFilter,tp,LOCATION_MZONE,0,nil,c,tp,ft,f)
	end
	if mustg then rg=mustg:Filter(Echo.MatFilter,nil,c,tp,ft,f) end	
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EMATERIAL)
	local sg=nil
	if #rg==1 then
		sg=rg
	else
		sg=aux.SelectUnselectGroup(rg,e,tp,1,1,nil,1,tp,HINTMSG_EMATERIAL,nil,nil,true,c)
	end
	
	if #sg>0 then
		c:SetMaterial(sg)
		local tc=sg:GetFirst()
		if tc:GetOverlayCount()>0 then
			Duel.SendtoGrave(tc:GetOverlayGroup(),REASON_RULE)
		end
		Duel.Overlay(c,tc) -- temporary overlay the card to free the monster zone
		--equip
		local e1=Effect.CreateEffect(c)
		e1:SetCategory(CATEGORY_EQUIP)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EVENT_SPSUMMON_SUCCESS)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCondition(Echo.EquipCon)
		e1:SetOperation(Echo.EquipOperation(tc,op))
		c:RegisterEffect(e1)
		Duel.SpecialSummon(c,SUMMON_TYPE_ECHO,tp,tp,true,false,POS_FACEUP)
		c:CompleteProcedure()
	end
end