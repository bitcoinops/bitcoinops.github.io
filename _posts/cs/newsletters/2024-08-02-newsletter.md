---
title: 'Zpravodaj „Bitcoin Optech” č. 314'
permalink: /cs/newsletters/2024/08/02/
name: 2024-08-02-newsletter-cs
slug: 2024-08-02-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Zpravodaj tento týden oznamuje odhalení dvou zranitelností postihujících
starší verze Bitcoin Core a shrnuje návrh přístupu, jak mohou těžaři optimalizovat
výběr transakcí během používání cluster mempoolu. Též nechybí naše pravidelné
rubriky s oznámeními nových vydání a popisem významných změn v populárním
bitcoinovém páteřním software.

## Novinky

- **Odhalení zranitelností postihujících Bitcoin Core verze před 0.21.0:**
  Niklas Gögge zaslal do emailové skupiny Bitcoin-Dev [příspěvek][goegge
  disclosure] s odkazem na oznámení dvou zranitelností postihujících verze
  Bitcoin Core, které jsou již po konci životního cyklu nejméně od října 2022.
  Toto oznámení přichází měsíc po odhalení jiných starších zranitelností
  (viz [zpravodaj č. 310][news310 disclosure]). Níže shrnujeme obě odhalení:

  - [Záplava zpráv `addr` způsobuje pád na dálku][Remote crash by sending excessive `addr` messages]:
    uzel starší než Bitcoin Core 22.0 vydaný v září 2021 spadl kvůli přetečení
    32bitového počítadla, pokud byl informován o více než 2<sup>32</sup> jiných
    uzlech. Toho mohl útočník dosáhnout zasláním velkého množství P2P zpráv
    `addr` (nejméně čtyř miliónů zpráv). Eugene Siegel zranitelnost
    [zodpovědně nahlásil][topic responsible disclosures], její oprava byla
    začleněna do Bitcoin Core 22.0. [Zpravodaj č. 159][news159 bcc22387]
    (_angl._) obsahuje náš souhrn opravy, kterou jsme napsali bez vědomí,
    že opravovala nějakou zranitelnost.

  - [Pád na dálku v místní síti se zapnutým UPnP][Remote crash on local network when UPnP enabled]:
    ve verzích před Bitcoin Core 22.0 byly uzly s aktivním [UPnP][] pro
    automatické nastavení [průchodu NATem][NAT traversal] (kvůli jiné
    zranitelnosti je UPnP ve výchozím nastavení neaktivní, viz
    [zpravodaj č. 310][news310 miniupnpc]) zranitelné vůči útoku zařízením
    v místní síti, které opakovaně posílalo určité UPnP zprávy. Každá
    zpráva mohla vést k nové alokaci paměti, dokud uzel nespadl nebo nebyl
    ukončen operačním systémem. Chybu způsobující nekonečnou smyčku
    v miniupnpc, závislosti Bitcoin Core, nahlásil projektu miniupnpc
    Ronald Huveneers. Zranitelnost objevil a zodpovědně nahlásil
    Michael Ford. Oprava byla začleněna ve vydání Bitcoin Core 22.0.

  Očekáváme, že další zranitelnosti postihující pozdější verze Bitcoin Core
  budou zveřejněny za několik týdnů.

