---
title: 'Zpravodaj „Bitcoin Optech” č. 391'
permalink: /cs/newsletters/2026/02/06/
name: 2026-02-06-newsletter-cs
slug: 2026-02-06-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Zpravodaj tento týden odkazuje na práci na paralelizované UTXO databázi s
dotazy v konstantním čase, shrnuje nový vysokoúrovňový jazyk pro psaní
bitcoinového Scriptu a popisuje myšlenku na obranu proti útokům prachem.
Též nechybí naše pravidelné rubriky se souhrnem diskuzí o změnách pravidel
bitcoinového konsenzu, s oznámeními nových vydání a s popisem významných
změn v populárním bitcoinovém páteřním software.

## Novinky

- **Paralelizovaná UTXO databáze s dotazy v konstantním časem**: Toby Sharp
  zaslal do fóra Delving Bitcoin [příspěvek][hornet del] o svém novém projektu
  Hornet UTXO(1), vlastní vysoce paralelizovatelné UTXO databázi s dotazy
  v konstantním čase. Jedná se o další komponentu experimentálního bitcoinového
  klienta [Hornet Node][hornet website] zaměřeného na poskytování minimální
  spustitelné specifikace bitcoinových pravidel konsenzu. Nová databáze
  si klade za cíl zrychlit úvodní stahování bloků (IBD) pomocí
  bezzámkové, vysoce souběžné architektury.

  Kód je napsaný v moderním C++23 bez externích závislostí. Pro dosažení vyšší
  rychlosti upřednostňuje seřazená pole a [LSM stromy][lsmt wiki] namísto [hašovacích
  map][hash map wiki]. Operace jako přidat, najít a stáhnout jsou spouštěny
  souběžně a bloky jsou zpracovávány mimo pořadí podle toho, jak přijdou; datové
  závislosti mezi nimi jsou řešeny automaticky. Kód ještě není veřejně dostupný.

  Sharp poskytl výsledky výkonnostního testu, aby vyhodnotil schopnosti svého
  softwaru. Validace celého řetězce na mainnetu trvala s Bitcoin Core v30
  167 minut (bez validace skriptů a podpisů), s Hornet UTXO(1) trvala
  15 minut. Testy byly provedeny na počítači se 32 jádry, 128 GB RAM a 1 TB
  úložiště.

  V následné diskuzi doporučili vývojáři Sharpovi porovnat výkonnost
  s [libbitcoin][libbitcoin gh], který je známý velmi efektivním IBD.

- **Bithoven: formálně ověřený imperativní jazyk pro bitcoinový Script:**
  Hyunhum Cho zaslal do fóra Delving Bitcoin [příspěvek][delving hc bithoven]
  o své [práci][arxiv hc bithoven] na Bithovenu, což je alternativa
  [miniscriptu][topic miniscript]. Na rozdíl od predikátového jazyka miniscriptu,
  který vyjadřuje možná naplnění zamykacího skriptu, používá Bithoven známější
  céčkovou syntax s primárními operátory `if`, `else`, `verify` a `return`.
  Kompilátor se stará o kompletní správu zásobníku a nabízí podobné
  garance jako kompilátor miniskriptu, mimo jiné ohledně všech cest vyžadujících
  alespoň jeden podpis.

- **Diskuze o bránění proti útokům prachem**: Bubb1es zaslal do fóra Delving Bitcoin
  [příspěvek][dust attacks del] o způsobu, jak se zbavit [útoků prachem][topic
  output linking] (dust attacks) na onchain peněženky. Tento druh útoku nastává,
  když nepřátelská strana pošle UTXO s prachem na všechny anonymní adresy, které
  chce sledovat, a doufá, že některá z nich bude neúmyslně utracena s nesouvisejícím
  UTXO.

  _Většina_ peněženek s tímto problémem dnes nakládá tak, že označuje UTXO s prachem,
  která nepovolí utratit. To může být v budoucnosti problém, pokud uživatel obnoví
  peněženku z klíčů a nový softwarový klient neví, že jsou tato UTXO označena,
  a umožní jejich utracení. Bubb1es navrhuje jiný způsob bránění se útokům prachem:
  vytvořením transakce s tímto UTXO s prachem, která utrácí celou částku
  a má `OP_RETURN` výstup, díky kterému jej nelze utratit. To je možné,
  protože Bitcoin Core v30.0 má nižší minimální poplatek pro přeposílání
  (0,1 sat/vbyte).

  Dále vyjmenovává několik možných problémů s implementacemi peněženek, které
  s prachovými UTXO nakládají tímto způsobem:

  1. Pokud schéma implementuje jen několik peněženek, lze provádět sledování
     digitálním otiskem (fingerprinting).

  2. Je-li současně zveřejněno několik prachových UTXO, je možné je korelovat.

  3. V případě zvýšení poplatků může být potřeba transakci znovu rozeslat.

  4. Hardwarové a multisig podepisování prachových UTXO může být ztížené.

  AJ Towns zmínil, že minimální velikost pro přeposílání je 65 bajtů, a
  vysvětlil, že použití ANYONECANPAY|ALL s tříbajtovým `OP_RETURN` by bylo
  efektivnější.

  Bubb1es dále poskytl experimentální nástroj [ddust][ddust tool], který tento
  mechanismus demonstruje.

