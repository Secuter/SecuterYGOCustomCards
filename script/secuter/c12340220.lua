--Fluid Reunion
--Scripted by Secuter
if not SECUTER_IMPORTED then Duel.LoadScript("secuter_utility.lua") end
local s,id=GetID()
s.Reunion=true
function s.initial_effect(c)
	c:EnableReviveLimit()
	Reunion.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_FLUID),2,99)
    --Reunion.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_FLUID),8,2,99)
    --to deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_series={SET_FLUID}

function s.cfilter(c,tp,sc)
    return (c:IsFaceup() or not c:IsLocation(LOCATION_MZONE))
        and c:IsSetCard(SET_FLUID) and c:GetLevel()>0 and c:IsAbleToDeckOrExtraAsCost()
        and Duel.IsExistingMatchingCard(s.tfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,c,c:GetLevel(),sc)
end
function s.tdfilter(c,lvl)
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsType(TYPE_MONSTER) and c:IsLevelBelow(lvl) and c:IsAbleToDeck()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE+LOCATION_HAND,0,1,c,tp,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE+LOCATION_HAND,0,1,1,c,tp,c)
	Duel.SendtoDeck(g,nil,2,REASON_COST)
	e:SetLabel(g:GetFirst():GetLevel())
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return s.tfilter(chkc,lvl) and chkc:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) end
	if chk==0 then return Duel.IsExistingTarget(s.tdfilter,tp,0,LOCATION_MZONE+LOCATION_GRAVE,1,e:GetHandler(),lvl) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,0,LOCATION_MZONE+LOCATION_GRAVE,1,1,e:GetHandler(),lvl)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SendtoDeck(tc,nil,2,REASON_EFFECT)
    end
end
