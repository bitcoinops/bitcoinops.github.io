---
title: 'Zpravodaj „Bitcoin Optech” č. 340'
permalink: /cs/newsletters/2025/02/07/
name: 2025-02-07-newsletter-cs
slug: 2025-02-07-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Zpravodaj tento týden oznamuje opravenou zranitelnost postihující LDK,
shrnuje diskuzi o gossipu s nulovou znalostí pro oznamování LN kanálů,
popisuje objevení starších studií, které mohou být použité pro hledání
optimální linearizace clusterů, poskytuje aktualizaci vývoje protokolu
Erlay, který má snížit síťové nároky přeposílání transakcí, nahlíží na
kompromisy mezi různými skripty pro implementaci LN dočasných anchorů,
sdílí návrh na emulaci opkódu `OP_RAND` způsobem zachovávajícím soukromí
a bez nutnosti změn konsenzu a poukazuje na obnovenou diskuzi o snížení
minimálního transakčního poplatku.

## Novinky

- **Zranitelnost LDK během vynuceného zavření kanálu:** Matt Morehouse
  zaslal do fóra Delving Bitcoin [příspěvek][morehouse forceclose]
  s ohlášením zranitelnosti postihující LDK, kterou [zodpovědně nahlásil][topic
  responsible disclosures] a která byla opravena v LDK verzi 0.1.1.
  Podobně jako v případě jiné nedávno zveřejněné zranitelnosti LDK
  (viz [zpravodaj č. 339][news339 ldkvuln]), i zde smyčka v kódu LDK
  skončila, jakmile vyřešila první neobvyklý případ, aniž by pokračovala
  řešením dalších případů stejného druhu. V tomto případě to mohlo vést
  k neúspěšnému urovnání čekajících [HTLC][topic htlc] v otevřených
  kanálech, načež byla poctivá protistrana donucena zavřít kanály
  a urovnat tak HTLC onchain.

  Zřejmě to k přímé krádeži vést nemohlo, ale oběť musela platit poplatky
  za zavření kanálů, za otevření nových kanálů a nemohla vydělávat na
  poplatcích za přeposílání.

  Morehouseův kvalitní příspěvek zabíhá do dalších podrobností a navrhuje,
  jak by bylo možné v budoucnosti podobným chybám předejít.

- **Gossip s nulovou znalostí pro oznamování LN kanálů:** Johan Halseth
  zaslal do fóra Delving Bitcoin [příspěvek][halseth zkgoss] s popisem
  rozšíření navrhovaného protokolu [oznamování kanálů][topic channel
  announcements] 1.75, který by ostatním uzlům umožnil ověřit, že za
  kanálem stojí skutečná otevírací transakce (čímž je možné zabránit
  několika laciným druhům DoS), avšak bez nutnosti odhalit, které UTXO
  otevírací transakci tvoří, což pozitivně dopadá na soukromí. Halsethovo
  rozšíření staví na jeho předchozím výzkumu (viz [zpravodaj č. 321][news321
  zkgoss]), který používá [utreexo][topic utreexo] a systém dokladů
  s nulovou znalostí (zero-knowledge proof system, ZK). Byl by použit
  s [jednoduchými taprootovými kanály][topic simple taproot channels]
  založenými na [MuSig2][topic musig].

  Diskuze se soustředila na kompromisy mezi Halsethovou myšlenkou,
  pokračujícím používáním veřejného gossipu a jinými metodami generování ZK
  dokladů. Mezi vyjádřené obavy patří zajištění, aby mohly všechny LN
  uzly doklady rychle ověřovat, a složitost systému dokladů a ověřování,
  neboť bude muset být implementován všemi LN uzly.

  Diskuze v době psaní nadále probíhala.

