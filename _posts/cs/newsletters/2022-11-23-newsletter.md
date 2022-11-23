---
title: 'Zpravodaj „Bitcoin Optech” č. 227'
permalink: /cs/newsletters/2022/11/23/
name: 2022-11-23-newsletter-cs
slug: 2022-11-23-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Tento týden přinášíme naše pravidelné rubriky s výběrem otázek a odpovědí z
Bitcoin Stack Exchange, oznámeními nových vydání a popisem významných změn
oblíbených páteřních bitcoinových projektů.

## Novinky

*Tento týden jsme nenalezli v emailových skupinách Bitcoin-Dev a Lightning-Dev žádné významné novinky.*

## Vybrané otázky a odpovědi z Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] je jedním z prvních míst, kde hledají
přispěvatelé Optechu odpovědi na své otázky a kde – najdou-li volnou chvíli –
pomáhají zvědavým či zmateným uživatelům. V této měsíční rubrice nabízíme
některé z otázek a odpovědí, které obdržely vysoký počet hlasů.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Jsou kvůli BIP-16 (P2SH) některé bitcoiny neutratitelné?]({{bse}}115803)
  Uživatel bca-0353f40e ukazuje šest výstupů, které obsahovaly skript v P2SH formátu
  `OP_HASH160 OP_DATA_20 [hash] OP_EQUAL` ještě před aktivací [BIP16][].
  Jeden z nich byl utracen podle starých pravidel před aktivací a v aktivačním kódu
  byla [zanesena výjimka][p2sh activation exception] pro tento jediný blok. Zbývající
  UTXO budou v případě utracení podléhat pravidlům BIP16.

- [Jaký software byl používán ke generování P2PK transakcí?]({{bse}}115962)
  Pieter Wuille poznamenává, že původní bitcoinový program vytvářel P2PK výstupy
  nejen v coinbase transakcích, ale také při posílání IP transakcí ([pay-to-IP
  adresy][wiki p2ip]).

- [Proč jsou spojením posílány zároveň txid i wtxid?]({{bse}}115907)
  Pieter Wuille odkazuje na [BIP339][] a vysvětluje, že zatímco wtxid jsou
  vhodnější pro přeposílání – mimo jiné kvůli poddajnosti („malleability”), některé
  uzly novější identifikátory wtxid nepodporují. Txid jsou tedy podporovány z důvodu
  zpětné kompatibility se staršími uzly.

- [Jak mohu vytvořit taprootovou adresu s vícenásobným podpisem?]({{bse}}115700)
  Pieter Wuille poznamenává, že současná RPC volání pro [vícenásobné podpisy][topic multisignature]
  (multisig), jako jsou např. `createmultisig` či `addmultisigaddress`, budou podporovat
  pouze staré peněženky, a nastiňuje, že s Bitcoin Core 24.0 budou moci uživatelé
  k vytváření [taprootových][topic taproot] skriptů s vícenásobným podpisem
  použít [deskriptory][topic descriptors] a RPC volání (např. `deriveaddresses` nebo
  `importdescriptors`) spolu s novým deskriptorem `multi_a`.

- [Je možné na novém ořezaném (pruned) uzlu přeskočit stahování bloků?]({{bse}}116030)
  Ač v současnosti není v Bitcoin Core tato možnost podporována, Pieter Wuille odkazuje
  na projekt [assumeutxo][topic assumeutxo]. Ten by umožnil nastartovat nové uzly
  stažením množiny UTXO, která by byla ověřena pomocí pevně zakódovaného hashe bez nutnosti
  důvěřovat zdroji.

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [LND 0.15.5-beta.rc2][] je kandidátem na údržbové vydání LND. Podle plánovaných poznámek
  vydání obsahuje pouze opravy drobných chyb.

- [Core Lightning 22.11rc2][] je kandidátem na vydání příští hlavní verze CLN. Tímto vydáním
  přejde CLN na nový model číslování verzí, avšak nadále bude používat [sémantické verzování][semantic
  versioning].

## Významné změny v kódu a dokumentaci

*Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo] a [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #25730][] přidává k RPC volání `listunspent` nový argument,
  který mezi výsledky volání začlení též coinbase výstupy, které nemohou
  být ještě utraceny, neboť od jejich začlenění těžařem nebylo ještě nalezeno
  více než 100 bloků.

- [LND #7082][] upravuje způsob vytváření faktur bez požadované částky tak, aby mohly
  obsahovat doporučené trasy, jež by pomohly odesílateli najít cestu k příjemci.

- [LDK #1413][] odstraňuje podporu pro původní formát onion dat s pevnou délkou.
  Nový format s proměnlivou délkou byl do specifikace přidán před více než třemi lety
  a podpora původní verze byla již odstraněna ze specifikace (viz [zpravodaj
  č. 220][news220 bolts962], *angl.*), z Core Lightning ([zpravodaj č. 193][news193
  cln5058], *angl.*), LND ([zpravodaj č. 196][news196 lnd6385], *angl.*) a Eclair
  ([zpravodaj č. 217][news217 eclair2190], *angl.*).

- [HWI #637][] přidává podporu pro velký plánovaný upgrade bitcoinového firmwaru
  v zařízeních Ledger. Úprava nakládání s pravidly utrácení, jak byla zmíněna ve
  [zpravodaji č. 200][news200 policy], nebyla do této změny začleněna; je však zmíněna
  jako plánovaná do budoucna.

{% include references.md %}
{% include linkers/issues.md v=2 issues="25730,7082,1413,637" %}
[bitcoin core 24.0]: https://bitcoincore.org/bin/bitcoin-core-24.0/
[bcc 24.0 rn]: https://github.com/bitcoin/bitcoin/blob/0ee1cfe94a1b735edc2581a05c4b12f8340ff609/doc/release-notes.md
[news222 rbf]: /en/newsletters/2022/10/19/#transaction-replacement-option
[news223 rbf]: /en/newsletters/2022/10/26/#continued-discussion-about-full-rbf
[news224 rbf]: /en/newsletters/2022/11/02/#mempool-consistency
[lnd 0.15.5-beta.rc2]: https://github.com/lightningnetwork/lnd/releases/tag/v0.15.5-beta.rc2
[core lightning 22.11rc2]: https://github.com/ElementsProject/lightning/releases/tag/v22.11rc2
[news220 bolts962]: /en/newsletters/2022/10/05/#bolts-962
[news217 eclair2190]: /en/newsletters/2022/09/14/#eclair-2190
[news193 cln5058]: /en/newsletters/2022/03/30/#c-lightning-5058
[news196 lnd6385]: /en/newsletters/2022/04/20/#lnd-6385
[news200 policy]: /cs/newsletters/2022/05/18/#prizpusobeni-miniscriptu-miniscript-a-deskriptoru-descriptors-podpisovym-zarizenim-signingdevices
[semantic versioning]: https://semver.org/spec/v2.0.0.html
[wiki p2ip]: https://en.bitcoin.it/wiki/IP_transaction
[p2sh activation exception]: https://github.com/bitcoin/bitcoin/commit/ce650182f4d9847423202789856e6e5f499151f8
