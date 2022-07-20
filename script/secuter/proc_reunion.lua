EFFECT_HAND_REUNION	= 601
REASON_REUNION		= 0x20000000
SUMMON_TYPE_REUNION	= 0x10
HINTMSG_RMATERIAL	= 600
REUNION_MAT_TOGRAVE	= 1
REUNION_MAT_REMOVE	= 2
REUNION_MAT_REMOVE_FACEDOWN	= 3
REUNION_MAT_TOHAND	= 4
REUNION_MAT_TODECK	= 5
REUNION_MAT_DESTROY	= 6
REUNION_TYPE_NONE		= 0x0
REUNION_TYPE_CHECK		= 0x1
REUNION_TYPE_INCLUDE	= 0x2
REUNION_TYPE_MAXSEND	= 0x4
REUNION_TYPE_LOCATION	= 0X8
REUNION_TYPES_MAIN		= REUNION_TYPE_CHECK+REUNION_TYPE_INCLUDE+REUNION_TYPE_MAXSEND
REUNION_IMPORTED	= true
if not aux.ReunionProcedure then
	aux.ReunionProcedure = {}
	Reunion = aux.ReunionProcedure
end
if not Reunion then
	Reunion = aux.ReunionProcedure
end
DEBUG=false
COUNT_R1=0
COUNT_R2=0
--[[
add at the start of the script to add Reunion procedure
if not REUNION_IMPORTED then Duel.LoadScript("proc_reunion.lua") end
condition if Reunion summoned
    return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_TYPE_REUNION
]]
--Reunion Summon
--Parameters:
-- c: card
-- f: optional, material filter
-- min: min materials
-- max: optional, max materials (Default = 99)
-- specialchk: optional, additional check for materials (for checks on the group of materials, for example if they must all be different or if there must be at least one that respects a condition)
-- opp: optional, flag if you can use opponent monsters as material (Default = false)
-- loc: optional, material location (Default = LOCATION_MZONE, if setted replaces the default)
-- send: optional, where the materials are sent
-- REUNION_MAT_REMOVE			or 1 >> sent to grave (Default)
-- REUNION_MAT_REMOVE			or 2 >> removed face-up
-- REUNION_MAT_REMOVE_FACEDOWN	or 3 >> removed face-down
-- REUNION_MAT_TOHAND			or 4 >> returned to the hand
-- REUNION_MAT_TODECK			or 5 >> shuffled into the deck
-- REUNION_MAT_DESTROY			or 6 >> destroyed
-- locsend: optional, if set limits the application of the 'send' paramter only to these location, those not included use the default send (sent to the grave).
--			Eg: if loc = LOCATION_MZONE+LOCATION_HAND+LOCATION_GRAVE, send=REUNION_MAT_REMOVE, locsend=LOCATION_GRAVE => only materials in the grave are banished, those on the field or in the hand are sent to the grave
-- maxsend: optional, flag if you can use only 1 material from locations different from the MZONE
-- inclf: optional, filter for material required at least at 1, faster than using specialchk
function Reunion.AddProcedure(c,f,min,max,specialchk,opp,loc,send,locsend,maxsend,inclf)
	local r_type=REUNION_TYPE_NONE
	if specialchk then r_type=r_type | REUNION_TYPE_CHECK end
	if inclf then r_type=r_type | REUNION_TYPE_INCLUDE end
	if locsend and maxsend then r_type=r_type | REUNION_TYPE_MAXSEND end
	if locsend then r_type=r_type | REUNION_TYPE_LOCATION end
	if r_type&(REUNION_TYPE_CHECK|REUNION_TYPE_LOCATION)==REUNION_TYPE_CHECK|REUNION_TYPE_LOCATION then
		Debug.Message("Warning! c"..c:GetCode().." is using Reunion Procedure with specialchk and Extra Locations! It may cause lagging!")
	end
	if r_type&(REUNION_TYPE_CHECK|REUNION_TYPE_INCLUDE)==REUNION_TYPE_CHECK|REUNION_TYPE_INCLUDE or r_type&(REUNION_TYPE_CHECK|REUNION_TYPE_MAXSEND)==REUNION_TYPE_CHECK|REUNION_TYPE_MAXSEND then
		Debug.Message("Warning! c"..c:GetCode().." is using Reunion Procedure with specialchk and include_filter/max_send is Not supported! Specialchk will override include_filter/max_send!")
	end
	if max==nil then max=99 end
	if loc==nil then loc=LOCATION_MZONE end
	if c.reunion_type==nil then
		local mt=c:GetMetatable()
		mt.reunion_type=1
		mt.reunion_parameters={c,f,min,max,specialchk,opp,loc,send,locsend,maxsend,inclf,r_type}
	end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetDescription(1181)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(Reunion.Condition(f,min,max,specialchk,opp,loc,send,locsend,maxsend,inclf,r_type))
	e1:SetTarget(Reunion.Target(f,min,max,specialchk,opp,loc,send,locsend,maxsend,inclf,r_type))
	e1:SetOperation(Reunion.Operation(f,min,max,specialchk,opp,loc,send,locsend,maxsend,inclf,r_type))
    e1:SetValue(SUMMON_TYPE_REUNION)
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
function Reunion.ConditionFilter(c,f,sc,tp,send,locsend)
	return Reunion.GetReunionCount(c)>0 and (not f or f(c,sc,SUMMON_TYPE_SPECIAL,tp)) and Reunion.SendFilter(c,send,locsend)
end
function Reunion.GetReunionCount(c)
    if c:GetLevel()>0 then return c:GetLevel()
    elseif c:GetRank()>0 then return c:GetRank()
    elseif c:GetLink()>0 then return c:GetLink() end
    return 0
end
function Card.GetReunionCount(c)
	return Reunion.GetReunionCount(c)
end
function Reunion.GetReunionSum(g)
	if not g then return 0 end
	local c=g:GetFirst()
	local sum=0
	while c do
		sum=sum+Reunion.GetReunionCount(c)
		c=g:GetNext()
	end
	return sum
end
function Group.GetReunionSum(g)
	return Reunion.GetReunionSum(g)
