---
title: 'Zpravodaj „Bitcoin Optech” č. 289'
permalink: /cs/newsletters/2024/02/14/
name: 2024-02-14-newsletter-cs
slug: 2024-02-14-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Tento týden přinášíme souhrn nápadů na zlepšení přeposílání po nasazení
cluster mempoolu, popisujeme výsledky výzkumu topologií a velikostí anchor
výstupů ve stylu LN v roce 2023, oznamujeme nového hostitele emailové
skupiny Bitcoin-Dev a nabádáme čtenáře k poděkování vývojářům svobodného
software v rámci oslav I Love Free Software Day. Též nechybí naše pravidelné
rubriky se souhrnem sezení Bitcoin Core PR Review Clubu a popisem významných
změn v populárním bitcoinovém páteřním software.

## Novinky

- **Nápady na vylepšení přeposílání po nasazení cluster mempoolu:**
  Gregory Sanders zaslal do fóra Delving Bitcoin [příspěvek][sanders future]
  s několika nápady, které by po úplné implementaci, otestování a nasazení [cluster
  mempoolu][topic cluster mempool] umožnily jednotlivým transakcím se volitelně
  řídit jistými pravidly mempoolu. Tato vylepšení staví na [přeposílání transakcí
  verze 3][topic v3 transaction relay] uvolněním některých pravidel, která již
  nejsou potřebná, a přidáním požadavku, aby transakce (či [balíček][topic package relay]
  transakcí) platily jednotkové poplatky, díky kterým by pravděpodobně byly
  vytěžené během jednoho či dvou následujících bloků.

- **Co by se bývalo stalo, kdyby byla v3 sémantika aplikována na anchor výstupy před rokem?**
  Suhas Daftuar zaslal do fóra Delving Bitcoin [příspěvek][daftuar retrospective],
  ve kterém popsal svůj výzkum myšlenky na automaticky aplikovaná [pravidla přeposílání
  transakcí verze 3][topic v3 transaction relay] na LN commitmenty ve stylu [anchor výstupů][topic
  anchor outputs] a transakce navyšující poplatky (viz [zpravodaj č. 286][news286 imbued],
  který popisuje návrh na _vštípenou v3 logiku_, na které je tato myšlenka založena).
  V krátkosti: v roce 2023 zaznamenal 14 124 transakcí, které vypadaly
  jako útraty anchorů. Z nich:

  - Kolem 94 % by bylo úspěšných s aplikovanými pravidly v3.

  - Kolem 2,1 % mělo více než jednoho rodiče (např. pokusy o dávkové CPFP).
    Některé LN peněženky tak činí pro účinnější zavírání více než jednoho kanálu
    během krátké doby. Toto chování by musely ukončit, pokud by výstupům
    ve stylu anchorů měly být vštípeny vlastnosti v3.

  - Kolem 1,8 % nebylo prvním potokem svého rodiče. Díky návrhu na vštípenou v3
    logiku by mohl druhý potomek nahradit prvního potomka v rámci [balíčku][topic
    package relay] (viz [zpravodaj č. 287][news287 kindred]).

  - Kolem 1,2 % bylo očividně prapotomkem commitment transakce, tedy utracení <!-- intentional -->
    utracení anchor výstupu. LN peněženky to mohou dělat
    z několika různých důvodů, od zavírání několika anchor kanálů v řadě po
    otevírání nových kanálů zůstatkem po zavření anchor kanálu. LN peněženky
    by toto chování musely opustit, pokud by byly anchor výstupům vštípeny vlastnosti
    v3.

  - Kolem 1,2 % nebylo nikdy vytěženo a nebylo dále ani analyzováno.

  - Kolem 0,1 % utrácelo nesouvisející nepotvrzený výstup, načež mělo utracení
    anchoru více než jednoho rodiče. Vývojář Bastien Teinturier míní, že toto
    mohlo být chování Eclairu a poznamenává, že Eclair by tuto situaci automaticky
    vyřešil i se současným kódem.

  - Méně než 0,1 % bylo větších než 1 000 vbyte. I toto chování by LN peněženky
    musely změnit. Daftuarovo následné bádání ukázalo, že téměř všechna utracení
    anchorů měla méně než 500 vbyte, z čehož vyplývá, že maximální velikost ve
    verzi 3 by mohla být ještě snížena. Díky tomu by bylo levnější přenést se přes
    [pinningový útok][topic transaction pinning] proti utráceným anchorům, ale
    také by to zabránilo LN peněženkám v možnosti používat na poplatky více než
    několik málo UTXO. Teinturier [poznamenal][teinturier better], že „je velmi
    lákavé snížit tuto 1 000vbyte hodnotu, ale data ukazují pouze čestné
    pokusy (s malým počtem čekajících HTLC), jelikož jsme zatím ještě neviděli
    žádný rozsáhlý útok na síť. Je tedy těžké vymyslet, jaká hodnota by byla ‚lepší’.“

  I když se očekává další diskuze a výzkumy vztažené k tomuto tématu, měli jsme
  z výsledků pocit, že než bude moci Bitcoin Core bezpečně nakládat s útratami
  anchor výstupů jako s v3 transakcemi, budou muset LN peněženky učinit několik změn,
  aby byly lépe v souladu s v3 pravidly.

