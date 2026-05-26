---
title: 'Zpravodaj „Bitcoin Optech” č. 406'
permalink: /cs/newsletters/2026/05/22/
name: 2026-05-22-newsletter-cs
slug: 2026-05-22-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Zpravodaj tento týden odkazuje na diskuzi o aktualizaci obecného formátu
podepsaných zpráv (BIP322) a popisuje nápad na používání TCP hole punchingu
pro umožnění příchozích spojení bitcoinovým uzlům za NATem. Též nechybí naše
pravidelné rubriky s popisem nedávných změn ve službách a klientském software
a se souhrnem významných změn v populárním bitcoinovém páteřním software.

## Novinky

- **Významné změny BIP322\: obecného formátu podepsaných zpráv**: Oliver Gugger
  zaslal do emailové skupiny Bitcoin-Dev [příspěvek][guggero bip322 ml] o svém
  nápadu na doplnění [BIP322][topic generic signmessage]. Během práce na přidání podpory
  do btcd si Gugger všiml v návrhu několika otevřených otázek a mezer. Navrhl tři
  významné úpravy:

  - Čitelné prefixy pro rozlišení všech tří variant podpisů.

  - Přidání informací o UTXO do varianty „Proof of Funds” (dokladu o prostředcích).

  - Podporu podepisování zpráv založeného na PSBT.

  Po diskuzi a vypořádání zpětné vazby ohledně konstrukce PSBT byla tato aktualizace BIP322
  zveřejněna (viz [zpravodaj č. 405][news405 bip322]). Gugger změnil stav BIPu na Complete,
  čímž dal najevo, že je specifikace nyní považovaná za stabilní a připravená k implementaci.
  Po aktualizaci se ukázalo, že Coldcard již podporu pro BIP322 [přidal][cc 322] v březnu.

  Projekty, které již implementovaly podporu dřívějších verzí BIP322, by měly soulad
  s aktualizovanou specifikací prověřit, jelikož přinesla nekompatibilní změny, včetně
  nového čitelného prefixu a změněného formátu podpisu dokladu o dostupných prostředcích.

- **TCP hole punching pro bitcoinové uzly za NATem**: 0xB10C zaslal do fóra Delving Bitcoin
  [příspěvek][hole punch del] o nápadu na zpřístupnění většího množství uzlů za domácím NATem.
  Původní myšlenka vychází z pozorování, že volba `-natpmp=1`, která je od [Bitcoin Core v30.0][]
  výchozí, nenavýšila počet dosažitelných uzlů z rezidenčních ISP, jak bylo očekáváno.

  Tento nápad využívá hole punching („děrování”), techniku, která dvěma stranám za určitými
  druhy NATu umožňuje přímé spojení bez přeposílání přes nějaký server. Proces funguje následovně:
  strany Alice a Bob, které nejsou přímo dosažitelné, si vymění své veřejné body (IP adresu a port)
  pomocí třetí strany a zároveň k sobě zahájí spojení. Tím se vytvoří v NATu mapování, které
  oběma stranám umožní kompletně navázat spojení. Jelikož tato navrhovaná technika funguje nad TCP,
  které vyžaduje přesnou synchronizaci mezi uzly, produkuje větší množství chyb ve srovnání
  s podobnými technikami používajícími UDP.

  0xB10C zmínil několik přístupů k implementaci použitím bitcoinového P2P protokolu. První sada
  vyžaduje přemostění, označované jako styčný (rendezvous) server, které Alici a Bobovi umožní
  vyměnit si informace o kontaktním bodu. Server by mohl buď nabídnout službu hledání protistrany,
  která by nedosažitelným uzlům umožnila nabídnout své sloty pro připojení, nebo by se mohl rozhodnout
  předat jedno ze svých existujících spojení jinému peer spojení, aby ho nemusel vyloučit kvůli
  chybějícímu volnému příchozímu slotu. Dále popsal způsob provádění hole punchingu napřímo
  přes [Tor/I2P][topic anonymity networks], čímž by obešel nutnost používat pro navázání spojení
  server třetí strany. Tímto způsobem by mohla Alice začít poslouchat na vyhrazené Tor/I2P
  službě, ke které by se Bob připojil a začal tak proces hole punchingu.

  Návrh ještě nebyl formalizován a zbývá zodpovědět mnoho otázek. 0xB10C požádal komunitu
  o zpětnou vazbu a vyzval k diskuzi ohledně mnoha otevřených otázek, mezi kterými jsou
  klasifikace takových spojení, spolehlivost TCP hole punchingu, možné útoky a snahy o
  implementaci.

## Změny ve službách a klientech

*V této měsíční rubrice upozorňujeme na zajímavé aktualizace bitcoinových
peněženek a služeb.*

