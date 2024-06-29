---
title: 'Zpravodaj „Bitcoin Optech” č. 309'
permalink: /cs/newsletters/2024/06/28/
name: 2024-06-28-newsletter-cs
slug: 2024-06-28-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Zpravodaj tento týden shrnuje výzkum odhadování pravděpodobnosti proveditelnosti
LN plateb. Též nechybí naše pravidelné rubriky s popisem populární otázek
a odpovědí z Bitcoin Stack Exchange, oznámeními o nových vydáních a souhrnem
významných změn v populárních bitcoinových páteřních projektech.

## Novinky

- **Odhad pravděpodobnosti úspěšného provedení LN platby:** René
  Pickhardt zaslal do fóra Delving Bitcoin [příspěvek][pickhardt feasible1]
  o odhadování pravděpodobnosti, zda je LN platba proveditelná. Pro odhad
  je použita pouze veřejná znalost maximální kapacity kanálů, nikoliv
  aktuální distribuce zůstatků. Například má-li Alice kanál s Bobem a Bob
  má kanál s Carol, zná Alice kapacitu kanálu Bob–Carol, avšak neví, jaká
  část této kapacity je na Bobově straně a jaká část je pod kontrolou Carol.

  Pickhardt poznamenává, že některá rozložení zůstatku nejsou v síti možná.
  Například Carol nemůže kanálem od Boba obdržet více peněz, než kolik je
  celá kapacita kanálu. Pokud vyloučíme všechna nemožná rozložení,
  může být užitečné považovat všechna ostatní rozložení za shodně pravděpodobná.
  Díky tomu je možné vytvořit metriku pravděpodobnosti, že platba
  je proveditelná.

  Mějme příklad, ve kterém chce Alice poslat 1 BTC Carol a jediné možné kanály
  jsou Alice–Bob a Bob–Carol. Můžeme se potom podívat, jaká procenta
  distribuce prostředků v kanálech Alice–Bob a Bob–Carol by mohla vést k
  úspěšnému provedení této platby. Má-li kanál Alice–Bob kapacitu několika
  BTC, většina možných rozdělení by umožnila úspěšnou platbou. Má-li
  kanál Bob–Carol kapacitu jen málo přes 1 BTC, většina možných rozdělení
  prostředků by platbě zabránila. To může být použito k výpočtu celkové
  pravděpodobnosti proveditelnosti platby 1 BTC mezi Alicí a Carol.

  Pravděpodobnost provedení platby ukazuje, že mnoho LN plateb, které se
  na první pohled zdají možné, ve skutečnosti neuspěje. Dále poskytuje užitečný
  základ pro další porovnání. Ve své [odpovědi][pickhardt feasible2] popisuje
  Pickhardt, jak by metrika pravděpodobnosti mohla být použita peněženkami
  a business software k provádění některých automatických rozhodnutí za
  uživatele.

## Vybrané otázky a odpovědi z Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] je jedním z prvních míst, kde hledají
přispěvatelé Optechu odpovědi na své otázky a kde – najdou-li volnou chvíli –
pomáhají zvědavým či zmateným uživatelům. V této měsíční rubrice nabízíme
některé z otázek a odpovědí, které obdržely vysoký počet hlasů.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aa
nswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Jak se počítá průběh prvotního stahování bloků (IBD)?]({{bse}}123350)
  Pieter Wuille odkazuje na funkci `GuessVerificationProgress` v Bitcoin Core
  a vysvětluje, že odhad celkového počtu transakcí v blockchainu používá
  napevno zakódovanou statistiku, která je aktualizována jako součást každého
  vydání.

- [Co znamená „Postup za hodinu” během synchronizace?]({{bse}}123279)
  Pieter Wuille vysvětluje, že postup za hodinu (progress increase per hour) je
  procento blockchainu synchronizovaného za hodinu a neznamená zvýšení tempa
  postupu. Dále vyjmenovává důvody, proč postup není konstantní a může se měnit.

- [Měla by sudá souřadnice Y být vynucena po každém tweaku nebo jen na konci?]({{bse}}119485)
  Pieter Wuille souhlasí, že je převážně věcí názoru, kdy provést negaci klíče
  k vynucení [veřejných klíčů pouze s x-ovou souřadnicí][topic X-only public keys].
  Dále vyjmenovává výhody a nevýhody v rámci různých protokolů.

- [Mobilní signetové peněženky?]({{bse}}123045)
  Murch vyjmenovává čtyři mobilní peněženky kompatibilní se [signetem][topic signet]:
  Nunchuk, Lava, Envoy a Xverse.

