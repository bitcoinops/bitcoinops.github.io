---
title: 'Zpravodaj „Bitcoin Optech” č. 201'
permalink: /cs/newsletters/2022/05/25/
name: 2022-05-25-newsletter-cs
slug: 2022-05-25-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Tento týden shrnujeme pracovní verzi BIP pro přeposílání balíčků a
nabízíme přehled o obavách ohledně těžaři extrahovatelné hodnoty
v návrhu bitcoinových kovenantů. Též nechybí naše pravidelné rubriky s výběrem
nejlepších otázek a odpovědí z Bitcoin Stack Exchange, souhrnem vydání nových verzí
a významných změn v populárních bitcoinových infrastrukturních projektech.

## Novinky

- **Návrh na přeposílání balíčků:** Gloria Zhao zaslala do emailové skupiny
  Bitcoin-Dev [příspěvek][zhao package] s pracovní verzí BIP pro
  [přeposílání balíčků][topic package relay] („package relay”). Jedná se o
  funkci, díky které bude [navyšování poplatků pomocí CPFP][topic cpfp] spolehlivější.
  Rodičovská transakce tak bude mít díky přispění svého potomka větší šanci na potvrzení.
  Spolehlivé navyšování poplatků pomocí CPFP je již vyžadováno několika protokoly včetně
  LN, přeposílání balíčků by tedy zvýšilo jejich bezpečnost a použitelnost. BIP
  navrhuje přidání čtyř nových zpráv do P2P protokolu:

  - `sendpackages` umožňuje dvěma uzlům navzájem zjistit, které funkce podporují.

  - `getpckgtxns` je požadavek na zaslání transakcí, které byly oznámeny
    jako součást nějakého balíčku.

  - `pckgtxns` poskytuje transakce, které jsou součástí nějakého balíčku.

  - `pckginfo1` poskytuje detaily o balíčku transakcí: jejich počet,
    identifikátory (wtxid), celkovou velikost (váhu) a celkový poplatek.
    Jednotkový poplatek („feerate”) pro celý balíček se spočítá vydělením
    celkového poplatku vahou.

  Dále jsou existující zprávy `inv` a `getdata` rozšířeny o nový typ
  objektu `MSG_PCKG1`, který uzlu umožňuje informovat svá spojení o schopnosti
  zaslat zprávu `pckginfo1` k transakci a který poté mohou uzly použít, chtějí-li
  obdržet zprávu `pckginfo1` ke konkrétní transakci.

  Uzel může  použít tyto zprávy a `inv(MSG_PCKG1)`, aby informoval spojení
  o možnosti nabídnout `pckginfo1` k nějaké transakci, např. takové, která má
  vysoký feerate a je potomkem nepotvrzené transakce s příliš nízkým feerate.
  Taková transakce by byla jinak ignorována. Uzly mohou na základě obsahu zprávy
  `pckginfo1` určit, zda mají o balíček zájem, a zjistit wtxid transakcí,
  které budou muset obdržet, aby mohly potomka zvalidovat. Samotné transakce
  mohou být vyžádány zprávou `getpckgtxns` a obdrženy ve zprávě `pckgtxins`.

  I když se [pracovní verze BIP][bip-package-relay] soustředí pouze na protokol,
  Gloria ve svém emailu poskytuje širší kontext, stručně popisuje alternativy,
  které byly shledány nedostatečnými, a odkazuje na [prezentaci][zhao preso]
  s dalšími informacemi.

