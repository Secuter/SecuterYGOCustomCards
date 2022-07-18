--Dark King's Forgotten Tome
--Scripted by Secuter
local s,id=GetID()
function s.initial_effect(c)
	local e1=Ritual.AddProcGreater(c,aux.FilterBoolFunction(Card.IsSetCard,0x205),nil,nil,nil,nil,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_DARK),s.stage2)
	--search
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_CUSTOM+id)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.thcon)
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	--event
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_END)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCondition(s.evcon)
	e3:SetOperation(s.evop)
	c:RegisterEffect(e3)
	e1:SetLabelObject(e3)
end
s.listed_series={0x205,0x230}
function s.stage2(mg,e,tp,eg,ep,ev,re,r,rp,tc)
	e:GetLabelObject():SetLabelObject(tc)
end
--search
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return re:GetHandler()==e:GetHandler()
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsAbleToRemove() end
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
function s.thfilter(c)
	return c:IsSetCard(0x230) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c.IsRunic and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.evcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabelObject()~=nil
end
function s.evop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	Duel.RaiseEvent(tc,EVENT_CUSTOM+id,e,0,tp,tp,0)
	e:SetLabelObject(nil)
end