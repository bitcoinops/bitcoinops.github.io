---
title: 'Zpravodaj „Bitcoin Optech” č. 307'
permalink: /cs/newsletters/2024/06/14/
name: 2024-06-14-newsletter-cs
slug: 2024-06-14-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Zpravodaj tento týden oznamuje návrh BIPu pro formát kvantově bezpečných
bitcoinových adres a obsahuje naše pravidelné rubriky se souhrnem
Bitcoin Core PR Review Clubu, oznámeními nových vydání a popisem významných
změn v populárních bitcoinových páteřních projektech.

## Novinky

- **Návrh BIPu pro kvantově bezpečný formát adres:** vývojář Hunter Beast
  zaslal do fóra Delving Bitcoin a emailové skupiny [příspěvek][beast post]
  s [„hrubým návrhem” BIPu][quantum draft], který přiřazuje segwitovou verzi
  3 adresám s [kvantově odolným][topic quantum resistance] algoritmem elektronických
  podpisů. Návrh BIPu problém popisuje a odkazuje na několik potenciálních algoritmů
  s jejich očekávanou onchain velikostí. Volba algoritmu, detaily o konkrétní
  implementaci a dodatečné BIPy potřebné k plnému uskutečnění vize přidání kvantové
  odolnosti do bitcoinu jsou ponechány budoucím diskuzím.

## Bitcoin Core PR Review Club

*V této měsíční rubrice shrnujeme nedávné sezení [Bitcoin Core PR Review Club][] a
vyzdvihujeme některé z důležitých otázek a odpovědí. Klikněte na otázku a odpověď se vám odhalí.*

[Nemaž opakovaně indexy při pokračování předchozí reindexace][review club
30132] je PR od [TheCharlatan][gh thecharlatan], které snižuje startovací dobu,
pokud uživatel restartuje uzel ještě před dokončením reindexace.

Bitcoin Core implementuje pět indexů. Vyžadované jsou indexy množiny UTXO a bloků,
indexy transakcí, [filtru kompaktních bloků][topic compact block filters] a
coinstats index jsou volitelné. Pokud je program spuštěn s volbou `-reindex`,
všechny indexy jsou vymazány a přepočítány. Tento proces může trvat dlouho a
není zaručeno, že skončí před ukončením programu.

Jelikož uzel potřebuje aktuální množinu UTXO a index bloků, je stav jejich reindexace
zapisován na disk. Na začátku reindexace je [aktivován][reindex flag set] příznak
a deaktivován bude pouze po dokončení reindexace. Tímto způsobem může uzel při svém
startu detekovat, že by měl pokračovat v reindexaci, i když uživatel neposkytl volbu.

Když je uzel restartován (bez volby `-reindex`) po nedokončené reindexaci, jsou
vyžadované indexy zachovány a bude se v nich pokračovat. Před tímto PR byly
volitelné index vymazány znovu. Díky [Bitcoin Core #30132][] může být start
uzlu efektivnější, jelikož tyto volitelné index nejsou vymazány, pokud to není
nutné.

{% include functions/details-list.md
  q0="Jakou změnu chování přináší toto PR?"
  a0="Chování se mění ve třech aspektech. Zaprvé, dle záměru tohoto PR, se již
  při restartu po nedokončené reindexaci nebudou mazat volitelné indexy. Tím
  bude chování volitelných indexů totožné s vyžadovanými. Zadruhé pokud
  uživatel vyvolá reindexaci přes GUI, nebude již tento požadavek ignorován.
  Tím se opraví nenápadná chyba představená v [b47bd95][gh b47bd95].
  Zatřetí je odstraněna logovací zpráva \"Initializing databases...\\n\"."
  a0link="https://bitcoincore.reviews/30132#l-19"

  q1="Jakými dvěma způsoby zpracovávají volitelné indexy nové bloky?"
  a1="Když se inicializuje volitelný index, zkontroluje, zda-li je jeho
  nejvyšší blok shodný s aktuálním nejvyšším blokem blockchainu. Pokud není,
  nejdříve zpracuje všechny chybějící bloky v rámci synchronizace na pozadí
  (pomocí `BaseIndex::StartBackgroundSync()`). Další bloky bude potom
  zpracovávat rozhraním validace pomocí `ValidationSignals::BlockConnected`."
  a1link="https://bitcoincore.reviews/30132#l-52"

  q2="Jaký dopad má toto PR na logiku zpracovávání nových bloků u volitelných indexů?"
  a2="Před tímto PR vymazání volitelných indexů bez vymazání stavu
  řetězce znamenalo, že byly tyto indexy považovány za nesynchronizované.
  Dle předchozí otázky to znamená, že nejdříve provedou synchronizaci na pozadí
  a poté přepnou do rozhraní validace. S tímto PR zůstávají volitelné indexy
  synchronizované se stavem řetězce, žádná synchronizace na pozadí tak není
  potřebná. Poznámka: synchronizace na pozadí začíná až po dokončení reindexace,
  zpracování validačních událostí se děje paralelně."
  a2link="https://bitcoincore.reviews/30132#l-70"
%}

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [Core Lightning 24.05][] je vydáním příští hlavní verze této populární implementace
  LN uzlu. Obsahuje vylepšení, díky kterým lépe funguje s ořezanými plnými uzly (viz
  [zpravodaj č. 300][news300 cln prune]), umožňuje RPC volání `check` fungovat s pluginy
  (viz [zpravodaj č. 302][news302 cln check]), přináší vylepšení stability (popsáno
  například ve zpravodajích [č. 303][news303 cln chainlag] a [č. 304][news304 cln feemultiplier]),
  umožňuje robustnější doručování [nabídek][topic offers] (viz [zpravodaj č. 304][news304 cln
  offers]) a opravuje přeplácení na poplatcích, pokud je použita konfigurační volba
  `ignore_fee_limits` (viz [zpravodaj č. 306][news306 cln overpay]).

- [Bitcoin Core 27.1][] je údržbovým vydáním této převládající implementace plného uzlu,
  která obsahuje opravy několika chyb.

## Významné změny kódu a dokumentace

_Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Bitcoin Inquisition][bitcoin inquisition repo] a [repozitáři BINANA][binana
repo]._

