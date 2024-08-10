---
title: 'Zpravodaj „Bitcoin Optech” č. 291'
permalink: /cs/newsletters/2024/02/28/
name: 2024-02-28-newsletter-cs
slug: 2024-02-28-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Zpravodaj tento týden popisuje návrh kontraktu pro futures s těžebními
poplatky bez požadavku na důvěru, odkazuje na algoritmus výběru mincí
pro LN uzly nabízející likviditu v rámci oboustranného financování, zkoumá
prototyp úschovny používající `OP_CAT` a nahlíží na posílání a přijímání
ecash pomocí LN a ZKCP. Též nechybí naše pravidelné rubriky se souhrnem
oblíbených otázek a odpovědí z Bitcoin Stack Exchange, oznámeními o
nových vydáních a popisem změn v populárních bitcoinových páteřních
projektech.

## Novinky

- **Kontrakty pro futures s těžebními poplatky bez požadavku na důvěru:** ZmnSCPxj
  zaslal do fóra Delving Bitcoin [příspěvek][zmnscpxj futures] se souborem
  skriptů, které dvěma stranám umožní si navzájem podmínečně zaplatit
  (dle jednotkového poplatku) za začlenění transakce v budoucím bloku.
  V našem příkladu je Alice uživatelkou, která očekává začlenění transakce
  do bloku 1 000 000 (nebo krátce po něm). Bob je těžař, který má určitou
  šanci na vytěžení bloku v té době. Oba vloží nějaké prostředky na
  _financující transakci_, která může být utracena jedním ze tří způsobů:

  1. Bob obdrží zpět svůj vklad a navíc si nárokuje Alicin vklad tím, že
	 utratí výstup financující transakce v bloku 1 000 000 (nebo krátce
	 po něm). Skript vyžaduje, aby bylo Bobovo jednostranné utracení
	 o určité velikosti, například větší než dvě běžné platby.

  2. Druhou možností je, že Alice obdrží zpět svůj vklad a navíc si
	 nárokuje Bobův vklad tím, že utratí výstup financující
	 transakce někdy po bloku 1 000 000 (například o den později
	 v bloku 1 000 144). Alicina transakce je relativně malá.

  3. Jinou možností je, že Alice s Bobem kooperativně utratí výstup
	 financující transakce, jakkoliv si přejí. Zde je pro maximální
	 efektivitu použito [taprootové][topic taproot] utracení klíčem.

  Jsou-li jednotkové poplatky kolem bloku 1 000 000 nižší, než očekávali,
  může Bob do tohoto bloku začlenit svou velkou transakci (nebo bloku krátce
  po něm) a vydělat na tom. Pro Boba je to v období nízkých poplatků obzvláště
  výhodné, neboť není jako těžař za produkované bloky tolik bohatě odměňován.

  Jsou-li jednotkové poplatky kolem bloku 1 000 000 vyšší, než očekávali,
  nebude Bob chtít svou velkou transakci do bloku začlenit, neboť by ho
  to na poplatcích stálo více, než kolik by vydělal. Vydělat na tom tak může
  Alice, když bude její menší platba začleněna do bloku 1 000 144 (nebo pozdějšího).
  Pro Alici je to v období vysokých poplatků obzvláště výhodné, neboť
  tím budou kompenzovány vysoké náklady na začlenění běžné transakce
  do dříve plánovaného bloku 1 000 000.

  Dále pokud si Alice i Bob uvědomí, že bude pro Boba výdělečné začlenit
  jeho utracení do bloku 1 000 000, mohou oba kooperativně vytvořit
  menší transakci, než byla původní Bobova jednostranná verze. Díky
  tomu Bob ušetří na poplatcích a Alice může díky redukci množství dat
  v bloku 1 000 000 dostat svou transakci do plánovaného bloku s nižším
  poplatkem.

  Ve vlákně diskuze se objevilo několik reakcí. Jedna odpověď [poznamenala][harding
  futures], že tento kontrakt nejen že nevyžaduje důvěru (což je pro
  kontrakty vynucované konsenzem běžné), ale navíc neumožňuje podplácení
  protistrany. Pokud by například existoval centralizovaný trh s poplatkovými
  futures, Bob a ostatní těžaři by mohli [přijímat poplatky bokem][topic out-of-band
  fees] nebo využít jiných triků k manipulaci zjevného jednotkového poplatku.
  Se ZmnSCPxjovo konstrukcí to však nehrozí: Bobovo rozhodnutí, zda velkou transakci
  začlení nebo ne, závisí zcela na jeho úhlu pohledu na mempool a na současné
  podmínky těžby. Zmíněná reakce dále rozjímala, zda by neměli větší
  těžaři výhodu oproti menším. Anthony Towns [poskytl][towns futures]
  tabulku výdělků ukazující, že pokusy o manipulaci by vedly k vyšším výdělkům
  pro těžaře používající běžný algoritmus výběru transakcí.

