---
title: 'Zpravodaj „Bitcoin Optech” č. 242'
permalink: /cs/newsletters/2023/03/15/
name: 2023-03-15-newsletter-cs
slug: 2023-03-15-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Tento týden přinášíme oznámení o service bitu používaném pro testování
Utreexo, odkazujeme na několik nových softwarových vydání a popisujeme
začleněný pull request Bitcoin Core.

## Novinky

- **Service bit pro Utreexo:** Calvin Kim [zaslal][kim utreexo] do
  emailové skupiny Bitcoin-Dev zprávu, že software právě navrhovaný
  pro experimenty na signetu a testnetu bude v P2P protokolu používat
  service bit 24. Experimentální software poskytuje podporu pro
  [Utreexo][topic utreexo], protokol umožňující plnou validaci
  transakcí uzly, které neukládají sadu UTXO, což ušetří až 5 GB
  diskového prostoru oproti modernímu Bitcoin Core plnému uzlu a
  bez snížení bezpečnosti. Utreexo uzel potřebuje stáhnout dodatečná data,
  obdrží-li nepotvrzenou transakci (nebo blok potvrzených transakcí),
  service bit tedy pomůže uzlu najít spojení schopná tato data
  poskytnout.

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [Core Lightning v23.02.2][] je údržbovým vydáním tohoto LN software.
  Vrací zpět změny RPC volání `pay`, které způsobily problémy
  jiným systémům, a obsahuje několik dalších změn.

- [Libsecp256k1 0.3.0][] je vydáním této kryptografické knihovny.
  Obsahuje změnu API, která porušuje kompatibilitu ABI.

- [LND v0.16.0-beta.rc3][] je kandidátem na vydání hlavní verze této
  oblíbené implementace LN.

## Významné změny v kódu a dokumentaci

*Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo] a [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #25740][] umožňuje uzlu používajícímu [assumeUTXO][topic assumeutxo]
  ověrit všechny bloky a transakce v blockchainu až do stavu, o kterém
  assumeUTXO tvrdí, že jím byl vygenerován. Zároveň s ověřováním se buduje
  množina UTXO (chainstate). Je-li chainstate roven stavu
  assumeUTXO staženému během prvního spuštění, je stav plně validován.
  Uzel validuje každý blok v blockchainu, stejně jako jiné plné uzly, však
  v jiném pořadí. Tento zvláštní chainstate, sloužící k ověření starších
  bloků, je smazán při následném spuštění uzlu a diskový prostor je uvolněn.
  Je potřeba do kódu začlenit ještě několik jiných částí [projektu][assumeUTXO project],
  než bude použitelný.

{% include references.md %}
{% include linkers/issues.md v=2 issues="25740" %}
[lnd v0.16.0-beta.rc3]: https://github.com/lightningnetwork/lnd/releases/tag/v0.16.0-beta.rc3
[libsecp256k1 0.3.0]: https://github.com/bitcoin-core/secp256k1/releases/tag/v0.3.0
[core lightning v23.02.2]: https://github.com/ElementsProject/lightning/releases/tag/v23.02.2
[kim utreexo]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-March/021515.html
[assumeutxo project]: https://github.com/bitcoin/bitcoin/projects/11
