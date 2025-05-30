---
title: 'Zpravodaj „Bitcoin Optech” č. 356'
permalink: /cs/newsletters/2025/05/30/
name: 2025-05-30-newsletter-cs
slug: 2025-05-30-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Zpravodaj tento týden shrnuje diskuzi o možných dopadech informací
o původci chyb na soukromí v LN. Též nechybí naše pravidelné rubriky
s vybranými otázkami a odpověďmi z Bitcoin Stack Exchange, oznámeními
nových vydání a popisem nedávných změn v populárním bitcoinovém
páteřním software.

## Novinky

- **Snižují informace o původci chyb soukromí v LN?** Carla Kirk-Cohen
  zaslala do fóra Delving Bitcoin [příspěvek][kirkcohen af] s analýzou
  možných dopadů na soukromí odesílatelů a příjemců v LN, pokud by síť
  začala používat [informace o původci chyb][topic attributable failures]
  (attributable failures), obzvláště informování odesílatele o počtu
  pokusů o přeposlání v každém skoku. Na základě několika citovaných
  článků popisuje dva druhy deanonymizačních útoků:

  - Útočník provozující jeden či více přeposílajících uzlů může
    měřením času určit počet skoků použitých platbou ([HTLC][topic
    htlc]), což může v kombinaci se znalostí topografie veřejné sítě
    zúžit seznam možných příjemců.

  - Útočník používající směrovač IP síťového provozu
    ([autonomní systém][autonomous system]) může pasivně monitorovat provoz a zkombinovat ho se znalostí
    latence IP sítě mezi uzly (např. měřením času ping) a topografie
    veřejné sítě LN.

  Dále popisuje možná řešení, včetně:

  - vyzývání příjemců, aby zpozdili přijetí HTLC o drobný náhodný čas,
    čímž by zabránili útokům měřením času k odhalení identity uzlu
    příjemce.

  - vyzývání odesílatelů, aby zpozdili opakované odesílání chybných
    plateb (nebo [MPP][topic multipath payments] částí) o drobný náhodný
    čas a používali alternativní cesty, čímž by zabránili útokům
    měřením času a vyvoláním selhání k odhalení identity uzlu odesílatele.

  - častějšího dělení platby pomocí MPP, což by ztížilo odhad celkové částky.

  - možnosti odesílatelů zpomalit přeposílání svých plateb, jak bylo již
    dříve navrženo (viz [zpravodaj č. 208][news208 slowln], _angl._).
    To by mohlo být zkombinováno s dávkováním HTLC, které LND již podporuje
    (avšak přidání náhodného zpoždění by soukromí dále navýšilo).

  - snížení přesnosti časových razítek v informacích o původci chyby.
    Tím by nebyly přeposílající uzly přidávající drobná náhodná zpoždění
    penalizovány.

  Účastníci diskuze podrobněji hodnotili riziko a navrhovaná řešení a
  hovořili o další možných útocích a opatřeních.

## Vybrané otázky a odpovědi z Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] je jedním z prvních míst, kde hledají
přispěvatelé Optechu odpovědi na své otázky a kde – najdou-li volnou chvíli –
pomáhají zvědavým či zmateným uživatelům. V této měsíční rubrice nabízíme
některé z otázek a odpovědí, které obdržely vysoký počet hlasů.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Jak se transakce dostanou do blockreconstructionextratxn?]({{bse}}116519)
  Glozow vysvětluje, jak datová struktura extrapoolu (viz [zpravodaj č. 339][news339
  extrapool]) kešuje odmítnuté a nahrazené transakce, které uzel obdržel,
  a vysvětluje kritéria pro jejich zamítání a vylučování.

- [Proč by někdo používal OP_RETURN namísto inscriptions (kromě poplatků)?]({{bse}}126208)
  Sjors Provoost poznamenává, že kromě nižších nákladů může být `OP_RETURN`
  používán v protokolech, které vyžadují, aby byla data dostupná před utracením
  transakce a ne – jako v případě dat witnessu – odhalena až v utrácející transakci.

- [Proč nemá můj bitcoinový uzel žádná příchozí spojení?]({{bse}}126338)
  Lightlike vysvětluje, že může trvat, než se adresa nového uzlu dostatečně
  propaguje v P2P síti a že uzly nezačnou svou adresu šířit, dokud není
  dokončeno úvodní stahování bloků.

- [Jak můžu nastavit svůj uzel, aby filtroval transakce větší než 400 bajtů?]({{bse}}126347)
  Antoine Poinsot potvrzuje, že v Bitcoin Core není žádná volba pro vlastní
  nastavení maximální velikosti standardních transakcí. Dodává, že uživatelé,
  kteří chtějí tuto hodnotu upravit, mohou změnit zdrojové kódy. Upozorňuje
  však na potenciální nevýhody vyšších i nižších hodnot.

- [Co v Bitcoin Core P2P znamená „not publicly routable”?]({{bse}}126225)
  Pieter Wuille a Vasil Dimov poskytují příklady P2P spojení, jako je
  na příklad [Tor][topic anonymity networks], která nemohou být v globálním
  internetu použita pro směrování a která se nacházejí v oddílu „npr“ ve výstupu
  `netinfo` v Bitcoin Core.

- [Proč by měl uzel přeposílat transakce?]({{bse}}127391)
  Pieter Wuille vyjmenovává výhody, které provozovatelovi uzlu přeposílání
  transakcí nabízí: soukromí během zveřejňování vlastních transakcí,
  rychlejší propagace bloků pro těžící uzly a vyšší míra decentralizace
  sítě. To vše s jen mírnými náklady nad rámec pouhého přeposílání bloků.

