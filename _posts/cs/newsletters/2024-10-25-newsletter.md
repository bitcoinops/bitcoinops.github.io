---
title: 'Zpravodaj „Bitcoin Optech” č. 326'
permalink: /cs/newsletters/2024/10/25/
name: 2024-10-25-newsletter-cs
slug: 2024-10-25-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Zpravodaj tento týden shrnuje aktualizaci návrhu nových zpráv oznamování LN
kanálů a popisuje BIP pro posílání tichých plateb s PSBT. Též nechybí naše
pravidelné rubriky s oblíbenými otázkami a odpověďmi z Bitcoin Stack Exchange,
oznámeními nových vydání a popisem významných změn v populárním bitcoinovém
páteřním software.

## Novinky

- **Aktualizace návrhu oznamování kanálů verze 1.75:** Elle
  Mouton zaslala do fóra Delving Bitcoin [příspěvek][mouton chanann]
  s popisem několika změn navrhovaných pro nový protokol [oznamování
  kanálů][topic channel announcements], který přinese podporu [jednoduchých
  taprootových kanálů][topic simple taproot channels]. Nejvýraznější
  plánovanou změnou je umožnit zprávě také oznámit současný druh P2WSH
  kanálů. To později uzlům umožní „začít vypínat starý protokol […],
  až bude většina sítě upgradována.”

  Dalším, též nedávno diskutovaným (viz [zpravodaj č. 325][news325
  chanann]), volitelným doplňkem do oznámení je SPV doklad, který umožní
  klientovi, jež má blockchain s největší provedenou prací, ověřit, že
  zakládající transakce kanálu byla začleněna do některého bloku.
  V současnosti musí lehké klienty pro provedení stejné úrovně ověření
  oznámení kanálu stáhnout kompletní blok.

  Příspěvek Mouton též krátce diskutuje umožnění oznamování existujících
  jednoduchých taprootových kanálů. Kvůli v současnosti chybějící
  podpoře oznámení jiných než P2WSH kanálů jsou všechny stávající taprootové
  kanály [neoznámené][topic unannounced channels]. V budoucnosti by mohla
  být k návrhu přidána možnost oznámit svému spojení, že chce uzel převést
  neoznámený kanál na veřejný.

- **Návrh BIPu na posílání tichých plateb s PSBT:** Andrew Toth
  zaslal do emailové skupiny Bitcoin-Dev [příspěvek][toth sp-psbt] s návrhem
  BIPu, který by peněženkám a podpisovým zařízením umožnil pomocí [PSBT][topic
  psbt] koordinovat tvorbu [tiché platby][topic silent payments]. Jedná se
  o pokračování předchozí diskuze o dřívější iteraci tohoto návrhu, viz
  zpravodaje [č. 304][news304 sp] a [č. 308][news308 sp]. Jak bylo v těchto
  zpravodajích zmíněno, zvláštním požadavkem tichých plateb oproti většině
  ostatních transakcí koordinovaných pomocí PSBT je, že jakákoliv změna
  vstupů transakce, která ještě není kompletně podepsaná, vyžaduje přepočet
  výstupů.

  Návrh pokrývá pouze očekávanou nejběžnější situaci, ve které má podepisující
  přístup k soukromým klíčům všech vstupů transakce. Případy s více
  podepisujícími, říká Toth, „budou specifikovány v následujícím BIPu.”

## Vybrané otázky a odpovědi z Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] je jedním z prvních míst, kde hledají
přispěvatelé Optechu odpovědi na své otázky a kde – najdou-li volnou chvíli –
pomáhají zvědavým či zmateným uživatelům. V této měsíční rubrice nabízíme
některé z otázek a odpovědí, které obdržely vysoký počet hlasů.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Duplikované bloky v souborech blk*.dat?]({{bse}}124368)
  Pieter Wuille vysvětluje, že kromě aktuálně nejlepšího řetězce obsahují soubory
  také staré nepoužité bloky nebo duplikovaná data.

- [Jak se rozhodlo o struktuře pay-to-anchor?]({{bse}}124383)
  Antoine Poinsot popisuje strukturu [pay-to-anchor (P2A)][topic ephemeral
  anchors] výstupů, které byly představené v rámci [změn pravidel][bcc28 guide] v
  Bitcoin Core 28.0. Jako dvoubajtový witnessový program byla zvolena
  čitelná (v [bech32m][topic bech32] kódování) adresa `bc1pfeessrawgf`.

- [Jaké výhody mají falešné pakety v BIP324?]({{bse}}124301)
  Pieter Wuille nastiňuje návrhová rozhodnutí kolem [začlenění falešných
  paketů][bip324 decoy packets] do specifikace [BIP324][]. Tyto volitelné
  falešné pakety mohou být použité k zastření provozu a tím k zabránění
  rozpoznávání během výměny klíčů, vyjednávání verzí a provozu aplikace.

- [Proč je limit opkódů 201?]({{bse}}124465)
  Vojtěch Strnad ukazuje na změny kódu, které Satoshi provedl během roku
  2010 se záměrem představit limit opkódů 200. Kvůli chybě implementace ale
  ve skutečnosti nastavil limit na 201.

