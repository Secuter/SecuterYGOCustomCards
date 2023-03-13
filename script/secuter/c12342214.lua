--Bulwark Champion Coliseum
--Scripted by Secuter
local s,id=GetID()
if not ARMOR_IMPORTED then Duel.LoadScript("proc_armor.lua") end
s.ArmorAtk=0
s.ArmorDef=0
s.IsArmor=true
function s.initial_effect(c)
	--Armor
	Armor.AddProcedure(c,s)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--add
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_XMATERIAL+EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_NO_TURN_RESET+EFFECT_FLAG2_ARMOR)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	--attach
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_ATTACH_ARMOR)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_CUSTOM+id)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,{id,1})
	e3:SetTarget(s.attg)
	e3:SetOperation(s.atop)
	c:RegisterEffect(e3)
	--summon register
	local g=Group.CreateGroup()
	g:KeepAlive()
	e3:SetLabelObject(g)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetRange(LOCATION_FZONE)
	e4:SetLabelObject(e3)
	e4:SetOperation(s.regop)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e5)
	local e6=e4:Clone()
	e6:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e6)
	--add
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(id,3))
	e7:SetCategory(CATEGORY_TOHAND)
	e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e7:SetCode(EVENT_SPSUMMON_SUCCESS)
	e7:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e7:SetRange(LOCATION_FZONE)
	e7:SetCountLimit(1,{id,2})
	e7:SetCondition(s.con)
	e7:SetTarget(s.thtg2)
	e7:SetOperation(s.thop2)
	c:RegisterEffect(e7)
	--destroy
	local e8=Effect.CreateEffect(c)
	e8:SetDescription(aux.Stringid(id,4))
	e8:SetCategory(CATEGORY_DESTROY)
	e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e8:SetCode(EVENT_SPSUMMON_SUCCESS)
	e8:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e8:SetRange(LOCATION_FZONE)
	e8:SetCountLimit(1,{id,2})
	e8:SetCondition(s.con)
	e8:SetTarget(s.destg)
	e8:SetOperation(s.desop)
	c:RegisterEffect(e8)
end
s.listed_series={0x21a}
function s.thcon(e)
	return Armor.Condition(e) and e:GetHandler():IsSetCard(0x21a)
end
function s.thfilter(c)
	return c:IsSetCard(0x21a) and c:IsRace(RACE_WARRIOR) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

function s.tgfilter(c,e,tp,chk)
	return c:IsRace(RACE_WARRIOR) and c:IsLocation(LOCATION_MZONE) and c:IsFaceup() and c:IsControler(tp) and c:IsCanBeEffectTarget(e)
		and (chk or Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_DECK,0,1,nil,c))
end
function s.cfilter(c,tc)
	return c:IsSetCard(0x21a) and c:IsType(TYPE_MONSTER) and Armor.AttachCheck(c,tc)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local tg=eg:Filter(s.tgfilter,nil,e,tp,false)
	if #tg>0 then
		for tc in aux.Next(tg) do
			tc:RegisterFlagEffect(id,RESET_CHAIN,0,1)
		end
		local g=e:GetLabelObject():GetLabelObject()
		if Duel.GetCurrentChain()==0 then g:Clear() end
		g:Merge(tg)
		g:Remove(function(c) return c:GetFlagEffect(id)==0 end,nil)
		e:GetLabelObject():SetLabelObject(g)
		if Duel.GetFlagEffect(tp,id)==0 then
			Duel.RegisterFlagEffect(tp,id,RESET_CHAIN,0,1)
			Duel.RaiseSingleEvent(e:GetHandler(),EVENT_CUSTOM+id,e,0,tp,tp,0)
		end
	end
end
function s.attg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=e:GetLabelObject():Filter(s.tgfilter,nil,e,tp,false)
	if chkc then return g:IsContains(chkc) and s.tgfilter(chkc,e,tp,true) end
	if chk==0 then 
		Duel.ResetFlagEffect(tp,id)
		for tc in aux.Next(g) do tc:ResetFlagEffect(id) end
		return #g>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 
	end
	if #g==1 then
		Duel.SetTargetCard(g:GetFirst())
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
		local tc=g:Select(tp,1,1,nil)
		Duel.SetTargetCard(tc)
	end
end
function s.atop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local tc=Duel.GetFirstTarget()
	if tc and  tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsControler(tp) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTACHARMOR)
		local sg=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_DECK,0,1,1,nil,tc)
		local ec=sg:GetFirst()
		if ec and Armor.AttachCheck(ec,tc) then
			Armor.Attach(tc,ec)
		end
	end
end

function s.con(e,tp,eg,ep,ev,re,r,rp)
	return eg:GetFirst():GetSummonPlayer()==tp and eg:GetFirst():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_TYPE_ARMORIZING
end
function s.thfilter2(c)
	return c:IsSetCard(0x21a) and not c:IsCode(id) and c:IsAbleToHand()
end
function s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfilter2(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.thfilter2,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local tg=Duel.SelectTarget(tp,s.thfilter2,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,tg,1,0,0)
end
function s.thop2(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local tg=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tg,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end