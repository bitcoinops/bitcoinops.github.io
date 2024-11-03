---
title: 'Zpravodaj „Bitcoin Optech” č. 325'
permalink: /cs/newsletters/2024/10/18/
name: 2024-10-18-newsletter-cs
slug: 2024-10-18-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Zpravodaj tento týden nahlíží na některá témata diskutovaná
během nedávného setkání vývojářů LN. Též nechybí naše pravidelné
rubriky s popisem změn v oblíbených klientech a službách,
oznámeními nových vydání a souhrnem významných změn v populárním
bitcoinovém páteřním software.

## Novinky

- **Poznámky z LN summitu 2024:** Olaoluwa Osuntokun zaslal do fóra Delving
  Bitcoin [příspěvek][osuntokun summary] se souhrnem svých [poznámek][osuntokun
  notes] (a dodatečným komentářem) z nedávné konference vývojářů LN. Mezi
  diskutovaná témata patřilo:

  - **Commitment transakce verze 3:** vývojáři diskutovali, jak používat
    [nové možnosti v P2P][bcc28 guide] včetně [TRUC][topic v3 transaction relay]
    transakcí a [P2A][topic ephemeral anchors] výstupů pro navýšení bezpečnosti
    LN commitment transakcí, které mohou být použity pro jednostranné
    uzavření kanálu. Diskuze se soustředila na rozličné kompromisy během
    navrhování.

  - **PTLC:** jsou dlouho navrhované jako způsob pro navýšení soukromí
    v LN i pro další možné účely jako například [stuckless
    transactions][topic redundant overpayments]. Byl diskutován nedávný
    průzkum kompromisů ohledně možných implementací [PTLC][topic ptlc]
    (viz [zpravodaj č. 268][news268 ptlc]). Zvláštní důraz byl kladen
    na konstrukci [signature adaptorů][topic adaptor signatures] (např.
    pomocí skriptového multisigu v kontrastu s bezskriptovým [MuSig2][topic
    musig]) a jejich dopadu na protokol commitmentů (viz další bod).

  - **Protokol aktualizování stavu:** byl diskutován návrh na změnu současného
    protokolu aktualizace stavu kanálů. Nyní je možné, aby kterákoliv strana
    navrhla aktualizaci stavu; nově by to měla být v danou chvíli jen jedna
    strana (viz též zpravodaje [č. 120][news120 simcom], _angl._, a
    [č. 261][news261 simcom]). Je-li oběma stranám umožněno navrhnout
    aktualizaci, můžou návrh podat obě strany najednou. Takové situace
    by byly náročné na řešení a mohly by vést k nezamýšlenému zavření kanálu.
    Alternativou je, aby v daný okamžik mohla navrhnout aktualizaci jen jedna
    ze stran. Např. zprvu je pouze Alici umožněno navrhnout aktualizaci
    stavu. Pokud žádný návrh nepodá, může připustit k navrhování Boba.
    Když Bob ukončí své návrhy, může předat kontrolu zpět Alici. Takový protokol
    je snadnější na uchopení, odstraňuje problémy vzniklé souběžnými
    návrhy a usnadňuje protistraně nechtěné návrhy odmítnout. Podobný protokol
    by byl navíc lépe v souladu se signature adaptory založenými na MuSig2.

  - **SuperScalar:** vývojář návrhu jednoho konstruktu [továren kanálů][topic
    channel factories] přednesl svůj návrh a obdržel zpětnou vazbu. Optech
    v budoucím čísle představí [SuperScalar][zmnscpxj superscalar] podrobněji.

  - **Upgrade gossip protokolu:** vývojáři diskutovali aktualizace [gossip
    protokolu pro LN][topic channel announcements]. Převážně jsou potřebné
    pro podporu nových typů zakládajících transakcí (např. [jednoduché taprootové
    kanály][topic simple taproot channels]), ale mohou být užitečné též
    pro přidání jiných schopností. Jedna z nich, o které se také diskutovalo,
    bylo přidání SPV dokladu (nebo jeho závazku) do zpráv oznamujících kanály.
    Díky tomu by mohly lehké klienty ověřit, že byla financující (nebo
    sponzorující) transakce začleněna do nějakého bloku.

  - **Výzkum fundamentálních limitů:** byl představen výzkum o
    platebních tocích, které kvůli limitům v síti (např. kanály s nedostatečnou
    kapacitou) nemohou skončit úspěšně (viz též [zpravodaj č. 309][news309
    feasible]). V případě nerealizovatelné LN platby mohou účastníci vždy
    přistoupit k onchain platbě. Avšak počet onchain plateb je omezen
    maximální vahou bloku, je tedy možné vypočítat maximální propustnost
    (počet plateb za sekundu) bitcoinu a LN dohromady vydělením maximálního
    počtu onchain plateb počtem neproveditelných LN plateb. Z tohoto
    hrubého vztahu vychází, že pro dosažení maximální propustnosti kolem
    47 000 plateb za sekundu musí být poměr neproveditelnosti pod 0,29 %.
    Byly diskutovány dvě techniky redukce poměru neproveditelnosti:
    za prvé virtuální či skutečné kanály s více než dvěma účastníky,
    neboť více stran znamená více prostředků pro přeposílání a tedy vyšší
    míru proveditelnosti. Za druhé kanály s kreditem, kde důvěryhodné strany
    mohou mezi sebou přeposílat platby, aniž by je mohly vynutit onchain
    (ostatní jim stále důvěřovat nemusí).

  Osuntokun vyzval ostatní účastníky o korekce a rozšíření.

