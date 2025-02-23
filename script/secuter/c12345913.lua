--Arcaneblade Ward
--Scripted by Secuter
if not SECUTER_IMPORTED then Duel.LoadScript("secuter_utility.lua") end
local s,id=GetID()
function s.initial_effect(c)
	--negate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.cond)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--can be activated the turn it was Set
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2:SetCondition(s.actcon)
	c:RegisterEffect(e2)
end
--negate
function s.cond(e,tp,eg,ep,ev,re,r,rp)
    --Effetto di un mostro di Archetipo
	-- local chainlink=Duel.GetCurrentChain(true)-1
	-- if not (chainlink>0 and Duel.IsChainDisablable(ev) and ep==1-tp) then return false end
	-- local trig_p,setcodes=Duel.GetChainInfo(chainlink,CHAININFO_TRIGGERING_PLAYER,CHAININFO_TRIGGERING_SETCODES)
	-- if not trig_p==tp then return false end
	-- for _,set in ipairs(setcodes) do
	-- 	if (SET_ARCANEBLADE&0xfff)==(set&0xfff) and (SET_ARCANEBLADE&set)==SET_ARCANEBLADE then return true end
	-- end
    --Test per mostro Exchange
	local chainlink=Duel.GetCurrentChain(true)-1
	if not (chainlink>0 and Duel.IsChainDisablable(ev) and ep==1-tp) then return false end
	local trig_p,trig_e=Duel.GetChainInfo(chainlink,CHAININFO_TRIGGERING_PLAYER,CHAININFO_TRIGGERING_EFFECT)
    return trig_p==tp and trig_e:GetHandler():IsExchange()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateEffect(ev)
end
--activate
function s.actcon(e)
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_MZONE,0)==0
end