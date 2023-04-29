---
title: 'Zpravodaj „Bitcoin Optech” č. 248'
permalink: /cs/newsletters/2023/04/26/
name: 2023-04-26-newsletter-cs
slug: 2023-04-26-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Tento týden přeposíláme žádost o poskytnutí zpětné vazby k návrhu na
odstranění podpory BIP35 P2P zprávy `mempool` v Bitcoin Core. Dále nechybí
naše pravidelné rubriky s oblíbenými otázkami a odpověďmi z Bitcoin Stack
Exchange, oznámeními o nových vydáních a souhrnem významných změn v
populární bitcoinových páteřních projektech.

## Novinky

- **Návrh na odstranění BIP35 P2P zprávy `mempool`:** Will Clark zaslal
  do emailové skupiny Bitcoin-Dev [příspěvek][clark mempool] o [PR][bitcoin
  core #27426], který otevřel za účelem odstranění podpory pro P2P zprávu
  `mempool`, která byla původně specifikována v [BIP35][]. Dle původní
  implementace by uzel po obdržení zprávy `mempool` měl odpovědět zprávou
  `inv` obsahující ID všech transakcí v jeho mempoolu. Uzel, který
  odeslal původní požadavek, by poté mohl běžnou zprávou `getdata`
  požádat o data kterékoliv transakce. BIP popisuje tři důvody pro existenci
  této zprávy: diagnostika síťového provozu, možnost odlehčených klientů
  žádat o nepotvrzené transakce a možnost těžařů požádat po restartu o
  nepotvrzené transakce (v té době Bitcoin Core ještě neukládal mempool
  na disk).

  Avšak později byly vyvinuty techniky, které zneužívaly zprávy `mempool`
  a `getdata` k určení, který uzel jako první odeslal nějakou transakci.
  Pro zlepšení [soukromí odesílatele transakcí][topic transaction origin privacy]
  byla později odstraněna možnost požádat jiné uzly o neoznámené transakce
  a zpráva `mempool` mohla být použita pouze s [bloom filtry transakcí][topic
  transaction bloom filtering] (dle [BIP37][]). Ještě později Bitcoin Core
  ve výchozím stavu bloom filtr neaktivoval (viz [zpravodaj č. 56][news56 bloom],
  *angl.*) a umožnil jej používat pouze se spojeními, která měla aktivovanou
  volbu `whitelist` ([zpravodaj č. 60][news60 bloom], *angl.*). To ve svém
  důsledku znamená, že i zpráva `mempool` je ve výchozím stavu neaktivní.

  Clarkův pull request do Bitcoin Core obdržel podporu, avšak někteří z
  podporujících soudí, že by měly být nejprve odstraněny BIP37 bloom filtry.
  Zatím jediná [reakce][harding mempool] v emailové skupině poznamenává,
  že odlehčené klienty, které se připojují k důvěryhodným uzlům, mohou v
  současnosti využívat BIP35 a BIP37 jako nejefektivnějšího způsobu, jak se
  mohou dozvědět o nepotvrzených transakcích. Autor příspěvku navrhl,
  aby Bitcoin Core před odstraněním současného rozhraní nejdříve poskytl
  alternativní způsob.

  Lidé, kteří používají BIP35 zprávu `mempool`, jsou žádáni o poskytnutí
  zpětné vazby buď v emailové skupině nebo PR.

## Vybrané otázky a odpovědi z Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] je jedním z prvních míst, kde hledají
přispěvatelé Optechu odpovědi na své otázky a kde – najdou-li volnou chvíli –
pomáhají zvědavým či zmateným uživatelům. V této měsíční rubrice nabízíme
některé z otázek a odpovědí, které obdržely vysoký počet hlasů.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Kolik sigops je v nevalidním bloku 783426?]({{bse}}117837)
  Vojtěch Strnad poskytl skript, který prochází všechny transakce v bloku a
  počítá [sigops]({{bse}}117359) (opkódy, které ověřují elektronické podpisy).
  Napočítal 80 003 sigops, což blok činí [nevalidním][max sigops].

