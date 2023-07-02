---
title: 'Zpravodaj „Bitcoin Optech” č. 256'
permalink: /cs/newsletters/2023/06/21/
name: 2023-06-21-newsletter-cs
slug: 2023-06-21-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Tento týden přinášíme souhrn diskuze o rozšíření BOLT11 faktur o
požadavek na dvě platby. Též nechybí další příspěvek do naší krátké
týdenní série o pravidlech mempoolu a naše pravidelné rubriky
popisující změny v klientech a službách, nová vydání a změny v populárních
bitcoinových páteřních projektech.

## Novinky

- **Návrh na rozšíření BOLT11 faktur o požadavek na dvě platby:** Thomas
  Voegtlin zaslal do emailové skupiny Lightning-Dev [příspěvek][v 2p]
  s návrhem, aby byly [BOLT11][] faktury rozšířeny o volitelnou možnost
  odesílatele vyžádat od plátce dvě oddělené platby, každou s vlastním
  tajným kódem a částkou. Voegtlin vysvětluje užitečnost návrhu pro
  [submarine swaps][topic submarine swaps] a [JIT kanály][topic jit channels]:

    - *Submarine swaps* v případě, kdy platba offchain LN faktury vyústí
      v přijetí onchain prostředků (opačný směr zde neuvažujeme).
      Onchain příjemce zvolí tajný kód a offchain plátce zaplatí [HTLC][topic
      htlc] s hashem tohoto kódu, které je směrováno po LN k poskytovateli
      submarine swap. Tento poskytovatel obdrží offchain HTLC a vytvoří
      onchain transakci platící za toto HTLC. Až bude uživatel považovat
      onchain transakci za zabezpečenou, odhalí tajný kód k vyrovnání
      onchain HTLC, což umožní poskytovateli vyrovnat offchain HTLC
      (a kteroukoliv další platbu v LN závislou na stejném tajném kódu).

      Pokud však příjemce tajný kód neodhalí, neobdrží poskytovatel žádnou
      kompenzaci a bude muset utratit právě vytvořený onchain výstup, což
      mu přinese nadbytečné náklady. Aby předešly tomuto zneužití, požadují
      existující poskytovatelé po plátci LN poplatek (zaslaný před vytvořením
      onchain transakce), který může být zcela či zčásti vrácen po vyrovnání
      onchain HTLC. Tento poplatek a submarine swap obsahují odlišné částky a
      musí být vyrovnány v odlišných časech, musí tedy použít i odlišný tajný
      kód. Současná BOLT11 faktura může obsahovat pouze jeden commitment k
      tajnému kódu a jednu částku. Každá peněženka poskytující submarine
      swaps tedy musí buď interakci se serverem obstarat sama nebo nechat
      dokončení tohoto postupu na plátci a příjemci.

    - *Just-in-Time (JIT) kanály*, kde uživatel bez kanálů (nebo bez likvidity)
      vytvoří s poskytovatelem služeb virtuální kanál. V okamžiku přijetí
      první platby do tohoto virtuálního kanálu vytvoří poskytovatel onchain
      transakci, která kanál otevře a zároveň provede tuto platbu. Tato offchain
      platba je jako kterékoliv jiné HTLC učiněna oproti tajnému kódu, který
      zná jen příjemce (uživatel). Je-li uživatel ujištěn, že otevření JIT
      kanálu je zajištěno, odhalí tajný kód a platbu nárokuje.

      Pokud však opět uživatel tajný kód neodhalí, neobdrží poskytovatel
      kompenzaci a vyvstanou mu dodatečné onchain náklady. Voegtlin věří,
      že existující poskytovatelé JIT kanálů se tomuto problému vyhýbají
      tím, že vyžadují odhalení tajného kódu před tím, než je otevírací
      transakce zajištěna, což podle něj může vytvářet problémy se zákonem
      a zabraňuje nekustodiálním peněženkám podobnou službu nabízet.

  Voegtlin věří, že kdyby BOLT11 faktura obsahovala dva separátní commitmenty,
  každý na jinou částku a k jinému tajnému kódu, umožnilo by to použít jeden
  kód a částku na poplatek placený dopředu (za onchain transakci) a druhý kód
  a částku na vlastní submarine swap nebo otevření JIT kanálu. Návrh obdržel
  několik komentářů, o některých se zde krátce zmíníme:

    - *Logika speciálně pro submarine swaps:* Olaoluwa Osuntokun
      [poznamenal][o 2p], že příjemce submarine swap musí vytvořit tajný kód,
      distribuovat ho a vyrovnat oproti němu platbu onchain. Nejlevnějším
      způsobem tohoto vyrovnání je interakce s poskytovatelem swapu.
      Pokud plátce i příjemce musí s poskytovatelem tak jako tak komunikovat,
      což se s existujícími implementacemi často děje, nemusí si předávat
      dodatečné informace v rámci faktury. Voegtlin [odpověděl][v 2p2], že
      tuto interakci může obstarat vyhrazený software a nebude tedy potřeba
      přidávat logiku do offchain peněženky, která platí prostředky, a onchain
      peněženky, která je přijímá. To by však bylo možné jen, pokud by
      LN peněženka mohla učinit dvě oddělené platby v rámci jedné smlouvy.

    - *Stabilita BOLT11:* Matt Corallo [odpověděl][c 2p], že všechny LN
      implementace stále ještě nemají podporu pro faktury bez částky (k umožnění
      [spontánních plateb][topic spontaneous payments]), nemyslí si tedy, že
      by přidání dalšího pole bylo nyní dobrým přístupem. Bastien Teinturier
      [odpověděl podobně][t 2p] a navrhl raději přidat podporu do
      [nabídek][topic offers]. Voegtlin [nesouhlasí][v 2p3] a myslí si, že
      přidání podpory je praktické.

    - *Splice-out jako alternativa:* Corallo se dále táže, proč by měl být
      protokol pozměněn, aby podporoval submarine swaps, pokud by byly
      dostupné [splice outs][topic splicing]. V konverzaci to nebylo zmíněno,
      avšak submarine swaps i splice outs umožňují přesunout offchain prostředky
      na onchain výstup, ale splice outs mohou být efektivnější onchain a
      netrpí problémem nekompenzovaného poplatku. Voegtlin odpověděl, že
      submarine swaps umožňují uživatelům LN navýšit svou kapacitu pro
      přijímání LN plateb, což splicing neumožňuje.

  V době psaní byla diskuze stále aktivní.

