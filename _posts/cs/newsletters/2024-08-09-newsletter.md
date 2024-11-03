---
title: 'Zpravodaj „Bitcoin Optech” č. 315'
permalink: /cs/newsletters/2024/08/09/
name: 2024-08-09-newsletter-cs
slug: 2024-08-09-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Zpravodaj tento týden ohlašuje rychlejší metodu exfiltrace seedu
nazvanou Dark Skippy, shrnuje diskuzi o útocích zadržováním bloků a
navrhovaných řešeních, sdílí statistiky o rekonstruování kompaktních
bloků, popisuje útok cyklickým nahrazováním proti transakcím s
pay-to-anchor výstupy, zmiňuje nový BIP specifikující prahové
podepisování s FROST a tlumočí oznámení o vylepšeném Eftrace, které
umožňuje optimisticky ověřit důkazy s nulovou znalostí pomocí dvou
navrhovaných soft forků.

## Novinky

- **Rychlejší exfiltrace seedu:** Lloyd Fournier, Nick Farrow a
  Robin Linus zveřejnili [Dark Skippy][], vylepšený způsob exfiltrace
  klíčů z bitcoinových podpisových zařízení. Před zveřejněním jej
  [zodpovědně nahlásili][topic responsible disclosures] přibližně
  patnácti různým výrobcům hardwarových podpisových zařízení.
  _Exfiltrace klíčů_ nastává, když kód podepisování transakcí záměrně
  vytváří podpisy způsobem, který umožňuje únik informací o tajných datech,
  jako jsou soukromé klíče či [seed BIP32 hierarchické peněženky][topic
  bip32]. Po získání uživatelova seedu může útočník ukrást jeho prostředky
  v libovolné výši a v libovolný čas (včetně prostředků utracených
  v transakci, která exfiltraci provádí, pokud útočník jedná rychle).

  Autoři zmiňují, že nejlepší předchozí známý útok exfiltrací klíčů
  vyžadoval k exfiltraci jednoho BIP32 seedu desítky podpisů. S Dark Slippy
  jim postačují dva podpisy, které mohou patřit jediné transakci s dvěma
  vstupy. Uživatelovy prostředky mohou tedy být v ohrožení od okamžiku
  prvního pokusu o poslání peněz.

  Exfiltrace klíčů může být vykonána kteroukoliv logikou, která vytváří
  podpisy, včetně softwarových peněženek, avšak obecně se očekává, že
  softwarová peněženka se zákeřným kódem jednoduše útočníkovi pošle seed
  přes internet. Exfiltrace se převážně považuje za hrozbu hardwarovým
  podpisovým zařízením, které nemají přístup na internet. Zařízení s podvrácenou
  logikou, ať již ve firmwaru či přímo v hardwaru, je nyní schopné
  rychle exfiltrovat seed, aniž by kdy bylo připojeno k počítači (např.
  jsou-li všechna data přenášena pomocí NFC, SD karet či QR kódů).

  Způsoby podepisování v bitcoinu, které jsou [odolné vůči exfiltraci][topic
  exfiltration-resistant signing], již byly diskutovány (včetně
  zpravodajů Optechu sahajících až ke [zpravodaji č. 87][news87 anti-exfil],
  _angl._) a pokud víme, jsou v současnosti implementovány ve dvou
  hardwarových podpisových zařízeních (viz [zpravodaj č. 136][news136
  anti-exfil], _angl._). Tato používaná metoda vyžaduje jedno kolo komunikace
  navíc oproti standardnímu podepisování s jedním podpisem. To však nemusí
  být považováno za nevýhodu, pokud si uživatelé zvyknou na jiné druhy
  podepisování, jako jsou [bezskriptové vícenásobné podpisy][topic multisignature],
  které též vyžadují více komunikace. Jsou známé i jiné způsoby odolného
  podepisování, které nabízejí odlišné kompromisy, avšak pokud víme,
  žádný z nich nebyl v bitcoinových podpisových zařízeních implementován.

  Optech doporučuje každému, kdo používá hardwarová podpisová zařízení
  k ochraně významného množství peněz, aby se před podvodným hardwarem
  či firmwarem chránil, například používáním podpisů odolných vůči
  exfiltraci nebo používáním několika nezávislých zařízení (např.
  se skriptovými či bezskriptovými vícenásobnými podpisy nebo s prahovým
  podepisováním).

