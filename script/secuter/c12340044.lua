--External Worlds Tree of the End
--Scripted by Secuter
if not SECUTER_IMPORTED then Duel.LoadScript("secuter_utility.lua") end
local s,id=GetID()
function s.initial_effect(c)
	c:EnableCounterPermit(0x306)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--add counter
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_REMOVE)
	e2:SetOperation(s.ctop)
	c:RegisterEffect(e2)
	--to hand
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,{id,1})
	e3:SetCost(s.thcost)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
	--additional Pendulum
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1,{id,2})
	e4:SetCondition(s.pscon)
	e4:SetCost(s.pscost)
	e4:SetOperation(s.psop)
	c:RegisterEffect(e4)
end
s.listed_series={SET_EXTERNAL_WORLDS,SET_EXTERNAL_WORLDS_LORD}
function s.filter(c)
	return c:IsSetCard(SET_EXTERNAL_WORLDS_LORD) and c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	if not Duel.CheckLocation(tp,LOCATION_PZONE,0) and not Duel.CheckLocation(tp,LOCATION_PZONE,1) then return end
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		local sg=g:Select(tp,1,1,nil)
		Duel.MoveToField(sg:GetFirst(),tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
--add counter
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(0x306,1)
end
--to hand
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x306,2,REASON_COST) end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
    e:GetHandler():RemoveCounter(tp,0x306,2,REASON_COST)
end
function s.thfilter(c)
	return c:IsSetCard(SET_EXTERNAL_WORLDS) and c:IsMonster() and c:IsAbleToHand() and c:IsFaceup()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_EXTRA,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_EXTRA)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
--additional Pendulum
function s.pscost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x306,6,REASON_COST) end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
    e:GetHandler():RemoveCounter(tp,0x306,6,REASON_COST)
end
function s.pscon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp,29432356)==0
end
function s.psop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetCode(EVENT_ADJUST)
	e1:SetOperation(s.checkop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.checkop(e,tp)
	local lpz=Duel.GetFieldCard(tp,LOCATION_PZONE,0)
	if lpz~=nil and lpz:GetFlagEffect(id)<=0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,4))
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_SPSUMMON_PROC_G)
		e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetRange(LOCATION_PZONE)
		e1:SetCondition(s.pencon)
		e1:SetOperation(s.penop)
		e1:SetValue(SUMMON_TYPE_PENDULUM)
		e1:SetReset(RESET_PHASE+PHASE_END)
		lpz:RegisterEffect(e1)
		lpz:RegisterFlagEffect(id,RESET_PHASE+PHASE_END,0,1)
	end
end
function s.pencon(e,c,og)
	if c==nil then return true end
	local tp=c:GetControler()
	local rpz=Duel.GetFieldCard(tp,LOCATION_PZONE,1)
	if rpz==nil or c==rpz or Duel.GetFlagEffect(tp,29432356)>0 then return false end
	local lscale=c:GetLeftScale()
	local rscale=rpz:GetRightScale()
	if lscale>rscale then lscale,rscale=rscale,lscale end
	local loc=0
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then loc=loc+LOCATION_HAND end
	if Duel.GetLocationCountFromEx(tp)>0 then loc=loc+LOCATION_EXTRA end
	if loc==0 then return false end
	local g=nil
	if og then
		g=og:Filter(Card.IsLocation,nil,loc)
	else
		g=Duel.GetFieldGroup(tp,loc,0)
	end
	return g:IsExists(Pendulum.Filter,1,nil,e,tp,lscale,rscale)
end
function s.penop(e,tp,eg,ep,ev,re,r,rp,c,sg,og)
	local rpz=Duel.GetFieldCard(tp,LOCATION_PZONE,1)
	local lscale=c:GetLeftScale()
	local rscale=rpz:GetRightScale()
	if lscale>rscale then lscale,rscale=rscale,lscale end
	local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local ft2=Duel.GetLocationCountFromEx(tp)
	local ft=Duel.GetUsableMZoneCount(tp)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then
		if ft1>0 then ft1=1 end
		if ft2>0 then ft2=1 end
		ft=1
	end
	local loc=0
	if ft1>0 then loc=loc+LOCATION_HAND end
	if ft2>0 then loc=loc+LOCATION_EXTRA end
	local tg=nil
	if og then
		tg=og:Filter(Card.IsLocation,nil,loc):Filter(Pendulum.Filter,nil,e,tp,lscale,rscale)
	else
		tg=Duel.GetMatchingGroup(Pendulum.Filter,tp,loc,0,nil,e,tp,lscale,rscale)
	end
	ft1=math.min(ft1,tg:FilterCount(Card.IsLocation,nil,LOCATION_HAND))
	ft2=math.min(ft2,tg:FilterCount(Card.IsLocation,nil,LOCATION_EXTRA))
	ft2=math.min(ft2,aux.CheckSummonGate(tp) or ft2)
	while true do
		local ct1=tg:FilterCount(Card.IsLocation,nil,LOCATION_HAND)
		local ct2=tg:FilterCount(Card.IsLocation,nil,LOCATION_EXTRA)
		local ct=ft
		if ct1>ft1 then ct=math.min(ct,ft1) end
		if ct2>ft2 then ct=math.min(ct,ft2) end
		local loc=0
		if ft1>0 then loc=loc+LOCATION_HAND end
		if ft2>0 then loc=loc+LOCATION_EXTRA end
		local g=tg:Filter(Card.IsLocation,sg,loc)
		if #g==0 or ft==0 then break end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tc=Group.SelectUnselect(g,sg,tp,true,true)
		if not tc then break end
		if sg:IsContains(tc) then
				sg:RemoveCard(tc)
				if tc:IsLocation(LOCATION_HAND) then
				ft1=ft1+1
			else
				ft2=ft2+1
			end
			ft=ft+1
		else
			sg:AddCard(tc)
			if tc:IsLocation(LOCATION_HAND) then
				ft1=ft1-1
			else
				ft2=ft2-1
			end
			ft=ft-1
		end
	end
	if #sg>0 then
		Duel.Hint(HINT_CARD,0,id)
		Duel.RegisterFlagEffect(tp,29432356,RESET_PHASE+PHASE_END+RESET_SELF_TURN,0,1)
		Duel.HintSelection(Group.FromCards(c))
		Duel.HintSelection(Group.FromCards(rpz))
	end
end
