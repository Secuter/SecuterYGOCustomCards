--Zenit Dragon Retribution
--Scripted by Secuter
local s,id=GetID()
function s.initial_effect(c)
	--banish
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
--banish
function s.cfilter(c,tc)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON) and c:IsType(TYPE_XYZ)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Group.CreateGroup()
	local mg=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,0,nil)
	for tc in aux.Next(mg) do
		g:Merge(tc:GetOverlayGroup())
	end
	if chk==0 then return #g>=2 and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVEXYZ)
	local nums={}
	local max=Duel.GetMatchingGroupCount(Card.IsAbleToRemove,tp,0,LOCATION_MZONE,1,nil)
	for i=1,max do
		if i*2>=#g then table.insert(nums,i*2) end
	end
	local ct=Duel.AnnounceNumber(tp,table.unpack(nums))
	local sg=g:Select(tp,ct,ct,nil)
	Duel.SendtoGrave(sg,REASON_COST)
	e:SetLabel(ct//2)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,e:GetLabel(),1-tp,LOCATION_ONFIELD)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local ct=e:GetLabel()
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,ct,ct,nil)
	if #g>=ct then
		Duel.HintSelection(g,true)
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end