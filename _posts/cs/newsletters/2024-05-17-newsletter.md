---
title: 'Zpravodaj „Bitcoin Optech” č. 303'
permalink: /cs/newsletters/2024/05/17/
name: 2024-05-17-newsletter-cs
slug: 2024-05-17-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Zpravodaj tento týden představuje nové schéma pro anonymní tokeny užívání, které
by mohly být použity pro oznamování LN kanálů a v několika dalších koordinačních
protokolech odolných vůči sybilím útokům, odkazuje na diskuzi o novém schématu
rozdělování BIP39 vět seedu, oznamuje alternativu k BitVM pro ověřování úspěšného
spuštění libovolných programů v interaktivních kontraktových protokolech
a sdílí návrhy na aktualizaci procesu tvorby BIPů.

## Novinky

- **Anonymní tokeny užívání:** Adam Gibson zaslal do fóra Delving Bitcoin
  [příspěvek][gibson autct] o schématu, které vyvinul a které umožní komukoliv,
  kdo je schopen [utratit klíčem][topic taproot] nějaké UTXO, aby prokázal možnost
  utratit jej bez nutnosti konkrétní UTXO odhalit. Tato práce navazuje na Gibsonův
  předchozí vývoj [PoDLE][news85 podle], mechanismu proti sybilímu útoku (je
  používán v implementaci [coinjoinu][topic coinjoin] Joinmarket), a [RIDDLE][news205 riddle].

  Jednou možností použití, kterou popisuje, je oznamování LN kanálů. Každý LN
  uzel oznamuje ostatním uzlům své kanály, aby mohly nalézt cesty sítí pro platby.
  Část těchto informací o kanálu je uložena v paměti a oznámení jsou často
  posílána opakovaně, aby bylo zajištěno, že dosáhnou co největšího počtu uzlů.
  Byl-li by útočník schopen levně produkovat oznámení o falešných kanálech,
  narušoval by tím hledání cest a plýtval by významným množstvím paměti a přenosového
  pásma čestných uzlů. LN uzly se proti tomu brání tím, že akceptují pouze oznámení
  podepsaná klíčem, který patří validnímu UTXO. To po vlastnících kanálu požaduje,
  aby identifikovali konkrétní UTXO, které spolu vlastní. Kvůli tomu lze
  asociovat prostředky kanálu s jinými minulými i budoucími onchain transakcemi,
  které vytvoří (nebo někdo může kvůli tomu vytvořit nepřesné asociace).

  Gibsonovo schéma, nazývané anonymní tokeny užívání se stromy křivek
  (anonymous usage tokens with curve trees, autct), umožňuje spoluvlastníkům
  kanálu podepsat zprávu, aniž by museli odhalit své UTXO. Útočník bez UTXO
  by nemohl takový validní podpis vytvořit. Útočník, který UTXO má k dispozici,
  by validní podpis vytvořit mohl, avšak musel by v něm držet tolik prostředků,
  kolik by uzel musel držet v kanálu. To omezuje dopady útoku v nejhorším možném
  případě. [Zpravodaj č. 261][news261 lngossip] obsahuje předchozí diskuzi
  o přerušení vztahu mezi [oznámeními kanálu][topic channel announcements]
  a konkrétními UTXO.

  Gibson dále popisuje několik dalších možných způsobů použití autct. Základní
  mechanismus pro podobný druh soukromí – kruhové podpisy (ring signatures) –
  je známý již dlouho. Avšak Gibson používá nový kryptografický konstrukt
  ([curve trees][], stromy křivek), díky kterému jsou důkazy kompaktnější
  a rychlejší na ověření. Každý důkaz skrytě zavazuje použitému klíči,
  jediné UTXO tedy nemůže vytvořit neomezený počet validních podpisů.

  Vedle [kódu][autct repo] zveřejnil Gibson také [fórum][hodlboard] jako
  ověření konceptu, které pro zaregistrování vyžaduje poskytnutí autct
  důkazu. Výsledkem je prostředí, kde je o každém účastníkovi známo,
  že vlastní bitcoiny, ale nikdo nemusí poskytnout žádné další informace
  o sobě či svých bitcoinech.

