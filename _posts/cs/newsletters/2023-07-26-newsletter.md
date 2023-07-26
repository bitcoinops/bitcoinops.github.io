---
title: 'Zpravodaj „Bitcoin Optech” č. 261'
permalink: /cs/newsletters/2023/07/26/
name: 2023-07-26-newsletter-cs
slug: 2023-07-26-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Tento týden popisujeme protokol pro zjednodušení komunikace v rámci
kooperativního uzavření LN kanálu a přinášíme souhrn poznámek k
nedávnému setkání vývojářů LN. Též nechybí naše pravidelné rubriky
s oblíbenými otázkami a odpověďmi z Bitcoin Stack Exchange, oznámeními
o nových verzích a popisem významných změn v populárních bitcoinových
páteřních projektech.

## Novinky

- **Jednodušší zavírání LN kanálů:** Rusty Russell zaslal do emailové
  skupiny Lightning-Dev [příspěvek][russell closing] s návrhem na
  zjednodušení procesu, kterým dva LN uzly kooperativně zavírají kanál.
  V novém protokolu uzavírání kanálu informuje jeden z uzlů svou protistranu,
  že si přeje zavřít kanál, a určí výši transakčního poplatku, který zaplatí.
  Tento iniciátor uzavření bude zodpovědný za celý poplatek, avšak
  oba výstupy typické transakce kooperativního uzavření kanálu budou
  okamžitě utratitelné, kterákoliv strana tedy bude moci použít
  [navýšení poplatku pomocí CPFP][topic cpfp]. Nový protokol má též
  kompatibilní způsob výměny informací s [protokoly vícenásobného
  podpisu][topic multisignature] založenými na [MuSig2][topic musig],
  který jsou součástí vyvíjených vylepšení LN mající za cíl navýšení
  soukromí a snížení onchain nákladů.

  V době psaní neobdržel Russellův návrh v emailové skupině žádné komentáře,
  avšak pod jeho [pull requestem][bolts #1096] se již několik reakcí
  objevilo.

- **Poznámky k LN summitu:** Carla Kirk-Cohen zaslala do emailové skupiny
  Lightning-Dev [příspěvek][kc notes] se souhrnem diskuzí z nedávného
  setkání vývojářů LN v New Yorku. Mezi diskutovanými tématy bylo:

    - *Spolehlivé potvrzování transakcí:* [přeposílání balíčků][topic
      package relay], [přeposílání v3 transakcí][topic v3 transaction relay],
      [dočasné anchor výstupy][topic ephemeral anchors], [cluster
      mempool][topic cluster mempool] i další témata související s
      přeposíláním transakcí a těžbou byly předmětem diskuzí v kontextu
      hledání jasnější cesty ke spolehlivějšímu potvrzování onchain
      transakcí bez hrozby [pinningu][topic transaction pinning] nebo
      nutnosti přeplácet během navyšování poplatků pomocí [CPFP][topic cpfp]
      a [RBF][topic rbf]. Doporučujeme čtenářům zajímajícím se o pravidla
      přeposílání transakcí, která mají dopad na všechny protokoly druhé
      vrstvy, aby si přečetli poznámky obsahující zajímavé informace
      poskytnuté vývojáři LN.

    - *Taproot a MuSig2 kanály:* krátká diskuze o vývoji kanálů založených
      na [P2TR][topic taproot] výstupech a [MuSig2][topic musig] pro
      elektronické podpisy. Významná část poznámek se týká zjednodušeného
      protokolu kooperativního zavření kanálu, kterému jsme se věnovali
      v předchozím bodě.

    - *Aktualizovaná oznámení o kanálech:* gossip protokol LN v současnosti
      přeposílá oznámení o nových nebo aktualizovaných kanálech jen, pokud
      jsou tyto kanály financovány P2WSH výstupem se skriptem 2-ze-2 `OP_CHECKMULTISIG`.
      Abychom mohli začít používat [P2TR][topic taproot]
      výstupy a [multisig][topic multisignature] commitmenty založené na
      [MuSig2][topic musig], musí být tento gossip protokol aktualizován.
      Jedním z diskutovaných [témat][topic channel announcements] během
      předchozího setkání LN vývojářů (viz [zpravodaj č. 204][news204 gossip])
      bylo, zda bychom měli učinit minimální aktualizaci protokolu (nazývanou
      gossip v1.5), která by pouze přidala P2TR výstupy, či širší aktualizaci
      protokolu (gossip v2.0), která by umožnila používat UTXO všech druhů.
      Pokud by mohl být použit jakýkoliv výstup, znamenalo by to, že výstup
      použitý pro oznámení kanálu nemusí být výstup, který je skutečně
      používán pro provoz kanálu. Tato vlastnost by porušila veřejnou vazbu
      mezi výstupy a financováním kanálů.

      Další diskutovanou myšlenkou bylo, zda by mělo být UTXO s hodnotou _n_
      umožněno oznamovat kanál s kapacitou větší než _n_. Díky tomu
      by mohli účastníci kanálu ponechat některé z otevíracích transakcí
      skryté. Například pokud by Alice a Bob spolu otevřeli dva kanály, mohli
      by použít jeden kanál k vytvoření oznámení s hodnotou vyšší než je hodnota
      tohoto kanálu. Tím by dali najevo, že mohou přeposílat platby vyšší, než
      kolik činí hodnota kanálu; k tomu by využívali druhého, skrytého kanálu.
      Díky tomu by mohli zvýšit pravděpodobnost, že kterýkoliv
      výstup v síti, včetně nikdy neoznámených, by mohl být používán pro
      LN kanál.

      Poznámka také hovoří o kompromisním rozhodnutí (gossip v1.75),
      které by umožnilo používat jakýkoliv skript, ale bez navýšené
      hodnoty.

    - *PTLC a redundantní přeplatky:* dle poznámek bylo krátce diskutováno
      i přidání [PTLC][topic ptlc] do protokolu, hlavně v souvislosti se
      [signature adaptors][topic adaptor signatures]. Větší část obsahu
      poznámky byla věnována vylepšení, které by mělo dopad na obdobné
      součásti protokolu: možnost [redundantního přeplacení][topic
      redundant overpayments] faktury a následného vrácení většiny nebo
      celého přeplatku. Příklad: Alice chce zaplatit Bobovi 1 BTC.
      Nejprve pošle Bobovi 20 [plateb s více cestami][topic multipath payments],
      každou o hodnotě 0,1 BTC. Díky použití buď matematiky (techniky
      nazývané _boomerang_, viz [zpravodaj č. 86][news86 boomerang], *angl.*)
      nebo commitmentů s více vrstvami a jednoho kola komunikace navíc
      (tzv. _spear_) by byl Bob schopný nárokovat maximálně 10 těchto plateb.
      Každá další platba, která by dosáhla jeho uzlu, by byla odmítnuta. Výhodou tohoto
      přístupu je, že až 10 částečných plateb od Alice by mohlo selhat, aniž
      by byla zpožděna celá platba. Nevýhodou se jeví býti zvýšená
      složitost a, v případě spearu, pravděpodobně i nižší rychlost, než
      kterou lze dosáhnout v dnešním stavu. Účastníci diskutovali, zda
      by mohly být najednou učiněny změny potřebné pro PTLC i redundantní
      přeplatky.

    - *Návrhy na obranu před zahlcením kanálu:* podstatná část poznámek
      poskytla souhrn diskuze o návrzích na zabránění [útoků zahlcením
      kanálu][topic channel jamming attacks]. Diskuze začala tvrzením,
      že žádné jedno řešení (jako je reputace nebo poplatek předem)
      nemůže úspěšně adresovat problém, aniž by nepřineslo nepřijatelné
      vedlejší efekty. Systém reputace musí myslet na nové uzly bez
      historie a na přirozenou míru neúspěšných HTLC; těchto by mohl
      útočník zneužít a přinést určitou míru škody, i když menší než
      dnes. Poplatky předem musí být nastaveny dostatečně vysoko, aby
      odradily útočníky, ale ne příliš, aby také neodrazovaly poctivé
      uživatele a aby neposkytovaly uzlům podnět k úmyslnému selhání
      přeposílaných plateb. Namísto toho bylo navrženo, aby se používalo
      několik způsobů najednou, což by umožnilo vyhnout se nejhorším
      scénářům.

      Dále se poznámky soustředily na podrobnosti o testování schémat
      lokální reputace popsaných ve [zpravodaji č. 226][news226 jamming]
      (*angl.*) a přípravy na pozdější implementaci nízkých poplatků
      napřed. Zdá se, že účastníci vyjádřili podporu testování
      těchto návrhů.

    - *Jednodušší commitmenty:* účastníci diskutovali o protokolu zjednodušených
      commitmentů (viz [zpravodaj č. 120][news120 commitments], *angl.*),
      který definuje, která strana je zodpovědná za návrh příští změny
      commitment transakce (oproti současnému stavu, kdy může změnu provést
      kdykoliv kterákoliv strana). Pokud by byla zodpovědnost na jedné
      ze stran, odstranilo by to složitost v případech existence dvou
      návrhu odeslaných zhruba ve stejnou dobu (např. pokud by Alice
      i Bob chtěli ve stejný okamžik přidat [HTLC][topic htlc]). Obzvláště
      komplikovaný případ je, pokud jedna ze stran nechce akceptovat návrh
      druhé strany. Tato situace je v současném protokolu těžko řešitelná.
      Nevýhodou přístupu se zjednodušenými commitmenty je v některých případech
      navýšení latence, jelikož by jedna strana musela před změnou požádat
      druhou stranu o povolení. Poznámky nezmínily žádný jasný závěr
      diskuze.

    - *Proces specifikace:* účastníci diskutovali o několika myšlenkách na
      vylepšení procesu specifikace a jeho dokumentů, včetně současných
      BOLTů a BLIPů. Diskuze byla, zdá se, velice pestrá a nepřinesla
      žádné jasné závěry.

## Vybrané otázky a odpovědi z Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] je jedním z prvních míst, kde hledají
přispěvatelé Optechu odpovědi na své otázky a kde – najdou-li volnou chvíli –
pomáhají zvědavým či zmateným uživatelům. V této měsíční rubrice nabízíme
některé z otázek a odpovědí, které obdržely vysoký počet hlasů.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Jak můžu ručně (na papíře) spočítat ze soukromého klíče klíč veřejný?]({{bse}}118933)
  Andrew Poelstra nejprve poskytuje přehled manuálních ověřovacích technik,
  jako je [codex32][news239 codex32], a poté nabízí kroky k ruční derivaci
  veřejného klíče z klíče soukromého. Podle jeho odhadu by tento proces i s
  různými optimalizacemi trval nejméně 1 500 hodin.

