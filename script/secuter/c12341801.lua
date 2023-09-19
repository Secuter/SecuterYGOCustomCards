--Abyss Challenger Ghoul Captain
--Scripted by Secuter
if not SECUTER_IMPORTED then Duel.LoadScript("secuter_utility.lua") end
local s,id=GetID()
function s.initial_effect(c)
	--spsummon proc
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
    --gain ATK/DEF
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCode(EFFECT_UPDATE_ATTACK)
    e2:SetValue(s.value)
    c:RegisterEffect(e2)
    local e3=e2:Clone()
    e3:SetCode(EFFECT_UPDATE_DEFENSE)
    c:RegisterEffect(e3)
    --indes battle
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD)
    e4:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e4:SetRange(LOCATION_MZONE)
    e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetCondition(s.econ)
    e4:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_ABYSS_CHALLENGER))
    e4:SetValue(1)
    c:RegisterEffect(e4)
	--search
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,0))
	e5:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_REMOVE+CATEGORY_DRAW)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1,{id,1})
	e5:SetTarget(s.thtg)
	e5:SetOperation(s.thop)
	c:RegisterEffect(e5)
end
s.listed_names={id}
s.listed_series={SET_ABYSS_CHALLENGER}
function s.cfilter(c)
	return c:IsFacedown() and c:IsAbleToRemoveAsCost(POS_FACEDOWN)
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_EXTRA,0,2,nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,c)
	local rg=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_EXTRA,0,nil)
	local g=rg:RandomSelect(tp,2)
	if #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.Remove(g,POS_FACEDOWN,REASON_COST)
	g:DeleteGroup()
end

function s.value(e,c)
	return Duel.GetMatchingGroupCount(Card.IsFacedown,e:GetHandlerPlayer(),LOCATION_REMOVED,0,nil)*100
end

function s.econ(e,tp,eg,ep,ev,re,r,rp)
	if not tp then tp=e:GetHandlerPlayer() end
	return Duel.IsExistingMatchingCard(Card.IsFacedown,tp,LOCATION_REMOVED,0,15,nil)
end

function s.thfilter(c)
	return c:IsSetCard(SET_ABYSS_CHALLENGER) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
        and Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.rfilter(c)
	return c:IsSetCard(SET_ABYSS_CHALLENGER) and not c:IsCode(id)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
		Duel.ConfirmCards(1-tp,g)
        Duel.ShuffleHand(tp)
		local rg=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_HAND,0,1,1,nil)
		if #rg>0 and Duel.Remove(rg,POS_FACEDOWN,REASON_EFFECT)>0
            and Duel.IsExistingMatchingCard(aux.FaceupFilter(s.rfilter),tp,LOCATION_MZONE,0,1,nil) then
            Duel.BreakEffect()
            Duel.Draw(tp,1,REASON_EFFECT)
        end
	end
end
