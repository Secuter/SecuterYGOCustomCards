REASON_QUICKWARP        = 0x80000000
SUMMON_TYPE_QUICKWARP   = 0x160
QUICKWARP_LIMIT         = 12340000
QUICKWARP_IMPORTED      = true

--[[
Add at the start of the script to add Quickwarp Procedure.
!! IMPORTANT !! The next 2 card ids must not be used, because the procedure uses them for flags.
Condition if Quickwarp Summoned:
    return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_TYPE_QUICKWARP
]]

if not aux.QuickwarpProcedure then
	aux.QuickwarpProcedure = {}
	Quickwarp = aux.QuickwarpProcedure
end
if not Quickwarp then
	Quickwarp = aux.QuickwarpProcedure
end

-- utility functions
function Card.IsQuickwarp(c)
	return c.Quickwarp
end

--Quickwarp Summon
function Quickwarp.AddProcedure(c,s,id,ct,ev,op)
	if c.quickwarp_type==nil then
		local mt=c:GetMetatable()
		mt.quickwarp_type=1
		mt.quickwarp_parameters={c,s,id,ct,ev,op}
	end
    --spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	--e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetRange(LOCATION_EXTRA)
    e1:SetCost(Quickwarp.Cost)
	e1:SetCondition(Quickwarp.Condition(id,ct))
	e1:SetTarget(Quickwarp.Target(id))
	e1:SetOperation(Quickwarp.Operation)
	c:RegisterEffect(e1)
    --check
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(ev)
		ge1:SetOperation(op)
		Duel.RegisterEffect(ge1,0)
	end)
	--remove fusion type
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_REMOVE_TYPE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetRange(LOCATION_ALL)
	e0:SetValue(TYPE_FUSION)
	c:RegisterEffect(e0)
end
function Quickwarp.Cost(self)
    return true
end
function Quickwarp.Condition(id,ct)
	return	function(e,tp,eg,ep,ev,re,r,rp)
        local c=e:GetHandler()
        if not c then return false end
        if c:IsType(TYPE_PENDULUM) and c:IsFaceup() then return false end
		local tp=c:GetControler()

        -- Check if the counter is triggered and if it's in the same chain
        return Duel.GetFlagEffect(tp,id)>=ct and (Duel.GetFlagEffect(tp,id+1)>0 or Duel.GetFlagEffect(tp,id+2)==0)
    end
end
function Quickwarp.Target(id)
	return function(e,tp,eg,ep,ev,re,r,rp,chk)
        local c=e:GetHandler()
        if chk==0 then
            if Duel.GetFlagEffect(e:GetHandlerPlayer(),id+2)==0 then
                -- Register that we are in the chain where the conditions are met for the first time
                Duel.RegisterFlagEffect(tp,id+1,RESET_CHAIN,0,1)
            end
            -- Register that the conditions have been met
            Duel.RegisterFlagEffect(tp,id+2,RESET_PHASE|PHASE_END,0,1)

            return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 --Duel.GetLocationCountFromEx(tp,tp)>0
                and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
        end
        Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
    end
end
function Quickwarp.Operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,SUMMON_TYPE_QUICKWARP,tp,tp,false,false,POS_FACEUP)
		c:CompleteProcedure()
	end
end