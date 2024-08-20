---
title: 'Zpravodaj „Bitcoin Optech” č. 250'
permalink: /cs/newsletters/2023/05/10/
name: 2023-05-10-newsletter-cs
slug: 2023-05-10-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Tento týden přinášíme popis článku o protokolu PoWswap a naše pravidelné
rubriky se souhrnem sezení Bitcoin Core PR Review Club, oznámeními o
nových verzích a popisem významných změn v populárních páteřních
bitcoinových projektech. Též nechybí krátká část oslavující pět let
Bitcoin Optech a naše 250. číslo.

## Novinky

- **Článek o protokolu PoWswap:** Thomas Hartman zaslal do emailové
  skupiny Bitcoin-Dev [příspěvek][hartman powswap] o [článku][hnr powswap],
  který napsal s Glebem Naumenkem a Antoinem Riardem, věnující se protokolu
  [PoWSwap][] poprvé navrženém Jeremy Rubinem. PoWswap umožňuje
  vytvářet onchainové kontrakty vztažené ke změně hash rate. Základní
  myšlenka spočívá ve využití vztahu mezi časem a produkcí bloků, který
  lze ověřovat na úrovni protokolu, spolu s možností vyjádřit časové
  zámky buď formou času nebo počtu bloků. Mějme například následující skript:

  ```
  OP_IF
    <Alicin klíč> OP_CHECKSIGVERIFY <čas> OP_CHECKLOCKTIMEVERIFY
  OP_ELSE
    <Bobův klíč> OP_CHECKSIGVERIFY <výška> OP_CHECKLOCKTIMEVERIFY
  OP_ENDIF
  ```

  Představme si, že aktuální čas je _t_ a aktuální výška bloků  je _x_.
  Předpokládejme, že bloky jsou produkovány průměrně v desetiminutových
  intervalech. Nastavíme-li `<čas>` na _t + 1 000  minut_ a `<výška>` na
  _x + 50_, můžeme očekávat, že Bob by byl schopen utratit výstup
  kontrolovaný výše uvedeným skriptem v průměru 500 minut před tím, než
  by ho mohla utratit Alice. Avšak pokud by se produkce bloků zrychlila
  více než dvakrát, mohla by Alice utratit výstup před Bobem.

  Lze si představit několik aplikací takového kontraktu:

  - *Pojištění proti navýšení hash rate:* těžaři musí zakoupit vybavení
   před tím, než najisto vědí, jaký příjem jim bude generovat. Například
   se může stát, že těžař zakoupí dost vybavení, aby obdržel jedno procento
   současných odměn. Tento těžař by jistě nepřivítal, kdyby ve stejné
   době jiný těžař zakoupil vybavení, kterým by zdvojnásobil celkový
   hash rate a tím by snížil jeho odměny na 0,5 %. Náš těžař by mohl
   pomocí PoWswap uzavřít kontrakt s někým, kdo je ochoten mu zaplatit
   v případě navýšení hash rate před určitým datem, čímž by vyrovnal
   těžařův neočekávaně nízký příjem. Výměnou by tento těžař souhlasil
   zaplatit větší částku, pokud by hash rate zůstal stejný nebo se snížil.

  - *Pojištění proti poklesu hash rate:* množství známých problémů
    bitcoinu by vyústilo ve velký pokles celkového hash rate. Hash rate
    by se snížil, pokud by těžaři byli zavírání nějakými mocnými stranami
    nebo pokud by se mezi zavedenými těžaři náhle začal ve velké míře
    objevovat [fee sniping][topic fee sniping] anebo pokud by hodnota
    BTC, který těžaři obdrží, náhle poklesla. Držitelé bitcoinu, kteří
    by se chtěli proti takovým situacím pojistit, by mohli uzavřít
    s těžaři nebo třetími stranami podobný kontrakt.

  - *Kurzové kontrakty:* obecně chtějí v případě navýšení kupní síly
    bitcoinu těžaři navýšit jimi poskytovaný hash rate, aby obdrželi
    více na odměnách. V případě poklesu kupní síly potom hash rate
    klesá. Lidé by mohli uzavírat kontrakty navázané na budoucí
    kupní sílu bitcoinu.

  I když se o PoWswap hovoří již několik let, tento článek poskytuje
  množství podrobností a analýz, které jsme do této doby neviděli.

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [Core Lightning 23.05rc2][] je kandidátem na vydání příští verze
  této implementace LN.

