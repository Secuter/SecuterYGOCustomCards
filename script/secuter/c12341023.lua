--Alternative Polymerization
--Scripted by Secuter
if not SECUTER_IMPORTED then Duel.LoadScript("secuter_utility.lua") end
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Fusion.CreateSummonEff(c,nil,Fusion.IsMonsterFilter(s.matfilter),s.fextra,nil,nil,s.stage2,nil,nil,nil,nil,nil,nil,nil,s.extratg)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
end
function s.matfilter(c)
	return c:IsType(TYPE_NORMAL) and c:IsAbleToGrave()
end
function s.fextra(e,tp,mg)
	return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(s.matfilter),tp,LOCATION_DECK,0,nil)
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,0,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_DECK)
end
function s.stage2(e,tc,tp,mg,chk)
	local c=e:GetHandler()
	if chk==2 then
		if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(aux.Stringid(id,0))
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
			e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
			e1:SetTargetRange(1,0)
			e1:SetTarget(s.splimit)
			e1:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e1,tp)
		end
	end
end
function s.splimit(e,c)
	return not Duel.IsExistingMatchingCard(aux.FaceupFilter(aux.NOT(Card.IsType),TYPE_EFFECT),e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil)
end
