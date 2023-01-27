---
title: 'Zpravodaj „Bitcoin Optech” č. 235'
permalink: /cs/newsletters/2023/01/25/
name: 2023-01-25-newsletter-cs
slug: 2023-01-25-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Tento týden přinášíme souhrn analýzy porovnávající návrh dočasných
anchor výstupů a `SIGHASH_GROUP` a přeposíláme požadavek na výzkum
možností vytváření důkazu úspěchu asynchronní LN platby. Nechybí také
naše pravidelné rubriky se souhrnem zajímavých otázek a odpovědí
z Bitcoin Stack Exchange a popisem významných změn oblíbených
páteřních bitcoinových projektů.

## Novinky

- **Dočasné anchor výstupy v porovnání s `SIGHASH_GROUP`:** Anthony Towns
  [zaslal][towns e-vs-shg] do emailové skupiny Bitcoin-Dev analýzu porovnávající
  nedávný návrh na [dočasné anchor výstupy][topic ephemeral anchors] se
  starším návrhem na [`SIGHASH_GROUP`][`SIGHASH_GROUP` proposal].
  `SIGHASH_GROUP` umožňuje vstupům určit, které výstupy autorizují. Každý vstup
  může autorizovat jinou skupinu výstupů, které se ale nesmí prolínat. Obzvláště
  užitečné je to v případě navýšení poplatků u protokolů, kde dva a více
  vstupů jsou použity s dopředu podepsanou transakcí. Z této vlastnosti
  vyplývá, že poplatky mohou být navýšeny v době, kdy je známa aktuální
  výše. Existující `SIGHASH_ANYONECANPAY` a `SIGHASH_SINGLE` nejsou dostatečně
  flexibilní, protože se týkají pouze jediného vstupu či výstupu.

  Dočasné anchor výstupy, které jsou podobné [sponzorství poplatků][topic fee
  sponsorship], umožňují komukoliv navýšit poplatky pomocí [CPFP][topic cpfp].
  Transakce, jejíž poplatky jsou navyšovány, může obsahovat nulové poplatky.
  Protože může kdokoliv navýšit poplatek pomocí dočasných anchor výstupů,
  může být tento mechanismus použit také k platbě poplatků předem
  podepsané transakce s více vstupy, což řeší právě `SIGHASH_GROUP`.

  `SIGHASH_GROUP` by i nadále nabízel dvě výhody: zaprvé, umožňoval by
  [dávkové zpracování][topic payment batching] vícero nesouvisejících
  předem podepsaných transakcí, což by mohlo snížit velikost transakce a
  náklady a zvýšit kapacitu sítě. Zadruhé nevyžaduje, aby transakce
  měla potomka, což by dále snížilo náklady a zvýšilo kapacitu.

  Towns svůj email uzavírá poznámkou, že dočasné anchor výstupy, díky
  závislosti na [přeposílání transakcí verze 3][topic v3 transaction relay],
  obsahují většinu benefitů `SIGHASH_GROUP` a nabízí velkou výhodu
  ve snadnosti nasazení do produkce oproti `SIGHASH_GROUP`, který
  by vyžadoval soft fork.

- **Požadavek důkazu, že asynchronní platba byla přijata:** Valentine
    Wallace [zaslala][wallace pop] do emailové skupiny Lightning-Dev požadavek
    na vývojáře k nalezení způsobu, kterým by mohl autor [asynchronní
    platby][topic async payments] obdržet důkaz, že platba byla přijata.
    V tradičních LN platbách generuje příjemce tajná data, která jsou
    zahashována. Tento hash je předán plátci v podepsané faktuře. Plátce
    poté pomocí [HTLC][topic htlc] zaplatí komukoliv, kdo odhalí původní
    tajná data. Ta jsou důkazem, že plátce zaplatil za hash z podepsané
    faktury.

    Oproti tomu jsou asynchronní platby přijaty, když je příjemce offline,
    a proto tajná data nemohou být odhalena, což v současném modelu
    znemožňuje vytvoření důkazu platby. Wallace po vývojářích žádá, aby
    vymysleli způsob, kterým by bylo možné důkaz asynchronní platby vytvořit
    ať již v současném modelu založeném na HTLC nebo budoucím [PTLC][topic ptlc].

## Vybrané otázky a odpovědi z Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] je jedním z prvních míst, kde hledají
přispěvatelé Optechu odpovědi na své otázky a kde – najdou-li volnou chvíli –
pomáhají zvědavým či zmateným uživatelům. V této měsíční rubrice nabízíme
některé z otázek a odpovědí, které obdržely vysoký počet hlasů.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Klíče pro podepisování Bitcoin Core byly z repozitáře odstraněny. Jak nově postupovat?]({{bse}}116649)
  Andrew Chow vysvětluje, že ač byly klíče pro podepisování [odstraněny][remove builder
  keys] z repozitáře Bitcoin Core, seznam klíčů lze nově nalézt v [repozitáři
  guix.sigs][guix.sigs repo], kde sídlí atestace sestavení [guix][topic reproducible
  builds].

