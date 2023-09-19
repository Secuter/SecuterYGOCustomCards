--External Worlds Hero WIND
--Scripted by Secuter
if not SECUTER_IMPORTED then Duel.LoadScript("secuter_utility.lua") end
local s,id=GetID()
function s.initial_effect(c)
	Pendulum.AddProcedure(c)
	--splimit
	local p1=Effect.CreateEffect(c)
	p1:SetType(EFFECT_TYPE_FIELD)
	p1:SetRange(LOCATION_PZONE)
	p1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	p1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
	p1:SetTargetRange(1,0)
	p1:SetTarget(s.splimit)
	c:RegisterEffect(p1)
	--atk/def up
	local p2=Effect.CreateEffect(c)
	p2:SetType(EFFECT_TYPE_FIELD)
	p2:SetRange(LOCATION_PZONE)
	p2:SetCode(EFFECT_UPDATE_ATTACK)
	p2:SetTargetRange(LOCATION_MZONE,0)
	p2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_EXTERNAL_WORLDS))
	p2:SetValue(200)
	c:RegisterEffect(p2)
    local p3=p2:Clone()
	p3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(p3)
	--spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--draw
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
end
s.listed_names={id}
s.listed_series={SET_EXTERNAL_WORLDS,SET_EXTERNAL_WORLDS_HERO}
function s.splimit(e,c,sump,sumtype,sumpos,targetp)
	return not c:IsSetCard(SET_EXTERNAL_WORLDS) and (sumtype&SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end

function s.thfilter(c,ft)
	return c:IsSetCard(SET_EXTERNAL_WORLDS) and c:IsFaceup() and not c:IsCode(id) and c:IsAbleToHand() and (ft>0 or c:IsLocation(LOCATION_MZONE))
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_EXTERNAL_WORLDS_HERO) and not c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
    local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and s.thfilter(chkc,ft)and chkc~=c end
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_ONFIELD,0,1,c,ft)
        and Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_ONFIELD,0,1,1,c,ft)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_HAND) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
        local tc=g:GetFirst()
        if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
            local c=e:GetHandler()
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_DISABLE)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD)
            tc:RegisterEffect(e1,true)
            local e2=Effect.CreateEffect(c)
            e2:SetType(EFFECT_TYPE_SINGLE)
            e2:SetCode(EFFECT_DISABLE_EFFECT)
            e2:SetReset(RESET_EVENT+RESETS_STANDARD)
            tc:RegisterEffect(e2,true)
        end
        Duel.SpecialSummonComplete()
	end
end

function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp,chk)
	Duel.Draw(tp,1,REASON_EFFECT)
end
