---
title: 'Zpravodaj „Bitcoin Optech” č. 274'
permalink: /cs/newsletters/2023/10/25/
name: 2023-10-25-newsletter-cs
slug: 2023-10-25-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Tento týden přinášíme popis replacement cycling útoku na HTLC používané v
LN i jiných systémech, zkoumáme opatření nasazená proti tomuto útoku a
vypisujeme návrhy na další možná opatření. Dále popisujeme významnou chybu
postihující Bitcoin Core RPC, výzkum kovenantů vyžadujících pouze minimální
změny bitcoinového Scriptu a návrh BIPu na opkód `OP_CAT`. Též nechybí naše
pravidelná měsíční rubrika se souhrnem oblíbených otázek a odpovědí z
Bitcoin Stack Exchange.

{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

## Novinky

- **Zranitelnost replacement cycling postihující HTLC:** Jak bylo krátce
  zmíněno v [minulém čísle zpravodaje][news274 cycle], zaslal Antoine Riard
  do emailových skupin Bitcoin-Dev a Lightning-Dev [příspěvek][riard cycle1]
  popisující [zodpovědně nahlášenou][topic responsible disclosures]
  zranitelnost postihující starší verze všech implementací LN. V době od
  nahlášení byla do implementací přidána opatření před útokem, důrazně
  doporučujeme aktualizovat vámi používaný LN software na poslední verzi.
  Postiženy jsou pouze uzly přeposílající platby; uzly používané pouze pro
  zahajování či přijímání plateb postiženy nejsou.

  Náš popis této zranitelnosti je rozdělen do tří částí: samotný popis
  zranitelnosti (tento bod), popis opatření dosud nasazených implementacemi
  LN a souhrn dodatečných opatření a řešení navržených v emailové skupině.

  Pro připomenutí: je možné využít [nahrazování transakcí][topic rbf]
  k odstranění jednoho či více vstupů transakce (mající více vstupů) z mempoolu.
  Mějme jednoduchý příklad, [drobně odlišný]({{bse}}120200) od
  původního Riardova popisu: Mallory zveřejní transakci se dvěma vstupy,
  které utrácí výstupy _A_ a _B_. Potom nahradí tuto transakci alternativní
  verzi s jediným vstupem, který utrácí pouze výstup _B_. Po tomto
  nahrazení je vstup _A_ (a všechna související data) odstraněn z mempoolů,
  které toto nahrazení zpracovaly.

  Ač není tento postup pro běžnou peněženku bezpečný[^rbf-warning], je to
  chování, kterého může Mallory zneužít k odstranění vstupu z mempoolů.

  Konkrétně sdílí-li Mallory kontrolu nad výstupem s Bobem, může počkat, až Bob
  výstup utratí, poté může nahradit jeho utracení svým vlastním, které obsahuje
  dodatečný vstup, a nato může nahradit své utracení transakcí, která společný
  výstup již neutrácí. A právě toto je _replacement cycle_ („cyklus nahrazování“).
  Těžaři sice obdrží od Mallory transakční poplatky, ale s velkou pravděpodobností
  nebude Bobovo ani Mallořino utracení výstupu během krátké doby od zveřejnění
  potvrzeno.

  To je důležité v případě LN a několika dalších protokolů, protože určité transakce
  se musí objevit během určitého časového okna, aby bylo zajištěno, že uživatelé
  přeposílající platby nepřijdou o peníze. Příklad: Mallory použije jeden ze
  svých uzlů (nazývejme ho _MalloryA_) pro přeposlání platby Bobovi a Bob
  přepošle tuto platbu dalšímu z Mallořiných uzlů (_MalloryB_). Od MalloryB se
  očekává, že buď poskytne Bobovi _předobraz_ (který mu umožní obdržet přeposlanou
  platbu od MalloryA) nebo přeposílanou platbu od Boba během určité doby zruší (revokuje).
  Namísto toho ale MalloryB během určené doby nic neudělá, a Bob je tak donucen
  zavřít kanál a zveřejnit transakci, která by mu zpět poslala tuto přeposílanou
  platbu. Tato transakce by měla být ihned potvrzena, aby tím mohl Bob zrušit
  (revokovat) platbu od MalloryA, čímž by se zůstatek každého účastníka vrátil
  do stavu před pokusem o přeposlání platby (kromě transakčních poplatků
  za zavření a urovnání kanálu mezi Bobem a MalloryB).

  Druhou možností je, že Bob kanál zavře a pokusí se utratit přeposílanou platbu
  zpět sobě. MalloryB toto utracení nahradí svým vlastním a tím odhalí předobraz.
  Je-li tato transakce včas potvrzena, může Bob pomocí tohoto předobrazu nárokovat
  platbu od MalloryA. Bob by tak byl spokojen.

  Pokud však MalloryB nahradí Bobovu transakci svou vlastní transakcí, která
  obsahuje předobraz, a nato rychle ten vstup odstraní, je
  nepravděpodobné, že by se Bobova transakce i předobraz MalloryB objevily
  na blockchainu. Bob by tak nedostal od MalloryB své peníze zpět. Bez
  předobrazu by nebyl Bob schopen držet přeposílanou platbu od MalloryA, musel by ji
  tedy refundovat. V tento okamžik by mohla MalloryB zveřejnit a nechat potvrdit
  transakci s předobrazem, což by jí umožnilo nárokovat přeposílanou platbu od Boba.
  Byla-li by přeposílaná částka _x_, MalloryA by nezaplatila nic, MalloryB by obdržela _x_
  a Bob by o _x_ přišel (různé poplatky nejsou zahrnuty).

  Aby byl útok výnosný, musí MalloryB sdílet s Bobem kanál, ale MalloryA může
  být kdekoliv na cestě k Bobovi, například:

      MalloryA -> X -> Y -> Z -> Bob -> MalloryB

  Replacement cycling má pro LN uzly podobné důsledky jako [transaction pinning útoky][topic
  transaction pinning]. Avšak techniky jako [přeposílání transakcí verze 3][topic v3 transaction
  relay], které byly navrženy na ochranu před pinningem, jsou pro replacement
  cycling nedostatečné.

- **Opatření proti replacement cycling nasazená v LN uzlech:** jak
  [popsal][riard cycle1] Antoine Riard, v LN implementacích bylo nasazeno několik
  opatření.

    - **Častá opakovaná zveřejňování:** poté, co mempool uzlu nahradí Bobovu transakci
      Mallořinou a Mallořin vstup odstraní pomocí její druhé nahrazovací transakce,
      je tento uzel okamžitě ochoten znovu přijmout Bobovu transakci. Bob ji jen musí
      znovu zveřejnit, což ho bude stát stejný poplatek, jaký byl ochoten
      zaplatit již předtím.

      Před soukromým odhalením replacement cycling útoku LN implementace
      opakovaně zveřejňovaly své transakce méně často, jednou za blok či méně.
      Zveřejňování či opakované zveřejňování transakcí obvykle přináší náklady
      v určité [ztrátě soukromí][topic transaction origin privacy]: třetí
      strany mohou snáze asociovat Bobovu onchain LN aktivitu s jeho IP adresou.
      Jen málo veřejných LN uzlů to však v současnosti bere v potaz. Nově budou
      Core Lightning, Eclair, LDK i LND opakovaně zveřejňovat častěji.

      Po každém Bobově opakovaném zveřejnění může Mallory opět použít stejnou
      techniku k nahrazení jeho transakce. Avšak pravidla nahrazení dle BIP125
      budou po Mallory vyžadovat dodatečný poplatek za každé další nahrazení,
      čili každé další Bobovo zveřejnění snižuje Mallory ziskovost útoku.

      Z toho vyplývá hrubý vzorec pro nejvyšší částku HTLC, kterou by měl
      uzel přijmout. Jsou-li útočníkovy náklady za každé kolo nahrazení
      _x_, počet bloků, který má obránce k dispozici, je _y_
      a počet efektivních zveřejnění, která obránce průměrně za blok učiní,
      je _z_, je HTLC pravděpodobně rozumně zabezpečené do výše kousek pod `x*y*z`.

    - **Delší CLTV expiry delta:** když Bob akceptuje od MalloryA HTLC,
      souhlasí, že jí umožní nárokovat onchain refundaci po určitém počtu
      bloků (řekněme 200 bloků). Když Bob nabídne ekvivalentní HTLC
      MalloryB, dovoluje mu nárokovat refundaci po nižším počtu bloků
      (řekněme 100 bloků). Tyto expirační podmínky jsou zapsány pomocí
      opkódu `OP_CHECKLOCKTIMEVERIFY` (CLTV), proto se rozdíl mezi nimi
      nazývá _CLTV expiry delta_.

      Čím delší je CLTV expiry delta, tím déle musí původní odesílatel
      platby čekat na návrat svých prostředků v případě selhání platby,
      proto odesílatelé preferují posílat platby cestami s kratšími delta.
      Avšak také platí, že čím delší je delta, tím více času má přeposílající
      uzel (jako Bob) na reakci na problémy jako [transaction pinning][topic
      transaction pinning] a masové zavírání kanálů. Tyto protichůdné
      požadavky vedly k častým změnám v LN software v nastavení výchozích delta,
      viz zpravodaje čísla [40][news40 delta], [95][news95 delta], [109][news109 delta],
      [112][news112 delta], [142][news142 delta] (vše _angl._), [248][news248 delta] a
      [255][news255 delta].

      V případě replacement cycling útoku dává Bobovi delší CLTV delta více možností
      opakovaného zveřejnění, což zvyšuje náklady útoku podle výše zmíněného
      vzorce.

      Navíc pokaždé, když je Bobova opakovaně zveřejněná transakce v mempoolu
      těžaře, existuje šance, že ji těžař vybere do šablony bloku, kterou poté
      vytěží. Tím by byl útok zmařen. Mallořino úvodní nahrazení s předobrazem
      by též mohlo být vytěženo před tím, než by měla možnost jej nahradit.
      I toto by útok překazilo. Stráví-li v každém cyklu tyto dvě
      transakce určitou dobu v těžařově mempoolu, každé Bobovo opakované
      zveřejnění tuto dobu násobí, stejně jako ji dále násobí CLTV expiry delta.

      Například i když tyto transakce stráví v mempoolu průměrného těžaře pouze 1 %
      času na blok, existuje zhruba 50% šance, že útok selže, je-li CLTV expiry delta
      jen 70 bloků. Následující graf ukazuje pravděpodobnost selhání Mallořina
      útoku za použití současných výchozích hodnot CLTV expiry delta v různých
      LN implementacích vypsaných v Riardově emailu. Předpokladem je, že
      očekávané HTLC transakce jsou v mempoolech těžařů 0,1 % času, 1 % času
      nebo 5 % času. Pro referenci: je-li průměrný čas mezi bloky 600 sekund,
      odpovídají tato procenta pouhým 0,6 sekundám, 6 sekundám a 30 sekundám
      z každých 10 minut.

      ![Plot of probability attack will fail within x blocks](/img/posts/2023-10-cltv-expiry-delta-cycling.png)

    - **Skenování mempoolu:** design HTLC dává Mallory podnět, aby
      nechala potvrdit transakci s předobrazem před tím, než může Bob
      nárokovat refundaci. Pro Boba je to praktické: blockchain je široce
      dostupný a jeho velikost omezena, Bob tedy může snadno najít
      jakýkoliv předobraz, který se ho týká. Kdyby tento systém fungoval
      podle záměru, Bob by mohl z blockchainu získat všechny informace potřebné
      pro provoz LN.

      Bohužel, replacement cycling znamená, že Mallory již nemusí být
      motivována k potvrzení své transakce před Bobovým nárokováním
      refundace. Ale aby mohla Mallory zahájit replacement cycle, musí
      krátce odhalit předobraz v rámci mempoolů těžařů, chce-li nahradit
      Bobovu transakci. Pokud Bob provozuje přeposílající plný uzel,
      Mallořina transakce s předobrazem může procházet i Bobovým uzlem.
      Pokud by Bob včas detekoval předobraz, útok by odrazil a Mallory
      by ztratila všechny peníze, které během pokusu o útok utratila.

      Skenování mempoolu není všemocné: neexistuje záruka, že Mallořina
      nahrazující transakce proteče Bobovým uzlem. Avšak čím častěji
      Bob opakovaně zveřejňuje svou transakci (viz _častá opakovaná zveřejňování_)
      a čím déle musí Mallory před Bobem skrývat svůj předobraz (viz
      _delší CLTV expiry delta_), tím pravděpodobnější je, že se jedna z
      transakcí s předobrazem včas dostane do Bobova mempoolu.

      Eclair a LND v současnosti implementují skenování mempoolu u
      přeposílajících uzlů.

    - **Diskuze o účinnosti opatření:** Riard v úvodním oznámení napsal:
      „Věřím, že replacement cycling útoky jsou pro schopné útočníky nadále
      praktické.” Matto Corallo [napsal][corallo cycle1], že „nasazená
      opatření problém neodstraňují; lze argumentovat, že neposkytují víc
      než pouhé PR vyjádření.” Olaoluwa Osuntokun [polemizoval][osuntokun
      cycle1]: „[podle mého názoru] se jedná spíše o vratký druh útoku,
      který vyžaduje určité aranžmá jednotlivých uzlů, extrémně přesné načasování
      a provedení, nepotvrzující postavení všech transakcí a okamžitou
      propagaci celou sítí.”

      My v Optechu si myslíme, že je důležité znovu zdůraznit, že tento útok
      postihuje pouze přeposílající uzly. Přeposílající uzel je bitcoinová
      horká peněženka neustále připojená k internetu. Jedná se o druh
      nasazení, který je neustále jednu zranitelnost od ztráty všech prostředků.
      Každý, kdo vyhodnocuje dopad replacement cyclingu na rizikovost provozu
      přeposílajícího LN uzlu, by tak měl činit v rámci již existujícího rizika.
      Pochopitelně je dobré hledat další způsoby snižování rizika.
      Tím se zabývá náš další bod.

- **Další navrhovaná opatření před replacement cycling útokem:** v době psaní
  zpravodaje se v emailových skupinách Bitcoin-Dev a Lightning-Dev objevilo
  přes 40 reakcí na odhalení útoku. Uvádíme některá navrhovaná opatření:

    - **Navyšování poplatků až do úplného konce:** Riardův [článek][riard
      cycle paper] o útoku a příspěvky v emailové skupině od [Ziggieho][ziggie
      cycle] a [Matta Morehouse][morehouse cycle] navrhují, aby obránce
      (např. Bob) namísto pouhého opakovaného zveřejňování své
      refundace začal zveřejňovat konfliktní alternativní transakce,
      které platí neustále se zvyšující jednotkové poplatky v souladu
      s tím, jak se blíží lhůta vyrovnání s útočníkem ve směru proti
      toku platby (např. MalloryA).

      Pravidla BIP125 vyžadují, aby útočník ve směru toku platby
      (např. MalloryB) platil za každé své nahrazení Bobovy transakce
      neustále se zvyšující poplatky, což by Bobovi umožnilo snížit
      ziskovost Mallořina útoku, pokud by se zdařil. Uvažme náš hrubý vzorec
      `x*y*z` z části o _opatření opakovanými zveřejněními_. Pokud by
      pro některá opakovaná zveřejnění narostly náklady na _x_, vzrostly
      by celkové náklady útoku a zvýšila by se maximální bezpečná hodnota HTLC.

      Riard ve svém článku vysvětluje, že náklady nemusí být symetrické,
      obzvláště v době, kdy se průměrný jednotkový poplatek zvyšuje a
      útočník je schopen vyhodit některé své transakce z mempoolů těžařů.
      V emailové skupině dále [píše][riard cycle2], že útočník může útok
      rozložit mezi více obětí pomocí určitého druhu [dávkových plateb][topic
      payment batching], čímž by mírně navýšil účinnost.

      Matt Corallo [poznamenává][corallo cycle2] hlavní nevýhodu tohoto
      přístupu v porovnání s prostým opakovaným zveřejněním: i kdyby Bob
      útočníka porazil, ztratil by část (nebo i všechnu) hodnoty HTLC.
      Teoreticky by útočník nebyl ochoten v útoku pokračovat, pokud
      by věřil, že obránce bude následovat cestu vzájemné destrukce.
      Bob by tedy ve skutečnosti nemusel vyšší a vyšší jednotkový
      poplatek platit. Zda by tomu tak ve skutečnosti v bitcoinové síti
      bylo, zůstává nezodpovězeno.

    - **Automatické opakované zkoušení minulých transakcí:** Corallo
      [naznačil][corallo cycle1], že „jediná oprava tohoto problému bude,
      když budou těžaři ukládat historii transakcí, které viděli, a budou
      je zkoušet znova po […] podobném útoku.” Bastien Teinturier
      [odpověděl][teinturier cycle]: „Souhlasím ale s Mattem, že bude
      nejspíš potřeba nějaké principiálnější změny na bitcoinové vrstvě,
      aby mohly L2 protokoly této třídě útoku lépe čelit.” Riard se též
      [vyjádřil][riard cycle3] v podobném duchu: „Trvalá oprava se může
      uskutečnit [jen] na základní vrstvě, například přidáním paměťově
      náročné historie všech viděných transakcí.”

    - **Předem podepsaná navýšení poplatku:** Peter Todd [řekl][todd cycle1],
      že „správným způsobem, jak předem podepisovat transakce, je předem
      podepsat dostatek *různých* transakcí, které by pokryly všechny
      rozumné potřeby navyšování poplatků. […] Neexistuje žádný důvod,
      proč by se měly transakce B->C zaseknout.” (Zdůraznění v originále.)

      To by mohlo fungovat následujícím způsobem: pro HTLC mezi Bobem
      a MalloryB poskytne Bob MalloryB deset různých podpisů stejné
      transakce s předobrazem s různými jednotkovými poplatky. Všimněte
      si, že v čase podepisování nemusí MalloryB Bobovi předobraz poskytnout.
      Zároveň poskytne MalloryB Bobovi deset různých podpisů stejné
      refundovací transakce s různými jednotkovými poplatky. Může tak být
      učiněno před zveřejněním refundace. Jednotkové poplatky by
      mohly být (sat/vbyte): 1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024,
      což by v dohledné době mělo pokrýt všechny případy.

      Je-li Mallořina transakce s předobrazem předem podepsána, jediné nahrazení,
      kterého by mohla dosáhnout, by bylo navýšení jednotkového poplatku.
      Nebyla by schopna přidat nový vstup do transakce s předobrazem, a
      tedy by nemohla útok zahájit.

    - **OP_EXPIRE:** v samostatném vlákně [navrhl][todd expire1] Peter Todd,
      cituje vlákno o útoku, několik změn konsenzu k umožnění opkódu
      `OP_EXPIRE`. Ten by učinil transakci nevalidní pro začlenění po určené
      výšce, pokud by script spustil `OP_EXPIRE`. Díky tomu by mohla být
      Mallořina podmínka s předobrazem v HTLC použitelná pouze před tím, než
      by byla Bobova refundovací podmínka utratitelná. To by zabránilo
      Mallory v nahrazení Bobovy refundovací transakce, a tím by nemohl
      být útok zahájen. `OP_EXPIRE` by též mohlo pomoci v boji proti
      některým [transaction pinning útokům][topic transaction pinning] proti
      HTLC.

      Hlavní nevýhodou `OP_EXPIRE` je, že vyžaduje změny konsenzu a změny
      pravidel přeposílání a mempoolu, aby se vyhnulo určitým problémům,
      jako je možnost použít jej k plýtvání zdroji uzlu.

      [Jedna odpověď][harding expire] pod tímto příspěvkem navrhla slabší verzi,
      která by dosáhla stejného cíle jako `OP_EXPIRE`, ale bez nutnosti
      měnit konsenzus či pravidla přeposílání. Avšak Peter Todd
      [odpověděl][todd expire2], že by replacement cycling útoku nezabránila.

    Očekáváme pokračování diskuzí o tomto tématu a v budoucích vydáních
    zpravodaje přineseme popis vývoje.

- **Nahrazení výpočtu hashe množiny bitcoinových UTXO:** Fabian Jahr
  zaslal do emailové skupiny Bitcoin-Dev [příspěvek][jahr hash_serialized_2]
  s oznámením o objevení chyby v Bitcoin Core ve výpočtu hashe aktuální
  množiny UTXO. Výpočet hashe UTXO nebral do úvahy výšku a coinbase,
  které jsou nutné pro vynucování pravidel 100blokové zralosti coinbasových
  transakcí a relativních časových zámků dle [BIP68][]. Všechny tyto informace
  zůstávají v databázi uzlu, který se synchronizuje od nuly (všechny současné
  Bitcoin Core uzly), a jsou nadále používané pro vynucování, takže tato chyba
  nepostihuje žádný známý vydaný software. Avšak experimentální [assumeUTXO][topic
  assumeutxo] plánované pro příští hlavní verzi Bitcoin Core umožní uživatelům
  navzájem sdílet své UTXO databáze. Neúplný commitment znamená, že upravená
  databáze by mohla mít stejný hash jako ověřená databáze, což by mohlo
  otevřít úzké okno útokům proti uživatelům assumeUTXO.

  Pokud víte o software, který používá pole `hash_serialized_2`, upozorněte
  prosím autory na tento problém a doporučte jim přečtení Jahrova emailu
  popisující změny, které budou v příštím hlavním vydání Bitcoin Core tuto
  chybu adresovat.

- **Výzkum obecných kovenantů s minimálními změnami Scriptu:**
  Rusty Russell zaslal do emailové skupiny Bitcoin-Dev [příspěvek][russell
  scripts] s odkazem na svůj [výzkum][russell scripts blog] použití
  několika jednoduchých nových opkódů umožňujících skriptu spouštěnému
  v transakci nahlížet do výstupních skriptů, na které se platí v té
  stejné transakci (_introspekce_). Schopnost provádět introspekci
  výstupních skriptů (a jejich commitmentů) by umožnila implementaci
  [kovenantů][topic covenants]. Uvádíme některá z jeho zjištění,
  která pokládáme za významná:

    - *Jednoduchost:* v jediném výstupním skriptu a jeho
      [taprootovém][topic taproot] commitmentu by bylo možné plně provádět
      introspekci pomocí tří nových opkódů a jednoho z dříve navrhovaných
      kovenantových opkódů (např. [OP_TX][news187 op_tx]). Každý z nových
      opkódů je snadno pochopitelný a jeví se jednoduše implementovatelný.

    - *Stručnost:* Russellovy příklady používají pro účely introspekce
      kolem 30 vbytů (vynucovaný skript by byl nad rámec těchto vbytů).

    - *Změny v OP_SUCCESS by prospěly:* [BIP342][] specifikace [tapscriptu][topic
      tapscript] definuje několik `OP_SUCCESSx` opkódů, které úspěšně ukončí
      skript, jež je obsahuje. To umožňuje budoucím soft forkům přidělit těmto
      opkódům nové podmínky (a učinit tak z nich běžné opkódy). Avšak kvůli tomuto
      chování by bylo používání introspekce s kovenanty, jež mohou obsahovat části
      libovolných skriptů, nebezpečné. Například by mohla Alice vytvořit
      kovenant, který by jí umožnil utratit prostředky na libovolnou
      adresu, pokud by tyto prostředky nejdříve utratila v oznamovací
      transakci [úschovny][topic vaults] a čekala určitý počet bloků,
      aby dala možnost zmrazovací transakci toto utracení blokovat.
      Pokud by však ona libovolná adresa obsahovala opkód `OP_SUCCESSx`,
      mohl by kdokoliv její peníze ukrást. Russell ve svém článku navrhuje dvě
      možná řešení tohoto problému.

  Výzkum obdržel několik reakcí a Russell naznačil, že pracuje na dalším
  příspěvku popisující introspekci výstupních částek.

- **Návrh BIPu pro OP_CAT:** Ethan Heilman zaslal do emailové skupiny
  Bitcoin-Dev [příspěvek][heilman cat] s [návrhem BIPu][op_cat bip]
  na přidání opkódu [OP_CAT][] do tapscriptu. Opkód by spojil dva elementy
  z vrcholu zásobníku do jednoho elementu. Odkazuje na několik popisů
  možností, které by sám `OP_CAT` přinesl. Jím navrhovaná referenční
  implementace obsahuje pouze 13 řádků (kromě prázdných řádků).

  Návrh obdržel průměrné množství reakcí, většina z nich se soustředila
  na limity v tapscriptu, které mohou snižovat užitečnost, a maximální
  možné náklady aktivace `OP_CAT` (či měl-li být některý z těchto limitů
  pozměněn).

## Vybrané otázky a odpovědi z Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] je jedním z prvních míst, kde hledají
přispěvatelé Optechu odpovědi na své otázky a kde – najdou-li volnou chvíli –
pomáhají zvědavým či zmateným uživatelům. V této měsíční rubrice nabízíme
některé z otázek a odpovědí, které obdržely vysoký počet hlasů.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}

