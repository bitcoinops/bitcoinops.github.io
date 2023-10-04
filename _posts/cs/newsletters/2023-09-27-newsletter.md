---
title: 'Zpravodaj „Bitcoin Optech” č. 270'
permalink: /cs/newsletters/2023/09/27/
name: 2023-09-27-newsletter-cs
slug: 2023-09-27-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Tento týden přinášíme popis návrhu na použití kovenantů k významnému
navýšení škálovatelnosti LN. Též nechybí naše pravidelné rubriky se
souhrnem oblíbených otázek a odpovědí z Bitcoin Stack Exchange,
oznámeními o nových vydáních a popisem významných změn v populárním
bitcoinovém páteřním software.

## Novinky

- **Kovenanty pro navýšení škálovatelnosti LN:** John Law zaslal do
  emailových skupin Bitcoin-Dev a Lightning-Dev [příspěvek][law cov
  post] přinášející souhrn jeho [článku][law cov paper] o vytváření
  velkých [továren kanálů][topic channel factories] pomocí [kovenantů][topic
  covenants] a správě výsledných kanálů použitím verzí několika protokolů,
  které dříve popsal; viz zpravodaje č. [221][news221 law] (*angl.*),
  [230][news230 law] a [244][news244 law].

  Nejdříve popisuje problém škálovatelnosti u protokolů založených na
  digitálních podpisech, které vyžadují účast velkého množství uživatelů,
  jako je [coinjoin][topic coinjoin] nebo předešlé návrhy na továrny:
  dohodne-li se tisíc uživatelů na účasti v obdobném protokolu, ale jeden
  z nich je během podepisování nedostupný, ostatních 999 podpisů je
  k ničemu. Pokud je během dalšího pokusu jiný účastník nedostupný,
  ostatních posbíraných 998 podpisů je též k ničemu. Jako řešení problému
  navrhuje Law kovenanty typu [OP_CHECKTEMPLATEVERIFY][topic
  op_checktemplateverify] či [SIGHASH_ANYPREVOUT][topic sighash_anyprevout].
  Ty, jak známo, umožňují malé transakci omezit, jak mohou být její prostředky
  utraceny jednou či více předdefinovanými následnými transakcemi. Také tyto
  následné transakce mohou být kovenantem omezeny.

  Law použitím tohoto mechanismu vytváří _expirační strom_ („timeout tree”),
  ve kterém _zakládající transakce_ („funding transaction”) platí stromu
  předem definovaných následných transakcí, které nakonec budou utraceny
  offchain do velkého počtu oddělených platebních kanálů. Mechanismus
  podobný Ark (viz [zpravodaj č. 253][news253 ark]) umožňuje každému
  platebnímu kanálu volitelné zveřejnění onchain, ale též dává zakladatelům
  továrny možnost získat zpět prostředky kanálu, který nebyl včas zveřejněn
  onchain. Může to být velice efektivní: offchain expirační strom vytvářející
  milióny kanálů může být vytvořen pomocí jedné malé onchain transakce.
  Po expiraci mohou být prostředky vráceny zakladateli továrny v další
  malé onchain transakci a jednotliví uživatelé mohou před expirací továrny
  poslat své prostředky jinam přes LN.

  Tento model je kompatibilní s LN-Penalty, současným modelem konstrukce
  kanálů, i s navrhovaným [LN-Symmetry][topic eltoo]. Avšak zbytek Lawova
  článku se soustředí na modifikace jím navrhovaného protokolu optimalizovaného pro
  továrny bez použití strážních věží (FFO-WF, „Fully Factory Optimized Watchtower
  Free“), který použitím kovenantů nabízí několik výhod. Kromě výhod popsaných
  v předchozích číslech zpravodaje, jako je například možnost _běžných uživatelů_
  být online jen pár minut každých několik měsíců a _zapálených uživatelů_
  efektivněji používat svůj kapitál napříč kanály, nová výhoda aktualizované
  konstrukce umožňuje zakladateli továrny přesouvat prostředky běžných
  uživatelů z jedné továrny (založené na konkrétní onchain transakci) do jiné
  továrny (ukotvené v jiné onchain transakci), aniž by vyžadoval uživatelovu
  spoluúčast. To znamená, že běžná uživatelka Alice, která ví, že musí být online
  před půlroční expirací továrny, se může připojit po pěti měsících a zjistit,
  že její prostředky byly již přesunuty do jiné továrny s novou, několikaměsíční
  expirací. Alice nemusí dělat nic a přitom si zachovává celkovou kontrolu nad
  svými prostředky. To snižuje pravděpodobnost situace, kdy se Alice připojí
  online příliš krátkou dobu před expirací a zjistí, že je zakladatel továrny
  dočasně nedostupný. Byla by tak nucena zveřejnit svou část expiračního
  stromu onchain, což by vyžadovalo transakční poplatky a snižovalo celkovou
  škálovatelnost sítě.

  Anthony Towns vyjádřil ve své [odpovědi][towns cov] obavu, kterou nazývá
  problémem „burácejícího stáda” a jež byla v [původním článku o LN][ln paper]
  nazývána „vynucený expirační spam” („forced expiration spam”). Townsova
  obava spočívá v úmyslném či nahodilém selhání velkého zapáleného uživatele,
  po kterém by muselo velké množství uživatelů ve stejný čas zveřejnit onchain
  své časově citlivé transakce. Například továrna s miliónem uživatelů by
  mohla vyžadovat včasné potvrzení až miliónu transakcí, po kterém by následovaly
  až dva milióny dalších transakcí uživatelů, kteří chtějí otevřít nové kanály.
  V současnosti trvá potvrzení tří miliónů transakcí zhruba týden. Uživatelé
  továrny s miliónem uživatelů by tak mohli po továrně požadovat přesunutí
  prostředků několik týdnů před expirací či několik měsíců, obávají-li se
  podobných problémů postihující několik miliónových továren najednou.

  Jedna z verzí původního článku o LN navrhovala řešení tohoto problému pomocí
  [myšlenky][maxwell clock stop] Gregoryho Maxwella, která by prodloužila expiraci,
  pokud by byly „bloky plné” (například pokud by jednotkové poplatky byly příliš vysoké).
  Law Townsovi [odpověděl][law fee stop], že již pracuje na konkrétním návrhu
  řešení tohoto typu a zveřejní jej, až s ním bude hotov.