- **Debata o těžaři extrahovatelné hodnotě:** Vývojář /dev/fd0 [poslal][fd0 ctv9]
  do emailové skupiny Bitcoin-Dev souhrn [devátého IRC meetingu][ctv9] o [OP_CHECKTEMPLATEVERIFY][topic
  op_checktemplateverify] (CTV). Mimo jiná témata diskutovaná během sezení
  uvedl Jeremy Rubin i několik obav, které lidé vyjadřují v souvislosti s
  rekurzivními [kovenanty][topic covenants][^covenants] (které CTV neumožňuje). Jedním
  z těchto znepokojení bylo vytváření těžaři extrahovatelné hodnoty („Miner
  Extractable Value”, MEV), která by výrazně převyšovala částky dostupné
  provozováním jednoduchého algoritmu výběru transakcí tak, jak jej nabízí
  Bitcoin Core.

  MEV se stal hrozbou především v Ethereu a souvisejících systémech,
  které používají veřejné protokoly obchodování viditelné v blockchainu.
  Ty umožňují těžařům dopouštět se front runningu. Představme si například
  následující dvě nepotvrzené transakce, které jsou dostupné k začlenění
  v následujícím bloku:

  * Alice prodává Bobovi za 1 ETH aktivum *x*
  * Bob prodává *x* Carol za 2 ETH (Bob vydělává 1 ETH)

  <br>Jsou-li tyto dvě výměny provedeny veřejným obchodovacím protokolem,
  může těžař Boba z transakce zcela odříznout:

  * Alice prodává těžařovi Mallorymu za 1 ETH aktivum *x*
  * Těžař Mallory prodává *x* Carol za 2 ETH (Mallory vydělává 1 ETH; Bob nevydělává nic)

  <br>Toto představuje samozřejmě problém pro Boba, vytváří to však také několik
  problémů pro celou síť. Prvním problémem je, že těžaři musí příležitosti
  k MEV aktivně vyhledávat. To je triviální v našem jednoduchém příkladu,
  ale složitější příležitosti mohou být nalezeny pouze použitím početně
  náročných algoritmů. Výše hodnoty, která může být nalezena určitým množstvím
  výpočtu, je nezávislá na těžařově hashrate. Dva těžaři se tak mohou spojit
  a na polovinu snížit náklady potřebné k obdržení MEV; to povede ke vzniku
  ekonomiky směřující k centralizaci a síti náchylné na cenzuru transakcí.

  [Zpráva][bitmex flashbots] od BitMex Research tvrdí, že jedna centralizovaná
  služba, která zprostředkovává obchod s tímto typem MEV transakcí, byla v době
  psaní zprávy používána 90 % hashrate v Ethereu. Aby dosáhla maximální
  návratnosti, mohla by tato služba být pozměněna tak, aby odrazovala
  od těžení konkurujících transakcí. Pokud by byla používána všemi těžaři,
  mohla by mít v důsledku moc cenzurovat transakce. Pokud by měla možnost
  zasáhnout do reorganizace blockchainu, stačila by polovina těžařů.

  Druhým problémem je, že i kdyby se Mallorymu podařilo vyprodukovat blok
  s extrahovaným 1 ETH, kterýkoliv jiný těžař může vytvořit alternativní
  blok a ukořistit MEV pro sebe. Tento tlak na přetěžování („re-mining”) bloků
  vede k [fee snipingu][topic fee sniping][^feesniping], který by v nejhorším případě
  znemožnil určení konečnosti transakce, a tedy schopnost použití proof of
  work k zabezpečení sítě.

  Tento typ protokolů umožňující MEV je díky použití UTXO v Bitcoinu hůře
  implementovatelný než v případě ethereovských účtů. Nicméně v CTV meetingu
  Jeremy Rubin poznamenal, že rekurzivní kovenanty by usnadnily implementaci
  systémů založených na účtech i nad bitcoinovými UTXO. Pravděpodobnost, že
  by MEV představovalo budoucí hrozbu v Bitcoinu, by tak byla zvýšena.

  V odpovědi na souhrn od /dev/fd0 navrhl vývojář ZmnSCPxj, abychom přijímali
  pouze takové mechanismy, které by vedly k protokolům navrženým pro maximální
  míru soukromí v blockchainu. Těžaři by tak neměli přístup k informacím
  potřebným k provedení MEV. V době psaní tohoto zpravodaje nebyly do emailové
  skupiny poslány další odpovědi, ale z reakcí na Twitteru i jinde lze vidět,
  že vývojáři stále více zvažují dopad MEV na design bitcoinových protokolů.

## Vybrané otázky a odpovědi z Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] je jedním z prvních míst, kde hledají
přispěvatelé Optechu odpovědi na své otázky a kde – najdou-li volnou chvíli –
pomáhají zvědavým či zmateným uživatelům. V této měsíční rubrice nabízíme
některé z otázek a odpovědí, které obdržely vysoký počet hlasů.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Kolik entropie se ztratí seřazením slov seedu?]({{bse}}113432)
  HansBKK se ptá, kolik entropie se ztratí, pokud by se 12 nebo 24 slov seedu
  seřadilo abecedně. Pieter Wuille rozebírá množství metrik, včetně počtu
  možností, entropie a průměrného počtu uhádnutí, potřebných k úspěšnému použití
  hrubé síly při 12 a 24 slovech. Také upozorňuje na potřebu vzít do úvahy
  i opakování slov.

- [Podepisování s taprootem a PSBT: jak určit způsob podepsání?]({{bse}}113489)
  Guggero vypisuje tři způsoby poskytnutí validního [Schnorrova podpisu][topic
  schnorr signatures] v taprootu: platba klíčem („keypath spend”) s [BIP86][]
  commitmentem, platba klíčem s commitmentem oproti kořenu stromu skriptu a platba
  skriptem („scriptpath spend”). Andrew Chow potvrzuje Guggerův souhrn, jak
  je která metoda označena uvnitř [PSBT][topic psbt].

