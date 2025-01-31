---
title: 'Zpravodaj „Bitcoin Optech” č. 339'
permalink: /cs/newsletters/2025/01/31/
name: 2025-01-31-newsletter-cs
slug: 2025-01-31-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Zpravodaj tento týden popisuje zranitelnost postihující starší verze
LDK, nahlíží na nově odhalenou formu již dříve zveřejněné zranitelnosti
a shrnuje obnovenou diskuzi o statistikách rekonstruování kompaktních
bloků. Též nechybí naše pravidelné rubriky se souhrnem oblíbených
otázek a odpovědí z Bitcoin Stack Exchange, oznámeními nových
vydání a popisem nedávných změn v populárním bitcoinovém páteřním software.

## Novinky

- **Zranitelnost LDK v procesu nárokování:** Matt Morehouse zaslal
  do fóra Delving Bitcoin [příspěvek][morehouse ldkclaim] s odhalením
  zranitelnosti postihující LDK, kterou [zodpovědně nahlásil][topic
  responsible disclosures] a která byla opravena v LDK verze 0.1.
  Během jednostranného zavření kanálu, ve kterém čeká na vyřízení
  několik [HTLC][topic htlc], se LDK pokouší vyřešit co nejvíce HTLC
  v jediné transakci, aby byly minimalizovány transakční poplatky. Pokud
  se však protistraně jako první podaří potvrdit některou z těchto HTLC,
  nastane _konflikt_ s dávkovou transakcí a tím bude zneplatněna.
  V takovém případě LDK správně vytvoří novou, aktualizovanou dávkovou
  transakci bez konfliktu. Bohužel pokud je transakce protistrany
  v konfliktu s několika separátními dávkami, LDK nesprávně aktualizuje
  pouze první dávku. Zbývající dávky potvrzeny nebudou.

  Uzly musí vyřešit svá HTLC před vypršením časové lhůty, jinak by
  protistrana mohla ukrást zpět své prostředky. [Časový zámek][topic
  timelocks] zabraňuje protistraně v utracení HTLC před vypršením
  jejich jednotlivých časových lhůt. Většina starších verzí LDK
  vytvářela jednotlivé dávky s takovými HTLC, u kterých bylo jisté, že
  se potvrdí před tím, než by byla protistrana schopna potvrdit konfliktní
  transakci. Díky tomu nemohly být žádné prostředky ukradené. U HTLC,
  kterým prostředky nemohly být ukradené, ale které mohla protistrana
  okamžitě vyřešit, existovala hrozba, že by mohla protistrana
  tyto prostředky zablokovat. Morehouse píše, že to může být napraveno
  „upgradem LDK na verzi 0.1 a přehráním posloupnosti commitmentů
  a HTLC transakcí, které k zablokování vedly.”

  Kandidát na vydání LDK 0.1-beta však tuto logiku změnil (viz
  [zpravodaj č. 335][news335 ldk3340]) a začal dávkovat všechny druhy
  HTLC dohromady, což útočníkovi umožnilo vytvořit konflikt s HTLC
  a jejími časovými zámky. Pokud nebylo HTLC do vypršení časového
  zámku vyřešené, bylo možné prostředky ukradnout. Vydaná verze
  LDK 0.1 tento druh zranitelnosti opravuje též.

  Morehouseův příspěvek poskytuje další podrobnosti a nabízí možnosti,
  jak budoucím zranitelnostem vycházejícím ze stejné příčiny zabránit.

- **Útoky cyklickým nahrazováním s využitím těžaře:** Antoine Riard
  zaslal do emailové skupiny Bitcoin-Dev [příspěvek][riard minecycle] s
  odhalením další zranitelnosti nad rámec útoku [cyklickým nahrazováním][topic
  replacement cycling], který veřejně odhalil v roce 2023 (viz [zpravodaj
  č. 274][news274 cycle]). Ve stručnosti:

  1. Bob zveřejní transakci platící Mallorymu (a třeba i dalším).

  2. Mallory provede [pinning][topic transaction pinning] Bobovy
     transakce.

  3. Bob si pinningu není vědom a navýší poplatky (pomocí [RBF][topic rbf]
     nebo [CPFP][topic cpfp]).

  4. Protože Bobova původní transakce trpěla pinningem, jeho navýšení
     poplatku se nepropaguje. Avšak Mallory ho nějakým způsobem obdrží.
     Kroky 3 a 4 mohou být opakovány, což výrazně navýší Bobův poplatek.

  5. Mallory vytěží Bobovo nejvyšší navýšení poplatku, které se nikdo
     jiný kvůli nulové propagaci nepokouší vytěžit. To umožní Mallorymu
     na poplatcích vydělávat více v porovnání s ostatními těžaři.

  6. Mallory může nyní použít cyklické nahrazování k přemístění jeho
     pinningu na jinou transakci a útok opakovat (možno i s jinou obětí).
     Nepotřebuje k tomu alokovat nové prostředky, proto je útok ekonomicky
     účinný.

  Nepovažujeme tuto zranitelnost za vážnou hrozbu. Její zneužití vyžaduje
  specifické okolnosti, které nastávají zřídka a mohou útočníkovi způsobit
  ztrátu peněz, pokud chybně vyhodnotí podmínky v síti. Pokud by útočník
  tuto zranitelnost zneužíval pravidelně, věříme, že by jeho chování
  bylo odhaleno činností členů komunity, která buduje a používá nástroje
  pro [monitorování bloků][miningpool.observer].