- [Který blok měl největší transakční poplatky? Proč?]({{bse}}7582)
  Murch odhaluje, že blok 409 008 měl nejvyšší bitcoinový poplatek (291 533 BTC
  kvůli chybějícímu výstupu pro zbytek) a blok 818 087 měl nejvyšší dolarový
  poplatek (3 189 221,50 USD zřejmě též kvůli chybějícímu výstupu pro zbytek).

- [bitcoin-cli listtransactions ukazuje poplatky úplně mimo, proč?]({{bse}}123391)
  Ava Chow poznamenává, že k tomuto rozporu dochází, pokud peněženka Bitcoin Core
  nezná jeden ze vstupů transakce, ale zná ostatní, jak lze vidět na příkladu
  [payjoinové][topic payjoin] transakce poskytnutém v otázce. Dále dodává:
  „Jelikož zde peněženka neumí přesně určit poplatek, neměla by ho vůbec zobrazovat.”

- [Používaly nekomprimované veřejné klíče prefix `04`, než začaly být používané komprimované?]({{bse}}123252)
  Pieter Wuille vysvětluje, že historicky bylo ověřování podpisů prováděno knihovnou OpenSSL,
  která akceptuje veřejné klíče nekomprimované (prefix `04`), komprimované (`02` a `03`)
  nebo smíšené (`06` a `07`).

- [Co se stane, je-li hodnota HTLC pod prahem ekonomičnosti?]({{bse}}123393)
  Antoine Poinsot ukazuje, že výstup LN commitment transakce, který by měl
  hodnotu pod [prahem ekonomičnosti][topic uneconomical outputs] (dust limit),
  by byl použit na placení poplatku (viz [ořezaná HTLC][topic trimmed htlc]).

- [Jak funguje subtractfeefrom?]({{bse}}123262)
  Murch poskytuje přehled, jak funguje [výběr mincí][topic coin selection] v Bitcoin
  Core, je-li aktivní volba `subtractfeefrom`. Dále poznamenává, že používání
  `subtractfeefromoutput` způsobuje několik chyb během hledání transakcí bez zbytku.

- [Jaký je rozdíl mezi adresáři `blocks/index/`, `bitcoin/indexes` a `chainstate`?]({{bse}}123364)
  Ava Chow objasňuje význam adresářů v Bitcoin Core:

  - `blocks/index/` obsahuje LevelDB databázi s indexem bloků
  - `chainstate/` obsahuje LevelDB databázi s množinou UTXO
  - `indexes/` obsahuje volitelné indexy txindex, coinstatsindex a blockfilterindex

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [LND v0.18.1-beta][] je menší vydání s opravou „[problému][lnd #8862], který se objevuje
  během vypořádání se s chybou způsobenou pokusem o zveřejnění transakce s btcd backendem
  starší verze (před v0.24.2).”

- [Bitcoin Core 26.2rc1][] je kandidátem na vydání údržbové verze série starších vydání
  Bitcoin Core.

## Významné změny kódu a dokumentace

_Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Bitcoin Inquisition][bitcoin inquisition repo] a [repozitáři BINANA][binana
repo]._

