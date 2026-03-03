---
title: 'Bitcoin Optech Newsletter #350'
permalink: /de/newsletters/2025/04/18/
name: 2025-04-18-newsletter-de
slug: 2025-04-18-newsletter-de
type: newsletter
layout: newsletter
lang: de
---
Der Newsletter dieser Woche enthält unsere regulären Abschnitte mit Beschreibungen aktueller Änderungen an Diensten und Client-Software, Ankündigungen neuer Releases und Release-Kandidaten sowie Zusammenfassungen wichtiger Änderungen an beliebter Bitcoin-Infrastruktur-Software. Außerdem gibt es eine Korrektur zu einigen Details aus unserem Bericht der letzten Woche über SwiftSync.

## Nachrichten

*In dieser Woche wurden in unseren [Quellen][] keine bedeutenden Nachrichten gefunden.*

## Änderungen an Diensten und Client-Software

*In dieser monatlichen Rubrik stellen wir interessante Aktualisierungen von Bitcoin-Wallets und -Diensten vor.*

- **Bitcoin Knots Version 28.1.knots20250305 veröffentlicht:**
  Dieser [Release][knots 28.1] von Bitcoin Knots unterstützt das [Signieren von Nachrichten][topic generic signmessage] für Segwit- oder Taproot-Adressen sowie die Verifizierung von [BIP137][], [BIP322][] und Electrum-signierten Nachrichten, neben weiteren Änderungen.

- **PSBTv2 Explorer angekündigt:**
  Der [Bitcoin PSBTv2 Explorer][bip370 website] ermöglicht die Inspektion von [PSBTs][topic psbt], die im Version-2-Datenformat kodiert sind.

- **LNbits v1.0.0 veröffentlicht:**
  Die [LNbits][lnbits github] Software bietet Buchhaltung und zusätzliche Funktionen auf Basis verschiedener Lightning Network Wallets.

- **The Mempool Open Source Project® v3.2.0 veröffentlicht:**
  Der [v3.2.0 Release][mempool 3.2.0] fügt Unterstützung für [v3-Transaktionen][topic v3 transaction relay], Anchor Outputs, das Broadcasting von [1P1C-Paketen][topic package relay], die Visualisierung von Stratum-Miningpool-Jobs und weitere Funktionen hinzu.

- **Coinbase MPC-Bibliothek veröffentlicht:**
  Das [Coinbase MPC][coinbase mpc blog] Projekt ist eine [C++-Bibliothek][coinbase mpc github] zur Sicherung von Schlüsseln für Multi-Party-Computing (MPC)-Schemata, einschließlich einer eigenen secp256k1-Implementierung.

- **Lightning Network Liquiditäts-Tool veröffentlicht:**
  [Hydrus][hydrus github] nutzt den Zustand des LN-Netzwerks, einschließlich vergangener Performance, um Lightning-Kanäle für LND automatisch zu öffnen und zu schließen. Es unterstützt auch [Batching][topic payment batching].

- **Versioned Storage Service angekündigt:**
  Das [Versioned Storage Service (VSS) Framework][vss blog] ist eine Open-Source-Cloudspeicherlösung für Lightning- und Bitcoin-Wallet-State-Daten mit Fokus auf non-custodial Wallets.

- **Fuzz-Testing-Tool für Bitcoin-Knoten:**
  [Fuzzamoto][fuzzamoto github] ist ein Framework, um mit Fuzz-Testing Fehler in verschiedenen Bitcoin-Protokollimplementierungen über externe Schnittstellen wie P2P und RPC zu finden.

- **Bitcoin Control Board Komponenten Open Source:**
  Braiins [kündigte][braiins tweet] die Open-Source-Verfügbarkeit einiger Hardware- und Software-Komponenten ihres BCB100-Mining-Control-Boards an.

## Veröffentlichungen und Release-Kandidaten

