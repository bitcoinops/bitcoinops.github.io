---
title: 'Zpravodaj „Bitcoin Optech” č. 319'
permalink: /cs/newsletters/2024/09/06/
name: 2024-09-06-newsletter-cs
slug: 2024-09-06-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Zpravodaj tento týden shrnuje návrh na rozšíření protokolu Stratum v2 pro
odměňování těžařů na základě transakčních poplatků obsažených v použitých
šablonách bloků, oznamuje fond na výzkum navrhovaného opkódu `OP_CAT`
a popisuje diskuzi o zabraňování zranitelnostem Merkleova stromu s případným
soft forkem. Též nechybí naše pravidelné rubriky s oznámeními nových vydání
a popisem významných změn v populárních bitcoinových páteřních projektech.

## Novinky

- **Rozšíření pro Stratum v2 pro sdílení výdělků:** Filippo Merli
  zaslal do fóra Delving Bitcoin [příspěvek][merli stratumfees]
  o rozšíření protokolu [Stratum v2][topic pooled mining], které umožní
  sledovat množství poplatků začleněných v _share_ v případech, kdy
  share obsahují transakce vybrané jednotlivými těžaři. Může to být
  použito k úpravě výplaty těžařům, kdy by těžaři vybírající transakce
  s vyššími poplatky mohli být placeni více.

  Merli odkazuje na [článek][merli paper], jehož je spoluautorem,
  který zkoumá obtíže vyplácení různých odměn různým těžařům podle
  vybraných transakcí. Článek navrhuje schéma, které je kompatibilní
  se schématem PPLNS (_pay per last N shares_, platba podle posledních
  N share). Jeho příspěvek dále odkazuje na dvě vyvíjené implementace.

- **Fond na výzkum OP_CAT:** Victor Kolobov zaslal do emailové skupiny
  Bitcoin-Dev [příspěvek][kolobov cat] s oznámením fondu ve výši
  1 miliónu dolarů určeného pro výzkum navrhovaného soft forku na přidání
  opkódu [`OP_CAT`][topic op_cat]. „Mezi možná témata patří: dopady aktivace
  `OP_CAT` na bezpečnost bitcoinu, logika výpočetních i platebních skriptů
  založených na `OP_CAT`, aplikace a protokoly používající `OP_CAT`
  v bitcoinu a všeobecný výzkum související s `OP_CAT` a jeho dopady.”
  Přihlášky musí být obdrženy do 1. ledna 2025.

- **Zabraňování zranitelnostem Merkleova stromu:** Eric Voskuil poslal do
  vlákna o [návrhu na pročištění konsenzu][topic consensus cleanup]
  (viz [zpravodaj č. 296][news296 cleanup]) ve fóru Delving Bitcoin
  [žádost][voskuil spv] o úpravu návrhu v reakci na nedávnou
  [diskuzi][voskuil spv dev] v emailové skupině Bitcoin-Dev. Konkrétně
  nevidí „důvod k existenci navrhovaného zákazu 64bajtových transakcí,”
  neboť dle něj zákaz 64bajtových transakcí nepřináší v porovnání s jinými
  kontrolami (které nevyžadují změnu konsenzu a které jsou prováděny již
  nyní) plným uzlům v ochraně před [zranitelnostmi Merkleova stromu][topic
  merkle tree vulnerabilities] jako CVE-2012-2459 žádná zlepšení výkonnosti.
  Hlavní obhájce pročištění konsenzu Antoine Poinsot zjevně s tímto aspektem
  [souhlasí][poinsot cache]: „Výhoda, kterou jsem původně zmínil, tedy že
  zakázání 64bajtových transakcí by mohlo pomoci zaznamenat chyby bloků
  v dřívější fázi, není správná.”

  Avšak Poinsot i jiní dříve také navrhli zákaz 64bajtových transakcí
  k ochraně softwaru ověřujícího Merkleovy důkazy proti CVE-2017-12842.
  Tato zranitelnost postihuje lehké peněženky, které používají _zjednodušené
  ověřování plateb_ (simplified payment verification, SPV), jak bylo popsané
  v původním [článku o bitcoinu][Bitcoin paper]. Může také postihovat
  [sidechainy][topic sidechains], které provádí SPV, a některé navrhované druhy
  [kovenantů][topic covenants], které pro aktivaci vyžadují soft fork.

  Od zveřejnění CVE-2017-12842 je známo, že SPV může být bezpečné,
  pokud validace navíc ověřuje hloubku coinbasové transakce v bloku. Voskuil
  odhaduje, že by to v průměru vyžadovalo dodatečných 576 bajtů u běžných
  moderních bloků, což je jen malý nárůst množství přenášených dat. Poinsot
  argumenty [shrnul][poinsot spv] a Anthony Towns [přidal][towns depth]
  informace k části o složitosti provádění dodatečného ověření hloubky.

  Voskuil dále odkázal na dřívější [návrh][lerner commitment] Sergia
  Demiana Lernera, dle kterého by po soft forku měnícím konsenzus
  hlavičky bloků zavazovaly hloubce svého Merkleova stromu. To by též
  chránilo před CVE-2017-12842, nevyžadovalo by zákaz 64bajtových
  transakcí a umožnilo maximální efektivitu SPV dokladů.

  Diskuze v době psaní nadále probíhala.

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [Core Lightning 24.08][] je vydáním nové hlavní verze této oblíbené
  implementace LN uzlu přinášející novinky a opravy chyb.

