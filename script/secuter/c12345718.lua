--Eternal Storm Marauder
--Scripted by Secuter
if not SECUTER_IMPORTED then Duel.LoadScript("secuter_utility.lua") end
local s,id=GetID()
s.Wandering=true
function s.initial_effect(c)
	c:EnableReviveLimit()
    --wandering summon
    Wandering.AddProcedure(c,s,id,5,EVENT_SPSUMMON_SUCCESS,s.check,nil,nil,nil,true)
    --to grave
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.tgcon)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
	--disable
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.discon)
	e2:SetCost(s.discost)
	e2:SetTarget(s.distg)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
end
--check
function s.check(c,e,tp,eg,ep,ev,re,r,rp)
    return c:IsControler(rp)
end

--to grave
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_WANDERING)
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0 end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,0,LOCATION_MZONE)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(nil,1-tp,LOCATION_MZONE,0,nil)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TOGRAVE)
		local sg=g:Select(1-tp,1,1,nil)
		Duel.HintSelection(sg)
		Duel.SendtoGrave(sg,REASON_RULE,PLAYER_NONE,1-tp)
	end
end

--disable
function s.selfspcon(e,tp,eg,ep,ev,re,r,rp)
	local ch=ev-1
	if ch==0 or ep==tp then return false end
	local ch_player,ch_eff=Duel.GetChainInfo(ch,CHAININFO_TRIGGERING_PLAYER,CHAININFO_TRIGGERING_EFFECT)
	local ch_c=ch_eff:GetHandler()
	return ch_player==tp and ((ch_c:IsSetCard(SET_LABRYNTH) and not ch_c:IsCode(id))
		or (ch_c:GetOriginalType()==TYPE_TRAP and ch_eff:IsTrapEffect()))
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	local ch=ev-1
	if ch==0 or ep==tp or e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	local ch_player,ch_eff=Duel.GetChainInfo(ch,CHAININFO_TRIGGERING_PLAYER,CHAININFO_TRIGGERING_EFFECT)
	return ch_player==tp
end
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToExtraAsCost() end
	Duel.SendtoDeck(c,nil,0,REASON_COST)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsNegatableMonster,tp,0,LOCATION_MZONE,1,nil) end
		Duel.SetOperationInfo(0,CATEGORY_DISABLE,nil,1,tp,LOCATION_MZONE)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.GetMatchingGroup(Card.IsNegatableMonster,tp,0,LOCATION_MZONE,nil)
	if #sg>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		local tc=sg:Select(tp,1,1,nil):GetFirst()
		tc:NegateEffects(e:GetHandler(),RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	end
end