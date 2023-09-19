--Fire Core Magic - Evolution
--Scripted by Secuter
if not SECUTER_IMPORTED then Duel.LoadScript("secuter_utility.lua") end
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	--to hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_DESTROYED)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_FIRE_CORE_MAGIC}

function s.desfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAttribute(ATTRIBUTE_FIRE) and (c:IsFaceup() or c:IsLocation(LOCATION_HAND))
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil)
        and Duel.IsPlayerCanDraw(tp,2) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_HAND+LOCATION_MZONE)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,s.desfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
	if #g>0 and Duel.Destroy(g,REASON_EFFECT)~=0 then
		Duel.Draw(tp,2,REASON_EFFECT)
	end
end

function s.resfilter(c)
    return c:IsAttribute(ATTRIBUTE_FIRE) and bit.band(c:GetReason(),REASON_DESTROY|REASON_EFFECT)==REASON_DESTROY|REASON_EFFECT
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.resfilter,1,nil)
end
function s.thfilter(c)
	return c:IsAbleToDeck() and c:IsSetCard(SET_FIRE_CORE_MAGIC) and (c:IsType(TYPE_SPELL) or c:IsType(TYPE_TRAP))
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and s.thfilter(chkc) end
    if chk==0 then return c:GetFlagEffect(id)==0 and e:GetHandler():IsAbleToHand()
        and Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,2,c) end
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,2,2,c)
	c:RegisterFlagEffect(id,RESET_CHAIN,0,1)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,2,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,2,REASON_EFFECT) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
