---
title: 'Zpravodaj „Bitcoin Optech” č. 292'
permalink: /cs/newsletters/2024/03/06/
name: 2024-03-06-newsletter-cs
slug: 2024-03-06-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Zpravodaj tento týden shrnuje diskuzi o aktualizaci specifikace URI typu
`bitcoin:` dle BIP21, popisuje návrh na správu několika souběžných sezení
MuSig2 s minimálním stavem, odkazuje na vlákno o přidání editorů repozitáře
BIPů a představuje soubor nástrojů, který by umožnil rychle přemístit projekt
Bitcoin Core z GitHubu na vlastní instanci GitLabu. Též nechybí naše pravidelné
rubriky s oznámeními nových vydání a souhrnem nedávných změn v populárním
bitcoinovém páteřním software.

## Novinky

- **Aktualizace BIP21 pro URI typu `bitcoin:` :** Josie Baker zaslal
  do fóra Delving Bitcoin [příspěvek][baker bip21] o URI dle [BIP21][]:
  jak je jejich používání specifikováno, jak jsou dnes používány a jak
  by mohly být používány v budoucnosti. Specifikace vyžaduje, aby ihned
  za dvojtečkou následoval zastaralý druh P2PKH adresy, např. `bitcoin:1BoB...`.
  Po této části mohou být předány další parametry včetně novějších formátů
  adres, například bech32m adresa: `bitcoin:1Bob...?bech32m=bc1pbob...`.
  Avšak tento způsob se významně odlišuje od současného běžného používání.
  Adresy odlišné od P2PKH jsou často posazeny hned za dvojtečku a někdy tato
  pozice ani obsazená není, pokud chce software přijímat platby pouze pomocí
  alternativních platebních protokolů. Dále Baker poznamenává, že adresy
  `bitcoin:` se více a více používají pro přenos trvalých identifikátorů
  pro platby respektující soukromí, jako jsou [tiché platby][topic silent payments]
  či [nabídky][topic offers].

  Dle diskutujících ve vlákně by zlepšením bylo, kdyby mohl autor URI
  specifikovat všechny podporované způsoby plateb jako parametry bez
  klíčů, např. `bitcoin:?bc1q...&sp1q...`. Plátce (který je obvykle
  zodpovědný za platbu poplatků) by si tak mohl ze seznamu vybrat
  preferovanou metodu. Ač byly v době psaní zpravodaje některé technické
  drobnosti stále diskutovány, žádná vážnější kritika se ve vlákně neobjevila.

- **PSBT pro více současně probíhajících MuSig2 sezení:** Salvatore
  Ingala zaslal do fóra Delving Bitcoin [příspěvek][ingala musig2] o minimalizaci
  stavu potřebného pro vykonání několika paralelně běžících podepisovacích sezení
  [MuSig2][topic musig]. Pomocí podpisového algoritmu popsaného v [BIP327][]
  bude skupina podepisujících potřebovat dočasně uložit lineárně se zvyšující
  množství dat pro každý dodatečný vstup, který chtějí přidat do podepisované
  transakce. Mnoho hardwarových podpisových zařízení má k dispozici pouze omezené
  úložiště, bylo by tedy vhodné jejich vyžadované množství minimalizovat
  bez negativního dopadu na bezpečnost.

  Ingala navrhuje vygenerovat jediný stavový objekt pro celé [PSBT][topic psbt]
  a z něj deterministicky odvodit stav pro každý vstup. Odvozování musí
  zaručit, že je jeho výsledek nerozlišitelný od náhodných dat. Tímto
  způsobem by bylo množství stavových dat, která zařízení podepisuje,
  konstantní a tedy nezávislé na počtu podepisovaných vstupů.

  Vývojář Christopher Scott ve své [reakci][scott musig2] poznamenal,
  že [BitEscrow][] již podobný mechanismus používá.

- **Diskuze o přidání dalších editorů BIPů:** Ava Chow zaslala do emailové
  skupiny Bitcoin-Dev [příspěvek][chow bips] s návrhem na přidání editorů
  BIPů, aby pomohli editorům současným. Jeden z nich, Luke Dashjr,
  [říká][dashjr backlogged], že práci na BIPech nestíhá a požádal o pomoc.
  Chow navrhla, aby se dva známí přispěvatelé stali editory, což se
  setkalo s podporou. Dále se diskutovalo, zda by noví editoři měli mít
  schopnost přiřazovat čísla BIPů. V době psaní nebylo dosaženo jasného
  závěru.

