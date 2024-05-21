---
title: 'Zpravodaj „Bitcoin Optech” č. 298'
permalink: /cs/newsletters/2024/04/17/
name: 2024-04-17-newsletter-cs
slug: 2024-04-17-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Zpravodaj tento týden shrnuje analýzu chování uzlu s cluster mempoolem, kterému
byly předány všechny transakce nalezené v síti během roku 2023. Též nechybí
naše pravidelné rubriky s popisem nedávných změn v klientech a službách,
oznámeními o nových vydáních a souhrnem významných změn v populárním bitcoinovém
páteřním software.

## Novinky

- **Co by nastalo, kdyby byl cluster mempool nasazen před rokem?**
  Suhas Daftuar ve svém [příspěvku][daftuar cluster] ve fóru Delving Bitcoin
  uvedl, že uložil všechny transakce, které jeho uzel obdržel během roku 2023,
  a prohnal je vývojovou verzí Bitcoin Core s aktivovaným [cluster
  mempoolem][topic cluster mempool], aby kvantifikoval rozdíly mezi stávající
  a vývojovou verzí. Mezi jeho nálezy patří:

  - *Uzel s cluster mempoolem přijal o 0,01 % více transakcí:* „V roce 2023
	bylo v aktuální verzi kvůli limitům předků a potomků odmítnuto přes
	46 000 transakcí. […] Jen kolem 14 000 transakcí bylo odmítnuto kvůli
	limitům velikosti clusterů.“ Kolem 10 000 transakcí původně odmítnutých
	cluster	mempoolem (70 % ze 14 000) by bylo později přijato, pokud by
	transakce byly po potvrzení předků znovu zveřejněny. Toto je očekávané
	chování.

  - *Rozdíly v RBF jsou zanedbatelné:* „Pravidla RBF vynucovaná oběma simulacemi
	nejsou totožná, avšak ukázalo se, že má tento rozdíl na počet přijetí zanedbatelný
	vliv.” Níže uvádíme více podrobností.

  - *Cluster mempool byl pro těžaře stejně dobrý jako původní výběr transakcí:*
	Daftuar poznamenal, že v současnosti nakonec skončí téměř každá transakce
	v nějakém bloku, aktuální výběr transakcí v Bitcoin Core i výběr s cluster
	mempoolem by tedy obdržely na poplatcích stejnou částku. Avšak v analýze,
	o které se Daftuar domnívá, že výsledky nadhodnocuje, obdržel cluster mempool
	více poplatků v 73 % případů. Původní výběr transakcí byl lepší v 8 % případů.
	Daftuar uvedl, že „i když není jasné, zda je na základě aktivity z roku 2023 cluster
	mempool materiálně lepší než současná verze, vidím jako nepravděpodobné,
	že by byl cluster mempool materiálně horší.”

  Daftuar též uvažoval nad dopadem cluster mempoolu na nahrazování transakcí
  poplatkem ([RBF][topic rbf]). Na začátku podrobně shrnuje rozdíl mezi současným
  chováním Bitcoin Core a fungováním s cluster mempoolem (zvýrazňování
  i odkazy jsou původní):

  > Centrálním bodem RBF pravidel cluster mempoolu je, zda by se po uskutečněném
  > nahrazení [poplatkový diagram mempoolu zlepšil][feerate diagram]. Současná
  > RBF pravidla v Bitcoin Core jsou zhruba popsána v BIP125 a [zdokumentována
  > zde][rbf doc].
  >
  > Na rozdíl od BIP125 se navrhovaná RBF pravidla [cluster mempoolu] soustředí
  > na **výsledek** nahrazení. Teoreticky může být transakce lepší, než je
  > v praxi: možná „by měla“ být akceptována na základě teoretického porozumění
  > toho, co je dobré pro mempool, ale pokud by byl z jakéhokoliv důvodu výsledný
  > poplatkový diagram horší (třeba kvůli neoptimálnímu algoritmu linearizace),
  > nahrazení odmítneme.

  Též zde znovu uvedeme závěr jedné sekce, o které se domníváme,
  že byla dobře podložená daty a analýzou, kterou poskytl:

  > Co se týče RBF, celkově byly rozdíly mezi cluster mempoolem a stávajícími
  > pravidly minimální. Liší se hlavně v bodech, kde navrhovaná nová pravidla RBF
  > chrání mempool před nahrazeními, která nejsou v souladu s ekonomickými záměry
  > (to je dobrá změna). Je ale důležité vědět, že by teoreticky mohlo dojít
  > k odmítnutí nahrazení v případech, kdy by bylo v ideálním světě [nyní] přijato,
  > protože někdy může zjevně dobré nahrazení vést k neoptimálnímu chování, které
  > dříve (dle pravidel BIP125) nebylo detekováno, ale s novými pravidly by detekováno
  > bylo a nahrazení by bylo zabráněno.

  V době psaní zpravodaje neobdržel příspěvek žádné reakce.

