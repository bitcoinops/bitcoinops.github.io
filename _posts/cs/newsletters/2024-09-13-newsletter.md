---
title: 'Zpravodaj „Bitcoin Optech” č. 320'
permalink: /cs/newsletters/2024/09/13/
name: 2024-09-13-newsletter-cs
slug: 2024-09-13-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Zpravodaj tento týden oznamuje nový testovací nástroj pro Bitcoin Core a
stručně popisuje úvěrové kontrakty založené na DLC. Též nechybí naše
pravidelné rubriky se souhrnem sezení Bitcoin Core PR Review Clubu,
oznámeními nových vydání a popisem významných změn v populárním
bitcoinovém páteřním software.

## Novinky

- **Testování Bitcoin Core modifikováním jeho kódu:** Bruno Garcia zaslal do fóra
  Delving Bitcoin [příspěvek][garcia announce] s oznámením [nástroje][mutation-core],
  který by automaticky modifikoval kód změněný v PR nebo commitu. Cílem
  je zjistit, zda tyto modifikace způsobí selhání některého z testů.
  Pokud náhodná změna kódu nevyvolá selhání testu, může to znamenat
  nedostatečné pokrytí kódu automatickými testy. Garciův automatický
  nástroj nemění komentáře ani jiné nerelevantní části zdrojového kódu.

- **Úvěrové kontrakty založené na DLC:** Shehzan Maredia zaslal do fóra
  Delving Bitcoin [příspěvek][maredia post] s oznámením [Lava Loans][].
  Jedná se o schéma úvěrových kontraktů, které pro zjišťování cen půjček
  ručených bitcoiny používá [DLC][topic dlc] orákula. Například Alice nabídne
  Bobovi 100 000 dolarů, pokud Bob bude na vkladové adrese držet minimálně
  dvojnásobek v BTC. Orákula, kterým Alice i Bob věří, pravidelně zveřejní
  podpisy zavazující aktuálnímu kurzu mezi BTC a USD. Pokud Bobův
  bitcoinový kolaterál spadne pod dohodnutou částku, Alice si může přisvojit
  jeho BTC v hodnotě 100 000 dolarů dle nejvyšší ceny podepsané orákulem.
  Druhou možností je, že Bob zveřejní onchain doklad (ve formě předobrazu
  haše odhaleného Alicí) o splacení úvěru, čímž mu bude kolaterál vrácen.
  Pro případy, kdy strany nespolupracují nebo nejsou online, jsou k dispozici
  i další možnosti řešení kontraktu. Stejně jako u jiných DLC se cenová
  orákula nedozví nic o kontraktech a dokonce ani o použitích jejich
  podpisů.

## Bitcoin Core PR Review Club

*V této měsíční rubrice shrnujeme nedávné sezení [Bitcoin Core PR Review Club][] a
vyzdvihujeme některé z důležitých otázek a odpovědí. Klikněte na otázku a odpověď se vám odhalí.*

[Testování kandidátů na vydání Bitcoin Core 28.0][review club v28-rc-testing]
bylo sezení review clubu, které se nedívalo na žádnou konkrétní změnu,
avšak zabývalo se skupinovým testováním.

Před každým [hlavním vydáním Bitcoin Core][major Bitcoin Core release] se
považuje za nezbytné podstoupit verzi důkladnému testování. Z tohoto důvodu
sepíše nějaký dobrovolník průvodce testování [kandidáta na vydání][release
candidate], aby jej mohlo co nejvíce lidí nezávisle otestovat, aniž by
sami museli zjišťovat nezbytné kroky k ověření jednotlivých změn a nových
funkcí.

Testování může být náročné, protože pokud tester narazí na nečekané chování,
není často zřejmé, je-li důvodem skutečná chyba nebo nesprávný způsob testování.
Reportování chyb, které skutečnými chybami nejsou, plýtvá časem vývojářů.
Aby byly podobné potíže minimalizované a pro co nejširší testování
drží review club sezení ke konkrétnímu kandidátovi na vydání, v tomto případě
28.0rc1.

[Průvodce testování kandidáta na vydání 28.0][28.0 testing] napsal rkrux,
který také vedl sezení klubu.

Účastníci byli dále vyzváni, aby se čtením [poznámek k vydání 28.0][28.0
release notes] nechali inspirovat k dalším nápadům na testování.

