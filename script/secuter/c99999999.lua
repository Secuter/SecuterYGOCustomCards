-- CARD FOR TESTING PURPOSES ONLY, DO NOT USE IT IN A REAL DUEL --
-- Instant Summon
-- Scripted by Secuter
if not IGNITION_IMPORTED then Duel.LoadScript("proc_ignition.lua") end
if not ARMOR_IMPORTED then Duel.LoadScript("proc_armor.lua") end
if not REUNION_IMPORTED then Duel.LoadScript("proc_reunion.lua") end
local s,id=GetID()
function s.initial_effect(c)
	-- Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end

function s.spfilter(c,e,tp)
	return Duel.GetLocationCountFromEx(tp,tp,nil,c)>0 and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,ft,nil,e,tp)
	local tc=g:GetFirst()
	while tc do
		local st=0
		if tc:IsType(SUMMON_TYPE_FUSION) then st=SUMMON_TYPE_FUSION
		elseif tc:IsType(SUMMON_TYPE_SYNCHRO) then st=SUMMON_TYPE_SYNCHRO
		elseif tc:IsType(SUMMON_TYPE_XYZ) then st=SUMMON_TYPE_XYZ
		elseif tc:IsType(SUMMON_TYPE_LINK) then st=SUMMON_TYPE_LINK
		elseif tc.IsIgnition then st=SUMMON_TYPE_IGNITION
		elseif tc.IsArmorizing then st=SUMMON_TYPE_ARMORIZING
		elseif tc.IsReunion then st=SUMMON_TYPE_REUNION
		end
		Duel.SpecialSummon(tc,SUMMON_TYPE_REUNION,tp,tp,false,false,POS_FACEUP)
		tc:CompleteProcedure()
		tc=g:GetNext()
	end
end