- **Výběr mincí pro poskytovatele likvidity:** Richard Myers
  zaslal do fóra Delving Bitcoin [příspěvek][myers cs], ve kterém popisuje
  vytvoření algoritmu [výběru mincí][topic coin selection], který je
  optimalizován pro LN uzly nabízející likviditu pomocí [inzerátů][topic
  liquidity advertisements]. Jeho příspěvek algoritmus popisuje a
  odkazuje na jeho [PR][bitcoin core #29442] do Bitcoin Core. Během testování
  dosáhl „15% redukce onchain poplatků v porovnání s výchozím výběrem
  mincí [v Bitcoin Core].” Myers žádá o kritiku přístupu a návrhy
  na vylepšení.

- **Prototyp jednoduché úschovny používající `OP_CAT`:** vývojář Rijndael
  zaslal do fóra Delving Bitcoin [příspěvek][rijndael vault] o rustové
  implementaci [úschovny][topic vaults], kterou napsal jako ověření konceptu.
  Jeho implementace závisí pouze na současných pravidlech konsenzu
  a navrhovaném opkódu [OP_CAT][topic op_cat]. Uvádíme stručný příklad použití
  úschovny: Alice vygeneruje adresu se skriptem vytvořeným softwarem
  úschovny a obdrží na tuto adresu platbu. Nato se ona nebo nějaký zloděj pokusí
  tyto prostředky utratit.

  - *Legitimní platba:* Alice platbu zahájí vytvořením spouštěcí transakce
	se dvěma vstupy a dvěma výstupy. Jeden vstup utrácí částku z úschovny,
	druhý přidává poplatky. Jeden výstup představuje přípravný výstup se
	shodnou částkou prvního vstupu, druhý potom platí na případnou adresu
	pro vybrání. Po uplynutí určitého množství bloků dokončí Alice vybrání
	prostředků vytvořením transakce se dvěma vstupy a jedním výstupem:
	jeden vstup utrácí první výstup spouštěcí transakce, druhý přidává dodatečný
	poplatek. Výstup je adresou pro vybrání.

	V první transakci se pomocí `OP_CAT` a jednoho dříve popsaného triku
	se [Schnorrovým podpisy][topic schnorr signatures] (viz [zpravodaj č.
	134][news134 cat], _angl._) ověřuje, zda má utrácený výstup stejný skript
	a částku jako odpovídající právě vytvářený výstup. Tím se zajistí,
	že spouštěcí transakce nemůže z úschovny odeslat žádné prostředky.
	Druhá transakce ověřuje, že její první vstup obsahuje relativní
	[časový zámek][topic timelocks] dle [BIP68][] na určitý počet
	bloků (např. 20), že výstup platí shodnou částku jako první vstup a
	že výstup platí na adresu shodnou s druhým výstupem spouštěcí transakce.
	Relativní časový zámek poskytuje lhůtu na zpochybnění (viz níže).
	Ověření přesné částky zajišťuje, že žádné prostředky nemohou být odeslány
	bez povolení. Ověření adresy zabraňuje zlodějovi na poslední
	chvíli vyměnit legitimní adresu pro vybrání za svou vlastní (tímto
	problémem trpí, pokud víme, všechny předem podepsané úschovny, viz
	[zpravodaj č. 59][news59 vaults], _angl._).

  - *Nelegitimní platba:* Mallory zahájí platbu vytvořením spouštěcí transakce,
	jak bylo popsáno výše. Alicina [strážní věž][topic watchtowers] si během
	lhůty na zpochybnění uvědomí, že utracení není legitimní, a vytvoří
	transakci pro navrácení prostředků zpět do úschovny. Tato transakce má
	dva vstupy a jeden výstup. Jeden vstup je prvním výstupem spouštěcí
	transakce, druhý platí poplatek. Výstup vrací částku zpět do úschovny.
	Protože má transakce vracející prostředky do úschovny pouze jediný
	výstup, ale podmínky pro vybrání stanovené skriptem vyžadují utracení
	ze spouštěcí transakce se dvěma výstupy, není Mallory schopen krádež
	Aliciných peněz dokončit.

	Jelikož jsou peníze vráceny na stejný skript úschovny, může Mallory
	opět vytvořit novou spouštěcí transakci a nutit tak Alici podstupovat
	dokola stejný cyklus. Mallory i Alici vznikají náklady platbami poplatků.
	Rijndaelova [rozsáhlá dokumentace][cat vault readme] projektu poznamenává,
	že by bylo zřejmě v tom případě vhodnější, aby nechala Alice vrátit peníze
	na jiný skript. V jeho schématu je tato konstrukce možná, ale zatím
	není z důvodu zachování jednoduchosti implementována.

  Tyto úschovny založené na CAT mohou být srovnány s předem podepsanými
  úschovnami, které lze vytvářet již nyní bez změn konsenzu, a s úschovnami
  ve stylu [BIP345][] (`OP_VAULT`), které by v případě přidání soft forkem
  nabízely dosud nejlepší soubor vlastností.

  <table>
  <tr>
  <th></th>
  <th>Předem podepsané</th>
  <th markdown="span">

  BIP345 `OP_VAULT`

  </th>
  <th markdown="span">

  `OP_CAT` se Schnorrem

  </th>
  </tr>

  <tr>
  <th>Dostupnost</th>
  <td markdown="span">

  **Nyní**

  </td>
  <td markdown="span">

  Vyžaduje soft fork s `OP_VAULT` a [OP_CTV][topic op_checktemplateverify]

  </td>
  <td markdown="span">

  Vyžaduje soft fork s `OP_CAT`

  </td>
  </tr>

  <tr>
  <th markdown="span">Útok nahrazení adresy na poslední chvíli</th>
  <td markdown="span">Zranitelné</td>
  <td markdown="span">

  **Nejsou zranitelné**

  </td>
  <td markdown="span">

  **Nejsou zranitelné**

  </td>
  </tr>

  <tr>
  <th markdown="span">Vybrání části prostředků</th>
  <td markdown="span">Pokud zajištěno předem</td>
  <td markdown="span">

  **Ano**

  </td>
  <td markdown="span">Ne</td>
  </tr>

  <tr>
  <th markdown="span">Statické a neinteraktivně odvoditelné adresy pro vklady</th>
  <td markdown="span">Ne</td>
  <td markdown="span">

  **Ano**

  </td>
  <td markdown="span">

  **Ano**

  </td>
  </tr>

  <tr>
  <th markdown="span">Redukce poplatků dávkovým návratem do úschovny</th>
  <td markdown="span">Ne</td>
  <td markdown="span">

  **Ano**

  </td>
  <td markdown="span">Ne</td>
  </tr>

  <tr>
  <th markdown="span">

  Provozní účinnost v nejlepším případě, tedy pouze legitimní platby<br>*(hrubý odhad Optechu)*

  </th>
  <td markdown="span">

  **2× velikost běžné single-sig**

  </td>
  <td markdown="span">3× velikost běžné single-sig</td>
  <td markdown="span">4× velikost běžné single-sig</td>
  </tr>
  </table>

  V době psaní zpravodaje se tento prototyp setkal s malým množství diskuze a rozboru.

- **Posílání a přijímání ecash pomocí LN a ZKCP:** Anthony Towns
  zaslal do fóra Delving Bitcoin [příspěvek][towns lnecash] o napojení
  „[ecashových][topic ecash] mincoven do Lightning Network bez ztráty
  anonymity či bez potřeby vyššího stupně důvěry.“ Jeho návrh používá
  podmíněné platby s nulovou znalostí ([ZKCP][topic acc], „zero-knowledge
  contingent payment”) pro odeslání platby uživateli ecash. Dále popisuje
  proces, jak použít commitment předobrazu hashe potřebný pro odeslání
  ecashových prostředků do LN.

  Calle, vedoucí vývojář ecashové implementace [Cashu][], uvedl v odpovědi
  některé potenciální problémy, ale též vyjádřil myšlence podporu. Dále
  poskytl odkaz na systém důkazů s nulovou znalostí implementovaný v Cashu
  a poznamenal, že aktivně zkoumá a implementuje podporu atomických
  plateb z ecash do LN.

## Vybrané otázky a odpovědi z Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] je jedním z prvních míst, kde hledají
přispěvatelé Optechu odpovědi na své otázky a kde – najdou-li volnou chvíli –
pomáhají zvědavým či zmateným uživatelům. V této měsíční rubrice nabízíme
některé z otázek a odpovědí, které obdržely vysoký počet hlasů.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aa
nswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Proč nemohou mít uzly volbu pro zakázání přeposílání některých typů transakcí?]({{bse}}121734)
  Ava Chow uvažuje o smyslu [mempoolu a pravidel přeposílání][policy series], výhodách
  stejnorodých mempoolů včetně [odhadu poplatků][topic fee estimation] a [přeposílání kompaktních
  bloků][topic compact block relay] a dotýká se i obcházení pravidel například
  [placením poplatků][topic  out-of-band fees] těžařům mimo blockchain.