## Diskuze o změnách konsenzu

_Měsíční rubrika shrnující návrhy a diskuze o změnách pravidel
bitcoinového konsenzu._

- **SHRINCS: 324bajtové stavové postkvantové podpisy se statickými zálohami:**
  V návaznosti na [bitcoinové podpisy založené na hašování][news386 jn
  hash] přednesl Jonas Nick v [příspěvku][delving jn shrings] ve fóru Delving
  Bitcoin konkrétní [kvantově odolný][topic quantum resistance] algoritmus
  podepisování založený na hašování, který by mohl mít užitečné vlastnosti
  pro používání v bitcoinu.

  Článek obsahoval diskuzi o kompromisech mezi stavovými a bezstavovými podpisy,
  kde stavové podpisy mohou být výrazně levnější, avšak za cenu složitého systému
  zálohování. SHRINCS nabízí kompromis: stavový podpis použije, pokud je
  věrnost klíče a stavu známa s jistotou, jinak v případě pochyb o validnosti
  stavu použije bezstavové podepisování s vyššími náklady.

  Pro SHRINCS bylo vybráno schéma SPHINCS+ pro bezstavové podepisování a
  Unbalanced XMSS pro stavové. Veřejný klíč ve výstupním skriptu je hašem stavových
  a bezstavových klíčů. Jelikož tato schémata podpisů založených na hašování
  vrací během ověřování veřejný klíč podpisu, může podepisující jednotka
  poskytnout nepoužitý veřejný klíč spolu s podpisem. Během ověřování
  se potom zkontroluje, zda haš vráceného veřejného klíče a poskytnutého veřejného
  klíče souhlasí s klíčem ve skriptu. Schéma Unbalanced XMSS bylo vybráno pro
  případy, kdy se po klíči požaduje relativně málo podpisů.

- **Adresování zbývajících bodů v BIP54:** Antoine Poinsot [popsal][ml ap
  gcc] zbývající body k diskuzi ohledně [soft forku pročištění konsenzu][topic
  consensus cleanup].

  Prvním bodem k diskuzi je návrh na vynucování, aby byl `nLockTime`
  mincetvorné transakce nastaven na hodnotu o jedna méně než je výška bloku.
  Diskuze se soustředí na otázku, zda tato změna zbytečně neomezuje schopnosti
  těžících čipů využívat toto pole jako extra nonce, pokud by těžící zařízení
  vyčerpala prostor dostupný pro nonce ve verzi, časovém razítku a nonce polích.
  Někteří účastníci diskuze zmínili, že `nLockTime` již má sémantický význam
  vynucovaný konsenzem a není tedy primárně využíván jako pole pro dodatečný
  nonce. Byly učiněny rozličné návrhy pro rozšíření prostoru pro nonce, včetně
  dodatečných bitů verze a vyčleněného `OP_RETURN` výstupu.

  Další diskutovanou změnou je návrh, aby byly transakce o velikosti 64 bajtů
  bez witnessů dle konsenzu nevalidní. Takové transakce jsou ve výchozím nastavení
  omezeny pravidly přeposílání, ale změna konsenzu by ochránila SPV (či podobné)
  lehké klienty před některými útoky. Několik účastníků se ptalo, zda se tato změna
  vyplatí, jelikož existují i jiná opatření a může to přinést překvapivé
  mezery ve validaci určitých druhů transakcí (např. [CPFPs][topic cpfp]
  v některých protokolech).