- [Je sobecká těžba stále možná i s kompaktními bloky a FIBRE?]({{bse}}49515)
  Antoine Poinsot dodává k otázce z roku 2016: „Ano, sobecká těžba je stále
  možnou optimalizací i přes vylepšenou propagaci bloků. Není správné považovat
  sobeckou těžbu již za pouze teoretický útok.” Dále odkazuje na svou
  [simulaci těžby][miningsimulation github].

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [Core Lightning 25.05rc1][] je kandidátem na vydání další hlavní verze této
  oblíbené implementace LN uzlu.

- [LDK 0.1.3][] a [0.1.4][ldk 0.1.4] jsou vydáními této populární knihovny
  pro budování aplikací s LN. Verze 0.1.3, otagována jako vydání na GitHubu
  tento týden ale datovaná minulý měsíc, obsahuje opravu útoku odepřením
  služby. Verze 0.1.4, nejnovější vydání, „opravuje zranitelnost umožňující
  v extrémně vzácných případech krádež prostředků.” Obě vydání obsahují
  i další opravy.

## Významné změny kódu a dokumentace

_Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo] a [repozitáři BINANA][binana repo]._

- [Bitcoin Core #31622][] přidává do [PSBT][topic psbt] pole druhu haše podpisu
  (sighash), je-li odlišné od `SIGHASH_DEFAULT` či `SIGHASH_ALL`. Podpora pro
  [MuSig2][topic musig] vyžaduje, aby všichni podepsali stejným druhem haše,
  proto musí v PSBT toto pole být přítomné. Dále bude RPC `descriptorprocesspsbt`
  používat funkci `SignPSBTInput`, která zajistí, aby druh haše v PSBT
  odpovídal volbě poskytnuté v CLI.

- [Eclair #3065][] přidává podporu informací o původci selhání (attributable failures,
  viz [zpravodaj č. 224][news224 failures], _angl._) dle specifikace v [BOLTs #1044][].
  Ve výchozím nastavení je neaktivní, protože specifikace není ještě finalizována,
  může být aktivována nastavením volby `eclair.​features.​option_attributable_failure` na `optional`.
  Úspěšně otestována byla kompatibilita s LDK; [zpravodaj č. 349][news349 failures]
  poskytuje o implementaci v LDK a fungování protokolu více informací.

- [LDK #3796][] zpřísňuje kontrolu zůstatku kanálu, aby měla zakládající strana
  dostatečné prostředky na pokrytí poplatku commitment transakce, dvou 330satových
  [anchor výstupů][topic anchor outputs] a rezervy kanálu. Dříve bylo možné
  pro zaplacení dvou anchorů sáhnout do rezerv kanálu.

- [BIPs #1760][] začleňuje [BIP53][], který specifikuje soft fork konsenzu
  zakazující 64bajtové transakce (bez dat witnessu). Toto pravidlo zabrání
  jednomu druhu [zranitelnosti Merkleova stromu][topic merkle tree vulnerabilities],
  které lze zneužít proti SPV klientům. PR navrhuje podobnou opravu jako
  soft fork [pročištění konsenzu][topic consensus cleanup].

- [BIPs #1850][] odstraňuje nedávnou změnu [BIP48][], která rezervovala hodnotu
  typu skriptu 3 pro [taprootové][topic taproot] (P2TR) derivace (viz
  [zpravodaj č. 353][news353 bip48]). Důvodem je, že [tapscript][topic tapscript]
  nepodporuje `OP_CHECKMULTISIG`, a proto výstupní skript v [BIP67][] (na kterém
  [BIP48][] závisí) nemůže být v P2TR vyjádřen. PR dále mění stav [BIP48][] na `Final`,
  čímž indikuje, že jeho účelem bylo definovat používání derivačních cest (`m/48'`)
  v [hierarchických deterministických peněženkách][topic bip32] v době představení
  BIPu a ne předepisovat nové chování.

- [BIPs #1793][] začleňuje [BIP443][] navrhující opkód [OP_CHECKCONTRACTVERIFY][topic
  matt] (OP_CCV). Ten umožňuje ověřit, zda nějaký veřejný klíč (vstupů či výstupů)
  zavazuje nějakým libovolným datům. Viz též [zpravodaj č. 348][news348 op_ccv], který
  o tomto navrhovaném [kovenantu][topic covenants] poskytuje další informace.

{% include snippets/recap-ad.md when="2025-06-03 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="31622,3065,3796,1760,1850,1793,1044" %}
[Core Lightning 25.05rc1]: https://github.com/ElementsProject/lightning/releases/tag/v25.05rc1
[ldk 0.1.3]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.1.3
[ldk 0.1.4]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.1.4
[news208 slowln]: /en/newsletters/2022/07/13/#allowing-deliberately-slow-ln-payment-forwarding
[autonomous system]: https://cs.wikipedia.org/wiki/Autonomn%C3%AD_syst%C3%A9m
[kirkcohen af]: https://delvingbitcoin.org/t/latency-and-privacy-in-lightning/1723
[news224 failures]: /en/newsletters/2022/11/02/#ln-routing-failure-attribution
[news349 failures]: /cs/newsletters/2025/04/11/#ldk-2256
[news353 bip48]: /cs/newsletters/2025/05/09/#bips-1835
[news348 op_ccv]: /cs/newsletters/2025/04/04/#semantika-op-checkcontractverify
[news339 extrapool]: /cs/newsletters/2025/01/31/#aktualizovane-statistiky-rekonstruovani-kompaktnich-bloku
[miningsimulation github]: https://github.com/darosior/miningsimulation
