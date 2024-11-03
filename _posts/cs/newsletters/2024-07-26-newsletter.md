---
title: 'Zpravodaj „Bitcoin Optech” č. 313'
permalink: /cs/newsletters/2024/07/26/
name: 2024-07-26-newsletter-cs
slug: 2024-07-26-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Zpravodaj tento týden shrnuje bohatou diskuzi o přeposílání zdarma a
změnách navyšování poplatků v Bitcoin Core. Též nechybí naše pravidelné
rubriky s přehledem oblíbených otázek a odpovědí z Bitcoin Stack Exchange,
s oznámeními nových vydání a s popisem významných změn v populárních
bitcoinových páteřních projektech.

## Novinky

- **Pestrá diskuze o přeposílání zdarma a změnách navyšování poplatků:**
  Peter Todd zaslal do emailové skupiny Bitcoin-Dev [příspěvek][todd fr-rbf]
  s popisem útoku přeposíláním zdarma, který před tím
  [zodpovědně nahlásil][topic responsible disclosures] vývojářům Bitcoin
  Core. To vedlo k propletené diskuzi o několika problémech a navrhovaných
  vylepšeních. Mezi diskutovanými tématy byly:

  - *Útoky přeposíláním zdarma:* [přeposílání zdarma][topic
    free relay] nastává, když plný uzel přeposílá nepotvrzené transakce,
    které neplatí alespoň minimální poplatek pro přeposílání (ve výchozím
    nastaven 1 sat/vbyte). Přeposílání zdarma často něco stojí, technicky
    tedy není zcela zdarma, náklady jsou však hluboko pod tím, co musí
    platit čestní uživatelé.

    Přeposílání zdarma umožňuje útočníkovi významně navýšit množství
    šířky pásma, které přeposílající plné uzly používají, což může
    snížit počet přeposílajících uzlů. Pokud by počet nezávisle provozovaných
    přeposílajících uzlů klesl příliš nízko, posílali by plátci své transakce
    v podstatě přímo těžařům, což by mělo stejná rizika centralizace jako
    [poplatky bokem][topic out-of-band fees].

    Toddem popisovaný útok zneužívá rozdílů v pravidlech mempoolu mezi
    těžaři a uživateli. Mnoho těžařů zjevně zapíná [full-RBF][topic rbf],
    avšak v Bitcoin Core je ve výchozím nastavení vypnuté (viz [zpravodaj
    č. 263][news263 full-rbf]). To umožňuje útočníkovi zbastlit různé
    verze transakce, které budou odlišně zpracovány full-RBF těžaři
    a nefull-RBF přeposílajícími uzly. Přeposílající uzly mohou nakonec
    přeposílat více verzí transakce, které mají minimální šanci na potvrzení,
    čímž plýtvají šířkou přenosového pásma přeposílajících uzlů.

    Útoky přeposíláním zdarma útočníkovi přímo neumožňují ukrást cizí
    prostředky, avšak náhlý či dlouhodobý útok může být použit k narušení
    sítě a může usnadnit jiné druhy útoků. Pokud víme, zatím nebyl vykonán
    žádný vážný útok přeposíláním zdarma.

  - *Přeposílání zdarma a nahrazení jednotkovým poplatkem:* Peter Todd dříve
    navrhl dva druhy nahrazení jednotkovým poplatkem (replace-by-feerate, RBFR),
    viz [zpravodaj č. 288][news288 rbfr]. Jednou z kritik RBFR bylo, že by
    umožňovalo přeposílání zdarma. Podobné množství přeposílání zdarma
    je již možné kvůli útoku, který sám popsal tento týden, či jiným, podobným
    útokům. Dle Todda by neměly obavy z přeposílání zdarma blokovat
    přidání vlastnosti užitečné pro obranu před [pinningovými útoky][topic
    transaction pinning].

    Jedna [reakce][harding rbfr fundamental] tvrdila, že přeposílání
    zdarma, které RBFR umožňuje, je inherentní jeho designu, ale podobné problémy
    v designu Bitcoin Core lze vyřešit. Todd projevil [nesouhlas][todd
    unsolvable].

  - *Užitečnost TRUC:* Peter Todd tvrdil, že [TRUC][topic v3 transaction
    relay] je „špatný návrh.” Již dříve protokol kritizoval (viz [zpravodaj
    č. 283][news283 truc pin]) a konkrétně kritizoval specifikaci TRUC,
    [BIP431][], která z obav o přeposílání zdarma dává přednost TRUC
    před Toddovým návrhem na RBFR.

    Avšak BIP431 také odrazuje od verzí RBFR, jako je Toddovo jednorázové
    RBFR, které závisí na tom, aby nahrazující transakce platila tak vysoký
    jednotkový poplatek, že by se stala po několik následujících bloků jednou
    z nejvýdělečnějších transakcí (byla by na „vrcholu mempoolu”). Todd
    i jiní souhlasili, že by to bylo jednodušší, až Bitcoin Core začne používat
    [cluster mempool][topic cluster mempool], avšak Todd navrhl i jiné způsoby
    dostupné již dnes. TRUC nepožaduje informace o vrcholu mempoolu, nezávisí
    tedy na cluster mempoolu ani jeho alternativách.

    Delší formát této kritiky byl shrnut ve [zpravodaji č. 288][news288 rbfr]
    a následný výzkum byl shrnut ve [zpravodaji č. 290][news290 rbf].
    Oba ilustrují, jak složité je vymyslet pravidla nahrazování, která by
    vždy měla pozitivní dopad na těžařovu výdělečnost. Narozdíl od RBFR
    nevyžaduje TRUC změnu pravidel nahrazování v Bitcoin Core (kromě
    požadavku, že se u TRUC transakcí má nahrazení vždy zvážit),
    neměl by tedy zhoršit stávající problémy se souladem ekonomických podnětů.

  - *Cesta ke cluster mempoolu:* jako bylo popsáno ve [zpravodaji
    č. 285][news285 cluster cpfp-co], návrh [cluster mempoolu][topic
    cluster mempool] vyžaduje odstranění [CPFP výjimky][topic cpfp carve out]
    (CPFP carve-out, CPFP-CO), které je v současnosti používáno v LN
    v [anchor výstupech][topic anchor outputs], které chrání vysoké částky
    v platebních kanálech. V kombinaci s [přeposíláním balíčků][topic package
    relay] (konkrétně s nahrazováním balíčků poplatkem) by mohlo jednorázové
    RBFR nahradit CPFP-CO, aniž by vyžadovalo jakékoliv změny v LN software,
    který již umí navyšovat poplatky svým útratám s anchor výstupy. Avšak jednorázové
    RBFR závisí na znalosti jednotkových poplatků na vrcholu mempoolu, například
    z cluster mempoolu, RBFR a cluster mempool by tak musely být nasazené naráz
    nebo by musela být použita jiná metoda určení jednotkových poplatků
    na vrcholu mempoolu.

    TRUC také nabízí alternativu CPFP-CO, ale je volitelnou funkcí. Všechen LN
    software by musel být aktualizován, aby TRUC podporoval, a všechny existující
    kanály by musely podstoupit [změnu commitmentu kanálu][topic channel commitment
    upgrades]. To by mohlo trvat velice dlouho, proto by CPFP-CO nemohlo být
    odstraněno, dokud by nebylo evidentní, že všichni uživatelé LN aktualizovali.
    Dokud by nebylo CPFP-CO deaktivováno, nemohl by být cluster mempool bezpečně
    široce nasazen.

    Jak zmínily dřívější zpravodaje [č. 286][news286 imbued], [č. 287][news287 sibling]
    a [č. 289][news289 imbued], pomalá adopce TRUC a rychlá dostupnost cluster
    mempoolu by mohly být adresovány pomocí _vštípeného TRUC_, které by automaticky
    aplikovalo TRUC a [vylučování sourozenců][topic kindred rbf] na LN commitment
    transakce vypadající jako anchory. Několik LN vývojářů a přispěvatelů návrhu
    na vštípený TRUC [se vyjádřilo][teinurier hacky], že by se tomu [raději][daftuar
    prefer not] vyhnuli (explicitní upgrade na TRUC je z mnoha důvodů lepší
    a pro LN vývojáře existuje množství jiných důvodů, proč pracovat na mechanismech
    upgradování kanálů), ale je možné, že vštípený TRUC bude opět zvažován,
    pokud by byl vývoj cluster mempoolu rychlejší než vývoj upgradu LN commitmentů.

    Ačkoliv by vštípený TRUC i široce používaný volitelný TRUC umožnily odstranění
    CPFP-CO a tím umožnily nasazení cluster mempoolu, ani jeden z těchto systému
    nezávisí na cluster mempoolu nebo jiných nových způsobech počítání souladu
    ekonomických podnětů transakcí. Díky tomu je analyzování TRUC bez závislosti
    na cluster mempoolu snazší než analyzování RBFR.

  V době psaní zpravodaje diskuze nadále probíhala.

