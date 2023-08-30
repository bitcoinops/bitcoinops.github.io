---
title: 'Zpravodaj „Bitcoin Optech” č. 266'
permalink: /cs/newsletters/2023/08/30/
name: 2023-08-30-newsletter-cs
slug: 2023-08-30-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Tento týden přinášíme oznámení o zodpovědném zveřejnění zranitelnosti
postihující staré LN implementace a souhrn návrhu na mix opkódů
pro kovenanty. Též nechybí naše pravidelné rubriky s vybranými otázkami
a odpověďmi z Bitcoin Stack Exchange, oznámeními o nových vydáních a souhrnem
významných změn v populárních bitcoinových páteřních projektech.

## Novinky

- **Zveřejnění proběhlé zranitelnosti LN spojené s falešným financováním:** Matt
  Morehouse zaslal do emailové skupiny Lightning-Dev [příspěvek][morehouse dos]
  s popisem zranitelnosti, kterou předtím [zodpovědně zveřejnil][topic
  responsible disclosures] a kterou ve svých posledních vydáních adresují
  všechny populární implementace LN. Abychom zranitelnosti porozuměli,
  představme si, že Bob provozující LN uzel obdrží od Malloryho žádost o
  otevření nového kanálu. Absolvují proces otevření kanálu až do bodu, ve
  kterém se od Malloryho očekává zveřejnění transakce financující kanál.
  Aby bylo možné kanál později používat, musí Bob uložit relevantní data
  a sledovat nové bloky pro dostatečné potvrzení této transakce. Pokud však
  Mallory transakci nikdy nezveřejní, plýtvá Bob úložištěm a zdroji vynaloženými
  na sledování bloků. Opakuje-li Mallory tento process tisíckrát nebo
  milionkrát, může přivést Bobův uzel až do bodu, kdy jej není možné vůbec
  používat a to včetně provádění citlivých operací nutných pro zabránění ztráty
  peněz.

  Během testování svého vlastního uzlu byl Morehouse schopen způsobit výrazné
  problémy Core Lightningu, Eclairu, LDK i LND, a to včetně dvou případů, které
  mohly podle našeho názoru vést ke ztrátě peněz mnoha uzlů. Morehousův
  [popis][morehouse post] odkazuje na PR, která tento problém adresují (včetně
  PR zmíněných ve zpravodajích [č. 237][news237 dos] a [č. 240][news240 dos])
  a vyjmenovává vydání, která tuto zranitelnost opravují:

  - Core Lightning 23.02
  - Eclair 0.9.0
  - LDK 0.0.114
  - LND 0.16.0

  V emailové skupině i na [IRC][stateless funding] se objevilo množství
  reakcí.

- **Kovenanty namíchané z `TXHASH` a `CSFS`:** Brandon Black
  zaslal do emailové skupiny Bitcoin-Dev [příspěvek][black mashup] s návrhem
  na variantu `OP_TXHASH` (viz [zpravodaj č. 185][news185 txhash], *angl.*)
  zkombinovanou s [OP_CHECKSIGFROMSTACK][topic op_checksigfromstack], která
  by mohla poskytnout většinu funkcí [OP_CHECKTEMPLATEVERIFY][topic
  op_checktemplateverify] (CTV) a [SIGHASH_ANYPREVOUT][topic
  sighash_anyprevout] (APO) bez velkých nadbytečných onchain nákladů oproti
  původním jednotlivým návrhům. I když je návrh zajímavý sám o sobě, jeho
  vznik byl částečně motivován snahou „objasnit naše uvažování o [CTV a APO]
  jednotlivě i dohromady a potenciálně nás posunout směrem ke konsenzu na
  cestě […] k úžasným budoucím možnostem používání bitcoinu.”
  Návrh obdržel v emailové skupině několik reakcí, [další příspěvky][delv mashup]
  a diskuze se objevily ve fóru Delving Bitcoin.

## Vybrané otázky a odpovědi z Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] je jedním z prvních míst, kde hledají
přispěvatelé Optechu odpovědi na své otázky a kde – najdou-li volnou chvíli –
pomáhají zvědavým či zmateným uživatelům. V této měsíční rubrice nabízíme
některé z otázek a odpovědí, které obdržely vysoký počet hlasů.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Existují ekonomické podněty k přechodu z P2WPKH na P2TR?]({{bse}}119301)
  Murch prochází běžné vzory používání peněženek a porovnává váhy transakčních
  vstupů a výstupů pro P2WPKH a [P2TR][topic taproot]. Jeho závěr:
  „Celkově bys mohl používáním P2TR místo P2WPKH ušetřit na poplatcích až 15,4 %.
  Pokud odesíláš mnohem více drobných plateb, než přijímáš, setrváním u P2WPKH
  bys mohl ušetřit až 1,5 %.”

