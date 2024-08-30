---
title: 'Zpravodaj „Bitcoin Optech” č. 318'
permalink: /cs/newsletters/2024/08/30/
name: 2024-08-30-newsletter-cs
slug: 2024-08-30-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Zpravodaj tento týden oznamuje novou emailovou skupinu pro diskuze o
bitcoinové těžbě. Též nechybí naše pravidelné rubriky se souhrnem
oblíbených otázek a odpovědí z Bitcoin Stack Exchange, oznámeními
nových vydání a popisem nedávných změn v populárním bitcoinovém
páteřním software.

## Novinky

- **Nová vývojářská emailová skupina o těžbě bitcoinu:** Jay Beddict
  [oznámil][beddict mining-dev] vznik nové emailové skupiny, která se bude
  zabývat „aktualitami ze světa technologie těžby bitcoinu a dopadů změn
  bitcoinového softwaru a protokolů na těžbu.”

  Mark „Murch” Erhardt zaslal do skupiny [příspěvek][erhardt warp] s dotazem,
  zda by oprava [ohýbání času][topic time warp] nasazená na [testnet4][topic
  testnet] mohla způsobit vytváření nevalidních bloků těžaři, byla-li by
  stejná oprava nasazena i na mainnetu (např. jako součást [soft forku pročištění
  konsenzu][topic consensus cleanup]). Mike Schmidt čtenáře [odkázal][schmidt
  oblivious] na [vlákno][towns oblivious] v emailové skupině Bitcoin-Dev
  o [zapomnětlivých share][topic block withholding] (viz [zpravodaj č. 315][news315
  oblivious]).

## Vybrané otázky a odpovědi z Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] je jedním z prvních míst, kde hledají
přispěvatelé Optechu odpovědi na své otázky a kde – najdou-li volnou chvíli –
pomáhají zvědavým či zmateným uživatelům. V této měsíční rubrice nabízíme
některé z otázek a odpovědí, které obdržely vysoký počet hlasů.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Může uzel, který nezná všechny transakce, odeslat bez validace kompaktní blok dle BIP152?]({{bse}}123858)
  Antoine Poinsot vysvětluje, že přeposílání [kompaktních bloků][topic compact
  block relay] bez ověření, zda hlavička bloku zavazuje všem transakcím, by umožňovalo
  útoky odepřením služby.

- [Eliminoval segwit (BIP141) všechny možnosti poddajnosti txid vypsané v BIP62?]({{bse}}124074)
  Vojtěch Strnad nejdříve vyjmenovává způsoby, kterými mohou být txid modifikovány. Dále popisuje,
  jak segwit tuto poddajnost (náchylnost k modifikacím) řeší, a vysvětluje
  neúmyslnou poddajnost a jeden pull request vztahující se k pravidlům přeposílání.

- [Proč jsou i v roce 2024 stále v kódu checkpointy?]({{bse}}123768)
  Lightlike poznamenává, že po přidání [„Headers Presync”][news216 headers
  presync] (předsynchronizace hlaviček) do Bitcoin Core neexistují na
  checkpointy žádné _známé_ požadavky. Zdůrazňuje však, že mohou existovat
  _neznámé_ vektory útoků, před kterým by checkpointy mohly chránit.

- [Bulletproof++ jako obecné důkazy s nulovou znalostí na způsob SNARKs?]({{bse}}119556)
  Liam Eagen popisuje v současnosti používaný druh stručných neinteraktivních
  dokladů znalosti (succinct non-interactive arguments of knowledge, SNARKs) a
  objasňuje, jak by mohly být bulletproofs, [BitVM][topic acc] a [OP_CAT][topic op_cat]
  použity v bitcoinu k ověření těchto dokladů.

- [Jak může být OP_CAT použit k implementaci kovenantů?]({{bse}}123829)
  Brandon - Rearden popisuje způsob, kterým by navrhovaný opkód OP_CAT mohl
  bitcoinovým skriptům poskytnout funkci [kovenantů][topic covenants].

- [Proč obsahují některé bech32 bitcoinové adresy velké množství ‚q’?]({{bse}}123902)
  Vojtěch Strnad odhaluje, že protokol OLGA kódující libovolná data do P2WSH
  výstupů klade požadavek na vyplnění dat nulami (padding) za účelem jejich zarovnání
  (0 je v [bech32][topic bech32] kódována jako ‚q’).

