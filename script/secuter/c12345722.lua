--Erinyes Purgatory
--Scripted by Secuter
if not SECUTER_IMPORTED then Duel.LoadScript("secuter_utility.lua") end
local s,id=GetID()
s.Wandering=true
function s.initial_effect(c)
	c:EnableReviveLimit()
    --wandering summon
    Wandering.AddProcedure(c,s,id,4,EVENT_SPSUMMON_SUCCESS,s.check)
    --atk change
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.atkcon)
	e1:SetTarget(s.atktg)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
    --negate spsummon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_SPSUMMON)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.discon)
	e2:SetTarget(s.distg)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
end
--check
function s.check(c,e,tp,eg,ep,ev,re,r,rp)
    return c:IsControler(rp) and Duel.GetTurnPlayer()~=rp
end

--atk change
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_WANDERING)
end
function s.atkfilter(c)
	return c:IsFaceup() and c:HasDefense()
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.lvfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.atkfilter,tp,LOCATION_MZONE,0,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.atkfilter,tp,LOCATION_MZONE,0,1,1,c)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetCode(EFFECT_SET_ATTACK)
        e1:SetTargetRange(LOCATION_MZONE,0)
        e1:SetTarget(function(e,c) return c~=e:GetHandler() end)
        e1:SetValue(tc:GetAttack())
        e1:SetReset(RESET_PHASE|PHASE_END)
        Duel.RegisterEffect(e1,tp)
        local e2=e1:Clone()
        e2:SetCode(EFFECT_SET_DEFENSE)
        e2:SetValue(tc:GetDefense())
        Duel.RegisterEffect(e2,tp)
	end
end
function s.filter(e,c)
	return c:GetPreviousLocation()==LOCATION_REMOVED and c:IsSetCard(SET_EXTERNAL_WORLDS)
end

--negate spsummon
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return tp~=ep and Duel.GetCurrentChain()==0
end
function s.cfilter(c)
	return (c:IsMonster() or c:IsLocation(LOCATION_MZONE)) and c:IsAbleToDeck()
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chkc then return chkc:IsLocation(LOCATION_MZONE|LOCATION_GRAVE) and chkc:IsControler(tp) and s.cfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.cfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,3,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.cfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,3,3,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,#eg,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,#eg,0,0)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local td=tg:Filter(Card.IsRelateToEffect,nil,e)
	if not tg or #td<=0 then return end
	if Duel.SendtoDeck(td,nil,0,REASON_EFFECT) then
        local g=Duel.GetOperatedGroup()
        if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
        local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK|LOCATION_EXTRA)
        if ct>0 then
            Duel.NegateSummon(eg)
            Duel.Destroy(eg,REASON_EFFECT)
        end
    end
end