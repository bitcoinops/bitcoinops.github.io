---
title: 'Zpravodaj „Bitcoin Optech” č. 283'
permalink: /cs/newsletters/2024/01/03/
name: 2024-01-03-newsletter-cs
slug: 2024-01-03-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Tento týden sdílíme informace o odhalení nedávných zranitelností v LND,
shrnujeme návrh na časové zámky závislé na poplatcích, popisujeme myšlenku na
zlepšení odhadu poplatků použitím clusterů transakcí, diskutujeme o specifikaci
neutratitelných klíčů v deskriptorech, zkoumáme náklady na pinning v navrhovaném
přeposílání transakcí verze 3, zmiňujeme návrh BIPu na začlenění deskriptorů
do PSBT, oznamujeme nástroj používající navrhovaný MATT pro doklad o spuštění
nějakého programu, nahlížíme na návrh umožňující vysoce efektivní skupinové
vystoupení ze sdílených UTXO a poukazujeme na nové strategie výběru mincí
navrhovaných pro Bitcoin Core. Též nechybí naše pravidelné rubriky oznamující
nová vydání a popisující významné změny v populárních bitcoinových
páteřních projektech.

## Novinky

- **Zveřejnění nedávných zranitelností LND:** Niklas Gögge zaslal do fóra
  Delving Bitcoin [příspěvek][gogge lndvuln] o dvou zranitelnostech, které
  předtím [zodpovědně nahlásil][topic responsible disclosures]. Následně
  byly vydány dvě opravné verze LND. Verze 0.15.0 či pozdější zranitelnost
  neobsahují. Uživatelé starších verzí by měli zvážit kvůli této i dalším
  známým zranitelnostem okamžitou aktualizaci. Následuje stručný popis
  těchto zranitelností:

  - DoS zranitelnost, která mohla vést k zahlcení paměti a pádu a následné
    nemožnosti zveřejnit časově citlivé transakce, což mohlo vést ke
    ztrátě prostředků.

  - Zranitelnost, která umožňovala útočníkovi zabránit LND uzlu,
    aby se dozvěděl o aktualizacích kanálů napříč sítí. Útočník tím mohl
    ovlivnit výběr tras a obdržet tak více peněz na poplatcích i více
    informací o odesílaných platbách.

  Gögge zranitelnosti nahlásil vývojářům před více než dvěma lety a opravné
  verze jsou dostupné již více než 18 měsíců. Nejsme si vědomi žádných
  uživatelů, kteří byli těmito zranitelnostmi postiženi.

