---
title: 'Zpravodaj „Bitcoin Optech” č. 321'
permalink: /cs/newsletters/2024/09/20/
name: 2024-09-20-newsletter-cs
slug: 2024-09-20-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Zpravodaj tento týden odkazuje na implementaci ověření konceptu generování
dokladu s nulovou znalostí o přítomnosti výstupu v množině UTXO, popisuje
jeden nový a dva předchozí návrhy na offline LN platby a shrnuje výzkum
DNS seedů pro ne-IP síťové adresy. Též nechybí naše pravidelné rubriky
s popisem změn klientů a služeb, oznámeními nových vydání a souhrnem
významných změn v populárním bitcoinovém páteřním software.

## Novinky

- **Doklad s nulovou znalostí o přítomnosti v množině UTXO:** Johan Halseth
  zaslal do fóra Delving Bitcoin [příspěvek][halseth utxozk] ohlašující
  nástroj sloužící jako ověření konceptu poskytování dokladu o kontrole
  nad některým výstupem v aktuální množině UTXO, aniž by doklad identifikoval
  konkrétní výstup. Konečným cílem je umožnit spoluvlastníkům výstupu
  financujícího LN kanál prokázat jeho vlastnictví bez odhalení jakýchkoliv
  dalších informací o jejich onchain transakcích. Takový doklad může
  být připojen ke [zprávám oznamujícím kanály][topic channel announcements]
  nové generace, které jsou používány ke sběru informací o LN pro
  decentralizované hledání cest.

  Metoda je odlišná od aut-ct popsaném ve [zpravodaji č. 303][news303 aut-ct],
  diskuze se mimo jiné soustředí na objasnění rozdílů mezi nimi. Další výzkum
  je nezbytný, sám Halseth popisuje několik nevyřešených problémů.

- **Lightningové offline platby:** Andy Schroder zaslal do fóra Delving Bitcoin
  [příspěvek][schroder lnoff] s náčrtem procesu, kterým by mohla LN peněženka
  vygenerovat tokeny, jež by umožnily jiné peněžence připojené k internetu
  na ni provést platbu. Nechť je v našem příkladu Alicina peněženka
  běžně připojena k jejímu online LN uzlu nebo k _poskytovateli lightningových
  služeb_ (LSP). Zatímco je Alice online, vygeneruje autentizační tokeny.

  Později, když chce Alice zaplatit Bobovi, ale její uzel je offline,
  poskytne Bobovi autentizační token, který mu umožní připojit se k jejímu
  online uzlu či LSP a vybrat částku určenou Alicí. Tento token může Bobovi
  předat přes [NFC][] či jiný dostupný přenosový protokol, který
  po Alici nevyžaduje připojení k internetu. Díky tomu může tento protokol
  zůstat jednoduchý a dostupný i na zařízeních s omezenými výpočetními
  prostředky (např. smart card).

  Vývojář ZmnSCPxj [zmínil][zmn lnoff] alternativní přístup, který již dříve
  popsal, a Bastien Teinurier [odkázal][t-bast lnoff] na svou metodu vzdáleného
  přístupu k uzlu pro podobné situace (viz [zpravodaj č. 271][news271 noderc]).

- **DNS seedy pro ne-IP adresy:** vývojář Virtu [zaslal][virtu seed] do fóra
  Delving Bitcoin výsledky průzkumu dostupnosti seedových uzlů v [anonymizačních
  sítích][topic anonymity networks]. Též započal diskuzi o metodách, které
  umožňují uzlům používajícím výhradně tyto sítě objevit další uzly pomocí
  DNS seedů.

  Bitcoinový uzel nebo P2P klient potřebují zjistit síťové adresy jiných uzlů,
  od kterých by mohly stahovat data. Může se stát, že nově nainstalovaný software
  nebo software, který byl po dlouhou dobu offline, nezná síťové adresy žádných
  aktivních uzlů. Bitcoin Core běžně řeší tento problém dotazem na DNS seed,
  který vrátí IPv4 nebo IPv6 adresy několika uzlů, které zřejmě budou dostupné.
  Selže-li použití DNS nebo je-li nedostupné (např. u anonymizačních sítí, které
  IPv4 ani IPv6 nepoužívají), obsahuje Bitcoin Core síťové adresy uzlů,
  které byly dostupné v době vydání. Tyto uzly jsou použity jako _seedové
  uzly_, od kterých uzel získá další adresy. DNS seedy mají před seedovými
  uzly přednost, neboť jejich data jsou obvykle čerstvější a cachovací
  infrastruktura globálního DNS umí zabránit, aby se DNS seeder dozvěděl síťové
  adresy dotazujících se uzlů.

  Virtu prozkoumal seedové uzly obsažené v posledních čtyřech hlavních vydáních
  Bitcoin Core a zjistil, že jich je stále dostupné vyhovující množství.
  Uživatelé anonymizačních sítí by tak měli být schopni další uzly nalézt.
  Spolu s dalšími účastníky diskuze dále prozkoumali možnost takové úpravy Bitcoin
  Core, která by mu umožnila použít DNS seedy pro anonymizační sítě buď s použitím
  DNS `NULL` záznamů nebo zakódováním alternativních síťových adres do rádoby IPv6
  adres.

