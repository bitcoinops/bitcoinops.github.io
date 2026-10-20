---
title: 'Zpravodaj „Bitcoin Optech” č. 402'
permalink: /cs/newsletters/2026/04/24/
name: 2026-04-24-newsletter-cs
slug: 2026-04-24-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Zpravodaj tento týden popisuje práci Hornet Node na deklarativní spustitelné
specifikaci pravidel konsenzu a shrnuje diskuzi o zahlcování onion zprávami
v lightningové síti. Též nechybí naše pravidelné rubriky s vybranými
otázkami a odpověďmi z Bitcoin Stack Exchange, s oznámeními nových vydání
a s popisem významných změn v populárním bitcoinovém páteřním software.

## Novinky

- **Hornet Node a deklarativní specifikace pravidel bitcoinového konsenzu**:
  Toby Sharp zaslal do [fóra][topic hornet update] Delving Bitcoin a do
  [emailové skupiny][hornet ml post] Bitcoin-Dev příspěvek o aktualizaci projektu Hornet.
  Sharp [dříve][topic hornet] popsal novou implementaci uzlu, která snížila čas
  úvodního stahování bloků ze 167 minut na 15 minut. V této aktualizaci představuje
  dokončení deklarativní specifikace pravidel validace neskriptových objektů bloku
  sestávající se z 34 sémantických neměnných kombinovaných pomocí jednoduché
  algebry.

  Sharp dále nastínil budoucí práci, včetně rozšíření specifikace o validaci
  skriptů, a diskutoval možné porovnání s implementacemi, jako je libbitcoin,
  v odpovědi na zpětnou vazbu od Erica Voskuila.