- **Návrh na používání postkvantového schématu podepisování Falcon:** Giulio Golinelli
  zaslal do emailové skupiny Bitcoin-Dev [příspěvek][ml gg falcon] s návrhem forku,
  který by do bitcoinu přidal možnost ověřování Falcon podpisů. Algoritmus
  Falcon je založen na mřížkové kryptografii a usiluje o FIPS standardizaci
  jako postkvantový algoritmus podepisování. Vyžaduje zhruba 20× více prostoru
  než ECDSA podpisy, avšak je dvakrát rychlejší během ověřování. Algoritmus
  je tak jedním z nejúspornějších postkvantových schémat podepisování, které
  zatím byly pro bitcoin navrženy.

  Conduition vyjmenoval některá omezení algoritmu Falcon, obzvlášť kolem náročnosti
  implementace podepisování v konstantním čase. Ostatní diskutovali, zda
  by postkvantový algoritmus podepisování v bitcoinu měl být navržen tak, aby
  dobře fungoval se STARK/SNARK.

  Poznámka: Ačkoliv je návrh v emailové skupině popisován jako soft fork,
  zdá se, že je implementovaný jako nová větev v ověřovací cestě P2WPKH, která
  by byla aktivována v určité výšce. To by tento návrh činilo hard forkem.
  Další práce by tak byla zapotřebí k vyvinutí softforkového klienta pro
  tento algoritmus.

- **Ověřování SLH-DSA je porovnatelné s ECC:** Conduition [popsal][ml cond
  slh-dsa] svou probíhající práci na porovnání výkonnosti své implementace
  postkvantového ověřování SLH-DSA s libsecp256k1. Jeho výsledky ukazují,
  že SLH-DSA lze v běžných případech porovnávat se [Schnorrovou][topic schnorr
  signatures] verifikací.

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [LDK 0.1.9][] a [0.2.1][ldk 0.2.1] jsou údržbovými vydáními této populární
  knihovny pro budování aplikací s podporou LN. Obě opravují chybu,
  která vyvolala selhání `ElectrumSyncClient` v případě existence
  nepotvrzených transakcí. Verze 0.2.1 dále opravuje chybu, kdy zpráva
  `splice_channel` neselhala okamžitě, pokud peer spojení [splicing][topic
  splicing] nepodporuje. Dále mění strukturu `AttributionData` na veřejně
  viditelnou a opravuje další chyby.

## Významné změny kódu a dokumentace

_Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo] a [repozitáři BINANA][binana repo]._