_Neue Veröffentlichungen und Release-Kandidaten für beliebte Bitcoin-Infrastrukturprojekte. Bitte erwägen Sie ein Upgrade auf neue Versionen oder helfen Sie bei der Testung von Release-Kandidaten._

- [Bitcoin Core 29.0][] ist die neueste Hauptversion des vorherrschenden Full Nodes im Netzwerk. Die [Release Notes][bcc rn] beschreiben mehrere bedeutende Verbesserungen: Ersatz der standardmäßig deaktivierten UPnP-Funktion (die in der Vergangenheit für einige Sicherheitslücken verantwortlich war) durch eine NAT-PMP-Option (ebenfalls standardmäßig deaktiviert), verbessertes Abrufen von Elternteilen verwaister Transaktionen zur Erhöhung der Zuverlässigkeit des aktuellen [Package Relay][topic package relay] in Bitcoin Core, etwas mehr Platz in Standard-Blockvorlagen (was potenziell die Miner-Einnahmen verbessert), Verbesserungen zur Vermeidung versehentlicher [Timewarps][topic time warp] für Miner, die andernfalls Einnahmeverluste riskieren könnten, falls Timewarps in einem [zukünftigen Soft Fork][topic consensus cleanup] verboten werden, und eine Migration des Build-Systems von autotools zu cmake.

- [LND 0.19.0-beta.rc2][] ist ein Release-Kandidat für diesen beliebten LN-Knoten. Eine der wichtigsten Verbesserungen, die wahrscheinlich getestet werden sollte, ist das neue RBF-basierte Fee-Bumping für kooperative Schließungen.

## Wichtige Code- und Dokumentationsänderungen

_Nennenswerte kürzliche Änderungen in [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo], [Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition repo] und [BINANAs][binana repo]._