## Vybrané otázky a odpovědi z Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] je jedním z prvních míst, kde hledají
přispěvatelé Optechu odpovědi na své otázky a kde – najdou-li volnou chvíli –
pomáhají zvědavým či zmateným uživatelům. V této měsíční rubrice nabízíme
některé z otázek a odpovědí, které obdržely vysoký počet hlasů.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Proč je pro cluster mempool potřebné měnit strukturu mempoolu?]({{bse}}123682)
  Murch vysvětluje problémy se současnou datovou strukturou mempoolu v Bitcoin
  Core, jak cluster mempool tyto problém řeší a jak by [cluster mempool][topic
  cluster mempool] mohl být v Bitcoin Core nasazen.

- [DEFAULT_MAX_PEER_CONNECTIONS pro Bitcoin Core je 125 nebo 130?]({{bse}}123645)
  Lightlike vysvětluje, že i když je nejvyšší počet automatických spojení v Bitcoin
  Core 125, provozovatel uzlu může ručně přidat až osm spojení.

- [Proč pracují vývojáři protokolů na maximalizace těžařových výdělků?]({{bse}}123679)
  David A. Harding vyjmenovává několik výhod schopnosti predikovat, které transakce
  se dostanou do bloku, za použití předpokladu, že těžaři budou maximalizovat
  výdělek z poplatků. Dále poznamenává: „To umožňuje plátcům odhadovat rozumné
  jednotkové poplatky, dobrovolným přeposílajícím uzlům operovat se soudnou
  šířkou pásma a paměti a malým decentralizovaným těžařům vydělávat na poplatcích shodně
  s velkými těžaři.”

