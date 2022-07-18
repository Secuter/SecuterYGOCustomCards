--Irradiance Nova
--Scripted by Secuter
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- all level/rank/link 1 monsters that is not token and is legal in format
-- select select * from datas where level = 1 and alias = 0 and type & 0x20 > 0;
s.ids = {
	[135598]=true,[263926]=true,[291414]=true,[595626]=true,[652362]=true,[1142880]=true,[1174075]=true,[1434352]=true,[1474910]=true,[1482001]=true,[2220237]=true,[2347477]=true,[2368215]=true,[2407147]=true,[2729285]=true,[2810642]=true,[2830693]=true,[2980764]=true,[3507053]=true,[3560069]=true,[3657444]=true,[3679218]=true,[4019153]=true,[4474060]=true,[4545683]=true,[4729591]=true,[4896788]=true,[5592689]=true,[5846183]=true,[5901497]=true,[6128460]=true,[6142488]=true,[6205579]=true,[6311717]=true,[6330307]=true,[6625096]=true,[7161742]=true,[7268133]=true,[7489323]=true,[7540107]=true,[7623640]=true,[7864030]=true,[7925734]=true,[7969770]=true,[8131171]=true,[8240199]=true,[8487449]=true,[8491308]=true,[8491961]=true,[8495780]=true,[8706701]=true,[8972398]=true,[9076207]=true,[9260791]=true,[9264485]=true,[9742784]=true,[10178757]=true,[10389794]=true,[10456559]=true,[10505300]=true,[10736540]=true,[10753491]=true,[11021521]=true,[11159464]=true,[11548522]=true,[11678191]=true,[11747708]=true,[11760174]=true,[11851647]=true,[12398280]=true,[12421694]=true,[12472242]=true,[12533811]=true,[12538374]=true,[13046291]=true,[13143275]=true,[13314457]=true,[13455953]=true,[13478040]=true,[13582837]=true,[13599884]=true,[13761956]=true,[13764881]=true,[14146794]=true,[14169843]=true,[14198496]=true,[14235211]=true,[14291024]=true,[14618326]=true,[14624296]=true,[14729426]=true,[14812471]=true,[14816857]=true,[14957440]=true,[15232745]=true,[15310033]=true,[15521027]=true,[15610297]=true,[16001119]=true,[16008155]=true,[16024176]=true,[16366810]=true,[16617334]=true,[16632144]=true,[16638212]=true,[16725505]=true,[16759958]=true,[16940215]=true,[17285476]=true,[17841097]=true,[18210764]=true,[18489208]=true,[18590133]=true,[18789533]=true,[18837926]=true,[18964575]=true,[18988391]=true,[19086954]=true,[19580308]=true,[19605133]=true,[19665973]=true,[20318029]=true,[20450925]=true,[20579538]=true,[20663556]=true,[20747792]=true,[20855340]=true,[21051977]=true,[21142671]=true,[21159309]=true,[21452275]=true,[21565445]=true,[22171591]=true,[22339232]=true,[22420202]=true,[23408872]=true,[23656668]=true,[23689428]=true,[23740893]=true,[24508238]=true,[24842059]=true,[25533642]=true,[25652655]=true,[25725326]=true,[26376390]=true,[26381750]=true,[26964762]=true,[26973555]=true,[27107590]=true,[27189308]=true,[27240101]=true,[27352108]=true,[27439792]=true,[27450400]=true,[27693363]=true,[27750191]=true,[27756115]=true,[28168762]=true,[28174796]=true,[28194325]=true,[28332833]=true,[28427869]=true,[29085954]=true,[29107423]=true,[29719112]=true,[29905795]=true,[30013902]=true,[30118200]=true,[30221870]=true,[30348744]=true,[30399511]=true,[30492798]=true,[30691817]=true,[31034919]=true,[31175914]=true,[31226177]=true,[31480215]=true,[31560081]=true,[31930787]=true,[32176662]=true,[32362575]=true,[32995276]=true,[33245030]=true,[33365932]=true,[33543890]=true,[33750025]=true,[33883834]=true,[33909817]=true,[33918636]=true,[34206604]=true,[34250214]=true,[34334692]=true,[34471458]=true,[34550857]=true,[34659866]=true,[34755994]=true,[34796454]=true,[35050257]=true,[35089369]=true,[35112613]=true,[35448319]=true,[35800511]=true,[36021814]=true,[36205132]=true,[36262024]=true,[36318200]=true,[36442179]=true,[36472900]=true,[36577931]=true,[36734924]=true,[37806313]=true,[37984331]=true,[38124994]=true,[38210374]=true,[38383368]=true,[38491199]=true,[38562933]=true,[38783169]=true,[39260991]=true,[39271553]=true,[40159926]=true,[40177746]=true,[40217358]=true,[40343749]=true,[40441990]=true,[40640057]=true,[40817915]=true,[41306080]=true,[41578483]=true,[41729254]=true,[41830887]=true,[41999284]=true,[42052439]=true,[42230449]=true,[42328171]=true,[42352091]=true,[43490025]=true,[43735670]=true,[43803845]=true,[44163252]=true,[44190146]=true,[44341034]=true,[44440058]=true,[44635489]=true,[44891812]=true,[45118716]=true,[45358284]=true,[45452224]=true,[45593005]=true,[45644898]=true,[46589034]=true,[46613515]=true,[46833854]=true,[46895036]=true,[47432275]=true,[47474172]=true,[47741109]=true,[48068378]=true,[48343627]=true,[48355999]=true,[48608796]=true,[48633301]=true,[48829461]=true,[48868994]=true,[48928529]=true,[49389190]=true,[49394035]=true,[49441499]=true,[49823708]=true,[50185950]=true,[50366775]=true,[50412166]=true,[50548657]=true,[50732780]=true,[50820852]=true,[50901852]=true,[51275027]=true,[51827737]=true,[51865604]=true,[51916853]=true,[52182715]=true,[52653092]=true,[53100061]=true,[53266486]=true,[53490455]=true,[53618293]=true,[53819028]=true,[54338958]=true,[54359696]=true,[54366836]=true,[54446813]=true,[54455664]=true,[54497620]=true,[54512827]=true,[54941203]=true,[55401221]=true,[55488859]=true,[55935416]=true,[56364287]=true,[56399890]=true,[56427559]=true,[56570271]=true,[56597272]=true,[56824871]=true,[56839613]=true,[56897896]=true,[57116033]=true,[57314798]=true,[57421866]=true,[57473560]=true,[57769391]=true,[57869175]=true,[58012107]=true,[58058134]=true,[58446973]=true,[58655504]=true,[58695102]=true,[58753372]=true,[58786132]=true,[58861941]=true,[59185998]=true,[60037599]=true,[60071928]=true,[60161788]=true,[60181553]=true,[60187739]=true,[60303245]=true,[60551528]=true,[60668166]=true,[60832978]=true,[60954556]=true,[60990740]=true,[61019812]=true,[61318483]=true,[61380658]=true,[61488417]=true,[61632317]=true,[62107612]=true,[62892347]=true,[62899696]=true,[63223260]=true,[63257623]=true,[63288573]=true,[63519819]=true,[63676256]=true,[63845230]=true,[64280356]=true,[64631466]=true,[64756282]=true,[64910482]=true,[65305468]=true,[65563871]=true,[65899613]=true,[66066482]=true,[66262416]=true,[66457407]=true,[66574418]=true,[66853752]=true,[67038874]=true,[67270095]=true,[67284107]=true,[67441435]=true,[67445676]=true,[68140974]=true,[68167124]=true,[68543408]=true,[68933343]=true,[69058960]=true,[69181753]=true,[69865139]=true,[70054514]=true,[70117860]=true,[70410002]=true,[70491682]=true,[70546737]=true,[70703416]=true,[70939418]=true,[70975131]=true,[71039903]=true,[71207871]=true,[71353388]=true,[71521025]=true,[71734607]=true,[71791814]=true,[72228247]=true,[72291412]=true,[72413000]=true,[72700231]=true,[72714392]=true,[72855441]=true,[72992744]=true,[73539069]=true,[73639099]=true,[73652465]=true,[73702909]=true,[73837870]=true,[74210057]=true,[74567889]=true,[74627016]=true,[74644400]=true,[74713516]=true,[74762582]=true,[74952447]=true,[75198893]=true,[75425043]=true,[75690317]=true,[75886890]=true,[75888208]=true,[76202610]=true,[76218313]=true,[76218643]=true,[76442347]=true,[76589546]=true,[76683171]=true,[76815942]=true,[76865611]=true,[77102944]=true,[77307161]=true,[77360173]=true,[77679716]=true,[77693536]=true,[77710579]=true,[78080961]=true,[78355370]=true,[78447174]=true,[78552773]=true,[78625448]=true,[78642798]=true,[78751195]=true,[79094383]=true,[79234734]=true,[79279397]=true,[79491903]=true,[79538761]=true,[79636594]=true,[79796561]=true,[79814787]=true,[79905468]=true,[80244114]=true,[80457744]=true,[80727721]=true,[81119816]=true,[81481818]=true,[81570454]=true,[81587028]=true,[81752019]=true,[81759748]=true,[81782101]=true,[81846636]=true,[81907872]=true,[81951640]=true,[81962318]=true,[82099401]=true,[82243738]=true,[82434071]=true,[82744076]=true,[83035296]=true,[83094004]=true,[83604828]=true,[83991690]=true,[84124261]=true,[84133008]=true,[84816244]=true,[84899094]=true,[85008676]=true,[85101097]=true,[85243784]=true,[85255550]=true,[85431040]=true,[85457355]=true,[85475641]=true,[86100785]=true,[86148577]=true,[86197239]=true,[86784733]=true,[86825114]=true,[86889202]=true,[87047161]=true,[87102774]=true,[87118301]=true,[87246309]=true,[87292536]=true,[87340664]=true,[87350908]=true,[87390067]=true,[87535691]=true,[87774234]=true,[87978805]=true,[88241506]=true,[88650530]=true,[89127526]=true,[89235196]=true,[89252157]=true,[89484053]=true,[89642993]=true,[90179822]=true,[90207654]=true,[90616316]=true,[90673288]=true,[90727556]=true,[90764875]=true,[91283212]=true,[91557476]=true,[91662792]=true,[92609670]=true,[92676637]=true,[92901944]=true,[92964816]=true,[93169863]=true,[93369354]=true,[93451636]=true,[93542102]=true,[93581434]=true,[93665266]=true,[93749093]=true,[93896655]=true,[93969023]=true,[94046012]=true,[94081496]=true,[94145021]=true,[94259633]=true,[94350039]=true,[94693857]=true,[94878265]=true,[95174353]=true,[95403418]=true,[95442074]=true,[95457011]=true,[95500396]=true,[95744531]=true,[95841282]=true,[95953557]=true,[96026108]=true,[96099959]=true,[96146814]=true,[96380700]=true,[96782886]=true,[97148796]=true,[97219708]=true,[97268402]=true,[97466712]=true,[97631303]=true,[97637162]=true,[97651498]=true,[97949165]=true,[98022050]=true,[98024118]=true,[98049915]=true,[98159737]=true,[98707192]=true,[98978921]=true,[99000151]=true,[99357565]=true,[99594764]=true,
}
--disable
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local ac=0
	local loop=true
	while loop do
		ac=Duel.AnnounceCard(tp)
		if s.ids[ac] == nil then
			ac=0
			if Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
				loop=false
			end
		else
			loop=false
		end
	end
	e:SetLabel(ac)
	Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,ANNOUNCE_CARD)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local ac=e:GetLabel()
	if ac and ac>0 then
		local c=e:GetHandler()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
		e1:SetTarget(s.distg)
		e1:SetLabel(ac)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_CHAIN_SOLVING)
		e2:SetCondition(s.discon)
		e2:SetOperation(s.disop)
		e2:SetLabel(ac)
		e2:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e2,tp)
	end
end
function s.distg(e,c)
	local code=e:GetLabel()
	local code1,code2=c:GetOriginalCodeRule()
	return code1==code or code2==code
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	local code=e:GetLabel()
	local code1,code2=re:GetHandler():GetOriginalCodeRule()
	return re:IsActiveType(TYPE_MONSTER) and (code1==code or code2==code)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	Duel.NegateEffect(ev)
end