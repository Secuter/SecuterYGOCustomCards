--Morhai Link 1
--Scripted by Secuter
local s,id=GetID()
function s.initial_effect(c)
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(s.linkcheck),1,1)
	c:EnableReviveLimit()
	--move
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.mvcon)
	e1:SetTarget(s.mvtg)
	e1:SetOperation(s.mvop)
	c:RegisterEffect(e1)
end
s.material_setcode={0x209}
function s.linkcheck(c,scard,sumtype,tp)
	return c:IsSetCard(0x209,scard,sumtype,tp) and not c:IsType(TYPE_LINK,scard,sumtype,tp)
end

function s.mvcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function s.mvfilter(c,zone)
	return c:IsFaceup() and c:GetSequence()<5
		and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE,c:GetControler(),LOCATION_REASON_CONTROL,zone)>0
end
function s.mvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local zone=c:GetLinkedZone(1-tp)&0x1f
	if chk==0 then return Duel.IsExistingMatchingCard(s.mvfilter,1-tp,LOCATION_MZONE,0,1,nil,zone) end	
end
function s.mvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local zone=c:GetLinkedZone(1-tp)&0x1f
	local g=Duel.GetMatchingGroup(s.mvfilter,1-tp,LOCATION_MZONE,0,nil,zone)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_CONFIRM)
		local sg=g:Select(1-tp,1,1,nil)
		Duel.HintSelection(sg)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
		--Duel.MoveSequence(sg:GetFirst(),math.log(Duel.SelectDisableField(1-tp,1,0,LOCATION_MZONE,0)>>16,2))
		local i=0
		if not c:IsControler(tp) then i=16 end
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TOZONE)
		local nseq=math.log(Duel.SelectDisableField(1-tp,1,LOCATION_MZONE,LOCATION_MZONE,~(zone<<i)),2)-i
		Duel.MoveSequence(sg:GetFirst(),nseq)
	end
end