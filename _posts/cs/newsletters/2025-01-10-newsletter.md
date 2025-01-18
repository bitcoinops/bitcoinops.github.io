---
title: 'Zpravodaj „Bitcoin Optech” č. 336'
permalink: /cs/newsletters/2025/01/10/
name: 2025-01-10-newsletter-cs
slug: 2025-01-10-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Zpravodaj tento týden popisuje potenciální změnu Bitcoin Core postihující
těžaře, shrnuje diskuzi o vytváření relativních časových zámků na úrovni
kontraktů a představuje návrh na variantu LN-Symmetry se systémem trestů.
Též nechybí naše pravidelné rubriky s oznámeními nových vydání a souhrnem
významných změn v populárním bitcoinovém páteřním software.

## Novinky

- **Zkoumání nastavení těžebních poolů před opravením chyby Bitcoin Core:**
  Abubakar Sadiq Ismail zaslal do fóra Delving Bitcoin [příspěvek][ismail
  double] o [chybě][bitcoin core #21950] objevené v roce 2021 Antoinem
  Riardem, která v šabloně bloku zarezervuje pro mincetvornou (coinbasovou)
  transakci 2 000 vB namísto zamýšlených 1 000 vB. Pokud by byla nadbytečná
  rezervace prostoru eliminována, mohlo by být do každé šablony přidáno
  zhruba pět malých transakcí navíc. Avšak to by mohlo způsobit významnou
  ztrátu příjmu těžařům, kteří na větší prostor spoléhají. Ismail analyzoval
  existující bloky, aby určil, kterým těžařům by mohla oprava uškodit.
  Poznamenal, že Ocean.xyz, F2Pool a jeden neznámý těžař očividně nepoužívají
  výchozí nastavení, avšak nezdá se, že by v případě opravy chyby kterýkoliv
  z nich ztratil peníze.

  Pro snížení rizika se navrhuje nová volba, která by těžařům umožnila během
  spuštění nastavit 1 000vB (nebo nižší) rezervaci, pokud by nevyžadovali
  zpětnou kompatibilitu. Volba by ve výchozím stavu rezervovala 2 000 vB.

  Jay Beddict zprávu [přeposlal][beddict double] do emailové skupiny Mining-Dev.

- **Relativní časové zámky na úrovni kontraktů:** Gregory Sanders zaslal do fóra
  Delving Bitcoin [příspěvek][sanders clrt] o nalezení řešení problému, který
  před rokem objevil (viz [zpravodaj č. 284][news284 deltas]), když pracoval
  na implementaci ověření konceptu [LN-Symmetry][topic eltoo]. V tomto
  protokolu může být každý stav kanálu potvrzen onchain, avšak pouze poslední
  stav potvrzený před vypršením lhůty může distribuovat prostředky kanálu.
  Obvykle se strany pokusí potvrdit pouze poslední stav. Avšak pokud Alice
  zahájí novou aktualizaci stavu tím, že částečně podepíše transakci a pošle
  ji Bobovi, pouze Bob může tuto transakci zkompletovat. Pokud Bob v tento
  okamžik přestane konat, je Alice schopna uzavřít kanál pouze v jeho
  předposledním stavu. Pokud by Bob čekal téměř do naplnění lhůty Alicina
  předposledního stavu a až tehdy potvrdil poslední stav, trvalo by zhruba
  dvakrát déle dosáhnout urovnání kanálu. Tento problém se nazývá
  _dvojnásobné čekání_ (2× delay problem). Znamená to, že v LN-Symmetry musí být
  [časové zámky][topic timelocks] v [HTLC][topic htlc] až dvakrát delší.
  Kvůli tomu by mohli útočníci snáze bránit přeposílajícím uzlům ve vydělávání
  peněz ([zahlcováním kanálu][topic channel jamming attacks] či jinými útoky).

  Sanders navrhuje tento problém vyřešit použitím relativního časového zámku
  na všechny transakce, které jsou potřebné pro vyrovnání kontraktu. Pokud
  by LN-Symmetry takovou možnost nabízel a Alice potvrdila předposlední stav,
  Bob by musel potvrdit poslední stav před vypršením lhůty předposledního
  stavu. V [pozdějším příspěvku][sanders tpp] odkázal Sanders na protokol
  od Johna Lawa (viz [zpravodaj č. 244][news244 tpp]), který nevyžaduje
  změnu konsenzu a který pro poskytnutí časových zámků na úrovni protokolu
  používá dva relativní časové zámky na úrovni transakcí. To by však
  na LN-Symmetry nebylo možné aplikovat, neboť každý stav může utratit
  z kteréhokoliv předchozího stavu.

  Sanders navrhuje jedno řešení, ale poznamenává, že má své nevýhody.
  Dále ukazuje, jak by tento problém mohl být vyřešen použitím
  `coinid` z Chia, což je podobné nápadu, který v roce 2021 představil
  John Law jako dědičné identifikátory (Inherited Identifiers, IID).
  Jeremy Rubin v [odpovědi][rubin muon] odkázal na svůj loňský návrh
  na _muon_ výstupy, které musí být utracené ve stejném bloku jako
  transakce, která je vytvořila. Rubin ukázal, jak by tento koncept
  mohl pomoci. Anthony Towns dále [ukázal][towns coinid], jak by `coinid`
  z blockchainu Chia mohlo dosáhnout konstantních datových požadavků.
  Salvator Ingala [popsal][ingala cat] podobný mechanismus s použitím
  [OP_CAT][topic op_cat], o kterém se dozvěděl od vývojáře Rijndaela.
  Ten později [poskytl podrobnosti][rijndael cat]. Brandon Black
  [popsal][black penalty] alternativní druh řešení – variantu LN-Symmetry
  se systémem trestů – a citoval práci Daniela Robertse (viz následující
  novinka).

- **Druh LN-Symmetry s více stranami a systémem trestů omezující zveřejňování aktualizací:**
  Daniel Roberts zaslal do fóra Delving Bitcoin [příspěvek][roberts sympen]
  popisující způsob, jak v LN zabránit škodící protistraně (Mallory) v možnosti
  pozdržet vyrovnání kanálu záměrným zveřejněním starého stavu s vyšším
  jednotkovým poplatkem, než kolik poctivá strana (Bob) platí za potvrzení
  konečného stavu. Teoreticky může Bob navázat svůj konečný stav na Malloryho
  starý stav a nechat obě transakce potvrdit ve stejném bloku, čímž by
  Mallory ztratil peníze za poplatky a Bob by potvrdil konečný stav
  za stejný poplatek, který byl již ochoten zaplatit. Avšak pokud by
  Mallory dokázal zařídit, aby se Bob o jeho zveřejněných starých stavech
  před potvrzením nedozvěděl, mohl by mu tím zabránit před vypršením
  [HTLC][topic htlc] reagovat a tím Boba okrást.

  Roberts navrhl schéma, které umožňuje účastníkovi kanálu potvrdit
  pouze jediný stav. Pokud by byl potvrzen pozdější stav, účastník,
  který odeslal finální stav, a každý účastník, který žádný stav neodeslal,
  by mohli vzít peníze od účastníků, kteří odeslali starý stav.

  Bohužel po zveřejnění schématu v něm Roberts našel – a zveřejnil – kritickou
  slabinu: podobně jako u problému _dvojnásobného čekání_ popsaného
  v předchozí novince může poslední podepisující strana zkompletovat
  stav, který žádná jiná strana zkompletovat nemůže, což tomuto
  poslednímu podepisujícímu dává výhradní přístup k aktuálnímu konečnému
  stavu. Pokud by se jiná strana pokusila zavřít kanál ve starém stavu,
  ztratila by peníze, pokud by poslední podepisující použil finální
  stav.

  Roberts hledá alternativní přístup, avšak mezitím se rozpoutala zajímavá
  diskuze o tom, zda by bylo užitečné do LN-Symmetry přidat systém
  trestů. Gregory Sanders, kterého jeho vlastní implementace ověření
  konceptu LN-Symmetry přesvědčila, že mechanismus trestů není nezbytný
  ([zpravodaj č. 284][news284 sympen]), poznamenal, že tento druh útoku
  je podobný [útoku cyklickým nahrazováním][topic replacement cycling]
  (replacement cycling). Soudí, že „je tento útok pěkně slabý, protože
  může být útočník snadno doveden do ztráty,” i když má napadený jen
  skromné zdroje a nevidí, které transakce těžaři zamýšlejí potvrdit.

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [Bitcoin Core 28.1][] je údržbovým vydáním této převládající implementace
  plného uzlu.

- [BDK 0.30.1][] je údržbovým, opravným vydáním v předchozí sérii vydání.
  Jak bylo oznámeno v minulém čísle zpravodaje, uživatelům se doporučuje
  upgradovat na BDK wallet 1.0.0. K dispozici je [průvodce migrace][bdk
  migration].

- [LDK v0.1.0-beta1][] je kandidátem na vydání této knihovny pro budování
  aplikací a peněženek s podporou LN.

## Významné změny kódu a dokumentace

_Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Bitcoin Inquisition][bitcoin inquisition repo] a [repozitáři BINANA][binana
repo]._

