---
title: 'Zpravodaj „Bitcoin Optech” č. 276'
permalink: /cs/newsletters/2023/11/08/
name: 2023-11-08-newsletter-cs
slug: 2023-11-08-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Tento týden přinášíme oznámení o nadcházejících změnách v emailové skupině
Bitcoin-Dev a krátký souhrn návrhu na agregaci několika HTLC dohromady. Též
nechybí naše pravidelné rubriky se souhrnem sezení Bitcoin Core PR Review Club,
oznámeními o nových vydáních a popisem významných změn v populárním
bitcoinovém páteřním software.

## Novinky

- **Hosting emailové skupiny:** administrátoři emailové skupiny Bitcoin-Dev
  [oznámili][bishop lists], že organizace, která skupinu na svých serverech
  hostuje, tak přestane po novém roce činit. Archiv emailů by měl na současných
  webových adresách v dohledné době zůstat. Předpokládáme, že stejným
  způsobem bude postižena i skupina Lightning-Dev, která je hostována
  stejnou organizací.

  Administrátoři žádali komunitu o poskytnutí zpětné vazby ohledně možností,
  mezi kterými je i migrace skupiny do Google Groups. Pokud by takový
  přechod nastal, Optech by jej začal používat jako jeden ze svých
  [zdrojů][sources].

  Jsme si vědomi, že před několika měsíci začali někteří etablovaní vývojáři
  experimentovat s diskuzemi na webovém fóru [DelvingBitcoin][]. Optech okamžitě
  začne toto fórum monitorovat.

- **Agregace HTLC pomocí kovenantů:** Johan Torås Halseth zaslal do emailové
  skupiny Lightning-Dev [příspěvek][halseth agg] s návrhem na agregaci několika
  [HTLC][topic htlc] do jediného výstupu pomocí [kovenantu][topic covenants].
  Takový výstup by mohl být v případě znalosti všech předobrazů utracen najednou.
  Pokud by utrácející neznal všechny předobrazy, mohl by nárokovat jen ty, které
  zná, a zůstatek by byl zaslán druhé straně. Halseth poznamenává, že tento
  způsob by byl efektivnější onchain a mohl by ztížit provádění určitého druhu
  [útoku zahlcením kanálu][topic channel jamming attacks].

## Bitcoin Core PR Review Club

*V této měsíční rubrice shrnujeme nedávné sezení [Bitcoin Core PR Review Club][] a
vyzdvihujeme některé z důležitých otázek a odpovědí. Klikněte na otázku a odpověď se vám odhalí.*

[Aktualizace odhadu poplatku z Validation rozhraní/CScheduler vlákna][review club 28368]
je PR od Abubakara Sadiqa Ismaila (ismaelsadeeq), které upravuje způsob, jímž
je aktualizován odhad poplatků za transakce. (Odhad poplatků se používá, když
vlastník uzlu vytváří transakci.) Dříve probíhaly aktualizace odhadu poplatků
synchronně během aktualizací mempoolu (když byly transakce přidány nebo odebrány),
nově by se tak mělo dít asynchronně. I když tento způsob přidává na složitosti,
zvyšuje výkonnost v kritické cestě (což následující diskuze ozřejmí).

Když je nalezen nový blok, jeho transakce jsou spolu s konfliktními transakcemi
odstraněny z mempoolu. Jelikož je zpracování bloků a jejich přeposílání kritické z hlediska
výkonnosti, je výhodné snížit během zpracování nového bloku množství požadované
práce, jako jen například aktualizace odhadu poplatků.

