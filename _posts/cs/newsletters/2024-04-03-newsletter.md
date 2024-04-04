---
title: 'Zpravodaj „Bitcoin Optech” č. 296'
permalink: /cs/newsletters/2024/04/03/
name: 2024-04-03-newsletter-cs
slug: 2024-04-03-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Zpravodaj tento týden shrnuje diskuzi a obnoveném úsilí na soft fork
pročišťující konsenzus a oznamuje plán na výběr nových editorů BIPů
před koncem tohoto týdne. Též nechybí naše pravidelné rubriky
s oznámeními o nových verzích a popisem významných změn v populárním
bitcoinovém páteřním software.

## Novinky

- **Návrat k tématu pročištění konsenzu:** Antoine Poinsot zaslal do
  fóra Delving Bitcoin [příspěvek][poinsot cleanup], ve kterém připomíná
  návrh Matta Coralla z roku 2019 na [pročištění konsenzu][topic consensus
  cleanup] (viz [zpravodaj č. 36][news36 cleanup], _angl._). Na začátek
  se pokouší kvantifikovat nejhorší scénáře několika problémů, které
  by návrh odstranil, včetně možnosti vytvořit blok, jehož ověření
  by na moderním laptopu zabralo přes tři minuty a na Raspberry Pi 4 kolem
  1,5 hodiny, schopnosti těžařů pomocí [útoku ohýbáním času][topic time warp]
  („time warp attack”) ukrást odměny a snížit bezpečnost LN po
  zhruba jednoměsíční přípravě či schopnosti klamem přinutit lehké klienty
  k přijetí falešných transakcí ([CVE-2017-12842][topic cves]) a plné
  uzly k odmítání validních bloků (viz [zpravodaj č. 37][news37 trees], _angl._).

  Nad rámec Corallova původního návrhu doporučuje Poinsot vypořádat
  se <!-- intentional --> se zbývajícím problémem [duplikovaných transakcí][topic duplicate
  transactions], který začne postihovat plné uzly při výšce 1 983 702 (a již postihuje uzly
  na testnetu).

  Všechny zmíněné problémy mají technicky jednoduchá řešení, která mohou
  být nasazena soft forkem. Dříve nevržené řešení problému s pomalým ověřováním
  bloků bylo mírně kontroverzní, jelikož by mohlo zneplatnit skripty, které
  by teoreticky mohly být použity v předem podepsaných transakcích. Tím by
  mohlo dojít k porušení pravidla na [zabraňování nechtěných konfiskací][topic
  accidental confiscation] (viz [zpravodaj č. 37][news37 confiscation], _angl._).
  Nejsme si vědomi žádného použití takového skriptu, ať již v desetileté
  historii bitcoinu před původním návrhem či během pěti let po něm. Některá
  použití by však byla nedetekovatelná, dokud by nebyla předem podepsaná transakce
  zveřejněna.

  Pro odstranění této námitky Poinsot navrhl, aby byla upravená pravidla konsenzu
  aplikována pouze na výstupy vytvořené po určité výšce bloku. Výstupy
  vytvořené dříve by byly utratitelné dle starých pravidel.

- **Výběr nových editorů BIPů:** Mark „Murch” Erhardt ve [vlákně][erhardt bip editors]
  o přidání nových editorů BIPů navrhl, aby všichni „do konce pátku (5. dubna) uvedli
  své důvody pro a proti jakémukoliv z kandidátů z vlákna. Pokud by někteří z kandidátů
  obdrželi širokou podporu, mohli by být přidáni jako noví editoři následující pondělí (8. dubna).”

  V době psaní zpravodaje diskuze stále probíhala. Učiníme, co je v našich silách, abychom
  o výsledcích informovali v příštím vydání zpravodaje.

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [Bitcoin Core 26.1][] je údržbovým vydáním této převládající implementace
  plného uzlu. Jeho [poznámky k vydání][26.1 rn] popisují opravy několika chyb.

- [Bitcoin Core 27.0rc1][] je kandidátem na vydání příští hlavní verze této
  převládající implementace plného uzlu. Testeři jsou vyzýváni k revizi
  [navrhovaných témat pro testování][bcc testing].