- **Záloha githubového projektu Bitcoin Core na GitLabu:** Fabian Jahr
  zaslal do fóra Delving Bitcoin [příspěvek][jahr gitlab] informující
  o udržování zálohy projektu Bitcoin Core (původně hostovaném na
  GitHubu) na vlastní instanci GitLabu. V případě, že by projekt
  náhle potřeboval GitHub opustit, mohly by být na GitLabu rychle zpřístupněny
  pull requesty a hlášení chyb, což by umožnilo pokračovat v práci jen
  s krátkým přerušením. Jahr poskytl náhled projektu na Gitlabu a plánuje
  zálohy udržovat pro případ náhlé potřeby na GitLab přejít. Jeho příspěvek
  neobdržel v době psaní žádné komentáře, avšak my mu děkujeme za
  usnadnění případného přechodu.

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [Eclair v0.10.0][] je novým vydáním této implementace LN uzlu. „Přidává oficiální
  podporu pro [oboustranné financování][topic dual funding], aktualizuje
  implementaci [nabídek][topic offers] dle BOLT12 a přináší zcela funkční
  prototyp [splicingu][topic splicing].” Dále obsahuje „rozličná vylepšení
  související s onchain poplatky, více možností nastavení, výkonnostní
  zlepšení a opravy drobných chyb.”

- [Bitcoin Core 26.1rc1][] je kandidátem na údržbové vydání této převládající
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

- [Bitcoin Core #29412][] přidává kód, který prověří každý známý způsob
  modifikace, jež z validního bloku činí nevalidní za zachování stejného
  hashe hlavičky. Modifikované bloky v minulosti způsobily několik zranitelností.
  V letech 2012 a 2017, kdy Bitcoin Core cachoval odmítnutí nevalidních bloků,
  mohl útočník vzít validní blok, modifikovat ho a jako nevalidní jej podstrčit
  uzlu oběti. Tento uzel by blok odmítl jako nevalidní a později by nepřijal
  ani validní formu tohoto bloku (dokud by uzel nebyl restartován). Tímto
  druhem [útoku zastíněním][topic eclipse attacks] by tak v uzlu oběti způsobil
  štěpení blokchainu (viz [zpravodaj č. 37][news37 invalid], _angl._, pro další
  podrobnosti). Další potíže nastaly v nedávné době, když Bitcoin Core vyžádal
  od jednoho spojení blok a jiné spojení mu podstrčilo modifikovaný blok. Bitcoin
  Core potom od prvního spojení žádné další bloky neobdržel. Oprava byla popsána
  ve [zpravodaji č. 251][news251 block].

  Kód přidaný tímto PR umožňuje rychle zkontrolovat, zda právě obdržený blok
  obsahuje některou ze známých modifikací, které by jej učinily nevalidním.
  Pokud ano, může být nevalidní blok odmítnut hned na začátku a nebude tak
  příčinou odmítnutí validního bloku později.

- [Eclair #2829][] umožňuje pluginům stanovit pravidla přispívání prostředků
  během otevírání [kanálů s oboustranným financováním][topic dual funding].
  Ve výchozím stavu nepřispívá Eclair do kanálů s oboustranným financováním
  žádnými prostředky. Toto PR nabízí pluginům toto pravidlo přepsat a
  rozhodnout, kolik prostředků provozovatele uzlu může být na nový kanál
  použito.

- [LND #8378][] přináší několik vylepšení [výběru mincí][topic coin selection].
  Mimo jiné umožňuje uživatelům zvolit strategii výběru a vybrat vstupy,
  které musí být součástí transakce. Algoritmus však může v případě potřeby
  přispět dalšími vstupy.

- [BIPs #1421][] přidává [BIP345][] pro opkód `OP_VAULT` a související změny
  konsenzu, které by v případě aktivace soft forkem přinesly podporu
  [úschoven][topic vaults] (vaults). Narozdíl od úschoven dostupných dnes
  použitím předem podepsaných transakcí jsou úschovny dle BIP345 odolné
  vůči útokům nahrazení transakce na poslední chvíli. Úschovny dle BIP345
  dále umožňují [dávkové][topic payment batching] operace, díky kterým
  jsou účinnější než většina návrhů používající pouze obecnější
  mechanismus [kovenantů][topic covenants].

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 15:00" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="29412,2829,8378,1421" %}
[jahr gitlab]: https://delvingbitcoin.org/t/gitlab-backups-for-bitcoin-core-repository/624
[ingala musig2]: https://delvingbitcoin.org/t/state-minimization-in-musig2-signing-sessions/626
[scott musig2]: https://delvingbitcoin.org/t/state-minimization-in-musig2-signing-sessions/626/2
[baker bip21]: https://delvingbitcoin.org/t/revisiting-bip21/630
[bitescrow]: https://github.com/BitEscrow/escrow-core
[chow bips]: https://gnusha.org/pi/bitcoindev/2092f7ff-4860-47f8-ba1a-c9d97927551e@achow101.com/
[dashjr backlogged]: https://twitter.com/LukeDashjr/status/1761127972302459000
[news37 invalid]: /en/newsletters/2019/03/12/#bitcoin-core-vulnerability-disclosure
[news251 block]: /cs/newsletters/2023/05/17/#bitcoin-core-27608
[eclair v0.10.0]: https://github.com/ACINQ/eclair/releases/tag/v0.10.0
[bitcoin core 26.1rc1]: https://bitcoincore.org/bin/bitcoin-core-26.1/
