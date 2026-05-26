---
title: 'Zpravodaj „Bitcoin Optech” č. 397'
permalink: /cs/newsletters/2026/03/20/
name: 2026-03-20-newsletter-cs
slug: 2026-03-20-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Zpravodaj tento týden přináší pravidelné rubriky s popisem změn ve službách
a klientském software, oznámeními nových vydání a souhrnem nedávných
změn v populárním bitcoinovém páteřním software.

## Novinky

*V našich [zdrojích][sources] jsme tento týden nenašli žádné významné novinky.*

## Změny ve službách a klientech

*V této měsíční rubrice upozorňujeme na zajímavé aktualizace bitcoinových
peněženek a služeb.*

- **Cake Wallet přidává podporu pro Lightning:**
  Cake Wallet [ohlásila][cake ln post] podporu Lightning Network díky integraci
  Breez SDK a [Sparku][topic statechains]. Nechybí ani možnost používat Lightning
  adresy.

- **Vydán Sparrow 2.4.0 a 2.4.2:**
  Sparrow [2.4.0][sparrow 2.4.0] přidává podporu pro [PSBT][topic psbt] pole pro
  [tiché platby][topic silent payments] dle [BIP375][] a nástroj pro import
  [Codex32][topic codex32]. Sparrow [2.4.2][sparrow 2.4.2] přidává podporu
  pro [v3 transakce][topic v3 transaction relay].

- **Blockstream Jade přidává Lightning přes Liquid:**
  Blockstream [ohlásil][jade ln blog], že hardwarová Jade (pomocí aplikace Green
  5.2.0) umí nově používat [submarine swaps][topic submarine swaps],
  které převádějí lightningové platby na [Liquid][topic sidechains] Bitcoin
  (L-BTC). Klíče zůstávají offline.

- **Lightning Labs vydává nástroje pro agenty:**
  Lightning Labs [vydaly][ll agent tools] open source nástroj umožňující
  AI agentům používat Lightning bez lidských zásahů a bez API klíčů
  používajících [L402 protokol][blip 26].

- **Tether spouští MiningOS:**
  Tether [spustil][tether mos] MiningOS, open source operační systém pro
  správu provozu bitcoinové těžby. Software, licencovaný pod Apache 2.0,
  má modulární P2P architekturu a je nezávislý na hardware.

- **Síť FIBRE opět spuštěna:**
  Localhost Research [ohlásil][fibre blog] opakované spuštění FIBRE (Fast
  Internet Bitcoin Relay Engine) ukončeného v roce 2017. Nově
  je založen na Bitcoin Core v30 a monitoruje síť pomocí šesti veřejných
  uzlů rozmístěných po světě. FIBRE doplňuje [přeposílání kompaktních
  bloků][topic compact block relay] za účelem propagace bloků s nízkou latencí.

- **Vydáno TUI pro Bitcoin Core:**
  [Bitcoin-tui][btctui tweet], konzolová aplikace pro přístup k Bitcoin Core,
  se připojuje přes JSON-RPC a zobrazuje data o blockchainu a síti, monitoruje
  mempool, hledá a zveřejňuje transakce a spravuje peer spojení.

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [BTCPay Server 2.3.6][] je menším vydáním tohoto platebního procesoru
  s možností vlastního hostování. Do lišty pro hledání peněženek přidává
  filtrování štítků, začleňuje data o platební metodě do API faktur
  a umožňuje rozšířením definovat vlastní pravidla přístupu. Též opravuje
  několik chyb.

## Významné změny kódu a dokumentace

_Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo] a [repozitáři BINANA][binana repo]._

- [Bitcoin Core #31560][] rozšiřuje RPC volání `dumptxoutset` (viz
  [zpravodaj č. 72][news72 dump], _angl._). Nově umožňuje, aby byl
  snapshot množiny UTXO zapsán do pojmenované roury. Díky tomu
  může být výstup streamován přímo do jiného procesu, není tedy
  třeba ukládat kompletní data na disk. Tato funkce dobře funguje
  s nástrojem `utxo_to_sqlite.py` (viz [zpravodaj č. 342][news342 sqlite]),
  který ukládá množinu UTXO do SQLite databáze.

