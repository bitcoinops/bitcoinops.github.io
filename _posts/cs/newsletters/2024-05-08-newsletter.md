---
title: 'Zpravodaj „Bitcoin Optech” č. 301'
permalink: /cs/newsletters/2024/05/08/
name: 2024-05-08-newsletter-cs
slug: 2024-05-08-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Zpravodaj tento týden popisuje nápad na zabezpečení transakcí Lamportovými
podpisy bez nutnosti měnit konsenzus. Též nechybí naše pravidelné rubriky se
souhrnem sezení Bitcoin Core PR Review Clubu, oznámeními nových vydání
a popisem významných změn v populárním bitcoinovém páteřním software.

## Novinky

- **Lamportovy podpisy postavené nad ECDSA podpisy, vynucované konsenzem:**
  Ethan Heilman zaslal do emailové skupiny Bitcoin-Dev [příspěvek][heilman lamport] s popisem
  metody, jak může být po transakci vyžadován [Lamportův podpis][lamport signature], aby byla
  validní. Díky tomu by mohly být P2SH a P2WSH výstupy [kvantově odolné][topic quantum resistance],
  což dle Andrew Poelstry [znamená][poelstra lamport1], „že jediným zbývajícím důvodem, proč bitcoin nemá
  kovenanty, jsou prostorová omezení.” Níže uvádíme shrnutí protokolu, ale pro
  zachování jednoduchosti a snadné pochopitelnosti vynecháme upozornění na nebezpečná
  místa. Prosíme, neimplementujte nic na základě tohoto popisu.

  Lamportův veřejný klíč obsahuje dva seznamy hašovacích otisků. Lamportův
  podpis obsahuje předobrazy vybraných otisků. Program sdílený podepisovací
  i ověřovací funkcí interpretuje, které předobrazy jsou odhaleny, jako instrukce.
  Například Bob chce ověřit, že Alice podepsala číslo mezi 0 a 31 (v binární
  soustavě číslo mezi 00000 a 11111). Alice vytvoří Lamportův soukromý klíč
  ze dvou seznamů náhodných čísel:

  ```text
  private_zeroes = [random(), random(), random(), random(), random()]
  priavte_ones   = [random(), random(), random(), random(), random()]
  ```

  Každé z těchto čísel zahašuje, čímž vytvoří veřejný Lamportův klíč:

  ```text
  public_zeroes = [hash(private_zeroes[0]), ..., hash(private_zeroes[4])]
  public_ones   = [hash(private_ones[0]), ..., hash(private_ones[4])]
  ```

  Svůj veřejný klíč poskytne Bobovi. Nato chce ověřitelným způsobem Bobovi sdělit
  číslo 21. Zašle následující předobrazy:

  ```text
  private_ones[0]
  private_zeroes[1]
  private_ones[2]
  private_zeroes[3]
  private_ones[4]
  ```

  Ty odpovídají binárnímu číslu 10101. Bob ověří, že každý z předobrazů odpovídá
  veřejnému klíči, který předtím obdržel. To ho ujistí, že zprávu „21“ mohla
  vygenerovat pouze Alice, která zná předobrazy.

  Bitcoin kóduje ECDSA podpisy [DER standardem][der encoding], který v obou dvou komponentách podpisu
  vynechává úvodní nulové bajty (0x00). U náhodných hodnot se nulový bajt objeví
  v každém 256. případě. Bitcoinové podpisy se tedy přirozeně liší ve velikosti.
  Tato variabilita je umocněna tím, že úvodní bajt hodnot R je nulový v polovině
  případů (viz [low-r grinding][topic low-r grinding]), ale v teoretické úrovni lze
  dosáhnout zmenšení transakce o jeden bajt v jednom z 256 případů.

  I kdyby rychlý kvantový počítač umožnil útočníkovi vytvořit podpis bez předchozí
  znalosti soukromého klíče, ECDSA podpisy v DER kódování by nadále měly proměnlivou
  délku a musely by být zavázány transakcím, které je obsahují, a tyto transakce
  by i nadále musely obsahovat dodatečná data potřebná k její validaci, jako jsou
  předobrazy hašů.

  Díky tomuto schématu může P2SH redeem skript obsahovat kontrolu ECDSA podpisu,
  který bude zavazovat transakci a Lamportově podpisu, který sám bude zavázán skutečné
  velikosti ECDSA podpisu. Například:

  ```text
  OP_DUP <pubkey> OP_CHECKSIGVERIFY OP_SIZE <size> OP_EQUAL
  OP_IF
    # Nyní víme, že velikost je <size> bajtů
    OP_SHA256 <digest_x> OP_CHECKEQUALVERIFY
  OP_ELSE
    # Nyní víme, že velikost není <size> bajtů
    OP_SHA256 <digest_y> OP_CHECKEQUALVERIFY
  OP_ENDIF
  ```

  Aby mohl být tento fragment úspěšně vykonán, musí plátce poskytnout
  ECDSA podpis. Ten je poté duplikován a ověřen; pokud se jedná o neplatný
  podpis, skript skončí neúspěchem. V době pokvantové by mohl útočník tímto
  testem projít a pokračovat ve validaci skriptu. Dále je změřena velikost
  podpisu. Pokud se rovná `<size>` bajtům, musí plátce odhalit předobraz
  otisku `<digest_x>`. Tato velikost `<size>` může být nastavena na hodnotu
  o jeden bajt menší, než je běžné, což se přirozeně stane u jednoho z 256
  podpisů. V opačném, běžném případě nebo v případě větších podpisů musí
  plátce odhalit předobraz pro otisk `<digest_y>`. Skript selže, pokud není
  poskytnut správný předobraz.

  Ani pokud by bylo ECDSA zcela prolomeno, nemohl by útočník prostředky
  utratit, pokud by neznal Lamportův soukromý klíč. Samo o sobě to není příliš
  zajímavé, P2SH i P2WSH tuto základní vlastnost, kdy jsou jejich předobrazy
  (skripty) drženy v tajnosti, [již mají][news141 key hiding]. Avšak po zveřejnění
  Lamportova podpisu by útočník, který by jej chtěl znovu použít s padělaným
  ECDSA podpisem, musel zajistit stejnou délku ECDSA podpisu, jako má podpis
  původní. To může po útočníkovi vyžadovat hledání vyhovujícího podpisu,
  které čestný uživatel provádět nemusí (tomuto hledání se říká „grinding”
  čili „obrušování”).

  Jak dlouho musí útočník obrušovat podpisy lze exponenciálně zvýšit přidáním
  dalších párů ECDSA a Lamportových podpisů. Jelikož se ECDSA podpisy liší ve
  velikosti přirozeně jednou v 256 případech, abychom dosáhli praktické
  bezpečnosti, museli bychom poskytnout velmi vysoký počet podpisů.
  Heilman [popisuje][heilman lamport2] mnohem efektivnější mechanismus.
  S jeho použitím je sice stále překročen limit velikosti P2SH daný konsenzem,
  avšak věříme, že by to mohlo fungovat s vyššími limity P2WSH.

  Dále by útočník s rychlým kvantovým počítačem nebo dostatečně výkonným
  klasickým počítačem mohl nalézt krátký ECDSA nonce, který by mu umožnil
  snadno okrást kohokoliv, kdo takto krátký nonce neočekával. Minimální velikost
  nonce je známa, tomuto útoku se tedy lze vyhnout, avšak soukromá část nonce
  známa není, proto by každý, kdo se snaží tomuto útoku zabránit, nemohl
  utratit své bitcoiny, dokud se nevynalezne rychlý kvantový počítač.

  Tato verifikace Lamportova podpisu je v praxi podobná navrhovanému opkódu
  [OP_CHECKSIGFROMSTACK][topic op_checksigfromstack]. V obou případech jsou
  ověřovaná data – veřejný klíč a podpis – umístěna do zásobníku a operace
  skončí úspěchem, pokud podpis odpovídá veřejnému klíči a zároveň zavazuje
  položkám v zásobníku. Andrew Poelstra [popsal][poelstra lamport2], jak
  by tento mechanismus mohl být v kombinaci s operacemi ve stylu [BitVM][topic acc]
  použit k vytváření [kovenantů][topic covenants]. Varuje však, že téměř
  jistě by byl přesažen alespoň jeden limit velikosti vynucovaný konsenzem.

