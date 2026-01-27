---
title: 'Zpravodaj „Bitcoin Optech” č. 390'
permalink: /cs/newsletters/2026/01/30/
name: 2026-01-30-newsletter-cs
slug: 2026-01-30-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Zpravodaj tento týden shrnuje efektivnější přístup ke garbled obvodům
a odkazuje na aktualizaci LN-Symmetry. Též nechybí naše pravidelné rubriky
s vybranými otázkami a odpověďmi z Bitcoin Stack Exchange, oznámeními
nových vydání a souhrnem významných změn v populárním bitcoinovém
páteřním software.

## Novinky

- **Argo: schéma pro garbled obvody s 1000× efektivnějšími offchain výpočty**:
  Robin Linus zaslal do fóra Delving Bitcoin [příspěvek][delving rl garbled] o novém
  článku, který napsali Liam Eagen a Ying Tong Lai. Článek popisuje techniku,
  která zefektivňuje [garbled zámky][news359 rl garbled] (garbled locks) více než
  tisíckrát. Tento nový přístup používá autentizační kódy zprávy (MAC), které kódují
  spojení garbled obvodů (garbled circuits) jako body na eliptické křivce. Tyto
  autentizační kódy jsou navrženy jako homomorfní, a tudíž umožňují reprezentovat operace
  v rámci garbled obvodu přímo jako operace nad body eliptické křivky.
  Hlavním vylepšením je, že Argo funguje nad _aritmetickými_ obvody, a nikoliv
  s binárními obvody. V případě binárních obvodů jsou pro reprezentaci násobení
  bodů na křivce potřebné miliony binárních hradel. S aritmetickými obvody
  je potřeba mít pouze jedno aritmetické hradlo. Článek je prvním z několika střípků,
  které budou potřebné pro používání této techniky nad bitcoinovými konstrukty typu
  [BitVM][topic acc].

- **Aktualizace LN-Symmetry**: Gregory Sanders zaslal do fóra Delving Bitcoin
  [příspěvek][symmetry update] o novém vývoji jeho práce na [LN-Symmetry][topic
  eltoo] (viz [zpravodaj č. 284][news284 ln sym]).

  Sanders aktualizoval verze [BOLT specifikace][bolts fork] a [CLN][cln fork],
  ze kterých odvádí svůj pilotní projekt. Nově funguje na [Bitcoin Inquisition][bitcoin
  inquisition repo] 29.x na [signetu][topic signet] s [TRUC][topic v3 transaction
  relay], [dočasným prachem (P2A)][topic ephemeral anchors] a 1p1c [přeposíláním
  balíčků][topic package relay]. Podporuje kooperativní zavírání kanálů,
  opravuje pád, kvůli kterému uzly správně nerestartovaly, a rozšiřuje pokrytí
  testy. Sanders požádal ostatní vývojáře o testování jeho nového
  prototypu na signetu s Bitcoin Inquisition.

  Sanders využil schopností LLM k migraci své práce z APO na
  OP_TEMPLATEHASH+OP_CSFS+IK (viz [zpravodaj č. 365][news365 op proposal], _angl._),
  upravil [návrh BOLTu][bolt th] a vytvořil [implementaci nad CLN][cln th].
  Dodal však, že jelikož OP_TEMPLATEHASH ještě není nasazen v Bitcoin Inquisition,
  může být tato druhá změna otestována pouze na regtestu.

## Vybrané otázky a odpovědi z Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] je jedním z prvních míst, kde hledají
přispěvatelé Optechu odpovědi na své otázky a kde – najdou-li volnou chvíli –
pomáhají zvědavým či zmateným uživatelům. V této měsíční rubrice nabízíme
některé z otázek a odpovědí, které obdržely vysoký počet hlasů.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Co se ukládá v dbcache a s jakou prioritou?]({{bse}}130376)
  Murch popisuje účel datové struktury `dbcache` jako mezipaměť pro podmnožinu
  množiny UTXO a detailně vypisuje její chování.

- [Lze provést coinjoin v Shielded CSV?]({{bse}}130364)
  Jonas Nick vysvětluje, že protokol Shielded CSV aktuálně [coinjoin][topic coinjoin]
  nepodporuje, ale že protokoly s [validací na straně klienta][topic
  client-side validation] obecně tuto funkcionalitu nevylučují.

