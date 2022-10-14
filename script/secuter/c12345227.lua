--Exoheart Stargazer
--Scripted by Secuter
local s,id=GetID()
s.TOKEN_ID=id+2
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_names={s.TOKEN_ID}
s.listed_series={0x20E}
--activate
function s.filter(c)
	return c:IsSetCard(0x20E) and c:IsDiscardable()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND,0,1,c:GetHandler())
		and Duel.IsPlayerCanDraw(tp,1)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,s.TOKEN_ID,0x20E,TYPES_TOKEN,500,500,1,RACE_CYBERSE,ATTRIBUTE_LIGHT) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)	
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	if Duel.Draw(p,d,REASON_EFFECT)>0 then		
		local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_HAND,0,nil)
		if #g==0 then return end
		if #g==1 then
			Duel.SendtoGrave(g,REASON_EFFECT+REASON_DISCARD)
		else
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
			local sg=g:Select(tp,1,1,e:GetHandler())
			Duel.SendtoGrave(sg,REASON_EFFECT+REASON_DISCARD)
		end
	end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	and Duel.IsPlayerCanSpecialSummonMonster(tp,s.TOKEN_ID,0x20E,TYPES_TOKEN,500,500,1,RACE_CYBERSE,ATTRIBUTE_LIGHT) then
		local c=e:GetHandler()
		local token=Duel.CreateToken(tp,s.TOKEN_ID)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		--splimit
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetRange(LOCATION_MZONE)
		e1:SetTargetRange(1,0)
		e1:SetTarget(s.splimit)
		token:RegisterEffect(e1,true)
	end
	Duel.SpecialSummonComplete()
end
function s.splimit(e,c)
	return not c:IsSetCard(0x20E) or c:IsCode(s.TOKEN_ID)
end