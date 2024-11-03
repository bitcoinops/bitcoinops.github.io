---
title: 'Zpravodaj „Bitcoin Optech” č. 316'
permalink: /cs/newsletters/2024/08/16/
name: 2024-08-16-newsletter-cs
slug: 2024-08-16-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Zpravodaj tento týden popisuje nový útok ohýbáním času postihující
hlavně nový testnet4, shrnuje diskuzi o návrzích na zmírnění hrozby odepření
služby onion zprávami, žádá o zpětnou vazbu k návrhu na volitelnou možnost
sebeidentifikace plátců v LN a oznamuje velkou změnu v sestavovacím systému
Bitcoin Core, která by mohla mít dopad na vývojáře a integrátory. Též
nechybí naše pravidelné rubriky s oznámeními nových vydání a popisem
významných změn v populárním bitcoinovém páteřním software.

## Novinky

- **Nová zranitelnost ohýbáním času v testnet4:** Mark „Murch”
  Erhardt zaslal do fóra Delving Bitcoin [příspěvek][erhardt warp] s popisem
  útoku [objeveného][zawy comment] vývojářem Zawy, který zneužívá nový
  algoritmus úpravy obtížnosti v [testnet4][topic testnet]. Testnet4
  aplikoval řešení z mainnetového soft forku na [pročištění konsenzu][topic
  consensus cleanup], které má za cíl bránit [útokům ohýbáním času][topic time
  warp] (time warp attacks). Avšak Zawy popsal útok podobný ohýbání času,
  který by navzdory novému pravidlu mohl být použit ke snížení obtížnosti těžby
  na 1/16 normální hodnoty. Erhardt rozšířil Zawyho útok tak, aby
  umožňoval redukci obtížnosti až na její minimální hodnotu. Níže popisujeme
  několik souvisejících útoků ve zjednodušené podobě:

  Bitcoinové bloky jsou produkovány nahodile se zamýšlenou změnou obtížnosti každých
  2 016 bloků tak, aby průměrný čas mezi dvěma bloky byl kolem deseti minut.
  Následující zjednodušená ilustrace ukazuje, jak by měla vypadat produkce
  bloků s konstantní měrou, pokud změna obtížnosti nastává každých pět bloků
  (sníženo z 2 016 bloků z důvodu čitelnosti):

  ![Ilustrace čestné těžby s konstantním hashrate (zjednodušeno)](/img/posts/2024-time-warp/reg-blocks.png)

  Záškodnický těžař (nebo skupina těžařů) vlastnící o něco více než 50 %
  hashrate může cenzurovat bloky produkované ostatními méně než 50 %
  čestných těžařů. To by přirozeně vedlo nejprve k jednomu produkovanému bloku
  v průměru za dvacet minut. Po 2 016 blocích produkovaných touto měrou
  by byla obtížnost snížena na polovinu její původní hodnoty, aby se míra
  produkce bloků vrátila na jeden blok každých deset minut:

  ![Ilustrace cenzurování bloků útočníkem majícím mírně přes 50 % celkového hashrate (zjednodušeno)](/img/posts/2024-time-warp/50p-attack.png)

  Útok ohýbáním času nastává, když záškodnický těžař použije svou většinu
  hashrate k protlačení časových razítek s minimální možnou hodnotou ve
  většině bloků. Na konci každé 2016blokové periody zvýší čas v hlavičce
  bloku na aktuální [skutečný čas][wall time], aby se doba mezi vyprodukovanými
  bloky jevila delší, než jaká byla ve skutečnosti. To vede ke snížení
  obtížnosti v následující periodě:

  ![Ilustrace klasického útoku ohýbáním času (zjednodušeno)](/img/posts/2024-time-warp/classic-time-warp.png)

  [Nové pravidlo][testnet4 rule] aplikované v testnet4 tomu brání tím, že
  nedovoluje prvnímu bloku nové periody mít časové razítko výrazně dřívější,
  než jaké má předchozí blok (poslední bok předchozí periody).

  Stejně jako původní útok ohýbáním času i Erhardtova verze Zawyho útoku
  inkrementuje většinu časových razítek v hlavičkách bloků minimálním
  možným přírůstkem. Avšak ve dvou z každých tří period posune dopředu čas
  posledního bloku periody a prvního bloku následující periody. To sníží
  obtížnost o největší možnou hodnotu (1/4 aktuální hodnoty). Ve třetí
  periodě používá nejnižší možný čas v každém bloku a také v prvním bloku
  následující periody, což zvýší obtížnost o maximální hodnotu (4×).
  Jinými slovy: obtížnost se sníží o 1/4, potom se opět sníží na 1/16 a potom
  zvýší na 1/4 původní hodnoty:

  ![Ilustrace Erhardtovy verze Zawyho nového útoků ohýbáním času (zjednodušeno)](/img/posts/2024-time-warp/new-time-warp.png)

  Tento tříperiodový cyklus může být opakován donekonečna. V každém cyklu se
  sníží obtížnost o 1/4, až nakonec bude snížená na úroveň, při které
  umožní těžařům produkovat až [šest bloků za sekundu][erhardt se].

  Aby útočníci (těžaři) mohli snížit obtížnost o 1/4, musí na začátku
  útoku nastavit čas posledního bloku periody o osm týdnů dále do
  budoucnosti, než kolik měl blok na začátku aktuální periody. Udělat
  to dvakrát za sebou bude vyžadovat nastavení času některého bloku na
  16 týdnů do budoucnosti. Plné uzly neakceptují bloky, které mají
  čas více než dvě hodiny v budoucnosti, což nedovolí záškodnickým
  blokům akceptování po osm týdnů, respektive 16 týdnů. Během čekání
  mohou útočníci vytvářet další bloky za ještě menší obtížnosti. Bloky
  vytvořené čestnými těžaři během těchto 16 týdnů, kdy útočníci připravují
  svůj útok, budou vyloučeny reorganizacemi, až plné uzly začnou akceptovat
  bloky útočníků. Kvůli tomu by mohly být všechny transakce z tohoto
  období v aktuálním blockchainu buď nepotvrzené nebo nevalidní (_konfliktní_).

  Erhardt navrhuje vyřešit tento druh útoku soft forkem, který by vyžadoval,
  aby časové razítko posledního bloku periody bylo větší než časové razítko
  prvního bloku stejné periody. Zawy navrhuje několik řešení, včetně
  zákazu poklesu časových razítek (to by mohlo způsobit problémy, pokud
  někteří těžaři vytváří bloky blízko dvouhodinového limitu vynucovaného
  uzly) nebo přinejmenším zákazu, aby klesly o více než dvě hodiny.

  Celkově je na mainnetu tento nový útok ohýbáním času podobný původní
  verzi útoku, co se týče požadavků na těžební vybavení, možnost včasného
  odhalení, dopadů na uživatele a řešení v podobě relativně jednoduchého
  soft forku. Vyžaduje, aby měl útočník k dispozici minimálně 50 % hashrate
  přinejmenším po dobu jednoho měsíce. To by uživatelům signalizovalo
  hrozící útok a někdo by si toho na mainnetu zřejmě povšiml. Jak Zawy
  [poznamenává][zawy testnet risk], útok lze mnohem snadněji provést
  na testnetu, neboť jen malé množství moderního vybavení postačuje na
  dosažení 50 % hashrate. Útočník by poté mohl teoreticky vytvořit
  přes 500 000 bloků za den. Zabránit by v tom mohl pouze někdo ochotný
  věnovat ještě větší množství hashrate. Nebo by mu v tom mohl zabránit
  soft fork.

  V době psaní zpravodaje byly kompromisy mezi řešeními stále diskutovány.