- **Útoky zadržováním bloků a možná řešení:**
  Anthony Towns zaslal do emailové skupiny Bitcoin-Dev [příspěvek][towns
  withholding] o [útoku zadržováním bloků][topic block withholding],
  s ním souvisejícím útoku _nevalidních share_ a o možných řešeních
  obou útoků, mimo jiné znemožněním výběrů transakcí klienty ve
  [Stratum v2][topic pooled mining] nebo pomocí zapomnětlivých share.

  Těžaři v poolu jsou placeni za posílání jednotek práce, kterým se říká
  _share_, z nichž každý je _kandidátem na blok_ obsahující určité
  množství proof of work (PoW). Očekává se, že určitý známý podíl
  těchto share bude obsahovat dostatečný PoW na začlenění do blockchainu.
  Například mají-li share PoW tisícinu PoW validního bloku, pool očekává,
  že bude za každý validní blok platit v průměru za tisíc share. Klasický
  útok zadržováním bloků nastává, když těžař v poolu neodešle tento tisící
  share s validním blokem, ale odešle zbývajících 999 share, které validními
  bloky nejsou. To umožňuje těžařovi obdržet peníze za 99,9 % své práce,
  ale nedovolí poolu od tohoto těžaře získat jakýkoliv příjem.

  Stratum v2 umožňuje, aby pool povolil těžařům začleňovat do svých
  bloků odlišnou množinu transakcí, než kterou navrhuje pool. Těžař
  v poolu se může dokonce pokoušet těžit transakce, které pool nezná.
  Tím může být pro pool ověřování share nákladné: každý share může
  obsahovat i několik megabajtů transakcí, které pool nikdy předtím
  neviděl a které mohou být vytvořené pro zpomalení validace. Infrastruktura
  poolu tak může být snadno přetížena, což mu znemožní přijímat share od
  čestných uživatelů.

  Pooly se mohou tomuto problému vyhnout tím, že budou validovat pouze
  PoW každého share namísto validace transakcí. To by však umožnilo
  těžařům v poolu obdržet platby za odeslání nevalidních share ve 100 %
  případů, což je ještě horší než zhruba 99,9 % případů, ve kterých
  mohou obdržet platby během klasického útoku zadržováním bloků.

  Tímto mají pooly motivaci buď výběr transakcí klientům zakázat nebo
  vyžadovat, aby se těžaři v poolu spolehlivě identifikovali (například
  jménem z dokumentu vydaného vládou), aby mohli být nečestní hráči
  vylučováni.

  Jedním z řešení navržených Townsem je, aby pooly nabízely k výběru
  více šablon bloků. Podobný systém dnes používá [Ocean Pool][].
  Takové share mohou být validovány rychle a s využitím minimálního
  množství přenosového pásma. To zabrání 100% výplatám za posílání
  nevalidních bloků, ale nepomůže útokům zadržováním bloků, které
  dosahují kolem 99,9% profitu.

  Pro zabránění útoku zadržováním bloků navrhuje Towns upravený
  nápad [původně navržený][rosenfeld pool] Menim Rosenfeldem v roce
  2011, dle kterého by koncepčně jednoduchý hard fork mohl zabránit těžařovi
  v poolu, aby se dozvěděl, zda množství vykonaného PoW konkrétního share
  stačilo na validní blok. Takový share se nazývá _zapomnětlivý share_
  (oblivious share). Útočník, který není schopen rozlišit mezi PoW
  validního bloku a běžného share může pool obrat o příjem stejnou měrou
  jako sám sebe. Tento přístup má několik nevýhod:

  - *Hard fork s dopadem na SPV:* všechny návrhy hard forků vyžadují upgrade
    po všech plných uzlech. Avšak mnoho z nich (například návrhy na
    navýšení velikosti bloku jako [BIP103][]) nevyžadují upgrade
    lehkých klientů, které používají _zjednodušené ověřování plateb_
    (simplified payment validation, SPV). Tento návrh mění interpretaci
    polí v hlavičce bloku a vyžadoval by tak upgrade od všech lehkých
    klientů. Towns nabízí alternativu, která by po lehkých klientech nevyžadovala
    upgrade, ale výrazně by snížila jejich bezpečnost.

  - *Vyžaduje od těžařů v poolu používat tajnou šablonu:* nejen by byla tato
    šablona vyžadována, aby mohlo být zabráněno útoku 100% nevalidními share,
    ale pool by navíc musel tuto šablonu před těžaři držet v tajnosti až do
    doby, kdy pool obdrží všechny share používající tuto šablonu. Pool by toho
    mohl využít jako lsti k donucení těžařů věnovat PoW k těžení transakcí,
    ke kterým by měli výhrady. Expirované šablony by ale mohly být publikovány
    pro účely auditu. Většina moderních poolů generuje nové šablony každých
    několik sekund, auditování by tak mohlo být prováděno téměř v reálném
    čase. Záškodnický pool by tak mohl klamat těžaře jen více než pár sekund.

  - *Vyžaduje zasílání share:* jednou z výhod Stratum v2 (v určitých režimech
    provozu) je, že čestní těžaři, kteří pro pool naleznou blok, jej mohou
    okamžitě zveřejnit v P2P síti. Tím může propagace bloku začít ještě před tím,
    než se share dostane k serveru poolu. Se zapomnětlivými share by share musely
    být nejdříve přijaty poolem, přeměněny do kompletního bloku a teprve tehdy
    by mohl být blok zveřejněn.

  Towns uzavírá popisem motivace bránění útoku: postihuje malé pooly více než velké
  a útoky na pooly s anonymními těžaři nestojí téměř nic, zatímco pooly
  vyžadující identifikaci těžařů mohou útočníky zabanovat. Oprava zadržování
  bloků by mohla rozvinout anonymnější a více decentralizovanou těžbu.

