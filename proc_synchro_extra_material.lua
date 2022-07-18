SYNCHRO_EXTRA_MATERIAL_IMPORTED=true
if not aux.SynchroProcedure then
	aux.SynchroProcedure = {}
	Synchro = aux.SynchroProcedure
end
if not Synchro then
	Synchro = aux.SynchroProcedure
end
--[[
if not SYNCHRO_EXTRA_MATERIAL_IMPORTED then Duel.LoadScript("proc_synchro_extra_material.lua") end
]]
Synchro.CheckAdditional=nil
--Synchro monster, m-n tuners + m-n monsters
function Synchro.AddProcedureExtra(c,...)
	--parameters (f1,min1,max1,f2,min2,max2,sub1,sub2,req1,req2,reqm)
	if c.synchro_type==nil then
		local code=c:GetOriginalCode()
		local mt=c:GetMetatable()
		mt.synchro_type=1
		mt.synchro_parameters={...}
		if type(mt.synchro_parameters[2])=='function' then
			Debug.Message("Old Synchro Procedure detected in c"..code..".lua")
			return
		end
	end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetDescription(1172)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(Synchro.ConditionExtra(...))
	e1:SetTarget(Synchro.TargetExtra(...))
	e1:SetOperation(Synchro.Operation)
	e1:SetValue(SUMMON_TYPE_SYNCHRO)
	c:RegisterEffect(e1)
