--Lair or the Void Wanderer Drago
--Scripted by Secuter
if not SECUTER_IMPORTED then Duel.LoadScript("secuter_utility.lua") end
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--cannot activate monster effects
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(0,1)
	e2:SetValue(s.actlim)
	c:RegisterEffect(e2)
	--spsummon token
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(s.tktg)
	e3:SetOperation(s.tkop)
	c:RegisterEffect(e3)
end
function s.actlim(e,re,rp)
	local tp=e:GetHandlerPlayer()
	local rc=re:GetHandler()
	local attr=rc:GetAttribute()
	return re:IsActiveType(TYPE_MONSTER)
		and Duel.IsExistingMatchingCard(Card.IsAttribute,tp,LOCATION_MZONE,0,1,nil,attr)
		and not Duel.IsExistingMatchingCard(Card.IsAttribute,tp,0,LOCATION_MZONE,1,nil,attr)
end
--spsummon token
function s.checkattr(tp)
	local attr_all=0
    local i=0
    local attr=2^i
	while attr < ATTRIBUTE_ALL do
        local token_id = math.max(12344699-i-1, 12344691) -- specific attribute token or default one
		if Duel.IsPlayerCanSpecialSummonMonster(tp,token_id,SET_EXTERNAL_WORLDS,TYPES_TOKEN,0,0,1,RACE_FIEND,attr) then
			attr_all=attr_all | attr
		end
        -- next attribute
        i=i+1
		attr=2^i
	end
	return attr_all
end
function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local attr_all = s.checkattr(tp)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and attr_all>0 end
	local attr=Duel.AnnounceAttribute(tp,1,attr_all)
	e:SetLabel(attr)
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
function s.tkop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    local attr=e:GetLabel()
    local i=math.log(attr, 2)
    local token_id = math.max(12344699-i-1, 12344691) -- specific attribute token or default one
	if Duel.IsPlayerCanSpecialSummonMonster(tp,token_id,SET_EXTERNAL_WORLDS,TYPES_TOKEN,0,0,1,RACE_FIEND,attr) then
		-- I'm changing the attribute both before and after summon to work properly with Gozen Match
		local token=Duel.CreateToken(tp,token_id)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e1:SetValue(attr)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		token:RegisterEffect(e1)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e1:SetValue(attr)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		token:RegisterEffect(e1)
		Duel.SpecialSummonComplete()
	end
end
