---
title: 'Zpravodaj „Bitcoin Optech” č. 347'
permalink: /cs/newsletters/2025/03/28/
name: 2025-03-28-newsletter-cs
slug: 2025-03-28-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Zpravodaj tento týden popisuje návrh na rozšíření LN o podporu
poplatků předem a za držení založených na spalitelných výstupech,
shrnuje diskuzi o testnetech 3 a 4 (včetně návrhu na hard fork)
a oznamuje záměr začít přeposílat určité transakce s taprootovými
přílohami. Též nechybí naše pravidelné rubriky se souhrnem vybraných
otázek a odpovědí z Bitcoin Stack Exchange, oznámeními nových vydání
a popisem významných změn v populárních bitcoinových páteřních projektech.

## Novinky

- **Poplatky předem a za držení v LN použitím spalitelných výstupů:** John Law
  zaslal do fóra Delving Bitcoin [příspěvek][law fees] se souhrnem svého
  [článku][law fee paper] o protokolu, který mohou uzly použít pro
  vyžadování dvou nových druhů poplatků za přeposílání plateb.
  Konečný odesílatel by platil _poplatek předem_  (upfront fee) jako odměnu
  přeposílajícím uzlům za dočasné využívání _HTLC slotu_ (tedy jednoho z omezeného
  počtu souběžných alokací dostupných v kanálu pro vynucování [HTLC][topic
  htlc]). Uzel, který pozdrží urovnání HTLC, by platil _poplatek za držení_
  (hold fee), jehož výše by byla úměrná délce držení až do dosažení
  maximální částky v okamžiku expirace HTLC. Jeho příspěvek i článek citují
  několik předchozích diskuzí o těchto poplatcích, včetně těch shrnutých
  ve zpravodajích [č. 86][news86 reverse upfront], [č. 119][news119 trusted
  upfront], [č. 120][news120 upfront], [č. 122][news122 bi-directional],
  [č. 136][news136 more fee] (vše _angl._) a [č. 263][news263 dos philosophy].

  Navržený protokol staví na myšlenkách Lawova protokolu _offchain vyrovnávání
  plateb_ (offchain payment resolution, OPR, viz [zpravodaj č. 329][news329 opr]),
  dle kterého každý ze spoluvlastníků kanálu alokuje 100 % dotyčných prostředků
  (tedy 200 % dohromady) na _spalitelný výstup_, který může být kterýmkoliv
  z nich jednostranně zničen. Dotyčnými prostředky jsou v tomto případě
  poplatky předem plus maximální poplatky za držení. Pokud jsou později
  obě strany spokojené s postupem protokolu, např. pokud jsou všechny
  poplatky řádně zaplacené, odstraní spalitelný výstup z budoucích verzí
  svých offchain transakcí. Je-li některá ze stran nespokojená, zavře
  kanál a zničí spalitelné prostředky. I když v tomto případě nespokojená
  strana též tratí, stejně tak je tomu u druhé strany, žádná strana tedy
  na porušení protokolu nevydělá.

  Law popisuje tento protokol jako řešení [útoků zahlcením kanálu][topic
  channel jamming attacks], zranitelnosti poprvé [popsané][russell loop] před
  téměř deseti lety, která útočníkovi umožňuje téměř bez nákladů bránit
  druhé straně ve využívání jeho prostředků. Jedna [odpověď][harding fee]
  poznamenala, že díky přidání poplatků za držení jsou [pozdržené faktury][topic
  hold invoices] pro síť udržitelnější.

- **Diskuze o testnetech 3 a 4:** Sjors Provoost zaslal do emailové skupiny
  Bitcoin-Dev [příspěvek][provoost testnet3] s dotazem, zda šest měsíců po
  aktivaci testnet4 (viz [zpravodaj č. 315][news315 testnet4]) stále někdo
  používá testnet3. Andres Schildbach ve své [odpovědi][schildbach testnet3] popisuje
  záměr pokračovat nejméně další rok v používání testnet3 v testovací verzi jeho
  populární peněženky. Olaoluwa Osuntokun [poznamenal][osuntokun testnet3],
  že testnet3 je poslední dobou mnohem stabilnější než testnet4, což ilustroval
  na přiloženém screenshotu webové stránky [Fork.Observer][] obsahující strom bloků
  z obou testnetů. Níže přikládáme náš vlastní screenshot ukazující stav
  testnet4 v době psaní:

  ![Fork Monitor ukazující strom bloků v testnet4 dne 25. 3. 2025](/img/posts/2025-03-fork-monitor-testnet3.png)

  Po Osuntokunově příspěvku začal Antoine Poinsot [nové vlákno][poinsot testnet4]
  soustřeďující se na problémy s testnet4. Dle jeho názoru jsou problémy
  s testnet4 důsledkem pravidla resetování složitosti. Toto pravidlo (týkající
  se pouze testnetů) umožňuje, aby byl blok validní i s minimální složitostí,
  pokud je časové razítko v jeho hlavičce 20 minut po předchozím bloku.
  Provoost v popisu problémů zachází ještě [hlouběji][provoost testnet4].
  Poinsot navrhuje, aby hard fork testnet4 toto pravidlo odstranil. Mark Erhardt
  [navrhuje][erhardt testnet4] jako jeho datum 8. ledna 2026.