- **Časové zámky se závislostí na poplatcích:** John Law zaslal do emailových
  skupin Bitcoin-Dev a Lightning-Dev [příspěvek][law fdt] s hrubým návrhem
  na soft fork, který by umožňoval, aby mohly [časové zámky][topic timelocks]
  transakci volitelně odemknout, pouze pokud by byl medián jednotkových poplatků
  v bloku pod zvolenou úrovní. Například Alice chce vložit peníze do
  platebního kanálu s Bobem, ale vyžaduje též, aby mohla prostředky refundovat,
  pokud by byl Bob nedostupný. Dá mu tedy možnost kdykoliv nárokovat své
  prostředky, které mu vyplatí, avšak sobě navíc poskytne možnost nárokovat
  po vypršení časového zámku zpět svůj vklad. S blížící se expirací časového
  zámku se Bob pokusí své prostředky nárokovat, ale aktuální jednotkový poplatek
  je mnohem vyšší, než kolik v počátku kontraktu předpokládali. Bob není schopen
  nechat potvrdit transakci vyjadřující jeho nárok na prostředky, ať již z důvodu
  nedostatku bitcoinů na poplatky nebo kvůli neekonomičnosti. Současný bitcoinový
  protokol by kvůli Bobově nemožnosti konat umožnil Alici refundovat své prostředky.
  S Lawovým návrhem by byla expirace časového zámku, který Alici v refundaci
  zabraňuje, prodloužena, dokud by nepřišla série bloků s mediánem jednotkových
  poplatků pod hodnotou stanovenou Alicí a Bobem během vyjednávání kontraktu.
  Bob by tak měl možnost nechat svou transakci potvrdit s přijatelnějším
  poplatkem.

  Law poznamenává, že tento návrh řeší jeden z dlouhodobých problémů popsaných
  [v původním článku o Lightning Network][original Lightning Network paper]
  jako _záplava vynucených expirací_ („forced expiration floods”). Problém
  se vyskytuje v situaci, kdy se příliš mnoho kanálů najednou snaží o
  uzavření a v důsledku není pro všechny dostatek blokového prostoru, aby stihli
  transakci potvrdit před vypršením časových zámků. Časové zámky závislé
  na poplatcích by v takovém případě byly prodloužené, neboť by aktuální
  jednotkové poplatky převyšovaly mez. Transakce by opět mohly být potvrzovány,
  jakmile se aktuální poplatky budou snižovat. V současnosti mají LN kanály
  pouze dva uživatele, ale návrhy jako [továrny kanálů][topic channel factories]
  či [joinpooly][topic joinpools], kde jsou UTXO sdílena více než dvěma uživateli,
  jsou ještě náchylnější. Tento návrh by výrazně zvýšil jejich bezpečnost.
  Law dále poznamenává, že v některých těchto konstruktech se strana, která
  drží podmínku refundace (v našem příkladě Alice), kvůli zvyšujícím se
  poplatkům dostává do největší nevýhody, neboť její kapitál je uzamčen
  v kontraktu až do doby, kdy se poplatky začnou snižovat. Časové zámky
  závislé na poplatcích dávají této straně další podněty, aby jednala způsobem,
  který udržuje poplatky nízké, tedy aby neuzavírala množství kanálů během
  krátké doby.

  Implementace časových zámků závislých na poplatcích je zvolena tak,
  aby byly snadno a volitelně použitelné účastníky kontraktu a aby bylo
  množství ukládaných dat potřebných pro validaci plnými uzly co nejnižší.

  Návrh obdržel průměrné množství reakcí obsahující například návrhy na
  [ukládání][riard fdt] parametrů v příloze („annex”) [taprootu][topic taproot],
  [zavazování][boris fdt] bloků ke svému mediánu poplatku pro podporu
  lehkých klientů či [způsob][harding pruned], kterým by mohly ořezané
  uzly fork podporovat. Mezi Lawem a [ostatními][evo fdt] proběhla
  další diskuze o dopadu placení poplatků těžařům mimo blockchain (napřímo).

- **Odhad poplatků a clustery:** Abubakar Sadiq Ismail zaslal do fóra
  Delving Bitcoin [příspěvek][ismail cluster] o použití některých nástrojů
  a poznatků z návrhu [cluster mempoolu][topic cluster mempool] k vylepšení
  odhadu poplatků v Bitcoin Core. Současný algoritmus odhadu poplatků
  v Bitcoin Core sleduje, kolik bloků uplyne mezi přijetím transakce do
  místního mempoolu a jejím potvrzením. Když je transakce potvrzena, její
  jednotkový poplatek je použit k aktualizaci systému předpovídání, jak
  dlouho potrvá čekání transakcí s podobným jednotkovým poplatek, než
  budou potvrzené.

  Používáním tohoto způsobu jsou některé transakce Bitcoin Core pro kalkulaci
  poplatků ignorovány, zatímco jiné mohou být započítány nesprávně. Důvodem
  je [CPFP][topic cpfp], kde potomci dávají těžařům podnět k potvrzení
  jejich předků. Potomci mohou mít sami o sobě vyšší jednotkový poplatek,
  ale když se jejich poplatek a poplatek předků posoudí dohromady,
  může být jednotkový poplatek výrazně nižší. To vede k delšímu čekání
  na potvrzení. Aby nenadhodnocoval rozumnou výši poplatků, neaktualizuje
  Bitcoin Core odhad poplatků transakcemi, které vstoupí do mempoolu,
  když je jejich rodič nepotvrzený. Podobně může mít rodičovská transakce
  sama o sobě nižší jednotkový poplatek, ale posouzena spolu se svými
  potomky bude mít jednotkový poplatek výrazně vyšší. Taková transakce
  bude potvrzena v porovnání s odhadem rychleji. Bitcoin Core neprovádí
  v takových případech žádné kompenzace.

  Cluster mempool bude držet související transakce spolu a bude nabízet
  jejich dělení do chunků, jejichž společná těžba bude výdělečná. Ismail
  navrhuje sledovat jednotkové poplatky chunků oproti individuálním
  transakcím (i když chunk může být tvořen jedinou transakcí) a poté
  se pokusit nalézt stejné chunky v blocích. Je-li chunk potvrzen,
  může být odhad poplatků aktualizován jeho jednotkovým poplatkem namísto
  poplatků jednotlivých transakcí.

  Návrhu se dostalo pozitivního přijetí, vývojáři diskutují o podrobnostech,
  které by takový algoritmus musel vzít do úvahy.