- **Optimalizace tvorby bloků s cluster mempoolem:** Pieter Wuille
  zaslal do fóra Delving Bitcoin [příspěvek][wuille selection] popisující
  způsob, který zajistí, aby během používání [cluster mempoolu][topic cluster
  mempool] obsahovaly šablony bloků pro těžaře nejlepší možnou množinu
  transakcí. V designu cluster mempoolu jsou _clustery_ souvisejících
  transakcí rozděleny do seřazeného seznamu _chunků_, z nichž každý
  má tato dvě omezení:

  1. Závisí-li některá transakce v chunku na jiné, nepotvrzené transakci, musí
     být tato druhá transakce buď ve stejném chunku nebo se musí v seřazeném
     seznamu objevit v dřívějším chunku.

  2. Každý chunk musí mít stejný nebo vyšší jednotkový poplatek než chunky,
     které jej v seřazeném seznamu následují.

  Díky tomu může být každý chunk z každého clusteru v mempoolu uložen v jediném
  seznamu seřazeném od nejvyššího po nejnižší jednotkový poplatek. Má-li
  potom těžař k dispozici mempool roztříděný do chunků a seřazený dle
  jednotkových poplatků, může jednoduše zkonstruovat šablonu bloku tím,
  že použije chunky z tohoto seznamu, dokud nezaplní požadovanou maximální
  váhu (která je obvykle kousek pod jeden milión vbyte, aby zbyl prostor
  pro coinbasovou transakci).

  Clustery a chunky se však liší ve velikosti, horní limit na cluster v Bitcoin
  Core bude zřejmě kolem 100 000 vbyte. To znamená, že pokud těžař během tvorby
  šablony bloku cílí na 998 000 vbyte a má již zaplněno 899 001 vbyte,
  a pokud má další chunk na řadě 99 000 vbyte, do zbývajícího prostoru se nevejde
  a zanechal by tak kolem 10 % nevyužitého prostoru. Těžař nemůže jednoduše
  přeskočit tento chunk s 99 000 vbyte, protože následující chunk může obsahovat
  transakci, která závisí na některé transakci z přeskočeného chunku.
  Pokud by těžař do šablony nezačlenil všechny závislosti, byly by vyprodukované
  bloky nevalidní.

  Wuille popisuje, jak s touto situací naložit: velké chunky mohou být
  rozdělené do menších _podchunků_ (sub-chunks), které mohou být začleněné
  do zbývajícího prostoru v závislosti na svém jednotkovém poplatku. Podchunk
  může být jednoduše vytvořen odstraněním poslední transakce z existujícího
  chunku nebo podchunku, který má dvě či více transakcí. Tímto způsobem lze
  vždy vytvořit nejméně jeden podchunk, který je menší než původní chunk,
  a někdy tím může vzniknout více podchunků. Wuille ukazuje, že počet chunků
  a podchanků je roven počtu transakcí, kde každá transakce patří do jedinečného
  chunku či podchunku. Proto je možné předem vypočítat chunk nebo podchunk
  každé transakce, což se nazývá její _absorpční množina_ (absorption set),
  a asociovat jej s touto transakcí. Wuille ukazuje, jak stávající algoritmus
  chunkování počítá absorpční množinu každé transakce.

  Když těžař zaplní šablonu všemi možnými plnými chunky, může vzít předem vypočítané
  absorpční množiny všech dosud nezačleněných transakcí a zvážit je v pořadí
  dle jednotkového poplatku. To nad seznamem se stejným počtem prvků, jako je transakcí
  v mempoolu (v současnosti téměř vždy pod jeden milión), vyžaduje jedinou operaci řazení.
  Zbývající blokový prostor potom může být zaplněn absorpční množinou (chunky
  a podchunky) s nejvyšším jednotkovým poplatkem. To vyžaduje sledování počtu
  transakcí z clusteru, které byly dosud začleněné, a přeskakování podchunků,
  které se již nevejdou nebo jejichž některé transakce již byly začleněné.

  I když chunky mohou být při výběru nejlepšího pořadí pro začlenění do bloku
  vzájemně porovnávané, jednotlivé transakce v rámci chunku nebo podchunku
  tuto záruku nenabízejí. To může vést k neoptimálnímu výběru v případech,
  kdy je blok téměř zaplněn. Například pokud zbývá pouze 300 vbyte prostoru,
  může algoritmus vybrat jednu 200vbytovou transakci při 5 sat/vbyte (celkem
  1 000 sat) namísto dvou 150vbytových transakcí při 4 sat/vbyte (celkem
  1 200 sat).

  Wuille popisuje, jak jsou předem spočítané absorpční množiny v tomto případě
  užitečné: jelikož vyžadují pouze sledování počtu dosud začleněných transakcí
  z každého clusteru, je jednoduché během provádění algoritmu obnovit předchozí stav,
  pozměnit výběr a zjistit, zda by výsledek nepřinesl vyšší poplatky.
  Za tímto účelem lze implementovat prohledávací [algoritmus větví a mezí][branch-and-bound]
  (branch-and-bound), který může vyzkoušet množství kombinací zaplnění zbývajícího
  prostoru v bloku v naději na nalezení lepšího výsledku.

