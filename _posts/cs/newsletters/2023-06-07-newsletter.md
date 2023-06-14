---
title: 'Zpravodaj „Bitcoin Optech” č. 254'
permalink: /cs/newsletters/2023/06/07/
name: 2023-06-07-newsletter-cs
slug: 2023-06-07-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Tento týden přinášíme souhrn diskuze z emailové skupiny o použití
návrhu MATT ke správě joinpoolů a napodobení funkcí navrhovaného
`OP_CHECKTEMPLATEVERIFY`. Též nechybí další příspěvek do krátké
týdenní série o pravidlech mempoolu a naše pravidelné rubriky s
oznámeními o vydání software a popisem významných změn v populárních
bitcoinových páteřních projektech.

## Novinky

- **Využití MATT k napodobení CTV a správě joinpoolů:** Johan Torås
  Halseth zaslal do emailové skupiny Bitcoin-Dev [příspěvek][halseth matt-ctv]
  o možnosti využít opkód `OP_CHECKOUTPUTCONTRACTVERIFY` (COCV) z navrhovaného
  konceptu Merklize All The Things (MATT, „všechno to zmerklujte“, viz
  zpravodaje [č. 226][news226 matt], *angl.*, a [č. 249][news249 matt])
  k napodobení funkcionality jiného návrhu [OP_CHECKTEMPLATEVERIFY][topic
  op_checktemplateverify]. Pro vytvoření commitmentu transakce s více
  výstupy by každý výstup vyžadoval zvláštní COCV opkód (pro porovnání:
  jediný CTV by stačil na commitment všech výstupů). To činí COCV méně
  efektivním, avšak „dost jednoduchým na to, aby byl zajímavý.”

  Kromě popisu funkcionality nabízí Halseth také [demo][halseth demo]
  s použitím [Tapsim][], nástroje pro „debugování tapscriptových transakcí […]
  zaměřený na vývojáře, kteří si chtějí hrát se skriptem, debugovat a
  pozorovat stav VM během výkonu skriptu.”

  V jiném vlákně [popsal][halseth matt-joinpool] Halseth použití MATT
  s [OP_CAT][] k vytvoření [joinpoolu][topic joinpools] (též nazývaného
  _coinpool_ nebo _payment pool_). I zde poskytuje [interaktivní demo][demo
  joinpool] pomocí Tapsim. Také na základě svých experimentů navrhl několik
  změn opkódů v MATT. Salvatore Ingala, původní autor návrhu MATT, se v
  [odpovědi][ingala matt] vyjádřil pozitivně.

## Čekání na potvrzení 4: odhad poplatků

_Krátká týdenní [série][policy series] o přeposílání transakcí, začleňování do mempoolu a výběru
transakcí k těžbě včetně vysvětlení, proč má Bitcoin Core přísnější pravidla,
než co je povoleno konsenzem, a jak mohou peněženky využít pravidla co nejefektivněji._

{% include specials/policy/cs/04-feerate-estimation.md %}

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [LND 0.16.3-beta][] je údržbovým vydáním této populární implementace LN.
  Poznámky k vydání uvádí, že „obsahuje pouze opravy chyb a má za cíl
  optimalizovat nedávno přidanou logiku sledování mempoolu a také opravit
  několik možných vektorů neúmyslného vynuceného zavření kanálu.” Pro
  více informací o logice sledování mempoolu, viz [zpravodaj č. 248][news248
  lnd mempool].

## Významné změny v kódu a dokumentaci

*Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo] a
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [Bitcoin Core #26485][] umožňuje RPC metodám, které jako parametr
  přijímají objekt `options`, přijmout stejné položky jako jmenné
  parametry. Například `bumpfee` může být voláno jako
  `src/bitcoin-cli -named bumpfee txid fee_rate=10` namísto dřívějšího
  `src/bitcoin-cli -named bumpfee txid options='{"fee_rate": 10}'`.

- [Eclair #2642][] přidává RPC volání `closedchannels`, které poskytuje
  data o vlastních zavřených kanálech. Viz též podobná změna v Core Lightning
  popsaná ve [zpravodaji č. 245][news245 listclosedchannels].

- [LND #7645][] přidává kontrolu, že jakýkoliv jednotkový poplatek poskytnutý
  uživatelem v rámci RPC volání `OpenChannel`, `CloseChannel`, `SendCoins` a
  `SendMany` není nižší než hodnota relay fee rate (jednotkový poplatek
  přeposílání). V poznámce je uvedeno: „Relay fee rate má pro různé backendy
  trochu jiný význam. V bitcoind je to v podstatě max(relay fee, min mempool fee).“

- [LND #7726][] bude vždy utrácet všechna HTLC platící místnímu uzlu, pokud
  kanál potřebuje vyrovnat zůstatky na blockchainu, včetně HTLC, jejichž
  hodnota je nižší než hodnota poplatku za transakci. Porovnejte se změnou
  v Eclair, již jsme popsali [minulý týden][news253 sweep], která programu
  zabrání nárokovat [neekonomická][topic uneconomical outputs] HTLC.
  Komentáře pod PR zmiňují, že LND pracuje na dalších změnách, které vylepší
  jeho schopnost kalkulovat náklady a zisky vztažené k vyrovnávání HTLC
  (offchain i onchain), což mu v budoucnosti umožní činit optimální rozhodnutí.

- [LDK #2293][] odpojí a znovu připojí uzly, které přestanou odpovídat. Má to
  zabránit problémům jiného LN software, které občas přestane odpovídat a vynutí
  si zavření kanálů.

{% include references.md %}
{% include linkers/issues.md v=2 issues="2642,26485,7645,7726,2293" %}
[policy series]: /cs/blog/waiting-for-confirmation/
[news226 matt]: /en/newsletters/2022/11/16/#general-smart-contracts-in-bitcoin-via-covenants
[news249 matt]: /cs/newsletters/2023/05/03/#uschovny-zalozene-na-matt
[news253 sweep]: /cs/newsletters/2023/05/31/#eclair-2668
[news245 listclosedchannels]: /cs/newsletters/2023/04/05/#core-lightning-5967
[halseth matt-ctv]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-June/021730.html
[halseth demo]: https://github.com/halseth/tapsim/blob/b07f29804cf32dce0168ab5bb40558cbb18f2e76/examples/matt/ctv2/README.md
[tapsim]: https://github.com/halseth/tapsim
[halseth matt-joinpool]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-May/021719.html
[demo joinpool]: https://github.com/halseth/tapsim/tree/matt-demo/examples/matt/coinpool
[ingala matt]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-May/021724.html
[news248 lnd mempool]: /cs/newsletters/2023/04/26/#lnd-7564
[lnd 0.16.3-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.16.3-beta
