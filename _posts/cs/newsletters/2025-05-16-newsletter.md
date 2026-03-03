---
title: 'Zpravodaj „Bitcoin Optech” č. 354'
permalink: /cs/newsletters/2025/05/16/
name: 2025-05-16-newsletter-cs
slug: 2025-05-16-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Zpravodaj tento týden popisuje opravenou zranitelnost postihující staré
verze Bitcoin Core. Též nechybí naše pravidelné rubriky se souhrnem
nedávných diskuzí o změnách konsenzu, oznámeními nových vydání a popisem
významných změn v populárním bitcoinovém páteřním software.

## Novinky

- **Odhalení zranitelnosti postihující staré verze Bitcoin Core:**
  Antoine Poinsot zaslal do emailové skupiny Bitcoin-Dev [příspěvek][poinsot
  addrvuln] s oznámením zranitelnosti postihující verze Bitcoin Core před
  29.0. Zranitelnost původně [zodpovědně nahlásil][topic responsible disclosures]
  Eugene Siegel spolu s další, úzce související zranitelností popsanou
  ve [zpravodaji č. 314][news314 excess addr]. Útočník mohl poslat
  nadměrný počet oznámení adresy uzlu, který způsobil přetečení
  32bitového identifikátoru a pád uzlu. Částečné opatření spočívalo v
  omezení počtu těchto zpráv na jednu za deset sekund na jedno spojení.
  Tím by přetečení při výchozím počtu 125 spojení nenastalo za méně než
  deset let. Zranitelnost byla zcela odstraněna použitím 64bitových
  datových typů počínaje Bitcoin Core verzí 29.0 vydanou minulý měsíc.

## Diskuze o změnách konsenzu

_Měsíční rubrika shrnující návrhy a diskuze o změnách pravidel
bitcoinového konsenzu._

- **Návrh BIPu pro 64bitovou aritmetiku ve Scriptu:** Chris Stewart
  zaslal do emailové skupiny Bitcoin-Dev [příspěvek][stewart bippost]
  s [pracovní verzí BIPu][64bit bip], který navrhuje přidat existujícím
  opkódům schopnost operovat s 64bitovými číselnými hodnotami. Návrhu předcházel
  jeho výzkum (viz zpravodaje [č. 285][news285 64bit], [č. 290][news290
  64bit] a [č. 306][news306 64bit]). Oproti návrhu v dřívější diskuzi
  používají nyní čísla stejný datový formát compactSize používaný v bitcoinu.
  Další související [diskuze][stewart inout] probíhala
  ve dvou [vláknech][stewart overflow] ve fóru Delving Bitcoin.

- **Návrh opkódů pro rekurzivní kovenanty pomocí quine:**
  Bram Cohen zaslal do fóra Delving Bitcoin [příspěvek][cohen quine] s návrhem
  sady jednoduchých opkódů, které by umožnily vytváření rekurzivních
  [koventantů][topic covenants] pomocí sebereprodukujících skriptů
  ([quine][quines]). Cohen popisuje, jak by mohly být tyto opkódy použité k
  tvorbě jednoduché [úschovny][topic vaults] a zmiňuje další
  pokročilý systém, na kterém pracuje.

- **Popis výhod `OP_CTV` a `OP_CSFS` pro BitVM:**
  Robin Linus zaslal do fóra Delving Bitcoin [příspěvek][linus bitvm-sf]
  o několika vylepšeních [BitVM][topic acc], které by případné opkódy
  [OP_CTV][topic op_checktemplateverify] a [OP_CSFS][topic op_checksigfromstack]
  mohly přinést, pokud by byly soft forkem přidané do bitcoinu.
  Mezi popsané výhody patří bezproblémové navýšení počtu operátorů,
  „zhruba desetinásobné snížení velikosti transakcí” (což snižuje maximální
  možné náklady) a u některých kontraktů možnost neinteraktivního peggingu.

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [LND 0.19.0-beta.rc4][] je kandidátem na vydání tohoto oblíbeného LN uzlu.
  Jedním významným vylepšením, které by si zasloužilo důkladné testování, je
  nové schéma RBF navyšování poplatků během kooperativního zavření kanálu.

## Významné změny kódu a dokumentace

_Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo] a [repozitáři BINANA][binana repo]._

