---
title: 'Zpravodaj „Bitcoin Optech” č. 355'
permalink: /cs/newsletters/2025/05/23/
name: 2025-05-23-newsletter-cs
slug: 2025-05-23-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Zpravodaj tento týden přináší pravidelné rubriky s popisem nedávných změn
ve službách a klientech, oznámeními nových vydání a souhrnem nedávaných
změn v populárním bitcoinovém páteřním software.

## Novinky

*V našich [zdrojích][sources] jsme tento týden nenašli žádné významné novinky.*

## Změny ve službách a klientech

*V této měsíční rubrice upozorňujeme na zajímavé aktualizace bitcoinových
peněženek a služeb.*

- **Cake Wallet podporuje payjoin v2:**
  Cake Wallet [v4.28.0][cake wallet 4.28.0] přidává [schopnost][cake blog]
  přijímat platby pomocí protokolu [payjoin][topic payjoin] v2.

- **Sparrow přidává podporu pro pay-to-anchor:**
  Sparrow [2.2.0][sparrow 2.2.0] zobrazuje a umí odesílat [pay-to-anchor
  (P2A)][topic ephemeral anchors] výstupy.

- **Vydána Safe Wallet 1.3.0:**
  [Safe Wallet][safe wallet github] je desktopová multisig peněženka s podporou
  hardwarových podpisových zařízení, která ve verzi [1.3.0][safe wallet 1.3.0]
  přidává [CPFP][topic cpfp] navyšování poplatků příchozím transakcím.

- **Vydána COLDCARD Q v1.3.2:**
  [Vydání 1.3.2][coldcard blog] COLDCARD Q přidává další pravidla pro [multisig
  utrácení][coldcard ccc] a nové možnosti [sdílení citlivých dat][coldcard kt].

- **Dávkování transakcí pomocí payjoinu:**
  [Private Pond][private pond post] je [experimentální implementace][private
  pond github] služby [dávkování transakcí][topic payment batching], která
  používá payjoin ke generování menších transakcí platících nižší poplatky.

- **JoinMarket Fidelity Bond Simulator:**
  [JoinMarket Fidelity Bond Simulator][jmfbs github] poskytuje účastníkům JoinMarketu
  nástroje pro simulaci úspěšnosti na trhu založeném na [finančních závazcích][news161 fb].

- **Dokumentace bitcoinových opkódů:**
  Webová stránka [Opcode Explained][opcode explained website] poskytuje dokumentaci
  každého opkódu v bitcoinovém skriptu.

- **Kód Bitkey zpřístupněn jako open-source:**
  Hardwarové podpisové zařízení Bitkey [ohlásilo][bitkey blog] dostupnost [zdrojového
  kódu][bitkey github] jako open source pro nekomerční účely.

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [LND 0.19.0-beta][] je novým hlavním vydáním tohoto oblíbeného LN uzlu.
  Obsahuje mnoho [vylepšení][lnd rn] a oprav  chyb, včetně nového systému
  RBF navyšování poplatků během kooperativního zavření kanálu.

- [Core Lightning 25.05rc1][] je kandidátem na vydání příští hlavní verze této
  oblíbené implementace LN uzlu.

## Významné změny kódu a dokumentace

_Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo] a [repozitáři BINANA][binana repo]._

