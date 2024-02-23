IGNITION_IMPORTED    = true

--[[
add at the start of the script to add Ignition procedure
condition if Ignition summoned
    return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_TYPE_IGNITION
]]

if not aux.IgnitionProcedure then
	aux.IgnitionProcedure = {}
	Ignition = aux.IgnitionProcedure
end
if not Ignition then
	Ignition = aux.IgnitionProcedure
end

-- utility functions
function Card.IsIgnition(c)
	return c.Ignition
end

--Ignition Summon
function Ignition.AddProcedure(c,f1,f2,min,max)
	if c.ignition_type==nil then
		local mt=c:GetMetatable()
		mt.ignition_type=1
		mt.ignition_parameters={c,f1,f2,min,max}
	end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetDescription(1182)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(Ignition.Condition(f1,f2,min,max))
	e1:SetTarget(Ignition.Target(f1,f2,min,max))
	e1:SetOperation(Ignition.Operation)
    e1:SetValue(SUMMON_TYPE_IGNITION)
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
function Ignition.FilterEx(c,f,sc,tp,mg,loc)
    local g=mg
    g:AddCard(c)
	return (not f or f(c,sc,SUMMON_TYPE_SPECIAL,tp))
        and (not loc or c:IsLocation(loc))
        and Duel.GetLocationCountFromEx(tp,tp,g,sc)>0
end
function Ignition.Filter(c,f,sc,tp)
	return (not f or f(c,sc,SUMMON_TYPE_SPECIAL,tp)) 
end
function Ignition.Check(tp,sg,sc,f1,f2,min)
	return sg:IsExists(Ignition.FilterEx,1,nil,f1,sc,tp,sg,LOCATION_MZONE)
		and sg:IsExists(Ignition.FilterEx,min,nil,f2,sc,tp,sg,LOCATION_HAND)
end
function Ignition.Remove(c,g)
	return g:IsContains(c)
end
function Ignition.Condition(f1,f2,min,max)
	return	function(e,c)
				if c==nil then return true end
				if c:IsType(TYPE_PENDULUM) and c:IsFaceup() then return false end
				local tp=c:GetControler()
                
                if not Duel.IsExistingMatchingCard(aux.FaceupFilter(Ignition.Filter),tp,LOCATION_MZONE,0,1,nil,f1,c,tp)
                    or not Duel.IsExistingMatchingCard(Ignition.Filter,tp,LOCATION_HAND,0,min,nil,f2,c,tp) then return false end
                
                local mg1=Duel.GetMatchingGroup(aux.FaceupFilter(Ignition.Filter),tp,LOCATION_MZONE,0,nil,f1,c,tp)
                local mg2=Duel.GetMatchingGroup(Ignition.Filter,tp,LOCATION_HAND,0,nil,f2,c,tp)
                
                if #mg1<=0 or #mg2<=0 then return false end
                return mg1:IsExists(Ignition.FilterEx,1,nil,f1,c,tp,mg2)
                    and mg2:IsExists(Ignition.FilterEx,min,nil,f2,c,tp,mg1)
            end
end
function Ignition.Target(f1,f2,min,max)
	return function(e,tp,eg,ep,ev,re,r,rp,chk,c,must,mg1,mg2)
                if not mg1 then
                    mg1=Duel.GetMatchingGroup(aux.FaceupFilter(Ignition.Filter),tp,LOCATION_MZONE,0,nil,f1,c,tp)
                end
                if not mg2 then
                    mg2=Duel.GetMatchingGroup(Ignition.Filter,tp,LOCATION_HAND,0,nil,f2,c,tp)
                end
				local mustg=Auxiliary.GetMustBeMaterialGroup(tp,mg1+mg2,tp,c,mg1+mg2,REASON_IGNITION)
				if must then mustg:Merge(must) end                
				local sg=Group.CreateGroup()
				local finish=false
				local cancel=false
				sg:Merge(mustg)
				while #sg<(max+1) do
					local cg=Group.CreateGroup()
                    if not sg:IsExists(Ignition.FilterEx,1,nil,f1,c,tp,mg2,LOCATION_MZONE) then
                        cg:Merge(mg1:Filter(Ignition.FilterEx,nil,f1,c,tp,mg2,LOCATION_MZONE))
					end
                    if not sg:IsExists(Ignition.FilterEx,max,nil,f2,c,tp,mg1,LOCATION_HAND) then
                        cg:Merge(mg2:Filter(Ignition.FilterEx,nil,f2,c,tp,mg1,LOCATION_HAND))
                    end
					cg:Remove(Ignition.Remove,nil,sg)
					if #cg==0 then break end
					finish=#sg>=(min+1) and Ignition.Check(tp,sg,c,f1,f2,min)
					cancel=Duel.GetCurrentChain()<=0 and #sg==0
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_IMATERIAL)
					local tc=Group.SelectUnselect(cg,sg,tp,finish,cancel,min+1,max+1)
					if not tc then break end
					if not sg:IsContains(tc) then
						sg:AddCard(tc)
					else
						sg:RemoveCard(tc)
					end
				end
				
				if #sg>0 then
					sg:KeepAlive()
					e:SetLabelObject(sg)
					return true
				else
					return false
				end
            end
