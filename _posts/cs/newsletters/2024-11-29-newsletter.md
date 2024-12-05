---
title: 'Zpravodaj „Bitcoin Optech” č. 331'
permalink: /cs/newsletters/2024/11/29/
name: 2024-11-29-newsletter-cs
slug: 2024-11-29-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Zpravodaj tento týden shrnuje několik nedávných diskuzí o dialektu Lispu
pro skriptování v bitcoinu a přináší pravidelné rubriky s popisem oblíbených
otázek a odpovědí z Bitcoin Stack Exchange, oznámeními nových vydání
a souhrnem významných změn v populárních bitcoinových páteřních projektech.

## Novinky

- **Dialekt Lispu pro bitcoinové skripty:** Anthony Towns zaslal několik
  příspěvků o své pokračující [snaze][topic bll] vytvořit dialekt Lispu
  pro bitcoin, který by mohl být přidán jako soft fork.

  - *bll, symbll, bllsh:* Towns [poznamenává][towns bllsh1], že strávil
    mnoho času přemýšlením nad radou vývojáře Chia Lispu Arta Yerkese
    o zajištění bezchybného převodu mezi vysokoúrovňovým kódem (co
    vývojář píše) a nízkoúrovňovým kódem (co se nakonec spustí, obvykle
    vytvořen z vyšší úrovně kompilátorem). Rozhodl se pro přístup podobný
    [miniscriptu][topic miniscript], ve kterém „nakládáte s vysokoúrovňovým
    jazykem jako s přátelskou variantou nízkoúrovňového (jako miniscript a
    Script).“ Výsledkem jsou dva jazyky a jeden nástroj:

    - *Základový Bitcoin Lisp language (bll)* je nízkoúrovňovým jazykem,
      který by mohl být soft forkem přidán do bitcoinu. Towns tvrdí, že
      bll je podobný BTC Lispu v jeho poslední aktualizaci (viz [zpravodaj č.
      294][news294 btclisp]).

    - *Symbolický bll (symbll)* je jazykem vyšší úrovně, který se
      překládá do bll. Měl by být pro vývojáře znalé funkcionálního
      programování poměrně snadný.

    - *Bll shell (bllsh)* je [REPL][], který umožňuje vývojářům testovat
      skripty v bll a symbll, kompilovat ze symbll do bll a spouštět
      debugování kódu.

  - *Implementace kvantově bezpečných podpisů v symbll oproti GSR:* Towns
    [odkazuje][towns wots] na [twitterový příspěvek][nick wots] Jonase Nicka
    o implementaci Winternitzových jednorázových podpisů (Winternitz One-Time
    Signatures, WOTS+) pomocí existujících opkódů a opkódů specifikovaných
    v [návrhu][russell gsr] _great script restoration_ (GSR) od Rustyho Russella.
    Towns ji nato porovnává s implementací WOTS+ v symbll a bllsh. Dosáhl
    tím snížení množství onchain dat přinejmenším o 83 % a možná i o více
    než 95 %. Mohlo by to přinést [kvantově bezpečné podpisy][topic quantum
    resistance] s náklady pouze 30× vyššími než P2WPKH výstupy.

  - *Flexibilní účelové dělení mincí:* Towns [popisuje][towns earmarks]
    obecnou konstrukci kompatibilní se symbll (a pravděpodobně i se
    [Simplicity][topic simplicity]), která umožní rozdělit nějaké UTXO
    dle konkrétních částek a platebních podmínek. Pokud se platební
    podmínky naplní, příslušná částka může být utracena a zbytek hodnoty
    UTXO je vrácen na nové UTXO se zbývajícími podmínkami. Může být také
    určena alternativní podmínka, která by utratila celé UTXO; umožnilo
    by to na příklad se všem stranám dohodnout na změně podmínek. Jedná
    se o flexibilní druh [kovenantů][topic covenants], podobný Townsově
    předchozímu návrhu na `OP_TAP_LEAF_UPDATE_VERIFY` (TLUV, viz
    [zpravodaj č. 166][news166 tluv], _angl._), avšak Towns již dříve
    [napsal][towns badcov], že nepovažuje _kovenanty_ za „přesný a užitečný
    termín.”

    Příspěvek obsahuje několik příkladů použití tohoto _flexibilního
    účelového dělení mincí_ (flexible coin earmarks), včetně zlepšení
    bezpečnosti a použitelnosti LN kanálů (též kanálů založených na
    [LN-Symmetry][topic eltoo]), alternativní verzi [úschoven][topic
    vaults] k [BIP345][] či [platebního poolu][topic joinpools]
    podobného příkladu použití TLUV, avšak bez problémů spojených
    s používáním [x-only veřejných klíčů][topic x-only public keys].

