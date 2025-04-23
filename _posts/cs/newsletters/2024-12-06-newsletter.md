---
title: 'Zpravodaj „Bitcoin Optech” č. 332'
permalink: /cs/newsletters/2024/12/06/
name: 2024-12-06-newsletter-cs
slug: 2024-12-06-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Zpravodaj tento týden oznamuje odhalení zranitelnosti umožňující
cenzurování transakcí a shrnuje diskuzi o návrhu soft forku na
pročištění konsenzu. Též nechybí naše pravidelné rubriky s oznámeními
nových vydání a popisem významných změn v populárním bitcoinovém
páteřním software.

## Novinky

- **Zranitelnost umožňující cenzurování transakcí:** Antoine Riard zaslal
  do emailové skupiny Bitcoin-Dev [příspěvek][riard censor] s popisem
  metody na zabránění uzlu v odeslání transakce patřící připojené peněžence.
  Patří-li připojená peněženka uživatelovu LN uzlu, může být útok použit
  k zabránění zabezpečení prostředků, které mu patří, před vypršením časové
  lhůty. Tím by protistrana mohla tyto prostředky ukrást.

  Existují dvě verze útoku, z nichž obě zneužívají limity v Bitcoin Core
  spojené s maximálním počtem nepotvrzených transakcí, které uzel během
  určitého časového období rozešle nebo přijme. Tyto limity chrání spojení
  uzlu před nadměrnou zátěží a před útoky odepřením služby.

  První verze útoku nazývaná Riardem _horní přetečení_ (high overflow)
  zneužívá skutečnosti, že Bitcoin Core najednou odešle svým spojením
  maximálně 1 000 oznámení o nepotvrzených transakcích. Čeká-li ve frontě
  na odeslání více než 1 000 transakcí, jsou nejdříve oznámeny transakce
  s nejvyššími jednotkovými poplatky. Po odeslání dávky oznámení čeká
  Bitcoin Core před odesláním dalších transakcí, dokud nedosáhne průměrná
  rychlost odesílání oznámení sedm transakcí za sekundu.

  Pokud z prvních 1 000 oznámení platí všechny vyšší jednotkové poplatky
  než transakce, kterou chce oběť odeslat, a pokud útočník nadále posílá
  uzlu oběti nejméně sedm transakcí s vyšším jednotkovým poplatkem za sekundu,
  může útočník ve zveřejnění transakce bránit donekonečna. Většina útoků na LN
  by potřebovala pozdržet zveřejnění na 32 bloků (výchozí nastavení Core
  Lightning) až 140 bloků (výchozí nastavení Eclair), což by při 10 sat/vbyte
  mohlo stát mezi 1,3 BTC (3 000 000 Kč) a 5,9 BTC (14 000 000 Kč), ačkoliv
  Riard poznamenává, že opatrný útočník, který je dobře připojený k jiným
  přeposílajícím uzlům (nebo přímo k velkým těžařům), by mohl tyto náklady
  výrazně snížit.

  Druhá verze útoku, kterou Riard nazývá _spodní přetečení_ (low overflow),
  zneužívá omezení Bitcoin Core, které nepovolí umístit do fronty
  více než 5 000 nevyžádaných transakcí na jedno spojení. Útočník pošle
  oběti obrovské množství transakcí s minimálním jednotkovým poplatkem.
  Oběť je oznámí svým čestným spojením a ta zařadí oznámení do fronty.
  Opakovaně se potom pokouší frontu vyprázdnit vyžadováním transakcí, avšak
  deficit se navyšuje, dokud nedosáhne limitu 5 000 oznámení. V ten okamžik
  začnou spojení další oznámení ignorovat, dokud se fronta částečně nevyprázdní.
  Je-li čestná transakce oběti oznámena během této doby, spojení ji budou
  ignorovat. Tento útok může být výrazně levnější než horní přetečení,
  neboť útočníkovy škodlivé transakce mohou platit minimální poplatek
  nutný pro přeposílání. Útok však může být méně spolehlivý, útočník tak
  může ztratit peníze utracené za poplatky, aniž by krádeží něco získal.

  V normální situaci se tyto útoky nejeví jako příliš vážné. Jen velmi málo
  kanálů bude mít platby čekající na vyřízení, které by převyšovaly náklady
  na útok. Riard doporučuje, aby uživatelé LN kanálů s vysokou hodnotou
  provozovali další plné uzly, včetně takových, které by neakceptovaly příchozí
  spojení a které by přijímaly a přeposílaly pouze bloky, aby bylo zaručené,
  že budou přeposílat nepotvrzené transakce pouze od vlastní peněženky.
  Sofistikovanější útoky, které umí náklady snížit, nebo útoky, které
  používají stejnou sadu škodlivých transakcí k útoku na více LN kanálů
  najednou, by mohly mít dopad i na kanály s nižšími hodnotami. Riard
  navrhuje LN implementacím několik opatření. Možné změny P2P protokolu
  v Bitcoin Core, které by tento problém adresovaly, ponechává na pozdější
  diskuzi.

  _Poznámka čtenářům:_ omlouváme se, pokud jsou v tomto popisu nějaké chyby.
  O tomto odhalení jsme se dozvěděli jen krátce před zveřejněním tohoto
  čísla zpravodaje.