- [Proč signet nepoužívá jedinečný bech32 prefix?]({{bse}}116630)
  Casey Rodarmor se ptá, proč adresy na testnetu i [signetu][topic signet] používají
  shodný prefix `tb1`. Jeden z autorů [BIP325][] Kalle vysvětluje, že i když
  signet původně odlišný prefix používal, věřilo se, že používání stejného
  prefixu zjednoduší práci s touto alternativní testovací sítí.

- [Ukládání libovolných dat ve witnessu?]({{bse}}116875)
  RedGrittyBrick poukazuje na [jednu z několika][large witness tx] nedávných
  P2TR transakcí obsahující velké množství dat ve witnessu. Jiní uživatelé
  vysvětlují, že projekt Ordinals poskytuje službu na začleňování libovolných
  dat, jako je [obrázek][ordinals example] v uvedené transakci, do bitcoinových
  transakcí pomocí witnessu.

- [Proč se locktime nastavuje na úrovni transakce, ale sequence na úrovni vstupu?]({{bse}}116706)
  RedGrittyBrick poskytuje historický kontext za `nSequence` a `nLockTime` a
  Pieter Wuille vysvětluje evoluci významu [časových zámků][topic timelocks].

- [BLS podpisy vs Schnorr]({{bse}}116551).
  Pieter Wuille porovnává kryptografické předpoklady mezi BLS a [Schnorrovými][topic schnorr signatures]
  podpisy, časy ověřování a vysvětluje potíže s BLS [vícenásobnými podpisy][topic
  multisignature] a chybějící podporu [adaptor podpisů][topic adaptor signatures].

- [Proč přesně by přidání dělitelnosti bitcoinu vyžadovalo hard fork?]({{bse}}116584)
  Pieter Wuille vysvětluje čtyři možnosti soft forku, které by umožnily dělitelnost
  mincí pod úroveň satoshi:

  1. [Vynucený soft fork][forced soft fork] se změnou pravidel vyžadující,
     aby všechny nové transakce následovaly nová pravidla
  2. Jednosměrné rozšíření bloků, které odděluje transakce následující nová
     pravidla, podobné bodu 1, ale též povoluje zastaralé transakce
  3. Obousměrné rozšíření bloků, podobné bodu 2, avšak umožňující mincím
     následující nová pravidla vrátit se zpět
  4. Metoda, která používá současná pravidla, ale ukládá hodnoty menší než
     satoshi na jiné místo v transakci

## Významné změny v kódu a dokumentaci

*Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo] a [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #26325][] vylepšuje výsledek RPC volání `scanblocks` odstraněním
  falešně pozitivních výsledků ve druhém běhu. `scanblocks` lze použít k vyhledání bloků
  obsahujících transakce vztažené k poskytnutému seznamu deskriptorů. Jelikož
  může filtrování nesprávně vybrat bloky, které ve skutečnosti neobsahují žádné
  relevantní transakce, přináší tato změna druhý běh s validací každého výsledku,
  která ověří, zda bloky ve výsledku skutečně odpovídají zadaným deskriptorům.
  Kvůli dopadu na výkonnost musí být tato validace aktivována argumentem
  `filter_false_positives`.

- [Libsecp256k1 #1192][] aktualizuje testy v knihovně. Změnou parametru `B`
  křivky secp256k1 ze `7` na jiné číslo lze nalézt jiné grupy, které
  jsou kompatibilní s libsecp256k1, ale které jsou mnohem menší než řád
  křivky secp256k1, tedy přibližně 2<sup>256</sup>. S těmito malými
  grupami, které jsou pro bezpečnou kryptografii nepoužitelné, lze provádět
  testování logiky libsecp256k1 nad každým možným podpisem. Tato změna
  přidává grupu velikosti 7 k již existujícím velikostem 13 a 199. Vývojáři
  však nejdříve museli vyřešit zvláštní algebraické vlastnosti, kvůli kterým
  jednoduchý vyhledávací algoritmus ne vždy uspěl. Velikost 13 zůstává jako
  výchozí.

- [BIPs #1383][] přiřazuje [BIP329][] návrhu na standardní formát exportu
  štítků peněženek. Oproti původnímu návrhu (viz [zpravodaj č. 215][news215 labels],
  *angl.*) je hlavní změnou přechod z CSV na JSON.

{% include references.md %}
{% include linkers/issues.md v=2 issues="26325,1383,1192" %}
[news215 labels]: /en/newsletters/2022/08/31/#wallet-label-export-format
[towns e-vs-shg]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-January/021334.html
[`sighash_group` proposal]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-July/019243.html
[wallace pop]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-January/003820.html
[forced soft fork]: https://petertodd.org/2016/forced-soft-forks
[remove builder keys]: https://github.com/bitcoin/bitcoin/commit/296e88225096125b08665b97715c5b8ebb1d28ec
[guix.sigs repo]: https://github.com/bitcoin-core/guix.sigs/tree/main/builder-keys
[wiki address prefixes]: https://en.bitcoin.it/wiki/List_of_address_prefixes
[large witness tx]: https://blockstream.info/tx/a6628f32a5b41b359cfe4ab038ff7c4279118ff601b9eca85eca8a64763db40c?expand
[ordinals example]: https://ordinals.com/tx/a6628f32a5b41b359cfe4ab038ff7c4279118ff601b9eca85eca8a64763db40c