- [Bitcoin Core 24.1rc2][] je kandidátem na údržbové vydání aktuální
  verze Bitcoin Core.

- [Bitcoin Core 25.0rc1][] je kandidátem na vydání příští hlavní verze
  Bitcoin Core.

## Bitcoin Core PR Review Club

*V této měsíční rubrice shrnujeme nedávné sezení [Bitcoin Core PR Review Club][] a
vyzdvihujeme některé z důležitých otázek a odpovědí. Klikněte na otázku a odpověď se vám odhalí.*

[Přidej getprioritisationmap, odstraň položku z mapDeltas pokud delta==0][review club 27501]
je PR od Glorie Zhao (glozow) vylepšující funkci Bitcoin Core,
která těžařům umožňuje upravit efektivní poplatek konkrétní transakce
v mempoolu (viz RPC volání [`prioritisetransaction`][prioritisetransaction RPC]),
a tím zvýšit či snížit prioritu její těžby. Hodnota, která navýší poplatek
(je-li kladná) či sníží poplatek (je-li záporná), se nazývá _fee delta_.
Hodnoty prioritizace transakcí jsou ukládány na disk do souboru `mempool.dat`
a jsou v případě restartu obnoveny.

Jednou ze situací, kdy těžař využije prioritizaci transakcí, je obdržení
externí platby poplatku. Poplatek takové transakce se potom bude během
těžby považovat za vyšší.

PR přidává nové RPC volání `getprioritisationmap`, které vrací seznam
prioritizovaných transakcí. PR dále odstraňuje již nepotřebné položky
prioritizace, je-li jejich delta nastavena na nulu.

{% include functions/details-list.md
  q0="Co je datová struktura [mapDeltas][] a proč ji potřebujeme?"
  a0="Ukládá hodnoty prioritizace transakcí. Tyto hodnoty ovlivňují
      rozhodování o lokální těžbě, zahazování transakcí a také
      kalkulaci poplatků rodičů a potomků."
  a0link="https://bitcoincore.reviews/27501#l-26"

  q1="Ovlivňuje prioritizace transakcí algoritmus odhadování poplatků?"
  a1="Ne. Odhad poplatků musí přesně předpovídat očekávaná rozhodnutí
      těžařů (v tomto případě se jedná o _ostatní_ těžaře) a tito
      těžaři nemají stejnou prioritizaci jako my. Prioritizace je
      lokální."
  a1link="https://bitcoincore.reviews/27501#l-31"

  q2="Jak jsou do `mapDeltas` položky přidávány? Kdy jsou odstraněny?"
  a2="Jsou přidávány RPC voláním `prioritisetransaction` a také během
      restartu ze souboru `mempool.dat`. Odstraněny jsou v okamžiku
      začlenění bloku s transakcí do blockchainu nebo když je transakce
      [nahrazena (RBF)][topic rbf]."
  a2link="https://bitcoincore.reviews/27501#l-34"

  q3="Proč bychom neměli odstranit položku z `mapDeltas`, když je její transakce
      odstraněna z mempoolu (např. protože její čas vypršel nebo byla vyhozena
      kvůli nízkému poplatku)?"
  a3="Transakce se může vrátit zpět do mempoolu. Pokud by byla položka z
      `mapDeltas` ostraněna, musel by uživatel opět nastavit prioritizaci
      této transakce."
  a3link="https://bitcoincore.reviews/27501#l-84"

  q4="Je-li transakce odstraněna z `mapDeltas` z důvodu začlenění do bloku
      a tento blok je následně obětí reorganizace, nebude se muset
      znovu nastavit prioritizace transakce?"
  a4="Ano, ale reorganizace by měly nastávat zřídka. Navíc externí platby
      mohou být ve formě bitcoinové transakce a ta také může vyžadovat
      prioritizaci."
  a4link="https://bitcoincore.reviews/27501#l-90"

  q5="Proč bychom měli umožnit prioritizaci transakce, která není přítomna
      v mempoolu?"
  a5="Protože tato transakce nemusí být v mempoolu _prozatím_. A nemusí
      se do mempoolu ani dostat kvůli vlastnímu poplatku (bez prioritizace)."
  a5link="https://bitcoincore.reviews/27501#l-89"

  q6="Jaký problém nastává, když `mapDeltas` nepročišťujeme?"
  a6="Hlavním problémem je zbytečná alokace paměti."
  a6link="https://bitcoincore.reviews/27501#l-107"

  q7="Kdy se `mempool.dat` (včetně `mapDeltas`) zapisuje na disk?"
  a7="V případě řádného ukončení nebo RPC voláním `savemempool`."
  a7link="https://bitcoincore.reviews/27501#l-114"

  q8="Jak před tímto PR těžaři pročišťovali `mapDeltas`?"
  a8="Jediným způsobem bylo uzel restartovat, jelikož během restartu
      nejsou nulové prioritizace do `mapDeltas` vkládány. Díky PR
      jsou nulové položky z `mapDeltas` odstraněny okamžitě a nejsou
      tak ani zapisovány na disk."
  a8link="https://bitcoincore.reviews/27501#l-127"
%}

