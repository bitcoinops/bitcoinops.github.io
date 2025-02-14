---
title: 'Zpravodaj „Bitcoin Optech” č. 341'
permalink: /cs/newsletters/2025/02/14/
name: 2025-02-14-newsletter-cs
slug: 2025-02-14-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Zpravodaj tento týden shrnuje pokračující diskuzi o pravděpodobnostních
platbách, přednáší další názory o dočasných anchor skriptech pro LN,
odkazuje na statistiky o vylučování sirotků v Bitcoin Core a oznamuje
aktualizovaný návrh revidovaného procesu přijímání BIPů. Též nechybí
naše pravidelné rubriky se souhrnem sezení Bitcoin Core PR Review Clubu,
oznámeními nových vydání a popisem významných změn v populárním
bitcoinovém páteřním software.

## Novinky

- **Pokračující diskuze o pravděpodobnostních platbách:** v návaznosti
  na [příspěvek][kurbatov pp] Oleksandra Kurbatova ve fóru Delving
  Bitcoin o emulaci opkódu `OP_RAND` (viz [zpravodaj č. 340][news340 pp])
  vzešlo několik nových diskuzí:

  - _Vhodnost jako alternativy k ořezaným HTLC:_ Dave Harding se
    [zeptal][harding pp], zda je Kurbatovova metoda vhodná pro použití
    v [LN-Penalty][topic ln-penalty] nebo [LN-Symmetry][topic eltoo]
    platebních kanálech pro směrování [HTLC][topic htlc], která jsou
    aktuálně [neekonomická][topic uneconomical outputs] a která jsou
    v současnosti řešena pomocí [ořezaných HTLC][topic trimmed htlc]
    (trimmed HTLCs), jejichž hodnota je ztracena, pokud během
    vynuceného uzavření kanálu stále čekají na vyřízení. Anthony Towns
    [si nemyslí][towns pp1], že by to v existujícím protokolu fungovalo,
    neboť jeho role jsou opačné než odpovídající role při řešení HTLC.
    Myslí si však, že by změny protokolu mohly pomoci.

  - _Nutný nultý krok:_ Towns [zjistil][towns pp1], že původně zveřejněný
    protokol postrádal jeden krok. Kurbatov souhlasil.

  - _Jednodušší doklady s nulovou znalostí:_ Adam Gibson [navrhl][gibson pp1],
    že používání [Schnorrových podpisů][topic schnorr signatures] a [taprootu][topic
    taproot] namísto hašovaných veřejných klíčů může výrazně zjednodušit
    a zrychlit konstrukci a ověřování dokladů s nulovou znalostí. Towns
    [nabídl][towns pp2] provizorní přístup, který Gibson [analyzoval][gibson
    pp2].

  Diskuze v době psaní dále probíhala.

- **Pokračující diskuze o dočasných anchor skriptech pro LN:** Matt
  Morehouse přidal [odpověď][morehouse eanchor] do vlákna o výběru
  [dočasných anchor][topic ephemeral anchors] skriptů pro budoucí
  kanály v LN (viz [zpravodaj č. 340][news340 eanchor]). Vyjádřil obavy
  o možném zneužívání transakčních poplatků (fee griefing) třetími stranami
  u [P2A][topic ephemeral anchors] výstupů.

  Anthony Towns [poznamenal][towns eanchor], že obtěžování (griefing)
  protistranami je vážné, jelikož protistrana bude mít lepší příležitost
  ukrást prostředky, pokud není kanál včas uzavřen nebo uveden do správného
  stavu. Třetí strany, které vaši transakci zdržují nebo se pokouší
  o nárůst jejího poplatku, mohou ztratit část svých peněz bez přímé
  možnosti na vás vydělat.

  Greg Sanders [navrhl][sanders eanchor] uvažovat v pravděpodobnostech:
  pokud to nejhorší, čeho může třetí strana dosáhnout, je navýšit
  náklady vaší transakce o 50 %, ale používání odolných metod stojí
  zhruba 10 % navíc, opravdu očekáváte, že vás bude třetí strana
  obtěžovat častěji než jedno vynucené zavření z každých pěti, obzvláště,
  pokud může ztratit peníze a finančně neprofituje?