- **Přesun emailové skupiny Bitcoin-Dev:** emailová skupina pro diskuze okolo
  vývoje protokolu je nyní hostována na novém serveru s novou emailovou adresou.
  Každý, kdo si přeje pokračovat v přijímání příspěvků, se musí znovu zaregistrovat.
  [Email][migration email] napsaný Bryanem Bishopem obsahuje další podrobnosti.
  Zpravodaje [č. 276][news276 ml] a [č. 288][news288 ml] přinesly popis diskuzí
  o migraci.

- **I Love Free Software Day:** každý rok 14. února nabádají organizace jako
  [FSF][] a [FSFE][] uživatele svobodného a open source software (FOSS), aby
  „kontaktovali a poděkovali všem lidem, kteří spravují a přispívají do
  svobodného software.” I pokud čtete toto vydání zpravodaje po 14. únoru,
  snažte se nalézt chvilku a poslat poděkování některým svým oblíbeným
  přispěvatelům do bitcoinových FOSS projektů.

## Bitcoin Core PR Review Club

*V této měsíční rubrice shrnujeme nedávné sezení [Bitcoin Core PR Review Club][] a
vyzdvihujeme některé z důležitých otázek a odpovědí. Klikněte na otázku a odpověď se vám odhalí.*

[Přidej do `submitpackage` argumenty `maxfeerate` a `maxburnamount`][review club 28950]
je PR Grega Sanderse (instagibbs na GitHubu), které do RPC volání `submitpackage`
přidává funkcionalitu již obsaženou v RPC pro jednotlivé transakce
`sendrawtransaction` a `testmempoolaccept`. PR je součástí rozsáhlejšího
projektu [přeposílání balíčků][topic package relay]. Konkrétně toto PR
umožní odesílateli balíčku specifikovat argumenty (zmíněné v titulku),
které zajistí provedení hrubé kontroly transakcí v balíčku a předejdou
tak nezamýšlené ztrátě prostředků. Sezení klubu vedl Abubakar Sadiq Ismail
(ismaelsadeeq na GitHubu).

