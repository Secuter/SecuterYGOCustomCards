--Irradiance Renegade
--Scripted by Secuter
if not SECUTER_IMPORTED then Duel.LoadScript("secuter_utility.lua") end
local s,id=GetID()
function s.initial_effect(c)
	--fusion summon
	Fusion.AddProcMixN(c,true,true,s.ffilter,2)
	Fusion.AddContactProc(c,s.contactfil,s.contactop,s.splimit,nil,nil,nil,false)
	c:EnableReviveLimit()
	--send to gy
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DESTROY+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
	--spsummon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,3))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(aux.exccon)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
s.listed_names={id}
s.listed_series={SET_IRRADIANCE}
--fusion
function s.ffilter(c,fc,sumtype,tp,sub,mg,sg)
	return c:IsSetCard(SET_IRRADIANCE,fc,sumtype,tp) and (not sg or sg:FilterCount(aux.TRUE,c)==0 or sg:IsExists(s.fusfilter,1,c,c:GetCode(fc,sumtype,tp),fc,tp))
end
function s.fusfilter(c,code,fc,tp)
	return c:IsSummonCode(fc,SUMMON_TYPE_FUSION,tp,code) or c:IsHasEffect(511002961) -- fusion parasite
end
--contact
function s.splimit(e,se,sp,st)
	return (st&SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION or e:GetHandler():GetLocation()~=LOCATION_EXTRA 
end
function s.contactfil(tp)
	return Duel.GetReleaseGroup(tp)
end
function s.contactop(g)
	Duel.Release(g,REASON_COST+REASON_MATERIAL)
end
--send to gy
function s.chkfilter(c,tp)
	return c:IsSetCard(SET_IRRADIANCE) and c:IsAbleToGrave()
		and Duel.IsExistingMatchingCard(s.codefilter,tp,LOCATION_DECK,0,1,c,c:GetCode())
end
function s.codefilter(c,code)
	return c:IsCode(code) and c:IsAbleToGrave()
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.chkfilter,tp,LOCATION_DECK,0,1,nil,tp) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,2,tp,LOCATION_DECK)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.chkfilter,tp,LOCATION_DECK,0,1,1,nil,tp)
	if #g>0 then
		local tc=g:GetFirst()
		local sg=Duel.GetFirstMatchingCard(s.codefilter,tp,LOCATION_DECK,0,tc,tc:GetCode())
		g:Merge(sg)
		if Duel.SendtoGrave(g,REASON_EFFECT)>0 and #g:Filter(Card.IsLocation,nil,LOCATION_GRAVE)==2 then
			local c=e:GetHandler()
			local op
			if Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RESOLVEEFFECT)
				op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))+1
			else
				op=2
			end
			if op==1 then
				--destroy 1 card
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
				local tg=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
				if #tg>0 then
					Duel.Destroy(tg,REASON_EFFECT)
				end
			elseif op==2 then
				--gains 1000 atk
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_UPDATE_ATTACK)
				e1:SetValue(1000)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				c:RegisterEffect(e1)
			end
		end
	end
end
--spsummon
function s.cfilter(c)
	return c:IsCode(id) and c:IsAbleToRemoveAsCost() and aux.SpElimFilter(c,true)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,e:GetHandler())
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then 
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
