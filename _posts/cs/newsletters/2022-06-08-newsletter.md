---
title: 'Zpravodaj „Bitcoin Optech” č. 203'
permalink: /cs/newsletters/2022/06/08/
name: 2022-06-08-newsletter-cs
slug: 2022-06-08-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Tento týden přinášíme naše pravidelné rubriky se souhrnem sezení Bitcoin
Core PR Review Club, seznamem nových softwarových vydání a popisem významných
změn v populárních bitcoinových infrastrukturních projektech.

## Novinky

*Tento týden nepřinesl žádné významné novinky.*

## Bitcoin Core PR Review Club

*V této měsíční rubrice shrnujeme nedávné sezení [Bitcoin Core PR Review Club][] a
vyzdvihujeme některé z důležitých otázek a odpovědí. Klikněte na otázku a odpověď se vám odhalí.*

[Miniscript support in Output Descriptors][reviews 24148] je PR od Antoine Poinsota
a Pieter Wuilleho. Přináší watch-only podporu pro [miniscript][topic miniscript] v
[deskriptorech][topic descriptors]. Účastníci posuzovali PR v rámci dvou sezení.
Témata diskuze obsahovala použití miniscriptu, zvažování poddajnosti („malleability”) a
implementaci parseru deskriptorů.

{% include functions/details-list.md

  q0="Pro jaké případy či aplikace by byly užitečné jaké typy analýzy umožněné
  miniscriptem?"
  a0="Diskutováno bylo několik aplikací a druhů analýzy. Miniscript nabízí analýzu
  největší velikosti witness, a tudíž nejhorší možné náklady na utracení za daného
  jednotkového poplatku („feerate”). Předvídatelné váhy transakcí pomáhají vývojářům
  protokolů druhé vrstvy psát spolehlivější způsoby navyšování poplatků. Navíc
  pokud dodáme nějaké pravidlo, vygeneruje kompilátor minimální miniscriptový skript
  (ne nezbytně nejmenší možný, jelikož miniscript kóduje pouze podmnožinu všech
  skriptů), který může být menší než ručně vytvořený. Účastníci poznamenali, že
  miniscript již v minulosti pomohl optimalizovat skripty LN. Kompozice miniskriptu
  také umožňuje více stranám zkombinovat složité platební podmínky a garantuje
  správnost výsledného skriptu, aniž by jim všem rozuměla."
  a0link="https://bitcoincore.reviews/24148#l-41"

  q1="Výrazy miniscriptu mohou být reprezentovány jako stromy uzlů, kde každý uzel
  reprezentuje nějaký fragment. Co znamená, když je uzel „rozumný” či „validní”?
  Znamenají totéž?"
  a1="Každý uzel obsahuje nějaký typ fragmentu (např. `and_v`, `thresh`, `multi`, atd.)
  a argumenty. Argumenty validního uzlu souhlasí s tím, co typ fragmentu očekává.
  Rozumný uzel musí být validní a sémantika jeho skriptu musí odpovídat jeho podmínce,
  musí být validní z pohledu konsenzu a v souladu se standardností, všechna řešení
  musí být nepoddajná („non-malleable”), nesmí míchat timelockové jednotky (tj.
  používat zároveň výšku bloku i čas) a nesmí obsahovat duplikované klíče. Tyto dvě
  vlastnosti nejsou podle definice identické; každý rozumný uzel je validní, avšak
  ne každý validní uzel je rozumný."
  a1link="https://bitcoincore.reviews/24148#l-107"

  q2="Co znamená, když výraz není poddajně uspokojitelný? Proč nás po segwitu obavy o
  poddajnost stále zajímají?"
  a2="Skript je poddajný („malleable”), pokud jej může třetí strana (tj. někdo, kdo
  kromě jiného nemá přístup k odpovídajícímu soukromému klíči) modifikovat a i tak
  uspokojit jeho platební podmínky. Segwit neodstranil poddajnost transakcí, pouze
  zajistil, že modifikace transakcí neporuší validnost nepotvrzených potomků, ale
  poddajnost může být stále problémem z jiných důvodů. Například může-li útočník
  přidat data do witnessu a stále uspokojit platební podmínku, může tak snížit
  jednotkový poplatek transakce a negativně ovlivnit její propagaci. Výraz, který
  není poddajně uspokojitelný, nedává třetí straně žádnou možnost upravit existující
  uspokojitelný skript do jiného uspokojitelného skriptu. Rozsáhlejší příklad lez
  nalézt [zde][sipa miniscript]."
  a2link="https://bitcoincore.reviews/24148#l-170"

  q3="Která funkce je zodpovědná za parsování řetězce deskriptoru výstupů?
  Jak určí, zda řetězec představuje `MiniscriptDescriptor`?
  Jak řeší, když lze deskriptor parsovat několika způsoby?"
  a3="Funkce `ParseScript` v script/descriptor.cpp je zodpovědná za parsování
  řetězců deskriptorů výstupů. Nejprve vyzkouší všechny jiné typy deskriptorů a
  potom zavolá `miniscript::FromString`, aby zjistila, je-li řetězec validním
  miniscriptovým výrazem. Díky tomuto pořadí operací jsou deskriptory, které
  mohou být interpretovány jako miniscript i ne-miniscript (např. `wsh(pk(...))`),
  parsovány jako ne-miniscript."
  a3link="https://bitcoincore.reviews/24148-2#l-30"

  q4="Vybíráme-li mezi dvěma dostupnými řešeními, proč bychom raději měli
  preferovat to, které používá méně podpisů, než to s menším výsledným skriptem?"
  a4="Třetí strany snažící se modifikovat transakci (tj. bez přístupu k
  soukromým klíčům) mohou odstranit podpisy, ale nemohou přidat nové. Zvolením
  řešení s dodatečnými podpisy bychom umožnili třetí straně modifikovat skript,
  který by poté stále uspokojoval platební podmínky. Například pravidlo
  `or(and(older(21), pk(B)), thresh(2, pk(A), pk(B)))` má dvě cesty: buď může
  být utraceno vždy, když podepíší A i B, nebo po 21 blocích, když podepíše
  pouze B. Po 21 blocích jsou obě řešení dostupná, ale zveřejníme-li transakci
  s oběma podpisy, třetí strana může odstranit podpis A, ale druhá podmínka
  bude stále splnitelná. Pokud na druhou stranu zveřejníme cestu s podpisem B,
  útočník nemůže uspokojit druhou podmínku bez podpisu A."
  a4link="https://bitcoincore.reviews/24148-2#l-106"