Review club se zabýval úvodem do [testnet4][topic testnet]
([Bitcoin Core #29775][]), [TRUC (v3) transakcemi][topic v3
transaction relay] ([Bitcoin Core #28948][]), [RBF balíčků][topic
rbf] ([Bitcoin Core #28984][]) a konfliktními transakcemi v mempoolu
([Bitcoin Core #27307][]). Mezi další témata uvedená v průvodci, která však
nebyla pokryta v tomto sezení, patří `mempoolfullrbf` ve výchozím nastavení
([Bitcoin Core #30493][]), [`PayToAnchor`][topic ephemeral anchors] platby
([Bitcoin Core #30352][]) a nový formát `dumptxoutset` ([Bitcoin Core #29612][]).

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [LND v0.18.3-beta][] je opravným vydáním této oblíbené implementace
  LN uzlu.

- [BDK 1.0.0-beta.2][] je kandidátem na vydání této knihovny pro budování peněženek
  a jiných bitcoinových aplikací. Původní rustový balíček `bdk` byl přejmenován
  na `bdk_wallet` a moduly nižší úrovně byly extrahovány do samostatných balíčků:
  `bdk_chain`, `bdk_electrum`, `bdk_esplora` a `bdk_bitcoind_rpc`. Balíček
  `bdk_wallet` „je první verzí nabízející stabilní 1.0.0 API.”


- [Bitcoin Core 28.0rc1][] je kandidátem na vydání příští hlavní verze této převládající
  implementace plného uzlu. K dispozici je [průvodce testování][bcc testing].

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

- [Bitcoin Core #30509][] přidává do `bitcoin-node` volbu `-ipcbind`, která umožní
  jiným procesům se pomocí unixového soketu k uzlu připojit a ovládat jej.
  V kombinaci s nadcházejícím PR [Bitcoin Core #30510][] budou moci externí
  [Stratum v2][topic pooled mining] procesy vytvářet, spravovat a odesílat šablony
  bloků. Tato změna je součástí projektu učinit Bitcoin Core [víceprocesovým][multiprocess
  project]. Viz též zpravodaje [č. 99][news99 multi] a [č. 147][news147 multi] (oba _angl._).

- [Bitcoin Core #29605][] přináší změny v objevování dalších uzlů. Nově bude
  upřednostňovat místního správce kontaktů před dotazováním se seedových uzlů.
  Díky tomu se sníží vliv seedových uzlů na výběr spojení i množství sdílených
  informací. Ve výchozím nastavení slouží seedové uzly jako záloha pro případ,
  kdy nejsou dostupné žádné DNS seedy (na mainnetu se stává zřídka). Uživatelé
  testovacích sítí a upravených uzlů mohou ručně přidat seedové uzly, aby
  se zvýšila pravděpodobnost nalezení podobně nakonfigurovaných uzlů. Před touto
  změnou způsobilo přidání seedového uzlu jeho dotazování na nové adresy téměř
  při každém startu uzlu, čímž mohl seedový uzel ovlivnit výběr adres. Díky tomuto
  PR se bude uzel dotazovat seedových uzlů pouze, pokud bude správce kontaktů
  (address manager) prázdný nebo pokud nebude možné se připojit k žádné jeho adrese.
  [Zpravodaj č. 301][news301 seednode] se též věnuje seedovým uzlům.

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="30509,29605,30510,29775,28948,28984,27307,30493,30352,29612" %}
[LND v0.18.3-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.18.3-beta
[BDK 1.0.0-beta.2]: https://github.com/bitcoindevkit/bdk/releases/tag/v1.0.0-beta.2
[bitcoin core 28.0rc1]: https://bitcoincore.org/bin/bitcoin-core-28.0/
[garcia announce]: https://delvingbitcoin.org/t/mutation-core-a-mutation-testing-tool-for-bitcoin-core/1119
[mutation-core]: https://github.com/brunoerg/mutation-core
[maredia post]: https://delvingbitcoin.org/t/lava-loans-trust-minimized-bitcoin-secured-loans/1112
[lava loans]: https://github.com/lava-xyz/loans-paper/blob/960b91af83513f6a17d87904457e7a9e786b21e0/loans_v2.pdf
[bcc testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/28.0-Release-Candidate-Testing-Guide
[news99 multi]: /en/newsletters/2020/05/27/#bitcoin-core-18677
[news147 multi]: /en/newsletters/2021/05/05/#bitcoin-core-19160
[multiprocess project]: https://github.com/ryanofsky/bitcoin/blob/pr/ipc/doc/design/multiprocess.md
[news301 seednode]: /cs/newsletters/2024/05/08/#bitcoin-core-28016
[review club v28-rc-testing]: https://bitcoincore.reviews/v28-rc-testing
[major bitcoin core release]: https://bitcoincore.org/en/lifecycle/#major-releases
[28.0 release notes]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/28.0-Release-Notes-Draft
[release candidate]: https://bitcoincore.org/en/lifecycle/#versioning
[28.0 testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/28.0-Release-Candidate-Testing-Guide