- [Bitcoin Core #29575][] zjednodušuje systém hodnocení špatného chování
  spojení tím, že používá pouze dva inkrementy: 100 bodů (znamenající okamžité
  odpojení a odrazování) a 0 bodů (chování akceptováno). Většině druhů špatného
  chování se lze vyhnout a bylo jim přiřazeno skóre 100. Dva typy chování,
  které mohou za určitých okolností vykazovat čestné a správně fungující uzly,
  byly sníženy na 0 bodů. Toto PR dále odstraňuje heuristiku, která pokládala
  pouze P2P zprávy `headers` s nejvýše osmi hlavičkami bloků za možná oznámení
  nových bloků dle [BIP130][]. Bitcoin Core bude nově pokládat všechny zprávy
  `headers`, které nepřipojují ke známému stromu bloků, jako potenciální oznámení
  o nových blocích a žádosti o chybějící bloky.

- [Bitcoin Core #28984][] přidává podporu omezené verze [nahrazování poplatkem][topic rbf]
  (RBF) pro [balíčky][topic package relay] velikost clusteru dva (jeden rodič, jeden
  potomek) včetně [TRUC][topic v3 transaction relay] transakcí (do potvrzení topologicky
  omezených, známé též jako v3 transakce). Tyto clustery mohou nahradit pouze existující
  clustery stejné nebo menší velikost. [Zpravodaj č. 296][news296 packagerbf] obsahuje
  další informace.

- [Core Lightning #7388][] odstraňuje schopnost vytvářet [anchorové][topic anchor outputs]
  kanály s nenulovým poplatkem. Tím dosáhne souladu se změnami v BOLT specifikaci
  představenými v roce 2021 (viz [zpravodaj č. 165][news165 anchors], _angl._).
  Podpora pro existující kanály zůstává zachována. Core Lightning byl jedinou implementací,
  která podporu přidala (a to pouze v experimentálním režimu) před tím, než bylo
  zjištěno, že se nejedná o bezpečné schéma (viz [zpravodaj č. 115][news115 anchors], _angl._),
  a než bylo nahrazeno anchory s nulovými poplatky. Mezi dalšími změnami je
  odmítání `encrypted_recipient_data` obsahující zároveň `scid` i `node`, zpracovávání
  LaTeXového formátu přidaného do onion specifikace a další změny zmíněné ve
  zpravodajích [č. 259][news259 bolts] a [č. 305][news305 bolts].

- [LND #8734][] vylepšuje nakládání s uživatelem přerušeným procesem odhadu poplatku za
  cestu (`lncli estimateroutefee`). Dříve server i po přerušení tohoto příkazu
  pokračoval ve zbytečném [sondování][topic payment probes]. [Zpravodaj č. 293][news293
  routefee] též zmiňuje tento RPC příkaz.

- [LDK #3127][] implementuje nestriktní přeposílání dle specifikace v [BOLT4][], které
  by mělo vylepšit spolehlivost plateb tím, že umožní přeposílat [HTLC][topic htlc]
  i přes kanály, které nejsou v onion zprávě specifikovány jako `short_channel_id`.
  Vybrány jsou vhodné kanály s nejnižší odchozí likviditou, aby byla maximalizována
  pravděpodobnost úspěchu budoucích HLTC.

- [Rust Bitcoin #2794][] implementuje vynucování limitu velikosti redeem skriptu 520 bajtů
  u P2SH a limitu velikosti witness skriptu 10 000 bajtů u P2WSH. Konstruktory pro
  `ScriptHash` a `WScriptHash` tak mohou nově vrátit chybu.

- [BDK #1395][] odstraňuje závislost na `rand` a nahrazuje ji `rand-core`. Tím se zjednodušil
  strom závislostí, odstranila se složitost `thread_rng` a `getrandom` a uživatelům byla
  umožněna větší flexibilita možností poskytnout vlastní generátor náhodných čísel.

- [BIPs #1620][] a [BIPs #1622][] přidávají změny do specifikace [BIP352][] [tichých plateb][topic
  silent payments]. První změnou je ošetření nevalidních součtů soukromých i veřejných
  klíčů pro posílání a skenování: pokud je soukromý klíč nulový nebo veřejný klíč je
  bodem v nekonečnu. #1622 mění provádění kalkulace `input_hash` po agregaci klíčů (dříve
  byla prováděna před agregací), čímž se proces zjednoduší.

- [BOLTs #869][] přidává do BOLT2 nový protokol quiescence („chvíle ticha“), díky kterému
  budou [upgradování protokolu][topic channel commitment upgrades] a změny platebních kanálů
  bezpečnější a efektivnější. Protokol představuje novou zprávu `stfu` (SomeThing Fundamental
  is Underway čili „něco velkého se děje”; též zkratka vulgární žádosti o ticho), která může
  být poslána, pokud je přítomna volba `option_quiesce`. Po odeslání `stfu` nebude odesílatel
  posílat žádné další aktualizace. Příjemce by rovněž měl pozastavit posílání všech aktualizací stavu
  a odpovědět `stfu`, pokud možno. Kanál by tak měl být zcela tichý. Viz též zpravodaje
  [č. 152][news152 quiescence] (_angl._) a [č. 262][news262 quiescence].

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="29575,28984,7388,8734,3127,2794,1395,1620,1622,869,8862" %}
[bitcoin core 26.2rc1]: https://bitcoincore.org/bin/bitcoin-core-26.2/
[pickhardt feasible1]: https://delvingbitcoin.org/t/estimating-likelihood-for-lightning-payments-to-be-in-feasible/973
[pickhardt feasible2]: https://delvingbitcoin.org/t/estimating-likelihood-for-lightning-payments-to-be-in-feasible/973/4
[lnd v0.18.1-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.18.1-beta
[news296 packagerbf]: /cs/newsletters/2024/04/03/#bitcoin-core-29242
[news259 bolts]: /cs/newsletters/2024/05/31/#bolts-1092
[news305 bolts]: /cs/newsletters/2023/07/12/#navrh-na-procisteni-specifikace-ln
[news293 routefee]: /cs/newsletters/2024/03/13/#lnd-8136
[news152 quiescence]: /en/newsletters/2021/06/09/#c-lightning-4532
[news262 quiescence]:/cs/newsletters/2023/08/02/#eclair-2680
[news115 anchors]: /en/newsletters/2020/09/16/#stealing-onchain-fees-from-ln-htlcs
[news165 anchors]: /en/newsletters/2021/09/08/#bolts-824
