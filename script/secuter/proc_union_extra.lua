UNION_EXTRA_IMPORTED		= true

--[[
	aux.AddUnionExtraProcedure(c,filter)
    Same as Union but can be Summoned ignoring Summoning conditions (for Extra Deck Union monsters)
]]

function Auxiliary.AddUnionExtraProcedure(c,f,oldequip,oldprotect)
	if oldprotect == nil then oldprotect = oldequip end
	--equip
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(1068)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(Auxiliary.UnionTarget(f,oldequip))
	e1:SetOperation(Auxiliary.UnionOperation(f))
	c:RegisterEffect(e1)
	--unequip
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(2)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	if oldequip then
		e2:SetCondition(Auxiliary.IsUnionState)
	else
		e2:SetCondition(function(e) return e:GetHandler():GetEquipTarget()end)
	end
	e2:SetTarget(Auxiliary.UnionSumTargetExtra(oldequip))
	e2:SetOperation(Auxiliary.UnionSumOperationExtra(oldequip))
	c:RegisterEffect(e2)
	--destroy sub
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetCode(EFFECT_DESTROY_SUBSTITUTE)
	if oldprotect then
		e3:SetCondition(Auxiliary.IsUnionState)
	else
		e3:SetCondition(function(e) return e:GetHandler():GetEquipTarget()end)
	end
	e3:SetValue(Auxiliary.UnionReplace(oldprotect))
	c:RegisterEffect(e3)
	--eqlimit
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_UNION_LIMIT)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetValue(Auxiliary.UnionLimit(f))
	c:RegisterEffect(e4)
	--auxiliary function compatibility
	if oldequip then
		local m=c:GetMetatable()
		m.old_union=true
	end
end
function Auxiliary.UnionSumTargetExtra(oldrule)
	return function (e,tp,eg,ep,ev,re,r,rp,chk)
		local c=e:GetHandler()
		local code=c:GetOriginalCode()
		local pos=POS_FACEUP
		if oldrule then pos=POS_FACEUP_ATTACK end
		if chk==0 then return c:GetFlagEffect(code)==0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,true,true,pos) end
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
		c:RegisterFlagEffect(code,RESET_EVENT+(RESETS_STANDARD-RESET_TOFIELD-RESET_LEAVE)+RESET_PHASE+PHASE_END,0,1)
	end
end
function Auxiliary.UnionSumOperationExtra(oldrule)
	return function (e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		if not c:IsRelateToEffect(e) then return end
		local pos=POS_FACEUP
		if oldrule then pos=POS_FACEUP_ATTACK end
		if Duel.SpecialSummon(c,0,tp,tp,true,true,pos)==0 and Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
			and c:IsCanBeSpecialSummoned(e,0,tp,true,true,pos) then
			Duel.SendtoGrave(c,REASON_RULE)
		end
	end
end