- [Bitcoin Core #33604][] opravuje chování [assumeUTXO][topic assumeutxo]
  uzlů. Během validování na pozadí uzly nestahují bloky od peer spojení,
  která nemají ve svém nejlepším řetězci snapshot bloku, protože uzel
  nemá data nezbytná pro řešení potenciálních reorganizací. Avšak
  toto omezení přetrvává i poté, co validování na pozadí skončí, i když
  uzel už reorganizace řešit umí. Nově uzly aplikují toto omezení
  pouze během validování na pozadí.

- [Bitcoin Core #34358][] opravuje chybu v peněžence, která se projevovala
  během odstraňování transakcí při RPC volání `removeprunedfunds`.
  Dříve odstranění transakce označilo všechny její vstupy jako opět
  utratitelné, i když peněženka obsahovala konfliktní transakci,
  která též utrácela shodná UTXO.

- [Core Lightning #8824][] přidává do pluginu hledání cest `askrene` (viz
  [zpravodaj č. 316][news316 askrene]) vrstvu `auto.include_fees`,
  která odvozuje routovací poplatky z částky platby, čímž v podstatě
  poplatky platí příjemce.

- [Eclair #3244][] přidává dvě události: `PaymentNotRelayed`, která je
  rozeslána, když platba nemůže být přeposlána dalšímu uzlu pravděpodobně kvůli
  nedostatečné likviditě, a `OutgoingHtlcNotAdded`, která je rozeslána, když
  [HTLC][topic htlc] nemůže být přidáno ke konkrétnímu kanálu. Tyto události
  mohou pomoci provozovatelům uzlů sestavit heuristiku pro alokaci likvidity,
  ačkoliv PR poznamenává, že jediná událost by alokaci spustit neměla.

- [LDK #4263][] přidává do API `pay_for_bolt11_invoice` volitelný parametr
  `custom_tlvs`, který volajícím umožní přidat do onion části libovolná
  metadata. Ačkoliv funkce na nižší úrovni `send_payment` již umožňovala
  začlenit libovolná Type-Length-Value ([TLV][TLVs]) data do [BOLT11][]
  plateb, neexistoval k této možnosti řádný přístup z vyšších vrstev.

- [LDK #4300][] přidává podporu pro obecné zachytávání [HTLC][topic htlc].
  Tato funkce staví na mechanismu zadržování HTLC přidaném pro [asynchronní
  platby][topic async payments] a rozšiřuje jeho schopnosti. Dříve bylo
  možné zachytit jen HTLC určená pro falešná SCID (viz [zpravodaj
  č. 230][news230 intercept]). Nová implementace používá bitové pole,
  pomocí kterého lze konfigurovat třídy HTLC, které budou zachycené:
  SCID (jako dříve), offline privátní kanály (užitečné pro LSP pro
  probouzení spících klientů), online privátní kanály, veřejné kanály
  a neznámá SCID. Jedná se o základy podpory LSPS5 ([zpravodaj
  č. 365][news365 lsps5], _angl._, popisuje implementaci klienta)
  a dalších LSP funkcí.

- [LND #10473][] činí RPC volání `SendOnion` (viz též [zpravodaj
  č. 386][news386 sendonion]) plně idempotentní. Klient tak může
  v případě selhání sítě požadavek bezpečně opakovaně odeslat,
  aniž by riskoval zdvojené platby. RPC vrátí chybu `DUPLICATE_HTLC`,
  pokud byl požadavek se stejným `attempt_id` již zpracován.

- [Rust Bitcoin #5493][] přidává možnost na kompatibilních ARM architekturách
  používat SHA256 operace optimalizované pro hardware. Výkonnostní testy
  ukazují, že hašování je u velkých bloků přibližně pětkrát rychlejší.
  Přidání podpory pro hardwarovou akceleraci SHA256 na architekturách
  x86 bylo popsáno ve [zpravodaji č. 265][news265 x86sha].

{% include snippets/recap-ad.md when="2026-02-10 17:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="33604,34358,8824,3244,4263,4300,10473,5493" %}

[news386 jn hash]: /cs/newsletters/2026/01/02/#bitcoinove-podpisy-zalozene-na-hasovani-v-postkvantove-budoucnosti
[delving jn shrings]: https://delvingbitcoin.org/t/shrincs-324-byte-stateful-post-quantum-signatures-with-static-backups/2158
[ml ap gcc]: https://groups.google.com/g/bitcoindev/c/6TTlDwP2OQg
[delving hc bithoven]: https://delvingbitcoin.org/t/bithoven-a-formally-verified-imperative-smart-contract-language-for-bitcoin/2189
[arxiv hc bithoven]: https://arxiv.org/abs/2601.01436
[ml gg falcon]: https://groups.google.com/g/bitcoindev/c/PsClmK4Em1E
[ml cond slh-dsa]: https://groups.google.com/g/bitcoindev/c/8UFkEvfyLwE
[hornet del]: https://delvingbitcoin.org/t/hornet-utxo-1-a-custom-constant-time-highly-parallel-utxo-database/2201
[hornet website]: https://hornetnode.org/overview.html
[lsmt wiki]: https://en.wikipedia.org/wiki/Log-structured_merge-tree
[hash map wiki]: https://cs.wikipedia.org/wiki/Ha%C5%A1ovac%C3%AD_tabulka
[libbitcoin gh]: https://github.com/libbitcoin
[dust attacks del]: https://delvingbitcoin.org/t/disposing-of-dust-attack-utxos/2215
[ddust tool]: https://github.com/bubb1es71/ddust
[LDK 0.1.9]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.1.9
[ldk 0.2.1]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.2.1
[news316 askrene]: /cs/newsletters/2024/08/16/#core-lightning-7517
[TLVs]: https://github.com/lightning/bolts/blob/master/01-messaging.md#type-length-value-format
[news230 intercept]: /cs/newsletters/2022/12/14/#ldk-1835
[news365 lsps5]: /en/newsletters/2025/08/01/#ldk-3662
[news386 sendonion]: /cs/newsletters/2026/01/02/#lnd-9489
[news265 x86sha]: /cs/newsletters/2023/08/23/#rust-bitcoin-1962
