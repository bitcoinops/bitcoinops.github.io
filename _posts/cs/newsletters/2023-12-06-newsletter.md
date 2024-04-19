---
title: 'Zpravodaj „Bitcoin Optech” č. 280'
permalink: /cs/newsletters/2023/12/06/
name: 2023-12-06-newsletter-cs
slug: 2023-12-06-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Tento týden popisujeme několik diskuzí o navrhovaném cluster mempoolu
a shrnujeme výsledky testu provedeného pomocí warnetu. Též nechybí naše
pravidelné rubriky se souhrnem sezení Bitcoin Core PR Review Clubu,
oznámeními o nových vydáních a popisem významných změn v populárním
bitcoinovém páteřním software.

## Novinky

- **Diskuze o cluster mempoolu:** vývojáři Bitcoin Core pracující na
  [cluster mempoolu][topic cluster mempool] ustanovili v rámci fóra
  Delving Bitcoin svou [pracovní skupinu][wg-cluster-mempool]. Cluster
  mempool je návrh na usnadnění práce s mempoolem za zachování požadovaného
  řazení transakcí. Validní řazení bitcoinových transakcí požaduje, aby
  byli předkové potvrzeni dříve než potomci. Toho lze dosáhnout začleněním
  předka v dřívějším bloku nebo na dřívější pozici v rámci stejného bloku.
  Dle návrhu cluster mempoolu jsou _clustery_ jedné nebo více souvisejících
  transakcí rozděleny do _chunků_ seřazených dle jednotkového poplatku.
  Kterýkoliv chunk může být začleněn do bloku (až do maximální váhy bloku),
  pokud jsou všechny předchozí nepotvrzené chunky (s vyššími jednotkovými
  poplatky) zařazeny dříve do stejného bloku.

  Jakmile jsou všechny transakce seřazeny do clusterů a clustery rozděleny
  do chunků, je jednoduché vybrat transakce pro začlenění do bloku:
  stačí zvolit chunk s nejvyšším jednotkovým poplatkem, potom s druhým
  nejvyšším a tak dále až do zaplnění bloku. Je-li použit tento algoritmus,
  je zřejmé, že chunk s nejnižším jednotkovým poplatkem je také chunk, který
  má do začlenění do bloku nejdále. Můžeme tedy použít převrácený algoritmus
  na vypořádání se s plným mempoolem, kdy je potřeba vyhodit některé transakce:
  vyhoďme chunk s nejnižším jednotkovým poplatkem, potom druhým nejnižším a
  tak dále, dokud není náš mempool opět pod svou zamýšlenou nejvyšší velikostí.

  Archiv pracovní skupiny je nyní přístupný všem, avšak pouze pozvaní členové
  mohou přispívat. Vybíráme některá zajímavá diskutovaná témata:

  - [Definice a teorie cluster mempoolu][clusterdef] přináší definice
    termínů použitých v návrhu cluster mempoolu. Též přináší několik
    vět, které demonstrují užitečné vlastnosti tohoto návrhu. Tento jediný
    příspěvek vlákna (v době psaní zpravodaje) je užitečný k porozumění
    dalších debat pracovní skupiny, ačkoliv jeho autor (Pieter Wuille)
    [varuje][wuille incomplete], že je stále „velice neúplný.”

  - [Sloučení neporovnatelných linearizací][cluster merge] zkoumá, jak sloučit
    dvě odlišené sady chunků (chunkování, „chunkings”) shodných množin transakcí,
    které jsou _neporovnatelné_. Porovnáním dvou odlišných sad chunků (chunkování)
    bychom mohli určit, která z nich by byla pro těžaře výhodnější. Chunkování
    by mohla být porovnána, pokud by jedno z nich vždy akumulovalo shodnou
    nebo vyšší výši poplatků v rámci libovolné hodnoty vbyte (diskrétní
    podle velikost chunku). Například:

    ![Comparable chunkings](/img/posts/2023-12-comparable-chunkings.png)

    Naopak neporovnatelná by byla, pokud by jedno z nich akumulovalo
    větší výši poplatků v rámci určitého rozmezí vbyte, a to druhé
    větší výši poplatků v jiném rozmezí, například:

    ![Incomparable chunkings](/img/posts/2023-12-incomparable-chunkings.png)

    Jak poznamenává jedna z vět zmíněná v předchozím příspěvku, „existují-li
    dvě neporovnatelná chunkování, potom musí existovat třetí, které je
    lepší než obě.” To znamená, že efektivní způsob, jakým sloučit dvě
    odlišná, neporovnatelná chunkování může být mocným nástrojem pro zvýšení
    těžařovy profitability. Příklad: je přijata nový transakce, která
    souvisí s jinou transakcí z mempoolu. Její cluster musí být aktualizován,
    a tedy i její chunkování musí být upraveno. Mohou být provedeny dva různé
    způsoby této úpravy:

    1. Je spočítáno nové chunkování pro aktualizovaný cluster. Pro velké clustery
       může být nalezení optimálního chunkování výpočetně nepraktické, nové
       chunkování tedy může být méně optimální než staré.

    2. Předchozí chunkování z předchozího clusteru je aktualizováno
       vložením nové transakce na místo, které je validní (předci
       před potomky). Výhodou je, že jakékoliv stávající optimalizace
       zůstávají nedotčené, na druhou stranu by transakce mohla být
       umístěna v neoptimálním místě.

    Když jsou obě metody vykonány, můžeme porovnáním zjistit, že výsledek
    jedné je lepší, může tedy být použit. Avšak jsou-li obě aktualizace
    neporovnatelné, lze použít metodu, která zaručuje ekvivalentní nebo
    lepší výsledek sloučení, k vytvoření třetího chunkování, které obsáhne
    nejlepší součásti obou přístupů: použitím nových chunkování, pokud jsou
    lepší, nebo zachování předchozích, pokud ta se blíží optimu.

  - [RBF balíčku v době clusterů][cluster rbf] se zabývá alternativami
    k pravidlům používaným v současnosti pro [nahrazování poplatkem][topic
    rbf]. Obdrží-li uzel validní nahrazení jedné nebo více transakcí,
    může být vytvořena dočasná verze všech dotčených clusterů a odvozeno
    jejich nové chunkování. To potom může být porovnáno s chunkováním
    původních clusterů v mempoolu (bez nahrazení). Pokud chunkování
    s nahrazením přináší vždy stejně nebo více na poplatcích než originální
    pro jakýkoliv počet vbyte, a pokud navyšuje celkovou hodnotu poplatků
    v mempoolu natolik, aby zaplatilo za své poplatky, potom může být
    začleněno do mempoolu.

    Toto vyhodnocování založené na důkazech by mohlo nahradit několik
    [heuristik][mempool replacements], které jsou v současnosti v Bitcoin
    Core používány k určení, zda má být transakce nahrazena. To by mohlo
    v několika oblastech zlepšit pravidla RBF, včetně navrhovaného
    [přeposílání balíčků][topic package relay] pro nahrazování.
    Několik [dalších][cluster rbf-old1] vláken [se též][cluster rbf-old2]
    zabývalo [tímto][cluster rbf-old3] tématem.

