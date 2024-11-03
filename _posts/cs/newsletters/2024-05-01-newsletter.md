---
title: 'Zpravodaj „Bitcoin Optech” č. 300'
permalink: /cs/newsletters/2024/05/01/
name: 2024-05-01-newsletter-cs
slug: 2024-05-01-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Zpravodaj tento týden shrnuje návrh ve stylu CTV, který používá commitmenty
vložené do veřejných klíčů, zkoumá analýzu kontraktového protokolu s Alloy,
oznamuje zatčení bitcoinových vývojářů a odkazuje na zápisky ze setkání vývojářů
CoreDev.tech. Též nechybí naše pravidelné rubriky s oznámeními nových vydání
a souhrnem významných změn v populárních bitcoinových páteřních projektech.

## Novinky

- **Návrh na rozrůstající se klíče ve stylu CTV:** Tadge Dryja zaslal do fóra
  Delving Bitcoin [příspěvek][dryja exploding] s návrhem na mírně efektivnější
  verzi hlavní myšlenky [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify]
  (CTV). Použitím CTV může Alice platit na výstup typu:

  ```text
  OP_CTV <hash>
  ```

  Předobraz hashe zavazuje hlavním částem transakce, zejména částce
  každého výstupu a skriptu, na který každý výstup platí. Například:

  ```text
  hash(
    2 BTC pro KlíčB,
    3 BTC pro KlíčC,
    4 BTC pro KlíčD
  )
  ```

  Opkód `OP_CTV` skončí úspěchem, pokud je vykonán v transakci přesně odpovídající
  těmto parametrům. Znamená to, že Alicin výstup v jedné transakci může být
  utracen v jiné bez požadavku na další dodatečný podpis nebo jiná data, pokud se tato
  druhá transakce přesně shoduje s Aliciným očekáváním.

  Dryja navrhuje alternativní způsob. Alice platí na veřejný klíč (podobně jako na
  [taprootový][topic taproot] výstup, avšak s jinou segwit verzí). Ten
  je zkonstruován z [MuSig2][topic musig] agregace jednoho nebo více skutečných
  veřejných klíčů s aplikovanými tweaky, které zavazují částkám. Následující příklad
  je odvozen z Dryjova příspěvku:

  ```text
  musig2(
    KlíčB + hash(2 BTC, KlíčB)*G,
    KlíčC + hash(3 BTC, KlíčC)*G,
    KlíčD + hash(4 BTC, KlíčD)*G
  )
  ```

  Transakce je platná, pokud posílá přesné částky na vnořené veřejné klíče.
  V takovém případě není vyžadován žádný podpis. V porovnání s CTV v taprootu
  ušetří tato metoda kolem 16 vbytes. Zdá se, že v porovnání s CTV v holém
  skriptu (tedy umístěným přímo ve výstupním skriptu) zabírá podobný prostor.

  Pokud se CTV použije v taprootu, může být poskytnut alternativní způsob platby
  v podobě platby klíčem (keypath spend), na kterém se shodnou všechny zúčastněné
  strany. Díky tomu mohou účastníci změnit příjemce prostředků. Rozrůstající se
  klíče („exploding keys”) umožní dosáhnout téhož těmi, kdo kontrolují
  KlíčB, KlíčC, KlíčD. Efektivita je v obou případech shodná.

  Dryja píše, že rozrůstající se klíče „nabízí základní funkcionalitu OP_CTV,
  avšak umí ušetřit pár bajtů dat witnessu. Samy o sobě asi nevypadají tak působivě,
  ale chtěl jsem to zveřejnit, protože by to mohl být užitečný základ pro
  složitější konstrukce kovenantů.”

- **Analýza kontraktového protokolu pomocí Alloy:** Dmitry Petukhov
  zaslal do fóra Delving Bitcoin [příspěvek][petukhov alloy] se
  [specifikací][petukhov spec] jednoduché úschovny založené na `OP_CAT`
  (viz [zpravodaj č. 291][news291 catvault]). Pro specifikaci použil jazyk
  [Alloy][]. Petukhov díky Alloy [nalezl][petukhov mods] několik užitečných
  modifikací a důležitých omezení, která by měl mít každý implementující na vědomí.
  Všem zájemcům o formální modelování kontraktových protokolů doporučujeme
  přečtení jeho příspěvku a důkladně dokumentované specifikace.