## Změny ve službách a klientech

*V této měsíční rubrice upozorňujeme na zajímavé aktualizace bitcoinových
peněženek a služeb.*

- **Ohlášena serverová verze Phoenix:**
  Phoenix Wallet ohlásila zjednodušený Lightning uzel bez grafického rozhraní
  [phoenixd][phoenixd github], který se soustředí na odesílání a příjem plateb.
  Phoenixd cílí na vývojáře, je založen na existujícím software Phoenix Wallet
  a automatizuje správu kanálů, spojení a likvidity.

- **Mercury Layer přidává Lightning swapování:**
  [Statechain][topic statechains] Mercury Layer umí díky [pozdrženým fakturám][topic
  hold invoices] („hold invoices”) swapovat mince statechainu za lightningové
  platby.

- **Vydána referenční implementace Stratum V2 v1.0.0:**
  [Vydání v1.0.0][sri blog] „je výsledkem vylepšení specifikace Stratum V2, které
  vzešlo ze spolupráce v rámci pracovní skupiny a důsledného testování.“

- **Aktualizace Teleport Transactions:**
  Byl [ohlášen][tt tweet] fork [původního repozitáře Teleport Transactions][news192 tt]
  obsahující několik aktualizací a vylepšení.

- **Vydán Bitcoin Keeper v1.2.1:**
  [Vydání v1.2.1][bitcoin keeper v.1.2.1] přidává podporu pro [taprootové][topic
  taproot] peněženky.

- **Software správy štítků dle BIP329:**
  Vydání [Labelbase][labelbase blog] verze 2 obsahuje mimo jiné možnost vlastního hostování a
  importu a exportu dle [BIP329][].

- **Spuštěn správce klíčů Sigbash:**
  Podpisová služba [Sigbash][] umožňuje uživatelům zakoupit xpub, který může
  být použit v konfiguracích s vícenásobnými podpisy. Služba podepíše
  [PSBT][topic psbt] pouze, pokud nastane nějaká uživatelem zvolená podmínka
  (hashrate, cena bitcoinu, zůstatek na adrese, uplynutí lhůty).

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [Bitcoin Core 27.0][] je vydání příští hlavní verze této převládající implementace
  plného uzlu. Tato verze zastarává libbitcoinconsensus (viz zpravodaje
  [č. 288][news288 libconsensus] a [č. 297][news297 libconsensus]), ve výchozím
  nastavení aktivuje [šifrovaný P2P přenos verze 2][topic v2 p2p transport]
  (viz [zpravodaj č. 288][news288 v2 p2p]), umožňuje volitelné používání
  pravidel transakcí do potvrzení topologicky omezených ([TRUC][topic v3
  transaction relay], „topologically restricted until confirmation,” též nazývané
  _přeposílání verze 3_) na testovacích sítích (viz [zpravodaj č. 289][news289 truc])
  a přidává novou strategii [výběru mincí][topic coin selection] použitelnou
  v období vysokých poplatků (viz [zpravodaj č. 290][news290 coingrinder]).
  [Poznámky k vydání][bcc27 rn] obsahují úplný seznam významných změn.

