---
title: 'Zpravodaj „Bitcoin Optech” č. 389'
permalink: /cs/newsletters/2026/01/23/
name: 2026-01-23-newsletter-cs
slug: 2026-01-23-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Zpravodaj tento týden odkazuje na studii o sítích platebních kanálů. Též obsahuje naše
pravidelné rubriky s popisem nedávných změn ve službách a klientském software, oznámeními
nových vydání a souhrnem významných změn v populárním bitcoinovém páteřním software.

## Novinky

- **Matematická teorie sítí platebních kanálů**: René Pickhardt zaslal do fóra Delving
  Bitcoin [příspěvek][channels post] o zveřejnění svého nového [článku][channels paper] nazvaného
  „Matematická teorie sítě platebních kanálů“ (A Mathematical Theory of Payment Channel Network).
  V článku Pickhardt sdružuje několik pozorování, která posbíral během let zkoumání, do jediného
  geometrického rámce. Konkrétně si jeho studie klade za cíl analyzovat běžné jevy, jako jsou
  vyčerpání kanálu (viz [zpravodaj č. 333][news333 depletion]) či neefektivní využití kapitálu
  v kanálech s dvěma účastníky. Vyhodnocuje, proč se dějí a jak jsou spolu provázané.

  Mezi hlavní přínosy článku patří:

  -  Model pro možná rozdělení bohatství uživatelů v lightningové síti pro daný graf kanálů.

  - Vzorec pro odhad horní meze platební šířky pásma pro platby.

  - Metoda pro odhad pravděpodobnosti, že je platba uskutečnitelná (viz
      [zpravodaj č. 309][news309 feasibility]).

  - Analýza rozličných
      [strategií][mitigation post] pro zabránění vyčerpání kanálu.

  - Závěr, že kanály se dvěma účastníky kladou silné překážky pohybu likvidity mezi účastníky sítě.

  Dle Pickhardta stály poznatky ze zkoumání za jeho nedávným příspěvkem o používání Arku jako
  továrny kanálů (viz [zpravodaj č. 387][new387 ark]). Pickhardt též poskytl [sadu][pickhardt gh]
  poznámek, notebooků, kódu a článků, na kterých svůj výzkum stavěl.

  Závěrem Pickhardt otevřel diskusi o své práci a vyzval vývojářskou komunitu LN k dotazům
  a zpětné vazbě ohledně toho, jak by jeho výzkum mohl ovlivnit návrh protokolu a
  jak nejlépe využít kanály s více účastníky.

## Změny ve službách a klientech

*V této měsíční rubrice upozorňujeme na zajímavé aktualizace bitcoinových
peněženek a služeb.*

- **Experimentální Electrum server pro testování tichých plateb:**
  [Frigate Electrum Server][frigate gh] implementuje službu [vzdáleného skenování][bip352
  remote scanner] (remote scanning) [tichých plateb][topic silent payments]
  z [BIP352][], kterou mohou klientské aplikace používat. Ověřovací prototyp používá
  pro urychlení skenování moderní výpočetní operace na GPU. To umožní provozovat
  instance pro mnoho uživatelů a vyřizovat současně mnoho požadavků na skenování.

- **BDK WASM knihovna:**
  Knihovna [bdk-wasm][bdk-wasm gh], kterou původně vyvinula a [používala][metamask
  blog] organizace MetaMask, poskytuje přístup k funkcím BDK v prostředích, která
  podporují WebAssembly (WASM).

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [Core Lightning 25.12.1][] je údržbovým vydáním, které opravuje vážnou chybu,
  kvůli které nemohly uzly vytvořené ve verzi 25.12 utratit prostředky zaslané
  na ne-[P2TR][topic taproot] adresy (viz níže). Dále opravuje problémy s
  kompatibilitou v obnovování záloh a `hsmtool` s novým formátem `hsm_secret`
  založeným na mnemonické frázi představeným ve verzi 25.12 (viz
  [zpravodaj č. 388][news388 cln]).