- [Bitcoin Core #31774][] chrání šifrovací (AES-256) klíče používané
  pro šifrování peněženek pomocí `secure_allocator`, aby nebyly při nedostatku
  paměti operačním systémem zapisovány do stránkovacího souboru.
  Též z paměti klíče bezpečně vymaže, nejsou-li již potřeba. Když uživatel
  šifruje nebo odemyká svou peněženku, zadá heslo, ze kterého se odvodí
  AES klíč, který následně šifruje a dešifruje soukromé klíče v peněžence.
  Dříve byla paměť pro tyto klíče vyhrazena standardním alokátorem,
  mohly tedy být zapsány na disk nebo přetrvat v paměti.

- [Core Lightning #8817][] opravuje několik problémů součinnosti s Eclairem
  během [splicingu][topic splicing]. Tyto problémy byly odhaleny během
  testování napříč implementacemi (viz též [zpravodaj č. 331][news331 interop],
  který informoval o počátcích tohoto testování). CLN nyní zpracovává
  zprávy `channel_ready`, které může Eclair během opakovaného iniciování
  splicingu poslat ještě před zahájením vyjednávání. Dále opravuje nakládání
  s RPC chybovými hlášeními, které mohlo způsobit pád, a přidává opakované
  posílání podpisů oznámení přes nové TLV `channel_reestablish`.

- [Eclair #3265][] a [LDK #4324][] nově odmítají [BOLT12 nabídky][topic
  offers], které mají hodnotu `offer_amount` nastavenou na nulu. Tyto změny
  jsou v souladu s aktualizacemi BOLT specifikace (viz [zpravodaj č. 396][news396
  amount]).

- [LDK #4427][] přidává podporu pro navyšování poplatků pomocí [RBF][topic rbf]
  během splicingu otevíracích transakcí, které ještě nebyly uzamčeny.
  Vyžaduje to opakované přistoupení k protokolu [chvíle ticha][topic
  channel commitment upgrades] (quiescence). Pokud se obě strany najednou
  pokusí o RBF, strana, kterou protokol označí za poraženou, může přispět
  jako akceptor. Pokud protistrana iniciuje RBF, jsou dřívější příspěvky
  automaticky znovu použity. To zabraňuje, aby byly během navyšování
  poplatku tiše odstraněny prostředky, kterými tato strana do splicingu
  přispěla. Viz též [zpravodaj č. 396][news396 splice], který o této
  funkcionalitě informoval.

- [LDK #4484][] navyšuje u [anchor][topic anchor outputs] kanálů
  s [HTLC][topic htlc] s nulovými poplatky (včetně [0-conf kanálů][topic
  zero-conf channels]) maximální limit přijímaného [prachu][topic
  uneconomical outputs] kanálu na 10 000 satoshi. Implementuje tím
  doporučení z [BOLTs #1301][] (viz též [zpravodaj č. 395][news395 dust]).

- [BIPs #1974][] zveřejňuje [BIP446][] a [BIP448][] ve stavu „návrh.”
  [BIP446][] specifikuje `OP_TEMPLATEHASH`, nový [tapscriptový][topic
  tapscript] opkód, který do zásobníku přidá haš utrácené transakce
  (viz též [zpravodaj č. 365][news365 op], _angl._). [BIP448][] specifikuje
  Taproot-native (Re)bindable Transactions (taprootové transakce, jejichž
  podpisy mohou být svázány s novými platebními podmínkami).
  Specifikace používá `OP_TEMPLATEHASH` spolu s [OP_CHECKSIGFROMSTACK][topic
  op_checksigfromstack] pro určitý druh [kovenantů][topic covenants].

{% include snippets/recap-ad.md when="2026-03-24 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="31560,31774,8817,3265,4324,4427,4484,1974,1301" %}
[sources]: /en/internal/sources/
[cake ln post]: https://blog.cakewallet.com/our-lightning-journey/
[sparrow 2.4.0]: https://github.com/sparrowwallet/sparrow/releases/tag/2.4.0
[sparrow 2.4.2]: https://github.com/sparrowwallet/sparrow/releases/tag/2.4.2
[jade ln blog]: https://blog.blockstream.com/jade-lightning-payments-are-here/
[ll agent tools]: https://github.com/lightninglabs/lightning-agent-tools
[blip 26]: https://github.com/lightning/blips/pull/26
[x402 blog]: https://blog.cloudflare.com/x402/
[tether mos]: https://mos.tether.io/
[fibre blog]: https://lclhost.org/blog/fibre-resurrected/
[btctui tweet]: https://x.com/_jan__b/status/2031741548098896272
[BTCPay Server 2.3.6]: https://github.com/btcpayserver/btcpayserver/releases/tag/v2.3.6
[news72 dump]: /en/newsletters/2019/11/13/#bitcoin-core-16899
[news342 sqlite]: /cs/newsletters/2025/02/21/#bitcoin-core-27432
[news331 interop]: /cs/newsletters/2024/11/29/#core-lightning-7719
[news396 amount]: /cs/newsletters/2026/03/13/#bolts-1316
[news396 splice]: /cs/newsletters/2026/03/13/#ldk-4416
[news395 dust]: /cs/newsletters/2026/03/06/#bolts-1301
[news365 op]: /en/newsletters/2025/08/01/#taproot-native-op-templatehash-proposal
