---
title: 'Zpravodaj „Bitcoin Optech” č. 304'
permalink: /cs/newsletters/2024/05/24/
name: 2024-05-24-newsletter-cs
slug: 2024-05-24-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Zpravodaj tento týden shrnuje analýzu několika návrhů na upgradování
LN kanálů bez nutnosti je zavřít a znovu otevřít, diskutuje obtíže
v zajištění korektních výplat odměn těžařům v poolech, odkazuje na
diskuzi o bezpečném používání PSBT pro tiché platby, oznamuje návrh
BIPu pro miniscript a shrnuje návrh na využívání časté změny zůstatku
LN kanálu k simulaci kontraktů s cenovými futures. Též nechybí naše
pravidelné rubriky se souhrnem změn ve službách a klientech, oznámeními
nových vydání a souhrnem významných změn v populárním bitcoinovém
páteřním software.

## Novinky

- **Upgradování existujících LN kanálů:** Carla Kirk-Cohen zaslala do
  fóra Delving Bitcoin [příspěvek][kc upchan], ve kterém shrnuje a
  analyzuje současné návrhy na upgradování existujících LN kanálů.
  Upgrade slouží k přidání podpory nových funkcí. Zkoumá řadu rozličných
  případů, např:

  - *Změny parametrů:* v současnosti jsou některá nastavení kanálu dojednána
    mezi stranami a nemohou být později změněna. Změna parametrů by umožňovala
    případné nové vyjednávání o nastavení, například by mohly uzly chtít
    změnit množství satoshi, při kterém začnou [ořezávat HTLC][topic trimmed htlc],
    nebo výši rezerv kanálu, kterou od protistrany očekávají jako pojistku
    proti jeho zavření ve starém stavu.

  - *Změny commitmentů:* _commitment transakce_ v LN umožňují, aby jednotlivec
    mohl poslat současný stav kanálu do blockchainu. Změny commitmentů by umožnily
    kanálům založeným na P2WSH přepnout na [anchor výstupy][topic anchor outputs]
    a [v3 transakce][topic v3 transaction relay] a [jednoduchým taprootovým kanálům][topic
    simple taproot channels] na [PTLC][topic ptlc].

  - *Obměna financování:* LN kanály jsou v blockchainu ukotvené ve _financující
    transakci_, jejíž výstup je offchain opakovaně utrácen jako commitment
    transakce. Původně používaly všechny financující transakce P2WSH výstup,
    avšak novější možnosti jako [PTLC][topic ptlc] vyžadují P2TR výstupy.

  Kirk-Cohen srovnává předchozí tři návrhy upgradování kanálů:

  - *Dynamické commitmenty:* jak popisuje [návrh specifikace][BOLTs #1117],
    umožňují změnit téměř všechny parametry kanálu a navíc poskytují
    všeobecný způsob upgradování financování a commitment transakcí
    díky nové „kickoff” transakci.

  - *Upgrade po splicu:* tato myšlenka umožňuje, aby [splicingová transakce][topic
    splicing], která již nezbytně aktualizuje onchain financování kanálu,
    mohla též změnit typ použitého financování a volitelně formát commitment
    transakce. Přímo se netýká změn parametrů kanálu.

  - *Upgrade při opakovaném navázání spojení:* jak popisuje [návrh
    specifikace][bolts #868], tento způsob umožňuje změnit několik parametrů
    kanálu během opakovaného navázání spojení mezi dvěma uzly. Přímo se netýká
    financování a upgradu commitment transakce.

  Kirk-Cohen dále v tabulce porovnává všechny možnosti: vypisuje jejich onchain
  náklady, výhody a nevýhody. Též je porovnává s onchain náklady v případě,
  pokud žádný upgrade nenastane. Mezi jejími závěry nechybí: „Myslím, že má
  smysl začít pracovat na upgradování parametrů i commitmentů pomocí
  [dynamických commitmentů][bolts #1117], bez ohledu na naši volbu způsobu
  upgradování na taprootové kanály. To nám dává možnost upgradovat na
  `option_zero_fee_htlc_tx` anchor kanály a poskytnout mechanismus
  upgradování formátů commitmentů, který může být použit pro V3 kanály
  (jakmile budou specifikovány).”

- **Obtíže s odměňováním těžařů v poolech:** Ethan Tuttle zaslal do fóra Delving
  Bitcoin [příspěvek][tuttle poolcash] s návrhem, aby mohly [těžební pooly][topic
  pooled mining] odměňovat těžaře [ecashovými][topic ecash] tokeny poměrně
  k počtu vytěžených share. Těžaři by hned nato mohli tokeny prodat či
  přeposlat nebo by mohli počkat, až pool vytěží blok, načež by pool směnil
  tokeny za satoshi.

  Mezi reakcemi nechyběla kritika i další návrhy. Obzvláště zajímavou jsme
  shledali [reakci][corallo pooldelay] Matta Coralla, ve které popisuje
  základní problém: neexistují standardizované platební metody implementované
  velkými pooly, které by těžařům umožnily v krátkých intervalech spočítat své
  odměny. Dva rozšířené způsoby výplat odměn jsou:

  - *Platba za share (PPS):* vyplácí těžařovi odměnu v poměru za množství
    vykonané práce, i pokud není nalezen žádný blok. Spočítat poměrnou
    výši odměny těžařovi za odměnu za vytěžený blok je snadné, avšak spočítat
    ji za transakční poplatky je složitější. Corallo poznamenává, že většina
    poolů používá průměr poplatků posbíraných během dne, ve kterém byl share
    vytvořen. Znamená to, že výše odměny za share nemůže být ve stejný den
    spočítána. Pooly mohou navíc průměrem poplatků různými způsoby manipulovat.

  - *Platba za posledních n share (PPLNS):* odměňuje těžaře za share nalezené
    blízko okamžiku nalezení bloku. Avšak těžař si může být jist, že pool
    nalezl blok, pouze, pokud jej nalezl tento těžař sám. Neexistuje způsob
    (v krátkém časovém horizontu), kterým by mohl běžný těžař ověřit, že mu pool
    vyplácí korektní odměny.

  Kvůli těmto chybějícím informacím nejsou těžaři schopni rychle přepínat mezi jednotlivými
  pooly, pokud zjistí, že jejich hlavní pool je začíná na odměnách krátit.
  [Stratum v2][topic pooled mining] řešení nenabízí, avšak čestné pooly mohou
  použít standardizované zprávy k informování těžařů, že se chystají přestat
  za share platit. Corallo dále odkazuje na [návrh][corallo sv2 proposal]
  změny Stratum v2, která by těžařům umožnila ověřit, že za své share obdrželi
  korektní odměny, což by alespoň těžařům poskytlo možnost po delší době
  (hodiny až dny) odhalit, že je pool krátí na výplatách.

  V době psaní diskuze stále probíhala.

- **Diskuze o PSBT pro tiché platby:** Josie Baker započal na fóru Delving Bitcoin
  [diskuzi][baker psbtsp] o rozšíření [PSBT][topic psbt] pro [tiché platby][topic silent
  payments] (SP) dle [návrhu specifikace][toth psbtsp] od Andrew Totha.
  PSBT pro SP mají tato dvě hlediska:

  - **Platby na SP adresy:** výstupní skript transakce závisí zároveň na adrese
    tiché platby a na vstupech transakce. Jakákoliv změna vstupů v PSBT
    může potenciálně způsobit, že nebudou standardní peněženky schopné SP výstup
    utratit. Je tedy nutná dodatečná validace PSBT. Některé druhy vstupů
    nemohou být v SP používané, i toto musí být validováno.

    Pro vstupy, které použité být mohou, potřebuje mít SP logika přístup
    k jejich soukromým klíčům, které však peněženka nemusí mít k dispozici,
    jsou-li její klíče uložené v hardwarovém podpisovém zařízení. Baker
    popisuje schéma, které by plátci umožnilo vytvořit SP výstupní skript bez
    soukromého klíče, avšak hrozí s ním možnost úniku soukromého klíče,
    implementace v hardwarových podpisových zařízeních se tedy zřejmě neuskuteční.

  - **Utracení dříve obdržených SP výstupů:** PSBT budou must obsahovat
    sdílený tajný kód, který se používá k tweaknutí klíče pro utracení.
    Může se jednat o nové PSBT pole.

  Diskuze v době psaní nadále probíhala.

- **Návrh BIPu pro miniscript:** Ava Chow zaslala do emailové skupiny Bitcoin-dev
  [příspěvek][chow miniscript] s [návrhem BIPu][chow bip] pro [miniscript][topic
  miniscript], jazyk, který může být převeden do bitcoinového Scriptu, který ale
  umožňuje kompozici, práci se šablonami a konečnou analýzu. Návrh BIPu je odvozen
  z dlouhotrvající webové stránky miniscriptu a měl by odpovídat existujícím
  implementacím miniscriptu pro P2WSH witness skripty i pro P2TR [tapscript][topic
  tapscript].

- **Navázaná hodnota kanálu:** Tony Klausing zaslal do fóra Delving Bitcoin
  [příspěvek][klausing stable] s návrhem a doprovodným [kódem][klausing code]
  _stabilních kanálů_. Představme si, že Alice chce držet množství bitcoinů
  odpovídající 1 000 dolarům. Bob je ochoten to garantovat, ať již z důvodu očekávání
  nárůstu hodnoty BTC nebo protože mu Alice platí (nebo oboje). Otevřou spolu LN
  kanál a každou minutu provedou následující operace:

  - Oba zkontrolují stejné zdroje kurzu mezi BTC a USD.

  - Zvýší-li se hodnota BTC, Alice sníží svůj bitcoinový zůstatek, dokud
    není roven 1 000 dolarům (nadbytek pošle Bobovi).

  - Sníží-li se hodnota BTC, Bob pošle Alici dostatečné množství BTC,
    dokud není její zůstatek opět roven 1 000 dolarům.

  Cílem je, aby k aktualizacím zůstatků docházelo dostatečně často na to,
  aby byla změna ceny pod náklady na uzavření kanálu znevýhodněnou stranou.
  Tato strana by tak byla motivována, aby jednoduše zaplatila a pokračovala dále.

  Klausing se domnívá, že by někteří obchodníci mohli upřednostňovat tento vztah s
  požadavkem na minimální důvěru před kustodiálním trhem s futures. Dále navrhuje,
  že by mohl být používán jako základ pro banku, která vydává [ecash][topic ecash]
  denominovaný v dolarech. Toto schéma by fungovalo s jakýmkoliv aktivem, pro nějž
  by mohla být určena tržní cena.

## Změny ve službách a klientech

*V této měsíční rubrice upozorňujeme na zajímavé aktualizace bitcoinových
peněženek a služeb.*

- **Zdroje k tichým platbám:**
  Bylo ohlášeno několik nových zdrojů na téma [tiché platby][topic silent payments] včetně
  informační webové stránky [silentpayments.xyz][sp website], [dvou][bi
  ts sp] typescriptových [knihoven][bw ts sp], [backendu][gh blindbitd] založeného na Go,
  [webové peněženky][gh silentium] a [dalších][sp website devs]. Doporučujeme opatrnost, neboť
  většina tohoto software je nová, v beta verzi či v aktivním vývoji.

- **Cake Wallet přidává tiché platby:**
  [Cake Wallet][cake wallet website] nedávno [ohlásila][cake wallet
  announcement], že její nejnovější beta verze podporuje tiché platby.

- **Ověření konceptu coinjoinu bez koordinátora:**
  [Emessbee][gh emessbee] je ověřením konceptu pro vytváření [coinjoinových][topic coinjoin]
  transakcí bez ústředního koordinátora.

- **OCEAN přidává podporu pro BOLT12:**
  Těžební pool OCEAN používá jako součást svého řešení [výplat po LN][ocean docs]
  [podepsané zprávy][topic generic signmessage] pro propojení bitcoinové adresy a
  [BOLT12 nabídky][topic offers].

- **Coinbase přidává podporu pro Lightning:**
  [Coinbase přidal][coinbase blog] podporu pro lightningové vklady a výběry za pomoci
  lightningové infrastruktury od [Lightspark][lightspark website].

- **Ohlášeny nástroje pro bitcoinová svěřenectví:**
  Tým [BitEscrow][bitescrow website] ohlásil sadu [vývojových nástrojů][bitescrow docs]
  pro implementování nekustodiálních bitcoinových svěřenectví třetí stranou (escrow).

- **Block žádá těžařskou komunitu o zpětnou vazbu:**
  V [aktualizaci][block blog] o vývoji svého 3nm čipu vyzývá Block těžařskou komunitu
  o poskytnutí zpětné vazby mimo jiné k funkcím software těžebního hardware a údržbě.

- **Vydána peněženka Sentrum:**
  [Sentrum][gh sentrum] je peněženka umožňující pouze sledování (watch-only), která podporuje
  různé kanály pro notifikace.

- **Stack Wallet přidává podporu pro FROST:**
  [Stack Wallet v2.0.0][gh stack wallet] přidává podporu pro FROST, schéma [prahového][topic threshold signature]
  vícenásobného elektronického podpisu, díky použití rustové knihovny Modular FROST.

- **Ohlášen nástroj pro zveřejňování transakcí:**
  [Pushtx][gh pushtx] je jednoduchý rustový program, který odesílá transakce přímo
  do bitcoinové P2P sítě.

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [Bitcoin Inquisition 27.0][] je nejnovějším hlavním vydáním tohoto forku Bitcoin Core
  navrženého pro testování soft forků a jiných významných změn protokolu na [signetu][topic
  signet]. Novinkou tohoto vydání je vynucování [OP_CAT][] dle specifikace v [BIN24-1][]
  a [BIP347][]. Dále byl přidán „do `bitcoin-util` nový příkaz `evalscript`, který může
  otestovat chování opkódu skriptu.” Odstraněna byla podpora pro `annexdatacarrier`
  a pseudo [dočasné anchory][topic ephemeral anchors] (viz zpravodaje [č. 244][news244
  annex] a [č. 248][news248 ephemeral]).

- [LND v0.18.0-beta.rc2][] je kandidátem na vydání příští hlavní verze této populární
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

- [Bitcoin Core #27101][] přináší podporu pro požadavky a odpovědi dle JSON-RPC 2.0.
  Server nově vždy vrátí HTTP 200 \"OK\", pokud nenastane chyba HTTP nebo není chybně formátovaný
  požadavek. Vrací buď pole `error` nebo `result`, nikdy však oboje. Jediný i dávkovaný
  požadavek používají stejný způsob nakládání s chybami. Není-li v těle požadavku specifikována
  verze 2.0, bude použit stávající protokol JSON-RPC 1.1.

- [Bitcoin Core #30000][] používá pro indexování záznamů v `TxOrphanage` `wtxid`
  namísto `txid`, aby mohl obsahovat skupinu transakcí se stejným `txid`.
  Sirotčinec (orphanage) je prostor s omezenou velikostí, který Bitcoin Core
  používá k ukládání transakcí odkazující na rodičovské transakce, ke kterým
  aktuálně nemá Bitcoin Core přístup. Přijme-li později odkazovanou rodičovskou transakci,
  může tohoto potomka dále zpracovat. Příležitostné [přijetí balíčku][topic package relay]
  s jedním rodičem a jedním potomkem (1p1c) pošle nejdříve potomka (v očekávání, že
  bude uložen v sirotčinci) a nato pošle rodiče; díky tomu je možné zvážit jejich
  poplatek dohromady.

  Avšak když byl kód příležitostného 1p1c začleněn (viz [zpravodaj č. 301][news301 bcc28970]),
  bylo známo, že může útočník čestnému uživatelovi zabránit v používání této
  možnosti tím, že zveřejní verzi potomka transakce s nevalidními daty ve witnessu.
  Tento znetvořený potomek by měl stejné txid jako čestný potomek, ale neprošel
  by po přijetí rodiče validací. Kvůli tomu by nemohl potomek přispět na poplatek
  ([CPFP][topic cpfp]), který by byl nutný pro akceptování balíčku.

  Jelikož byly dříve transakce v sirotčinci indexovány pomocí txid, byla v sirotčinci
  uložena první přijatá verze transakce s konkrétním txid. Útočník, který byl
  schopen zveřejnit transakce rychleji a častěji než čestný uživatel, tak mohl čestného
  uživatele donekonečna blokovat. Po této změně může být přijato více transakcí se
  shodnými txid, které se však liší v obsahu witnessu a generují tak odlišná wtxid.
  V okamžiku přijetí rodičovské transakce má uzel dostatek informací na odstranění
  znetvořeného potomka a může tak akceptovat potomka validního. Toto PR bylo dříve
  diskutováno v PR Review Clubu shrnutém ve [zpravodaji č. 301][news301 prclub].

- [Bitcoin Core #28233][] stavějící na [#17487][bitcoin core #17487] odstraňuje
  každodenní periodické zapisování na disk a čistění mezipaměti horkých mincí (UTXO).
  Před #17487 snižovalo časté zapisování na disk riziko, že by bylo po pádu uzlu či
  hardwaru nutné podstoupit zdlouhavý process obnovy indexu. Po #17487
  mohou být nová UTXO zapsána na disk bez nutnosti vyprázdnění mezipaměti
  (ta i nadále musí být vyprázdněna v případě nedostatku paměti). Horká
  mezipaměť ve výchozím nastavení téměř zdvojnásobuje rychlost validace bloku,
  vyšších rychlostí je možné dosáhnout alokováním dodatečné paměti.

- [Core Lightning #7304][] přidává řešení pro situace, kdy `invoice_requests` nemůže
  nalézt cestu k uzlu určenému v `reply_path`. Démon `connectd` otevře k dotyčnému uzlu
  dočasné TCP/IP spojení a doručí [onion zprávu][topic onion messages] obsahující
  fakturu. Tato změna navyšuje interoperabilitu s LDK a navíc umožňuje používat onion
  zprávy i v situacích, kdy jsou podporovány pouze několika málo uzly (viz [zpravodaj č. 283][news283
  ldk2723]).

- [Core Lightning #7063][] činí bezpečnostní multiplikátor poplatků dynamickým, aby lépe
  odrážel předpokládané nárůsty poplatků. Multiplikátor se snaží zajistit, aby transakce
  platily dostatečně vysoké poplatky na dosažení včasné konfirmace, ať napřímo (u transakcí,
  jejichž poplatky nemohou být navýšeny později) či pomocí navyšování poplatků. Multiplikátor
  nyní začíná na dvojnásobku aktuálního [odhadu][topic fee estimation] v době nízkých poplatků
  (1 sat/vbyte) a s poplatky blížícími se k `maxfeerate` se postupně snižuje až na 1,1násobek.

- [Rust Bitcoin #2740][] přidává do modulu `pow` funkci `from_next_work_required`, která z předaného
  `CompactTarget` (předchozí cíl složitosti), `timespan` (časový rozdíl mezi aktuálním a předchozími
  bloky) a `Params` (parametry sítě) vypočítá nový `CompactTarget` představující příští cíl složitosti.
  Algoritmus implementovaný touto funkcí je založen `pow.cpp` z Bitcoin Core.

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when="2024-05-27 14:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="27101,30000,28233,7304,7063,2740,1117,868,17487" %}
[lnd v0.18.0-beta.rc2]: https://github.com/lightningnetwork/lnd/releases/tag/v0.18.0-beta.rc2
[kc upchan]: https://delvingbitcoin.org/t/upgrading-existing-lightning-channels/881
[tuttle poolcash]: https://delvingbitcoin.org/t/ecash-tides-using-cashu-and-stratum-v2/870
[corallo pooldelay]: https://delvingbitcoin.org/t/ecash-tides-using-cashu-and-stratum-v2/870/14
[corallo sv2 proposal]: https://github.com/stratum-mining/sv2-spec/discussions/76#discussioncomment-9472619
[baker psbtsp]: https://delvingbitcoin.org/t/bip352-psbt-support/877
[toth psbtsp]: https://gist.github.com/andrewtoth/dc26f683010cd53aca8e477504c49260
[chow miniscript]: https://mailing-list.bitcoindevs.xyz/bitcoindev/0be34bd2-637b-44b1-a0d5-e0ad5812d505@achow101.com/
[chow bip]: https://github.com/achow101/bips/blob/miniscript/bip-miniscript.md
[klausing stable]: https://delvingbitcoin.org/t/stable-channels-peer-to-peer-dollar-balances-on-lightning/875
[klausing code]: https://github.com/toneloc/stable-channels/
[news244 annex]: /cs/newsletters/2023/03/29/#bitcoin-inquisition-22
[news248 ephemeral]: /cs/newsletters/2023/04/26/#bitcoin-inquisition-23
[Bitcoin Inquisition 27.0]: https://github.com/bitcoin-inquisition/bitcoin/releases/tag/v27.0-inq
[news301 prclub]: /cs/newsletters/2024/05/08/#bitcoin-core-pr-review-club
[news301 bcc28970]: /cs/newsletters/2024/05/08/#bitcoin-core-28970
[news283 ldk2723]: /cs/newsletters/2024/01/03/#ldk-2723
[sp website]: https://silentpayments.xyz/
[bi ts sp]: https://github.com/Bitshala-Incubator/silent-pay
[bw ts sp]: https://github.com/BlueWallet/SilentPayments
[gh blindbitd]: https://github.com/setavenger/blindbitd
[gh silentium]: https://github.com/louisinger/silentium
[sp website devs]: https://silentpayments.xyz/docs/developers/
[cake wallet website]: https://cakewallet.com/
[cake wallet announcement]: https://twitter.com/cakewallet/status/1791500775262437396
[gh emessbee]: https://github.com/supertestnet/coinjoin-workshop
[coinbase blog]: https://www.coinbase.com/blog/coinbase-integrates-bitcoins-lightning-network-in-partnership-with
[lightspark website]: https://www.lightspark.com/
[block blog]: https://www.mining.build/latest-updates-3nm-system/
[gh sentrum]: https://github.com/sommerfelddev/sentrum
[ocean docs]: https://ocean.xyz/docs/lightning
[bitescrow website]: https://www.bitescrow.app/
[bitescrow docs]: https://www.bitescrow.app/dev
[gh stack wallet]: https://github.com/cypherstack/stack_wallet/releases/tag/build_222
[gh pushtx]: https://github.com/alfred-hodler/pushtx