- **Zahlcování lightningové sítě onion zprávami**: Erick Cestari zaslal do fóra
  Delving Bitcoin [příspěvek][onion del] o problému zahlcování lightningové sítě
  [onion zprávami][topic onion messages] (onion message jamming). BOLT4 přiznává, že
  jsou onion zprávy nespolehlivé, a doporučuje implementacím používat techniky
  omezování rychlosti. Dle Cestariho jsou právě tyto techniky tím, co zahlcování umožňuje.
  Útočníci mohou rozběhnout škodící uzly a zahltit síť nevyžádanými zprávami, které aktivují
  omezení rychlosti u peer spojení, čímž je donutí zahazovat legitimní zprávy.
  BOLT4 navíc nevynucuje maximální délku zprávy, což útočníkům umožňuje
  maximalizovat dosah jediné zprávy.

  Cestari prozkoumal několik opatření proti zahlcování onion zprávami a poskytl
  přehled technik, které jsou dle něj vhodné:

  - *Poplatky předem*: Tuto techniku poprvé navrhla Carla Kirk-Cohen v [BOLTs #1052][]
    jako řešení zahlcování kanálů, avšak může být snadno rozšířena. Uzly by inzerovaly
    pevný poplatek za zprávu, který by byl zaplacen každému skoku. Pokud by poplatek
    zaplacen nebyl, zpráva by byla zahozena. Metoda má několik omezení, jako
    schopnost přeposílat zprávy pouze spojením kanálu a zvýšený P2P provoz.

  - *Omezení skoků a přeposílání na základě podílu v kanálu*: Tuto techniku
    [navrhli][mitig2 onion] Bashiri a Khabbazian. Sestává ze dvou komponent:

    - Omezení počtu skoků: Buď nastavení maximálního počtu skoků, které může zpráva
      provést (např. tři skoky), nebo vyřešení hádanky s proof of work, jejíž
      náročnost se zvyšuje exponenciálně s počtem skoků.

    - Síla přeposílání na základě podílu: Každý uzel nastaví pro spojení
      omezení rychlosti na základě zůstatku kanálu (proof of stake), čímž
      dostanou dobře financované uzly více možnosti přeposílání.

    Tento přístup přijímá některé kompromisy vztažené k centralizačnímu tlaku,
    jelikož staví velké uzly do výhody a omezení na tři skoky by mohlo snížit
    anonymizační množinu.

  - *Placení za přenosové pásmo*: Tato technika (bandwidth metered payment),
    kterou [navrhl][mitig3 onion] Olaoluwa Osuntokun, je podobná poplatkům předem,
    avšak přidává pro každé sezení stav a urovnává přes [AMP platby][topic amp].
    Odesílatel by nejdříve poslal AMP platbu, jejíž poplatek se každým krokem snižuje
    a která doručí identifikátor sezení. Odesílatel by dále přiložil tento identifikátor
    do onion zprávy. Známá omezení tohoto přístupu se vztahují k schopnosti
    přeposílat zprávy pouze spojením kanálu a k možnosti spojit všechny zprávy
    do stejného sezení.

  - *Rychlostní limit založený na zpětné propagaci*: Tento přístup [navrhl][mitig4 onion] Bastien Teinturier.
    Používá backpressure, který je statisticky schopen vysledovat spam k jeho zdroji.
    Když peer spojení dosáhne rychlostního limitu, pošle uzel drop zprávu odesílateli, který ji nato
    přepošle poslednímu spojení, které původní zprávu přeposlalo. Tím sníží rychlostní
    limit na polovinu. Původní odesílatel je identifikován statisticky, penalizován by tak
    mohl být nesprávný peer. Navíc by útočník mohl falšovat drop zprávy a snižovat rychlostní
    limity poctivých uzlů.

  Nakonec Cestari vyzval LN vývojáře k diskuzi. Dodal, že stále je čas pro opatření,
  než vážné DDoS zasáhnou síť, jako se nedávno [stalo Toru][tor issue].

## Vybrané otázky a odpovědi z Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] je jedním z prvních míst, kde hledají
přispěvatelé Optechu odpovědi na své otázky a kde – najdou-li volnou chvíli –
pomáhají zvědavým či zmateným uživatelům. V této měsíční rubrice nabízíme
některé z otázek a odpovědí, které obdržely vysoký počet hlasů.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Proč BIP342 nahradil CHECKMULTISIG novým opkódem, místo aby z něj pouze odstranil FindAndDelete?]({{bse}}130665)
  Pieter Wuille vysvětluje, že nahrazení `OP_CHECKMULTISIG` opkódem
  `OP_CHECKSIGADD` v [tapscriptu][topic tapscript] bylo nutné pro dávkové
  ověřování [Schnorrových][topic schnorr signatures] podpisů (viz
  [zpravodaj č. 46][news46 batch], _angl._) v případné budoucí změně protokolu.

- [Zavazuje SIGHASH_ANYPREVOUT haši listu nebo celé taprootové Merkleově cestě?]({{bse}}130637)
  Antoine Poinsot potvrzuje, že podpisy se [SIGHASH_ANYPREVOUT][topic sighash_anyprevout]
  aktuálně zavazují pouze haši listu (tapleaf), ne celé Merkleově cestě v [taprootovém][topic taproot]
  stromu. Avšak tento design je právě předmětem diskuze, neboť jeden spoluautor
  BIPu navrhl raději zavazovat celé cestě.

- [Co kromě formátu adresy zaručuje tweak dle BIP86 v MuSig2 lightningovém kanálu?]({{bse}}130652)
  Ava Chow vysvětluje, že tweak brání používání skrytých větví skriptu,
  protože protokol podepisování v [MuSig2][topic musig] požaduje, aby všichni účastníci
  aplikovali stejný tweak ([BIP86][]), jinak agregace podpisů selže. Pokud by
  se jedna strana pokusila použít odlišný tweak, např. tweak odvozený ze skryté
  větve skriptu, jejich částečný podpis by se do validního konečného podpisu
  nepřidal.

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [Bitcoin Core 31.0][] je novým vydáním hlavní verze této převládající implementace
  plného uzlu. [Poznámky k vydání][notes31] popisují několik významných vylepšení,
  včetně implementace [mempoolu clusterů][topic cluster mempool], nové volby
  `-privatebroadcast` pro `sendrawtransaction` (viz [zpravodaj č. 388][news388 private]),
  dat `asmap` volitelně přidaných do binárky pro ochranu před [útoky zastíněním][topic eclipse
  attacks] a navýšení výchozí hodnoty `-dbcache` na 1024 MiB na systémech
  s více než 4096 MiB paměti.

