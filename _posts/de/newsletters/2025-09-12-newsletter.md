---
title: 'Bitcoin Optech Newsletter #371'
permalink: /de/newsletters/2025/09/12/
name: 2025-09-12-newsletter-de
slug: 2025-09-12-newsletter-de
type: newsletter
layout: newsletter
lang: de
---
Der Newsletter dieser Woche kündigt die Verfügbarkeit eines Arbeitsbuchs an,
das sich der beweisbaren Kryptographie widmet. Außerdem enthalten sind unsere
regelmäßigen Abschnitte mit Links zu neuen Releases und Release-Kandidaten sowie
Beschreibungen wichtiger Änderungen an beliebter Bitcoin-Infrastruktur-Software.

## Nachrichten

- **Arbeitsbuch zur beweisbaren Kryptographie:** Jonas Nick [veröffentlichte][nick workbook]
  in Delving Bitcoin die Ankündigung eines kurzen Arbeitsbuchs, das er für eine
  viertägige Veranstaltung erstellt hat, um "Entwicklern die Grundlagen der
  beweisbaren Kryptographie zu vermitteln, [...] bestehend aus kryptographischen
  Definitionen, Sätzen, Beweisen und Übungen." Das Arbeitsbuch ist als
  [PDF][workbook pdf] mit frei lizenzierter [Quelle][workbook source] verfügbar.

## Releases und Release-Kandidaten

_Neue Releases und Release-Kandidaten für beliebte Bitcoin-Infrastrukturprojekte.
Bitte erwägen Sie, auf neue Versionen zu aktualisieren oder bei der Testung von
Release-Kandidaten zu helfen._

- [Bitcoin Core 29.1][] ist die Veröffentlichung einer Wartungsversion
  der führenden Full-Node-Software.

- [Eclair v0.13.0][] ist die Veröffentlichung dieser LN-Knoten-Implementierung.
  Sie "enthält eine Menge Refactoring, eine erste Implementierung von
  Taproot-Kanälen, [...] Verbesserungen am Splicing basierend auf den
  jüngsten Spezifikations-Updates und eine bessere Bolt-12-Unterstützung."
  Die Taproot-Kanal- und Splicing-Funktionen werden noch vollständig
  spezifiziert, daher sollten sie von normalen Benutzern nicht verwendet
  werden. Die Versionshinweise warnen auch: "Dies ist die letzte Version
  von Eclair, in der Kanäle, die keine Anchor-Outputs verwenden, unterstützt
  werden. Wenn Sie Kanäle haben, die keine Anchor-Outputs verwenden, sollten
  Sie diese schließen."

- [Bitcoin Core 30.0rc1][] ist ein Release-Kandidat für die nächste Hauptversion
  dieser Full-Verification-Node-Software.

## Wichtige Code- und Dokumentationsänderungen

_Wichtige aktuelle Änderungen in [Bitcoin Core][bitcoin core repo],
[Core Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], und [BINANAs][binana repo]._

- [Bitcoin Core #30469][] aktualisiert die Typen der Werte
  `m_total_prevout_spent_amount`, `m_total_new_outputs_ex_coinbase_amount` und
  `m_total_coinbase_amount` von `CAmount` (64 Bit) auf `arith_uint256`
  (256 Bit), um einen Wertüberlauffehler zu verhindern, der bereits auf dem
  Standard-[Signet][topic signet] beobachtet wurde. Die neue Version des
  Coinstats-Index wird in `/indexes/coinstatsindex/` gespeichert, und ein
  aktualisierter Knoten muss von Grund auf neu synchronisieren, um den Index
  neu zu erstellen. Die alte Version wird zum Schutz vor Downgrades beibehalten,
  könnte aber in einem zukünftigen Update entfernt werden.

- [Eclair #3163][] fügt einen Testvektor hinzu, um sicherzustellen, dass der
  öffentliche Schlüssel eines Zahlungsempfängers aus einer [BOLT11][]-Rechnung
  mit einer High-S-Signatur wiederhergestellt werden kann, zusätzlich zur
  bereits erlaubten Low-S-Signatur. Dies entspricht dem Verhalten von
  libsecp256k1 und dem vorgeschlagenen [BOLTs #1284][].

- [Eclair #2308][] führt eine neue Option `use-past-relay-data` ein, die bei
  Aktivierung (Standard: false) einen probabilistischen Ansatz basierend auf
  vergangenen Zahlungsversuchen verwendet, um die Pfadfindung zu verbessern.
  Dies ersetzt eine frühere Methode, die von einer gleichmäßigen Verteilung
  der Kanalguthaben ausging.

- [Eclair #3021][] ermöglicht es dem Nicht-Initiator eines [beidseitig
  finanzierten Kanals][topic dual funding], die Finanzierungstransaktion
  mittels [RBF][topic rbf] zu ersetzen, was bei [Splicing][topic splicing]-Transaktionen
  bereits erlaubt ist. Eine Ausnahme gilt jedoch für Kauftransaktionen von
  [Liquiditätsanzeigen][topic liquidity advertisements]. Dies wurde in
  [BOLTs #1236][] vorgeschlagen.

- [Eclair #3142][] fügt dem API-Endpunkt `forceclose` einen neuen Parameter
  `maxClosingFeerateSatByte` hinzu, der die globale Gebührenkonfiguration
  für nicht dringende Force-Close-Transaktionen pro Kanal überschreibt.
  Die globale Einstellung `max-closing-feerate` wurde in [Eclair #3097][]
  eingeführt.

- [LDK #4053][] führt gebührenfreie Commitment-Kanäle ein, indem die beiden
  Anchor-Outputs durch einen gemeinsamen [Pay-to-Anchor (P2A)][topic ephemeral anchors]-Output
  ersetzt werden, der auf einen Wert von 240 Sats begrenzt ist. Zusätzlich
  werden die [HTLC][topic htlc]-Signaturen in gebührenfreien Commitment-Kanälen
  auf `SIGHASH_SINGLE|ANYONECANPAY` umgestellt und die HTLC-Transaktionen
  auf [Version 3][topic v3 transaction relay] angehoben.

- [LDK #3886][] erweitert `channel_reestablish` für [Splicing][topic splicing]
  um zwei `funding_locked_txid`-TLVs (was ein Knoten zuletzt gesendet und
  empfangen hat), damit Peers die aktive Finanzierungstransaktion bei
  Wiederverbindung abgleichen können. Zusätzlich wird der Wiederverbindungsprozess
  optimiert, indem `commitment_signed` vor `tx_signatures` erneut gesendet,
  implizites `splice_locked` gehandhabt, `next_funding` übernommen und bei
  Bedarf Ankündigungssignaturen angefordert werden.

{% include snippets/recap-ad.md when="2025-09-16 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="30469,3163,2308,3021,3142,4053,3886,1284,1236,3097" %}
[bitcoin core 29.1]: https://bitcoincore.org/bin/bitcoin-core-29.1/
[bitcoin core 30.0rc1]: https://bitcoincore.org/bin/bitcoin-core-30.0/
[nick workbook]: https://delvingbitcoin.org/t/provable-cryptography-for-bitcoin-an-introduction-workbook/1974
[workbook pdf]: https://github.com/cryptography-camp/workbook/releases
[workbook source]: https://github.com/cryptography-camp/workbook
[Eclair v0.13.0]: https://github.com/ACINQ/eclair/releases/tag/v0.13.0
