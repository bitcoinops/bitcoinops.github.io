[Minulý příspěvek][policy01] představil mempool jako mezipaměť nepotvrzených
transakcí, která uživatelům poskytuje decentralizovaný způsob posílání
transakcí těžařům. Avšak těžaři nejsou povinni tyto transakce potvrdit,
blok obsahující pouze coinbasovou transakci je podle pravidel konsenzu
zcela validní. Uživatelé mohou těžařům poskytnout podnět k začlenění
transakcí navýšením celkové hodnoty vstupů bez navýšení celkové hodnoty
výstupů. Tento rozdíl si mohou těžaři vzít jako _poplatek_ za transakci.

I když jsou v tradičním finančním světě transakční poplatky běžné,
noví bitcoinoví uživatelé jsou často překvapeni, že poplatky za umístění
v blockchainu nejsou úměrné hodnotě transakce, ale její váze. Namísto
likvidity je omezujícím faktorem blokový prostor. _Jednotkový poplatek_
se obvykle uvádí v jednotkách satoshi za virtuální byte.

Pravidla konsenzu v každém bloku omezují celkový prostor využitý transakcemi.
Díky tomuto omezení jsou časy propagace bloků nízké v porovnání s
intervalem produkce bloků a riziko zahození bloků je tak nižší.
Též napomáhá k omezení nárůstu blockchainu a množiny UTXO, tedy vlastností,
které přímo přispívají k nákladům na udržování plného uzlu.

Mempooly díky své roli mezipaměti nepotvrzených transakcí též zprostředkovávají
veřejnou dražbu neelastického blokového prostoru. Pracuje-li správně,
funguje tato dražba na principu volného trhu, tedy priorita je stanovena
čistě jen na poplatcích a ne na vztazích s těžaři.

Maximalizace poplatků při výběru transakcí do bloku (který je limitován
celkovou váhou a počtem operací podepisování) je [NP-těžký problém][NP-hard problem].
Tento problém dále ztěžují vztahy mezi transakcemi. Těžba
transakce s vysokým jednotkovým poplatkem může být podmíněna těžbou jeho
rodiče s nízkým poplatkem. Nebo, vzato z jiného úhlu, výběr
transakce s nízkým jednotkovým poplatkem může otevřít příležitost
k těžbě potomka s vysokým jednotkovým poplatkem.

Mempool v Bitcoin Core počítá jednotkový poplatek pro každou položku
a jeho předky (tzv. _jednotkový poplatek předků_, „ancestor feerate”), ukládá tento
výsledek do mezipaměti a sestrojuje šablony bloků pomocí hladového algoritmu.
Seřazuje mempool v pořadí dle _hodnocení předků_ („ancestor score”; jedná
se o minimum z jednotkového poplatku předků a vlastního jednotkového poplatku),
vybírá balíčky předků v tomto pořadí a za chodu upravuje informace o
poplatcích a váhách předků zbývajících transakcí. Tento algoritmus
nabízí rovnováhu mezi výkonností a ziskovostí, avšak nemusí poskytnout
optimální výsledky. Jeho účinnost může být zvýšena omezením velikosti
transakcí a balíčků předků; Bitcoin Core stanovuje tyto limity na
400 000, resp. 404 000 váhových jednotek.

Podobně se počítá i _hodnocení potomků_ („descendant score”), které
se používá při výběru balíčků, které mají být z mempoolu vyhozeny.
Bylo by nevýhodné vyhodit transakce s nízkým poplatkem, které mají
potomky s vysokým poplatkem.

Validace mempoolu též používá poplatky a jednotkové poplatky při
nakládání s transakcemi, které utrácejí shodné vstupy. Těmto případům
se též říká dvojí utrácení nebo konfliktní transakce. Uzly neakceptují
vždy jen první transakci, kterou spatří, ale aplikují soubor pravidel,
aby určily, které transakce je výhodnější ponechat. Toto chování
je známé jako [nahrazení poplatkem][topic rbf] („replace by fee”).

Je zřejmé, že těžaři chtějí maximalizovat poplatky, avšak proč by měly
netěžící uzly též implementovat tato pravidla? Jak bylo zmíněno v minulém
příspěvku, užitečnost mempoolů netěžících uzlů je přímo navázána
na jejich podobnost s mempooly těžařů. I když se provozovatelé uzlů
nechystají produkovat bloky z obsahu svých mempolů, držení nejvýhodnějších
transakcí je i v jejich zájmu.

I když neexistují žádná pravidla konsenzu vyžadující platbu poplatků,
hrají poplatky a jednotkové poplatky v bitcoinové síti důležitou roli
ve „spravedlivém” způsobu řešení soutěže o blokový prostor. Těžaři
využívají jednotkové poplatky k posuzování přijímání, vyhazování a
řešení konfliktů a netěžící uzly se drží tohoto chování, aby maximalizovaly
užitečnost svých mempoolů.

Vzácnost blokového prostoru tlačí velikost transakcí směrem dolů a
ponouká vývojáře k lepší efektivitě konstrukce transakcí. Příští týden
prozkoumáme praktické strategie a techniky minimalizace transakčních
poplatků.

[policy01]: /cs/newsletters/2023/05/17/#čekání-na-potvrzení-1-k-čemu-je-mempool
[np-hard problem]: https://en.wikipedia.org/wiki/NP-hardness