end
function Synchro.ConditionExtra(f1,min1,max1,f2,min2,max2,sub1,sub2,req1,req2,reqm)
	return	function(e,c,smat,mg,min,max)
				if c==nil then return true end
				if c:IsType(TYPE_PENDULUM) and c:IsFaceup() then return false end
				local tp=c:GetControler()
				local dg
				local lv=c:GetLevel()
				local g
				local mgchk
				if mg then
					dg=mg
					g=mg:Filter(Card.IsCanBeSynchroMaterial,c,c)
					mgchk=true
				else
					dg=Duel.GetMatchingGroup(function(mc) return mc:IsFaceup() and (mc:IsControler(tp) or mc:IsCanBeSynchroMaterial(c)) end,tp,LOCATION_MZONE,LOCATION_MZONE,c)
					g=dg:Filter(Card.IsCanBeSynchroMaterial,nil,c)
					mgchk=false
				end
				local emt,etg=aux.GetExtraMaterials(tp,dg,c,SUMMON_TYPE_SYNCHRO)
				etg=etg:Filter(Card.IsCanBeSynchroMaterial,c,c)
				g:Merge(etg)
				local pg=Auxiliary.GetMustBeMaterialGroup(tp,dg,tp,c,g,REASON_SYNCHRO)
				if not g:Includes(pg) or pg:IsExists(aux.NOT(Card.IsCanBeSynchroMaterial),1,nil,c) then return false end
				if smat then
					if smat:IsExists(aux.NOT(Card.IsCanBeSynchroMaterial),1,nil,c) then return false end
					pg:Merge(smat)
					g:Merge(smat)
				end
				if g:IsExists(Synchro.CheckFilterChk,1,nil,f1,f2,sub1,sub2,c,tp) then
					--if there is a monster with EFFECT_SYNCHRO_CHECK (Genomix Fighter/Mono Synchron)
					local g2=g:Clone()
					if not mgchk then
						local thg=g2:Filter(Card.IsHasEffect,nil,EFFECT_HAND_SYNCHRO)
						local hg=Duel.GetMatchingGroup(Card.IsCanBeSynchroMaterial,tp,LOCATION_HAND+LOCATION_GRAVE,0,c,c)
						for thc in aux.Next(thg) do
							local te=thc:GetCardEffect(EFFECT_HAND_SYNCHRO)
							local val=te:GetValue()
							local ag=hg:Filter(function(mc) return val(te,mc,c) end,nil) --tuner
							g2:Merge(ag)
						end
					end
					local res=g2:IsExists(Synchro.CheckP31,1,nil,g2,Group.CreateGroup(),Group.CreateGroup(),Group.CreateGroup(),f1,sub1,f2,sub2,min1,max1,min2,max2,req1,req2,reqm,lv,c,tp,pg,mgchk,min,max)
					local hg=Duel.GetMatchingGroup(Card.IsHasEffect,tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,EFFECT_HAND_SYNCHRO+EFFECT_SYNCHRO_CHECK)
					aux.ResetEffects(hg,EFFECT_HAND_SYNCHRO+EFFECT_SYNCHRO_CHECK)
					Duel.AssumeReset()
					return res
				else
					--no race change
					local tg
					local ntg
					if mgchk then
						tg=g:Filter(Synchro.TunerFilter,nil,f1,sub1,c,tp)
						ntg=g:Filter(Synchro.NonTunerFilter,nil,f2,sub2,c,tp)
					else
						tg=g:Filter(Synchro.TunerFilter,nil,f1,sub1,c,tp)
						ntg=g:Filter(Synchro.NonTunerFilter,nil,f2,sub2,c,tp)
						local thg=tg:Filter(Card.IsHasEffect,nil,EFFECT_HAND_SYNCHRO)
						thg:Merge(ntg:Filter(Card.IsHasEffect,nil,EFFECT_HAND_SYNCHRO))
						local hg=Duel.GetMatchingGroup(Card.IsCanBeSynchroMaterial,tp,LOCATION_HAND+LOCATION_GRAVE,0,c,c)
						for thc in aux.Next(thg) do
							local te=thc:GetCardEffect(EFFECT_HAND_SYNCHRO)
							local val=te:GetValue()
							local thag=hg:Filter(function(mc) return Synchro.TunerFilter(mc,f1,sub1,c,tp) and val(te,mc,c) end,nil) --tuner
							local nthag=hg:Filter(function(mc) return Synchro.NonTunerFilter(mc,f2,sub2,c,tp) and val(te,mc,c) end,nil) --non-tuner
							tg:Merge(thag)
							ntg:Merge(nthag)
						end
					end
					local lv=c:GetLevel()
					local res=tg:IsExists(Synchro.CheckP41,1,nil,tg,ntg,Group.CreateGroup(),Group.CreateGroup(),Group.CreateGroup(),min1,max1,min2,max2,req1,req2,reqm,lv,c,tp,pg,mgchk,min,max)
					local hg=Duel.GetMatchingGroup(Card.IsHasEffect,tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,EFFECT_HAND_SYNCHRO+EFFECT_SYNCHRO_CHECK)
					aux.ResetEffects(hg,EFFECT_HAND_SYNCHRO+EFFECT_SYNCHRO_CHECK)
					return res
				end
				return false
			end
