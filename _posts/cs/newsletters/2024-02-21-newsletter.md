---
title: 'Zpravodaj „Bitcoin Optech” č. 290'
permalink: /cs/newsletters/2024/02/21/
name: 2024-02-21-newsletter-cs
slug: 2024-02-21-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Zpravodaj tento týden popisuje návrh na poskytování čitelných bitcoinových
platebních instrukcí založených na DNS, shrnuje příspěvek s úvahou o
mempoolu a souladu ekonomických podnětů, odkazuje na vlákno s diskuzí
o designu Cashu a dalších ecashových systémů, krátce nahlíží na
pokračující diskuzi o 64bitové aritmetice v bitcoinových skriptech
(včetně specifikace již dříve navrženého opkódu) a poskytuje přehled
vylepšeného procesu reprodukovatelné tvorby ASMap. Též nechybí naše
pravidelné rubriky s popisem aktualizací klientů a služeb, nových
vydání a významných změn v populárních bitcoinových páteřních projektech.

## Novinky

- **Čitelné bitcoinové platební instrukce založené na DNS:** v návaznosti
  na předchozí diskuzi (viz [zpravodaj č. 278][news278 dns]) zaslal Matt
  Corallo do fóra Delving Bitcoin [příspěvek][corallo dns] s [návrhem BIPu][dns
  bip], díky kterému bude možné přeložit řetězce jako `example@example.com`
  na DNS adresu jako například `example.user._bitcoin-payment.example.com`,
  která vrátí TXT záznam podepsaný [DNSSEC][] obsahující URI dle [BIP21][],
  např. `bitcoin:bc1qexampleaddress0123456`. BIP21 URI mohou být
  rozšířené o podporu několika protokolů (viz [BIP70 platební protokoly][topic
  bip70 payment protocol]); například následující TXT záznam by určoval
  [bech32m][topic bech32] adresu jako alternativu pro jednoduché onchain
  peněženky, adresu [tiché platby][topic silent payments] pro onchain
  peněženky s patřičnou podporou a LN [nabídku][topic offers] pro LN
  peněženky:

  ```text
  bitcoin:bc1qexampleaddress0123456?sp=sp1qexampleaddressforsilentpayments0123456&b12=lno1qexampleblindedpathforanoffer...
  ```

  Návrh BIPu neobsahuje podrobnosti ohledně podporovaných platebních protokolů.
  Corallo má dva další návrhy: [BOLT][dns bolt] a [BLIP][dns BLIP] popisující
  detaily pro LN uzly. BOLT umožňuje vlastníkovi domény nastavit wildcard
  záznam jako `*.user._bitcoin-payment.example.com`, který se přeloží
  na BIP21 URI s parametrem `omlookup` obsahujícím zaslepenou cestu k uzlu,
  který po přijetí [onion zprávy][topic onion messages] vrátí BOLT12 nabídku.
  Plátce, který by chtěl poslat nabídku na `example@example.com`, potom
  tomuto uzlu předá identifikátor příjemce (`example`) a tím bude moci uzel
  platbu řádně zpracovat. BLIP popisuje možnost, jak by mohl kterýkoliv LN
  uzel bezpečně tyto platební instrukce přeložit pro kterýkoliv jiný
  uzel pomocí komunikačního protokolu LN.

  V době psaní zpravodaje byla většina diskuze vedena pod [PR v BIP repozitáři][bips
  #1551]. Jeden příspěvek navrhoval použít HTTPS, které může být pro
  mnoho webových vývojářů přístupnější, ale vyžadovalo by dodatečné
  závislosti; Corallo řekl, že tuto část specifikace měnit nebude, ale napsal
  [malou knihovnu][dnssec-prover] s [ukázkovou webovou stránkou][dns demo],
  která za webové vývojáře vše vyřeší. Další příspěvek navrhoval použít
  existující systém překladu platebních adres založený na DNS [OpenAlias][],
  který je již podporován některým bitcoinovým software, např. Electrum.
  Dalším diskutovaným tématem byl způsob, jak adresy zobrazovat: mělo
  by to být `example@example.com`, `@example@example.com`, `example$example.com`
  či jinak?

- **Úvaha o mempoolu a souladu ekonomických podnětů:** Suhas Daftuar
  zaslal do fóra Delving Bitcoin [příspěvek][daftuar incentive] s několika
  pohledy na kritéria, která za účelem maximalizace zisku mohou plné uzly
  použít k výběru transakcí přidaných do svých mempoolů, přeposílaných dalším
  uzlům a pro těžbu. Příspěvek začíná základními principy a pokračuje až
  na hranici současného výzkumu. Přístupné popisy by měly být srozumitelné
  každému, kdo se zajímá o design pravidel pro přeposílání transakcí.
  Mezi postřehy, které jsou podle nás nejzajímavější, patří:

  - *Ryzí nahrazení jednotkovým poplatkem nezaručuje soulad ekonomických podnětů:*
	zdá se, že [nahrazení][topic rbf] transakce platící nižší jednotkový
	poplatek transakcí platící vyšší jednotkový poplatek by mělo být pro
	pro těžaře vždy výhrou. Daftuar poskytuje jednoduchý [ilustrovaný
	příklad][daftuar feerate rule] ukazující, že to tak nemusí vždy být.
	[Zpravodaj č. 288][news288 rbfr] obsahuje předešlou diskuzi o ryzím
	nahrazení jednotkovým poplatkem.

  - *Těžaři s různými hashrate mají různé priority:* těžař s 1 % hashrate
	celé sítě, který se vzdá začlenění konkrétní transakce do své šablony
	bloku a kterému se podaří nalézt blok, bude mít pouze 1% šanci na vytěžení
	následného bloku, který by mohl tuto transakci začlenit. Proto má
	malý těžař silný podnět k výběru co nejvyššího poplatky nyní, i za cenu
	výrazné redukce výše poplatku dostupného těžařům (i sobě samému) v budoucích
	blocích.

	V porovnání s ním bude mít těžař s 25 % hashrate, který se rozhodne
	nezačlenit transakci do bloku, 25% šanci na vytěžení následného
	bloku, který by mohl tuto transakci obsahovat. Pro tohoto velkého
	těžaře je výhodné odložit výběr některých poplatků na později, kdy
	mu to může s určitou pravděpodobností vynést vyšší poplatky.

	Daftuar nabízí [příklad][daftuar incompatible] dvou konfliktních
	transakcí. Menší transakce platí vyšší jednotkový poplatek, větší
	transakce platí vyšší absolutní poplatek. Pokud by nebylo v mempoolu
	mnoho transakcí s jednotkovým poplatkem podobným větší transakci,
	blok obsahující tuto transakci by přinesl těžařovi více na poplatcích
	než blok s menší transakcí (s vyšším jednotkovým poplatkem). Avšak
	pokud by bylo v mempoolu mnoho transakcí s podobným jednotkovým
	poplatkem, jako má větší transakce, pro těžaře s menším podílem na celkovém
	hashrate může být výhodnější vytěžit menší transakci (vyšší jednotkový
	poplatek), aby získal co nejvíce na poplatcích nyní, zatímco těžař
	s větším podílem na celkovém hashrate může být motivován vyčkat,
	až bude výdělečné vytěžit větší transakci (nižší jednotkový poplatek)
	nebo až se odesílatel unaví čekáním a vytvoří verzi s ještě vyšším
	jednotkovým poplatkem. Odlišné podněty pro různé těžaře mohou
	indikovat, že neexistuje jeden univerzální soubor pravidel pro
	soulad ekonomických podnětů.

  - *Bylo by užitečné nalézt pravidla souladu ekonomických podnětů, která nejsou odolná vůči DoS:*
	Daftuar popisuje, jak se Bitcoin Core snaží [implementovat][mempool series]
	pravidla, která jsou v souladu s ekonomickými podněty a zároveň
	jsou odolná vůči útokům odepření služby (DoS). Avšak poznamenává, že
	„zajímavou a hodnotnou oblastí výzkumu by bylo určit, zda-li existují
	(a pokud ano, charakterizovat je) chování v souladu s ekonomickým podněty,
	která nejsou odolná vůči DoS. Pokud existují, mohla by taková
	chování představovat podněty pro uživatele, aby se připojovali
	přímo k těžařům, což by mohlo být pro tyto strany vzájemně výhodné,
	ale celkově škodlivé pro decentralizaci těžby. […] Porozumění těmto
	scénářům by nám také mohlo pomoci během navrhování protokolů, které
	jsou odolné vůči DoS, jelikož bychom znali hranice možného.”

- **Diskuze o designu Cashu a dalších ecash systemů:** před několika týdny
  zaslal vývojář Thunderbiscuit do fóra Delving Bitcoin [příspěvek][thunderbiscuit
  ecash] s popisem [schématu zaslepených podpisů][blind signature scheme]
  stojícího za [chaumovským][Chaumian ecash] ecash systémem použitým
  v [Cashu][]. Tento systém používá satoshi jako jednotku zůstatků a
  umožňuje odesílat a přijímat peníze pomocí bitcoinu a LN. Vývojáři
  Moonsettler a Zmnscpxj tento týden ve svých odpovědích uvedli některá
  omezení této jednoduché verze zaslepeného podepisování a popsali,
  jak by alternativní protokoly mohly přinést další výhody. Diskuze
  se vedla zcela v teoretické úrovni, ale věříme, že by mohla být
  zajímavá pro každého se zájmem o ecashové systémy.

- **Pokračující diskuze o 64bitové aritmetice a opkódu `OP_INOUT_AMOUNT`:**
  několik vývojářů [pokračovalo v diskuzu][64bit discuss] o potenciálním
  budoucím soft forku, který by mohl do bitcoinu přidat 64bitové aritmetické
  operace (viz [zpravodaj č. 285][news285 64bit]). Většina diskuze se po naší
  předchozí zmínce soustředila na kódování 64bitových hodnot ve skriptech.
  Hlavním rozdílem je, zda používat formát minimalizující onchain data nebo
  formát co nejjednodušší pro programování. Dále se diskutovalo, zda používat
  celá čísla se znaménkem nebo povolit pouze celá čísla bez znaménka (pro neznalé,
  mezi které evidentně patří také jeden samozvaný brilantní bitcoinový inovátor:
  celá čísla se znaménkem indikují, jaké znaménko používají (kladné/záporné);
  celá čísla bez znaménka mohou být pouze kladná čísla nebo nula). Dále
  bylo uvažováno, zda umožnit pracovat s většími čísly, potenciálně až
  4160bitovými (což odpovídá 520 bytům, tedy současné maximální velikosti
  prvku bitcoinového zásobníku).

  Tento týden vytvořil Chris Stewart nové [vlákno][stewart inout]
  [s návrhem BIPu][bip inout] pro opkód původně navržený jako
  součást `OP_TAPLEAF_UPDATE_VERIFY` (viz [zpravodaj č. 166][news166 tluv],
  _angl._). Tento opkód `OP_INOUT_AMOUNT` přidá do zásobníku hodnotu
  aktuálního vstupu (což je hodnota výstupu, který utrácí) a hodnotu výstupu,
  který má stejný index jako tento vstup. Například má-li v transakci
  první vstup hodnotu 4 milióny sat, druhý vstup 3 milióny sat, první
  výstup platí 2 milióny sat a druhý výstup 1 milión sat, potom by
  `OP_INOUT_AMOUNT` spuštěn během vykonávání druhého vstupu přidal do
  zásobníku `3_000_000 1_000_000`. (Pokud chápeme návrh BIPu správně,
  bylo by to kódováno jako 64bitové celé číslo bez znaménka v little endian,
  tedy `0xc0c62d0000000000 0x40420f0000000000`). Pokud by byl opkód do bitcoinu
  přidán, výrazně by kontraktům usnadnil ověřování očekávaného rozsahu částek
  vstupů a výstupů, např. že uživatel vybral z [joinpoolu][topic joinpools]
  pouze částku, na kterou měl nárok.

- **Vylepšený proces opakovatelného sestavování ASMap:** Fabian Jahr
  zaslal do fóra Delving Bitcoin [příspěvek][jahr asmap] o vývoji ve vytváření mapy [autonomních
  systémů][autonomous systems] (ASMap, „map of autonomous systems”),
  které kontrolují routování po rozsáhlých částech internetu. Bitcoin Core
  se v současnosti pokouší udržovat spojení do různorodých podsítí globálního
  jmenného prostoru. Aby mohl útočník provést i ten nejjednodušší druh [útoku
  zastíněním][topic eclipse attacks] („eclipse attack”), potřeboval by získat
  IP adresy ve všech podsítích. Avšak někteří poskytovatelé internetového
  připojení (ISP) a hostingové služby kontrolují IP adresy ve více podsítích,
  což tuto ochranu oslabuje. Projekt ASmap má za cíl poskytovat přímo v Bitcoin
  Core přibližné informace o tom, který ISP kontroluje které IP adresy
  (viz zpravodaje [č. 52][news52 asmap] a [č. 83][news83 asmap], _angl._).
  Náročným úkolem je umožnit vícero přispěvatelům opakovatelně tuto mapu vytvořit,
  díky čemuž by bylo možné nezávisle ověřit přesnost obsahu mapy v době jejího
  vytvoření.

  Jahr tento týden ve svém příspěvku popisuje nástroje a techniky, které podle
  jeho slov „nabízejí dobrou šanci, že ve skupině s pěti nebo více členy dojde
  většina účastníků ke stejnému výsledku. […] Kdokoliv může tento proces zahájit,
  podobně jako Core PR. Účastníci se stejným výsledkem mohou být počítáni jako
  ACK. Pokud někdo spatří ve výsledcích něco divného nebo zkrátka nenalezne shodu,
  může požádat o sdílení surových dat a hledat příčiny.”

  Pokud by se tento proces setkal s přijetím (po případných úpravách), mohly by
  být budoucí verze Bitcoin Core dodávány s ASMapami a tato funkce by mohla
  být ve výchozím nastavení zapnuta. Díky tomu by se zvýšila odolnost vůči
  útokům zastíněním.

## Změny ve službách a klientech

*V této měsíční rubrice upozorňujeme na zajímavé aktualizace bitcoinových
peněženek a služeb.*

- **Ohlášen protokol NWC pro koordinaci více stran:**
  [Nostr Wallet Connect (NWC)][nwc blog] je koordinační protokol zprostředkující
  komunikaci v interaktivních scénářích s účastní několik stran. Ačkoliv se NWC
  zpočátku soustředí na LN, mohl by tento protokol být užitečný i pro schémata
  jako [joinpooly][topic joinpools], [Ark][topic ark], [DLC][topic dlc] či
  [vícenásobné podpisy][topic multisignature] (multisig).

- **Vydána Mutiny Wallet v0.5.7:**
  Vydání [Mutiny Wallet][mutiny github] přidává podporu pro [payjoin][topic payjoin]
  a vylepšuje funkce NWC a LSP.

- **Služba dávkování transakcí GroupHug:**
  [GroupHug][grouphug github] je služba pro [dávkování plateb][scaling payment batching]
  používající [PSBT][topic psbt], s [některými omezeními][grouphug blog].

- **Boltz ohlašuje taproot swap:**
  Nekustodiální swap směnárna Boltz [ohlásila][boltz blog] aktualizaci svého protokolu
  atomických swapů. Nově bude používat [taproot][topic taproot], [Schnorrovy podpisy][topic
  schnorr signatures] a [MuSig2][topic musig].

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [Core Lightning 24.02rc1][] je kandidátem na vydání příští hlavní verze tohoto
  oblíbeného LN uzlu.

## Významné změny kódu a dokumentace

_Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Bitcoin Inquisition][bitcoin inquisition repo] a [repozitáři BINANA][binana
repo]._