## Vybrané otázky a odpovědi z Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] je jedním z prvních míst, kde hledají
přispěvatelé Optechu odpovědi na své otázky a kde – najdou-li volnou chvíli –
pomáhají zvědavým či zmateným uživatelům. V této měsíční rubrice nabízíme
některé z otázek a odpovědí, které obdržely vysoký počet hlasů.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Jak v Bitcoin v0.1 fungovalo hledání spojení?]({{bse}}119507)
  Pieter Wuille popisuje vývoj způsobů hledání spojení v Bitcoin Core od
  hledání na IRC ve vydání 0.1 přes napevno zakódované IP adresy až po
  současný DNS seeding.

- [Mohla by série reorganizací rozbít bitcoin kvůli pravidlu dvou hodin?]({{bse}}119677)
  Uživatel fiatjaf se táže, zda by mohla série reorganizací blockchainu, například
  jako výsledek [fee snipingu][topic fee sniping], způsobit problémy kvůli
  restrikcím časových razítek bitcoinových bloků. Antoine Poinsot a Pieter Wuille
  popisují tyto dvě restrikce (musí být větší než [Median Time Past (MTP)][news146 mtp],
  tj. medián časových razítek posledních 11 bloků, a ne více než dvě hodiny do
  budoucnosti dle lokálního času) a vyvozuje, že ani jedna z restrikcí není
  reorganizacemi umocněna.

- [Existuje způsob, jak stáhnout bloky bez nutnosti nejdříve stáhnout hlavičky?]({{bse}}119503)
  Pieter Wuille potvrzuje, že je možné stáhnout bloky bez hlaviček, ale upozorňuje
  na nevýhodu, že dokud uzel nestáhne a nezpracuje všechny bloky, neví, zda je na nejlepším
  blockchainu. Porovnává tento přístup s [prvotní synchronizací hlaviček][headers first pr]
  a ukazuje, jaké P2P zprávy jsou u každého přístupu používány.