## Změny ve službách a klientech

*V této měsíční rubrice upozorňujeme na zajímavé aktualizace bitcoinových
peněženek a služeb.*

- **Strike přidává podporu pro BOLT12:**
  Strike [ohlásil][strike blog] podporu [BOLT12 nabídek][topic offers]
  včetně používání nabídek s DNS platebními instrukcemi dle [BIP353][].

- **BitBox02 přidává podporu tichých plateb:**
  BitBox02 [ohlásil][bitbox blog sp] podporu [tichých plateb][topic
  silent payments] a implementaci [žádostí o platbu][bitbox blog pr].

- **Vydán The Mempool Open Source Project v3.0.0:**
  [Vydání v3.0.0][mempool github 3.0.0] obsahuje mimo jiné nový způsob výpočtu
  [CPFP][topic cpfp] poplatků, nové funkce kolem [RBF][topic rbf] včetně podpory
  fullrbf, podporu pro P2PK a nové možnosti analýzy mempoolu a blockchainu.

- **Vydán ZEUS v0.9.0:**
  [Blogový příspěvek o v0.9.0][zeus blog 0.9.0] hovoří o nových LSP funkcích,
  peněženkách umožňující pouze sledování, podpoře hardwarových podpisových zařízení,
  podpoře pro [dávkování transakcí][scaling payment batching] včetně transakcí pro
  otevírání kanálů a dalších novinkách.

- **Live Wallet přidává podporu konsolidací:**
  Aplikace Live Wallet analyzuje náklady na útratu skupiny UTXO s různými poplatky
  včetně zjištění, které výstupy by byly [neekonomické][topic uneconomical outputs].
  [Vydání 0.7.0][live wallet github 0.7.0] přináší funkce pro simulaci
  [konsolidačních transakcí][consolidate info] a generování konsolidačních [PSBT][topic
  psbt].

- **Bisq přidává podporu Lightningu:**
  [Bisq v2.1.0][bisq github v2.1.0] dává uživatelům možnost vyrovnat obchody přes Lightning
  Network.

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [HWI 3.1.0][] je vydáním nové verze tohoto balíčku poskytujícího jednotné
  rozhraní pro přístup k rozličným hardwarovým podpisovým zařízením.
  Toto vydání přináší podporu Trezor Safe 5 a několik dalších vylepšení a
  oprav chyb.

- [Core Lightning 24.08.1][] je údržbovým vydáním, které opravuje pády a další chyby
  objevené v nedávném vydání 24.08.

- [BDK 1.0.0-beta.4][] je kandidátem na vydání této knihovny pro budování peněženek
  a jiných bitcoinových aplikací. Původní rustový balíček `bdk` byl přejmenován
  na `bdk_wallet` a moduly nižší úrovně byly extrahovány do samostatných balíčků:
  `bdk_chain`, `bdk_electrum`, `bdk_esplora` a `bdk_bitcoind_rpc`. Balíček
  `bdk_wallet` „je první verzí nabízející stabilní 1.0.0 API.”

- [Bitcoin Core 28.0rc2][] je kandidátem na vydání příští hlavní verze této převládající
  implementace plného uzlu. K dispozici je [průvodce testování][bcc testing].

## Významné změny kódu a dokumentace

_Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Bitcoin Inquisition][bitcoin inquisition repo] a [repozitáři BINANA][binana
repo]._

_Poznámka: commity do Bitcoin Core zmíněné níže se vztahují na jeho master vývojovou
větev. Tyto změny pravděpodobně nebudou vydány do doby kolem šesti měsíců od vydání
připravované verze 28._

