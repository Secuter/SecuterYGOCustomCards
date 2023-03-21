--Worldless Rumble Dragon
--Scripted by Secuter
local s,id=GetID()
s.IsReunion=true
if not REUNION_IMPORTED then Duel.LoadScript("proc_reunion.lua") end
function s.initial_effect(c)
	c:EnableReviveLimit()
	Reunion.AddProcedure(c,s.rfilter,2,99,s.rcheck)
	--ATK
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.atktg)
	e1:SetValue(1000)
	c:RegisterEffect(e1)
	--send to gy
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DECKDES+CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.tgcon)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
	--search
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(s.thcon)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
s.listed_names={id}
s.listed_series={0x20F}
function s.rfilter(c,lc,sumtype,tp)
	return c:IsType(ATTRIBUTE_DARK,lc,sumtype,tp)
end
function s.ifilter(c,lc,sumtype,tp)
	return c:IsSetCard(0x20F,lc,sumtype,tp) and c:IsRace(RACE_DRAGON,lc,sumtype,tp)
end
function s.rcheck(g,lc,sumtype,tp)
	return g:IsExists(s.ifilter,1,nil,lc,sumtype,tp)
end
--ATK
function s.atktg(e,c)
	return c:GetOriginalLevel()==8 and c:IsSetCard(0x20F) and c:IsRace(RACE_DRAGON)
end
--send to gy
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_TYPE_REUNION
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,3) end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,3)
end
function s.filter(c)
	return c:IsLocation(LOCATION_GRAVE) and c:IsSetCard(0x20F)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.DiscardDeck(tp,3,REASON_EFFECT)
	local dg=Duel.GetOperatedGroup()
	local ct=dg:FilterCount(s.filter,nil)
	if ct>0 then		
		local g=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,0,LOCATION_ONFIELD,nil)
		if #g> 0 then
			local tg=g:Select(tp,1,ct,nil)
			if #tg>0 then
				Duel.SendtoGrave(g,REASON_EFFECT)
			end
		end
    end
end
--search
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==1
end
function s.thfilter(c)
	return c:IsSetCard(0x20F) and c:IsRace(RACE_DRAGON) and c:IsAbleToHand()
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
	end
end