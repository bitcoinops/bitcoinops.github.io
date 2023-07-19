Doufáme, že tato série poskytla čtenářům lepší porozumění, co se děje
během čekání na potvrzení. Začali jsme zkoumáním, jak se ideologické
hodnoty bitcoinu [projevují][policy01] v jeho struktuře a designu.
Distribuovaná struktura peer-to-peer sítě nabízí oproti běžnému
centralizovanému modelu zvýšené soukromí a odolnost vůči cenzuře.
Otevřená síť propagace transakcí umožňuje každému dozvědět se o
transakcích ještě před jejich potvrzením, což zlepšuje [efektivitu
propagace bloků][policy01], usnadňuje počátky novým těžařům a přináší
[veřejnou aukci blokového prostoru][policy02]. Jelikož ideální síť sestává
z mnoha nezávislých anonymních entit provozujících uzly, musí být
software uzlů navržen tak, aby [ochraňoval před DoS][policy05] a
minimalizoval provozní náklady.

Poplatky hrají v bitcoinu důležitou úlohu jako „spravedlivý” způsob
řešení soutěže o blokový prostor. Mempooly s nahrazováním transakcí
a algoritmy výběru a vyloučení využívají k měření užitku transakcí
[ekonomické incentivy][policy02] a dávají uživatelům k dispozici nástroje
k navyšování poplatků: [RBF][topic rbf] a [CPFP][topic cpfp]. Kombinace
pravidel mempoolu, peněženek se schopností [ekonomické konstrukce
transakcí][policy03] a dobrý [odhad poplatků][policy04] vytváří efektivní
trh blokového prostoru, který přináší užitek všem.

Jednotlivé uzly dále vynucují _pravidla přeposílání transakcí_, aby
[chránily samy sebe před vyčerpáním zdrojů][policy05] a [vyjadřovaly
své osobní preference][policy06]. Na [úrovni celé sítě][policy07]
jsou aplikována pravidla standardnosti pro ochranu zdrojů nutných pro
škálování, dostupnost uzlů a schopnost měnit pravidla konsenzu. Jelikož
drtivá většina sítě tato pravidla vynucuje, jsou důležitou součástí
[rozhraní][policy08], nad nímž jsou bitcoinové aplikace a protokoly
druhé vrstvy vystavěny. Avšak nejsou dokonalá. Popsali jsme několik
[návrhů kolem pravidel][policy09], které adresují obecná omezení i
konkrétní případy jako jsou například [pinning útoky transakcí na
druhé vrstvě][policy08].

Též jsme zdůraznili, že probíhající evoluce pravidel sítě vyžaduje
spolupráci mezi vývojáři pracujícími na protokolech, aplikacích i
peněženkách. S růstem bitcoinového ekosystému, tedy s množstvím software,
případů užití a uživatelů, roste důležitost i náročnost procesu
decentralizovaného rozhodování. Tento systém vyvstává ze zájmů a cílů
účastníků bitcoinové sítě. Není v jejím středu žádná firma sbírající
názory zákazníků a najímající inženýry k přidávání nových funkcí.
Kdo si přeje být součástí širšího konsenzu sítě, může si vybrat
svou cestu: může se učit, ptát se, hlásit problémy, účastnit
se návrhu sítě nebo přímo přispívat ve vývoji novinek.

Až budete příště příliš dlouho čekat na potvrzení své transakce,
budete vědět, co dělat.

[policy01]: /cs/newsletters/2023/05/17/#čekání-na-potvrzení-1-k-čemu-je-mempool
[policy02]: /cs/newsletters/2023/05/24/#čekání-na-potvrzení-2-incentivy
[policy03]: /cs/newsletters/2023/05/31/#čekání-na-potvrzení-3-aukce-blokového-prostoru
[policy04]: /cs/newsletters/2023/06/07/#čekání-na-potvrzení-4-odhad-poplatků
[policy05]: /cs/newsletters/2023/06/14/#čekání-na-potvrzení-5-pravidla-pro-ochranu-zdrojů-uzlů
[policy06]: /cs/newsletters/2023/06/21/#čekání-na-potvrzení-6-konzistence-pravidel
[policy07]: /cs/newsletters/2023/06/28/#čekání-na-potvrzení-7-síťové-zdroje
[policy08]: /cs/newsletters/2023/07/05/#čekání-na-potvrzení-8-pravidla-jako-rozhraní
[policy09]: /cs/newsletters/2023/07/12/#čekání-na-potvrzení-9-návrhy-pravidel
