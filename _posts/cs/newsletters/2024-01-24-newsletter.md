---
title: 'Zpravodaj „Bitcoin Optech” č. 286'
permalink: /cs/newsletters/2024/01/24/
name: 2024-01-24-newsletter-cs
slug: 2024-01-24-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Tento týden přinášíme zveřejnění opraveného selhání konsenzu ve
starších verzích btcd, ohlášení nového repozitáře bitcoinových
specifikací a popis navrhovaných změn LN pro dočasné anchory
a přeposílání transakcí verze 3. Též nechybí naše pravidelné rubriky
s popisem aktualizací služeb a klientského software, oznámeními nových
vydání a souhrnem významných změn v populárním bitcoinovém páteřním software.

## Novinky

- **Zveřejnění opraveného selhání konsenzu v btcd:** Niklas Gögge
  [oznámil][gogge btcd] ve fóru Delving Bitcoin selhání konsenzu
  starších verzí btcd, které předtím [zodpovědně nahlásil][topic
  responsible disclosures]. Relativní [časové zámky][topic timelocks]
  byly do bitcoinu [přidány][topic soft fork activation] v soft forku
  přiřazením významu sekvenčním číslům vstupů a jeho vynucování konsenzem.
  Aby bylo zajištěno, že žádné podepsané transakce vytvořené před soft forkem
  nebudou považovány za neplatné, jsou relativní časové zámky aplikovány pouze
  na transakce verze 2 či vyšší. To umožňuje transakcím s původním číslem verze 1
  zachovat platnost s jakýmikoliv vstupy. Avšak v původním bitcoinovém
  programu jsou čísla verzí celými čísly se znaménkem, což znamená, že záporná
  čísla verzí jsou možná. Část _referenční implementace_ [BIPu 68][BIP68]
  poznamenává, že „verze 2 a vyšší” se týká čísla verze [přetypované][cast]
  z celého čísla se znaménkem na celé číslo bez znaménka, z čeho vyplývá,
  že se pravidla aplikují na jakoukoliv verzi, která není 0 či 1.

  Gögge zjistil, že btcd toto přetypování neimplementovalo. Bylo tedy možné
  zkonstruovat transakci se záporným číslem verze, dle které by Bitcoin Core
  musel následovat pravidla BIP68, ale btcd by nemuselo. V tom případě by
  jeden uzel transakci odmítl (a každý blok, který by ji obsahoval), zatímco
  jiný uzel by ji přijal (spolu s blokem). To by vedlo ke štěpení blockchainu.
  Útočník by toho mohl zneužít k oklamání provozovatele btcd uzlu (nebo
  software na něj připojeného) k přijetí nevalidních bitcoinů.

  Chyba bylo diskrétně nahlášena vývojářům btcd, kteří ji opravili ve vydání
  v0.24.0. Všichni, kteří používají btcd pro vynucování konsenzu by měli
  vážně zvážit upgrade. Dále Chris Stewart [zaslal][stewart bitcoin-s] do fóra
  patch s opravou stejné chyby obsažené v knihovně bitcoin-s. Autoři kódu,
  který by mohl být použit k validaci relativních časových zámků dle BIP68,
  jsou vyzýváni, aby svůj kód též ověřili.