- **Statistiky vylučování sirotků:** vývojář 0xB10C zaslal do fóra Delving
  Bitcoin [příspěvek][b10c orphan] se statistikami počtu transakcí vyloučených
  ze sirotčinců jeho uzlů. Osiřelé transakce jsou nepotvrzené transakce,
  pro které uzel ještě nemá všechny jejich rodičovské transakce, bez nichž
  nemohou být transakce začleněny do bloku. Bitcoin Core ve výchozím
  nastavení drží až 100 osiřelých transakcí. Pokud nová osiřelá transakce
  přijde poté, co je sirotčinec již plný, jeden dříve přijatý sirotek je
  vyloučen.

  0xB10C zjistil, že někdy jeho uzly vyloučí více než deset miliónů
  sirotků s vrcholem přes 100 000 vyloučení za minutu. Po zkoumání
  zjistil, že „přes 99 % z nich jsou podobné této [transakci][runestone
  tx], která vypadá jako z runestone mincoven [NFT protokolů].” Zdá
  se, že bylo opakovaně vyžadováno mnoho stejných osiřelých transakcí,
  které byly náhodně vyloučeny a po chvilce opět vyžádány.

- **Aktualizace návrhu aktualizace BIP procesu:** Mark „Murch” Erhardt
  zaslal do emailové skupiny Bitcoin-Dev [příspěvek][erhardt bip3] oznamující,
  že jeho návrh BIPu pro změnu procesu navrhování a schvalování BIPů
  obdržel identifikátor BIP3 a je připraven pro další revizi, snad
  již poslední před začleněním a aktivací. V případě zájmu zanechte
  zpětnou vazbu v příslušné [žádosti o začlenění][bips #1712].

## Bitcoin Core PR Review Club

*V této měsíční rubrice shrnujeme nedávné sezení [Bitcoin Core PR Review Club][] a
vyzdvihujeme některé z důležitých otázek a odpovědí. Klikněte na otázku a odpověď se vám odhalí.*

[Cluster mempool: přidej TxGraph][review club 31363] je PR od Pietera Wuilleho
([sipa][gh sipa]), které přináší třídu `TxGraph`. Třída zapouzdřuje
znalosti (efektivních) poplatků,  velikostí a závislostí mezi
všemi transakcemi v mempoolu. Je součástí projektu [mempoolu
clusterů][topic cluster mempool] a přináší srozumitelné rozhraní
umožňující interakci s grafem mempoolu za použití mutací,
inspektorů a přípravných funkcí.

Za zmínku stojí, že `TxGraph` nemá žádnou znalost o transakcích,
vstupech, výstupech, txid, wtxid, prioritizaci, validitě, pravidlech
apod. Díky tomu je snazší (téměř) plně specifikovat chování třídy
a vytvářet testy založené na simulacích (které jsou součástí PR).

{% include functions/details-list.md
  q0="Co je „graf” mempoolu a do jaké míry je součástí kódu mempoolu v master větvi?"
  a0="V masteru existuje graf mempoolu implicitně v podobě množiny
  objektů typu `CTxMemPoolEntry` jako uzlů, jejichž vztahy mohou
  být rekurzivně procházeny pomocí `GetMemPoolParents()` a `GetMemPoolChildren()`."
  a0link="https://bitcoincore.reviews/31363#l-26"

  q1="Jaké výhody, dle vašich vlastních slov, `TxGraph` přináší?
  Má i nějaké nevýhody?"
  a1="Výhody: 1) `TxGraph` umožní implementovat [mempool clusterů][topic
  cluster mempool] se všemi jeho výhodami. 2) Lepší zapouzdření
  kódu mempoolu a efektivnější datové struktury. 3) Zjednodušuje práci
  s mempoolem, odstiňuje od detailů topologie jako např. nutnost nepočítat
  nahrazené transakce dvakrát.
  <br><br>Nevýhody: 1) Kvůli velkým změnám
  potřeba vynaložit mnoho úsilí na revizi a testování kódu. 2) Omezuje,
  jak může validace určovat transakcím topologické limity, jako např.
  u TRUC a jiných pravidel. 3) Drobný dopad na výkonnost způsobený
  překladem z a na ukazatele `TxGraph::Ref*`."
  a1link="https://bitcoincore.reviews/31363#l-54"

  q2="V kolika `Cluster`ech může být v rámci `TxGraph` jednotlivá transakce součástí?"
  a2="Ačkoliv koncepčně může transakce patřit pouze do jediného
  clusteru, odpověď je 2. Důvodem je, že `TxGraph` může obsahovat
  dva paralelní grafy: hlavní (main) a volitelný přípravný (staging)."
  a2link="https://bitcoincore.reviews/31363#l-116"

  q3="Co znamená, když je `TxGraph` přeplněn (oversized)? Je to stejné,
  jako když je mempool plný?"
  a3="`TxGraph` je přeplněn, když minimálně jeden z jeho `Cluster`ů
  překračuje `MAX_CLUSTER_COUNT_LIMIT`. Není to stejné, jako když je mempool
  plný, protože `TxGraph` může mít více než jeden `Cluster`."
  a3link="https://bitcoincore.reviews/31363#l-147"

  q4="Je-li `TxGraph` přeplněn, které funkce mohou být nadále volány a které
  nemohou?"
  a4="Operace, které by vyžadovaly vytvoření přeplněného clusteru, a funkce,
  které vyžadují O(n<sup>2</sup>) nebo horší, nejsou v přeplněném `TxGraph`u
  povolené. Mezi tyto operace patří mimo jiné počítání předků a potomků
  transakce. Měnitelné operace (`AddTransaction()`, `RemoveTransaction()`,
  `AddDependency()` a `SetTransactionFee()`) a operace jako
  `Trim()` (zhruba O(n log n)) jsou nadále povoleny."
  a4link="https://bitcoincore.reviews/31363#l-162"
