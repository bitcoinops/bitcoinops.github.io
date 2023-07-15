---
title: 'Zpravodaj „Bitcoin Optech” č. 259'
permalink: /cs/newsletters/2023/07/12/
name: 2023-07-12-newsletter-cs
slug: 2023-07-12-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Tento týden popisujeme návrh na odstranění některých drobností ze specifikace LN,
které již nejsou relevantní, a přinášíme předposlední část naší krátké týdenní
série o pravidlech mempoolu. Též nechybí naše pravidelné rubriky se souhrnem
sezení Bitcoin Core PR Review Club, oznámeními o nových vydáních a kandidátech
na vydání a popisem významných změn v populárních bitcoinových páteřních
projektech.

## Novinky

- **Návrh na pročištění specifikace LN:** Rusty Russell zaslal do emailové
  skupiny Lightning-Dev [příspěvek][russell clean up] s odkazem na
  [PR][bolts #1092], ve kterém navrhuje odstranit některé funkce, které již
  nejsou podporovány v moderních implementacích LN, a ponechané funkce
  označit jako navždy podporované. Russell dále poskytl výsledky svého výzkumu
  podporovaných funkcí veřejnými uzly dle jejich gossip zpráv. Výsledky
  naznačují, že téměř všechny uzly podporují následující funkce:

  - *Onion zprávy s proměnlivou velikostí:* součástí specifikace jsou od
    roku 2019 (viz [zpravodaj č. 58][news58 bolts619], *angl.*), tedy od doby,
    kdy byly také představeny Type-Length-Value (TLV) pole. Tím byl nahrazen
    původní formát šifrovaného onion routingu, který vyžadoval použití
    zpráv o pevné délce a omezoval počet skoků na 20. Díky formátu s proměnlivou
    velikostí je snazší přeposílat konkrétním skokům libovolná data. Jedinou
    nevýhodou je, že celková velikost zprávy zůstává konstantní, čili nárůst
    v objemu posílaných dat snižuje maximální počet skoků.

  - *Gossip dotazy:* součástí specifikace od roku 2018 (viz [BOLTs #392][]).
    Umožňují uzlu vyžádat od svých spojení pouze podmnožinu gossip zpráv
    poslaných jinými uzly v síti. Uzel může vyžádat například pouze nejnovější
    aktualizace a ignorovat starší, čímž ušetří na datovém přenosu a čase
    zpracování.

  - *Ochrana před ztrátou dat:* součástí specifikace od roku 2017 (viz
    [BOLTs #240][]). Uzly používající tuto funkci posílají před novým připojením
    informace o svém posledním stavu kanálu. Díky tomu může uzel detekovat,
    že přišel o data. Dále nabádá uzel, který o data nepřišel, aby kanál uzavřel
    ve svém posledním stavu. Viz [zpravodaj č. 31][news31 data loss] (*angl.*)
    pro další informace.

  - *Statické klíče vzdálené strany:* součástí specifikace od roku 2019
    (viz [zpravodaj č. 67][news67 bolts642], *angl.*), umožňují uzlu požadovat,
    aby každý channel update zavazoval k posílání ne[HTLC][topic htlc] prostředků
    na stejnou adresu. Předtím mohla být v každém channel update použita jiná
    adresa. Po této změně uzel, který používá tento protokol a ztratí
    data, nakonec téměř vždy obdrží alespoň část svých prostředků na zvolenou
    adresu, jako je například adresa v [HD peněžence][topic bip32].

  První odpovědi k návrhu na pročištění byly pozitivní.

## Čekání na potvrzení 9: návrhy pravidel

_Krátká týdenní [série][policy series] o přeposílání transakcí, začleňování do mempoolu a výběru
transakcí k těžbě včetně vysvětlení, proč má Bitcoin Core přísnější pravidla,
než co je povoleno konsenzem, a jak mohou peněženky využít pravidla co nejefektivněji._

{% include specials/policy/cs/09-proposals.md %}

## Bitcoin Core PR Review Club

*V této měsíční rubrice shrnujeme nedávné sezení [Bitcoin Core PR Review Club][] a
vyzdvihujeme některé z důležitých otázek a odpovědí. Klikněte na otázku a odpověď se vám odhalí.*

[Přestaň přeposílat transakce mimo mempool][review club 27625] je
PR od Marca Falkeho (MarcoFalke) zjednodušující klienta Bitcoin Core
odstraněním paměťové datové struktury `mapRelay`, která může způsobit vysokou
spotřebu paměti a není již více potřebná, respektive poskytuje pouze zcela
okrajové benefity. Tato mapa obsahuje transakce, které mohou či nemusí být
také v mempoolu. Někdy se používá pro generování odpovědi na požadavek
[`getdata`][wiki getdata].

{% include functions/details-list.md
  q0="Jaké důvody stojí za odstraněním `mapRelay`?"
  a0="Spotřeba paměti této datové struktury je neomezená.
      I když v běžném případě nespotřebovává tolik paměti, je na pováženou,
      je-li velikost jakékoliv datové struktury určena chováním vnějších
      entit (spojení) a nemá žádné maximum. Takové případy mohou vnést DoS
      zranitelnosti."
  a0link="https://bitcoincore.reviews/27625#l-19"

  q1="Proč je těžké určit spotřebu paměti `mapRelay`?"
  a1="Každý prvek v `mapRelay` je ukazatelem na transakci (`CTransaction`),
      který může být sdílen s mempoolem. Druhý ukazatel na stejný objekt
      používá velmi málo dodatečného prostoru v porovnání s jedním ukazatelem.
      Je-li sdílená transakce odstraněna z mempoolu, veškerý jeho použitý prostor lze
      připsat `mapRelay`. Čili spotřeba paměti `mapRelay` nezávisí pouze na počtu
      a velikosti transakcí, ale také na tom, kolik jeho transakcí již není
      v mempoolu. Toto není snadné dopředu určit."
  a1link="https://bitcoincore.reviews/27625#l-33"

  q2="Jaký problém řeší přidaný `m_most_recent_block_txs`?
      (Toto je seznam pouze těch transakcí, které jsou v posledním obdrženém bloku.)"
  a2="Jelikož `mapRelay` není již k dispozici, nemohli bychom bez něj posílat
      právě vytěžené transakce (z posledního bloku) spojením, která o něj požádají.
      Tyto transakce již nejsou v našem mempoolu."
  a2link="https://bitcoincore.reviews/27625#l-45"

  q3="Považujete za nezbytné přidávat `m_most_recent_block_txs`,
      či by bylo možné odstranit `mapRelay` bez náhrady?"
  a3="Mezi účastníky review klubu panovala u této otázky nejistota.
      Někdo navrhl, že by mohl `m_most_recent_block_txs` vylepšit rychlost
      propagace bloků, protože pokud naše spojení stále neobdrželo blok, který
      my jsme právě obdrželi, může schopnost našeho uzlu poskytnout své transakce
      pomoci zkompletovat našemu spojení [kompaktní blok][topic compact block relay].
      Jiný návrh byl, že může pomoci v případě chain splitu; pokud by naše spojení
      bylo na jiném chainu než my, možná obdrželo transakci jinak než z bloku."
  a3link="https://bitcoincore.reviews/27625#l-54"

  q4="Jaké jsou paměťové požadavky `m_most_recent_block_txs` v porovnání s
      `mapRelay`?"
  a4="Počet položek v `m_most_recent_block_txs` je ohraničen počtem transakcí
      v bloku. Avšak paměťové požadavky jsou ještě menší, neboť položky v
      `m_most_recent_block_txs` jsou sdílené ukazatele na transakce, na které
      již ukazuje `m_most_recent_block`."
  a4link="https://bitcoincore.reviews/27625#l-65"

  q5="Existují případy, ve kterých by v důsledku této změny byly transakce dostupné
      po kratší nebo delší dobu než předtím?"
  a5="Delší, pokud je doba od posledního bloku delší než 15 minut (což je čas, po
      který zůstávají položky uloženy v `mapRelay`), jinak kratší. To je
      přijatelné, neboť volba 15 minut byla spíše nahodilá. Avšak tato změna může
      snížit dostupnost transakcí v případě chain splitu hlubšího než jeden blok
      (ty jsou extrémně vzácné), protože neuchováváme transakce, které jsou obsaženy
      pouze v bloku, jež není v našem řetězci."
  a5link="https://bitcoincore.reviews/27625#l-70"
%}

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [LND v0.16.4-beta][] je údržbovým vydáním tohoto uzlu, které opravuje
  memory leak postihující některé uživatele.

## Významné změny v kódu a dokumentaci

*Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo] a
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [Bitcoin Core #27869][] zobrazuje během načítání zastaralé peněženky varování
  v rámci pokračující snahy popsané v [Bitcoin Core #20160][], jejímž cílem
  je pomoci uživatelům migrovat zastaralé peněženky na peněženky s
  [deskriptory][topic descriptors], jak bylo zmíněno ve zpravodajích [č. 125][news125
  descriptor wallets], [č. 172][news172 descriptor wallets] (oba *angl.*) a
  [č. 230][news230 descriptor wallets].

{% include references.md %}
{% include linkers/issues.md v=2 issues="1092,392,240,20160,27869" %}
[news58 bolts619]: /en/newsletters/2019/08/07/#bolts-619
[policy series]: /cs/blog/waiting-for-confirmation/
[news31 data loss]: /en/newsletters/2019/01/29/#fn:fn-data-loss-protect
[news67 bolts642]: /en/newsletters/2019/10/09/#bolts-642
[lnd v0.16.4-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.16.4-beta
[russell clean up]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-June/004001.html
[review club 27625]: https://bitcoincore.reviews/27625
[wiki getdata]: https://en.bitcoin.it/wiki/Protocol_documentation#getdata
[news125 descriptor wallets]: /en/newsletters/2020/11/25/#how-will-the-migration-tool-from-a-bitcoin-core-legacy-wallet-to-a-descriptor-wallet-work
[news172 descriptor wallets]: /en/newsletters/2021/10/27/#bitcoin-core-23002
[news230 descriptor wallets]: /cs/newsletters/2022/12/14/#bude-bitcoin-core-moci-podepisovat-zpravy-i-se-zastaralymi-penezenkami
