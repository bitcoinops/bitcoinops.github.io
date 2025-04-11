---
title: 'Zpravodaj „Bitcoin Optech” č. 349'
permalink: /cs/newsletters/2025/04/11/
name: 2025-04-11-newsletter-cs
slug: 2025-04-11-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Zpravodaj tento týden popisuje návrh na urychlení úvodního stahování
bloků v Bitcoin Core s ukázkovou implementací demonstrující
pětkrát kratší stahování oproti výchozímu nastavení Bitcoin Core.
Též nechybí naše pravidelné rubriky se souhrnem sezení Bitcoin Core PR Review
Clubu, oznámeními nových vydání a popisem významných změn v populárních
bitcoinových páteřních projektech.

## Novinky

- **SwiftSync urychlující úvodní stahování bloků:** Sebastian
  Falbesoner zaslal do fóra Delving Bitcoin [příspěvek][falbesoner ss1]
  s ukázkou implementace a s výkonnostními výsledky _SwiftSync_​u, nápadu
  [navrženého][somsen ssgist] Rubenem Somsenem během nedávného setkání
  vývojářů Bitcoin Core. Později příspěvek [zaslal][somsen ssml] i do emailové
  skupiny. V době psaní zpravodaje tvrdila [většina výsledků][falbesoner
  ss2] ve vlákně 5,28× zrychlení _úvodního stahování bloků_ (IBD) oproti
  výchozím nastavením Bitcoin Core (používajícím [assumevalid][] bez [assumeUTXO][topic
  assumeutxo]). Díky tomu se podařilo snížit čas úvodní synchronizace ze zhruba 41
  hodin na osm.

  Před tím, než je možné SwiftSync používat, musí někdo s uzlem
  synchronizovaným na nějaký nedávný blok vytvořit _hints file_ určující,
  které výstupy budou součástí množiny UTXO v jeho výšce (tedy které
  výstupy jsou neutracené). To lze při současné velikosti množiny UTXO
  efektivně zakódovat do několika set megabajtů. Hints file také určuje,
  pro který blok byl vygenerovaný, nazvěme ho _terminální blok SwiftSyncu_
  (terminal SwiftSync block).

  Uživatel, který chce SwiftSync použít, stáhne tento soubor a pomocí
  něj zpracuje každý blok až do terminálního bloku. Přitom ukládá do množiny UTXO
  pouze výstupy obsažené v hints file. Tento způsob masivně snižuje počet
  položek, které jsou do UTXO databáze během IBD přidány a později z ní odstraněny.

  Aby byla zajištěna správnost hints file, je každý výstup, který do databáze
  UTXO nemá být uložen, přičten do [kryptogafického akumulátoru][cryptographic
  accumulator]. Každý utracený výstup je z akumulátoru odečten. Při dosažení
  terminálního bloku musí být akumulátor prázdný, tedy každý výstup, který
  byl do něj přidán, z něj byl posléze také odebrán (tj. byl utracen). Pokud
  tomu tak není, znamená to, že byl hints file nesprávný, a IBD musí být
  provedeno znovu od začátku a bez SwiftSyncu. Tímto způsobem nemusí uživatelé
  tvůrcům hints file důvěřovat, neboť škodlivý soubor nemůže vyústit ve
  správný stav UTXO. Může jen vést k proplýtvaným několika hodinám práce počítače.

  Další možností SwiftSyncu, která ještě nebyla naimplementována, je možnost
  paralelní validace bloků během IBD. To je možné, jelikož assumevalid nekontroluje
  skripty starších bloků, položky nejsou z databáze UTXO nikdy odstraňovány
  (před dosažením terminálního bloku) a akumulátor pouze sleduje součet výstupů
  přidaných (vytvořené výstupy) a odebraných (utracené výstupy). Díky
  tomu nejsou do dosažení terminálního bloku žádné závislosti mezi jednotlivými
  bloky. Z podobných důvodů nabízí paralelní validaci během IBD i
  [Utreexo][topic utreexo].

  Diskutující se zabývali několika aspekty návrhu. Falbesonerova původní
  implementace používala akumulátor [MuHash][] (viz [zpravodaj č. 123][news123
  muhash], _angl._), u kterého [byla ukázána][wuille muhash] odolnost vůči
  [generalizovanému narozeninovému útoku][generalized birthday attack]. Somsen
  [popsal][somsen ss1] alternativní přístup, který by mohl být rychlejší.
  Falbesoner pochyboval, že by byl tento alternativní přístup kryptograficky
  bezpečný, avšak díky jeho jednoduchosti ho i přesto naimplementoval a zjistil,
  že SwiftSync urychluje ještě více.

  James O'Beirne [se ptal][obeirne ss], zda je SwiftSync užitečný, když
  assumeUTXO nabízí ještě výraznější zrychlení.
  Somsen [odpověděl][somsen ss2], že SwiftSync zrychluje u assumeUTXO
  validaci na pozadí, je tedy i pro uživatele assumeUTXO přínosný. Dále poznamenal,
  že pokud někdo stahuje potřebná data pro assumeUTXO (databázi UTXO v určité
  blokové výšce), nemusí zvlášť stahovat ještě hints file (jsou-li oba
  generované pro stejnou výšku).

  Vojtěch Strnad, 0xB10C a Somsen [diskutovali][b10c ss] o komprimování dat
  v hints file, které by mohlo snížit velikost souborů o 75 % s výslednou
  velikostí pro blok 850 900 kolem 88 MB.

  Diskuze v době psaní nadále probíhala.

