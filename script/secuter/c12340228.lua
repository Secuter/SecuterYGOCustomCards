--Hafnir, the Fluid Captain
--Scripted by Secuter
if not SECUTER_IMPORTED then Duel.LoadScript("secuter_utility.lua") end
local s,id=GetID()
function s.initial_effect(c)
	Pendulum.AddProcedure(c)
	--search or spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	c:RegisterEffect(e1)
end
s.listed_series={SET_LV,SET_FLUID,SET_FLUIDSPHERE}

--reveal
function s.thfilter(c)
	return c:IsSetCard(SET_FLUID) and c:IsSpellTrap() and c:IsAbleToHand()
end
function s.spfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(SET_LV) and c:IsSetCard(SET_FLUID) and c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
function s.cfilter(c,e,tp)
	return ((c:IsSetCard(SET_LV) and c:IsMonster() and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil))
			or (c:IsSetCard(SET_FLUIDSPHERE) and c:IsSpellTrap() and c:IsType(TYPE_CONTINUOUS) and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp))
		) and not c:IsPublic()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,c,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local rc=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,c,e,tp):GetFirst()
	Duel.SetTargetCard(rc)
	Duel.ConfirmCards(1-tp,rc)
	Duel.ShuffleHand(tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	local b2=Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
	if chk==0 then return true end
	local ctype=Duel.GetFirstTarget():GetType()
	if ctype&TYPE_MONSTER>0 then
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		e:SetProperty(0)
		e:SetOperation(s.thop)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	elseif ctype&(TYPE_SPELL|TYPE_TRAP)>0 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e:SetProperty(0)
		e:SetOperation(s.spop)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	end
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT) and g:GetFirst():IsLocation(LOCATION_HAND) then
		Duel.ConfirmCards(1-tp,g)
		--spsummon itself
		local tc=Duel.GetFirstTarget()
		if tc:IsDiscardable(REASON_EFFECT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.BreakEffect()
			if Duel.SendtoGrave(tc,REASON_EFFECT+REASON_DISCARD)>0 then
				Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
			end
		end
	end
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 and Duel.SpecialSummonStep(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)>0 then
		tc:RegisterFlagEffect(tc:GetCode(),RESET_EVENT+0x16e0000,0,0)
		Duel.SpecialSummonComplete()
		--spsummon itself
		local tc=Duel.GetFirstTarget()
		if tc:IsDiscardable(REASON_EFFECT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.BreakEffect()
			if Duel.SendtoGrave(tc,REASON_EFFECT+REASON_DISCARD)>0 then
				Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
			end
		end
	end
end