- [Bitcoin Core #32423][] odstraňuje poznámku o zastarání `rpcuser/rpcpassword`
  a nahrazuje ji bezpečnostním varováním o ukládání hesel v konfiguračním
  souboru v čitelné podobě. Tato volba byla původně odsouzena k odstranění,
  když byl v [Bitcoin Core #7044][] představen `rpcauth`, který podporuje
  několik uživatelů RPC a hašuje cookie. PR dále přidává k heslům 16bajtovou
  náhodnou sůl a před uložením do paměti je hašuje.

- [Bitcoin Core #31444][] přidává do třídy `TxGraph` (viz [zpravodaj č. 348][news348
  txgraph]) tři pomocné funkce: `GetMainStagingDiagrams()` vrací rozdíly v clusterech
  mezi hlavním a přípravným diagramem poplatků, `GetBlockBuilder()` prochází
  grafem chunků (podskupiny transakcí seřazených dle poplatku) od nejvyššího poplatku
  po nejnižší a `GetWorstMainChunk()` vrací chunk s nejnižším jednotkovým
  poplatkem určený k vyloučení. Toto PR je jedním z posledních kroků před
  kompletní implementací [mempoolu clusterů][topic cluster mempool].

- [Core Lightning #8140][] aktivuje ve výchozím nastavení [peer storage][topic peer storage]
  pro zálohy kanálů (viz [zpravodaj č. 238][news238 storage]). PR činí tuto možnost
  použitelnou i pro velké uzly, neboť omezuje množství ukládaných dat, kešuje
  zálohy a seznamy spojení v paměti namísto opakovaných volání `listdatastore`/`listpeerchannels`,
  omezuje současné nahrávání záloh na dvě spojení, přeskakuje zálohy větší než 65 kB
  a nahodile vybírá spojení pro posílání.

- [Core Lightning #8136][] upravuje čas výměny podpisů pro oznámení kanálu. Dříve
  s výměnou čekal na šest potvrzení, nově se budou podpisy v souladu s nedávnou
  změnou specifikace v [BOLTs #1215][] vyměňovat, jakmile je kanál připraven.
  Na zveřejnění [oznámení kanálu][topic channel announcements] se i nadále musí
  čekat šest bloků.

- [Core Lightning #8266][] přidává nový příkaz `update` do manažeru pluginů Reckless
  (viz [zpravodaj č. 226][news226 reckless], _angl._). Příkaz aktualizuje pluginy
  (jeden konkrétní nebo všechny) kromě těch nainstalovaných z daného tagu nebo commitu.
  PR dále rozšiřuje příkaz `install` o možnost kromě názvu pluginu předat i URL nebo cestu
  ke zdrojovým kódům.

- [Core Lightning #8021][] dokončuje interoperabilitu [splicingu][topic splicing] s Eclairem
  (viz [zpravodaj č. 331][news331 interop]). Mimo jiné opravuje rotaci vzdálených klíčů a opakované
  zaslání zprávy `splice_locked` při opakovaném navázání kanálu v případech, kdy se původní
  zpráva ztratí (viz [zpravodaj č. 345][news345 splicing]), uvolňuje požadavky na
  pořadí obdržených zpráv, umožňuje přijímat a iniciovat splicingové transakce
  s [RBF][topic rbf] a automaticky převádí odchozí [PSBT][topic psbt] na verzi 2.

- [Core Lightning #8226][] implementuje [BIP137][]. Přidává nový RPC příkaz
  `signmessagewithkey`, který uživatelům umožňuje podepsat zprávy jakýmkoliv klíčem
  z peněženky poskytnutím bitcoinové adresy. Dříve podepsání zprávy s Core Lightning
  vyžadovalo nalézt xpriv a index klíče, odvodit soukromý klíč pomocí externí knihovny
  a poté podepsat s Bitcoin Core.

- [LND #9801][] přidává novou volbu `--no-disconnect-on-pong-failure`, která nastavuje,
  zda uzel v případě pozdního nebo nesprávného pongu spojení odpojí. Tato volba je
  ve výchozím stavu nastavena na false, čímž zachovává současné chování (tedy že spojení
  budou odpojena, viz [zpravodaj č. 275][news275 ping]). V opačném případě LND
  událost pouze zaloguje.

{% include snippets/recap-ad.md when="2025-05-27 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="32423,31444,8140,8136,8266,8021,8226,9801,7044,1215" %}
[lnd 0.19.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.19.0-beta
[sources]: /en/internal/sources/
[lnd rn]: https://github.com/lightningnetwork/lnd/blob/master/docs/release-notes/release-notes-0.19.0.md
[Core Lightning 25.05rc1]: https://github.com/ElementsProject/lightning/releases/tag/v25.05rc1
[news348 txgraph]: /cs/newsletters/2025/04/04/#bitcoin-core-31363
[news238 storage]: /cs/newsletters/2023/02/15/#core-lightning-5361
[news226 reckless]: /en/newsletters/2022/11/16/#core-lightning-5647
[news331 interop]: /cs/newsletters/2024/11/29/#core-lightning-7719
[news345 splicing]: /cs/newsletters/2025/03/14/#eclair-3007
[news275 ping]: /cs/newsletters/2023/11/01/#lnd-7828
[cake wallet 4.28.0]: https://github.com/cake-tech/cake_wallet/releases/tag/v4.28.0
[cake blog]: https://blog.cakewallet.com/bitcoin-privacy-takes-a-leap-forward-cake-wallet-introduces-payjoin-v2/
[sparrow 2.2.0]: https://github.com/sparrowwallet/sparrow/releases/tag/2.2.0
[safe wallet github]: https://github.com/andreasgriffin/bitcoin-safe
[safe wallet 1.3.0]: https://github.com/andreasgriffin/bitcoin-safe/releases/tag/1.3.0
[coldcard blog]: https://blog.coinkite.com/ccc-and-keyteleport/
[coldcard ccc]: https://coldcard.com/docs/coldcard-cosigning/
[coldcard kt]: https://github.com/Coldcard/firmware/blob/master/docs/key-teleport.md
[private pond post]: https://njump.me/naddr1qvzqqqr4gupzqg42s9gsae3lu2cketskuzfp778fh2vg9c5x3elx8ttdpzhfkk25qq2nv5nzddgxxdjtd4u9vwrdv939vmnswfzk6j85dxk
[private pond github]: https://github.com/Kukks/PrivatePond
[jmfbs github]: https://github.com/m0wer/joinmarket-fidelity-bond-simulator
[news161 fb]: /en/newsletters/2021/08/11/#implementation-of-fidelity-bonds
[opcode explained website]: https://opcodeexplained.com/
[bitkey blog]: https://x.com/BEN0WHERE/status/1918073429791785086
[bitkey github]: https://github.com/proto-at-block/bitkey
