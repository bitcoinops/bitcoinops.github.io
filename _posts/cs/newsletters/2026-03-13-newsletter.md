---
title: 'Zpravodaj „Bitcoin Optech” č. 396'
permalink: /cs/newsletters/2026/03/13/
name: 2026-03-13-newsletter-cs
slug: 2026-03-13-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Zpravodaj tento týden popisuje hašovací funkci s odolností vůči kolizím používající
bitcoinový Script a shrnuje pokračující diskuzi o analýze provozu Lightning
Network. Též nechybí naše pravidelné rubriky s oznámeními nových vydání
a popisem významných změn v populárním bitcoinovém páteřním software.

## Novinky

- **Hašovací funkce s odolností vůči kolizím pro bitcoinový Script**: Robin Linus
  zaslal do fóra Delving Bitcoin [příspěvek][bino del] o Binohashi, nové hašovací funkci
  pro bitcoin s odolností vůči kolizím. V [článku][bino paper] Linus uvádí,
  že Binohash umožňuje omezenou introspekci transakcí bez nutnosti změn konsenzu.
  Tím by mohly protokoly jako [BitVM][topic acc] disponovat – podobně
  jako [kovenanty][topic covenants] – introspekcí řetězce bez potřeby důvěřovat orákulím.

  Navrhovaná hašovací funkce nepřímo odvozuje otisk po dvou krocích:

  - Fixace polí transakce: Pole transakce jsou svázána s několika výpočetními problémy
    nad podpisy, které musí plátce vyřešit. Každý problém vyžaduje `W1` bitů práce,
    čímž jsou neautorizované změny výpočetně nákladné.

  - Odvození haše: haš se vypočítá využitím `FindAndDelete` v zastaralém `OP_CHECKMULTISIG`.
    Vytvoří se zásobník noncí s `n` podpisy. Plátce připraví podmnožinu s `t` podpisy,
    které jsou ze zásobníku pomocí `FindAndDelete` vyňaty, a poté spočítá sighash
    zbývajících podpisů. Proces se opakuje, dokud nenalezne podpis řešící výpočetní problém.
    Výsledný otisk (Binohash) je složen z `t` indexů nalezené podmnožiny.

  Výsledný otisk má tři vlastnosti: může být extrahován a ověřen v bitcoinovém skriptu,
  poskytuje odolnost vůči kolizím kolem 84 bitů a může být podepsán
  [Lamportovým podpisem][lamport wiki] pro použití v BitVM. Dohromady tyto
  vlastnosti znamenají, že vývojáři mohou již dnes konstruovat protokoly používající
  onchain data z transakcí za použití pouze současně dostupných skriptových primitiv.

- **Aktualizace nástroje analyzování provozu Gossip Observer**: V listopadu
  Jonathan Harvey-Buschel [ohlásil][news 381 gossip observer] Gossip Observer,
  nástroj pro sběr dat o provozu lightningového gossip protokolu a výpočet metrik.
  Snahou je posoudit nahrazení současného systému zaplavování sítě zprávami novým
  protokolem založeným na synchronizaci množin (set reconciliation).

  Od té doby se do [vlákna][gossip observer delving] připojil Rusty Russell a jiní,
  aby diskutovali o výběru nejlepšího způsobu posílání skečů (sketch; kompaktní datová
  struktura reprezentující pravděpodobnostní zastoupení prvků v množině a umožňující
  efektivní porovnávání). Jedním návrhem bylo přeskočit obousměrnou zprávu `GETDATA` a
  použít číslo bloku. Tím se odstraní zbytečná výměna požadavku a odpovědi v případech,
  kdy příjemce již může odvodit kontext relevantního bloku.

  V návaznosti [aktualizoval][gossip observer github] Harvey-Buschel svou verzi
  Gossip Observeru, kterou provozuje a která sbírá data. [Podělil][gossip observer
  update] se o analýzu průměrných každodenních zpráv a popsal model detekovaných
  komunit a zpoždění propagace.

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [BDK wallet 3.0.0-rc.1][] je kandidátem na vydání nové hlavní verze této
  knihovny pro budování peněženek. Mezi hlavní změny patří uzamykání UTXO
  napříč restarty aplikace, strukturované události vyvolané při změnách
  řetězce a používání `NetworkKind` napříč API pro rozlišování mezi mainnetem
  a testovacími sítěmi. Vydání dále přidává podporu pro exportní formát
  Caravan (viz [zpravodaj č. 77][news77 caravan], _angl._) a migrační nástroj
  pro SQLite databáze z verzí před 1.0.