- **Objevení staršího článku užitečného pro hledání optimální linearizace clusterů:**
  Stefan Richter zaslal do fóra Delving Bitcoin [příspěvek][richter cluster],
  ve kterém odkazuje na vědecký článek z roku 1989, který nalezl.
  Článek obsahuje algoritmus (a důkaz), který může být použit k efektivnímu
  nalezení podmnožiny s nejvyšším jednotkovým poplatkem ve skupině transakcí,
  která zůstane topologicky validní, bude-li tato podmnožina začleněna do bloku.
  Též nalezl [implementaci v C++][mincut impl] několika algoritmů řešících
  podobné problémy, které „by měly být v praxi ještě rychlejší.”

  Předchozí práce na [mempoolu clusterů][topic cluster mempool] se soustředila
  na zjednodušování a zrychlování porovnávání různých linearizací, aby
  mohla být použita ta nejlepší. Díky tomu by mohl být používán rychlý algoritmus
  k okamžité linearizaci clusteru a pomalejší – avšak optimálnější – algoritmus
  by mohl běžet v okamžiku, kdy by procesor nebyl využit naplno. Pokud by
  však tento algoritmus z roku 1989 (nebo jiný) řešící _problém uzávěru
  s maximálním poměrem vah_ (maximum-ratio closure problem) běžel dostatečně
  rychle, mohl by být používán ve všech případech. I kdyby byl mírně
  pomalejší, mohl by být používán jako algoritmus, který běží v období
  s dostupnými procesorovými cykly.

  Pieter Wuille [odpověděl][wuille cluster] s nadšením a několika dalšími
  otázkami. Dále [popsal][wuille sp cl] nový algoritmus linearizace clusterů,
  který pracovní skupina zabývající se mempoolem clusterů vyvíjí. Tento nový
  algoritmus vychází z diskuze z Bitcoin Research Week, jejímiž účastníky
  byli Dongning Guo a Aviv Zohar. Převádí tento problém na jiný, který
  lze řešit [lineárním programováním][linear programming] a který se jeví
  být rychlým a snadno implementovatelným a navíc vrací optimální
  linearizaci – pokud je konečný. Chybí však ještě dokázat, že algoritmus
  konečný je a že skončí v rozumném čase.

  I když se to přímo bitcoinu netýká, přišel nám zajímavý Richterův
  [popis][richter deepseek], jak pomocí LLM od DeepSeek článek z roku
  1989 nalezl.

  V době psaní zpravodaje diskuze stále probíhala a byly zkoumány další
  články o této doméně. Richter napsal: „zdá se, že náš problém, nebo
  spíše jeho obecné řešení, které se nazývá _parametrický minimální řez
  s monotónními kapacitami mezi zdrojem a stokem_ (source-sink-monotone
  parametric min-cut), má použití v agregaci polygonů při zjednodušování
  map a v počítačovém vidění.”

- **Novinky u Erlay:** Sergi Delgado popsal v několika příspěvcích
  do fóra Delving Bitcoin výsledek roční práce implementování
  [Erlay][topic erlay] v Bitcoin Core. Začíná [přehledem][delgado erlay],
  jak funguje současné přeposílání transakcí (tzv. _fanout_, přibližně
  „rozvíření” či „rozvětvení”) a jaké jeho změny Erlay navrhuje. Poznamenává,
  že nějaký fanout zůstane i v síti, kde každý uzel Erlay podporuje, neboť
  „fanout je účinnější a výrazně rychlejší než synchronizace množin (set reconciliation),
  pokud přijímající uzel oznamovanou transakci nezná.“

  Používání kombinace fanoutu a synchronizace vyžaduje vybrat, kdy
  použít kterou metodu a se kterými spojeními. Jeho výzkum se tedy
  soustředí na hledání optimálního výběru:

  - [Filtrování na základě znalosti transakce][sd1] zkoumá, zda by měl uzel
    mezi spojení pro fanout zahrnout i taková, která transakci již určitě mají.
    Například: náš uzel má deset spojení a tři z nich nám již oznámila
    nějakou transakci. Pokud chceme náhodně zvolit tři další spojení pro
    fanout této transakce, měli bychom vybírat ze všech deseti spojení
    nebo jen těch sedmi, která nám tuto transakci neoznámila? Simulace
    překvapivě odhalily, že „mezi těmito volbami není výrazný rozdíl.”
    Delgado tento překvapivý výsledek zkoumal a usoudil, že by měla
    být zvažována všechna spojení (čili žádné filtrování).

  - [Kdy vybírat kandidáty pro fanout][sd2] zkoumá, kdy by měl uzel
    vybírat spojení pro fanout transakce (zbytek použije synchronizaci
    pomocí Erlay). Uvažuje se nad dvěma možnostmi: krátce po validaci
    nové transakce a přidání do fronty pro přeposlání nebo když nastane
    čas pro přeposlání transakce (uzly neodesílají transakce okamžitě;
    pro ztížení odhadování topologie sítě a pro ochranu soukromí původce
    transakce čekají náhodou dobu). Výsledky simulace opět ukázaly, že
    „neexistuje významný rozdíl,” i když „rozdíly mohou nastat v síti
    s částečnou podporou Erlay.”

  - [Kolik spojení by mělo obdržet fanout][sd3] zkoumá míru fanoutu.
    Vyšší míra urychluje propagaci transakcí, ale snižuje úsporu přenosového
    pásma. Kromě míry fanoutu testoval Delgado též zvyšování počtu odchozích
    spojení, což je jeden z cílů nasazení Erlay. Simulace ukazuje, že
    aktuální přístup v Erlay snižuje využití přenosového pásma zhruba o 35 %
    při současném počtu odchozích spojení (osm) a 45 % při 12 odchozích
    spojeních. Latence se však zvyšuje zhruba o 240 %. Příspěvek na grafech
    zobrazuje další konfigurace a jejich kompromisy. Výsledky simulace budou
    užitečné nejen pro výběr parametrů, ale podle Delgada též pro
    hodnocení alternativních algoritmů pro fanout, které mohou nabídnout
    příznivější kompromisy.

  - [Míra fanoutu dle způsobu obdržení transakce][sd4]
    zkoumá, zda by měla být míra fanoutu upravena podle toho, jestli
    byla transakce obdržena přes fanout nebo synchronizaci. A pokud by
    upravena být měla, jakým způsobem? Fanout je rychlejší a účinnější
    během počátku života přeposílané transakce, ale plýtvá přenosovým
    pásmem, když už transakce dosáhne většinu uzlů. Neexistuje možnost,
    jak by mohl uzel přímo určit, kolik jiných uzlů transakci již vidělo.
    Avšak pokud spojení, které mu transakci poslalo jako první, použilo
    fanout a nečekalo na další kolo synchronizace, jedná se zřejmě o
    transakci v rané fázi propagace. Tato data mohou být použita k mírnému
    navýšení vlastní míry fanoutu pro tuto konkrétní transakci a tím
    jí pomoci k rychlejší propagaci. Delgado tuto myšlenku simuloval a
    našel upravený poměr fanoutu, který snižuje čas propagace o 18 %, ale
    zvyšuje využití přenosového pásma pouze o 6,5 % oproti kontrolní simulaci,
    ve které použil stejnou míru fanoutu pro všechny transakce.