- [Bitcoin Core #28358][] odstraňuje `dbcache` limit, protože stávající hodnota
  16 GB již nedostačuje na dokončení prvotního stažení bloků (Initial Block Download,
  IBD) bez potřeby zapsat množinu UTXO z paměti na disk (což může proces [urychlit][lopp
  cache] o zhruba 25 %). Odstranění bylo upřednostněno před navýšením hodnoty,
  protože neexistuje optimální hodnota, která by byla spolehlivě použitelná
  i v budoucnosti a poskytla uživatelům maximální flexibilitu.

- [Bitcoin Core #30286][] optimalizuje algoritmus hledání kandidátů během linearizace
  clusterů, který je založen na popisu z druhé části [příspěvku][delving cluster]
  na fóru Delving Bitcoin. Tato vylepšení dosahují lepšího výkonu díky snížení počtu
  iterací, avšak za cenu navýšení doby spuštění a nákladů na jednu iteraci.
  Jedná se o součást projektu [cluster mempoolu][topic cluster mempool]. Viz též
  [zpravodaj č. 315][news315 cluster].

- [Bitcoin Core #30807][] mění způsob signalizace uzlu, který na pozadí právě provádí
  synchronizaci blockchainu v rámci [assumeUTXO][topic assumeutxo]. Namísto původní
  hodnoty `NODE_NETWORK` bude nově použito `NODE_NETWORK_LIMITED`, aby spojení nepožadovala
  bloky starší než zhruba jeden týden. Tím se opravuje chyba, která způsobovala odpojení
  assumeUTXO uzlu poté, co od něj na žádost o historický blok nepřišla žádná odpověď.

- [LND #8981][] zužuje použití `paymentDescriptor` pouze na modul `lnwallet`. Později
  bude `paymentDescriptor` nahrazen novou strukturou `LogUpdate`, čímž se zjednoduší
  zpracování a logování změn. PR je součástí snahy o implementaci dynamických
  commitmentů jako typu [upgradu commitmentů kanálu][topic channel commitment upgrades].

- [LDK #3140][] přidává podporu placení statických [BOLT12][topic offers] faktur
  pro posílání [asynchronních plateb][topic async payments] uzly, které jsou vždy online,
  dle definice v [BOLTs #1149][]. Žádost o fakturu není v [onion zprávě][topic onion
  messages] obsažena. Přijímání asynchronní plateb ani jejich posílání uzly,
  které jsou často offline, není zatím podporováno.

- [LDK #3163][] přidává do zaslané BOLT12 faktury `reply_path`, což plátci umožní
  v případě potřeby poslat příjemci chybovou zprávu.

- [LDK #3010][] dává uzlu nově možnost opakovat zaslání žádosti o fakturu jako odpovědi
  na [nabídku][topic offers], pokud ještě odpovídající fakturu neobdržel.

- [BDK #1581][] upravuje algoritmus [výběru mincí][topic coin selection] možností
  nastavit záložní algoritmus u strategie `BranchAndBoundCoinSelection` (metoda větví
  a mezí). Signatura metody `coin_select` nově umožňuje předat generátor náhodných
  čísel. Dále PR přináší několik dalších změn a zjednodušení nakládání s chybami.

- [BDK #1561][] odstraňuje z projektu balíček `bdk_hwi` za účelem zjednodušení
  závislostí a CI. `bdk_hwi` obsahoval `HWISigner`, který byl přemístěn do projektu
  `rust_hwi`.

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="28358,30286,30807,8981,3140,3163,3010,1581,1561,1149" %}
[BDK 1.0.0-beta.4]: https://github.com/bitcoindevkit/bdk/releases/tag/v1.0.0-beta.4
[bitcoin core 28.0rc2]: https://bitcoincore.org/bin/bitcoin-core-28.0/
[bcc testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/28.0-Release-Candidate-Testing-Guide
[halseth utxozk]: https://delvingbitcoin.org/t/proving-utxo-set-inclusion-in-zero-knowledge/1142/
[schroder lnoff]: https://delvingbitcoin.org/t/privately-sending-payments-while-offline-with-bolt12/1134/
[virtu seed]: https://delvingbitcoin.org/t/hardcoded-seeds-dns-seeds-and-darknet-nodes/1123
[news303 aut-ct]: /cs/newsletters/2024/05/17/#anonymni-tokeny-uzivani
[nfc]: https://cs.wikipedia.org/wiki/Near_Field_Communication
[zmn lnoff]: https://delvingbitcoin.org/t/privately-sending-payments-while-offline-with-bolt12/1134/2
[t-bast lnoff]: https://delvingbitcoin.org/t/privately-sending-payments-while-offline-with-bolt12/1134/4
[news271 noderc]: /cs/newsletters/2023/10/04/#zabezpecene-vzdalene-ovladani-ln-uzlu
[hwi 3.1.0]: https://github.com/bitcoin-core/HWI/releases/tag/3.1.0
[core lightning 24.08.1]: https://github.com/ElementsProject/lightning/releases/tag/v24.08.1
[delving cluster]: https://delvingbitcoin.org/t/how-to-linearize-your-cluster/303#h-2-finding-high-feerate-subsets-5
[lopp cache]: https://github.com/bitcoin/bitcoin/pull/28358#issuecomment-2186630679
[news315 cluster]: /cs/newsletters/2024/08/02/#bitcoin-core-30126
[strike blog]: https://strike.me/blog/bolt12-offers/
[bitbox blog sp]: https://bitbox.swiss/blog/understanding-silent-payments-part-one/
[bitbox blog pr]: https://bitbox.swiss/blog/using-payment-requests-to-securely-send-bitcoin-to-an-exchange/
[mempool github 3.0.0]: https://github.com/mempool/mempool/releases/tag/v3.0.0
[zeus blog 0.9.0]: https://blog.zeusln.com/new-release-zeus-v0-9-0/
[live wallet github 0.7.0]: https://github.com/Jwyman328/LiveWallet/releases/tag/0.7.0
[consolidate info]: https://en.bitcoin.it/wiki/Techniques_to_reduce_transaction_fees#Consolidation
[bisq github v2.1.0]: https://github.com/bisq-network/bisq2/releases/tag/v2.1.0
