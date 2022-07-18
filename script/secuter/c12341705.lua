--Summoner of Felgrand
--Scripted by Secuter
local s,id=GetID()
function s.initial_effect(c)
	Link.AddProcedure(c,s.matfilter,1,1)
	c:EnableReviveLimit()
	--indes
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e1:SetCondition(s.incon)
	e1:SetCountLimit(1)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--equip
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCountLimit(1,id)
	e2:SetCondition(aux.zptcon(Card.IsFaceup))
	e2:SetTarget(s.eqtg)
	e2:SetOperation(s.eqop)
	c:RegisterEffect(e2)
	--aux.AddEREquipLimit(c,nil,s.eqval,s.equipop,e2)
end
function s.efilter(c)
	return c:IsRace(RACE_DRAGON) and c:IsType(TYPE_EQUIP)
end
function s.matfilter(c,lc,sumtype,tp)
	return c:GetEquipGroup():IsExists(s.efilter,1,nil)
end
function s.incon(e)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end

function s.eqfilter(c)
	return c:IsRace(RACE_DRAGON) and (c:GetLevel()==7 or c:GetLevel()==8) and not c:IsForbidden()
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_DECK)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=c:GetLinkedGroup()
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or not g then return end
	local c=g:GetFirst()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local sg=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_DECK,0,1,1,nil,c)
	local tc=sg:GetFirst()
	if Duel.Equip(tp,tc,c,true) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+0x1fe0000)
		e1:SetValue(s.eqlimit)
		tc:RegisterEffect(e1)
	end
end
function s.eqlimit(e,c)
	return e:GetOwner()==c
end
function s.equipop(c,e,tp,tc)
	aux.EquipByEffectAndLimitRegister(c,e,tp,tc,nil,true)
end