## Vybrané otázky a odpovědi z Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] je jedním z prvních míst, kde hledají
přispěvatelé Optechu odpovědi na své otázky a kde – najdou-li volnou chvíli –
pomáhají zvědavým či zmateným uživatelům. V této měsíční rubrice nabízíme
některé z otázek a odpovědí, které obdržely vysoký počet hlasů.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Jak ColliderScript vylepšuje Bitcoin a jaké možnosti nabízí?]({{bse}}124690)
  Victor Kolobov vyjmenovává možná použití ColliderScriptu (viz [zpravodaj č. 330][news330
  cs] a [podcast č. 330][pod330 cs]) včetně [kovenantů][topic covenants], [úschoven][topic
  vaults], emulace [CSFS][topic op_checksigfromstack] a validity rollups (viz [zpravodaj
  č. 222][news222 validity rollups], _angl._) a poukazuje na vysoké výpočetní náklady
  těchto transakcí.

- [Proč omezují pravidla standardnosti váhu transakcí?]({{bse}}124636)
  Murch poskytuje důvody pro a proti omezením váhy v pravidlech standardnosti
  v Bitcoin Core a nastiňuje, jak by mohla ekonomická poptávka po větších
  transakcích efektivitu tohoto [pravidla][policy series] poznamenat.

- [Musí být scriptSig utrácející PayToAnchor výstup prázdný?]({{bse}}124615)
  Pieter Wuille vysvětluje, že kvůli způsobu [konstrukce][news326 p2a]
  musí [pay-to-anchor (P2A)][topic ephemeral anchors] výstupy následovat
  segwitové podmínky utrácení včetně prázdného scriptSigu.

- [Co se stane s nepoužitými P2A výstupy?]({{bse}}124617)
  Instagibbs poznamenává, že nepoužité P2A výstupy budou smeteny, až to bude
  ekonomicky výhodné, a tím budou odstraněny z množiny UTXO. Dále odkazuje na
  nedávno začleněné PR o [dočasném prachu][news330 ed], které povolí jeden
  výstup s neekonomickou hodnotou v transakci s nulovým poplatkem, pokud
  ho [potomek][topic cpfp] okamžitě utrácí.

- [Proč nepoužívá bitcoinový PoW algoritmus posloupnost hašů s nižší složitostí?]({{bse}}124777)
  Pieter Wuille a Vojtěch Strnad popisují tlak na centralizaci těžby, pokud by byla
  podobným přístupem narušena absence progresivity (tedy že výpočet jednoho haše
  nepřináší žádnou výhodu následujícím pokusům).

- [Objasnění false hodnoty ve Scriptu.]({{bse}}124673)
  Pieter Wuille vyjmenovává tři hodnoty, které se v bitcoinovém Scriptu
  vyhodnotí jako false: prázdné pole, pole s nulovými bajty a pole s nulovými
  bajty a 0x80 na konci. Všechny ostatní hodnoty jsou vyhodnoceny jako true.

- [Co je zač tato divná transakce v mé peněžence?]({{bse}}124744)
  Vojtěch Strnad vysvětluje mechanismus otravy adres (address poisoning)
  a způsoby bránění těmto útokům.

- [Existují UTXO, která není možné utratit?]({{bse}}124865)
  Pieter Wuille poskytuje dva příklady výstupů, které jsou bez ohledu
  na prolomení kryptografických předpokladů neutratitelné: `OP_RETURN`
  výstupy a výstupy se scriptPubKey delšími než 10 000 bajtů.

- [Proč nebyl BIP34 implementován pomocí locktime nebo nSequence v coinbasové transakci?]({{bse}}75987)
  Antoine Poinsot přidává k této starší otázce vysvětlení, že hodnota `nLockTime`
  coinbasové transakce nemůže být nastavena na aktuální výšku, neboť [locktime][topic
  timelocks] představuje poslední blok, ve kterém je transakce _nevalidní_.

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [Core Lightning 24.11rc2][] je kandidátem na vydání následující hlavní verze
  této oblíbené implementace LN.

- [BDK 0.30.0][] je vydáním této knihovny pro budování peněženek a jiných
  bitcoinových aplikací. Přináší opravy několika drobných chyb a přípravy
  na očekávaný upgrade na verzi 1.0.

- [LND 0.18.4-beta.rc1][] je kandidátem na menší vydání této oblíbené
  implementace LN.

## Významné změny kódu a dokumentace

_Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Bitcoin Inquisition][bitcoin inquisition repo] a [repozitáři BINANA][binana
repo]._