end
function Synchro.TargetExtra(f1,min1,max1,f2,min2,max2,sub1,sub2,req1,req2,reqm)
	return	function(e,tp,eg,ep,ev,re,r,rp,chk,c,smat,mg,min,max)
				local sg=Group.CreateGroup()
				local lv=c:GetLevel()
				local mgchk
				local g
				local dg
				if mg then
					mgchk=true
					dg=mg
					g=mg:Filter(Card.IsCanBeSynchroMaterial,c,c)
				else
					mgchk=false
					dg=Duel.GetMatchingGroup(function(mc) return mc:IsFaceup() and (mc:IsControler(tp) or mc:IsCanBeSynchroMaterial(c)) end,tp,LOCATION_MZONE,LOCATION_MZONE,c)
					g=dg:Filter(Card.IsCanBeSynchroMaterial,nil,c)
				end
				local emt,etg=aux.GetExtraMaterials(tp,dg,c,SUMMON_TYPE_SYNCHRO)
				etg=etg:Filter(Card.IsCanBeSynchroMaterial,c,c)
				g:Merge(etg)
				local pg=Auxiliary.GetMustBeMaterialGroup(tp,dg,tp,c,g,REASON_SYNCHRO)
				if smat then
					pg:Merge(smat)
					g:Merge(smat)
				end
				local tg
				local ntg
				if mgchk then
					tg=g:Filter(Synchro.TunerFilter,nil,f1,sub1,c,tp)
					ntg=g:Filter(Synchro.NonTunerFilter,nil,f2,sub2,c,tp)
				else
					tg=g:Filter(Synchro.TunerFilter,nil,f1,sub1,c,tp)
					ntg=g:Filter(Synchro.NonTunerFilter,nil,f2,sub2,c,tp)
					local thg=tg:Filter(Card.IsHasEffect,nil,EFFECT_HAND_SYNCHRO)
					thg:Merge(ntg:Filter(Card.IsHasEffect,nil,EFFECT_HAND_SYNCHRO))
					local hg=Duel.GetMatchingGroup(Card.IsCanBeSynchroMaterial,tp,LOCATION_HAND+LOCATION_GRAVE,0,c,c)
					for thc in aux.Next(thg) do
						local te=thc:GetCardEffect(EFFECT_HAND_SYNCHRO)
						local val=te:GetValue()
						local thag=hg:Filter(function(mc) return Synchro.TunerFilter(mc,f1,sub1,c,tp) and val(te,mc,c) end,nil) --tuner
						local nthag=hg:Filter(function(mc) return Synchro.NonTunerFilter(mc,f2,sub2,c,tp) and val(te,mc,c) end,nil) --non-tuner
						tg:Merge(thag)
						ntg:Merge(nthag)
					end
				end
				local lv=c:GetLevel()
				local tsg=Group.CreateGroup()
				local selectedastuner=Group.CreateGroup()
				if g:IsExists(Synchro.CheckFilterChk,1,nil,f1,f2,sub1,sub2,c,tp) then
					local ntsg=Group.CreateGroup()
					local tune=true
					local g2=Group.CreateGroup()
					while #ntsg<max2 do
						local cancel=false
						local finish=false
						if tune then
							cancel=not mgchk and Duel.IsSummonCancelable() and #tsg==0
							local g3=ntg:Filter(Synchro.CheckP32,sg,g,tsg,ntsg,sg,f2,sub2,min2,max2,req2,reqm,lv,c,tp,pg,mgchk,min,max)
							g2=g:Filter(Synchro.CheckP31,sg,g,tsg,ntsg,sg,f1,sub1,f2,sub2,min1,max1,min2,max2,req1,req2,reqm,lv,c,tp,pg,mgchk,min,max)
							if #g3>0 and #tsg>=min1 and tsg:IsExists(Synchro.TunerFilter,#tsg,nil,f1,sub1,c,tp) and (not req1 or req1(tsg,c,tp)) then
								g2:Merge(g3)
							end
							Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SMATERIAL)
							local tc=Group.SelectUnselect(g2,sg,tp,false,cancel)
							if not tc then
								if #tsg>=min1 and tsg:IsExists(Synchro.TunerFilter,#tsg,nil,f1,sub1,c,tp) and (not req1 or req1(tsg,c,tp))
									and ntg:Filter(Synchro.CheckP32,sg,g,tsg,ntsg,sg,f2,sub2,min2,max2,req2,reqm,lv,c,tp,pg,mgchk,min,max):GetCount()>0 then tune=false
								else
									return false
								end
							end
							if not sg:IsContains(tc) then
								if g3:IsContains(tc) then
									ntsg:AddCard(tc)
									tune = false
								else
									tsg:AddCard(tc)
								end
								selectedastuner:AddCard(tc)
								sg:AddCard(tc)
								if tc:IsHasEffect(EFFECT_SYNCHRO_CHECK) then
									local teg={tc:GetCardEffect(EFFECT_SYNCHRO_CHECK)}
									for i=1,#teg do
										local te=teg[i]
										local tg=g:Filter(function(mc) return te:GetValue()(te,mc) end,nil)
									end
								end
							else
								selectedastuner:RemoveCard(tc)
								tsg:RemoveCard(tc)
								sg:RemoveCard(tc)
								if not sg:IsExists(Card.IsHasEffect,1,nil,EFFECT_SYNCHRO_CHECK) then
									Duel.AssumeReset()
								end
							end
							if g:FilterCount(Synchro.CheckP31,sg,g,tsg,ntsg,sg,f1,sub1,f2,sub2,min1,max1,min2,max2,req1,req2,reqm,lv,c,tp,pg,mgchk,min,max)==0 or #tsg>=max1 then
								tune=false
							end
						else
							if (#ntsg>=min2 and (not req2 or req2(ntsg,c,tp)) and (not reqm or reqm(sg,c,tp)) 
								and ntsg:IsExists(Synchro.NonTunerFilter,#ntsg,nil,f2,sub2,c,tp)
								and sg:Includes(pg) and Synchro.CheckP43(tsg,ntsg,sg,lv,c,tp)) then
									finish=true
							end
							cancel = (not mgchk and Duel.IsSummonCancelable()) and #sg==0
							g2=g:Filter(Synchro.CheckP32,sg,g,tsg,ntsg,sg,f2,sub2,min2,max2,req2,reqm,lv,c,tp,pg,mgchk,min,max)
							if #g2==0 then break end
							local g3=g:Filter(Synchro.CheckP31,sg,g,tsg,ntsg,sg,f1,sub1,f2,sub2,min1,max1,min2,max2,req1,req2,reqm,lv,c,tp,pg,mgchk,min,max)
							if #g3>0 and #(ntsg-selectedastuner)==0 and #tsg<max1 then
								g2:Merge(g3)
							end
							Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SMATERIAL)
							local tc=Group.SelectUnselect(g2,sg,tp,finish,cancel)
							if not tc then
								if #ntsg>=min2 and (not req2 or req2(ntsg,c,tp)) and (not reqm or reqm(sg,c,tp)) 
									and sg:Includes(pg) and Synchro.CheckP43(tsg,ntsg,sg,lv,c,tp) then break end
								return false
							end
							if not selectedastuner:IsContains(tc) then
								if not sg:IsContains(tc) then
									ntsg:AddCard(tc)
									sg:AddCard(tc)
									if tc:IsHasEffect(EFFECT_SYNCHRO_CHECK) then
										local teg={tc:GetCardEffect(EFFECT_SYNCHRO_CHECK)}
										for i=1,#teg do
											local te=teg[i]
											local tg=g:Filter(function(mc) return te:GetValue()(te,mc) end,nil)
										end
									end
								else
									ntsg:RemoveCard(tc)
									sg:RemoveCard(tc)
									if not sg:IsExists(Card.IsHasEffect,1,nil,EFFECT_SYNCHRO_CHECK) then
										Duel.AssumeReset()
									end
								end
							elseif #(ntsg-selectedastuner)==0 then
								tune=true
								selectedastuner:RemoveCard(tc)
								ntsg:RemoveCard(tc)
								tsg:RemoveCard(tc)
								sg:RemoveCard(tc)
							end
						end
					end
					Duel.AssumeReset()
				else
					local ntsg=Group.CreateGroup()
					local tune=true
					local g2=Group.CreateGroup()
					while #ntsg<max2 do
						local cancel=false
						local finish=false
						if tune then
							cancel=not mgchk and Duel.IsSummonCancelable() and #tsg==0
							local g3=ntg:Filter(Synchro.CheckP42,sg,ntg,tsg,ntsg,sg,min2,max2,req2,reqm,lv,c,tp,pg,mgchk,min,max)
							g2=tg:Filter(Synchro.CheckP41,sg,tg,ntg,tsg,ntsg,sg,min1,max1,min2,max2,req1,req2,reqm,lv,c,tp,pg,mgchk,min,max)
							if #g3>0 and #tsg>=min1 and (not req1 or req1(tsg,c,tp)) then
								g2:Merge(g3)
							end
							Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SMATERIAL)
							local tc=Group.SelectUnselect(g2,sg,tp,finish,cancel)
							if not tc then
								if #tsg>=min1 and (not req1 or req1(tsg,c,tp))
									and ntg:Filter(Synchro.CheckP42,sg,ntg,tsg,ntsg,sg,min2,max2,req2,reqm,lv,c,tp,pg,mgchk,min,max):GetCount()>0 then tune=false
								else
									return false
								end
							else
								if not sg:IsContains(tc) then
									if g3:IsContains(tc) then
										ntsg:AddCard(tc)
										tune = false
									else
										tsg:AddCard(tc)
									end
									selectedastuner:AddCard(tc)
									sg:AddCard(tc)
								else
									selectedastuner:RemoveCard(tc)
									tsg:RemoveCard(tc)
									sg:RemoveCard(tc)
								end
							end
							if tg:FilterCount(Synchro.CheckP41,sg,tg,ntg,tsg,ntsg,sg,min1,max1,min2,max2,req1,req2,reqm,lv,c,tp,pg,mgchk,min,max)==0 or #tsg>=max1 then
								tune=false
							end
						else
							if #ntsg>=min2 and (not req2 or req2(ntsg,c,tp)) and (not reqm or reqm(sg,c,tp))
								and sg:Includes(pg) and Synchro.CheckP43(tsg,ntsg,sg,lv,c,tp) then
								finish=true
							end
							cancel=not mgchk and Duel.IsSummonCancelable() and #sg==0
							g2=ntg:Filter(Synchro.CheckP42,sg,ntg,tsg,ntsg,sg,min2,max2,req2,reqm,lv,c,tp,pg,mgchk,min,max)
							if #g2==0 then break end
							local g3=tg:Filter(Synchro.CheckP41,sg,tg,ntg,tsg,ntsg,sg,min1,max1,min2,max2,req1,req2,reqm,lv,c,tp,pg,mgchk,min,max)
							if #g3>0 and #(ntsg-selectedastuner)==0 and #tsg<max1 then
								g2:Merge(g3)
							end
							Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SMATERIAL)
							local tc=Group.SelectUnselect(g2,sg,tp,finish,cancel)
							if not tc then
								if #ntsg>=min2 and (not req2 or req2(ntsg,c,tp)) and (not reqm or reqm(sg,c,tp))
									and sg:Includes(pg) and Synchro.CheckP43(tsg,ntsg,sg,lv,c,tp) then break end
								return false
							end
							if not selectedastuner:IsContains(tc) then
								if not sg:IsContains(tc) then
									ntsg:AddCard(tc)
									sg:AddCard(tc)
								else
									ntsg:RemoveCard(tc)
									sg:RemoveCard(tc)
								end
							elseif #(ntsg-selectedastuner)==0 then
								tune=true
								selectedastuner:RemoveCard(tc)
								ntsg:RemoveCard(tc)
								tsg:RemoveCard(tc)
								sg:RemoveCard(tc)
							end
						end
					end
				end
				local hg=Duel.GetMatchingGroup(Card.IsHasEffect,tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,EFFECT_HAND_SYNCHRO+EFFECT_SYNCHRO_CHECK)
				aux.ResetEffects(hg,EFFECT_HAND_SYNCHRO+EFFECT_SYNCHRO_CHECK)
				if sg then
					local subtsg=tsg:Filter(function(c) return sub1 and sub1(c) and ((f1 and not f1(c)) or not c:IsType(TYPE_TUNER)) end,nil)
					local subc=subtsg:GetFirst()
					while subc do
						local e1=Effect.CreateEffect(c)
						e1:SetType(EFFECT_TYPE_SINGLE)
						e1:SetCode(EFFECT_ADD_TYPE)
						e1:SetValue(TYPE_TUNER)
						e1:SetReset(RESET_EVENT+RESETS_STANDARD)
						subc:RegisterEffect(e1,true)
						subc=subtsg:GetNext()
					end
					sg:KeepAlive()
					e:SetLabelObject(sg)
					return true
				else return false end
			end
end