- [Kde je ve zdrojovém kódu bitcoinu stanoven limit 21 miliónů?]({{bse}}119475)
  Pieter Wuille vysvětluje funkci `GetBlockSubsidy` z Bitcoin Core, která
  definuje plán uvolňování. Také odkazuje na předchozí diskuzi na Stack Exchange
  o [limitu 20 999 999,976 9 BTC]({{bse}}38998) a ukazuje na konstantu `MAX_MONEY`
  používanou jako rychlá kontrola v kódu validace konsenzu.

- [Jsou bloky s nestandardními transakcemi přeposílány sítí nebo nejsou stejně jako nestandardní transakce?]({{bse}}119693)
  Uživatel fiatjaf odpovídá, že i když transakce, které jsou dle [pravidel][policy series]
  nestandardní, nejsou ve výchozím nastavení P2P sítí přeposílány, bloky obsahující
  nestandardní transakce přeposílány jsou, pokud se drží pravidel konsenzu.

- [Kdy mi Bitcoin Core umožňuje „zahodit transakci”?]({{bse}}119771)
  Murch vypisuje tři podmínky, aby mohla být transakce v bitcoin Core
  [zahozena][rpc abandontransaction]:

  - tato transakce ještě zahozena nebyla
  - tato transakce ani žádná konfliktní transakce nejsou potvrzeny
  - tato transakce není v mempoolu uzlu

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [LND v0.17.0-beta.rc5][] je kandidátem na vydání příští hlavní verze této
  oblíbené implementace LN uzlu. Velkou novou experimentální funkcí
  plánovanou pro toto vydání, které by prospělo testování, je podpora
  „jednoduchých taprootových kanálů.”

## Významné změny kódu a dokumentace

*Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo] a
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [Bitcoin Core #28492][] přidává do výsledku RPC volání `descriptorprocesspsbt`
  kompletní serializovanou transakci, pokud zpracování [PSBT][topic psbt]
  vyústí v transakci připravenou ke zveřejnění. Viz podobné začleněné PR
  popsané v [minulém čísle zpravodaje][news269 psbt].

- [Bitcoin Core GUI #119][] odstraňuje v GUI ze seznamu transakcí zvláštní
  kategorii „platba sama sobě.” Nově budou transakce, jejichž vstupy i
  výstupy mají dopad na peněženku, zobrazeny na samostatných řádkách jako
  přijetí a odeslání. Může to pomoci porozumění v případě [coinjoinů][topic
  coinjoin] a [payjoinů][topic payjoin], i když Bitcoin Core zatím ani
  jeden z těchto typů transakcí nepodporuje.

- [Bitcoin Core GUI #738][] přidává do menu položku umožňující migraci
  ze zastaralých peněženek založených na klíčích a jejich výstupních
  skriptech uložených v BerkeleyDB (BDB) na moderní peněženku, která
  používá [deskriptory][topic descriptors] uložené v SQLite.

- [Bitcoin Core #28246][] aktualizuje způsob, kterým peněženka v Bitcoin
  Core interně určuje, jakým výstupním skriptů (scriptPubKey) by měla
  transakce platit. Dříve transakce platily kterýmkoliv výstupním
  skriptům uživatelem určeným, ale pokud by byla do Bitcoin Core přidána
  podpora [tichých plateb][topic silent payments], výstupní skripty
  by byly odvozeny z dat ze vstupů vybraných pro transakci. Díky této
  aktualizaci to bude snadnější.

- [Core Lightning #6311][] odstraňuje volbu sestavení `--developer`,
  která vyústila v binární soubory s více možnostmi než standardní
  CLN. Nově jsou experimentální a doplňkové možnosti přístupné
  konfigurační volbou `--developer` předanou během spuštění `lightningd`.
  Volba sestavení `--enable-debug` bude i nadále produkovat mírně
  odlišné binární soubory vhodné pro testování.

- [Core Lightning #6617][] přidává do výsledku RPC volání `showrunes`
  novou položku `last_used`, která zobrazuje čas posledního použití
  _runy_ (autentizačního tokenu).

- [Core Lightning #6686][] přidává do REST rozhraní nastavitelné hlavičky
  Content-Security-Policy (CSP) a Cross-Origin-Resource-Sharing (CORS).

- [Eclair #2613][] umožňuje, aby Eclair spravoval všechny své soukromé
  klíče a používal Bitcoin Core pouze pro watch-only peněženku (peněženku
  mající pouze veřejné klíče). To může být užitečné v případech, kdy
  je Eclair provozován ve více zabezpečených prostředích než Bitcoin Core.
  [Dokumentace][eclair keys] přidaná tímto PR obsahuje více podrobností.

- [LND #7994][] přidává do RPC rozhraní vzdáleného podepisování podporu
  pro otevírání taprootových kanálů. Rozhraní vyžaduje veřejný klíč a
  nonce pro [MuSig2][topic musig].

- [LDK #2547][] přidává do kódu pravděpodobnostního vyhledávání cest
  předpoklad, že vzdálené kanály mají pravděpodobně většinu své
  likvidity na jedné straně kanálu. Například v případě jednobitcoinového
  kanálu mezi Alicí a Bobem je nejméně pravděpodobný stav s 0,5 BTC
  na každé straně. S větší pravděpodobností bude mít jeden z nich 0,9 BTC
  a 0,99 BTC s ještě větší pravděpodobností.

- [LDK #2534][] přidává metodu `ChannelManager::send_preflight_probes`
  umožňující [sondování][topic payment probes] platební cesty před uskutečněním
  samotné platby. Sonda je vytvořena odesílatelem jako běžná LN platba, ale
  obsah jejího [HTLC][topic htlc] předobrazu je nastaven na nepoužitelnou
  hodnotu (například hodnotu známou pouze odesílateli). Když platba dosáhne
  svého cíle, příjemce ji odmítne z důvodu neznámého předobrazu a odešle
  zpět chybovou hlášku. Obdrží-li odesílatel tuto chybu, ví, že platební
  cesta má dostatek likvidity pro skutečnou platbu a skutečná platba
  se stejnou částkou by tedy pravděpodobně uspěla. Pokud by obdržel jinou
  chybovou hlášku, například chybu ukazující na nemožnost jednoho uzlu
  na cestě platbu přeposlat, mohla by být pro sondu vybraná jiná cesta.

  Sondování před skutečnou platbou („preflight”) může být užitečný a levný
  způsob nalezení uzlů v cestě, které mají nějaké potíže a mohly by způsobit
  zdržení. Pokud na několik hodin uvízne několik set (či méně) satoshi, není
  to většinou velký problém. Pokud by však uvízla částka představující
  významnou část kapitálu uzlu, mohlo by to být velice otravné. Je též
  možné sondovat několik cest zároveň a později z nich vybrat tu nejlepší
  pro skutečnou platbu.

{% include references.md %}
{% include linkers/issues.md v=2 issues="28492,119,738,28246,6311,6617,6686,2613,7994,2547,2534" %}
[LND v0.17.0-beta.rc5]: https://github.com/lightningnetwork/lnd/releases/tag/v0.17.0-beta.rc5
[news253 ark]: /cs/newsletters/2023/05/31/#navrh-na-spravovany-joinpool-protokol
[maxwell clock stop]: https://www.reddit.com/r/Bitcoin/comments/37fxqd/it_looks_like_blockstream_is_working_on_the/crmr5p2/
[law cov post]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-September/004092.html
[law cov paper]: https://github.com/JohnLaw2/ln-scaling-covenants
[towns cov]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-September/004095.html
[ln paper]: https://lightning.network/lightning-network-paper.pdf
[law fee stop]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-September/004102.html
[news221 law]: /en/newsletters/2022/10/12/#ln-with-long-timeouts-proposal
[news230 law]: /cs/newsletters/2022/12/14/#navrh-na-ln-protokol-pro-tovarny
[news244 law]: /cs/newsletters/2023/03/29/#jak-predejit-uviznuti-kapitalu-pomoci-kanalu-s-vice-stranami-a-tovarnami-kanalu
[eclair keys]: https://github.com/ACINQ/eclair/blob/d3ac58863fbb76f4a44a779a52a6893b43566b29/docs/ManagingBitcoinCoreKeys.md
[news269 psbt]: /cs/newsletters/2023/09/20/#bitcoin-core-28414
[news146 mtp]: /en/newsletters/2021/04/28/#what-are-the-different-contexts-where-mtp-is-used-in-bitcoin
[headers first pr]: https://github.com/bitcoin/bitcoin/pull/4468
[policy series]: /cs/blog/waiting-for-confirmation/