## Změny ve službách a klientech

*V této měsíční rubrice upozorňujeme na zajímavé aktualizace bitcoinových
peněženek a služeb.*

- **Coinbase podporuje posílání na taproot:**
  Směnárna Coinbase [nově podporuje][coinbase post] výběry na taprootové
  [bech32m][topic bech32] adresy.

- **Vydána peněženka Dana:**
  [Peněženka Dana][dana wallet github] je peněženkou pro [tiché platby][topic silent payments],
  která se zaměřuje na darování. Vývojáři doporučují používat na [signetu][topic signet]
  a též provozují signetový [faucet][dana wallet faucet].

- **Vydán lehký klient pro BIP157/158 Kyoto:**
  [Kyoto][kyoto github] je rustový lehký klient pro vývojáře peněženek používající
  [kompaktní filtry bloků][topic compact block filters].

- **DLC Markets spuštěn na mainnetu:**
  Tato platforma založená na [DLC][topic dlc] [oznámila][dlc markets blog] mainnetovou
  dostupnost svých nekustodiálních služeb pro obchodování.

- **Ohlášena peněženka Ashigaru:**
  Ashigaru je forkem projektu Samourai Wallet, [oznámení][ashigaru blog] zmiňuje vylepšení
  [dávkového posílání][scaling payment batching], podpory [RBF][topic rbf] a [odhadu
  poplatků][topic fee estimation].

- **Ohlášen protokol DATUM:**
  [Těžební protokol DATUM][datum docs] umožňuje těžařům sestavovat kandidáty bloků jako
  součást [sdílené těžby][topic pooled mining], vykazuje podobnosti s protokolem Stratum v2.

- **Ohlášena implementace Arku Bark:**
  Tým Second [ohlásil][bark blog] [Bark][bark codeberg], implementaci protokolu [Ark][topic ark],
  a [ukázal][bark demo] živé arkové transakce na mainnetu.

- **Vydány Phoenix v2.4.0 a phoenixd v0.4.0:**
  Vydání [Phoenix v2.4.0][phoenix v2.4.0] a [phoenixd v0.4.0][] přidávají podporu
  pro financování za běhu dle návrhu [BLIP36][blip36] a další možnosti pro práci
  s likviditou (viz [podcast č. 323][pod323 eclair]).

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