- [Core Lightning 26.04][] je hlavním vydáním této populární implementace
  LN uzlu. Přináší ve výchozím nastavení aktivní [splicing][topic splicing],
  nové příkazy `splicein` a `spliceout` včetně režimu `cross-splice`,
  který použije druhý kanál jako  cíl pro splice out, předělaný design
  `bkpr-report` pro souhrn příjmů, paralelní hledání cest a opravy několika
  chyb v `askrene`, přidává do RPC `offer` a nastavení `payment-fronting-node`
  volbu `fronting_nodes` a odstraňuje podporu pro zastaralý formát onionu.
  [Poznámky k vydání][notes cln] popisují další podrobnosti.

- [LND 0.21.0-beta.rc1][] je prvním kandidátem na vydání příští hlavní verze
  tohoto populárního LN uzlu. Uživatelé provozující uzly s příznakem
  `--db.use-native-sql` s SQLite nebo PostgreSQL by měli vědět, že
  tato verze migruje úložiště plateb z key-value formátu na nativní SQL
  (s možností přeskočit migraci volbou `--db.skip-native-sql-migration`).
  Viz též [poznámky k vydání][notes lnd].

## Významné změny kódu a dokumentace

_Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo] a [repozitáři BINANA][binana repo]._

- [Bitcoin Core #33477][] mění, jak režim `rollback` RPC příkazu `dumptxoutset`
  (viz [zpravodaj č. 72][news72 dump], _angl._) sestavuje export množiny
  historických UTXO používaných pro [assumeUTXO][topic assumeutxo] snapshoty.
  Namísto vrácení hlavního stavu (chainstate) pomocí invalidace bloků nově
  Bitcoin Core vytvoří dočasnou UTXO databázi, vrátí ji na požadovanou výšku
  a vytvoří snapshot z této dočasné databáze. Tím je hlavní stav zachován
  a není třeba pozastavit síťovou aktivitu ani riskovat potíže s větvením řetězce.
  Cenou je dodatečný prostor na disku a pomalejší proces exportování.
  Nová volba `in_memory` bude držet dočasnou UTXO databázi pouze v paměti.
  To zvýší rychlost za cenu mít k dispozici více než 10 GB (na mainnetu) volné paměti.
  Pro práci s větší hloubkou je doporučeno nepoužívat RPC timeout (`bitcoin-cli
  -rpcclienttimeout=0`), neboť operace může trvat několik minut.

- [Bitcoin Core #35006][] přidává do `bitcoin-cli` volbu `-rpcid`, která
  nastaví daný řetězec jako `id` v JSON-RPC žádosti namísto pevně dané hodnoty
  `1`. Tím mohou být žádosti a odpovědi korelované během více paralelních
  volání. Identifikátor je také zapsán do serverového logu.

- [BIPs #1895][] zveřejňuje [BIP361][], který představuje abstraktní návrh
  na [postkvantovou][topic quantum resistance] migraci a ukončení zastaralých
  podpisů. Za předpokladu, že je standardizováno a nasazeno nějaké postkvantové (PQ)
  schéma podpisů, tento návrh předkládá migraci z ECDSA/[Schnorra][topic
  schnorr signatures] v několika fázích. Současná verze návrhu je rozdělena
  do dvou fází. Fáze A zakazuje posílat prostředky na kvantově zranitelné
  adresy, čímž urychlí používání PQ adres. Fáze B omezuje utrácení ECDSA/Schnorra
  vnuceným kvantově bezpečným záchranným protokolem, který by krádeži kvantově
  zranitelných UTXO zabránil.

- [BIPs #2142][] přidává do [BIP352][], návrhu na [tiché platby][topic silent
  payments], testovací data pro odeslání a přijímání v krajním případě, kdy
  průběžný součet vstupních klíčů dosáhne po dvou vstupech nuly, i když
  celkový součet všech vstupů je nenulový. Tato data zachytí případ, kdy
  implementace ukončí výpočet příliš brzy.

- [LDK #4555][] opravuje, jak přeposílající uzly vynucují [`max_cltv_expiry`][topic
  cltv expiry delta] u [zaslepených platebních cest][topic rv routing].
  Toto pole má zajistit, aby byly expirované zaslepené cesty odmítnuté
  úvodním skokem a nebyly přeposlané zaslepeným segmentem. Dříve LDK tuto hodnotu
  porovnávalo s výchozí CLTV hodnotou skoku, nově kontroluje příchozí.

- [LND #10713][] přidává omezení rychlosti, globální a na spojení, příchozích
  [onion zpráv][topic onion messages]. Nadměrný provoz se zahodí hned na začátku,
  ještě před zpracováním zprávy. Tím se navýší robustnost nedávno přidané podpory
  přeposílání onion zpráv (viz [zpravodaj č. 396][news396 lnd onion]) s lepší
  ochranou proti zneužití. Omezení mají stejné hodnoty jako dříve představené
  limit gossip zpráv (viz [zpravodaj č. 370][news370 lnd gossip], _angl._).

- [LND #10754][] přestává přeposílat [onion message][topic onion messages], pokud
  je zvolený příští skok stejné peer spojení, které zprávu doručilo.

{% include snippets/recap-ad.md when="2026-04-28 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="1052,33477,35006,4555,10713,10754,1895,2142" %}
[news46 batch]: /en/newsletters/2019/05/14/#new-script-based-multisig-semantics
[topic hornet update]: https://delvingbitcoin.org/t/hornet-update-a-declarative-executable-specification-of-consensus-rules/2420
[hornet ml post]: https://groups.google.com/g/bitcoindev/c/M7jyQzHr2g4
[topic hornet]: /cs/newsletters/2026/02/06/#paralelizovana-utxo-databaze-s-dotazy-v-konstantnim-casem
[onion del]: https://delvingbitcoin.org/t/onion-message-jamming-in-the-lightning-network/2414
[mitig2 onion]: https://ualberta.scholaris.ca/items/245a6a68-e1a6-481d-b219-ba8d0e640b5d
[mitig3 onion]: https://diyhpl.us/~bryan/irc/bitcoin/bitcoin-dev/linuxfoundation-pipermail/lightning-dev/2022-February/003498.txt
[mitig4 onion]: https://diyhpl.us/~bryan/irc/bitcoin/bitcoin-dev/linuxfoundation-pipermail/lightning-dev/2022-June/003623.txt
[tor issue]: https://blog.torproject.org/tor-network-ddos-attack/
[Bitcoin Core 31.0]: https://bitcoincore.org/bin/bitcoin-core-31.0/
[notes31]: https://bitcoincore.org/en/releases/31.0/
[news388 private]: /cs/newsletters/2026/01/16/#bitcoin-core-29415
[Core Lightning 26.04]: https://github.com/ElementsProject/lightning/releases/tag/v26.04
[notes cln]: https://github.com/ElementsProject/lightning/releases/tag/v26.04
[LND 0.21.0-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.21.0-beta.rc1
[notes lnd]: https://github.com/lightningnetwork/lnd/blob/master/docs/release-notes/release-notes-0.21.0.md
[news72 dump]: /en/newsletters/2019/11/13/#bitcoin-core-16899
[news396 lnd onion]: /cs/newsletters/2026/03/13/#lnd-10089
[news370 lnd gossip]: /en/newsletters/2025/09/05/#lnd-10103