- [Jak funguje 0-conf signature bond?]({{bse}}124022)
  Matt Black nastiňuje, jak by mohly prostředky uzamčené v kovenantu založeném
  na OP_CAT poskytnout plátci podnět, aby nenavyšoval svým transakcím poplatek
  pomocí [RBF][topic rbf]. Tím by mohla být navýšena šance na přijímání
  transakcí bez potvrzení.

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [Core Lightning 24.08rc2][] je kandidátem na vydání příští hlavní verze
  této oblíbené implementace LN uzlu.

- [LND v0.18.3-beta.rc1][] je kandidátem na vydání opravné verze této populární
  implementace LN uzlu.

- [BDK 1.0.0-beta.2][] je kandidátem na vydání této knihovny pro budování peněženek
  a jiných bitcoinových aplikací. Původní rustový balíček `bdk` byl přejmenován
  na `bdk_wallet` a moduly nižší úrovně byly extrahovány do samostatných balíčků:
  `bdk_chain`, `bdk_electrum`, `bdk_esplora` a `bdk_bitcoind_rpc`. Balíček
  `bdk_wallet` „je první verzí nabízející stabilní 1.0.0 API.”

- [Bitcoin Core 28.0rc1][] je kandidátem na vydání příští hlavní verze této převládající
  implementace plného uzlu. [Průvodce testování][bcc testing] se připravuje.

## Významné změny kódu a dokumentace

_Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Bitcoin Inquisition][bitcoin inquisition repo] a [repozitáři BINANA][binana
repo]._

- [LDK #3263][] zjednodušuje zacházení s odpověďmi na [onion zprávy][topic
  onion messages]. Ze struktury `ResponseInstruction` byl odstraněn typový
  parametr označující druh zprávy. Přidán byl nový výčet `MessageSendInstructions`
  založený na novém tvaru `ResponseInstruction`, který si umí poradit s normálními
  i [zaslepenými][topic rv routing] cestami pro odpověď. Metoda `send_onion_message`
  nově používá `MessageSendInstructions`, díky čemuž může uživatel určit
  cesty pro odpověď bez nutnosti je sám hledat. Nová varianta
  `MessageSendInstructions::ForReply` umožňuje kódu zpracovávajícímu zprávy
  posílat odpovědi bez vytváření cirkulárních závislostí v kódu. Viz též
  [zpravodaj č. 303][news303 onion].

- [LDK #3247][] zastarává metodu `AvailableBalances::balance_msat`. Nově by měla
  být používána metoda `ChannelMonitor::get_claimable_balances`, která poskytuje
  přímočařejší a přesnější přístup zjištění zůstatku kanálu. Logika zastaralé
  metody již není aktuální, neboť byla původně navržena na řešení potenciálních
  problémů s podtečením, pokud zůstatky začleňovaly nevyřízená HTLC (taková,
  která mohla být později revertována).

- [BDK #1569][] přidává crate `bdk_core` a přesunuje do něj některé typy z `bdk_chain`:
  `BlockId`, `ConfirmationBlockTime`, `CheckPoint`, `CheckPointIter`, `tx_graph::Update`
  a`spk_client`. Zdroje pro data z blockchainu `bdk_esplora`, `bdk_electrum` a `bdk_bitcoind_rpc`
  nově závisí pouze na `bdk_core`. Tyto změny umožní rychleji refaktorovat `bdk_chain`.

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="3263,3247,1569" %}
[Core Lightning 24.08rc2]: https://github.com/ElementsProject/lightning/releases/tag/v24.08rc2
[LND v0.18.3-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.18.3-beta.rc1
[BDK 1.0.0-beta.2]: https://github.com/bitcoindevkit/bdk/releases/tag/v1.0.0-beta.2
[bitcoin core 28.0rc1]: https://bitcoincore.org/bin/bitcoin-core-28.0/
[news315 oblivious]: /cs/newsletters/2024/08/09/#utoky-zadrzovanim-bloku-a-mozna-reseni
[beddict mining-dev]: https://groups.google.com/g/bitcoinminingdev/c/97fkfVmHWYU
[erhardt warp]: https://groups.google.com/g/bitcoinminingdev/c/jjkbeODskIk
[schmidt oblivious]: https://groups.google.com/g/bitcoinminingdev/c/npitVsP9KNo
[towns oblivious]: https://groups.google.com/g/bitcoindev/c/1tDke1a2e_Q
[bcc testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/28.0-Release-Candidate-Testing-Guide
[news216 headers presync]: /en/newsletters/2022/09/07/#bitcoin-core-25717
[news303 onion]: /cs/newsletters/2024/05/17/#ldk-2907