- **Plán na přeposílání některých taprootových příloh:** Peter Todd v emailové skupině
  Bitcoin-Dev [oznámil][todd annex], že plánuje v Libre Relay, svém uzlu založeném
  na Bitcoin Core, přeposílat transakce obsahující taprootové [přílohy][topic annex]
  (annex), pokud jsou splněna tato dvě pravidla:

  - _Prefix 0x00:_ „Všechny neprázdné přílohy začínají bajtem 0x00, aby byly odlišeny
    od budoucích příloh týkajících se konsenzu.”

  - _Žádné nebo všechny:_ „Všechny vstupy obsahují přílohu. To zajistí, aby byly přílohy
    volitelné, což v protokolech s více stranami zabrání [pinningu transakcí][topic
    transaction pinning].”

  Plán je založen na [pull requestu][bitcoin core #27926] z roku 2023 od Joosta
  Jagera, který je dále založen na předchozí diskuzi započaté Jagerem
  (viz [zpravodaj č. 255][news255 annex]). V Jagerových slovech měl předchozí
  pull request také „omezení maximální velikosti nestrukturovaných dat v příloze
  na 256 bajtů, […] což má účastníky chránit v transakci s více stranami,
  která používá tuto přílohu proti nafukování příloh.” Toddova verze toto
  pravidlo neobsahuje, protože věří, že „požadavek na volitelnost příloh by
  měl být dostatečný.” Pokud by nebyl, učinil by v přeposílání další změny.

  V době psaní zpravodaje ve vlákně nikdo nepopsal, jak by příloh využil.

## Vybrané otázky a odpovědi z Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] je jedním z prvních míst, kde hledají
přispěvatelé Optechu odpovědi na své otázky a kde – najdou-li volnou chvíli –
pomáhají zvědavým či zmateným uživatelům. V této měsíční rubrice nabízíme
některé z otázek a odpovědí, které obdržely vysoký počet hlasů.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Proč je commitment witnessu volitelný?]({{bse}}125948)
  Pieter Wuille a Antoine Poinsot vysvětlují [BIP30][] „duplikované transakce”,
  [BIP34][] „blok v2 a výšku v coinbase” a souvislost [pročištění konsenzu][topic consensus
  cleanup] s [problémem bloku 1 983 702][topic duplicate transactions] a jak by
  povinný commitment witnessu tento problém řešil.

- [Mohou být všechny platné 64bajtové transakce pozměněny třetí stranou ke zvýšení velikosti?]({{bse}}125971)
  Sjors Provoost zkoumá myšlenku poddajnosti libovolné [64bajtové transakce][news27 64tx],
  která by byla konsenzuálně nevalidní, pokud by byl aktivován soft fork
  [pročištění konsenzu][topic consensus cleanup]. Antoine Poinsot dodává, že takovým
  transakcím je možné přidat více vstupů nebo výstupů a zvýšit jejich velikost.

- [Jak dlouho trvá transakci propagace celou sítí?]({{bse}}125776)
  Sr_gi poznamenává, že jediný uzel není schopen čas propagace celou sítí měřit
  a že by pro měření a odhad bylo potřeba mít přístup k více uzlům. Dodává, že
  [webová stránka][dsn kit], kterou provozuje Decentralized Systems and Network Services
  Research Group při KIT, měří mimo jiné čas propagace transakcí: „transakci trvá
  kolem sedmi sekund dosáhnout 50 % sítě a potřebuje kolem 17 sekund na 90 %.”

- [Použitelnost dlouhodobých odhadů poplatků]({{bse}}124227)
  Abubakar Sadiq Ismail hledá pro svou práci na [odhadování poplatků][topic
  fee estimation] zpětnou vazbu od projektů, protokolů nebo uživatelů,
  kteří na dlouhodobé odhady spoléhají.

- [Proč jsou v LN používány dva anchor výstupy?]({{bse}}125883)
  Instagibbs nabízí historický kontext [anchor výstupů][topic anchor outputs]
  používaných v současnosti v LN a dodává, že se změnami [pravidel Bitcoin Core
  v 28.0][28.0 wallet guide] se plánuje update na [v3 commitmenty][topic v3 commitments].

