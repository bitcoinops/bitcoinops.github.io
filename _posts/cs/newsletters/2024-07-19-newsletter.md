---
title: 'Zpravodaj „Bitcoin Optech” č. 312'
permalink: /cs/newsletters/2024/07/19/
name: 2024-07-19-newsletter-cs
slug: 2024-07-19-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Zpravodaj tento týden přináší popis protokolu pro distribuované generování
klíčů pro schéma bezskriptového prahového elektronického podpisu FROST a
odkazuje na podrobný úvod do linearizace clusterů. Též nechybí naše pravidelné
rubriky s popisem nedávných významných změn ve službách, klientech a
populárních bitcoinových páteřních projektech.

## Novinky

- **Protokol pro distribuované generování klíčů pro FROST:** Tim Ruffing a
  Jonas Nick zaslali do emailové skupiny Bitcoin-Dev [příspěvek][ruffing
  nick post] s [návrhem BIPu][chilldkg bip] a [referenční implementací][chilldkg
  ref] protokolu ChillDKG pro bezpečné generování klíčů, které mohou být
  používány pro [bezskriptové prahové elektronické podpisy][topic threshold
  signature] kompatibilní se [Schnorrovými podpisy][topic schnorr signatures].
  Jedním příkladem takového schématu je [FROST][].

  Bezskriptové prahové elektronické podpisy jsou kompatibilní s vytvořením
  `n` klíčů, z nichž kterýchkoliv `t` může být kooperativně použito k vytvoření
  validního podpisu. Například schéma 2-ze-3 vytvoří tři klíče, z nichž
  kterékoliv dva mohou vytvořit validní podpis. _Bezskriptové_ znamená, že
  schéma zcela závisí na operacích mimo konsenzus a blockchain, což je opakem
  vestavěných skriptových prahových podpisů (např. pomocí `OP_CHECKMULTISIG`).

  Podobně jako při generování běžného bitcoinového soukromého klíče musí i
  zde každý účastník vygenerovat velké náhodné číslo, které nikomu nesmí
  sdělit. Avšak každý účastník musí navíc rozeslat ostatním účastníkům
  kódy odvozené z těchto náhodných čísel, aby mohla patřičná část z nich
  (daná hodnotou prahu) podpis vytvořit, i kdyby byl jeho klíč nedostupný.
  Každý uživatel musí ověřit, že informace obdržené od všech ostatních
  byly vygenerované správně. Existuje několik protokolů pro generování
  klíčů, avšak předpokládají, že uživatelé mají přístup k šifrovanému a
  autentizovanému komunikačnímu kanálu mezi jednotlivými uživateli, který
  navíc umožňuje necenzurovatelné autentizované šíření zpráv od každého
  uživatele všem ostatním. Protokol ChillDKG kombinuje známý algoritmus
  generování klíčů pro FROST s dalšími moderními kryptografickými primitivy
  a jednoduchými algoritmy, které poskytnou nezbytnou bezpečnou, autentizovanou
  a doložitelně necenzurovanou komunikaci.

  Šifrování a autentizace mezi účastníky začíná výměnou klíčů pomocí
  [Diffieho-Hellmannova protokolu nad eliptickými křivkami][ecdh] (ECDH).
  Každý účastník vytvoří doklad absence cenzury tím, že svým klíčem
  podepíše transkript sezení od začátku až do vytvoření bezskriptového prahového
  veřejného klíče (kterým sezení končí). Všichni ostatní tento podpis ověří, než
  prahový veřejný klíč přijmou.

  Cílem je poskytnout zcela obecný protokol, který by byl použitelný ve
  všech případech, kdy chtějí lidé generovat klíče pro bezskriptové prahové
  elektronické podpisy založené na FROSTu. Navíc tento protokol nabízí
  možnost snadno ukládat zálohy: uživatel pouze potřebuje svůj soukromý
  seed a data pro obnovu, která nejsou citlivá na bezpečnost (ale mají
  dopad na soukromí). V [následné zprávě][nick follow-up] Jonas Nick zmínil,
  že uvažují nad rozšířením protokolu o šifrování dat pro obnovu klíčem
  odvozeným ze seedu. Díky tomu by jedinými daty, které uživatel musí
  chránit, byl seed.

- **Úvod do linearizace clusterů:** Pieter Wuille zaslal do fóra Delving
  Bitcoin [příspěvek][wuille cluster] s podrobným popisem všech hlavních
  částí linearizace clusterů, která tvoří základ [mempoolu clusterů][topic cluster
  mempool]. V minulých číslech zpravodaje jsme se toto téma pokoušeli
  představit v době, kdy byly vyvíjeny a publikovány klíčové koncepty.
  Tento přehled je však mnohem podrobnější. Postupně seznamuje čtenáře
  se vším od základních konceptů po konkrétní implementované algoritmy.
  Na závěr uvádí odkazy na několik pull requestů Bitcoin Core, které
  části cluster mempoolu implementují.

## Změny ve službách a klientech