## Čekání na potvrzení 6: konzistence pravidel

_Krátká týdenní [série][policy series] o přeposílání transakcí, začleňování do mempoolu a výběru
transakcí k těžbě včetně vysvětlení, proč má Bitcoin Core přísnější pravidla,
než co je povoleno konsenzem, a jak mohou peněženky využít pravidla co nejefektivněji._

{% include specials/policy/cs/06-consistency.md %}

## Změny ve službách a klientech

*V této měsíční rubrice upozorňujeme na zajímavé aktualizace bitcoinových
peněženek a služeb.*

- **Knihovny Greenlight open source:**
  Nekustodiální CLN poskytovatel služeb [Greenlight][news162 greenlight]
  [zveřejnil][decker twitter] [repozitář][github greenlight] klientských knihoven,
  jazykových rozhraní a také [průvodce testovacím frameworkem][greenlight testing].

- **Debugger tapscriptu Tapsim:**
  [Tapsim][github tapsim] je nástrojem pro debugování (viz [zpravodaj č. 254][news254
  tapsim]) a vizualizaci [tapscriptu][topic tapscript] používající btcd.

- **Oznámen Bitcoin Keeper 1.0.4:**
  [Bitcoin Keeper][] je mobilní peněženka podporující multisig, hardwarová podpisová
  zařízení, [BIP85][] a díky poslednímu vydání také [coinjoin][topic coinjoin]
  používající [protokol Whirlpool][gitlab whirlpool].

