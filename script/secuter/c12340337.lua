--Dark King's Offering
--Scripted by Secuter
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	--Ritual.AddProcGreater(c,aux.FilterBoolFunction(Card.IsSetCard,0x205),nil,nil,nil,nil,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_DARK),nil,LOCATION_GRAVE+LOCATION_HAND)
	Ritual.AddProcGreater({handler=c,filter=aux.FilterBoolFunction(Card.IsSetCard,0x205),matfilter=aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_DARK),location=LOCATION_HAND|LOCATION_GRAVE})
	--to hand
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_TODECK)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
s.listed_names={id}
s.listed_series={0x205}
function s.thfilter(c)
	return c:IsSetCard(0x205) and c:IsType(TYPE_MONSTER) and c:IsFaceup() and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_REMOVED) and s.thfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_REMOVED,0,1,nil)
		and e:GetHandler():IsAbleToDeck() end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,LOCATION_REMOVED)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	if tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 and c and c:IsRelateToEffect(e) then
		Duel.SendtoDeck(c,nil,1,REASON_EFFECT)
	end
end