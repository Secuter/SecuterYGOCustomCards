--Dark Sovereign Squire
--Scripted by Secuter
if not SECUTER_IMPORTED then Duel.LoadScript("secuter_utility.lua") end
local s,id=GetID()
s.Runic=true
function s.initial_effect(c)
	--spsummon itself
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--search
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.thcon)
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
    --runic effect
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG2_RUNIC)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.rcon)
    e3:SetCost(s.rcost)
	e3:SetTarget(s.rtg)
	e3:SetOperation(s.rop)
	c:RegisterEffect(e3)
end
s.listed_names={id}
s.listed_series={SET_DARK_SOVEREIGN}

--spsummon itself
function s.cfilter(c,tp)
	return c:IsRunic() and c:IsSpellTrap() and c:IsAbleToGraveAsCost()
        and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil,c:GetCode())
end
function s.tgfilter(c,code)
	return c:IsSetCard(SET_DARK_SOVEREIGN) and c:IsRunic() and c:IsSpellTrap() and not c:IsCode(code) and c:IsAbleToGrave()
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,e:GetHandler(),tp) end
    local tc=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,e:GetHandler(),tp):GetFirst()
    e:SetLabel(tc:GetCode())
	Duel.SendtoGrave(tc,REASON_DISCARD+REASON_COST)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		local sg=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_DECK,0,nil,e:GetLabel())
        if #sg>0 then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
			local g=sg:Select(tp,1,1,nil)
            if #g>0 then
                Duel.SendtoGrave(g,REASON_EFFECT)
            end
        end
	end
end

--search
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==tp and re and re:IsHasProperty(EFFECT_FLAG2_RUNIC) and not re:GetHandler():IsCode(id)
end
function s.thfilter(c)
	return c:IsSpellTrap() and c:IsSetCard(SET_DARK_SOVEREIGN) and c:GetCode()~=id and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

--runic effect
function s.rcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND)
end
function s.rcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
function s.rfilter(c,e,tp,eg,ep,ev,re,r,rp)
	if c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsRunic() then
		local te=c.RunicEffect
		if te then
			local condition=c.RunicEffect:GetCondition()
			local target=c.RunicEffect:GetTarget()
			return (not condition or condition(e,tp,eg,ep,ev,re,r,rp)) and (not target or target(e,tp,eg,ep,ev,re,r,rp,0))
		end
	end
	return false
end
function s.rtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()==0 then return false end
		e:SetLabel(0)
		return Duel.IsExistingMatchingCard(s.rfilter,tp,LOCATION_HAND,0,1,nil,e,tp,eg,ep,ev,re,r,rp)
	end
	e:SetLabel(0)
	--cost
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,s.rfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp,eg,ep,ev,re,r,rp)
	local te=g:GetFirst().RunicEffect
	Duel.ConfirmCards(1-tp,g)
	Duel.ShuffleHand(tp)
	--copy effect
	e:SetProperty(EFFECT_FLAG2_RUNIC | te:GetProperty())
	local tg=te:GetTarget()
	if tg then tg(e,tp,eg,ep,ev,re,r,rp,1) end
	te:SetLabelObject(e:GetLabelObject())
	e:SetLabelObject(te)
	Duel.ClearOperationInfo(0)
end
function s.rop(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	if not te then return end
	e:SetLabelObject(te:GetLabelObject())
	local op=te:GetOperation()
	if op then op(e,tp,eg,ep,ev,re,r,rp) end
end