- **Testování s warnetem:** Matthew Zipkin zaslal do Delving Bitcoin
  [příspěvek][zipkin warnet] s výsledky simulací, které provádí pomocí
  [warnetu][warnet], programu spouštějícímu velké množství bitcoinových
  uzlů s definovanými vzájemnými spojeními (obvykle v testovací síti).
  Zipkinovy výsledky ukazují, jaká paměť navíc by byla potřeba, pokud
  by bylo přijato několik navrhovaných změn kódu správy spojení (ať již
  nezávisle nebo spolu). Dále poznamenává, že by rád prováděl testovací
  simulace i dalších navrhovaných změn a měřil dopad navrhovaných útoků.

## Bitcoin Core PR Review Club

*V této měsíční rubrice shrnujeme nedávné sezení [Bitcoin Core PR Review Club][] a
vyzdvihujeme některé z důležitých otázek a odpovědí. Klikněte na otázku a odpověď se vám odhalí.*

Sezení review klubu [Testování kandidátů na vydání Bitcoin Core 26.0][review club v26-rc-testing]
se nezabývalo konkrétním PR, ale společným testováním.

Důsledné testování členy komunity před každým [hlavním vydáním Bitcoin Core][major Bitcoin Core release]
je nezbytné. Z tohoto důvodu sepíše dobrovolník průvodce testování [kandidáta na
vydání][release candidate], aby mohlo co nejvíce lidí efektivně testovat,
aniž by museli sami zjišťovat, co je nového, co se změnilo a jaké kroky je potřeba
podniknout k jejich otestování.

