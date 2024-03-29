--Fluid Decomposition
--Scripted by Secuter
if not SECUTER_IMPORTED then Duel.LoadScript("secuter_utility.lua") end
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_FLUID}
function s.rfilter(c,e,tp)
     return c:GetLevel()>0 and c:IsSetCard(SET_FLUID) and c:IsCanBeSpecialSummoned(e,0,tp,true,true)
end
function s.filter(c,e,tp)
    local ct=Duel.GetLocationCount(tp,LOCATION_MZONE)+1
    if ct<2 then return false end
	local g=Duel.GetMatchingGroup(s.rfilter,tp,LOCATION_HAND+LOCATION_DECK,0,nil,e,tp)
	return c:GetLevel()>0 and c:IsSetCard(SET_FLUID) and c:IsAbleToDeckOrExtraAsCost()
        and g:CheckWithSumEqual(Card.GetLevel,c:GetLevel(),2,ct)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil,e,tp)
        and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,tp,LOCATION_MZONE)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_HAND+LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
        local lv=tc:GetLevel()
        if Duel.SendtoDeck(tc,nil,0,REASON_COST)>0 then
            local rg=Duel.GetMatchingGroup(s.rfilter,tp,LOCATION_HAND+LOCATION_DECK,0,nil,e,tp)
            Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
            local ct=Duel.GetLocationCount(tp,LOCATION_MZONE)+1
            if ct<2 or Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return end
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
            local g=rg:SelectWithSumEqual(tp,Card.GetLevel,lv,2,ct)
            local tc=g:GetFirst()
            while tc do
                if Duel.SpecialSummonStep(tc,0,tp,tp,true,true,POS_FACEUP) then
                    tc:RegisterFlagEffect(tc:GetCode(),RESET_EVENT+0x16e0000,0,0)
                    Duel.SpecialSummonComplete()
                    tc=g:GetNext()
                end
            end
        end
    end
end--Fluid Decomposition
--Scripted by Secuter
if not SECUTER_IMPORTED then Duel.LoadScript("secuter_utility.lua") end
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_FLUID}
function s.rfilter(c,e,tp)
     return c:GetLevel()>0 and c:IsSetCard(SET_FLUID) and c:IsCanBeSpecialSummoned(e,0,tp,true,true)
end
function s.filter(c,e,tp)
    local ct=Duel.GetLocationCount(tp,LOCATION_MZONE)+1
    if ct<2 then return false end
	local g=Duel.GetMatchingGroup(s.rfilter,tp,LOCATION_HAND+LOCATION_DECK,0,nil,e,tp)
	return c:GetLevel()>0 and c:IsSetCard(SET_FLUID) and c:IsAbleToDeckOrExtraAsCost()
        and g:CheckWithSumEqual(Card.GetLevel,c:GetLevel(),2,ct)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil,e,tp)
        and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,tp,LOCATION_MZONE)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_HAND+LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
        local lv=tc:GetLevel()
        if Duel.SendtoDeck(tc,nil,0,REASON_COST)>0 then
            local rg=Duel.GetMatchingGroup(s.rfilter,tp,LOCATION_HAND+LOCATION_DECK,0,nil,e,tp)
            Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
            local ct=Duel.GetLocationCount(tp,LOCATION_MZONE)+1
            if ct<2 or Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return end
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
            local g=rg:SelectWithSumEqual(tp,Card.GetLevel,lv,2,ct)
            local tc=g:GetFirst()
            while tc do
                if Duel.SpecialSummonStep(tc,0,tp,tp,true,true,POS_FACEUP) then
                    tc:RegisterFlagEffect(tc:GetCode(),RESET_EVENT+0x16e0000,0,0)
                    Duel.SpecialSummonComplete()
                    tc=g:GetNext()
                end
            end
        end
    end
end