*V této měsíční rubrice upozorňujeme na zajímavé aktualizace bitcoinových
peněženek a služeb.*

- **ZEUS přidává podporu pro BOLT12 nabídky a BIP353:**
  Vydání [v0.8.5][zeus v0.8.5] využívá službu [TwelveCash][twelve cash
  website] pro podporu [nabídek][topic offers] a [BIP353][] (viz
  [zpravodaj č. 307][news307 bip353]).

- **Phoenix přidává podporu pro BOLT12 nabídky a BIP353:**
  Vydání [Phoenix 2.3.1][phoenix 2.3.1] přidalo podporu pro nabídky a [Phoenix
  2.3.3][phoenix 2.3.3] přidalo podporu pro [BIP353][].

- **Stack Wallet přidává podporu pro RBF a CPFP:**
  Vydání Stack Wallet [v2.1.1][stack wallet v2.1.1] přidalo podporu pro navýšení
  poplatku pomocí [RBF][topic rbf] a [CPFP][topic cpfp] a také podporu pro
  [Tor][topic anonymity networks].

- **BlueWallet přidává podporu pro posílání tichých plateb:**
  Ve vydání [v6.6.7][bluewallet v6.6.7] přidala BlueWallet možnost platit na
  adresy [tichých plateb][topic silent payments].

- **Ohlášen BOLT12 Playground:**
  Strike [ohlásil][strike bolt12 playground] testovací prostředí pro BOLT12 nabídky.
  Projekt pomocí Dockeru vytváří a automatizuje peněženky, kanály a platby napříč
  různými LN implementacemi.

- **Ohlášen testovací repozitář Moosig:**
  Ledger zveřejnil testovací [repozitář][moosig github] založený na Pythonu určený
  k používání [MuSig2][topic musig] a [pravidel peněženek pro deskriptorové
  peněženky][news302 bip388] ([BIP388][]).

- **Vydán nástroj pro vizualizaci protokolu Stratum v reálném čase:**
  Webová stránka [stratum.work][stratum.work] založená na [předchozím bádání][b10c
  nostr] zobrazuje v reálném čase Stratum zprávy od různých bitcoinových
  těžebních poolů. K dispozici je [zdrojový kód][stratum work github].

- **Ohlášen BMM 100 Mini Miner:**
  [Těžební zařízení][braiins mini miner] od Braiins přichází s podmnožinou funkcí
  [Stratum V2][topic pooled mining], jehož podpora je ve výchozím nastavení aktivní.

- **Coldcard zveřejňuje specifikaci publikování transakcí založeného na URL:**
  [Protokol][pushtx spec] umožňuje zveřejňovat bitcoinové transakce pomocí
  HTTP GET požadavku; mimo jiné může být protokol použit hardwarovými podpisovými
  zařízeními založenými na NFC.

## Významné změny kódu a dokumentace

_Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Bitcoin Inquisition][bitcoin inquisition repo] a [repozitáři BINANA][binana
repo]._

