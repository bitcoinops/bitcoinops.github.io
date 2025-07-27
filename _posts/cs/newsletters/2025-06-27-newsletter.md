---
title: 'Zpravodaj „Bitcoin Optech” č. 360'
permalink: /cs/newsletters/2025/06/27/
name: 2025-06-27-newsletter-cs
slug: 2025-06-27-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Zpravodaj tento týden shrnuje výzkum identifikace plných uzlů pomocí zpráv
P2P protokolu a žádá o zpětnou vazbu ke zvažovanému odstranění podpory
pro `H` v BIP32 cestách v BIP380 specifikaci deskriptorů. Též nechybí
naše pravidelné rubriky se souhrnem nejoblíbenějších otázek a odpovědí
z Bitcoin Stack Exchange, oznámeními nových vydání a popisem významných
změn v populárním bitcoinovém páteřním software.

## Novinky

- **Detekce uzlů pomocí zpráv `addr`:** Daniela Brozzoni
  zaslala do fóra Delving Bitcoin [příspěvek][brozzoni addr] o výzkumu,
  který provedla s vývojářem Naiyoma. Výzkum se týkal identifikace
  stejného uzlu napříč sítěmi na základě zasílaných zpráv `addr`.
  Uzly v rámci decentralizovaného gossip systému posílají zprávy
  `addr` svým spojením, aby je informovaly o dalších známých uzlech,
  čímž uzlům pomáhají se navzájem najít. Brozzoni a Naiyoma však byli
  schopni detekovat jednotlivé uzly díky drobnostem v jejich `addr`
  zprávách. To jim pomohlo identifikovat uzel provozovaný ve více
  různých sítích (jako IPv4 a [Tor][topic anonymity networks]).

  Výzkumníci navrhují dvě možná opatření: odstranit ze zpráv časová
  razítka, nebo je mírně náhodně upravit, aby nebyla příliš specifická.

- **Používá některý software v deskriptorech `H`?** Ava Chow zaslala do emailové
  skupiny Bitcoin-Dev [příspěvek][chow hard] s dotazem, zda nějaký software
  generuje deskriptory používající velké `H` k indikaci hardened derivace
  potomka dle [BIP32][topic bip32]. Pokud ne, bude možné upravit [BIP380][],
  specifikaci [deskriptorů výstupních skriptů][topic descriptors], aby povolovala
  pouze malé `h` a `'`. Chow poznamenává, že ačkoliv BIP32 velké `H` umožňuje,
  BIP380 dříve obsahovala test, který použití velkého `H` vylučoval. Bitcoin
  Core v současnosti velké `H` též neakceptuje.

## Vybrané otázky a odpovědi z Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] je jedním z prvních míst, kde hledají
přispěvatelé Optechu odpovědi na své otázky a kde – najdou-li volnou chvíli –
pomáhají zvědavým či zmateným uživatelům. V této měsíční rubrice nabízíme
některé z otázek a odpovědí, které obdržely vysoký počet hlasů.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Existuje způsob, jak uzlu zakázat spojení s Bitcoin Knots?]({{bse}}127456)
  Vojtěch Strnad poskytuje možnost blokování spojení na základě názvu
  klienta pomocí dvou RPC Bitcoin Core, avšak od podobného přístupu odrazuje
  a poukazuje na související [tiket][Bitcoin Core #30036] v projektu Bitcoin
  Core.

- [Co OP_CAT dělá s celými čísly?]({{bse}}127436)
  Pieter Wuille vysvětluje, že položky v zásobníku Bitcoin Scriptu neobsahují
  informace a datových typech. Různé opkódy interpretují bajty v zásobníku
  různými způsoby.

- [Asynchronní přeposílání bloků a přeposílání kompaktních bloků (BIP152)]({{bse}}127420)
  Uživatel bca-0353f40e ukazuje, jako Bitcoin Core nakládá s [kompaktními bloky][topic
  compact block relay] a odhaduje, jaký dopad mají chybějící transakce na propagaci
  bloků.

- [Proč není útočníkova odměna v sobecké těžbě úměrná jeho hashrate?]({{bse}}53030)
  Antoine Poinsot přidává reakci k této a [jiné]({{bse}}125682) starší otázce ohledně
  [sobecké těžby][topic selfish mining]. Poznamenává, že „úprava obtížnosti
  nebere v potaz zastaralé bloky, což znamená, že snižující se efektivní hashrate
  konkurence zvyšuje těžařovy výdělky (v dostatečně dlouhém časovém měřítku) stejně
  jako jeho vlastní“ (viz [zpravodaj č. 358][news358 selfish mining]).

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [Bitcoin Core 28.2][] je údržbové vydání předchozí série této
  převládající implementace plného uzlu. Obsahuj opravy několika chyb.

## Významné změny kódu a dokumentace

_Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo] a [repozitáři BINANA][binana repo]._