- **Statistika rekonstruování kompaktních bloků:** vývojář 0xB10C
  zaslal do fóra Delving Bitcoin [příspěvek][0xb10c compact] popisující
  spolehlivost rekonstruování [kompaktních bloků][topic compact block relay].
  Mnoho přeposílajících plných uzlů používá kompaktní bloky dle
  [BIP152][] již od doby, kdy byly v roce 2016 do Bitcoin Core 0.13.0
  přidány. Pokud dva spojené uzly již oba znají některé nepotvrzené
  transakce, mohou po potvrzení v novém bloku na tyto transakce odkázat
  krátkou referencí namísto opakovaného přeposlání celé transakce.
  To výrazně snižuje požadované přenosové pásmo a latenci, díky čemuž
  se nové bloky propagují rychleji.

  Rychlejší propagace nových bloků snižuje množství nahodilých štěpení
  blockchainu. Méně štěpení redukuje plýtvání proof of work (PoW) a snižuje
  počet výskytů _honby za bloky_ (block races) nahrávajících větším těžebním
  poolům. Tím přispívá k většímu zabezpečení a větší decentralizaci
  bitcoinu.

  Avšak někdy bloky obsahují transakce, které uzel předtím neviděl. V takovém
  případě musí obvykle uzel přijímající kompaktní blok požádat posílající
  uzel o kompletní transakce a poté počkat na odpověď. To propagaci nových
  bloků zpomaluje. Dokud uzel neobdrží všechny transakce bloku, nemůže jej
  validovat a rozeslat dále. Počet nahodilých štěpení blockchainu
  se tím zvyšuje, zabezpečení PoW se snižuje a roste tlak na centralizaci.

  Z tohoto důvodu je užitečné sledovat, jak často poskytují kompaktní
  bloky všechny informace potřebné k okamžité validaci nového bloku
  bez nutnosti potřeby požádat o dodatečné transakce (_úspěšná rekonstrukce_).
  Gregory Maxwell [nedávno reportoval][maxwell reconstruct] o poklesu
  počtu úspěšných rekonstrukcí u uzlů provozujících Bitcoin Core ve výchozím
  nastavení, obzvláště v porovnání s uzly aktivujícími volbu `mempoolfullrbf`.

  Vývojář 0xB10C tento týden poskytl přehled počtu úspěšných rekonstrukcí,
  které zaznamenaly jeho uzly s různými nastaveními. Některá data sahala
  až šest měsíců do minulosti. Čerstvější údaje o dopadu aktivovaného
  `mempoolfullrbf` zabírají pouze poslední týden, avšak shodují se
  s Maxwellovým pozorováním. To přispělo k úvahám o přijetí [pull
  requestu][bitcoin core #30493], který by v nadcházejících verzích
  Bitcoin Core volbu `mempoolfullrbf` aktivoval ve výchozím nastavení.

- **Cyklické nahrazování útočící na pay-to-anchor:** Peter Todd zaslal
  do emailové skupiny Bitcoin-Dev [příspěvek][todd cycle] o výstupu
  typu pay-to-anchor (P2A), který je součástí návrhu na [dočasné
  anchory][topic ephemeral anchors] (ephemeral anchors). P2A je
  výstupem transakce, který může utratit kdokoliv. To může být
  užitečné u navyšování poplatků pomocí [CPFP][topic cpfp], obzvláště
  u protokolů s více účastníky jako LN. Avšak CPFP navyšování je
  v současnosti v LN náchylné na [útok cyklickým nahrazováním][topic
  replacement cycling] (replacement cycling attack), při kterém
  záškodnická protistrana provádí dvoukrokový proces. V prvním kroku
  protistrana [nahradí][topic rbf] transakci čestného uživatele svou
  verzí.  Nahrazenou transakci potom nahradí transakcí, která se
  nevztahuje ani na jednu z verzí. V případě, kdy má LN kanál
  nevyřízená [HTLC][topic htlc], může úspěšně provedený útoky umožnit
  protistraně ukrást prostředky čestné strany.

  Pokud je použit současný druh kanálů s [anchor výstupy][topic anchor
  outputs], může útok provést pouze protistrana. Avšak Todd poznamenává,
  že jelikož P2A výstup může utratit kdokoliv, může také kdokoliv provést
  útok cyklickým nahrazením proti transakcím, které P2A používají. I tehdy
  však může na útoku vydělat pouze protistrana, neexistuje tedy pro třetí
  strany přímá motivace k útoku na P2A výstupy. Útok může být dokonce
  zdarma v případě, kdy útočník plánuje zveřejnit svou vlastní transakci
  s jednotkovým poplatkem vyšším, než jaký má P2A čestného uživatele, a kdy
  se útočníkovi podaří úspěšně dokončit cyklus nahrazení, aniž by byl jejich
  mezistav potvrzen těžaři. Všechna současná opatření v LN proti útokům
  cyklickým nahrazením (viz [zpravodaj č. 274][news274 cycle mitigate]) budou
  srovnatelně účinná i v případě P2A.

- **Návrh BIPu na bezskriptové prahové podpisy:** Sivaram Dhakshinamoorthy
  zaslal do emailové skupiny Bitcoin-Dev [příspěvek][dhakshinamoorthy frost]
  ohlašující [návrh BIPu][frost sign bip] na vytváření [bezskriptových
  prahových podpisů][topic threshold signature] pro bitcoinovou implementaci
  [Schnorrových podpisů][topic schnorr signatures]. To umožní skupině
  podepisujících, kteří předtím provedli nastavující proceduru (např.
  pomocí [ChillDKG][news312 chilldkg]), aby vytvořili podpisy vyžadující
  interakci pouze nějaké dynamické podmnožiny všech podepisujících.
  Podpisy onchain jsou neodlišitelné od Schnorrových podpisů vytvořených
  jedním uživatelem nebo více uživateli jako multisig. To přispívá
  soukromí a nahraditelnosti mincí.

- **Optimistické ověřování důkazů s nulovou znalostí pomocí CAT, MATT a Elftrace:**
  Johan T. Halseth zaslal do fóra Delving Bitcoin [příspěvek][halseth zkelf]
  s oznámením, že jeho nástroj [Elftrace][] má nově schopnost ověřovat
  důkazy s nulovou znalostí (zero-knowledge proofs, ZKP). Pro používání onchain
  bude potřeba aktivovat soft forky [OP_CAT][topic op_cat] a [MATT][topic acc].

## Bitcoin Core PR Review Club

*V této měsíční rubrice shrnujeme nedávné sezení [Bitcoin Core PR Review Club][] a
vyzdvihujeme některé z důležitých otázek a odpovědí. Klikněte na otázku a odpověď se vám odhalí.*

  [Přidej PayToAnchor(P2A), OP_1 <0x4e73>, jako standardní výstupní skript
  pro platby][review club 30352] je PR od [instagibbs][gh instagibbs],
  které přináší nový typ výstupního skriptu `TxoutType::ANCHOR`. Anchor výstupy
  mají výstupní skript `OP_1 <0x4e73>` (což odpovídá adrese [`bc1pfeessrawgf`][mempool
  bc1pfeessrawgf]). Po označení těchto výstupů za standardní budou moci být
  vytvářené a přeposílané platby z anchor výstupů.

{% include functions/details-list.md
  q0="Jakým `TxoutType` byl před tímto PR klasifikován `scriptPubKey`
  `OP_1 <0x4e73>`?"
  a0="Jelikož sestává z jednobajtového push kódu (`OP_1`) a dvoubajtových dat
  (`0x4e73`), jedná se o validní v1 witness výstup. Protože nemá 32 bajtů,
  nelze jej označit za `WITNESS_V1_TAPROOT`, proto je typu
  `TxoutType::WITNESS_UNKNOWN`."
  a0link="https://bitcoincore.reviews/30352#l-18"

  q1="Na základě odpovědi na předchozí otázku, bylo by standardní vytvořit výstup
  tohoto druhu? Jak by to bylo s jeho utracením? (Tip: jak s tímto typem nakládají
  [`IsStandard`][gh isstandard] a [`AreInputsStandard`][gh areinputsstandard]?)"
  a1="Protože `IsStandard` (používaný pro kontrolu výstupů) považuje za
  nestandardní pouze `TxoutType::NONSTANDARD`, vytváření by bylo standardní.
  Protože `AreInputsStandard` považuje transakci utrácející z `TxoutType::WITNESS_UNKNOWN`
  za nestandardní, nebylo by standardní tento výstup utrácet."
  a1link="https://bitcoincore.reviews/30352#l-24"

  q2="Jaké výstupy mohly být před tímto PR ve výchozím nastavení _vytvořené_
  ve standardní transakci? Jsou stejné jako typy skriptů, které mohou být ve
  standardní transakci _utracené_?"
  a2="Vytvořené mohou být všechny `TxoutType` kromě `TxoutType::NONSTANDARD`.
  Utracené mohou být všechny `TxoutType` kromě `TxoutType::NONSTANDARD` a
  `TxoutType::WITNESS_UNKNOWN` (ačkoliv utratit `TxoutType::NULL_DATA` je nemožné)."
  a2link="https://bitcoincore.reviews/30352#l-42"

  q3="Definujte _anchor výstup_, aniž byste zmínili transakce v Lightning Network
  (pojměte to obecně)."
  a3="Anchor výstup je dodatečný výstup vytvořený v předem podepsané transakci,
  který v době zveřejnění umožňuje přidat poplatky pomocí CPFP. Pro více informací
  viz [téma anchor výstupů][topic anchor outputs]."
  a3link="https://bitcoincore.reviews/30352#l-48"

  q4="Proč záleží na velikosti výstupního skriptu anchor výstupu?"
  a4="Kvůli velkému výstupnímu skriptu by bylo nákladnější transakci přeposílat a
  prioritizovat."
  a4link="https://bitcoincore.reviews/30352#l-66"

  q5="Kolik virtuálních bajtů je potřeba pro vytvoření a utracení P2A výstupu?"
  a5="Vytvoření P2A výstupu vyžaduje 13 vbyte. Utracení 41 vbyte."
  a5link="https://bitcoincore.reviews/30352#l-120"

  q6="Třetí commit [přidává][gh 30352 3rd commit] do `IsWitnessStandard` klauzuli `if
  (prevScript.IsPayToAnchor()) return false`. Co to znamená a proč je to potřeba?"
  a6="Zajišťuje, že anchor výstup může být utracen pouze bez witnessů.
  To zabraňuje útočníkovi vzít čestnou transakci, přidat data witnessu
  a dále ji distribuovat s vyšším absolutním, avšak nižším jednotkovým
  poplatkem. To by nutilo čestného uživatele platit víc a víc na její
  nahrazení."
  a6link="https://bitcoincore.reviews/30352#l-154"
%}

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [Libsecp256k1 0.5.1][] je menším vydáním této knihovny bitcoinových
  kryptografických funkcí. Mění výchozí velikost předem vypočítané tabulky
  pro podepisování na stejnou velikost jako v Bitcoin Core a přidává
  příklad pro výměnu klíčů založenou na ElligatorSwift (protokol používaný
  v [šifrovaném P2P přenosu verze 2][topic v2 p2p transport]).

- [BDK 1.0.0-beta.1][] je kandidátem na vydání této knihovny pro budování
  peněženek a jiných bitcoinových aplikací. Původní rustový crate `bdk`
  byl přejmenován na `bdk_wallet` a moduly nižší úrovně byly extrahovány
  do vlastních crate: `bdk_chain`, `bdk_electrum`, `bdk_esplora` a `bdk_bitcoind_rpc`.
  `bdk_wallet` je „první verzí se stabilním 1.0.0 API.”

## Významné změny kódu a dokumentace

_Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Bitcoin Inquisition][bitcoin inquisition repo] a [repozitáři BINANA][binana
repo]._

- [Bitcoin Core #30493][] přináší aktivní [full RBF][topic rbf] jako výchozí nastavení.
  I nadále umožní provozovatelům uzlů jej vypnout. Full RBF umožňuje nahrazení
  jakékoliv nepotvrzené transakce i bez [BIP125][bip125 github] signalizace.
  Volbu bylo možné aktivovat od července 2022 (viz [zpravodaj č. 208][news208 fullrbf],
  _angl._), ale byla ve výchozím nastavení neaktivní. [Zpravodaj č. 263][news263 fullrbf]
  popisuje diskuzi o aktivaci ve výchozím nastavení.

- [Bitcoin Core #30285][] přidává do [cluster mempoolu][topic cluster mempool]
  dva klíčové algoritmy [linearizace clusterů][wuille cluster]:
  `MergeLinearizations` pro kombinaci dvou existujících linearizací a
  `PostLinearize` pro modifikaci linearizace přidáním dodatečného zpracování.
  PR staví na práci představené minulý týden ve [zpravodaji č. 314][news314
  cluster].

- [Bitcoin Core #30352][] přináší nový typ výstupu Pay-To-Anchor (P2A) a označuje
  jeho utracení za standardní. Tento typ výstupu může být utracen kýmkoliv.
  Umožňuje kompaktní anchory pro navyšování poplatků dle [CPFP][topic cpfp],
  které jsou odolné vůči poddajnosti txid (viz [zpravodaj č. 277][news277 p2a]).
  V kombinaci s [TRUC][topic v3 transaction relay] transakcemi přináší pokrok
  v implementaci [dočasných anchorů][topic ephemeral anchors], které v LN nahradí
  [anchor výstupy][topic anchor outputs] založené na [CPFP výjimce][topic
  cpfp carve out] z pravidel přeposílání.

- [Bitcoin Core #29775][] přidává konfigurační volbu `testnet4`, která nastaví
  síť na [testnet4][topic testnet] dle specifikace v [BIP94][]. Testnet4
  obsahuje opravy několika problémů s předchozím testnet3 (viz [zpravodaj č.
  306][news306 testnet]). Stávající konfigurační volba Bitcoin Core `testnet`
  (pro testnet3) zůstává dostupná, ale očekává se, že bude v budoucích
  vydáních odstraněna.

- [Core Lightning #7476][] implementuje do [nabídek][topic offers] nedávné změny
  [BOLT12 specifikace][bolt12 spec]. Nově bude v nabídkách a žádostech o fakturu
  odmítat [zaslepené cesty][topic rv routing] nulové délky. Dále umožní vynechat
  v nabídkách pole `offer_issuer_id`, pokud je poskytnuta zaslepená cesta. V takových
  případech bude finální zaslepený klíč shodný s klíčem, který podepíše fakturu.
  Očekává se, že autor nabídky má k tomuto klíči přístup.

- [Eclair #2884][] implementuje [BLIP4][] pro [HTLC atestace][topic htlc endorsement]
  (HTLC endorsements), čímž se stává jejich první LN implementací. HTLC atestace
  slibují částečně bránit [útokům zahlcením kanálu][topic channel jamming
  attacks]. PR aktivuje volitelné přeposílání příchozích atestací. Přeposílající
  uzly samy určí, zda atestaci během přeposílání [HTLC][topic htlc] připojit.
  Pokud by v síti došlo k širokému nasazení HTLC atestací, mohla by taková
  HTLC obdržet preferenční zacházení, například přístup k vzácným síťovým zdrojům.
  Implementace staví na předchozí práci popsané ve [zpravodaji č. 257][news257 eclair].

- [LND #8952][] refaktoruje komponentu `channel` v `lnwallet`. Nově bude používat
  typovaný `List`. Jedná se o součást série PR implementující dynamické commitmenty,
  jeden druh [upgradu commitmentů kanálu][topic channel commitment upgrades].

- [LND #8735][] přidává možnost generovat faktury se [zaslepenými cestami][topic rv routing]
  pomocí příznaku `-blind` příkazu `addinvoice`. Dále též umožňuje za takové faktury
  zaplatit. Jedná se pouze o implementaci pro [BOLT11][], neboť [BOLT12][topic offers]
  není ještě v LND implementován. [LND #8764][] k předchozímu PR přidává možnost
  použít během platby faktury více zaslepených cest pro vykonání plateb
  s více cestami ([MPP][topic multipath payments]).

- [BIPs #1601][] začleňuje [BIP94][], který přidává specifikaci testnet4, nové verze
  [testnetu][topic testnet]. Obsahuje vylepšení pravidel konsenzu, která by měla
  zabránit snadným útokům na síť. Všechny předchozí mainnetové soft forky jsou v
  testnet4 aktivní od prvního bloku a ve výchozím nastavení je použit port `48333`.
  Zpravodaje [č. 306][news306 testnet4] a [č. 311][news311 testnet4] poskytují
  více informací o problémech testnet3 a změnách v testnet4.

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="30493,30285,30352,30562,7476,2884,8952,8735,8764,1601,29775" %}
[BDK 1.0.0-beta.1]: https://github.com/bitcoindevkit/bdk/releases/tag/v1.0.0-beta.1
[libsecp256k1 0.5.1]: https://github.com/bitcoin-core/secp256k1/releases/tag/v0.5.1
[news274 cycle mitigate]: /cs/newsletters/2023/10/25/#opatreni-proti-replacement-cycling-nasazena-v-ln-uzlech
[dark skippy]: https://darkskippy.com/
[news87 anti-exfil]: /en/newsletters/2020/03/04/#proposal-to-standardize-an-exfiltration-resistant-nonce-protocol
[news136 anti-exfil]: /en/newsletters/2021/02/17/#anti-exfiltration
[towns withholding]: https://mailing-list.bitcoindevs.xyz/bitcoindev/Zp%2FGADXa8J146Qqn@erisian.com.au/
[0xb10c compact]: https://delvingbitcoin.org/t/stats-on-compact-block-reconstructions/1052
[maxwell reconstruct]: https://github.com/bitcoin/bitcoin/pull/30493#issuecomment-2260918779
[todd cycle]: https://mailing-list.bitcoindevs.xyz/bitcoindev/ZqyQtNEOZVgTRw2N@petertodd.org/
[dhakshinamoorthy frost]: https://mailing-list.bitcoindevs.xyz/bitcoindev/740e2584-5b6c-47f6-832e-76928bf613efn@googlegroups.com/
[frost sign bip]: https://github.com/siv2r/bip-frost-signing
[halseth zkelf]: https://delvingbitcoin.org/t/optimistic-zk-verification-using-matt/1050
[ocean pool]: https://ocean.xyz/blocktemplate
[rosenfeld pool]: https://bitcoil.co.il/pool_analysis.pdf
[elftrace]: https://github.com/halseth/elftrace
[news306 testnet]: /cs/newsletters/2024/06/07/#bip-a-experimentalni-implementace-testnet4
[news312 chilldkg]: /cs/newsletters/2024/07/19/#protokol-pro-distribuovane-generovani-klicu-pro-frost
[bip125 github]: https://github.com/bitcoin/bips/blob/master/bip-0125.mediawiki
[news208 fullrbf]: /en/newsletters/2022/07/13/#bitcoin-core-25353
[news263 fullrbf]: /cs/newsletters/2023/08/09/#full-rbf-ve-vychozim-stavu
[wuille cluster]: https://delvingbitcoin.org/t/introduction-to-cluster-linearization/1032
[news314 cluster]: /cs/newsletters/2024/08/02/#bitcoin-core-30126
[bolt12 spec]: https://github.com/lightning/bolts/pull/798
[news257 eclair]: /cs/newsletters/2023/06/28/#eclair-2701
[news306 testnet4]: /cs/newsletters/2024/06/07/#bip-a-experimentalni-implementace-testnet4
[news311 testnet4]: /cs/newsletters/2024/07/12/#bitcoin-core-pr-review-club
[news277 p2a]: /cs/newsletters/2023/11/15/#odstraneni-poddajnosti-docasnych-anchoru
[review club 30352]: https://bitcoincore.reviews/30352
[gh instagibbs]: https://github.com/instagibbs
[mempool bc1pfeessrawgf]: https://mempool.space/address/bc1pfeessrawgf
[gh isstandard]: https://github.com/bitcoin/bitcoin/blob/fa0b5d68823b69f4861b002bbfac2fd36ed46356/src/policy/policy.cpp#L7
[gh areinputsstandard]: https://github.com/bitcoin/bitcoin/blob/fa0b5d68823b69f4861b002bbfac2fd36ed46356/src/policy/policy.cpp#L177
[gh 30352 3rd commit]: https://github.com/bitcoin-core-review-club/bitcoin/commit/ccad5a5728c8916f8cec09e838839775a6026293#diff-ea6d307faa4ec9dfa5abcf6858bc19603079f2b8e110e1d62da4df98f4bdb9c0R228-R232
