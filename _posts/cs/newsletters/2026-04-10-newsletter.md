---
title: 'Zpravodaj „Bitcoin Optech” č. 400'
permalink: /cs/newsletters/2026/04/10/
name: 2026-04-10-newsletter-cs
slug: 2026-04-10-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Zpravodaj tento týden přináší pravidelné rubriky se souhrnem sezení Bitcoin Core
PR Review Clubu a s popisem významných změn v populárních bitcoinových páteřních
projektech.

## Novinky

*V našich [zdrojích][sources] jsme tento týden nenašli žádné významné novinky.*

## Bitcoin Core PR Review Club

*V této měsíční rubrice shrnujeme nedávné sezení [Bitcoin Core PR Review Club][] a
vyzdvihujeme některé z důležitých otázek a odpovědí. Klikněte na otázku a odpověď se vám odhalí.*

[Testování kandidátů na vydání Bitcoin Core 31.0][review club
v31-rc-testing] bylo sezení review clubu, během kterého se účastníci nezabývali
konkrétním PR, ale prováděli skupinové testování.

Důsledné testování členy komunity před každým [hlavním vydáním Bitcoin Core][major Bitcoin Core release]
je nezbytné. Z tohoto důvodu sepíše dobrovolník průvodce testování kandidáta na
vydání, aby mohlo co nejvíce lidí efektivně testovat, aniž by museli sami zjišťovat,
co je nového, co se změnilo a jaké kroky je potřeba podniknout k jejich otestování.

Testování může být náročné, protože nemusí být v případě neočekávaného chování
jasné, zda se jedná o chybu programu či omyl v testování. Reportování chyb,
které nejsou skutečnými chybami, plýtvá časem vývojářů. Sezení review klubu
se zabývá konkrétním kandidátem na vydání, aby se předešlo podobným problémům.

[Průvodce testováním kandidáta na vydání 31.0][31.0 testing] sepsal [svanstaa][gh svanstaa]
(viz [Podcast #397][pod397 v31rc1]), který též sezení review clubu předsedal.

Účastníci byli vyzýváni, aby si pro hledání inspirace k testování přečetli [poznámky
k vydání 31.0][31.0 release notes].

Průvodce testování pokrývá [mempool clusterů][topic cluster mempool] včetně nových
RPC a omezení (viz [zpravodaj č. 382][news382 bc33629], _angl._), zveřejňování
transakcí se zachováním soukromí (viz [zpravodaj č. 388][news388 bc29415]), RPC `getblock` s novým polem
`coinbase_tx` (viz [zpravodaj č. 394][news394 bc34512]), nový `txospenderindex` sledující,
které transakce každý výstup utrácí (viz [zpravodaj č. 394][news394 bc24539]),
zvýšené výchozí velikosti `-dbcache` (viz [zpravodaj č. 396][news396 bc34692]), vestavěných
dat pro ASMap (viz [zpravodaj č. 394][news394 bc28792]) a nového REST API `blockpart`
(viz [zpravodaj č. 386][news386 bc33657]).

## Významné změny kódu a dokumentace

_Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo] a [repozitáři BINANA][binana repo]._

- [Bitcoin Core #33908][] přidává do C API `libbitcoinkernel` (viz [zpravodaj
  č. 380][news380 kernel], _angl._) rozhraní `btck_check_block_context_free`
  pro validaci kandidátů na bloky s bezkontextovými kontrolami: velikost/váha
  limitů bloku, pravidla mincetvorné transakce a kontroly transakcí, které
  nezávisí na stavu, indexu bloků nebo množině UTXO. Volající mohou též volitelně
  ověřovat proof of work a Merkleův kořen.

