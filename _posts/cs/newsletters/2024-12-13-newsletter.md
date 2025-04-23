---
title: 'Zpravodaj „Bitcoin Optech” č. 333'
permalink: /cs/newsletters/2024/12/13/
name: 2024-12-13-newsletter-cs
slug: 2024-12-13-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Zpravodaj tento týden popisuje zranitelnost, která umožňovala okrást
starší verze LN implementací, oznamuje zranitelnost způsobující
deanonymizaci u Wasabi a souvisejícího software, shrnuje příspěvek a
diskuzi o vyčerpání LN kanálů, odkazuje na dotazník na názory o vybraných
návrzích kovenantů, popisuje dva druhy pseudokovenantů založených na
incentivách a odkazuje na shrnutí pravidelného osobního setkání
vývojářů Bitcoin Core. Též nechybí naše pravidelné rubriky se souhrnem
sezení Bitcoin Core PR Review Clubu, seznamem změn ve službách a klientském
software, odkazy na oblíbené otázky a odpovědi z Bitcoin Stack Exchange,
oznámeními nových vydání a popisem významných změn v populárním
bitcoinovém páteřním software.

## Novinky

- **Zranitelnost umožňující s těžařovou asistencí krádež z LN kanálů:**
  David Harding ve fóru Delving Bitcoin [oznámil][harding irrev] zranitelnost,
  kterou dříve tento rok [zodpovědně nahlásil][topic responsible disclosures].
  Starší verze Eclair, LDK a LND ve výchozím nastavení umožňovaly straně,
  která otevřela kanál, ukrást až 98 % jeho hodnoty. Core Lightning zůstává
  nadále zranitelný, pokud se použije volba `--ignore-fee-limits` (není
  ve výchozím nastavení aktivní, v dokumentaci je označena za nebezpečnou).

  Byly též popsány dvě méně závažné verze této zranitelnosti. Všechny
  implementace LN vyjmenované výše se pokouší tato rizika snížit, avšak
  kompletní řešení čeká na [přeposílání balíčků][topic package relay],
  [upgradování kanálů][topic channel commitment upgrades] a jiné
  související projekty.

  Zranitelnost zneužívá vlastnosti LN protokolu, která umožňuje, aby
  transakce starého stavu kanálu měla vyšší onchain poplatky, než kolik
  strana platící poplatky v aktuálním stavu vlastní. Na příklad Mallory,
  která kontroluje 99 % zůstatku kanálu, vyčlení 98 % celkové hodnoty
  kanálu na [endogenní][topic fee sourcing] poplatky (tj. poplatky, které
  jsou přímo součástí transakce). Nato vytvoří nový stav, který platí pouze
  minimální poplatky, a přepošle 99 % zůstatku kanálu Bobovi. Mallory poté
  osobně vytěží starý stav platící 98% poplatek, který si ponechá. Tím
  sníží maximální hodnotu, kterou může Bob obdržet onchain z očekávaných
  99 % na 2 %. Mallory může současným použitím této metody okrást zhruba
  3 000 kanálů v bloku (každý kanál může potenciálně patřit jiné
  oběti). Je-li průměrná hodnota kanálu 20 000 Kč, může tím v jednom bloku
  ukrást kolem 60 000 000 Kč.

  Pokud by si uživatel útoku včas všiml, nebyl by schopen vypnutím svých
  LN uzlů prostředky ochránit, neboť Mallory mohla již všechny potřebné
  stavy vytvořit předem. I kdyby se oběť pokusila vynuceně své kanály
  zavřít ve svém posledním stavu (tedy kdy v příkladu Bob kontroluje
  99 % hodnoty), Mallory by mohla obětovat 1 % hodnoty a získat 98 %.

  Nejhorší scénář byl v implementacích opraven a méně závažným variantám částečně
  předchází omezením maximální částky, která může být vyčleněná na
  poplatky.  Jelikož poplatky v dřívějších stavech mohou i nadále být
  vyšší, než kolik strana platící poplatky v pozdějším stavu vlastní,
  krádež je stále možná, avšak její částka je omezená. Kompletní řešení
  čeká na pokrok v používání plně [exogenních][topic fee sourcing] poplatků
  (tj.  poplatků, které mohou být zaplaceny později pomocí navýšení), např.
  by všechny commitment transakce platily stejný poplatek, což závisí na
  robustním přeposílání balíčků pro [CPFP][topic cpfp] navyšování poplatků
  v bitcoinovém P2P protokolu a upgradování commitment transakcí v LN.

