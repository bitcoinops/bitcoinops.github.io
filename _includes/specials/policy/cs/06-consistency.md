Minulý týden jsme si představili soubor pravidel pro validaci transakcí
používaných nad rámec pravidel konsenzu. Tato pravidla nejsou aplikována
na transakce v blocích, uzel tedy může zůstat v konsenzu s ostatními,
i když se jeho pravidla liší. Stejně jako se může provozovatel uzlu rozhodnout
nepodílet se na přeposílání transakcí, může si též svobodně zvolit svá
pravidla či žádná pravidla vůbec nevynucovat (a tím se vystavit riziku
DoS). Z toho vyplývá, že nemůžeme předpokládat jednotnost mempoolů v
síti. Avšak aby mohla být naše transakce přijata těžařem, musí nejdříve
projít cestou uzlů, které ji přijmou do svých mempoolů; jakákoliv
odchylka pravidel mezi těmito uzly má přímý dopad na přeposílání
transakcí.

Hraničním příkladem odlišnosti pravidel mezi uzly budiž situace, ve
které si každý provozovatel uzlu zvolí náhodné číslo, které bude jako
jediné přijímat v `nVersion`. Jelikož by většina peer-to-peer relací
měla nekompatibilní pravidla, transakce by se k těžařům nedostávaly.

Na druhou stranu shodná pravidla napříč sítí napomáhají sjednocování
obsahu mempoolů. Síť se shodnými mempooly nejlépe přeposílá transakce
a je též ideální pro [odhad poplatků][policy04] a [přeposílání kompaktních
bloků][policy01], jak bylo zmíněno v předchozích příspěvcích.

Vzhledem ke složitosti validace mempoolu a obtížím spojených s
rozdílností pravidel je Bitcoin Core [konzervativní][aj mempool consistency]
v možnostech konfigurování pravidel. I když mohou uživatelé snadno
nastavit způsob počítání sigops (`bytespersigop`) či omezit množství
dat v `OP_RETURN` výstupech (`datacarriersize` a `datacarrier`),
nemohou se bez změny kódu vyvázat z maximální standardní váhy 400 000
váhových jednotek či používat odlišný soubor pravidel pro RBF.

Některá z nastavení pravidel v Bitcoin Core existují pro přizpůsobení
se odlišným provozním prostředím či důvodům provozování uzlu. Například
těžařovy hardwarové zdroje a důvody pro držení mempoolu jsou odlišné
od běžného uživatele provozujícího lehký uzel na laptopu nebo Raspberry Pi.
Těžař může chtít navýšit kapacitu mempoolu (`maxmempool`) nebo čas
expirace (`mempoolexpiry`), aby mohl během špičky ukládat transakce
s nízkým jednotkovým poplatkem, které by mohl těžit v čase nižšího
provozu. Webové stránky nabízející vizualizace, archívy či statistiky
mohou provozovat několik uzlů, aby sbíraly co nejvíce dat a zobrazovaly
výchozí chování mempoolu.

Co se týče jednotlivých uzlů, nastavení kapacity mempoolu ovlivňuje
dostupnost nástrojů k navýšení poplatků. Roste-li minimální jednotkový
poplatek mempoolu kvůli vysokému počtu příchozích transakcí, nemohou
být poplatky navyšovány pomocí [CPFP][topic cpfp] transakcím vyloučeným
z mempoolu či transakcím novým majícím jednotkový poplatek pod tímto minimem.

Na druhou stranu, jelikož vstupy odstraněných transakcí už nejsou utráceny
žádnou transakcí v mempoolu, může být nově možné navýšit poplatek pomocí
[RBF][topic rbf]. Nová transakce ve skutečnosti v mempoolu nic nenahrazuje,
nemusí tedy uvažovat běžná pravidla RBF. Avšak uzly, které původní
transakci z mempoolu neodstranily (kvůli vyšší kapacitě), považují tuto
novou transakci za možnou nahrazující transakci a vynucují pravidla RBF.
Pokud odstraněná transakce nesignalizovala možnost nahrazení (BIP125) či
poplatek nové transakce nesplňuje kritéria RBF navzdory vysokému jednotkovému
poplatku, nemusí těžař tuto novou transakci akceptovat. Peněženky musí
s odstraněnými transakcemi nakládat opatrně, neboť výstupy transakce
nemohou být pokládány za utratitelné a rovněž vstupy jsou podobně
nedostupné k dalšímu použití.

Na první pohled se může zdát, že díky větší kapacitě mempoolu je pro uzel
CPFP užitečnější a RBF méně užitečné. Avšak přeposílání transakcí je
předmětem aktuálního chování sítě a cesta od uživatele k těžařovi,
ve které všechny uzly toto CPFP akceptují, nemusí existovat. Uzly běžně
přeposílají transakce až po akceptování do vlastního mempoolu a ignorují
oznámení o transakcích, která již ve svém mempoolu mají. Uzly, které ukládají
více transakcí, se chovají jako [černé díry][se maxmempool], když se k
nim tyto transakce dostanou. Dokud celá síť nenavýší kapacitu svých
mempoolů, což by bylo signálem pro změnu výchozí hodnoty, přinese navýšení
kapacity jednotlivým uživatelům jen málo výhod. Minimální jednotkový
poplatek mempoolu omezuje ve výchozím stavu užitečnost používání CPFP během
špiček. Uživatel, jehož CPFP transakci vlastní uzel přijme díky navýšené
kapacitě, si nemusí všimnout, že tuto transakci nikdo jiný nepřijal.

Síť přeposílání transakcí sestává z jednotlivých uzlů, které se k síti
dynamicky připojují a odpojují. Každý z nich musí sám sebe chránit
před zneužitím. Proto nemůžeme zaručit, že se každý uzel dozví o
každé nepotvrzené transakci. Zároveň bitcoinové síti prospívá,
konvergují-li uzly ke shodné množině pravidel přeposílání transakcí,
díky které mají mempooly stejnorodý obsah. Příští článek osvětlí,
jaká pravidla byla přijata pro co nejlepší fungování celé sítě.

[policy01]: /cs/newsletters/2023/05/17/#%C4%8Dek%C3%A1n%C3%AD-na-potvrzen%C3%AD-1-k-%C4%8Demu-je-mempool
[policy04]: /cs/newsletters/2023/06/07/#%C4%8Dek%C3%A1n%C3%AD-na-potvrzen%C3%AD-4-odhad-poplatk%C5%AF
[aj mempool consistency]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-October/021116.html
[se maxmempool]: https://bitcoin.stackexchange.com/questions/118137/how-does-it-contribute-to-the-bitcoin-network-when-i-run-a-node-with-a-bigger-th