- [Jak by rychlejší bloky způsobily centralizaci těžby?]({{bse}}113505)
  Murch popisuje, proč by rychlejší emise bloků způsobovala častější reorganizace
  blockchainu, které by byly díky latenci propagace bloků prospěšné velkým těžařům.

- [Co ve výběru mincí znamená „skóre plýtvání”?]({{bse}}113622)
  Murch vysvětluje, že Bitcoin Core během platby používá heuristiku [skóre plýtvání][news165 waste]
  („waste metric”) jako míru poplatků za množinu vstupů při současném feerate v porovnání
  s tou stejnou množinou při hypotetickém budoucím feerate. Tato heuristika
  hodnotí kandidáty [výběru mincí][topic coin selection] vzešlé z výsledku algoritmů
  Branch and Bound (BnB, metoda větví a mezí), Single Random Draw (SRD, náhodný výběr)
  a problému batohu.

- [Proč není `OP_CHECKMULTISIG` kompatibilní s dávkovým ověřováním Schnorrových podpisů?]({{bse}}113816)
  Pieter Wuille ukazuje, že jelikož [`OP_CHECKMULTISIG`][wiki op_checkmultisig]
  neoznačuje, které podpisy patří ke kterému veřejnému klíči, není kompatibilní
  s dávkovým ověřováním, což [vedlo][bip342 fn4] k nové instrukci `OP_CHECKSIGADD` v BIP342.

## Vydání nových verzí

*Vydání nových verzí populárních bitcoinových infrastrukturních projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [Core Lightning 0.11.1][] je vydání s opravou chyby, která způsobovala
  zbytečné zveřejnění transakce jednostranného uzavření kanálu, a jiné, nesouvisející
  chyby způsobující pády C-Lightning uzlu.

- [LND 0.15.0-beta.rc3][] je kandidátem na vydání příští verze tohoto oblíbeného LN uzlu.

## Významné změny v kódu a dokumentaci

*Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo] a [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #20799][] odstraňuje podporu verze 1
  [přeposílání kompaktních bloků][topic compact block relay] („compact block relay”),
  která umožňovala rychlejší a datově efektivnější přeposílání bloků a transakcí
  spojením, která nepodporovala segwit. Verze 2 zůstává aktivní a umožňuje
  rychlé a efektivní přeposílání spojením, která segwit podporují.

- [LND #6529][] přidává příkaz `constrainmacaroon`, který umožňuje omezit
  práva existujícího autentizačního tokenu (macaroon). Dříve bylo potřeba
  vytvořit nový macaroon.

- [LND #6524][] navyšuje číslo verze zálohovacího schématu aezeed z 0 na 1.
  V případě budoucí obnovy prostředků ze zálohy aezeedu to indikuje,
  že by měl software hledat [taprootové][topic taproot] výstupy.

## Zvláštní poděkování

Kromě pravidelných přispěvatelů do našeho zpravodaje chceme tento týden
obzvláště poděkovat Jeremy Rubinovi za poskytnutí podrobností o MEV.
V případě chyb či opomenutí spadá zodpovědnost zcela na nás.

## Poznámky a vysvětlivky

[^covenants]: [kovenanty][topic covenants] jsou druhem kontraktu, který povoluje poslat bitcoin pouze za předem daných podmínek, např. pouze na jednu z vyjmenovaných adres. Rekurzivní kovenanty umožňují platbu pouze na sebe sama.
[^feesniping]: [fee sniping][topic fee sniping] se objevuje, pokud těžař záměrně přetěžuje („re-mine”) jeden nebo více předešlých bloků, aby si osvojil poplatky od původního těžaře.

{% include references.md %}
{% include linkers/issues.md v=2 issues="20799,6529,6524" %}
[lnd 0.15.0-beta.rc3]: https://github.com/lightningnetwork/lnd/releases/tag/v0.15.0-beta.rc3
[Core Lightning 0.11.1]: https://github.com/ElementsProject/lightning/releases/tag/v0.11.1
[zhao package]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-May/020493.html
[bip-package-relay]: https://github.com/bitcoin/bips/pull/1324
[zhao preso]: https://docs.google.com/presentation/d/1B__KlZO1VzxJGx-0DYChlWawaEmGJ9EGApEzrHqZpQc/edit#slide=id.p
[fd0 ctv9]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-May/020501.html
[ctv9]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-May/020501.html
[bitmex flashbots]: https://blog.bitmex.com/flashbots/
[news165 waste]: /en/newsletters/2021/09/08/#bitcoin-core-22009
[wiki op_checkmultisig]: https://en.bitcoin.it/wiki/OP_CHECKMULTISIG
[bip342 fn4]: https://github.com/bitcoin/bips/blob/master/bip-0342.mediawiki#cite_note-4