- **Aktualizované statistiky rekonstruování kompaktních bloků:** vývojář
  0xB10C zaslal do fóra Delving Bitcoin [příspěvek][b10c cb] s aktualizovanou
  (pro předchozí zmínku viz [zpravodaj č. 315][news315 cb]) statistikou
  ukazující, kolikrát potřebovaly jeho Bitcoin Core uzly vyžádat
  dodatečné transakce pro vykonání rekonstrukce [kompaktních bloků][topic compact
  block relay]. Když uzel obdrží kompaktní blok, musí požádat o jakoukoliv
  transakci, kterou ještě nemá ve svém mempoolu (nebo ve svém
  _extrapoolu_, což je speciální rezerva určená pro pomoc s rekonstrukcí
  kompaktních bloků). To výrazně zpomaluje propagaci bloků a přispívá
  k centralizaci těžby.

  0xB10C zjistil, že četnost žádostí se významně zvyšuje s nárůstem velikosti
  mempoolu. Několik vývojářů diskutovalo o možných příčinách. Prvotní
  data ukazují, že chybějící transakce byly _sirotky_, potomky neznámých
  rodičovských transakcí, které Bitcoin Core ukládá pouze na krátkou dobu
  pro případ, že by jejich rodičovské transakce brzy dorazily. Napravit
  tuto situaci by mohlo vylepšené sledování a vyžadování rodičů osiřelých
  transakcí, které bylo nedávno začleněno do Bitcoin Core (viz
  [zpravodaj č. 338][news338 orphan]).

  Vývojáři dále hovořili o jiných možných řešeních. Uzly nemohou držet
  osiřelé transakce příliš dlouho, protože je útočník může vytvářet
  zdarma, ale snad by jich (a jiných vyloučených transakcí) mohly
  v extrapoolu ukládat větší množství a po delší dobu. V době psaní
  nedosáhla diskuze závěru.

## Vybrané otázky a odpovědi z Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] je jedním z prvních míst, kde hledají
přispěvatelé Optechu odpovědi na své otázky a kde – najdou-li volnou chvíli –
pomáhají zvědavým či zmateným uživatelům. V této měsíční rubrice nabízíme
některé z otázek a odpovědí, které obdržely vysoký počet hlasů.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Kdo používá nebo chce používat PSBTv2 (BIP370)?]({{bse}}125384)
  Kromě příspěvku do emailové skupiny Bitcoin-Dev (viz [zpravodaj č.
  338][news338 psbtv2]) otevřel Sjors Provoost též vlákno v Bitcoin Stack
  Exchange, ve kterém hledá uživatele a potenciální uživatele [PSBTv2][topic
  psbt]. Čtenáři se zájmem o [BIP370][] by měli odpovědět v tomto vlákně nebo
  na příspěvek v emailové skupině.

- [Které části bitcoinového genesis bloku mohou být vyplněné libovolně?]({{bse}}125274)
  Pieter Wuille vysvětluje, že žádné pole bitcoinového [genesis bloku][mempool
  genesis block] nepodléhá běžným pravidlům validace: „Doslova všechna
  pole mohla obsahovat cokoliv. Vypadá jako normální blok, ale nemusel tak
  vypadat.”

- [Detekce vynucených uzavření lightningových kanálů]({{bse}}122504)
  Sanket1729 a Antoine Poinsot diskutují, jak [prohlížeč bloků][topic block explorers]
  mempool.space používá pro určení, zda je transakce vynuceným uzavřením
  lightningového kanálu, pole [`nLockTime`][topic timelocks] a `nSequence`.

