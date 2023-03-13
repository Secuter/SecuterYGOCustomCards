--Armor S/T
--Scripted by Secuter
local s,id=GetID()
if not ARMOR_IMPORTED then Duel.LoadScript("proc_armor.lua") end
s.ArmorAtk=200
s.ArmorDef=200
s.IsArmor=true
function s.initial_effect(c)
	--Armor
	Armor.AddProcedure(c,s)
	local a3=Effect.CreateEffect(c)
	a3:SetDescription(aux.Stringid(id,1))
	a3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	a3:SetType(EFFECT_TYPE_XMATERIAL+EFFECT_TYPE_IGNITION)
	a3:SetRange(LOCATION_MZONE)
	a3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	a3:SetCountLimit(1,id)
	a3:SetCondition(Armor.Condition)
	a3:SetCost(s.spcost)
	a3:SetTarget(s.sptg)
	a3:SetOperation(s.spop)
	c:RegisterEffect(a3)
	--Ritual
	aux.AddRitualProcGreaterCode(c,12341511)
end
s.listed_names={12341511}

function s.spfilter(c,e,tp)
	return c:IsCode(12341511) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,true,true)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	Duel.Release(e:GetHandler(),REASON_COST)
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
		Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,true,true,POS_FACEUP)
	end
end