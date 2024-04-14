--Rascal Ace Valkyrie
--Scripted by Secuter
if not SECUTER_IMPORTED then Duel.LoadScript("secuter_utility.lua") end
local s,id=GetID()
s.Wandering=true
function s.initial_effect(c)
	c:EnableReviveLimit()
    --wandering summon
    Wandering.AddProcedure({handler=c,script=s,id=id,ct=4,ev={EVENT_RELEASE,EVENT_DISCARD,EVENT_REMOVE},filter=s.check,opp=true})
    --to grave redirect
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	-- e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	-- e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.con)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
    --to deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_RELEASE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.tdcon)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
    local e3=e2:Clone()
	e3:SetCode(EVENT_DISCARD)
	c:RegisterEffect(e3)
    local e4=e2:Clone()
	e4:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e4)
end
--check
function s.check(c,e,tp,eg,ep,ev,re,r,rp)
    return c:IsControler(rp)
end

--to grave redirect
function s.con(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_WANDERING)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EFFECT_TO_GRAVE_REDIRECT)
	e1:SetTargetRange(0xff,0xff)
	e1:SetTarget(s.rmtg)
	e1:SetValue(LOCATION_REMOVED)
	e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
end
function s.rmtg(e,c)
    local tc=e:GetHandler()
    local r=c:GetReason()&(REASON_EFFECT|REASON_COST|REASON_ADJUST|REASON_LOST_TARGET|REASON_RULE)
    local re=c:GetReasonEffect()
    local rc
    if re then rc=re:GetHandler() else rc=c:GetReasonCard() end
    local field_id=(r)+(rc and rc:GetFieldID() or 0)*10000+(Duel.GetCurrentChain()*10000000)
    local label=tc:GetFlagEffectLabel(id)
    if not label then
        tc:RegisterFlagEffect(id+50,RESET_CHAIN,0,1)
    end
    tc:RegisterFlagEffect(id,RESET_PHASE|PHASE_END,0,1,field_id)
    --Debug.Message("c: "..c:GetCode().." r"..(re and "(effect)" or (rc and "(card)" or "(nil)"))..": "..aux.DecodeReason(r).." FieldID: "..tostring(field_id).." label: "..tostring(label).." chain: "..tostring(tc:GetFlagEffect(id+50)))
    return tc:GetFlagEffect(id+50)>0 and (not label or (field_id and label==field_id))
end

--to deck
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
    return rp~=tp
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsAbleToDeck() and chkc:IsControler(1-tp) end
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end