V této sérii jsme zatím prozkoumali [motivace][policy01] a záludnosti
spojené s decentralizovaným přeposíláním transakcí, které vedou k
[lokální][policy05] i [globální][policy07] poptávce po přísnějších pravidlech
validace, než je konsenzus. Jelikož mohou mít změny pravidel
přeposílání transakcí v Bitcoin Core dopad na přeposílání transakcí,
vyžadují nejdříve dosažení společenského přijetí v rámci širší bitcoinové
komunity. Podobně musí být i aplikace a protokoly na druhé vrstvě
navrženy tak, aby se vyhnuly odmítání svých transakcí.

Protokoly s kontrakty jsou ještě závislejší na pravidlech spojených s
prioritizací, protože vymahatelnost onchain závisí na možnosti mít
transakce rychle potvrzené. V nepřátelském prostředí mohou mít podvádějící
protistrany zájem na zdržení konfirmace, musíme tedy také uvažovat, jak
by mohly být drobnosti v pravidlech přeposílání transakcí použity proti
uživateli.

Transakce v lightning network se drží pravidel standardnosti zmíněných v
předchozích článcích. Například jeho peer-to-peer protokol obsahuje ve
zprávě `open_channel` volbu `dust_limit_satoshis` určující práh neutratitelnosti.
Jelikož transakce obsahující výstup s hodnotou nižší než tento práh by nebyly
uzly přeposlány, jsou tyto platby považovány za „nevymahatelné onchain”
a jsou z commitment transakcí vyřazeny.

Protokoly s kontrakty často používají časové zámky, aby poskytly každému
účastníkovi možnost zpochybnit stav publikovaný onchain. Pokud by transakce
dotčeného uživatele nebyla potvrzena před uplynutím doby zámku, mohl by
přijít o prostředky. Proto jsou poplatky extrémně důležitým nástrojem
pro navýšení priority konfirmace. [Odhad jednotkového poplatku][policy04]
je ztížen tím, že transakce budou zveřejněny v neznámém čase, uzly jsou
často provozovány jako lehké klienty a některé možnosti navyšování poplatků
nemusí být k dispozici. Například byl-li by jeden z účastníků LN kanálu offline,
mohl by ten druhý jednostranně zveřejnit předem podepsanou commitment transakci
a tím dosáhnout vyrovnání společných prostředků onchain. Žádná ze stran nemůže
sama utratit společné UTXO, je-li tedy jedna strana offline, podepsání
[nahrazující][topic rbf] transakce pro navýšení poplatku commitment transakce
je nemožné. Namísto toho mohou commitment transakce obsahovat [anchor výstupy][topic
anchor outputs], které pomohou účastníkům kanálu připojit v době zveřejnění
[potomka navyšujícího poplatek][topic cpfp] (CPFP).

Tento způsob navyšování poplatků má ale také svá omezení. Jak bylo zmíněno v
[předchozím příspěvku][policy06], přidání CPFP transakce není efektivní, pokud
minimální jednotkový poplatek mempoolu přeroste poplatek commitment transakce.
Musí tedy i tak být podepsány s mírně přeceněným jednotkový poplatkem pro případ
navýšení minimálního poplatku mempoolu. Dále během vývoje anchor výstupů byly také
zohledněny případy, kdy může být v zájmu jedné strany konfirmaci pozdržet.
Například jedna strana (Alice) může zveřejnit svou commitment transakci před vypnutím
uzlu. Pokud by byl jednotkový poplatek této commitment transakce příliš nízký pro
dosažení okamžité konfirmace a pokud by Bob, Alicina protistrana, její transakci
neobdržel, mohl by být zmaten, proč zveřejnění jeho verze commitment transakce
není úspěšně propagováno v síti. Každá commitment transakce má dva anchor výstupy,
takže každá strana může použít CPFP na kteroukoliv commitment transakci, například
Bob může zkusit naslepo zveřejnit navýšení poplatku Aliciny verze commitment
transakce, i když si není jist, zda předtím ona svou verzi zveřejnila. Každý anchor
výstup disponuje malou hodnotou nad prahem neutratitelnosti. Po nějaké době ji může
nárokovat kdokoliv jako opatření před zahlcením množiny UTXO.