- **Ohlášena peněženka Ibis Wallet:**
  [Ibis Wallet][ibis wallet] je peněženka pro Android postavená nad BDK. Podporuje
  kontrolu mincí, správu poplatků pomocí [RBF][topic rbf] a [CPFP][topic cpfp], multisig,
  integraci s hardwarovými podpisovými zařízeními pomocí QR kódů, [tiché platby][topic
  silent payments] a [Tor][topic anonymity networks]. Též podporuje dodatečné systémy
  druhé vrstvy jako Spark, Liquid či v budoucnu [Ark][topic ark].

- **Ohlášen LDK Server:**
  Spiral ohlásil [LDK Server][ldk server], lightningový uzel určený primárně pro
  API volání a postavený nad LDK Node, sloužící platebním procesorům a poskytovatelům
  peněženek. Nabízí gRPC rozhraní, vestavěnou peněženku (BDK) a MCP server pro interakci
  AI agentů.

- **Vydán Mempool.space v3.3.0:**
  Mempool [v3.3.0][mempool v3.3.0] přidává vizualizaci [taprootových][topic taproot]
  stromů skriptů, upravuje náhledy [PSBT][topic psbt], vylepšuje [odhad
  poplatků][topic fee estimation], podporu [dočasného prachu][topic ephemeral anchors],
  porovnání zastaralých bloků, ikony sighashů, API pro Merkleovy doklady a další.

- **Nástroj pro monitorování P2P peer-observer:**
  0xB10C [vyjmenovává][peer-observer delving] některé open-source komponenty, které
  jeho [peer-observer][peer-observer site] používá, včetně infrastruktury pro
  extrahování událostí z uzlů Bitcoin Core pomocí IPC, logů, P2P a RPC.
  Dále popisuje probíhající vývoj kolem archivace, detekce anomálií a nástrojů
  pro upozorňování.

## Významné změny kódu a dokumentace

_Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo] a [repozitáři BINANA][binana repo]._