- [LDK 0.0.124][] je novým vydáním této knihovny pro budování lightningových
  aplikací.

- [LND v0.18.3-beta.rc2][] je kandidátem na vydání opravné verze této populární
  implementace LN uzlu.

- [BDK 1.0.0-beta.2][] je kandidátem na vydání této knihovny pro budování peněženek
  a jiných bitcoinových aplikací. Původní rustový balíček `bdk` byl přejmenován
  na `bdk_wallet` a moduly nižší úrovně byly extrahovány do samostatných balíčků:
  `bdk_chain`, `bdk_electrum`, `bdk_esplora` a `bdk_bitcoind_rpc`. Balíček
  `bdk_wallet` „je první verzí nabízející stabilní 1.0.0 API.”

- [Bitcoin Core 28.0rc1][] je kandidátem na vydání příští hlavní verze této převládající
  implementace plného uzlu. [Průvodce testování][bcc testing] je k dispozici.

## Významné změny kódu a dokumentace

_Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Bitcoin Inquisition][bitcoin inquisition repo] a [repozitáři BINANA][binana
repo]._

_Poznámka: commity do Bitcoin Core zmíněné níže se vztahují na jeho master vývojovou
větev. Tyto změny pravděpodobně nebudou vydány do doby kolem šesti měsíců od vydání
připravované verze 28._