## Bitcoin Core PR Review Club

*V této měsíční rubrice shrnujeme nedávné sezení [Bitcoin Core PR Review Club][] a
vyzdvihujeme některé z důležitých otázek a odpovědí. Klikněte na otázku a odpověď se vám odhalí.*

[Indexuj TxOrphanage hodnotou wtxid, umožni položky se stejným txid][review club
30000] je PR od Glorie Zhao (glozow na GitHubu), které umožňuje, aby skupina transakcí
se stejným `txid` mohla být naráz umístěna v `TxOrphanage` (objekt držící osiřelé transakce,
je tedy nazýván sirotčincem) tím, že používá pro indexaci `wtxid` namísto `txid`.

Díky tomuto PR je příležitostné [přijetí balíčku][topic package relay] s jedním rodičem
a jedním potomkem (1-parent-1-child, 1p1c) představené v [Bitcoin Core #28970][]
robustnější.

{% include functions/details-list.md
  q0="Proč bychom měli umožnit současnou existenci více transakcí se
      stejným txid v TxOrphanage? Jakým situacím to má zabránit?"
  a0="Dle definice nemohou být witness data transakce bez rodičů
      validována, protože rodičovská transakce není známa. Když je
      přijato více transakcí s odlišnými wtxid, ale stejnými txid,
      je tedy nemožné vědět, která verze je ta správná. Tím, že umožníme
      jejich paralelní existenci uvnitř TxOrphanage, nemůže útočník
      poslat nesprávnou, upravenou verzi, která by zabránila přijetí
      správné verze."
  a0link="https://bitcoincore.reviews/30000#l-11"

  q1="Jaké jsou příklady osiřelých transakcí se stejným txid, ale odlišným witnessem?"
  a1="Taková transakce může obsahovat nevalidní podpis (a tím být celá nevalidní)
      nebo větší witness (stejný poplatek, a tedy nižší jednotkový poplatek)."
  a1link="https://bitcoincore.reviews/30000#l-67"

  q2="Uvažujme, co nastane, pokud bychom umožnili pouze jeden záznam na txid.
      Co se stane, pokud nám zákeřné spojení pošle upravenou verzi osiřelé
      transakce, která nemá rodiče s nízkým jednotkovým poplatkem?
      Co se musí stát, aby byl tento potomek přijat do mempoolu? Existuje
      více odpovědí."
  a2="Pokud je upravený potomek v sirotčinci a obdržíme validního rodiče
      s nenízkým jednotkovým poplatkem, rodič bude do mempoolu přijat
      a upravený potomek bude zneplatněn a ze sirotčince odstraněn."
  a2link="https://bitcoincore.reviews/30000#l-52"

  q3="Uvažujme, co se stane, pokud máme balíček s jedním rodičem a jedním
      potomkem (1p1c), kde rodič má nízký jednotkový poplatek a musí být
      doprovázen svým potomkem. Co se musí stát, abychom do mempoolu správně
      přijali tento balíček rodiče s potomkem?"
  a3="Jelikož má rodič nízký jednotkový poplatek, nebude sám o sobě do mempoolu
      přijat. Nicméně po [Bitcoin Core #28970][] může být příležitostně přijat
      jako 1p1c balíček, pokud je potomek v sirotčinci. Pokud je osiřelý
      potomek pozměněn, rodič je z mempoolu vyloučen a sirotek odstraněn
      ze sirotčince."
  a3link="https://bitcoincore.reviews/30000#l-60"

  q4="Namísto držení více transakcí se stejným txid (kde očividně plýtváme
      prostorem na verzi, kterou neakceptujeme), měli bychom umožnit, aby
      transakce nahradila existující položku v sirotčinci? Jaké by byly
      požadavky?"
  a4="Zdá se, že neexistuje dobrá metrika, která by rozhodovala o nahrazení
      existující transakce. Jedním možným směrem je nahrazovat duplikované
      transakce pouze přicházející od stejného spojení."
  a4link="https://bitcoincore.reviews/30000#l-80"
%}

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [Libsecp256k1 v0.5.0][] je vydáním této knihovny pro provádění kryptografických
  operací. Zrychluje generování klíčů a podepisování (viz [minulé číslo
  zpravodaje][news300 secp]) a snižuje velikost zkompilované verze, „což bude zvláště
  výhodné pro vestavěná zařízení.“ Dále přidává funkci pro řazení veřejných klíčů.

- [LND v0.18.0-beta.rc1][] je kandidátem na vydání příští hlavní verze tohoto
  oblíbeného LN uzlu.

## Významné změny kódu a dokumentace

_Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Bitcoin Inquisition][bitcoin inquisition repo] a [repozitáři BINANA][binana
repo]._

