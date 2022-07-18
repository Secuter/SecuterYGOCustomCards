--Pyroclast Fusion
--Scripted by Secuter
local s,id=GetID()
function s.initial_effect(c)
	local e1=Fusion.CreateSummonEff(c,s.ffilter,nil,s.fextra,s.extraop)
	c:RegisterEffect(e1)
	if not AshBlossomTable then AshBlossomTable={} end
	table.insert(AshBlossomTable,e1)
end
s.listed_series={0x226}
function s.ffilter(c)
	return c:IsAttribute(ATTRIBUTE_FIRE)
end
function s.cfilter(c)
	return c:IsSummonType(SUMMON_TYPE_SPECIAL)
end
function s.dfilter(c)
	return c:IsSetCard(0x226) and c:IsAbleToGrave()
end
function s.fextra(e,tp,mg)
	if Duel.GetFlagEffect(e:GetHandlerPlayer(),id)==0
	and Duel.IsExistingMatchingCard(s.cfilter,tp,0,LOCATION_MZONE,1,nil) then
		local sg=Duel.GetMatchingGroup(s.dfilter,tp,LOCATION_DECK,0,nil)
		if #sg>0 then
			return sg,s.fcheck
		end
	end
	return nil
end
function s.fcheck(tp,sg,fc)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK)<=1
end
function s.extraop(e,tc,tp,sg)
	local mg=sg:Filter(Card.IsLocation,nil,LOCATION_DECK)
	if #mg>0 then
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	end
end