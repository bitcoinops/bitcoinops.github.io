---
title: 'Zpravodaj „Bitcoin Optech” č. 401'
permalink: /cs/newsletters/2026/04/17/
name: 2026-04-17-newsletter-cs
slug: 2026-04-17-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Zpravodaj tento týden popisuje nápad na lightningové uzly používající vnořený
MuSig2 a shrnuje projekt formálně ověřující skalární násobení modulo
v secp256k1. Též nechybí naše pravidelné rubriky s popisem nedávných změn
ve službách a klientském software, s oznámeními nových vydání a se souhrnem
významných změn v populárním bitcoinovém páteřním software.

## Novinky

- **Diskuze o používání vnořeného MuSig2 v Lightning Network**: ZmnSCPxj zaslal do fóra Delving
  Bitcoin [příspěvek][kofn post del] o nápadu na vytvoření lightningových uzlů
  v podobě _k_ z _n_ vícenásobného podpisu s použitím vnořeného Musig2 protokolu
  z nedávno zveřejněného [článku][nmusig2 paper]. Začal vysvětlením důležitosti
  této vlastnosti, poté vyjmenoval současná technická omezení lightningového
  protokolu a nakonec poskytl návrh na úpravy BOLT specifikací.

  ZmnSCPxj tvrdí, že potřeba pro _k_ z _n_ podpisové schéma v lightningu vychází
  z žádosti mnoha držitelů poskytovat síti svou likviditu výměnou za poplatky.
  Tito velcí držitelé mohou vyžadovat silné záruky zabezpečení prostředků,
  které jediný klíč nemůže poskytnout. Schéma s _k_ z _n_ podpisy by takové
  zabezpečení garantovat mohlo, dokud by bylo kompromitováno méně než k klíčů.

  BOLT specifikace by v dnešní podobě neumožnily poskytnout bezpečný způsob
  přidání _k_ z _n_ multisig schématu. Hlavní překážkou je revokační klíč. Dle BOLT
  je revokační klíč vytvořen pomocí tzv. shachainu, který je ze své povahy
  nevhodný pro použití s _k_ z _n_ multisigem.

  ZmnSCPxj proto navrhuje upravit BOLT specifikace tak, aby validace revokačních
  klíčů účastníků kanálu pomocí shachainu byla volitelná. K tomu by měl sloužit
  nový pár feature bitů nazvaný `no_more_shachains` a přítomný v `globalfeatures`
  i `localfeatures`. Lichý bit by signalizoval, že uzel nebude provádět shachain
  validaci klíčů protistrany, avšak validní revokační klíče by pro zachování
  kompatibility nadále poskytoval. Sudý bit by signalizoval, že uzel nebude ani
  validovat, ani poskytovat validní revokační klíče. Lichý bit by byl používán
  hraničními uzly (ZmnSCPxj je definuje jako gateway nodes), které by propojovaly
  uzly schopné _k_ z _n_ podpisů (sudý bit) a zbytek sítě.

  Nakonec ZmnSCPxj zdůrazňuje, jak by tento návrh představoval vážný kompromis,
  totiž v požadavcích na ukládání revokačních klíčů. Uzly by musely ukládat jednotlivé
  revokační klíče namísto kompaktní shachain reprezentace. V důsledku
  by tak tyto klíče vyžadovaly na disku třikrát více místa.

- **Formální ověření skalárního násobení modulo v secp256k1**:
  Remix7531 zaslal do emailové skupiny Bitcoin-Dev [příspěvek][topic secp
  formalization] o vytvoření formální verifikace skalárního násobení modulo
  v secp256k1. Projekt ukazuje, že formální verifikace části
  bitcoin-core/secp256k1 je praktická.

  V rámci [secp256k1-scalar-fv-test codebase][secp verification codebase]
  vzal Remix7531 skutečný céčkový kód z knihovny a dokázal jeho správnost
  vzhledem k formální matematické specifikaci. Použil Rocq a Verified
  Software Toolchain (VST). Remix7531 vysvětlil, proč je tato snaha důležitá.
  Paměťově bezpečné jazyky, testování a fuzz testování mohou najít mnoho chyb,
  ale nemohou zaručit jejich absenci. Formalizace v jazyce Rocq může dokázat
  absenci chyb ve správě paměti, správnost implementace specifikace a konečnost
  algoritmu.

  Jako další kroky plánuje převést důkaz skalárního násobení do RefinedC.
  Tím by dosáhl možnosti napřímo porovnat oba nástroje nad stejným kódem.
  Co se týče verifikace, dalším cílem je Pippengerův algoritmus
  násobení více skalárů, který se používá pro dávkové ověřování podpisů.

## Změny ve službách a klientech

*V této měsíční rubrice upozorňujeme na zajímavé aktualizace bitcoinových
peněženek a služeb.*