- **Kompromisy dočasných anchor skriptů v LN:** Bastien Teinturier
  zaslal do fóra Delving Bitcoin [příspěvek][teinturier ephanc] s žádostí
  o názory, které [dočasné anchor][topic ephemeral anchors] skripty by
  měly nahradit existující [anchor výstupy][topic anchor outputs] jako
  jeden z výstupů LN commitment transakcí založených na [TRUC][topic v3
  transaction relay]. Použitý skript určuje, kdo a za jakých podmínek
  může commitment transakci zaplatit [navýšení poplatku pomocí CPFP][topic
  cpfp]. Představil čtyři možnosti:

  - _Pay-to-anchor (P2A) skript:_ ten zanechává onchain minimální stopu,
    avšak kvůli němu zřejmě skončí veškerý přebytek hodnoty [ořezaných HTLC][topic
    trimmed htlc] u těžařů (jako je tomu dnes).

  - _Anchor s klíčem jednoho účastníka:_ umožní získat část hodnoty ořezaných
    HTLC účastníkovi, který je ochoten čekat několik desítek bloků, než
    bude moci peníze ze zavřeného kanálu použít. Každý, kdo vynuceně
    uzavírá kanál, musí čekat v jakémkoliv případě. Avšak ani jedna strana
    kanálu nemůže platbu poplatku delegovat na třetí stranu, aniž by jí
    nedaly možnost ukrást všechny prostředky kanálu. Pokud s protistranou
    soupeříte o získání přebytku, pravděpodobně stejně skončí u těžaře.

  - _Anchor se sdíleným klíčem:_ též umožňuje získat přebytek hodnoty
    HTLC a umožňuje delegovat, ale ten, na kterého delegujete, může s vámi
    a s vaší protistranou soupeřit o nárokování přebytku hodnoty. V případě
    soupeření zřejmě opět připadne přebytek hodnoty těžařovi.

  - _Anchor s duálním klíčem:_ každý účastník má možnost nárokovat přebytek
    hodnoty ořezaných HTLC bez čekání. Avšak delegování není možné. Obě strany
    kanálu spolu stále mohou soupeřit.

  V odpovědích Gregory Sanders [poznamenal][sanders ephanc], že v různých
  případech lze používat různá schémata. Například P2A by mohlo být použito,
  když nejsou žádná ořezaná HTLC. V ostatních případech lze použít některý
  s anchorů s klíčem. Pokud by byla ořezaná hodnota nad [hodnotou prachu][topic
  uneconomical outputs], mohla by být namísto anchor výstupu přidána do
  commitment transakce. Dále varoval, že by to mohlo vytvořit „podivnou
  situaci, kdy by se protistrana mohla pokusit nakopnout ořezanou částku a
  sama si ji vzít.“ David Harding v [pozdějším příspěvku][harding ephanc]
  toto téma rozšířil.

  Antoine Riard [varoval][riard ephanc] proti používání P2A kvůli riziku,
  že těžaři budou provádět [pinning transakcí][topic transaction pinning]
  (viz [zpravodaj č. 339][news339 pincycle]).

  V době psaní diskuze nadále probíhala.

- **Emulace OP_RAND:** Oleksandr Kurbatov zaslal do fóra Delving Bitcoin
  [příspěvek][kurbatov rand] o interaktivním protokolu, který dvěma stranám
  umožňuje vytvořit kontrakt platící způsobem, který ani jedna ze stran
  nemůže předvídat. V důsledku se tak jedná o náhodný způsob. [Dřívější
  práce][dryja pp] na bitcoinových _pravděpodobnostních platbách_ používala
  pokročilé skripty, avšak Kurbatovův přístup využívá speciálně konstruované
  veřejné klíče, které vítězovi umožní utratit prostředky v kontraktu.
  Tento způsob nabízí větší soukromí a flexibilitu.

  Optech nebyl schopen protokol analyzovat, ale žádných zřejmých problémů
  jsme si nevšimli. Doufáme, že se myšlence dostane další diskuze,
  neboť pravděpodobnostní platby mají několik aplikací, například mohou
  uživatelům umožnit poslat onchain částky, které by jinak byly
  [neekonomické][topic uneconomical outputs], jako např. u [ořezaných HTLC][topic
  trimmed htlc].