- **Specifikace neutratitelných klíčů v deskriptorech:** Salvatore Ingala
  otevřel na fóru Delving Bitcoin [diskuzi][ingala undesc] o tom, jak
  umožnit [deskriptorům][topic descriptors], jmenovitě [taprootovým][topic
  taproot], specifikovat klíč, pro který není znám žádný soukromý klíč.
  Jednou z důležitých situací je posílání peněz na taprootové výstupy,
  které mohou být utraceny pouze skriptem. Jako klíč pro utracení
  klíčem se musí použít nějaký neutratitelný.

  Ingala popsal několik obtíží používání neutratitelných klíčů v
  deskriptorech a navrhl několik řešení s různými kompromisy.
  Pieter Wuille shrnul několik nedávných osobních diskuzí o deskriptorech,
  včetně jednoho [nápadu][wuille undesc2] týkajícího se neutratitelných
  klíčů. Josie Baker se ptal po důvodech, proč nemohou být neutratitelné
  klíče konstantní (jako například tzv. NUMS bod v BIP341), což by
  umožnilo komukoliv okamžitě poznat, že byl použit neutratitelný klíč.
  To by mohlo být výhodné v některých protokolech, například v
  [tichých platbách][topic silent payments]. Ingala Bakerovi odpověděl,
  že „je to forma zanechávání stop. Můžeš se sám rozhodnout tuto informaci
  kdykoliv odhalit, ale je dobré, když tě standardy nenutí.” Wuille dále
  sdílel algoritmus pro generování důkazu. V posledním příspěvku vlákna
  v době psaní zpravodaje Ingala poznamenal, že specifikace pravidel
  souvisejících s neutratitelnými klíči může být rozdělena mezi
  deskriptory a pravidla peněženek dle [BIP388][].

- **Náklady na pinning V3 transakcí:** Peter Todd zaslal do emailové skupiny
  Bitcoin-Dev [analýzu][todd v3] navrhovaných pravidel [přeposílání v3
  transakcí][topic v3 transaction relay] týkající se [pinningu transakcí][topic
  transaction pinning] u protokolů jako je LN. Mějme příklad, ve kterém
  Bob a Mallory sdílí kanál. Bob chce kanál zavřít, zveřejní tedy svou
  aktuální commitment transakci a připojí drobnou transakci, která
  přispěje na výši poplatku pomocí [CPFP][topic cpfp], s celkovou velikostí
  500 vbyte. Mallory v P2P síti detekuje Bobovy transakce před tím, než
  dosáhnou nějakého těžaře, a odešle svou vlastní commitment transakci spolu
  s velikým potomkem s celkovou velikostí 100 000 vbyte, avšak s
  nižším jednotkovým poplatkem, než byla Bobova původní verze. Dle současných
  výchozích pravidel přeposílání v Bitcoin Core i aktuálního návrhu
  [přeposílání balíčků][topic package relay] se může Bob pokusit
  [nahradit][topic rbf] dvě Mallořiny transakce, avšak kvůli pravidlu č. 3
  [BIP125][] bude muset zaplatit i za prostor zabraný Mallořinou transakcí.
  Pokud Bob původně platil 10 sat/vbyte (tedy celkem 5 000 sat) a Mallořina
  verze měla 5 sat/vbyte (500 000 sat), musel by Bob za náhradu zaplatit stokrát
  víc, než kolik platil původně. Pokud částka překračuje Bobovu mez, Mallořina
  velká transakce s nízkým poplatkem nemusí před vypršením časového zámku obdržet
  žádnou konfirmaci, což by vedlo ke krádeži Bobových peněz.

  V navrhovaném přeposílání transakcí verze 3 umožňují pravidla transakcím
  nejvýše jednoho nepotvrzeného potomka, který bude přeposílán, ukládán
  v mempoolech a vytěžen uzly dodržující pravidla verze 3. Jak Peter Todd
  ve svém příspěvku ukázal, i to by umožnilo Mallory navýšit Bobovy náklady
  zhruba 1,5×, než kolik původně zamýšlel zaplatit. Reakce většinou
  souhlasily s existencí rizika, že by musel Bob platit záškodnické protistraně více.
  Poznamenávají však, že by to bylo výrazně méně než v případě současných pravidel.

  Dodatečná diskuze se vedla kolem konkrétních bodů pravidel verze 3,
  [dočasnými anchory][topic ephemeral anchors] („ephemeral anchors”) a jejich
  porovnání s aktuálně dostupnými [CPFP carve-out][topic cpfp carve out] a [anchor
  výstupy][topic anchor outputs].