Testování může být náročné, protože nemusí být v případě neočekávaného chování
jasné, zda se jedná o chybu programu či omyl v testování. Reportování chyb,
které nejsou skutečnými chybami, plýtvá časem vývojářů. Sezení review klubu
se zabývá konkrétním kandidátem na vydání (v tomto případě 26.0rc2), aby se předešlo
podobným problémům.

[Průvodce testováním kandidáta na vydání 26.0][26.0 testing] napsal Max Edwards,
který se též zhostil vedení sezení review klubu. Pomáhal mu Stéphan (stickies-v).

Účastníci byli dále vyzýváni, aby se čtením [poznámek k vydání 26.0][26.0 release notes] sami inspirovali
k nápadům na testování.

Toto sezení klubu se zabývalo dvěma RPC voláními: [`getprioritisedtransactions`][PR
getprioritisedtransactions] (bylo též předmětem [jednoho z předchozích sezení][news250 pr review],
ačkoliv tehdy ještě pod jiným názvem) a [`importmempool`][PR importmempool].
Tato i další nová volání jsou popsána v sekci poznámek k vydání [New RPCs][].
Sezení se dále zabývalo [přenosem verze 2 (BIP324)][topic v2 p2p transport]
a zamýšlelo též pokrýt [TapMiniscript][PR TapMiniscript], ale z časových důvodů
se na toto téma nedostalo.

{% include functions/details-list.md
  q0="Které operační systémy lidé používají?"
  a0="Ubuntu 22.04 na WSL (Windows Subsystem for Linux); macOS 13.4 (M1 chip)."
  a0link="https://bitcoincore.reviews/v26-rc-testing#l-18"

  q1="Jaké byly výsledky vašeho testování `getprioritisedtransactions`?"
  a1="Účastníci hlásili, že fungovalo dle očekávání, avšak jeden z nich si
      povšiml, že se důsledek [`prioritisetransaction`][prioritisetransaction]
      sčítal: pokud bylo voláno dvakrát pro stejnou transakci, poplatek se
      zdvojil.
      Toto chování je dle očekávání. Poplatek v argumentu je _přičten_ ke
      stávající prioritě transakce."
  a1link="https://bitcoincore.reviews/v26-rc-testing#l-32"

  q2="Jakých výsledků testování `importmempool` jste dosáhli?"
  a2="Jeden z účastníku obdržel chybu \"Importovat mempool lze až po stažení
      bloků a synchronizaci\", avšak po dvou minutách čekání bylo volání
      úspěšné. Jiný účastník poznamenal, že to trvá dlouho."
  a2link="https://bitcoincore.reviews/v26-rc-testing#l-45"

  q3="Co se stane, pokud během importu přerušíme CLI proces a potom jej bez
      zastavení `bitcoind` restartujeme?"
  a3="Toto nezpůsobilo žádné potíže, druhý požadavek o import se dokončil
      podle očekávání. Zdá se, že proces importování pokračoval i po přerušení
      CLI příkazu a druhý požadavek nezpůsobil, aby dvě vlákna importu běžela
      najednou a kolidovala se sebou."
  a3link="https://bitcoincore.reviews/v26-rc-testing#l-91"

  q4="Jaký byl výsledek provozování přenosu verze 2?"
  a4="Účastníci nebyli schopni připojit se ke známému uzlu s V2 na mainnetu.
      Zdálo se, že nepřijímal žádná spojení. Je možné, že všechny příchozí
      sloty uzlu již byly obsazené. Z tohoto důvodu nedošlo během sezení
      k testování P2P."
  a4link="https://bitcoincore.reviews/v26-rc-testing#l-115"
%}

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [Bitcoin Core 26.0][] je další hlavní vydání této převládající implementace
  plného uzlu. Vydání obsahuje experimentální podporu pro [protokol přenosu
  verze 2][topic v2 p2p transport], [taproot][topic taproot] v [miniscriptu][topic
  miniscript], nová RPC volání pro práci s [assumeUTXO][topic assumeutxo],
  experimentální RPC volání pro zpracování [balíčků][topic package relay]
  transakcí (podpora pro přeposílání ještě začleněna není) a množství dalších
  vylepšení a oprav chyb.

