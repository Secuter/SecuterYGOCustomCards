--Exchange Daemon of War
--Scripted by Secuter
if not EXCHANGE_IMPORTED then Duel.LoadScript("proc_exchange.lua") end
local s,id=GetID()
s.IsExchange=true
function s.initial_effect(c)
	Exchange.Enable(c,s,aux.FilterBoolFunctionEx(Card.IsLevelBelow,4))
	--cannot be battle target
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(s.target)
	c:RegisterEffect(e1)
	--spsummon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
s.listed_names={id}
--battle target
function s.target(e,c)
	return c~=e:GetHandler() and c:IsFaceup() and c.IsExchange
end
--spsummon
function s.spcon(e,tp,eg,ep,ev,re,r,rp,chk)
	local a=Duel.GetAttacker()
	local at=Duel.GetAttackTarget()
	return at and ((a:IsControler(tp) and a.IsExchange)
		or (at:IsControler(tp) and at:IsFaceup() and at.IsExchange))
end
function s.thfilter(c,e,tp)
	return c.IsExchange and not c:IsCode(id) and c:IsAbleToHand() and c:IsLocation(LOCATION_MZONE) and c:IsFaceup() and c:IsControler(tp) and c:IsCanBeEffectTarget(e)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local g=Group.CreateGroup()
	g:AddCard(Duel.GetAttacker())
	g:AddCard(Duel.GetAttackTarget())
	g=g:Filter(s.thfilter,nil,e,tp)
	if chkc then return g:IsContains(chkc) and s.thfilter(chkc,e,tp) end
	if chk==0 then return #g>0
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	local tc=nil
	if #g==1 then
		tc=g:GetFirst()
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
		tc=g:Select(tp,1,1,nil)
	end
	Duel.SetTargetCard(tc)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,tc,1,tp,LOCATION_MZONE)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc and tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,tp,REASON_EFFECT)>0 and Duel.GetOperatedGroup():GetFirst():IsLocation(LOCATION_HAND) then
		if Duel.SpecialSummon(c,SUMMON_TYPE_EXCHANGE,tp,tp,false,false,POS_FACEUP)~=0 then
			--gain atk
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(tc:GetAttack())
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
			c:RegisterEffect(e1)
			--battle target
			local a=Duel.GetAttacker()
			if tc~=a then
				if a:CanAttack() and not a:IsImmuneToEffect(e) then
					Duel.CalculateDamage(a,c)
				end
			end
		end
	end
end