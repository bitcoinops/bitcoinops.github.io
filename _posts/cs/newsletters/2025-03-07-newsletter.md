---
title: 'Zpravodaj „Bitcoin Optech” č. 344'
permalink: /cs/newsletters/2025/03/07/
name: 2025-03-07-newsletter-cs
slug: 2025-03-07-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Zpravodaj tento týden oznamuje odhalení zranitelnosti postihující starší
verze LND a shrnuje diskuzi o prioritách projektu Bitcoin Core. Též
nechybí naše pravidelné rubriky s popisem diskuzí o změnách konsenzu,
oznámeními nových vydání a souhrnem významných změn v populárním
bitcoinovém páteřním software.

## Novinky

- **Odhalení opravené zranitelnosti v LND umožňující krádež:** Matt
  Morehouse zaslal do fóra Delving Bitcoin [příspěvek][morehouse failback]
  s odhalením [zodpovědně nahlášené][topic responsible disclosures] zranitelnosti,
  která postihovala verze LND před 0.18. Doporučuje se upgrade na 0.18 nebo
  (ideálně) na [aktuální verzi][lnd current]. Útočník, který s obětí sdílí
  kanál a který v určitou dobu může přimět oběť k restartování svého uzlu,
  může klamem přinutit LND k platbě i refundaci jednoho HTLC, což útočníkovi
  umožní ukrást téměř kompletní hodnotu kanálu.

  Morehouse poznamenává, že všechny ostatní LN implementace tuto
  zranitelnost nezávisle objevily a opravily, některé už v roce 2018 (viz [zpravodaj
  č. 17][news17 cln2000], _angl._). LN specifikace však správné chování
  nepopisuje (může dokonce doporučovat nesprávné chování), Morehouse
  proto [otevřel PR][bolts #1233] s aktualizací specifikace.

- **Diskuze o prioritách Bitcoin Core:** [vlákno][poinsot pri] ve fóru
  Delving Bitcoin odkázalo na několik blogových příspěvků od Antoine
  Poinsota o budoucnosti projektu Bitcoin Core. V [prvním][poinsot pri1]
  příspěvku popisuje Poinsot výhody dlouhodobých cílů a náklady ad-hoc
  rozhodnutí. Ve [druhém][poinsot pri2] příspěvku soudí, že „by měl být
  Bitcoin Core robustní oporou bitcoinové sítě, která hledá rovnováhu
  mezi bezpečností Bitcoin Core a přidáváním nových funkcí posilňujících
  a vylepšujících celou síť.“ Ve [třetím][poinsot pri3] příspěvku doporučuje
  rozdělit existující projekt na tři části: uzel, peněženku a grafické
  rozhraní. Tato možnost je nyní na dosah díky několikaletému úsilí stojícímu
  za podprojektem rozdělení aplikace do více běžících procesů (ve zpravodaji byl
  tento podprojekt poprvé zmíněn v [č. 39][news39 multiprocess], _angl._).

  Anthony Towns [pochybuje][towns pri], že by běh ve více procesech opravdu
  umožnil efektivní rozdělení, neboť jednotlivé komponenty by nadále zůstaly
  úzce provázané. Mnoho změn učiněných v jednom projektu by si vyžádalo
  změny i v ostatních. Bylo by však jasnou výhrou, pokud by byly funkce,
  které nevyžadují uzel, extrahovány do nějaké knihovny nebo nástroje,
  jež by mohly být udržovány nezávisle. Dále popisuje, jak někteří lidé
  používají uzly s mezivrstvou, která jim usnadňuje připojit jejich peněženky
  k vlastním uzlům pomocí indexů blockchainu (v podstatě [osobních
  prohlížečů bloků][topic block explorers]); Bitcoin Core v minulosti
  odmítl přidat podobnou funkci přímo do svého uzlu. Nakonec [poznamenává][towns
  pri2], že dle něj „poskytování funkce peněženky (ve větší míře) a GUI
  (v menší míře) je způsob, jak držet směr bitcoinu jako použitelného
  decentralizovanou skupinou hackerů oproti něčemu, co můžou používat
  jen finanční velryby nebo zavedené korporace ochotné investovat ve
  velkém.”

  David Harding vyjádřil [obavy][harding pri], že změna zaměření
  hlavního projektu pouze na kód konsenzu a P2P přeposílání ztíží běžným
  uživatelům používání plného uzlu pro validování svých vlastních
  příchozích transakcí. Žádá Poinsota a jiné přispěvatele, aby namísto toho
  zvážili zaměřit se na snadnost používání Bitcoin Core. Popisuje sílu
  validování plným uzlem: ti, kteří provozují plné uzly validující převládající
  množství ekonomické aktivity, drží schopnost definovat bitcoinová pravidla
  konsenzu. Na příkladu ukazuje, že i pouhá 30minutová změna výběru
  vynucovaných pravidel může vést k politicky trvalému zničení opěvovaných
  vlastností bitcoinu, jako je omezení na 21 miliónů BTC. Věří, že každodenní
  uživatelé mají silnější motivaci zachovat vlastnosti bitcoinu než
  organizace provozující uzly pro své klienty. Pokud si vývojáři Bitcoin
  Core cení současných pravidel konsenzu, je dle Hardinga pro bezpečnost
  stejně důležité usnadňovat běžným uživatelům osobně ověřovat své transakce,
  jako je bránění a odstraňování chyb, které by mohly vést k vážným
  zranitelnostem.

## Diskuze o změnách konsenzu

_Měsíční rubrika shrnující návrhy a diskuze o změnách pravidel
bitcoinového konsenzu._

- **Průvodce forkováním bitcoinu:** Anthony Towns ve fóru Delving
  Bitcoin [ohlásil][towns bfg] průvodce budováním komunitního konsenzu
  pro změny bitcoinových pravidel konsenzu. Rozděluje sociální konsenzus
  do čtyř fází: výzkum a vývoj, zkoumání pokročilými uživateli, vyhodnocování
  průmyslem a posuzování investory. Dále se krátce zabývá technickými
  kroky, které přichází na konci procesu v rámci aktivace změn v bitcoinovém
  software.

  Jeho příspěvek poznamenává, že „je to jen průvodce cestou spolupráce, kde
  děláte změny, které zlepší život všech, a víceméně všichni se na tom
  nakonec shodnou.” Též varuje, že „průvodce hledí z dost velké výšky.”

- **Aktualizace BIP360 pay-to-quantum-resistant-hash (P2QRH):** vývojář
  Hunter Beast zaslal do emailové skupiny Bitcoin-Dev [aktualizaci][beast p2qrh]
  svého výzkumu [kvantové rezistence][topic quantum resistance] pro [BIP360][].
  Změnil obsah seznamu kvantově bezpečných algoritmů, které navrhuje používat,
  hledá advokáta vývoje schématu pay-to-taproot-hash (P2TRH, viz též [zpravodaj
  č. 141][news141 p2trh], _angl._) a zvažuje zaměřit se na stejnou bezpečnostní
  úroveň, jakou poskytuje současný bitcoin (NIST Ⅱ), namísto vyšší úrovně
  (NIST Ⅴ), která by vyžadovala více blokového prostoru a procesoru během
  validace. Jeho příspěvek obdržel několik reakcí.

- **Tržiště se soukromými šablonami bloků jako obrana před centralizujícím MEV:** Matt
  Corallo a vývojář 7d5x9 zaslali do fóra Delving Bitcoin [příspěvek][c7 mev]
  o veřejných aukcích vybraného prostoru uvnitř šablon bloků. Příklad:
  „zaplatím X BTC za začlenění transakce Y, pokud bude před jakoukoliv
  transakcí chytrého kontraktu Z.” Toto již dnes chtějí tvůrci transakcí
  některých bitcoinových protokolu (např. určité [protokoly s obarvenými mincemi][topic
  client-side validation]) a pravděpodobně to bude v budoucnosti ještě žádanější
  v nových protokolech (včetně návrhů vyžadujících změnu konsenzu jako některé
  [kovenanty][topic covenants]).

  Pokud by služba preferenčního pořadí transakcí v bloku nebyla poskytována
  veřejným trhem redukujícím potřebu důvěry, je pravděpodobné, že by byla
  poskytována velkými těžaři, kteří by soupeřili s uživateli rozličných
  protokolů. To si od těžařů vyžádá obdržet velké množství kapitálu
  a technologie, což jim zřejmě umožní vydělávat mnohem více než menším
  těžařům bez podobných schopností. To povede k centralizaci těžby a umožní
  velkým těžařům snadněji cenzurovat bitcoinové transakce.

  Vývojáři navrhují umožnit těžařům pracovat na zaslepených šablonách bloků,
  jejichž kompletní transakce jim nebudou odhaleny, dokud nevyprodukují
  proof of work dostatečný ke zveřejnění bloku. Vývojáři navrhují dva mechanismy,
  které nevyžadují žádné změny konsenzu:

  - **Důvěryhodné šablony bloků:** těžař se připojí k tržišti, zvolí nabídky,
    které chce začlenit do bloku, a požádá tržiště o konstrukci šablony bloku.
    Tržiště odpoví hlavičkou bloku, mincetvornou transakcí a částečnou
    Merkleovou větví, které těžařovi umožní generovat šabloně proof of work,
    aniž by se dozvěděl její obsah. Pokud těžař vyprodukuje _cílové_ množství
    proof of work, odešle tržišti hlavičku a mincetvornou transakci. Tržiště
    ověří proof of work, přidá ho do šablony a block zveřejní. Tržiště může
    začlenit transakci platící těžařovi přímo v šabloně nebo mu může zaplatit
    později.

  - **Důvěryhodné spouštěcí prostředí:** těžaři obdrží zařízení se zabezpečnou
    enklávou důvěryhodného spouštěcího prostředí (trusted execution environment,
    [TEE][]), připojí se k tržišti, vyberou si nabídky, které chtějí začlenit
    do svých bloků, a obdrží transakce z těchto nabídek zašifrované klíčem z
    TEE. Šablona bloku je zkonstruována uvnitř TEE a TEE poskytne hlavičku bloku,
    mincetvornou transakci a částečnou Merkleovu větev. Pokud je vygenerován
    dostatečný proof of work, těžař ho poskytne TEE, které ho ověří a vrátí
    kompletní nešifrovanou šablonu bloku, do které může těžař přidat hlavičku
    a zveřejnit. I zde může šablona bloku obsahovat transakci platící těžařovi
    z UTXO patřícímu tržišti nebo tržiště může těžařovi zaplatit později.

  Obě schémata by v důsledku vyžadovala několik soupeřících tržišť. Návrh
  zmiňuje očekávání, že někteří členové komunity a organizace by provozovali
  nevýdělečná tržiště, aby bránili vzniku dominantního tržiště a napomohli
  tak zachovat decentralizaci.

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [Core Lightning 25.02][] je vydáním další hlavní verze tohoto oblíbeného LN
  uzlu. Přináší vedle vylepšení a oprav i podporu [peer storage][topic peer storage]
  používaného pro ukládání zašifrovaných trestných transakcí, které mohou být
  vyžádány a dešifrovány jako druh [strážních věží][topic watchtowers].

## Významné změny kódu a dokumentace

_Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo] a [repozitáři BINANA][binana repo]._