- [Jak funguje algoritmus výběru mincí Branch and Bound?]({{bse}}119919)
  Murch shrnuje své bádání o algoritmu [Branch and Bound][branch
  and bound paper] („metoda větví a mezí”) pro [výběr mincí][topic coin selection],
  který „hledá nejméně plýtvající množinu vstupů, která produkuje transakci bez
  zůstatku.“

- [Proč se v bitcoinové síti posílá každá transakce dvakrát?]({{bse}}119819)
  Antoine Poinsot odpovídá na starší Satoshiho příspěvek v emailové skupině, který
  tvrdí, že „každá transakce musí být poslána dvakrát.” Poinsot vysvětluje, že
  sice v té době byla transakce poslána dvakrát (jednou během přeposílání transakce,
  podruhé během přeposílání bloku), avšak po následném přidání [přeposílání kompaktních bloků][topic
  compact block relay] dle [BIP152][] se data transakcí posílají jen jednou
  na každé spojení.

- [Proč jsou v bitcoinu  OP_MUL a OP_DIV neaktivní?]({{bse}}119785)
  Antoine Poinsot se domnívá, že opkódy `OP_MUL` a `OP_DIV` byly pravděpodobně
  deaktivovány (spolu s [dalšími opkódy][github disable opcodes]) v reakci na
  chyby [„1 RETURN”]({{bse}}38037) a [OP_LSHIFT crash][CVE-2010-5137] objevené
  několik týdnů předtím.

