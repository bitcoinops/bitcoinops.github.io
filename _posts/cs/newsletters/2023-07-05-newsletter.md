---
title: 'Zpravodaj „Bitcoin Optech” č. 258'
permalink: /cs/newsletters/2023/07/05/
name: 2023-07-05-newsletter-cs
slug: 2023-07-05-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Tento týden přinášíme další příspěvek do naší krátké týdenní série o
pravidlech mempoolu. Též nechybí naše pravidelné rubriky s oznámeními
o nových vydáních a popisem významných změn v populárních bitcoinových
páteřních projektech.

## Novinky

_V emailových skupinách Bitcoin-Dev a Lightning-Dev se tento týden neobjevily
žádné významné novinky._

## Čekání na potvrzení 8: pravidla jako rozhraní

_Krátká týdenní [série][policy series] o přeposílání transakcí, začleňování do mempoolu a výběru
transakcí k těžbě včetně vysvětlení, proč má Bitcoin Core přísnější pravidla,
než co je povoleno konsenzem, a jak mohou peněženky využít pravidla co nejefektivněji._

{% include specials/policy/cs/08-interface.md %} {% assign timestamp="0:30" %}

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [Core Lightning 23.05.2][] je údržbovým vydáním této implementace LN uzlu,
  které obsahuje opravy několika chyb, které mohou mít vliv na uživatele
  produkčních nasazení.

## Významné změny v kódu a dokumentaci

*Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo] a
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [Bitcoin Core #24914][] načítá záznamy z databáze peněženky seřazené podle
  druhu namísto procházení celé databáze dvakrát za účelem detekce závislostí.
  Po této změně již nemusí být některé peněženky s poškozenými záznamy načteny,
  avšak mohou být načteny předchozí verzí Bitcoin Core a migrovány na novou verzi.

- [Bitcoin Core #27896][] odstraňuje experimentální sandboxing systémových volání
  (syscall; viz [zpravodaj č. 170][news170 syscall], *angl.*). [Související report][Bitcoin
  Core #24771] a jeho komentáře hovoří o nevýhodách této funkce včetně udržovatelnosti
  seznamu volání a podpory OS, alternativy s lepší podporou a úvahy, zda
  by syscall sandboxing měl být zodpovědností Bitcoin Core.

- [Core Lightning #6334][] upravuje a rozšiřuje experimentální podporu
  [anchor výstupů][topic anchor outputs] (viz prvotní implementace ve [zpravodaji č.
  111][news111 cln anchor], *angl.*). PR dále obsahuje aktivaci
  experimentální podpory [HTLC][topic htlc] anchors s nulovými poplatky a
  přidání nastavitelných kontrol, které zajistí, že má uzel dostatek prostředků,
  pokud by potřeboval provozovat anchor kanál.

- [BIPs #1452][] přidává do specifikace [BIP329][] pro exportní formát [popisků
  peněženek][topic wallet labels] nový volitelný štítek `spendable`, který určuje,
  zda je připojený výstup peněženkou utratitelný. Mnoho peněženek implementuje
  funkce _kontroly mincí_, které uživateli umožňují určit, které výstupy nemá
  algoritmus [výběru mincí][topic coin selection] zvažovat pro utracení, například
  výstupy redukující soukromí uživatelů.

- [BIPs #1354][] přidává [BIP389][] pro [deskriptory][topic descriptors] s více derivačními
  cestami popsané ve [zpravodaji č. 211][news211 desc] (*angl.*). Umožňuje jedinému
  deskriptoru specifikovat dvě svázané BIP32 cesty pro generování hierarchických
  deterministických klíčů: jednu pro příchozí platby, druhou pro interní platby
  (např. drobné).

{% include references.md %}
{% include linkers/issues.md v=2 issues="24914,27896,6334,1452,1354,24771" %}
[policy series]: /cs/blog/waiting-for-confirmation/
[news111 cln anchor]: /en/newsletters/2020/08/19/#c-lightning-3830
[news211 desc]: /en/newsletters/2022/08/03/#multiple-derivation-path-descriptors
[core lightning 23.05.2]: https://github.com/ElementsProject/lightning/releases/tag/v23.05.2
[news170 syscall]: /en/newsletters/2021/10/13/#bitcoin-core-20487
