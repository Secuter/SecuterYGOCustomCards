--Cracking Lord
--Scripted by Secuter
if not SECUTER_IMPORTED then Duel.LoadScript("secuter_utility.lua") end
local s,id=GetID()
function s.initial_effect(c)
	--link summon
	c:EnableReviveLimit()
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_DARK),3,nil,s.matcheck)
	--disable zones
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_FORCE_MZONE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetTargetRange(1,0)
	e1:SetValue(s.znval)
	c:RegisterEffect(e1)
	--indes effect
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	--cannot be banished
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_REMOVE)
	c:RegisterEffect(e3)
	--cannot be link material
	local e4=e2:Clone()
	e4:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	c:RegisterEffect(e4)
	--cannot be fusion material
	local e5=e2:Clone()
	e5:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
	c:RegisterEffect(e5)
	--negate
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,0))
	e6:SetCategory(CATEGORY_NEGATE)
	e6:SetType(EFFECT_TYPE_QUICK_F)
	e6:SetCode(EVENT_CHAINING)
	e6:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCondition(s.negcon)
	e6:SetTarget(s.negtg)
	e6:SetOperation(s.negop)
	c:RegisterEffect(e6)
	--register last effect
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(id,0))
	e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e7:SetCode(EVENT_CHAINING)
	e7:SetRange(LOCATION_ALL)
	e7:SetCondition(s.regcon)
	e7:SetOperation(s.regop)
	c:RegisterEffect(e7)
	--spsummon
	local e8=Effect.CreateEffect(c)
	e8:SetDescription(aux.Stringid(id,1))
	e8:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e8:SetProperty(EFFECT_FLAG_DELAY)
	e8:SetCode(EVENT_TO_GRAVE)
	e8:SetCountLimit(1,id)
	e8:SetCondition(s.spcon)
	e8:SetTarget(s.sptg)
	e8:SetOperation(s.spop)
	c:RegisterEffect(e8)
end
s.listed_names={id}
s.listed_series={SET_CRACKING}
s.material_setcode={SET_CRACKING}
function Card.IsCracking(c,tc,sumtype,tp) return c:IsSetCard(SET_CRACKING,tc,sumtype,tp) or c:IsCode(60349525) or c:IsCode(32835363) or c:IsCode(98864751) end
function Card.IsCrackingOrWyvern(c,tc,sumtype,tp) return c:IsSetCard(SET_CRACKING,tc,sumtype,tp) or c:IsCode(60349525) or c:IsCode(32835363) or c:IsCode(98864751) or c:IsCode(23850421) end
--material
function s.matcheck(g,lc,sumtype,tp)
	return g:IsExists(Card.IsCracking,1,nil,lc,sumtype,tp)
end
--disable zones
function s.znval(e)
	return ~(e:GetHandler():GetLinkedZone()&0x60)
end
--negate
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	return rp~=tp and Duel.IsChainNegatable(ev) and re:IsActiveType(Duel.GetFlagEffectLabel(tp,id) or 0)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)	
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateActivation(ev)
end
--register
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	return rp~=tp and not re:IsActiveType(EFFECT_TYPE_CONTINUOUS)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	--Duel.RegisterFlagEffect(int player, int code, int reset_flag, int property, int reset_count[, int label = 0])
	Duel.ResetFlagEffect(tp,id)
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1,(re:GetActiveType()&(TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP)))
end
--spsummon
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function s.spfilter(c,e,tp)
	return c:IsCracking() and not c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
