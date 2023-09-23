--Worm Hydra
--Scripted by Secuter
if not SECUTER_IMPORTED then Duel.LoadScript("secuter_utility.lua") end
local s,id=GetID()
function s.initial_effect(c)
	c:EnableUnsummonable()
	--spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
    e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--cannot be xyz
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	e2:SetValue(s.xyzlimit)
	c:RegisterEffect(e2)
end
s.listed_series={SET_HYDRA}

function s.spfilter(c,e)
	return c:IsSetCard(SET_HYDRA) and c:IsRace(RACE_REPTILE) and c:GetLevel()>0
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.spfilter,1,nil) and eg:GetFirst():IsControler(tp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		local tc
		if #eg==1 then
			tc=eg:GetFirst()
			Duel.HintSelection(tc)
		else
			tc=eg:FilterSelect(tp,s.lvfilter,1,1,nil):GetFirst()
		end
        if tc then
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_CHANGE_LEVEL)
            e1:SetValue(tc:GetLevel())
            e1:SetReset(RESET_EVENT+0x1ff0000+RESET_PHASE+PHASE_END)
            c:RegisterEffect(e1)
        end
	end
end
function s.lvfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_HYDRA) and c:IsRace(RACE_REPTILE) and c:GetLevel()>0
end

function s.xyzlimit(e,c)
	if not c then return false end
	return not c:IsRace(RACE_REPTILE)
end