- [Jak by mohl útočník až 500krát zvýšit poplatek potřebný k nahrazení transakce?]({{bse}}117734)
  Michael Folkson poukazuje na návrh BIP pro [dočasné anchor výstupy][topic ephemeral
  anchors] („ephemeral anchors”) a táže se, jakým způsobem je možné 500krát navýšit
  poplatek vyžadovaný pro nahrazení transakce. Antoine Poinsot poskytuje příklad,
  jak by útočník mohl zneužít pravidla navýšení poplatku pomocí [Replace-By-Fee (RBF)][topic rbf]
  k vyžádání dodatečných transakcí, které by platily výrazně vyšší poplatky.

- [Jak nejlépe na vícenásobné CPFP a CPFP + RBF?]({{bse}}117877)
  Sdaftuar vysvětluje techniku navyšování poplatků pomocí RBF a CPFP
  ([Child Pays For Parent][topic cpfp]) v situaci, kdy prvotní pokus o navýšení
  pomocí CPFP selže z důvodu nedostatečného jednotkového poplatku.

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [LDK 0.0.115][] je vydáním této knihovny pro stavbu peněženek a aplikací
  s LN. Obsahuje několik nových funkcí a oprav chyb, včetně lepší podpory
  pro experimentální protokol [nabídek][topic offers] a vylepšené
  bezpečnosti a soukromí.

- [LND v0.16.1-beta][] je vydáním této implementace LN, která obsahuje
  několik oprav a další vylepšení. Poznámky o vydání zmiňují, že
  CLTV delta byla navýšena ze 40 bloků na 80 (viz [zpravodaj č. 40][news40
  cltv], který se zabývá předchozí změnou výchozí hodnoty).

- [Core Lightning 23.05rc1][] je kandidátem na vydání příští verze
  této implementace LN.

## Významné změny v kódu a dokumentaci

*Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo] a
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [LND #7564][] nyní umožňuje, aby uživatelé backendů poskytujících
  přístup do mempoolu mohli monitorovat nepotvrzené transakce obsahující
  předobraz HTLC svých kanálů. Díky tomu může uzel rychleji vyřídit
  HTLC, jelikož nemusí čekat na potvrzení transakce.

- [LND #6903][] přidává do RPC volání `openchannel` novou volbu `fundmax`,
  která alokuje všechny prostředky kanálu na nový kanál. Vyňaty jsou
  částky potřebné k přidání poplatků pomocí [anchor výstupů][topic anchor outputs].

- [LDK #2198][] prodlužuje dobu, po kterou LDK čeká, než odešle gossip zprávu
  oznamující nedostupnost kanálu (např. kvůli nedostupnému spojení).
  V předešlé verzi čekalo LDK zhruba minutu, avšak jiné implementace čekají
  déle. Existující [návrh][bolts #1059] doporučuje používat počet bloků
  namísto [unixové času][Unix epoch time], což by si vynutilo aktualizaci
  gossip zpráv jednou za blok (průměrně zhruba každých deset minut).
  Ač PR poznamenává, že pomalejší odesílání aktualizací má klady i zápory,
  nastavuje novou hodnotu na deset minut.

- [Bitcoin Inquisition #23][] přidává částečnou podporu [dočasných anchor
  výstupů][topic ephemeral anchors]. Nepřináší podporu [přeposílání v3 transakcí][topic
  v3 transaction relay], kterou dočasné anchor výstupy potřebují k zabránění
  [transaction pinning útokům][topic transaction pinning].

{% include references.md %}
{% include linkers/issues.md v=2 issues="7564,6903,2198,1059,23,27426" %}
[Core Lightning 23.05rc1]: https://github.com/ElementsProject/lightning/releases/tag/v23.05rc1
[news56 bloom]: /en/newsletters/2019/07/24/#bitcoin-core-16152
[news60 bloom]: /en/newsletters/2019/08/21/#bitcoin-core-16248
[clark mempool]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-April/021562.html
[harding mempool]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-April/021563.html
[unix epoch time]: https://en.wikipedia.org/wiki/Unix_time
[ldk 0.0.115]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.0.115
[lnd v0.16.1-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.16.1-beta
[news40 cltv]: /en/newsletters/2019/04/02/#lnd-2759
[max sigops]: https://github.com/bitcoin/bitcoin/blob/e9262ea32a6e1d364fb7974844fadc36f931f8c6/src/consensus/consensus.h#L17
