---
title: 'Zpravodaj „Bitcoin Optech” č. 337'
permalink: /cs/newsletters/2025/01/17/
name: 2025-01-17-newsletter-cs
slug: 2025-01-17-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Zpravodaj tento týden shrnuje pokračující diskuzi o odměňování těžařů
v poolu obchodovatelnými ecashovými share a popisuje nový návrh umožňující
offchain urovnání DLC. Též nechybí naše pravidelné rubriky s oznámeními
nových vydání a popisem významných změn v populárním bitcoinovém páteřním
software.

## Novinky

- **Pokračující diskuze o používání ecash k vyplácení odměn za těžbu v poolu:**
  [diskuze][ecash tides] o používání ecash k vyplácení odměn za každý share
  zaslaný [těžaři v poolu][topic pooled mining] od našeho [předchozího souhrnu][news304
  ecashtides] vlákna ve fóru Delving Bitcoin dále pokračuje. Matt Corallo se již
  dříve [tázal][corallo whyecash], proč by pool přidával další kód a účetnictví
  pro zpracování obchodovatelných ecashových share, když mohou jednoduše platit
  těžařům pomocí normálního ecash či LN. David Caseria [odpověděl][caseria pplns],
  že v některých [PPLNS][topic pplns] schématech (pay per last N shares, platba za
  posledních N share) jako [TIDES][recap291 tides] může těžař čekat, až pool nalezne
  několik bloků, což může v případě menších poolů trvat dny či týdny. Namísto
  čekání by mohl těžař svá ecashová share okamžitě prodat na trhu (aniž by
  poolu nebo třetí straně odhalil či naznačil svou identitu).

  Caseria dále poznamenal, že pro existující těžební pooly je finančně
  náročné podporovat schéma plné výplaty za share (full pay per share,
  [FPPS][topic fpps]), ve kterém těžař za vytvořený share obdrží odměnu
  poměrnou k odměně za celý blok (včetně poplatků z transakcí). Svou
  myšlenku již dále nerozvinul, ale dle našeho chápání je problémem
  proměnlivost poplatků, která pooly nutí držet velké rezervy. Na příklad
  pokud těžař do poolu přispívá 1 % hashrate a vytvoří share nad šablonou
  s 1 000 BTC za poplatky a 3BTC odměnou, měl by od svého poolu obdržet
  kolem 10 BTC. Avšak pokud pool tento blok nevytěží a vytěží jiný s poplatky,
  které tvoří jen zlomek hodnoty odměny za jeho nalezení, má pool k rozdělení mezi
  všechny své těžaře pouze 3 BTC. Bude tak muset platit ze svých rezerv.
  Pokud se to děje příliš často, jeho rezervy se vyčerpají a pool skončí.
  Pooly tento problém řeší několika způsoby včetně používání různých
  [zástupných metrik za skutečné poplatky][news304 fpps proxy].

  Vývojář vnprc [popsal][vnprc ehash] své [řešení][hashpool], které
  se zaměřuje na ecashové share obdržená v PPLNS schématu. Domnívá se,
  že by mohlo být obzvláště užitečné pro spouštění nových poolů: první
  těžař, který se k poolu připojí, trpí stejnou vysokou variabilitou
  jako sólo těžař, proto obvykle pool založí jen existující velcí
  těžaři nebo ti, kteří jsou ochotni pronajmout si významný hashrate.
  Vnprc se však domnívá, že s PPLNS ecashovými share by mohl být
  pool spuštěn jako klient většího poolu a i první těžař, který se
  připojí, by měl nižší variabilitu než při těžbě sólo. Tento prostředník
  by potom mohl vydělané ecashové share prodat a financovat tím
  kterékoliv schéma výplat těžařům, které si zvolí. Po získání
  významnějšího množství hashrate by měl i tento pool-prostředník
  dostatečnou sílu na vyjednávání s většími pooly o alternativních
  šablonách bloků, které by byly pro jeho těžaře vhodnější.

- **Offchain DLC:** vývojář conduition zaslal do emailové skupiny DLC-dev
  [příspěvek][conduition offchain] s popisem protokolu, který umožňuje
  vytvářet množství [DLC][topic dlc] offchain útratou financující transakce
  podepsané oběma stranami. Po urovnání offchain DLC (např. po získání
  všech potřebných podpisů orákulí) mohou obě strany podepsat další
  offchain platbu a přeposlat prostředky dle kontraktu. Třetí alternativní
  útrata může nato prostředky poslat do nových DLC.

  Kulpreet Singh a Philipp Hoenisch ve svých odpovědích odkázali na předchozí
  výzkum a vývoj této základní myšlenky, včetně možnosti použít jeden
  sdílený fond v offchain DLC i v LN (viz zpravodaje [č. 174][news174 dlc-ln],
  _angl._, a [č. 260][news260 dlc]). Conduition ve své [odpovědi][conduition
  offchain2] popsal rozdíly od předchozích návrhů.

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [LDK v0.1][] je milníkem této knihovny pro budování peněženek a aplikací
  s podporou LN. Mezi novinky patří „podpora pro obě strany protokolu pro
  vyjednávání otevření LSPS kanálu, […] podpora překladu čitelných jmen
  (Human Readable Names) dle [BIP353][] [a snížení] nákladů na onchain
  poplatky během vyrovnání několika HTLC při vynuceném zavření kanálu.”