## Bitcoin Core PR Review Club

*V této měsíční rubrice shrnujeme nedávné sezení [Bitcoin Core PR Review Club][] a
vyzdvihujeme některé z důležitých otázek a odpovědí. Klikněte na otázku a odpověď se vám odhalí.*

[Přidej správce prediktorů poplatků][review club 31664] je PR od vývojáře
[ismaelsadeeq][gh ismaelsadeeq], které zlepšuje logiku předpovídání transakčních
poplatků (též nazývaného [odhadování][topic fee estimation]). Přináší novou třídu `ForecasterManager`,
která umožňuje registraci více `Forecaster`ů. Stávající `CBlockPolicyEstimator`
(který bere do úvahy pouze potvrzené transakce) je refaktorován do jednoho
z takových prediktorů a je přidán nový `MemPoolForecaster`. Ten pro výpočet
používá nepotvrzené transakce v mempoolu, a proto umí na změny poplatků
reagovat rychleji.

{% include functions/details-list.md
  q0="Proč se tento nový systém nazývá „prediktor” (forecaster) a
  „správce prediktorů” (forecaster manager) a ne „odhadce” (estimator)
  a „správce odhadování poplatků” (fee estimation manager)?"
  a0="Systém předpovídá (predikuje) budoucí dopad na základě současných
  a minulých dat. Na rozdíl od odhadce, který aproximuje aktuální podmínky
  s určitou dávkou náhodnosti, prediktor předpovídá budoucí události,
  což je v souladu s prediktivní povahou tohoto systému."
  a0link="https://bitcoincore.reviews/31664#l-19"

  q1="Proč nebyla do `CBlockPolicyEstimator` přidána reference na mempool,
  podobně jako v PR #12966? Jaký je aktuální přístup a proč je lepší než
  držet referenci na mempool? (Tip: podívejte se na PR #28368)"
  a1="`CBlockPolicyEstimator` dědí z `CValidationInterface` a
  implementuje jeho virtuální metody `TransactionAddedToMempool`,
  `TransactionRemovedFromMempool` a `MempoolTransactionsRemovedForBlock`.
  To poskytuje `CBlockPolicyEstimator` všechna data o mempoolu, aniž by s ním
  musel být úzce provázán přes referenci."
  a1link="https://bitcoincore.reviews/31664#l-26"

  q2="Jaké jsou kompromisy mezi novou architekturou a přímou změnou
  `CBlockPolicyEstimator`u?"
  a2="Nová architektura s třídou `FeeRateForecasterManager`, do které
  se může registrovat více prediktorů (`Forecaster`), je modulárnějším
  přístupem, který umožňuje lepší testování a vynucuje lepší dělení
  zodpovědností. Umožňuje později snadno přidat nové strategie předpovídání.
  Daní za to je větší množství kódu, který se musí udržovat, a možná i
  zmatení uživatelů, kteří si musí vybrat konkrétní metodu."
  a2link="https://bitcoincore.reviews/31664#l-43"
%}

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [Core Lightning 25.02.1][] je údržbovým vydáním současné hlavní verze
  tohoto oblíbeného LN uzlu přinášejícím několik oprav.

- [Core Lightning 24.11.2][] je údržbovým vydáním předchozí hlavní verze
  tohoto populárního LN uzlu. Obsahuje opravy několik chyb, některé z nich
  jsou stejné jako ve vydání 25.02.1.

- [BTCPay Server 2.1.0][] je hlavním vydáním tohoto platebního procesoru s vlastním
  hostováním. Obsahuje nekompatibilní změny pro uživatele některých altcoinů,
  vylepšení navyšování poplatků pomocí [RBF][topic rbf] i [CPFP][topic cpfp]
  a lepší proces vícenásobného podepisování v případech, kdy všichni podepisující
  používají BTCPay Server.

- [Bitcoin Core 29.0rc3][] je kandidátem na vydání příští hlavní verze tohoto
  převládajícího plného uzlu. Prosíme, přečtěte si [průvodce testováním verze
  29][bcc29 testing guide].

- [LND 0.19.0-beta.rc2][] je kandidátem na vydání tohoto oblíbeného LN uzlu.
  Jedním významným vylepšením, které by si zasloužilo důkladné testování, je
  nové schéma RBF navyšování poplatků během kooperativního zavření kanálu.

## Významné změny kódu a dokumentace

_Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo] a [repozitáři BINANA][binana repo]._