- [Co je kruhová závislost při podepisování řady nepotvrzených transakcí?]({{bse}}121959)
  Ava Chow vysvětluje problém [kruhových závislostí][mastering 06 cds] při
  používání nepotvrzených zastaralých druhů bitcoinových transakcí.

- [Jak funguje systém výplat TIDES u Ocean?]({{bse}}120719)
  Uživatel Lagrang3 objasňuje systém výplat TIDES (Transparent Index of Distinct Extended
  Shares) používaný těžebním poolem Ocean.

- [Jaká data peněženka Bitcoin Core vyhledává během skenování blockchainu?]({{bse}}121563)
  Pieter Wuille a Ava Chow shrnují, jak peněženka Bitcoin Core identifikuje transakce
  související se zastaralým druhem peněženky nebo s peněženkou založenou na [deskriptorech][topic
  descriptors].

- [Jak funguje opakované zveřejňování transakcí u watch-only peněženek?]({{bse}}121899)
  Ava Chow poznamenává, že logika opakovaného zveřejňování transakcí nezávisí na
  druhu peněženky. Nicméně, aby se uzel pokoušel opakovaně zveřejnit transakci
  z watch-only peněženky, musela být transakci v nějakém okamžiku přijata do
  jeho mempoolu.

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [Core Lightning 24.02][] je vydáním příští hlavní verze tohoto populárního LN uzlu.
  Obsahuje vylepšení pluginu `recover`, díky kterým „jsou nouzové obnovy méně stresující,“
  vylepšení [anchor kanálů][topic anchor outputs], o 50 % rychlejší synchronizaci
  blockchainu a opravu chyby parsování velké transakce nalezené na testnetu.