- [Proč existuje 17 verzí nativního segwitu?]({{bse}}118974)
  Murch vysvětluje, že [segwit][topic segwit] definoval pro [verzi witnessu][bip141
  witness program] 17 hodnot (0–16), aby využil existující opkódy konstant
  `OP_0` … `OP_16`. Dále poznamenává, že další čísla by vyžadovala použití
  méně datově efektivnějších opkódů `OP_PUSHDATA`.

- [Vynucuje `0 OP_CSV`, aby utrácející transakce signalizovala nahraditelnost podle BIP125?]({{bse}}115586)
  Murch poukazuje na [diskuzi][rbf csv discussion] potvrzující, že jelikož
  [časový zámek][topic timelocks] `OP_CHECKSEQUENCEVERIFY` (CSV) i nahrazení poplatkem
  ([RBF][topic rbf]) jsou [vynucovány ]({{bse}}87376) použitím pole
  `nSequence`, musí transakce s výstupem s `0 OP_CSV` signalizovat nahraditelnost
  dle [BIP125][].

- [Jak ovlivňují návrhy tras hledání cesty?]({{bse}}118755)
  Christian Decker vysvětluje dva důvody, proč by příjemce v LN poskytl
  odesílateli návrhy tras. Jeden důvod je, pokud by příjemce používal
  [neoznámené kanály][topic unannounced channels]. Druhým důvodem je poskytnutí
  odesílateli seznamu kanálů, které mají dostatečný zůstatek pro dokončení
  platby. O této technice hovoří jako o „route boost.”