- **Coldcard 6.5.0 přidává MuSig2 a miniscript:**
  Coldcard [6.5.0][coldcard 6.5.0] přidává podporu pro [MuSig2][topic musig],
  schopnost doložit dostupné prostředky dle [BIP322][] a nové funkce pro [miniscript][topic
  miniscript] a [taproot][topic taproot], např. podporu až pro osm listů v [tapscriptu][topic
  tapscript].

- **Vydán Frigate 1.4.0:**
  Frigate [v1.4.0][frigate blog], experimentální Electrum server pro skenování
  [tichých plateb][topic silent payments] (viz [zpravodaj č. 389][news389
  frigate]), nově používá knihovnu UltrafastSecp256k1 ve spojení s výpočty
  na moderním GPU. Doba skenování několika měsíců bloků se snížila z hodiny
  na půl sekundy.

- **Aktualizace Bitcoin Backbone:**
  Bitcoin Backbone [vydal][backbone ml 1] několik [aktualizací][backbone ml 2]
  přidávajících podporu [kompaktních bloků][topic compact block relay] dle [BIP152][],
  vylepšujících správu transakcí a adres a pokládajících základy víceprocesového
  rozhraní (viz [zpravodaj č. 368][news368 backbone], _angl._). Oznámení dále
  navrhuje rozšířit Bitcoin Kernel API o nezávislé ověřování hlaviček a transakcí.

- **Vydán Utreexod 0.5:**
  Utreexod [v0.5][utreexod blog] přidává úvodní stahování bloků přes [SwiftSync][news349
  swiftsync], který nemusí díky kryptografické agregaci během úvodního stahovaní
  stahovat a ověřovat doklady o začlenění do akumulátoru a který snižuje
  stahování dodatečných dat uzly během úvodního stahování z 1,4 TB na zhruba
  200 GB (s možností další redukce díky kešování).

- **Vydána Floresta 0.9.0:**
  Floresta [v0.9.0][floresta v0.9.0] přináší soulad P2P síťového protokolu
  s [BIP183][news366 utreexo bips] pro výměnu UTXO dokladů a vyměňuje
  `libbitcoinconsensus`  ze Bitcoin Kernel. Dosahuje tím zhruba 15× rychlejší
  validace skriptu.

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [Bitcoin Core 31.0rc4][] je kandidátem na vydání příští hlavní verze této
  převládající implementace plného uzlu. K dispozici je [průvodce testováním][bcc31 testing].

- [Core Lightning 26.04rc3][] je kandidátem na vydání příští hlavní verze této
  populární implementace LN uzlu. Pokračuje v aktualizacích splicingu a opravuje
  chyby předchozích kandidátů.

## Významné změny kódu a dokumentace

_Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo] a [repozitáři BINANA][binana repo]._

