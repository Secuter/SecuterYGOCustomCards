--Wyrmwind Southern Wyvern
--Scripted by Secuter
local s,id=GetID()
s.Echo=true
if not ECHO_IMPORTED then Duel.LoadScript("proc_echo.lua") end
function s.initial_effect(c)
	c:EnableReviveLimit()
	--echo summon
	Echo.AddProcedure(c,s.efilter)
	--spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--material check
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(s.matcheck)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	--xyz atk
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_XMATERIAL)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(1200)
	e3:SetCondition(s.xyzcon)
	c:RegisterEffect(e3)
	--xyz attacks twice
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_XMATERIAL)
	e4:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
	e4:SetValue(1)
	e4:SetCondition(s.xyzcon)
	c:RegisterEffect(e4)
	--xyz negate
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetCategory(CATEGORY_DISABLE)
	e5:SetType(EFFECT_TYPE_XMATERIAL+EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_CHAINING)
	e5:SetCountLimit(1,{id,1})
	e5:SetCondition(s.negcon)
	e5:SetCost(s.negcost)
	e5:SetTarget(s.negtg)
	e5:SetOperation(s.negop)
	c:RegisterEffect(e5)
end
s.listed_series={0x220}
function s.efilter(c,sc,sumtype,tp)
	return c:IsAttribute(ATTRIBUTE_WIND,sc,sumtype,tp) and c:IsType(TYPE_XYZ,sc,sumtype,tp)
end
--mat check
function s.matcheck(e,c)
	e:GetLabelObject():SetLabelObject(e:GetHandler():GetMaterial():GetFirst())
end
--spsummon
function s.spfilter(c,e,tp,lv)
	return c:IsAttribute(ATTRIBUTE_WIND) and c:IsLevel(lv) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local oc=e:GetLabelObject()
	if chk==0 then return oc and c:HasEquip(oc) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp,oc:GetRank()) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_HAND)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local oc=e:GetLabelObject()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 or not oc or not c:HasEquip(oc) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil,e,tp,oc:GetRank())
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
--xyz attack
function s.xyzcon(e)
	return e:GetHandler():IsAttribute(ATTRIBUTE_WIND)
end
--xyz negate
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsAttribute(ATTRIBUTE_WIND) and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
		and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
end
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=c:GetOverlayGroup():Filter(Card.IsCode,nil,id)
	if chk==0 then return #g>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVEXYZ)
	local sg=g:Select(tp,1,1,nil)
	Duel.SendtoGrave(sg,REASON_COST)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateActivation(ev)
end