- [Bitcoin Core #31981][] přidává do rozhraní `Mining` (viz [zpravodaj
  č. 310][news310 ipc]) meziprocesové komunikace (IPC) metodu `checkBlock`,
  který provádí stejné kontroly jako RPC `getblocktemplate` v režimu
  `proposal`. Těžební pooly tím mohou použít [Stratum v2][topic pooled
  mining] pro validaci šablon bloků poskytnutých těžaři přes rychlejší
  IPC rozhraní, než je posílání po RPC až 4 MB dat serializovaných do JSON.
  Kontroly proof of work a kořene Merkleova stromu mohou být vypnuty.

- [Eclair #3109][] rozšiřuje podporu [informací o původci chyb][topic attributable
  failures] (attributable failures, viz [zpravodaj č. 356][news356 failures])
  na [trampolínové platby][topic trampoline payments]. Trampolínový uzel nově
  dešifruje a uloží část informací o původci chyby, která je určená pro něj,
  a připraví data pro další skok. Toto PR zatím neimplementuje samotné přeposílání
  dat o původci chyb dalším skokům v trampolínové cestě.

- [LND #9950][] přidává do RPC `DescribeGraph`, `GetNodeInfo` a `GetChanInfo`
  a jim odpovídajících `lncli` příkazů příznak `include_auth_proof`. Ten vrátí
  podpisy [oznámení kanálu][topic channel announcements], které mohou
  být použité jiným software k validaci podrobností o kanálech.

- [LDK #3868][] snižuje přesnost měření času pro držení [HTLC][topic htlc] pro
  [informace o původci chyb][topic attributable failures] (viz [zpravodaj č.
  349][news349 attributable]) z jednomilisekundových jednotek na stomilisekundové.
  Cílem je bránit detekci prováděním otisků. Změna byla provedena po nedávné
  aktualizaci návrhu [BOLTs #1044][].

- [LDK #3873][] navyšuje časovou prodlevu před zapomenutím krátkého identifikátoru
  kanálu (SCID) z 12 na 144 bloků poté, co je utracen zakládající výstup.
  Cílem je zlepšit propagaci [spliců][topic splicing]. Jedná se o dvojnásobek
  hodnoty v Eclair (viz [zpravodaj č. 359][news359 eclair]). PR dále přidává
  další změny ve výměně zpráv `splice_locked`.

- [Libsecp256k1 #1678][] přidává do CMake `secp256k1_objs`, které zveřejňuje všechny
  objektové soubory této knihovny. Díky tomu je mohou rodičovské projekty jako
  plánovaný [libbitcoinkernel][libbitcoinkernel project] v Bitcoin Core
  linkovat napřímo do svých vlastních statických knihoven. Jedná se o řešení
  chybějícího nativního mechanismu pro linkování statických knihoven v CMake,
  díky kterému nemusí jiné projekty poskytovat vlastní sestavení `libsecp256k1`.

- [BIPs #1803][] povoluje v gramatice [deskriptorů][topic descriptors] v [BIP380][]
  všechny běžně používané značky pro hardened potomky BIP32 derivační cesty.
  Dále [#1871][bips #1871], [#1867][bips #1867] a [#1866][bips #1866] upravují
  deskriptory [MuSig2][topic musig] v [BIP390][]: zpřísňují pravidla specifikování
  klíčů, povolují opakované veřejné klíče a explicitně zakazují vícenásobné derivace
  potomků.

{% include snippets/recap-ad.md when="2025-07-01 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="31981,3109,9950,3868,3873,1678,1803,1871,1867,1866,30036,1044,1270" %}
[bitcoin core 28.2]: https://bitcoincore.org/bin/bitcoin-core-28.2/
[brozzoni addr]: https://delvingbitcoin.org/t/fingerprinting-nodes-via-addr-requests/1786/
[chow hard]: https://mailing-list.bitcoindevs.xyz/bitcoindev/848d3d4b-94a5-4e7c-b178-62cf5015b65f@achow101.com/T/#u
[news358 selfish mining]: /cs/newsletters/2025/06/13/#vypocet-prahu-sobecke-tezby
[news310 ipc]: /cs/newsletters/2024/07/05/#bitcoin-core-30200
[news356 failures]: /cs/newsletters/2025/05/30/#eclair-3065
[news349 attributable]: /cs/newsletters/2025/04/11/#ldk-2256
[news359 eclair]: /cs/newsletters/2025/06/20/#eclair-3110
[libbitcoinkernel project]: https://github.com/bitcoin/bitcoin/issues/27587