- [LDK #2256][] a [LDK #3709][] vylepšují informace o původci selhání (viz
  [zpravodaj č. 224][news224 failures], _angl._) dle specifikace v [BOLTs #1044][].
  Přidává novou strukturu `AttributionData` a do stávající struktury `UpdateFailHTLC`
  přidává volitelné pole `attribution_data`. Dle tohoto protokolu připojí každý
  přeposílající uzel do chybové zprávy příznak `hop_payload`, dobu, po kterou uzel HTLC
  držel, a HMAC na odpovídající pozici v cestě. Pokud nějaký uzel chybovou hlášku
  pozmění, nesoulad v HMAC může identifikovat, mezi kterými dvěma uzly se tak stalo.

- [LND #9669][] mění [jednoduché taprootové kanály][topic simple taproot
  channels], aby vždy používaly zastaralý druh kooperativního zavření, i když
  je nastavený nový druh s [RBF][topic rbf] (viz [zpravodaj č. 347][news347 coop]).
  Dříve uzel s aktivovanými oběma funkcemi nenastartoval.

- [Rust Bitcoin #4302][] přidává do builder API skriptu novou metodu `push_relative_lock_time()`,
  které se předává jako argument relativní [časový zámek][topic timelocks].
  Zároveň změna zastarává metodu `push_sequence()`, jejímž argumentem bylo
  prosté číslo sekvence. Tato změna odstraňuje potenciální zmatení vývojářů,
  kteří neúmyslně přidali do skriptů prosté číslo sekvence namísto relativního
  časového zámku, který je zkontrolován oproti číslu sekvence vstupu pomocí
  `CHECKSEQUENCEVERIFY`.

{% include snippets/recap-ad.md when="2025-04-15 15:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="2256,3709,9669,4302,1044" %}
[bitcoin core 29.0rc3]: https://bitcoincore.org/bin/bitcoin-core-29.0/
[bcc29 testing guide]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/29.0-Release-Candidate-Testing-Guide
[lnd 0.19.0-beta.rc2]: https://github.com/lightningnetwork/lnd/releases/tag/v0.19.0-beta.rc2
[wuille muhash]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2017-May/014337.html
[falbesoner ss1]: https://delvingbitcoin.org/t/ibd-booster-speeding-up-ibd-with-pre-generated-hints-poc/1562/
[somsen ssgist]: https://gist.github.com/RubenSomsen/a61a37d14182ccd78760e477c78133cd
[falbesoner ss2]: https://delvingbitcoin.org/t/ibd-booster-speeding-up-ibd-with-pre-generated-hints-poc/1562/7
[assumevalid]: https://bitcoincore.org/en/2017/03/08/release-0.14.0/#assumed-valid-blocks
[cryptographic accumulator]: https://en.wikipedia.org/wiki/Accumulator_(cryptography)
[news123 muhash]: /en/newsletters/2020/11/11/#bitcoin-core-pr-review-club
[muhash]: https://cseweb.ucsd.edu/~mihir/papers/inchash.pdf
[generalized birthday attack]: https://www.iacr.org/archive/crypto2002/24420288/24420288.pdf
[somsen ss1]: https://delvingbitcoin.org/t/ibd-booster-speeding-up-ibd-with-pre-generated-hints-poc/1562/2
[obeirne ss]: https://delvingbitcoin.org/t/ibd-booster-speeding-up-ibd-with-pre-generated-hints-poc/1562/5
[somsen ss2]: https://delvingbitcoin.org/t/ibd-booster-speeding-up-ibd-with-pre-generated-hints-poc/1562/6
[b10c ss]: https://delvingbitcoin.org/t/ibd-booster-speeding-up-ibd-with-pre-generated-hints-poc/1562/4
[somsen ssml]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CAPv7TjaM0tfbcBTRa0_713Bk6Y9jr+ShOC1KZi2V3V2zooTXyg@mail.gmail.com/T/#u
[core lightning 25.02.1]: https://github.com/ElementsProject/lightning/releases/tag/v25.02.1
[core lightning 24.11.2]: https://github.com/ElementsProject/lightning/releases/tag/v24.11.2
[btcpay server 2.1.0]: https://github.com/btcpayserver/btcpayserver/releases/tag/v2.1.0
[news224 failures]: /en/newsletters/2022/11/02/#ln-routing-failure-attribution
[news347 coop]: /cs/newsletters/2025/03/28/#lnd-8453
[review club 31664]: https://bitcoincore.reviews/31664
[gh ismaelsadeeq]: https://github.com/ismaelsadeeq
[forecastresult compare]: https://github.com/bitcoin-core-review-club/bitcoin/commit/1e6ce06bf34eb3179f807efbddb0e9bca2d27f28#diff-5baaa59bccb2c7365d516b648dea557eb50e63837de71531dc460dbcc62eb9adR74-R77