## Významné změny kódu a dokumentace

_Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo] a [repozitáři BINANA][binana repo]._

- [Bitcoin Core #26988][] nově vrací na CLI příkaz `-addrinfo` (viz
  [zpravodaj č. 146][news146 addrinfo], _angl._) kompletní seznam známých
  adres. Dříve vracel jen podmnožinu na základě kvality a aktuálnosti.
  Interně se namísto RPC příkazu `getnodeaddresses` (viz [zpravodaj
  č. 14][news14 rpc], _angl._) používá `getaddrmaninfo` (viz též
  [zpravodaj č. 275][news275 addrmaninfo]). Počet vrácených
  záznamů se nyní rovná počtu adres, mezi kterými se hledá odchozí spojení.

- [Bitcoin Core #34692][] navyšuje na 64bitových systémech s více než
  4 GiB paměti výchozí hodnotu `dbcache` z 450 MiB na 1 GiB. V ostatních
  situacích zůstává na 450 MiB. Změna se týká pouze `bitcoind`, knihovna
  jádra ponechává výchozí nastavení na 450 MiB.

- [LDK #4304][] rozšiřuje přeposílání [HTLC][topic htlc] o podporu
  několika příchozích a odchozích HTLC v rámci jednoho přeposlání.
  Staví tím základy pro [trampolínové][topic trampoline payments] trasování.
  Na rozdíl od běžného přeposílání může trampolínový uzel představovat
  [MPP][topic multipath payments] bod (pro platby s více cestami) pro oba směry:
  shromažďuje příchozí části, hledá trasy pro následující skoky a rozděluje
  částku mezi více odchozích HTLC. Nová varianta `HTLCSource::TrampolineForward`
  sleduje všechna HTLC pro trampolínová přeposlání. Nárokování i chyby
  jsou řádně řešené a monitor kanálů správně při restartování rekonstruuje stav.

- [LDK #4416][] umožňuje akceptorovi finančně přispět, pokud se obě strany
  pokoušejí iniciovat [splice][topic splicing] ve stejný okamžik. Tím
  v podstatě přidává podporu pro [oboustranné financování][topic dual funding]
  během splicingu. Pokud obě strany zahájí splice, [protokol chvíle ticha][topic channel
  commitment upgrades] (quiescence) vybere jednu z nich jako iniciátora.
  Dříve mohl přidat prostředky pouze iniciátor a akceptor musel čekat
  na další splice, aby mohl také přispět. Jelikož byl akceptor připraven
  jednat jako iniciátor, jsou poplatky upraveny z iniciátorovy
  sazby (která pokrývá běžná pole v transakci) na akceptorovu sazbu.
  API `splice_channel` též nově obdrží parametr `max_feerate`.

- [LND #10089][] přidává podporu pro přeposílání [onion zpráv][topic onion messages],
  jejíž základy byly představeny ve [zpravodaji č. 377][news377 onion] (_angl._).
  Přináší zprávu `OnionMessagePayload` a každému peer spojení přiřazuje
  aktora, který zabezpečuje dešifrování a přeposílání. Funkcionalitu
  lze deaktivovat příznakem `--protocol.no-onion-messages`. Jedná se
  o součást práce na podpoře [BOLT12 nabídek][topic offers].

- [Libsecp256k1 #1777][] přidává nové API
  `secp256k1_context_set_sha256_compression()`, které aplikacím umožní
  za běhu dodat vlastní kompresní funkci pro SHA256. Díky tomu je možné
  v prostředích, jako je Bitcoin Core, směrovat hašování na hardware
  bez nutnosti překompilovat knihovnu.

- [BIPs #2047][] zveřejňuje [BIP392][], který definuje formát
  [deskriptorů][topic descriptors] pro peněženky podporující
  [tiché platby][topic silent payments]. Nový deskriptor `sp()`
  předepisuje peněženkám, jak skenovat a utrácet výstupy tichých plateb.
  Ty specifikuje [BIP352][] jako [P2TR][topic taproot] výstupy. Verze
  s jedním argumentem přebírá jediný [bech32m][topic bech32] klíč:
  `spscan` obsahující soukromý klíč pro skenování a veřejný klíč pro utrácení
  (nelze s ním utrácet) či `spspend` kódující soukromé klíče pro skenování
  i utrácení. Formát se dvěma argumenty `sp(KEY,KEY)` obsahuje jako první
  výraz soukromý klíč pro skenování a další oddělený klíč pro utrácení:
  buď veřejný klíč, nebo soukromý s podporou [MuSig2][topic musig] agregace
  dle [BIP390][]. Viz [zpravodaj č. 387][news387 sp], který popisoval
  úvodní diskuzi v emailové skupině.

- [BOLTs #1316][] objasňuje, že pokud je v [BOLT12 nabídce][topic offers]
  přítomna volba `offer_amount`, musí být vyšší než nula. Na nabídku
  se nesmí odpovědět, pokud je částka nula. Byla též přidána testovací
  data pro nevalidní nabídky s nulovou částkou.

- [BOLTs #1312][] přidává testovací data [BOLT12][topic offers] nabídek
  s nevalidním [bech32][topic bech32] zarovnáním. Tím zdůrazňuje, že
  takové nabídky musí být dle [BIP173][] odmítnuté. Problém byl objeven
  během fuzz testování napříč lightningovými implementacemi, které odhalilo,
  že CLN a LDK nabídky s nevalidním zarovnáním akceptovaly, zatímco
  Eclair a Lightning-KMP je správně odmítaly. [Zpravodaj č. 390][news390
  bech32] popisuje opravu v LDK.

{% include snippets/recap-ad.md when="2026-03-17 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="26988,34692,4304,4416,10089,1777,2047,1316,1312" %}

[bino del]: https://delvingbitcoin.org/t/binohash-transaction-introspection-without-softforks/2288
[bino paper]: https://robinlinus.com/binohash.pdf
[lamport wiki]: https://en.wikipedia.org/wiki/Lamport_signature
[news146 addrinfo]: /en/newsletters/2021/04/28/#bitcoin-core-21595
[news275 addrmaninfo]: /cs/newsletters/2023/11/01/#bitcoin-core-28565
[news14 rpc]: /en/newsletters/2018/09/25/#bitcoin-core-13152
[news377 onion]: /en/newsletters/2025/10/24/#lnd-9868
[news387 sp]: /cs/newsletters/2026/01/09/#navrh-bipu-pro-deskriptory-tichych-plateb
[news390 bech32]: /cs/newsletters/2026/01/30/#ldk-4349
[news77 caravan]: /en/newsletters/2019/12/18/#unchained-capital-open-sources-caravan-a-multisig-coordinator
[BDK wallet 3.0.0-rc.1]: https://github.com/bitcoindevkit/bdk_wallet/releases/tag/v3.0.0-rc.1
[gossip observer delving]: https://delvingbitcoin.org/t/gossip-observer-new-project-to-monitor-the-lightning-p2p-network/2105
[gossip observer update]: https://delvingbitcoin.org/t/gossip-observer-new-project-to-monitor-the-lightning-p2p-network/2105/23
[gossip observer github]: https://github.com/jharveyb/gossip_observer
[news 381 gossip observer]: /en/newsletters/2025/11/21/#ln-gossip-traffic-analysis-tool-announced