- **Pokračuje diskuze o návrhu soft forku na pročištění konsenzu:**
  Antoine Poinsot připojil do existujícího vlákna ve fóru Delving Bitcoin
  o navrhovaném soft forku [pročištění konsenzu ][topic consensus cleanup]
  nový [příspěvek][poinsot time warp], ve kterém vedle již navržené opravy
  klasické [zranitelnosti způsobené ohýbáním času][topic time warp]
  navrhuje též přidat opravu nedávno objeveného Zawyho-Murchova ohýbání
  času (viz [zpravodaj č. 316][news316 time warp]). Upřednostňoval by
  opravu, kterou původně navrhl Mark „Murch” Erhardt: „požadovat, aby
  poslední blok periody měl vyšší časové razítko než první blok stejné
  periody.”

  Anthony Towns [vyjádřil][towns time warp] preferenci nad jiným řešením,
  které navrhl Zawy. Toto řešení by zakázalo blokům tvrdit, že byly vytvořené
  více než dvě hodiny před kterýmkoliv předchozím blokem. Zawy [poznamenal][zawy
  time warp], že jeho řešení by těžařům zvýšilo riziko ztráty peněz v případě
  používání staršího software, avšak na druhou stranu by zpřesnilo časová
  razítka pro jiné účely, jako jsou [časové zámky][topic timelocks].

  Poinsot dále ve fóru [Delving Bitcoin][poinsot duptx delv] i v emailové
  skupině [Bitcoin-Dev][poinsot duptx ml] žádal o poskytnutí zpětné vazby
  k výběru řešení pro zabránění bloku 1 983 702 a několika pozdějších
  [v duplikaci][topic duplicate transactions] předchozí coinbasové transakce
  (což by mohlo vyústit ve ztrátu peněz a k tvorbě nových útoků). Prezentovány
  jsou čtyři návrhy řešení, z nichž každé by mělo přímý dopad na těžaře.
  [Jejich zpětná vazba][mining-dev] je tedy obzvláště žádoucí.

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [Eclair v0.11.0][] je nejnovějším vydáním této oblíbené implementace
  LN uzlu. „Přidává oficiální podporu pro BOLT12 [nabídky][topic offers]
  a zlepšuje funkce pro správu likvidity ([splicing][topic splicing],
  [inzeráty likvidity][topic liquidity advertisements] a [financování za
  běhu][topic jit channels]).” Vydání dále přestává přijímat ne[anchor
  kanály][topic anchor outputs] a přináší optimalizace a opravy chyb.

- [LDK v0.0.125][] je nejnovějším vydáním této knihovny pro budování aplikací
  s LN. Obsahuje opravy několika chyb.

- [Core Lightning 24.11rc3][] je kandidátem na vydání příští hlavní verze této
  oblíbené implementace LN.

- [LND 0.18.4-beta.rc1][] je kandidátem na vydání menší verze této populární
  implementace LN.

- [Bitcoin Core 28.1RC1][] je kandidátem na vydání údržbové verze této převládající
  implementace plného uzlu.

## Významné změny kódu a dokumentace

_Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Bitcoin Inquisition][bitcoin inquisition repo] a [repozitáři BINANA][binana
repo]._

