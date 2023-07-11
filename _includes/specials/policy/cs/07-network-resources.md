Předchozí článek popisoval ochrany zdrojů uzlu. Jelikož mohou být zdroje u každého
uzlu jedinečné, mohou být konfigurovatelné. Též jsme přednesli argumenty,
proč je lepší konvergovat k jednomu souboru pravidel. Co by však mělo být součástí
těchto pravidel? Tento článek vysvětlí koncept celosíťových zdrojů kritických
pro škálovatelnost, aktualizovatelnost a přístupnost nastartování a udržování
plného uzlu.

Jak bylo popsáno v [předchozích příspěvcích][policy01], distribuovaná struktura
bitcoinové sítě je zásadní pro dosažení jeho ideologických cílů. Peer-to-peer
podstata bitcoinu umožňuje, aby pravidla sítě vyvstávala z hrubého konsenzu
voleb jednotlivých provozovatelů uzlů, a omezuje pokusy o získání nepatřičného
vlivu v síti. Tato pravidla jsou vynucována jednotlivě každým uzlem ověřujícím
každou transakci. Různorodá a zdravá populace uzlů vyžaduje, aby byly náklady
na provozování uzlů nízké. Je náročné škálovat v globálním měřítku jakýkoliv projekt,
ale činit tak bez obětování decentralizace je jako bojovat s jednou rukou za zády.
Bitcoin se snaží o udržení rovnováhy nekompromisní ochranou svých sdílených síťových
zdrojů: množiny UTXO, datové stopy na blockchainu spolu s výpočetními nároky vyžadované
na jejich zpracování a systém evoluce protokolu.

Není nutné znovu připomínat celou válku o velikost bloků, abychom si uvědomili,
že omezení nárůstu blockchainu je nezbytné k zachování přístupnosti provozování
vlastního uzlu. Na úrovni pravidel také existuje prostředek pro omezování
růstu blockchainu v podobě `minRelayTxFee`, tedy minimálního poplatku nutného
pro přeposlání transakce ve výši 1 sat/vbyte. Toto pravidlo zajišťuje existenci
minimálních nákladů k omezení [„bezmezné poptávky po trvalém vysoce replikovaném
úložišti.”][unbounded]


Původně se pro sledování stavu sítě uchovávaly všechny transakce, které měly
neutracené výstupy. [Nově představená množina UTXO][ultraprune] jako prostředek
sledování prostředků přinesla významnou redukci dat. Od té doby se množina UTXO
stala ústřední datovou strukturou. Vyhledání UTXO tvoří hlavní podíl všech přístupů
do paměti, obzvláště během prvotního stahování bloků. Bitcoin Core již pro UTXO
mezipaměť používá [optimalizovanou datovou strukturu][pooled resource], avšak
velikost množiny UTXO určuje, jaká její část se do mezipaměti nevměstná. Větší
množina UTXO znamená více cache miss, což zpomaluje validaci bloků, prvotní
stahování a validaci transakcí. „Dust limit” je příkladem pravidla, které omezuje
tvorbu neutratitelných UTXO, jejichž hodnota je [nižší][topic uneconomical outputs]
než náklady na utracení. I přes to se [„prachové bouře” s tisíci transakcemi
objevily dokonce i v roce 2020][lopp storms].

Když se použití bare multisigu stalo populárním způsobem publikování dat na
blockchainu, upravila se definice standardní transakce, aby jako alternativu
povolovala jeden OP_RETURN výstup. Lidé si uvědomili, že by bylo nemožné
zabránit uživatelům v publikování dat na blockchainu, avšak alespoň by tato
data, uložena v neutratitelných výstupech, nemusela být navždy udržována v množině
UTXO. Bitcoin Core 0.13.0 přinesl volbu `-permitbaremultisig`, která umožňuje
uživatelům odmítnout nepotvrzené transakce obsahující výstupy s bare multisig.

I když pravidla konsenzu povolují ve výstupech jakékoliv skripty, Bitcoin Core
přeposílá pouze několik známých vzorů skriptů. Díky tomu je snazší porozumět
dopadům na síť, včetně nákladů na validaci a upgrade protokolu. Například transakce
se vstupním skriptem obsahujícím op-kódy, P2SH vstupem s více než 15 podpisy nebo
P2WSH vstupem, jehož witness by tvořil v zásobníku více než 100 položek, by všechny
byly označeny za nestandardní. ([Přehled pravidel][instagibbs policy zoo] obsahuje
příklady a jejich motivace.)

Bitcoinový protokol je žijícím softwarovým projektem, který se musí nadále vyvíjet,
aby odpovídal na budoucí potíže či potřeby uživatelů. Pro tento účel obsahuje
konsenzus několik nepoužívaných děr („upgrade hooks”), jako je příloha („annex”),
verze taprootových listů, verze witnessů, OP_SUCCESS a množství NOOP op-kódů.
Avšak podobně jako absence centrálních bodů selhání brání útokům, vyžadují i
celosíťové upgrady software koordinaci desítek tisíc nezávislých provozovatelů uzlů.
Uzly nepřeposílají transakce, které používají některé z rezervovaných děr, dokud nebude
jejich význam definován. Tento postup má odrazovat aplikace, aby nezávisle tvořily
konfliktní standardy, což by vedlo k nemožnosti začlenit do konsenzu standard
jedné aplikace bez zneplatnění standardu aplikace jiné. A pokud změna konsenzu
nastane, uzly, které okamžitě neupgradují a tedy neví o nových pravidlech konsenzu,
nemohou být přinuceny k akceptování zatím nevalidních transakcí do svých mempoolů.
Tento způsob odrazování vede k dopředné kompatibilitě uzlů a umožňuje síti
bezpečně upgradovat pravidla konsenzu bez nutnosti vyžadovat synchronizovanou
aktualizaci software.

Jak můžeme vidět, používání pravidel k ochraně sdílených síťových zdrojů napomáhá
k ochraně vlastností celé sítě a zároveň ponechává otevřené dveře k budoucímu vývoji
protokolu. Také vidíme, jak třenice mezi růstem sítě a striktním omezením
váhy bloků vedla k osvojení nejlepších postupů, dobrého technického designu a inovací.
Příští týden prozkoumáme pravidla mempoolu jako vstupní brány protokolů
druhé vrstvy a systémů chytrých kontraktů.

[policy01]: /cs/newsletters/2023/05/17/#%C4%8Dek%C3%A1n%C3%AD-na-potvrzen%C3%AD-1-k-%C4%8Demu-je-mempool
[unbounded]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2015-December/011865.html
[lopp storms]: https://blog.lopp.net/history-bitcoin-transaction-dust-spam-storms/
[ultraprune]: https://github.com/bitcoin/bitcoin/pull/1677
[pooled resource]: /cs/newsletters/2023/05/03/#bitcoin-core-25325
[instagibbs policy zoo]: https://gist.github.com/instagibbs/ee32be0126ec132213205b25b80fb3e8
