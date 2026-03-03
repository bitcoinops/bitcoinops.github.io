---
title: 'Zpravodaj „Bitcoin Optech” č. 394'
permalink: /cs/newsletters/2026/02/27/
name: 2026-02-27-newsletter-cs
slug: 2026-02-27-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Zpravodaj tento týden nahlíží na návrh BIPu na přidání dodatečných informací
k deskriptorům výstupních skriptů. Též nechybí naše pravidelné rubriky
se souhrnem oblíbených otázek a odpovědí z Bitcoin Stack Exchange, oznámeními
nových vydání a popisem významných změn v populárním bitcoinovém páteřním
software.

## Novinky

- **Návrh BIPu na anotace deskriptorů výstupních skriptů**: Craig Raw
  zaslal do emailové skupiny Bitcoin-Dev [příspěvek][annot ml] o návrhu na nový BIP,
  který by měl řešit jeden z kritických bodů objevených během diskuze kolem BIP392
  (viz [zpravodaj č. 387][news387 sp]). Ten se týká vysokých nároků na zdroje
  během hledání prostředků z [tichých plateb][topic silent payments]. Dle Rawa
  by mohla dostupnost některých metadat (např. datum vzniku peněženky vyjádřené
  jako výška) proces zrychlit. Avšak tato metadata nejsou z technického hlediska pro
  stanovení výstupních skriptů nezbytná, nejsou proto vhodná pro přímé začlenění
  do deskriptoru.

  Rawův BIP navrhuje poskytnout užitečná metadata v anotacích vyjádřených jako klíč
  s hodnotou a připojených k deskriptoru ve stejném stylu jako v URL. Deskriptor
  s anotacemi by vypadal jako `SCRIPT?key=value&key=value#CHECKSUM`. Znaky
  `?`, `&` a `=` jsou již definovány [BIP380][], algoritmus kontrolního součtu
  by tedy žádnou změnu nevyžadoval.

  V [návrhu BIPu][annot draft] Raw definuje tři klíče, které by hledání prostředků
  zefektivnily:

  - Block Height `bh`: Výška bloku, ve kterém peněženka obdržela první platbu;

  - Gap Limit `gl`: Maximální počet odvozených nepoužitých adres v řadě;

  - Max Label `ml`: Pro peněženky podporující tiché platby: maximální index štítku ke skenování.

  Nakonec Raw poznamenal, že anotace by neměly být používané v běžných zálohách peněženek,
  ale pouze pro efektivnější obnovu prostředků bez nutnosti měnit skripty vytvořené
  z deskriptorů.

## Vybrané otázky a odpovědi z Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] je jedním z prvních míst, kde hledají
přispěvatelé Optechu odpovědi na své otázky a kde – najdou-li volnou chvíli –
pomáhají zvědavým či zmateným uživatelům. V této měsíční rubrice nabízíme
některé z otázek a odpovědí, které obdržely vysoký počet hlasů.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Vypadá bitcoinový v2 P2P transport dle BIP324 jako náhodná data?]({{bse}}130500)
  Pieter Wuille poznamenává, že protokol [v2 šifrovaného přenosu][topic v2 p2p transport]
  dle [BIP324][] podporuje shaping provozu, avšak žádný známý software tuto
  možnost neimplementuje. Dodává, že „dnešní implementace skrývají charakteristické
  znaky protokolu pouze v odeslaných bajtech, nikoliv v provozu.”

- [Co kdyby těžař zveřejnil pouze hlavičku a nikdy neposlal blok?]({{bse}}130456)
  Uživatel bigjosh nastiňuje, jak by se těžař mohl chovat, kdyby obdržel hlavičku
  bloku před jeho samotným obsahem: těžil by prázdný blok. Pieter Wuille
  dodává, že v praxi mnoho těžařů spatří hlavičky nových bloků sledováním,
  jakou práci ostatní pooly posílají svým těžařům. Tato technika je známá
  jako spy mining.

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [Bitcoin Core 28.4rc1][] je kandidátem na vydání údržbové aktualizace předchozí
  hlavní verze. Obsahuje hlavně opravy migrace peněženek a odstraňuje nespolehlivý
  DNS seed.

- [Rust Bitcoin 0.33.0-beta][] je beta vydáním této knihovny pro práci s bitcoinovými
  datovými strukturami. Jedná se o rozsáhlou aktualizaci s více než 300 změnami,
  které přináší nový balíček `bitcoin-consensus-encoding`, přidávají kódování
  P2P zpráv, během dekódování odmítají transakce s duplikovanými vstupy či se
  součtem výstupů přesahujícím `MAX_MONEY` a navyšují verze všech podbalíčků.

