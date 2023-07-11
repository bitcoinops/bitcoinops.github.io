---
title: 'Zpravodaj „Bitcoin Optech” č. 257'
permalink: /cs/newsletters/2023/06/28/
name: 2023-06-28-newsletter-cs
slug: 2023-06-28-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Tento týden přinášíme popis nápadu na zabránění pinningu coinjoinových
transakcí a návrhu na spekulativní využití vysněných změn konsenzu.
Též nechybí další příspěvek do naší krátké týdenní série o pravidlech
mempoolu a pravidelné rubriky s populárními otázkami a odpověďmi z
Bitcoin Stack Exchange, novými vydáními a změnami v populárním
páteřním bitcoinovém software.

## Novinky

- **Přeposílání v3 transakcí zabraňuje pinningu coinjoinu:** Greg
  Sanders ve svém [příspěvku][sanders v3cj] do emailové skupiny Bitcoin-Dev
  popsal, jak by mohla navrhovaná [pravidla přeposílání v3 transakcí][topic v3
  transaction relay] pomoci vytvářet [coinjoinové][topic coinjoin] transakce
  s více stranami, které by nebyly náchylné k [transaction pinningu][topic
  transaction pinning]. Hrozba pinningu spočívá v možnosti jednoho z účastníků
  použít svůj vstup k vytvoření konfliktní transakce, která by zabránila
  coinjoinové transakci v konfirmaci.

  Sanders navrhuje, že by se mohly coinjoinové transakce této hrozbě vyhnout
  tím, že by přiměly všechny účastníky nejprve utratit své bitcoiny na
  skript, který by bylo možné utratit buď podpisy všech účastníků coinjoinu
  nebo pouze tímto účastníkem po expiraci časového zámku. V případě
  koordinovaného coinjoinu by musel koordinátor podepsat spolu s účastníkem
  (nebo účastník sám po uplynutí časového zámku).

  Chtěl-li by účastník podepsat konfliktní transakci před uplynutím časového zámku,
  musel by získat podpisy buď ostatních účastníků nebo koordinátora, což by
  se mu podařilo jen v případě, kdy by podepsání bylo v zájmu všech (např.
  v případě [navýšení poplatků][topic rbf]).

- **Spekulativní využívání vysněných změn konsenzu:** Robin Linus
  zaslal do emailové skupiny Bitcoin-Dev [příspěvek][linus spec] s nápadem
  na utracení peněz na fragment skriptu, který nebude moci být spuštěn po
  dlouhou dobu (např. 20 let). Byl-li by tento fragment interpretován
  podle současných pravidel konsenzu, umožnil by těžařům za 20 let nárokovat
  všechny prostředky. Fragment je však navržen tak, aby změna pravidel
  konsenzu dala fragmentu odlišný význam. Linus dává za příklad opkód
  `OP_ZKP_VERIFY`, který by v případě přidání do bitcoinu umožnil nárokovat
  prostředky komukoliv, kdo poskytne důkaz s nulovou znalostí (Zero-Knowledge
  Proof) na program s určitým hashem.

  Tento mechanismus by umožnil lidem utratit dnes bitcoin na jeden z těchto
  skriptů a za důkaz o tomto utracení obdržet ekvivalentní množství bitcoinů
  na [sidechainu][topic sidechains] nebo alternativním chainu (_jednosměrný
  peg_). Bitcoiny na druhém chainu by mohly být opakovaně utráceny po dobu
  20 let, dokud by neexpiroval časových zámek. Poté by mohl současný vlastník
  bitcoinů na druhém chainu vygenerovat ZKP důkaz, že bitcoiny vlastnil,
  a použít jej k vyzvednutí uzamčeného vkladu na bitcoinovém mainnetu
  (_obousměrný peg_). S dobrým návrhem ověřovacího programu by bylo vyzvednutí
  snadné a flexibilní.

  Autoři poznamenávají, že lidé benefitující z tohoto konstruktu (např.
  příjemci bitcoinů na druhém chainu) by se v podstatě sázeli, že nastane
  změna pravidel konsenzu (např. že bude přidán `OP_ZKP_VERIFY`). To jim
  dává podnět, aby změnu propagovali. Příliš silná propagace však může
  ostatní odrazovat. Tento nápad v době psaní neobdržel žádné reakce.