- [Bitcoin Core #30454][] a [#30664][bitcoin core #30664] přidávají
  sestavovací systém založený na CMake (viz [zpravodaj č. 316][news316
  cmake]) a odstraňují předchozí systém založený na autotools. Viz též
  následná PR [#30779][bitcoin core #30779],
  [#30785][bitcoin core #30785], [#30763][bitcoin core #30763],
  [#30777][bitcoin core #30777], [#30752][bitcoin core #30752],
  [#30753][bitcoin core #30753], [#30754][bitcoin core #30754],
  [#30749][bitcoin core #30749], [#30653][bitcoin core #30653],
  [#30739][bitcoin core #30739], [#30740][bitcoin core #30740],
  [#30744][bitcoin core #30744], [#30734][bitcoin core #30734],
  [#30738][bitcoin core #30738], [#30731][bitcoin core #30731],
  [#30508][bitcoin core #30508], [#30729][bitcoin core #30729] a
  [#30712][bitcoin core #30712].

- [Bitcoin Core #22838][] implementuje [deskriptory][topic descriptors]
  s více derivačními cestami ([BIP389][]), které umožňují jednomu
  deskriptoru specifikovat dvě souvislé derivační cesty: první pro
  příjem plateb a druhou pro interní použití (např. pro zbytek).
  Viz též zpravodaje [č. 211][news211 bip389] (_angl._) a [č. 258][news258
  bip389].

- [Eclair #2865][] přidává možnost probudit odpojený mobilní uzel
  mobilní notifikací a připojit se na jeho poslední známou IP adresu.
  To je užitečné obzvláště u [asynchronních plateb][topic async payments],
  kde místní uzel drží platbu nebo [onion zprávu][topic onion messages],
  které doručí po opětovném připojení vzdáleného uzlu. Viz též
  [zpravodaj č. 232][news232 async].

- [LND #9009][] přináší mechanismus omezování spojení za posílání
  nevalidních oznámení o kanálech, např. takových, jejichž financující
  transakce neexistuje, je již utracená nebo má nevalidní výstupy.
  S omezenými spojeními bude nakládat v závislosti na jejich vztahu:

  - spojení bez sdíleného kanálu budou odpojena

  - od spojení se sdíleným kanálem bude na 48 hodin ignorovat oznámení

- [LDK #3268][] přidává `ConfirmationTarget::MaximumFeeEstimate` nabízející
  během kontroly poplatků protistrany konzervativnější [odhad poplatků][topic
  fee estimation] u výpočtů s neekonomickými výstupy ([dust][topic uneconomical
  outputs]). Tím zabrání zbytečným vynuceným zavřením kanálu v době
  s vysokými poplatky. PR dále rozděluje `ConfirmationTarget::OnChainSweep` na
  `UrgentOnChainSweep` a `NonUrgentOnChainSweep` za účelem rozlišení
  mezi časově citlivými (např. expirující [HTLC][topic htlc]) a neurgentními
  vynucenými zavřeními.

- [HWI #742][] přidává podporu pro hardwarové podpisové zařízení Trezor Safe 5.

- [BIPs #1657][] přidává do [PSBT][topic psbt] výstupů nové standardní pole pro
  [DNSSEC][dnssec] doklady použitelné s [BIP353][]. Externí zařízení jako podpisový
  hardware mohou z PSBT výstupů obdržet důkazy formátované dle [RFC 9102][rfc9102],
  které zajistí, že akceptované budou pouze validní důkazy s vynucenými časovými
  limity. Viz též [zpravodaj č. 307][news307 bip353].

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="30454,30664,30779,30785,30763,30777,30752,30753,30754,30749,30653,30739,30740,30744,30734,30738,30731,30508,30729,30712,22838,2865,9009,3268,742,1657" %}
[Core Lightning 24.08]: https://github.com/ElementsProject/lightning/releases/tag/v24.08
[LND v0.18.3-beta.rc2]: https://github.com/lightningnetwork/lnd/releases/tag/v0.18.3-beta.rc2
[BDK 1.0.0-beta.2]: https://github.com/bitcoindevkit/bdk/releases/tag/v1.0.0-beta.2
[bitcoin core 28.0rc1]: https://bitcoincore.org/bin/bitcoin-core-28.0/
[voskuil spv]: https://delvingbitcoin.org/t/great-consensus-cleanup-revival/710/28
[voskuil spv dev]: https://mailing-list.bitcoindevs.xyz/bitcoindev/72e83c31-408f-4c13-bff5-bf0789302e23n@googlegroups.com/
[poinsot cache]: https://mailing-list.bitcoindevs.xyz/bitcoindev/wg_er0zMhAF9ERoYXmxI6aB7rc97Cum6PQj4UOELapsHVBBVWktFeOZT7sHDlyrXwJ5o5s9iMb2LW2Od-qacywsh-86p5Q7dP3XjWASXcMw=@protonmail.com/
[bitcoin paper]: https://cdn.prod.website-files.com/5e5fcd39a7ed2643c8f70a6a/60ae0e84e7b6be8373534c4e_Bitcoin-whitepaper-original-CZ%20(1).pdf
[poinsot spv]: https://delvingbitcoin.org/t/great-consensus-cleanup-revival/710/41
[lerner commitment]: https://bitslog.com/2018/06/09/leaf-node-weakness-in-bitcoin-merkle-tree-design/
[towns depth]: https://delvingbitcoin.org/t/great-consensus-cleanup-revival/710/43
[merli stratumfees]: https://delvingbitcoin.org/t/pplns-with-job-declaration/1099
[merli paper]: https://github.com/demand-open-source/pplns-with-job-declaration/blob/bd7258db08e843a5d3732bec225644eda6923e48/pplns-with-job-declaration.pdf
[kolobov cat]: https://mailing-list.bitcoindevs.xyz/bitcoindev/04b61777-7f9a-4714-b3f2-422f99e54f87n@googlegroups.com/
[news296 cleanup]: /cs/newsletters/2024/04/03/#navrat-k-tematu-procisteni-konsenzu
[news316 cmake]: /cs/newsletters/2024/08/16/#bitcoin-core-prechazi-na-sestavovaci-system-cmake
[bcc testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/28.0-Release-Candidate-Testing-Guide
[ldk 0.0.124]: https://github.com/lightningdevkit/rust-lightning/releases
[news211 bip389]: /en/newsletters/2022/08/03/#multiple-derivation-path-descriptors
[news258 bip389]: /cs/newsletters/2023/07/05/#bips-1354
[news232 async]: /cs/newsletters/2023/01/04/#eclair-2464
[dnssec]: https://cs.wikipedia.org/wiki/Domain_Name_System_Security_Extensions
[rfc9102]: https://datatracker.ietf.org/doc/html/rfc9102
[news307 bip353]: /cs/newsletters/2024/06/14/#bips-1551