## Významné změny v kódu a dokumentaci

*Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo] a
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [Bitcoin Core #26094][] přidává do volání `getbalances`, `gettransaction`a
  `getwalletinfo` hash a výšku bloku. Tato volání zamykají chainstate,
  aby garantovala aktuální stav, začlenění validního hashe a výšky bloku
  do odpovědi je pro ně tedy výhodné.

- [Bitcoin Core #27195][] umožňuje odstranit všechny externí příjemce
  transakce, která je [nahrazována][topic rbf] pomocí volání `bumpfee`
  z interní peněženky Bitcoin Core. Uživatel tak učiní tím, že jediný
  výstup nahrazující transakce platí na jeho vlastní adresu. Po potvrzení
  nahrazující transakce nemůže dojít k zaplacení původním příjemcům.
  Této technice se někdy říká „zrušení” bitcoinové platby.

- [Eclair #1783][] přidává API `cpfpbumpfees` pro navýšení poplatku
  jedné nebo více transakcí pomocí [CPFP][topic cpfp]. PR také aktualizuje
  seznam [doporučených parametrů][eclair bitcoin.conf] pro provoz
  Bitcoin Core tak, aby navyšování poplatků bylo možné.

- [LND #7568][] přidává možnost definovat během startu dodatečné feature
  bity. Dále odstraňuje možnost deaktivovat jakékoliv pevně zakódované
  nebo definované feature bity během provozu (ale dodatečné bity
  mohou být přidány a později odstraněny). Navázaný návrh v [BLIPs #24][]
  poznamenává, že uživatelské [BOLT11][] feature bity jsou omezeny
  na maximální hodnotu 5114.

- [LDK #2044][] přináší několik změn v doporučeních tras v rámci
  [BOLT11][] faktur, tedy mechanismu, kterého může příjemce využít
  k návrhu tras, které může odesílatel použít. V rámci této změny
  jsou pro doporučení použity pouze první tři kanály (z důvodu efektivity
  a soukromí) a je vylepšena podpora phantom uzlů (viz [zpravodaj č.
  188][news188 phantom], *angl.*). Diskuze pod PR obsahuje [několik][carman
  hints] užitečných [komentářů][corallo hints] o dopadech používání
  doporučených tras na soukromí.

## Oslavujeme zpravodaj číslo 250

Bitcoin Optech byl zčásti založen, aby „pomohl vylepšit vztahy mezi
byznysem a open source komunitou.” Tento týdenní zpravodaj byl vytvořen,
aby poskytl vedení a vývojářům v bitcoinových firmách přehled o
výsledcích snah open source komunity. Proto jsme se v počátcích
soustředili na dokumentování činnosti, která může mít vliv na byznys.

Brzy jsme zjistili, že o tyto informace měli zájem nejen čtenáři
z řad byznysu. Mnoho přispěvatelů do bitcoinových projektů nemělo čas
na čtení všech diskuzí v emailových skupinách nebo na monitorování
významných změn jiných projektů. Rádi by, kdyby je někdo informoval
o změnách, které by je mohli zajímat či mít dopad na jejich práci.

Je nám potěšením již téměř pět let poskytovat tuto službu. Snažíme se
tuto jednoduchou misi rozšiřovat a proto také poskytujeme průvodce
[kompatibilitou peněženek][compatibility matrix], rejstřík více než
100 [témat][topics] a týdenní diskuzní [podcast][podcast] s hosty,
mezi kterými nechyběli mnozí z těch, o kterých máme tu čest psát.

Nic z toho by nebylo možné bez našich přispěvatelů, mezi kterými byli
za poslední rok: <!-- alphabetical -->
Adam Jonas,
Copinmalin,
David A. Harding,
Gloria Zhao,
Jiri Jakes,
Jon Atack,
Larry Ruane,
Mark „Murch” Erhardt,
Mike Schmidt,
nechteme,
Patrick Schwegler,
Shashwat Vangani,
Shigeyuki Azuchi,
Vojtěch Strnad,
Zhiwei „Jeffrey” Hu
a několik dalších, kteří přispěli k jednotlivým tématům.

Též zůstáváme navždy vděčni našim [zakládajícím sponzorům][founding
sponsors] Wencesovi Casaserovi, Johnovi Pfefferovi, Alexovi Morcosovi
a mnoha těm, kteří [přispěli finančně][financial supporters].

Děkujeme vám za čtení. Doufáme, že v tom budete během následujících 250
zpravodajů pokračovat.

{% include references.md %}
{% include linkers/issues.md v=2 issues="26094,27195,1783,7568,24,2044" %}
[Core Lightning 23.05rc2]: https://github.com/ElementsProject/lightning/releases/tag/v23.05rc2
[bitcoin core 24.1rc2]: https://bitcoincore.org/bin/bitcoin-core-24.1/
[bitcoin core 25.0rc1]: https://bitcoincore.org/bin/bitcoin-core-25.0/
[eclair bitcoin.conf]: https://github.com/ACINQ/eclair/pull/1783/files#diff-b335630551682c19a781afebcf4d07bf978fb1f8ac04c6bf87428ed5106870f5
[carman hints]: https://github.com/lightningdevkit/rust-lightning/pull/2044#issuecomment-1448840896
[corallo hints]: https://github.com/lightningdevkit/rust-lightning/pull/2044#issuecomment-1461049958
[hartman powswap]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-May/021605.html
[hnr powswap]: https://raw.githubusercontent.com/blockrate-binaries/paper/master/blockrate-binaries-paper.pdf
[powswap]: https://powswap.com/
[news188 phantom]: /en/newsletters/2022/02/23/#ldk-1199
[founding sponsors]: /en/about/#founding-sponsors
[financial supporters]: /#members
[review club 27501]: https://bitcoincore.reviews/27501
[prioritisetransaction rpc]: https://developer.bitcoin.org/reference/rpc/prioritisetransaction.html
[mapDeltas]: https://github.com/bitcoin/bitcoin/blob/fc06881f13495154c888a64a38c7d538baf00435/src/txmempool.h#L450
