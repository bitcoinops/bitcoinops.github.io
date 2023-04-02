---
title: 'Zpravodaj „Bitcoin Optech” č. 243'
permalink: /cs/newsletters/2023/03/22/
name: 2023-03-22-newsletter-cs
slug: 2023-03-22-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Tento týden přinášíme naše pravidelné rubriky s popisem změn ve službách
a klientech a souhrnem významných změn populárních bitcoinových páteřních
projektů.

## Novinky

*Tento týden se v emailových skupinách Bitcoin-Dev a
Lightning-Dev neobjevily žádné významné novinky.*

## Změny ve službách a klientech

*V této měsíční rubrice upozorňujeme na zajímavé aktualizace bitcoinových
peněženek a služeb.*

- **Banka Xapo podporuje Lightning:**
  Banka Xapo [oznámila][xapo lightning blog] svým zákazníkům, že nyní mohou odesílat
  lightningové platby z aplikace mobilního bankovnictví. Banka používá infrastrukturu
  od Lightspark.

- **Vydána typescriptová knihovna pro práci s deskriptory miniscriptu:**
  [Bitcoin Descriptors Library][github descriptors library] založená na TypeScriptu
  podporuje [PSBT][topic psbt], [deskriptory][topic descriptors] a [miniscript][topic miniscript],
  včetně podpory pro přímé podepisování a podepisování pomocí některého hardware.

- **Oznámeno Breez Lightning SDK:**
  V nedávném [blogovém příspěvku][breez blog] oznámil Breez vydání open source
  [Breez SDK][github breez sdk] pro mobilní vývojáře, kteří chtějí integrovat
  bitcoinové a lightningové platby. SDK také podporuje [Greenlight][blockstream
  greenlight], možnosti poskytovatelů lightningových služeb (LSP) a další
  funkce.

- **Spuštěna směnárna OpenOrdex založená na PSBT:**
  [Open source][github openordex] software směnárny umožňuje prodávajícím vytvářet
  knihu objednávek Ordinal satoshi pomocí [PSBT][topic psbt] a kupujícím
  je podepisovat a odesílat.

- **Vydán coinjoin plugin pro BTCPay Server:**
  Wasabi Wallet [oznámila][wasabi blog], že kterýkoliv obchodník používající BTCPay Server
  může tento plugin aktivovat. Podporuje [coinjoinový][topic coinjoin] protokol
  [WabiSabi][news102 wabisabi].

- **Prohlížeč mempool.space vylepšuje podporu CPFP:**
  [Prohlížeč][topic block explorers] mempool.space oznámil [rozšířenou podporu][mempool
  tweet] transakcí využívající [CPFP][topic cpfp].

- **Vydán Sparrow v1.7.3:**
  [Vydání v1.7.3][sparrow v1.7.3] peněženky Sparrow obsahuje mimo jiné podporu pro multisig
  peněženky podle [BIP129][]  (viz [zpravodaj č. 136][news136 bsms], *angl.*) a nastavitelný
  prohlížeč bloků.

- **Stack Wallet přidává výběr mincí a BIP47:**
  Nedávné vydání [Stack Wallet][github stack wallet] přidává [výběr mincí][topic
  coin selection] a podporu [BIP47][].

- **Vydána Wasabi Wallet v2.0.3:**
  [Vydání v2.0.3][Wasabi v2.0.3] peněženky Wasabi obsahuje podepisování taprootových
  coinjoinů a podporu taprootových drobných, volitelný výběr mincí pro odesílání,
  zrychlené spouštění a další novinky.

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [LND v0.16.0-beta.rc3][] je kandidátem na vydání nové hlavní verze této oblíbené
  implementace LN.

## Významné změny v kódu a dokumentaci

*Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo] a [Lightning BOLTs][bolts repo].*

- [LND #7448][] přidává nové rozhraní pro opakované odesílání nepotvrzených
  transakcí, zejména takových, které byly vyloučeny z mempoolů. Je-li toto
  rozhraní aktivované, bude odesílat nepotvrzené transakce pomocí připojeného
  plného uzlu jednou za blok až do úspěšného potvrzení. LND již dříve opakovaně
  odesílalo transakce podobným způsobem, avšak pouze v režimu Neutrino.
  Jak bylo poznamenáno v Stack Exchange Q&A, [Bitcoin Core v současnosti
  transakce opakovaně neodesílá][no rebroadcast], ač by bylo žádoucí z
  důvodu spolehlivosti a bezpečnosti, kdyby plný uzel opakovaně odesílal
  transakce, které měly být (podle uzlu) začleněny do předchozího bloku.
  Mezitím je odpovědností každé peněženky ujistit se o umístění transakce
  v mempoolech.

- [BDK #793][] přináší velkou restrukturalizaci knihovny založené na projektu
  [bdk_core][bdk_core sub-project]. Dle popisku PR „zachovává současné API jak
  jen je to možné a přidává jen velmi málo.” Tři zjevně menší změny API jsou
  popsány v PR.

{% include references.md %}
{% include linkers/issues.md v=2 issues="7448,793" %}
[lnd v0.16.0-beta.rc3]: https://github.com/lightningnetwork/lnd/releases/tag/v0.16.0-beta.rc3
[bdk_core sub-project]: https://bitcoindevkit.org/blog/bdk-core-pt1/
[no rebroadcast]: /en/newsletters/2021/03/31/#will-nodes-with-a-larger-than-default-mempool-retransmit-transactions-that-have-been-dropped-from-smaller-mempools
[xapo lightning blog]: https://www.xapobank.com/blog/another-first-xapo-bank-now-supports-lightning-network-payments
[github descriptors library]: https://github.com/bitcoinerlab/descriptors
[breez blog]: https://medium.com/breez-technology/lightning-for-everyone-in-any-app-lightning-as-a-service-via-the-breez-sdk-41d899057a1d
[github breez sdk]: https://github.com/breez/breez-sdk
[blockstream greenlight]: https://blockstream.com/lightning/greenlight/
[github openordex]: https://github.com/orenyomtov/openordex
[wasabi blog]: https://blog.wasabiwallet.io/wasabiwalletxbtcpayserver/
[news102 wabisabi]: /en/newsletters/2020/06/17/#wabisabi-coordinated-coinjoins-with-arbitrary-output-values
[mempool tweet]: https://twitter.com/mempool/status/1630196989370712066
[news136 bsms]: /en/newsletters/2021/02/17/#securely-setting-up-multisig-wallets
[sparrow v1.7.3]: https://github.com/sparrowwallet/sparrow/releases/tag/1.7.3
[github stack wallet]: https://github.com/cypherstack/stack_wallet
[Wasabi v2.0.3]: https://github.com/zkSNACKs/WalletWasabi/releases/tag/v2.0.3