- **Simulátor bitcoinové P2P sítě Hyperion:**
  Sergi Delgado zaslal do fóra Delving Bitcoin [příspěvek][delgado hyperion] o
  [Hyperionu][Hyperion], jeho síťovém simulátoru, který sleduje propagaci
  dat simulovanou bitcoinovou sítí. Prvotní motivací projektu je zájem
  porovnat šíření oznámení o transakcích (zpráva `inv`) současným
  způsobem s navrhovanou metodou [Erlay][topic erlay].

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [BDK 1.0.0-beta.1][] je kandidátem na vydání „první beta verze `bdk_wallet` se stabilním
  1.0.0 API.”

## Významné změny kódu a dokumentace

_Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Bitcoin Inquisition][bitcoin inquisition repo] a [repozitáři BINANA][binana
repo]._

- [Bitcoin Core #30515][] přidává do odpovědi RPC příkazu `scantxoutset`
  haš bloku a počet potvrzení. Díky tomu je k dispozici spolehlivější
  identifikátor bloku s daným UTXO, než je jeho výška, obzvláště v případech
  reorganizací řetězce.

- [Bitcoin Core #30126][] přináší novou funkci `Linearize`. Ta je součástí
  projektu [cluster mempoolu][topic cluster mempool]. Funkce je určená pro
  vytváření nebo zlepšování [linearizace clusterů][wuille cluster],
  která navrhuje pořadí transakcí pro přidání do šablon bloků za účelem
  maximalizace získaných poplatků nebo pro minimalizaci ztrát na poplatcích
  během vylučování z plného mempoolu. Funkce zatím není mempoolem používána,
  PR tedy nepřináší žádnou změnu chování.

- [Bitcoin Core #30482][] zlepšuje validaci parametrů RESTového endpointu
  `getutxos`. Nově budou odmítány identifikátory transakcí s nesprávnou
  délkou a bude vrácena chyba `HTTP_BAD_REQUEST`. Dříve požadavek skončil
  selháním bez chybové hlášky.

- [Bitcoin Core #30275][] mění výchozí mód RPC volání `estimatesmartfee`
  z konzervativního na ekonomický. Tato změna je založena na pozorování
  uživatelů a vývojářů, že konzervativní mód často vede k přeplácení
  poplatků kvůli pomalejší reakci při krátkodobých výkyvech trhu, než kterou
  pro [odahodávní poplatků][topic fee estimation] nabízí ekonomický mód.

- [Bitcoin Core #30408][] nahrazuje v nápovědě RPC volání `decodepsbt`, `decoderawtransaction`,
  `decodescript`, `getblock` (s verbosity=3), `getrawtransaction` (s verbosity=2,3) a
  `gettxout` v referencích na `scriptPubKey` frázi „public key script” na „output script”.
  Jedná se o stejný název, který používá navrhovaný BIP s popisem terminologie transakcí
  (viz [zpravodaj č. 246][news246 bipterminology]).

- [Core Lightning #7474][] aktualizuje plugin pro [nabídky][topic offers], který
  bude používat nově definované experimentální rozsahy Type-Length-Value typů (TLV)
  používaných v nabídkách, požadavcích o faktury a fakturách. Ty byly nedávno
  přidány v zatím nezačleněném [BOLT12 PR][bolt12 pr].

- [LND #8891][] přidává do očekávané odpovědi externího zdroje [odhadu poplatků][topic
  fee estimation] nové pole `min_relay_fee_rate`, kterým může služba určit
  minimální poplatek pro přeposílání. Pokud není specifikován, bude použita
  výchozí hodnota `FeePerKwFloor` 1 012 sat/kvB (1,012 sat/vbyte). PR
  dále zlepšuje spolehlivost spouštění, pokud je odhad poplatků volán ještě
  před jeho plnou inicializací.

- [LDK #3139][] počíná autentizovat [zaslepené cesty][topic rv routing] a tím navyšuje
  bezpečnost BOLT12 [nabídek][topic offers]. Bez této autentizace mohl útočník
  Mallory vzít Bobovu nabídku a vyžádat od každého uzlu v síti fakturu, aby zjistil,
  který z nich patří Bobovi. Tím byl schopný narušit výhodu používání zaslepených cest.
  Problém je opraven tím, že je nově 128bitový nonce součástí šifrované zaslepené cesty
  namísto nešifrovaných metadat. Tato změna zneplatňuje odchozí platby a návratky
  mající neprázdnou zaslepenou cestu vytvořenou předchozími verzemi. Nabídky
  vytvořené předchozími verzemi jsou nadále validní, avšak náchylné na tento
  deanonymizační útok. Uživatelům se doporučuje po upgradu nabídky znovu vygenerovat.

- [Rust Bitcoin #3010][] přidává do `sha256::Midstate` pole s délkou, které
  umožňuje přesnější a flexibilnější sledování stavu hašování během
  inkrementálního generování SHA256 otisku. Změna může postihnout stávající
  implementace, které závisí na předchozí podobě struktury `Midstate`.

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="30515,30126,30482,30275,30408,7474,8891,3139,3010" %}
[BDK 1.0.0-beta.1]: https://github.com/bitcoindevkit/bdk/releases/tag/v1.0.0-beta.1
[wuille selection]: https://delvingbitcoin.org/t/cluster-mempool-block-building-with-sub-chunk-granularity/1044
[branch-and-bound]: https://cs.wikipedia.org/wiki/Metoda_v%C4%9Btv%C3%AD_a_mez%C3%AD
[delgado hyperion]: https://delvingbitcoin.org/t/hyperion-a-discrete-time-network-event-simulator-for-bitcoin-core/1042
[hyperion]: https://github.com/sr-gi/hyperion
[news310 disclosure]: /cs/newsletters/2024/07/05/#odhaleni-zranitelnosti-postihujicich-bitcoin-core-verze-pred-0-21-0
[Remote crash by sending excessive `addr` messages]: https://bitcoincore.org/en/2024/07/31/disclose-addrman-int-overflow/
[news159 bcc22387]: /en/newsletters/2021/07/28/#bitcoin-core-22387
[news310 miniupnpc]: /cs/newsletters/2024/07/05/#vzdalene-spusteni-kodu-kvuli-chybe-v-miniupnpc
[Remote crash on local network when UPnP enabled]: https://bitcoincore.org/en/2024/07/31/disclose-upnp-oom/
[upnp]: https://cs.wikipedia.org/wiki/Universal_Plug_and_Play
[nat traversal]: https://cs.wikipedia.org/wiki/NAT_traversal
[wuille cluster]: https://delvingbitcoin.org/t/introduction-to-cluster-linearization/1032
[news246 bipterminology]: /cs/newsletters/2023/04/12/#navrh-bipu-s-terminologii-transakci
[bolt12 pr]: https://github.com/lightning/bolts/pull/798
[goegge disclosure]: https://mailing-list.bitcoindevs.xyz/bitcoindev/bf5287e8-0960-45e8-9c90-64ffc5fdc9aan@googlegroups.com/
