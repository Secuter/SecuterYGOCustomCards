WANDERING_IMPORTED      = true

local DEBUG = true
local ONLY_ID = nil
local function Debugging(id)
    return (DEBUG or ONLY_ID) and (not ONLY_ID or ONLY_ID == id)
end

--[[
Add at the start of the script to add Wandering Procedure.
Condition if Wandering Summoned:
    return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_TYPE_WANDERING
]]

if not aux.WanderingProcedure then
	aux.WanderingProcedure = {}
	Wandering = aux.WanderingProcedure
end
if not Wandering then
	Wandering = aux.WanderingProcedure
end

-- check if it's Wandering
function Card.IsWandering(c)
	return c.Wandering
end

--Wandering Summon
-- ct: the counter that must be met to enable Summon
-- ev: the event that trigger the check
-- filter: the function used to filter trigger events
-- value: the function used to get the counter (eg. Card.GetLevel)
-- ct_event: bool, if to count the events instead of the cards
--    false: count the cards (eg. summon X monsters)
--    true: count the events (eg. summon a monster(s) X times)
-- cond: function (optional), if set it's used instead of the counter to check if the monster is summonable
-- duel: bool, conditions per duel instead of per turn
-- force: bool, ignore the once Wandering Summon per turn limit
Wandering.AddProcedure = aux.FunctionWithNamedArgs(
function (c,s,id,ct,ev,f,ct_event,value,cond,duel,force)
	if c.wandering_type==nil then
		local mt=c:GetMetatable()
		mt.wandering_type=1
		mt.wandering_parameters={c,s,id,ct,ev,f,ct_event,value,cond,duel,force}
	end
    local id_limit_chain=aux.GetSubId(id, 0)
    local id_first_chain=aux.GetSubId(id, 1)
    local id_limit_count=aux.GetSubId(id, 2)
    --spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(1188)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
    e1:SetHintTiming(TIMINGS_CHECK_MONSTER_E)
	e1:SetRange(LOCATION_EXTRA)
    e1:SetCost(Wandering.Cost)
	e1:SetCondition(Wandering.Condition(id,ct,cond,force,id_limit_chain,id_first_chain,id_limit_count))
	e1:SetTarget(Wandering.Target(id,id_limit_count))
	e1:SetOperation(Wandering.Operation(id_limit_count))
	c:RegisterEffect(e1)
    --check
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(ev)
		ge1:SetOperation(Wandering.Check(id,f,ct_event,value,duel))
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
end,"handler","script","id","ct","ev","filter","ct_event","value","cond","duel","force")

function Wandering.Cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk then return true end
    local c=e:GetHandler()
    local tp=c:GetControler()
    -- Prevent multiple activate of Wandering Summon in the same chain
    Duel.RegisterFlagEffect(tp,ID_WANDERING_LIMIT,RESET_CHAIN,0,1)
    --Duel.RegisterFlagEffect(tp,id_limit_count,RESET_CHAIN,0,1)
    Debug.UniqueMessage(tp, "Limit Chain in Cost")
end
function Wandering.Check(id,f,ct_event,value,duel)
    return function (e,tp,eg,ep,ev,re,r,rp)
        local t={}
        local tc=eg:GetFirst()
        for tc in aux.Next(eg) do
            if f and f(tc,e,tp,eg,ep,ev,re,r,rp) then
                local cp=tc:GetControler()
                if ct_event and t[cp] then
                    -- Do nothing if it's counting events and has already triggered for that player
                else
                    t[cp]=1
                    local current=Duel.GetFlagEffectLabel(tp,id) or 0
                    Duel.ResetFlagEffect(tp,id)
                    Duel.RegisterFlagEffect(tp,id,not duel and RESET_PHASE|PHASE_END or 0,0,1,current + (value and value(tc,e,tp,eg,ep,ev,re,r,rp) or 1))
                end
            end
        end
    end