- [LND 0.20.1-beta.rc1][] je kandidátem na menší vydání, které přidává zotavení
  po panice během zpracování gossip zpráv, zlepšuje ochranu před reorganizacemi
  řetězce, implementuje heuristiku detekce LSP a opravuje několik chyb
  a souběhů. Podrobnosti lze nalézt v [poznámkách k vydání][release notes].

## Významné změny kódu a dokumentace

_Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo] a [repozitáři BINANA][binana repo]._

- [Bitcoin Core #32471][] opravuje chybu způsobující, že volání RPC příkazu
  `listdescriptors` s parametrem `private=true` (viz zpravodaje [č. 134][news134
  descriptor] a [č. 162][news162 descriptor], oba _angl._) selhalo, pokud
  některý z [deskriptorů][topic descriptors] neměl soukromý klíč. Chyba postihovala
  peněženky obsahující watch-only i ne-watch-only deskriptory, stejně jako
  multisig deskriptory bez všech soukromých klíčů. Toto PR zajišťuje,
  že RPC správně vrací dostupné soukromé klíče a umožňuje tak uživatelům
  pořídit řádné zálohy. Volání `listdescriptors private=true` na čistě watch-only
  peněženkách i nadále selhává.

- [Bitcoin Core #34146][] posílá první sebeoznámení uzlu ve vlastní P2P zprávě, čímž
  vylepšuje propagaci adresy. Dříve byla tato oznámení posílána ve skupině
  dalších adres v odpovědi na požadavek `getaddr`. To mohlo způsobit zahození
  adresy nebo její nahrazení jinou adresou.

- [Core Lightning #8831][] opravuje vážnou chybu, kvůli které nemohly uzly
  vytvořené ve verzi 25.12 utratit prostředky zaslané na ne-[P2TR][topic taproot]
  adresy. I když byly všechny druhy adres odvozené dle [BIP86][], kód podepisování
  používal [BIP86][] pouze pro P2TR adresy. Toto PR zajišťuje, že podepisování
  používá [BIP86][] derivace pro všechny typy adres.

- [LDK #4261][] přidává podporu pro smíšený [splicing][topic splicing], který
  umožňuje v jedné transakci provést zároveň splice-in i splice-out.
  Stejně jako v prostém splice-inu, i zde platí poplatek vstup pocházející
  z otevírací transakce. Celková suma může být negativní, pokud odcházející
  hodnota převyšuje přicházející.

- [LDK #4152][] přidává podporu pro falešné skoky v [zaslepené][topic rv routing]
  platební cestě. Již dříve byla podobná funkce přidána pro zaslepené
  cesty pro posílání zpráv (viz [zpravodaj č. 370][news370 dummy], _angl._).
  Přidání skoků výrazně ztěžuje odhadování vzdálenosti k cíli nebo identity
  příjemce. [Zpravodaj č. 381][news381 dummy] (_angl._) popisuje další související
  změny.

- [LND #10488][] opravuje chybu, kvůli které byly kanály otevřené s volbou
  `fundMax` (viz [zpravodaj č. 246][news246 fundmax]) omezené na velikosti
  uživatelským nastavením `maxChanSize` (viz [zpravodaj č. 116][news116 maxchan], _angl._).
  Toto nastavení bylo zamýšleno pouze pro omezení počtu přicházejících žádostí
  o kanál. Tato změna zajišťuje, že volba `fundMax` bude používat maximální velikost
  kanálu dle protokolu v závislosti na tom, zda strany podporují [velké kanály][topic
  large channels].

- [LND #10331][] se lépe vyrovnává s reorganizacemi řetězce během zavírání kanálu.
  Nově vyžaduje počet potvrzení od jednoho do šesti v závislosti na velikosti kanálu.
  Démon sledující blockchain obdržel nový stavový automat, který lépe detekuje
  reorganizace a sleduje soupeřící zavírací transakce. PR dále přidává monitorování
  záporných potvrzení (v případě, že potvrzená transakce kvůli reorganizaci
  potvrzení ztratí), avšak zatím není vyřešeno, jak s nimi bude nakládat.
  Změna řeší [nejstarší otevřený tiket][lnd issue] LND z roku 2016.

- [Rust Bitcoin #5402][] přidává validaci během dekódování, aby vyloučila transakce
  s duplikovanými vstupy (problém souvisí s [CVE-2018-17144][topic cve-2018-17144]).
  Transakce, které obsahují více vstupů utrácejících stejný výstup, jsou dle konsenzu
  nevalidní.

- [BIPs #1820][] mění stav [BIP3][] na `Deployed`, čímž nahrazuje [BIP2][] jako
  soubor směrnic pro přijímání BIPů (návrhů na vylepšení bitcoinu). [Zpravodaj
  č. 388][news388 bip3] obsahuje další podrobnosti.

- [BOLTs #1306][] upřesňuje ve specifikaci [BOLT12][], že [nabídky][topic offers]
  s prázdným polem `offer_chains` musí být odmítnuty. Pro nabídku, ve které je toto
  pole přítomné, ale neobsahuje žádný haš řetězce, nelze vytvořit fakturu, jelikož
  plátce nemůže uspokojit požadavek na nastavení `invreq_chain` na jeden z hašů
  z `offer_chains`.

- [BLIPs #59][] přidává do [BLIP51][], známého též jako LSPS1, podporu pro
  [BOLT12 nabídky][topic offers] jako jednu z možností pro placení poskytovatelům
  lightningových služeb (LSP). Stávajícími možnostmi jsou [BOLT11][] a onchain platby.
  Toto bylo již dříve implementováno v LDK (viz [zpravodaj č. 347][news347 lsp]).

{% include snippets/recap-ad.md when="2026-01-27 17:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="32471,34146,8831,4261,4152,10488,10331,5402,1820,1306,59" %}

[channels post]: https://delvingbitcoin.org/t/a-mathematical-theory-of-payment-channel-networks/2204
[channels paper]: https://arxiv.org/pdf/2601.04835
[news309 feasibility]: /cs/newsletters/2024/06/28/#odhad-pravdepodobnosti-uspesneho-provedeni-ln-platby
[mitigation post]: https://delvingbitcoin.org/t/mitigating-channel-depletion-in-the-lightning-network-a-survey-of-potential-solutions/1640/1
[news333 depletion]: /cs/newsletters/2024/12/13/#zjisteni-o-vycerpani-kanalu
[new387 ark]: /cs/newsletters/2026/01/09/#ark-jako-tovarna-kanalu
[pickhardt gh]: https://github.com/renepickhardt/Lightning-Network-Limitations
[frigate gh]: https://github.com/sparrowwallet/frigate
[bip352 remote scanner]: https://github.com/silent-payments/BIP0352-index-server-specification/blob/main/README.md#remote-scanner-ephemeral
[bdk-wasm gh]: https://github.com/bitcoindevkit/bdk-wasm
[metamask blog]: https://metamask.io/news/bitcoin-on-metamask-btc-wallet
[Core Lightning 25.12.1]: https://github.com/ElementsProject/lightning/releases/tag/v25.12.1
[LND 0.20.1-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.20.1-beta.rc1
[news388 cln]: /cs/newsletters/2026/01/16/#core-lightning-8830
[release notes]: https://github.com/lightningnetwork/lnd/blob/v0.20.x-branch/docs/release-notes/release-notes-0.20.1.md
[news134 descriptor]: /en/newsletters/2021/02/03/#bitcoin-core-20226
[news162 descriptor]: /en/newsletters/2021/08/18/#bitcoin-core-21500
[news370 dummy]: /en/newsletters/2025/09/05/#ldk-3726
[news381 dummy]: /en/newsletters/2025/11/21/#ldk-4126
[news246 fundmax]: /cs/newsletters/2023/04/26/#lnd-6903
[news116 maxchan]: /en/newsletters/2020/09/23/#lnd-4567
[lnd issue]: https://github.com/lightningnetwork/lnd/issues/53
[news388 bip3]: /cs/newsletters/2026/01/16/#aktualizace-procesu-prijimani-bipu
[news347 lsp]: /cs/newsletters/2025/03/28/#ldk-3649