- [Existují ekonomické podněty k používání P2WSH namísto P2TR?]({{bse}}123500)
  Vojtěch Strnad vysvětluje, že i když některá užití P2WSH mohou být levnější
  než P2TR výstupy, většina případů používání P2WSH (např. multisig a LN)
  by skrýváním nepoužitých skriptů v [taprootu][topic taproot] a používáním
  [Schnorrových podpisů][topic schnorr signatures] pro agregaci klíčů
  (např. [MuSig2][topic musig] či FROST) dosáhla redukce poplatků.

- [Kolik bloků za sekundu může být udržitelně tvořeno útokem ohýbáním času?]({{bse}}123698)
  Murch vypočítává, že v kontextu [útoku ohýbáním času][topic time warp] by „byl
  útočník schopen stabilně produkovat šest bloků za sekundu bez navýšení obtížnosti.”

- [Je pkh() uvnitř tr() povoleno?]({{bse}}123568)
  Pieter Wuille vysvětluje, že dle [BIP386][] („Deskriptory tr() výstupních skriptů”)
  nepředstavuje `pkh()` uvnitř `tr()` validní deskriptor, avšak dle [BIP379][]
  („Miniscript”) je taková konstrukce povolena. Vývojáři aplikací by si měli
  zvolit, kterých konkrétních BIPů se budou držet.

- [Může být více než týden starý blok považován za validní vrchol řetězce?]({{bse}}123671)
  Murch soudí, že takový vrchol řetězce by mohl být považován za validní, ale
  dokud by byl více než 24 hodin v minulosti oproti místnímu času uzlu, zůstával
  by tento uzel ve stavu „initialblockdownload.”

- [Změna transakce pomocí SIGHASH_ANYONECANPAY]({{bse}}123429)
  Murch objasňuje problémy používání `SIGHASH_ALL | SIGHASH_ANYONECANPAY` v onchain
  crowdfundingových schématech a ukazuje, jak by mohl pomoci [SIGHASH_ANYPREVOUT][topic
  sighash_anyprevout].

- [Proč existuje RBF pravidlo č. 3?]({{bse}}123595)
  Antoine Poinsot potvrzuje, že [RBF][topic rbf] pravidlo č. 4 (nahrazující transakce
  platí dodatečné poplatky nad rámec absolutních poplatků původní transakce)
  je silnější než pravidlo č. 3 (nahrazující transakce platí absolutní poplatky
  přinejmenším tak vysoké jako součet poplatků původních transakcí) a poznamenává,
  že důvodem existence těchto dvou podobných pravidel v dokumentaci jsou dvě
  nezávislé kontroly v kódu.

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [BDK 1.0.0-beta.1][] je kandidátem na vydání „první beta verze `bdk_wallet`
  se stabilním 1.0.0 API.“