- [Proč nejsou v 2xx rozsahu žádné BIPy?]({{bse}}125914)
  Michael Folkson poznamenává, že BIP čísla 200–299 byla v jednu chvíli
  rezervována pro Lightning Network.

- [Proč není v Bech32 používáno písmeno „b”?]({{bse}}125902)
  Bordalix v odpovědi poznamenává, že kvůli podobnosti s „8” není „B” ve formátech
  [bech32 a bech32m][topic bech32] povoleno. Dále poskytuje další informace o bech32.

- [Referenční implementace detekce a korekce chyb z Bech32]({{bse}}125961)
  Pieter Wuille poznamenává, že bech32 umí v adrese detekovat až čtyři chyby a opravit
  dvě.

- [Jak bezpečně utratit/propálit prach?]({{bse}}125702)
  Murch vyjmenovává, co je třeba uvážit během pokusu o odeslání [prachu][topic
  uneconomical outputs] z existující peněženky.

- [Jak je konstruována refundovací transakce v asymetrických revokovatelných commitmentech?]({{bse}}125905)
  Biel Castellarnau prochází příklady commitment transakcí z knihy Mastering Bitcoin.

- [Které aplikace používají ZMQ s Bitcoin Core?]({{bse}}125920)
  Sjors Provoost hledá uživatele ZMQ služeb poskytovaných Bitcoin Core v rámci
  zjišťování, zda by [IPC][news320 ipc] mohlo jeho používání nahradit.

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [Bitcoin Core 29.0rc2][] je kandidátem na vydání příští hlavní verze převládající
  implementaci plného uzlu. Viz též [průvodce testováním verze 29][bcc29 testing guide].

- [LND 0.19.0-beta.rc1][] je kandidátem na vydání tohoto oblíbeného LN uzlu.
  Jedním významným vylepšením, které by si zasloužilo důkladné testování, je
  nové schéma RBF navyšování poplatků během kooperativního zavření kanálu
  popsané níže ve významných změnách.

## Významné změny kódu a dokumentace

_Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo] a [repozitáři BINANA][binana repo]._

