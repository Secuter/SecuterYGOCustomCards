--Armor
--Scripted by Secuter
local s,id=GetID()
if not ARMOR_IMPORTED then Duel.LoadScript("proc_armor.lua") end
s.ArmorAtk=0
s.ArmorDef=0
s.IsArmor=true
function s.initial_effect(c)
	--Armor
	Armor.AddProcedure(c)
	--atk up
	local a1=Effect.CreateEffect(c)
	a1:SetDescription(aux.Stringid(id,2))
	a1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	a1:SetType(EFFECT_TYPE_XMATERIAL+EFFECT_TYPE_TRIGGER_F)
	a1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	a1:SetCondition(s.atkcon)
	a1:SetOperation(s.atkop)
	c:RegisterEffect(a1)
	--attach
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATTACH_ARMOR)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end

function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetBattleTarget() and Armor.Condition(e)
		and e:GetHandler():GetFlagEffect(id)==0
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	local val=0
	if    bc:GetLevel()>0 then val=bc:GetLevel()*100
	elseif bc:GetRank()>0 then val=bc:GetRank()*100
	elseif bc:GetLink()>0 then val=bc:GetLink()*100
	end
	if c:IsRelateToBattle() and c:IsFaceup() and bc:IsRelateToBattle() and bc:IsFaceup() then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_PHASE+PHASE_DAMAGE_CAL)
		e1:SetValue(val)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		c:RegisterEffect(e2)
		e:GetHandler():RegisterFlagEffect(id,RESET_PHASE+PHASE_DAMAGE_CAL,0,1)
	end
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and Armor.AttachCheck(chkc,e:GetHandler()) end
	if chk==0 then return Duel.IsExistingTarget(Armor.AttachCheck,tp,LOCATION_GRAVE,0,1,nil,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTACHARMOR)
	local g=Duel.SelectTarget(tp,Armor.AttachCheck,tp,LOCATION_GRAVE,0,1,1,nil,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_ATTACH_ARMOR,g,1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Armor.Attach(e:GetHandler(),tc)
	end
end