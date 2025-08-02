--External Worlds Dark Synchro Dragon
--Scripted by Secuter
if not SECUTER_IMPORTED then Duel.LoadScript("secuter_utility.lua") end
local s,id=GetID()
function s.initial_effect(c)
	--dark synchro summon 
	c:EnableReviveLimit()
	Synchro.AddDarkSynchroProcedure(c,Synchro.NonTuner(Card.IsSetCard,SET_EXTERNAL_WORLDS),nil,11)
	--remove & boost atk
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(s.rmcond)
	e2:SetTarget(s.rmcost)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)
    --negate effect
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_ATTACK_ANNOUNCE)
	e4:SetOperation(s.disop)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_BE_BATTLE_TARGET)
	c:RegisterEffect(e5)
	--change level
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_CHANGE_LEVEL)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.lvcon)
	e3:SetValue(12)
	c:RegisterEffect(e3)
end
s.listed_series={SET_EXTERNAL_WORLDS}

function s.rmcond(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SYNCHRO
end
function s.rmfilter(c)
	return c:IsSetCard(SET_EXTERNAL_WORLDS) and c:IsAbleToRemoveAsCost() and c:IsFaceup() and c:IsType(TYPE_MONSTER)
end
function s.rmcost(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE+LOCATION_EXTRA) and chkc:IsControler(1-tp) and s.rmfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.rmfilter,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.rmfilter,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,99,nil)
	e:SetLabel(g:GetCount())
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if e:GetLabel()>0 and c:IsFaceup() and c:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(e:GetLabel()*500)
		e1:SetReset(RESET_EVENT+0x1ff0000+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end

function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if bc then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE_STEP)
		bc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE_STEP)
		bc:RegisterEffect(e2)
	end
end

function s.lvfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON) and c:IsType(TYPE_SYNCHRO)
end
function s.lvcon(e)
	return Duel.IsExistingMatchingCard(s.lvfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,e:GetHandler())
end

function s.tmatfilter(c,sc)
	return c:IsSetCard(0x600) and c:IsType(TYPE_TUNER) and (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and c:IsCanBeSynchroMaterial(sc)
end
function s.ntmatfilter(c,sc,tp)
	return c:IsSetCard(SET_EXTERNAL_WORLDS) and c:IsNotTuner(sc,tp) and (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and c:IsCanBeSynchroMaterial(sc)
end
function s.synfilter1(c,lv,tuner,sc,pe,tc)
	if sc:GetFlagEffect(100000147)==0 then
		return tuner:IsExists(s.synfilter2,1,c,true,lv,c,sc,pe,tc)
	else
		return tuner:IsExists(s.synfilter2,1,c,false,lv,c,sc,pe,tc)
	end
end
function s.synfilter2(c,add,lv,ntng,sc,pe,tc)    
	if pe and not Group.FromCards(ntng,c):IsContains(pe:GetOwner()) then return false end
	if tc and not Group.FromCards(ntng,c):IsContains(tc) then return false end
	if c.tuner_filter and not c.tuner_filter(ntng) then return false end
	if ntng.tuner_filter and not ntng.tuner_filter(c) then return false end
	if not c:IsHasEffect(EFFECT_HAND_SYNCHRO) and ntng:IsLocation(LOCATION_HAND) then return false end
	if not ntng:IsHasEffect(EFFECT_HAND_SYNCHRO) and c:IsLocation(LOCATION_HAND) then return false end
	if (ntng:IsHasEffect(EFFECT_HAND_SYNCHRO) or c:IsHasEffect(EFFECT_HAND_SYNCHRO)) and c:IsLocation(LOCATION_HAND) 
		and ntng:IsLocation(LOCATION_HAND) then return false end
        
    local tp=sc:GetControler()
	if sc:IsLocation(LOCATION_EXTRA) then
        local sg=Group.CreateGroup()
        sg:AddCard(ntng)
        sg:AddCard(c)
		if Duel.GetLocationCountFromEx(tp,tp,sg,sc)<=0 then return false end
	else
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
            and not Group.FromCards(ntng,c):IsExists(Card.IsLocation,1,nil,LOCATION_MZONE) then return false end
	end
    
	local ntlv=ntng:GetSynchroLevel(sc)
	local lv1=bit.band(ntlv,0xffff)
	local lv2=bit.rshift(ntlv,16)
	if add then
		return c:GetSynchroLevel(sc)==lv+lv1 or c:GetSynchroLevel(sc)==lv+lv2
	else
		return c:GetSynchroLevel(sc)==lv-lv1 or c:GetSynchroLevel(sc)==lv-lv2
	end
end
function s.syncon(e,c,tuner,mg)
	if c==nil then return true end
    local lvsyn=e:GetHandler():GetLevel()
	local tp=c:GetControler()
	local pe=Duel.IsPlayerAffectedByEffect(tp,EFFECT_MUST_BE_MATERIAL)
	local tng=Duel.GetMatchingGroup(s.tmatfilter,tp,LOCATION_MZONE+LOCATION_HAND,LOCATION_MZONE,nil,c)
	local ntng=Duel.GetMatchingGroup(s.ntmatfilter,tp,LOCATION_MZONE+LOCATION_HAND,LOCATION_MZONE,nil,c,tp)
	return ntng:IsExists(s.synfilter1,1,nil,lvsyn,tng,c,pe,tuner)
end
function s.synop(e,tp,eg,ep,ev,re,r,rp,c,tuner,mg)
    local lvsyn=e:GetHandler():GetLevel()
	local pe=Duel.IsPlayerAffectedByEffect(tp,EFFECT_MUST_BE_MATERIAL)
	local g=Group.CreateGroup()
	local tun=Duel.GetMatchingGroup(s.tmatfilter,tp,LOCATION_MZONE+LOCATION_HAND,LOCATION_MZONE,nil,c)
	local nont=Duel.GetMatchingGroup(s.ntmatfilter,tp,LOCATION_MZONE+LOCATION_HAND,LOCATION_MZONE,nil,c,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SMATERIAL)
	local nontmat=nont:FilterSelect(tp,s.synfilter1,1,1,nil,lvsyn,tun,c,pe,tuner)
	local mat1=nontmat:GetFirst()
	g:AddCard(mat1)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SMATERIAL)
	local t
	if mat1:GetFlagEffect(100000147)==0 then
		t=tun:FilterSelect(tp,s.synfilter2,1,1,mat1,true,lvsyn,mat1,c,pe,tuner)
	else
		t=tun:FilterSelect(tp,s.synfilter2,1,1,mat1,false,lvsyn,mat1,c,pe,tuner)
	end
	g:Merge(t)
	c:SetMaterial(g)
	Duel.SendtoGrave(g,REASON_MATERIAL+REASON_SYNCHRO)
	g:DeleteGroup()
end