- [Jak v Bitcoin Core používat Tor pouze pro rozesílání nových transakcí?]({{bse}}99442)
  Vasil Dimov dodává v reakci na tuto starší otázku, že s novou volbou
  `privatebroadcast` (viz [zpravodaj č. 388][news388 private broadcast]) může
  Bitcoin Core zveřejnit transakce přes krátkodobá spojení do [sítí zachovávajících
  soukromí][topic anonymity networks].

- [Brassardův–Høyerův–Tappův (BHT) algoritmus a bitcoin (BIP360)]({{bse}}130431) Uživatel
  bca-0353f40e vysvětluje, že možnost provést kolizní útok na
  [multisig][topic multisignature] adresy použitím Brassardova–Høyerova–Tappova
  (BHT) [kvantového][topic quantum resistance] algoritmu znehodnocujícího bezpečnost
  SHA256 by se netýkala adres vytvořených před touto schopností.

- [Proč BitHash střídá sha256 a ripmed160?]({{bse}}130373)
  Sjors Provoost vypisuje odůvodnění kolem funkce BitHash v [BitVM3][topic acc].
  Tato hašovací funkce je vytvořená pro bitcoinový jazyk Script.

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [Libsecp256k1 0.7.1][] je údržbovým vydáním této knihovny pro bitcoinové kryptografické
  operace, které přináší bezpečnostní vylepšení zvyšující počet případů, ve kterých
  se knihovna pokusí vymazat tajné kódy ze zásobníku. Dále přináší nový testovací
  framework a několik změn v systému sestavování.

## Významné změny kódu a dokumentace

_Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo] a [repozitáři BINANA][binana repo]._

- [Bitcoin Core #33822][] přidává do API `libbitcoinkernel` (viz [zpravodaj č.
  380][news380 kernel], _angl._) podporu pro hlavičky bloků. Nový typ
  `btck_BlockHeader` a jeho metody umožňují vytvářet, kopírovat a uvolňovat
  hlavičky a načítat jejich pole jako haš, předchozí haš, časová razítka,
  cíl složitosti, verze a nonce. Nová metoda `btck_chainstate_manager_process_block_header()`
  validuje a zpracovává hlavičky bloků bez potřeby mít kompletní blok.
  `btck_chainstate_manager_get_best_entry()` vrací záznam ze stromu bloků, který
  nashromáždil nejvíce proof of work.