- **Návrh změn LN pro přeposílání verze 3 a dočasné anchory:** Bastien
  Teinturier zaslal do fóra Delving Bitcoin [příspěvek][teinturier v3]
  s popisem změn specifikace Lightning Network, které by podle něj účinně
  využívaly [přeposílání transakcí verze 3][topic v3 transaction relay] a
  [dočasných anchorů][topic ephemeral anchors] („ephemeral anchors”). Změny
  se zdají býti jednoduché:

  - *Výměna anchorů*: commitment transakce mají v současnosti dva [anchor výstupy][topic
    anchor outputs], které díky pravidlu [CPFP carve out][topic cpfp carve out]
    garantují možnost [navýšit poplatek pomocí CPFP][topic cpfp]. Tyto dva
    anchor výstupy budou nahrazeny jedním dočasným anchorem.

  - *Snížení prodlevy*: aby bylo zajištěno, že pravidlo CPFP carve out bude vždy fungovat, je na
    commitment transakce aplikována jednobloková prodleva navíc. V rámci přeposílání
    verze 3 již není prodleva potřeba, může tedy být odstraněna.

  - *Přesměrování ořezaných HTLC*: V případě existence [ořezaných HTLC][topic trimmed htlc]
    („trimmed HTLCs”) se namísto utracení jejich celkové hodnoty na poplatcích za commitment
    transakci přidá jejich kombinovaná hodnota na anchor výstup. Díky tomu mohou
    být tyto poplatky navíc použity na zajištění potvrzení commitment transakce
    i dočasného anchoru ([minulé číslo zpravodaje][news285 mev] obsahuje podrobnosti).

  - *Další změny*: Několik dalších drobných změn a zjednodušení.

  Následná diskuze zkoumala několik zajímavých důsledků navržených změn včetně:

  - *Snížené požadavky na UTXO*: Díky odstranění jednoblokové prodlevy navíc je jednodušší zajistit, že
    bude publikován správný stav kanálu. Pokud pochybná strana zveřejní
    revokovanou commitment transakci, druhá strana může použít hlavní výstup
    své commitment transakce pro navýšení poplatku revokované commitment transakce
    pomocí CPFP. Nemusí tedy držet oddělené potvrzené UTXO pouze pro tento účel.
    Aby to bylo bezpečné, musí mít tato strana dodatečnou finanční rezervu,
    neboť 1% minimum doporučované [BOLT2][] nemusí být dostatečné. Uzly, které
    nepřeposílají platby a mají dostatečnou rezervu, potřebují z bezpečnostních
    důvodů jedno oddělené UTXO pouze, chtějí-li přijmout příchozí platbu.

  - *Vštípená v3 logika:* V reakci na obavy vyjádřené během setkání vývojářů specifikace
    LN, že design, implementace a nasazení těchto změn mohou trvat dlouho,
    [navrhuje][sanders transition] Gregory Sanders mezikrok,
    ve kterém by bylo zvláštním způsobem nakládáno s transakcemi, které vypadají
    jako LN commitment transakce se současným stylem anchorů. Bitcoin Core
    by tak mohl nasadit cluster mempool bez čekání na vývoj LN. Po dosažení dostatečně
    širokého nasazení a po dokončení upgradu LN implementací by mohlo být toto
    dočasné pravidlo odstraněno.

  - *Určení maximální velikosti potomka:* návrh v3 přeposílání nastavuje velikost
    nepotvrzeného potomka na 1 000 vbyte. Čím je velikost větší, tím více musí čestný
    uživatel platit na překonání [pinningu][topic transaction pinning] (viz
    [zpravodaj č. 283][news283 v3pin]). Nižší velikost omezuje čestného uživatele
    v možnostech výběru vstupu pro přispění na poplatky.

- **Nový repozitář dokumentace:** Anthony Towns zaslal do emailové skupiny
  Bitcoin-Dev [příspěvek][towns binana] oznamující nový repozitář specifikací
  protokolů _Bitcoin Inquisition Numbers And Names Authority_ ([BINANA][binana repo]).
  V době psaní obsahuje repozitář čtyři specifikace:

  - [BIN24-1][] `OP_CAT` od Ethana Heilmana a Armina Sabouriho. Viz popis jejich
    soft forku ve [zpravodaji č. 274][news274 cat].

  - [BIN24-2][] dědičné nasazování („heretical deployments”) od Anthonyho Townse
    popisující používání [Bitcoin Inquisition][bitcoin inquisition repo] pro
    návrhy soft forků a další změny na [signetu][topic signet]. Viz rozšířený popis ve
    [zpravodaji č. 232][news232 inqui].

  - [BIN24-3][] `OP_CHECKSIGFROMSTACK` od Brandona Blacka specifikující
    tuto [dlouho navrhnovanou myšlenku][topic OP_CHECKSIGFROMSTACK].
    [Minulé číslo zpravodaje][news285 lnhance] popisuje Blackův návrh na
    začlenění tohoto opkódu do soft forku LNHANCE.

  - [BIN24-4][] `OP_INTERNALKEY` do Brandona Blacka specifikující opkód,
    který umožní načíst taprootový interní klíč z interpretru skriptu.
    Také tento opkód byl popsán v minulém čísle v rámci LNHANCE.

  Bitcoin Optech přidal repozitář BINANA na seznam zdrojů, které monitorujeme.
  Mezi další zdroje patří BIPy, BOLTy a BLIPy. Budoucí aktualizace budou popsány
  v rubrice s _významnými změnami kódu a dokumentace_.

## Změny ve službách a klientech

*V této měsíční rubrice upozorňujeme na zajímavé aktualizace bitcoinových
peněženek a služeb.*

- **Vydán Envoy 1.5:**
  [Envoy 1.5][] přidává podporu [taprootového][topic taproot] posílání i přijímání
  a mění způsob, kterým nakládá s [neekonomickými výstupy][topic uneconomical outputs].
  Dále obsahuje opravy chyb [a další novinky][envoy blog].

- **Vydána Liana v4.0:**
  Byla [vydána][liana blog] [Liana v4.0][]. Obsahuje podporu pro [navyšování
  poplatků pomocí RBF][topic rbf], rušení transakcí pomocí RBF, automatický
  [výběr mincí][topic coin selection] a ověřování adres hardwarovými podpisovými
  zařízeními.

- **Ohlášen Mercury Layer:**
  [Mercury Layer][] je [implementací][mercury layer github] [statechainů][topic statechains],
  která používá [variaci][mercury blind musig] protokolu [MuSig2][topic musig] pro
  zaslepené podepisování provozovatelem statechainu.