{% include functions/details-list.md
  q0="Proč je výhodné odstranit z `CTxMempool` závislost na `CBlockPolicyEstimator`?"
  a0="V současnosti je po přijetí nového bloku jeho zpracování blokováno, dokud se
      nedokončí aktualizace odhadu poplatků. To má za následek delší zpracování a
      prodlevu v přeposílání. Odstraněním závislosti na `CBlockPolicyEstimator`
      z `CTxMempool` může být odhad poplatků aktualizován asynchronně, tj.
      z jiného vlákna. Validace a přeposílání tak mohou být dokončeny rychleji.
      Navíc testování `CTxMempool` může být snazší. V budoucnu to také umožní
      používat složitější algoritmy odhadu poplatků, aniž by měly dopad
      na rychlost validace a přeposílání."
  a0link="https://bitcoincore.reviews/28368#l-30"

  q1="Není odhad poplatků aktualizován synchronně pokaždé, když jsou transakce přidány či
      odebrány z mempoolu, bez ohledu na to, zda uzel obdržel nový blok?"
  a1="Ano, ale výkonnost není tak kritická jako během validace a přeposílání."
  a1link="https://bitcoincore.reviews/28368#l-41"

  q2="Nabízí současný stav, tedy `CBlockPolicyEstimator` uvnitř `CTxMempool`
      a synchronní aktualizace, nějaké výhody? Přináší jeho odstranění nějaké
      nevýhody?"
  a2="Synchronní kód je jednodušší a srozumitelnější. Odhad poplatků má navíc
      větší vhled do celého mempoolu. Na druhou stranu je nutné zapouzdřit
      všechny informace pro odhad poplatků do struktury `NewMempoolTransactionInfo`.
      Odhad poplatků však mnoho informací nepotřebuje."
  a2link="https://bitcoincore.reviews/28368#l-43"

  q3="Jaké jsou podle vás výhody a nevýhody přístupu tohoto PR oproti [PR 11775][],
      které rozděluje `CValidationInterface`?"
  a3="I když rozdělení vypadá atraktivně, ve skutečnosti části stále sdílely backend
      (aby byly události patřičně seřazené), nebyly tedy na sobě zcela nezávislé.
      Nezdá se, že by z praktického hlediska přinášelo rozdělení významné výhody.
      Toto PR je ve svém záběru užší a s menším dopadem."
  a3link="https://bitcoincore.reviews/28368#l-71"

  q4="Proč je implementace rozhraní `CValidationInterface` ekvivalentní odebírání událostí?"
  a4="Všechny třídy implementující `CValidationInterface` jsou klienty.
      Třída může implementovat všechny nebo jen některé metody (callbacky) z `CValidationInterface`,
      například připojení či odpojení bloku nebo [přidání][tx add] či [odebrání][tx remove]
      transakce z mempoolu. Po registraci (voláním `RegisterSharedValidationInterface()`)
      budou implementované metody vykonány pokaždé, když je callback zavolán pomocí
      `CMainSignals`. Callbacky jsou zavolány, kdykoliv nastane odpovídající událost."
  a4link="https://bitcoincore.reviews/28368#l-90"

  q5="[`BlockConnected`][BlockConnected] a [`NewPoWValidBlock`][NewPoWValidBlock]
      jsou rozdílné callbacky. Který z nich je asynchronní a který synchronní?
      Jak to lze poznat?"
  a5="`BlockConnected` je asynchronní, `NewPoWValidBlock` je synchronní.
      Asynchronní callback přidá do fronty „událost,“ která bude později
      vykonána v rámci vlákna `CScheduler`."
  a5link="https://bitcoincore.reviews/28368#l-105"

  q6="Proč přidáváme v [commitu 4986edb][commit 4986edb] nový callback
      `MempoolTransactionsRemovedForConnectedBlock` namísto použití
      `BlockConnected` (který navíc také indikuje, že byla transakce odstraněna
      z mempoolu)?"
  a6="Algoritmus odhadu poplatku musí vědět, kdy jsou transakce z jakéhokoliv důvodu
      odstraněny z mempoolu, tedy nejen v případě připojení bloku. Odhad poplatku též
      potřebuje znát bázový poplatek transakce a ten  `BlockConnected`
      (který zpřístupňuje `CBlock`) nenabízí. Mohli bych přidat bázový poplatek
      do položek `block.vtx` (seznam transakcí), ale není žádoucí z tohoto důvodu
      měnit tak důležitou a všudypřítomnou datovou strukturu."
  a6link="https://bitcoincore.reviews/28368#l-130"

  q7="Proč nepoužíváme `std::vector<CTxMempoolEntry>` jako parametr callbacku
      `MempoolTransactionsRemovedForBlock`? Mohlo by to odstranit požadavek
      na novou strukturu, která by držela transakční informace potřebné pro
      odhad poplatků."
  a7="Odhad poplatků nepotřebuje všechna pole obsažená v `CTxMempoolEntry`."
  a7link="https://bitcoincore.reviews/28368#l-159"

  q8="Jak je počítán bázový poplatek `CTransactionRef`?"
  a8="Jedná se o součet vstupních hodnot minus součet výstupních hodnot. Callback
      ale nemá přístup ke vstupním hodnotám, neboť jsou uloženy ve výstupech předchozí
      transakce (k nimž callback přístup nemá). Proto je bázový poplatek obsažen ve
      struktuře `TransactionInfo`."
  a8link="https://bitcoincore.reviews/28368#l-166"
%}

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [Bitcoin Core 26.0rc2][] je kandidátem na vydání příští hlavní verze této
  převládající implementace plného uzlu. K dispozici je stručný přehled
  [navrhovaných témat k testování][26.0 testing] a na 15. listopadu 2023
  je naplánované sezení [Bitcoin Core PR Review Club][].