end
function Reunion.Remove(c,g)
	return g:IsContains(c)
end
function Reunion.SendFilter(c,send,locsend)
	if send and (not locsend or c:IsLocation(locsend)) and (send==REUNION_MAT_REMOVE or send==REUNION_MAT_REMOVE_FACEDOWN) then
		return c:IsAbleToRemoveAsCost() and (c:IsLocation(LOCATION_SZONE) or aux.SpElimFilter(c,false,true))
	end
	return true
end
function Reunion.CheckRecursive(c,tp,sg,mg,sc,minc,maxc,f,specialchk,og,emt,filt)
	COUNT_R1=COUNT_R1+1
	if #sg>maxc then return false end
	filt=filt or {}
	sg:AddCard(c)
	for _,filt in ipairs(filt) do
		if not filt[2](c,filt[3],tp,sg,mg,sc,filt[1],1) then
			sg:RemoveCard(c)
			return false
		end
	end
	if not og:IsContains(c) then
		res=aux.CheckValidExtra(c,tp,sg,mg,sc,emt,filt)
		if not res then
			sg:RemoveCard(c)
			return false
		end
	end
	local res=Reunion.CheckGoal(tp,sg,sc,minc,f,specialchk,filt)
		or (#sg<maxc and mg:IsExists(Reunion.CheckRecursive,1,sg,tp,sg,mg,sc,minc,maxc,f,specialchk,og,emt,{table.unpack(filt)}))
	sg:RemoveCard(c)
	return res
end
function Reunion.CheckRecursive2(c,tp,sg,sg2,secondg,mg,sc,minc,maxc,f,specialchk,og,emt,filt)
	COUNT_R2=COUNT_R2+1
	if #sg>maxc then return false end
	sg:AddCard(c)
	for _,filt in ipairs(filt) do
		if not filt[2](c,filt[3],tp,sg,mg,sc,filt[1],1) then
			sg:RemoveCard(c)
			return false
		end
	end
	if not og:IsContains(c) then
		res=aux.CheckValidExtra(c,tp,sg,mg,sc,emt,filt)
		if not res then
			sg:RemoveCard(c)
			return false
		end
	end
	if #(sg2-sg)==0 then
		if secondg and #secondg>0 then
			local res=secondg:IsExists(Reunion.CheckRecursive,1,sg,tp,sg,mg,sc,minc,maxc,f,specialchk,og,emt,{table.unpack(filt)})
			sg:RemoveCard(c)
			return res
		else
			local res=Reunion.CheckGoal(tp,sg,sc,minc,f,specialchk,{table.unpack(filt)})
			sg:RemoveCard(c)
			return res
		end
	end
	local res=Reunion.CheckRecursive2((sg2-sg):GetFirst(),tp,sg,sg2,secondg,mg,sc,minc,maxc,f,specialchk,og,emt,filt)
	sg:RemoveCard(c)
	return res
end
function Reunion.CheckGoal(tp,sg,sc,minc,f,specialchk,filt)
	for _,filt in ipairs(filt) do
		if not sg:IsExists(filt[2],1,nil,filt[3],tp,sg,Group.CreateGroup(),sc,filt[1],1) then
			return false
		end
	end
	return #sg>=minc and sg:CheckWithSumEqual(Reunion.GetReunionCount,sc:GetReunionCount()*2,#sg,#sg)
		and (not specialchk or specialchk(sg,sc,SUMMON_TYPE_SPECIAL,tp)) and Duel.GetLocationCountFromEx(tp,tp,sg,sc)>0
end
function Reunion.CheckGoal2(tp,sg,sc,min,max,mustlvl,mustcount,inclf,locsend,maxsend)
	return #sg>=min and #sg<=max and (not inclf or sg:IsExists(inclf,1,nil,sc,SUMMON_TYPE_SPECIAL,tp))
		and (not locsend or not maxsend or not sg:IsExists(Card.IsLocation,2,nil,locsend))
		and sg:CheckWithSumEqual(Reunion.GetReunionCount,sc:GetReunionCount()*2-mustlvl,math.max(0,#sg-mustcount),#sg-mustcount)
		and Duel.GetLocationCountFromEx(tp,tp,sg,sc)>0
end
function Reunion.CheckTypeInclude(mg,tp,min,max,inclf,mustg,mustlvl,mustcount)
	local res=false
	if #mustg>0 and mustg:IsExists(inclf,1,nil,c,SUMMON_TYPE_SPECIAL,tp) then
		res=g2:CheckWithSumEqual(Reunion.GetReunionCount,c:GetReunionCount()*2-mustlvl,min-mustcount,max-mustcount)
	end
	if not res then
		local g1=mg:Filter(inclf,nil,c,SUMMON_TYPE_SPECIAL,tp)
		if #g1>0 then
			local tc=g1:GetFirst()
			while tc and not res do
				COUNT_R1=COUNT_R1+1
				local g2=mg:Clone()
				g2:RemoveCard(tc)
				res=g2:CheckWithSumEqual(Reunion.GetReunionCount,c:GetReunionCount()*2-mustlvl-tc:GetReunionCount(),min-mustcount-1,max-mustcount-1)
				tc=g1:GetNext()
			end
		end
	end
	return res
end
function Reunion.CheckTypeMaxSend(mg,tp,min,max,inclf,mustg,mustlvl,mustcount)
	local res=false
	local gs=mg:Filter(Card.IsLocation,nil,LOCATION_MZONE)
	local gn=mg:Filter(aux.NOT(Card.IsLocation),nil,LOCATION_MZONE)
	if #mustg>0 then
		if mustg:IsExists(aux.NOT(Card.IsLocation),1,nil,LOCATION_MZONE) then
			res=gs:CheckWithSumEqual(Reunion.GetReunionCount,c:GetReunionCount()*2-mustlvl,min-mustcount,max-mustcount)
		end
	end
	if #gs>0 then
		if not res then
			local tc=gn:GetFirst()
			while tc and not res do
				COUNT_R1=COUNT_R1+1
				local g2=gn:Clone()
				g2:RemoveCard(tc)
				res=gs:CheckWithSumEqual(Reunion.GetReunionCount,c:GetReunionCount()*2-mustlvl-tc:GetReunionCount(),min-mustcount-1,max-mustcount-1)
				tc=gn:GetNext()
			end
		end
	end
	return res
end
function Reunion.CheckTypeIncludeMaxSend(mg,tp,min,max,inclf,mustg,mustlvl,mustcount)
	local res=false
	local gs=mg:Filter(Card.IsLocation,nil,LOCATION_MZONE)
	local gn=mg:Filter(aux.NOT(Card.IsLocation),nil,LOCATION_MZONE)
	if mustg:IsExists(inclf,1,nil,c,SUMMON_TYPE_SPECIAL,tp) then
		res=gs:CheckWithSumEqual(Reunion.GetReunionCount,c:GetReunionCount()*2-mustlvl,min-mustcount,max-mustcount)
		if not res then
			local tc=gn:GetFirst()
			while tc and not res do
				COUNT_R1=COUNT_R1+1
				res=gs:CheckWithSumEqual(Reunion.GetReunionCount,c:GetReunionCount()*2-mustlvl-tc:GetReunionCount(),min-mustcount-1,max-mustcount-1)
				tc=gn:GetNext()
			end
		end
	end
	if #gs>0 then
		if not res then
			local g1=mg:Filter(inclf,nil,c,SUMMON_TYPE_SPECIAL,tp)
			if #g1>0 then
				local tc1=g1:GetFirst()
				while tc1 and not res do
					COUNT_R1=COUNT_R1+1
					local gs2=gs:Clone()
					local gn2=gn:Clone()
					gs2:RemoveCard(tc1)
					gn2:RemoveCard(tc1)
					res=gs2:CheckWithSumEqual(Reunion.GetReunionCount,c:GetReunionCount()*2-mustlvl-tc1:GetReunionCount(),min-mustcount-1,max-mustcount-1)
					if not res and tc1:IsLocation(LOCATION_MZONE) then
						local tc2=gn2:GetFirst()
						while tc2 and not res do
							COUNT_R1=COUNT_R1+1
							res=gs2:CheckWithSumEqual(Reunion.GetReunionCount,c:GetReunionCount()*2-mustlvl-tc1:GetReunionCount()-tc2:GetReunionCount(),min-mustcount-2,max-mustcount-2)
							tc2=gn2:GetNext()
						end
					end
					tc1=g1:GetNext()
				end
			end
		end
	end
	return res
end
function Reunion.CheckNotRecursive(c,mg,sg,tp,sc,f,min,max)
	local lvlsum=sg:GetReunionSum()+c:GetReunionCount()
	local tg=mg:Clone()
	tg=tg:RemoveCard(c)
	return tg:CheckWithSumEqual(Reunion.GetReunionCount,sc:GetReunionCount()*2-lvlsum,math.max(0,min-#sg-1),max-#sg-1)
end
function Reunion.CheckTypeInclude2(mg,sg,tp,sc,f,min,max,inclf)
	local lvlsum=sg:GetReunionSum()
	local count=#sg
	local rg=Group.CreateGroup()
	if sg:IsExists(inclf,1,nil,sc,SUMMON_TYPE_SPECIAL,tp) then
		local c=mg:GetFirst()
		while c do
			local str=(not locsend or c:IsLocation(locsend)) and "(g)" or ""
			local str2="["..lvlsum.."+"..c:GetReunionCount().."]"
			COUNT_R1=COUNT_R1+1
			local tg=mg:Clone()
			tg=tg:RemoveCard(c)
			if tg:CheckWithSumEqual(Reunion.GetReunionCount,sc:GetReunionCount()*2-lvlsum-c:GetReunionCount(),math.max(0,min-count-1),max-count-1) then
				if DEBUG then Debug.Message(c:GetCode()..str2.." >> ? include"..str.." + field") end
				rg:AddCard(c)
			end
			c=mg:GetNext()
		end
	else
		local mgs=mg:Filter(inclf,nil,sc,SUMMON_TYPE_SPECIAL,tp)
		local mgn=mg:Filter(aux.NOT(inclf),nil,sc,SUMMON_TYPE_SPECIAL,tp)
		local c=mgs:GetFirst()
		while c do
			local str=(not locsend or c:IsLocation(locsend)) and "(g)" or ""
			local str2="["..lvlsum.."+"..c:GetReunionCount().."]"
			COUNT_R1=COUNT_R1+1
			local tg=mg:Clone()
			tg=tg:RemoveCard(c)
			if tg:CheckWithSumEqual(Reunion.GetReunionCount,sc:GetReunionCount()*2-lvlsum-c:GetReunionCount(),math.max(0,min-count-1),max-count-1) then
				if DEBUG then Debug.Message(c:GetCode()..str2.." >> include"..str.." + field") end
				rg:AddCard(c)
			end
			c=mgs:GetNext()
		end
		local c1=mgn:GetFirst()
		while c1 do
			local str=(not locsend or c1:IsLocation(locsend)) and "(g)" or ""
			local str2="["..lvlsum.."+"..c1:GetReunionCount().."]"
			COUNT_R1=COUNT_R1+1
			local tg=mg:Clone()
			tg=tg:RemoveCard(c1)
			local res=false
			if DEBUG and res then Debug.Message(c1:GetCode()..str2.." >> not include"..str.." + field") end
			local c2=mgs:GetFirst()
			while c2 and not res do
				COUNT_R1=COUNT_R1+1
				tg=tg:RemoveCard(c2)
				res=tg:CheckWithSumEqual(Reunion.GetReunionCount,sc:GetReunionCount()*2-lvlsum-c1:GetReunionCount()-c2:GetReunionCount(),math.max(0,min-count-2),max-count-2)
				if DEBUG and res then Debug.Message(c1:GetCode()..str2.." >> not include"..str.." + include["..c2:GetReunionCount().."] + field") end
				c2=mgs:GetNext()
			end
			if res then rg:AddCard(c1) end
			c1=mgn:GetNext()
		end
	end
	return rg
end
function Reunion.CheckTypeMaxSend2(mg,sg,tp,sc,f,min,max,locsend,maxsend)
	local lvlsum=sg:GetReunionSum()
	local count=#sg
	local rg=Group.CreateGroup()
	local mgs=mg:Filter(aux.NOT(Card.IsLocation),nil,locsend)
	local mgn=mg:Filter(Card.IsLocation,nil,locsend)
	if sg:IsExists(Card.IsLocation,1,nil,locsend) then
		local c=mgs:GetFirst()
		while c do
			local str=c:IsLocation(locsend) and "(g)" or ""
			local str2="["..lvlsum.."+"..c:GetReunionCount().."]"
			if DEBUG and c:IsType(TYPE_LINK) then Debug.Message(c:GetCode()..": check as mgs 1 "..str2) end
			COUNT_R1=COUNT_R1+1
			local tg=mgs:Clone()
			tg=tg:RemoveCard(c)
			if tg:CheckWithSumEqual(Reunion.GetReunionCount,sc:GetReunionCount()*2-lvlsum-c:GetReunionCount(),math.max(0,min-count-1),max-count-1) then
				if DEBUG then Debug.Message(c:GetCode()..str2.." >> field"..str.." + field") end
				rg:AddCard(c)
			end
			c=mgs:GetNext()
		end
	else
		local c=mgn:GetFirst()
		while c do
			local str2="["..lvlsum.."+"..c:GetReunionCount().."]"
			if DEBUG and c:IsType(TYPE_LINK) then Debug.Message(c:GetCode()..": check as mgn "..str2) end
			COUNT_R1=COUNT_R1+1
			if mgs:CheckWithSumEqual(Reunion.GetReunionCount,sc:GetReunionCount()*2-lvlsum-c:GetReunionCount(),math.max(0,min-count-1),max-count-1) then
				if DEBUG then Debug.Message(c:GetCode()..str2.." >> grave + field") end
				rg:AddCard(c)
			end
			c=mgn:GetNext()
		end
		local c1=mgs:GetFirst()
		while c1 do
			local str2="["..lvlsum.."+"..c1:GetReunionCount().."]"
			if DEBUG and c1:IsType(TYPE_LINK) then Debug.Message(c1:GetCode()..": check as mgs 2 "..str2) end
			COUNT_R1=COUNT_R1+1
			local tg=mgs:Clone()
			tg=tg:RemoveCard(c1)
			local res=mgs:CheckWithSumEqual(Reunion.GetReunionCount,sc:GetReunionCount()*2-lvlsum-c1:GetReunionCount(),math.max(0,min-count-1),max-count-1)
			if DEBUG and res then Debug.Message(c1:GetCode()..str2.." >> field + field") end
			if not res then
				local c2=mgn:GetFirst()
				while c2 and not res do
					COUNT_R1=COUNT_R1+1
					res=tg:CheckWithSumEqual(Reunion.GetReunionCount,sc:GetReunionCount()*2-lvlsum-c1:GetReunionCount()-c2:GetReunionCount(),math.max(0,min-count-2),max-count-2)
					if DEBUG and res then Debug.Message(c1:GetCode()..str2.." >> field + grave["..c2:GetReunionCount().."] + field") end
					c2=mgn:GetNext()
				end
			end
			if res then rg:AddCard(c1) end
			c1=mgs:GetNext()
		end
	end
	return rg
end	
function Reunion.CheckTypeIncludeMaxSend2(mg,sg,tp,sc,f,min,max,inclf,locsend,maxsend)
	if DEBUG then Debug.Message("---------------------------------") end
	mg=mg:Remove(Reunion.Remove,nil,sg)
	local rg=Group.CreateGroup()
	if sg:IsExists(inclf,1,nil,sc,SUMMON_TYPE_SPECIAL,tp) then
		if DEBUG then Debug.Message("CheckTypeMaxSend") end
		rg=Reunion.CheckTypeMaxSend2(mg,sg,tp,sc,f,min,max,locsend,maxsend)
	else
		local mgs=mg:Filter(aux.NOT(Card.IsLocation),nil,locsend)
		local mgn=mg:Filter(Card.IsLocation,nil,locsend)	
		if sg:IsExists(Card.IsLocation,1,nil,locsend) then
			if DEBUG then Debug.Message("CheckTypeInclude") end
			rg=Reunion.CheckTypeInclude2(mgs,sg,tp,sc,f,min,max,inclf)
		else
			local lvlsum=sg:GetReunionSum()
			local count=#sg	
			local mg1=mg:Filter(inclf,nil,sc,SUMMON_TYPE_SPECIAL,tp)
			local mg2=mg:Filter(aux.NOT(inclf),nil,sc,SUMMON_TYPE_SPECIAL,tp)
			local c1=mg1:GetFirst()
			while c1 do
				local str=c1:IsLocation(locsend) and "(g)" or ""
				local str2="["..lvlsum.."+"..c1:GetReunionCount().."]"
				COUNT_R1=COUNT_R1+1
				local tg=mgs:Clone():RemoveCard(c1)
				local res=tg:CheckWithSumEqual(Reunion.GetReunionCount,sc:GetReunionCount()*2-lvlsum-c1:GetReunionCount(),math.max(0,min-count-1),max-count-1)
				if DEBUG and res then Debug.Message(c1:GetCode()..str2.." >> include"..str.." + field") end
				if not res and not c1:IsLocation(locsend) then
					local c2=mgn:GetFirst()
					while c2 and not res do
						COUNT_R1=COUNT_R1+1
						res=tg:CheckWithSumEqual(Reunion.GetReunionCount,sc:GetReunionCount()*2-lvlsum-c1:GetReunionCount()-c2:GetReunionCount(),math.max(0,min-count-2),max-count-2)
						if DEBUG and res then Debug.Message(c1:GetCode()..str2.." >> include"..str.." + grave["..c2:GetReunionCount().."] + field") end
						c2=mgn:GetNext()
					end
				end
				if res then rg:AddCard(c1) end
				c1=mg1:GetNext()
			end
			if not mg1:IsExists(aux.NOT(Card.IsLocation),1,nil,locsend) then mg2=mg2:Filter(aux.NOT(Card.IsLocation),nil,locsend) end
			local c1=mg2:GetFirst()
			while c1 do
				local str=c1:IsLocation(locsend) and "(g)" or ""
				local str2="["..lvlsum.."+"..c1:GetReunionCount().."]"
				COUNT_R1=COUNT_R1+1
				local tg=mgs:Clone():RemoveCard(c1)
				local res=false
				if DEBUG and res then Debug.Message(c1:GetCode()..str2.." >> not include"..str.." + include") end
				local mg1s=mg1:Clone()
				if c1:IsLocation(locsend) then mg1s=mg1s:Filter(aux.NOT(Card.IsLocation),nil,locsend) end
				local c2=mg1s:GetFirst()
				while c2 and not res do
					COUNT_R1=COUNT_R1+1
					tg:RemoveCard(c2)					
					res=tg:CheckWithSumEqual(Reunion.GetReunionCount,sc:GetReunionCount()*2-lvlsum-c1:GetReunionCount()-c2:GetReunionCount(),math.max(0,min-count-2),max-count-2)
					if DEBUG and res then Debug.Message(c1:GetCode()..str2.." >> not include"..str.." + include["..c2:GetReunionCount().."] + field") end					
					if not res and not c1:IsLocation(locsend) and not c2:IsLocation(locsend) then
						local c3=mgn:GetFirst()
						while c3 and not res do
							COUNT_R1=COUNT_R1+1
							res=tg:CheckWithSumEqual(Reunion.GetReunionCount,sc:GetReunionCount()*2-lvlsum-c1:GetReunionCount()-c2:GetReunionCount()-c3:GetReunionCount(),math.max(0,min-count-3),max-count-3)
							if DEBUG and res then Debug.Message(c1:GetCode()..str2.." >> not include"..str.." + include["..c2:GetReunionCount().."] + grave["..c3:GetReunionCount().."] + field") end
							c3=mgn:GetNext()
						end
					end
					c2=mg1s:GetNext()
				end
				if res then rg:AddCard(c1) end
				c1=mg2:GetNext()
			end
		end
	end
	return rg
end
function Reunion.Condition(f,minc,maxc,specialchk,opp,loc,send,locsend,maxsend,inclf,r_type)
	return	function(e,c,must,g,min,max)
				if c==nil then return true end
				if c:IsType(TYPE_PENDULUM) and c:IsFaceup() then return false end
				local tp=c:GetControler()
				local loc2=0
				if opp then loc2=loc end
				if not g then
					g=Duel.GetMatchingGroup(Card.IsFaceup,tp,loc,loc2,nil)
				end
				local mg=g:Filter(Reunion.ConditionFilter,nil,f,c,tp,send,locsend)
				local mustg=Auxiliary.GetMustBeMaterialGroup(tp,g,tp,c,mg,REASON_REUNION)
				if must then mustg:Merge(must) end
				if min and min < minc then return false end
				if max and max > maxc then return false end
				min = min or minc
				max = max or maxc
				if mustg:IsExists(aux.NOT(Reunion.ConditionFilter),1,nil,f,c,tp,send,locsend) or #mustg>max then return false end
				local emt,tg=aux.GetExtraMaterials(tp,mustg+mg,c,SUMMON_TYPE_REUNION)
				local res=(mg+tg):Includes(mustg) and #mustg<=max
				COUNT_R1=0
				COUNT_R2=0
				if res then					
					if r_type&REUNION_TYPE_CHECK==0 then
						local mustlvl=Reunion.GetReunionSum(mustg)
						local mustcount=#mustg
						if r_type==REUNION_TYPE_NONE or r_type==REUNION_TYPE_LOCATION then
							res=(mg+tg):CheckWithSumEqual(Reunion.GetReunionCount,c:GetReunionCount()*2-mustlvl,min-mustcount,max-mustcount)
						elseif r_type&REUNION_TYPES_MAIN==REUNION_TYPE_INCLUDE then
							res=Reunion.CheckTypeInclude((mg+tg),sg,tp,c,f,min,max,inclf)
						elseif r_type&REUNION_TYPES_MAIN==REUNION_TYPE_MAXSEND then
							res=Reunion.CheckTypeMaxSend((mg+tg),sg,tp,c,f,min,max,locsend,maxsend)
						elseif r_type&REUNION_TYPES_MAIN==REUNION_TYPE_INCLUDE+REUNION_TYPE_MAXSEND then
							res=Reunion.CheckTypeIncludeMaxSend((mg+tg),sg,tp,c,f,min,max,inclf,locsend,maxsend)
						else
							res=Reunion.CheckTypeIncludeMaxSend((mg+tg),sg,tp,c,f,min,max,inclf,locsend,maxsend)
						end
					else
						if #mustg==max then
							local sg=Group.CreateGroup()
							res=mustg:IsExists(Reunion.CheckRecursive,1,sg,tp,sg,(mg+tg),c,min,max,f,specialchk,mg,emt)
						elseif #mustg<max then
							local sg=mustg
							res=(mg+tg):IsExists(Reunion.CheckRecursive,1,sg,tp,sg,(mg+tg),c,min,max,f,specialchk,mg,emt)
						end
					end
				end
				if DEBUG and COUNT_R1>10 then Debug.Message("CheckRecursive: "..COUNT_R1) end
				aux.DeleteExtraMaterialGroups(emt)
				return res
			end
end
function Reunion.Target(f,minc,maxc,specialchk,opp,loc,send,locsend,maxsend,inclf,r_type)
	return	function(e,tp,eg,ep,ev,re,r,rp,chk,c,must,g,min,max)
				local loc2=0
				if opp then loc2=loc end
				if not g then
					g=Duel.GetMatchingGroup(Card.IsFaceup,tp,loc,loc2,nil)
				end
				local mg=g:Filter(Reunion.ConditionFilter,nil,f,c,tp,send,locsend)
				local mustg=Auxiliary.GetMustBeMaterialGroup(tp,g,tp,c,mg,REASON_REUNION)
				if must then mustg:Merge(must) end
				if min and min < minc then return false end
				if max and max > maxc then return false end
				min = min or minc
				max = max or maxc
				local emt,tg=aux.GetExtraMaterials(tp,mustg+mg,c,SUMMON_TYPE_REUNION)
				tg=tg:Filter(Reunion.ConditionFilter,nil,f,c,tp,send,locsend)
				local sg=Group.CreateGroup()
				local finish=false
				local cancel=false
				sg:Merge(mustg)
				COUNT_R1=0
				COUNT_R2=0
				if r_type&REUNION_TYPE_CHECK==0 then
					local mustlvl=Reunion.GetReunionSum(mustg)
					local mustcount=#mustg
					while #sg<max do
						local cg
						if r_type==REUNION_TYPE_NONE or r_type==REUNION_TYPE_LOCATION then
							cg=(mg+tg):Filter(Reunion.CheckNotRecursive,nil,(mg+tg),sg,tp,c,f,min,max)
						elseif r_type&REUNION_TYPES_MAIN==REUNION_TYPE_INCLUDE then
							cg=Reunion.CheckTypeInclude2((mg+tg),sg,tp,c,f,min,max,inclf)
						elseif r_type&REUNION_TYPES_MAIN==REUNION_TYPE_MAXSEND then
							cg=Reunion.CheckTypeMaxSend2((mg+tg),sg,tp,c,f,min,max,locsend,maxsend)
						elseif r_type&REUNION_TYPES_MAIN==REUNION_TYPE_INCLUDE+REUNION_TYPE_MAXSEND then
							cg=Reunion.CheckTypeIncludeMaxSend2((mg+tg),sg,tp,c,f,min,max,inclf,locsend,maxsend)
						else
							cg=Reunion.CheckTypeIncludeMaxSend2((mg+tg),sg,tp,c,f,min,max,inclf,locsend,maxsend)
						end						
						if #cg==0 then break end
						finish=#sg>=min and #sg<=max and Reunion.CheckGoal2(tp,sg,c,min,max,mustlvl,mustcount,inclf,locsend,maxsend)
						cancel=Duel.IsSummonCancelable() and #sg==0
						Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RMATERIAL)
						cg:Remove(Reunion.Remove,nil,sg)
						local tc=Group.SelectUnselect(cg,sg,tp,finish,cancel,min,max)
						if not tc then break end
						if #mustg==0 or not mustg:IsContains(tc) then
							if not sg:IsContains(tc) then
								sg:AddCard(tc)
							else
								sg:RemoveCard(tc)
							end
						end
					end
				else
					while #sg<max do
						local filters={}
						if #sg>0 then
							Reunion.CheckRecursive2(sg:GetFirst(),tp,Group.CreateGroup(),sg,mg+tg,mg+tg,c,min,max,f,specialchk,mg,emt,filters)
						end
						local cg=(mg+tg):Filter(Reunion.CheckRecursive,sg,tp,sg,(mg+tg),c,min,max,f,specialchk,mg,emt,{table.unpack(filters)})
						if #cg==0 then break end
						finish=#sg>=min and #sg<=max and Reunion.CheckGoal(tp,sg,c,min,f,specialchk,filters)
						cancel=not og and Duel.IsSummonCancelable() and #sg==0
						Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RMATERIAL)
						local tc=Group.SelectUnselect(cg,sg,tp,finish,cancel,1,1)
						if not tc then break end
						if #mustg==0 or not mustg:IsContains(tc) then
							if not sg:IsContains(tc) then
								sg:AddCard(tc)
							else
								sg:RemoveCard(tc)
							end
						end
					end
				end
				if DEBUG and COUNT_R1>10 then Debug.Message("CheckRecursive: "..COUNT_R1) end
				if DEBUG and COUNT_R2>10 then Debug.Message("CheckRecursive2: "..COUNT_R2) end
				
				local res=0 -- 0 => exit, 1 => ok, 2 => error
				if #sg>0 then
					if #sg>=min and #sg<=max and Reunion.CheckGoal2(tp,sg,c,min,max,Reunion.GetReunionSum(mustg),#mustg,inclf,locsend,maxsend) then
						res = 1
					else
						res = 2
						DEBUG = true
						Debug.Message("ERROR in reunion_proc.lua for summoning "..c:GetCode())
						local str=" #sg="..#sg.." materials:"
						local tc=sg:GetFirst()
						while tc do
							str=str.." "..tc:GetCode()..","
							tc=sg:GetNext()
						end
						Debug.Message(str)
					end
				end
				
				if res==1 then
					local filters={}
					if r_type&REUNION_TYPE_CHECK>0 then Reunion.CheckRecursive2(sg:GetFirst(),tp,Group.CreateGroup(),sg,mg+tg,mg+tg,c,min,max,f,specialchk,mg,emt,filters) end
					sg:KeepAlive()
					local reteff=Effect.GlobalEffect()
					reteff:SetTarget(function()return sg,filters,emt end)
					e:SetLabelObject(reteff)
					return true
				else 
					aux.DeleteExtraMaterialGroups(emt)
					return false
				end
			end
end
function Reunion.Operation(f,minc,maxc,specialchk,opp,loc,send,locsend,maxsend,inclf,r_type)
	return	function(e,tp,eg,ep,ev,re,r,rp,c,must,g,min,max)
				local g,filt,emt=e:GetLabelObject():GetTarget()()
				e:GetLabelObject():Reset()
				for _,ex in ipairs(filt) do
					if ex[3]:GetValue() then
						ex[3]:GetValue()(1,SUMMON_TYPE_SPECIAL,ex[3],ex[1]&g,c,tp)
					end
				end
				c:SetMaterial(g)				
				if locsend then
					local g2=g:Filter(aux.NOT(Card.IsLocation),nil,locsend)
					g=g:Filter(Card.IsLocation,nil,locsend)
					if #g2>0 then Duel.SendtoGrave(g2,REASON_MATERIAL+REASON_REUNION) end
					g2:DeleteGroup()
				end					
				if send==REUNION_MAT_TOGRAVE then
					Duel.SendtoGrave(g,REASON_MATERIAL+REASON_REUNION)
				elseif send==REUNION_MAT_REMOVE then
					Duel.Remove(g,POS_FACEUP,REASON_MATERIAL+REASON_REUNION)
				elseif send==REUNION_MAT_REMOVE_FACEDOWN then
					Duel.Remove(g,POS_FACEDOWN,REASON_MATERIAL+REASON_REUNION)
				elseif send==REUNION_MAT_TOHAND then
					Duel.SendtoHand(g,nil,REASON_MATERIAL+REASON_REUNION)
				elseif send==REUNION_MAT_TODECK then
					Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_MATERIAL+REASON_REUNION)
				elseif send==REUNION_MAT_DESTROY then
					Duel.Destroy(g,REASON_MATERIAL+REASON_REUNION)
				else
					Duel.SendtoGrave(g,REASON_MATERIAL+REASON_REUNION)
				end
				g:DeleteGroup()
				aux.DeleteExtraMaterialGroups(emt)
			end
end
-- Reunion Summon by card effect
function Card.IsReunionSummonable(c,e,tp,must_use,mg,min,max)
	return c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SPECIAL,tp,false,false)
		and c.IsReunion and c:ReunionRule(e,tp,must_use,mg,min,max)
end
function Card.ReunionRule(c,e,tp,mustg,g,minc,maxc)
	if c==nil then return true end
	if minc==nil then minc=1 end
	if maxc==nil then maxc=99 end
	if c:IsType(TYPE_PENDULUM) and c:IsFaceup() then return false end
	local mt=c:GetMetatable()
	local f=mt.reunion_parameters[2]
	local minc=mt.reunion_parameters[3]
	local maxc=mt.reunion_parameters[4]
	local specialchk=mt.reunion_parameters[5]
	local opp=mt.reunion_parameters[6]
	local loc=mt.reunion_parameters[7]
	local send=mt.reunion_parameters[8]
	local locsend=mt.reunion_parameters[9]
	local maxsend=mt.reunion_parameters[10]
	local inclf=mt.reunion_parameters[11]
	local r_type=mt.reunion_parameters[12]
	
	local loc2=0
	if opp then loc2=loc end
	if not g then
		g=Duel.GetMatchingGroup(Card.IsFaceup,tp,loc,loc2,nil)
	end
	local mg=g:Filter(Reunion.ConditionFilter,nil,f,c,tp,send,locsend)
	if min and min < minc then return false end
	if max and max > maxc then return false end
	min = min or minc
	max = max or maxc
	if mustg:IsExists(aux.NOT(Reunion.ConditionFilter),1,nil,f,c,tp,send,locsend) or #mustg>max then return false end
	local emt,tg=aux.GetExtraMaterials(tp,mustg+mg,c,SUMMON_TYPE_REUNION)
	local res=(mg+tg):Includes(mustg) and #mustg<=max
	COUNT_R1=0
	COUNT_R2=0
	if res then		
		if r_type&REUNION_TYPE_CHECK==0 then
			local mustlvl=Reunion.GetReunionSum(mustg)
			local mustcount=#mustg
			if r_type==REUNION_TYPE_NONE or r_type==REUNION_TYPE_LOCATION then
				res=(mg+tg):CheckWithSumEqual(Reunion.GetReunionCount,c:GetReunionCount()*2-mustlvl,min-mustcount,max-mustcount)
			elseif r_type&REUNION_TYPES_MAIN==REUNION_TYPE_INCLUDE then
				res=Reunion.CheckTypeInclude((mg+tg),sg,tp,c,f,min,max,inclf)
			elseif r_type&REUNION_TYPES_MAIN==REUNION_TYPE_MAXSEND then
				res=Reunion.CheckTypeMaxSend((mg+tg),sg,tp,c,f,min,max,locsend,maxsend)
			elseif r_type&REUNION_TYPES_MAIN==REUNION_TYPE_INCLUDE+REUNION_TYPE_MAXSEND then
				res=Reunion.CheckTypeIncludeMaxSend((mg+tg),sg,tp,c,f,min,max,inclf,locsend,maxsend)
			else
				res=Reunion.CheckTypeIncludeMaxSend((mg+tg),sg,tp,c,f,min,max,inclf,locsend,maxsend)
			end
		else
			if #mustg==max then
				local sg=Group.CreateGroup()
				res=mustg:IsExists(Reunion.CheckRecursive,1,sg,tp,sg,(mg+tg),c,min,max,f,specialchk,mg,emt)
			elseif #mustg<max then
				local sg=mustg
				res=(mg+tg):IsExists(Reunion.CheckRecursive,1,sg,tp,sg,(mg+tg),c,min,max,f,specialchk,mg,emt)
			end
		end
	end
	if DEBUG and COUNT_R1>10 then Debug.Message("CheckRecursive: "..COUNT_R1) end
	aux.DeleteExtraMaterialGroups(emt)
	return res
end
function Reunion.FilterMustBeMat(mg1,mg2,mustg)
	local tc=mustg:GetFirst()
	while tc do
		if not mg1:IsContains(tc) and not mg2:IsContains(tc) then return false end
		tc=mustg:GetNext()
	end
	return true
end
function Duel.ReunionSummon(tp,c,mustg,g,minc,maxc)
	if minc==nil then minc=1 end
	if maxc==nil then maxc=99 end
	local mt=c:GetMetatable()
	local f=mt.reunion_parameters[2]
	local minc=mt.reunion_parameters[3]
	local maxc=mt.reunion_parameters[4]
	local specialchk=mt.reunion_parameters[5]
	local opp=mt.reunion_parameters[6]
	local loc=mt.reunion_parameters[7]
	local send=mt.reunion_parameters[8]
	local locsend=mt.reunion_parameters[9]
	local maxsend=mt.reunion_parameters[10]
	local inclf=mt.reunion_parameters[11]
	local r_type=mt.reunion_parameters[12]
	
	local loc2=0
	if opp then loc2=loc end
	if not g then
		g=Duel.GetMatchingGroup(Card.IsFaceup,tp,loc,loc2,nil)
	end
	local mg=g:Filter(Reunion.ConditionFilter,nil,f,c,tp,send,locsend)
	if min and min < minc then return false end
	if max and max > maxc then return false end
	min = min or minc
	max = max or maxc
	local emt,tg=aux.GetExtraMaterials(tp,mustg+mg,c,SUMMON_TYPE_REUNION)
	tg=tg:Filter(Reunion.ConditionFilter,nil,f,c,tp,send,locsend)
	local sg=Group.CreateGroup()
	local finish=false
	local cancel=false
	sg:Merge(mustg)
	COUNT_R1=0
	COUNT_R2=0
	if r_type&REUNION_TYPE_CHECK==0 then
		local mustlvl=Reunion.GetReunionSum(mustg)
		local mustcount=#mustg
		while #sg<max do
			local cg
			if r_type==REUNION_TYPE_NONE or r_type==REUNION_TYPE_LOCATION then
				cg=(mg+tg):Filter(Reunion.CheckNotRecursive,nil,(mg+tg),sg,tp,c,f,min,max)
			elseif r_type&REUNION_TYPES_MAIN==REUNION_TYPE_INCLUDE then
				cg=Reunion.CheckTypeInclude2((mg+tg),sg,tp,c,f,min,max,inclf)
			elseif r_type&REUNION_TYPES_MAIN==REUNION_TYPE_MAXSEND then
				cg=Reunion.CheckTypeMaxSend2((mg+tg),sg,tp,c,f,min,max,locsend,maxsend)
			elseif r_type&REUNION_TYPES_MAIN==REUNION_TYPE_INCLUDE+REUNION_TYPE_MAXSEND then
				cg=Reunion.CheckTypeIncludeMaxSend2((mg+tg),sg,tp,c,f,min,max,inclf,locsend,maxsend)
			else
				cg=Reunion.CheckTypeIncludeMaxSend2((mg+tg),sg,tp,c,f,min,max,inclf,locsend,maxsend)
			end			
			if #cg==0 then break end
			finish=#sg>=min and #sg<=max and Reunion.CheckGoal2(tp,sg,c,min,max,mustlvl,mustcount,inclf,locsend,maxsend)
			cancel=Duel.IsSummonCancelable() and #sg==0
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RMATERIAL)
			cg:Remove(Reunion.Remove,nil,sg)
			local tc=Group.SelectUnselect(cg,sg,tp,finish,cancel,min,max)
			if not tc then break end
			if #mustg==0 or not mustg:IsContains(tc) then
				if not sg:IsContains(tc) then
					sg:AddCard(tc)
				else
					sg:RemoveCard(tc)
				end
			end
		end
	else
		while #sg<max do
			local filters={}
			if #sg>0 then
				Reunion.CheckRecursive2(sg:GetFirst(),tp,Group.CreateGroup(),sg,mg+tg,mg+tg,c,min,max,f,specialchk,mg,emt,filters)
			end
			local cg=(mg+tg):Filter(Reunion.CheckRecursive,sg,tp,sg,(mg+tg),c,min,max,f,specialchk,mg,emt,{table.unpack(filters)})
			if #cg==0 then break end
			finish=#sg>=min and #sg<=max and Reunion.CheckGoal(tp,sg,c,min,f,specialchk,filters)
			cancel=not og and Duel.IsSummonCancelable() and #sg==0
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RMATERIAL)
			local tc=Group.SelectUnselect(cg,sg,tp,finish,cancel,1,1)
			if not tc then break end
			if #mustg==0 or not mustg:IsContains(tc) then
				if not sg:IsContains(tc) then
					sg:AddCard(tc)
				else
					sg:RemoveCard(tc)
				end
			end
		end
	end
	if DEBUG and COUNT_R1>10 then Debug.Message("CheckRecursive: "..COUNT_R1) end
	if DEBUG and COUNT_R2>10 then Debug.Message("CheckRecursive2: "..COUNT_R2) end
	
	if #sg>0 then
		local filters={}
		if r_type&REUNION_TYPE_CHECK>0 then Reunion.CheckRecursive2(sg:GetFirst(),tp,Group.CreateGroup(),sg,mg+tg,mg+tg,c,min,max,f,specialchk,mg,emt,filters) end
		local reteff=Effect.GlobalEffect()
		reteff:SetTarget(function()return sg,filters,emt end)
		for _,ex in ipairs(filters) do
			if ex[3]:GetValue() then
				ex[3]:GetValue()(1,SUMMON_TYPE_SPECIAL,ex[3],ex[1]&g,c,tp)
			end
		end
		c:SetMaterial(sg)	
		if locsend then
			local sg2=sg:Filter(aux.NOT(Card.IsLocation),nil,locsend)
			sg=sg:Filter(Card.IsLocation,nil,locsend)
			if #sg2>0 then Duel.SendtoGrave(sg2,REASON_MATERIAL+REASON_REUNION) end
			sg2:DeleteGroup()
		end		
		if send==REUNION_MAT_TOGRAVE then
			Duel.SendtoGrave(g,REASON_MATERIAL+REASON_REUNION)
		elseif send==REUNION_MAT_REMOVE then
			Duel.Remove(g,POS_FACEUP,REASON_MATERIAL+REASON_REUNION)
		elseif send==REUNION_MAT_REMOVE_FACEDOWN then
			Duel.Remove(g,POS_FACEDOWN,REASON_MATERIAL+REASON_REUNION)
		elseif send==REUNION_MAT_TOHAND then
			Duel.SendtoHand(g,nil,REASON_MATERIAL+REASON_REUNION)
		elseif send==REUNION_MAT_TODECK then
			Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_MATERIAL+REASON_REUNION)
		elseif send==REUNION_MAT_DESTROY then
			Duel.Destroy(g,REASON_MATERIAL+REASON_REUNION)
		else
			Duel.SendtoGrave(g,REASON_MATERIAL+REASON_REUNION)
		end
		aux.DeleteExtraMaterialGroups(emt)
	end
end