- **Návrh BIPu na deskriptory v PSBT:** Tým SeedHammer zaslal do emailové skupiny
  Bitcoin-Dev [návrh BIPu][seedhammer descpsbt] na přidání [deskriptorů][topic
  descriptors] do [PSBT][topic psbt]. Hlavním záměrem zdá se býti zapouzdření
  deskriptorů do PSBT pro přenos mezi peněženkami, jelikož návrh umožňuje,
  aby PSBT neobsahovalo transakční data, je-li přítomen deskriptor. To by
  mohlo být užitečné pro přenos informací o výstupech ze softwarové
  peněženky do hardwarového podpisového zařízení nebo pro několik peněženek
  podílejících se na vícenásobném podpisu pro sdílení informací o výstupech,
  které chtějí vytvářet. V době psaní zpravodaje neobdržel návrh BIPu
  v emailové skupině žádné reakce, ačkoliv dřívější, listopadový [příspěvek][seedhammer
  descpsbt2] o předchůdci návrhu zpětnou vazbu [obdržel][black descpsbt].

- **Verifikace libovolných programů pomocí navrhovaného opkódu z MATT:**
  Johan Torås Halseth zaslal do fóra Delving Bitcoin [příspěvek][halseth ccv]
  o [elftrace][], programu, který pomocí opkódu `OP_CHECKCONTRACTVERIFY`
  z návrhu soft forku [MATT][] umožňuje nějaké straně v kontraktu nárokovat
  peníze, pokud by byl úspěšně spuštěn libovolný program. Jedná se o koncept
  podobný BitVM (viz [zpravodaj č. 273][news273 bitvm]), ale díky opkódu
  navrženému přímo pro verifikaci spuštění programu je jeho bitcoinová
  implementace jednodušší. Elftrace je schopen fungovat s programy
  zkompilovanými pro architekturu RISC-V a používající linuxový formát
  [ELF][]. Téměř každý programátor může snadno vytvořit programy pro
  tento formát, což činí elftrace vysoce dostupným. Příspěvek neobdržel
  v době psaná zpravodaje žádné reakce.

- **Dávkování plateb při odchodu z poolu pomocí dokladů o podvodu:**
  Salvatore Ingala zaslal do fóra Delving Bitcoin [návrh][ingala exit],
  který může vylepšit kontrakty s více stranami, kde několik uživatelů
  sdílí jedno UTXO (např. [joinpooly][topic joinpools] či [továrny
  kanálů][topic channel factories]) a někteří z uživatelů chtějí z kontraktu
  vystoupit v době, kdy jsou ostatní nedostupní, ať již záměrně či neúmyslně.
  Typicky jsou takové protokoly konstruovány tak, že každý uživatel má
  offchain k dispozici transakci, kterou může zveřejnit, když má v záměru
  vystoupit. Znamená to, že chce-li pět uživatelů z kontraktu vystoupit,
  i v nejlepším případě musí každý z nich zveřejnit jednu transakci a každá
  z nich bude mít minimálně jeden vstup a jeden výstup; dohromady pět vstupů
  a pět výstupů. Ingala navrhuje způsob, kterým by tito uživatelé mohli
  spolupracovat a vystoupit s použitím pouze jediné transakce s jedním vstupem
  a pěti výstupy. Tím by dosáhli redukce velikosti okolo 50 %,
  obvyklé v [dávkových platbách][topic payment batching].

  Ve složitých kontraktech s mnoha účastníky může redukce v onchain
  velikosti snadno výrazně přesáhnout 50 %. Ba co více, pokud by těchto
  pět uživatelů chtělo jednoduše přesunout své prostředky na nové UTXO
  sdílené jen jimi, mohli by použít transakci s jedním vstupem a
  jedním výstupem. Pět uživatelů by tak dosáhlo 80% redukce velikosti,
  v případě sta uživatelů by snížení bylo 99 %. Takto výrazné snížení
  velikosti u velkých skupin uživatelů, kteří se chtějí přesunout
  z jednoho kontraktu do jiného, může být kritické v obdobích s vysokými
  poplatky. Pro příklad mějme sto uživatelů, kteří mají každý zůstatek
  10 000 sat (110 Kč v době psaní). Pokud by každý z nich měl jednotlivě
  platit transakční poplatek za vystoupení z kontraktu a vstup do nového
  kontraktu, spotřebovala by dokonce i nepravděpodobně malá transakce
  o velikosti 100 vbyte s poplatkem 100 sat/vbyte celý jejich zůstatek.
  Pokud by mohli dohromady přesunout svůj 1 milión sat v jediné
  200vbytové transakci s poplatkem 100 sats/vbyte, každý z nich by zaplatil
  pouze 200 sat (2 % zůstatku).

  Dávkové platby se dosáhne tím, že jeden z účastníků kontraktu vytvoří
  transakci s útratou společných prostředků na výstupy odsouhlasené
  ostatními aktivními stranami. Kontrakt toto umožní pouze v případě,
  pokud uživatel vytvářející transakci pošle nejdříve peníze do fondu,
  o který by přišel v případě podvodu. Výše fondu by měla být výrazně
  vyšší, než kolik by podvodem jinak získal. Pokud by žádná strana
  nebyla schopna poskytnout doklad o podvodu ukazující, že autor transakce
  jednal nečestně, byly by prostředky z fondu vrácenu jemu. Ingala zhruba
  popsal, jak by tento systém mohl být přidán do protokolů s kontrakty
  s více účastníky pomocí [OP_CAT][], `OP_CHECKCONTRACTVERIFY` a introspekce
  částky z navrhovaného soft forku [MATT][]. Poznamenal, že by to bylo
  ještě jednodušší, pokud by byly k dispozici i [OP_CSFS][topic op_checksigfromstack]
  a 64bitové aritmetické operátory [tapscriptu][topic tapscript].

  Myšlenka se setkala s mírným množstvím reakcí.