- [Proč jsou hashSequence a hashPrevouts počítány odděleně?]({{bse}}119832)
  Pieter Wuille vysvětluje, že rozdělením hashovaných dat transakce na
  předchozí výstupy a sekvence je možné hashe vypočítat pouze jednou
  a použít je na výpočet všech druhů sighash.

- [Proč při porovnávání hashe přidává Miniscript kontrolu velikosti předobrazu?]({{bse}}119892)
  Antoine Poinsot poznamenává, že [miniscript][topic miniscript] omezuje předobrazy
  ve velikosti, aby se vyvaroval nestandardních bitcoinových transakcí a
  nevalidních atomických směn napříč různými blockchainy a aby zajistil možnost
  přesného výpočtu velikosti (a nákladů) witnessů.

- [Jak může být poplatek v příštím bloku nižší, než je vylučovací poplatek mempoolu?]({{bse}}120015)
  Uživatel Steven odkazuje na rozhraní mempool.space, které ukazuje výchozí vylučovací
  poplatek 1,51 sat/vB, ale zároveň odhaduje, že příští blok bude obsahovat transakci
  s poplatkem 1,49 sat/vB. Podle Glozow je pravděpodobným vysvětlením, že plný mempool
  vyloučil transakci, která navyšovala minimální jednotkový poplatek (`-incrementalRelayFee`),
  ale ponechal v mempoolu některé transakce s nižším jednotkovým poplatkem, které vyloučeny
  být nemusely.

  Též zmiňuje, že asymetrie mezi [skórem předků][waiting for confirmation 2] pro výběr šablony
  bloku a skórem potomků pro vyloučení z mempoolu může být dalším možným vysvětlením.
  Odkazuje na [problém][Bitcoin Core #27677] související s [cluster mempool][topic cluster
  mempool], který asymetrii vysvětluje a nabízí možný nový přístup.

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [Bitcoin Core 25.1][] je údržbovým vydáním obsahujícím hlavně opravy chyb.
  Jedná se o aktuálně doporučovanou verzi Bitcoin Core.

