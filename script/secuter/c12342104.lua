--Destiny HERO
--Scripted by Secuter
if not SECUTER_IMPORTED then Duel.LoadScript("secuter_utility.lua") end
local s,id=GetID()
s.Reunion=true
function s.initial_effect(c)
	c:EnableReviveLimit()
	Reunion.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_DESTINY_HERO),2,99)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
end

function s.spfilter(c,e,tp,lv,cid)
	return c:IsLevel(lv) and c:IsSetCard(SET_DESTINY_HERO) and not c:IsCode(cid) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.tgfilter(c,e,tp)
	return c:IsSetCard(SET_DESTINY_HERO) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
        and Duel.IsExistingMatchingCard(s.spfilter,e:GetHandlerPlayer(),LOCATION_GRAVE,0,1,nil,e,tp,c:GetLevel(),c:GetCode())
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
        and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
        Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
        Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_GRAVE) then
        local tg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,tc:GetLevel(),tc:GetCode())
		Duel.SpecialSummon(tg,0,tp,tp,false,false,POS_FACEUP)
    end
end
