[Minulý příspěvek][policy08] popsal [anchor výstupy][topic anchor outputs] a [CPFP carve
out][topic cpfp carve out] zajišťující, že kterákoliv strana kanálu může
navýšit poplatek sdílené commitment transakce bez nutnosti spolupráce.
Tento přístup stále obsahuje několik nevýhod: prostředky kanálu jsou svázané,
aby mohly vytvořit anchor výstupy, jednotkový poplatek commitment transakce je
většinou o trochu vyšší, aby byl vyšší než minimální poplatek mempoolu, a
CPFP carve out povoluje pouze jednoho potomka navíc. Anchor výstupy nemohou
zajistit podobnou dostupnost navýšení poplatků transakcí sdílených mezi více
než dvěma stranami, jako je [coinjoin][topic coinjoin] nebo protokoly s více
účastníky. Tento příspěvek zkoumá současné snahy adresovat tato i jiná omezení.

[Přeposílání balíčků][topic package relay] obsahuje P2P protokol a změny pravidel,
které umožní transport a validaci skupin transakcí. Díky tomu by mohly být
poplatky commitment transakcí navýšeny potomkem, i kdyby nesplňovaly požadavek
minimálního jednotkového poplatku mempoolu. Dále by _RBF balíčku_ umožnilo
potomkovi navyšujícímu poplatek zaplatit za [nahrazení][topic rbf] transakcí,
se kterými jsou jeho rodiče v konfliktu. Přeposílání balíčků je navrženo tak,
aby odstranilo obecná omezení na základní vrstvě protokolu. Avšak díky jeho
použití pro navyšování poplatků sdílených transakcí byly na jeho základě
představeny pokusy o eliminaci [pinningu][topic transaction pinning]
v některých konkrétních případech. Například by RBF balíčku umožnil commitment
transakcím nahrazení sebe navzájem, pokud by byly zveřejněny spolu se svými
potomky navyšujícími poplatek. Díky tomu by nebylo potřeba mít v každé
commitment transakci několik anchor výstupů.

Drobným zádrhelem je, že existující pravidla pro RBF vyžadují, aby nahrazující
transakce platila vyšší absolutní poplatek než součet poplatků placených všemi
nahrazovanými transakcemi. Toto pravidlo napomáhá prevenci odepření služby
opakovanými nahrazeními, ale umožňuje záškodníkům zvýšit náklady na nahrazení
transakce připojením potomka, který má vysoký poplatek, ale nízký jednotkový
poplatek, což zamezuje transakci ve vytěžení. Tomuto druhu pinningu se často
říká „pinning třetího pravidla.”

Vývojáři též navrhli zcela odlišné způsoby přidávání poplatků předem podepsaným
transakcím. Například podepsání vstupů transakce s `SIGHASH_ANYONECANPAY | SIGHASH_ALL`
by umožnilo odesílateli transakce poskytnout poplatek připojením dodatečných vstupů,
avšak se zachováním výstupů. Jelikož však nemá RBF žádná pravidla vyžadující, aby
měla nahrazující transakce vyšší „těžební skóre” (tj. byla by rychleji vybrána
do bloku), mohl by útočník „přišpendlit” tento druh transakcí vytvořením
nahrazení zatíženého předky s nízkými jednotkovými poplatky. Existující limity
předků a potomků nejsou dostatečné, aby omezily výpočetní náročnost této
kalkulace, což ztěžuje přesný odhad těžebního skóre transakcí a balíčků
transakcí. Jakékoliv připojené transakce mohou ovlivnit pořadí, ve kterém jsou
transakce vybírány do bloku. Komponenta, která je plně propojena (nazývající se
_cluster_), může mít jakoukoliv velikost danou současnými limity předků a potomků.

Dlouhodobým řešením adresování některých nedostatků mempoolu a RBF pinning
útoků je v mempoolu [předělat strukturu dat, aby se sledovaly clustery][mempool
clustering] namísto pouhých množin předků a potomků. Tyto clustery by byly
omezeny ve velikosti. Limity clusterů by omezily způsob, kterým by mohli uživatelé
utrácet nepotvrzená UTXO, ale díky nim by mohl být celý mempool linearizován
použitím těžebního algoritmu založeném na skóre předků, tvorba šablon bloků
by byla extrémně rychlá a mohl by být přidán požadavek, aby nahrazující
transakce měly vyšší těžební skóre než transakce, které chtějí nahradit.

