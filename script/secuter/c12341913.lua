--Elite Geartron Disintegrator
--Scripted by Secuter
if not SECUTER_IMPORTED then Duel.LoadScript("secuter_utility.lua") end
local s,id=GetID()
function s.initial_effect(c)
	--cannot special summon
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	--summon with 3 tributes
	local e2=aux.AddNormalSummonProcedure(c,true,false,3,3,SUMMON_TYPE_TRIBUTE,aux.Stringid(id,0))
	local e3=aux.AddNormalSetProcedure(c,true,false,3,3,SUMMON_TYPE_TRIBUTE,aux.Stringid(id,0))
	--indes effect
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(s.trcon)
    e4:SetValue(s.efilter)
	c:RegisterEffect(e4)
	--cannot be banished
	local e5=e4:Clone()
	e5:SetCode(EFFECT_CANNOT_REMOVE)
	c:RegisterEffect(e5)
	--cannot be tributed
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_UNRELEASABLE_SUM)
	e6:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCondition(s.trcon)
    e6:SetValue(s.relfilter)
	c:RegisterEffect(e6)
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_FIELD)
	e7:SetCode(EFFECT_CANNOT_RELEASE)
	e7:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e7:SetRange(LOCATION_MZONE)
	e7:SetTargetRange(0,1)
	e7:SetCondition(s.trcon)
	e7:SetTarget(s.relval)
	e7:SetValue(1)
	c:RegisterEffect(e7)
	--attack all
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_SINGLE)
	e8:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e8:SetCode(EFFECT_ATTACK_ALL)
	e8:SetRange(LOCATION_MZONE)
	e4:SetCondition(s.trcon)
	e8:SetValue(1)
	c:RegisterEffect(e8)
	--sp tokens
	local e9=Effect.CreateEffect(c)
	e9:SetDescription(aux.Stringid(id,0))
	e9:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e9:SetType(EFFECT_TYPE_IGNITION)
	e9:SetRange(LOCATION_HAND)
	e9:SetCountLimit(1,id)
	e9:SetCost(s.tkcost)
	e9:SetTarget(s.tktg)
	e9:SetOperation(s.tkop)
	c:RegisterEffect(e9)
	--search
	local e10=Effect.CreateEffect(c)
	e10:SetDescription(aux.Stringid(id,1))
	e10:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e10:SetType(EFFECT_TYPE_QUICK_O)
	e10:SetCode(EVENT_FREE_CHAIN)
	e10:SetRange(LOCATION_MZONE)
	e10:SetCountLimit(1,{id,1})
	e10:SetCost(s.thcost)
	e10:SetTarget(s.thtg)
	e10:SetOperation(s.thop)
	c:RegisterEffect(e10)
	--to grave
	local e11=Effect.CreateEffect(c)
	e11:SetDescription(aux.Stringid(id,2))
	e11:SetCategory(CATEGORY_TOGRAVE)
	e11:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e11:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e11:SetCode(EVENT_RELEASE)
	e11:SetCountLimit(1,{id,2})
	e11:SetCondition(s.tgcon)
	e11:SetTarget(s.tgtg)
	e11:SetOperation(s.tgop)
	c:RegisterEffect(e11)
	local e12=e11:Clone()
	e12:SetCode(EVENT_LEAVE_FIELD)
	e12:SetCondition(s.tgcon2)
	c:RegisterEffect(e12)
end
s.listed_names={id}
s.listed_series={SET_GEARTRON}
TOKEN_GEARTRON=12341999

function s.trcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_TRIBUTE)
end
function s.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end
function s.relval(e,c)
	return c==e:GetHandler()
end
function s.relfilter(e,te)
	return te and e and te:GetHandlerPlayer()~=e:GetHandlerPlayer()
end

--sp tokens
function s.tkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,s.cfilter,1,nil) end
	local g=Duel.SelectReleaseGroupCost(tp,s.cfilter,1,1,nil)
	Duel.Release(g,REASON_COST)
end
function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>1 and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) 
		and Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_GEARTRON,0,TYPES_TOKEN,100,100,2,RACE_MACHINE,ATTRIBUTE_EARTH)end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,0)
end
function s.tkop(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft>1 and Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	if ft<2 then return end
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_GEARTRON,0,TYPES_TOKEN,100,100,2,RACE_MACHINE,ATTRIBUTE_EARTH) then return end
	for i=1,2 do
		local token=Duel.CreateToken(tp,TOKEN_GEARTRON)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
	end
	Duel.SpecialSummonComplete()
end
--search
function s.cfilter(c)
	return c:IsRace(RACE_MACHINE) and c:IsReleasable()
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,s.cfilter,1,true,nil,nil) end
	local g=Duel.SelectReleaseGroupCost(tp,s.cfilter,1,1,true,nil,nil)
	Duel.Release(g,REASON_COST)
end
function s.thfilter(c)
	return c:IsSetCard(SET_GEARTRON) and c:IsAbleToHand() and c:GetCode()~=id
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
--to grave
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_TRIBUTE) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEUP)
end
function s.tgcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsSummonType(SUMMON_TYPE_TRIBUTE) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEUP)
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,0,LOCATION_ONFIELD,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,#g,0,0)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,0,LOCATION_ONFIELD,nil)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end