- [Bitcoin Core #34269][] znemožňuje vytváření nebo obnovu nepojmenovaných peněženek
  během používání RPC volání `createwallet` a `restorewallet` (viz zpravodaje [č. 45][news45
  wallettool] a [č. 130][news130 wallettool], oba _angl._). I když GUI tato omezení
  již vynucovalo, RPC a kód nikoliv. Migrace peněženky může i nadále obnovit
  nepojmenované peněženky. [Zpravodaj č. 387][news387 unnamed] popisuje chybu
  související s nepojmenovanými peněženkami.

- [Core Lightning #8850][] odstraňuje několik zastaralých funkcí:
  `option_anchors_zero_fee_htlc_tx`, přejmenovanou na `option_anchors` kvůli
  změnám v [anchor výstupech][topic anchor outputs], RPC `decodepay`
  (nahrazenou voláním `decode`), pole `tx` a `txid` v odpovědi na příkaz `close`
  (nahrazena poli `txs` a `txids`) a `estimatefeesv1`, původní formát odpovědí
  používaný pluginem `bcli` pro získání [odhadu poplatků][topic fee estimation].

- [LDK #4349][] přidává do parsování [BOLT12 nabídek][topic offers] validaci
  zarovnání (padding) [bech32][topic bech32] dle specifikace v [BIP173][].
  Dříve LDK akceptovalo nabídky s nevalidním zarovnáním, avšak ostatní implementace
  jako Lightning-KMP a Eclair je korektně odmítly. Do výčtového seznamu
  `Bolt12ParseError` byla přidána nová položka `InvalidPadding`.

- [Rust Bitcoin #5470][] přidává do dekodéru validaci odmítající transakce
  bez výstupů. Platné bitcoinové transakce musí mít alespoň jeden výstup.

- [Rust Bitcoin #5443][] přidává do dekodéru validaci odmítající transakce,
  jejichž výstupy mají částky dohromady přesahující `MAX_MONEY` (21 milionů bitcoinů).
  Tato kontrola souvisí s [CVE-2010-5139][topic cves], historickou zranitelností,
  kdy mohl útočník vytvořit transakce s extrémně vysokými výstupními hodnotami.

- [BDK #2037][] přidává do struktury `CheckPoint` metodu `median_time_past()`,
  která spočítá medián času posledních 11 bloků (Median Time Past, MTP) definovaný
  v [BIP113][]. Ten je používán pro validaci [časových zámků][topic timelocks].
  [Zpravodaj č. 372][news372 mtp] (_angl._) popisuje další související práci.

- [BIPs #2076][] přidává [BIP434][], který definuje P2P zprávu, která by
  peer spojením umožnila oznamovat a vyjednávat o podpoře nové funkcionality.
  Myšlenka zobecňuje mechanismus [BIP339][] (viz [zpravodaj č. 87][news87 negotiation],
  _angl._), ale namísto nutnosti definovat novou zprávu pro každou funkci
  poskytuje [BIP434][] jednu univerzální zprávu pro různé upgrady P2P
  protokolu. Tento mechanismus je užitečný pro některé návrhy na změnu
  v P2P protokolu jako [sdílení šablon][news366 template]. Viz též [zpravodaj
  č. 386][news386 feature], který popisuje diskuzi v emailové skupině.

- [BIPs #1500][] přidává [BIP346][], který definuje opkód `OP_TXHASH` pro
  [tapscript][topic tapscript]. Tato instrukce přidá do zásobníku hašový otisk
  určitých částí utrácející transakce. Toho lze využít pro vytváření
  [koventantů][topic covenants] a snížení interaktivity v protokolech s více
  stranami. Opkód zobecňuje [OP_CHECKTEMPLATEVERIFY][topic
  op_checktemplateverify] a může v kombinaci s [OP_CHECKSIGFROMSTACK][topic
  op_checksigfromstack] emulovat [SIGHASH_ANYPREVOUT][topic sighash_anyprevout].
  Viz zpravodaje [č. 185][news185 txhash] (_angl._) a [č. 272][news272
  txhash] pro související diskuze.

{% include snippets/recap-ad.md when="2026-02-03 17:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="33822,34269,8850,4349,5470,5443,2037,2076,1500" %}
[news359 rl garbled]: /en/newsletters/2025/06/20/#improvements-to-bitvm-style-contracts
[news369 le garbled]: /en/newsletters/2025/08/29/#garbled-locks-for-accountable-computing-contracts
[delving rl garbled]: https://delvingbitcoin.org/t/argo-a-garbled-circuits-scheme-for-1000x-more-efficient-off-chain-computation/2210
[iacr le ytl garbled]: https://eprint.iacr.org/2026/049.pdf
[symmetry update]: https://delvingbitcoin.org/t/ln-symmetry-project-recap/359/17
[news284 ln sym]: /cs/newsletters/2024/01/10/#implementace-ln-symmetry
[bolts fork]: https://github.com/instagibbs/bolts/tree/eltoo_trucd
[cln fork]: https://github.com/instagibbs/lightning/tree/2026-01-eltoo_rebased
[news365 op proposal]: /en/newsletters/2025/08/01/#taproot-native-op-templatehash-proposal
[news388 private broadcast]: /cs/newsletters/2026/01/16/#bitcoin-core-29415
[bolt th]: https://github.com/instagibbs/bolts/tree/2026-01-eltoo_th
[cln th]: https://github.com/instagibbs/lightning/commits/2026-01-eltoo_templatehash
[Libsecp256k1 0.7.1]: https://github.com/bitcoin-core/secp256k1/releases/tag/v0.7.1
[news380 kernel]: /en/newsletters/2025/11/14/#bitcoin-core-30595
[news45 wallettool]: /en/newsletters/2019/05/07/#new-wallet-tool
[news130 wallettool]: /en/newsletters/2021/01/06/#bitcoin-core-19137
[news387 unnamed]: /cs/newsletters/2026/01/09/#chyba-v-migraci-penezenky-v-bitcoin-core
[news372 mtp]: /en/newsletters/2025/09/19/#bdk-1582
[news87 negotiation]: /en/newsletters/2020/03/04/#improving-feature-negotiation-between-full-nodes-at-startup
[news386 feature]: /cs/newsletters/2026/01/02/#vyjednavani-o-schopnostech-peer-spojeni
[news366 template]: /en/newsletters/2025/08/08/#peer-block-template-sharing-to-mitigate-problems-with-divergent-mempool-policies
[news185 txhash]: /en/newsletters/2022/02/02/#composable-alternatives-to-ctv-and-apo
[news272 txhash]: /cs/newsletters/2023/10/11/#navrh-specifikace-op-txhash