- [Bitcoin Core #32155][] přidává v kódu těžby mincetvorným transakcím
  [časový zámek][topic timelocks] . Nastaví pole `nLockTime` na aktuální
  výšku bloku mínus jedna a bude vyžadovat, aby pole `nSequence`  nebylo
  finální (aby mohl být časový zámek vynucen). I když není na mainnetu
  obvykle vestavěná těžba používána, tato změna by měla povzbudit těžební
  pooly k implementaci těchto změn do svého software v přípravě na navrhovaný
  soft fork [pročištění konsenzu][topic consensus cleanup] ([BIP54][]).
  Přidání časového zámku do mincetvorných transakcí řeší zranitelnost
  [duplikovaných transakcí][topic duplicate transactions] a umožní odstranit
  nákladnou kontrolu dle [BIP30][].

- [Bitcoin Core #28710][] odstraňuje zbývající kód, dokumentaci a testy související
  se zastaralými peněženkami včetně RPC volání  `importmulti`, `sethdseed`,
  `addmultisigaddress`, `importaddress`, `importpubkey`, `dumpwallet`, `importwallet`
  a `newkeypool`. Jako finální krok odstranění podpory zastaralých peněženek je
  odstraněna závislost na BerkeleyDB. Malá část kódu a nezávislý parser databáze
  (viz [zpravodaj č. 305][news305 bdb]) zůstávají zachovány pro možnost provádět
  migraci na [deskriptorové][topic descriptors] peněženky.

- [Core Lightning #8272][] odstraňuje z démonu `connectd` mechanismus vyhledávání
  spojení z DNS seedu. Řeší tím problémy způsobené offline DNS seedy.

- [LND #8330][] přidává do modelu pravděpodobnosti bimodálního hledání cest
  malou konstantu (1/c), která řeší numerickou nestabilitu. V okrajových případech,
  kde by jinak výpočet selhal kvůli chybám zaokrouhlování nebo by byla výsledkem
  nulová pravděpodobnost, poskytuje tato regularizace záložní mechanismus v podobě
  návratu k rovnoměrnému rozdělení. Změna opravuje chybu normalizace, která se
  objevuje ve scénářích pracujících s objemnými kanály nebo kanály, které do
  bimodálního rozdělení nezapadají. Dále model přestane provádět některé nepotřebné
  výpočty pravděpodobnosti a bude opravovat neaktuální data o likviditě kanálu
  a rozporné historické informace.

- [Rust Bitcoin #4458][] nahrazuje strukturu `MtpAndHeight` explicitní dvojicí
  typů `BlockMtp` (nově přidaný) a `BlockHeight` (již existující). Tím umožní
  lepší reprezentaci výšky bloku a mediánu času posledních 11 bloků (Median Time Past,
  MTP) v relativních [časových zámcích][topic timelocks]. Na rozdíl od
  `locktime::absolute::MedianTimePast`, jehož hodnota je minimálně 500 miliónů
  (zhruba rok 1985), může `BlockMtp` reprezentovat jakékoliv 32bitové časové
  razítko. Může být tedy použit i v teoretických okrajových případech např.
  v řetězcích s neobvyklými časovými razítky. Změna dále přináší `BlockMtpInterval`
  a přejmenovává `BlockInterval` na `BlockHeightInterval`.

- [BIPs #1848][] mění stav [BIP345][] na `Withdrawn` (stažen), jelikož autor
  [věří][obeirne vaultwithdraw], že jím navrhovaný opkód `OP_VAULT` byl překonán opkódem
  [`OP_CHECKCONTRACTVERIFY`][topic matt] (OP_CCV), který přináší obecnější návrh
  [úschoven][topic vaults] a nový typ [kovenantů][topic covenants].

- [BIPs #1841][] začleňuje [BIP172][], který navrhuje na základě současného hojného
  používání formálně definovat „satoshi” jako nedělitelnou bázovou jednotku bitcoinu.

- [BIPs #1821][] začleňuje [BIP177][], který navrhuje předefinovat „bitcoin” jako
  nejmenší nedělitelnou jednotku (běžně nazývanou satoshi) namísto 100 000 000
  těchto jednotek. Návrh tvrdí, že sjednocení terminologie se skutečnou
  bázovou jednotkou by odstranilo zmatky způsobené nahodilým formátováním
  desetinných čísel.

{% include snippets/recap-ad.md when="2025-05-20 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="32155,28710,8272,8330,4458,1848,1841,1821" %}
[lnd 0.19.0-beta.rc4]: https://github.com/lightningnetwork/lnd/releases/tag/v0.19.0-beta.rc4
[news314 excess addr]: /cs/newsletters/2024/08/02/#zaplava-zprav-addr-zpusobuje-pad-na-dalku
[stewart bippost]: https://groups.google.com/g/bitcoindev/c/j1zEky-3QEE
[64bit bip]: https://github.com/Christewart/bips/blob/2025-03-17-64bit-pt2/bip-XXXX.mediawiki
[news285 64bit]: /cs/newsletters/2024/01/17/#navrh-na-soft-fork-pro-64bitovou-aritmetiku
[news290 64bit]: /cs/newsletters/2024/02/21/#pokracujici-diskuze-o-64bitove-aritmetice-a-opkodu-op-inout-amount
[news306 64bit]: /cs/newsletters/2024/06/07/#zmeny-navrhovaneho-soft-forku-pro-64bitovou-aritmetiku
[stewart inout]: https://delvingbitcoin.org/t/op-inout-amount/549/4
[stewart overflow]: https://delvingbitcoin.org/t/overflow-handling-in-script/1549
[poinsot addrvuln]: https://mailing-list.bitcoindevs.xyz/bitcoindev/EYvwAFPNEfsQ8cVwiK-8v6ovJU43Vy-ylARiDQ_1XBXAgg_ZqWIpB6m51fAIRtI-rfTmMGvGLrOe5Utl5y9uaHySELpya2ojC7yGsXnP90s=@protonmail.com/
[cohen quine]: https://delvingbitcoin.org/t/a-simple-approach-to-allowing-recursive-covenants-by-enabling-quines/1655/
[linus bitvm-sf]: https://delvingbitcoin.org/t/how-ctv-csfs-improves-bitvm-bridges/1591/
[quines]: https://cs.wikipedia.org/wiki/Quine_(program)
[news305 bdb]: /cs/newsletters/2024/05/31/#bitcoin-core-26606
[obeirne vaultwithdraw]: https://delvingbitcoin.org/t/withdrawing-op-vault-bip-345/1670/