- **Oznámena lightningová peněženka EttaWallet:**
  Nedávno byla [oznámena][ettawallet blog] mobilní [EttaWallet][github ettawallet]
  s LN (díky LDK) a důrazem na použitelnost inspirovanou referenčním designem [daily
  spending wallet][bitcoin design guide] od Bitcoin Design Community.

- **Oznámeno ověření konceptu synchronizace hlaviček bloků založených na zkSNARKs:**
  [BTC Warp][github btc warp] je ověřením konceptu lehkého synchronizačního klienta
  používajícího zkSNARKs k prokázání a ověření řetězce hlaviček bitcoinových bloků.
  Více podrobností lze nalézt v [blogovém příspěvku][btc warp blog].

- **Vydán lnprototest v0.0.4:**
  Projekt [lnprototest][github lnprototest] je testovacím nástrojem pro LN včetně
  „sady pomocných funkcí napsaných v Python3 navržených k usnadnění psaní nových
  testů navrhovaných změn protokolu LN a testů existujících implementací.”

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [Eclair v0.9.0][] je novým vydáním této implementace LN, které „obsahuje
  hodně přípravných prací důležitých (a složitých) lightningových funkcí:
  [dual-funding][topic dual funding], [splicing][topic splicing] a [BOLT12 nabídky][topic
  offers].” Tyto funkce jsou prozatím experimentální. Vydání také „dává nové
  schopnosti pluginům, přináší opatření proti několika typům DoS a zlepšuje
  výkonnost v mnoha oblastech.”

## Významné změny v kódu a dokumentaci

*Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo] a
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [LDK #2294][] přidává podporu pro přehrávání [onion zpráv][topic onion messages]
  a přináší LDK blíže k plné podpoře [nabídek][topic offers].

- [LDK #2156][] přidává podporu [keysend plateb][topic spontaneous payments], které
  používají [zjednodušené platby s více cestami][topic multipath payments]. LDK dříve
  podporovalo obě tyto technologie, avšak pouze pokud byly použité odděleně.
  Platby s více cestami musí používat [skrytá data][topic payment secrets], ale
  LDK dříve odmítalo keysend platby se skrytými daty. Byla také přidána chybová
  hlášení, nastavení a varování, aby potenciálním problémům zabránila.

{% include references.md %}
{% include linkers/issues.md v=2 issues="2294,2156" %}
[policy series]: /cs/blog/waiting-for-confirmation/
[v 2p]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-June/003977.html
[o 2p]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-June/003978.html
[v 2p2]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-June/003979.html
[c 2p]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-June/003980.html
[t 2p]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-June/003982.html
[v 2p3]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-June/003981.html
[eclair v0.9.0]: https://github.com/ACINQ/eclair/releases/tag/v0.9.0
[news162 greenlight]: /en/newsletters/2021/08/18/#blockstream-announces-non-custodial-ln-cloud-service-greenlight
[decker twitter]: https://twitter.com/Snyke/status/1666096470884515840
[github greenlight]: https://github.com/Blockstream/greenlight
[greenlight testing]: https://blockstream.github.io/greenlight/tutorials/testing/
[github tapsim]: https://github.com/halseth/tapsim
[news254 tapsim]: /cs/newsletters/2023/06/07/#vyuziti-matt-k-napodobeni-ctv-a-sprave-joinpoolu
[Bitcoin Keeper]: https://bitcoinkeeper.app/
[gitlab whirlpool]: https://code.samourai.io/whirlpool/whirlpool-protocol
[github ettawallet]: https://github.com/EttaWallet/EttaWallet
[ettawallet blog]: https://rukundo.mataroa.blog/blog/introducing-ettawallet/
[bitcoin design guide]: https://bitcoin.design/guide/daily-spending-wallet/
[github btc warp]: https://github.com/succinctlabs/btc-warp
[btc warp blog]: https://blog.succinct.xyz/blog/btc-warp
[github lnprototest]: https://github.com/rustyrussell/lnprototest