- [Přepošle můj uzel transakci mající poplatek pod můj minimální přenosový poplatek?]({{bse}}124387)
  Murch poznamenává, že uzel přepošle pouze takové transakce, které přijme do svého
  vlastního mempoolu. I když může uživatel snížit hodnotu `minTxRelayFee` svého
  uzlu, aby umožnil přijetí do místního mempoolu, začlenění takové transakce do bloku
  by i nadále vyžadovalo, aby měl některý těžař podobné nastavení a aby klesl
  průměrný poplatek na tuto hodnotu.

- [Proč peněženka Bitcoin Core nepodporuje BIP69?]({{bse}}124382)
  Murch souhlasí, že univerzální implementace řazení výstupů a vstupů
  transakce dle specifikace [BIP69][] by napomohla zabránit [identifikaci
  otisků peněženek][ishaana fingerprinting], avšak poznamenává, že vzhledem
  k nepravděpodobnému všeobecnému nasazení je implementace BIP69 sama
  o sobě zranitelností napomáhající identifikaci.

- [Jak můžu s Bitcoin Core 28.0 aktivovat testnet4?]({{bse}}124443)
  Pieter Wuille zmiňuje dvě konfigurační volby, které aktivují [testnet4][topic testnet]
  dle [BIP94][]: `chain=testnet4` a `testnet4=1`.

- [Jaká jsou rizika zveřejnění transakce odhalující `scriptPubKey` s klíčem s nízkou entropií?]({{bse}}124296)
  Uživatel Quuxplusone odkazuje na nedávnou transakci spojenou se sérií bitcoinových
  [„hádanek”][puzzle bitcointalk] z roku 2015 s obrušováním klíčů, o které se [soudí][puzzle
  stackernews], že byla [nahrazena][topic rbf] botem hledajícím v mempoolu klíče s nízkou
  entropií.

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [Core Lightning 24.08.2][] je údržbovým vydáním této oblíbené implementace
  LN, které přináší „pár oprav pádů a obsahuje vylepšení pro zapamatování
  a aktualizaci nápovědy kanálů během plateb.”

## Významné změny kódu a dokumentace

_Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Bitcoin Inquisition][bitcoin inquisition repo] a [repozitáři BINANA][binana
repo]._

- [Eclair #2925][] přináší podporu pro používání [RBF][topic rbf] se
  [splicingovými][topic splicing] transakcemi pomocí příkazu `rbfsplice`. Ten mezi
  spojeními spustí výměnu zpráv `tx_init_rbf` a `tx_ack_rbf`, kterými si dohodnou
  nahrazení transakce. Tato možnost není aktivní pro [0-conf kanály][topic
  zero-conf channels], aby se předešlo případným krádežím prostředků. Série nepotvrzených
  splicingových transakcí jsou v 0-conf kanálech povolené. RBF je dále blokované
  pro transakce nákupu likvidity pomocí protokolu [inzerátů likvidity][topic liquidity
  advertisements], aby se předešlo okrajovým případům, při kterých by mohl
  prodávající přidat likviditu do kanálu, aniž by obdržel platbu.

- [LND #9172][] přidává do příkazů `lncli create` a `lncli createwatchonly`
  nový příznak `mac_root_key`, který umožní generovat deterministické macaroony
  (autentizační tokeny). Externí klíče LND uzlu tak mohou být nastavené ještě před
  jeho samotnou inicializací. To je obzvláště užitečné v kombinaci s používáním
  reverzního vzdáleného podepisování navrženého v [LND #8754][] (viz [zpravodaj
  č. 172][news172 remote], _angl._).

- [Rust Bitcoin #2960][] činí z AEAD [ChaCha20-Poly1305][rfc8439] samostatný balíček,
  který tak může být použit i jinými způsoby, než je [přenosový protokol v2][topic v2
  p2p transport] dle specifikace v [BIP324][], např. [payjoin v2][topic payjoin].
  Kód byl optimalizován pro SIMD instrukce, čímž se zvýší výkonnost (viz
  [zpravodaj č. 264][news264 chacha]).

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="2925,9172,2960,8754" %}
[mouton chanann]: https://delvingbitcoin.org/t/updates-to-the-gossip-1-75-proposal-post-ln-summit-meeting/1202/
[news325 chanann]: /cs/newsletters/2024/10/18/#upgrade-gossip-protokolu
[toth sp-psbt]: https://mailing-list.bitcoindevs.xyz/bitcoindev/cde77c84-b576-4d66-aa80-efaf4e50468fn@googlegroups.com/
[news304 sp]: /cs/newsletters/2024/05/24/#diskuze-o-psbt-pro-tiche-platby
[news308 sp]: /cs/newsletters/2024/06/21/#pokracuje-diskuze-o-psbt-pro-tiche-platby
[core lightning 24.08.2]: https://github.com/ElementsProject/lightning/releases/tag/v24.08.2
[news172 remote]: /en/newsletters/2021/10/27/#lnd-5689
[rfc8439]: https://datatracker.ietf.org/doc/html/rfc8439
[news264 chacha]: /cs/newsletters/2023/08/16/#bitcoin-core-28008
[bcc28 guide]: /cs/bitcoin-core-28-wallet-integration-guide/
[bip324 decoy packets]: https://github.com/bitcoin/bips/blob/22660ad3078ee9bd106e64d44662a59a1967c4bd/bip-0324.mediawiki?plain=1#L126
[ishaana fingerprinting]: https://ishaana.com/blog/wallet_fingerprinting/
[puzzle bitcointalk]: https://bitcointalk.org/index.php?topic=1306983.0
[puzzle stackernews]: https://stacker.news/items/683489
