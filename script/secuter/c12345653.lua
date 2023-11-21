--Phantasm Spiral Hunt
--Scripted by Secuter
if not SECUTER_IMPORTED then Duel.LoadScript("secuter_utility.lua") end
local s,id=GetID()
function s.initial_effect(c)
	aux.AddEquipProcedure(c,nil,aux.FilterBoolFunction(Card.IsType,TYPE_NORMAL))
	--intarget
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
	--spsummon
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DAMAGE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BATTLE_DESTROYING)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1,id)
	e4:SetCondition(s.spcon)
    e4:SetCost(s.spcost)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
end
local CARD_PHANTASM_SPIRAL_DRAGON=56649609
s.listed_names={CARD_PHANTASM_SPIRAL_DRAGON}
--spsummon
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and eg:IsContains(ec)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local tc=c:GetEquipTarget()
	if chk==0 then return c:IsReleasable() and tc:IsReleasable() end
	local g=Group.FromCards(c,tc)
	Duel.Release(g,REASON_COST)
end
function s.spfilter(c,e,tp)
	return c:IsCode(CARD_PHANTASM_SPIRAL_DRAGON) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
        and (c:IsFaceup() or (not c:IsLocation(LOCATION_REMOVED) and not c:IsLocation(LOCATION_EXTRA)))
end
function s.spcheck(ex)
	return function(sg,e,tp,mg)
        return #sg:Filter(Card.IsLocation,nil,LOCATION_EXTRA)<=ex
	end
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
    local ex=Duel.GetLocationCountFromEx(tp)
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_REMOVED|LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE|LOCATION_EXTRA,0,nil,e,tp)
	if chk==0 then return aux.SelectUnselectGroup(g,e,tp,1,ft,s.spcheck(ex),0) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_REMOVED|LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE|LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
    ft=math.min(ft,aux.CheckSummonGate(tp) or ft)
    local ex=Duel.GetLocationCountFromEx(tp)
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_REMOVED|LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE|LOCATION_EXTRA,0,nil,e,tp)
	local sg=aux.SelectUnselectGroup(g,e,tp,1,ft,s.spcheck(ex),1,tp,HINTMSG_SPSUMMON)
    local i=0
    local ct=sg:FilterCount(Card.IsLocation,nil,LOCATION_EXTRA) -- count the number of monsters selected in the Extra Deck
	for tc in aux.Next(sg) do
        if tc:IsLocation(LOCATION_EXTRA) then
            Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
            i=i+1
        else
            -- check if have to leave zones for mons in the Extra Deck
            local lz=Duel.GetFreeLinkedZone(tp)
            if ct-i>=aux.GetZonesCount(lz) then
                Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP,ZONES_MMZ&~lz)
            else
                Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
            end
        end
    end
    Duel.SpecialSummonComplete()
end