- **Diskuze o snížení minimálního poplatku pro přeposílání transakcí:**
  Greg Tonoski zaslal do emailové skupiny Bitcoin-Dev [příspěvek][tonoski
  minrelay] o snížení [výchozího minimálního jednotkového poplatku pro
  přeposílání transakcí][topic default minimum transaction relay feerates].
  Toto téma se opakovaně diskutuje (a Optech o něm přináší souhrny)
  od roku 2018, naposledy v roce 2022 (viz [zpravodaj č. 212][news212 relay],
  _angl._). Za zmínku stojí, že nedávno zveřejněná zranitelnost
  (viz [zpravodaj č. 324][news324 largeinv]) odhalila možný problém,
  který mohl postihnout uživatele a těžaře, kteří v minulosti toto
  nastavení snížili. Optech bude o případném pokračování diskuze
  informovat.

## Diskuze o změnách konsenzu

_Měsíční rubrika shrnující návrhy a diskuze o změnách pravidel
bitcoinového konsenzu._

- **Aktualizace návrhu na soft fork pročištění konsenzu:** Antoine Poinsot
  zaslal do vlákna ve fóru Delving Bitcoin o [soft forku na pročištění
  konsenzu][topic consensus cleanup] několik příspěvků, ve kterých
  navrhl změnu parametrů:

  - [Nový limit na sigops u zastaralých vstupů][ap1]: v soukromém vlákně se
    Poinsot a několik dalších přispěvatelů pokusilo vytvořit regtestový blok,
    jehož validace by trvala co nejdelší možnou dobu za použití známých
    problémů validace zastaralých (předsegwitových) transakcí. Poté
    zjistil, že by mohl „tento nejhorší blok přizpůsobit tak, aby
    byl validní i navzdory [obraně][ccbip] původně navržené v roce 2019”
    (viz [zpravodaj č. 36][news36 cc], _angl._). To ho vedlo k návrhu
    na jiný způsob ochrany: omezení maximálního počtu operací nad podpisy
    (sigop) v zastaralých transakcích na 2 500. Každé vykonání opkódu
    `OP_CHECKSIG` se počítá jako jeden sigop a každé vykonání
    `OP_CHECKMULTISIG` se počítá až jako 20 sigops (dle počtu použitých
    veřejných klíčů). Jeho analýza ukazuje, že by to snížilo čas validace
    nejhoršího případu o 97,5 %.

    Stejně jako v případě jakékoliv změny tohoto druhu i zde existuje
    riziko [neúmyslných konfiskací][topic accidental confiscation], protože
    kvůli novému pravidlu by byly dříve podepsané transakce neplatné.
    Pokud znáte někoho, kdy potřebuje u zastaralých transakcí
    více než 2 500 sigops nebo více než 2 125 v případě vícenásobných
    podpisů[^2kmultisig], prosíme upozorněte Poinsota nebo další vývojáře
    protokolu.

  - [Prodloužení přechodného období ohýbání času na 2 hodiny][ap2]: dříve tento návrh
    na pročištění zakazoval prvnímu bloku nové periody složitosti mít
    v hlavičce časové razítko více než 600 sekund před časovým razítkem
    předchozího bloku. Díky tomu by konstantní množství hashrate nemohlo
    zneužít zranitelnosti s [ohýbáním času][topic time warp] k produkci
    více než jednoho bloku za 10 minut.

    Poinsot nyní akceptuje použití 7 200 sekund (2 hodiny), jak původně
    navrhl Sjors Provoost, jako hodnotu, se kterou je mnohem méně
    pravděpodobné, že by vedla k neúmyslně vytvořenému nevalidnímu
    bloku. Na druhou stranu umožňuje velmi trpělivému útočníkovi
    s kontrolou více než 50 % celkového hashrate pomocí ohýbání
    času snížit během měsíců složitost, i kdyby hashrate zůstával konstantní
    nebo se zvyšoval. To by byl veřejně patrný útok a síť by měla
    měsíce na reakci. Ve svém příspěvku Poinsot shrnuje předešlé
    argumenty (viz [zpravodaj č. 335][news335 cc] pro náš méně detailní
    souhrn) a uzavírá slovy: „navzdory dosti chabým argumentům ve
    prospěch prodloužení přechodného období nám nebrání náklady na jeho učinění
    chybovat na bezpečné straně.”

    Ve vlákně věnovaném diskuzi o prodloužení období [hovořili][wuille erlang]
    vývojáři Zawy a Pieter Wuille, jak je 600 sekund, o kterých by se mohlo
    zdát, že umožňují pomalé snižování složitosti na její minimum,
    ve skutečnosti dostatečná hodnota bránící více než jednomu
    drobnému snížení složitosti. Konkrétně sledovali dopad chyby v úpravě
    složitosti („o jedničku mimo“) a asymetrii [Erlangova rozložení][erlang]
    na přesně se měnící složitost. Zawy následně uzavřel slovy: „Nejde o to, že
    by opravy Erlanga a ‚2015kové díry’ nebyly potřeba, ale
    že 600 sekund před předchozím blokem není 600sekundová lež, je to
    1200sekundová lež, protože jsme předpokládali časové razítko
    600 sekund po něm.”

  - [Oprava duplikovaných transakcí][ap3]: na základě žádosti o zpětnou vazbu
    od těžařů (viz [zpravodaj č. 332][news332 cleanup]) o možných negativních
    dopadech řešení problému [duplikovaných transakcí][topic duplicate transactions]
    vybral Poinsot konkrétní řešení, které bude součástí návrhu na
    pročištění: požadavek, aby byla výška předchozího bloku obsažena
    v poli `nLockTime` všech mincetvorných (coinbasových) transakcí.
    Tento návrh přináší dvě výhody: umožňuje [extrahovat][corallo duplocktime]
    výšku bloku bez nutnosti parsovat skript a umožňuje [vytvářet][harding
    duplocktime] kompaktní doklad o výšce bloku založený na SHA256
    (v nejhorším případě kolem 700 bajtů, mnohem méně než 1MB doklad,
    který by byl potřeba dnes bez pokročilého systému dokladů).

    Tato změna nebude mít dopad na běžného uživatele, ale bude nakonec
    vyžadovat, aby těžaři aktualizovali software, který používají
    pro generování mincetvorných transakcí. Pokud kterýkoliv z těžařů
    vidí tento návrh jako problémový, prosíme kontaktujte Poinsota nebo
    jiného vývojáře.

  Poinsot dále zaslal do emailové skupiny Bitcoin-Dev [příspěvek][ap4]
  s novinkami o své práci a aktuálním stavem návrhu.

