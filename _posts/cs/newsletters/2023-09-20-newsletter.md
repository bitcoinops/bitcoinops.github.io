---
title: 'Zpravodaj „Bitcoin Optech” č. 269'
permalink: /cs/newsletters/2023/09/20/
name: 2023-09-20-newsletter-cs
slug: 2023-09-20-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Tento týden přinášíme oznámení o nadcházejícím setkání badatelů a naše
pravidelné rubriky se souhrnem významných změn ve službách a klientském
software, oznámeními o nových vydáních a popisem významných změn v populárních
bitcoinových páteřních projektech.

## Novinky

- **Setkání bitcoinových badatelů:** Sergi Delgado Segura a Clara Shikhelman
  zaslali do emailových skupin Bitcoin-Dev a Lightning-Dev [příspěvek][ds brd]
  oznamující _Bitcoin Research Day_, osobní setkání, které se uskuteční
  27. října v New Yorku. Během dne vystoupí několik známých bitcoinových
  badatelů. Rezervace jsou povinné. V době psaní bylo ještě několik volných
  slotů pro pětiminutové prezentace.

## Změny ve službách a klientech

*V této měsíční rubrice upozorňujeme na zajímavé aktualizace bitcoinových
peněženek a služeb.*

- **Vydán Bitcoin-like Script Symbolic Tracer (B'SST):**
  [B'SST][] je nástroj pro analýzu skriptů bitcoinu a Elements, který poskytuje rozbor
  skriptů včetně „vynucovaných podmínek, možných selhání a možných hodnot dat.”

- **Demo ověřování řetězce hlaviček pomocí STARK:**
  Projekt [ZeroSync][news222 zerosync] oznámil [ukázku][zerosync demo] a
  [repozitář][zerosync code] používající STARK k prokázání a ověření řetězce
  bitcoinových hlaviček.

- **Vydán JoinMarket v0.9.10:**
  Vydání [v0.9.10][joinmarket v0.9.10] přináší podporu [RBF][topic rbf] u
  ne[coinjoin][topic coinjoin]ových transakcí, vylepšený odhad poplatků a další
  novinky.

- **BitBox přidává miniscript:**
  [Nový BitBox02 firmware][bitbox blog] přidává podporu [miniscriptu][topic
  miniscript], bezpečnostní opravu a vylepšení použitelnosti.

- **Machankura oznamuje aditivní dávkování:**
  Poskytovatel bitcoinových služeb [Machankura][] [oznámil][machankura tweet]
  beta verzi funkce, která podporuje aditivní [dávkování][batching] pomocí
  RBF v [taprootové][topic taproot] peněžence s podporou [prahových][topic
  threshold signature] podmínek utrácení FROST.

- **Lightningový simulátor SimLN :**
  [SimLN][] je simulační nástroj pro výzkumníky LN a vývojáře protokolu a aplikací,
  který generuje realistickou aktivitu LN plateb. SimLN podporuje LND a CLN,
  podpora pro Eclair a LDK-Node je ve vývoji.

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [Core Lightning 23.08.1][] je údržbovým vydáním obsahující opravy několika
  chyb.

- [LND v0.17.0-beta.rc4][] je kandidátem na vydání příští hlavní verze této
  oblíbené implementace LN uzlu. Velkou novou experimentální funkcí
  plánovanou pro toto vydání, které by prospělo testování, je podpora
  „jednoduchých taprootových kanálů.”

## Významné změny v kódu a dokumentaci

*Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo] a
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [Bitcoin Core #26152][], stavějící na dříve přidaném rozhraní (viz
  [zpravodaj č. 252][news252 bumpfee]), přidává možnost zaplatit jakýkoliv
  _schodek poplatku_ („fee deficit”) mezi vstupy vybranými do
  transakce. Schodek poplatku nastává, když musí peněženka zvolit UTXO
  s nepotvrzenými rodiči, kteří platí nízký jednotkový poplatek.
  Aby mohla transakce platit uživatelem zvolený jednotkový poplatek,
  musí transakce platit dostatečně velký poplatek, aby zaplatila za sebe
  i za nepotvrzené rodiče s nízkým jednotkovým poplatkem. Ve stručnosti
  toto PR zajišťuje, aby se uživatelovi, který volbou poplatku určuje prioritu
  potvrzení transakce, této priority dostálo, i když musí jeho peněženka platit
  za nepotvrzená UTXO. Všechny ostatní peněženky, kterých jsme si vědomi,
  garantují prioritu založenou na jednotkovém poplatku pouze v případě
  utrácení potvrzených UTXO. Viz též [zpravodaj č. 229][news229 bumpfee],
  jehož souhrn sezení Bitcoin Core PR Review Club se věnuje právě tomuto PR.

- [Bitcoin Core #28414][] přidává do RPC volání `walletprocesspsbt`
  kompletní serializovanou transakci, pokud tento krok vyústí v
  transakci připravenou na zveřejnění. Díky tomu nemusí uživatel
  volat `finalizepsbt`, pokud je [PSBT][topic psbt] již hotové.

- [Bitcoin Core #28448][] zastarává konfigurační parameter `rpcserialversion`
  určující verzi RPC serializací. Tato volba byla přidána během přechodu
  na v0 segwit, aby mohly mít starší programy nadále přístup k blokům
  a transakcím ve formátu bez segwitových polí. Dnes by již všechny
  programy měly být schopné zpracovávat segwitové transakce a tato volba
  by již neměla být potřebná. Dle poznámek k vydání přidaných tímto PR
  je však možné volbu dočasně znovu aktivovat jako zastaralou.

- [Bitcoin Core #28196][] přidává významný kus kódu potřebný k podpoře
  [transportního protokolu verze 2][topic v2 p2p transport] dle specifikace
  v [BIP324][] spolu s důsledným fuzz testováním tohoto kódu. Neaktivuje
  žádné nové schopnosti, pouze redukuje množství kódu, který bude muset
  být v budoucích PR přidán.

- [Eclair #2743][] přidává RPC volání `bumpforceclose`, které řekne uzlu,
  aby použil [anchor výstup][topic anchor outputs] kanálu na navýšení
  poplatku commitment transakce pomocí [CPFP][topic cpfp]. Uzly Eclair
  nabízí v nutných případech automatické navyšování poplatků, toto volání
  umožní provozovateli učinit totéž i manuálně.

- [LDK #2176][] navyšuje přesnost, se kterou se LDK pokouší o pravděpodobnostní
  odhad výše likvidity ve vzdálených kanálech, přes které se snažilo
  posílat platby. Přesnost byla dříve až 0,01500 BTC v 1BTC kanálech. Nová
  přesnost dosahuje ve stejně velikých kanálech kolem 0,00006 BTC. Díky
  tomu se může mírně snížit čas nalezení cesty pro platby, avšak testy
  naznačují, že rozdíl bude velmi malý.

- [LDK #2413][] přidává podporu pro zasílání plateb na [zaslepené cesty][topic
  rv routing] a umožňuje přijímat platby na cesty, jejichž poslední skok
  před odesílatelem je skrytý (zaslepený). [PR #2514][ldk #2514], též
  začleněné tento týden, poskytuje další podporu zaslepených cest.

- [LDK #2371][] přidává podporu správy plateb používajících [nabídky][topic
  offers]. Umožňuje klientským aplikacím použít nabídku k zaznamenání
  záměru provést platbu faktury, expirovat pokus o platbu, pokud odeslaná
  nabídka nevyústí v odeslanou fakturu, a nato použít existující kód v LDK
  k provedení platby faktury (včetně opakovaných pokusů v případě selhání).

{% include references.md %}
{% include linkers/issues.md v=2 issues="26152,28414,28448,28196,2743,2176,2413,2514,2371" %}
[LND v0.17.0-beta.rc4]: https://github.com/lightningnetwork/lnd/releases/tag/v0.17.0-beta.rc4
[ds brd]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-September/021959.html
[news252 bumpfee]: /cs/newsletters/2023/05/24/#bitcoin-core-27021
[news229 bumpfee]: /cs/newsletters/2022/12/07/#bitcoin-core-pr-review-club
[Core Lightning 23.08.1]: https://github.com/ElementsProject/lightning/releases/tag/v23.08.1
[B'SST]: https://github.com/dgpv/bsst
[news222 zerosync]: /en/newsletters/2022/10/19/#zerosync-project-launches
[zerosync demo]: https://zerosync.org/demo/
[zerosync code]: https://github.com/ZeroSync/header_chain
[joinmarket v0.9.10]: https://github.com/JoinMarket-Org/joinmarket-clientserver/releases/tag/v0.9.10
[bitbox blog]: https://bitbox.swiss/blog/bitbox-08-2023-marinelli-update/
[Machankura]: https://8333.mobi/
[machankura tweet]: https://twitter.com/machankura8333/status/1695827506794754104
[batching]: /en/payment-batching/
[SimLN]: https://github.com/bitcoin-dev-project/sim-ln