- **Zranitelnost způsobující deanonymizaci ve Wasabi a souvisejícím software:**
  vývojář GingerWallet [zveřejnil][drkgry deanon] způsob,
  kterým by mohl koordinátor [coinjoinu][topic coinjoin] zabránit
  uživatelům v získání jakéhokoliv soukromí. Novinář Bitcoin Magazine Shinobi
  [uvedl][shinobi deanon], že původně zranitelnost objevil Yuval Kogman
  v roce 2021 a [nahlásil][wasabi #5439] ji vývojářům Wasabi spolu
  s několika dalšími problémy. Optech od poloviny roku 2022 věděl, že
  Kogman měl vážné obavy o nasazených verzích Wasabi, avšak nepovažovali
  jsme za nutné je hlouběji prozkoumat. Za naši chybu se jemu a uživatelům
  Wasabi omlouváme.

- **Zjištění o vyčerpání kanálů:** René Pickhardt zaslal do fóra Delving
  Bitcoin [příspěvek][pickhardt deplete] a [zúčastnil][dd deplete] se spolu
  s Christianem Deckerem podcastu Optech Deep Dive o svém výzkumu matematických
  základů sítí platebních kanálů (jmenovitě LN). Jeho příspěvek ve fóru
  se obzvláště soustředil na objev, že některé kanály v cirkulárních cestách
  se nakonec vyčerpají, pokud je trasa dostatečně používaná. Pokud se kanál
  efektivně zcela vyčerpá (tj. nemůže přeposlat další platby ve směru, ve kterém
  k vyčerpání došlo), je cirkulární cesta (cyklus) porušena. Jak postupně
  dochází k porušení cyklů v grafu sítě, konverguje síť do zbytkového grafu,
  který nemá žádné cykly (kostra grafu). To se shoduje s [dřívějším nálezem][guidi
  spanning] výzkumníka Gregoria Guidiho, ačkoliv Pickhardt k němu došel
  jiným přístupem. Výsledky zřejmě potvrzuje i nepublikovaný výzkum
  Anastasiose Sidiropoulose.

  ![Příklad cyklu, vyčerpání a zbytkové kostry grafu](/img/posts/2024-12-depletion-cs.png)

  Zřejmě nejvýznamnějším nálezem tohoto výzkumu je, že rozsáhlé vyčerpání
  kanálů se objeví i v cirkulární ekonomice, kde žádné uzly nejsou v roli
  zdrojů (tedy čistí plátci) ani odtoků (čistí příjemci). LN by konvergovala
  ke kostře grafu, i kdyby byla používána na každou platbu: od zákazníka
  k obchodu, od obchodu k obchodu i od obchodu k zaměstnanci.

  Není zřejmé, zda by uzly chtěly, aby jejich kanály byly součástí
  zbytkové kostry grafu nebo ne. Na jednu stranu kostra reprezentuje poslední
  součást sítě, která by stále mohla přeposílat platby (odpovídá topologii
  rozjezdu, též nazývané hub-and-spoke), může tedy umožnit účtovat ve zbytkových
  kanálech vysoké poplatky za přeposílání. Na druhou stranu jsou
  zbytkové kanály tím, co zbylo po vyčerpání všech ostatních kanálů vybranými
  poplatky.

  Ačkoliv má kanál s vyššími poplatky menší pravděpodobnost vyčerpání (pokud
  jsou všechny ostatní podmínky beze změny), vlastnosti ostatních kanálů
  ve stejném cyklu hrají v pravděpodobnosti vyčerpání velkou roli. Pro
  provozovatele uzlu je tak náročné pokusit se zabránit vyčerpání nastavením
  vlastních poplatků za přeposílání.

  Kanály s vyšší kapacitou mají též menší pravděpodobnost vyčerpání než kanály
  s nižší kapacitou. To se jeví jako zřejmé, avšak podrobné hledání důvodů
  přinese překvapivé zjištění o offchain protokolech s více než dvěma účastníky.
  Kanál s vyšší kapacitou podporuje mezi účastníky vyšší počet distribucí bohatství,
  platby přes tento kanál zůstávají proveditelné, i když ekvivalentní platby
  přes kanály o nižší kapacitě by již vyčerpaly zůstatek jedné ze stran.
  U dvou účastníků, jako je tomu v současné generaci LN kanálů, zvýší každý
  satoshi přidaný ke kapacitě rozsah distribucí bohatství o jednu. Avšak u
  [továren kanálů][topic channel factories] a jiných konstrukcí s více stranami,
  které umožňují přemisťovat prostředky offchain mezi _k_ stranami, zvýší každý
  satoshi přidaný ke kapacitě rozsah distribucí bohatství o jednu _pro
  každou z k stran_. Exponenciálně se tak zvyšuje počet proveditelných plateb
  a snižuje riziko vyčerpání.

  Vezměme si jako příklad současnou LN, kde má Alice kanály s Bobem a Carol
  a ti mají kanál mezi sebou: {AB, AC, BC}. Každý kanál má kapacitu 1 BTC.
  V této konfiguraci může Alice kontrolovat (a tedy poslat nebo obdržet) maximálně
  2 BTC. Stejný limit se týká Boba i Carol. Tyto limity by též platily, i kdyby
  se v továrně kanálů použily 3 BTC na opětovné vytvoření všech tří kanálů.
  Pokud by však továrna zůstala v provozu, jedna aktualizace offchain stavu mezi
  všemi třemi stranami by mohla vymazat kanál mezi Bobem a Carol, což by
  Alici umožnilo kontrolovat až plné 3 BTC (mohla by tedy poslat nebo přijmout
  3 BTC). Následná aktualizace stavu by mohla to stejné učinit pro Boba a
  Carol, a tím i jim umožnit odeslat nebo přijmout až 3 BTC. Tento způsob
  používání offchain protokolů s více stranami umožňuje, aby stejné množství
  kapitálu dalo každému z účastníků přístup ke kanálům s vyšší kapacitou,
  které se méně pravděpodobně vyčerpají. Menší pravděpodobnost vyčerpání
  a vyšší rozsah proveditelných plateb odpovídají vyšší maximální propustnosti
  LN, jak Pickhardt již dříve popsal (viz zpravodaje [č. 309][news309 feasible]
  a [č. 325][news325 feasible]).

  Ve svém příspěvku i v podcastu požádal Pickhardt o data (např. od velkých
  poskytovatelů lightningových služeb), která by pomohla simulované výsledky
  validovat.

- **Dotazník o návrzích kovenantů:** /dev/fd0 [zaslal][fd0 poll] do
  emailové skupiny Bitcoin-Dev odkaz na [veřejný dotazník][wiki poll], ve
  kterém se ptá vývojářů na názory na vybrané návrhy kovenantů.  Yuval
  Kogman [poznamenal][kogman poll], že vývojáři mají vyhodnotit „technické
  zásluhy návrhů” i jejich „pocit o podpoře komunity,” avšak bez možnosti
  vyjádřit libovolné kombinace. Jonas Nick [navrhl][nick poll] „oddělit
  technická hodnocení od podpory komunity” a Anthony Towns [navrhl][towns
  poll] se vývojářů jednoduše zeptat, zda mají nějaké problémy s
  jednotlivými návrhy. Nick i Towns doporučili vývojářům, aby odkázali na
  argumenty podporující jejich názory.

  I přes zmíněné problémy s dotazníkem by mohla demonstrace větší podpory
  konkrétních návrhů pomoci výzkumníkům shodnout se na krátkém seznamu
  myšlenek, které by mohly být podrobené prozkoumání širší komunitou.

- **Pseudokovenanty založené na incentivách:** Jeremy Rubin zaslal
  do emailové skupiny Bitcoin-Dev [příspěvek][rubin unfed] s odkazem na
  svůj [článek][rubin unfed paper] o orákuly podporovaných
  [kovenantech][topic covenants]. Model vyžaduje dva druhy orákulí:
  _kovenantové orákulum_ (covenant oracle) a _orákulum integrity_
  (integrity oracle). Kovenantové orákulum umístí prostředky do finančního
  závazku a zaváže se podepsat transakce pouze, pokud jsou založené na
  úspěšném provedení nějakého programu. Orákulum integrity provede
  [odpovědný výpočet][topic acc] (accountable computing) a pokud může
  prokázat, že podpis byl vytvořen, i když program úspěchem neskončil, může
  uzmout prostředky ze závazku. V případě podvodu neexistuje záruka, že by
  uživatel, který ztratí peníze kvůli klamu kovenantového orákula, mohl
  ztracené prostředky získat zpět.

  Nezávisle na výše uvedeném příspěvku zaslal Ethan Heilman do emailové
  skupiny Bitcoin-Dev [zprávu][heilman slash] popisující odlišný konstrukt,
  který by umožnil komukoliv potrestat nesprávný podpis. V tomto případě by
  nebyly prostředky uzmuty, ale zničeny. To by zajistilo potrestání
  podvodného orákula, ale nepomohlo by oběti získat zpět ztracené
  prostředky.

- **Souhrny setkání vývojářů Bitcoin Core:** mnoho vývojářů Bitcoin Core se v
  říjnu osobně setkalo, ze setkání vzešlo několik poznámek, které byly
  nyní [zveřejněné][coredev notes].  Diskutovalo se o [přidání podpory pro
  payjoin][adding payjoin support], vytváření [několika binárních
  sestavení][multiple binaries], která by spolu komunikovala, [rozhraní pro
  těžbu][mining interface] a [podpoře pro Stratum v2][Stratum v2 support],
  vylepšení [benchmarkování][benchmarking] a [flamegraphů][flamegraphs],
  [API pro libbitcoinkernel][API for libbitcoinkernel], zabraňování
  [zaseklým blokům][block stalling], vylepšení [RPC kódu][RPC code]
  inspirovaného Core Lightningem, pokračování ve [vývoji erlay][development
  of erlay] a [kovenantech][contemplating covenants].

## Bitcoin Core PR Review Club

*V této měsíční rubrice shrnujeme nedávné sezení [Bitcoin Core PR Review Club][] a
vyzdvihujeme některé z důležitých otázek a odpovědí. Klikněte na otázku a odpověď se vám odhalí.*

[Sleduj a používej všechna možná spojení pro řešení sirotků][review club
31397] je PR od [glozow][gh glozow], které zvyšuje spolehlivost řešení
sirotků: uzel vyžádá chybějící předky od všech svých spojení namísto pouze
od toho, které mu sirotka oznámilo. Za tímto účelem je přidán
`m_orphan_resolution_tracker`. Tento člen ukládá spojení, která mohou být
použita pro řešení sirotků, a plánuje, kdy řešení provést. Kód je navržen
tak, aby šetřil přenesenými daty, nebyl náchylný na cenzurování a aby zátěž
rozkládal mezi spojení.

{% include functions/details-list.md
  q0="Co je řešení sirotků?"
  a0="Transakci označujeme za sirotka, pokud uzel nezná alespoň jednu
  z transakcí, ze kterých utrácí. Řešení sirotků je proces získávání
  těchto chybějících transakcí."
  a0link="https://bitcoincore.reviews/31397#l-23"

  q1="Jaké kroky jsou součástí řešení sirotků před tímto PR, počínaje
  zjištěním, že transakce má neznámé vstupy?"
  a1="Když uzel obdrží osiřelou transakci, vyžádá od stejného spojení,
  které sirotka poslalo, rodičovské transakce. Jiná spojení nejsou
  aktivně kontaktována, mohou ale předka poslat na příklad ve formě
  oznámení zprávou INV nebo pošlou jiného sirotka se stejným chybějícím
  rodičem."
  a1link="https://bitcoincore.reviews/31397#l-29"

  q2="Proč může být řešení sirotka u stejného spojení, které ho poslalo,
  skončit neúspěchem? Z jakých důvodů se to může stát, poctivých či nikoliv?"
  a2="Poctivý uzel se může jednoduše odpojit nebo mohl vyloučit předka
  ze svého mempoolu. Záškodnický uzel nemusí na požadavek odpovědět
  nebo může poslat rodiče s upraveným, nevalidním witnessem, kvůli čemuž
  by měl rodič očekávané txid, ale neprošel by validací."
  a2link="https://bitcoincore.reviews/31397#l-49"

  q3="Jak by mohl útočník zneužitím dnešního způsobu řešení sirotků zabránit
  uzlu ve stažení 1p1c balíčku?"
  a3="Útočník může sám o sobě oznámit upraveného sirotka (viz otázka 3).
  Jakmile je upravená osiřelá transakce přijata do sirotčince, poctivá
  osiřelá transakce už přijatá nebude, protože má stejné txid. To znemožní,
  aby byl balíček přeposlán. Útočník by dále mohl zaplavit uzel osiřelými
  transakcemi. Jelikož má sirotčinec omezenou velikost a transakce mohou
  být vyloučeny nahodile, mělo by to dopad na stahování 1p1c balíčků."
  a3link="https://bitcoincore.reviews/31397#l-64"

  q4="Jak PR řeší problém popsaný v předchozí otázce?"
  a4="Namísto přidání chybějící rodičovské transakce mezi sledované
  požadavky na transakci je transakce přidána do nového pole
  `m_orphan_resolution_tracker`. Zde se plánuje řešení sirotků, tedy
  kdy by měla být od různých spojení vyžádána rodičovská transakce.
  Účastníci navrhli a diskutovali alternativní přístup, který by nevyžadoval
  `m_orphan_resolution_tracker`. Přístup bude autorkou prozkoumán."
  a4link="https://bitcoincore.reviews/31397#l-81"

  q5="Jak a proč v tomto PR identifikujeme potenciální kandidáty pro řešení
  sirotků?"
  a5="Všechna spojení, která oznámila transakci, jež se ukázala jako osiřelá,
  jsou označena jako potenciální kandidáti."
  a5link="https://bitcoincore.reviews/31397#l-127"

  q6="Co uzel učiní, pokud spojení oznámí transakci, která právě čeká na
  vyřešení jako sirotek?"
  a6="Namísto přidání transakce do `m_txrequest` je spojení přidáno jako
  kandidát na řešení sirotka. Pomáhá to zabránit útokům popsaným v otázce
  4."
  a6link="https://bitcoincore.reviews/31397#l-148"

  q7="Proč preferujeme řešit sirotky s odchozími spojeními namísto s příchozími?"
  a7="Odchozí spojení jsou vybrána samotným uzlem a jsou tedy považována
  za více důvěryhodná. I když odchozí spojení stále mohou škodit,
  přinejmenším budou méně pravděpodobně cílit konkrétně na váš uzel."
  a7link="https://bitcoincore.reviews/31397#l-251"
%}

## Změny ve službách a klientech

*V této měsíční rubrice upozorňujeme na zajímavé aktualizace bitcoinových
peněženek a služeb.*

- **Vydáno javovské HWI:**
  [Lark App][larkapp github] je aplikace pro příkazovou řádku pro interakci s hardwarovými
  podpisovými zařízeními. Používá [knihovnu Lark Java][lark github], port
  [HWI][topic hwi] pro Javu.

- **Ohlášena vzdělávací hra pro vývoj bitcoinu Saving Satoshi:**
  Webová stránka [Saving Satoshi][saving satoshi website] nabízí interaktivní
  vzdělávací cvičení pro nováčky ve vývoji bitcoinu.

- **Plugin do Neovimu pro Bitcoin Script:**
  Plugin do Neovimu [Bitcoin script hints][bsh github] zobrazuje v editoru
  u každé operace stav zásobníku.

- **Proton Wallet přidává RBF:**
  Uživatelé Proton Wallet mohou nově [svým transakcím][proton blog] navýšit
  poplatek pomocí [RBF][topic rbf].

## Vybrané otázky a odpovědi z Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] je jedním z prvních míst, kde hledají
přispěvatelé Optechu odpovědi na své otázky a kde – najdou-li volnou chvíli –
pomáhají zvědavým či zmateným uživatelům. V této měsíční rubrice nabízíme
některé z otázek a odpovědí, které obdržely vysoký počet hlasů.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Jak dlouho zůstavají forknuté řetězce uložené v Bitcoin Core?]({{bse}}124973)
  Pieter Wuille vysvětluje, že kromě ořezaných uzlů Bitcoin Core zůstávají
  všechny stažené bloky, v hlavním řetězci i mimo, uložené navždy.