end
function Wandering.Condition(id,ct,cond,force,id_limit_chain,id_first_chain,id_limit_count)
	return	function(e,tp,eg,ep,ev,re,r,rp)
        local c=e:GetHandler()
        if not c then return false end
        if c:IsType(TYPE_PENDULUM) and c:IsFaceup() then return false end
		local tp=c:GetControler()

        -- Check if opponent has Nullaor, Apotheosis of the Innerplane
        if Duel.IsPlayerAffectedByEffect(tp,EFFECT_NO_WANDERING_SUMMON) then return false end
        -- Check increase number of Wandering Summons effect
        local max=1
        if Duel.IsPlayerAffectedByEffect(tp,EFFECT_WANDERING_SUMMON_TWICE) then max=2 end
        if Duel.IsPlayerAffectedByEffect(tp,EFFECT_WANDERING_SUMMON_TRICE) then max=3 end
        if Duel.IsPlayerAffectedByEffect(tp,EFFECT_WANDERING_SUMMON_UNLIMITED) then max=999 end

        -- Logging
        if Debugging(id) and Duel.GetFlagEffect(tp,id)>0 and Duel.GetFlagEffectLabel(tp,id)>0 then
            local msg="Limit: "..(force and "none" or tostring(Duel.GetFlagEffect(tp,ID_WANDERING_LIMIT))).." Chain: "..Duel.GetFlagEffect(tp,id_first_chain).."/"..Duel.GetFlagEffect(tp,id_limit_chain).." Count: "..Duel.GetFlagEffectLabel(tp,id)
            if cond then msg = msg.." Special: "..tostring(cond(c,e,tp,eg,ep,ev,re,r,rp,Duel.GetFlagEffectLabel(tp,id) or 0)) end
            Debug.UniqueMessage(tp, msg)
        end

        -- Check if already Wandering Summoned this card this turn
        if Duel.GetFlagEffect(tp,id_limit_count)>0 then
            return false
        end

        -- Check if already Wandering Summoned this turn
        if Duel.GetFlagEffect(tp,ID_WANDERING_LIMIT)>=max and not force then return false end
        -- Custom function check
        if cond then
            if not cond(c,e,tp,eg,ep,ev,re,r,rp,Duel.GetFlagEffectLabel(tp,id) or 0) then return false end
        else
            -- Standard counter check
            if not (Duel.GetFlagEffect(tp,id)>0 and Duel.GetFlagEffectLabel(tp,id)>=ct) then return false end
        end

        if Duel.GetFlagEffect(tp,id_limit_chain)==0 then
            -- Register that the conditions have been met for the first time in this chain
            Duel.RegisterFlagEffect(tp,id_first_chain,RESET_CHAIN,0,1)
            -- Register that the conditions have been met (to prevent another activation in the next chain)
            Duel.RegisterFlagEffect(tp,id_limit_chain,not duel and RESET_PHASE|PHASE_END or 0,0,1)
        end

        -- Check if condition was triggered this chain
        if Debugging(id) then Debug.UniqueMessage(tp, "return "..tostring(Duel.GetFlagEffect(tp,id_first_chain))) end
        return Duel.GetFlagEffect(tp,id_first_chain)>0
    end
end
function Wandering.Target(id,id_limit_count)
	return function(e,tp,eg,ep,ev,re,r,rp,chk)
        local c=e:GetHandler()
        if chk==0 then
            if Debugging(id) then
                Debug.UniqueMessage(tp, "Target check: "..tostring(Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
            end

            return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 --Duel.GetLocationCountFromEx(tp,tp)>0
                and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
        end
        -- Prevent multiple activate of Wandering Summon in the same chain
        Duel.RegisterFlagEffect(tp,ID_WANDERING_LIMIT,RESET_CHAIN,0,1)
        Duel.RegisterFlagEffect(tp,id_limit_count,RESET_CHAIN,0,1)
        Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
    end
end
function Wandering.Operation(id_limit_count)
	return function(e,tp,eg,ep,ev,re,r,rp,chk)
        local c=e:GetHandler()
        if c:IsRelateToEffect(e) then
            if Duel.SpecialSummon(c,SUMMON_TYPE_WANDERING,tp,tp,false,false,POS_FACEUP)>0 then
                -- Register Wandering Summon counter
                Duel.RegisterFlagEffect(tp,ID_WANDERING_LIMIT,RESET_PHASE|PHASE_END,0,1)
                Duel.RegisterFlagEffect(tp,id_limit_count,RESET_CHAIN,0,1)
                c:CompleteProcedure()
            end
        end
    end
end