---
title: 'Zpravodaj „Bitcoin Optech” č. 348'
permalink: /cs/newsletters/2025/04/04/
name: 2025-04-04-newsletter-cs
slug: 2025-04-04-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Zpravodaj tento týden odkazuje na vzdělávací implementaci kryptografie
nad eliptickou křivkou secp256k1 používanou v bitcoinu. Též nechybí naše
pravidelné rubriky s popisem diskuzí o změnách konsenzu, oznámeními
nových vydání a souhrnem významných změn v populárním bitcoinovém
páteřním software.

## Novinky

- **Vzdělávací a experimentální implementace secp256k1:**
  Sebastian Falbesoner, Jonas Nick a Tim Ruffing zaslali do emailové
  skupiny Bitcoin-Dev [příspěvek][fnr secp] s ohlášením pythonové
  [implementace][secp256k1lab] rozličných kryptografických funkcí
  používaných v bitcoinu. Varují, že implementace „NENÍ BEZPEČNÁ”
  (verzálky v originále) a je „určená pro prototypování, experimenty
  a studium.”

  Dále poznamenávají, že referenční a testovací kód několika BIPů
  ([340][bip340], [324][bip324], [327][bip327] a [352][bip352]) již
  obsahuje „vlastní a někdy se drobně lišící implementace secp256k1.”
  Doufají, že tuto situaci vylepší a začnou snad nadcházejícím BIPem
  pro ChillDKG (viz [zpravodaj č. 312][news312 chilldkg]).

## Diskuze o změnách konsenzu

_Měsíční rubrika shrnující návrhy a diskuze o změnách pravidel
bitcoinového konsenzu._

- **Několik diskuzí o krádeži kvantovými počítači a obraně:**
  několik diskuzí zkoumalo, jak by bitcoineři reagovali, kdyby
  schopnosti kvantových počítačů umožnily krádež bitcoinů.

  - *Měly by být zranitelné bitcoiny zničeny?* Jameson Lopp [zaslal][lopp
    destroy] do emailové skupiny Bitcoin-Dev několik důvodů pro zničení
    bitcoinů náchylných na kvantovou krádež poté, co je nastolena cesta ke
    [kvantové odolnosti][topic quantum resistance], a po uplynutí dostatečné
    doby pro osvojení uživateli. Mezi některé důvody patří:

    - *Sdílená preference:* Lopp věří, že většina lidí by raději preferovala, aby
      byly jejich prostředky zničeny, než ukradeny někým s rychlým kvantovým počítačem,
      obzvláště když by to byl zloděj z „úzké skupinky privilegovaných lidí,
      kteří se ke kvantovým počítačům dostanou brzy.”

    - *Obecná škoda:* mnoho z ukradených bitcoinů by byly buď ztracené mince
      nebo mince určené pro dlouhodobé držení. Na druhou stranu by zloději
      rychle ukradené bitcoiny utratili, čímž by se snížila kupní síla ostatních
      bitcoinů (podobně jako u inflace peněžní zásoby). Poznamenává, že
      nižší kupní síla bitcoinů vede k nižším příjmům těžařů, což snižuje bezpečnost
      sítě a (dle Loppa) i ochotu obchodníků bitcoin přijímat.

    - *Minimální výhody:* i když by existence možnosti krádeže mohla vést k financování
      vývoje kvantových počítačů, krádež mincí neposkytuje poctivým účastníkům
      bitcoinového protokolu žádné přímé výhody.

    - *Jasná lhůta:* nikdo nemůže dopředu znát den, kdy někdo
      s kvantovým počítačem bude moci začít s krádeží bitcoinů, avšak datum,
      kdy by byly zranitelné mince zničeny, může být ohlášeno dlouho dopředu
      s dokonalou přesností. Tato jasná lhůta poskytne uživatelům více podnětů
      k včasnému zabezpečení jejich bitcoinů a zajistí minimální ztrátu mincí.

    - *Podněty těžařů:* jak bylo poznamenáno výše, kvantová krádež by pravděpodobně
      snížila příjmy těžařů. Trvalá většina hašovacího výkonu může cenzurovat
      platby kvantově zranitelnými bitcoiny, což mohou dělat, i kdyby měl zbytek
      bitcoinerů jiné preference.

    Lopp dále poskytuje několik argumentů proti destrukci zranitelných bitcoinů,
    ale na závěr se vyjadřuje ve prospěch zničení.

    Nagaev Boris [se ptá][boris timelock], zda UTXO, která mají [časový zámek][topic
    timelocks] za lhůtou, by měla být také zničena. Lopp poznamenává stávající
    potíže s dlouhými časovými zámky a říká, že se osobně cítí „při zamykání
    na déle než rok nebo dva trochu nervózní.”

  - *Bezpečné doložení vlastnictví UTXO odhalením SHA256 předobrazu:*
    Martin Habovštiak zaslal do emailové skupiny Bitcoin-Dev [příspěvek][habovstiak
    gfsig] s myšlenkou, která by komukoliv umožnila doložit kontrolu
    nad nějakým UTXO, i kdyby nebyly ECDSA a [Schnorrovy podpisy][topic
    schnorr signatures] bezpečné (např. po příchodu rychlých kvantových
    počítačů). Pokud by UTXO obsahovalo SHA256 (nebo jiný
    kvantově bezpečný) commitment k předobrazu, který nikdy předtím
    odhalen nebyl, mohl by být pro zabránění kvantové krádeže použit
    vícekrokový protokol (v kombinaci se změnou konsenzu) odhalující tento
    předobraz. Jedná se v základu o stejný nápad popsaný v [dřívějším návrhu][ruffing
    gfsig] Tima Ruffinga (viz [zpravodaj č. 141][news141 gfsig], _angl._), který se
    obecně nazývá [podpisové schéma Guy Fawkes][Guy Fawkes signature scheme].
    Jedná se také o variantu [schématu][back crsig], které Adam Back
    vymyslel v roce 2013 pro zlepšení ochrany proti cenzurujícím těžařům.
    Ve stručnosti funguje protokol takto:

    1. Alice obdrží prostředky na výstup, který nějakým způsobem vytváří SHA256
       závazek. Může to být přímo hašovaný výstup (P2PKH, P2SH, P2PWPKH, P2WSH)
       nebo [P2TR][topic taproot] výstup se skriptem.

    2. Pokud Alice obdrží několik plateb na stejný výstupní skript, musí
       se ujistit, že buď neutratí ani jednu z nich, dokud nebude připravena
       utratit všechny (určitě nutné pro P2PKH a P2WPKH, pravděpodobně
       v praxi potřebné též pro P2SH a P2WSH), nebo musí zajistit,
       že alespoň jeden předobraz zůstane po jejích platbách neodhalený
       (snadné s P2TR platbou klíčem oproti platbě skriptem).

    3. Je-li Alice připravena provést platbu, běžným způsobem vytvoří transakci,
       avšak nezveřejní ji. Dále získá nějaký bitcoin s kvantově bezpečným podpisovým
       algoritmem na zaplacení poplatků.

    4. V transakci posílající některé z kvantově bezpečných bitcoinů vytvoří
       závazek kvantově nezabezpečeným bitcoinům, které chce poslat, a také
       závazek nezveřejněné transakci (stále ji neodhaluje). Počká na dostatečný
       počet potvrzení transakce.

    5. Je-li Alicina transakce již dostatečně hluboko, odhalí předobraz a kvantově
       nezabezpečenou platbu.

    6. Uzly v síti hledají první transakci, která tomuto předobrazu zavazuje.
       Zavazuje-li tato transakce Alicině kvantově nezabezpečené platbě, její
       platbu provedou. Jinak nedělají nic.

    Tyto kroky zajistí, aby Alice nemusela odhalovat kvantově slabé informace,
    dokud si není jista, že její verze platby bude upřednostněna před
    pokusem o platbu nějakého provozovatele kvantového počítače. Přesnější
    popis protokolu lze nalézt v Ruffingově [příspěvku][ruffing gfsig] z roku 2018.
    Věříme, že takový protokol by mohl být nasazen jako soft fork (avšak nasazení
    se ve vlákně neprobíralo).

    Habovštiak říká, že by bitcoiny, které je možné bezpečně utratit
    použitím tohoto protokolu (např. pokud jejich předobrazy ještě nebyly
    odhaleny), neměly být zničeny, i kdyby se komunita rozhodla pro zničení
    kvantově zranitelných bitcoinů. Dále tvrdí, že možnost v naléhavých případech
    bezpečně utratit bitcoin snižuje urgentnost nasazení kvantově odolného
    schématu v blízké budoucnosti.

    Lloyd Fournier [říká][fournier gfsig]: „jestli se tento přístup přijme,
    myslím, že hlavní věcí pro uživatele je přesunout se na taprootovou
    peněženku“ pro její schopnost plateb klíčem pod současnými pravidly
    konsenzu včetně případů [opakovaného použití adresy][topic output linking],
    ale i pro odolnost vůči kvantové krádeži, pokud by byly platby klíčem
    později zakázány.

    V jiném vlákně (viz další položku) Pieter Wuille [poznamenal][wuille
    nonpublic], že UTXO zranitelná vůči kvantové krádeži také obsahují
    klíče, které nebyly veřejně použité, ale které jsou známé více
    stranám, jako jsou různé formy vícenásobného podpisu (LN, [DLC][topic
    dlc] či služby svěřenectví).

  - *Návrh BIPu na zničení kvantově nezabezpečených bitcoinů:* Agustin Cruz
    zaslal do emailové skupiny Bitcoin-Dev [příspěvek][cruz qramp] o [návrhu
    BIPu][cruz bip], který popisuje několik obecných možností procesu
    zničení bitcoinů, které nejsou zabezpečené vůči kvantové krádeži
    (pokud by se stala hrozbou). Cruz říká, že „vynucením lhůty pro migraci
    poskytujeme právoplatným majitelům jasnou a pevně danou příležitost
    zabezpečit své prostředky vynucenou migrací v dostatečném předstihu
    a s robustními ochranami; pro dlouhodobé zabezpečení bitcoinu je to
    zároveň realistické i nezbytné.”

    Jen málo diskuze v tomto vlákně se soustředilo na návrh BIPu. Podobně jako
    ve vlákně Jamesona Loppa (viz výše) se většina zaměřovala na otázku, zda je ničení
    kvantově nezabezpečených bitcoinů dobrý nápad.