- [Bitcoin Core #28970][] a [#30012][bitcoin core #30012] přidávají podporu
  pro omezenou formu [přeposílání balíčku][topic package relay] sestávajícího
  se z jednoho rodiče a jednoho potomka (1p1c), která nevyžaduje žádné změny
  P2P protokolu. Představme si, že má Alice rodičovskou transakci pod úrovní
  [BIP133][] poplatkových filtrů všech svých spojení. Ví, že by transakci
  žádné její spojení nepřijalo, nebude se tedy snažit o její odeslání.
  Dále má potomka, který platí dostatečný poplatek za sebe i za rodiče.
  Alice a její spojení provedou následující proces:

  - Alice odešle potomka svému spojení.

  - Její spojení si uvědomí, že nezná rodiče transakce, uloží tedy transakci
    do _sirotčince_. Všechny verze Bitcoin Core z poslední dekády obsahují
    sirotčinec, do kterého dočasně ukládají omezený počet transakcí, které
    jsou přijaty dříve než její rodiče. Tím se napraví situace, kdy v P2P
    síti někdy přicházejí transakce v zaměněném pořadí.

  - Po několika okamžicích odešle Alice rodičovskou transakci.

  - Před tímto PR by si uzel všiml, že jednotkový poplatek rodiče
    je příliš nízký a transakci by nepřijal. Dále by ze sirotčince
    odstranil potomka, neboť už poznal jeho rodiče. Po tomto PR
    si uzel všimne, že již má potomka tohoto rodiče v sirotčinci a
    vyhodnotí jejich poplatky dohromady. Pokud je tento poplatek
    nad prahem (a pokud jsou obě transakce jinak v souladu s pravidly
    uzlu), jsou obě transakce přijaty do mempoolu.

  Je známo, že útočník může tento mechanismus narušit. Sirotčinec v Bitcoin
  Core je kruhový buffer, do kterého může položky přidat kterékoliv spojení.
  Útočník, který chce oběti zabránit v přeposlání tohoto druhu balíčku,
  tak musí zaplavit spojení mnoha osiřelými transakcemi. To může potenciálně
  vést k vyloučení platícího potomka ještě před přijetím rodiče. [Následné PR][bitcoin
  core #27742] může poskytnout každému spojení exkluzivní přístup do části
  sirotčince, čímž by byl tento problém eliminován. Pro jiné, související
  PR viz rubriku _Bitcoin PR Review Club_ v tomto čísle zpravodaje. Další
  vylepšení vyžadující změny P2P protokolu jsou popsány v [BIP331][].

- [Bitcoin Core #28016][] se nejprve dotáže všech seedových uzlů před tím,
  než odešle dotazy DNS seedům. Uživatelé mohou nastavit seznam seedových uzlů
  i DNS seedů. Seedový uzel je běžný bitcoinový plný uzel. Bitcoin Core
  k němu může otevřít TCP spojení, vyžádat si seznam adres potenciálních
  dalších spojení a odpojit se. DNS seed vrací IP adresy potenciálních
  spojení přes DNS. Díky tomu může tato informace putovat (a být dočasně
  uložena) DNS sítí, takže vlastník serveru DNS seedu se nedozví, která
  IP adresa si informaci vyžádala. Ve výchozím nastavení se Bitcoin Core
  pokouší vytvořit spojení s IP adresami, které již zná. Pokud žádný pokus
  není úspěšný, dotáže se DNS seedů. Pokud není žádný DNS seed dosažitelný,
  kontaktuje množinu napevno zakódovaných seedových uzlů. Uživatelé mají
  možnost poskytnout vlastní seznam seedových uzlů.

  Pokud uživatel před tímto PR nastavil vlastní seznam seedových uzlů
  a zároveň ponechal ve výchozím nastavení používání DNS seedů, obě skupiny
  byly kontaktovány najednou a adresy toho rychlejšího v odpovědích
  dominovaly. Jelikož má DNS nižší požadavky a odpovědi jsou často kešovány
  blízkým serverem, DNS zvítězilo téměř vždy. Po tomto PR mají seedové
  uzly přednost; pokud uživatel sám nastavil volbu `seednode`, zřejmě preferuje
  její výsledky.

- [Bitcoin Core #29623][] lépe varuje uživatele,
  pokud se jeho lokální čas jeví být více než deset minut mimo oproti
  času jeho spojení. Uzel se špatným časem může dočasně odmítat validní
  bloky, což může potenciálně vést k vážným bezpečnostním problémům.
  Tato změna následuje po odstranění síťově upraveného času z kódu konsenzu
  (viz [zpravodaj č. 288][news288 time]).

## Korekce

Ukázkový skript ověření Lamportova podpisu původně používal `OP_CHECKSIG`,
avšak byl po publikaci nahrazen opkódem `OP_CHECKSIGVERIFY`. Děkujeme
Antoineovi Poinsotovi za upozornění na naši chybu.

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="30012,28016,29623,27742,28970" %}
[lnd v0.18.0-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.18.0-beta.rc1
[libsecp256k1 v0.5.0]: https://github.com/bitcoin-core/secp256k1/releases/tag/v0.5.0
[heilman lamport]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CAEM=y+XyW8wNOekw13C5jDMzQ-dOJpQrBC+qR8-uDot25tM=XA@mail.gmail.com/
[lamport signature]: https://en.wikipedia.org/wiki/Lamport_signature
[poelstra lamport1]: https://mailing-list.bitcoindevs.xyz/bitcoindev/ZjD-dMMGxoGNgzIg@camus/
[der encoding]: https://en.wikipedia.org/wiki/X.690#DER_encoding
[heilman lamport2]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CAEM=y+UnxB2vKQpJAa-z-qGZQfpR1ZeW3UyuFFZ6_WTWFYGfjw@mail.gmail.com/
[poelstra lamport2]: https://gnusha.org/pi/bitcoindev/Zjo72iTDYjwwsXW3@camus/T/#m9c4d5836e54ed241c887bcbf3892f800b9659ee2
[news300 secp]: /cs/newsletters/2024/05/01/#libsecp256k1-1058
[news288 time]: /cs/newsletters/2024/02/07/#bitcoin-core-28956
[news141 key hiding]: /en/newsletters/2021/03/24/#p2pkh-hides-keys
[review club 30000]: https://bitcoincore.reviews/30000