- [Je transakce formátovaná jako segwitová a mající všechny vstupy bez witnessů validní?]({{bse}}125240)
  Pieter Wuille činí rozdíl mezi [BIP141][], který specifikuje strukturu a validitu
  kolem segwitu jako změny konsenzu a výpočet wtxid, a [BIP144][], který specifikuje
  formát serializace pro výměnu segwitových transakcí.

- [Otázka ohledně bezpečnosti P2TR]({{bse}}125334)
  Pieter Wuille citací z [BIP341][], který specifikuje [taproot][topic taproot],
  vysvětluje, proč je veřejný klíč obsažen přímo ve výstupu a jak se to
  vztahuje ke kvantovým výpočtům.

- [Co přesně se dnes dělá pro „kvantově bezpečný” bitcoin?]({{bse}}125171)
  Murch komentuje současný stav kvantových možností, nedávných
  [post-kvantových schémat podepisování][topic quantum resistance] a návrh BIPu
  [QuBit - Pay to Quantum Resistant Hash][BIPs #1670] (platba na kvantově
  odolný haš).

- [Čím by byl kratší čas mezi bloky škodlivý?]({{bse}}125318)
  Pieter Wuille vyzdvihuje, jakou výhodu má díky době propagace těžař, který právě
  našel blok, jak tuto výhodu násobí kratší čas mezi bloky a jaké jsou
  potencální důsledky.

- [Mohl by proof of work nahradit pravidla mempoolu?]({{bse}}124931)
  Jgmontoya se táže, zda by proof of work přidaný k nestandardním transakcím
  mohl dosáhnout podobné [ochrany zdrojů uzlu][policy series] jako pravidla
  mempoolu. Antoine Poinsot vysvětluje, že pravidla mempoolu mají i jiné
  cíle, než je ochrana zdrojů, včetně efektivní tvorby šablon bloků,
  odrazování od některých druhů transakcí a zajištění hladkého nasazení
  [soft forků][topic soft fork activation] (soft fork upgrade hooks).

- [Jak v reálných bitcoinových situacích funguje MuSig?]({{bse}}125030)
  Pieter Wuille nejprve objasňuje rozdíly mezi verzemi [MuSigu][topic musig],
  komentuje variantu MuSig1 s podporou interaktivních agregovaných podpisů
  (Interactive Aggregated Signature, IAS) a jejich význam pro [agregaci podpisů
  napříč vstupy][topic cisa] (cross-input signature aggregation, CISA), poté
  odpovídá na dotazy o nižších úrovních specifikace.

- [Jak funguje přepínač -blocksxor, který maskuje soubory blocks.dat?]({{bse}}125055)
  Vojtěch Strnad popisuje volbu `-blocksxor`, která v Bitcoin Core zapíná
  maskování datových souborů s bloky (viz [zpravodaj č. 316][news316 xor]).

- [Jak funguje útok na Schnorrovy podpisy s odvozenými klíči?]({{bse}}125328)
  Pieter Wuille odpovídá, že „tento útok nastává, když si oběť zvolí nějaký odvozený
  klíč a útočník ví, jak byl klíč odvozen,” a že odvozené klíče jsou naprosto
  běžné.

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [LDK v0.1.1][] je bezpečnostním vydáním této populární knihovny pro budování
  aplikací s podporou LN. Útočník, který je ochotný obětovat přinejmenším
  1 % prostředků kanálu, by mohl klamem donutit oběť k zavření jiných,
  nesouvisejících kanálů. To by mohlo vyústit ve zbytečné utracení
  peněz oběti za transakční poplatky. Matt Morehouse, který zranitelnost
  objevil, ji [popsal][morehouse ldk-dos] ve fóru Delving Bitcoin.
  Optech v příštím čísle poskytne podrobnější souhrn. Vydání dále
  obsahuje aktualizované API a opravy chyb.

## Významné změny kódu a dokumentace

_Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Bitcoin Inquisition][bitcoin inquisition repo] a [repozitáři BINANA][binana
repo]._

