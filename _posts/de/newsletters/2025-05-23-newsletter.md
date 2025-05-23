---
title: 'Bitcoin Optech Newsletter #355'
permalink: /de/newsletters/2025/05/23/
name: 2025-05-23-newsletter-de
slug: 2025-05-23-newsletter-de
type: newsletter
layout: newsletter
lang: de
---
Der Newsletter dieser Woche enthält unsere regulären Abschnitte mit Beschreibungen von Änderungen an Diensten und Client-Software, Ankündigungen neuer Veröffentlichungen und Release-Kandidaten sowie Zusammenfassungen wichtiger Änderungen an beliebter Bitcoin-Infrastruktursoftware.

## Nachrichten

*In dieser Woche wurden keine bedeutenden Nachrichten in unseren [Quellen][] gefunden.*

## Änderungen an Diensten und Client-Software

*In dieser monatlichen Rubrik stellen wir interessante Aktualisierungen von Bitcoin-Wallets und -Diensten vor.*

- **Cake Wallet fügt Unterstützung für Payjoin v2 hinzu:**
  Cake Wallet [v4.28.0][cake wallet 4.28.0] fügt [die Möglichkeit][cake blog] hinzu,
  Zahlungen mit dem [Payjoin][topic payjoin] v2-Protokoll zu empfangen.

- **Sparrow fügt Pay-to-Anchor-Funktionen hinzu:**
  Sparrow [2.2.0][sparrow 2.2.0] zeigt [Pay-to-Anchor (P2A)][topic ephemeral anchors]-Outputs an und kann diese senden.

- **Safe Wallet 1.3.0 veröffentlicht:**
  [Safe Wallet][safe wallet github] ist eine Desktop-Multisig-Wallet mit Unterstützung für Hardware-Signiergeräte,
  die in Version [1.3.0][safe wallet 1.3.0] [CPFP][topic cpfp] Fee-Bumping für eingehende Transaktionen hinzugefügt hat.

- **COLDCARD Q v1.3.2 veröffentlicht:**
  Der [v1.3.2 Release][coldcard blog] von COLDCARD Q umfasst zusätzliche [Unterstützung für Multisig-Ausgaberichtlinien][coldcard ccc]
  und neue Funktionen zum [Teilen sensibler Daten][coldcard kt].

- **Transaktions-Batching mit Payjoin:**
  [Private Pond][private pond post] ist eine [experimentelle Implementierung][private pond github]
  eines [Transaktions-Batching][topic payment batching]-Dienstes, der Payjoin verwendet,
  um kleinere Transaktionen mit geringeren Gebühren zu generieren.

- **JoinMarket Fidelity Bond Simulator:**
  Der [JoinMarket Fidelity Bond Simulator][jmfbs github] bietet Werkzeuge für JoinMarket-Teilnehmer,
  um ihre Leistung im Markt auf Basis von [Fidelity Bonds][news161 fb] zu simulieren.

- **Bitcoin-Opcodes dokumentiert:**
  Die Website [Opcode Explained][opcode explained website] dokumentiert jeden Bitcoin-Script-Opcode.

- **Bitkey-Code als Open Source veröffentlicht:**
  Das Bitkey Hardware-Signiergerät [hat angekündigt][bitkey blog], dass ihr [Quellcode][bitkey github]
  für nicht-kommerzielle Nutzungen als Open Source verfügbar ist.

## Veröffentlichungen und Release-Kandidaten

_Neue Veröffentlichungen und Release-Kandidaten für beliebte Bitcoin-Infrastrukturprojekte. Bitte erwägen Sie ein Upgrade auf neue Veröffentlichungen oder helfen Sie bei der Überprüfung von Release-Kandidaten._

- [LND 0.19.0-beta][] ist die neueste Hauptversion dieses beliebten LN-Knotens.
  Sie enthält viele [Verbesserungen][lnd rn] und Fehlerbehebungen,
  einschließlich neuem [RBF][topic rbf]-basierten Fee-Bumping für kooperative Schließungen.

- [Core Lightning 25.05rc1][] ist ein Release-Kandidat für die nächste Hauptversion
  dieser beliebten LN-Knoten-Implementierung.

## Erwähnenswerte Code- und Dokumentationsänderungen

_Nennenswerte kürzliche Änderungen in [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo], [Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition repo] und [BINANAs][binana repo]._