{% include functions/details-list.md
  q0="Proč je důležité provádět tyto kontroly odesílaných balíčků?"
  a0="Pomáhají uživatelům zajistit, aby měly transakce v rámci odesílaných
      balíčků stejné garance jako jednotlivé odesílané transakce."
  a0link="https://bitcoincore.reviews/28950#l-27"

  q1="Existují vedle `maxburnamount` a `maxfeerate` i jiné důležité kontroly,
      které by měly být nad balíčky vykonány před akceptováním do mempoolu?"
  a1="Ano, dvěma příklady jsou kontrola bázového poplatku a maximální
      velikost standardní transakce. Tyto kontroly jsou na nízké úrovni,
      mohou být provedeny časně a rychle balíček odmítnout."
  a1link="https://bitcoincore.reviews/28950#l-33"

  q2="Volby `maxburnamount` a `maxfeerate` mohou transakci zabránit
      od vstupu do mempoolu a přeposílání. Můžeme tyto volby považovat
      za pravidla mempoolu? Proč ano a proč ne?"
  a2="Jedná se o pravidla; tyto kontroly nejsou aplikovány na transakce
      ve vytěžených blocích, nejedná se tedy o konsenzus. Dokonce ani
      neovlivňují přeposílání transakcí od spojení, pouze transakce
      odeslané lokálně přes RPC."
  a2link="https://bitcoincore.reviews/28950#l-47"

  q3="Proč validujeme maximální jednotkový poplatek proti modifikovanému
      jednotkovému poplatku namísto bázového jednotkového poplatku?"
  a3="(Minulá sezení klubu [24152][review club 24152],
      [24538][review club 24538] a [27501][review club 27501]
      se zabývala konceptem modifikovaných a bázových poplatků.)
      Většina účastníků se domnívala, že by měl být používán bázový poplatek
      namísto modifikovaného, neboť `sendrawtransaction` i `testmempoolaccept`
      používají ve svých kontrolách bázový poplatek. Zdálo by se to
      více konzistentní. Jelikož je `prioritisetransaction` (díky kterému
      jsou bázové a modifikované poplatky odlišné) obecně používán pouze
      těžaři, neznamená v praxi volba poplatku výrazný rozdíl."
  a3link="https://bitcoincore.reviews/28950#l-69"

  q4="Maximální jednotkový poplatek validujeme proti modifikovanému
      jednotkovému poplatku jednotlivých transakcí v balíčku a ne proti
      jednotkovému poplatku balíčku. Kdy to může přinést nepřesnosti?"
  a4="Když je potomek v balíčku odmítnut, protože jeho modifikovaný
      jednotkový poplatek přesahuje `maxfeerate`, ale ne v případě
      kontroly celého balíčku."
  a4link="https://bitcoincore.reviews/28950#l-84"

  q5="Vzhledem k této možné nepřesnosti, proč raději nekontrolovat
      `maxfeerate` proti jednotkovému poplatku balíčku?"
  a5="Protože to může způsobit jinou nepřesnost. Předpokládejme, že má
      transakce A nulový poplatek a B ho pomocí CPFP navýší.
      A i B jsou fyzicky velké, takže ani jedna z nich nepřevýší
      `maxfeerate`. Ale nyní je přidána C, která má vysoký jednotkový
      poplatek a utrácí z A i B. (Tato topologie balíčku je povolená,
      neboť má jen dvě úrovně, i když bylo ukázáno, že volání
      `submitpackage` tuto topologii nedovoluje.) V tomto případě
      by transakce C byla akceptována, protože A a B absorbují část jejích
      poplatků. C by však měla být odmítnuta."
  a5link="https://bitcoincore.reviews/28950#l-108"

  q6="Proč nemůže být `maxfeerate` zkontrolován ihned po dekódování stejně jako
      `maxburnamount`?"
  a6="Protože, jak známo, vstup transakce nestanoví hodnotu vstupu. Ta je
      známa až po vyhledání rodičovského výstupu. Jednotkový poplatek vyžaduje,
      aby byl znám poplatek, což vyžaduje znalost hodnoty vstupu."
  a6link="https://bitcoincore.reviews/28950#l-141"

  q7="Jak se liší kontrola `maxfeerate` ve volání `testmempoolaccept`od
      volání `submitpackage`? Proč nemůžou být stejné?"
  a7="`submitpackage` používá modifikované poplatky, zatímco `testmempoolaccept`
      používá bázové poplatky, jak bylo vysvětleno výše. Dále je
      kontrola jednotkového poplatku provedena po zpracování balíčku
      v rámci `testaccept`, protože transakce nejsou po zpracování přidány
      do mempoolu a zveřejněny. Můžeme tedy bezpečně zkontrolovat `maxfeerate`
      a vrátit vhodnou chybovou zprávu. To stejné nelze učinit v `submitpackage`,
      protože transakce balíčku již mohly být do mempoolu přijaty a odeslány
      dalším uzlům. Kontrola by byla nadbytečná."
  a7link="https://bitcoincore.reviews/28950#l-153"
%}

## Významné změny kódu a dokumentace

_Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Bitcoin Inquisition][bitcoin inquisition repo] a [repozitáři BINANA][binana
repo]._

- [Bitcoin Core #28948][] přidává podporu (ale neaktivuje) pro [přeposílání
  transakcí verze 3][topic v3 transaction relay]. Umožní tím kterékoliv
  v3 transakci mající nepotvrzeného rodiče vstoupit do mempoolu dle
  běžných pravidel přijetí transakce. Tato v3 transakce může mít poplatek
  navýšen pomocí [CPFP][topic cpfp], avšak pouze pokud má potomek
  1 000 vbyte nebo méně. Každý v3 rodič může mít v mempoolu pouze jediného
  nepotvrzeného potomka a každý potomek může mít pouze jednoho nepotvrzeného
  rodiče. Obě transakce mohou být kdykoliv [nahrazeny poplatkem][topic rbf] (RBF).
  Pravidla se dotýkají pouze pravidel přeposílání Bitcoin Core. Na úrovni
  konsenzu jsou v3 transakce validovány stejným způsobem jako transakce verze 2
  dle definice v [BIP68][]. Nová pravidla mají za cíl pomoci protokolům
  používajícím kontrakty (jako je LN) zajistit, aby mohly být jejich předem
  připravené transakce rychle potvrzeny s minimálními dodatečnými poplatky
  na vymanění se z [pinningových útoků][topic transaction pinning].