- [Bitcoin Core #31376][] rozšiřuje kontrolu, která těžařům brání ve vytváření šablon
  bloků zneužívajících [ohýbání času][topic time warp], na všechny sítě.
  Dříve byla aplikována pouze v [testnet4][topic testnet]. Tato změna napomůže
  případnému budoucímu soft forku, který by chybu navždy opravil.

- [Bitcoin Core #31583][] přidává do výsledků RPC volání `getmininginfo`, `getblock`,
  `getblockheader`, `getblockchaininfo` a `getchainstates` pole `nBits`
  (kompaktní reprezentace cíle složitosti) a `target` (cíl složitosti).
  Dále přidává do `getmininginfo` objekt `next` s výškou, `nBits`, složitostí
  a cílem příštího bloku. PR přidává pomocné funkce `DeriveTarget()` a
  `GetTarget()` pro výpočet cíle. Změny jsou užitečné pro implementaci
  [Stratum V2][topic pooled mining].

- [Bitcoin Core #31590][] mění metodu `GetPrivKey()` tak, aby se při hledání
  soukromých klíčů pro veřejné klíče pouze s x-ovou ([x-only][topic x-only
  public keys]) souřadnicí v [deskriptorech][topic descriptors] dívala na obě
  parity. Pokud byl dříve veřejný klíč uložen s nesprávnou paritou, jeho
  soukromý klíč nebyl nalezen a transakce nemohly být podepsané.

- [Eclair #2982][] přináší volbu nastavení `lock-utxos-during-funding`, která
  poskytovatelům [inzerátů likvidity][topic liquidity advertisements] pomůže
  zabránit určitému druhu otravných útoků, které by mohly poctivým uživatelům
  po dlouhou dobu bránit v používání svých UTXO. Ve výchozím stavu je volba
  nastavena na `true`, tedy UTXO jsou během vytváření kanálů zamčená a jsou
  náchylná ke zneužití. V případě nastavení na `false` je zamykání UTXO
  vypnuto a útoku tak může být zcela zabráněno. Může to však negativně ovlivnit
  poctivá spojení. PR dále přidává mechanismus s nastavitelnou časovou lhůtou, který
  automaticky zruší příchozí kanály, pokud druhá strana přestane komunikovat.

- [BDK #1614][] přidává podporu pro stahování potvrzených transakcí pomocí
  [kompaktních filtrů bloků][topic compact block filters] dle specifikace
  v [BIP158][]. Do modulu `bdk_bitcoind_rpc` byla přidání podpora pro BIP158
  a nový typ `FilterIter`, který může být použit pro získání bloků s transakcemi
  s odpovídajícími scriptPubKey.

- [BOLTs #1110][] začleňuje specifikaci protokolu pro [peer storage][topic peer
  storage], který uzlu umožní na vyžádání a za poplatek uložit až 64 kB zašifrovaných
  dat pro své spojení. Core Lightning a Eclair protokol již implementují (viz zpravodaje
  [č. 238][news238 peer], respektive [č. 335][news335 peer]).

{% include snippets/recap-ad.md when="2025-02-04 15:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="31376,31583,31590,2982,1614,1110,1670" %}
[morehouse ldkclaim]: https://delvingbitcoin.org/t/disclosure-ldk-invalid-claims-liquidity-griefing/1400
[news335 ldk3340]: /cs/newsletters/2025/01/03/#ldk-3340
[riard minecycle]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CALZpt+EnDUtfty3X=u2-2c5Q53Guc6aRdx0Z4D75D50ZXjsu2A@mail.gmail.com/
[miningpool.observer]: https://miningpool.observer/template-and-block
[b10c cb]: https://delvingbitcoin.org/t/stats-on-compact-block-reconstructions/1052/5
[news315 cb]: /cs/newsletters/2024/08/09/#statistika-rekonstruovani-kompaktnich-bloku
[news338 orphan]: /cs/newsletters/2025/01/24/#bitcoin-core-31397
[news274 cycle]: /cs/newsletters/2023/10/25/#zranitelnost-replacement-cycling-postihujici-htlc
[ldk v0.1.1]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.1.1
[morehouse ldk-dos]: https://delvingbitcoin.org/t/disclosure-ldk-duplicate-htlc-force-close-griefing/1410
[news238 peer]: /cs/newsletters/2023/02/15/#core-lightning-5361
[news335 peer]: /cs/newsletters/2025/01/03/#eclair-2888
[news338 psbtv2]: /cs/newsletters/2025/01/24/#integracni-test-psbtv2
[mempool genesis block]: https://mempool.space/block/000000000019d6689c085ae165831e934ff763ae46a2a6c172b3f1b60a8ce26f
[policy series]: /cs/blog/waiting-for-confirmation/#pravidla-pro-ochranu-zdroj%C5%AF-uzl%C5%AF
[news316 xor]: /cs/newsletters/2024/08/16/#bitcoin-core-28052
