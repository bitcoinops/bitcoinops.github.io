---
title: 'Zpravodaj „Bitcoin Optech” č.279'
permalink: /cs/newsletters/2023/11/29/
name: 2023-11-29-newsletter-cs
slug: 2023-11-29-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Tento týden přinášíme souhrn aktualizace specifikace inzerátů likvidity.
Též nechybí naše pravidelné rubriky s vybranými otázkami a odpověďmi
z Bitcoin Stack Exchange, oznámeními o nových vydáních a popisem
významných změn v populárních bitcoinových páteřních projektech.

## Novinky

- **Aktualizace specifikace inzerátů likvidity:** Lisa Neigut
  zaslala do emailové skupiny Lightning-Dev [příspěvek][neigut liqad]
  oznamující aktualizaci specifikace [inzerátů likvidity][topic
  liquidity advertisements] („liquidity advertisements”). Tato funkce,
  implementovaná v Core Lightning a právě vyvíjená i pro Eclair,
  umožňuje uzlu oznámit, že je ochoten přispět prostředky na
  [kanál s oboustranným vkladem][topic dual funding]. Pokud jiný
  uzel nabídku přijme požadavkem na otevření kanálu, žádající
  uzel musí předem zaplatit nabízejícímu uzlu poplatek. To umožňuje
  uzlu, který potřebuje příchozí likviditu (např. obchodník), nalézt
  dobře propojená spojení, která mohou tuto likviditu za trží cenu
  poskytnout. Použit je k tomu pouze open source software a decentralizovaný
  gossip protokol.

  Aktualizace obsahuje několik změn struktur a zvýšenou flexibilitu
  doby trvání kontraktu a stropu příchozích poplatků. Příspěvek
  obdržel v emailové skupině několik odpovědí a očekávány jsou
  další změny [specifikace][bolts #878]. Neigut v příspěvku dále
  poznamenala, že současná konstrukce inzerátů likvidity a oznamování
  kanálů teoreticky umožňuje kryptograficky prokázat případ, ve kterém
  jedna ze stran kontrakt poruší. Návrh na kompaktní doklad o podvodu,
  který by mohl být použit v kontraktech s finančním závazkem k odrazení
  porušování kontraktu, je otevřeným problémem.

## Vybrané otázky a odpovědi z Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] je jedním z prvních míst, kde hledají
přispěvatelé Optechu odpovědi na své otázky a kde – najdou-li volnou chvíli –
pomáhají zvědavým či zmateným uživatelům. V této měsíční rubrice nabízíme
některé z otázek a odpovědí, které obdržely vysoký počet hlasů.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Jsou Schnorrovy digitální podpisy schématem pro interaktivní podepisování s více účastníky a zároveň i neagregované neinteraktivní schéma?]({{bse}}120402)
  Pieter Wuille popisuje rozdíly mezi podpisy s více účastníky, agregací podpisů a
  bitcoinovým multisigem a poukazuje na několik souvisejících schémat včetně
  [Schnorrových podpisů][topic schnorr signatures] dle [BIP340][], [MuSig2][topic musig],
  FROST a Bellare-Neven 2006.

- [Je vhodné provozovat kandidáta na vydání jako plný uzel na mainnetu?]({{bse}}120375)
  Vojtěch Strnad a Murch poznamenávají, že provozovat kandidáta na vydání Bitcoin Core
  na mainnetu neohrožuje bitcoinovou _síť_, ale uživatelé API, peněženky a další
  funkcionality by měli být opatrní a důkladně svou konfiguraci otestovat.

- [Jaký je vztah mezi nLockTime a nSequence?]({{bse}}120256)
  Antoine Poinsot a Pieter Wuille odpovídají na sérii otázek o `nLockTime` a `nSequence`,
  včetně [vztahu mezi těmito dvěma]({{bse}}120273), [původním smyslu `nLockTime`]({{bse}}120276),
  [možných hodnotách `nSequence`]({{bse}}120254) a vztahu k [BIP68]({{bse}}120320) a
  [`OP_CHECKLOCKTIMEVERIFY`]({{bse}}120259).

- [Co by se stalo, kdybychom poskytli opkódu OP_CHECKMULTISIG více podpisů, než je práh (m)?]({{bse}}120604)
  Pieter Wuille vysvětluje, že zatímco toto bylo dříve možné, po soft forku [BIP147][]
  již není nadále umožněno, aby dodatečný prvek v zásobníku u OP_CHECKMULTISIG a OP_CHECKMULTISIGVERIFY
  byla libovolná hodnota.

- [Co jsou „pravidla (mempoolu)”?]({{bse}}120269)
  Antoine Poinsot definuje termíny _pravidla_ („policy”) a _standardnost_ („standardness”)
  v kontextu Bitcoin Core a poskytuje několik příkladů. Též odkazuje na naši sérii o pravidlech
  [Čekání na potvrzení][policy series].

- [Co znamená Pay to Contract (P2C)?]({{bse}}120362)
  Vojtěch Strnad popisuje [Pay-to-Contract (P2C)][topic p2c] a odkazuje na
  [původní návrh][p2c paper].

- [Může být nesegwitová transakce serializovaná do segwitového formátu?]({{bse}}120317)
  Pieter Wuille vysvětluje, že zatímco několik starších verzí Bitcoin Core
  neúmyslně umožňovalo rozšířenou serializaci pro nesegwitové transakce,
  [BIP144][] specifikuje, že nesegwitové transakce musí použít starý
  formát serializace.

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [Core Lightning 23.11][] je vydáním další hlavní verze této implementace
  LN uzlu. Nabízí více flexibility autentizačního mechanismu _run_, vylepšenou
  verifikaci záloh a nové možnosti pluginů.

- [Bitcoin Core 26.0rc3][] je kandidátem na vydání příští hlavní verze
  této převládající implementace plného uzlu. K dispozici je [průvodce
  testováním][26.0 testing].

## Významné změny kódu a dokumentace

*Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo] a
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [Rust Bitcoin #2213][] upravuje výpočet předpokládané váhy P2WPKH vstupů
  během odhadu poplatků. Jelikož jsou transakce s high-s podpisy považovány
  za nestandardní již od Bitcoin Core verzí [0.10.3][bcc 0.10.3] a [0.11.1][bcc
  0.11.1], mohou procesy tvorby transakcí bezpečně předpokládat, že serializované
  ECDSA podpisy budou zabírat nejvíce 72 bytů namísto předchozí hodnoty
  73 bytů.

- [BDK #1190][] přidává novou metodu `Wallet::list_output`, která vrací
  všechny výstupy v peněžence, utracené i neutracené. Dříve bylo snadné
  získat seznam neutracených výstupů, avšak obdržet seznam utracených
  výstupů bylo těžké.

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 15:00" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="2213,1190,878" %}
[bitcoin core 26.0rc3]: https://bitcoincore.org/bin/bitcoin-core-26.0/
[26.0 testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/26.0-Release-Candidate-Testing-Guide
[core lightning 23.11]: https://github.com/ElementsProject/lightning/releases/tag/v23.11
[neigut liqad]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-November/004217.html
[policy series]: /cs/blog/waiting-for-confirmation/
[p2c paper]: https://arxiv.org/abs/1212.3257
[bcc 0.11.1]: https://bitcoin.org/en/release/v0.11.1#test-for-lows-signatures-before-relaying
[bcc 0.10.3]: https://bitcoin.org/en/release/v0.10.3#test-for-lows-signatures-before-relaying