- [K čemu jsou sólo těžební pooly?]({{bse}}124926)
  Murch nastiňuje, proč by bitcoinový těžař mohl používat těžební pool,
  který nedělí odměny mezi účastníky, tedy _sólo těžební pool_.

- [Existuje důvod k používání P2TR místo P2WSH, pokud chci používat pouze platbu skriptem?]({{bse}}124888)
  Vojtěch Strnad uvádí potenciální úspory při používání P2WSH, ale poukazuje
  na jiné výhody [P2TR][topic taproot] včetně soukromí, možnosti použít
  strom skriptů a dostupnosti [PTLC][topic ptlc].

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [Core Lightning 24.11][] je vydáním nové hlavní verze této oblíbené
  implementace LN. Obsahuje nový experimentální plugin pro vytváření
  plateb používajících pokročilé plánování trasy; placení a přijímání
  plateb na [nabídky][topic offers] je ve výchozím nastavení aktivní;
  byla přidána další vylepšení [splicingu][topic splicing]; vydání obsahuje
  ještě několik dalších novinek a oprav chyb.

- [BTCPay Server 2.0.4][] je vydáním tohoto software pro zpracování plateb,
  které přináší několik nových funkcí, vylepšení a oprav chyb.

- [LND 0.18.4-beta.rc2][] je kandidátem na vydání menší verze této
  populární implementace LN.

