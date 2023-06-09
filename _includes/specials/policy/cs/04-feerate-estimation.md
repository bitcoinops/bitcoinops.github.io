Minulý týden jsme prozkoumali techniky minimalizace poplatků placených
za transakci při daném jednotkovém poplatku. Avšak jaký by tento
jednotkový poplatek měl být? Nejlépe co nejnižší, abychom ušetřili
peníze, ale dostatečně vysoký, aby nám zajistil místo v bloku
podle uživatelovy časové preference.

Cílem _odhadu (jednotkového) poplatku_ je převést cílený časový
rámec pro konfirmaci na nejnižší jednotkový poplatek, který by
transakce měla zaplatit.

Jednou z komplikací odhadu poplatku je nepravidelnost produkce
blokového prostoru. Řekněme, že aby obdržel zboží, potřebuje uživatel
obchodníkovi zaplatit během jedné hodiny. Uživatel očekává, že každých
deset minut bude vytěžený jeden blok, a tak bude cílit pozici uvnitř
příštích šesti bloků. Avšak je možné, že jeden z bloků bude nalezen
až za 45 minut. Odhady poplatků musí vzít do úvahy uživatelovu
naléhavost nebo časový rámec (ve smyslu „chci, aby byla tato transakce
potvrzena do konce pracovního dne”) a nabídku blokového prostoru (počet
bloků). Aby se s těmito obtížemi algoritmy odhadování poplatků vypořádaly,
vyjadřují cíle konfirmací v čase i počtu bloků.

Naivní odhad poplatku lze postavit na historických údajích o výši
poplatků, které postačují na začlenění do bloků. Jelikož takový odhad
nezahrnuje transakce čekající v mempoolech na potvrzení, dosahoval
by velmi nepřesných výsledků v dobách s neočekávaně vysokou fluktuací
poptávky po blokovém prostoru a občasných dlouhých intervalech mezi
bloky. Další slabostí je závislost na informacích zcela ovládaných
těžaři, kteří by mohli dosáhnout zvyšování poplatků začleňováním
falešných transakcí s vysokými jednotkovými poplatky do svých bloků.

Naštěstí trh blokového prostoru není aukcí naslepo. V našem [prvním
příspěvku][policy01] jsme zmínili, že vedení mempoolu a účast v P2P síti
přeposílání transakcí umožňuje uzlu vidět nabídky ostatních uživatelů.
Odhad poplatků v Bitcoin Core používá k výpočtu pravděpodobnosti začlenění
transakce s poplatkem `f` v příštích `n` blocích i historická data, avšak
zaměřuje se hlavně na výšky, ve kterých uzel transakci poprvé zaznamená
a kdy se potvrdí. Tato metoda ignoruje aktivitu, která se děje mimo
veřejný trh. Pokud těžaři začleňují do svých bloků transakce s uměle
nafouknutými poplatky, tento odhad poplatků by tím ovlivněn nebyl, neboť
používá jen data transakcí, které byly před potvrzením veřejně šířeny.

Dále máme dobrý přehled o způsobu vybírání transakcí do bloků. V
[předchozím příspěvku][policy02] jsme zmínili, že uzly emulují
pravidla těžařů, aby ve svých mempoolech držely výhodné transakce.
Díky tomu můžeme postavit algoritmus odhadu poplatků, který simuluje chování
těžařů. Abychom nalezli jednotkový poplatek, za který by byla transakce
potvrzena během příštích `n` bloků, mohli bychom díky použití algoritmu
sestavování bloků a vlastního mempoolu navrhnout příštích `n` bloků a
spočítat, jaký poplatek by porazil poslední transakce, které by se
dostaly do bloku `n`.

Je zřejmé, že účinnost tohoto odhadu poplatků závisí na podobnosti obsahu
našeho mempoolu a mempoolu těžařů, což nikdy nelze zaručit. Dále nemůže
zohlednit transakce, které těžař může začlenit na základě externích podnětů,
např. vlastní těžařovy transakce či transakce, jejíž poplatky
za potvrzení byly zaplaceny jiným způsobem. Algoritmus také musí zohlednit
dodatečné transakce, které se objeví. Může tak učinit snížením velikosti
navržených bloků, ale o kolik?

Tato otázka opět vyzdvihuje užitečnost historický dat. Chytrý model může
zahrnout vzory aktivity a zohlednit vnější události ovlivňující poplatky
jako jsou pracovní doba, plánované konsolidace UTXO či reakce na změny
ceny bitcoinu. Problematika předpovídání poptávky po blokovém prostoru
je a nadále zůstane předmětem studií a zkoumání.

Odhadování poplatků je mnohostranný a složitý problém. Špatný odhad
může přivést plýtvání prostředky, zhoršit použitelnost bitcoinu pro placení
a způsobit ztrátu peněz uživatelům vrstev nad bitcoinem, kteří kvůli
nevhodnému poplatku zmeškají okno časového zámku UTXO. Dobrý odhad poplatků
umožňuje uživatelům jasně a přesně sdělovat těžařům naléhavost transakce
a díky [CPFP][topic cpfp] a [RBF][topic rbf] mohou aktualizovat své nabídky
v případě podhodnocených původních odhadů. Díky pravidlům a politikám mempoolu
zohledňujícím výhodnost transakcí, dobře navrženým nástrojům pro odhadování
poplatků a [peněženkám][policy03] se mohou uživatelé účastnit efektivní veřejné
aukce blokového prostoru.

Odhady poplatků obvykle nenabízí hodnoty pod 1 sat/vB, bez ohledu na
délku časového horizontu či množství transakcí čekající na potvrzení.
Mnozí považují 1 sat/vB za nejnižší jednotkový poplatek v bitcoinové síti,
neboť většina uzlů (včetně těžařů) [nikdy neakceptuje][topic default minimum
transaction relay feerates] nic pod touto hodnotou. Příští týden prozkoumáme
pravidla uzlu a další důvody pro zohledňování jednotkových poplatků
přeposílaných transakcí: ochrana před vyčerpáním zdrojů.

[policy01]: /cs/newsletters/2023/05/17/#čekání-na-potvrzení-1-k-čemu-je-mempool
[policy02]: /cs/newsletters/2023/05/24/#čekání-na-potvrzení-2-incentivy
[policy03]: /cs/newsletters/2023/05/31/#čekání-na-potvrzení-3-aukce-blokového-prostoru