- **Nové strategie výběru mincí:** Mark Erhardt zaslal do fóra Delving
  Bitcoin [příspěvek][erhardt coin] popisující krajní případy používání
  [výběru mincí][topic coin selection] v Bitcoin Core a navrhuje dvě
  nové strategie, které by tyto krajní případy adresovaly snížením
  počtu vstupů transakcí s vysokým jednotkovým poplatkem. Dále shrnuje
  výhody a nevýhody všech strategií v Bitcoin Core, již implementovaných
  i jím navrhovaných, a poskytuje výsledky několik simulací, které provedl
  s různými algoritmy. Konečným cílem pro Bitcoin Core je vybírat sadu
  vstupů, která dlouhodobě minimalizuje podíl poplatků na hodnotě UTXO
  vyhýbá se tvoření nadbytečně velkých transakcí v době s vysokými
  poplatky.

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [Core Lightning 23.11.2][] je opravným vydáním, které pomáhá zajistit,
  aby LND uzly mohly platit faktury vytvořené uživateli Core Lightning.
  Podrobnosti jsou obsaženy níže v poznámkách k Core Lightning #6957
  v rubrice o _významných změnách_.

- [Libsecp256k1 0.4.1][] je vedlejším vydáním, které „mírně zrychluje ECDH
  operace a výrazně zvyšuje výkonnost mnoha funkcí na x86_64 ve výchozím
  nastavení.”

## Významné změny v kódu a dokumentaci

*Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo] a
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [Bitcoin Core #28349][] přináší požadavek na používání kompilátorů kompatibilních
  s C++20. Díky tomu mohou budoucí PR používat vlastnosti C++20. Jak uvádí popis PR,
  „C++20 umožní psát bezpečnější kód, neboť umožňuje během kompilace kontrolovat
  více věcí.”

- [Core Lightning #6957][] opravuje neúmyslnou nekompatibilitu, která zabraňovala
  uživatelům LND platit faktury vygenerované Core Lightningem ve výchozím nastavení.
  Problém spočívá v nastavení `min_final_cltv_expiry`, které určuje minimální počet
  bloků, po který musí příjemce čekat před nárokováním platby. [BOLT2][] navrhuje
  nastavit tuto volbu ve výchozím stavu na 18, avšak LND používá hodnotu 9, což je
  nižší hodnota, než kterou Core Lightning ve výchozím nastavení přijme. Core Lightning
  problém řeší tím, že ve faktuře nastaví pole vyžadující, aby tato hodnota byla 18.

- [Core Lightning #6869][] upravuje RPC volání `listchannels`, aby již nadále nezačleňovalo
  [neoznámené kanály][topic unannounced channels]. Uživatelé, kteří tuto informaci
  vyžadují, mohou použít volání `listpeerchannels`.

- [Eclair #2796][] aktualizuje svou závislost na [logback-classic][], aby tím
  vyřešil jednu zranitelnost. Eclair přímo nepoužívá postiženou funkcionalitu,
  upgrade má však zajistit, aby žádný plugin nebo jiný související software touto
  zranitelností postižen nebyl.

- [Eclair #2787][] aktualizuje svou podporu stahování hlaviček z BitcoinHeaders.net
  na nejnovější verzi API. Stahování hlaviček přes DNS napomáhá chránit uzel před
  [útoky zastíněním][topic eclipse attacks] („eclipse attacks”). [Zpravodaj č. 123][news123
  headers] (_angl._) popisuje původní začlenění do Eclairu. I jiný software
  používající BitcoinHeaders.net by měl aktualizovat verzi používaného API.

- [LDK #2781][] a [#2688][ldk #2688] upravují podporu pro posílání a přijímání
  [zaslepených plateb][topic rv routing], obzvláště se zaslepenými cestami s více
  skoky. Dále vylepšuje dodržování pravidla, aby [nabídky][topic offers] vždy
  obsahovaly alespoň jeden zaslepený skok.

- [LDK #2723][] přidává podporu pro posílání [onion zpráv][topic onion
  messages] pomocí _přímých spojení_. V případě, kdy odesílatel nemůže nalézt
  trasu k příjemci, avšak zná jeho síťovou adresu (například protože příjemce
  je veřejný uzel, který zveřejnil svou IP adresu), může odesílatel k příjemcovi
  jednoduše otevřít přímé spojení, zprávu odeslat a pak volitelně spojení zavřít.
  Díky tomu mohou onion zprávy dobře fungovat, i pokud jsou podporovány pouze
  malým počtem uzlů (což je současný stav).

- [BIPs #1504][] upravuje BIP2, aby umožňoval používání Markdownu pro BIPy. Dříve musely
  být BIPy psány ve značkovacím jazyce Mediawiki.

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 15:00" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="28349,6957,6869,2796,2787,2781,2723,1504,2688" %}
[gogge lndvuln]: https://delvingbitcoin.org/t/denial-of-service-bugs-in-lnds-channel-update-gossip-handling/314/1
[law fdt]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-December/004254.html
[original lightning network paper]: https://lightning.network/lightning-network-paper.pdf
[riard fdt]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-December/004256.html
[boris fdt]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-December/004256.html
[harding pruned]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-December/004256.html
[evo fdt]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-December/004260.html
[ismail cluster]: https://delvingbitcoin.org/t/package-aware-fee-estimator-post-cluster-mempool/312/1
[ingala undesc]: https://delvingbitcoin.org/t/unspendable-keys-in-descriptors/304/1
[wuille undesc]: https://delvingbitcoin.org/t/unspendable-keys-in-descriptors/304/2
[wuille undesc2]: https://gist.github.com/sipa/06c5c844df155d4e5044c2c8cac9c05e#unspendable-keys
[todd v3]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-December/022211.html
[seedhammer descpsbt]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-December/022200.html
[seedhammer descpsbt2]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-November/022184.html
[black descpsbt]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-November/022186.html
[halseth ccv]: https://delvingbitcoin.org/t/verification-of-risc-v-execution-using-op-ccv/313
[elftrace]: https://github.com/halseth/elftrace
[matt]: /en/newsletters/2022/11/16/#general-smart-contracts-in-bitcoin-via-covenants
[news273 bitvm]: /cs/newsletters/2023/10/18/#platby-podminene-libovolnym-vypoctem
[elf]: https://cs.wikipedia.org/wiki/Executable_and_Linkable_Format
[ingala exit]: https://delvingbitcoin.org/t/aggregate-delegated-exit-for-l2-pools/297
[erhardt coin]: https://delvingbitcoin.org/t/gutterguard-and-coingrinder-simulation-results/279/1
[logback-classic]: https://logback.qos.ch/
[news123 headers]: /en/newsletters/2020/11/11/#eclair-1545
[bip388]: https://github.com/bitcoin/bips/pull/1389
[core lightning 23.11.2]: https://github.com/ElementsProject/lightning/releases/tag/v23.11.2
[libsecp256k1 0.4.1]: https://github.com/bitcoin-core/secp256k1/releases/tag/v0.4.1