I přesto je možné, že žádná jedna sada pravidel nemůže uspokojit širokou řadu
potřeb a očekávání přeposílání transakcí. Například zatímco pro příjemce dávkové
platby je výhodné, že mohou utratit své nepotvrzené výstupy, uvolněné limity
potomků vytváří prostor pro pinning RBF balíčků sdílené transakce skrz
absolutní poplatky. Návrh na [pravidla přeposílání v3 transakcí][topic v3 transaction
relay] byl vyvinut, aby umožnil protokolům s kontrakty volitelně používat
striktnější sadu limitů balíčků. V3 transakce by povolovaly pouze balíčky o velikosti
dva (jeden předek, jeden potomek) a omezovaly váhu potomka. Tyto limity by
zabraňovaly RBF pinningu skrz absolutní poplatky a nabídly by některé z výhod
mempoolu clusterů bez nutnosti restrukturovat mempool.

[Ephemeral anchors][topic ephemeral anchors] dále vylepšují anchor výstupy na základě
vlastností přeposílání v3 transakcí a balíčků. Anchor výstupy patřící v3 transakci
s nulovým poplatkem budou mít výjimku z [limitu neutratitelnosti][topic
uneconomical outputs] („dust limit”), pokud jsou utráceny potomkem navyšujícím
poplatek. Jelikož transakce s nulovým poplatkem musí mít poplatek navýšený
právě jedním potomkem (jinak by neměl těžař motivaci ji začlenit do bloku),
je tento anchor výstup dočasný („ephemeral”) a nestane se součástí množiny UTXO.
Tento návrh na ephemeral anchors implicitně zabraňuje neanchor výstupům, aby
byly utraceny, dokud jsou nepotvrzené a nemají `1 OP_CSV` časové zámky, neboť
potomek musí tento anchor výstup utratit. Díky tomu by také byl proveditelný
[LN symmetry][topic eltoo] (eltoo), který by mohl využít [CPFP][topic cpfp]
jako mechanismu poskytování poplatků transakcím uzavírajícím kanál. Dále by
mohl být tento mechanismus použit u transakcí sdílených mezi více než dvěma
účastníky. Vývojáři používají k nasazení ephemeral anchors a navrhovaných soft
forků [bitcoin-inquisition][bitcoin inquisition repo], v jehož rámci budují
a testují tyto změny na [signetu][topic signet].

Problém pinningu, popsaný mimo jiné v tomto příspěvku, stál loni za [množstvím
diskuzí a návrhů vylepšení pravidel RBF][2022 rbf] v emailových skupinách,
pull requestech, sociálních médiích a při osobních setkáních. Vývojáři navrhli
a implementovali řešení v různých škálách, od malých úprav až po kompletní
předělání. Volba `-mempoolfullrbf`, jejímž účelem je potýkat se s problémem
pinningu a nesouladem v BIP125 implementacích, nám připomenula náročnost
a důležitost spolupráce v rámci pravidel přeposílání transakcí. A i když byly
upřímné snahy o zapojení komunity použitím obvyklých prostředků včetně konverzace
v emailové skupině Bitcoin-Dev rok dopředu, bylo zřejmé, že existující způsoby
komunikace a rozhodování nevyústily v zamýšlený výsledek a potřebovaly
doladit.

Decentralizované rozhodování je náročným, ale nezbytným procesem v podpoře
různorodého ekosystému protokolů a aplikací, které používají bitcoinovou síť.
Příští týden bude náš poslední příspěvek v této sérii, ve kterém, doufáme,
se nám podaří zapojit čtenáře a zlepšit tento proces.

[mempool clustering]: https://github.com/bitcoin/bitcoin/issues/27677
[policy08]: /cs/newsletters/2023/07/05/#čekání-na-potvrzení-8-pravidla-jako-rozhraní
[2022 rbf]: /en/newsletters/2022/12/21/#rbf