- [Eclair #3283][] přidává do plných odpovědí na volání hledání cest `findroute`,
  `findroutetonode` a `findroutebetweennodes` pole `fee` (v msat). Toto pole
  poskytuje celkový [poplatek za přeposílání][topic inbound forwarding fees]
  v celé trase. Není tak již nutné tuto hodnotu počítat ručně.

- [LDK #4529][] umožňuje operátorům nastavit pro oznámené a [neoznámené][topic
  unannounced channels] kanály různé limity jako procento kapacity kanálu
  během konfigurace celkové hodnoty příchozích [HTLC][topic htlc]. Výchozí
  hodnota pro oznámené kanály je 25 %, pro neoznámené 100 %.

- [LDK #4494][] mění vnitřní logiku [RBF][topic rbf], aby byla v souladu s pravidly
  nahrazování během nízkých poplatků, jak stanoví [BIP125][]. Namísto pouhé
  aplikace koeficientu poplatku 25/24 dle [BOLT2][] použije LDK nově buď tento
  koeficient, nebo dodatečných 25 sat/kwu, podle toho, která hodnota je vyšší.
  Objasnění související specifikace se diskutuje v [BOLTs #1327][].

- [LND #10666][] přidává RPC volání `DeleteForwardingHistory` a příkaz `lncli
  deletefwdhistory`, které provozovatelům umožňují selektivně smazat události
  o přeposílání starší než daný práh. Pro ochranu před nezáměrným smazáním
  čerstvých dat musí být tato hodnota vyšší než jedna hodina. Tato funkce
  umožňuje uzlům provádějícím routování smazat historické záznamy o přeposílání
  bez potřeby mazat databázi nebo vypnout uzel.

- [BIPs #2099][] zveřejňuje [BIP393][], který specifikuje syntax volitelných
  anotací [deskriptorů][topic descriptors] výstupních skriptů. Ty umožňují
  peněženkám ukládat data pro obnovu, jako je výška vzniku, pro urychlení
  skenování peněženky (včetně skenování [tichých plateb][topic silent payments]).
  Viz též [zpravodaj č. 394][news394 bip393], který tento BIP popisoval.

- [BIPs #2118][] zveřejňuje [BIP440][] a [BIP441][] jako návrhy v sérii návrhů
  velkého skriptového obrození (GSR, Great Script Restoration či Grand Script
  Renaissance; viz též [zpravodaj č. 399][news399 bips]).
  [BIP440][] navrhuje varops rozpočet (náklady opkódů závisejících na velikosti vstupů)
  pro běhová omezení skriptu (viz [zpravodaj č. 374][news374 varops], _angl._).
  [BIP441][] popisuje novou verzi [tapscriptu][topic tapscript], která obnovuje
  opkódy deaktivované v roce 2010 jako [OP_CAT][topic op_cat] (viz
  [zpravodaj č. 374][news374 tapscript], _angl._) a omezuje náklady vyhodnocování
  skriptů dle varops rozpočtu z BIP440.

- [BIPs #2134][] přidává do [BIP352][] ([tiché platby][topic silent payments])
  varování vývojářům peněženek, aby pravidla filtrování (např. [prachu][topic
  uneconomical outputs]) neovlivňovala rozhodnutí, zda má skenování po nalezení
  platby pokračovat. V opačném případě hrozí předčasné ukončení skenování a peněženka
  by mohla postrádat pozdější výstupy od stejného odesílatele.

{% include snippets/recap-ad.md when="2026-04-14 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="33908,3283,4529,4494,10666,2099,2118,2134,1327" %}
[sources]: /en/internal/sources/
[news380 kernel]: /en/newsletters/2025/11/14/#bitcoin-core-30595
[news394 bip393]: /cs/newsletters/2026/02/27/#navrh-bipu-na-anotace-deskriptoru-vystupnich-skriptu
[news399 bips]: /cs/newsletters/2026/04/03/#rozpocet-varops-operaci-a-tapscriptovy-list-0xc2-skriptove-obrozeni-maji-bip-440-a-441
[news374 varops]: /en/newsletters/2025/10/03/#first-bip
[news374 tapscript]: /en/newsletters/2025/10/03/#second-bip
[BIP393]: https://github.com/bitcoin/bips/blob/master/bip-0393.mediawiki
[BIP440]: https://github.com/bitcoin/bips/blob/master/bip-0440.mediawiki
[BIP441]: https://github.com/bitcoin/bips/blob/master/bip-0441.mediawiki
[review club v31-rc-testing]: https://bitcoincore.reviews/v31-rc-testing
[major bitcoin core release]: https://bitcoincore.org/en/lifecycle/#versioning
[31.0 release notes]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/31.0-Release-Notes-Draft
[31.0 testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/31.0-Release-Candidate-Testing-Guide
[gh svanstaa]: https://github.com/svanstaa
[pod397 v31rc1]: /en/podcast/2026/03/24/#bitcoin-core-31-0rc1-transcript
[news382 bc33629]: /en/newsletters/2025/11/28/#bitcoin-core-33629
[news388 bc29415]: /cs/newsletters/2026/01/16/#bitcoin-core-29415
[news394 bc34512]: /cs/newsletters/2026/02/27/#bitcoin-core-34512
[news394 bc24539]: /cs/newsletters/2026/02/27/#bitcoin-core-24539
[news396 bc34692]: /cs/newsletters/2026/03/13/#bitcoin-core-34692
[news394 bc28792]: /cs/newsletters/2026/02/27/#bitcoin-core-28792
[news386 bc33657]: /cs/newsletters/2026/01/02/#bitcoin-core-33657