## Významné změny kódu a dokumentace

_Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Bitcoin Inquisition][bitcoin inquisition repo] a [repozitáři BINANA][binana
repo]._

- [LDK #2770][] přináší přípravy na budoucí podporu [kanálů s oboustranným financováním][topic
  dual funding].

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 15:00" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="2770,29442" %}
[Core Lightning 24.02]: https://github.com/ElementsProject/lightning/releases/tag/v24.02
[myers csliq]: https://delvingbitcoin.org/t/liquidity-provider-utxo-management/600
[news134 cat]: /en/newsletters/2021/02/03/#replicating-op-checksigfromstack-with-bip340-and-op-cat
[news59 vaults]: /en/newsletters/2019/08/14/#bitcoin-vaults-without-covenants
[cashu]: https://github.com/cashubtc/nuts
[zmnscpxj futures]: https://delvingbitcoin.org/t/an-onchain-implementation-of-mining-feerate-futures/547
[harding futures]: https://delvingbitcoin.org/t/an-onchain-implementation-of-mining-feerate-futures/547/2
[myers cs]: https://delvingbitcoin.org/t/liquidity-provider-utxo-management/600
[rijndael vault]: https://delvingbitcoin.org/t/basic-vault-prototype-using-op-cat/576
[cat vault readme]: https://github.com/taproot-wizards/purrfect_vault
[towns lnecash]: https://delvingbitcoin.org/t/ecash-and-lightning-via-zkcp/586
[towns futures]: https://delvingbitcoin.org/t/an-onchain-implementation-of-mining-feerate-futures/547/6?u=harding
[policy series]: /cs/blog/waiting-for-confirmation/
[mastering 06 cds]: https://github.com/bitcoinbook/bitcoinbook/blob/develop/ch06_transactions.adoc#circular-dependencies
[calle lnecash]: https://delvingbitcoin.org/t/ecash-and-lightning-via-zkcp/586/2
