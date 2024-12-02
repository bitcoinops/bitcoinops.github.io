---
title: 'Zpravodaj „Bitcoin Optech” č. 327'
permalink: /cs/newsletters/2024/11/01/
name: 2024-11-01-newsletter-cs
slug: 2024-11-01-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Zpravodaj tento týden popisuje návrh na továrny kanálů s expiračními stromy
a shrnuje návrh BIPu na doklady rovnosti diskrétních logaritmů pro použití
během generování tichých plateb. Též nechybí naše pravidelné rubriky s oznámeními
nových vydání a popisem významných změn v populárním bitcoinovém páteřním
software.

## Novinky

- **Továrny kanálů s expiračními stromy:** ZmnSCPxj zaslal do fóra Delving Bitcoin
  [příspěvek][zmnscpxj post1] o svém návrhu na vícevrstvé [továrny kanálů][topic
  channel factories], který nazývá _SuperScalar_. Svůj návrh také představil
  v [diskuzi][deepdive] s přispěvateli Optechu. Cílem návrhu je poskytnout konstrukt,
  který by mohl být snadno implementován jedním subjektem, aniž by musel čekat na
  významné změny v protokolu vyžadující širokou podporu. Například nějaký poskytovatel
  lightningových služeb (LSP), který nabízí softwarovou peněženku, by mohl svým
  uživatelům umožnit otevírat kanály levněji a přijímat příchozí likviditu bez
  negativního vlivu na absenci požadavku na důvěru v LN.

  Konstrukt je založen na _expiračním stromu_ („timeout tree”), kde
  _financující transakce_ platí stromu předem definovaných následných transakcí,
  které jsou nakonec utraceny offchain v rámci mnoha oddělených platebních kanálů.
  Po nastavitelné době expirace (např. jeden měsíc) propadnou některým účastníkům
  expiračního stromu zbývající prostředky, čímž jsou motivováni před dosažením
  expirace prostředky vybrat nebo najít alternativní způsob jejich zabezpečení.
  To podpoří používání levných offchain mechanismů namísto publikování částí
  stromu onchain. V dříve popsaných expiračních stromech (viz [zpravodaj č. 270][news270
  timeout trees]) se staly expirované prostředky majetkem poskytovatele služby,
  avšak ZmnSCPxj to převrací: v jeho schématu připadnou expirované prostředky
  poskytovatele služby uživateli. Tím je břemeno zajištění potvrzení transakcí
  na straně poskytovatele služby a ne na koncových uživatelích.

  Expirační stromy vyžadují po každé zúčastněné straně podpis. Díky tomu není
  vyžadována žádná změna konsenzu, avšak kvůli známému [problému koordinace více
  podepisujících stran][news270 coordination] je tím omezen maximální počet uživatelů
  v továrně.

  Většina listů expiračního stromu jsou offchainové financující transakce
  kanálů, které se dnes běžně používají ([LN-Penalty][]), díky čemuž může být
  znovu použita část existujícího kódu správy LN kanálů. Protistranami každého
  kanálu jsou koncový uživatel a poskytovatel lightningových služeb (LSP), který
  expirační strom vytvořil. Část listů stromu může být výhradně pod kontrolou
  LSP za účelem vyrovnávání prostředků.

  Mezi kořenem a listy jsou [obousměrné mikroplatební kanály][topic duplex micropayment
  channels] („duplex micropayment channels”). Na rozdíl od kanálů typu
  LN-Penalty umožňují obousměrné kanály účast více než dvou stran bezpečně
  sdílejících prostředky. Na druhou stranu však povolují pouze relativně
  nízký počet aktualizací stavu (v porovnání s prakticky nekonečným počtem
  v případě LN-Penalty). Tyto mezilehlé obousměrné kanály jsou používány
  k vyrovnávání prostředků mezi LSP a dvěma koncovými uživateli, čímž
  je možné dosáhnout offchainových rychlostí. Uživatelé tak budou moci
  přijmout platby téměř okamžitě, i když před tím neměli ve svých kanálech
  na přijetí dostatečnou kapacitu.

  ZmnSCPxj později [popsal][zmnscpxj post2] výměnu části obousměrného kanálu
  za [Spillmanův][spillman channel] (jednosměrný) mikroplatební kanál. To by bylo
  onchain efektivnější v případě kooperativního zavření, avšak méně efektivní
  v případě jednostranného zavření.

  Návrh se setkal s průměrným množstvím reakcí. Autor poznamenal, že jednou
  ze slabin návrhu je vedle náročnosti správy dodatečného offchain stavu jakýchkoliv
  továren i jeho technická složitost zapříčiněná použitím několika různých
  typů kanálů. Avšak jeho návrh by mohl být implementován jediným týmem a mohl
  by dosáhnout kompatibility se standardním LN bez nutnosti provést v protokolu
  příliš mnoho změn.