- [Bitcoin Core #30955][] přidává do rozhraní `Mining` (viz [zpravodaj č. 310][news310
  mining]) dvě nové metody vyžadované pro podporu [Stratum V2][topic pooled mining].
  Metoda `submitSolution()` umožňuje těžařům odeslat řešení bloku efektivněji:
  namísto celého bloku se odesílají pouze nonce, časové razítko, pole s verzemi
  a coinbasová transakce. Druhou metodou je `getCoinbaseMerklePath()`, která
  vrátí cestu Merkleovým stromem požadovanou zprávou `NewTemplate`. PR dále
  do kódu vrací `BlockMerkleBranch` odstraněnou v [Bitcoin Core #13191][].

- [Eclair #2927][] přidává vynucování doporučených jednotkových poplatků (viz
  [zpravodaj č. 323][news323 fees]) při financování za běhu (viz [zpravodaj č.
  323][news323 fly]) tím, že bude odmítat zprávy `open_channel2` a `splice_init`,
  pokud používají jednotkový poplatek nižší.

- [Eclair #2922][] odstraňuje podporu pro [splicing][topic splicing] bez předem
  iniciované chvíle ticha (quiescence, viz [zpravodaj č. 309][news309 quiescence]).
  Bude tak odpovídat poslední verzi protokolu z [BOLTs #1160][], která po každém
  uzlu požaduje během splicingu používat chvíli ticha.

- [LDK #3235][] přidává do události `ChannelForceClosed` pole `last_local_balance_msats`,
  které obsahuje místní zůstatek uzlu těsně před vynuceným zavřením kanálu.
  Uživatel tak bude moci zjistit ztrátu milisatoshi způsobenou zaokrouhlováním.

- [LND #8183][] přidává do struktury `chanbackup.Single` volitelné pole `CloseTxInputs`,
  které umožní přidat do souboru se [statickou zálohou kanálu][topic static channel
  backups] vstupy potřebné pro vygenerování transakce vynuceného zavření. Díky tomu
  budou moci uživatelé manuálně obdržet od offline spojení prostředky pomocí
  příkazu `chantools scbforceclose` jako poslední možnost. Uživatelé by měli
  být obzvláště opatrní, neboť by tato akce mohla vést ke ztrátě prostředků
  v případě, pokud od poslední zálohy nastala změna. PR dále přidává metodu
  `ManualUpdate`, která aktualizuje zálohu kanálů během ukončování LND.

- [Rust Bitcoin #3450][] přidává v3 jako novou variantu verze transakce. Bitcoin
  Core nově považuje tyto transakce, označované též jako transakce [do potvrzení
  topologicky omezené][topic v3 transaction relay] (TRUC), za standardní.
  Viz též [zpravodaj č. 307][news307 truc].

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="30955,2927,2922,3235,8183,3450,13191,1160" %}
[BDK 1.0.0-beta.5]: https://github.com/bitcoindevkit/bdk/releases/tag/v1.0.0-beta.5
[osuntokun summary]: https://delvingbitcoin.org/t/ln-summit-2024-notes-summary-commentary/1198
[osuntokun notes]: https://docs.google.com/document/d/1erQfnZjjfRBSSwo_QWiKiCZP5UQ-MR53ZWs4zIAVcqs/edit?tab=t.0#heading=h.chk08ds793ll
[news268 ptlc]: /cs/newsletters/2023/09/13/#zmeny-v-ln-urcene-pro-ptlc
[news120 simcom]: /en/newsletters/2020/10/21/#simplified-htlc-negotiation
[news261 simcom]: /cs/newsletters/2023/07/26/#jednodussi-commitmenty
[zmnscpxj superscalar]: https://delvingbitcoin.org/t/superscalar-laddered-timeout-tree-structured-decker-wattenhofer-factories/1143
[news309 feasible]: /cs/newsletters/2024/06/28/#odhad-pravdepodobnosti-uspesneho-provedeni-ln-platby
[bcc28 guide]: /cs/bitcoin-core-28-wallet-integration-guide/
[coinbase post]: https://x.com/CoinbaseAssets/status/1843712761391399318
[dana wallet github]: https://github.com/cygnet3/danawallet
[dana wallet faucet]: https://silentpayments.dev/
[saving satoshi editor]: https://script.savingsatoshi.com/
[kyoto github]: https://github.com/rustaceanrob/kyoto
[dlc markets blog]: https://blog.dlcmarkets.com/dlc-markets-reshaping-bitcoin-trading/
[ashigaru blog]: https://ashigaru.rs/news/release-wallet-v1-0-0/
[datum docs]: https://ocean.xyz/docs/datum
[bark blog]: https://blog.second.tech/ark-on-bitcoin-is-here/
[bark codeberg]: https://codeberg.org/ark-bitcoin/bark
[bark demo]: https://blog.second.tech/demoing-the-first-ark-transactions-on-bitcoin-mainnet/
[phoenix v2.4.0]: https://github.com/ACINQ/phoenix/releases/tag/android-v2.4.0
[phoenixd v0.4.0]: https://github.com/ACINQ/phoenixd/releases/tag/v0.4.0
[blip36]: https://github.com/lightning/blips/pull/36
[pod323 eclair]: /en/podcast/2024/10/08/#eclair-2848-transcript
[news310 mining]:/cs/newsletters/2024/07/05/#bitcoin-core-30200
[news323 fees]: /cs/newsletters/2024/10/04/#eclair-2860
[news323 fly]: /cs/newsletters/2024/10/04/#eclair-2861
[news309 quiescence]:/cs/newsletters/2024/06/28/#bolts-869
[news307 truc]: /cs/newsletters/2024/06/14/#bitcoin-core-29496