- **Žádost o návrh kovenantu pro Braidpool:** Bob McElrath
  zaslal do fóra Delving Bitcoin [příspěvek][mcelrath braidcov], ve
  kterém žádá vývojáře navrhující [kovenanty][topic covenants], aby
  zvážili, jak by mohly jejich oblíbené nebo nové návrhy pomoci při
  vytváření efektivního decentralizovaného [těžebního poolu][topic pooled
  mining]. Návrh současného prototypu pro Braidpool používá federaci
  podepisujících entit, které pomocí [prahových podpisů][topic threshold
  signature] obdrží podíly dle svých příspěvků do celkového hashrate poolu.
  To umožňuje většinovému podílu těžařů či skupiny těžařů
  krást výplaty menším těžařům. McElrath by raději používal kovenant,
  který by zajistil, že by každý těžař mohl z poolu vyvést pouze prostředky
  poměrné ke svým příspěvkům. V textu poskytl seznam konkrétních
  požadavků a též je vítán důkaz o nemožnosti.

  V době psaní zpravodaje byl příspěvek bez reakcí.

- **Deterministický výběr transakcí a závazek k mempoolu:**
  vlákno z dubna 2024 získalo minulý měsíc novou pozornost. Již dříve
  zaslal Bob McElrath [příspěvek][mcelrath dtx] o tom, jak by se těžaři
  museli zavazovat k transakcím ve svém mempoolu a pouze tehdy by mohli
  do svých bloků zařadit transakce, které byly deterministicky vybrané
  z předchozích závazků. McElrath vidí dvě možnosti použití:

  - _Globálně pro všechny těžaře:_ to by odstranilo „riziko a odpovědnost
    za výběr transakcí“ ve světě, kde jsou těžaři často velké korporace,
    které se musí podrobovat zákonům, regulacím a radám risk managerů.

  - _Lokálně pro jeden pool:_ nabízí většinu výhod globálně deterministického
    algoritmu, ale k implementaci nevyžaduje žádné změny konsenzu.
    Navíc může ušetřit velké množství síťového provozu mezi účastníky
    decentralizovaného [těžebního poolu][topic pooled mining], jako
    je Braidpool, jelikož tento algoritmus určuje, které transakce musí
    _kandidát na blok_ obsahovat, proto jakýkoliv _share_ vytvořený
    z tohoto bloku nemusí explicitně poskytovat žádná data transakcí
    ostatním účastníkům poolu.

  Anthony Towns [popsal][towns dtx] několik potenciálních problémů s
  globální možností se změnou konsenzu: jakákoliv změna výběru transakcí
  by vyžadovala změnu konsenzu (a možná i hard fork) a žádná nestandardní
  transakce by neměla možnost vytěžení ani ve spolupráci s těžařem.
  Mezi změny pravidel z posledních několika let, které by vyžadovaly změnu
  konsenzu, patří: [TRUC][topic v3 transaction relay], upravená [RBF][topic rbf]
  pravidla a [dočasné anchory][topic ephemeral anchors]. Towns odkázal na
  [známý případ][bitcoin core #26348], ve kterém byly neúmyslně zaseknuty
  milióny dolarů v nestandardním skriptu a které pomohl vysekat kooperující
  těžař.

  Zbytek diskuze se soustředil na lokální přístup, tak jak byl koncipován
  pro Braidpool. Neobjevily se žádné námitky a dodatečná diskuze k tématu
  algoritmu úpravy složitosti (viz následující položku v této rubrice)
  ukázala, jak by mohl být obzvláště užitečný pro pool, který vytváří
  bloky s mnohem větší kadencí než bitcoin a kde by determinismus
  výběru transakcí výrazně snížil síťové nároky, latenci a náklady
  na validaci.

- **Rychlý algoritmus úpravy složitosti u DAG blockchainů:**
  vývojář Zawy zaslal do fóra Delving Bitcoin [příspěvek][zawy daadag]
  o [algoritmu úpravy složitosti][topic daa] (difficulty adjustment algorithm,
  DAA) pro blockchain v podobě orientovaného acyklického grafu (directed
  acyclic graph, DAG). Algoritmus byl [navržen][bp pow] pro použití
  v místním konsenzu mezi účastníky Braidpoolu (a ne pro globální
  bitcoinový konsenzus), avšak diskuze se opakovaně dotýkala i aspektů
  globálního konsenzu.

  V bitcoinovém blockchainu zavazuje každý blok právě jednomu rodiči.
  Několik potomků může zavazovat stejnému rodiči, ale uzly budou za
  validní v _nejlepším řetězci_ považovat pouze jeden z nich. V DAG
  blockchainu může každý blok zavázat jednomu nebo více rodičům a může
  mít nula nebo více potomků, které mu zavazují. V DAG blockchainu
  lze mít ve stejné generaci několik validních bloků v nejlepším blockchainu.

  ![Illustration of a DAG blockchain](/img/posts/2025-02-dag-blockchain-cs.png)

  Navržený DAA se zaměřuje na průměrný počet rodičů v naposledy spatřených
  100 validních blocích. Pokud se průměrný počet rodičů zvýší, algoritmus
  zvýší složitost; pokud je méně rodičů, složitost klesá. Dle Zawyho
  cíl dvou rodičů v průměru poskytuje nejrychlejší konsenzus. Na rozdíl
  od bitcoinového DAA nepotřebuje mít tento navrhovaný DAA pojem o čase,
  avšak vyžaduje, aby účastníci poolu ignorovali bloky, které obdrží
  mnohem později než ostatní bloky stejné generace; jelikož by jinak
  nebylo možné dosáhnout konsenzu, byly by nakonec DAG s více proof of work
  upřednostňovány před těmi s méně proof of work. Bob McElrath, author tohoto
  DAA, problém a možné řešení [analyzoval][mcelrath daa-latency].

  Pieter Wuille [napsal][wuille prior], že tento návrh se podobá
  [nápadu z roku 2012][miller stale] od Andrew Millera. Zawy [souhlasil][zawy
  prior] a McElrath [přidá][mcelrath prior] do svého článku citaci.
  Sjors Provoost [diskutoval][provoost dag] složitost práce s DAG
  řetězci v současné architektuře Bitcoin Core, ale poznamenal, že
  libbitcoin by ji mohl zjednodušit a [utreexo][topic utreexo] zefektivnit.
  Zawy podrobil protokol rozsáhlé [simulaci][zawy sim] a naznačil,
  že pracuje na simulacích dalších variant protokolu, aby nalezl
  nejlepší kompromis.

  Poslední příspěvek ve vlákně se objevil zhruba měsíc před sepsáním
  tohoto shrnutí, očekáváme však, že Zawy a vývojáři Braidpoolu
  v analýze a implementaci protokolu pokračují.

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [BDK Wallet 1.1.0][] je vydáním této knihovny pro budování aplikací
  s podporou bitcoinu. Ve výchozím nastavení používá transakce verze 2
  (čímž zlepšuje soukromí, neboť BDK transakce splynou s transakcemi
  jiných peněženek, které musí používat v2 transakce za účelem
  podpory relativních časových zámků, viz [zpravodaj č. 337][news337 bdk]).
  Dále přidává podporu [kompaktních filtrů bloků][topic compact block
  filters] (viz [zpravodaj č. 339][news339 bdk-cpf]), opravuje chyby
  a přináší další vylepšení.

- [LND v0.18.5-beta.rc1][] je kandidátem na menší vydání této populární
  implementace LN uzlu.

## Významné změny kódu a dokumentace

_Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo] a [repozitáři BINANA][binana repo]._