- [Co znamená, že zabezpečení 256bitových ECDSA, a tedy i bitcoinových klíčů je 128 bitů?]({{bse}}118928)
  Pieter Wuille objasňuje, že 256bitová ECDSA poskytuje pouze 128bitové
  zabezpečení kvůli algoritmům, které mohou derivovat soukromý klíč z
  veřejného klíče efektivněji než hrubou silou. Pokračuje vysvětlením
  rozdílu mezi zabezpečením jednotlivých klíčů a zabezpečením [seedu][topic bip32].

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [HWI 2.3.0][] je vydáním tohoto middleware umožňujícího softwarovým peněženkám
  komunikovat s podpisovými zařízeními. Přidává podporu pro osobně sestrojená
  zařízení Jade a binárku pro běh hlavního programu `hwi` na zařízeních Apple
  Silicon s MacOS 12.0+.

- [LDK 0.0.116][] je vydáním tého knihovny pro tvorbu LN software. Obsahuje
  podporu pro [anchor výstupy][topic anchor outputs] a [platby s více cestami][topic
  multipath payments] s [keysend][topic spontaneous payments].

## Významné změny v kódu a dokumentaci

*Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo] a
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [Bitcoin Core GUI #740][] aktualizuje dialog pro používání [PSBT][topic psbt].
  Nově označuje výstupy platící vlastní peněžence jako „vlastní adresa.”
  To usnadní porozumění importovaných PSBT obzvláště v situacích, ve kterých
  transakce vrací zbytek odesílateli.

{% include references.md %}
{% include linkers/issues.md v=2 issues="740,1096" %}
[russell closing]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-July/004013.html
[kc notes]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-July/004014.html
[news193 gossip]: /en/newsletters/2022/03/30/#continued-discussion-about-updated-ln-gossip-protocol
[news204 gossip]: /cs/newsletters/2022/06/15/#aktualizace-gossip-protokolu
[news86 boomerang]: /en/newsletters/2020/02/26/#boomerang-redundancy-improves-latency-and-throughput-in-payment-channel-networks
[news226 jamming]: /en/newsletters/2022/11/16/#paper-about-channel-jamming-attacks
[news120 commitments]: /en/newsletters/2020/10/21/#simplified-htlc-negotiation
[news239 codex32]: /cs/newsletters/2023/02/22/#navrh-bip-pro-kodovani-seedu-codex32
[bip141 witness program]: https://github.com/bitcoin/bips/blob/master/bip-0141.mediawiki#witness-program
[wiki script]: https://en.bitcoin.it/wiki/Script#Constants
[rbf csv discussion]: https://twitter.com/SomsenRuben/status/1683056160373391360
[hwi 2.3.0]: https://github.com/bitcoin-core/HWI/releases/tag/2.3.0
[ldk 0.0.116]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.0.116