- [LDK #3593][] ermöglicht es Nutzern, einen [BOLT12][topic offers] Zahlungsnachweis zu liefern, indem die BOLT12-Rechnung im `PaymentSent`-Event nach Abschluss einer Zahlung enthalten ist. Dies wird durch das Hinzufügen des Feldes `bolt12` zum Enum `PendingOutboundPayment::Retryable` erreicht, das dann an das `PaymentSent`-Event angehängt werden kann.

- [BOLTs #1242][] macht das [Payment Secret][topic payment secrets] für [BOLT11][]-Rechnungszahlungen verpflichtend, indem von Lesern (Zahlern) verlangt wird, eine Zahlung zu verweigern, wenn das Feld `s` (Payment Secret) fehlt. Zuvor war es nur für Schreiber (Empfänger) verpflichtend, und Leser konnten `s`-Felder mit falscher Länge ignorieren (siehe Newsletter [#163][news163 secret]). Dieser PR aktualisiert auch das Payment Secret Feature auf den Status `ASSUMED` in [BOLT9][].

## Korrektur

Der Bericht der letzten Woche über [SwiftSync][news349 ss] enthielt mehrere Fehler und verwirrende Aussagen.

- *Kein kryptografischer Akkumulator verwendet:* Wir beschrieben SwiftSync als Verwendung eines kryptografischen Akkumulators, was nicht korrekt ist. Ein kryptografischer Akkumulator würde es ermöglichen zu testen, ob ein bestimmter Transaktionsoutput (TXO) Teil einer Menge ist. SwiftSync benötigt das nicht. Stattdessen wird ein Wert, der einen TXO repräsentiert, beim Erstellen zum Aggregat addiert und beim Ausgeben (Verbrauchen) subtrahiert. Nach Durchführung dieses Vorgangs für alle TXOs, die vor dem SwiftSync-Endblock ausgegeben werden sollten, prüft der Knoten, ob das Aggregat null ist – was bedeutet, dass alle erstellten TXOs später ausgegeben wurden.

- *Parallele Blockvalidierung erfordert kein assumevalid:* Wir beschrieben einen Weg, wie parallele Validierung mit SwiftSync funktionieren könnte, bei dem Skripte bis zum Endblock von SwiftSync nicht validiert werden – ähnlich wie Bitcoin Core heute während des Initial Syncs mit _assumevalid_. Allerdings könnten frühere Skripte mit SwiftSync validiert werden, was wahrscheinlich Änderungen am Bitcoin-P2P-Protokoll erfordern würde, um optional zusätzliche Daten mit Blöcken zu übertragen. Bitcoin Core Knoten speichern diese Daten bereits für jeden Block, den sie ebenfalls speichern, daher glauben wir nicht, dass das Hinzufügen einer P2P-Nachrichtenerweiterung schwierig wäre, falls erwartet wird, dass viele Leute SwiftSync mit deaktiviertem assumevalid nutzen wollen.

- *Parallele Blockvalidierung aus anderen Gründen als bei Utreexo:* Wir schrieben, dass SwiftSync Blöcke aus ähnlichen Gründen wie [Utreexo][topic utreexo] parallel validieren kann, aber beide gehen unterschiedlich vor. Utreexo validiert einen Block (oder eine Serie von Blöcken zur Effizienzsteigerung), indem es mit einem Commitment zum UTXO-Set beginnt, alle Änderungen am UTXO-Set durchführt und ein Commitment zum neuen UTXO-Set erzeugt. Dadurch kann die Validierungsarbeit nach CPU-Threads aufgeteilt werden; z.B. validiert ein Thread die ersten tausend Blöcke und ein anderer Thread die zweiten tausend Blöcke. Am Ende der Validierung prüft der Knoten, ob das Commitment am Ende der ersten tausend Blöcke mit dem Commitment übereinstimmt, mit dem er für die zweiten tausend Blöcke gestartet ist.

  SwiftSync verwendet einen Aggregatzustand, der Subtraktion vor Addition erlaubt. Angenommen, ein TXO wird in Block 1 erstellt und in Block 2 ausgegeben. Wenn wir Block 2 zuerst verarbeiten, subtrahieren wir die Darstellung des TXO vom Aggregat. Wenn wir später Block 1 verarbeiten, addieren wir die Darstellung des TXO zum Aggregat. Der Nettoeffekt ist null, was am Ende der SwiftSync-Validierung überprüft wird.

Wir entschuldigen uns bei unseren Lesern für unsere Fehler und danken Ruben Somsen für den Hinweis darauf.

{% include snippets/recap-ad.md when="2025-04-22 15:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="3593,1242" %}
[bitcoin core 29.0]: https://bitcoincore.org/bin/bitcoin-core-29.0/
[bcc29 testing guide]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/29.0-Release-Candidate-Testing-Guide
[lnd 0.19.0-beta.rc2]: https://github.com/lightningnetwork/lnd/releases/tag/v0.19.0-beta.rc2
[Quellen]: /en/internal/sources/
[news349 ss]: /de/newsletters/2025/04/11/#swiftsync-beschleunigung-fur-initial-block-download
[bcc rn]: https://bitcoincore.org/en/releases/29.0/
[knots 28.1]: https://github.com/bitcoinknots/bitcoin/releases/tag/v28.1.knots20250305
[bip370 website]: https://bip370.org/
[lnbits github]: https://github.com/lnbits/lnbits
[mempool 3.2.0]: https://github.com/mempool/mempool/releases/tag/v3.2.0
[coinbase mpc blog]: https://www.coinbase.com/blog/innovation-matters-coinbase-breaks-new-ground-with-mpc-security-technology
[coinbase mpc github]: https://github.com/coinbase/cb-mpc
[hydrus github]: https://github.com/aftermath2/hydrus
[vss blog]: https://lightningdevkit.org/blog/announcing-vss/
[fuzzamoto github]: https://github.com/dergoegge/fuzzamoto
[braiins tweet]: https://x.com/BraiinsMining/status/1904601547855573458
[news163 secret]: /en/newsletters/2021/08/25/#bolts-887