- **Několik diskuzí o soft forku CTV+CSFS:** několik konverzací zkoumalo rozličné
  aspekty soft forků pro přidání opkódů [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify]
  (CTV) a [OP_CHECKSIGFROMSTACK][topic op_checksigfromstack] (CSFS).

  - *Kritika motivace CTV:* Anthony Towns [zaslal][towns ctvmot] kritiku
    motivace [BIP119][], která by dle něj byla přidáním CTV s CSFS
    do bitcoinu podryta. Několik dní po začátku diskuze přinesl autor BIP119
    aktualizaci odstraňující většinu (možná i všechny) kontroverzních
    výroků. Ve [zpravodaji č. 347][news347 bip119] jsme přinesli souhrn
    této změny, viz též [starší verzi][bip119 prechange] BIP119. Mezi
    diskutovaná témata patřilo:

    - *CTV+CSFS umožňuje vytváření nekonečných kovenantů:*
      Motivace CTV říká: „Kovenanty jsou historicky považované za
      nevhodné pro bitcoin, protože jsou příliš složité na implementaci
      a hrozí redukce zaměnitelnosti dotčených mincí. Tento BIP přináší
      jednoduchý kovenant nazvaný *šablona*, která umožňuje omezenou
      sadu vysoce hodnotných případů použití bez vážných rizik. Šablony
      dle BIP119 umožňují **nerekurzivní** kovenanty bez dynamického
      stavu, které musí být po jednom vyjmenované” (zdůraznění v původním textu).

      Towns popisuje skript používající CTV i CSFS a odkazuje na [transakci][mn
      recursive] na [signetu][topic signet] MutinyNetu, která může být
      utracena pouze zasláním shodné částky zpět stejnému skriptu.
      Ačkoliv se vedla o definicích debata, autor CTV již [dříve popsal][rubin
      recurse] funkčně identický konstrukt jako rekurzivní kovenant
      a Optech tuto konvenci ve svém [souhrnu][news190 recursive] (_angl._)
      následoval.

      Olaoluwa Osuntokun [obhajoval][osuntokun enum] motivaci CTV, jelikož
      skripty musí „být po jednom vyjmenované” a „bez dynamického stavu.” To
      je podobné [argumentům][rubin enumeration] autora CTV Jeremyho Rubina
      z roku 2022, kdy nazýval tento druh kovenantů platících sobě samým
      „rekurzivní, ale po jednom vyjmenovaný.” Towns [reagoval][towns enum],
      že přidání CSFS tento benefit (po jednom vyjmenované) podrývá. Požadoval
      úpravu BIPů CTV nebo CSFS, aby obsahoval popis „případu, který je
      nějakým způsobem hrozivý, ale kombinace CTV a CSFS mu zabraňuje.”
      Možná se tak [stalo][ctv spookchain] v nedávné aktualizaci BIP119,
      která popisuje „samoreprodukující automaty (obecně nazývané
      SpookChains),“ které by byly možné s [SIGHASH_ANYPREVOUT][topic
      sighash_anyprevout], ale ne s CTV+CSFS.

    - *Nástroje pro CTV a CSFS:* Towns [poznamenal][towns ctvmot], že
      používání stávajících nástrojů pro vývoj jeho rekurzivního skriptu
      je náročné. Ukazuje tím na nepřipravenost pro nasazení. Osuntokun
      [řekl][osuntokun enum], že nástroj, který používá, „je hezky
      přímočarý.” Towns ani Osuntokun neuvedli, jaké nástroje používají.
      Nadav Ivgi [poskytl][ivgi minsc] příklad používání jeho jazyka
      [Minsc][] a řekl, že „pracuje na vylepšení Minscu, aby byly tyhle
      věci snazší. Podporuje Taproot, CTV, PSBT, deskriptory,
      miniscript, Script, BIP32 a další." Přiznává však, že „hodně z toho
      stále nemá dokumentaci.”

    - *Alternativy:* Towns přirovnává CTV+CSFS ke svému Basic Bitcoin
      Lisp Language ([bll][topic bll]) i [Simplicity][topic simplicity],
      které by mohly poskytnout alternativní skriptovací jazyk. Antoine
      Poinsot [říká][poinsot alt], že alternativní jazyk, který je jednoduchý
      na porozumění, může být méně riskantní než malá změna do současného
      systému. Vývojář Moonsettler [tvrdí][moonsettler express], že
      díky inkrementálnímu přidávání nových schopností do bitcoinového
      skriptu je bezpečnější přidat nové funkce v budoucnu, neboť
      díky každému nárůstu expresivity je méně pravděpodobné, že narazíme
      na překvapení.

      Osuntokun a James O'Beirne [připravenost][obeirne readiness] bll a
      Simplicity v porovnání s CTV a CSFS [kritizovali][osuntokun enum].

  - *Výhody CTV+CSFS:* Steven Roose [zaslal][roose ctvcsfs] do fóra Delving
    Bitcoin příspěvek s návrhem na přidání CTV a CSFS do bitcoinu jako první krok
    před dalšími změnami, které by expresivitu navýšily ještě dále. Většina
    diskuze se soustředila na výčet možných výhod, které CTV, CSFS
    nebo oba dohromady poskytují. Mezi ně patří:

    - *DLC:* CTV i CSFS jednotlivě mohou snížit počet podpisů potřebných
      pro vytváření [DLC][topic dlc], obzvláště DLC pro podepisování velkého
      množství variant kontraktu (např. cenový kontrakt na BTC–USD vyčíslený
      v jednodolarových přírůstcích). Antoine Poinsot [odkázal][poinsot ctvcsfs1]
      na nedávné [oznámení][10101 shutdown] ukončení provozu jednoho poskytovatele
      DLC služeb jako důkaz, že bitcoinoví uživatelé nemají příliš zájem
      o DLC. Dále odkázal na několik měsíců starý [příspěvek][nick dlc] od
      Jonase Nicka, dle kterého „se DLC v bitcoinu neshledala s významným
      osvojením a nezdá se, že by jejich nízké používání pramenilo
      z výkonnostních limitů.” Odpovědi odkazovaly na jiné dosud funkční
      služby, včetně jedné, která [tvrdí][lava 30m], že vybrala „30 miliónů
      dolarů na financování.“

    - *Úschovny:* CTV zjednodušuje implementaci [úschoven][topic vaults] (vaults),
      které jsou možné i dnes s použitím předem podepsaných transakcí a
      (volitelně) vymazání soukromých klíčů. Anthony Towns [tvrdí][towns
      vaults], že tento typ úschoven není příliš zajímavý. James O'Beirne
      [odpovídá][obeirne ctv-vaults], že CTV či něco podobného je prerekvizitou
      pro budování pokročilejších typů úschoven, jako např. jeho [BIP345][]
      `OP_VAULT`.

    - *Kontrakty s odpovědnými výpočty:* CSFS může odstranit mnoho kroků
      v [kontraktech s odpovědnými výpočty][topic acc] (accountable computing
      contracts) jako BitVM, které aktuálně vyžadují používat Script pro
      provádění Lamportových podpisů. CTV by mohlo snížit počet kroků ještě
      více. Poinsot opět [pátrá][poinsot ctvcsfs1] po výrazné poptávce po BitVM.
      Gregory Sanders [odpovídá][sanders bitvm], že by mohlo být užitečné
      pro obousměrné přemosťování tokenů v Shielded [client-side
      validation][topic client-side validation] (viz [zpravodaj č. 322][news322
      csv-bitvm]). Avšak též poznamenává, že CTV ani CSFS výrazně nevylepšují
      model důvěry v BitVM; pro to by byly potřebné další změny.

    - *Vylepšení skriptů s časovými zámky v Liquid:* James O'Beirne
      [přeposílá][obeirne liquid] komentáře dvou inženýrů z Blockstream,
      že by dle jeho slov CTV mohlo „drasticky zlepšit skripty s časovými
      zámky v Liquid (od Blockstreamu), které vyžadují, aby byly mince
      pravidelně přesouvány.” Po žádostech o objasnění [vysvětlil][kanjalkar
      liquid] bývalý inženýr Blockstreamu Sanket Kanjalkar, že tou výhodou
      by bylo výrazné snížení transakčních poplatků. O'Beirne dále
      [sdílel][poelstra liquid] další podrobnosti od Andrew Poelstry,
      ředitele výzkumu v Blockstream.

    - *LN-Symmetry:* CTV spolu s CSFS mohou být použity k implementaci typu
      [LN-Symmetry][topic eltoo], který odstraňuje některé z nedostatků
      [LN-Penalty][topic ln-penalty] kanálů aktuálně používaných v LN a který
      by mohl umožnit vytváření kanálů s více než dvěma stranami (efektivnější
      pro správu likvidity a onchain). Gregory Sanders, který naimplementoval
      experimentální verzi LN-Symmetry (viz [zpravodaj č. 284][news284 lnsym])
      pomocí [SIGHASH_ANYPREVOUT][topic sighash_anyprevout] (APO), [poznamenává][sanders
      versus], že verze LN-Symmetry s CTV+CSFS neposkytuje tolik funkcí jako
      APO verze a vyžaduje několik kompromisů. Anthony Towns [dodává][towns nonrepo],
      že nikdo ještě neaktualizoval Sandersův experimentální kód s APO, aby
      běžel s moderním software a používal čerstvé funkce jako [TRUC][topic
      v3 transaction relay] a [dočasné anchory][topic ephemeral anchors], natož
      aby používal CTV+CSFS. Tím je naše schopnost hodnotit tuto kombinaci
      pro LN-Symmetry omezená.

      Poinsot [se ptá][poinsot ctvcsfs1], zda by implementace LN-Symmetry byla
      pro vývojáře LN prioritou, pokud by ji nějaký soft fork umožnil. Citace
      od dvou vývojářů Core Lightning (a též spoluautorů článku, který představil
      LN-Symmetry) naznačily, že pro ně to prioritou je. Na druhou stranu
      vedoucí vývojář LDK Matt Corallo [již dříve řekl][corallo eltoo]:
      „LN-Symmetry mi nepřijde tak zajímavá, abychom ji ‚museli hned dokončit’.”

    - *Ark:* Roose je šéfem firmy budující implementaci [Arku][topic ark].
      Říká, že „CTV je pro Ark převratnou novinkou, výhody CTV jsou pro uživatele
      nesporné a není pochyb, že obě implementace Arku začnou CTV používat, jakmile
      bude dostupné.” Towns [poznamenává][towns nonrepo], že nikdo Ark pro testování
      s APO či CTV nenaimplementoval. Roose krátce nato napsal [kód][roose ctv-ark],
      který přesně to činil. Dle něj je „pozoruhodně přímočarý” a prošel existujícími
      integračními testy. Vyčíslil dále některá z vylepšení: při přechodu
      na CTV „bychom mohli odstranit kolem 900 řádků kódu, snížit počet výměn v
      každém kole ze tří na dvě a snížit datový přenos, protože by nebylo
      nutné předávat nonce a částečné podpisy.”

      Roose později začal nové vlákno s diskuzí o výhodách CTV pro uživatele
      Arku (viz náš souhrn níže).

  - *Výhody CTV pro uživatele Arku:* Steven Roose zaslal do fóra Delving Bitcoin
    krátký [popis][roose ctv-for-ark] protokolu [Ark][topic ark] aktuálně nasazeného
    na [signetu][topic signet] nazvaného [bezkovenantový Ark][clark doc] (covenantless Ark,
    clArk). Dále popsal, jak by dostupnost opkódu [OP_CHECKTEMPLATEVERIFY][topic
    op_checktemplateverify] (CTV) mohla použitelnost jeho [kovenantové][topic covenants]
    verze pro uživatele zlepšit.

    Jedním z cílů Arku je umožnit [asynchronní platby][topic async payments], tedy
    platby provedené v okamžiku, kdy je příjemce offline. V clArku za tímto účelem
    odesílatel a Ark server rozšíří odesílatelův stávající řetězec předem
    podepsaných transakcí, což nakonec příjemci umožní získat nad prostředky
    exkluzivní kontrolu. Taková platba v Arku se nazývá [mimo kolo][oor doc]
    (out-of-round, _arkoor_). Když se příjemce opět připojí, může si zvolit,
    co dále dělat:

    - *Vystoupit (exit) po prodlevě:* zveřejnit kompletní řetězec předem podepsaných
      transakcí a tím vystoupit z [joinpoolu][topic joinpools] (nazývaného _Ark_,
      čili archa). To si vyžádá počkat na vypršení časového zámku odsouhlaseného
      odesílatelem. Jakmile získá předem podepsaná transakce dostatečné množství
      potvrzení, může si být příjemce jist, že má nad prostředky výhradní kontrolu.
      Ztrácí tím však výhody účasti v joinpoolu, jako jsou rychlé platby a nižší
      poplatky díky sdílení UTXO. Navíc musí platit transakční poplatky za potvrzení.

    - *Nic:* v běžném případě nakonec předem podepsaná transakce v řetězci transakcí
      expiruje a odesílatel si bude moci prostředky nárokovat. Nejedná se o krádež,
      ale o očekávanou součást protokolu. Server se může rozhodnout část nebo všechny
      prostředky nějakým způsobem uživatelovi vrátit. Dokud expirace nenastane,
      příjemce může jednoduše čekat.

      V krajním případě se mohou server a plátce v kterýkoliv okamžik tajně dohodnout a
      podepsat alternativní řetězec transakcí a ukrást tím prostředky zaslané
      příjemci. Poznámka: díky vlastnostem bitcoinu mohou server a plátce
      být stejná osoba, tajná dohoda tedy nemusí být ani potřeba. Avšak pokud příjemce
      drží kopii řetězce transakcí podepsaného spolu se serverem, může doložit,
      že server prostředky ukradl. To může stačit k odrazení ostatních od používání
      tohoto serveru.

    - *Obnovit (refresh):* ve spolupráci se serverem může příjemce atomicky přesunout vlastnictví
      prostředků v transakci podepsané spolu s plátcem na jinou předem podepsanou transakci,
      kterou příjemce spolupodepsal. Tím se prodlouží expirační lhůta a eliminuje se
      možnost serveru a předchozího plátce ukrást dříve zaslané prostředky. Avšak
      obnovování vyžaduje, aby server držel obnovované prostředky až do jejich expirace,
      což snižuje likviditu serveru. Proto server po příjemci požaduje platbu úroku
      (čas expirace je pevně daný, proto může být zaplacen předem).

    Dalším cílem návrhu Arku je umožnit účastníkům přijímat LN platby. Ve svém původním
    příspěvku a v [odpovědi][roose ctv-ark-ln] Roose vysvětluje, že stávající účastníci,
    kteří již prostředky v joinpoolu mají, mohou být penalizováni až do výše nákladů
    na onchain transakci, pokud řádně neprovedou interakci vyžadovanou pro příjem
    LN platby. Avšak ti, kteří prostředky v joinpoolu nemají, penalizováni být nemohou,
    proto mohou odmítat provádět vyžadované kroky a tím bez nákladů vytvářet problémy
    poctivým účastníkům. Zdá se, že to ve svém důsledku zabraňuje uživatelům Arku
    přijímat LN platby, doku nevloží na vybraný Ark server určité množství prostředků.

    Roose dále popisuje, jak by dostupnost CTV tento protokol vylepšila. Hlavní změnou
    je způsob vytváření kol. _Kolo v Arku_ (round) sestává z malé onchain transakce, která
    zavazuje stromu offchain transakcí. Těmi jsou v případě clArku předem podepsané
    transakce, což vyžaduje během provádění tohoto kola dostupnost všech plátců
    pro podepsání. S dostupným CTV by mohla každá větev ve stromu transakcí zavazovat
    svým potomkům pomocí CTV, bez podepisování. Tím by mohly být transakce vytvářené
    i pro účastníky, kteří nejsou v okamžiku vytváření kola dostupní. Přináší to
    tyto výhody:

    - *Neinteraktivní platby uvnitř kol:* namísto platby mimo kolo
      (arkoor) může plátce, který je ochoten čekat na příští kolo, poslat peníze
      uvnitř kola (in-round). To příjemcovi poskytuje jednu velkou výhodu:
      po dostatečném množství konfirmací získá výhradní kontrolu nad obdrženými
      prostředky (až do expirace, kdy může buď vystoupit nebo levně obnovit).
      Namísto čekání na potvrzení se může příjemce rozhodnout ihned důvěřovat
      protokolu Arku a incentivám serveru provozovat poctivě (viz též
      [zpravodaj č. 253][news253 ark 0conf]). Na jiném místě Roose poznamenal,
      že tyto neinteraktivní platby mohou být navíc [dávkované][topic payment
      batching] a lze tak poslat peníze více příjemcům najednou.

    - *Příjem LN plateb uvnitř kola:* uživatel může požádat o zaslání LN platby
      ([HTLC][topic htlc]) na Ark server, který potom tuto platbu [drží][topic hold
      invoices] do dalšího kola. Do něj by pomocí CTV tuto HTLC platbu začlenil,
      načež by mohl uživatel předobraz HTLC odhalit a platbu nárokovat. Avšak
      Roose poznamenává, že by to stále vyžadovalo „nějaká opatření proti
      zneužití” (věříme, že důvodem je riziko, že příjemce předobraz neodhalí,
      kvůli čemuž by zůstaly prostředky serveru uzamčené do konce kola, které by
      se mohlo prodloužit na dva i více měsíců).

      David Harding v [odpovědi][harding ctv-ark-ln] Roose žádá o další podrobnosti
      a přirovnává tuto situaci k [JIT kanálům][topic jit channels], které
      mají podobný problém s neodhalenými předobrazy ztěžující práci poskytovatelům
      lightningových služeb (LSP). LSP aktuálně řeší tento problém mechanismem
      založeným na důvěře (viz [zpravodaj č. 256][news256 ln-jit]). Pokud
      by bylo možné použít stejné řešení v CTV-Arku, mohlo by zřejmě umožnit bezpečný
      příjem LN plateb uvnitř kola také v clArku.

    - *Méně kol, méně podpisů, méně ukládání:* clArk používá [MuSig2][topic musig]
      a každá strana se musí účastnit více kol. Tím je potřeba generovat množství
      částečných podpisů a ukládat kompletní podpisy. S CTV by bylo
      generováno a ukládáno méně data a bylo by vyžadováno méně interakce.

