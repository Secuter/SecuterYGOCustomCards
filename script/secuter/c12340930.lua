--Asura - Fusion
--Scripted by Secuter
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Fusion.CreateSummonEff(c,aux.FilterBoolFunction(Card.IsSetCard,0x218),nil,s.fextra)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
	if not AshBlossomTable then AshBlossomTable={} end
	table.insert(AshBlossomTable,e1)
end
s.listed_series={0x218}
function s.cfilter(c)
	return c:IsSummonType(SUMMON_TYPE_TRIBUTE) and c:IsLevelAbove(7)
end
function s.mfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x218) and c:IsAbleToGrave()
end
function s.fextra(e,tp,mg)
	if Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil) then
		return Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_DECK,0,nil)
	end
	return nil
end