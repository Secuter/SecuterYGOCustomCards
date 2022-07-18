--Undead Eagle Overseer Fusion
--Scripted by Secuter
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Fusion.CreateSummonEff(c,aux.FilterBoolFunction(Card.IsRace,RACE_ZOMBIE|RACE_WINGEDBEAST),Fusion.OnFieldMat(s.mfilter),s.fextra,s.fop,nil,s.stage2)
	e1:SetCost(s.cost)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
	if not GhostBelleTable then GhostBelleTable={} end
	table.insert(GhostBelleTable,e1)
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
function s.mfilter(c)
	return c:IsAbleToHand() and c:IsRace(RACE_ZOMBIE+RACE_WINGEDBEAST)
end
function s.fextra(e,tp,mg)
	return Duel.GetMatchingGroup(aux.NecroValleyFilter(Fusion.IsMonsterFilter(Card.IsFaceup,Card.IsAbleToHand)),tp,LOCATION_GRAVE,0,nil)
end
function s.fop(e,tc,tp,sg)
	Duel.SendtoHand(sg,nil,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
	sg:Clear()
end
function s.stage2(e,tc,tp,mg,chk)
	if chk==2 then
		if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
			e1:SetDescription(aux.Stringid(id,0))
			e1:SetTargetRange(1,0)
			e1:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e1,tp)
		end
	end
end
function s.counterfilter(c)
	return c:IsRace(RACE_ZOMBIE+RACE_WINGEDBEAST)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsRace(RACE_ZOMBIE+RACE_WINGEDBEAST)
end