Zaručit každé straně možnost navýšit poplatek transakce pomocí CPFP je však mnohem
složitější, než přiřadit každé straně anchor výstup. Jak bylo zmíněno v [předchozím
příspěvku][policy05], jako ochranu před DoS omezuje Bitcoin Core počet a celkovou
velikost potomků, kteří mohou být přiřazeni nepotvrzené transakci. Jelikož má každá
protistrana možnost přidat potomky sdíleným transakcím, mohla by jedna z nich zablokovat
CPFP transakci té druhé vyčerpáním tohoto limitu a tím jí zabránit v propagaci.
Přítomnost těchto potomků tak v mempoolech „přišpendlí” tuto commitment transakci na pozici
s nízkou prioritou.

Na zabránění tohoto potenciálního útoku je navrhováno, aby byly všechny
ostatní výstupy omezeny relativním časovým zámkem, což by zabránilo v jejich
utracení před konfirmací. Dále byla upravena pravidla v Bitcoin Core, aby bylo možné
[přidat ještě jednoho potomka][topic cpfp carve out] (CPFP carve out), pokud je tento potomek malý
a nemá žádné další předky. Tato kombinace změn v obou protokolech zajišťuje, že alespoň
dva účastníci ve sdílené transakci by mohli v čase zveřejnění upravit jednotkový poplatek,
aniž by významně navýšili možnost DoS útoku.

Zabránění CPFP naplněním omezení počtu potomků je příkladem [pinning útoků][topic transaction
pinning]. Tyto útoky zneužívají omezení v pravidlech mempoolu, aby transakcím zabránily v přístupu
do mempoolu nebo v potvrzení. V tomto případě představují pravidla mempoolu
kompromis mezi [odolností vůči DoS][policy05] a [incentivami][policy02]. Nějaký kompromis
musí být učiněn: uzel by měl zvažovat navýšení poplatků, ale nemůže zpracovávat
nekonečně mnoho potomků. CPFP carve out upravuje tento kompromis pro konkrétní případ
použití.

Vedle vyčerpání limitu potomků existují i další pinning útoky, které [zabraňují použití RBF][full
rbf pinning], činí RBF [příliš drahým][rbf ml] či zneužívají RBF ke zpoždění konfirmace
ANYONECANPAY transakcí. Pinning je problémem pouze v případech, kdy více stran spolupracuje
na vytvoření společné transakce nebo kde má nedůvěryhodná strana prostor upravovat transakci.
Minimalizace přístupu transakce nedůvěryhodným stranám je obecně dobrým způsobem
vyhýbání se pinningu.

Tyto třecí plochy zdůrazňují nejen důležitost pravidel jako rozhraní pro aplikace a protokoly
v rámci ekosystému bitcoinu, ale také ukazují místa, která potřebují vylepšit.
Příští týden se podíváme na návrhy pravidel a otevřené otázky.

[full rbf pinning]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-May/003033.html
[rbf ml]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-January/019817.html
[n25038 notes]: https://bitcoincore.reviews/25038
[policy01]: /cs/newsletters/2023/05/17/#čekání-na-potvrzení-1-k-čemu-je-mempool
[policy02]: /cs/newsletters/2023/05/24/#čekání-na-potvrzení-2-incentivy
[policy04]: /cs/newsletters/2023/06/07/#čekání-na-potvrzení-4-odhad-poplatků
[policy05]: /cs/newsletters/2023/06/14/#čekání-na-potvrzení-5-pravidla-pro-ochranu-zdrojů-uzlů
[policy06]: /cs/newsletters/2023/06/21/#čekání-na-potvrzení-6-konzistence-pravidel
[policy07]: /cs/newsletters/2023/06/28/#čekání-na-potvrzení-7-síťové-zdroje