- [Bitcoin Core #26596][] používá nový parser zastaralých databází k migrování
  zastaralých peněženek na [deskriptorové][topic descriptors]. Změna ponechává
  podporu pro zastaralé peněženky i zastaralý typ `BerkeleyDatabase`. Byla přidána
  třída `LegacyDataSPKM`, která obsahuje pouze data a funkce nezbytné pro nahrávání
  zastaralých peněženek určených k migraci. [Zpravodaj č. 305][news305 bdb] představil
  `BerkeleyRODatabase`.

- [Core Lightning #7455][] přidává do `connectd` přeposílání [onion zpráv][topic
  onion messages] pomocí `short_channel_id` (SCID) i `node_id` (viz [zpravodaj
  č.307][news307 ldk3080], který popisuje podobnou změnu v LDK). Onion zprávy
  jsou nově vždy aktivní, příchozí zprávy jsou omezeny na čtyři za sekundu.

- [Eclair #2878][] přináší volitelnou podporu [zaslepených cest][topic rv routing]
  a quiescence (chvíle ticha) protokolu. Obě funkce jsou již plně implementované
  a mají své BOLT specifikace (viz zpravodaje [č. 245][news245 blind] a [č. 309][news309
  stfu]). Eclair uzel inzeruje podporu pro obě funkce, avšak `route_blinding`
  (zaslepené cesty) je ve výchozím nastavení neaktivní, neboť neumí přeposílat
  [zaslepené platby][topic rv routing], které nepoužívají [trampolínového routování][topic
  trampoline payments].

- [Rust Bitcoin #2646][] přidává do struktur `Script` a `Witness` nové inspektory
  jako `redeem_script` (ověřující shodu s [BIP16][] pravidly ohledně utrácení P2SH),
  `taproot_control_block` a `taproot_annex` (ověřující shodu s [BIP341][]) a
  `witness_script` (shoda s [BIP141][]). Viz též [zpravodaj č. 309][news309 p2sh].

- [BDK #1489][] přináší do `bdk_electrum` používání Merkleových důkazů během
  zjednodušeného ověřování plateb (simplified payment verification, SPV). Vedle
  transakcí stáhne též Merkleovy důkazy a hlavičky bloků a ověří, že transakce
  jsou obsažené v potvrzených blocích. PR dále představuje nový typ ukotvení
  bloků `ConfirmationBlockTime`, který nahrazuje předchozí typy.

- [BIPs #1599][] přidává [BIP46][] popisující schéma derivace pro HD peněženky, které
  vytváří adresy s [časovým zámkem][topic timelocks] používané pro [finanční
  závazky][news161 fidelity] (fidelity bonds), které jsou používány při párování
  nabídek v online tržištích s [coinjoiny][topic coinjoin] ve stylu JoinMarket. Finanční závazky
  zlepšují odolnost vůči sybil útokům, protože přináší systém reputace, ve kterém
  tvůrci nabídek dokládají svou serióznost záměrnou obětí v podobě časově uzamčených
  bitcoinů.

- [BOLTs #1173][] činí pole `channel_update` v chybových [onion zprávách][topic onion
  messages] volitelným. Uzly nově toto pole mimo aktuální platbu ignorují, aby
  pomohly chránit identitu odesílatelů [HTLC][topic htlc]. Změna má za cíl
  eliminovat zdržování plateb kvůli neaktuálním parametrům kanálu, avšak ponechává
  uzlům se starými gossip daty možnost v případě potřeby aktualizace přijímat.

- [BLIPs #25][] přidává [BLIP25][] popisující, jak umožnit přeposílání HTLC, která
  platí nedostatečně vzhledem k zakódované hodnotě. Například Alice chce, aby jí
  Bob poslal peníze, avšak nemá žádný platební kanál. Alicino LSP Carol otevře
  [JIT kanál][topic jit channels]. Aby mohla Carol nárokovat poplatek za službu
  a pokrytí svých onchain nákladů, využije tohoto protokolu a pošle Alici
  HTLC, které platí nedostatečně vzhledem k zakódované hodnotě. Viz též [zpravodaj
  č. 257][news257 jit htlc], který popisuje implementaci v LDK.

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="26596,7455,2878,2646,1489,1599,1173,25" %}
[ruffing nick post]: https://mailing-list.bitcoindevs.xyz/bitcoindev/8768422323203aa3a8b280940abd776526fab12e.camel@timruffing.de/T/#u
[chilldkg bip]: https://github.com/BlockstreamResearch/bip-frost-dkg
[chilldkg ref]: https://github.com/BlockstreamResearch/bip-frost-dkg/tree/master/python/chilldkg_ref
[nick follow-up]: https://groups.google.com/g/bitcoindev/c/HE3HSnGTpoQ/m/DC90IMZiBgAJ
[wuille cluster]: https://delvingbitcoin.org/t/introduction-to-cluster-linearization/1032
[frost]: https://eprint.iacr.org/2020/852.pdf
[ecdh]: https://cs.wikipedia.org/wiki/Diffieho%E2%80%93Hellman%C5%AFv_protokol_s_vyu%C5%BEit%C3%ADm_eliptick%C3%BDch_k%C5%99ivek
[zeus v0.8.5]: https://github.com/ZeusLN/zeus/releases/tag/v0.8.5
[twelve cash website]: https://twelve.cash/
[news307 bip353]: /cs/newsletters/2024/06/14/#bips-1551
[phoenix 2.3.1]: https://github.com/ACINQ/phoenix/releases/tag/android-v2.3.1
[phoenix 2.3.3]: https://github.com/ACINQ/phoenix/releases/tag/android-v2.3.3
[stack wallet v2.1.1]: https://github.com/cypherstack/stack_wallet/releases/tag/build_235
[bluewallet v6.6.7]: https://github.com/BlueWallet/BlueWallet/releases/tag/v6.6.7
[strike bolt12 playground]: https://strike.me/blog/bolt12-playground/
[moosig github]: https://github.com/LedgerHQ/moosig
[news302 bip388]: /cs/newsletters/2024/05/15/#bips-1389
[stratum.work]: https://stratum.work/
[stratum work github]: https://github.com/bboerst/stratum-work
[b10c nostr]: https://primal.net/e/note1qckcs4y67eyaawad96j7mxevucgygsfwxg42cvlrs22mxptrg05qtv0jz3
[braiins mini miner]: https://braiins.com/hardware/bmm-100-mini-miner
[pushtx spec]: https://pushtx.org/#url-protocol-spec
[news305 bdb]: /cs/newsletters/2024/05/31/#bitcoin-core-26606
[news309 p2sh]: /cs/newsletters/2024/06/28/#rust-bitcoin-2794
[news161 fidelity]: /en/newsletters/2021/08/11/#implementation-of-fidelity-bonds
[news257 jit htlc]: /cs/newsletters/2023/06/28/#ldk-2319
[news307 ldk3080]: /cs/newsletters/2024/06/14/#ldk-3080
[news245 blind]: /cs/newsletters/2023/04/05/#bolts-765
[news309 stfu]: /cs/newsletters/2024/06/28/#bolts-869