- [Bitcoin Core #27877][] přidává do peněženky Bitcoin Core novou strategii
  [výběru mincí][topic coin selection] CoinGrinder (viz [zpravodaj č. 283][news283
  coingrinder]). Účelem této strategie je použití v případech, kdy je odhadovaný
  jednotkový poplatek v porovnání s dlouhodobou úrovní vysoký. To peněžence
  umožní vytvořit malé transakce nyní (důsledkem může být nutnost vytvořit
  větší transakce později, snad s nižším jednotkovým poplatkem).

- [BOLTs #851][] přidává do specifikace LN podporu [oboustranného financování][topic
  dual funding] („dual funding”) spolu s podporou protokolu pro interaktivní konstrukci
  transakcí. Interaktivní konstrukce umožňuje dvěma uzlům vyměnit si detaily
  o nastavení a UTXO a tím spolupracovat na vytvoření otevírající transakce.
  Oboustranné financování umožňuje transakci obsahovat vstupy kterékoliv nebo
  obou stran. Například Alice může chtít otevřít s Bobem kanál. Před touto
  změnou musela Alice poskytnout kompletní financování kanálu. Nyní může
  Alice otevřít s Bobem kanál, ve kterém poskytne kompletní financování on nebo
  se o financování podělí. Může to být použito spolu s [protokolem inzerátů
  likvidity][topic liquidity advertisements] („liquidity advertisements”),
  který zatím do specifikace přidán nebyl.

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 15:00" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="1551,27877,851" %}
[news283 coingrinder]: /cs/newsletters/2024/01/03/#nove-strategie-vyberu-minci
[news52 asmap]: /en/newsletters/2019/06/26/#differentiating-peers-based-on-asn-instead-of-address-prefix
[news83 asmap]: /en/newsletters/2020/02/05/#bitcoin-core-16702
[jahr asmap]: https://delvingbitcoin.org/t/asmap-creation-process/548
[autonomous systems]: https://cs.wikipedia.org/wiki/Autonomn%C3%AD_syst%C3%A9m
[daftuar feerate rule]: https://delvingbitcoin.org/t/mempool-incentive-compatibility/553#feerate-rule-9
[news288 rbfr]: /cs/newsletters/2024/02/07/#navrh-na-nahrazovani-jednotkovym-poplatkem-jako-reseni-pinningu
[daftuar incompatible]: https://delvingbitcoin.org/t/mempool-incentive-compatibility/553#using-feerate-diagrams-as-an-rbf-policy-tool-13
[daftuar incentive]: https://delvingbitcoin.org/t/mempool-incentive-compatibility/553
[news285 64bit]: /cs/newsletters/2024/01/17/#navrh-na-soft-fork-pro-64bitovou-aritmetiku
[dnssec]: https://cs.wikipedia.org/wiki/Domain_Name_System_Security_Extensions
[corallo dns]: https://delvingbitcoin.org/t/human-readable-bitcoin-payment-instructions/542/
[dns bip]: https://github.com/TheBlueMatt/bips/blob/d46a29ff4b4ac27210bc81474ae18e4802141324/bip-XXXX.mediawiki
[dns bolt]: https://github.com/lightning/bolts/pull/1136
[dns blip]: https://github.com/lightning/blips/pull/32
[dnssec-prover]: https://github.com/TheBlueMatt/dnssec-prover
[dns demo]: http://http-dns-prover.as397444.net/
[news278 dns]: /cs/newsletters/2023/11/22/#ln-adresy-kompatibilni-s-nabidkami
[news166 tluv]: /en/newsletters/2021/09/15/#amount-introspection
[64bit discuss]: https://delvingbitcoin.org/t/64-bit-arithmetic-soft-fork/397
[stewart inout]: https://delvingbitcoin.org/t/op-inout-amount/549
[thunderbiscuit ecash]: https://delvingbitcoin.org/t/building-intuition-for-the-cashu-blind-signature-scheme/506
[blind signature scheme]: https://en.wikipedia.org/wiki/Blind_signature
[chaumian ecash]: https://en.wikipedia.org/wiki/Ecash
[openalias]: https://openalias.org/
[cashu]: https://github.com/cashubtc/nuts
[bip inout]: https://github.com/Christewart/bips/blob/92c108136a0400b3a2fd66ea6c291ec317ee4a01/bip-op-inout-amount.mediawiki
[mempool series]: /cs/blog/waiting-for-confirmation/
[Core Lightning 24.02rc1]: https://github.com/ElementsProject/lightning/releases/tag/v24.02rc1
[nwc blog]: https://blog.getalby.com/scaling-bitcoin-apps/
[mutiny github]: https://github.com/MutinyWallet/mutiny-web
[grouphug blog]: https://peachbitcoin.com/blog/group-hug/
[grouphug github]: https://github.com/Peach2Peach/groupHug
[boltz blog]: https://blog.boltz.exchange/p/introducing-taproot-swaps-putting
