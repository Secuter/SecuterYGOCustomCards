--Littlebeard, the Plunder Patroll Quartermaster
--Scripted by Secuter
if not SECUTER_IMPORTED then Duel.LoadScript("secuter_utility.lua") end
local s,id=GetID()
s.Echo=true
function s.initial_effect(c)
	c:EnableReviveLimit()
	--echo summon
	Echo.AddProcedure(c,s.efilter)
	--quick echo summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.ectg)
	e1:SetOperation(s.ecop)
	c:RegisterEffect(e1)
	--spsummon from hand/gy
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
s.listed_names={id}
s.listed_series={SET_PLUNDER_PATROLL}
function s.efilter(c,sc,sumtype,tp)
	return c:IsSetCard(SET_PLUNDER_PATROLL) and c:IsSummonLocation(LOCATION_EXTRA)
end
--quick echo summon
function s.mgfilter(c,e,tp,tc)
	return c:IsFaceup() and c:IsSetCard(SET_PLUNDER_PATROLL) and tc:IsEchoSummonable(e,tp,nil,Group.FromCards(c))
end
function s.ectg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.mgfilter(chkc,e,tp,c) end
	if chk==0 then return Duel.IsExistingTarget(s.mgfilter,tp,LOCATION_MZONE,0,1,nil,e,tp,c) end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
	Duel.SelectTarget(tp,s.mgfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp,c)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.ecop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsLocation(LOCATION_HAND) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local mg=Group.FromCards(tc)
		Duel.EchoSummon(tp,c,mg,mg)
	end
end
--spsummon from hand/gy
function s.filter(c,e,tp,ft)
	return c:IsSetCard(SET_PLUNDER_PATROLL)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and (ft>0 or (c:IsControler(tp) and c:GetSequence()<5))
end
function s.cfilter(c)
	return c:IsMonster() and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE))
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(aux.FaceupFilter(Card.IsType,TYPE_EFFECT),tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp,ft)
		and Duel.IsPlayerCanDraw(tp,1) end
	local g=Duel.SelectTarget(tp,aux.FaceupFilter(Card.IsType,TYPE_EFFECT),tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
	--check if equipped
	if c:GetEquipGroup():IsExists(Card.IsSetCard,1,nil,SET_PLUNDER_PATROLL) then
		e:SetLabel(1)
	else
		e:SetLabel(0)
	end
	local cat=CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP
	if e:GetLabel()==1 then cat=cat+CATEGORY_TOHAND+CATEGORY_SEARCH end
	e:SetCategory(cat)
end
function s.thfilter(c)
	return c:IsSetCard(SET_PLUNDER_PATROLL) and not c:IsCode(id) and c:IsAbleToHand()
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,ft):GetFirst()
	if not sc or Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)<1 then return end
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsType(TYPE_EFFECT)
		and tc:IsControler(tp) and Duel.Equip(tp,tc,sc,true) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(s.eqlimit)
		e1:SetLabelObject(sc)
		tc:RegisterEffect(e1)
		--search
		local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
		if e:GetLabel()==1 and #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local sg=g:Select(tp,1,1,nil)
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,sg)
		end
	end
end
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end