## Významné změny kódu a dokumentace

_Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Bitcoin Inquisition][bitcoin inquisition repo] a [repozitáři BINANA][binana
repo]._

- [Eclair #2936][] přidává 12blokovou prodlevu, než označí kanál za zavřený po
  utracení otevíracího výstupu za účelem propagace [splicu][topic splicing]
  (viz [zpravodaj č. 214][news214 splicing], _angl._, a objasnění [motivace][tbast
  splice] od vývojáře Eclair). Utracené kanály budou
  dočasně sledovány v nově přidané mapě `spentChannels`, ze které jsou po
  12 blocích buď odstraněny nebo označeny za účastníky splicingu. Po splicu
  jsou aktualizovány krátký identifikátor (SCID) rodičovského kanálu, jeho
  kapacita a zůstatky; nový kanál se nevytváří.

- [Rust Bitcoin #3792][] přidává schopnost kódovat a dekódovat zprávy [v2 P2P
  transportního protokolu][topic v2 P2P transport] dle [BIP324][] (viz též
  [zpravodaj č. 306][news306 v2]). Přidána byla nová struktura `V2NetworkMessage`,
  která obaluje původní výčtový seznam `NetworkMessage` a poskytuje v2 kódování
  a dekódování.

- [BDK #1789][] mění výchozí verzi transakce z 1 na 2. Záměrem je zvýšení soukromí,
  neboť před touto změnou byly BDK peněženky snadněji identifikovatelné (verzi
  1 používá jen 15 % sítě). Verze 2 bude dále vyžadována v implementacích
  [BIP326][], které [taprootovým][topic taproot] transakcím přinesou obranu
  proti [fee snipingu][topic fee sniping] založenou na nSequence.

- [BIPs #1687][] začleňuje [BIP375][] specifikující používání [tichých plateb][topic
  silent payments] s [PSBT][topic psbt]. V případě více nezávislých podepisujících
  stran je vyžadován [DLEQ][topic dleq] doklad, který ostatním bez nutnosti odhalit
  jakékoliv soukromé klíče potvrdí, že jejich podpis nepovede ke zneužití prostředků
  (viz též [zpravodaj č. 335][news335 dleq] a [podcast č. 327][recap327 dleq], _angl._).

- [BIPs #1396][] odstraňuje z [payjoinové][topic payjoin] specifikace v [BIP78][]
  rozpor s [PSBT][topic psbt] specifikací v [BIP174][]. V BIP78 dříve příjemce
  po zkompletování vstupů odstranil data o UTXO, i když je odesílatel potřeboval.
  Nově budou údaje o UTXO zachovány.

{% include snippets/recap-ad.md when="2025-01-21 15:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="3792,1789,1687,1396,2936" %}
[ldk v0.1]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.1
[news174 dlc-ln]: /en/newsletters/2021/11/10/#dlcs-over-ln
[news260 dlc]: /cs/newsletters/2023/07/19/#penezenka-od-10101-testuje-sdileni-prostredku-mezi-ln-a-dlc
[ecash tides]: https://delvingbitcoin.org/t/ecash-tides-using-cashu-and-stratum-v2/870
[news304 ecashtides]: /cs/newsletters/2024/05/24/#obtize-s-odmenovanim-tezaru-v-poolech
[corallo whyecash]: https://delvingbitcoin.org/t/ecash-tides-using-cashu-and-stratum-v2/870/27
[caseria pplns]: https://delvingbitcoin.org/t/ecash-tides-using-cashu-and-stratum-v2/870/29
[recap291 tides]: /en/podcast/2024/02/29/#how-does-ocean-s-tides-payout-scheme-work-transcript
[vnprc ehash]: https://delvingbitcoin.org/t/ecash-tides-using-cashu-and-stratum-v2/870/32
[hashpool]: https://github.com/vnprc/hashpool
[conduition offchain]: https://mailmanlists.org/pipermail/dlc-dev/2025-January/000186.html
[news304 fpps proxy]: /cs/newsletters/2024/05/24/#platba-za-share-pps
[tbast splice]: https://github.com/ACINQ/eclair/pull/2936#issuecomment-2595930679
[conduition offchain2]: https://mailmanlists.org/pipermail/dlc-dev/2025-January/000189.html
[news214 splicing]: /en/newsletters/2022/08/24/#bolts-1004
[news306 v2]: /cs/newsletters/2024/06/07/#rust-bitcoin-2644
[news335 dleq]: /cs/newsletters/2025/01/03/#bips-1689
[recap327 dleq]: /en/podcast/2024/11/05/#draft-bip-for-dleq-proofs