- [LND 0.17.3-beta.rc1][] je kandidátem na vydání obsahující opravy několika chyb.

## Významné změny kódu a dokumentace

*Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo] a
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [Bitcoin Core #28848][] upravuje chybová hlášení RPC volání `submitpackage`.
  Namísto vrácení `JSONRPCError` s první chybou nově vrací výsledek za každou transakci.

- [LDK #2540][] staví na posledním vývoji [zaslepených cest][topic rv routing] v LDK
  (viz zpravodaje [č. 257][news257 ldk2120] a [č. 266][news266 ldk2411]) a přidává
  podporu pro přeposílání jako první uzel v zaslepené cestě. Změna je součástí
  [vývoje][LDK #1970] podpory [nabídek][topic offers] dle BOLT12.

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 15:00" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="28848,2540,1970" %}
[bitcoin core 26.0]: https://bitcoincore.org/bin/bitcoin-core-26.0/
[26.0 testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/26.0-Release-Candidate-Testing-Guide
[wg-cluster-mempool]:  https://delvingbitcoin.org/c/implementation/wg-cluster-mempool/9
[clusterdef]: https://delvingbitcoin.org/t/clustermempool-definitions-theory/202
[cluster merge]: https://delvingbitcoin.org/t/merging-incomparable-linearizations/209/38
[cluster rbf]: https://delvingbitcoin.org/t/post-clustermempool-package-rbf-per-chunk-processing/190
[cluster rbf-old1]: https://delvingbitcoin.org/t/defunct-post-clustermempool-package-rbf/173
[cluster rbf-old2]: https://delvingbitcoin.org/t/defunct-cluster-mempool-package-rbf-sketch/171
[cluster rbf-old3]: https://delvingbitcoin.org/t/cluster-mempool-rbf-thoughts/156
[zipkin warnet]: https://delvingbitcoin.org/t/warnet-simulations/232
[warnet]: https://github.com/bitcoin-dev-project/warnet
[wuille incomplete]: https://github.com/bitcoinops/bitcoinops.github.io/pull/1421#discussion_r1414487021
[mempool replacements]: https://github.com/bitcoin/bitcoin/blob/fa9cba7afb73c01bd2c8fefd662dfc80dd98c5e8/doc/policy/mempool-replacements.md
[LND 0.17.3-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.17.3-beta.rc1
[review club v26-rc-testing]: https://bitcoincore.reviews/v26-rc-testing
[major bitcoin core release]: https://bitcoincore.org/en/lifecycle/#major-releases
[26.0 release notes]: https://github.com/bitcoin/bitcoin/blob/44d8b13c81e5276eb610c99f227a4d090cc532f6/doc/release-notes.md
[new rpcs]: https://github.com/bitcoin/bitcoin/blob/44d8b13c81e5276eb610c99f227a4d090cc532f6/doc/release-notes.md#new-rpcs
[news250 pr review]: /cs/newsletters/2023/05/10/#bitcoin-core-pr-review-club
[release candidate]: https://bitcoincore.org/en/lifecycle/#versioning
[pr getprioritisedtransactions]: https://github.com/bitcoin/bitcoin/pull/27501
[pr importmempool]: https://github.com/bitcoin/bitcoin/pull/27460
[pr tapminiscript]: https://github.com/bitcoin/bitcoin/pull/27255
[prioritisetransaction]: https://developer.bitcoin.org/reference/rpc/prioritisetransaction.html
[news257 ldk2120]: /cs/newsletters/2023/06/28/#ldk-2120
[news266 ldk2411]: /cs/newsletters/2023/08/30/#ldk-2411