end
function Ignition.Operation(e,tp,eg,ep,ev,re,r,rp,c,smat,mg)
	local g=e:GetLabelObject()
	c:SetMaterial(g)
	Duel.SendtoGrave(g,REASON_MATERIAL+REASON_IGNITION)
	g:DeleteGroup()
end
-- Ignition Summon by card effect
function Card.IsIgnitionSummonable(c,e,tp,must_use,mg)
	return c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SPECIAL,tp,false,false)
		and c:IsIgnition() and c:IgnitionRule(e,tp,must_use,mg)
end
function Card.IgnitionRule(c,e,tp,mustg,mg)
	local mt=c:GetMetatable()
	local f1=mt.ignition_parameters[2]
	local f2=mt.ignition_parameters[3]
	local min=mt.ignition_parameters[4]
    local mg1=nil
    local mg2=nil
	if mg then
		mg1=mg:Filter(aux.FaceupFilter(Card.IsLocation,LOCATION_MZONE),nil):Filter(Ignition.Filter,nil,f1,c,tp)
		mg2=mg:Filter(Card.IsLocation,nil,LOCATION_HAND):Filter(Ignition.Filter,nil,f2,c,tp)
	else
		mg1=Duel.GetMatchingGroup(aux.FaceupFilter(Ignition.Filter),tp,LOCATION_MZONE,0,nil,f1,c,tp)
		mg2=Duel.GetMatchingGroup(Ignition.Filter,tp,LOCATION_HAND,0,nil,f2,c,tp)
	end
    if #mg1<=0 or #mg2<=0 then return false end
	if mustg and not Ignition.FilterMustBeMat(mg1,mg2,mustg) then return false end
    return mg1:IsExists(Ignition.FilterEx,1,nil,f1,c,tp,mg2)
        and mg2:IsExists(Ignition.FilterEx,min,nil,f2,c,tp,mg1)
end
function Ignition.FilterMustBeMat(mg1,mg2,mustg)
	local tc=mustg:GetFirst()
	while tc do
		if not mg1:IsContains(tc) and not mg2:IsContains(tc) then return false end
		tc=mustg:GetNext()
	end
	return true
end
function Duel.IgnitionSummon(tp,c,mustg,mg)
	local mt=c:GetMetatable()
	local f1=mt.ignition_parameters[2]
	local f2=mt.ignition_parameters[3]
	local min=mt.ignition_parameters[4]
	local max=mt.ignition_parameters[5]
    local mg1=nil
    local mg2=nil
	if mg then
		mg1=mg:Filter(aux.FaceupFilter(Card.IsLocation,LOCATION_MZONE),nil):Filter(Ignition.Filter,nil,f1,c,tp)
		mg2=mg:Filter(Card.IsLocation,nil,LOCATION_HAND):Filter(Ignition.Filter,nil,f2,c,tp)
	else
		mg1=Duel.GetMatchingGroup(aux.FaceupFilter(Ignition.Filter),tp,LOCATION_MZONE,0,nil,f1,c,tp)
		mg2=Duel.GetMatchingGroup(Ignition.Filter,tp,LOCATION_HAND,0,nil,f2,c,tp)
	end
	
	local sg=Group.CreateGroup()
	local finish=false
	local cancel=false
	if mustg then sg:Merge(mustg) end
	while #sg<(max+1) do
		local cg=Group.CreateGroup()
        if not sg:IsExists(Ignition.FilterEx,1,nil,f1,c,tp,mg2,LOCATION_MZONE) then
        cg=mg1:Filter(Ignition.FilterEx,nil,f1,c,tp,mg2,LOCATION_MZONE)
        elseif not sg:IsExists(Ignition.FilterEx,max,nil,f2,c,tp,mg1,LOCATION_HAND) then
            cg=mg2:Filter(Ignition.FilterEx,nil,f2,c,tp,mg1,LOCATION_HAND)
        end
		cg:Remove(Ignition.Remove,nil,sg)
		if #cg==0 then break end
		finish=#sg>=(min+1) and Ignition.Check(tp,sg,c,f1,f2,min)
		cancel=Duel.GetCurrentChain()<=0 and #sg==0
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_IMATERIAL)
		local tc=Group.SelectUnselect(cg,sg,tp,finish,cancel,min+1,max+1)
		if not tc then break end
		if not sg:IsContains(tc) then
			sg:AddCard(tc)
		else
			sg:RemoveCard(tc)
		end
	end
	
	if #sg>0 then
		c:SetMaterial(sg)
		Duel.SendtoGrave(sg,REASON_MATERIAL+REASON_IGNITION)
		Duel.SpecialSummon(c,SUMMON_TYPE_IGNITION,tp,tp,false,false,POS_FACEUP)
		c:CompleteProcedure()
	end
end