- **Zatčení bitcoinových vývojářů:** jak bylo široce reportováno jinde, dva vývojáři
  bitcoinové peněženky Samourai nabízející funkce pro zlepšení soukromí byli minulý týden
  zatčeni v souvislosti se svým software. Zatčení byla provedna na základě
  obvinění amerických orgánů činných v trestním řízení. Dvě další firmy nato
  oznámily záměr ukončit kvůli právním rizikům nabídku svých služeb americkým zákazníkům.

  Optech se specializuje na psaní o bitcoinových technologiích, přenecháme tedy
  informování o této právní situaci jiným publikacím. Avšak vyzýváme všechny,
  kteří mají zájem na úspěchu bitcoinu, obzvláště pokud sídlí v USA nebo mají vazby
  na tamní lidi, aby si zjistili podrobnosti a v případě možnosti zvážili podporu.

- **Setkání CoreDev.tech v Berlíně:** množství přispěvatelů Bitcoin Core se minulý měsíc
  osobně sešlo v Berlíně v rámci pravidelného setkání [CoreDev.tech][]. Účastníci poskytli
  [přepisy][coredev xs] některých sezení. Prezentace, revize kódu, pracovní
  skupiny a další sezení se mimo jiné zabývaly těmito tématy:

  - nálezy bádání ASMap
  - připravenost assumeUTXO na mainnetu
  - BTC Lisp
  - CMake
  - cluster mempool
  - výběr mincí
  - agregace podpisů napříč vstupy (cross-input signature aggregation)
  - současný spam v síti
  - odhad poplatků
  - obecná diskuze o BIP
  - velké pročištění konsenzu
  - diskuze o GUI
  - odstranění zastaralé peněženky
  - libbitcoinkernel
  - MuSig2
  - monitorování P2P
  - revize přeposílání balíčků
  - odesílání soukromých transakcí
  - revize současných tiketů na GitHubu
  - revize současných PR na GitHubu
  - signet/testnet4
  - tiché platby
  - poskytování šablon se Stratum v2
  - warnet
  - slabé bloky


## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [Bitcoin Inquisition 25.2][] je nejnovějším vydáním tohoto experimentálního
  plného uzlu navrženého na [signetové][topic signet] testování změn protokolu.
  Poslední verze přidává podporu pro [OP_CAT][topic op_cat] na signetu.

- [LND v0.18.0-beta.rc1][] je kandidátem na vydání příští hlavní verze tohoto
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

