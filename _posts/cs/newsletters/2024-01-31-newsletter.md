---
title: 'Zpravodaj „Bitcoin Optech” č. 287'
permalink: /cs/newsletters/2024/01/31/
name: 2024-01-31-newsletter-cs
slug: 2024-01-31-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Tento týden přinášíme popis návrhu na nahrazování transakcí verze 3
pomocí RBF pravidel k usnadnění přechodu na cluster mempool a
souhrn polemiky proti `OP_CHECKTEMPLATEVERIFY` na základě jeho potřeby
exogenních poplatků. Též nechybí naše pravidelné rubriky se souhrnem
zajímavých otázek a odpovědí z Bitcoin Stack Exchange, oznámeními o
nových vydáních a popisem významných změn v populárních bitcoinových
páteřních projektech.

## Novinky

- **Příbuzenské nahrazování poplatkem:** Gloria Zhao zaslala do fóra Delving
  Bitcoin [příspěvek][zhao v3kindred] o nahrazování transakcí
  příbuznými transakcemi i bez existence konfliktu mezi nimi. Dvě
  transakce jsou _v konfliktu_, pokud nemohou obě dvě zároveň
  existovat ve validním blockchainu. Obvyklým důvodem je utracení
  stejného UTXO, což porušuje pravidlo proti dvojímu utracení. Pravidla [RBF][topic rbf]
  porovnávají transakci v mempoolu oproti nově obdržené transakci, která
  je s ní v konfliktu. Zhao navrhuje idealizovaný způsob, jak nakládat
  s konflikty: má-li přeposílající uzel dvě transakce, z nichž akceptována může být pouze
  jedna, měl by vybrat ne první, ale tu, která nejlépe vyhovuje provozovatelovým
  cílům (např. maximalizace příjmů z těžby a omezení přeposílání
  zdarma). Pravidla RBF aplikují toto pravidlo na konflikty, Zhao
  ve svém příspěvku tuto myšlenku rozšiřuje i na příbuzné transakce.

  Bitcoin Core aplikuje _pravidla_ omezující počet a velikost příbuzných
  transakcí, které mohou být zároveň v mempoolu. To zabraňuje několika druhům
  DoS útoků, ale také kvůli tomu může mempool odmítnout transakci B proto,
  že předtím obdržel transakci A a tím bylo dosaženo limitu. Toto je
  v rozporu s výše popsaným principem: namísto toho by měl Bitcoin Core akceptovat
  A či B v souladu se svými cíli.

  Navrhovaná pravidla pro [přeposílání transakcí verze 3][topic v3
  transaction relay] povolují, aby měl nepotvrzený v3 rodič v mempoolu
  pouze jediného potomka. Jelikož žádná z těchto transakcí nemůže mít
  žádné další předky v mempoolu, aplikace existujících pravidel RBF na
  nahrazení tohoto potomka je snadná a Zhao ji již
  [naimplementovala][zhao kindredimpl]. Pokud by existující LN
  commitment transakce s [anchor výstupy][topic anchor outputs]
  automaticky přijaly pravidla v3, jak popisuje [minulé číslo
  zpravodaje][news286 imbued], byla by každá ze stran vždy schopna
  navýšit poplatek commitment transakce:

  - Alice může poslat commitment transakci s potomkem pro placení poplatků.

  - Alice může poté navýšit poplatek potomka pomocí RBF.

  - Bob může použít příbuzenského nahrazení k vyhození Alicina potomka
    zasláním svého vlastního potomka, který platí vyšší poplatky.

  - Alice může poté použít příbuzenského nahrazení na Bobova potomka
    zasláním svého potomka s ještě vyšším poplatkem (Bobův potomek by
    tak byl vyhozen).

  Přidání tohoto pravidla a jeho automatická aplikace na existující
  LN anchory umožní odstranit pravidlo [CPFP carve-out][topic cpfp carve out].
  Toto odstranění je nutné pro implementaci [cluster mempoolu][topic cluster
  mempool], který by měl v budoucnu umožnit nejrůznější druhy nahrazení
  v souladu s ekonomickými záměry těžařů.

  V době psaní zpravodaje nenadnesl ve fóru nikdo proti této myšlence žádné
  námitky. Jeden přispěvatel se tázal, zda by se tímto staly [dočasné
  anchory][topic ephemeral anchors] nepotřebnými. Autor tohoto návrhu
  Gregory Sanders odpověděl: „Neplánuju přestat pracovat na dočasných
  anchorech. Nulové výstupy mají několik důležitých použití i mimo LN.”