- **Návrh BIPu na DLEQ doklady:** Andrew Toth zaslal do emailové skupiny
  Bitcoin-Dev [příspěvek][toth dleq] s návrhem BIPu a odkazem na [implementaci][dleq
  imp] generování a ověřování dokladů [rovnosti diskrétních logaritmů][topic dleq]
  (discrete log equality, DLEQ) pro eliptickou křivku používanou v bitcoinu
  (secp256k1). DLEQ umožňuje jedné straně prokázat, že zná soukromý klíč
  bez nutnosti o něm cokoliv odhalit (např. odpovídající veřejný klíč).
  V minulosti to bylo využíváno k podávání dokladu o vlastnictví nějakého
  UTXO, aniž by bylo potřeba toto UTXO odhalit (viz zpravodaje [č. 83][news83
  podle] a [č. 131][news131 podle], oba _angl._).

  Současný BIP je motivován podporou [tichých plateb][topic silent payments]
  vytvořených použitím několika nezávislých podepisujících. Pokud jeden z
  podepisujících lže nebo je vadný, může to vést ke ztrátě prostředků.
  DLEQ umožňuje každému podepisujícímu prokázat, že správně podepsal, aniž
  by musel odhalit svůj soukromý klíč ostatním. [Zpravodaj č. 308][news308 sp]
  popisuje předchozí diskuzi.

  Na návrh [reagoval][gibson dleq] Adam Gibson, který dříve implementoval
  systém DLEQ dokladů v implementaci [coinjoinu][topic coinjoin] JoinMarket.
  Navrhl několik změn, díky kterým by byl DLEQ flexibilnější pro používání
  i mimo tiché platby.

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [BTCPay Server 2.0.0][] je nejnovějším vydáním tohoto platebního procesoru,
  který umožňuje vlastní hostování. Mezi novinky patří „vylepšená lokalizace,
  navigace v postranním panelu, vylepšený průvodce nového uživatele, vylepšené
  možnosti brandingu, podpora pro pluginy s poskytovateli kurzů“ a další.
  Upgrade obsahuje několik migrací databáze a změn narušujících kompatibilitu.
  Doporučuje se před upgradem přečíst [oznámení][btcpay post].

## Významné změny kódu a dokumentace

_Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Bitcoin Inquisition][bitcoin inquisition repo] a [repozitáři BINANA][binana
repo]._

- [Bitcoin Core #31130][] odstraňuje závislost na `miniupnp` a tím i podporu
  Universal Plug and Play (UPnP) Internet Gateway Device (IGD), která byla v minulosti
  zdrojem zranitelností a byla již ve výchozím nastavení neaktivní (viz [zpravodaj
  č. 310][news310 upnp]). Nově byla nahrazena implementací Port Control Protocol (PCP)
  se záložním Network Address Translation-Port Mapping protokolem (NAT-PMP, viz
  [zpravodaj č. 323][news323 pcp]). Ten umožňuje se na uzel připojit bez manuální konfigurace
  a neobsahuje bezpečnostní rizika spojená s `miniupnp`.

- [LDK #3007][] přidává do výčtového typu `OutboundTrampolinePayload` varianty
  `BlindedForward` a `BlindedReceive`. Tím přináší do [trampolínového routování][topic
  trampoline payments] podporu pro [zaslepené cesty][topic rv routing], která je potřebná
  pro implementaci protokolu [nabídek][topic offers] dle [BOLT12][].

- [BIPs #1676][] mění stav [BIP85][] na dokončený. BIP je široce používán a již nepřinese
  nekompatibilní změny. Změna stavu byla navržena po nedávné nekompatibilní změně,
  která byla nejprve začleněna a později revertována (viz [zpravodaj č. 324][news324 bip85]).

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="31130,3007,1676" %}
[news83 podle]: /en/newsletters/2020/02/05/#podle
[news131 podle]: /en/newsletters/2021/01/13/#ln-dual-funding-anti-utxo-probing
[news308 sp]: /cs/newsletters/2024/06/21/#pokracuje-diskuze-o-psbt-pro-tiche-platby
[zmnscpxj post1]: https://delvingbitcoin.org/t/superscalar-laddered-timeout-tree-structured-decker-wattenhofer-factories/1143
[deepdive]: /en/podcast/2024/10/31/
[news270 timeout trees]: /cs/newsletters/2023/09/27/#kovenanty-pro-navyseni-skalovatelnosti-ln
[zmnscpxj post2]: https://delvingbitcoin.org/t/superscalar-laddered-timeout-tree-structured-decker-wattenhofer-factories/1143/16
[spillman channel]: https://en.bitcoin.it/wiki/Payment_channels#Spillman-style_payment_channels
[toth dleq]: https://mailing-list.bitcoindevs.xyz/bitcoindev/b0f40eab-42f3-4153-8083-b455fbd17e19n@googlegroups.com/
[dleq imp]: https://github.com/BlockstreamResearch/secp256k1-zkp/blob/master/src/modules/ecdsa_adaptor/dleq_impl.h
[gibson dleq]: https://mailing-list.bitcoindevs.xyz/bitcoindev/77ad84ed-2ff8-4929-b8da-d940c95d18a7n@googlegroups.com/
[news270 coordination]: /cs/newsletters/2023/09/27/#kovenanty-pro-navyseni-skalovatelnosti-ln
[ln-penalty]: https://en.bitcoin.it/wiki/Payment_channels#Poon-Dryja_payment_channels
[btcpay post]: https://blog.btcpayserver.org/btcpay-server-2-0/
[btcpay server 2.0.0]: https://github.com/btcpayserver/btcpayserver/releases/tag/v2.0.0
[news310 upnp]: /cs/newsletters/2024/07/05/#vzdalene-spusteni-kodu-kvuli-chybe-v-miniupnpc
[news323 pcp]: /cs/newsletters/2024/10/04/#bitcoin-core-30043
[news324 bip85]: /cs/newsletters/2024/10/11/#bips-1674
