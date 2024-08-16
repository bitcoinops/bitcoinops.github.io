---
title: 'Zpravodaj „Bitcoin Optech” č. 311'
permalink: /cs/newsletters/2024/07/12/
name: 2024-07-12-newsletter-cs
slug: 2024-07-12-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Zpravodaj tento týden obsahuje naše pravidelné rubriky se souhrnem sezení
Bitcoin Core PR Review Clubu, oznámeními nových vydání a popisem významných
změn v populárním bitcoinovém páteřním software.

## Novinky

*V našich [zdrojích][sources] jsme tento týden nenašli žádné významné novinky.
Pro zábavu se můžete podívat na jednu nedávnou [pozoruhodnou
transakci][interesting transaction].*

## Bitcoin Core PR Review Club

*V této měsíční rubrice shrnujeme nedávné sezení [Bitcoin Core PR Review Club][] a
vyzdvihujeme některé z důležitých otázek a odpovědí. Klikněte na otázku a odpověď se vám odhalí.*

[Testnet4 včetně opravy úpravy obtížnosti PoW][review club 29775] je PR od
[Fabiana Jahra][gh fjahr], které přináší Testnet4 jako novou testovací síť
nahrazující Testnet3 a zároveň opravuje dlouholeté chyby úpravy obtížnosti
a ohýbání času. Je výsledkem [diskuze v emailové skupině][ml testnet4] a
je doprovázen [návrhem BIPu][bip testnet4].

{% include functions/details-list.md
  q0="Jaké rozdíly kromě změn konsenzu vidíte mezi Testnet 4 a Testnet 3,
  obzvláště v parametrech blockchainu?"
  a0="Všechny výšky nasazení minulých soft forků jsou nastaveny na 1,
  což znamená, že jsou aktivní od začátku. Testnet4 dále používá jiný
  port (`48333`) a messagestart a obsahuje nové poselství v genesis bloku."
  a0link="https://bitcoincore.reviews/29775#l-29"

  q1="Jak v Testnet 3 funguje 20minutová výjimka? Jak vede k záplavě bloků?"
  a1="Je-li časové razítko nového bloku více než 20 minut napřed oproti
  předchozímu bloku, je mu dovoleno mít minimální PoW obtížnost. Následující
  blok bude mít opět „pravou“ obtížnost, pokud též nespadá pod 20minutovou
  výjimku. Tato výjimka byla přidána, aby v prostředí vysoce proměnlivého
  hashrate blockchain vždy postupoval. Kvůli chybě v implementaci
  `GetNextWorkRequired()` je však obtížnost nastavena natrvalo (namísto
  jejího dočasného snížení na jeden blok), je-li poslední blok periody
  blokem s minimální obtížností."
  a1link="https://bitcoincore.reviews/29775#l-47"

  q2="Proč byla do tohoto PR začleněna oprava ohýbání času? Jak tato oprava
  funguje?"
  a2="Útok [ohýbáním času][topic time warp] umožňuje útočníkovi výrazně pozměnit
  míru produkce bloků, je tedy rozumné tuto opravu přinést spolu s opravou chyby
  minimální obtížnosti. Jelikož se dále jedná o součást [soft forku na pročištění
  konsenzu][topic consensus cleanup], poskytne otestování v rámci Testnet4
  užitečnou zpětnou vazbu. PR opravuje chybu ohýbání času tím, že zkontroluje,
  zda není první blok nové epochy obtížnosti více než dvě hodiny před posledním
  blokem předchozí epochy."
  a2link="https://bitcoincore.reviews/29775#l-68"

  q3="Jaké poselství přináší genesis blok v Testnet 3?"
  a3="Testnet 3 – stejně jako všechny další sítě předcházející Testnet 4 –
  obsahuje v genesis bloku stejné, dobře známé poselství: „The Times
  03/Jan/2009 Chancellor on brink of second bailout for banks“ („The Times, 3.
  ledna 2009, ministr financí na pokraji druhé finanční výpomoci bankám”). Testnet4
  je první sítí mající své vlastní poselství, které obsahuje haš
  nedávného mainnetového bloku (
  `000000000000000000001ebd58c244970b3aa9d783bb001011fbe8ea8e98e00e`), aby
  poskytl silné záruky, že na Testnet 4 nedošlo před tímto blokem k
  pre-miningu."
  a3link="https://bitcoincore.reviews/29775#l-17"
%}

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [Bitcoin Core 26.2][] je údržbovou verzí starší série vydání Bitcoin Core.
  Doporučuje se přejít na tuto údržbovou verzi každému, kdo používá 26.1 či
  starší a není schopen či ochoten upgradovat na nejnovější vydání (27.1).

- [LND v0.18.2-beta][] je menším vydáním obsahující opravu chyby, která postihuje
  uživatele starších verzí backendu btcd.

## Významné změny kódu a dokumentace

_Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Bitcoin Inquisition][bitcoin inquisition repo] a [repozitáři BINANA][binana
repo]._

- [Rust Bitcoin #2949][] přidává novou metodu `is_standard_op_return()`,
  která validuje OP_RETURN výstupy oproti současným pravidlům standardnosti.
  Díky ní mohou programátoři zjistit, zda data v OP_RETURN nepřesahují 80bajtové
  maximum vynucované v Bitcoin Core. Stávající `is_op_return` může být nadále
  používáno v případech, kdy testování překračování limitů Bitcoin Core není
  důležité.

- [BDK #1487][] přináší podporu pro vlastní funkce řazení vstupů a výstupů
  specifikované v nové variantě `Custom` výčtového seznamu `TxOrdering`.
  Podpora pro [BIP69][] byla odstraněna, neboť kvůli nízké míře použití
  (viz zpravodaje [č. 19][news19 bip69] a [č. 151][news151 bip69], oba _angl._)
  nemusí poskytovat požadovanou úroveň soukromí. V případě potřeby transakcí
  odpovídající BIP69 mohou uživatelé implementovat vlastní řadící funkce.

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="2949,1487" %}
[bitcoin core 26.2]: https://bitcoincore.org/bin/bitcoin-core-26.2/
[sources]: /en/internal/sources/
[interesting transaction]: https://stacker.news/items/600187
[news19 bip69]: /en/newsletters/2018/10/30/#bip69-discussion
[news151 bip69]: /en/newsletters/2021/06/02/#bolts-872
[gh fjahr]: https://github.com/fjahr
[review club 29775]: https://bitcoincore.reviews/29775
[ml testnet4]: https://groups.google.com/g/bitcoindev/c/9bL00vRj7OU
[bip testnet4]: https://github.com/bitcoin/bips/pull/1601
[LND v0.18.2-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.18.2-beta