- **Opozice vůči CTV kvůli vyžadování exogenních poplatků:**
  Peter Todd zaslal do emailové skupiny Bitcoin-Dev [příspěvek][pt ctv]
  se svými argumenty proti [exogenním poplatkům][topic fee sourcing]
  (viz [zpravodaj č. 284][news284 ptexogenous]) aplikovanými na navrhovaný
  [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify]. Poznamenává,
  že „v mnoha (ne-li ve všech) případech, kdy je CTV použito
  k umožnění sdílení jednoho UTXO mezi několika stranami, je náročné až
  nemožné zajistit, aby všechny varianty CTV pokryly všechny možné
  jednotkové poplatky. Očekává se, že CTV budou obvykle používané spolu
  s [anchor výstupy][topic ephemeral anchors], které budou platit poplatky, […]
  nebo snad i pomocí soft forku [sponzorovaných transakcí][topic fee
  sponsorship]. […] Požadavek, aby měl každý uživatel k dispozici UTXO
  na placení poplatků, je v rozporu s nabízenou efektivitou schémat sdílení
  UTXO použitím CTV. […] Jedinou realistickou alternativou je zaplatit za UTXO
  pomocí třetí strany (např. LN platbou), ale to už by bylo výhodnější zaplatit
  poplatek [mimo blockchain][topic out-of-band fees]. To je pochopitelně
  velice nežádoucí z pohledu centralizace těžby.” (Odkazy přidal Optech.)
  Doporučuje vzdát se CTV a namísto toho pracovat na [schématech kovenantů][topic
  covenants], která jsou kompatibilní s [RBF][topic rbf].

  John Law odpověděl, že díky časovým zámkům závislým na poplatku (viz [zpravodaj
  č. 283][news283 fdt]) by mohlo být CTV s endogenními poplatky bezpečné v případech,
  kdy je potřebné dosáhnout potvrzení transakce před vypršením nějaké lhůty. Na druhou
  stranu by časové zámky závislé na poplatcích mohly na velmi dlouho pozdržet některá
  vyrovnání kontraktů.

## Vybrané otázky a odpovědi z Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] je jedním z prvních míst, kde hledají
přispěvatelé Optechu odpovědi na své otázky a kde – najdou-li volnou chvíli –
pomáhají zvědavým či zmateným uživatelům. V této měsíční rubrice nabízíme
některé z otázek a odpovědí, které obdržely vysoký počet hlasů.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aa
nswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Jak dnes v Bitcoin Core funguje synchronizace bloků?]({{bse}}121292)
  Pieter Wuille popisuje strom hlaviček bloků, data bloků, aktivní
  chaintip (vrchol řetězce) a datové struktury blockchainu. Dále vysvětluje
  synchronizaci hlaviček, bloků a procesy aktivace bloků, které následují.

- [Jak zabraňuje stažení hlaviček před bloky útoku zaplněním disku?]({{bse}}76018)
  Pieter Wuille doplňuje starou otázku o vysvětlení pozdějšího opatření proti
  spamu přidanému do Bitcoin Core 24.0, které se nazývá „Headers Presync” (viz
  [zpravodaj č. 216][news216 headers presync], _angl._) a během kterého dochází
  k synchronizaci hlaviček před tím, než započne synchronizace dat bloků.

- [Je BIP324 v2transport u tor a i2p spojení nadbytečný?]({{bse}}121360)
  Pieter Wuille připouští, že [přenos verze 2][topic v2 p2p transport] nenabízí
  během používání [anonymních sítí][topic anonymity networks] další výhody.
  Dodává, že oproti nešifrované verzi 1 může potenciálně dosáhnout lepšího
  výpočetního výkonu.

- [Jak rozumně nastavit maximální počet spojení?]({{bse}}121088)
  Pieter Wuille rozlišuje mezi [odchozími a příchozími spojeními]({{bse}}121015)
  a vypisuje body, které je dobré zvážit při nastavení vyšších hodnot
  `-maxconnections`.

- [Proč není horní hranice (+2 hodiny) času bloku nastavena jako pravidlo konsenzu?]({{bse}}121248)
  V této i [dalších]({{bse}}121247) souvisejících [otázkách]({{bse}}121253) vysvětluje
  Pieter Wuille požadavek, aby časové razítko nového bloku nebylo více než
  dvě hodiny v budoucnosti, důležitost tohoto požadavku a proč „pravidla konsenzu
  mohou záviset pouze na informacích, ke kterým existuje závazek (commitment) pomocí
  hashů bloku.”

- [Počet sigop a jeho dopad na výběr transakce?]({{bse}}121355)
  Uživatel Cosmik Debris se ptá, jak omezení operací ověření podpisů
  („sigop”) dopadají na těžařovu konstrukci šablony bloku a na mempoolový
  [odhad poplatků][topic fee estimation].

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [HWI 2.4.0][] je vydáním další verze tohoto balíčku poskytujícího společné
  rozhraní několika různým hardwarovým podpisovým zařízením. Nové vydání přidává
  podporu pro Trezor Safe 3 a obsahuje několik drobných vylepšení.

## Významné změny kódu a dokumentace

_Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Bitcoin Inquisition][bitcoin inquisition repo] a [repozitáři BINANA][binana
repo]._