## Významné změny kódu a dokumentace

_Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo] a [repozitáři BINANA][binana repo]._

- [Bitcoin Core #34568][] přináší několik nekompatibilních změn do IPC
  rozhraní Mining (viz [zpravodaj č. 310][news310 mining]). Zastaralé
  metody `getCoinbaseRawTx()`, `getCoinbaseCommitment()` a
  `getWitnessCommitmentIndex()` (viz [zpravodaj č. 388][news388 mining])
  byly odstraněny, do `createNewBlock` a `checkBlock` byl přidán parametr
  `context`, aby mohly běžet v jiných vláknech a nemusely blokovat
  smyčku událostí [Cap'n Proto][capn proto], a ve schématu stanovuje
  výchozí hodnoty voleb. Číslo verze `Init.makeMining` bylo navýšeno,
  aby starší klienty namísto chybné interpretace nového schématu
  skončily jasnou chybou. Změna v práci s vlákny je předpokladem
  pro nadcházející možnost přidat prodlevu (cooldown) po úvodním
  stahování bloků.

- [Bitcoin Core #34184][] přidává do`createNewBlock()` v IPC rozhraní
  Mining volitelnou prodlevu (cooldown). Pokud je volba aktivována,
  bude metoda před vrácením šablony bloku vždy čekat na dokončení
  úvodního stahování bloků (IBD) a na aktuální vrchol řetězce.
  Pomůže to během startování zabránit zahlcování klientů
  [Stratum v2][topic pooled mining] šablonami, které se okamžitě
  stávají neplatnými. Též byla přidána metoda `interrupt()`,
  která IPC klientům umožní řádně přerušit blokující volání
  `createNewBlock()` a `waitTipChanged()`.

- [Bitcoin Core #24539][] přidává novou volbu `-txospenderindex`, která
  udržuje index transakcí utrácejících dané výstupy. Je-li volba aktivní,
  je návratová hodnota RPC volání `gettxspendingprevout` u potvrzených
  transakcí rozšířena o `spendingtxid` a `blockhash`. Dále byly do RPC
  přidány dvě volitelné volby: `mempool_only` omezuje hledání na mempool,
  i pokud je index dostupný, a `return_spending_tx` vrací kompletní
  utrácející transakci. Index nevyžaduje`-txindex` a není slučitelný
  s ořezáváním (pruning). Volby jsou obzvláště užitečné pro Lightning
  Network a jiné protokoly na druhé vrstvě, které potřebují sledovat
  posloupnosti utrácejících transakcí.

- [Bitcoin Core #34329][] přidává dvě nová RPC volání pro správu privátního
  způsobu zveřejňování transakcí (viz [zpravodaj č. 388][news388 private]):
  `getprivatebroadcastinfo` vrací informace o transakcích, které právě
  čekají ve frontě na privátní zveřejnění, včetně adresy zvoleného peer spojení
  a času odeslání, a `abortprivatebroadcast` přeruší zveřejňování dané transakce.

- [Bitcoin Core #28792][] završuje sérii o ASMap přidáním dat přímo do binárky
  Bitcoin Core. Uživatelé s aktivní volbou `-asmap` tak již nemusí data stahovat
  zvlášť. Sestavení data nepřibalí, pokud je odstraněna volba
  `WITH_EMBEDDED_ASMAP`. ASMap pomáhá chránit před [útokem zastíněním][topic
  eclipse attacks] (eclipse attack) rozprostřením peer spojení
  mezi různé autonomní systémy (viz též zpravodaje [č. 52][news52 asmap],
  _angl._, a [č. 290][news290 asmap]). Ve výchozím nastavení zůstává
  funkcionalita neaktivní, uživatel ji zapne volbou `-asmap`. Nový
  [dokumentační soubor][github asmap-data] ukazuje proces pořizování dat a
  jejich připojení do Bitcoin Core.

- [Bitcoin Core #32138][] odstraňuje RPC volání `settxfee` a spouštěcí volbu
  `-paytxfee`. Obě umožňovaly uživatelům nastavit statické jednotkové poplatky
  pro všechny transakce. Obě volby byly zastarané v Bitcoin Core 30.0 (viz
  [zpravodaj č. 349][news349 settxfee]). Uživatelé by namísto nich měli
  spoléhat na [odhadování poplatků][topic fee estimation] nebo nastavit
  poplatek pro každou transakci zvlášť.

- [Bitcoin Core #34512][] přidává do odpovědi na RPC volání `getblock`
  pole `coinbase_tx` (pouze s verbosity 1 nebo větší). Pole obsahuje data
  mincetvorné transakce: `version`, `locktime`, `sequence`, `coinbase` skript
  a `witness` data. Výstupy jsou záměrně vynechány, aby nebyla zpráva
  příliš velká. Dříve vyžadoval přístup k těmto vlastnostem
  verbosity úrovně 2, která dekóduje každou transakci v bloku. Tato
  novinka je užitečná pro monitorování požadavků na locktime mincetvorných
  transakcí dle [BIP54][] ([pročištění konsenzu][topic consensus cleanup])
  nebo pro rozpoznání těžebního poolu z coinbase skriptu.

- [Core Lightning #8490][] přidává novou konfigurační volbu `payment-fronting-node`,
  která specifikuje jeden nebo více uzlů, které budou vždy používány
  jako vstupní body příchozích plateb. Pokud je volba nastavena, budou návrhy tras
  (route hints) v [BOLT11][] fakturách a úvodní body [zaslepených cest][topic
  rv routing] v [BOLT12][topic offers] nabídkách, fakturách a žádostech
  o fakturu konstruovány pouze s těmito předsunutými uzly.
  Dříve CLN automaticky vybralo jeden uzel, čímž mohlo napříč více fakturami
  odhalit různá peer spojení. Volbu lze zapnout globálně nebo pro konkrétní
  nabídku.

- [Eclair #3250][] umožňuje, aby `OpenChannelInterceptor` během
  otevírání kanálu automaticky zvolil `channel_type`, pokud nebyl již explicitně nastaven.
  Dříve automatická tvorba kanálu (např. když LSP otevíral ke klientům kanál)
  selhala, pokud nebyl druh kanálu poskytnut. Současné nastavení upřednostňuje
  [anchor kanály][topic anchor outputs]. Očekává se, že v následných PR
  dostanou [jednoduché taprootové kanály][topic simple taproot channels]
  přednost.

- [LDK #4373][] přidává podporu pro posílání [plateb s více cestami][topic
  multipath payments] (multipath payments, MPP), kde místní uzel platí pouze
  část celkové částky. Nové pole `total_mpp_amount_msat`
  v `RecipientOnionFields` umožňuje stanovit celkovou částku MPP vyšší,
  než kolik uzel odesílá, čímž může na zaplacení jedné faktury dílčími platbami
  spolupracovat více peněženek nebo uzlů. Příjemce HTLC posbírá od všech
  přispěvatelů a po obdržení kompletní částky platbu nárokuje. Podpora pro
  [BOLT12][topic offers] je ponechána pro následná PR.

- [BDK #2081][] přidává do `SpkTxOutIndex` a `KeychainTxOutIndex` metody
  `spent_txouts()` a `created_txouts()`, které pro danou transakci
  vrátí, které sledované výstupy utrácí a které výstupy nově sleduje.
  To umožní peněženkám snadno určit adresy a částky z transakcí, o které
  se zajímají.

{% include snippets/recap-ad.md when="2026-03-03 17:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="34568,34184,24539,34329,28792,32138,34512,8490,3250,4373,2081" %}

[annot ml]: https://groups.google.com/g/bitcoindev/c/ozjr1lF3Rkc
[news387 sp]: /cs/newsletters/2026/01/09/#navrh-bipu-pro-deskriptory-tichych-plateb
[annot draft]: https://github.com/craigraw/bips/blob/descriptorannotations/bip-descriptorannotations.mediawiki
[news310 mining]: /cs/newsletters/2024/07/05/#bitcoin-core-30200
[news388 mining]: /cs/newsletters/2026/01/16/#bitcoin-core-33819
[news388 private]: /cs/newsletters/2026/01/16/#bitcoin-core-29415
[capn proto]: https://capnproto.org/
[news52 asmap]: /en/newsletters/2019/06/26/#differentiating-peers-based-on-asn-instead-of-address-prefix
[news290 asmap]: /cs/newsletters/2024/02/21/#vylepseny-proces-opakovatelneho-sestavovani-asmap
[github asmap-data]: https://github.com/bitcoin/bitcoin/blob/master/doc/asmap-data.md
[news349 settxfee]: /cs/newsletters/2025/04/04/#bitcoin-core-31278
[Bitcoin Core 28.4rc1]: https://bitcoincore.org/bin/bitcoin-core-28.4/test.rc1/
[Rust Bitcoin 0.33.0-beta]: https://github.com/rust-bitcoin/rust-bitcoin/releases/tag/bitcoin-0.33.0-beta
