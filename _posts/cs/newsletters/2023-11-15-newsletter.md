---
title: 'Zpravodaj „Bitcoin Optech” č. 277'
permalink: /cs/newsletters/2023/11/15/
name: 2023-11-15-newsletter-cs
slug: 2023-11-15-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Tento týden přinášíme popis aktualizace návrhu dočasných anchorů a
začleňujeme externí terénní zprávu o miniscriptu od vývojáře pracujícího
ve Wizardsardine. Též nechybí naše pravidelné rubriky s oznámeními o nových
vydáních a souhrnem významných změn v populárních bitcoinových páteřních
projektech.

## Novinky

- **Odstranění poddajnosti dočasných anchorů:** Gregory Sanders zaslal do fóra
  Delving Bitcoin [příspěvek][sanders mal] s úpravou navrhovaných [dočasných
  anchorů][topic ephemeral anchors] („ephemeral anchors”). Návrh by umožnil,
  aby transakce obsahovaly výstup s nulovou hodnotou a anyone-can-spend výstupním
  skriptem. Protože by tento výstup mohl utratit kdokoliv, kdokoliv by také
  mohl transakci, která výstup vytvořila, navýšit poplatek pomocí [CPFP][topic cpfp].
  To je výhodné pro protokoly s kontrakty s více účastníky jako LN, kde se
  transakce často podepisují před tím, než je možné přesně určit, jaký jednotkový
  poplatek by měly platit. Dočasné anchory umožňují, aby kterákoliv strana kontraktu
  přidala takový poplatek, jaký považuje za nezbytný. Pokud by kterákoliv
  strana (nebo z jakéhokoliv důvodu i kterýkoliv jiný uživatel) chtěla přidat
  vyšší poplatek, mohou navýšení pomocí CPFP [nahradit][topic rbf] svým vlastním
  CPFP navýšením.

  Jako anyone-can-spend skript je navrhován výstupní skript obsahující ekvivalent
  `OP_TRUE`, který lze utratit vstupem s prázdným vstupním skriptem. Jak Sanders
  tento týden poznamenal, zastaralý druh výstupního skriptu znamená, že potomek,
  který jej utrácí, bude mít poddajné txid, tedy kterýkoliv těžař může do vstupního
  skriptu přidat data, aby tím změnil txid potomka. Kvůli tomu by nebylo moudré
  použít potomka k jinému účelu, než je navýšení poplatku, neboť v opačném případě
  by mohl být potvrzen s jiným txid, což by tranzitivně zneplatnilo jakéhokoliv potomka
  tohoto potomka.

  Sanders proto navrhuje použití jednoho z výstupních skriptů, které byly rezervovány
  pro budoucí upgrady segwitu. Sice by to vyžadovalo o trochu více blokového
  prostoru (čtyři byty u segwitu oproti jednomu bytu v případě holého `OP_TRUE`),
  ale na druhou stranu by to odstranilo rizika poddajnosti transakce. Později Sanders
  navrhl možnost používat obě varianty: `OP_TRUE`, pokud uživatele poddajnost nezajímá,
  ale chce co nejmenší velikost transakce, a segwitovou verzi, která je větší, avšak
  nedovoluje pozměnit potomka. Diskuze ve vlákně se dále soustředila na výběr bytů
  v segwitové variantě tak, aby vznikaly zapamatovatelné [bech32m addresy][topic bech32].

## Terénní zpráva: Cesta k miniscriptu

{% include articles/cs/wizardsardine-miniscript.md extrah="#" %} {% assign timestamp="20:17" %}

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [LND 0.17.1-beta][] je údržbovým vydáním této implementace LN uzlu, které obsahuje opravy
  několika chyb a drobná vylepšení.

- [Bitcoin Core 26.0rc2][]  je kandidátem na vydání příští hlavní verze této
  převládající implementace plného uzlu. K dispozici je [průvodce testování][26.0
  testing] a na 15. listopadu 2023 je naplánované sezení [Bitcoin Core PR Review Club][]
  věnované testování.

- [Core Lightning 23.11rc1][] je kandidátem na vydání příští hlavní verze
  této implementace LN uzlu.

## Významné změny kódu a dokumentace

*Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo] a
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [Bitcoin Core #28207][] upravuje způsob, kterým je mempool uložen na disku
  (což se děje během vypínání uzlu, ale lze též vynutit RPC voláním `savemempool`).
  Dříve byl uložen jako prostá serializovaná data v paměti. Nově je tato
  serializovaná struktura XORována hodnotou náhodně vygenerovanou každým uzlem,
  aby tím byla data zatemněna. Během zapínání uzlu jsou zatemněná data XORována
  stejnou hodnotou. Zatemnění zabraňuje vložení určitých dat do transakce, která
  by se potom objevila mezi uloženými daty mempoolu a která by mohly antivirové
  a podobné programy označit za nebezpečná. Stejná metoda byla již dříve použita
  na ukládání množiny UTXO v [PR #6650][bitcoin core #6650]. Software, který
  potřebuje data mempoolu z disku načíst, by měl být sám schopen provést XOR nebo
  použít konfigurační volbu `-persistmempoolv1`, která bude ukládat data v
  nezatemněném formátu. Tato volba bude v budoucím vydání odstraněna.

- [LDK #2715][] umožňuje uzlu volitelně přijmout menší hodnotu [HTLC][topic htlc],
  než která má být doručena. To je užitečné, pokud spojení proti směru toku platí
  uzlu přes nový [JIT kanál][topic jit channels], za jehož onchain náklady musí
  platit a odečíst tyto náklady z hodnoty HTLC. Viz [zpravodaj č. 257][news257 jitfee]
  pro detaily o implementaci druhé části této vlastnosti.

{% include snippets/recap-ad.md when="2023-11-16 15:00" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="28207,6650,2715" %}
[bitcoin core 26.0rc2]: https://bitcoincore.org/bin/bitcoin-core-26.0/
[26.0 testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/26.0-Release-Candidate-Testing-Guide
[core lightning 23.11rc1]: https://github.com/ElementsProject/lightning/releases/tag/v23.11rc1
[lnd 0.17.1-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.17.1-beta
[sanders mal]: https://delvingbitcoin.org/t/segwit-ephemeral-anchors/160
[news257 jitfee]: /cs/newsletters/2023/06/28/#ldk-2319