- [Bitcoin Core #29291][] přidává test, který selže, pokud má transakce spouštějící
  opkód `OP_CHECKSEQUENCEVERIFY` záporné číslo verze. Pokud by byl
  tento test spouštěn alternativními implementacemi konsenzu, odhalil by chybu
  zmíněnou v [minulém čísle][news286 bip68ver].

- [Eclair #2811][], [#2813][eclair #2813] a [#2814][eclair #2814]
  přidávají [trampolínovým platbám][topic trampoline payments] možnost
  použít [zaslepenou cestu][topic rv routing] ke konečnému příjemci.
  Trampolínové routování samo o sobě nadále používá běžné identifikátory
  uzlu zašifrované v onion zprávě, každý trampolínový uzel se tedy dozví
  identifikátor následujícího trampolínového uzlu. Avšak je-li použita zaslepená
  cesta, poslední trampolínový uzel se nově dozví pouze počáteční uzel zaslepené
  cesty. Nedozví se identifikátor konečného příjemce.

  Dříve záviselo soukromí trampolín na použití několika trampolínových
  přeposílajících uzlů, aby žádný z nich s jistotou nevěděl, jsou-li
  posledním přeposílajícím. Nevýhodou tohoto přístupu je používání
  delších cest, které zvyšovaly pravděpodobnost selhání a vyžadovaly platbu
  vyšších poplatků. Nově přeposlání platby i přes jediný trampolínový
  uzel zabrání, aby se tento uzel dozvěděl konečného příjemce.

- [LND #8167][] umožňuje, aby LND uzel kooperativně zavřel kanál, který
  má stále jednu či více čekajících plateb ([HTLC][topic htlc]). [BOLT2][]
  specifikace určuje, že správným řešením je, aby jedna strana poslala
  zprávu `shutdown`, po které nebudou přijata žádná nová HTLC. Poté,
  co jsou všechna čekající HTLC vyřízena offchain, obě strany si vyjednají
  a podepíší transakci kooperativního uzavření. Když v předchozích verzích
  LND obdrželo zprávu `shutdown`, uzavřelo kanál jednostranně, což si
  vyžádalo nadbytečné onchain transakce a poplatky.

- [LND #7733][] přidává do [strážní věže][topic watchtowers] možnost
  zálohy a vynucení správného uzavření [jednoduchých taprootových
  kanálů][topic simple taproot channels], které jsou nyní v LND
  experimentálně podporovány.

- [LND #8275][] počíná od spojení vyžadovat podporu určitých univerzálně
  nasazených vlastností dle specifikace v [BOLTs #1092][] (viz [zpravodaj
  č. 259][news259 lncleanup]).

- [Rust Bitcoin #2366][] zastarává metodu `.txid()` objektů `Transaction`
  a nahrazuje ji metodou `.compute_txid()`. Kdykoliv je metoda `.txid()`
  volána, je txid transakce vypočítáno nově, což spotřebovává u velkých
  transakcí či velkého množství malých transakcí významný procesorový
  čas. Nové jméno pomůže programátorům uvědomit si potenciální náklady
  volání metody. Metody `.wtxid()` a `.ntxid()` (založené na
  [BIP141][], respektive na [BIP140][]) jsou podobným způsobem přejmenovány
  na `.compute_wtxid()` a `.compute_ntxid()`.

- [HWI #716][] přidává podporu pro hardwarové podpisové zařízení Trezor Safe 3.

- [BDK #1172][] přidává do peněženky API pro registraci jednotlivých bloků.
  Uživatel s přístupem k množině bloků může postupně, blok po bloku, aktualizovat
  peněženku dle transakcí z těchto bloků. To může být použito pro každý blok
  v řetězci. Software dále může použít nějaký způsob filtrování (např.
  [kompaktní filtry bloků][topic compact block filters]) k nalezení pouze
  takových bloků, které pravděpodobně obsahují transakce relevantní pro peněženku,
  a může tedy uvažovat pouze tuto podmnožinu bloků.

- [BINANAs #3][] přidává [BIN24-5][] se seznamem repozitářů s bitcoinovými
  specifikacemi, jakou jsou BIPy, BOLTy, BLIPy, SLIPy, LNPBP a specifikace DLC.
  Též jsou vyjmenovány repozitáře se specifikacemi i jiných, souvisejících projektů.

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 15:00" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="29291,2811,2813,2814,8167,7733,8275,1092,2366,716,1172,3" %}
[hwi 2.4.0]: https://github.com/bitcoin-core/HWI/releases/tag/2.4.0
[news286 bip68ver]: /cs/newsletters/2024/01/24/#zverejneni-opraveneho-selhani-konsenzu-v-btcd
[trezor safe 3]: https://trezor.io/trezor-safe-3
[news283 fdt]: /cs/newsletters/2024/01/03/#casove-zamky-se-zavislosti-na-poplatcich
[zhao v3kindred]: https://delvingbitcoin.org/t/sibling-eviction-for-v3-transactions/472
[news259 lncleanup]: /cs/newsletters/2023/07/12/#navrh-na-procisteni-specifikace-ln
[news284 ptexogenous]: /cs/newsletters/2024/01/10/#caste-pouzivani-externich-poplatku-muze-ohrozovat-decentralizaci-tezby
[zhao kindredimpl]: https://github.com/bitcoin/bitcoin/pull/29306
[pt ctv]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2024-January/022309.html
[news286 imbued]: /cs/newsletters/2024/01/24/#vstipena-v3-logika
[news216 headers presync]: /en/newsletters/2022/09/07/#bitcoin-core-25717