- **Dělení BIP39 vět seedu:** Rama Gan zaslal do emailové skupiny
  Bitcoin-Dev odkaz na [sadu nástrojů][penlock website] pro generování
  a dělení [BIP39][] vět seedu bez nutnosti používání jakýchkoliv
  elektronických výpočetních zařízení (kromě tisku instrukcí a šablon).
  Podobá se schématu [codex32][topic codex32], ale pracuje s BIP39,
  které jsou kompatibilní s téměř všemi současnými hardwarovými
  podpisovými zařízeními a mnoha softwarovými peněženkami.

  Andrew Poelstra, spoluautor codex32, poskytl v [odpovědi][poelstra penlock1]
  několik komentářů a návrhů. Bez vyzkoušení obou schémat (každé
  by zabralo několik hodin) nám není přesně známo, kde každé z nich
  učinilo kompromisy. Avšak zdá se, že obě dvě v základu nabízejí shodné
  možnosti: instrukce pro bezpečné offline generování seedu, možnost
  rozdělit seed do několika částí pomocí [Shamirova sdílení tajných dat][sss],
  schopnost spojit části do původního seedu a schopnost ověřit kontrolní
  součty jednotlivých částí i původního seedu, čímž může uživatel odhalit
  poškození dat dostatečně brzy na to, aby původní data mohl stále obnovit.

- **Alternativa k BitVM:** Sergio Demian Lerner se spoluautory zaslali
  do emailové skupiny Bitcoin-Dev [příspěvek][lerner bitvmx] o nové
  virtuální procesorové architektuře částečně založené na myšlenkách
  stojících za [BitVM][topic acc]. Cílem jejich projektu nazvaného
  BitVMX je efektivně vytvářet doklady o řádném provedení nějakého
  programu, který může být zkompilován pro běh na běžné procesorové
  architektuře, jako je [RISC-V][]. Podobně jako BitVM nevyžaduje ani
  BitVMX změny konsenzu, ale potřebuje, aby se jedna či více určených
  stran ujaly role důvěryhodného ověřovatele. Znamená to, že skupina uživatelů,
  kteří se interaktivně účastní protokolu, může zabránit jednomu (či více)
  z účastníků ve výběru peněz z kontraktu, dokud tento účastník úspěšně
  nespustí libovolný program specifikovaný tímto kontraktem.

  Lerner odkazuje na [článek][bitvmx paper] o BitVMX, který jej porovnává
  s původním BitVM (viz [zpravodaj č. 273][news273 bitvm]) a (i přes nedostupné
  podrobnosti) k následným projektům původních vývojářů BitVM. Doprovodná
  [webová stránka][bitvmx website] poskytuje dodatečné informace v méně
  technické podobě.

- **Diskuze o změnách BIP2 pokračuje:** Mark „Murch” Erhardt
  [pokračuje][erhardt bip2] v emailové skupině Bitcoin-Dev v diskuzi
  o změnách [BIP2][], což je dokument, který popisuje proces navrhování
  a schvalování BIP, návrhů na zlepšení bitcoinu. Jeho email popisuje
  několik problémů, navrhuje řešení mnoha z nich a žádá o poskytnutí
  zpětné vazby. [Zpravodaj č. 297][news297 bip2] popisuje předchozí
  diskuzi o změnách BIP2.

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [LND v0.18.0-beta.rc2][]  je kandidátem na vydání příští hlavní verze
  tohoto oblíbeného LN uzlu.

## Významné změny kódu a dokumentace

_Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Bitcoin Inquisition][bitcoin inquisition repo] a [repozitáři BINANA][binana
repo]._