- [Bitcoin Core #29496][] navyšuje hodnotu konstanty `TX_MAX_STANDARD_VERSION` na 3,
  čímž činí standardními do potvrzení topologicky omezené ([TRUC][topic v3 transaction
  relay]) transakce. Je-li verze transakce rovná hodnotě 3, bude s ní nakládáno jako
  s TRUC transakcí dle specifikace v [BIP431][]. Hodnota `CURRENT_VERSION` zůstává 2,
  peněženka tedy TRUC transakce zatím vytvářet nebude.

- [Bitcoin Core #28307][] opravuje chybu, která aplikovala maximální velikost P2SH skriptu
  (520 bajtů) i na redeem skripty u P2SH-segwit i bech32. Díky opravě je možné vytvářet
  multisig [deskriptory výstupů][topic descriptors] s více než 15 klíči (až do 20 klíčů,
  což je limit konsenzu pro `OP_CHECKMULTISIG`) včetně jejich podepisování.

- [Bitcoin Core #30047][] refaktoruje reprezentaci limitu počtu znaků (`charlimit`)
  [bech32][topic bech32] kódování z konstanty 90 na výčtový typ. Díky tomu je snadné
  podporovat nové typy adres, které používají bech32 kódování, ale nemají stejný limit
  počtu znaků, jako definuje [BIP173][]. Například bude možné zpracovávat adresy
  [tichých plateb][topic silent payments], které vyžadují až 118 znaků.

- [Bitcoin Core #28979][] přidává do dokumentace RPC příkazu `sendall` (viz [zpravodaj č. 194][news194
  sendall], _angl._) informaci, že vedle potvrzených výstupů utrácí i nepotvrzené. Jsou-li nepotvrzené
  výstupy utracené, kompenzuje jakýkoliv _schodek poplatku_ (viz [zpravodaj č. 269][news269 deficit]).
  _Tento odstavec byl po publikaci opraven._[^correction-28979]

- [Eclair #2854][] a [LDK #3083][] implementují [BOLTs #1163][], který odstraňuje požadavek
  na zaslání zprávy `channel_update` po neúspěšném doručení [onion zprávy][topic onion messages].
  Tento požadavek umožňoval útok, ve kterém přeposílající uzel, který vygeneroval
  chybový status neúspěšného doručení, mohl identifikovat odesílatele [HTLC][topic htlc]
  díky `channel_update`, čímž narušil odesílatelovo soukromí.

- [LND #8491][] přidává do `lncli` RPC příkazů `addinvoice` a `addholdinvoice`
  volbu `cltv_expiry`, která umožní uživatelům nastavit hodnotu `min_final_cltv_expiry_delta`
  ([CLTV expiry delta][topic cltv expiry delta] pro poslední část cesty).
  V popisu změny není uvedena motivace, mohlo by to však být v reakci na nedávné
  navýšení výchozí hodnoty z 9 na 18 bloků dle [BOLT2][] specifikace (viz
  [zpravodaj č. 284][news284 lnd final delta]).

- [LDK #3080][] rozděluje `create_blinded_path` v `MessagerRouter` do dvou metod:
  jednu pro tvorbu kompaktních [zaslepených cest][topic rv routing] a druhou
  pro běžné zaslepené cesty. Volající si tedy může zvolit podle potřeby.
  Kompaktní zaslepené cesty používají krátké identifikátory kanálů (SCID),
  které odkazují na financující transakci (nebo alias kanálu) a mají obvykle
  8 bajtů. Běžné zaslepené cesty odkazují na LN uzel jeho 33bajtovým veřejným klíčem.
  Kompaktní cesty mohou být neaktuální, pokud je kanál uzavřen nebo podstoupil
  [splicing][topic splicing], jsou tedy vhodnější pro krátkodobé QR kódy nebo
  odkazy, kde se nižší prostor ocení. Běžné cesty se upřednostňují u dlouhodobých
  případů použití včetně [nabídek][topic offers] založených na [onion zprávách][topic
  onion messages], kde díky použití identifikátorů uzlů lze přeposílat zprávy spojením,
  ke kterým již neexistuje kanál (onion zprávy kanály nevyžadují). `ChannelManager`
  bude nově používat kompaktní zaslepené cesty pro krátkodobé [nabídky][topic offers]
  a refundace, cesty pro odpovědi budou používat běžné zaslepené cesty.

- [BIPs #1551][] přidává [BIP353][] se specifikací DNS platebních instrukcí. Tento
  protokol kóduje [BIP21][] adresy do TXT záznamů DNS. Protokol nabízí čitelnost
  instrukcí a možnost soukromého dotazování. Například `example@example.com` by mohl
  být přeložen na DNS adresu `example.user._bitcoin-payment.example.com`, která vrátí
  TXT záznam podepsaný pomocí DNSSEC a obsahující BIP21 URI, například
  `bitcoin:bc1qexampleaddress0123456`. [Zpravodaj č. 290][news290 bip353] obsahuje
  popis a [minulé číslo][news306 dns] zmiňuje začlenění BLIPu.

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}

## Poznámky

[^correction-28979]:
	Náš původní, zveřejnění popis Bitcoin Core #28979 tvrdil, že utrácení nepovrzených
	transakcí pomocí `sendall` byla změna chování. Děkujeme Gustavo Floresovi za jeho
	původní, správný popis (chybu zanesl editor zpravodaje). Mark „Murch” Edhardt
	chybu nahlásil, též mu děkujeme.

{% include references.md %}
{% include linkers/issues.md v=2 issues="29496,28307,30047,28979,2854,3083,1163,8491,3080,3072,1551,30132" %}
[beast post]: https://delvingbitcoin.org/t/proposing-a-p2qrh-bip-towards-a-quantum-resistant-soft-fork/956
[quantum draft]: https://github.com/cryptoquick/bips/blob/p2qrh/bip-p2qrh.mediawiki
[core lightning 24.05]: https://github.com/ElementsProject/lightning/releases/tag/v24.05
[Bitcoin Core 27.1]: https://bitcoincore.org/bin/bitcoin-core-27.1/
[news306 cln overpay]: /cs/newsletters/2024/06/07/#core-lightning-7252
[news304 cln feemultiplier]: /cs/newsletters/2024/05/24/#core-lightning-7063
[news304 cln offers]: /cs/newsletters/2024/05/24/#core-lightning-7304
[news303 cln chainlag]: /cs/newsletters/2024/05/17/#core-lightning-7190
[news302 cln check]: /cs/newsletters/2024/05/15/#core-lightning-7111
[news300 cln prune]: /cs/newsletters/2024/05/01/#core-lightning-7240
[review club 30132]: https://bitcoincore.reviews/30132
[gh thecharlatan]: https://github.com/TheCharlatan
[gh b47bd95]: https://github.com/bitcoin/bitcoin/commit/b47bd959207e82555f07e028cc2246943d32d4c3
[reindex flag set]: https://github.com/bitcoin/bitcoin/blob/457e1846d2bf6ef9d54b9ba1a330ba8bbff13091/src/node/blockstorage.cpp#L58
[news198 sendall]: /en/newsletters/2022/04/06/#bitcoin-core-24118
[news290 bip353]: /cs/newsletters/2024/02/21/#citelne-bitcoinove-platebni-instrukce-zalozene-na-dns
[news194 sendall]: /en/newsletters/2022/04/06/#bitcoin-core-24118
[news269 deficit]: /cs/newsletters/2023/09/20/#bitcoin-core-26152
[news284 lnd final delta]: /cs/newsletters/2024/01/10/#lnd-8308
[news306 dns]: /cs/newsletters/2024/06/07/#blips-32
