---
title: 'Zpravodaj „Bitcoin Optech” č. 284'
permalink: /cs/newsletters/2024/01/10/
name: 2024-01-10-newsletter-cs
slug: 2024-01-10-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Tento týden přinášíme souhrn diskuze o LN anchorech a součástech návrhu
přeposílání transakcí verze 3 a připojujeme oznámení o pokusné implementaci
LN-Symmetry. Též nechybí naše pravidelné rubriky se souhrnem sezení
Bitcoin Core PR Review Clubu a popisem významných změn v populárním
bitcoinovém páteřním software.

## Novinky

- **Diskuze o LN anchorech a přeposílání transakcí verze 3:**
  Antoine Poinsot zaslal do fóra Delving Bitcoin [příspěvek][poinsot v3]
  oživující debatu o návrzích [pravidel přeposílání transakcí verze 3][topic
  v3 transaction relay] a [dočasných anchorů][topic ephemeral anchors]
  („ephemeral anchors”). Zdá se, že vlákno bylo motivováno [kritikou][todd v3]
  pravidel přeposílání v3, kterou Peter Todd zveřejnil na svém blogu.
  Diskuzi jsme rozčlenili do několik částí:

  - **Časté používání externích poplatků může ohrožovat decentralizaci těžby:**
    v ideální podobě by bitcoinový protokol odměňoval těžaře dle
    jejich hashrate. Poplatky placené za transakce tuto vlastnost zachovávají:
    těžař s 10 % hashrate má 10% pravděpodobnost ulovení poplatků za příští
    blok, zatímco těžař s 1 % hashrate má 1% šanci. Poplatky placené mimo
    transakce, tedy napřímo těžařům (nazývané [out-of-band fees][topic out-of-band
    fees]) tuto vlastnost narušují: systém, který platí těžařům kontrolujícím dohromady
    přes 55 % hashrate, nabízí 99% šanci potvrzení transakce během příštích
    šesti bloků. To by pravděpodobně mělo za následek velice málo poplatků
    směřující k malým těžařům s méně než 1 % hashrate. Pokud by byli malí těžaři
    placeni relativně méně než velcí, přirozeně by to vedlo k centralizaci.
    Ta by dále snížila počet subjektů, které musí být napadeny za účelem
    cenzurování transakcí.

    Aktivně používané protokoly, jako jsou [LN-Penalty s anchory][topic
    anchor outputs] (LN-Anchors), [DLC][dlc cpfp] či [validace na straně
    klienta][topic client-side validation], umožňují přinejmenším části
    svých onchain transakcí platit _exogenními_ poplatky. Tyto poplatky placené
    transakcí mohou být navýšeny poplatky placenými pomocí nezávislých UTXO.
    Například v LN-Anchors obsahuje commitment transakce za každou stranu
    jeden výstup pro navýšení poplatků pomocí [CPFP][topic cpfp] (potomek
    platí UTXO navíc) a transakce HTLC-Success a HTLC-Failure (HTLC-X) jsou
    částečně podepsané pomocí `SIGHASH_SINGLE|SIGHASH_ANYONECANPAY`. Mohou
    tak být agregovány do jediné transakce s přinejmenším jedním vstupem
    navíc pro platbu poplatků (z odděleného UTXO).

    Peter Todd se soustředil na potenciální verzi LN, která používá [P2TR][topic
    taproot] a navrhované dočasné anchory, a tvrdí, že jeho závislost na
    exogenních poplatcích motivuje k placení poplatků mimo blockchain.
    Konkrétně by jednostranné uzavření kanálu, ve kterém nečekají žádné platby
    ([HTLC][topic htlc]), umožnilo velkému těžaři přijímajícímu poplatky
    mimo blockchain začlenit do bloku dvakrát více zavírajících transakcí,
    než kolik by byl schopen začlenit malý těžař přijímající pouze běžné
    poplatky přes CPFP navyšování. Velký těžař by mohl vydělávat na
    nabízení poplatků mimo blockchain s dodatečnou slevou. Dle Petera Todda
    se jedná o ohrožení decentralizace.

    Příspěvek naznačuje, že některá použití exogenních poplatků v rámci
    protokolů jsou přijatelná, důležitá je tedy frekvence očekávaného
    používání a relativní rozdíl jejich velikostí oproti poplatkům mimo
    blockchain. Jinými slovy, často se opakující jednostranná uzavření
    kanálů bez čekajících plateb a se 100% velikostí navíc by zřejmě
    byla považována za rizikovější než zřídka se opakující jednostranná
    uzavření s 20 čekajícími HLTC, kde je 20 % velikosti navíc.

  - **Dopady exogenních poplatků na bezpečnost, škálovatelnost a náklady:**
    Toddův příspěvek také poznamenává, že existující návrhy jako
    [LN-Anchors][topic anchor outputs] i budoucí návrhy, které používají
    [dočasné anchory][topic ephemeral anchors], vyžadují po každém uživateli
    uchovávat v peněžence jedno UTXO navíc pro důležitá navýšení poplatků.
    Jelikož vytvoření UTXO s sebou nese náklady v podobě blokového prostoru,
    teoreticky se tím snižuje maximální počet nezávislých uživatelů protokolu
    o polovinu či více. Dále to znamená, že uživatel nemůže bezpečně alokovat
    celý svůj zůstatek peněženky na své LN kanály, což zhoršuje uživatelskou
    přívětivost LN. A konečně, používání [navyšování poplatků pomocí CPFP][topic
    cpfp] nebo dodatečných vstupů transakcí pro exogenní platby poplatků
    vyžaduje používání většího blokového prostoru a placení více poplatků
    než placení poplatků přímo ze vstupní hodnoty transakce (endogenní
    poplatky). Teoretické náklady se tak zvyšují, i kdybychom ostatní problémy
    neuvažovali.

  - **Dočasné anchory představují nový druh pinningových útoků:** jak jsme zmínili
    [v minulém zpravodaji][news283 pinning], Peter Todd popsal drobný pinningový
    útok proti uživatelům dočasných anchorů. Nemá-li commitment transakce
    žádné čekající platby (HTLC), může neprivilegovaný útočník vytvořit situaci,
    ve které může čestný uživatel platit 1,5× až 3,7× více na poplatcích, aby
    dosáhl zamýšleného jednotkového poplatku. Avšak pokud by se tento čestný
    uživatel rozhodl pro [trpělivost][harding pinning] namísto placení poplatků
    navíc, platil by útočník část nebo celý poplatek čestného uživatele. Jelikož
    nejsou commitment transakce bez čekajících plateb tlačené žádnými časovými
    zámky, mnoho čestných uživatelů se může rozhodnout pro trpělivost a nechat
    své transakce potvrdit za útočníkovy náklady. Útok je též proveditelný,
    pokud jsou nějaká HTLC použita, avšak náklady na vymanění se z útoku
    jsou pro čestného uživatele nižší a i tak může útočník nakonec tratit.

  - **Alternativa: používání endogenních poplatků s předem podepsanými RBF navýšeními:**
    Peter Todd navrhuje a analyzuje alternativní přístup: podepsání několika verzí
    každé commitment transakce s různými jednotkovými poplatky. Například navrhuje
    podepsat 50 různých verzí LN-Penalty commitment transakce v poplatcích
    začínajících na 10 sat/vbyte a navýšené v každé verzi o 10 % až do poplatku
    1 000 sat/vbyte. Nemá-li commitment transakce žádné čekající platby (HTLC),
    vyplývá z jeho analýzy, že by podepisování zabralo kolem pěti milisekund.
    Avšak za každé HTLC připojené ke commitment transakci by se počet podpisů
    zvýšil o 50 a podepisování by se navýšilo o pět milisekund. Bastien Teinturier
    odkázal na [dřívější diskuzi][bolts #1036], ve které použil podobný přístup.

    Ačkoliv může tento nápad v některých případech fungovat, Peter Todd poznamenal,
    že endogenní poplatky s předem podepsanými inkrementálními navýšeními nejsou
    vždy dostatečnou náhradou za exogenní poplatky. Jsou-li časová zdržení
    vyžadovaná za podepsání commitment transakcí obsahující několik HTLC
    vynásobena počtem skoků běžné platební cesty, může [prodleva][harding delays]
    snadno dosáhnout více než sekundy a teoreticky může vystoupat až za jednu
    minutu. Peter Todd poznamenal, že zdržení by mohlo být zhruba konstantní,
    pokud by byl dostupný navrhovaný opkód [SIGHASH_ANYPREVOUT][topic sighash_anyprevout]
    (APO).

    I kdyby prodleva byla konstantních pět milisekund, je [možné][harding stuckless],
    že by přeposílající uzly používající endogenní poplatky vydělávaly méně
    než uzly používající exogenní poplatky. Důvodem by bylo očekávání,
    že by plátci využívali [redundatního přeplácení][topic redundant
    overpayments], které by odměňovalo rychlejší přeposílání oproti
    pomalejším, i kdyby byl rozdíl pouze v řádu milisekund.

    Další obtíží by bylo používání stejných endogenních poplatků za předem podepsané
    HTLC-Success a HTLC-Timeout transakce (HTLC-X). I s APO by to mohlo vyžadovat
    <i>n<sup>2</sup></i> podpisů. Jak Peter Todd dodává, toto číslo by
    mohlo být sníženo předpokladem, že HTLC-X transakce by platily podobný
    jednotkový poplatek jako commitment transakce.

    [Diskuze][teinturier fees], zda by endogenní poplatky mohly vyústit
    v nadměrné množství kapitálu rezervovaného na poplatky, zůstala nedořešena.
    Například pokud by Alice podepsala varianty s poplatky od 10 do 1 000 sat/vbyte,
    musela by se rozhodovat na základě možnosti, že by její protistrana Bob
    odeslal na blockchain variantu s 1 000 sat/vbyte, i když ona sama by takový
    poplatek neplatila. Znamená to, že nemůže od Boba přijmout platby, ve kterých
    Bob odesílá peníze, které by potřeboval na variantu s 1 000 sat/vbyte.
    Například commitment transakce s 20 HTLC by dočasně zablokovala jeden milión
    satoshi (10 000 Kč v době psaní). Pokud by endogenní poplatky byly použity
    také pro HTLC-X transakce, dočasně zablokovaná částka za 20 HTLC by byla
    blíže k 4,5 miliónům satoshi (46 000 Kč). Pro porovnání, pokud by Bob
    očekával poplatky exogenně, nemusela by Alice pro svou bezpečnost
    redukovat kapacitu kanálu.

  - **Závěr:** diskuze v době psaní zpravodaje stále probíhala. Peter Todd ji
    uzavřel slovy, že „existující použití anchor výstupů by mělo být kvůli výše
    zmíněným rizikům centralizace těžby ukončeno a žádná nová podpora pro anchor
    výstupy by neměla být do nových protokolů či Bitcoin Core přidávána.”
    LN vývojář Rusty Russell zaslal [příspěvek][russell inline] o používání
    efektivnější formy exogenních poplatků v nových protokolech za účelem
    minimalizace rizik poplatků mimo blockchain. Ve vlákně ve fóru Delving
    Bitcoin obhajovali vývojáři pracující na LN, transakcích verze 3 a dočasných
    anchorech užitečnost anchorů a zdá se pravděpodobné, že budou fungovat i v protokolech
    kolem v3. Pokud se něco význačného přihodí, budeme o tom v budoucích zpravodajích
    informovat.

- **Implementace LN-Symmetry** Gregory Sanders zaslal do fóra Delving
  Bitcoin [příspěvek][sanders lns] se svou [pokusnou implementací][poc lns]
  protokolu [LN-Symmetry][topic eltoo] (původně nazývaného _eltoo_) pracující
  nad forkem Core Lightning. LN-Symmetry poskytuje obousměrné platební kanály,
  které zaručují schopnost publikovat na blockchainu poslední stav kanálu bez
  potřeby trestných transakcí. Avšak vyžadují, aby mohly dceřiné transakce
  utrácet z kterékoliv verze rodičovské transakce. To je možné pouze se softforkovou
  změnou protokolu jako [SIGHASH_ANYPREVOUT][topic sighash_anyprevout]. Sanders
  nabízí několik postřehů:

  - *Jednoduchost:* LN-Symmetry je mnohem jednodušším protokolem než současný
    protokol LN-Penalty/[LN-Anchors][topic anchor outputs].

  - *Pinning:* „[Pinningu][topic transaction pinning] je hrozně těžké se
    vyhnout.“ Sandersova práce v této oblasti mu dala vhled a inspiraci,
    která vedla v jeho příspěvky do [přeposílání balíčků][topic package relay]
    a jeho široce uznávaný návrh na [dočasné anchory][topic ephemeral anchors].

  - *CTV:* „[CTV][topic op_checktemplateverify] (emulované)
    […] umožňuje ‚rychlá přeposílání’, která jsou jednoduchá a pravděpodobně by
    v případě širokého používání redukovala časy plateb.”

  - *Tresty:* Tresty se skutečně zdají nepotřebné, jak vývojáři doufali. Avšak
    někteří lidé mysleli, že by tresty i nadále byly nutné pro odrazování
    zlomyslných protistran od pokusů o krádež. Podpora pro tresty by výrazně
    zvýšila složitost protokolu a vyžadovala by rezervování části prostředků
    na placení pokut. Bylo by tedy lepší se podpory trestů vyvarovat, pokud by
    nebyly nezbytně nutné pro bezpečnost.

  - *Expiry delta:* LN-Symmetry vyžaduje delší CLTV expiry delta, než bylo
    očekáváno. Když Alice přepošle HTLC Bobovi, dá mu určitý počet bloků
    na nárokování svých prostředků pomocí předobrazu. Po vypršení doby
    si může prostředky vzít zpět. Pokud Bob HTLC dále přepošle Carol,
    dá on jí nižší počet bloků na odhalení předobrazu. Rozdíl mezi těmito
    dvěma hodnotami je _CLTV expiry delta_. Sanders zjistil, že tyto rozdíly
    musí být dostatečně dlouhé, aby zabránily protistraně v obohacení,
    pokud by protokol v půlce přerušila.

  Sanders v současnosti pracuje na vylepšení mempoolu Bitcoin Core a pravidel
  přeposílání, která v budoucnosti usnadní nasazení LN-Symmetry i jiných protokolů.

## Bitcoin Core PR Review Club

*V této měsíční rubrice shrnujeme nedávné sezení [Bitcoin Core PR Review Club][] a
vyzdvihujeme některé z důležitých otázek a odpovědí. Klikněte na otázku a odpověď se vám odhalí.*

[Vyhoď upravený čas (druhý pokus)][review club 28956]
je PR od Niklase Göggeho, které upravuje kontrolu validity
bloku v souvislosti s časovým razítkem bloku. Zjednodušeně řečeno,
pokud je časové razítko bloku (obsažené v jeho hlavičce) příliš daleko
v minulosti nebo v budoucnosti, uzel blok odmítne jako nevalidní.
Poznamenejme, že je-li blok nevalidní kvůli časovému razítku, které
je příliš daleko v budoucnosti, může se tento blok stát validním
později (i když blockchain už se mezitím posune jinam).

{% include functions/details-list.md
  q0="Musí mít hlavička bloku časové razítko? Pokud ano, proč?"
  a0="Ano, časové razítko se používá v úpravách náročnosti a k validaci
      časových zámků transakcí."
  a0link="https://bitcoincore.reviews/28956#l-39"

  q1="Jaký je rozdíl mezi Median Time Past (MTP) a časem upraveným
      dle sítě (network-adjusted)? Který z nich je relevantní pro
      toto PR?"
  a1="MTP je medián času posledních 11 bloků a používá se jako spodní
      hranice validity časového razítka bloků. Čas upravený dle sítě
      je spočítán jako čas našeho uzlu plus medián rozdílů mezi naším
      časem a časem náhodně vybraných odchozích spojení (tento medián
      může být negativní). Pouze čas upravený dle sítě je předmětem
      tohoto PR."
  a1link="https://bitcoincore.reviews/28956#l-67"

  q2="Proč jsou tyto časy koncepčně zcela odlišné?"
  a2="MTP je jedinečně definovaný pro všechny uzly synchronizované
      na stejný blockchain: existuje konsenzus času. Čas upravený
      dle sítě se mezi uzly liší."
  a2link="https://bitcoincore.reviews/28956#l-74"

  q3="Proč zkrátka nepoužíváme MTP pro všechno a nevyhodíme čas dle sítě zcela?"
  a3="MTP se používá jako spodní hranice validity časového razítka bloku,
      ale jako horní hranice nemůže být použit, neboť časová razítka
      budoucích bloků jsou neznámá."
  a3link="https://bitcoincore.reviews/28956#l-77"

  q4="Proč jsou vynucovány limity, jak moc mimo může časové razítko bloku
      být od vlastního času uzlu? A jelikož nevyžadujeme přesný souhlas
      na čase, mohou být tyto limity přísnější?"
  a4="Rozsah časového razítka bloku je omezen, aby nemohly záškodnické
      uzly snadno manipulovat se změnami náročnosti a časovými zámky.
      Tento druh útoků se nazývá ohýbání času („timewarp”).
      Validní rozsah může být do určité míry striktnější,
      ale kdyby byl příliš striktní, mohlo by to vést k dočasnému
      štěpení blockchainu, neboť by některé uzly odmítaly bloky
      shledané validními jinými uzly. Časová razítka bloků nemusí
      být přesná, ale musí v dlouhodobém horizontu sledovat
      skutečný čas."
  a4link="https://bitcoincore.reviews/28956#l-82"

  q5="Proč by se před tímto PR snažil útočník manipulovat časem upraveným dle sítě?"
  a5="Jedná-li se o těžící uzel, mohl by způsobit odmítání
      vytěžených bloků nebo zabránění přijetí validního bloku,
      načež by těžař plýtval hashrate (oba tyto případy by pomohly
      konkurenčním těžařům). Mohl by přinutit napadený uzel
      následovat špatný blockchain. Mohl by způsobit, aby se transakce
      s časovými zámky netěžily ve správný čas. Mohl by provést
      [útok dilatací času][time dilation attack] v Lightning Network."
  a5link="https://bitcoincore.reviews/28956#l-89"

  q6="Jak mohl útočník před tímto PR manipulovat s časem upraveným dle sítě?
      Které síťové zprávy by použil?"
  a6="Útočník by nám musel poslat „version” zprávy s pozměněnými
      časovými razítky od několika spojení, která mají pod kontrolou.
      Musel by nás donutit mít více než polovinu odchozích spojení
      k jeho uzlům, což je velice náročné, avšak jednodušší než
      kompletní zastínění uzlu."
  a6link="https://bitcoincore.reviews/28956#l-100"

  q7="Toto PR používá jako horní hranici pro validaci času bloku místní čas uzlu
      namísto času upraveného dle sítě. Můžeme si být jisti, že se tím
      dosáhne snížení možnosti provádět tajuplné útoky a ne jejich
      zvýšení?"
  a7="Diskuze, zda je pro útočníka jednodušší ovlivnit množinu spojení
      uzlu nebo jeho vnitřní čas (např. použitím malware nebo falešnými
      NTP zprávami), zůstala bez jasného závěru. Většina účastníků se
      shodla, že PR přináší zlepšení."
  a7link="https://bitcoincore.reviews/28956#l-102"

  q8="Mění toto PR chování konsenzu? Pokud ano, jedná se o soft fork, hard fork
      nebo ani jeden? A proč?"
  a8="Protože pravidla konsenzu nemohou používat vnější data mimo blockchain
      (např. čas uzlu), nemůže toto PR být považováno za změnu konsenzu.
      Jedná se jen o změnu pravidel _přijetí_ sítí. Neznamená to však,
      že by tato pravidla byla volitelná – pravidla určující, jak daleko
      do budoucnosti se může časové razítko bloku odchýlit, jsou pro
      bezpečnost sítě [zásadní][se timestamp accecptance]."
  a8link="https://bitcoincore.reviews/28956#l-141"

  q9="Které operace před tímto PR závisely na času upraveném dle sítě?"
  a9="[`TestBlockValidity`][TestBlockValidity function],
      [`CreateNewBlock`][CreateNewBlock function] (používaný těžaři pro
      tvorbu šablon bloku) a
      [`CanDirectFetch`][CanDirectFetch function] (používaný v P2P vrstvě).
      Rozmanitost použití ukazuje, že PR neovlivňuje pouze validitu bloků,
      ale má také další dopady, které musí být ověřeny."
  a9link="https://bitcoincore.reviews/28956#l-197"
%}

## Významné změny v kódu a dokumentaci

*Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo] a
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [LND #8308][] navyšuje `min_final_cltv_expiry_delta` z 9 na 18 dle doporučení
  BOLT2 pro konečné platby. Tato hodnotu postihuje externí faktury, které nedodají
  parametr `min_final_cltv_expiry`. Změna napravuje problémy s interoperabilitou
  objevené poté, co CLN přestalo začleňovat parametr, když byla použita výchozí
  hodnota 18. O tomto problému jsme se též zmínili [v minulém čísle][cln hotfix].

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 15:00" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="1036,8308" %}
[poinsot v3]: https://delvingbitcoin.org/t/v3-transaction-policy-for-anti-pinning/340
[todd v3]: https://petertodd.org/2023/v3-transactions-review
[dlc cpfp]: https://github.com/discreetlogcontracts/dlcspecs/blob/master/Non-Interactive-Protocol.md
[news283 pinning]: /cs/newsletters/2024/01/03/#naklady-na-pinning-v3-transakci
[harding pinning]: https://delvingbitcoin.org/t/v3-transaction-policy-for-anti-pinning/340/22
[harding delays]: https://delvingbitcoin.org/t/v3-transaction-policy-for-anti-pinning/340/6
[harding stuckless]: https://delvingbitcoin.org/t/v3-transaction-policy-for-anti-pinning/340/5
[teinturier fees]: https://github.com/bitcoin/bitcoin/pull/28948#issuecomment-1873793179
[russell inline]: https://rusty.ozlabs.org/2024/01/08/txhash-tx-stacking.html
[sanders lns]: https://delvingbitcoin.org/t/ln-symmetry-project-recap/359
[poc lns]: https://github.com/instagibbs/lightning/tree/eltoo_support
[cln hotfix]: /cs/newsletters/2024/01/03/#core-lightning-6957
[review club 28956]: https://bitcoincore.reviews/28956
[time dilation attack]: /en/newsletters/2020/06/10/#time-dilation-attacks-against-ln
[se timestamp accecptance]: https://bitcoin.stackexchange.com/a/121251/97099
[TestBlockValidity function]: https://github.com/bitcoin/bitcoin/blob/063a8b83875997068b3eb506b5f30f2691d18052/src/validation.cpp#L4228
[CreateNewBlock function]: https://github.com/bitcoin/bitcoin/blob/063a8b83875997068b3eb506b5f30f2691d18052/src/node/miner.cpp#L106
[CanDirectFetch function]: https://github.com/bitcoin/bitcoin/blob/063a8b83875997068b3eb506b5f30f2691d18052/src/net_processing.cpp#L1314