%}

## Vydání nových verzí

*Vydání nových verzí populárních bitcoinových infrastrukturních projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [LND 0.15.0-beta.rc4][] je kandidátem na vydání příští verze tohoto oblíbeného LN uzlu.

## Významné změny v kódu a dokumentaci

*Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo] a [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #24408][] přidává RPC pro načtení transakcí z mempoolu,
  které utrácí daný výstup. To usnadňuje hledání výstupů tím, že transakce
  lze vybrat jednotlivě; není tak již třeba je načítat ze seznamu vráceného
  příkazem `getrawmempool`. Nový příkaz bude užitečný pro Lightning Network
  během hledání transakce utrácející nabíjející („funding”) transakci nebo pro
  načtení konfliktní transakce za účelem určení, proč selhalo odeslání
  [RBF][topic rbf] transakce.

- [LDK #1401][] přidává podporu pro zero-conf (bez konfirmací) otevírání kanálů.
  Související informace lze nalézt v souhrnu BOLT #910 níže.

- [BOLTs #910][] přidává dvě změny do specifikace LN. První přidává aliasy
  pro zkrácené identifikátory kanálů („short channel identifier”, SCID), které
  mohou navýšit soukromí a také umožní odkazování na kanál ještě před tím, než je
  jeho txid stabilní (tj. před tím, než obdrží nabíjející transakce dostatečné
  množství konfirmací). Druhá změna přidává feature bit `option_zeroconf`, který
  může být aktivován, když je uzel ochoten používat [zero-conf kanály][topic zero-conf channels].

{% include references.md %}
{% include linkers/issues.md v=2 issues="24408,1401,910" %}
[lnd 0.15.0-beta.rc4]: https://github.com/lightningnetwork/lnd/releases/tag/v0.15.0-beta.rc4
[reviews 24148]: https://bitcoincore.reviews/24148
[sipa miniscript]: https://bitcoin.sipa.be/miniscript
