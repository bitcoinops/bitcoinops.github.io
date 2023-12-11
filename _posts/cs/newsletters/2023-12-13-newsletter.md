---
title: 'Zpravodaj „Bitcoin Optech” č. 281'
permalink: /cs/newsletters/2023/12/13/
name: 2023-12-13-newsletter-cs
slug: 2023-12-13-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Tento týden přinášíme souhrn diskuze o záškodnických inzerátech likvidity
a připojujeme naše pravidelné rubriky s popisem změn ve službách a klientském
software, souhrnem oblíbených otázek a odpovědí z Bitcoin Stack Exchange,
oznámeními o nových softwarových vydáních a přehledem nedávných změn
v populárním bitcoinovém páteřním software.

## Novinky

- **Diskuze o záškodnických inzerátech likvidity:** Bastien Teinturier
  zaslal do emailové skupiny Lightning-Dev [příspěvek][teinturier liqad]
  s popisem možného problému s časovými zámky [kanálů s oboustranným
  vkladem][topic dual funding] („dual-funded channels”) vytvořených z [inzerátů
  likvidity][topic liquidity advertisements] („liquidity ads”). Problém byl již
  dříve zmíněn v [rekapitulaci č. 279][recap279 liqad]. Příklad: Alice inzeruje,
  že je za poplatek ochotna poskytnout svých 10 000 satoshi nějakému kanálu na
  28 dní. Tento 28denní časový zámek zaručuje, že Alice nebude moci po obdržení
  platby jen tak zavřít kanál a použít své prostředky k jiným účelům.

  Dále v tomto příkladu Bob otevře kanál s dodatečným přispěním svých prostředků
  ve výši 100 000 000 satoshi (1 BTC). Tímto kanálem potom pošle téměř všechny své
  prostředky. Na Alicině straně však nyní není 10 000 satoshi, za které obdržela
  poplatek, ale téměř 10 000× více. Má-li Bob zlé úmysly, nedovolí Alici až do
  vypršení 28denního časového zámku její prostředky použít.

  Opatření navržené Teinturierem a diskutované spolu s ostatními spočívá v
  aplikaci časového zámku pouze na příspěvek pocházející z likvidity (čili
  v našem případě 10 000 satoshi). To navyšuje složitost a neefektivitu,
  ale může to problém vyřešit. Jiným Teinturierovým návrhem bylo jednoduše
  časový zámek zavrhnout (nebo ho učinit volitelným) a nechat na příjemci
  likvidity riziko, že poskytovatel může krátce po obdržení poplatku
  za likviditu kanál zavřít. Pokud by v typickém případě kanály otevřené pomocí
  inzerátů likvidity generovaly významný příjem na poplatcích, bylo by v zájmu
  provozovatelů je nechat otevřené.

## Změny ve službách a klientech

*V této měsíční rubrice upozorňujeme na zajímavé aktualizace bitcoinových
peněženek a služeb.*

- **Spuštěn těžební pool se Stratum v2:**
  [DEMAND][demand website] je těžební pool postavený na [referenční implementaci
  protokolu Stratum v2][news247 sri]. Zpočátku povoluje sólo těžbu, těžba v poolu je plánována
  do budoucna.

- **Oznámen simulační nástroj bitcoinové sítě warnet:**
  Software [warnet][warnet github] umožňuje specifikovat topologie uzlů, spouštět
  nad sítí [naskriptované scénáře][warnet scenarios], [monitorovat][warnet monitoring]
  a analyzovat chování.

- **Vydán klient Payjoinu pro Bitcoin Core:**
  Rustový projekt [payjoin-cli][] přidává pomocí konzolového nástroje [payjoin][topic payjoin]
  do Bitcoin Core možnost odesílání a přijímání payjoinu.