- [Bitcoin Core #29136][] přidává RPC volání `addhdkey`, které importuje daný
  rozšířený soukromý klíč dle [BIP32][] nebo ho generuje, pokud žádný klíč předán
  nebyl. Přitom negeneruje žádné výstupní skripty. To peněžence umožní
  uložit klíče pro podepisování pro budoucí použití (např. pro multisig skripty),
  aniž by bylo nutné z nich generovat adresy. PR dále přidává nový typ
  [deskriptoru][topic descriptors] `unused(KEY)`, který vrací `listdescriptors`.
  Uložené klíče tak mohou být součástí záloh peněženky.

- [Bitcoin Core #34893][] mění chování RPC volání `combinepsbt`, aby při kombinování
  [PSBT][topic psbt] zachovávalo proprietární pole dle [BIP174][] (viz zpravodaje
  [č. 72][news72 psbt] a [č. 181][news181 psbt], oba _angl._). Dříve příkaz
  tato pole tiše zahodil, což vyústilo ve ztrátu aplikačních metadat.
  RPC `decodepsbt` tato pole řádně parsuje, serializuje i zobrazuje.

- [Bitcoin Core #34860][] odstraňuje z metody `CreateNewBlock()` (viz zpravodaj
  [č. 392][news392 mining]) volbu `include_dummy_extranonce`. Bitcoin Core
  nově vždy falešnou výplň připojí k internímu scriptSig mincetvorné transakce
  bloků 0 až 16, jelikož u nich je indikovaná výška dle [BIP34][] příliš
  krátká a nevyhovuje konsenzu. Tato výplň však není obsažena v poli
  `scriptSigPrefix` struktury `CoinbaseTx`, která je vystavena klientům [Stratum
  V2][topic pooled mining] připojeným pomocí Mining IPC rozhraní
  (viz zpravodaje [č. 310][news310 ipc] a [č. 388][news388 ipc]).

- [Bitcoin Core #31298][] mění RPC volání `combinerawtransaction`. Nově bude odmítat
  nesouvisející transakce namísto tichého vrácení první z nich bez hlášení.
  Bitcoin Core nyní z každé transakce odstraní vstupní scriptSig a witnessy,
  porovná haše výsledných nepodepsaných transakcí a vrátí chybovou hlášku,
  pokud si neodpovídají.

- [Bitcoin Core #28802][] přidává do `ArgsManager`u, parseru argumentů příkazové
  řádky Bitcoin Core, podporu pro volby konkrétních příkazů. Příkazy mohou
  nově deklarovat, které volby přijímají, což `ArgsManager`u umožňuje
  ve výstupu nápovědy vyjmenovat jen ty volby, které se příkazu týkají.
  Též může automaticky odmítnout nevalidní kombinace voleb. PR aplikuje
  tento mechanismus na volbu `-dumpfile` nástroje `bitcoin-wallet` (viz
  [zpravodaj č. 32][news32 dump], _angl._); tato volba je nyní registrována
  pouze pro příkazy `dump` a `createfromdump`.

- [Eclair #3298][] mění interní logiku [RBF][topic rbf], aby byla v souladu s novým
  pravidlem navyšování poplatků dle [BOLT2][]. Toto pravidlo bylo navrženo, aby
  zajistilo soulad s pravidly z [BIP125][] během období s nízkými jednotkovými poplatky.
  Dříve Eclair pouze aplikoval činitel 25/24, nově používá dodatečných 25 sat/kw,
  pokud je větší než činitel. Tím se dostává do souladu s chováním LDK
  ([zpravodaj č. 400][news400 rbf]) a BOLT specifikací ([zpravodaj č. 404][news404 rbf]).

- [LDK #4575][] přidává API `splice_in_inputs`, které uživatelům umožňuje manuálně
  zvolit UTXO během přidávání prostředků do kanálu pomocí [splicingu][topic splicing].
  Zvolená UTXO jsou kompletně zkonzumována, celá jejich hodnota (mínus poplatky)
  je přidána do kanálu a není vytvořen žádný výstup se zbytkem. Tato funkce
  doplňuje stávající možnost přidat určitou částku zvolenou uživatelem,
  kdy peněženka vhodné vstupy vybere sama. Tyto dvě možnosti nemohou být
  použity najednou.

- [LND #10814][] odstraňuje zastaralé příkazy `SendPayment`, `SendPaymentSync`,
  `SendToRoute`, `SendToRouteSync` a `TrackPayment`, které byly naplánovány
  k odstranění ve verzi 0.21 (viz [zpravodaj č. 340][news340 lnd]).
  Volající by měli používat tyto V2 náhrady: `SendPaymentV2`, `SendToRouteV2`
  a `TrackPaymentV2`. PR dále odstraňuje zastaralé pole `outgoing_chan_id`,
  náhradou je `outgoing_chan_ids` (viz [zpravodaj č. 33][news33 lnd], _angl._).

- [Rust Bitcoin #6191][] přidává podporu pro kódování a dekódování P2P zprávy
  `sendtxrcncl` používané pro synchronizaci transakcí v [Erlay][topic erlay].
  Bitcoin Core přidal podporu pro tuto zprávu v rámci Erlay podpory (viz
  [zpravodaj č. 223][news223 erlay], _angl._). Plná podpora synchronizace
  transakcí ještě není implementována.

- [BLIPs #42][] přidává [BLIP42][], specifikaci [BOLT12][] kontaktů. Jelikož mohou
  být [BOLT12 nabídky][topic offers] opakovaně používány jako statické instrukce pro
  lightningové platby, mohou je peněženky ukládat jako kontakty. BLIP definuje
  volitelné pole `invoice_request`, které může plátce připojit k odcházející
  platbě např. pro předání tajného kódu, vlastní nabídky nebo [BIP353][] jména.
  To příjemcům umožní rozpoznat platby od známých kontaktů, přidat nové
  kontakty a poslat prostředky zpět plátci bez nutnosti další interakce.

{% include snippets/recap-ad.md when="2026-05-26 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="29136,34893,34860,31298,28802,3298,4575,10814,6191,42" %}
[ibis wallet]: https://github.com/aeonBTC/IbisWallet
[ldk server]: https://github.com/lightningdevkit/ldk-server
[mempool v3.3.0]: https://github.com/mempool/mempool/releases/tag/v3.3.0
[peer-observer delving]: https://delvingbitcoin.org/t/peer-observer-a-tool-and-infrastructure-for-monitoring-the-bitcoin-p2p-network-for-attacks-and-anomalies/1988/4
[peer-observer site]: https://public.peer.observer/
[news72 psbt]: /en/newsletters/2019/11/13/#bips-849
[news181 psbt]: /en/newsletters/2022/01/05/#bitcoin-core-17034
[news392 mining]: /cs/newsletters/2026/02/13/#bitcoin-core-32420
[news310 ipc]: /cs/newsletters/2024/07/05/#bitcoin-core-30200
[news388 ipc]: /cs/newsletters/2026/01/16/#bitcoin-core-33819
[news32 dump]: /en/newsletters/2019/02/05/#bitcoin-core-13926
[news400 rbf]: /cs/newsletters/2026/04/10/#ldk-4494
[news404 rbf]: /cs/newsletters/2026/05/08/#bolts-1327
[news340 lnd]: /cs/newsletters/2025/02/07/#lnd-9456
[news33 lnd]: /en/newsletters/2019/02/12/#lnd-2572
[news223 erlay]: /en/newsletters/2022/10/26/#bitcoin-core-23443
[hole punch del]: https://delvingbitcoin.org/t/tcp-hole-punching-for-bitcoin-nodes-behind-home-nats/2497
[Bitcoin Core v30.0]: https://bitcoincore.org/en/releases/30.0/
[guggero bip322 ml]: https://groups.google.com/g/bitcoindev/c/qd6BNz9gxCk/m/k1fHq4RKAQAJ
[cc 322]: https://blog.coinkite.com/bip322-wif/
[news405 bip322]: /cs/newsletters/2026/05/15/#bips-2141
