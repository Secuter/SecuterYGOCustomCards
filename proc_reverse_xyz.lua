REVERSE_XYZ_IMPORTED=true
if not aux.ReverseXyzProcedure then
	aux.ReverseXyzProcedure = {}
	ReverseXyz = aux.ReverseXyzProcedure
end
if not ReverseXyz then
	ReverseXyz = aux.ReverseXyzProcedure
end
--[[
add at the start of the script to add Ingition procedure
if not REVERSE_XYZ_IMPORTED then Duel.LoadScript("proc_reverse_xyz.lua") end
]]
--ReverseXyz Summon
--Parameters:
-- c: card
-- lv: level of the first material (the second is two times the level)
-- f1: optional, filter for the first material
-- f2: optional, filter for the second material
-- alterf: optional, filter for the alternative summon method (using 1 monster as material)
-- alterop: optional, operation for the alternative summon method
-- desc: optional, description for the alternative summon method
function ReverseXyz.AddProcedure(c,lv,f1,f2,alterf,alterop,desc)
	if c.rxyz_filter==nil then
		local mt=c:GetMetatable()
		mt.rxyz_type=1
		mt.rxyz_filter=function(mc,ignoretoken) return mc and (not f or f(mc)) and (mc:IsXyzLevel(c,lv) or mc:IsXyzLevel(c,lv*2)) and (not mc:IsType(TYPE_TOKEN) or ignoretoken) end
		mt.rxyz_parameters={mt.rxyz_filter,c,lv,f1,f2,alterf,alterop,desc}
	end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetDescription(1180)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(ReverseXyz.Condition(lv,f1,f2))
	e1:SetTarget(ReverseXyz.Target(lv,f1,f2))
	e1:SetOperation(ReverseXyz.Operation)
	e1:SetValue(SUMMON_TYPE_XYZ)
	c:RegisterEffect(e1)
	if alterf then
		local e2=e1:Clone()
		e2:SetDescription(desc)
		e2:SetCondition(ReverseXyz.Condition2(alterf,alterop))
		e2:SetTarget(ReverseXyz.Target2(alterf,alterop))
		e2:SetOperation(ReverseXyz.Operation2(alterf,alterop))
		c:RegisterEffect(e2)
	end
end
function ReverseXyz.FilterEx(c,f,sc,tp,lv,mg)
    local g
	if mg then
		g=mg
	else
		g=Group.CreateGroup()
	end
    g:AddCard(c)
	return (not lv or c:IsXyzLevel(sc,lv)) and (not f or f(c,sc,SUMMON_TYPE_XYZ,tp))
        and Duel.GetLocationCountFromEx(tp,tp,g,sc)>0
end
function ReverseXyz.Filter(c,f1,sc,tp,lv)
	return c:IsFaceup() and not c:IsType(TYPE_TOKEN) and (not lv or c:IsXyzLevel(sc,lv))
        and (not f1 or f1(c,sc,SUMMON_TYPE_XYZ,tp)) 
end
function ReverseXyz.Check(tp,sg,sc,lv,f1,f2)
	if lv then
		return sg:IsExists(ReverseXyz.FilterEx,1,nil,f1,sc,tp,lv,sg)
			and sg:IsExists(ReverseXyz.FilterEx,1,nil,f2,sc,tp,lv*2,sg)
	else
		return sg:IsExists(ReverseXyz.FilterEx,2,nil,f1,sc,tp,lv,sg)
	end
end
function ReverseXyz.Condition(lv,f1,f2)
	return	function(e,c,must,og,min,max)
				if c==nil then return true end
				if c:IsType(TYPE_PENDULUM) and c:IsFaceup() then return false end
				local tp=c:GetControler()
                
				if lv then
					local mg1=Duel.GetMatchingGroup(ReverseXyz.Filter,tp,LOCATION_MZONE,0,nil,f1,c,tp,lv)
					local mg2=Duel.GetMatchingGroup(ReverseXyz.Filter,tp,LOCATION_MZONE,0,nil,f2,c,tp,lv*2)					
					if #mg1<1 or #mg2<1 then return false end
					local mustg=Auxiliary.GetMustBeMaterialGroup(tp,g,tp,c,mg,REASON_XYZ)
					if must then mustg:Merge(must) end
					if not (mg1+mg2):Includes(mustg) then return false end
					
					return mg1:IsExists(ReverseXyz.FilterEx,1,nil,f1,c,tp,lv,mg2)
						and mg2:IsExists(ReverseXyz.FilterEx,1,nil,f2,c,tp,lv*2,mg1)
				else
					local mg1=Duel.GetMatchingGroup(ReverseXyz.Filter,tp,LOCATION_MZONE,0,nil,f1,c,tp,lv)
					if #mg1<2 then return false end
					local mustg=Auxiliary.GetMustBeMaterialGroup(tp,g,tp,c,mg,REASON_XYZ)
					if must then mustg:Merge(must) end
					if not mg1:Includes(mustg) then return false end
					
					return mg1:IsExists(ReverseXyz.FilterEx,2,nil,f1,c,tp,lv,nil)
				end
            end