## Čekání na potvrzení 7: síťové zdroje

_Krátká týdenní [série][policy series] o přeposílání transakcí, začleňování do mempoolu a výběru
transakcí k těžbě včetně vysvětlení, proč má Bitcoin Core přísnější pravidla,
než co je povoleno konsenzem, a jak mohou peněženky využít pravidla co nejefektivněji._

{% include specials/policy/cs/07-network-resources.md %}

## Vybrané otázky a odpovědi z Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] je jedním z prvních míst, kde hledají
přispěvatelé Optechu odpovědi na své otázky a kde – najdou-li volnou chvíli –
pomáhají zvědavým či zmateným uživatelům. V této měsíční rubrice nabízíme
některé z otázek a odpovědí, které obdržely vysoký počet hlasů.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Proč uzly akceptují bloky s tolika chybějícími transakcemi?]({{bse}}118707)
  Uživatele commstarka zajímá, proč uzel akceptuje od těžaře blok, který neobsahuje
  transakce, o kterých se na základě [šablony bloku][reference getblocktemplate]
  předpokládalo, že budou začleněny. Existuje množství [nástrojů][miningpool observer],
  které [porovnávají][mempool space] očekávané a skutečné bloky. Pieter Wuille
  poznamenává, že kvůli inherentní [rozdílnosti mempoolů][waiting for confirmation 1]
  napříč uzly způsobené propagací transakcí není možné vynucovat pravidla konsenzu
  na základě obsahu bloků.

- [Proč všichni říkají, že soft forky omezují existující sadu pravidel?]({{bse}}118642)
  Pieter Wuille dává za příklad zpřísnění pravidla přidaná během [aktivace][topic soft
  fork activation] soft forků [taprootu][topic taproot] a [segwitu][topic segwit]:

  - taproot přidal požadavek, aby se `OP_1 <32 bytes>` (taproot) výstup řídil
    taprootovými pravidly konsenzu
  - segwit přidal požadavek, aby se `OP_{0..16} <2..40 bytes>` (segwit) výstup
    řídil segwitovými pravidly konsenzu a také vyžaduje pro předsegwitové  výstupy prázdný witness

- [Proč je výchozí limit LN kanálu nastaven na 16777215 sat?]({{bse}}118709)
  Vojtěch Strnad osvětluje historii limitu 2<sup>24</sup> satoshi a motivaci pro
  velké (wumbo) kanály. Též odkazuje na naše [téma velkých kanálů][topic large channels]
  pro získání více informací.

- [Proč během výběru transakcí používá Bitcoin Core hodnocení předků namísto jednotkového poplatku?]({{bse}}118611)
  Sdaftuar vysvětluje, že důvodem použití jednotkového poplatku předků i hodnocení
  předků algoritmem výběru transakcí pro těžbu je optimalizace výkonu. (Viz též
  [Čekání na potvrzení 2: incentivy][waiting for confirmation 2].)

- [Jak jsou definovány částky v LN platbách s více částmi (MPP)?]({{bse}}117405)
  Rene Pickhardt píše, že [platby s více cestami][topic multipath payments]
  nemají specifikovánu velikost jednotlivých částí a odkazuje na studie
  zabývající se dělením plateb.

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [BTCPay Server 1.10.3][] je nejnovějším vydáním tohoto software pro zpracování
  plateb. [Blogový příspěvek][btcpay 1.10] obsahuje přehled důležitých novinek
  tohoto vydání.

## Významné změny v kódu a dokumentaci

*Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo] a
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [Core Lightning #6303][] přidává nové RPC volání `setconfig`, které umožňuje
  měnit některá nastavení bez restartování démonu.

- [Eclair #2701][] zaznamenává, kdy je přijato [HTLC][topic htlc] a kdy je
  urovnáno. To umožňuje sledovat, jak dlouho bylo z pohledu uzlu HTLC
  vyřizováno. Je-li mnoho HTLC nebo několik HTLC s vysokou hodnotou vyřizováno
  po dlouhou dobu, může to značit probíhající [útok zahlcením kanálu][topic channel
  jamming attacks]. Sledování trvání HTLC napomáhá k odhalování podobných
  útoků a může je omezovat.

- [Eclair #2696][] mění způsob nastavení jednotkových poplatků uživateli.
  V předchozích verzích mohli uživatelé určit jednotkové poplatky
  zvolením _cíle bloku_, např. nastavení na 6 znamenalo, že se Eclair
  pokusí o potvrzení transakce během šesti bloků. Nově uživatel zvolí
  mezi „pomalu,” „středně” a „rychle,” což se přeloží do konkrétního
  jednotkového poplatku použitím konstanty nebo cíle.

- [LND #7710][] dává pluginům a samotnému démonu přístup k datům
  obdrženým dříve v rámci HTLC. To je nezbytné pro [zaslepování tras][topic
  rv routing] a může být mimo jiné použito různými opatřeními proti
  [zahlcení kanálu][topic channel jamming attacks].

- [LDK #2368][] umožňuje akceptovat nové kanály vytvořené spojením, které
  používá [anchor výstupy][topic anchor outputs], ale vyžaduje, aby
  měl ovládající program možnost každý kanál zvlášť akceptovat. Důvodem
  je, že řádné vyrovnání anchor kanálů může po uživateli vyžadovat
  vlastnictví jednoho či více UTXO s dostatečnou hodnotou. LDK jako
  knihovna netuší, jaká UTXO mimo LN uživatelova peněženka vlastní.
  Tento mechanismus dává programu možnost ověřit přítomnost tohoto UTXO.

- [LDK #2367][] zpřístupňuje [anchor výstupy][topic anchor outputs]
  běžnému uživateli API.

- [LDK #2319][] umožňuje spojení vytvářet HTLC, které je zavázáno k platbě
  nižší než je původní částka určená odesílatelem. Zbytek si může spojení
  přisvojit jako poplatek. Tato možnost je užitečná pro vytváření [JIT
  kanálů][topic jit channels], ve kterých spojení obdrží HTLC pro příjemce,
  který ještě nemá kanál. Spojení vytvoří onchain transakci, která financuje
  kanál a zavazuje k HTLC uvnitř tohoto kanálu, ale způsobuje dodatečné
  náklady na poplatky při vytváření onchain transakce. Tento nový
  poplatek může sloužit jako kompenzace.

- [LDK #2120][] přidává podporu pro hledání trasy k příjemci, který používá
  [zaslepné cesty][topic rv routing].

- [LDK #2089][] přidává funkci pro zpracování událostí, která usnadní peněženkám
  navýšit poplatek za [HTLC][topic htlc], která musí být urovnána onchain.

- [LDK #2077][] refaktoruje velké množství kódu pro snadné budoucí
  přidání podpory [kanálů s oboustranným vkladem][topic dual funding].

- [Libsecp256k1 #1129][] implementuje techniku [ElligatorSwift][ElligatorSwift paper]
  přinášející 64bytové kódování veřejného klíče, které je výpočetně
  nerozeznatelné od náhodných dat. Modul `ellswift` poskytuje funkce
  pro kódování a dekódování veřejných klíčů v novém formátu, funkce pro
  generování nových náhodných klíčů a pro provádění ECDH výměny klíčů
  s tímto kódováním. ECDH založené na ellswift bude použito v navazování
  spojení v rámci protokolu [P2P šifrovaného transportu verze 2][topic v2
  p2p transport] ([BIP324][]).

{% include references.md %}
{% include linkers/issues.md v=2 issues="6303,2701,2696,7710,2368,2367,2319,2120,2089,2077,1129" %}
[policy series]: /cs/blog/waiting-for-confirmation/
[sanders v3cj]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-June/021780.html
[linus spec]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-June/021781.html
[BTCPay Server 1.10.3]: https://github.com/btcpayserver/btcpayserver/releases/tag/v1.10.3
[btcpay 1.10]: https://blog.btcpayserver.org/btcpay-server-1-10-0/
[miningpool observer]: https://miningpool.observer/template-and-block
[mempool space]: https://mempool.space/graphs/mining/block-health
[waiting for confirmation 1]: /cs/blog/waiting-for-confirmation/#k-%C4%8Demu-je-mempool
[reference getblocktemplate]: https://developer.bitcoin.org/reference/rpc/getblocktemplate.html
[waiting for confirmation 2]: /cs/blog/waiting-for-confirmation/#incentivy
[ElligatorSwift paper]: https://eprint.iacr.org/2022/759