- [Bitcoin Core #31603][] bude odmítat veřejné klíče začínající nebo končící
  mezerou během parsování v `ParsePubkeyInner`. Tím bude mít stejné chování jako
  [rust-miniscript][rust miniscript]. Přidávat nahodile mezery by nemělo být
  díky ochraně kontrolním součtem možné. RPC příkazy `getdescriptorinfo` a
  `importdescriptors` budou nově hlásiti chybu, pokud veřejný klíč v
  [deskriptoru][topic descriptors] bude obsahovat mezeru.

- [Eclair #3044][] navyšuje minimální počet konfirmací pro založení kanálu z šesti
  na osm z důvodu zabezpečení. Dále odstraňuje změny této hodnoty v přímé
  úměře k částce, protože kapacita kanálu se může během [splicingu][topic splicing]
  výrazně měnit a uzel by tak mohl přijmout nízký počet konfirmací i pro
  vysoké částky.

- [Eclair #3026][] přidává podporu pro peněženky Bitcoin Core používající
  [Pay-to-Taproot (P2TR)][topic taproot] adresy včetně peněženek pouze pro sledování
  spravované Eclairem. Jedná se o základ pro implementaci [jednoduchých taprootových
  kanálů][topic simple taproot channels]. Pro některá kooperativní zavření kanálu
  jsou stále vyžadované P2WPKH skripty i s P2TR peněženkami.

- [LDK #3649][] přidává podporu pro placení poskytovatelům lightningových služeb (LSP)
  [BOLT12 nabídkami][topic offers]. Dříve to bylo možné pouze pomocí [BOLT11][] a
  onchain plateb. Viz též návrh v [BLIPs #59][].

- [LDK #3665][] navyšuje maximální přípustnou velikost [BOLT11][] faktury z 1 023 bajtů
  na 7 089 bajtů, což odpovídá limitu v LND. Tato hodnota je založena na maximálním
  množství bajtů, které se mohou vměstnat do QR kódu. Autor PR se domnívá, že QR
  kódy kompatibilní s kódováním v BOLT11 fakturách jsou ve skutečnosti omezené na
  4 296 znaků, ale hodnota 7 089 byla zvolena, protože „široký soulad je asi
  důležitější.”

- [LND #8453][], [#9559][lnd #9559], [#9575][lnd #9575], [#9568][lnd
  #9568] a [LND #9610][] přináší kooperativní zavření s [RBF][topic rbf] dle
  [BOLTs #1205][] (viz [zpravodaj č. 342][news342 closev2]), které umožní
  kterékoliv straně navýšit poplatek použitím svých vlastních prostředků v kanálu.
  Dříve musela někdy jedna ze stran přesvědčit druhou, aby zaplatila za navýšení
  poplatku, což často vyústilo v selhání. Pro použití musí být aktivní konfigurační
  příznak `protocol.rbf-coop-close`.

- [BIPs #1792][] přináší změny do [BIP119][], který specifikuje
  [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify]. Objasňuje text, odstraňuje
  logiku aktivace, mění zmínky o Eltoo na [LN-Symmetry][topic eltoo] a nově zmiňuje
  nové návrhy [kovenantů][topic covenants] a projektů jako [Ark][topic ark], které `OP_CTV`
  používají.

- [BIPs #1782][] zvyšuje čitelnost a zřetelnost specifikace [BIP94][], který vypisuje pravidla
  konsenzu v [testnet4][topic testnet].

{% include snippets/recap-ad.md when="2025-04-01 15:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="31603,3044,3026,3649,3665,9610,1792,1782,27926,59,8453,9559,9575,9568,1205" %}
[bitcoin core 29.0rc2]: https://bitcoincore.org/bin/bitcoin-core-29.0/
[bcc29 testing guide]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/29.0-Release-Candidate-Testing-Guide
[lnd 0.19.0-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.19.0-beta.rc1
[news255 annex]: /cs/newsletters/2023/06/14/#diskuze-o-taprootovych-prilohach
[news315 testnet4]: /cs/newsletters/2024/08/09/#bitcoin-core-29775
[fork.observer]: https://fork.observer/
[law fees]: https://delvingbitcoin.org/t/fee-based-spam-prevention-for-lightning/1524/
[law fee paper]: https://github.com/JohnLaw2/ln-spam-prevention
[news329 opr]: /cs/newsletters/2024/11/15/#protokol-pro-offchain-vyrovnavani-plateb-zalozeny-na-mad
[harding fee]: https://delvingbitcoin.org/t/fee-based-spam-prevention-for-lightning/1524/4
[provoost testnet3]: https://mailing-list.bitcoindevs.xyz/bitcoindev/9FAA7EEC-BD22-491E-B21B-732AEA15F556@sprovoost.nl/
[schildbach testnet3]: https://mailing-list.bitcoindevs.xyz/bitcoindev/7c28f8e9-d221-4633-8b71-53b4db07fa78@schildbach.de/
[osuntokun testnet3]: https://groups.google.com/g/bitcoindev/c/jYBlh24OB-Y/m/vbensqcZAwAJ
[poinsot testnet4]: https://mailing-list.bitcoindevs.xyz/bitcoindev/hU75DurC5XToqizyA-vOKmVtmzd3uZGDKOyXuE_ogE6eQ8tPCrvX__S08fG_nrW5CjH6IUx7EPrq8KwM5KFy9ltbFBJZQCHR2ThoimRbMqU=@protonmail.com/
[provoost testnet4]: https://mailing-list.bitcoindevs.xyz/bitcoindev/2064B7F4-B23A-44B0-A361-0EC4187D8E71@sprovoost.nl/
[erhardt testnet4]: https://mailing-list.bitcoindevs.xyz/bitcoindev/7c6800f0-7b77-4aca-a4f9-2506a2410b29@murch.one/
[todd annex]: https://mailing-list.bitcoindevs.xyz/bitcoindev/Z9tg-NbTNnYciSOh@petertodd.org/
[russell loop]: https://diyhpl.us/~bryan/irc/bitcoin/bitcoin-dev/linuxfoundation-pipermail/lightning-dev/2015-August/000135.txt
[news263 dos philosophy]: /cs/newsletters/2023/08/09/#navrh-na-ochranu-pred-odeprenim-sluzby-dos
[news136 more fee]: /en/newsletters/2021/02/17/#renewed-discussion-about-bidirectional-upfront-ln-fees
[news122 bi-directional]: /en/newsletters/2020/11/04/#bi-directional-upfront-fees-for-ln
[news86 reverse upfront]: /en/newsletters/2020/02/26/#reverse-up-front-payments
[news119 trusted upfront]: /en/newsletters/2020/10/14/#trusted-upfront-payment
[news120 upfront]: /en/newsletters/2020/10/21/#more-ln-upfront-fees-discussion
[rust miniscript]: https://github.com/rust-bitcoin/rust-miniscript
[news342 closev2]: /cs/newsletters/2025/02/21/#bolts-1205
[rust miniscript]: https://github.com/rust-bitcoin/rust-miniscript
[dsn kit]: https://www.dsn.kastel.kit.edu/bitcoin/#propdelaytx
[28.0 wallet guide]: /cs/bitcoin-core-28-wallet-integration-guide/
[news320 ipc]: /cs/newsletters/2024/09/13/#bitcoin-core-30509
[news27 64tx]: /en/newsletters/2018/12/28/#cve-2017-12842