- [Bitcoin Core #32423][] entfernt den Hinweis, dass `rpcuser/rpcpassword` als veraltet markiert ist, und ersetzt ihn durch eine Sicherheitswarnungbezüglich der Speicherung von Klartext-Anmeldedaten in der Konfigurationsdatei. Diese Option wurde ursprünglich als veraltet markiert, als `rpcauth`
  in [Bitcoin Core #7044][] eingeführt wurde, welches mehrere RPC-Benutzer unterstützt und
  seinen Cookie hasht. Der PR fügt außerdem ein zufälliges 16-Byte-Salt zu Anmeldedaten aus
  beiden Methoden hinzu und hasht diese, bevor sie im Speicher gespeichert werden.

- [Bitcoin Core #31444][] erweitert die `TxGraph`-Klasse (siehe Newsletter [#348][news348 txgraph])
  um drei neue Hilfsfunktionen: `GetMainStagingDiagrams()` gibt die Abweichungen von Clustern
  zwischen den Haupt- und Staging-Feerate-Diagrammen zurück, `GetBlockBuilder()` iteriert durch
  Graph-Chunks (nach Feerate sortierte Teilcluster-Gruppierungen) von höchster bis niedrigster
  Feerate für optimierte Blockerstellung, und `GetWorstMainChunk()` identifiziert den Chunk mit
  der niedrigsten Feerate für Entscheidungen zur Räumung. Dieser PR ist einer der letzten Bausteine
  der vollständigen ersten Implementierung des [Cluster-Mempool][topic cluster mempool]-Projekts.

- [Core Lightning #8140][] aktiviert standardmäßig die [Peer-Speicherung][topic peer storage] von Kanal-Sicherungen (siehe Newsletter [#238][news238 storage]) und macht sie für große Knoten praktikabel, indem die Speicherung auf Peers mit aktuellen oder früheren Kanälen begrenzt wird, Daten im Speicher zwischengespeichert werden anstatt wiederholte `listdatastore`/`listpeerchannels`-Aufrufe zu tätigen, gleichzeitige Uploads auf zwei Peers begrenzt werden, Daten größer als 65 kB übersprungen werden und beim Senden eine zufällige Auswahl der Peers getroffen wird.

- [Core Lightning #8136][] aktualisiert den Austausch von Ankündigungssignaturen so, dass
  er stattfindet, wenn der Kanal bereit ist, anstatt nach sechs Blöcken, um mit der kürzlichen
  [BOLTs #1215][] Spezifikationsaktualisierung übereinzustimmen. Es ist immer noch erforderlich,
  sechs Blöcke zu warten, um den [Kanal anzukündigen][topic channel announcements].

- [Core Lightning #8266][] fügt einen `update`-Befehl zum Reckless-Plugin-Manager hinzu
  (siehe Newsletter [#226][news226 reckless]), der ein bestimmtes Plugin oder alle installierten
  Plugins aktualisiert, wenn keines angegeben ist, außer solche, die von einem festen Git-Tag
  oder -Commit installiert wurden. Dieser PR erweitert auch den `install`-Befehl, um einen
  Quellpfad oder eine URL zusätzlich zu einem Plugin-Namen zu akzeptieren.

- [Core Lightning #8021][] finalisiert die [Splicing][topic splicing]-Interoperabilität mit
  Eclair (siehe Newsletter [#331][news331 interop]), indem die Rotation der Remote-Funding-Keys
  korrigiert wird, `splice_locked` bei der Kanal-Wiederherstellung erneut gesendet wird, um Fälle
  abzudecken, in denen es ursprünglich verpasst wurde (siehe Newsletter [#345][news345 splicing]),
  die Anforderung gelockert wird, dass commitment-signed-Nachrichten in einer bestimmten Reihenfolge
  ankommen müssen, das Empfangen und Initiieren von Splice-[RBF][topic rbf]-Transaktionen
  ermöglicht wird, ausgehende [PSBTs][topic psbt] bei Bedarf automatisch in Version 2
  konvertiert werden und andere Refactoring-Änderungen vorgenommen werden.

- [Core Lightning #8226][] implementiert [BIP137][] durch Hinzufügen eines neuen
  `signmessagewithkey`-RPC-Befehls, der es Benutzern ermöglicht, Nachrichten mit einem
  beliebigen Schlüssel aus der Wallet zu signieren, indem eine Bitcoin-Adresse angegeben wird.
  Früher erforderte das Signieren einer Nachricht mit einem Core Lightning-Schlüssel,
  den xpriv und den Schlüsselindex zu finden, den privaten Schlüssel mit einer externen
  Bibliothek abzuleiten und dann die Nachricht mit Bitcoin Core zu signieren.

- [LND #9801][] fügt eine neue Option `--no-disconnect-on-pong-failure` hinzu, die steuert,
  ob ein Peer getrennt wird, wenn eine Pong-Antwort verspätet oder nicht übereinstimmend ist.
  Diese Option ist standardmäßig auf false gesetzt, wodurch das aktuelle Verhalten von LND
  beibehalten wird, sich bei einem Pong-Nachrichtenfehler von einem Peer zu trennen
  (siehe Newsletter [#275][news275 ping]); andernfalls würde LND das Ereignis nur protokollieren.
  Der PR refaktoriert den Ping-Watchdog, um seine Schleife fortzusetzen, wenn die Trennung
  unterdrückt wird.

{% include snippets/recap-ad.md when="2025-05-27 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="32423,31444,8140,8136,8266,8021,8226,9801,7044,1215" %}
[lnd 0.19.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.19.0-beta
[Quellen]: /en/internal/sources/
[lnd rn]: https://github.com/lightningnetwork/lnd/blob/master/docs/release-notes/release-notes-0.19.0.md
[Core Lightning 25.05rc1]: https://github.com/ElementsProject/lightning/releases/tag/v25.05rc1
[news348 txgraph]: /de/newsletters/2025/04/04/#bitcoin-core-31363)
[news238 storage]: /en/newsletters/2023/02/15/#core-lightning-5361
[news226 reckless]: /en/newsletters/2022/11/16/#core-lightning-5647
[news331 interop]: /en/newsletters/2024/11/29/#core-lightning-7719
[news345 splicing]: /de/newsletters/2025/03/14/#eclair-3007
[news275 ping]: /en/newsletters/2023/11/01/#lnd-7828
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
