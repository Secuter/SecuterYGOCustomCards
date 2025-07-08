--Dark Sovereign Butcher
--Scripted by Secuter
if not SECUTER_IMPORTED then Duel.LoadScript("secuter_utility.lua") end
local s,id=GetID()
s.Runic=true
function s.initial_effect(c)
	--atk
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetOperation(s.regop)
	c:RegisterEffect(e1)
    --spsummon itself
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.spcon)
	e2:SetCost(Cost.Discard(function(c) return c:IsAttribute(ATTRIBUTE_DARK) and c:IsMonster() end,true))
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--runic effect
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,{id,1})
	e3:SetCost(s.rcost)
	e3:SetTarget(s.rtg)
	e3:SetOperation(s.rop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
	local e5=e3:Clone()
	e5:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e5)
	--to hand
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,3))
	e6:SetCategory(CATEGORY_TOHAND)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e6:SetCode(EVENT_CHAINING)
	e6:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e6:SetRange(LOCATION_GRAVE)
	e6:SetCountLimit(1,{id,2})
	e6:SetCondition(s.thcon)
	e6:SetTarget(s.thtg)
	e6:SetOperation(s.thop)
	c:RegisterEffect(e6)
end
s.listed_series={SET_DARK_SOVEREIGN}

--atk
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_SET_ATTACK_FINAL)
	e6:SetValue(1000)
	e6:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
	c:RegisterEffect(e6)
end

--spsummon itself
function s.cfilter(c)
	return c:IsFacedown() or not c:IsAttribute(ATTRIBUTE_DARK)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end

--runic effect
function s.rcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
function s.rfilter(c,e,tp,eg,ep,ev,re,r,rp)
	if c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsRunic() and c:IsAbleToGraveAsCost() then
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
        return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=5
	end
	e:SetLabel(0)
	--cost
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<5 then return end
	Duel.ConfirmDecktop(tp,5)
	local g=Duel.GetDecktopGroup(tp,5)
	if g:IsExists(s.rfilter,1,nil,e,tp,eg,ep,ev,re,r,rp) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local sg=g:FilterSelect(tp,s.rfilter,1,1,nil,e,tp,eg,ep,ev,re,r,rp)
	    local te=sg:GetFirst().RunicEffect
	    Duel.SendtoGrave(sg,REASON_COST)
        --copy effect
        e:SetProperty(EFFECT_FLAG2_RUNIC | te:GetProperty())
        local tg=te:GetTarget()
        if tg then tg(e,tp,eg,ep,ev,re,r,rp,1) end
        te:SetLabelObject(e:GetLabelObject())
        e:SetLabelObject(te)
        e:SetProperty(e:GetProperty()|EFFECT_FLAG2_RUNIC)
        Duel.ClearOperationInfo(0)
	end
	Duel.ShuffleDeck(tp)
end
function s.rop(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	if not te then return end
	e:SetLabelObject(te:GetLabelObject())
	local op=te:GetOperation()
	if op then op(e,tp,eg,ep,ev,re,r,rp) end
end

--to hand
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==tp and re and re:IsHasProperty(EFFECT_FLAG2_RUNIC) and not re:GetHandler():IsCode(id)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end