---
title: 'Zpravodaj „Bitcoin Optech” č. 272'
permalink: /cs/newsletters/2023/10/11/
name: 2023-10-11-newsletter-cs
slug: 2023-10-11-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Tento týden přinášíme odkaz na specifikaci navrhovaného opkódu
`OP_TXHASH`. Nechybí též naše pravidelné rubriky se souhrnem sezení
Bitcoin Core PR Review Club, oznámeními o nových vydáních a popisem
významných změn v populárních páteřních bitcoinových projektech.

## Novinky

- **Návrh specifikace `OP_TXHASH`:** Steven Roose zaslal do emailové
  skupiny Bitcoin-Dev [příspěvek][roose txhash] s [návrhem BIPu][bips #1500]
  nového opkódu `OP_TXHASH`. O myšlence stojící za tímto opkódem jsme
  již dříve informovali (viz [zpravodaj č. 185][news185 txhash], *angl.*),
  avšak jedná se o první její specifikaci. Kromě přesného popisu chování
  opkódu se též zabývá opatřeními proti některým možným nevýhodám, jako
  je potřeba plných uzlů spočítat několik megabytů hashů při každém volání
  opkódu. Rooseův návrh obsahuje též ukázku implementace opkódu.

## Bitcoin Core PR Review Club

*V této měsíční rubrice shrnujeme nedávné sezení [Bitcoin Core PR Review Club][] a
vyzdvihujeme některé z důležitých otázek a odpovědí. Klikněte na otázku a odpověď se vám odhalí.*

[util: Typově bezpečné identifikátory transakcí][review club 28107] je PR od Niklase Göggeho
(dergoegge), které zvyšuje typovou bezpečnost zavedením odlišných typů
pro `txid` (identifikátor transakce, který neobsahuje data segwitových witnessů)
a `wtxid` (obsahující data segwitových witnessů). Dříve byly oba identifikátory
reprezentovány typem `uint256` (256bitové celé číslo, které může obsáhnout
SHA256 hash). PR by nemělo mít žádný dopad na provoz, cílí na zabránění
případných programátorských chyb, kvůli kterým by mohl být jeden druh
identifikátoru nesprávně použit namísto druhého. Podobné chyby budou nově
odhaleny v době kompilace.

Za účelem minimalizace zásahů a usnadnění revize budou tyto nové typy
použity nejdříve v jediné části kódu (v „sirotčinci” transakcí), budoucí
PR pak jejich použíti mohou rozšiřovat dále.

{% include functions/details-list.md
  q0="Co znamená, když je identifikátor transakce typově bezpečný?
      Proč je to důležité či užitečné? Přináší to nějaké nevýhody?"
  a0="Typová bezpečnost zaručuje, že identifikátor transakce, který může nabývat
      dvou různých významů (`txid` či `wtxid`), nemůže být použit s nesprávným
      významem. Tedy `txid` nemůže být použito, je-li očekáváno `wtxid`, a naopak.
      Tato vlastnost je vynucována kompilátorem během typové kontroly."
  a0link="https://bitcoincore.reviews/28107#l-38"

  q1="Mělo být raději upřednostněno _začlenění_ (obalení) typu `uint256`
      uvnitř nových tříd `Txid` a `Wtxid` před _děděním_ z `uint256`?
      Jak si tyto dva přístupy stojí v porovnání?"
  a1="Tyto třídy by mohly dědit, ale v důsledku by bylo potřeba pozměnit mnohem
      víc řádků zdrojového kódu."
  a1link="https://bitcoincore.reviews/28107#l-39"

  q2="Proč je lepší vynucovat typy během kompilace než za běhu?"
  a2="Vývojáři nacházejí chyby rychleji během kódování a nemusí spoléhat
      na psaní rozsáhlých testů, který by je odhalily za běhu (tyto testy
      navíc nemusí všechny chyby najít). Avšak testování je i nadále
      užitečné, neboť typová bezpečnost nezabrání zvolení nesprávného
      typu identifikátoru."
  a2link="https://bitcoincore.reviews/28107#l-67"

  q3="Kdy byste měli během psaní nového kódu odkazujícího na transakce
      použít `txid` a kdy `wtxid`? Můžete ukázat na nějaké příklady kódu,
      kdy by jejich záměna vedla k problémům?"
  a3="Obecně je používání `wtxid` preferováno, neboť obsahuje celou transakci.
      Důležitou výjimkou je `prevout`, který ve vstupech odkazuje na utrácený
      výstup (UTXO) a musí být `txid`. [Zde][wtxid example] je příklad,
      ve kterém je důležité použít jeden a nikoliv druhý typ (pro podrobnosti
      viz [zpravodaj č. 104][news104 wtxid], *angl.*)."
  a3link="https://bitcoincore.reviews/28107#l-85"

  q4="Jakým způsobem by mohlo používání `transaction_identifier` namísto
      `uint256` odhalit existující chybu či zabránit zanesení nové? Na
      druhou stranu, mohla by tato změna přinést nové chyby?"
  a4="Bez tohoto PR bychom mohli funkci, která vyžaduje argument typu `uint256`
      (např. identifikátor bloku), předat `txid`. Po tomto PR to vyvolá
      chybu kompilace."
  a4link="https://bitcoincore.reviews/28107#l-128"

  q5="Již existuje třída [`GenTxid`][GenTxid]. Jakým způsobem vynucuje
      typovou správnost a jak se odlišuje od přístupu z tohoto PR?"
  a5="Tato třída obsahuje hash a příznak určující, je-li hash `wtxid`
      či `txid`. Jedná se tedy o jediný typ a ne o dva odlišné. Typovou
      kontrolu umožňuje, ale musí být explicitně napsána v kódu a,
      co je důležitější, může být prováděna pouze za běhu. Řeší případy,
      ve kterých chceme předat kterýkoliv ze dvou druhů identifikátoru.
      Proto toto PR `GenTxid` neodstraňuje. V budoucnu může být vhodnější
      alternativou `std::variant<Txid, Wtxid>`."
  a5link="https://bitcoincore.reviews/28107#l-161"

  q6="Jak je možné, že `transaction_identifier`  rozšiřuje `uint256`,
      když jsou v C++ celá čísla typy a na třídami?"
  a6="Protože samo `uint256` je třídou a ne vestavěným typem.
      (Největší vestavěný celočíselný typ má v C++ 64 bitů.)"
  a6link="https://bitcoincore.reviews/28107#l-194"

  q7="Chová se jinak `uint256` stejně jako například `uint64_t`?"
  a7="Ne, aritmetické operace nejsou nad `uint256` povoleny, protože
      nedávají pro hashe, které jsou hlavním použitím `uint256`, smysl.
      Jméno je zavádějící, jedna se opravdu jen o shluk 256 bitů.
      Existuje též `arith_uint256`, který aritmetické operace povoluje
      (používaný například pro PoW výpočty)."
  a7link="https://bitcoincore.reviews/28107#l-203"

  q8="Proč `transaction_identifier` rozšiřuje `uint256` namísto vytvoření
      zcela nového typu?"
  a8="Umožňuje nám prozatím ponechat beze změn kód, který očekává identifikátor
      transakce ve formě `uint256` , a použít explicitní i implicitní konverze.
      Kód může být ve vhodný čas refaktorován, aby používal striktnější typy
      `Txid` či `Wtxid`."
  a8link="https://bitcoincore.reviews/28107#l-219"
%}

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [LDK 0.0.117][] je kandidátem na vydání této knihovny pro budování
  LN aplikací. Přináší opravy bezpečnostních chyb související s
  [anchor výstupy][topic anchor outputs] přidanými v předchozím vydání.
  Dále mimo jiné zlepšuje hledání cest, podporu [strážní věže][topic
  watchtowers] a umožňuje [dávkové][topic payment batching] financování
  nových kanálů.

- [BDK 0.29.0][] je kandidátem na vydání této knihovny pro budování
  peněženek. Aktualizuje závislosti a opravuje (pravděpodobně vzácnou)
  chybu objevující se v případech, kdy peněženka obdržela více než jeden
  výstup z coinbasových transakcí.

## Významné změny kódu a dokumentace

*Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo] a
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [Bitcoin Core #27596][bitcoin core #27596] uzavírá první fázi
  projektu [assumeutxo][topic assumeutxo]. Přináší všechny zbývající
  změny potřebné pro používání assumedvalid snapshot chainstate i
  pro plně validovanou synchronizaci na pozadí. UTXO snapshoty lze načíst
  voláním `loadtxoutset`. Dále přidává do chainparams parametr `assumeutxo`.

  I když celý soubor nových funkcí nebude ještě před samotnou [aktivací][bitcoin
  core #28553] na mainnetu přístupný, přináší tato změna vyvrcholení
  několikaleté práce. Projekt, který byl [navržen v roce 2018][assumeutxo
  core dev] a [formalizován v roce 2019][assumeutxo 2019 mailing list],
  výrazně zpříjemní používání nových plných uzlů a jejich připojení do sítě.
  Související následné změny: [Bitcoin Core #28590][bitcoin core #28590],
  [#28562][bitcoin core #28562] a [#28589][bitcoin core #28589].

- [Bitcoin Core #28331][], [#28588][bitcoin core #28588],
  [#28577][bitcoin core #28577] a [GUI #754][bitcoin core gui #754]
  přidávají podporu [šifrovaného P2P přenosu verze 2][topic v2 p2p
  transport] dle specifikace v [BIP324][]. Tato funkce je ve výchozím
  nastavení neaktivní, může být však zapnuta volbou `-v2transport`.

  Šifrovaný přenos pomáhá navýšit soukromí bitcoinových uživatelů tím,
  že zabraňuje pasivním pozorovatelům (jako jsou například poskytovatelé
  internetového připojení) přímo zjistit, jaké transakce uzly přeposílají
  svým spojením. Je též možné porovnáváním identifikátorů sezení zabránit
  aktivním man-in-the-middle odposloucháním. V budoucnu přidané další
  [funkce][topic countersign] mohou usnadnit lehkým klientům bezpečné
  připojení k důvěryhodným uzlům.

- [Bitcoin Core #27609][] zpřístupňuje RPC volání `submitpackage` i na jiných
  sítích než regtest. Uživatelé mohou pomocí tohoto volání odesílat balíčky
  jediné transakce s jejími nepotvrzenými předky, pokud žádný z předků
  neutrácí výstup jiného předka. Potomek může být použit k provedení CPFP
  předků, jejichž jednotkový poplatek spadá pod dynamické minimum mempoolu
  uzlu. Jelikož však [přeposílání balíčků][topic package relay] není
  ještě podporováno, nemusí se tyto transakce dostat k ostatním uzlům
  v síti.

- [Bitcoin Core GUI #764][] odstraňuje z GUI možnost vytvářet zastaralé
  typy peněženek. Všechny nově vytvořené peněženky v budoucích verzích
  Bitcoin Core budou založeny na [deskriptorech][topic descriptors].

- [Core Lightning #6676][] přidává nové RPC volání `addpsbtoutput`, které
  přidá do [PSBT][topic psbt] výstup pro příjem onchain prostředků peněženkou
  uzlu.

{% include references.md %}
{% include linkers/issues.md v=2 issues="27596,28590,28562,28589,28331,28588,28577,28553,754,27609,764,6676,1500" %}
[roose txhash]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-September/021975.html
[news185 txhash]: /en/newsletters/2022/02/02/#composable-alternatives-to-ctv-and-apo
[ldk 0.0.117]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.0.117
[bdk 0.29.0]: https://github.com/bitcoindevkit/bdk/releases/tag/v0.29.0
[review club 28107]: https://bitcoincore.reviews/28107
[wtxid example]: https://github.com/bitcoin/bitcoin/blob/3cd02806ecd2edd08236ede554f1685866625757/src/net_processing.cpp#L4334
[GenTxid]: https://github.com/bitcoin/bitcoin/blob/dcfbf3c2107c3cb9d343ebfa0eee78278dea8d66/src/primitives/transaction.h#L425
[news104 wtxid]: /en/newsletters/2020/07/01/#bips-933
[assumeutxo core dev]: https://btctranscripts.com/bitcoin-core-dev-tech/2018-03/2018-03-07-priorities/#:~:text=“Assume%20UTXO”
[assumeutxo 2019 mailing list]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-April/016825.html