- **Sémantika OP_CHECKCONTRACTVERIFY:** Salvatore Ingala zaslal do fóra
  Delving Bitcoin [příspěvek][ingala ccv] s popisem sémantiky navrhovaného opkódu
  [OP_CHECKCONTRACTVERIFY][topic matt] (CCV), s odkazem na [první návrh BIPu][ccv
  bip] a s odkazem na [návrh implementace][bitcoin core #32080] pro Bitcoin Core.
  Jeho popis začíná přehledem chování CCV: umožňuje zkontrolovat, že veřejný
  klíč zavazuje nějakým libovolným datům. Může zkontrolovat veřejný klíč
  utráceného i vytvářeného [taprootového][topic taproot] výstupu. Tím lze zajistit,
  že data z utráceného výstupu jsou přenesena do vytvářeného výstupu. V taprootu
  může tweak výstupu zavazovat listům [tapscriptu][topic tapscript]. Pokud
  tweak zavazuje jednomu nebo více tapscriptům, klade na výstup _platební
  podmínku_ (encumbrance; též „břemeno”), což umožní, aby byly podmínky
  kladené na utrácený výstup přenesené na výstup vytvářený – obecně
  (byť [kontroverzně][towns anticov]) se mu říká [kovenant][topic covenants].
  Kovenant může platební podmínku naplnit nebo pozměnit, což by kovenant
  ukončilo nebo pozměnilo jeho podmínky pro budoucí iterace. Ingala popisuje
  některé výhody a nevýhody tohoto přístupu:

  - *Výhody:* přímé používání taprootu, nezvyšuje velikost taprootových položek
    v množině UTXO a pokud nejsou vyžadována extra data, nemusí být do witnessů
    začleňována (a tedy v takových případech žádné dodatečné náklady).

  - *Nevýhody:* funguje pouze s taprootem, kontrola tweaků vyžaduje operace
    nad eliptickou křivkou, které jsou nákladnější než např. SHA256 operace.

  Samotný přenos platebních podmínek z utráceného výstupu na vytvářený výstup
  může být užitečný, avšak mnoho kovenantů bude chtít zajistit, aby byly
  všechny nebo některé bitcoiny z utráceného výstupu předány na vytvářený
  výstup. Ingala popisuje tři možnosti, jak s částkami naložit:

  - *Ignorovat:* částky nekontrolovat.

  - *Odečíst:* částka vytvářeného výstupu s konkrétním indexem (např.
    třetí výstup) je odečtena z částky utráceného výstupu se stejným indexem.
    Zbytky jsou uloženy na později. Příklad: má-li utrácený výstup s indexem tři
    hodnotu 100 BTC a vytvářený výstup s indexem tři hodnotu 70 BTC,
    potom si kód zapamatuje zbytek 30 BTC. Transakce je označena za nevalidní,
    pokud je vytvářený výstup větší než utrácený výstup (což by snížilo
    zbytek, třeba i pod nulu).

  - *Výchozí:* označit transakci za nevalidní, pokud není částka vytvářeného
    výstupu s konkrétním indexem větší než částka utráceného výstupu plus
    součet předchozích zbytků, které nebyly ještě s _výchozí_ kontrolou
    použité.

  Transakce je validní, pokud je některý výstup zkontrolován dvakrát
  s _odečíst_ nebo pokud jsou _odečíst_ a _výchozí_ použité na stejný výstup.

  Ingala poskytuje několik vizuálních příkladů kombinací těchto operací.
  Následuje náš textový popis jeho příkladu „pošli část hodnoty,” který
  by mohl být užitečný pro [úschovny][topic vaults]: transakce má jeden
  vstup (utrácí jeden výstup) o hodnotě 100 BTC a dva výstupy, jeden
  s 70 BTC a druhý s 30 BTC. CCV je během validace transakce proveden
  dvakrát:

  1. CCV provede _odečíst_ na index 0: 100 BTC utrácených, 70 BTC vytvářených,
     zbytek 30 BTC. V úschovně typu [BIP345][] by CCV vracelo těchto 70 BTC
     zpět na stejný skript.

  2. Podruhé použije _výchozí_ na index 1. I když existuje vytvářený výstup
     s indexem 1, žádný vstup mu neodpovídá, implicitně je tedy použita
     hodnota `0`. K této nule je připočten zbytek 30 BTC z _odečíst_ na
     indexu 0, což si vyžádá, aby byl tento vytvářený výstup roven 30 BTC
     (nebo vyšší). V úschovně typu BIP345 by CCV mohl tweaknout výstupní
     skript, aby umožnil utratit tuto hodnotu na libovolnou adresu
     po vypršení [časového zámku][topic timelocks] nebo ho kdykoliv vrátit na
     uživatelovu adresu hlavní úschovny.

  V příspěvku a v odpovědích se diskutují i alternativní přístupy,
  které Ingala zvažoval a zavrhl. Píše: „Myslím, že tato dvě chování (výchozí
  a odečíst) jsou velmi ergonomická a v praxi pokrývají většinu požadovaných
  kontrol částek.“

  Dále poznamenává, že „naimplementoval kompletní úschovny pomocí `OP_CCV`
  s [OP_CTV][topic op_checktemplateverify], které jsou zhruba na úrovni
  [… BIP345 …]. Navíc je méně vybavená verze používající jen `OP_CCV`
  naimplementovaná jako funkční test v Bitcoin Core implementaci `OP_CCV`.”

- **Zveřejněn návrh BIPu na pročištění konsenzu:** Antoine Poinsot zaslal
  do emailové skupiny Bitcoin-Dev [příspěvek][poinsot cleanup] s odkazem na
  svůj [návrh BIPu][cleanup bip] pro soft fork [pročištění konsenzu][topic
  consensus cleanup] (consensus cleanup). Obsahuje několik oprav:

  - Opravy dvou různých útoků [ohýbáním času][topic time warp], kterými by
    mohla většina hašovacího výkonu produkovat bloky zrychleným tempem.

  - Limit na provádění operací s podpisy (sigops) u zastaralých typů transakcí,
    který zabrání vytváření bloků s přespříliš pomalou validací.

  - Oprava jedinečnosti mincetvorné transakce dle [BIP34][], která by měla
    zcela zabránit [duplikovaným transakcím][topic duplicate transactions].

  - Zneplatnění budoucích 64bajtových transakcí pro zabránění určitého druhu
    [zranitelnosti Merkleova stromu][topic merkle tree vulnerabilities].

  Technicky zaměřené odpovědi byly nakloněné všem částem návrhu kromě dvou.
  První námitka se týkala zneplatnění 64bajtových transakcí. Odpovědi
  opakovaly předchozí kritiku (viz [zpravodaj č. 319][news319 64byte]).
  Existuje alternativní metoda řešení zranitelností Merkleova stromu, která
  je poměrně snadno použitelná pro lehké (SPV) peněženky, ale může být náročná
  pro SPV validaci chytrých kontraktů, jako jsou _přemostění_ mezi bitcoinem
  a jinými systémy. Sjors Provoost [navrhl][provoost bridge], aby někdo
  implementující takové přemostění poskytl kód ilustrující rozdíl mezi dvěma
  možnostmi: předpokládat, že 64bajtové transakce neexistují, a muset použít
  alternativní metodu pro odstranění zranitelností.

  Druhá námitka se týkala pozdní změny, která byla popsána v Poinsotově
  [příspěvku][poinsot nsequence] v Delving Bitcoin. Změna požaduje, aby
  měly bloky vytvořené po aktivaci soft forku nastavený příznak, který by
  aktivoval vynucování časových zámků jejich mincetvorných transakcí. Jak bylo
  již dříve navrženo, mincetvorné transakce v blocích po aktivaci budou mít
  časový zámek nastaven na výšku bloku (mínus 1). Tato změna znamená, že
  žádný těžař nebude moci vytvořit časný alternativní bitcoinový blok, který
  používá poaktivační časový zámek a také nastavuje příznak vynucování
  (protože pokud by tak učinil, jeho mincetvorná transakce by nebyla kvůli
  použití budoucího časového zámku platná v bloku, který ji obsahuje).
  Nemožnost použít přesně ty stejné hodnoty v minulých mincetvorných
  transakcích jako v budoucích zabrání problému duplikovaných transakcí.
  Námitka proti tomuto návrh byla, že není jasné, zda budou všichni těžaři
  schopni nastavit příznak vynucování časového zámku.


## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [BDK wallet 1.2.0][] přidává flexibilitu při posílání plateb na uživatelské
  skripty, opravuje okrajový případ související s mincetvornými transakcemi
  a obsahuje další novinky a opravy chyb.

- [LDK v0.1.2][] je vydáním této knihovny pro budování aplikací s LN. Obsahuje
  několik vylepšení výkonnosti a oprav chyb.

- [Bitcoin Core 29.0rc3][] je kandidátem na vydání příští hlavní verze tohoto
  převládajícího plného uzlu. Prosíme, přečtěte si [průvodce testováním verze
  29][bcc29 testing guide].

- [LND 0.19.0-beta.rc1][] je kandidátem na vydání tohoto oblíbeného LN uzlu.
  Jedním významným vylepšením, které by si zasloužilo důkladné testování, je
  nové schéma RBF navyšování poplatků během kooperativního zavření kanálu.

## Významné změny kódu a dokumentace

_Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo] a [repozitáři BINANA][binana repo]._