- [Bitcoin Core #27679][] umožňuje, aby byly notifikace posílané pomocí
  [ZMQ][] přeposílány na unixový soket. To bylo dříve (zřejmě neúmyslně)
  podporováno předáním konfigurační volby nedokumentovaným způsobem.
  [Bitcoin Core #22087][] zpřísnil parsování této volby, čímž v Bitcoin Core
  27.0 změnil nedokumentované chování. Tato změna [postihla LND][gugger zmq]
  a možná i jiné programy. Toto PR přináší pro volbu oficiální podporu a
  drobně mění její sémantiku, aby byla konzistentní s dalšími podobnými
  volbami v Bitcoin Core, viz například změny popsané ve [zpravodaji č. 294][news294
  sockets].

- [Core Lightning #7240][] přidává podporu pro stahování potřebných bloků
  z bitcoinové P2P sítě, pokud je místní ořezaný bitcoinový uzel odstranil.
  Pokud CLN takový blok potřebuje, zavolá `getblockfrompeer`, aby uzel tento blok
  stáhl od svého spojení. Po přijetí bloku jej Bitcoin Core autentizuje
  propojením s hlavičkou, kterou ukládá i během ořezávání. Dále blok
  uloží a tím ho zpřístupní standardními RPC voláními.

- [Eclair #2851][] začíná vyžadovat Bitcoin Core 26.1 či novější a odstraňuje
  kód pro financování s nepotvrzenými předky. Po upgradu bude využívat
  funkci Bitcoin Core, která je navržena, aby kompenzovala jakýkoliv _schodek
  poplatku_ (viz [zpravodaj č. 269][news269 fee deficit]).

- [LND #8147][], [#8422][lnd #8422], [#8423][lnd #8423], [#8148][lnd
  #8148], [#8667][lnd #8667] a [#8674][lnd #8674] nahrazují starý sweeper
  (nástroj pro „zametení” UTXO zpět do vlastní peněženky, zejména po vynuceném
  zavření kanálu) novou implementací, která umožňuje zveřejnění urovnávajících
  transakcí i jakýchkoliv dalších, které jsou potřebné pro efektivní navyšování
  jejích poplatků. Nová implementace akceptuje většinu parametrů staré,
  jako je například časová lhůta, do které musí být transakce potvrzena,
  a počáteční poplatek. Nová implementace dále přidává volbu `budget`, která
  stanovuje maximální částku použitelnou na poplatky. Nová implementace
  umožňuje podrobnější nastavení, usnadňuje psaní testů, umí používat
  navyšování poplatků dle [CPFP][topic cpfp] i [RBF][topic rbf] (každý
  podle situace), lépe dávkuje navyšování poplatků a aktualizuje
  poplatky každý blok namísto každých 30 sekund.

- [LND #8627][] nově ve výchozím nastavení odmítá uživatelem vyžádané změny
  nastavení kanálu, které vyžadují kladný _příchozí poplatek za přeposílání._
  Například si představme, že Alice chce Carol přeposlat platbu přes Boba.
  Ve výchozím nastavení již Bob nemůže použít nově přidanou funkci pro
  příchozí poplatky za přeposílání (viz [zpravodaj č. 297][news297 inbound]),
  aby od Alice obdržel poplatek navíc. Toto nové výchozí chování zajišťuje,
  aby zůstal Bobův uzel kompatibilní s uzly, které příchozí poplatky
  nepodporují (což jsou v současnosti téměř všechny LN uzly). Bob může
  přestat být zpětně kompatibilní překrytím výchozího chování pomocí
  konfiguračního nastavení `accept-positive-inbound-fees`. Jinou možností,
  jak může Bob dosáhnout požadovaného výsledku a zůstat zpětně kompatibilní,
  je zvýšit odchozí poplatek za přeposlání Carol a poté pomocí záporného
  příchozího poplatku nabídnout slevu na platby nepocházející od Alice.

- [Libsecp256k1 #1058][] mění algoritmus používaný pro generování veřejných
  klíčů a podpisů. Starý i nový algoritmus běží v konstantním čase, aby zabránily
  vytváření příležitostí pro časované útoky [postranním kanálem][topic side channels].
  Výkonnostní testy ukazují, že nový algoritmus je zhruba o 12 % rychlejší.
  Jeden z účastníků PR review popsal fungování nového algoritmu ve svém [blogovém
  příspěvku][stratospher comb].

- [BIPs #1382][] přiřazuje návrhu na [přeposílání balíčku předků][topic package relay]
  číslo [BIP331][].

- [BIPs #1068][] zaměňuje pořadí dvou parametrů ve verzi 1 opakovaně použitelných
  platebních kódů ([BIP47][]), aby odpovídaly implementaci v peněžence
  Samourai. Dále jsou k BIPu přidány odkazy na informace o dalších verzích.
  Poznamenáváme, že původní implementace BIP47 v Samourai se objevila před lety
  a toto PR bylo otevřeno přes tři roky. Začleněno bylo minulý týden.

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="27679,7240,2851,22087,8147,8422,8423,8148,8667,8627,1058,1382,1068,8674" %}
[gugger zmq]: https://github.com/lightningnetwork/lnd/pull/8664#issuecomment-2065802617
[news269 fee deficit]: /cs/newsletters/2023/09/20/#bitcoin-core-26152
[news 297 inbound]: /cs/newsletters/2024/04/10/#lnd-6703
[stratospher comb]: https://github.com/stratospher/blogosphere/blob/main/sdmc.md
[petukhov alloy]: https://delvingbitcoin.org/t/analyzing-simple-vault-covenant-with-alloy/819
[petukhov mods]: https://delvingbitcoin.org/t/basic-vault-prototype-using-op-cat/576/16
[petukhov spec]: https://gist.github.com/dgpv/514134c9727653b64d675d7513f983dd
[alloy]: https://en.wikipedia.org/wiki/Alloy_(specification_language)
[dryja exploding]: https://delvingbitcoin.org/t/exploding-keys-covenant-construction/832
[zmq]: https://en.wikipedia.org/wiki/ZeroMQ
[news291 catvault]: /cs/newsletters/2024/02/28/#prototyp-jednoduche-uschovny-pouzivajici-op-cat
[news297 inbound]: /cs/newsletters/2024/04/10/#lnd-6703
[coredev.tech]: https://coredev.tech/
[coredev xs]: https://btctranscripts.com/bitcoin-core-dev-tech/2024-04/
[news294 sockets]: /cs/newsletters/2024/03/20/#bitcoin-core-27375
[bitcoin inquisition 25.2]: https://github.com/bitcoin-inquisition/bitcoin/releases/tag/v25.2-inq
[lnd v0.18.0-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.18.0-beta.rc1