- [Bitcoin Core 24.2][] je údržbovým vydáním obsahujícím hlavně opravy chyb.
  Je doporučována každému, kdo stále používá 24.0 nebo 24.1 a není schopen
  či ochoten aktualizovat na verzi 25.1.

- [Bitcoin Core 26.0rc1][] je kandidátem na vydání příští hlavní verze této
  převládající implementace plného uzlu. Ověřené testovací binárky nebyly
  v době psaní zveřejněny, očekáváme však jejich zveřejnění na této adrese
  krátce po vydání zpravodaje. Kandidáti na předchozí vydání mívají průvodce
  testování na [Bitcoin Core developer wiki][] a sezení [Bitcoin Core PR
  Review Club][] věnované testování. Vyzýváme čtenáře, aby pravidelně
  kontrolovali, zda jsou tyto zdroje již dostupné i pro tohoto kandidáta.

## Významné změny kódu a dokumentace
_Kvůli objemu novinek v tomto čísle a nedostatku času našeho hlavního
autora jsme nebyli schopni zpracovat přehled změn kódu za poslední týden.
Budou obsaženy v příštím vydání. Za zpoždění se omlouváme._

## Poznámky

[^rbf-warning]:
    Replacement cycle útok popsaný zde je založen na nahrazení transakce
    transakcí s nižším počtem vstupů, než měla transakce původní. Autoři
    peněženek jsou většinou před tímto chováním varováni. Například kniha
    _Mastering Bitcoin, 3rd edition_ uvádí:

    > Buďte obzvláště opatrní, vytváříte-li více než jedno nahrazení stejné
    > transakce. Musíte zajistit, aby byly všechny verze transakce v konfliktu
    > se všemi ostatními. Pokud by v konfliktu nebyly, mohlo by dojít k potvrzení
    > více transakcí, což by vedlo k přeplacení. Například:
    >
    > - Transakce verze 0 obsahuje vstup A.
    >
    > - Transakce verze 1 obsahuje vstupy A a B (např. jste museli přidat vstup B
    >   k zaplacení poplatku).
    >
    > - Transakce verze 2 obsahuje vstupy B a C (např. jste museli přidat vstup C
    >   k platbě zvláštních poplatků, ale C bylo dostatečně velké, že už jste
    >   nepotřebovali A).
    >
    > V tomto scénáři může těžař, který uložil transakci verze 0, potvrdit verze 0 i 2.
    > Platí-li obě verze stejnému příjemci, obdrží prostředky dvakrát (a těžař obdrží
    > poplatky ze dvou transakcí).
    >
    > Jednoduchým způsobem, jak se tomuto problému vyhnout, je ujistit se, že nahrazující
    > transakce vždy obsahuje všechny vstupy jako její předchozí verze.

