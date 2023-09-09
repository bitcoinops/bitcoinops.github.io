---
title: 'Zpravodaj „Bitcoin Optech” č. 267'
permalink: /cs/newsletters/2023/09/06/
name: 2023-09-06-newsletter-cs
slug: 2023-09-06-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Tento týden přinášíme popis nové techniky komprese bitcoinových transakcí
a souhrn myšlenky na zvýšení soukromí během kooperativního podepisování
transakcí. Též nechybí naše pravidelné rubriky s oznámeními o nových
vydáních a popisem významných změn v populárním bitcoinovém páteřním
software.

## Novinky

- **Komprimované bitcoinové transakce:** Tom Briar zaslal do emailové skupiny
  Bitcoin-Dev [příspěvek][briar compress] s návrhy [specifikace][compress
  spec] a [implementace][compress impl] komprese bitcoinových transakcí.
  Menší transakce by umožnily praktičtější přeposílání médii s omezenou
  šířkou pásma, jako je satelit nebo použíti steganografie (např. zakódování
  transakce do rastrového obrázku). Tradiční kompresní algoritmy využívají
  vlastnosti, že většina strukturovaných dat obsahuje elementy, které se
  objevují častěji než jiné. Avšak typická bitcoinová transakce sestává
  většinou z rovnoměrně rozložených prvků jako veřejné klíče a hashe,
  které vypadají náhodně.

  V Briarově návrhu je tato skutečnost adresována několika způsoby:

  - Části transakce s celými čísly reprezentovanými čtyřmi byty (např.
    verze transakce a index výstupu) jsou nahrazeny celým číslem s
    proměnlivou délkou, které mohou mít i pouhé dva bity.

  - Rovnoměrné rozložené 32bytové ID výstupní transakce je v každém vstupu
    nahrazeno ukazatelem na umístění této transakce v blockchainu za použití
    výšky bloku a indexu transakce, např. `123456` a `789` by ukazovaly
    na 789. transakci v bloku 123 456. Jelikož se může blok v určité výšce
    změnit kvůli reorganizacím (což by v důsledku znemožnilo transakci
    dekomprimovat), je tato metoda použita pouze pro odkazované transakce
    mající více než 100 konfirmací.

  - U P2WPKH transakcí, ve kterých musí struktura witnessu obsahovat podpis
    spolu s 33bytovým veřejným klíčem, je tento veřejný klíč vynechán a
    namísto toho je rekonstruován z podpisu.

  Pro ušetření několika dalších bytů jsou u typických transakcí použity
  i další techniky. Obecnou nevýhodou návrhu je, že převést komprimované
  transakce zpět na data, která plný uzel a další software mohou používat,
  vyžaduje více CPU, paměti a I/O než běžná serializovaná transakce.
  Proto zřejmě spojení s vysokou šířkou pásma zůstanou u běžného formátu
  a komprimované transakce budou používány jen v případech, kdy takové
  pásmo není k dispozici.

  Myšlenka obdržela průměrné množství reakci, většinou obsahující nápady na
  ušetření dalších bytů.

- **Kooperativní podepisování se zvýšeným soukromím:** Nick Farrow zaslal
  do emailové skupiny Bitcoin-Dev [příspěvek][farrow cosign] ukazující,
  jak mohou [bezskriptová schémata prahového elektronického podepisování][topic
  threshold signature] jako [FROST][] zvýšit soukromí lidí, kteří používají
  služby poskytující kooperativní podepisování. Typický uživatel takové
  služby má několik klíčů pro podepisování, které jsou z důvodu bezpečnosti
  uloženy odděleně. Aby však bylo běžné placení jednodušší, umožňují též,
  aby byly jejich výstupy utraceny kombinací některých svých klíčů spolu
  s jedním či více klíči drženými jedním či více poskytovateli služby,
  kteří podepíší jen po autentizaci uživatele nějakým způsobem. Uživatel
  může poskytovatele v případě potřeby obejít, ale tento poskytovatel
  služby ve většinu případů vše usnadňuje.

  Použitím skriptových schémat prahového elektronického podpisu, jako je 2-ze-3
  `OP_CHECKMULTISIG`, musí být veřejný klíč poskytovatele asociován s
  utráceným výstupem. Každý poskytovatel služby je tak schopen na blockchainu
  vyhledat transakce, které podepsal, a tím shromažďovat data o svých
  uživatelích. Co je ještě horší, všechny současně používané protokoly,
  kterých jsme si vědomi, přímo vyžadují odhalení uživatelovy transakce
  poskytovateli. Ten tak může některé transakce odmítnout podepsat.

  Dle Farrowova popisu umožňuje FROST před poskytovatelem skrýt podepisovanou
  transakci v každém kroku procesu, od generování výstupního skriptu přes
  podepisování až po publikaci kompletní podepsané transakce. Služba ví jen,
  kdy byla transakce podepsána, a zná další data, která uživatel službě
  sám poskytl za účelem autentizace.

  Příspěvek obdržel v emailové skupině několik komentářů.

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [Libsecp256k1 0.4.0][] je nejnovějším vydáním knihovny pro bitcoinové
  kryptografické operace. Nová verze obsahuje modul s implementací kódování
  ElligatorSwift. Více informací lze najít v [changelogu][libsecp cl].

- [LND v0.17.0-beta.rc2][] je kandidátem na vydání příští hlavní verze
  této oblíbené implementace LN uzlu. Velkou novou experimentální funkcí
  plánovanou pro toto vydání, které by prospělo testování, je podpora
  „jednoduchých taprootových kanálů.”

## Významné změny v kódu a dokumentaci

*Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo] a
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [Bitcoin Core #28354][] mění na testnetu výchozí hodnotu `-acceptnonstdtxn`
  na 0, což je výchozí hodnota na všech ostatních sítích. Změna může pomoci
  aplikacím vyvarovat se vytváření nestandardních transakcí, které by
  mohly být odmítnuty mainnetovými uzly ve výchozím nastavení.

- [LDK #2468][] umožňuje uživatelům poskytnout `payment_id` zašifrované
  v metadatech v žádosti o fakturu. LDK metadata v přijatých fakturách
  kontroluje a zaplatí pouze, pokud ID rozpozná a pokud ještě nebylo
  použito. Toto PR je součástí [snahy][ldk bolt12] přidat implementaci
  [BOLT12][topic offers].

{% include references.md %}
{% include linkers/issues.md v=2 issues="28354,2468" %}
[LND v0.17.0-beta.rc2]: https://github.com/lightningnetwork/lnd/releases/tag/v0.17.0-beta.rc2
[briar compress]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-August/021924.html
[compress spec]: https://github.com/TomBriar/bitcoin/blob/2023-05--tx-compression/doc/compressed_transactions.md
[compress impl]: https://github.com/TomBriar/bitcoin/pull/3
[farrow cosign]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-August/021917.html
[frost]: https://eprint.iacr.org/2020/852
[libsecp cl]: https://github.com/bitcoin-core/secp256k1/blob/master/CHANGELOG.md
[libsecp256k1 0.4.0]: https://github.com/bitcoin-core/secp256k1/releases/tag/v0.4.0
[ldk bolt12]: https://github.com/lightningdevkit/rust-lightning/issues/1970