- [Bitcoin Core #34401][] přidává do `btck_BlockHeader` v
  `libbitcoinkernel` C API (viz [zpravodaj č. 380][news380 kernel], _angl._,
  a [zpravodaj č. 390][news390 header]) metodu pro serializaci hlavičky bloku
  ve standardním kódování. To umožňuje externím programům používajícím C API
  ukládat, posílat či porovnávat serializované hlavičky bez potřeby dalšího
  serializačního kódu.

- [Bitcoin Core #35032][] přestává ukládat síťové adresy, které se dozvěděl
  z RPC volání `sendrawtransaction` s aktivní volbou `privatebroadcast`
  (viz [zpravodaj č. 388][news388 private]). Volba `privatebroadcast` umožňuje
  uživatelům zveřejnit transakce přes krátkodobé [Tor][topic anonymity networks]
  nebo I2P spojení nebo přes Tor proxy.

- [Core Lightning #9021][] činí [splicing][topic splicing] aktivním ve výchozím
  nastavení. Po zveřejnění specifikace protokolu splicingu (viz
  [zpravodaj č. 398][news398 splicing]) již není splicing považován za experimentální.

- [Core Lightning #9046][] navyšuje předpokládaný `final_cltv_expiry`
  ([CLTV expiry delta][topic cltv expiry delta] posledního skoku) u [keysend
  plateb][topic spontaneous payments] z 22 na 42 bloků pro lepší spolupráci
  s LDK.

- [LDK #4515][] přepíná feature bit kanálů s [commitmenty s nulovými poplatky][topic v3 commitments] (
  viz [zpravodaj č. 371][news371 0fc], _angl._) z experimentálního na produkční.
  Kanály s commitmenty s nulovými poplatky nahrazují dva [anchor výstupy][topic anchor outputs] jedním sdíleným
  [Pay-to-Anchor (P2A)][topic ephemeral anchors] výstupem zastropovaným na hodnotě
  240 sat.

- [LDK #4558][] aplikuje stávající vypršení časového limitu u nekompletních
  [plateb s více cestami][topic multipath payments] (MPP) také na [keysend platby][topic
  spontaneous payments]. Dříve mohl nekompletní keysend MPP zůstat nevyřízen až do
  vypršení CLTV, čímž držel [HTLC][topic htlc] sloty.

- [LND #9985][] přidává kompletní podporu pro produkční [jednoduché taprootové
  kanály][topic simple taproot channels] s produkčními feature bity 80/81 a
  speciálním typem commitmentu `SIMPLE_TAPROOT_FINAL`. Používá optimalizované
  [tapscripty][topic tapscript], které upřednostňují `OP_CHECKSIGVERIFY` před
  `OP_CHECKSIG`+`OP_DROP`, a přidává zpracovávání noncí založené na mapě s txid
  klíčem v reakci na `revoke_and_ack`. Jedná se o základy pro budoucí
  [splicing][topic splicing].

- [BTCPay Server #7250][] přidává podporu pro [LUD-21][]. Přináší volitelný
  neautentizovaný vstupní bod `verify`, který umožňuje externím službám ověřit,
  zda již byla [BOLT11][] faktura vytvořená přes [LNURL-pay][topic lnurl] urovnána.

- [BIPs #2089][] zveřejňuje [BIP376][], který definuje nová [PSBTv2][topic psbt]
  pole na úrovni vstupů pro data potřebná pro podepisování a utrácení
  výstupů [tichých plateb][topic silent payments] a volitelné pole pro [BIP32][topic bip32]
  derivaci kompatibilní s 33bajtovými klíči pro utrácení dle [BIP352][].
  Tato změna doplňuje [BIP375][], který specifikuje, jak vytvářet výstupy tichých
  plateb pomocí PSBT (viz [zpravodaj č. 309][news309 bip375]).

{% include snippets/recap-ad.md when="2026-04-21 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="34401,35032,9021,9046,4515,4558,9985,7250,2089" %}

[coldcard 6.5.0]: https://coldcard.com/docs/upgrade/#edge-version-650xqx-musig2-miniscript-and-taproot-support
[frigate blog]: https://damus.io/nevent1qqsrg3xsjwpt4d9g05rqy4vkzx5ysdffm40qtxntfr47y3annnfwpzgpp4mhxue69uhkummn9ekx7mqpz3mhxue69uhkummnw3ezummcw3ezuer9wcq3samnwvaz7tmjv4kxz7fwwdhx7un59eek7cmfv9kqz9rhwden5te0wfjkccte9ejxzmt4wvhxjmczyzl85553k5ew3wgc7twfs9yffz3n60sd5pmc346pdaemf363fuywvqcyqqqqqqgmgu9ev
[news389 frigate]: /cs/newsletters/2026/01/23/#experimentalni-electrum-server-pro-testovani-tichych-plateb
[news368 backbone]: /en/newsletters/2025/08/22/#bitcoin-core-kernel-based-node-announced
[backbone ml 1]: https://groups.google.com/g/bitcoindev/c/D6nhUXx7Gnw/m/q1Bx4vAeAgAJ
[backbone ml 2]: https://groups.google.com/g/bitcoindev/c/ViIOYc76CjU/m/cFOAYKHJAgAJ
[news349 swiftsync]: /cs/newsletters/2025/04/11/#swiftsync-urychlujici-uvodni-stahovani-bloku
[utreexod blog]: https://delvingbitcoin.org/t/new-utreexo-releases/2371
[floresta v0.9.0]: https://www.getfloresta.org/blog/release-v0.9.0
[news366 utreexo bips]: /en/newsletters/2025/08/08/#draft-bips-proposed-for-utreexo
[kofn post del]: https://delvingbitcoin.org/t/towards-a-k-of-n-lightning-network-node/2395
[nmusig2 paper]: https://eprint.iacr.org/2026/223
[bitcoin core 31.0rc4]: https://bitcoincore.org/bin/bitcoin-core-31.0/test.rc4/
[bcc31 testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/31.0-Release-Candidate-Testing-Guide
[Core Lightning 26.04rc3]: https://github.com/ElementsProject/lightning/releases/tag/v26.04rc3
[news380 kernel]: /en/newsletters/2025/11/14/#bitcoin-core-30595
[news390 header]: /cs/newsletters/2026/01/30/#bitcoin-core-33822
[news388 private]: /cs/newsletters/2026/01/16/#bitcoin-core-29415
[news398 splicing]: /cs/newsletters/2026/03/27/#bolts-1160
[news371 0fc]: /en/newsletters/2025/09/12/#ldk-4053
[news309 bip375]: /cs/newsletters/2025/01/17/#bips-1687
[BIP376]: https://github.com/bitcoin/bips/blob/master/bip-0376.mediawiki
[LUD-21]: https://github.com/lnurl/luds/blob/luds/21.md
[topic secp formalization]: https://groups.google.com/g/bitcoindev/c/l7AdGAKd1Oo
[secp verification codebase]: https://github.com/remix7531/secp256k1-scalar-fv-test