- [Core Lightning #7190][] přidává do výpočtu hodnoty časového zámku [HTLC][topic htlc]
  dodatečný offset (nazývaný `chainlag`). To umožní HTLC cílit aktuální výšku bloku namísto
  výšky, kterou uzel naposledy zpracoval. Díky tomu mohou být platby bezpečné
  i během synchronizace blockchainu.

- [LDK #2973][] přidává do `OnionMessenger`u podporu pro zachycování [onion zpráv][topic
  onion messages] určených pro offline uzly. Generuje události při zachycení zprávy a když
  je spojení opět online. Uživatelé by měli udržovat seznam spojení, pro která se budou
  zprávy ukládat. Jedná se o další krok v podpoře [asynchronních plateb][topic async payments]
  pomocí `held_htlc_available`  ([BOLTs #989][]). Například Alice chce Carol
  poslat peníze přes Boba, ale Alice neví, zda je Carol online. Alice pošle Bobovi
  onion zprávu, Bob zprávu drží, dokud není Carol online. Nato Carol zprávu otevře
  a na základě ní pošle Alici (či jejímu poskytovateli služeb) žádost o platbu.
  Nakonec Alice Carol zaplatí běžným způsobem.

- [LDK #2907][] rozšiřuje metodu zpracovávající `OnionMessage` o volitelný parametr
  `Responder` a mění její návratový typ na `ResponseInstructions`, který udává, jak
  má být s odpovědí na zprávu naloženo. Tato změna umožní asynchronní odpovědi
  na onion zprávy a otevírá dveře komplexnějším mechanismům odpovědí, jakou jsou
  ty potřebné pro [asynchronní platby][topic async payments].

- [BDK #1403][] upravuje modul `bdk_electrum` tak, aby používal nové sync/full-scan
  struktury představené v [BDK #1413][], dotazovatelné spojové seznamy `CheckPoint`ů
  ([BDK #1369][]) a snadno klonovatelné transakce zapouzdřené v `Arc` ([BDK #1373][]).
  Tato změna zvyšuje efektivitu skenování transakcí během používání podobných serverů, jako
  je Electrum. Dále nově umožňuje načíst předchozí výstupy, což umožní výpočet poplatků
  transakcí přijatých z externí peněženky.

 - [BIPs #1458][] přidává [BIP352][], který navrhuje [tiché platby][topic silent
  payments], protokol pro znovupoužitelné adresy generující při každém použití onchain
  unikátní adresu. Návrh BIPu byl poprvé diskutován ve [zpravodaji č. 255][news255 bip352].

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when="2024-05-21 14:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="7190,2973,2907,1403,1458,989,1413,1369,1373" %}
[lnd v0.18.0-beta.rc2]: https://github.com/lightningnetwork/lnd/releases/tag/v0.18.0-beta.rc2
[gibson autct]: https://delvingbitcoin.org/t/anonymous-usage-tokens-from-curve-trees-or-autct/862/
[news261 lngossip]: /cs/newsletters/2023/07/26/#aktualizovana-oznameni-o-kanalech
[news205 riddle]: /cs/newsletters/2022/06/22/#riddle-novy-system-proti-sybil-utokum
[news85 podle]: /en/newsletters/2020/02/19/#using-podle-in-ln
[curve trees]: https://eprint.iacr.org/2022/756
[autct repo]: https://github.com/AdamISZ/aut-ct
[hodlboard]: https://hodlboard.org/
[gan penlock]: https://mailing-list.bitcoindevs.xyz/bitcoindev/9bt6npqSdpuYOcaDySZDvBOwXVq_v70FBnIseMT6AXNZ4V9HylyubEaGU0S8K5TMckXTcUqQIv-FN-QLIZjj8hJbzfB9ja9S8gxKTaQ2FfM=@proton.me/
[penlock website]: https://beta.penlock.io/
[poelstra penlock1]: https://mailing-list.bitcoindevs.xyz/bitcoindev/ZkIYXs7PgbjazVFk@camus/
[sss]: https://cs.wikipedia.org/wiki/%C5%A0amirovo_sd%C3%ADlen%C3%AD_tajemstv%C3%AD
[lerner bitvmx]: https://mailing-list.bitcoindevs.xyz/bitcoindev/5189939b-baaf-4366-92a7-3f3334a742fdn@googlegroups.com/
[risc-v]: https://cs.wikipedia.org/wiki/RISC-V
[bitvmx paper]: https://bitvmx.org/files/bitvmx-whitepaper.pdf
[news273 bitvm]: /cs/newsletters/2023/10/18/#platby-podminene-libovolnym-vypoctem
[bitvmx website]: https://bitvmx.org/
[erhardt bip2]: https://mailing-list.bitcoindevs.xyz/bitcoindev/0bc47189-f9a6-400b-823c-442974c848d5@murch.one/
[news297 bip2]: /cs/newsletters/2024/04/10/#aktualizace-bip2
[news255 bip352]: /cs/newsletters/2023/06/14/#navrh-bip-na-tiche-platby