- **Diskuze o hrozbě DoS onion zprávami:** Gijs van Dam zaslal do fóra
  Delving Bitcoin [příspěvek][vandam onion] odkazující na nedávný
  [článek][bk onion] od badatelů Amina Bashiriho a Majida Khabbaziana
  o [onion zprávách][topic onion messages]. Výzkumníci poznamenávají,
  že každá onion zpráva může být přeposlána mnoha uzly (dle van Damových
  kalkulací až 481), čímž může potenciálně plýtvat jejich přenosovým pásmem.
  Popisují několik metod snížení rizika zneužití přenosového pásma, včetně
  chytré metody vyžadování exponenciálně se zvyšujícího PoW za každý
  další skok, čímž by se staly dlouhé cesty nákladnými.

  Matt Corallo navrhuje, aby se před vynakládáním úsilí na něco složitějšího
  nejdříve vyzkoušel již představený návrh (viz [zpravodaj č. 207][news207
  onion], _angl._), který by omezoval spojení k uzlům posílajícím příliš mnoho
  zpráv.

- **Volitelná identifikace a autentizace LN plátců:** Bastien
  Teinturier zaslal do fóra Delving Bitcoin [příspěvek][teinturier auth]
  s návrhem způsobu, který by plátcům umožnil volitelně přidat k platbám
  dodatečná data, jež by příjemci pomohla tyto platby identifikovat
  jako pocházející od známého kontaktu. Například pokud by Alice vygenerovala
  [nabídku][topic offers], kterou by Bob zaplatil, mohla by požadovat
  kryptografický důkaz, že platba skutečně pochází od Boba a ne od nějaké
  třetí strany předstírající, že je Bob. Nabídky jsou navržené, aby
  skrývaly identitu plátců a příjemců, musel by tedy existovat dodatečný
  mechanismus, který by umožnil volitelnou identifikaci a autentizaci.

  Teinturier začíná popisem mechanismu volitelné distribuce _kontaktních
  klíčů_, kterým by Bob mohl odhalit svůj veřejný klíč Alici.
  Dále popisuje tři možné kandidáty na další volitelný mechanismus, který
  by Bob mohl použít k podepsání svých plateb Alici. Pokud by Bob tento
  mechanismus použil, Alicina LN peněženka by mohla podpis autentizovat
  jako Bobův a tuto informaci jí zobrazit. V neautentizovaných platbách
  by pole nastavována plátcem (jako libovolný obsah v `payer_note`) mohla
  být označena za nedůvěryhodná. Tím by byli uživatelé odrazováni
  od spoléhání na jejich hodnoty.

  Teinturier žádá o zpětnou vazbu k volbě kryptografických metod a plánuje
  vydat [BLIP42][blips #42] se specifikacemi vybraných způsobů.

- **Bitcoin Core přechází na sestavovací systém CMake:** Cory Fields
  zaslal do emailové skupiny Bitcoin-Dev [příspěvek][fields cmake]
  s oznámením nadcházejícího přechodu Bitcoin Core ze sestavovacího systému
  GNU autotools na systém [CMake][cmake wiki]. Přechod byl veden
  Hennadijem Stepanovem za přispění Michaela Forda (modernizace a opravy
  chyb) a revidování kódu a příspěvky od několika dalších vývojářů (včetně
  Fieldse). Tato změna by neměla mít žádný dopad na uživatele binárních
  sestavení dostupných na BitcoinCore.org (podle našeho odhadu jsou používána
  většinou lidí). Avšak vývojáři a integrátoři, kteří sestavují své vlastní
  binárky za účelem testování nebo přizpůsobení, mohou změnu pocítit (obzvláště
  ti, kteří pracují s neobvyklými platformami či konfigurací sestavování).

  Fieldsův email poskytuje odpovědi na očekávané otázky a žádá kohokoliv, kdo
  Bitcoin Core sám sestavuje, aby otestoval [PR #30454][bitcoin core #30454]
  a nahlásil problémy. Očekává se, že PR bude během příštích týdnů začleněno
  a vydáno ve verzi 29 (zhruba za sedm měsíců). Čím dříve testování provedete,
  tím více času budou vývojáři Bitcoin Core mít na odstranění problémů
  před vydáním verze 29. Tím se zvýší šance, že změna nebude mít na
  vaši konfiguraci dopad.

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [BDK 1.0.0-beta.1][] je kandidátem na vydání této knihovny pro budování
  peněženek a jiných bitcoinových aplikací. Původní rustový crate `bdk`
  byl přejmenován na `bdk_wallet` a moduly nižší úrovně byly extrahovány
  do vlastních crate: `bdk_chain`, `bdk_electrum`, `bdk_esplora` a `bdk_bitcoind_rpc`.
  `bdk_wallet` je „první verzí se stabilním 1.0.0 API.”

- [Core Lightning 24.08rc2][] je kandidátem na vydání další hlavní verze této
  populární implementace LN uzlu.

- [LND v0.18.3-beta.rc1][] je kandidátem na menší opravné vydání této oblíbené
  implementace LN uzlu.

## Významné změny kódu a dokumentace

_Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Bitcoin Inquisition][bitcoin inquisition repo] a [repozitáři BINANA][binana
repo]._

- [Bitcoin Core #29519][] nastavuje po načtení [assumeUTXO][topic assumeutxo] snapshotu
  hodnotu `pindexLastCommonBlock`, aby uzel prioritizoval stahování bloků od posledního
  bloku v snapshotu. Tím se opravuje chyba, kvůli které uzel nastavoval `pindexLastCommonBlock`
  na základě existujících spojení ještě před načtením snapshotu a začal stahovat
  bloky od tohoto mnohem staršího bloku. I když starší bloky i nadále musí být
  stahovány (assumeUTXO je na pozadí validuje), nové bloky by měly mít prioritu,
  aby uživatelé viděli své potvrzené transakce.

- [Bitcoin Core #30598][] odstraňuje z metadat [assumeUTXO][topic assumeutxo] snapshotu
  výšku bloku, neboť se nejedná o jedinečný identifikátor v nedůvěryhodném nezpracovaném
  souboru. Haš bloku, který je ve snapshotu též uložen, je vhodnějším identifikátorem
  a může být použit ke zjištění výšky bloku z jiných vnitřních zdrojů.

- [Bitcoin Core #28280][] zrychluje prvotní stahování bloků (Initial Block Download, IBD)
  u ořezaných uzlů, protože uzel již nebude během zápisů do databáze vyprazdňovat mezipaměť
  UTXO. Za tímto účelem sleduje prvky v mezipaměti, které se od posledního zápisu do databáze
  změnily, a nemusí tak během zápisů skenovat celou mezipaměť. Optimalizace dosahuje až
  32% zrychlení IBD u ořezaných uzlů s vysokou hodnotou `dbcache` a kolem 9% zrychlení
  s výchozím nastavením. Další informace ve [zpravodaji č. 304][news304 cache].

- [Bitcoin Core #28052][] přináší do souborů `blocksdir *.dat` [XOR][] kódování
  jako preventivní mechanismus proti nechtěnému a nahodilému poškození dat antivirem
  či podobným softwarem. Kódování nechrání proti záměrnému poškození dat a je možné
  jej vypnout. Stejný mechanismus byl v září 2015 implementován pro `chainstate` soubory
  ([Bitcoin Core #6650][]) a v listopadu 2023 pro mempool ([#28207][bitcoin core
  #28207], viz též [zpravodaj č. 277][news277 bcc28207]).

- [Core Lightning #7528][] upravuje [odhad poplatků][topic fee estimation] používaný
  při jednostranném uzavření kanálu, které není citlivé na časování. Nová hodnota
  absolutního limitu je 2 016 bloků (kolem dvou týdnů) oproti 300 blokům v předchozí
  verzi. To dříve mohlo způsobit, že transakce se kvůli [spodní hranici poplatků][topic
  default minimum transaction relay feerates] v pravidlech pro přeposílání nikdy
  nepotvrdila.

- [Core Lightning #7533][] upravuje interní notifikace o pohybu mincí a účetní
  systém transakcí (bookkeeper), aby braly do úvahy utrácení financujících výstupů
  [splicingových][topic splicing] transakcí. Dříve nebyly vůbec sledovány.

- [Core Lightning #7517][] představuje nový experimentální plugin `askrene` a
  API pro hledání cest s minimálními náklady založené na pluginu `renepay`
  (viz [zpravodaj č. 263][news263 renepay]) zlepšující implementaci Pickhardtových
  plateb. RPC příkaz `getroutes` vrací množinu možných cest spolu s odhadem
  pravděpodobnosti úspěchu. Bylo též přidáno několik dalších RPC příkazů pro
  správu routovacích dat, přidávání kanálů, úpravu jejich dat, vylučování kanálů
  z hledání cest, prohlížení dat a správu probíhajících pokusů o platby.

- [LND #8955][] přidává do příkazu `sendcoins` volitelné pole `utxo` (a `Outpoints`
  do odpovídajícího RPC příkazu `SendCoinsRequest`), které zjednoduší používání
  [výběru mincí][topic coin selection] na jediný krok. Dříve musel uživatel projít
  vícekrokovým procesem, který obsahoval výběr mincí, odhad poplatků, financování
  [PSBT][topic psbt], kompletaci PSBT a zveřejnění transakce.

- [LND #8886][] přidává do funkce `BuildRoute` podporu pro [příchozí poplatky za
  přeposlání][topic inbound forwarding fees]. Obrací proces hledání cesty, nově
  bude hledat od příjemce k odesílateli, což umožní přesnější výpočet poplatků.
  [Zpravodaj č. 297][news297 inboundfees] obsahuje více podrobností o příchozích
  poplatcích.

- [LND #8967][] přidává podporu pro zprávu `stfu` (SomeThing Fundamental is Underway
  čili „něco velkého se děje”; též zkratka vulgární žádosti o ticho) reprezentovanou
  novým typem `Stfu`. Tato zpráva je navržena ke zmrazení stavu kanálu před
  zahájením [upgradu parametrů kanálu][topic channel commitment upgrades]. Zpráva
  obsahuje pole pro ID kanálu, příznak iniciátora a data pro možná budoucí rozšíření.
  Jedná se o součást implementace protokolu Quiescence („chvíle ticha”; viz též
  [zpravodaj č. 309][news309 quiescence]).

- [LDK #3215][] kontroluje, že transakce má nejméně 65 bajtů. Tato kontrola ochrání
  před [nákladným a nepravděpodobným útokem][spv attack] na lehké SPV klienty,
  u kterých může být vytvořena falešná 64bajtová transakce z hašů dvou vnitřních
  Merkleových uzlů.

- [BLIPs #27][] přidává BLIP04 pro experimentální podporu [HTLC atestací][topic htlc
  endorsement]. Ty by měly částečně bránit [útokům zahlcením kanálu][topic channel
  jamming attacks]. Popisuje nové TLV záznamy, způsob nasazení a případný přechod
  z experimentální fáze, pokud by HTLC atestace byly začleněny mezi BOLTy.

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="29519,30598,28280,28052,7528,7533,7517,8955,8886,8967,3215,1658,27,30454,42,6650,28207" %}
[BDK 1.0.0-beta.1]: https://github.com/bitcoindevkit/bdk/releases/tag/v1.0.0-beta.1
[erhardt se]: https://bitcoin.stackexchange.com/a/123700
[erhardt warp]: https://delvingbitcoin.org/t/zawy-s-alternating-timestamp-attack/1062
[zawy comment]: https://github.com/bitcoin/bitcoin/pull/29775#issuecomment-2276135560
[wall time]: https://en.wikipedia.org/wiki/Elapsed_real_time
[testnet4 rule]: https://github.com/bitcoin/bips/blob/master/bip-0094.mediawiki#time-warp-fix
[zawy testnet risk]: https://delvingbitcoin.org/t/zawy-s-alternating-timestamp-attack/1062/5
[vandam onion]: https://delvingbitcoin.org/t/onion-messaging-dos-threat-mitigations/1058
[bk onion]: https://fc24.ifca.ai/preproceedings/104.pdf
[news207 onion]: /en/newsletters/2022/07/06/#onion-message-rate-limiting
[teinturier auth]: https://delvingbitcoin.org/t/bolt-12-trusted-contacts/1046
[fields cmake]: https://mailing-list.bitcoindevs.xyz/bitcoindev/6cfd5a56-84b4-4cbc-a211-dd34b8942f77n@googlegroups.com/
[cmake wiki]: https://cs.wikipedia.org/wiki/CMake
[Core Lightning 24.08rc2]: https://github.com/ElementsProject/lightning/releases/tag/v24.08rc2
[LND v0.18.3-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.18.3-beta.rc1
[news304 cache]: /cs/newsletters/2024/05/24/#bitcoin-core-28233
[news263 renepay]: /cs/newsletters/2023/08/09/#core-lightning-6376
[news309 quiescence]: /cs/newsletters/2024/06/28/#bolts-869
[spv attack]: https://web.archive.org/web/20240329003521/https://bitslog.com/2018/06/09/leaf-node-weakness-in-bitcoin-merkle-tree-design/
[news297 inboundfees]: /cs/newsletters/2024/04/10/#lnd-6703
[news277 bcc28207]: /cs/newsletters/2023/11/15/#bitcoin-core-28207
[xor]: https://cs.wikipedia.org/wiki/Vernamova_%C5%A1ifra