- **Ohlášena peněženka AQUA:**
  [Peněženka AQUA][AQUA wallet] je [open source][aqua github] mobilní peněženkou, která podporuje
  bitcoin, Lightning Network a [sidechain][topic sidechains] Liquid.

- **Samourai Wallet ohlašuje atomické směny:**
  [Atomická směna napříč blockchainy][samourai gitlab swap] založená na předchozím
  [bádání][samourai gitlab comit] umožňuje peer-to-peer směny mezi bitcoinem a Monerem.

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [LDK 0.0.120][] je bezpečnostní vydání této knihovny pro budování aplikací
  s LN. „Opravuje DoS zranitelnost, kterou lze vyvolat nedůvěryhodným vstupem
  od spojení, je-li aktivována volba `UserConfig::manually_accept_inbound_channels`.”
  Vydání dále obsahuje drobná vylepšení a opravy několika dalších chyb.

- [HWI 2.4.0-rc1][] je kandidátem na vydání příští verze toho balíčku
  poskytujícího jednotné rozhraní k několika různým hardwarovým podpisovým
  zařízením.

## Významné změny kódu a dokumentace

*Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo] a
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [Bitcoin Core #29239][] umožňuje pomocí RPC volání `addnode` používat
  [přenosový protokol verze 2][topic v2 p2p transport], je-li aktivní volba
  `-v2transport`.

- [Eclair #2810][] umožňuje, aby informace [trampolínového routování][topic
   trampoline payments] zašifrované v onion zprávě používaly více než 400
   bytů. Maximální velikost je dle [BOLT4][] 1 000 bytů. Trampolínové
   routování vyžadující méně než 400 bytů je zarovnáno na 400 bytů.

- [LDK #2791][], [#2801][ldk #2801] a [#2812][ldk #2812] dokončují přidání
  podpory [zaslepených cest][topic rv routing] a počínají tuto schopnost
  oznamovat síti.

- [Rust Bitcoin #2230][] přidává funkci pro kalkulaci _efektivní hodnoty_ vstupu,
  což je jeho hodnota bez nákladů na utracení.

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 15:00" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="29239,2810,2791,2801,2812,2230" %}
[teinturier v3]: https://delvingbitcoin.org/t/lightning-transactions-with-v3-and-ephemeral-anchors/418/
[towns binana]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2024-January/022289.html
[sanders transition]: https://delvingbitcoin.org/t/lightning-transactions-with-v3-and-ephemeral-anchors/418/2
[news283 v3pin]: /cs/newsletters/2024/01/03/#naklady-na-pinning-v3-transakci
[news274 cat]: /cs/newsletters/2023/10/25/#navrh-bipu-pro-op-cat
[news232 inqui]: /cs/newsletters/2023/01/04/#bitcoin-inquisition
[news285 mev]: /cs/newsletters/2024/01/17/#diskuze-o-tezari-extrahovatelne-hodnote-v-nenulovych-docasnych-anchorech
[news285 lnhance]: /cs/newsletters/2024/01/17/#navrh-noveho-soft-forku-lnhance
[stewart bitcoin-s]: https://delvingbitcoin.org/t/disclosure-btcd-consensus-bugs-due-to-usage-of-signed-transaction-version/455/2
[gogge btcd]: https://delvingbitcoin.org/t/disclosure-btcd-consensus-bugs-due-to-usage-of-signed-transaction-version/455
[hwi 2.4.0-rc1]: https://github.com/bitcoin-core/HWI/releases/tag/2.4.0-rc.1
[ldk 0.0.120]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.0.120
[cast]: https://cs.wikipedia.org/wiki/P%C5%99etypov%C3%A1n%C3%AD#Explicitn%C3%AD_(vynucen%C3%A9)
[Envoy 1.5]: https://github.com/Foundation-Devices/envoy/releases/tag/v1.5.1
[envoy blog]: https://foundationdevices.com/2024/01/envoy-version-1-5-1-is-now-live/
[Liana v4.0]: https://github.com/wizardsardine/liana/releases/tag/v4.0
[liana blog]: https://www.wizardsardine.com/blog/liana-4.0-release/
[Mercury Layer]: https://mercurylayer.com/
[mercury blind musig]: https://github.com/commerceblock/mercurylayer/blob/dev/docs/blind_musig.md
[mercury layer github]: https://github.com/commerceblock/mercurylayer/tree/dev/docs
[AQUA Wallet]: https://aquawallet.io/
[aqua github]: https://github.com/AquaWallet/aqua-wallet
[samourai gitlab swap]: https://code.samourai.io/wallet/comit-swaps-java/-/blob/master/docs/SWAPS.md
[samourai gitlab comit]: https://code.samourai.io/wallet/comit-swaps-java/-/blob/master/docs/files/Atomic_Swaps_between_Bitcoin_and_Monero-COMIT.pdf
