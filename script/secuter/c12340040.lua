--External Worlds Lord DARK
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
	--spsummon itself from PZ
	local p2=Effect.CreateEffect(c)
	p2:SetDescription(aux.Stringid(id,0))
	p2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	p2:SetType(EFFECT_TYPE_IGNITION)
	p2:SetRange(LOCATION_PZONE)
	p2:SetCountLimit(1,id)
	p2:SetCondition(s.con)
	p2:SetTarget(s.tg)
	p2:SetOperation(s.op)
	c:RegisterEffect(p2)
	--to pendulum/extra
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_TOEXTRA)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,{id,1})
	e1:SetTarget(s.tptg)
	e1:SetOperation(s.tpop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	--attack limit
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_HAND)
	e4:SetHintTiming(TIMING_DAMAGE_STEP,TIMING_DAMAGE_STEP+TIMINGS_CHECK_MONSTER)
	e4:SetCountLimit(1,{id,2})
	e4:SetCost(aux.bfgcost)
	e4:SetTarget(s.atktg)
	e4:SetOperation(s.atkop)
	c:RegisterEffect(e4)
end
s.listed_names={id}
s.listed_series={SET_EXTERNAL_WORLDS}
function s.splimit(e,c,sump,sumtype,sumpos,targetp)
	return not c:IsSetCard(SET_EXTERNAL_WORLDS) and (sumtype&SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end
--spsummon itself from PZ
function s.filter(c)
	return c:IsSetCard(SET_EXTERNAL_WORLDS) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsFaceup()
end
function s.con(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.filter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,true,POS_FACEUP_DEFENSE) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then 
		Duel.SpecialSummon(c,0,tp,tp,false,true,POS_FACEUP_DEFENSE)
	end
end
--to pendulum/extra
function s.tpfilter(c)
	return c:IsSetCard(SET_EXTERNAL_WORLDS) and c:IsMonster() and c:IsType(TYPE_PENDULUM) and not c:IsCode(id) and (c:IsAbleToExtra() or not c:IsForbidden())
end
function s.rescon(sg,e,tp,mg)
	return sg:GetClassCount(Card.GetCode)==#sg and sg:IsExists(Card.IsAbleToExtra,1,nil) and sg:IsExists(aux.NOT(Card.IsForbidden),1,nil)
end
function s.tptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.tpfilter,tp,LOCATION_DECK,0,nil)
	if chk==0 then return aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,0)
		and (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)) end
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,nil,1,tp,LOCATION_DECK)
end
function s.tpop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.CheckLocation(tp,LOCATION_PZONE,0) and not Duel.CheckLocation(tp,LOCATION_PZONE,1) then return end
	local g=Duel.GetMatchingGroup(s.tpfilter,tp,LOCATION_DECK,0,nil)
	local sg=aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,1,tp,HINTMSG_SELECT)
	if #sg>=2 then
		Duel.ConfirmCards(1-tp,sg)
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TOFIELD)
		local cg=sg:Select(1-tp,1,1,nil)
		local tc=cg:GetFirst()
		Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true) --to pendulum
		sg:RemoveCard(tc)
		Duel.SendtoExtraP(sg,tp,REASON_EFFECT) --to extra
	end
end
--give atk
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c:IsSetCard(SET_EXTERNAL_WORLDS) and c:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(aux.FaceupFilter(Card.IsSetCard,SET_EXTERNAL_WORLDS),tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,aux.FaceupFilter(Card.IsSetCard,SET_EXTERNAL_WORLDS),tp,LOCATION_MZONE,0,1,1,nil)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
		e1:SetRange(LOCATION_MZONE)
		e1:SetTargetRange(0,LOCATION_MZONE)
		e1:SetValue(s.altg)
        e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
        tc:RegisterEffect(e1,true)
	end
end
function s.altg(e,c)
	return c~=e:GetHandler() and c:IsFaceup() and c:IsSetCard(SET_EXTERNAL_WORLDS)
end