- [Bitcoin Core #30708][] přidává RPC příkaz `getdescriptoractivity`, který
  v rámci stanovené množiny bloků vyhledá všechny transakce spojené
  s [deskriptorem][topic descriptors]. Peněženky tím budou moci s Bitcoin
  Core komunikovat bezstavově. Příkaz je obzvláště užitečný ve spolupráci
  se `scanblocks` (viz [zpravodaj č. 222][news222 scanblocks], _angl._),
  který vrátí seznam hašů bloků obsahujících transakce asociované s deskriptorem.

- [Core Lightning #7832][] utrácí z [anchor výstupů][topic anchor outputs]
  též u transakcí neurgentních jednostranných zavření kanálu. Na začátku bude
  cílit 2016 bloků (zhruba dva týdny), postupně se cíl bude snižovat až na
  12 bloků. Tyto hodnoty budou ukládány, aby se zachovala konzistence mezi
  restarty. Dříve tento druh transakcí ve výchozím stavu z anchor výstupů
  neutrácel a bylo obtížné tak učinit manuálně a nemožné navýšit poplatek pomocí
  [CPFP][topic cpfp].

- [LND #8270][] implementuje protokol chvíle ticha (channel quiescence) dle
  specifikace v [BOLT2][] (viz [zpravodaj č. 309][news309 quiescence]).
  Podpora protokolu je předpokladem pro [dynamické commitmenty][topic channel
  commitment upgrades] a pro [splicing][topic splicing]. Umožňuje uzlu
  reagovat na žádost protistrany o chvíli ticha i tento proces iniciovat
  pomocí nových operací v `ChannelUpdateHandler`. PR též přidává nastavitelnou
  lhůtu pro nakládání se spojeními, které dlouho neodpovídají. Taková spojení
  budou odpojena, pokud chvíle ticha trvá příliš dlouho.

- [LND #8390][] přináší podporu pro nastavení a šíření hodnoty pole pro
  signalizaci experimentálních [HTLC atestací][topic htlc endorsement] ve
  zprávách `update_add_htlc`. Cílem změny je výzkum prevence [útoku zahlcením
  kanálu][topic channel jamming attacks]. Pokud uzel obdrží HTLC s tímto
  signalizačním polem, přepošle jej beze změny, jinak nastaví jeho hodnotu
  na nulu. Tato funkce je ve výchozím nastavení aktivní, avšak lze ji vypnout.

- [BIPs #1534][] začleňuje BIP349 specifikující nový [tapscriptový][topic tapscript]
  (BIP342) opkód `OP_INTERNALKEY`, který umístí taprootový interní klíč
  do zásobníku. Autoři skriptů potřebují znát interní klíč před tím, než
  mohou na výstup platit. Tento mechanismus poskytuje alternativu k přidání
  interního klíče přímo do skriptu, čímž při každém použití ušetří 8 vbyte
  a skripty budou moci být snáze opakovaně použitelné (viz [zpravodaj
  č. 285][news285 bip349]).

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 15:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="30708,7832,8270,8390,1534" %}
[core lightning 24.11rc3]: https://github.com/ElementsProject/lightning/releases/tag/v24.11rc3
[lnd 0.18.4-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.18.4-beta.rc1
[news316 time warp]: /cs/newsletters/2024/08/16/#nova-zranitelnost-ohybanim-casu-v-testnet4
[poinsot time warp]: https://delvingbitcoin.org/t/great-consensus-cleanup-revival/710/53
[towns time warp]: https://delvingbitcoin.org/t/great-consensus-cleanup-revival/710/54
[zawy time warp]: https://delvingbitcoin.org/t/great-consensus-cleanup-revival/710/55
[poinsot duptx delv]: https://delvingbitcoin.org/t/great-consensus-cleanup-revival/710/51
[poinsot duptx ml]: https://groups.google.com/g/bitcoindev/c/KRwDa8aX3to
[mining-dev]: https://groups.google.com/g/bitcoinminingdev/c/qyrPzU1WKSI
[eclair v0.11.0]: https://github.com/ACINQ/eclair/releases/tag/v0.11.0
[ldk v0.0.125]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.0.125
[bitcoin core 28.1RC1]: https://bitcoincore.org/bin/bitcoin-core-28.1/
[riard censor]: https://groups.google.com/g/bitcoindev/c/GuS36ldye7s
[news222 scanblocks]: /en/newsletters/2022/10/19/#bitcoin-core-23549
[news309 quiescence]: /cs/newsletters/2024/06/28/#bolts-869
[news285 bip349]: /cs/newsletters/2024/01/17/#navrh-noveho-soft-forku-lnhance
