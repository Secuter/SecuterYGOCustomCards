--Titanium Hydra Link
--Scripted by Secuter
if not SECUTER_IMPORTED then Duel.LoadScript("secuter_utility.lua") end
local s,id=GetID()
function s.initial_effect(c)
	--link summon
	c:EnableReviveLimit()
	Link.AddProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_REPTILE),2)
    --sp summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--to hand
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(s.thcon2)
	e3:SetTarget(s.thtg2)
	e3:SetOperation(s.thop2)
	c:RegisterEffect(e3)
end
s.listed_series={SET_HYDRA}

function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	Duel.PayLPCost(tp,500)
end
function s.spfilter(c,e,tp,zone)
	return c:IsType(TYPE_MONSTER) and c:GetOverlayTarget():IsControler(tp) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,zone)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local zone=e:GetHandler():GetLinkedZone(tp)
	if chkc then return s.spfilter(chkc,e,tp,zone) end
	if chk==0 then return Duel.GetOverlayGroup(tp,1,1):IsExists(s.spfilter,1,nil,e,tp,zone) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.GetOverlayGroup(tp,1,1):FilterSelect(tp,s.spfilter,1,1,nil,e,tp,zone)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,nil)
	e:SetLabelObject(g:GetFirst())
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc then
        --Duel.RaiseSingleEvent(tc,EVENT_DETACH_MATERIAL,e,0,0,0,0)
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP,e:GetHandler():GetLinkedZone(tp))
	end
end

function s.thcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (c:GetReasonPlayer()~=tp and c:IsReason(REASON_EFFECT))	and c:IsPreviousPosition(POS_FACEUP)
end
function s.thfilter2(c)
	return c:IsSetCard(SET_HYDRA) and (c:IsType(TYPE_SPELL) or c:IsType(TYPE_TRAP)) and c:IsAbleToHand()
end
function s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.thop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter2,tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
