--Fluid Manipulation
--Scripted by Secuter
if not SECUTER_IMPORTED then Duel.LoadScript("secuter_utility.lua") end
local s,id=GetID()
function s.initial_effect(c)
	--Level Up
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.uptarget)
	e1:SetOperation(s.upactivate)
	c:RegisterEffect(e1)
	--Union
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.target)
	e2:SetOperation(s.activate)
	c:RegisterEffect(e2)
end
s.listed_series={SET_FLUID}

function s.shfilter(c,e,tp)
	return c:GetLevel()>0 and c:IsSetCard(SET_FLUID) and c:IsAbleToDeckOrExtraAsCost()
        and Duel.IsExistingMatchingCard(s.upfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp,c:GetLevel())
end
function s.upfilter(c,e,tp,lv)
	return c:IsSetCard(SET_FLUID) and c:IsCanBeSpecialSummoned(e,0,tp,true,true) and c:GetLevel()==lv+2
end
function s.uptarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.shfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
    local g=Duel.SelectMatchingCard(tp,s.shfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp):GetFirst()
	Duel.SendtoDeck(g,nil,0,REASON_COST)
    e:SetLabelObject(g)
end
function s.upactivate(e,tp,eg,ep,ev,re,r,rp)
	local tg=e:GetLabelObject()
	local lv=tg:GetLevel()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,s.upfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp,lv):GetFirst()
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,true,true,POS_FACEUP) then
		--Duel.SpecialSummon(tc,0,tp,tp,true,true,POS_FACEUP)
		tc:RegisterFlagEffect(tc:GetCode(),RESET_EVENT+0x16e0000,0,0)
        Duel.SpecialSummonComplete()
		tc:CompleteProcedure()
	end
end

function s.filter(c,g,e,tp)
	return c:GetLevel()>0 and c:IsSetCard(SET_FLUID) and g:CheckWithSumEqual(Card.GetLevel,c:GetLevel(),2,99) and c:IsCanBeSpecialSummoned(e,0,tp,true,true)
end
function s.rfilter(c)
	return c:GetLevel()>0 and c:IsSetCard(SET_FLUID) and c:IsAbleToDeckOrExtraAsCost()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local rg=Duel.GetMatchingGroup(s.rfilter,tp,LOCATION_MZONE,0,nil)
		return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,rg,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_MZONE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local rg=Duel.GetMatchingGroup(s.rfilter,tp,LOCATION_MZONE,0,nil)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,rg,e,tp):GetFirst()
	if g then
		Duel.ConfirmCards(1-tp,g)
		Duel.ShuffleHand(tp)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local sg=rg:SelectWithSumEqual(tp,Card.GetLevel,g:GetLevel(),2,99)
        Duel.SendtoDeck(sg,nil,0,REASON_COST)
        
        if g and Duel.SpecialSummonStep(g,0,tp,tp,true,true,POS_FACEUP) then
            g:RegisterFlagEffect(g:GetCode(),RESET_EVENT+0x16e0000,0,0)
            Duel.SpecialSummonComplete()
		end
	end
end