- [HWI 3.0.0-rc1][] je kandidátem na vydání příští hlavní verze tohoto balíčku
  poskytujícího jednotné rozhraní k několika různým hardwarovým podpisovým zařízením.

## Významné změny kódu a dokumentace

_Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Bitcoin Inquisition][bitcoin inquisition repo] a [repozitáři BINANA][binana
repo]._

*Poznámka: commity do Bitcoin Core uvedené níže se vztahují na jeho vývojovou,
master větev. Nebudou tedy pravděpodobně vydány před uplynutím zhruba
šesti měsíců po vydání nadcházející verze 27.*

- [Bitcoin Core #27307][] přináší sledování transakcí v mempoolu, které kolidují
  s transakcemi patřícími peněžence vestavěné v Bitcoin Core, včetně transakcí
  v mempoolu, které jsou v konfliktu s předky transakcí této peněženky. Je-li
  kolidující transakce potvrzena, nemůže být transakce peněženky začleněna
  do blockchainu, je tedy užitečné o konfliktech vědět. Kolidující transakce
  z mempoolu jsou nyní obsaženy v novém poli `mempoolconflict` ve výsledku
  volání `gettransaction` na nějakou transakci peněženky. Vstupy transakce
  s kolizí v mempoolu mohou být znovu utraceny bez ručního zahození kolidující
  transakce v mempoolu a jsou zahrnuty v zůstatku peněženky.

- [Bitcoin Core #29242][] představuje pomocné funkce k porovnání dvou
  [diagramů jednotkových poplatků][sdaftuar incentive compatibility] a k vyhodnocení
  souladu ekonomických podnětů nahrazení clusterů až dvěma transakcemi.
  Tyto funkce poskytnou základ nahrazování [balíčků][topic package relay]
  poplatkem ([RBF][topic rbf]) clustery o maximální velikosti dva včetně
  [transakcí do potvrzení topologicky omezenených][TRUC BIP draft] (TRUC, „Topologically
  Restricted Until Confirmation”), známých též jako [transakce verze 3][topic v3 transaction
  relay].

- [Core Lightning #7094][] odstraňuje několik funkcí, které byly předtím označeny za
  zastaralé použitím nového způsobu zastarávání v Core Lightning (viz [zpravodaj č. 288][news288
  cln deprecation]).

- [BDK #1351][] mění interpretaci parametru `stop_gap`, který nastavuje chování
  [gap limitu][topic gap limits]. Jednou konkrétní změnou se přibližuje chování jiných
  peněženek: `stop_gap` s hodnotou 10 znamená, že BDK bude generovat nové adresy
  pro skenování transakcí tak dlouho, dokud nenalezne deset po sobě jdoucích adres bez
  jakékoliv transakce.

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="27307,29242,7094,1351" %}
[bitcoin core 26.1]: https://bitcoincore.org/bin/bitcoin-core-26.1/
[bcc testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/27.0-Release-Candidate-Testing-Guide
[Bitcoin Core 27.0rc1]: https://bitcoincore.org/bin/bitcoin-core-27.0/test.rc1/
[poinsot cleanup]: https://delvingbitcoin.org/t/great-consensus-cleanup-revival/710
[news36 cleanup]: /en/newsletters/2019/03/05/#cleanup-soft-fork-proposal
[news37 confiscation]: /en/newsletters/2019/03/12/#cleanup-soft-fork-proposal-discussion
[erhardt bip editors]: https://gnusha.org/pi/bitcoindev/52a0d792-d99f-4360-ba34-0b12de183fef@murch.one/
[sdaftuar incentive compatibility]: https://delvingbitcoin.org/t/mempool-incentive-compatibility/553
[TRUC BIP draft]: https://github.com/bitcoin/bips/pull/1541
[news288 cln deprecation]: /cs/newsletters/2024/02/07/#core-lightning-6936
[26.1 rn]: https://github.com/bitcoin/bitcoin/blob/master/doc/release-notes/release-notes-26.1.md
[HWI 3.0.0-rc1]: https://github.com/bitcoin-core/HWI/releases/tag/3.0.0-rc.1
[news37 trees]: /en/newsletters/2019/03/12/#bitcoin-core-vulnerability-disclosure