%}

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [LND v0.18.5-beta][] je opravné vydání této populární implementace LN uzlu.
  Opravy jsou v poznámkách o vydání popsané jako „důležité” a „kritické.“

- [Bitcoin Inquisition 28.1][] je menším vydáním tohoto [signetového][topic
  signet] plného uzlu navrženého pro experimentování s návrhy soft forků
  a jinými významnými změnami protokolu. Obsahuje opravy chyb z Bitcoin Core
  28.1 a podporu pro [dočasný prach][topic ephemeral anchors] (ephemeral dust).

## Významné změny kódu a dokumentace

_Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo] a [repozitáři BINANA][binana repo]._

- [Bitcoin Core #25832][] přidává pět nových trasovacích bodů (a jejich dokumentaci)
  pro monitorování P2P událostí jako doba spojení, četnost opakovaných spojování
  podle IP a sítě, odrazování od spojení, vylučování, špatné chování apod.
  Uživatelé Bitcoin Core, kteří mají aktivované trasování pomocí Extended Berkeley
  Packet Filter (eBPF), ho mohou použít ke sledování použitím přiložených
  nebo vlastních skriptů (viz též zpravodaje [č. 160][news160 ebpf], _angl._,
  a [č. 244][news244 ebpf]).

- [Eclair #2989][] přidává do routeru podporu pro [dávkové][topic payment batching]
  splicy, což umožní sledovat více kanálů účastnících se jediné [splicingové][topic
  splicing] transakce. Kvůli nemožnosti deterministicky spojit nové [oznámení
  kanálu][topic channel announcements] s odpovídajícím kanálem aktualizuje
  router pouze první kanál, který nalezne.

- [LDK #3440][] ověřuje odesílatelovu žádost o fakturu z [HTLC][topic htlc]
  onion zprávy a generuje správný `PaymentPurpose` pro nárokování platby.
  Tím dokončuje podporu přijímání [asynchronních plateb][topic async payments].
  Pro přicházející asynchronní zprávy je nově nastavena absolutní expirační lhůta,
  což zabrání nekonečnému sondování online stavu uzlu. Dále byla přidána
  komunikační procedura nezbytná pro uvolnění HTLC drženého předešlým uzlem,
  když se uzel opět připojí. Pro kompletní implementaci asynchronních plateb
  musí být uzly schopné jednat jako LSP, který doručuje faktury namísto příjemců.

- [LND #9470][] přidává do RPC příkazů `BumpFee` a `BumpForceCloseFee` parametr
  `deadline_delta`, který určuje počet bloků, během kterých bude daný
  rozpočet plně alokován na navyšování poplatků a [RBF][topic rbf] bude proveden.
  Dále byl předefinován parametr `conf_target` jako počet bloků, který bude použit
  jako cíl při zjišťování aktuálního poplatku, u obou zmíněných příkazů a u již zastaralého
  `BumpCloseFee`.

- [BTCPay Server #6580][] odstraňuje kontrolu přítomnosti a korektnosti
  haše popisku (`description_hash`) v [BOLT11][] fakturách při platbách
  s [LNURL][topic lnurl]-pay. Tato změna je v souladu s [navrženým
  zastaráním][ludpr] v LNURL Documents (LUD) specifikaci, dle kterého
  nabízí tento požadavek minimální bezpečnostní benefity, ale významně
  ztěžuje implementování LNURL-pay. Pole s hašem deskriptoru
  je implementováno v Core-Lightning (viz též zpravodaje [č. 194][news194
  deschash], _angl._, a [č. 232][news232  deschash]).

## Korekce

V [poznámce][fn sigops] v minulém zpravodaji jsme nesprávně napsali:
„Co se týče P2SH a navrhovaného počítání sigops vstupů, `OP_CHECKMULTISIG`
s více než 16 veřejnými klíči se počítá jako 20 sigops.” Jedná se o přílišné
zjednodušení. [Příspěvek][towns sigops] od Anthonyho Townse popisuje přesná
pravidla.

{% include snippets/recap-ad.md when="2025-02-18 15:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="25832,2989,3440,9470,6580,1712" %}
[lnd v0.18.5-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.18.5-beta
[Bitcoin Inquisition 28.1]: https://github.com/bitcoin-inquisition/bitcoin/releases/tag/v28.1-inq
[news340 pp]: /cs/newsletters/2025/02/07/#emulace-op-rand
[towns sigops]: https://delvingbitcoin.org/t/great-consensus-cleanup-revival/710/69
[kurbatov pp]: https://delvingbitcoin.org/t/emulating-op-rand/1409
[harding pp]: https://delvingbitcoin.org/t/emulating-op-rand/1409/2
[towns pp1]: https://delvingbitcoin.org/t/emulating-op-rand/1409/3
[gibson pp1]: https://delvingbitcoin.org/t/emulating-op-rand/1409/5
[towns pp2]: https://delvingbitcoin.org/t/emulating-op-rand/1409/6
[gibson pp2]: https://delvingbitcoin.org/t/emulating-op-rand/1409/7
[morehouse eanchor]: https://delvingbitcoin.org/t/which-ephemeral-anchor-script-should-lightning-use/1412/8
[news340 eanchor]: /cs/newsletters/2025/02/07/#kompromisy-docasnych-anchor-skriptu-v-ln
[towns eanchor]: https://delvingbitcoin.org/t/which-ephemeral-anchor-script-should-lightning-use/1412/9
[sanders eanchor]: https://delvingbitcoin.org/t/which-ephemeral-anchor-script-should-lightning-use/1412/11
[b10c orphan]: https://delvingbitcoin.org/t/stats-on-orphanage-overflows/1421/
[runestone tx]: https://mempool.space/tx/ac8990b04469bad8630eaf2aa51561086d81a241deff6c95d96d27e41fa19f90
[erhardt bip3]: https://mailing-list.bitcoindevs.xyz/bitcoindev/25449597-c5ed-42c5-8ac1-054feec8ad88@murch.one/
[fn sigops]: /cs/newsletters/2025/02/07/#fn:2kmultisig
[review club 31363]: https://bitcoincore.reviews/31363
[gh sipa]: https://github.com/sipa
[news244 ebpf]: /cs/newsletters/2023/03/29/#bitcoin-core-26531
[news160 ebpf]: /en/newsletters/2021/08/04/#bitcoin-core-22006
[ludpr]: https://github.com/lnurl/luds/pull/234
[news232 deschash]: /cs/newsletters/2023/01/04/#btcpay-server-4411
[news194 deschash]: /en/newsletters/2022/04/06/#c-lightning-5121