## Významné změny kódu a dokumentace

_Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Bitcoin Inquisition][bitcoin inquisition repo] a [repozitáři BINANA][binana
repo]._

- [Bitcoin Core #30320][] upravuje [assumeUTXO][topic assumeutxo] tak,
  aby nenačítalo snapshot, pokud není potomkem aktuálně nejlepší hlavičky
  `m_best_header`, a namísto toho synchronizovalo jako běžný uzel. Když se
  snapshot později díky reorganizaci stane potomkem nejlepší hlavičky,
  načítání assumeUTXO snapshotu bude pokračovat.

- [Bitcoin Core #29523][] přidává do RPC příkazů financujících transakce
  `fundrawtransaction`, `walletcreatefundedpsbt` a `send` novou volbu
  `max_tx_weight`. Ta zajistí, že váha výsledné transakce nepřekročí stanovený
  limit, což může být výhodné pro budoucí pokusy o [RBF][topic rbf] nebo
  pro konkrétní protokoly. Pokud není volba nastavena, je jako výchozí
  hodnota použita `MAX_STANDARD_TX_WEIGHT` 400 000 váhových jednotek
  (100 000 vbyte).

- [Core Lightning #7461][] přidává uzlům možnost stáhnout a platit své [BOLT12
  nabídky][topic offers] a faktury, což může zjednodušit kód správy účtů,
  který na pozadí volá CLN (popsáno ve [zpravodaji č. 262][cln self-pay]).
  PR dále umožňuje uzlům platit faktury, i když je uzel sám prvním v
  [zaslepené cestě][topic rv routing]. Dále nově mohou neoznámené uzly
  (bez [neoznámených kanálů][topic unannounced channels]) vytvářet nabídky
  automatickým přidáním zaslepené cesty, jejíž předposlední skok je
  jednou z protistran vlastních kanálů.

- [Eclair #2881][] odstraňuje podporu pro nové příchozí `static_remote_key` kanály.
  Podpora pro stávající a nové odchozí zůstává zachována. Uzly by měly namísto
  nich používat [anchor výstupy][topic anchor outputs], nové `static_remote_key`
  kanály jsou považovány za překonané.

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="30320,29523,7461,2881" %}
[BDK 1.0.0-beta.1]: https://github.com/bitcoindevkit/bdk/releases/tag/v1.0.0-beta.1
[news263 full-rbf]: /cs/newsletters/2023/08/09/#full-rbf-ve-vychozim-stavu
[news288 rbfr]: /cs/newsletters/2024/02/07/#navrh-na-nahrazovani-jednotkovym-poplatkem-jako-reseni-pinningu
[news283 truc pin]: /cs/newsletters/2024/01/03/#naklady-na-pinning-v3-transakci
[news288 rbfr]: /cs/newsletters/2024/02/07/#navrh-na-nahrazovani-jednotkovym-poplatkem-jako-reseni-pinningu
[news290 rbf]: /cs/newsletters/2024/02/21/#ryzi-nahrazeni-jednotkovym-poplatkem-nezarucuje-soulad-ekonomickych-podnetu
[news285 cluster cpfp-co]: /cs/newsletters/2024/01/17/#cpfp-carve-out-musi-byt-odstraneno
[news286 imbued]: /cs/newsletters/2024/01/24/#vstipena-v3-logika
[news287 sibling]: /cs/newsletters/2024/01/31/#pribuzenske-nahrazovani-poplatkem
[news289 imbued]: /cs/newsletters/2024/02/14/#co-by-se-byvalo-stalo-kdyby-byla-v3-semantika-aplikovana-na-anchor-vystupy-pred-rokem
[todd fr-rbf]: https://mailing-list.bitcoindevs.xyz/bitcoindev/Zpk7EYgmlgPP3Y9D@petertodd.org/
[harding rbfr fundamental]: https://mailing-list.bitcoindevs.xyz/bitcoindev/d57a02a84e756dbda03161c9034b9231@dtrt.org/
[todd unsolvable]: https://mailing-list.bitcoindevs.xyz/bitcoindev/Zp1utYduhnWf4oA4@petertodd.org/
[teinurier hacky]: https://github.com/bitcoin/bitcoin/issues/29319#issuecomment-1968709925
[daftuar prefer not]: https://github.com/bitcoin/bitcoin/issues/29319#issuecomment-1968709925
[cln self-pay]: /cs/newsletters/2023/08/02/#core-lightning-6399
[BIP379]: https://github.com/bitcoin/bips/blob/master/bip-0379.md