- [Bitcoin Core 28.1RC1][] je kandidátem na údržbové vydání této převládající
  implementace plného uzlu.

- [BDK 1.0.0-beta.6][] je posledním plánovaným beta vydáním této knihovny
  pro budování bitcoinových peněženek a jiných bitcoinových aplikací před
  vydáním `bdk_wallet` verze 1.0.0.

## Významné změny kódu a dokumentace

_Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Bitcoin Inquisition][bitcoin inquisition repo] a [repozitáři BINANA][binana
repo]._

- [Bitcoin Core #31096][] odstraňuje omezení RPC příkazu `submitpackage`
  (viz [zpravodaj č. 272][news272 submitpackage]), která znemožňovala
  přidání balíčku s jedinou transakcí. Logika funkce `AcceptPackage` byla
  změněna a kontroly v `submitpackage` byly uvolněné. I když jediná
  transakce neodpovídá definici balíčku dle specifikace [přeposílání
  balíčků][topic package relay], neexistuje důvod, proč uživatelům bránit
  v používání tohoto příkazu k odeslání transakcí, které odpovídají pravidlům.

- [Bitcoin Core #31175][] odstraňuje nadbytečné kontroly z RPC příkazu
  `submitblock` a z `bitcoin-chainstate.cpp`, které ověřují, zda blok
  obsahuje coinbasovou transakci nebo je duplikátem. Tyto kontroly jsou
  již prováděny v `ProcessNewBlock`. Změna standardizuje chování napříč
  rozhraními, jako je IPC pro těžení (viz [zpravodaj č. 323][news323 ipc])
  a `net_processing`, což bude potřebné pro API projekt
  [libbitcoinkernel][libbitcoinkernel project]. Dále budou duplikované bloky
  odeslané pomocí `submitblock` uložené, i když byly předtím ořezané.
  Pro zachování konzistence s `getblockfrompeer` budou data ořezána znova,
  pokud to bude potřeba.

- [Bitcoin Core #31112][] rozšiřuje funkcionalitu `CCheckQueue`, aby lépe
  logovala chyby během vícevláknové validace skriptů. Dříve byly detailní
  chybové zprávy dostupné pouze v jednovláknové validaci (`par=1`) kvůli
  omezenému přenosu informací mezi vlákny. Dále byly do logovacích zpráv
  přidány podrobnosti o vstupu transakce a utráceném UTXO.

- [LDK #3446][] přidává do [BOLT12][topic offers] faktur možnost aktivovat
  příznak [trampolínové platby][topic trampoline payments]. Podporu pro
  trampolínové routování nebo služby trampolínového routování zatím nepřidává.
  Podpora pro trampolínové platby je potřebná pro typ [asynchronních plateb][topic
  async payments], který LDK zamýšlí přidat.

- [Rust Bitcoin #3682][] přidává několik nástrojů pro stabilizaci veřejného API
  modulů `hashes`, `io`, `primitives` a `units`. Mezi novinky patří vygenerované
  textové soubory se signaturami funkcí a skript pro jejich generování pomocí
  `cargo check-api`, skript, který tyto soubory načítá, a CI proces, který je
  porovnává a detekuje nezamýšlené změny API. Dále je do dokumentace přidán
  požadavek na přispěvatele vygenerovat novou verzi souboru v případě změny API.

- [BTCPay Server #5743][] přináší u multisig a watch-only peněženek koncept
  „čekajících (pending) transakcí”. Jedná se o [PSBT][topic psbt], které nepožaduje
  okamžitý podpis. Transakce sbírá podpisy podle toho, jak jsou podepisující
  online. Až obdrží dostatečné množství podpisů, bude zveřejněna. PR také
  automaticky označuje transakce jako dokončené, jsou-li podepsány mimo BTCPay
  Server, a zneplatní čekající transakci, jsou-li její UTXO utracena jinde.
  Též podporuje nastavení volitelné lhůty pro zachování aktuálních poplatků.
  Tento systém umožňuje výplatnímu procesoru vytvářet čekající transakce pro
  výplaty, rušit je nebo je nahrazovat novými verzemi. Funkcionalita
  je dostupná pouze s horkými peněženkami. Systém může také poslat email
  během vytvoření čekající transakce.

- [BDK #1756][] kontroluje, zda se `fetch_prev_txout` nepokouší vyžádat předchozí
  výstupy coinbasové transakce (které žádné nemají). Dříve v takovém případě
  `bdk_electrum` spadl a proces synchronizace blockchainu tím selhal.

- [BIPs #1535][] začleňuje [BIP348][], specifikaci opkódu
  [OP_CHECKSIGFROMSTACK][topic op_checksigfromstack], který umožňuje
  ověřit, zda podpis podepisuje nějakou zprávu. Opkód umístí do zásobníku
  podpis, zprávu a veřejný klíč a zjistí, zda podpis odpovídá zprávě a klíči.
  Tento opkód je jedním z mnoha návrhů pro [kovenanty][topic covenants].

- [BOLTs #1180][] upravuje specifikaci [BOLT12][topic offers] přidáním volitelného
  [BIP353][] (čitelné bitcoinové platební instrukce) do požadavku na fakturu (viz
  [zpravodaj č. 290][news290 omdns]). [BLIPs #48][] upravuje [BLIP32][]
  (viz [zpravodaj č. 306][news306 blip32]), aby odkazoval na změnu v [BOLT12][].

## Veselé Vánoce!

Toto je letošní poslední pravidelné číslo zpravodaje. V pátek 20. prosince
zveřejníme náš sedmý celoroční přehled. V pravidelném publikování budeme pokračovat
v pátek 3. ledna.

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 15:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="31096,31175,31112,3446,3682,5743,1756,1535,1180,48" %}
[core lightning 24.11]: https://github.com/ElementsProject/lightning/releases/tag/v24.11
[lnd 0.18.4-beta.rc2]: https://github.com/lightningnetwork/lnd/releases/tag/v0.18.4-beta.rc2
[eclair v0.11.0]: https://github.com/ACINQ/eclair/releases/tag/v0.11.0
[ldk v0.0.125]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.0.125
[bitcoin core 28.1RC1]: https://bitcoincore.org/bin/bitcoin-core-28.1/
[harding irrev]: https://delvingbitcoin.org/t/disclosure-irrevocable-fees-stealing-from-ln-using-revoked-commitment-transactions/1314
[pickhardt deplete]: https://delvingbitcoin.org/t/channel-depletion-ln-topology-cycles-and-rational-behavior-of-nodes/1259/6
[guidi spanning]: https://diyhpl.us/~bryan/irc/bitcoin/bitcoin-dev/linuxfoundation-pipermail/lightning-dev/2019-August/002115.txt
[news309 feasible]: /cs/newsletters/2024/06/28/#odhad-pravdepodobnosti-uspesneho-provedeni-ln-platby
[news325 feasible]: /cs/newsletters/2024/10/18/#vyzkum-fundamentalnich-limitu
[fd0 poll]: https://gnusha.org/pi/bitcoindev/028c0197-5c45-4929-83a9-cfe7c87d17f4n@googlegroups.com/
[wiki poll]: https://en.bitcoin.it/wiki/Covenants_support
[kogman poll]: https://gnusha.org/pi/bitcoindev/CAAQdECALHHysr4PNRGXcFMCk5AjRDYgquUUUvuvwHGoeJDgZJA@mail.gmail.com/
[nick poll]: https://gnusha.org/pi/bitcoindev/941b8c22-0b2c-4734-af87-00f034d79e2e@gmail.com/
[towns poll]: https://gnusha.org/pi/bitcoindev/Z1dPfjDwioa%2FDXzp@erisian.com.au/
[rubin unfed]: https://gnusha.org/pi/bitcoindev/30440182-3d70-48c5-a01d-fad3c1e8048en@googlegroups.com/
[rubin unfed paper]: https://rubin.io/public/pdfs/unfedcovenants.pdf
[heilman slash]: https://gnusha.org/pi/bitcoindev/CAEM=y+V_jUoupVRBPqwzOQaUVNdJj5uJy3LK9JjD7ixuCYEt-A@mail.gmail.com/
[drkgry deanon]: https://github.com/GingerPrivacy/GingerWallet/discussions/116
[shinobi deanon]: https://bitcoinmagazine.com/technical/wabisabi-deanonymization-vulnerability-disclosed
[wasabi #5439]: https://github.com/WalletWasabi/WalletWasabi/issues/5439
[adding payjoin support]: https://btctranscripts.com/bitcoin-core-dev-tech/2024-10/payjoin
[multiple binaries]: https://btctranscripts.com/bitcoin-core-dev-tech/2024-10/multiprocess-binaries
[mining interface]: https://btctranscripts.com/bitcoin-core-dev-tech/2024-10/mining-interface
[stratum v2 support]: https://btctranscripts.com/bitcoin-core-dev-tech/2024-10/stratumv2
[benchmarking]: https://btctranscripts.com/bitcoin-core-dev-tech/2024-10/leveldb
[flamegraphs]: https://btctranscripts.com/bitcoin-core-dev-tech/2024-10/flamegraphs
[api for libbitcoinkernel]: https://btctranscripts.com/bitcoin-core-dev-tech/2024-10/kernel
[block stalling]: https://btctranscripts.com/bitcoin-core-dev-tech/2024-10/block-stalling
[rpc code]: https://btctranscripts.com/bitcoin-core-dev-tech/2024-10/rpc-discussion
[development of erlay]: https://btctranscripts.com/bitcoin-core-dev-tech/2024-10/erlay
[contemplating covenants]: https://btctranscripts.com/bitcoin-core-dev-tech/2024-10/covenants
[coredev notes]: https://btctranscripts.com/bitcoin-core-dev-tech/2024-10
[dd deplete]: /en/podcast/2024/12/12/
[bdk 1.0.0-beta.6]: https://github.com/bitcoindevkit/bdk/releases/tag/v1.0.0-beta.6
[btcpay server 2.0.4]: https://github.com/btcpayserver/btcpayserver/releases/tag/v2.0.4
[larkapp github]: https://github.com/sparrowwallet/larkapp
[lark github]: https://github.com/sparrowwallet/lark
[saving satoshi website]: https://savingsatoshi.com/
[bsh github]: https://github.com/taproot-wizards/bitcoin-script-hints.nvim
[proton blog]: https://proton.me/support/speed-up-bitcoin-transactions
[news272 submitpackage]: /cs/newsletters/2023/10/11/#bitcoin-core-27609
[news323 ipc]: /cs/newsletters/2024/10/04/#bitcoin-core-30510
[libbitcoinkernel project]: https://github.com/bitcoin/bitcoin/issues/24303
[news290 omdns]: /cs/newsletters/2024/02/21/#citelne-bitcoinove-platebni-instrukce-zalozene-na-dns
[news306 blip32]: /cs/newsletters/2024/06/07/#blips-32
[review club 31397]: https://bitcoincore.reviews/31397
[gh glozow]: https://github.com/glozow