- [Bitcoin Core #31363][] přidává třídu `TxGraph` (viz [zpravodaj č. 341][news341
  pr review]), lehký model transakcí v mempoolu, který sleduje pouze
  jednotkové poplatky a závislosti mezi transakcemi. Přináší funkce pro modifikace
  jako `AddTransaction`, `RemoveTransaction` a `AddDependency` a funkce pro inspekci
  jako `GetAncestors`, `GetCluster` a `CountDistinctClusters`. `TxGraph` též
  podporuje přípravnou fázi změn s funkcemi commit nebo abort. Jedná se o součást
  projektu [mempoolu clusterů][topic cluster mempool] a je přípravou na budoucí
  vylepšení vylučování z mempoolu, řešení reorganizací a těžební logiky se znalostí
  clusterů.

- [Bitcoin Core #31278][] zastarává RPC příkaz `settxfee` a volbu
  `-paytxfee`, které umožňují nastavit všem transakcím statický poplatek.
  Uživatelé by měli spoléhat na [odhad poplatků][topic fee estimation] nebo nastavit
  poplatek pro každou transakci zvlášť. Budou odstraněné v Bitcoin Core 31.0.

- [Eclair #3050][] mění způsob přeposílání hlášení o selhání [BOLT12][topic offers] plateb
  v případech, kdy je příjemce přímo připojeným uzlem. Nově bude vždy zprávu
  přeposílat namísto posílání nečitelné chyby `invalidOnionBlinding`. Pokud chyba
  obsahuje `channel_update`, Eclair ji promění v `TemporaryNodeFailure`, aby neodhaloval
  údaje o [neoznámených kanálech][topic unannounced channels]. U [zaslepených cest][topic
  rv routing] obsahujících jiné uzly bude Eclair nadále posílat `invalidOnionBlinding`.
  Všechny chybové zprávy jsou šifrované pomocí `blinded_node_id`.

- [Eclair #2963][] implementuje [přeposílání balíčků][topic package relay] s jedním rodičem
  a jedním potomkem (1p1c). Za tímto účelem volá během vynucených zavření kanálů RPC příkaz
  Bitcoin Core `submitpackage`. Tím zveřejní commitment transakci i její anchor najednou.
  Díky tomu mohou být commitment transakce propagované, i když je jejich jednotkový poplatek
  pod minimem mempoolu. Vyžaduje však, aby byl uzel připojen ke spojením s Bitcoin Core 28.0
  nebo novějším. Tato změna odstraňuje potřebu dynamicky nastavovat poplatek commitment
  transakcí a zajišťuje, že se vynucená zavření nezaseknou, pokud se uzly nemohou shodnout
  na aktuálním poplatku.

- [Eclair #3045][] mění pole ve vnější `payment_secret` onion datové části na volitelné
  u [trampolínových plateb][topic trampoline payments] s jedinou částí. Dříve každá
  trampolínová platba obsahovala `payment_secret`, i když se nejednalo o [platbu s více částmi][topic
  multipath payments] (multipath payment, MPP). Jelikož platební tajné kódy mohou být vyžadované
  při zpracování moderních [BOLT11][] faktur, Eclair během dešifrování vloží maketu, pokud
  je potřeba.

- [LDK #3670][] přidává podporu pro přijímání a zpracování [trampolínových plateb][topic
  trampoline payments], ale zatím pro ně neposkytuje routování. Jedná se o předpoklad pro
  nasazení [asynchronních plateb][topic async payments].

- [LND #9620][] přidává podporu pro [testnet4][topic testnet].

{% include snippets/recap-ad.md when="2025-04-08 15:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="31363,31278,3050,2963,3045,3670,9620,32080" %}
[bitcoin core 29.0rc3]: https://bitcoincore.org/bin/bitcoin-core-29.0/
[bcc29 testing guide]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/29.0-Release-Candidate-Testing-Guide
[lnd 0.19.0-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.19.0-beta.rc1
[back crsig]: https://bitcointalk.org/index.php?topic=206303.msg2162962#msg2162962
[bip119 prechange]: https://github.com/bitcoin/bips/blob/9573e060e32f10446b6a2064a38bdc2047171d9c/bip-0119.mediawiki
[news75 ctv]: /en/newsletters/2019/12/04/#op-checktemplateverify-ctv
[news190 recursive]: /en/newsletters/2022/03/09/#limiting-script-language-expressiveness
[modern ctv]: /en/newsletters/2019/12/18/#proposed-changes-to-bip-ctv
[rubin enumeration]: https://gnusha.org/pi/bitcoindev/CAD5xwhjj3JAXwnrgVe_7RKx0AVDDy4X-L9oOnwhswXAQFoJ7Bw@mail.gmail.com/
[towns ctvmot]: https://mailing-list.bitcoindevs.xyz/bitcoindev/Z8eUQCfCWjdivIzn@erisian.com.au/
[mn recursive]: https://mutinynet.com/address/tb1p0p5027shf4gm79c4qx8pmafcsg2lf5jd33tznmyjejrmqqx525gsk5nr58
[rubin recurse]: https://gnusha.org/pi/bitcoindev/CAD5xwhjsVA7k7ZQ_QdrcZOxdi+L6L7dvqAj1Mhx+zmBA3DM5zw@mail.gmail.com/
[osuntokun enum]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CAO3Pvs-1H2s5Dso0z5CjKcHcPvQjG6PMMXvgkzLwXgCHWxNV_Q@mail.gmail.com/
[towns enum]: https://mailing-list.bitcoindevs.xyz/bitcoindev/Z8tes4tXo53_DRpU@erisian.com.au/
[ctv spookchain]: https://github.com/bitcoin/bips/pull/1792/files#diff-aaa82c3decf53fb4312de88fbb3cc081da786b72387c9fec7bfb977ad3558b91R589-R593
[ivgi minsc]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CAGXD5f3EGyUVBc=bDoNi_nXcKmW7M_-mUZ7LOeyCCab5Nqt69Q@mail.gmail.com/
[minsc]: https://min.sc/
[poinsot alt]: https://mailing-list.bitcoindevs.xyz/bitcoindev/1JkExwyWEPJ9wACzdWqiu5cQ5WVj33ex2XHa1J9Uyew-YF6CLppDrcu3Vogl54JUi1OBExtDnLoQhC6TYDH_73wmoxi1w2CwPoiNn2AcGeo=@protonmail.com/
[moonsettler express]: https://mailing-list.bitcoindevs.xyz/bitcoindev/Gfgs0GeY513WBZ1FueJBVhdl2D-8QD2NqlBaP0RFGErYbHLE-dnFBN_rbxnTwzlolzpjlx0vo9YSgZpC013Lj4SI_WZR0N1iwbUiNze00tA=@protonmail.com/
[obeirne readiness]: https://mailing-list.bitcoindevs.xyz/bitcoindev/45ce340a-e5c9-4ce2-8ddc-5abfda3b1904n@googlegroups.com/
[nick dlc]: https://gist.github.com/jonasnick/e9627f56d04732ca83e94d448d4b5a51#dlcs
[lava 30m]: https://x.com/MarediaShehzan/status/1896593917631680835
[news322 csv-bitvm]: /cs/newsletters/2024/09/27/#shielded-client-side-validation-csv
[news253 ark 0conf]: /cs/newsletters/2023/05/31/#vnitrni-transfery
[clark doc]: https://ark-protocol.org/intro/clark/index.html
[oor doc]: https://ark-protocol.org/intro/oor/index.html
[lopp destroy]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CADL_X_cF=UKVa7CitXReMq8nA_4RadCF==kU4YG+0GYN97P6hQ@mail.gmail.com/
[boris timelock]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CAFC_Vt54W1RR6GJSSg1tVsLi1=YHCQYiTNLxMj+vypMtTHcUBQ@mail.gmail.com/
[habovstiak gfsig]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CALkkCJY=dv6cZ_HoUNQybF4-byGOjME3Jt2DRr20yZqMmdJUnQ@mail.gmail.com/
[news141 gfsig]: /en/newsletters/2021/03/24/#taproot-improvement-in-post-qc-recovery-at-no-onchain-cost
[guy fawkes signature scheme]: https://www.cl.cam.ac.uk/archive/rja14/Papers/fawkes.pdf
[fournier gfsig]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CALkkCJYaLMciqYxNFa6qT6-WCsSD3P9pP7boYs=k0htAdnAR6g@mail.gmail.com/T/#ma2a9878dd4c63b520dc4f15cd51e51d31d323071
[wuille nonpublic]: https://mailing-list.bitcoindevs.xyz/bitcoindev/pXZj0cBHqBVPjkNPKBjiNE1BjPHhvRp-MwPaBsQu-s6RTEL9oBJearqZE33A2yz31LNRNUpZstq_q8YMN1VsCY2vByc9w4QyTOmIRCE3BFM=@wuille.net/T/#mfced9da4df93e56900a8e591d01d3b3abfa706ed
[cruz qramp]: https://mailing-list.bitcoindevs.xyz/bitcoindev/08a544fa-a29b-45c2-8303-8c5bde8598e7n@googlegroups.com/
[news347 bip119]: /cs/newsletters/2025/03/28/#bips-1792
[roose ctvcsfs]: https://delvingbitcoin.org/t/ctv-csfs-can-we-reach-consensus-on-a-first-step-towards-covenants/1509/
[poinsot ctvcsfs1]: https://delvingbitcoin.org/t/ctv-csfs-can-we-reach-consensus-on-a-first-step-towards-covenants/1509/4
[10101 shutdown]: https://10101.finance/blog/10101-is-shutting-down
[towns vaults]: https://delvingbitcoin.org/t/ctv-csfs-can-we-reach-consensus-on-a-first-step-towards-covenants/1509/14
[obeirne ctv-vaults]: https://delvingbitcoin.org/t/ctv-csfs-can-we-reach-consensus-on-a-first-step-towards-covenants/1509/23
[sanders bitvm]: https://delvingbitcoin.org/t/ctv-csfs-can-we-reach-consensus-on-a-first-step-towards-covenants/1509/7
[obeirne liquid]: https://delvingbitcoin.org/t/ctv-csfs-can-we-reach-consensus-on-a-first-step-towards-covenants/1509/24
[kanjalkar liquid]: https://delvingbitcoin.org/t/ctv-csfs-can-we-reach-consensus-on-a-first-step-towards-covenants/1509/28
[poelstra liquid]: https://delvingbitcoin.org/t/ctv-csfs-can-we-reach-consensus-on-a-first-step-towards-covenants/1509/32
[news284 lnsym]: /cs/newsletters/2024/01/10/#implementace-ln-symmetry
[sanders versus]: https://delvingbitcoin.org/t/ctv-csfs-can-we-reach-consensus-on-a-first-step-towards-covenants/1509/7
[towns nonrepo]: https://delvingbitcoin.org/t/ctv-csfs-can-we-reach-consensus-on-a-first-step-towards-covenants/1509/14
[roose ctv-ark]: https://codeberg.org/ark-bitcoin/bark/src/branch/ctv
[roose ctv-for-ark]: https://delvingbitcoin.org/t/the-ark-case-for-ctv/1528/
[roose ctv-ark-ln]: https://delvingbitcoin.org/t/the-ark-case-for-ctv/1528/5
[harding ctv-ark-ln]: https://delvingbitcoin.org/t/the-ark-case-for-ctv/1528/8
[news256 ln-jit]: /cs/newsletters/2023/06/21/#just-in-time-jit-kanaly
[ruffing gfsig]: https://gnusha.org/pi/bitcoindev/1518710367.3550.111.camel@mmci.uni-saarland.de/
[cruz bip]: https://github.com/chucrut/bips/blob/master/bip-xxxxx.md
[towns anticov]: https://gnusha.org/pi/bitcoindev/20220719044458.GA26986@erisian.com.au/
[ccv bip]: https://github.com/bitcoin/bips/pull/1793
[ingala ccv]: https://delvingbitcoin.org/t/op-checkcontractverify-and-its-amount-semantic/1527/
[news319 64byte]: /cs/newsletters/2024/09/06/#zabranovani-zranitelnostem-merkleova-stromu
[poinsot nsequence]: https://delvingbitcoin.org/t/great-consensus-cleanup-revival/710/79
[provoost bridge]: https://mailing-list.bitcoindevs.xyz/bitcoindev/19f6a854-674a-4e4d-9497-363af306e3a0@app.fastmail.com/
[poinsot cleanup]: https://mailing-list.bitcoindevs.xyz/bitcoindev/uDAujRxk4oWnEGYX9lBD3e0V7a4V4Pd-c4-2QVybSZNcfJj5a6IbO6fCM_xEQEpBvQeOT8eIi1r91iKFIveeLIxfNMzDys77HUcbl7Zne4g=@protonmail.com/
[cleanup bip]: https://github.com/darosior/bips/blob/consensus_cleanup/bip-cc.md
[news312 chilldkg]: /cs/newsletters/2024/07/19/#protokol-pro-distribuovane-generovani-klicu-pro-frost
[fnr secp]: https://mailing-list.bitcoindevs.xyz/bitcoindev/d0044f9c-d974-43ca-9891-64bb60a90f1f@gmail.com/
[secp256k1lab]: https://github.com/secp256k1lab/secp256k1lab
[corallo eltoo]: https://x.com/TheBlueMatt/status/1857119394104500484
[bdk wallet 1.2.0]: https://github.com/bitcoindevkit/bdk/releases/tag/wallet-1.2.0
[ldk v0.1.2]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.1.2
[news341 pr review]: /cs/newsletters/2025/02/14/#bitcoin-core-pr-review-club
