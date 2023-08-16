{:.post-meta}
*napsal [Brandon Black][] z [BitGo][]*

První [vědecký článek][MuSig paper] o [MuSig][topic musig] byl publikován v roce 2018 a
jeho potenciál pro bitcoin byl jedním z lákadel soft forku taprootu. Práce na MuSig
pokračovala publikacemi [MuSig-DN][] a [MuSig2][] v roce 2020. Když se v roce 2021
blížila aktivace taprootu na mainnetu bitcoinu, vzrušení okolo příchodu MuSig podepisování
bylo zjevné. V BitGo jsme doufali ve vydání peněženky s podporou taprootu a MuSig zároveň
s aktivací taprootu, ale specifikace, testovací vektory a referenční implementace nebyly
kompletní. Namísto toho [vydal][bitgo blog taproot] BitGo první tapscriptovou multisig
peněženku a učinil [první tapscriptovou multisig transakci][first tapscript multisig transaction]
na mainnetu. Téměř o dva roky později je MuSig2 specifikován v [BIP327][] a my jsme
[vydali][bitgo blog musig2] první MuSig taprootovou multisig peněženku.

## Proč MuSig2?

### Porovnání s multisig skripty

V porovnání s multisig skripty nabízí MuSig dvě hlavní výhody. První a nejzjevnější
výhodou je snížení velikosti transakce a poplatku za vytěžení. Onchain stopa je
64–73 bytů (16–18,25 vB, virtuálních bytů). K tomu může navíc MuSig zkombinovat dva či více
podpisů do jednoho. V případě BitGo a jeho „2 ze 3” vícenásobného podpisu stojí MuSig
cesta pro utracení klíčem 57,5 vB; pro porovnání nativní SegWit vstup stojí
104,5 vB a [tapscript][topic tapscript] hloubky 1 stojí 107,5 vB. Druhou výhodou MuSig
je zlepšení soukromí. MuSig cestu pro utracení klíčem nelze při kooperativním utracení
rozeznat od běžného taprootového utracení s jedním podpisem.

MuSig2 však samozřejmě také má své nevýhody. Dvě důležité se týkají
[nonce](#nonce-deterministické-i-náhodné). Na rozdíl od prostého ECDSA (algoritmus digitálního
podpisu s eliptickými křivkami) nebo [Schnorrových podpisů][topic schnorr signatures] nelze v
MuSig2 používat deterministické nonce. Kvůli této vlastnosti je náročnější zajistit
kvalitní nonce a zaručit, že se nonce neopakují. MuSig2 vyžaduje ve většině případů
dvě kola komunikace. Během prvního se vyměňují nonce, ve druhém probíhá podepisování.
V některých případech lze v prvním kole použít předem vypočítaných hodnot, avšak obezřetnost
je nezbytná.

### Porovnání s ostatními MPC protokoly

Protokoly pro podepisování více stranami (multi-party compute, MPC) se díky zmíněným
výhodám stávají oblíbenější. MuSig je _jednoduchý_ protokol s vícenásobným „_n_ z _n_” podpisem,
který těží z linearity Schnorrových podpisů. MuSig2 lze vysvětlit během 30minutové
prezentace a jeho úplná referenční implementace v Pythonu zabírá 461 řádků. Protokoly
s [minimálním vyžadovaným počtem podpisů][topic threshold signature] („_t_ z _n_”), jako je
například [FROST][], jsou výrazně složitější a dokonce i [vícenásobné podpisy s dvěma
účastníky][2-party multi-signatures] založené na ECDSA vyžadují Paillierovo šifrování
a jiné techniky.

## Volba skriptů

I před [taprootem][topic taproot] byla volba konkrétního skriptu pro peněženky s
vícenásobným podpisem („_t_ z _n_”) obtížná. Taproot se svými několika různými
způsoby utrácení záležitost dále komplikuje. MuSig přidává další volby. Následují
některé úvahy, které stály za návrhem MuSig2 taprootové peněženky v BitGo:

- Klíče neřadíme lexikograficky, ale používáme pevné pořadí klíčů. Každý klíč pro
podepisování má v sobě stanovenou konkrétní roli, řazení klíčů je tak jednoduché
a předvídatelné.
- Naše MuSig cesta pro utracení klíčem obsahuje pouze nejběžnější podpisové kvórum,
„uživatel” / „bitgo”. Začlenění zálohového podpisového klíče by výrazně snížilo,
jak často by cesta mohla být použita.
- Nezačleňujeme do taptree podpisový pár „uživatel“ a „bitgo”. Jelikož toto je náš druhý
typ taprootového skriptu a první obsahuje tři tapscripty, uživatelé vyžadující podepisování
skriptů mohou použít první druh.
- Pro tapscripty nepoužíváme MuSig klíče. Naše peněženky obsahují zálohový klíč,
ke kterému je potenciálně ztížený přístup nebo který vyžaduje k podepsání jiný software mimo
naši kontrolu. Není tedy realistické předpokládat, že bude tento
klíč schopen podepisovat MuSig.
- Pro tapscripty jsou zvolili skripty `OP_CHECKSIG` / `OP_CHECKSIGVERIFY` namísto
`OP_CHECKSIGADD`. Víme, které klíče budou podepisovat během konstrukce transakce
a 2 ze 2 skripty hloubky 1 jsou mírně levnější než 2 ze 3 skripty hloubky 0.

Konečná struktura vypadá takto:

{:.center}
![BitGo's MuSig taproot structure](/img/posts/bitgo-musig/musig-taproot-tree.png)

## Nonce (deterministické i náhodné)

Elektronické podpisy nad eliptickými křivkami jsou tvořeny za pomoci dočasné
tajné hodnoty známé jako nonce („number once”). Sdílením veřejného nonce
(veřejný nonce je soukromému nonce to stejné jako veřejný klíč soukromému klíči)
v podpisu mohou ověřovatelé potvrdit validitu podpisu, aniž by bylo nutné
odhalit soukromý klíč. Aby byl tento soukromý klíč ochráněn, nesmí být nonce
znovu použit se stejným (nebo odvozeným) soukromým klíčem a zprávou. Pro
jednoduché podpisy je nejčastěji doporučovaným způsobem ochrany proti
znovupoužití nonce deterministický generátor dle [RFC6979][]. Rovnoměrně
náhodná hodnota může být také bezpečně použita, je-li okamžitě po použití
zahozena. Ani jedna z těchto technik však nemůže být přímo použita pro
protokoly s vícenásobnými podpisy.

Abychom mohli v MuSig bezpečně používat deterministické nonce, musí být použita
nějaká technika jako MuSig-DN, která prokáže, že všichni účastníci správně
vygenerovali svá deterministická nonce. Bez tohoto důkazu by mohl záškodník
započít dvě sezení podepisující stejnou zprávu, ale za pomoci odlišných
nonce. Druhý podepisující, který generuje nonce deterministicky, by tak v důsledku
částečně podepsal dvě odlišné zprávy shodným nonce. Tím by záškodníkovi odhalil svůj
soukromý klíč.

Během vývoje specifikace MuSig2 jsme si já a [Dawid][] uvědomili, že _poslední_
podepisující by mohl svůj nonce vygenerovat deterministicky. Prodiskutoval jsem
to s [Jonasem Nickem][Jonas Nick], který toto pozorování formalizoval ve
specifikaci. V rámci naší implementace MuSig2 využíváme deterministického
podepisování s našimi HMS (hardware security modules), které tak mohou podepisovat
bez držení vnitřního stavu.

Při používání náhodných nonce v rámci vícekolových podpisových protokolů musí
podepisující zvážit, jak mezi jednotlivými koly nonce ukládat. U jednoduchých
podpisů může být tajný nonce smazán v rámci stejného procesu, který jej vytvořil.
Pokud by útočník získal klon podpisového zařízení okamžitě po vytvoření nonce,
ale ještě před jeho poskytnutím ostatním podepisujícím, mohlo by podpisové
zařízení být donuceno k vytvoření několika podpisů různých zpráv, ale se shodným
nonce. Z tohoto důvodu je doporučeno, aby podepisující uvážlivě rozhodli,
jak lze k vnitřnímu stavu přistupovat a kdy přesně je soukromý nonce smazán.
Když uživatelé BitGo podepisují pomocí MuSig2 a BitGo SDK, soukromá nonce
jsou držena v rámci knihovny [MuSig-JS][], kde jsou po podepsání smazána.

## Proces specifikace

Naše zkušenost s implementací MuSig2 ukazuje, že firmy i jednotlivci pracující
kolem bitcoinu by si měli vynahradit čas na revidování a přispívání vývoji
specifikací, které plánují implementovat. Když jsme poprvé zkoumali návrh
specifikace MuSig2 a začali promýšlet, jak jej nejlépe integrovat do našeho
systému, zvažovali jsme různé složité způsoby, jak provádět stavové podepisování
na našich HSM.

Naštěstí když jsem popsal tyto potíže Dawidovi, věřil, že existuje způsob, jak
používat deterministická nonce. Nakonec jsme se shodli na představě, že jedno
podpisové zařízení by mohlo být deterministické. Když jsem později nadnesl
tuto myšlenku Jonasovi a vysvětlil mu náš konkrétní případ, rozpoznal její hodnotu
a formalizoval ji ve specifikaci.

Nyní mohou i ostatní implementátoři využít flexibility dané tím, že jedno z
jejich podpisových zařízení nemusí držet stav. Revidováním a implementací
návrhu specifikace během vývoje jsme byli schopni do specifikace přispět a
také jsme mohli uvolnit MuSig2 podepisování krátce po formální publikaci
specifikace v rámci BIP327.

## MuSig a PSBT

Formát [částečně podepsaných transakcí][topic psbt] („partially signed bitcoin transaction”
neboli PSBT) je navržen tak, aby obsahoval všechny informace potřebné k podepsání
transakce mezi účastníky (kterými jsou v jednoduchých případech koordinátor a
podepisující). Čím více informací je pro podepsání potřebných, tím užitečnějším
se tento formát stává. Prozkoumali jsme náklady a výhody rozšíření našeho existujícího
API formátu o dodatečná pole pro MuSig2 v porovnání s přechodem na PSBT. Nakonec
jsme se rozhodli pro konverzi k PSBT jako formátu pro výměnu dat o transakci a byl
to obrovský úspěch. Zatím se to obecně neví, ale peněženky BitGo (kromě těch používajících
MuSig2, viz následující odstavec) mohou nyní spolupracovat s hardwarovými podpisovými
zařízeními podporujícími PSBT.

Zatím nejsou publikována PSBT pole pro použití s MuSig2. Pro naši implementaci
jsme použili proprietární pole, která byla založena na návrhu, jež s námi sdílel
[Sanket][]. Představuje to jednu málo známou výhodu PSBT formátu: možnost do
jednoho binárního datového formátu začlenit – vedle předdefinovaných globálních
sekcí vstupů a výstupů – i _jakákoliv_ dodatečná data potřebná pro váš
vlastní proces tvorby transakcí nebo protokol elektronického podepisování.
Specifikace PSBT odděluje nepodepsané transakce od skriptů, podpisů a dalších
dat potřebných pro zkompletování transakce. Toto oddělení umožňuje efektivnější
komunikaci během procesu podepisování. Například díky tomu mohou naše HSM
poskytnout minimální PSBT obsahující pouze nonce a podpisy a ty mohou být
snadno zkombinovány do předpodpisového PSBT.

## Poděkování

Děkuji Jonasovi Nickovi a Sanketovi Kanjalkarovi z Blockstreamu, Dawidovi
Ciężarkiewiczovi z Fedi a [Saravananovi Manimu][Saravanan Mani], Davidovi Kaplanovi
i všem ostatním členům BitGo týmu.

{% include references.md %}
[Brandon Black]: https://twitter.com/reardencode
[BitGo]: https://www.bitgo.com/
[MuSig paper]: https://eprint.iacr.org/2018/068
[MuSig-DN]: https://eprint.iacr.org/2020/1057
[MuSig2]: https://eprint.iacr.org/2020/1261
[bitgo blog taproot]: https://blog.bitgo.com/taproot-support-for-bitgo-wallets-9ed97f412460
[first tapscript multisig transaction]: https://mempool.space/tx/905ecdf95a84804b192f4dc221cfed4d77959b81ed66013a7e41a6e61e7ed530
[bitgo blog musig2]: https://blog.bitgo.com/save-fees-with-musig2-at-bitgo-3248d690f573
[FROST]: https://datatracker.ietf.org/doc/draft-irtf-cfrg-frost/
[2-party multi-signatures]: https://duo.com/labs/tech-notes/2p-ecdsa-explained
[RFC6979]: https://datatracker.ietf.org/doc/html/rfc6979
[Dawid]: https://twitter.com/dpc_pw
[Jonas Nick]: https://twitter.com/n1ckler
[MuSig-JS]: https://github.com/brandonblack/musig-js
[Sanket]: https://twitter.com/sanket1729
[Saravanan Mani]: https://twitter.com/saravananmani_