- [BTCPay Server 1.13.1][] je nejnovějším vydáním tohoto platebního procesoru
  nabízející vlastní hostování. Od naší poslední zmínky o aktualizaci
  BTCPay Serveru ve [zpravodaji č. 262][news262 btcpay] byly [rozšířeny][btcpay
  server #5421] webhooks, byla přidána podpora pro import multisig peněženek dle
  [BIP129][] (viz [zpravodaj č. 281][news281 bip129]), vylepšena byla
  flexibilita pluginů, započala migrace podpory všech altcoinů do pluginů
  a byla přidána podpora pro [PSBT][topic psbt] kódované pomocí BBQr
  (viz [zpravodaj č. 295][news295 bbqr]). Vydání obsahuje i další nové
  funkce a opravy chyb.

- [LDK 0.0.122][] je nejnovějším vydáním této knihovny pro budování
  aplikací s LN. Následuje po vydání [0.0.121][ldk 0.0.121], které opravilo
  zranitelnost způsobující odepření služby. Nové vydání též opravuje
  několik chyb.

## Významné změny kódu a dokumentace

_Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Bitcoin Inquisition][bitcoin inquisition repo] a [repozitáři BINANA][binana
repo]._

- [LDK #2704][] přináší významnou aktualizaci a rozšíření dokumentace `ChannelManager`.
  Tato třída je „konečným automatem stavu kanálu a logikou správy plateb; zprostředkovává
  posílání, přeposílání a příjem plateb lightningovými kanály.”

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="2704,5421" %}
[Bitcoin Core 27.0]: https://bitcoincore.org/bin/bitcoin-core-27.0/
[feerate diagram]: https://delvingbitcoin.org/t/mempool-incentive-compatibility/553/1
[rbf doc]: https://github.com/bitcoin/bitcoin/blob/0de63b8b46eff5cda85b4950062703324ba65a80/doc/policy/mempool-replacements.md
[daftuar cluster]: https://delvingbitcoin.org/t/research-into-the-effects-of-a-cluster-size-limited-mempool-in-2023/794
[bcc27 rn]: https://github.com/bitcoin/bitcoin/blob/c7567d9223a927a88173ff04eeb4f54a5c02b43d/doc/release-notes/release-notes-27.0.md
[news288 libconsensus]: /cs/newsletters/2024/02/07/#bitcoin-core-29189
[news297 libconsensus]: /cs/newsletters/2024/04/10/#bitcoin-core-29648
[news288 v2 p2p]: /cs/newsletters/2024/02/07/#bitcoin-core-29347
[news289 truc]: /cs/newsletters/2024/02/14/#bitcoin-core-28948
[news290 coingrinder]: /cs/newsletters/2024/02/21/#bitcoin-core-27877
[news281 bip129]: /cs/newsletters/2023/12/13/#btcpay-server-5389
[news295 bbqr]: /cs/newsletters/2024/03/27/#btcpay-server-5852
[news262 btcpay]: /cs/newsletters/2023/08/02/#btcpay-server-1-11-1
[ldk 0.0.122]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.0.122
[ldk 0.0.121]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.0.121
[btcpay server 1.13.1]: https://github.com/btcpayserver/btcpayserver/releases/tag/v1.13.1
[phoenixd github]: https://github.com/ACINQ/phoenixd
[sri blog]: https://stratumprotocol.org/blog/sri-1-0-0/
[news192 tt]: /en/newsletters/2022/03/23/#coinswap-implementation-teleport-transactions-announced
[tt tweet]: https://twitter.com/RajarshiMaitra/status/1768623072280809841
[bitcoin keeper v.1.2.1]: https://github.com/bithyve/bitcoin-keeper/releases/tag/v1.2.1
[labelbase blog]: https://labelbase.space/ann-v2/
[Sigbash]: https://sigbash.com/
