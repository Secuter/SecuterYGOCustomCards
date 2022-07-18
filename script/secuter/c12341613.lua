--Demon Rival Blood Moon (FIELD)
--Scripted by Secuter
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--cannot activate effects
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(0,1)
	e2:SetCondition(s.accon1)
	e2:SetValue(s.aclimit)
	c:RegisterEffect(e2)
	--cannot target
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x216))
	e3:SetCondition(s.accon2)
	e3:SetValue(s.ctval)
	c:RegisterEffect(e3)
	--sum limit
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetRange(LOCATION_FZONE)
	e4:SetTargetRange(1,0)
	e4:SetTarget(s.splimit)
	c:RegisterEffect(e4)
	--spsummon
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,1))
	e6:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e6:SetType(EFFECT_TYPE_IGNITION)
	e6:SetRange(LOCATION_FZONE)
	e6:SetCountLimit(1,{id,1})
	e6:SetCondition(s.spcon2)
	e6:SetCost(s.spcost2)
	e6:SetTarget(s.sptg2)
	e6:SetOperation(s.spop2)
	c:RegisterEffect(e6)
end
s.listed_series={0x216}
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x216)
end
function s.accon1(e)
	return Duel.IsExistingMatchingCard(s.filter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
		and Duel.GetTurnPlayer()==e:GetHandler():GetControler() and Duel.IsMainPhase()
end
function s.aclimit(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER) and not re:GetHandler():IsLocation(LOCATION_ONFIELD)
end
function s.accon2(e)
	return Duel.GetTurnPlayer()~=e:GetHandler():GetControler()
end
function s.ctval(e,re,rp)
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and rp==1-e:GetHandlerPlayer()
end
function s.splimit(e,c,tp,sumtp,sumpos)
	return not c:IsAttribute(ATTRIBUTE_DARK)
end

function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsSummonLocation,LOCATION_EXTRA),tp,0,LOCATION_MZONE,1,nil)
		and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
function s.cfilter2(c,tp)
	return c:IsAttribute(ATTRIBUTE_DARK) and (c:IsControler(tp) or c:IsFaceup())
end
function s.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,s.cfilter2,1,true,nil,nil,tp) end
	local g=Duel.SelectReleaseGroupCost(tp,s.cfilter2,1,1,true,nil,nil,tp)
	Duel.Release(g,REASON_COST)
end
function s.spfilter2(c,e,tp)
	return c:IsSetCard(0x216) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end