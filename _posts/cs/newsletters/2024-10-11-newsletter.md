---
title: 'Zpravodaj „Bitcoin Optech” č. 324'
permalink: /cs/newsletters/2024/10/11/
name: 2024-10-11-newsletter-cs
slug: 2024-10-11-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Zpravodaj tento týden oznamuje tři zranitelnosti postihující starší verze
Bitcoin Core, oznamuje jinou zranitelnost postihující starší verze btcd
a odkazuje na příspěvek v podobě průvodce seznamujícího s používáním
několika nových vlastností P2P sítě přidaných v Bitcoin Core 28.0. Též
nechybí naše pravidelné rubriky se souhrnem sezení Bitcoin Core PR Review
Clubu, oznámeními nových vydání a popisem významných změn v populárních
bitcoinových páteřních projektech.

## Novinky

- **Odhalení zranitelností postihující Bitcoin Core před 25.0:**
  Niklas Gögge zaslal do emailové skupiny Bitcoin-Dev [příspěvek][gogge
  corevuln] s odkazem na oznámení tří zranitelností postihující verze
  Bitcoin Core, které mají minimálně od dubna 2024 ukončenou podporu.

  - [CVE-2024-35202 vzdálený pád][cve-2024-35202 remote crash vulnerability]: útočník může zaslat zprávu s
    [kompaktním blokem][topic compact block relay] záměrně sestaveným
    tak, aby rekonstrukce bloku selhala. Nefungující rekonstrukce se
    někdy stávají i při čestném používání protokolu, po čemž následuje
    dotaz na kompletní blok.

    Avšak namísto odpovědi s plným blokem mohl útočník zaslat druhou
    zprávu s kompaktním blokem odpovídající stejné hlavičce bloku. Před
    Bitcoin Core 25.0 by to způsobilo pád uzlu, jelikož byl kód uzlu
    navržen tak, aby zabránil rekonstrukci stejného kompaktního bloku
    více než jednou během stejného sezení.

    Tato snadno zneužitelná zranitelnost mohla být použit ke způsobení
    pádu kteréhokoliv uzlu s Bitcoin Core, což mohlo v součinnosti s jinými
    útoky vést ke krádeži peněz. Například spadlý uzel by nebyl schopný
    upozornit připojený LN uzel, že se protistrana jeho kanálu pokusila
    o krádež prostředků.

    Zranitelnost byla objevena, [zodpovědně nahlášena][topic
    responsible disclosures] a [opravena][bitcoin core #26898] Niklasem Göggem
    ve vydání Bitcoin Core 25.0.

  - [DoS kvůli velkému inventáři][DoS from large inventory sets]: Bitcoin Core
    drží v paměti pro každé své spojení seznam transakcí, které mu pošle.
    Transakce jsou v seznamu seřazené dle svých jednotkových poplatků
    a vzájemných vztahů, aby bylo zaručeno, že nejlepší transakce se
    přeposílají rychle a aby nebylo jednoduché sestavit topologii sítě.

    Avšak během vysoké aktivity v květnu 2023 si několik uživatelů všimlo,
    že jejich uzly používaly nadměrné množství procesoru. Vývojář 0xB10C
    zjistil, že tento výpočetní výkon byl použit na řadící funkci. Vývojář
    Anthony Towns hledal hlouběji a [opravil][bitcoin core #27610] problém
    tím, že transakce jsou z fronty odstraňovány proměnlivou rychlostí,
    která se během vysoké aktivity zvyšuje. Oprava byla vydána ve verzi
    Bitcoin Core 25.0.

  - [Pomalá propagace bloků][Slow block propagation attack]: před Bitcoin Core 25.0
    mohl nevalidní blok od útočníka zabránit Bitcoin Core v pokračování
    zpracování validního bloku se stejnou hlavičkou získaného od čestných
    spojení. To obzvláště postihovalo rekonstrukci kompaktních bloků v situacích,
    kdy byly vyžádány dodatečné transakce: uzel přestal čekat na transakce,
    pokud obdržel od jiného spojení nevalidní blok. I když později transakce
    přijal, uzel je ignoroval.

    Poté, co Bitcoin Core odmítl nevalidní blok (a možná ukončil spojení,
    které mu jej poslalo), obnovil pokusy o obdržení bloku od jiných
    spojení. Několik útočících spojení mohlo tento cyklus držet po dlouhou
    dobu. Některá spojení, která záměrně neútočila, mohla toto chování
    vyvolat nezáměrně.

    Problém byl objeven poté, co několik vývojářů včetně Williama Casarina
    a ghost43 nahlásilo problémy se svými uzly. Několik dalších vývojářů
    problém vyšetřovalo a Suhas Daftuar zranitelnost izoloval. Daftuar ji
    dále [opravil][bitcoin core #27608] tím, že zabránil spojení, aby
    ovlivňovalo stav stahování jiných spojení (kromě případů, kdy blok
    byl úspěšně validován a uložen na disk). Oprava byla součástí vydání
    Bitcoin Core 25.0.

- **CVE-2024-38365 selhání konsenzu v btcd:** jak bylo oznámeno [minulý týden][news323
  btcd], [odhalili][pg btcd] Antoine Poinsot a Niklas Gögge zranitelnost
  v plných uzlech btcd způsobující selhání konsenzu. V zastaralých bitcoinových
  transakcích jsou podpisy uloženy ve skriptovém poli s podpisem. Avšak podpisy
  též zavazují k tomuto poli s podpisem. To však není možné, podpis nemůže podepsat
  sám sebe, proto podepisující strana podepíše všechna data v poli kromě
  samotného podpisu. Ověřující strana musí stejným způsobem odstranit podpis
  před samotným ověřením.

  Funkce `FindAndDelete` v Bitcoin Core, která podpis odstraňuje, odstraňuje
  ze skriptu jen samotný podpis. Btcd implementuje funkci `removeOpcodeByData`,
  která odstraňovala _jakákoliv_ data v poli skriptu, které podpis obsahovalo.
  Toho bylo možné zneužít k odstranění více dat ze skriptu, než kolik odstraňuje
  Bitcoin Core. Jeden program tedy považoval podpis za validní, druhý nikoliv.
  Jakákoliv transakce obsahující nevalidní podpis a jakýkoliv blok obsahující
  nevalidní transakci jsou nevalidní. Konsenzus mezi Bitcoin Core a btcd byl
  tak narušen. Uzly, které se dostanou mimo konsenzus, mohou být klamem donuceny
  k přijetí nevalidních transakcí a nemusí vidět poslední transakce, které
  zbytek sítě považuje za validní. Každý z těchto problémů může vést ke ztrátě
  peněz.

  Zodpovědné nahlášení Poinsota a Göggeho umožnilo vývojářům btcd v tichosti
  zranitelnost opravit a před třemi měsíci vydat opravnou verzi 0.24.2.

- **Průvodce pro peněženky využívající pravidla Bitcoin Core 28.0:** Jak bylo
  zmíněno [minulý týden][news323 bcc28], obsahuje nové vydání verze Bitcoin Core
  28.0 několik nových vlastností P2P sítě, včetně [přeposílání balíčků][topic
  package relay] s jedním rodičem a jedním potomkem (1P1C), přeposílání transakcí
  do potvrzení topologicky omezených ([TRUC][topic v3 transaction relay]),
  [RBF nahrazování balíčků][topic rbf], [vylučování sourozenců][topic kindred rbf]
  a nový standardní druh výstupového skriptu pay-to-anchor ([P2A][topic ephemeral
  anchors]). Tyto novinky mohou výrazně zvýšit bezpečnost a spolehlivost
  v několika běžných případech užití.

  Gregory Sanders napsal pro Optech [průvodce][sanders guide] zaměřeného na
  vývojáře peněženek i jiného software, který používá Bitcoin Core pro vytváření
  a zveřejňování transakcí. Průvodce seznamuje s používáním těchto nových
  vlastností a popisuje, jak mohou být užitečné pro některé protokoly:
  běžné platby s RBF navyšováním poplatků, LN commitmenty a [HTLC][topic htlc],
  [Ark][topic ark] a [LN splicing][topic splicing].

## Bitcoin Core PR Review Club

*V této měsíční rubrice shrnujeme nedávné sezení [Bitcoin Core PR Review Club][] a
vyzdvihujeme některé z důležitých otázek a odpovědí. Klikněte na otázku a odpověď se vám odhalí.*

[Přidej getorphantxs][review club 30793] je PR od [tdb3][gh tdb3], které
přidává nový experimentální RPC příkaz nazvaný `getorphantxs`. Jelikož
je v první řadě mířen na vývojáře, je příkaz skrytý. Příkaz poskytuje
volajícímu seznam všech aktuálních osiřelých transakcí. Ten může být užitečný
během ověřování chování sirotků (např. ve funkčních testech jako
`p2p_orphan_handling.py`) nebo pro poskytování dodatečných dat pro
statistiky a vizualizace.

{% include functions/details-list.md
  q0="Co je osiřelá transakce? V jakém místě je transakce vložena do sirotčince?"
  a0="Osiřela transakce je taková, jejíž vstupy odkazují na neznámé
  nebo chybějící rodičovské transakce. Transakce jsou do sirotčince
  vloženy, když jsou přijaty od spojení, ale neprojdou v `ProcessMessage`
  validací kvůli `TX_MISSING_INPUTS`."
  a0link="https://bitcoincore.reviews/30793#l-16"

  q1="Kterým příkazem můžete získat seznam dostupných RPC příkazů?"
  a1="`bitcoin-cli help` poskytuje seznam dostupných RPC. Poznámka:
  jelikož `getorphantxs` je [označen jako skrytý][gh getorphantxs hidden]
  (pro RPC přístupné pouze vývojářům), v tomto seznamu se neobjeví."
  a1link="https://bitcoincore.reviews/30793#l-26"

  q2="Musí se něco zvláštního provést, má-li RPC neřetězcový argument?"
  a2="Neřetězcové RPC argumenty musí být přidány do seznamu `vRPCConvertParams`
  v `src/rpc/client.cpp`, aby byla zajištěna správná konverze typu."
  a2link="https://bitcoincore.reviews/30793#l-72"

  q3="Jaká je maximální velikost výsledku volání tohoto RPC? Existuje omezení
  počtu držených sirotků? Existuje limit doby, po kterou jsou sirotci v sirotčinci
  drženi?"
  a3="Maximální počet sirotků je 100 (`DEFAULT_MAX_ORPHAN_TRANSACTIONS`).
  S `verbosity=0` je každé txid 32bajtová binární hodnota, ale v hex-kódování
  v JSON-RPC výsledku se stává 64znakovým řetězcem (kažý bajt je reprezentován
  dvěma znaky). Maximální velikost výsledku je tedy zhruba 6,4 kB
  (100 txid × 64 bajtů).<br><br>
  S `verbosity=2` je zdaleka největším polem transakce v hex-kódování, pro
  zjednodušení tedy ignorujme ostatní pole. Maximální velikost serializované
  transakce může být až 400 kB (v extrémním nemožném scénáři, kdy obsahuje
  pouze witnessová data) neboli 800 kB v hex-kódování. Proto je maximální
  velikost výsledku zhruba 80 MB (100 transakcí × 800 kB).<br><br>
  Sirotci mají časové omezení, jsou odstranění po 20 minutách
  (`ORPHAN_TX_EXPIRE_TIME`)."
  a3link="https://bitcoincore.reviews/30793#l-94"

  q4="Odkdy existuje maximální velikost sirotčince?"
  a4="Konstanta `MAX_ORPHAN_TRANSACTIONS` byla přidána již v roce 2012
  v commitu [142e604][gh commit 142e604]."
  a4link="https://bitcoincore.reviews/30793#l-105"

  q5="Můžeme pomocí RPC volání `getorphantxs` zjistit, jak dlouho je transakce
  v sirotčinci? Pokud ano, jak?"
  a5="Ano, s parametrem `verbosity=1` můžeme zjistit čas expirace každé osiřelé
  transakce. Odečtením `ORPHAN_TX_EXPIRE_TIME` (tedy 20 minut) zjistíme
  čas vložení."
  a5link="https://bitcoincore.reviews/30793#l-128"

  q6="Můžeme pomocí RPC volání `getorphantxs` zjistit, jaké vstupy osiřelá transakce
  má? Pokud ano, jak?"
  a6="Ano, s parametrem `verbosity=2` volání vrátí hex-kódovanou serializovanou
  transakci, kterou můžeme dekódovat voláním `decoderawtransaction` a zjistit její
  vstupy."
  a6link="https://bitcoincore.reviews/30793#l-140"
%}

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [BDK 1.0.0-beta.5][] je kandidátem na vydání této knihovny pro budování
  peněženek a jiných aplikací s podporou bitcoinu. Tento kandidát „aktivuje
  ve výchozím nastavení RBF a klient bdk_esplora se bude po selhání opakovaně
  zkoušet znovu připojit. Balíček `bdk_electrum` také nově nabízí konfigurační
  příznak `use-openssl`.”

## Významné změny kódu a dokumentace

_Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Bitcoin Inquisition][bitcoin inquisition repo] a [repozitáři BINANA][binana
repo]._

- [Core Lightning #7494][] přináší do `channel_hints` dvouhodinovou dobu trvání.
  Díky tomu budou moci být informace pro hledání cest získané z platby znovu
  použité v budoucích pokusech. Kanály, které byly považované za nedostupné,
  budou postupně obnovené a zcela dostupné budou po dvou hodinách. Cesty, které
  se mezitím obnovily, tak již nebudou kvůli zastaralým informacím přeskakovány.

- [Core Lightning #7539][] přidává RPC příkaz `getemergencyrecoverdata`, který
  načte a vrátí data ze souboru `emergency.recover`. Vývojáři tak budou moci pomocí
  API přidat do svých aplikací funkcionalitu zálohování peněženky.

- [LDK #3179][] přidává [onion zprávy][topic onion messages] `DNSSECQuery` a `DNSSECProof`
  a `DNSResolverMessageHandler` pro jejich zpracování jako základ pro implementaci
  [BLIP32][]. Dále byl přidán `OMNameResolver`, který ověří DNSSEC záznamy a převede
  je na [nabídky][topic offers]. Viz též [zpravodaj č. 306][news306 blip32].

- [LND #8960][] implementuje funkcionalitu uživatelských kanálů přidáním taprootové
  vrstvy jako nového experimentálního typu kanálu. Ten je identický s [jednoduchými
  taprootovými kanály][topic simple taproot channels], avšak zavazuje k dodatečným
  metadatům v listech [tapscriptu][topic tapscript]. Aktualizované byly hlavní
  konečný automat kanálu a databáze, aby uživatelské tapscriptové listy mohly
  být zpracovány a uloženy. Volba nastavení `TaprootOverlayChans`musí být pro podporu
  tohoto typu kanálu aktivována. Uživatelské kanály zlepšují podporu pro
  [taproot assets][topic client-side validation]. Viz též [zpravodaj č. 322][news322
  customchans].

- [Libsecp256k1 #1479][] přidává modul [MuSig2][topic musig] obsahující multisig
  schéma kompatibilní s [BIP340][] dle specifikace v [BIP327][]. Modul je téměř
  identický s implementací v [secp256k1-zkp][zkpmusig2] s některými drobnými změnami
  jako např. odstranění podpory pro [adaptor signatures][topic adaptor signatures]
  (aby modul nemusel být označen za experimentální).

- [Rust Bitcoin #2945][] přináší podporu pro [testnet4][topic testnet]. Přidává
  výčtový typ `TestNetVersion` a refaktoruje kód potřebný pro přidání nové testovací
  sítě.

- [BIPs #1674][] revokuje změny specifikace [BIP85][] popsané ve [zpravodaji č.
  323][news323 bip85]. Změny narušily kompatibilitu s nasazenými implementacemi
  protokolu. Diskutující pod PR vyjádřili podporu pro nový BIP v případě významných
  změn.

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="7494,7539,3179,8960,1479,2945,1674,26898,27610,27608" %}
[BDK 1.0.0-beta.5]: https://github.com/bitcoindevkit/bdk/releases/tag/v1.0.0-beta.5
[news323 bip85]: /cs/newsletters/2024/10/04/#bips-1600
[review club 30793]: https://bitcoincore.reviews/30793
[gh tdb3]: https://github.com/tdb3
[gh getorphantxs hidden]: https://github.com/bitcoin/bitcoin/blob/a9f6a57b6918b2f92c7d6662e8f5892bf57cc127/src/rpc/mempool.cpp#L1131
[gh commit 142e604]: https://github.com/bitcoin/bitcoin/commit/142e604184e3ab6dcbe02cebcbe08e5623182b81
[news306 blip32]: /cs/newsletters/2024/06/07/#blips-32
[news322 customchans]: /cs/newsletters/2024/09/27/#lnd-9095
[zkpmusig2]: https://github.com/BlockstreamResearch/secp256k1-zkp
[sanders guide]: /cs/bitcoin-core-28-wallet-integration-guide/
[gogge corevuln]: https://mailing-list.bitcoindevs.xyz/bitcoindev/2df30c0a-3911-46ed-b8fc-d87528c68465n@googlegroups.com/
[cve-2024-35202 remote crash vulnerability]: https://bitcoincore.org/en/2024/10/08/disclose-blocktxn-crash/
[dos from large inventory sets]: https://bitcoincore.org/en/2024/10/08/disclose-large-inv-to-send/
[slow block propagation attack]: https://bitcoincore.org/en/2024/10/08/disclose-mutated-blocks-hindering-propagation/
[news323 btcd]: /cs/newsletters/2024/10/04/#nadchazejici-odhaleni-bezpecnostni-zranitelnosti-btcd
[pg btcd]: https://delvingbitcoin.org/t/cve-2024-38365-public-disclosure-btcd-findanddelete-bug/1184
[news323 bcc28]: /cs/newsletters/2024/10/04/#bitcoin-core-28-0
[bitcoin inquisition 28.0]: https://github.com/bitcoin-inquisition/bitcoin/releases/tag/v28.0-inq