end
function ReverseXyz.Target(lv,f1,f2)
	return function(e,tp,eg,ep,ev,re,r,rp,chk,c,must,mg1,mg2)
                if not mg1 then
                    mg1=Duel.GetMatchingGroup(ReverseXyz.Filter,tp,LOCATION_MZONE,0,nil,f1,c,tp,lv)
                end
				if lv then
					if not mg2 then
						mg2=Duel.GetMatchingGroup(ReverseXyz.Filter,tp,LOCATION_MZONE,0,nil,f2,c,tp,lv*2)
					end
				else
					if not mg2 then
						mg2=Group.CreateGroup()
					end
				end

				local mustg=Auxiliary.GetMustBeMaterialGroup(tp,mg1+mg2,tp,c,mg1+mg2,REASON_XYZ)
				if must then mustg:Merge(must) end
				local sg=Group.CreateGroup()
				local finish=false
				local cancel=false
				sg:Merge(mustg)
				while #sg<2 do                    
					local cg=Group.CreateGroup()
					if lv then
						if not sg:IsExists(ReverseXyz.FilterEx,1,nil,f1,c,tp,lv,mg2) then
							cg:Merge(mg1:Filter(ReverseXyz.FilterEx,nil,f1,c,tp,lv,mg2))
						end
						if not sg:IsExists(ReverseXyz.FilterEx,1,nil,f2,c,tp,lv*2,mg1) then
							cg:Merge(mg2:Filter(ReverseXyz.FilterEx,nil,f2,c,tp,lv*2,mg1))
						end
					else
						if not sg:IsExists(ReverseXyz.FilterEx,2,nil,f1,c,tp,lv,mg2) then
							cg:Merge(mg1:Filter(ReverseXyz.FilterEx,nil,f1,c,tp,lv,mg2))
						end
					end
					cg:Remove(function(c,g) return g:IsContains(c) end,nil,sg)
					if #cg==0 then break end
					finish=#sg==max and ReverseXyz.Check(tp,sg,c,lv,f1,f2)
					cancel=Duel.GetCurrentChain()<=0 and #sg==0
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
					local tc=Group.SelectUnselect(cg,sg,tp,finish,cancel,1,1)
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
function ReverseXyz.Operation(e,tp,eg,ep,ev,re,r,rp,c,smat,mg)				
    local c=e:GetHandler()
	local g=e:GetLabelObject()
	local sg=Group.CreateGroup()
	for tc in aux.Next(g) do
		sg:Merge(tc:GetOverlayGroup())
	end
	Duel.SendtoGrave(sg,REASON_RULE)
	c:SetMaterial(g)
    Duel.Overlay(c,g)
	g:DeleteGroup()
end
--Reverse-Xyz Summon Alternative
function ReverseXyz.AlterFilter(c,alterf,xyzc,e,tp,alterop)
	if not alterf(c,tp,xyzc) or not c:IsCanBeXyzMaterial(xyzc,tp) or (c:IsControler(1-tp) and not c:IsHasEffect(EFFECT_XYZ_MATERIAL)) 
		or (alterop and not alterop(e,tp,0,c)) then return false end
	if xyzc:IsLocation(LOCATION_EXTRA) then
		return Duel.GetLocationCountFromEx(tp,tp,c,xyzc)>0
	else
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 or c:GetSequence()<5
	end
end
function ReverseXyz.Condition2(alterf,alterop)
	return	function(e,c,must,og,min,max)
				if c==nil then return true end
				if c:IsType(TYPE_PENDULUM) and c:IsFaceup() then return false end
				local tp=c:GetControler()
				local mg=nil
				if og then
					mg=og
				else
					mg=Duel.GetFieldGroup(tp,LOCATION_MZONE,LOCATION_MZONE)
				end
				local mustg=Auxiliary.GetMustBeMaterialGroup(tp,og,tp,c,mg,REASON_XYZ)
				if must then mustg:Merge(must) end
				if #mustg>1 or (min and min>1) or not mg:Includes(mustg) then return false end
				local mustc=mustg:GetFirst()
				if mustc then
					return ReverseXyz.AlterFilter(mustc,alterf,c,e,tp,alterop)
				else
					return mg:IsExists(ReverseXyz.AlterFilter,1,nil,alterf,c,e,tp,alterop)
				end
			end
end
function ReverseXyz.Target2(alterf,alterop)
	return	function(e,tp,eg,ep,ev,re,r,rp,chk,c,must,og,min,max)
				local cancel=not og and Duel.IsSummonCancelable()
				if og and not min then
					e:SetLabelObject(og:GetFirst())
					if alterop then alterop(e,tp,1,og:GetFirst()) end
					return true
				else
					local mg=nil
					if og then
						mg=og
					else
						mg=Duel.GetFieldGroup(tp,LOCATION_MZONE,LOCATION_MZONE)
					end
					local mustg=Auxiliary.GetMustBeMaterialGroup(tp,og,tp,c,mg,REASON_XYZ)
					if must then mustg:Merge(must) end
					local oc
					if #mustg>0 then
						oc=mustg:GetFirst()
					else
						Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
						oc=mg:Filter(ReverseXyz.AlterFilter,nil,alterf,c,e,tp,alterop):SelectUnselect(Group.CreateGroup(),tp,false,cancel)
					end
					if not oc then return false end
					local res=true
					if alterop then ok=alterop(e,tp,1,oc) end
					if not res then return false end
					e:SetLabelObject(oc)
					return true
				end
			end
end	
function ReverseXyz.Operation2(alterf,alterop)
	return	function(e,tp,eg,ep,ev,re,r,rp,c,must,og,min,max)
				local oc=e:GetLabelObject()
				local mg=oc:GetOverlayGroup()
				if #mg~=0 then
					Duel.Overlay(c,mg)
				end
				c:SetMaterial(Group.FromCards(oc))
				Duel.Overlay(c,oc)
			end
end