- **Žádost o poskytnutí času přijetí bloků:**
  Přispěvatel do repozitáře projektu [Bitcoin Block Arrival Time Dataset][block arrival github]
  [vyzývá][b10c tweet] provozovatele uzlů o poskytnutí časových razítek přijetí
  bloků svými uzly. Pro sběr dat o starých blocích („stale blocks”) existuje
  podobný [repozitář][stale block github].

- **Envoy 1.4 released:**
  [Vydádní 1.4][envoy v1.4.0] bitcoinové peněženky Envoy přidává mimo jiné
  [výběr mincí][topic coin selection] a [štítkování peněženky][topic wallet labels]
  (podpora pro [BIP329][] přijde brzy).

- **Ohlášeno kódovací schéma BBQr:**
  [Schéma][bbqr github] umí efektivně kódovat větší soubory, například [PSBT][topic
  psbt], do animované série QR kódů pro používání peněženkami nemajícími připojení k
  počítači.

- **Vydán Zeus v0.8.0:**
  Vydání [v0.8.0][zeus v0.8.0] obsahuje mimo jiné vestavěný LND uzel, dodatečnou podporu pro
  [zero conf kanály][topic zero-conf channels] a podporu pro jednoduché taprootové kanály.

## Vybrané otázky a odpovědi z Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] je jedním z prvních míst, kde hledají
přispěvatelé Optechu odpovědi na své otázky a kde – najdou-li volnou chvíli –
pomáhají zvědavým či zmateným uživatelům. V této měsíční rubrice nabízíme
některé z otázek a odpovědí, které obdržely vysoký počet hlasů.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aa
nswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Jaká existují pravidla ohledně navyšování poplatků pomocí CPFP?]({{bse}}120853)
  Pieter Wuille poznamenává, že na rozdíl od navyšování poplatků pomocí [RBF][topic rbf],
  které má řadu pravidel, nemá [CPFP][topic cpfp] technika žádná dodatečná
  pravidla.

- [Jak se počítá, kolik transakcí se má nahradit pomocí RBF?]({{bse}}120823)
  Murch a Pieter Wuille procházejí několika příklady RBF nahrazení v kontextu
  pravidla číslo 5 z [BIP125][]: „Počet původních transakcí, které budou nahrazeny,
  a jejich potomků, kteří budou vyhozeni z mempoolu, nesmí dohromady překročit sto
  transakcí.” Čtenáře může dále zajímat sezení PR Review Clubu [Přidej test BIP-125 pravidla
  číslo 5 s výchozím mempoolem][review club 25228].

- [Jaké existují typy RBF a které z nich Bitcoin Core podporuje a používá?]({{bse}}120749)
  Murch vysvětluje historii nahrazování transakcí v Bitcoin Core a v [související
  otázce]({{bse}}120773) poskytuje souhrn pravidel nahrazení dle RBF. Dále odkazuje na
  dokumentaci Bitcoin Core [Mempool Replacements][bitcoin core mempool
  replacements] a na nápad na [zlepšení RBF][glozow rbf improvements].

- [V čem spočívá problém bloku 1 983 702?]({{bse}}120834)
  Antoine Poinsot poskytuje přehled problémů, které vedly k [BIP30][] omezujícímu
  duplikovaná txid a [BIP34][] požadujícímu začlenění čísla bloku v coinbase.
  Dále poznamenává, že existuje řada bloků, jejichž coinbase obsahuje náhodná data, která
  vypadají jako výška pozdějšího bloku. Blok 1 983 702 byl prvním, který v praxi mohl
  opakovat coinbase transakci nějakého předchozího bloku. V [související otázce]({{bse}}120836)
  se touto možností Murch a Antoine Poinsot zabývají hlouběji. Viz též
  [zpravodaj č. 182][news182 block1983702] (_angl._).

- [K čemu se v bitcoinu používají hashovací funkce?]({{bse}}120418)
  Pieter Wuille vypisuje přes třicet různých případů v pravidlech konsenzu,
  peer to peer protokolu, peněžence a implementaci uzlu, které dohromady používají
  nejméně deset různých hashovacích funkcí.

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [LND 0.17.3-beta][] je vydání obsahující opravy několika chyb včetně redukce
  použité paměti během používání Bitcoin Core backendu.