- [Bitcoin Core #31122][] přidává do mempoolu rozhraní pro operace nad množinou
  změn. Tím umožní uzlu vypočítat dopad navržených změn na stav mempoolu:
  na příklad zkontrolovat, zda by byly při přijetí transakce nebo balíčku
  narušeny limity předků, potomků či [TRUC][topic v3 transaction relay]/clusterů,
  nebo určit, zda by [RBF][topic RBF] navýšení zlepšilo stav mempoolu. PR je
  součástí projektu [mempoolu clusterů][topic cluster mempool].

- [Core Lightning #7852][] vrací pole popisku do pluginu `pyln-client`, čímž
  obnovuje zpětnou kompatibilitu s verzemi před 24.08.

- [Core Lightning #7740][] přináší API abstrahující složitost řešení problému
  nejlevnějšího toku (minimum cost flow, MCF) v pluginu `askrene` (viz
  [zpravodaj č. 316][news316 askrene]). Tím umožní snazší integraci nově
  přidaných grafových algoritmů pro výpočet toku. Algoritmus hledající řešení
  používá stejnou linearizaci funkce nákladů kanálu jako `renepay` (viz
  [zpravodaj č. 263][news263 renepay]), čímž zlepšuje schopnost hledání cest.
  Dále přináší podporu pro definici uživatelských jednotek mimo msat.
  PR přidává metody `simple_feasibleflow`, `get_augmenting_flow`, `augment_flow`
  a `node_balance`, které celkově vylepší efektivitu výpočtů toku.

- [Core Lightning #7719][] přináší interoperabilitu s Eclair pro vykonávání
  splicingu. PR představuje několik změn včetně podpory pro rotaci vzdálených
  funding klíčů, přidání `batch_size` pro commitmentové podepsané zprávy
  (zabrání tím posílání starších otevíracích transakcí), odstranění hašů
  bloků ze zpráv a úpravě přednastavených zůstatků.

- [Eclair #2935][] pošle provozovateli uzlu zprávu v případě vynuceného zavření
  kanálu iniciovaného protistranou.

- [LDK #3137][] přidává podporu pro přijímání [kanálů s oboustranným
  financováním][topic dual funding] iniciovaných protistranou. Financování či
  vytváření těchto kanálů zatím podporováno není. Je-li `manually_accept_inbound_channels`
  nastaveno na false, kanály jsou automaticky přijaty. Metoda
  `ChannelManager::accept_inbound_channel()` řídí jejich manuální přijetí.
  Bylo přidáno nové pole `channel_negotiation_type` pro rozlišení mezi druhy
  kanálů. [0-conf][topic zero-conf channels] oboustranně financované kanály ani
  [RBF][topic rbf] navyšování poplatků financujících transakcí podporováno není.

- [LND #8337][] přidává modul `protofsm`, framework pro vytváření konečných automatů
  pro protokoly založené na událostech. Namísto psaní hromady kódu pro zpracování
  stavů, jejich přechodů a událostí mohou vývojáři definovat stavy, spouštěče
  událostí a pravidla pro pohyb mezi nimi a rozhraní `State` poskytne zbytek výpočtů.
  Adaptéry budou mít na starosti vedlejší efekty jako posílání transakcí a zpráv.

{% include references.md %}
{% include linkers/issues.md v=2 issues="31122,7852,7740,7719,2935,3137,8337" %}
[news294 btclisp]: /cs/newsletters/2024/03/20/#prehled-btc-lispu
[russell gsr]: https://github.com/rustyrussell/bips/pull/1
[towns bllsh1]: https://delvingbitcoin.org/t/debuggable-lisp-scripts/1224
[repl]: https://en.wikipedia.org/wiki/Read%E2%80%93eval%E2%80%93print_loop
[towns wots]: https://delvingbitcoin.org/t/winternitz-one-time-signatures-contrasting-between-lisp-and-script/1255
[nick wots]: https://x.com/n1ckler/status/1854552545084977320
[towns earmarks]: https://delvingbitcoin.org/t/flexible-coin-earmarks/1275
[news166 tluv]: /en/newsletters/2021/09/15/#covenant-opcode-proposal
[towns badcov]: https://gnusha.org/pi/bitcoindev/20220719044458.GA26986@erisian.com.au/
[core lightning 24.11rc2]: https://github.com/ElementsProject/lightning/releases/tag/v24.11rc2
[bdk 0.30.0]: https://github.com/bitcoindevkit/bdk/releases/tag/v0.30.0
[lnd 0.18.4-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.18.4-beta.rc1
[news316 askrene]: /cs/newsletters/2024/08/16/#core-lightning-7517
[news263 renepay]: /cs/newsletters/2023/08/09/#core-lightning-6376
[news330 cs]: /cs/newsletters/2024/11/22/#kovenanty-zalozene-na-obrusovani-misto-zmen-konsenzu
[pod330 cs]: /en/podcast/2024/11/26/#covenants-based-on-grinding-rather-than-consensus-changes
[news222 validity rollups]: /en/newsletters/2022/10/19/#validity-rollups-research
[policy series]: /cs/blog/waiting-for-confirmation/
[news326 p2a]: /cs/newsletters/2024/10/25/#jak-se-rozhodlo-o-strukture-pay-to-anchor
[news330 ed]: /cs/newsletters/2024/11/22/#bitcoin-core-30239
