---
title: 'Bitcoin Optech Newsletter #362'
permalink: /de/newsletters/2025/07/11/
name: 2025-07-11-newsletter-de
slug: 2025-07-11-newsletter-de
type: newsletter
layout: newsletter
lang: de
---
Der Newsletter dieser Woche beschreibt kurz eine neue Bibliothek, die es ermöglicht, Output-Script-Deskriptoren für die Verwendung in QR-Codes zu
komprimieren. Ebenfalls enthalten sind unsere regulären Abschnitte mit einer Zusammenfassung eines Bitcoin Core PR Review Club Meetings, der
Ankündigung neuer Releases und Release-Kandidaten und der Beschreibung wichtiger Änderungen an beliebter Bitcoin-Infrastruktursoftware.

## Nachrichten

- **Komprimierte Deskriptoren:** Josh Doman [postete][dorman descom] auf Delving Bitcoin, um eine [Bibliothek][descriptor-codec] anzukündigen,
  die er geschrieben hat und die [Output-Script-Deskriptoren][topic descriptors] in ein binäres Format kodiert, das ihre Größe um etwa 40%
  reduziert. Dies kann besonders nützlich sein, wenn Deskriptoren mittels QR-Codes gesichert werden. Sein Beitrag erläutert die Details der
  Kodierung und erwähnt, dass er plant, die Komprimierung in seine Bibliothek für verschlüsselte Deskriptor-Backups zu integrieren
  (siehe [Newsletter #358][news358 descencrypt]).

## Bitcoin Core PR Review Club

*In diesem monatlichen Abschnitt fassen wir ein kürzliches [Bitcoin Core PR Review Club][] Meeting zusammen und heben einige der wichtigen Fragen
und Antworten hervor. Klicken Sie auf eine Frage unten, um eine Zusammenfassung der Antwort aus dem Meeting zu sehen.*

[Improve TxOrphanage denial of service bounds][review club 31829] ist ein PR von [glozow][gh glozow], der die `TxOrphanage`-Eviction-Logik
ändert, um jedem Peer die Ressourcen für mindestens 1 Paket maximaler Größe für die Orphan-Auflösung zu garantieren. Diese neuen Garantien
verbessern die [1-parent-1-child opportunistische Paket-Weiterleitung][1p1c relay] erheblich, insbesondere (aber nicht nur) unter widrigen Bedingungen, wenn
Angreifer versuchen, das System zu stören.

Der PR modifiziert bestehende globale Orphanage-Limits und führt neue Per-Peer-Limits ein. Zusammen schützen sie sowohl vor übermäßiger
Speichernutzung als auch vor rechnerischer Erschöpfung. Der PR ersetzt auch den zufälligen Eviction-Ansatz durch einen algorithmischen und
berechnet einen Per-Peer-DoS-Score.

_Hinweis: Der PR hat [einige bedeutende Änderungen][review club 31829 changes] seit dem Review Club durchlaufen, wobei die wichtigste in der Verwendung
eines Latenz-Score-Limits anstelle eines Announcement-Limits besteht._

{% include functions/details-list.md
  q0="Warum ist das aktuelle globale TxOrphanage-Maximum von 100 Transaktionen mit zufälliger Eviction problematisch?"
  a0="Es ermöglicht einem bösartigen Peer, einen Knoten mit Orphan-Transaktionen zu überlasten und schließlich alle legitimen Transaktionen anderer Peers zu verdrängen. Dies kann genutzt werden, um die opportunistische 1-parent-1-child-Transaktions-Weiterleitung am Erfolg zu hindern, da die Kind-Transaktion nicht lange im temporären Speicher (Orphanage) bleiben könnte."
  a0link="https://bitcoincore.reviews/31829#l-12"
  q1="Wie funktioniert der Eviction-Algorithmus auf hoher Ebene?"
  a1="Eviction ist nicht mehr zufällig. Der Algorithmus identifiziert den \"schlechtesten\" Peer basierend auf einem \"DoS-Score\" und verdrängt die älteste Transaktionsankündigung von diesem Peer. Dies schützt wohlverhaltende Peers davor, dass ihre Transaktions-Kinder von einem fehlverhaltenden Peer verdrängt werden."
  a1link="https://bitcoincore.reviews/31829#l-19"
  q2="Warum ist es wünschenswert, Peers zu erlauben, ihre individuellen Limits zu überschreiten, während die globalen Limits nicht erreicht sind?"
  a2="Peers verwenden möglicherweise mehr Ressourcen, einfach weil sie ein hilfreicher Peer sind, der nützliche Transaktionen wie CPFPs weiterleitet."
  a2link="https://bitcoincore.reviews/31829#l-25"
  q3="Der neue Algorithmus verdrängt Ankündigungen anstelle von Transaktionen. Was ist der Unterschied und warum ist das wichtig?"
  a3="Eine Ankündigung ist ein Paar aus einer Transaktion und dem Peer, der sie gesendet hat. Durch das Verdrängen von Ankündigungen kann ein bösartiger Peer keine Transaktion verdrängen, die auch von einem ehrlichen Peer gesendet wurde."
  a3link="https://bitcoincore.reviews/31829#l-34"
  q4="Was ist der \"DoS-Score\" eines Peers und wie wird er berechnet?"
  a4="Der DoS-Score eines Peers ist das Maximum seines \"Speicher-Scores\" (verwendeter Speicher / reservierter Speicher) und \"CPU-Scores\" (Anzahl der gesendeten Ankündigungen / Ankündigungslimit). Die Verwendung eines einzigen kombinierten Scores vereinfacht die Eviction-Logik zu einer einzigen Schleife, die den Peer anvisiert, der am aggressivsten eines seiner Limits überschreitet."
  a4link="https://bitcoincore.reviews/31829#l-133"
%}




## Releases und Release-Kandidaten

_Neue Releases und Release-Kandidaten für beliebte Bitcoin-Infrastrukturprojekte. Bitte erwägen Sie ein Upgrade auf neue Releases oder helfen Sie
beim Testen von Release-Kandidaten._

- [LND v0.19.2-beta.rc2][] ist ein Release-Kandidat für eine Wartungsversion dieses beliebten LN-Knotens.

## Wichtige Code- und Dokumentationsänderungen

_Wichtige kürzliche Änderungen in [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning repo], [Eclair][eclair repo],
[LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo],
[BTCPay Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition repo], und [BINANAs][binana repo]._

- [Core Lightning #8377][] verschärft die [BOLT11][]-Invoice-Parsing-Anforderungen, indem es vorschreibt, dass Sender eine Invoice nicht
  bezahlen, wenn ein [Payment Secret][topic payment secrets] fehlt oder wenn ein Pflichtfeld wie p (Payment Hash), h (Description Hash) oder
  s (Secret) eine falsche Länge hat. Diese Änderungen werden vorgenommen, um sich an die kürzlichen Spezifikations-Updates anzupassen
  (siehe Newsletter [#350][news350 bolts] und [#358][news358 bolts]).

- [BDK #1957][] führt RPC-Batching für Transaktionshistorie, Merkle-Beweise und Block-Header-Anfragen ein, um die Full-Scan- und
  Sync-Performance mit einem Electrum-Backend zu optimieren. Dieser PR fügt auch Anchor-Caching hinzu, um Simple Payment Verification (SPV)
  (siehe Newsletter [#312][news312 spv]) Revalidierung während eines Syncs zu überspringen. Mit Beispieldaten beobachtete der Autor
  Performance-Verbesserungen von 8,14 Sekunden auf 2,59 Sekunden mit RPC-Call-Batching bei einem Full Scan und von 1,37 Sekunden auf
  0,85 Sekunden mit Caching während eines Syncs.

- [BIPs #1888][] entfernt `H` als Hardened-Path-Marker aus [BIP380][] und lässt nur das kanonische `h` und die Alternative `'` übrig.
  Der kürzliche Newsletter [#360][news360 bip380] hatte angemerkt, dass die Grammatik klargestellt wurde, um alle drei Marker zu erlauben,
  aber da wenige (wenn überhaupt) Deskriptor-Implementierungen dies tatsächlich unterstützen (weder Bitcoin Core noch rust-miniscript tun es),
  wird die Spezifikation verschärft, um dies zu verbieten.

{% include snippets/recap-ad.md when="2025-07-15 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="8377,1957,1888" %}
[LND v0.19.2-beta.rc2]: https://github.com/lightningnetwork/lnd/releases/tag/v0.19.2-beta.rc2
[news358 descencrypt]: /de/newsletters/2025/06/13/#bibliothek-zur-verschlusselung-von-deskriptoren
[dorman descom]: https://delvingbitcoin.org/t/a-rust-library-to-encode-descriptors-with-a-30-40-size-reduction/1804
[descriptor-codec]: https://github.com/joshdoman/descriptor-codec
[news350 bolts]: /de/newsletters/2025/04/18/#bolts-1242
[news358 bolts]: /de/newsletters/2025/06/13/#bolts-1243
[news312 spv]: /en/newsletters/2024/07/19/#bdk-1489
[news360 bip380]: /de/newsletters/2025/06/27/#bips-1803
[review club 31829]: https://bitcoincore.reviews/31829
[gh glozow]: https://github.com/glozow
[review club 31829 changes]: https://github.com/bitcoin/bitcoin/pull/31829#issuecomment-3046495307
[1p1c relay]: /en/bitcoin-core-28-wallet-integration-guide/#one-parent-one-child-1p1c-relay