- [Bitcoin Core #28121][] přidává do odpovědi RPC volání `testmempoolaccept`
  pole `reject-details`, pokud by testovaná transakce nebyla do mempoolu přijata
  kvůli porušení pravidel mempoolu či konsenzu. Chybová hláška je stejná jako
  u `sendrawtransaction` v případě odmítnutí.

- [BDK #1592][] přináší záznamy architektonických rozhodnutí (Architectural
  Decision Records, ADR) sloužící k dokumentaci významných změn. Záznamy obsahují
  popis řešeného problému, kritéria, alternativy, výhody a nevýhody a finální
  řešení. Díky tomu se mohou noví přispěvatelé a uživatelé seznámit s historií
  repozitáře. PR přidává šablonu ADR a první dva záznamy: jeden o odstranění
  modulu `persist` z `bdk_chain` a druhý o novém typu `PersistedWallet`.

{% include snippets/recap-ad.md when="2025-01-14 15:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="28121,1592,21950" %}
[bitcoin core 28.1]: https://bitcoincore.org/bin/bitcoin-core-28.1/
[ldk v0.1.0-beta1]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.1.0-beta1
[bdk migration]: https://bitcoindevkit.github.io/book-of-bdk/getting-started/migrating/
[ismail double]: https://delvingbitcoin.org/t/analyzing-mining-pool-behavior-to-address-bitcoin-cores-double-coinbase-reservation-issue/1351
[beddict double]: https://groups.google.com/g/bitcoinminingdev/c/aM9SDXSMZDs
[sanders clrt]: https://delvingbitcoin.org/t/contract-level-relative-timelocks-or-lets-talk-about-ancestry-proofs-and-singletons/1353/
[news284 deltas]: /cs/newsletters/2024/01/10/#expiry-delta
[sanders tpp]: https://delvingbitcoin.org/t/contract-level-relative-timelocks-or-lets-talk-about-ancestry-proofs-and-singletons/1353/2
[news244 tpp]: /cs/newsletters/2023/03/29/#jak-predejit-uviznuti-kapitalu-pomoci-kanalu-s-vice-stranami-a-tovarnami-kanalu
[rubin muon]: https://delvingbitcoin.org/t/contract-level-relative-timelocks-or-lets-talk-about-ancestry-proofs-and-singletons/1353/3
[towns coinid]: https://delvingbitcoin.org/t/contract-level-relative-timelocks-or-lets-talk-about-ancestry-proofs-and-singletons/1353/7
[ingala cat]: https://delvingbitcoin.org/t/contract-level-relative-timelocks-or-lets-talk-about-ancestry-proofs-and-singletons/1353/8
[rijndael cat]: https://delvingbitcoin.org/t/contract-level-relative-timelocks-or-lets-talk-about-ancestry-proofs-and-singletons/1353/11
[black penalty]: https://delvingbitcoin.org/t/contract-level-relative-timelocks-or-lets-talk-about-ancestry-proofs-and-singletons/1353/12
[roberts sympen]: https://delvingbitcoin.org/t/broken-multi-party-eltoo-with-bounded-settlement/1364/
[news284 sympen]: /cs/newsletters/2024/01/10/#tresty
[bdk 0.30.1]: https://github.com/bitcoindevkit/bdk/releases/tag/v0.30.1
