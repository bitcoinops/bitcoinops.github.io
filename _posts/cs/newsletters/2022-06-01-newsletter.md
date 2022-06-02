---
title: 'Zpravodaj „Bitcoin Optech” č. 202'
permalink: /cs/newsletters/2022/06/01/
name: 2022-06-01-newsletter-cs
slug: 2022-06-01-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Tento týden popisujeme pokusy vývojářů pracujících na tichých platbách a
připojujeme naše pravidelné rubriky se souhrnem vydání nových verzí a významných
změn v populárních bitcoinových infrastrukturních projektech.

## Novinky

- **Experimenty s tichými platbami:** jak jsme popsali ve [zpravodaji č. 194][news194 silent]
  (*angl.*), *tiché platby* („silent payments”) umožňují provést platbu veřejnému
  identifikátoru („adrese”), aniž by existoval veřejný záznam, že tato adresa
  nějakou platbu obdržela. Tento týden poslal vývojář w0xlt [příspěvek][w0xlt post]
  do emailové skupiny Bitcoin-Dev s [návodem][sp tutorial] na vytváření tichých
  plateb na [signetu][topic signet] pomocí experimentální [implementace][bitcoin core #24897]
  v Bitcoin Core. Několik dalších vývojářů včetně autorů populárních peněženek
  debatovalo o detailech návrhu včetně jeho [formátu adres][sp address].

## Vydání nových verzí

*Vydání nových verzí populárních bitcoinových infrastrukturních projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [HWI 2.1.1][] opravuje dvě drobné chyby postihující zařízení Ledger a Trezor
  a přidává podporu pro Ledger Nano S Plus.

- [LND 0.15.0-beta.rc3][] je kandidátem na vydání příští verze tohoto oblíbeného LN uzlu.

## Významné změny v kódu a dokumentaci

*Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo] a [Lightning BOLTs][bolts repo].*

- [BTCPay Server #3772][] umožňuje uživatelům provést test před vydáním ostré verze aktivací
  experimentálních funkcí.

- [BTCPay Server #3744][] přidává možnost exportu transakcí v CSV nebo JSON.

- [BOLTs #968][] přidává výchozí TCP porty uzlů používající Bitcoin testnet nebo signet.

{% include references.md %}
{% include linkers/issues.md v=2 issues="3772,3744,968,24897" %}
[lnd 0.15.0-beta.rc3]: https://github.com/lightningnetwork/lnd/releases/tag/v0.15.0-beta.rc3
[hwi 2.1.1]: https://github.com/bitcoin-core/HWI/releases/tag/2.1.1
[news194 silent]: /en/newsletters/2022/04/06/#delinked-reusable-addresses
[w0xlt post]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-May/020513.html
[sp tutorial]: https://gist.github.com/w0xlt/72390ded95dd797594f80baba5d2e6ee
[sp address]: https://gist.github.com/RubenSomsen/c43b79517e7cb701ebf77eec6dbb46b8?permalink_comment_id=4177027#gistcomment-4177027