- [Jaká je struktura BIP324 zašifrovaných paketů?]({{bse}}119369)
  Pieter Wuille ukazuje strukturu síťových paketů u [P2P přenosu verze 2][topic
  v2 p2p transport] dle návrhu v [BIP324][], jehož implementaci lze sledovat
  v [Bitcoin Core #27634][].

- [Kolik falešně pozitivních výsledků vrací filtry kompaktních bloků?]({{bse}}119142)
  Murch poukazuje na [BIP158][] a jeho část o výběru parametrů [filtru bloků][bip158
  filters], která poznamenává, že míra falešně pozitivních výsledků [filtrů
  kompaktních bloků][topic compact block filters] je 1:784 931, tedy zhruba
  jeden blok každých osm týdnů v případě peněženky monitorující kolem tisíce
  výstupních skriptů.

- [Které opkódy jsou součástí navrhovaného MATT?]({{bse}}119239)
  Salvatoshi objasňuje koncept Merkleize All The Things ([MATT][merkle.fun],
  „všechno to zmerklujte”), jehož je sám autorem, včetně současně navrhovaných
  opkódů: [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify],
  OP_CHECKCONTRACTVERIFY a  [OP_CAT][]. Viz též zpravodaje [č. 226][news226
  matt] (*angl.*), [č. 249][news249 matt] a [č. 254][news254 matt].

- [Je poslední bitcoinový blok nějak definovaný?]({{bse}}119223)
  RedGrittyBrick a Pieter Wuille vysvětlují, že i když výška bloku nemá žádné
  omezení, současná pravidla konsenzu nepřijmou žádný nový blok obsahující
  časové razítko nad limit daný bezznaménkovým 32bitovým datovým typem, tedy
  rok 2106. Transakce a jejich [nLockTime][topic timelocks] hodnoty mají stejné
  [omezení]({{bse}}110666).

- [Proč těžaři nastavují locktime v coinbasových transakcích?]({{bse}}110474)
  Bordalix odpovídá na dlouho otevřenou otázku, proč těžaři zjevně používají
  locktime v coinbasových transakcích. Provozovatel těžebního poolu vysvětlil,
  že „přepoužili tyto čtyři byty pro držení dat stratum session, což jim
  umožňuje rychlejší připojení” a dále celé schéma [objasnil][twitter satofishi].

- [Proč během Schnorrova podepisování nepoužívá Bitcoin Core doplňkovou náhodnost?]({{bse}}119042)
  Matthew Leon se táže, proč [BIP340][] doporučuje během generování nonce [Schnorrových
  podpisů][topic schnorr signatures] používat doplňkovou náhodnost jako ochranu
  před [útoky postranními kanály][topic side channels], a přesto Bitcoin Core
  tuto doplňkovou náhodnost ve své implementaci nepoužívá. Andrew Chow odpovídá,
  že současná implementace je i takto bezpečná a že žádné PR ještě nebylo otevřeno,
  aby toto doporučení adresovalo.

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [Core Lightning 23.08][] je nejnovějším hlavním vydáním této oblíbené
  implementace LN uzlu. Mezi novými funkcemi a opravami chyb je možnost
  změnit několik položek konfigurace uzlu bez nutnosti jej restartovat,
  podpora pro zálohu a obnovu [seedu][topic bip32] pomocí [Codex32][topic
  codex32], nový experimentální plugin pro vylepšené hledání cest,
  experimentální podpora pro [splicing][topic splicing] a možnost platit
  lokálně generované smlouvy.

- [LND v0.17.0-beta.rc1][] je kandidátem na vydání příští hlavní verze
  této populární implementace LN uzlu. Významnou novou experimentální
  funkcí plánovanou pro toto vydání, které by testování prospělo,
  je podpora „jednoduchých taprootových kanálů” popsaných v LND PR #7904
  v rubrice s významnými změnami.

## Významné změny v kódu a dokumentaci

*Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo] a
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [Bitcoin Core #27460][] přidává nové RPC volání `importmempool`.
  Volání načte soubor `mempool.dat` a pokusí se do mempoolu přidat načtené
  transakce.

- [LDK #2248][] přináší vestavěný systém, který může projektům používajícím
  LDK poskytnout sledování UTXO odkazovaných v gossip zprávách. LN uzly, které
  gossip zpracovávají, musí akceptovat pouze zprávy podepsané klíčem přidruženým
  k nějakému UTXO, jinak by mohly být donuceny zpracovávat a přeposílat
  spam nebo přeposílat platby přes neexistující kanály (což by vždy selhalo).
  Nový vestavěný `UtxoSource` funguje s LN uzly připojenými k lokální instanci
  Bitcoin Core.

- [LDK #2337][] usnadňuje používání LDK pro budování [strážních věží][topic
  watchtowers], které běží nezávisle na uživatelově peněžence, ale které
  mohou od uživatelova uzlu přijímat zašifrované transakce s LN pokutami.
  Strážní věž může z každé transakce v novém bloku extrahovat informace a
  pokusit se díky nim dešifrovat data přijatá dříve. Pokud rozšifrování
  uspěje, může strážní věž trestnou transakci zveřejnit. To chrání uživatele
  před protistranami publikujícími starý, neplatný stav kanálu v době uživatelovy
  nedostupnosti.

- [LDK #2411][] a [#2412][ldk #2412] přidávají API pro konstrukci platebních
  cest pro [zaslepené platby][topic rv routing]. PR odděluje kód pro [onion
  zprávy][topic onion messages] (které zaslepené cesty používají) od samotných
  zaslepených cest. Následující PR [#2413][ldk #2413] vlastní podporu pro zaslepené
  cesty přidává.

- [LDK #2507][] obchází dlouhotrvající problémy jiné implementace, které vedou
  ke zbytečnému nucenému zavření kanálu.

- [LDK #2478][] přidává událost, která poskytuje informace o přeposílaném
  [HTLC][topic htlc], které již bylo vyrovnáno, včetně kanálu, ze kterého
  přišlo, částky a velikosti poplatku.

- [LND #7904][] přidává experimentální podporu „jednoduchých taprootových kanálů,”
  která umožní používat [P2TR][topic taproot] pro otevírací a commitment
  transakce. To s sebou také přináší podporu bezskriptového podepisování
  [vícenásobnými elektronickými podpisy][topic multisignature] dle [MuSig2][topic
  musig]. Sníží to váhu transakce a vylepší soukromí v případě kooperativního
  zavření. LND nadále používá výhradně [HTLC][topic htlc], díky čemuž mohou
  být platby začínající v taprootovém kanálu i nadále přeposílány i uzly,
  které taproot kanály nepodporují.

  Toto PR sestává z 134 commitů, které byly předtím začleněny do pracovní
  větve z následujících PR: [#7332][lnd #7332], [#7333][lnd #7333],
  [#7331][lnd #7331], [#7340][lnd #7340], [#7344][lnd #7344], [#7345][lnd #7345],
  [#7346][lnd #7346], [#7347][lnd #7347] a [#7472][lnd #7472].

{% include references.md %}
{% include linkers/issues.md v=2 issues="27460,2466,2248,2337,2411,2412,2413,2507,2478,7904,7332,7333,7331,7340,7344,7345,7346,7347,7472,27634" %}
[LND v0.17.0-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.17.0-beta.rc1
[core lightning 23.08]: https://github.com/ElementsProject/lightning/releases/tag/v23.08
[delv mashup]: https://delvingbitcoin.org/t/combined-ctv-apo-into-minimal-txhash-csfs/60/6
[morehouse dos]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-August/004064.html
[morehouse post]: https://morehouse.github.io/lightning/fake-channel-dos/
[news237 dos]: /cs/newsletters/2023/02/08/#core-lightning-5849
[news240 dos]: /cs/newsletters/2023/03/01/#ldk-1988
[black mashup]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-August/021907.html
[news185 txhash]: /en/newsletters/2022/02/02/#composable-alternatives-to-ctv-and-apo
[stateless funding]: https://gnusha.org/lightning-dev/2023-08-27.log
[bip158 filters]: https://github.com/bitcoin/bips/blob/master/bip-0158.mediawiki#block-filters
[merkle.fun]: https://merkle.fun/
[news254 matt]: /cs/newsletters/2023/06/07/#vyuziti-matt-k-napodobeni-ctv-a-sprave-joinpoolu
[news249 matt]: /cs/newsletters/2023/05/03/#uschovny-zalozene-na-matt
[news226 matt]: /en/newsletters/2022/11/16/#general-smart-contracts-in-bitcoin-via-covenants
[twitter satofishi]: https://twitter.com/satofishi/status/1693537663985361038