- [Core Lightning 23.11rc1][] je kandidátem na vydání příští hlavní verze
  této implementace LN uzlu.

- [LND 0.17.1-beta.rc1][] je kandidátem na vydání údržbové verze této implementace
  LN uzlu.

## Významné změny kódu a dokumentace

*Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo] a
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [Core Lightning #6824][] upravuje implementaci [interaktivního protokolu
  financování][topic dual funding], aby „ukládala stav během posílání
  `commitment_signed`, a [přidává] do `channel_reestablish` pole
  `next_funding_txid`, které si od spojení vyžádá přeposlání podpisů,
  které ještě nemáme.” Změna je založena na [aktualizaci][36c04c8ac]
  PR návrhu [oboustranného financování][bolts #851].

- [Core Lightning #6783][] zastarává v nastavení volbu `large-channels`.
  [Velké kanály][topic large channels] a velké částky budou vždy aktivní.

- [Core Lightning #6780][] zlepšuje podporu navýšení poplatků onchain transakcí
  spojených s [anchor výstupy][topic anchor outputs].

- [Core Lightning #6773][] přidává do RPC volání `decode` ověření, že
  obsahu záložního souboru je validní a obsahuje informace potřebné k provedení plné obnovy.

- [Core Lightning #6734][] přidává do výsledku RPC volání `listfunds` informace
  potřebné k [CPFP][topic cpfp] navýšení poplatku transakce vzájemného zavření kanálu.

- [Eclair #2761][] umožňuje přeposlat omezený počet [HTLC][topic htlc], i když je
  kanál pod požadavkem minimální rezervy. Může to napomoci vyřešit _problém s uvízlými
  prostředky_, který se může objevit po [splicingu][topic splicing] či [oboustranném
  financování][topic dual funding]. [Zpravodaj č. 253][news253 stuck] popisuje další
  opatření Eclairu proti uvízlým prostředkům.

{% include references.md %}
{% include linkers/issues.md v=2 issues="6824,6783,6780,6773,6734,2761,851" %}
[bitcoin core 26.0rc2]: https://bitcoincore.org/bin/bitcoin-core-26.0/
[core lightning 23.11rc1]: https://github.com/ElementsProject/lightning/releases/tag/v23.11rc1
[lnd 0.17.1-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.17.1-beta.rc1
[sources]: /en/internal/sources/
[bishop lists]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-November/022134.html
[delvingbitcoin]: https://delvingbitcoin.org/
[halseth agg]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-October/004181.html
[36c04c8ac]: https://github.com/lightning/bolts/pull/851/commits/36c04c8aca48e04d1fba64d968054eba221e63a1
[news253 stuck]: /cs/newsletters/2023/05/31/#eclair-2666
[bitcoin core pr review club]: https://bitcoincore.reviews/#upcoming-meetings
[26.0 testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/26.0-Testing-Guide-Topics
[review club 28368]: https://bitcoincore.reviews/28368
[pr 11775]: https://github.com/bitcoin/bitcoin/pull/11775
[tx add]: https://github.com/bitcoin/bitcoin/blob/eca2e430acf50f11da2220f56d13e20073a57c9b/src/validation.cpp#L1217
[tx remove]: https://github.com/bitcoin/bitcoin/blob/eca2e430acf50f11da2220f56d13e20073a57c9b/src/txmempool.cpp#L504
[BlockConnected]: https://github.com/bitcoin/bitcoin/blob/d53400e75e2a4573229dba7f1a0da88eb936811c/src/validationinterface.cpp#L227
[NewPoWValidBlock]: https://github.com/bitcoin/bitcoin/blob/d53400e75e2a4573229dba7f1a0da88eb936811c/src/validationinterface.cpp#L260
[commit 4986edb]: https://github.com/bitcoin-core-review-club/bitcoin/commit/4986edb99f8aa73f72e87f3bdc09387c3e516197
