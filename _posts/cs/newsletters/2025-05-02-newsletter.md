---
title: 'Zpravodaj „Bitcoin Optech” č. 352'
permalink: /cs/newsletters/2025/05/02/
name: 2025-05-02-newsletter-cs
slug: 2025-05-02-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Zpravodaj tento týden odkazuje na srovnání různých technik
linearizace clusterů a stručně shrnuje diskuzi o navýšení nebo odstranění
limitů `OP_RETURN` v Bitcoin Core. Též nechybí naše pravidelné rubriky
s oznámeními nových vydání a popisem významných změn v populárním
bitcoinovém páteřním software.

## Novinky

- **Srovnání technik linearizace clusterů:**
  Pieter Wuille zaslal do fóra Delving Bitcoin [příspěvek][wuille clustrade]
  srovnávající výhody a nevýhody tří různých technik linearizace clusterů.
  Dále poskytuje [výkonnostní testy][wuille clusbench] jejich implementací.
  Další vývojáři o výsledcích diskutovali a kladli doplňující dotazy, které
  Wuille zodpověděl.

- **Navýšení či odstranění omezení velikosti `OP_RETURN` v Bitcoin Core:**
  ve vlákně v emailové skupině Bitcoin-Dev diskutovalo několik vývojářů
  o změně nebo odstranění výchozího omezení výstupů `OP_RETURN`,
  které umožňují přidání libovolných dat. Další diskuze probíhala v následném
  [pull requestu][bitcoin core #32359] v Bitcoin Core repozitáři.
  Namísto snahy o shrnutí celé rozsáhlé diskuze zde shrneme pouze naše
  myšlenky o nejpádnějších argumentech pro změnu a proti změně.

  - *Pro navýšení (nebo odstranění) limitu:* Pieter Wuille [říká][wuille opr],
    že pravidla standardnosti transakcí jen těžko zabrání potvrzování
    transakcí s libovolnými daty, které jsou vytvářené majetnými organizacemi.
    Tyto organizace budou posílat transakce přímo těžařům. Dále věří, že
    bloky jsou obecně plné bez ohledu na přítomnost transakcí s daty,
    celkové množství ukládaných dat uzly je v obou případech zhruba stejné.

  - *Proti změně limitu:* Jason Hughes [soudí][hughes opr], že navýšení
    limitu by usnadnilo ukládání libovolných dat na počítačích provozujících
    plné uzly a že některá data by mohla být nepřípustná (včetně nezákonnosti
    ve většině jurisdikcích). I kdyby uzel data na disku šifroval (viz
    [zpravodaj č. 316][news316 blockxor]), ukládání těchto dat a možnost
    je pomocí RPC stahovat by mohla být pro mnoho uživatelů problematická.

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [LND 0.19.0-beta.rc3][] je kandidátem na vydání tohoto oblíbeného LN uzlu.
  Jedním významným vylepšením, které by si zasloužilo důkladné testování, je
  nové schéma RBF navyšování poplatků během kooperativního zavření kanálu.

## Významné změny kódu a dokumentace

_Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo] a [repozitáři BINANA][binana repo]._

- [Bitcoin Core #31250][] deaktivuje vytváření a načítání zastaralých peněženek.
  Tím završuje migraci na [deskriptorové][topic descriptors] peněženky, které
  jsou výchozí již od roku 2021 (viz [zpravodaj č. 172][news172 descriptors],
  _angl._). Soubory Berkeley DB používané zastaralými peněženkami již načítané
  být nemohou a odstraněné jsou též všechny testy zastaralých peněženek.
  Nějaký související kód nadále zůstává, bude odstraněn v následných PR. Bitcoin Core
  bude i nadále schopný migrovat zastaralé peněženky na nový formát (viz
  [zpravodaj č. 305][news305 bdbro]).

- [Eclair #3064][] refaktoruje kód správy klíčů kanálu. Přináší třídu `ChannelKeys`,
  jejíž instanci bude nově držet každý kanál. Pro podepisování commitmentů
  a [HTLC][topic htlc] transakcí slouží `CommitmentKeys`, který je derivován
  z `ChannelKeys`. Logika vynucených zavření kanálů a tvorba skriptů a witnessů
  nově závisí na `CommitmentKeys`. Dříve byl kód generování klíčů roztříštěn,
  aby mohl podporovat externí podpisová zařízení. To bylo náchylné na chyby,
  jelikož tento systém při výběru správných klíčů závisel na jmenných konvencích
  spíše než na typech.

- [BTCPay Server #6684][] přidává podporu části [deskriptorů][topic descriptors]
  pravidel peněženek (wallet policy descriptors) dle [BIP388][]. Umožní tím
  uživatelům importovat a exportovat pravidla pro jednoduché i vícenásobné (_k_ z _n_)
  podpisy. Obsahuje formáty, které podporuje Sparrow: P2PKH, P2WPKH, P2SH-P2WPKH a P2TR
  a jim odpovídající multisig varianty (kromě P2TR). Záměrem PR je zlepšit používání
  multisig peněženek.

- [BIPs #1555][] začleňuje [BIP321][], který navrhuje URI schéma pro popis bitcoinových
  platebních instrukcí. Jedná se o modernizaci a rozšíření [BIP21][]. Zachovává
  původní adresy v cestě, avšak standardizuje používání parametrů v dotazu URI dle
  platební metody. Pokud je v dotazu přítomna alespoň jedna platební instrukce,
  adresa v cestě nemusí být uvedena. Dále je přidáno volitelné rozšíření umožňující
  poskytnout plátci doklad o zaplacení a jsou poskytnuty kroky pro přidání nových
  platebních instrukcí.

{% include snippets/recap-ad.md when="2025-05-06 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="31250,3064,6684,1555,32359" %}
[lnd 0.19.0-beta.rc3]: https://github.com/lightningnetwork/lnd/releases/tag/v0.19.0-beta.rc3
[wuille clustrade]: https://delvingbitcoin.org/t/how-to-linearize-your-cluster/303/68
[wuille clusbench]: https://delvingbitcoin.org/t/how-to-linearize-your-cluster/303/73
[hughes opr]: https://mailing-list.bitcoindevs.xyz/bitcoindev/f4f6831a-d6b8-4f32-8a4e-c0669cc0a7b8n@googlegroups.com/
[wuille opr]: https://mailing-list.bitcoindevs.xyz/bitcoindev/QMywWcEgJgWmiQzASR17Dt42oLGgG-t3bkf0vzGemDVNVnvVaD64eM34nOQHlBLv8nDmeBEyTXvBUkM2hZEfjwMTrzzoLl1_62MYPz8ZThs=@wuille.net/
[news316 blockxor]: /cs/newsletters/2024/08/16/#bitcoin-core-28052
[news172 descriptors]: /en/newsletters/2021/10/27/#bitcoin-core-23002
[news305 bdbro]: /cs/newsletters/2024/05/31/#bitcoin-core-26606