## Významné změny kódu a dokumentace

*Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo] a
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [LDK #2685][] přidává možnost získávání blockchainových dat ze serverů
  fungujících podobně jako Electrum.

- [Libsecp256k1 #1446][] odstraňuje z projektu část assembly kódu pro x86_64
  a přechází na používání stávajícího jazyka C, který byl vždy používán na
  ostatních platformách. Assembly kód byl před několika lety ručně optimalizován za
  účelem zvýšení výkonnosti knihovny, avšak kompilátory se od té doby
  zlepšily a nové verze GCC i LLVM (clang) nyní produkují ještě efektivnější
  kód.

- [BTCPay Server #5389][] přidává podporu pro bezpečné vytváření multisig
  peněženek dle [BIP129][] (viz [zpravodaj č. 136][news136 bip129], _angl._).
  To umožňuje BTCPay serveru spolupracovat během jednoduchého nastavení
  multisigu s několika softwarovými peněženkami a hardwarovými podpisovými zařízeními.

- [BTCPay Server #5490][] začíná ve výchozím nastavení používat [mempool.space][]
  pro [odhad poplatků][ms fee api] s místním Bitcoin Core uzlem jako jeho zálohou.
  Vývojáři pod PR poznamenávají, že mají pocit, že odhad poplatků poskytovaný
  Bitcoin Core nereaguje dostatečně rychle na změny v místním mempoolu. Viz
  [Bitcoin Core #27995][] pro související diskuzi o obtížích vylepšování
  přesnosti odhadu poplatků.

## Krásné svátky!

Toto číslo je letošním posledním pravidelným vydáním. Ve středu 20. prosince
vydáme náš šestý roční přehled. Pravidelné vydávání zpravodaje bude pokračovat ve středu
3. ledna.

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 15:00" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="2685,5389,5490,1446,27995" %}
[LND 0.17.3-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.17.3-beta
[teinturier liqad]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-December/004227.html
[ms fee api]: https://mempool.space/docs/api/rest#get-recommended-fees
[mempool.space]: https://mempool.space/
[news136 bip129]: /en/newsletters/2021/02/17/#securely-setting-up-multisig-wallets
[recap279 liqad]: /en/podcast/2023/11/30/#update-to-the-liquidity-ads-specification-transcript
[news182 block1983702]: /en/newsletters/2022/01/12/#bitcoin-core-23882
[demand website]: https://dmnd.work/
[news247 sri]: /cs/newsletters/2023/04/19/#aktualizace-referencni-implementace-protokolu-stratum-v2
[warnet github]: https://github.com/bitcoin-dev-project/warnet
[warnet scenarios]: https://github.com/bitcoin-dev-project/warnet/blob/main/docs/scenarios.md
[warnet monitoring]: https://github.com/bitcoin-dev-project/warnet/blob/main/docs/monitoring.md
[payjoin-cli]: https://github.com/payjoin/rust-payjoin/tree/master/payjoin-cli
[block arrival github]: https://github.com/bitcoin-data/block-arrival-times
[b10c tweet]: https://twitter.com/0xb10c/status/1732826609260872161
[stale block github]: https://github.com/bitcoin-data/stale-blocks
[envoy v1.4.0]: https://github.com/Foundation-Devices/envoy/releases/tag/v1.4.0
[bbqr github]: https://github.com/coinkite/BBQr
[zeus v0.8.0]: https://github.com/ZeusLN/zeus/releases/tag/v0.8.0
[review club 25228]: https://bitcoincore.reviews/25228
[bitcoin core mempool replacements]: https://github.com/bitcoin/bitcoin/blob/master/doc/policy/mempool-replacements.md
[glozow rbf improvements]: https://gist.github.com/glozow/25d9662c52453bd08b4b4b1d3783b9ff
