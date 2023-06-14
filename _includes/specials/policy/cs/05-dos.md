Na [počátku][policy01] naší série jsme uvedli, že většina ochrany soukromí
a odolnost vůči cenzuře pramení z decentralizace bitcoinové sítě. Uživatelé
provozující uzly napomáhají k redukci počtu slabých míst, špehování
a cenzury. Vyplývá z toho, že jedním z hlavních cílů designu software
bitcoinového uzlu je jeho vysoká dostupnost. Pokud by byli uživatelé
nuceni pořídit si drahý hardware, používat konkrétní operační systém
nebo platit měsíčně stovky dolarů za jeho provozování, počet uzlů
v síti by nejspíš klesl.

Navíc je takový uzel bitcoinové sítě připojen pomocí internetu k neznámým
entitám, které mohou spustit útok odepření služby (DoS) a způsobit
tím pád uzlu vyčerpáním paměti nebo plýtvání výpočetními a přenosovými
zdroji. Jelikož jsou tyto entity anonymní, nemohou naše uzly před připojením
určit, které uzly budou poctivé a které zlomyslné, a nemohou je ani
po detekci útoku účinně zakázat. Je tedy nutné, aby byla implementována pravidla,
která chrání před DoS a omezují náklady na provozování plného uzlu.

Všeobecné ochrany proti DoS a vyčerpání zdrojů jsou vestavěné přímo do software
uzlů. Například obdrží-li Bitcoin Core od jediného spojení velké množství zpráv,
zpracuje pouze první z nich, zbytek uloží do fronty a zpracuje je pouze,
až obdrží a zpracuje zprávy od jiných spojení. Uzly také obvykle nejdříve
stáhnou pouze hlavičku bloku, ověří její Proof of Work (PoW) a teprve potom
stáhnou a ověří zbytek bloku. Útočník, který by chtěl vyčerpat zdroje uzlu
v rámci přeposílání bloků, by tak nejdříve musel věnovat nepřiměřené množství
vlastních zdrojů k výpočtu validního PoW. Tato asymetrie mezi obrovskými
náklady na výpočet PoW a minimálními náklady na jeho ověření poskytuje
přirozený způsob ochrany DoS v rámci přeposílání bloků. Tuto vlastnost však
nemá přeposílání _nepotvrzených_ transakcí.

Všeobecné ochrany proti DoS však neposkytují dostatečné překážky proti jiným
druhům útoků. Útočník může například [zbastlit maximálně výpočetně náročnou][max cpu tx]
validní transakci, jako byla 1MB [„megatransakce”][megatx mempool space] v bloku
364292, jejíž validace trvala mimořádně dlouho dobu kvůli [ověřování podpisů
a kvadratickému sighashingu][rusty megatx]. Útočník může také za řadu
validních podpisů přidat jeden nevalidní, kvůli čemuž stráví uzel nad transakcí
několik minut, aby zjistil, že se jedná o zmetka. Během té doby uzel nepracuje
na novém bloku. Můžeme si představit, že takový druh útoku by cílil na konkurenční
těžaře, aby jim zpozdil počátek hledání nového bloku.

Ve snaze vyhnout se práci na výpočetně velmi náročných transakcích omezují
uzly s Bitcoin Core maximální velikost a počet operací s podpisy (tzv. „sigops”)
v každé transakci více, než jsou limity konsenzu. Uzly s Bitcoin Core také
vynucují omezení na velikost balíčků předků a potomků, díky čemuž jsou produkce
šablon bloků a algoritmy vylučování účinnější a [výpočetní náročnost][se descendant
limits] přidání do a odebírání z mempoolu nižší. I když kvůli těmto pravidlům
mohou být vyloučeny některé validní transakce, očekává se, že podobné případy
budou vzácné.

Tato pravidla jsou příklady _pravidel přeposílání transakcí_ („transaction relay
policy”), jež existují nad rámec pravidel konsenzu a týkají se nepotvrzených
transakcí.

Ve výchozím stavu neakceptuje Bitcoin Core transakce s nižším jednotkovým poplatkem
než 1 sat/vB („minrelaytxfee”), neověřují žádné podpisy před ověřením tohoto požadavku
a nepřeposílají transakce, dokud nejsou přijaty do jejich vlastních mempoolů. Ve své
podstatě stanovuje toto pravidlo minimální „cenu” za validaci a přeposílání.
Netěžící uzly nikdy poplatky neobdrží, pouze těžař, který transakci potvrdí, dostane
zaplaceno. Poplatky však přináší náklady útočníkovi. Kdo posílá extrémní množství
transakci a „plýtvá” tak síťovými zdroji, brzy přijde platbou poplatků o všechny peníze.

Pravidla [nahrazování poplatkem][topic rbf] („replace by fee”) [implementována v Bitcoin
Core][bitcoin core rbf docs] vyžadují, aby nahrazující transakce platila vyšší jednotkový
poplatek než kterákoliv transakce, se kterou je v přímém konfliktu, a také aby celkový
poplatek byl vyšší než poplatek za všechny transakce, které nahrazuje. Dodatečné
poplatky vydělené virtuální velikostí nahrazující transakce musí být vyšší než
1 sat/vB. Jinými slovy, bez ohledu na jednotkový poplatek původní a nahrazující transakce
musí nová transakce zaplatit „nové” poplatky, aby pokryla své vlastní přenosové náklady
za cenu 1 sat/vB. Hlavní důvod tohoto pravidla je zdražit opakované útoky plýtvající přenosovým
pásmem, např. takové, kdy každé další nahrazení přidává jediný satoshi.

Uzel, který kompletně validuje bloky a transakce, vyžaduje zdroje včetně paměti,
výpočetních zdrojů a přenosového pásma. Musíme zajistit, aby požadavky na zdroje
byly co nejnižší a aby tak bylo provozování uzlu přístupné a odolné vůči vykořisťování.
Všeobecné DoS ochrany nejsou dostatečné, proto uzly vedle pravidel konsenzu aplikují
během validace nepotvrzených transakcí navíc i pravidla přeposílání transakcí. Jelikož
však pravidla nejsou konsenzem, dva uzly mohou mít pravidla nastavena odlišně a i tak
mohou dojít ke shodě na stavu blockchainu. Příští týden popíšeme pravidla jako
individuální volbu.

[policy01]: /cs/newsletters/2023/05/17/#čekání-na-potvrzení-1-k-čemu-je-mempool
[max cpu tx]: https://bitcointalk.org/?topic=140078
[megatx mempool space]: https://mempool.space/tx/bb41a757f405890fb0f5856228e23b715702d714d59bf2b1feb70d8b2b4e3e08
[rusty megatx]: https://rusty.ozlabs.org/?p=522
[bitcoin core rbf docs]: https://github.com/bitcoin/bitcoin/blob/v25.0/doc/policy/mempool-replacements.md
[pr 6722]: https://github.com/bitcoin/bitcoin/pull/6722
[se descendant limits]: https://bitcoin.stackexchange.com/questions/118160/whats-the-governing-motivation-for-the-descendent-size-limit