- [Core Lightning #6785][] bude ve výchozím stavu v bitcoinové síti vytvářet
  kanály ve stylu [anchorů][topic anchor outputs]. Neanchorové kanály budou
  nadále používány pro kanály v Elements [sidechainech][topic sidechains].

- [Eclair #2818][] maximalizuje počet vstupů, o kterých se peněženka Eclair
  domnívá, že je může bezpečně utratit. Činí tak odhalováním některých případů,
  ve kterých je velmi nepravděpodobné, že by existující nepotvrzená transakce
  dosáhla potvrzení. Eclair používá pro správu UTXO pro onchain platby a navyšování
  poplatků transakcí peněženku Bitcoin Core. Je-li UTXO pod kontrolou této peněženky
  použito jako vstup nějaké transakce, peněženka Bitcoin Core nepovolí vytváření
  dalších nesouvisejících transakcí s tímto vstupem. Pokud však tuto transakci
  nelze utratit kvůli dvojímu utracení jiného vstupu, povolí peněženka Bitcoin Core
  jiné utracení tohoto vstupu v rámci jiné transakce. Avšak pokud rodiče
  této transakce nelze utratit kvůli jiné potvrzené verzi, peněženka Bitcoin Core
  nepovolí automaticky nové utracení tohoto UTXO. Eclair může nezávisle dvojí utracení
  rodičovské transakce detekovat a instruovat peněženku Bitcoin Core, aby
  dřívější pokus o alokaci UTXO [anulovala][rpc abandontransaction] a umožnila
  jej znovu utratit.

- [Eclair #2816][] umožňuje provozovateli uzlu zvolit maximální částku, kterou
  je pro potvrzení commitment transakce ochoten utratit na [anchor výstupu][topic
  anchor outputs]. Dříve Eclair utrácel až pět procent hodnoty kanálu, což
  může být pro některé hodnotné kanály příliš vysoká částka. Nový výchozím nastavením
  je nejvyšší jednotkový poplatek navržený odhadcem jednotkového poplatku až
  do maximální výše 10 000 sat. Eclair bude i nadále platit částku rovnající
  se až hodnotám [HTLC][topic htlc], kterým se blíží doba expirace. Tato
  částka může být vyšší než 10 000 sat.

- [LND #8338][] přidává funkce pro nový protokol kooperativního zavírání
  kanálů (viz [zpravodaj č. 261][news261 close] a [BOLTs #1096][]).

- [LDK #2856][] upravuje implementaci [zaslepeného routování][topic rv routing],
  aby zajistil, že má příjemce dostatečný blokový čas k nárokování platby.
  Aktualizace je založena na změně specifikaci v [BOLTs #1131][].

- [LDK #2442][] přidává do `ChannelDetails` podrobnosti o každém [HTLC][topic htlc]
  čekajícím na vyřízení. To umožní uživatelům API zjistit, jaký krok
  je potřeba dále učinit k posunu HTLC blíže k přijetí nebo odmítnutí.

- [Rust Bitcoin #2451][] odstraňuje požadavek, aby HD derivační cesta začínala
  na `m`. V [BIP32][] je `m` použito jako proměnná představující hlavní („master”)
  soukromý klíč. Při odkazování na pouhou derivační cestu je `m` nadbytečné
  a může v některých případech být dokonce chybné.

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 15:00" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="28948,6785,2818,2816,8338,2856,2442,2451,1131,1096" %}
[fsfe]: https://fsfe.org/activities/ilovefs/index.en.html
[fsf]: https://www.fsf.org/blogs/community/i-love-free-software-day-is-here-share-your-love-software-and-a-video
[sanders future]: https://delvingbitcoin.org/t/v3-and-some-possible-futures/523
[news261 close]: /cs/newsletters/2023/07/26/#jednodussi-zavirani-ln-kanalu
[teinturier better]: https://delvingbitcoin.org/t/v3-transaction-policy-for-anti-pinning/340/37
[daftuar retrospective]: https://delvingbitcoin.org/t/analysis-of-attempting-to-imbue-ln-commitment-transaction-spends-with-v3-semantics/527/
[news286 imbued]: /cs/newsletters/2024/01/24/#vstipena-v3-logika
[review club 28950]: https://bitcoincore.reviews/28950
[review club 24152]: https://bitcoincore.reviews/24152
[review club 24538]: https://bitcoincore.reviews/24538
[review club 27501]: https://bitcoincore.reviews/27501
[news287 kindred]: /cs/newsletters/2024/01/31/#pribuzenske-nahrazovani-poplatkem
[migration email]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2024-February/022327.html
[news276 ml]: /cs/newsletters/2023/11/08/#hosting-emailove-skupiny
[news288 ml]: /cs/newsletters/2024/02/07/#aktualizace-migrace-emailove-skupiny-bitcoin-dev
