--Demonic Shellmancer
--Scripted by Secuter
if not SECUTER_IMPORTED then Duel.LoadScript("secuter_utility.lua") end
local s,id=GetID()
s.Armorizing=true
s.Exarmorizing=true
s.Shells=2
function s.initial_effect(c)
	Armorizing.AddProcedure(c,nil,1,nil,2)
	c:EnableReviveLimit()
    --banish
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.rmcon)
	e1:SetTarget(s.rmtg)
	e1:SetOperation(s.rmop)
	c:RegisterEffect(e1)
    --attach
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,3))
	e2:SetCategory(CATEGORY_ATTACH_ARMOR+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
--banish
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ARMORIZING)
end
function s.rmfilter(c)
	return c:IsAbleToRemove() and (c:IsLocation(LOCATION_SZONE) or aux.SpElimFilter(c,true,true))
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(s.rmfilter,tp,0,LOCATION_ONFIELD+LOCATION_HAND,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_ONFIELD+LOCATION_HAND)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local g1=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,nil)
	local g2=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_HAND,nil)
	if #g1>0 or #g2>0 then
        local op=0
        if #g1>0 and #g2>0 then
            op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))+1
        elseif #g1>0 then op=1
        elseif #g2>0 then op=2
        end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
        local g
        if op==1 then
            g=g1:Select(tp,1,1,nil)
        elseif op==2 then
            g=g2:RandomSelect(tp,1)
        end
		local tc=g:GetFirst()
		if Duel.Remove(tc,0,REASON_EFFECT|REASON_TEMPORARY)>0 then
			tc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END,0,2)
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_PHASE+PHASE_END)
			e1:SetReset(RESET_PHASE|PHASE_END,2)
			e1:SetLabelObject(tc)
			e1:SetLabel(Duel.GetTurnCount())
			e1:SetCountLimit(1)
			e1:SetCondition(s.retcon)
			e1:SetOperation(s.retop(op))
			Duel.RegisterEffect(e1,tp)
		end
	end
end
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnCount()~=e:GetLabel() and e:GetLabelObject():GetFlagEffect(id)>0
end
function s.retop(op)
	return function(e,tp,eg,ep,ev,re,r,rp)
		if op==1 then
			Duel.ReturnToField(e:GetLabelObject())
		end
		if op==2 then
			Duel.SendtoHand(e:GetLabelObject(),nil,REASON_EFFECT)
		end
	end
end
--spsummon
function s.atfilter(c,tc)
	return c:IsArmorizing() and Armor.AttachCheck(c,tc)
end
function s.arfilter(c,e,tp,sh)
	return c:IsArmorizing() and c:IsShellBelow(sh) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
        and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_ARMORIZING,tp,false,false,POS_FACEUP_DEFENSE)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.atfilter(chkc,c) end
	if chk==0 then return Duel.IsExistingTarget(s.atfilter,tp,LOCATION_GRAVE,0,1,nil,c)
		and Duel.IsExistingMatchingCard(s.arfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c:GetOverlayCount()+1) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTACHARMOR)
	local g=Duel.SelectTarget(tp,s.atfilter,tp,LOCATION_GRAVE,0,1,1,nil,c)
	Duel.SetOperationInfo(0,CATEGORY_ATTACH_ARMOR,g,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and Armor.Attach(c,tc,e) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.arfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,c:GetOverlayCount())
		if #g>0 then
			Duel.SpecialSummon(g,SUMMON_TYPE_ARMORIZING,tp,tp,false,false,POS_FACEUP_DEFENSE)
		end
	end
end
