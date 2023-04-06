SUMMON_TYPE_EXCHANGE= 0x80
HINTMSG_EXSUMMON	= 607
EXCHANGE_IMPORTED	= true

--[[
add at the start of the script to add Exchange procedure
if not EXCHANGE_IMPORTED then Duel.LoadScript("proc_exchange.lua") end
condition if Exchange summoned
    return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_TYPE_EXCHANGE
]]

if not aux.ExchangeProcedure then
	aux.ExchangeProcedure = {}
	Exchange = aux.ExchangeProcedure
end
if not Exchange then
	Exchange = aux.ExchangeProcedure
end

--Exchange Summon
--Parameters:
-- c: card
-- s: script of the card
-- f: optional, filter for monsters special summoned by the Exchange Summon (Default must be an Exchange Monster)
-- sp: optional, flag if the effect includes a special summon (Default = SP yes, true = SP yes, false = SP no)
-- location: optional, special summon location (Default = LOCATION_HAND, if set replaces the default)
-- extracat: optional, eventual extra categories for the effect (Default = CATEGORY_TOHAND|CATEGORY_SPECIAL_SUMMON)
-- extrainfo: optional, eventual OperationInfo to be set in Target function for extraop
-- extraop: optional, additional operation to be performed
function Exchange.Enable(c,s,f,sp,location,extracat,extrainfo,extraop)
	if sp==nil then sp=true end
	if not location then location=LOCATION_HAND end
	if not extracat then extracat=0 end
	local e1=Effect.CreateEffect(c)
	if sp then
		e1:SetCategory(CATEGORY_TOHAND|CATEGORY_SPECIAL_SUMMON|extracat)
	else
		e1:SetCategory(CATEGORY_TOHAND|extracat)
	end
	e1:SetDescription(1185)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(Exchange.Condition(c:GetOriginalCode()))
	e1:SetTarget(Exchange.Target(c,f,sp,location,extrainfo))
	e1:SetOperation(Exchange.Operation(c,f,sp,location,extraop))
	c:RegisterEffect(e1)
	aux.GlobalCheck(s,function()
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_SPSUMMON_SUCCESS)
		e2:SetLabel(c:GetOriginalCode())
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCondition(Exchange.SumCheck)
		e2:SetOperation(aux.sumreg)
		Duel.RegisterEffect(e2,0)
	end)
	
end
function Exchange.SumCheck(e,tp,eg,ep,ev,re,r,rp)
	local code=e:GetLabel()
	for tc in aux.Next(eg) do
		if tc:GetOriginalCode()==code then
			return tc:GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_TYPE_EXCHANGE
		end
	end
	return false
end

function Exchange.Filter(c,f,lc,tp,id)
	return c.IsExchange and not c:IsCode(id) and (not f or f(c,lc,SUMMON_TYPE_SPECIAL,tp))
end
function Exchange.Condition(id)
	return function(e,tp,eg,ep,ev,re,r,rp)
		return e:GetHandler():GetFlagEffect(id)==0
	end
end
function Exchange.Target(c,f,sp,location,extrainfo)
	return function(e,tp,eg,ep,ev,re,r,rp,chk)
		local c=e:GetHandler()
		if chk==0 then return true end
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
		if sp and Duel.GetLocationCount(tp,LOCATION_MZONE)>-1 and Duel.IsExistingMatchingCard(Exchange.Filter,tp,location,0,1,nil,f,c,tp,c:GetOriginalCode()) then
			Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,location)
		end
		if extrainfo then extrainfo(e,tp,eg,ep,ev,re,r,rp,chk) end
	end
end
function Exchange.Operation(c,f,sp,location,extraop)	
	return function(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		if c:IsRelateToEffect(e) and Duel.SendtoHand(c,nil,REASON_EFFECT)~=0 and c:IsLocation(LOCATION_HAND) then
			local g=Duel.GetMatchingGroup(Exchange.Filter,tp,location,0,nil,f,c,tp,c:GetOriginalCode())
			if sp and #g>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.SelectYesNo(tp,HINTMSG_EXSUMMON) then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
				local tc=g:Select(tp,1,1,nil)
				if tc then
					Duel.SpecialSummon(tc,SUMMON_TYPE_EXCHANGE,tp,tp,false,false,POS_FACEUP)
				end
			end
			if extraop then
				extraop(e,tp,eg,ep,ev,re,r,rp)
			end
		end
	end
end