- [Eclair #3019][] upřednostňuje v případě jednostranného zavření kanálu druhou stranou
  commitment transakci protistrany (z mempoolu) před zveřejněním místní transakce.
  Dříve uzel zveřejnil svou místní commitment transakci, což mohlo způsobit
  soupeření obou transakcí. Volba commitment transakce vzdálené strany je pro
  místní uzel výhodná, protože neobsahuje prodlevu místního `OP_CHECKSEQUENCEVERIFY` (CSV)
  [časového zámku][topic timelocks] a nepotřebuje dodatečné transakce pro vyřešení
  čekajících [HTLC][topic htlc].

- [Eclair #3016][] přináší nízkoúrovňové metody pro vytváření lightningových transakcí
  v [jednoduchých taprootových kanálech][topic simple taproot channels]. Žádné
  změny funkčnosti představeny nebyly. Skripty jsou vygenerovány z [miniscriptu][topic
  miniscript] a odlišují se od specifikace v [BOLTs #995][].

- [LDK #3342][] přidává strukturu `RouteParametersConfig`, která uživatelům umožňuje
  upravit parametry routování v [BOLT12][topic offers] platbách. Nově tak lze
  nastavit [`max_total_cltv_expiry_delta`][topic cltv expiry delta],
  `max_path_count` a `max_channel_saturation_power_of_half`. Tato změna odpovídá
  podobnému nastavení v [BOLT11][].

- [Rust Bitcoin #4114][] snižuje minimální velikost transakce bez witnessů z 85
  na 65 bajtů podobně jako Bitcoin Core (viz zpravodaje [č. 222][news222 minsize], _angl._,
  a [č. 232][news232 minsize]). Nově tak budou povolené i transakce s jedním vstupem
  a jedním `OP_RETURN` výstupem.

- [Rust Bitcoin #4111][] přidává podporu nového standardního výstupu [P2A][topic ephemeral
  anchors] představeného v Bitcoin Core 28.0 (viz [zpravodaj č. 315][news315 p2a]).

- [BIPs #1758][] aktualizuje [BIP374][], který definuje doklady rovnosti diskrétních logaritmů
  (Discrete Log Equality Proofs, [DLEQ][topic dleq]; viz též [zpraovdaj č. 335][news335 dleq]).
  Do výpočtu `rand` nově přidává zprávu. Změna brání možnému úniku soukromého klíče
  `a`, který mohl nastat, pokud byly dva doklady zkonstruovány se shodnými `a`, `b`
  a `g`, ale s odlišnými zprávami a nulovým `r`.

- [BIPs #1750][] aktualizuje [BIP329][], který definuje formát pro exportování [štítků
  peněženek][topic wallet labels]. Přidává volitelné pole asociované s adresami,
  transakcemi a výstupy.

- [BIPs #1712][] a [BIPs #1771][] přidávají [BIP3][], který nahrazuje [BIP2][].
  Mezi změny procesu schvalování BIP patří redukce hodnot stavu z devíti na čtyři,
  možnost zavřít návrh BIPu po roce nečinnosti a bez potvrzení autora o probíhající
  práci, možnost BIPu zůstat ve stavu Complete navždy, možnost dalších změn
  procesu schvalování, možnost delegovat některá editorská rozhodnutí na autory
  či čtenáře, odstranění systému komentářů a nutnost držet se tematického obsahu
  jako předpokladu pro obdržení čísla. Dále byly učiněny změny formátu a preambule.

{% include snippets/recap-ad.md when="2025-03-11 15:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="3019,3016,3342,4114,4111,1758,1750,1712,1771,1233,995" %}
[Core Lightning 25.02]: https://github.com/ElementsProject/lightning/releases/tag/v25.02
[news39 multiprocess]: /en/newsletters/2019/03/26/#bitcoin-core-10973
[news141 p2trh]: /en/newsletters/2021/03/24/#we-could-add-a-hash-style-address-after-taproot-is-activated
[poinsot pri]: https://delvingbitcoin.org/t/antoine-poinsot-on-bitcoin-cores-priorities/1470/
[poinsot pri1]: https://antoinep.com/posts/core_project_direction/
[poinsot pri2]: https://antoinep.com/posts/stating_the_obvious/
[poinsot pri3]: https://antoinep.com/posts/bitcoin_core_scope/
[towns pri]: https://delvingbitcoin.org/t/antoine-poinsot-on-bitcoin-cores-priorities/1470/3
[towns pri2]: https://delvingbitcoin.org/t/antoine-poinsot-on-bitcoin-cores-priorities/1470/15
[harding pri]: https://delvingbitcoin.org/t/antoine-poinsot-on-bitcoin-cores-priorities/1470/10
[towns bfg]: https://delvingbitcoin.org/t/bitcoin-forking-guide/1451
[beast p2qrh]: https://mailing-list.bitcoindevs.xyz/bitcoindev/8797807d-e017-44e2-b419-803291779007n@googlegroups.com/
[c7 mev]: https://delvingbitcoin.org/t/best-worst-case-mevil-response/1465
[tee]: https://en.wikipedia.org/wiki/Trusted_execution_environment
[news17 cln2000]: /en/newsletters/2018/10/16/#c-lightning-2000
[morehouse failback]: https://delvingbitcoin.org/t/disclosure-lnd-excessive-failback-exploit/1493
[lnd current]: https://github.com/lightningnetwork/lnd/releases
[news222 minsize]: /en/newsletters/2022/10/19/#minimum-relayable-transaction-size
[news232 minsize]: /cs/newsletters/2023/01/04/#bitcoin-core-26265
[news315 p2a]: /cs/newsletters/2024/08/09/#bitcoin-core-30352
[news335 dleq]: /cs/newsletters/2025/01/03/#bips-1689