{% include references.md %}
{% include linkers/issues.md v=2 issues="27677" %}
[news274 cycle]: /cs/newsletters/2023/10/18/#zverejneni-bezpecnostniho-problemu-postihujiciho-ln
[riard cycle1]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-October/021999.html
[corallo cycle1]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-October/022015.html
[osuntokun cycle1]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-October/022044.html
[riard cycle paper]: https://github.com/ariard/mempool-research/blob/2023-10-replacement-paper/replacement-cycling.pdf
[ziggie cycle]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-October/022005.html
[morehouse cycle]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-October/022024.html
[riard cycle2]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-October/022029.html
[corallo cycle2]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-October/022025.html
[teinturier cycle]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-October/022022.html
[riard cycle3]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-October/022032.html
[todd cycle1]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-October/022033.html
[todd expire1]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-October/022042.html
[harding expire]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-October/022050.html
[todd expire2]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-October/022051.html
[hash_serialized_2]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-October/022038.html
[russell scripts]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-October/022031.html
[russell scripts blog]: https://rusty.ozlabs.org/2023/10/20/examining-scriptpubkey-in-script.html
[news187 op_tx]: /en/newsletters/2022/02/16/#simplified-alternative-to-op-txhash
[heilman cat]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-October/022049.html
[op_cat bip]: https://github.com/EthanHeilman/op_cat_draft/blob/main/cat.mediawiki
[jahr hash_serialized_2]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-October/022038.html
[Bitcoin Core 25.1]: https://bitcoincore.org/bin/bitcoin-core-25.1/
[Bitcoin Core 24.2]: https://bitcoincore.org/bin/bitcoin-core-24.2/
[Bitcoin Core 26.0rc1]: https://bitcoincore.org/bin/bitcoin-core-26.0/
[news40 delta]: /en/newsletters/2019/04/02/#lnd-2759
[news95 delta]: /en/newsletters/2020/04/29/#new-attack-against-ln-payment-atomicity
[news109 delta]: /en/newsletters/2020/08/05/#lnd-4488
[news112 delta]: /en/newsletters/2020/08/26/#bolts-785
[news142 delta]: /en/newsletters/2021/03/31/#rust-lightning-849
[news248 delta]: /cs/newsletters/2023/04/26/#lnd-v0-16-1-beta
[news255 delta]: /cs/newsletters/2023/06/14/#eclair-2677
[bitcoin core developer wiki]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki
[bitcoin core pr review club]: https://bitcoincore.reviews/#upcoming-meetings
[branch and bound paper]: https://murch.one/erhardt2016coinselection.pdf
[github disable opcodes]: https://github.com/bitcoin/bitcoin/commit/4bd188c4383d6e614e18f79dc337fbabe8464c82#diff-27496895958ca30c47bbb873299a2ad7a7ea1003a9faa96b317250e3b7aa1fefR94
[CVE-2010-5137]: https://en.bitcoin.it/wiki/Common_Vulnerabilities_and_Exposures#CVE-2010-5137
[waiting for confirmation 2]: /cs/blog/waiting-for-confirmation/#incentivy