- [Bitcoin Core #21590][] implementuje algoritmus [modulární inverze][modularinversion]
  založený na safegcd určený pro MuHash3072 (viz zpravodaje [č. 131][news131 muhash] a
  [č. 136][news136 gcd], oba _angl._). Kód je převzatý z libsecp256k1, navíc
  sjednocuje kód pro 32- a 64bitovou architekturu. Výsledky výkonnostního testu
  ukazují zhruba 100násobné zlepšení na x86_64, díky čemuž došlo ke snížení
  výpočtu MuHash z 5,8 ms na 57 μs.

- [Eclair #2983][] mění synchronizaci routovací tabulky během opakovaného
  připojení. Nově synchronizuje [oznámení kanálů][topic channel announcements]
  pouze se spojeními s nejvyšší sdílenou kapacitou kanálu. Výsledkem
  je redukce síťového provozu. Dále bylo upraveno výchozí chování whitelistu
  synchronizace (viz [zpravodaj č. 62][news62 whitelist], _angl._): pokud chce
  uživatel deaktivovat synchronizaci se spojeními mimo whitelist, musí nastavit
  `router.sync.peer-limit` na 0 (výchozí hodnota je 5).

- [Eclair #2968][] přidává podporu [splicingu][topic splicing] ve veřejných
  kanálech. Jakmile se splicingová transakce potvrdí a uzamkne na obou
  stranách, uzly si vymění podpisy a zveřejní do sítě `channel_announcement`.
  Eclair nedávno přidal sledování nevlastních splicingů (viz [zpravodaj
  č. 337][news337 splicing]). Toto PR dále znemožňuje používání `short_channel_id`
  pro routování v soukromých kanálech; namísto toho používá `scid_alias`,
  aby neodhalil UTXO kanálu.

- [LDK #3556][] vyvolá selhání [HTLC][topic htlc] ve zpětném sledu, pokud
  se příliš přiblíží času expirace. Dříve uzel čekal další tři bloky navíc,
  aby měla nárokovací transakce čas na potvrzení. Avšak tato prodleva
  zvyšovala riziko vynuceného zavření tohoto kanálu. Dále bylo odstraněno
  pole `historical_inbound_htlc_fulfills` a přidán `SentHTLCId`.

- [LND #9456][] přidává varování o zastarání do `SendToRoute`,
  `SendToRouteSync`, `SendPayment` a `SendPaymentSync` v přípravě na jejich
  odstranění v přespříštím vydání (0.21). Uživatelé by měli používat nové
  v2 metody `SendToRouteV2`, `SendPaymentV2` a `TrackPaymentV2`.

{% include snippets/recap-ad.md when="2025-02-11 15:30" %}

## Poznámky

[^2kmultisig]:
    Co se týče P2SH a navrhovaného počítání sigops vstupů, `OP_CHECKMULTISIG`
    s více než 16 veřejnými klíči se počítá jako 20 sigops; pokud někdo
    použije 125× `OP_CHECKMULTISIG`, pokaždé se 17 klíči, budou počítány
    jako 2 500 sigops.

{% include references.md %}
{% include linkers/issues.md v=2 issues="21590,2983,2968,3556,9456,26348" %}
[dryja pp]: https://docs.google.com/presentation/d/1G4xchDGcO37DJ2lPC_XYyZIUkJc2khnLrCaZXgvDN0U/mobilepresent?pli=1#slide=id.g85f425098_0_219
[morehouse forceclose]: https://delvingbitcoin.org/t/disclosure-ldk-duplicate-htlc-force-close-griefing/1410
[news339 ldkvuln]: /cs/newsletters/2025/01/31/#zranitelnost-ldk-v-procesu-narokovani
[halseth zkgoss]: https://delvingbitcoin.org/t/zk-gossip-for-lightning-channel-announcements/1407
[news321 zkgoss]: /cs/newsletters/2024/09/20/#doklad-s-nulovou-znalosti-o-pritomnosti-v-mnozine-utxo
[richter cluster]: https://delvingbitcoin.org/t/how-to-linearize-your-cluster/303/9
[mincut impl]: https://github.com/jonas-sauer/MonotoneParametricMinCut
[wuille cluster]: https://delvingbitcoin.org/t/how-to-linearize-your-cluster/303/10
[linear programming]: https://cs.wikipedia.org/wiki/Line%C3%A1rn%C3%AD_programov%C3%A1n%C3%AD
[wuille sp cl]: https://delvingbitcoin.org/t/spanning-forest-cluster-linearization/1419
[richter deepseek]: https://delvingbitcoin.org/t/how-to-linearize-your-cluster/303/15
[delgado erlay]: https://delvingbitcoin.org/t/erlay-overview-and-current-approach/1415
[sd1]: https://delvingbitcoin.org/t/erlay-filter-fanout-candidates-based-on-transaction-knowledge/1416
[sd2]: https://delvingbitcoin.org/t/erlay-select-fanout-candidates-at-relay-time-instead-of-at-relay-scheduling-time/1418
[sd3]: https://delvingbitcoin.org/t/erlay-find-acceptable-target-number-of-peers-to-fanout-to/1420
[teinturier ephanc]: https://delvingbitcoin.org/t/which-ephemeral-anchor-script-should-lightning-use/1412
[sanders ephanc]: https://delvingbitcoin.org/t/which-ephemeral-anchor-script-should-lightning-use/1412/2
[harding ephanc]: https://delvingbitcoin.org/t/which-ephemeral-anchor-script-should-lightning-use/1412/4
[riard ephanc]: https://delvingbitcoin.org/t/which-ephemeral-anchor-script-should-lightning-use/1412/3
[news339 pincycle]: /cs/newsletters/2025/01/31/#utoky-cyklickym-nahrazovanim-s-vyuzitim-tezare
[kurbatov rand]: https://delvingbitcoin.org/t/emulating-op-rand/1409
[tonoski minrelay]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CAMHHROxVo_7ZRFy+nq_2YzyeYNO1ijR_r7d89bmBWv4f4wb9=g@mail.gmail.com/
[news324 largeinv]: /cs/newsletters/2024/10/11/#dos-kvuli-velkemu-inventari
[news212 relay]: /en/newsletters/2022/08/10/#lowering-the-default-minimum-transaction-relay-feerate
[ap1]: https://delvingbitcoin.org/t/great-consensus-cleanup-revival/710/64
[ap2]: https://delvingbitcoin.org/t/great-consensus-cleanup-revival/710/66
[mcelrath braidcov]: https://delvingbitcoin.org/t/challenge-covenants-for-braidpool/1370/1
[news332 cleanup]: /cs/newsletters/2024/12/06/#pokracuje-diskuze-o-navrhu-soft-forku-na-procisteni-konsenzu
[harding duplocktime]: https://delvingbitcoin.org/t/great-consensus-cleanup-revival/710/26
[corallo duplocktime]: https://delvingbitcoin.org/t/great-consensus-cleanup-revival/710/25
[ap3]: https://delvingbitcoin.org/t/great-consensus-cleanup-revival/710/65
[mcelrath dtx]: https://delvingbitcoin.org/t/deterministic-tx-selection-for-censorship-resistance/842/
[towns dtx]: https://delvingbitcoin.org/t/deterministic-tx-selection-for-censorship-resistance/842/7
[bp pow]: https://github.com/braidpool/braidpool/blob/6bc7785c7ee61ea1379ae971ecf8ebca1f976332/docs/braid_consensus.md#difficulty-adjustment
[miller stale]: https://bitcointalk.org/index.php?topic=98314.msg1075701#msg1075701
[mcelrath daa-latency]: https://delvingbitcoin.org/t/fastest-possible-pow-via-simple-dag/1331/12
[zawy prior]: https://delvingbitcoin.org/t/fastest-possible-pow-via-simple-dag/1331/9
[mcelrath prior]: https://delvingbitcoin.org/t/fastest-possible-pow-via-simple-dag/1331/8
[zawy sim]: https://delvingbitcoin.org/t/fastest-possible-pow-via-simple-dag/1331/10
[zawy daadag]: https://delvingbitcoin.org/t/fastest-possible-pow-via-simple-dag/1331
[wuille prior]: https://delvingbitcoin.org/t/fastest-possible-pow-via-simple-dag/1331/6
[provoost dag]: https://delvingbitcoin.org/t/fastest-possible-pow-via-simple-dag/1331/13
[ccbip]: https://github.com/TheBlueMatt/bips/blob/7f9670b643b7c943a0cc6d2197d3eabe661050c2/bip-XXXX.mediawiki#specification
[news36 cc]: /en/newsletters/2019/03/05/#prevent-use-of-op-codeseparator-and-findanddelete-in-legacy-transactions
[news335 cc]: /cs/newsletters/2025/01/03/#prechodne-obdobi-proti-ohybani-casu-v-ramci-procisteni-konsenzu
[wuille erlang]: https://delvingbitcoin.org/t/timewarp-attack-600-second-grace-period/1326/28?u=harding
[erlang]: https://en.wikipedia.org/wiki/Erlang_distribution
[sd4]: https://delvingbitcoin.org/t/erlay-define-fanout-rate-based-on-the-transaction-reception-method/1422
[news136 gcd]: /en/newsletters/2021/02/17/#faster-signature-operations
[news337 bdk]: /cs/newsletters/2025/01/17/#bdk-1789
[news339 bdk-cpf]: /cs/newsletters/2025/01/31/#bdk-1614
[bdk wallet 1.1.0]: https://github.com/bitcoindevkit/bdk/releases/tag/wallet-1.1.0
[lnd v0.18.5-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.18.5-beta.rc1
[ap4]: https://mailing-list.bitcoindevs.xyz/bitcoindev/jiyMlvTX8BnG71f75SqChQZxyhZDQ65kldcugeIDJVJsvK4hadCO3GT46xFc7_cUlWdmOCG0B_WIz0HAO5ZugqYTuX5qxnNLRBn3MopuATI=@protonmail.com/
[modularinversion]: https://cs.wikipedia.org/wiki/Modul%C3%A1rn%C3%AD_aritmetika
[news131 muhash]: /en/newsletters/2021/01/13/#bitcoin-core-19055
[news62 whitelist]: /en/newsletters/2019/09/04/#eclair-954
[news337 splicing]: /cs/newsletters/2025/01/17/#eclair-2936
