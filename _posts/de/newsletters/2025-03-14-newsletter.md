---
title: 'Bitcoin Optech Newsletter #345'
permalink: /de/newsletters/2025/03/14/
name: 2025-03-14-newsletter-de
slug: 2025-03-14-newsletter-de
type: newsletter
layout: newsletter
lang: de
---
Der Newsletter dieser Woche enthält eine Analyse des Peer-to-Peer-Datenübertragung,
den ein typischer Full-Node verarbeitet, fasst Forschungsergebnisse zu LN-Pathfinding
zusammen und beschreibt einen neuen Ansatz für die Erstellung von probabilistischen
Zahlungen. Ebenfalls enthalten sind unsere regelmäßigen Rubriken, in denen wir eine Sitzung
des Bitcoin Core PR Review Club zusammenfassen, neue Releases und Release-Kandidaten
ankündigen und wichtige Änderungen an beliebten Bitcoin-Infrastrukturprojekten beschreiben.

## News

- **Analyse der P2P-Datenübertragung:**
  Der Entwickler Virtu hat auf Delving Bitcoin eine Analyse der P2P-Datenübertragung
  [veröffentlicht][virtu traffic], die sein Knoten in vier verschiedenen Modi generiert
  und empfängt: Initial Block Download (IBD), nicht-erreichbar (nur ausgehende Verbindungen),
  nicht-archivierend (pruned) erreichbarer Knoten und archivierend erreichbarer Knoten. Obwohl
  die Ergebnisse für seinen einzelnen Knoten nicht in allen Fällen repräsentativ gewesen
  sein mögen, fanden wir einige seiner Entdeckungen interessant:

  - *Hoher Blockverkehr als archivierender erreichbarer Knoten:* Virtus Knoten lieferte
    mehrere Gigabyte Blöcke pro Stunde an andere Knoten, wenn er als nicht-pruned
    erreichbarer Knoten betrieben wurde. Viele der Blöcke waren ältere Blöcke, die von
    eingehenden Verbindungen angefordert wurden, um IBD durchzuführen.

  - *Hoher inv-Datenübertragung als nicht-archivierender erreichbarer Knoten:* etwa 20%
    der gesamten Knoten-Datenübertragung bestand aus `inv`-Nachrichten, bevor er den Service
    für ältere Blöcke aktiviert hatte. [Erlay][topic erlay] könnte diesen 20%-Overhead erheblich
    reduzieren, der etwa 100 Megabyte pro Tag ausmachte.

  - *Die Mehrheit der eingehenden Peers scheint aus Spion-Knoten zu bestehen:* "Interessanterweise
    tauschen die meisten eingehenden Peers nur etwa 1 MB Datenübertragung mit meinem Knoten, was
    zu niedrig ist (unter Verwendung der Datenübertragung über meine ausgehenden Verbindungen als
    Basis), um sie als reguläre Verbindungen zu betrachten. Alles, was diese Knoten tun, ist, die
    P2P-Handshake zu vervollständigen und höflich auf Ping-Nachrichten zu antworten. Ansonsten
    saugen sie nur unsere `inv`-Nachrichten auf."

  Virtus Beitrag enthält weitere Erkenntnisse und mehrere Diagramme, die den Datenübertragung
  illustrieren, den sein Knoten erlebt.

- **Forschung zur LN-Pfadfindung mit einem einzigen Pfad:**
  Sindura Saraswathi hat auf Delving Bitcoin über ihre [Forschung][sk path] mit Christian
  Kümmerle [berichtet][saraswathi path], bei der es um die Suche nach optimalen Wegen
  zwischen LN-Knoten für die Überweisung von Zahlungen in einem einzigen Teil geht. Ihr
  Beitrag beschreibt die Strategien, die derzeit von Core Lightning, Eclair, LDK und LND
  verwendet werden. Die Autoren verwenden dann acht modifizierte und unmodifizierte LN-Knoten
  in einem simulierten LN-Netzwerk (basierend auf einer Momentaufnahme des tatsächlichen Netzwerks),
  um die Pathfinding zu testen und Kriterien wie höchste Erfolgsrate, niedrigste Gebührenverhältnisse
  (niedrigste Kosten), kürzeste Gesamtsperre (kürzeste Wartezeit im schlimmsten Fall) und kürzester
  Weg (wenigste Wahrscheinlichkeit, dass eine Zahlung stecken bleibt) zu bewerten. Kein Algorithmus
  hat in allen Fällen besser abgeschnitten als die anderen, und Saraswathi schlägt vor, dass
  Implementierungen bessere Gewichtungsfunktionen bereitstellen sollten, die es den Benutzern
  ermöglichen, die Kompromisse zu wählen, die sie für unterschiedliche Zahlungen bevorzugen
  (z.B. können Sie für eine kleine persönliche Überweisung eine hohe Erfolgsrate priorisieren,
  aber für die Zahlung einer großen monatlichen Rechnung, die noch nicht fällig ist, ein niedriges
  Gebührenverhältnis bevorzugen). Sie merkt auch an, dass "[obwohl] dies über den Rahmen dieser
  Studie hinausgeht, die gewonnenen Erkenntnisse auch für zukünftige Verbesserungen bei
  [Multi-Part-Zahlungen][topic multipath payments] relevant sind."

- **Probabilistische Zahlungen unter Verwendung verschiedener Hash-Funktionen als XOR-Operation:**
  Robin Linus [antwortete][linus pp] im Delving Bitcoin Thread über
  [probabilistische Zahlungen][topic probabilistic payments] mit einem
  konzeptionell einfachen Skript, das es zwei Parteien ermöglicht, jeweils eine beliebige
  Menge an Entropie zu verpflichten, die später offenbart und zusammengeführt werden kann,
  um einen Wert zu erzeugen, der bestimmt, welche von ihnen eine Zahlung erhält. Unter
  Verwendung (und geringfügiger Erweiterung) von Linus' Beispiel aus dem Beitrag:

  - Alice wählt privat den Wert `1 0 0` plus eine separate Nonce.
    Bob wählt privat den Wert `1 1 0` plus eine andere
    separate Nonce.

  - Jede Partei hasht nacheinander ihre Nonce, wobei die Zahlen in
    ihrem Wert bestimmen, welche Hash-Funktion verwendet wird. Wenn der Wert
    oben auf dem Stapel `0` ist, verwenden sie den `HASH160` Opcode;
    wenn der Wert `1` ist, verwenden sie den `SHA256` Opcode. In Alices
    Fall führt sie `sha256(hash160(hash160(alice_nonce)))` aus; in Bobs
    Fall führt er `sha256(sha256(hash160(bob_nonce)))` aus. Dies
    erzeugt ein Commitment für jeden von ihnen, das sie einander senden,
    ohne ihren Wert oder ihre Nonce zu offenbaren.

  - Mit den geteilten Commitments erstellen sie eine On-Chain-Finanzierungstransaktion
    mit einem Skript, das die Eingaben mithilfe von `OP_IF` validiert, um zwischen den
    verschiedenen Hash-Funktionen zu wählen und es einem von ihnen zu ermöglichen, die
    Zahlung zu beanspruchen. Zum Beispiel, wenn die Summe ihrer
    beiden XOR-Operation 0 oder 1 ist, erhält Alice das Geld; wenn es 2 oder
    3 ist, erhält Bob es. Der Vertrag kann auch eine Timeout-Klausel und
    eine platzsparende Klausel für gegenseitige Vereinbarungen enthalten.

  - Nachdem die Finanzierungstransaktion in ausreichender Tiefe bestätigt wurde, geben Alice
    und Bob einander ihre Werte und Nonces bekannt. Das
    XOR von `1 0 0` und `1 1 0` ist `0 1 0`, was zu `1` summiert wird und
    Alice ermöglicht, die Zahlung zu beanspruchen.

## Bitcoin Core PR Review Club

*In diesem monatlichen Abschnitt fassen wir eine kürzlich durchgeführte [Bitcoin Core PR Review Club][]
-Sitzung zusammen, indem wir einige der wichtigen Fragen und Antworten hervorheben. Klicken Sie auf eine
Frage unten, um eine Zusammenfassung der Antwort aus der Sitzung zu sehen.*

[Strengere interne Behandlung von ungültigen Blöcken][review club 31405] ist ein PR von
[mzumsande][gh mzumsande], der die Korrektheit von zwei nicht-konsenskritischen und teuren
Validierungsfeldern verbessert, indem er sie sofort aktualisiert, wenn ein Block als ungültig
markiert wird. Vor diesem PR wurden diese Aktualisierungen verzögert, bis ein späteres Ereignis
eintrat, um den Ressourcenverbrauch zu minimieren. Allerdings seit [Bitcoin Core #25717][],
müsste ein Angreifer viel mehr Arbeit investieren, um dies auszunutzen.

Insbesondere stellt dieser PR sicher, dass `ChainstateManager`'s `m_best_header` immer auf den
Header mit dem meisten Arbeitsaufwand zeigt, der nicht als gültig bekannt ist, und dass ein Blocks
`BLOCK_FAILED_CHILD` `nStatus` immer korrekt ist.


{% include functions/details-list.md
  q0="Welchen Zweck(e) dient `ChainstateManager::m_best_header`?"
  a0="`m_best_header` stellt den Header mit dem meisten Arbeitsaufwand dar, den der Knoten
  bisher gesehen hat, den er jedoch noch nicht ungültig gemacht hat, aber auch nicht
  garantieren kann, dass er gültig ist. Er hat viele Verwendungen, aber der Hauptzweck ist,
  als Ziel zu dienen, auf das der Knoten seine beste Kette fortschreiben kann. Weitere
  Verwendungszwecke umfassen die Bereitstellung einer Schätzung der aktuellen Zeit und eine
  Schätzung der Höhe der besten Kette, wenn fehlende Header von einem Peer angefordert werden.
  Eine vollständigere Übersicht kann im etwa 6 Jahre alten Pull-Request [Bitcoin Core #16974][]
  gefunden werden."
  a0link="https://bitcoincore.reviews/31405#l-36"

  q1="Welche der folgenden Aussagen sind vor diesem PR wahr?
  1) Ein `CBlockIndex` mit einem ungültigen Vorgänger wird IMMER einen
  `BLOCK_FAILED_CHILD` `nStatus` haben.
  2) Ein `CBlockIndex` mit einem gültigen Vorgänger wird NIE einen `BLOCK_FAILED_CHILD`
  `nStatus` haben."
  a1="Aussage 1) ist falsch und wird direkt in diesem PR behandelt. Bevor diesem PR würde
  `AcceptBlock()` einen ungültigen Block als solchen markieren, aber aus Leistungsgründen
  nicht sofort seine Nachfolger als solche aktualisieren. Die Teilnehmer des Review Clubs
  konnten keine Situation finden, in der Aussage 2) falsch war."
  a1link="https://bitcoincore.reviews/31405#l-68"

  q2="Eines der Ziele dieses PR ist es, sicherzustellen, dass `m_best_header` und der
  `nStatus` von Nachfolgern eines ungültigen Blocks immer korrekt gesetzt sind. Welche
  Funktionen sind direkt dafür verantwortlich, diese Werte zu aktualisieren?"
  a2="`SetBlockFailureFlags()` ist dafür verantwortlich, `nStatus` zu aktualisieren. Im
  normalen Betrieb wird `m_best_header` am häufigsten über den Ausgabeparameter in
  `AddToBlockIndex()` gesetzt, aber es kann auch über `RecalculateBestHeader()` berechnet
  und gesetzt werden."
  a2link="https://bitcoincore.reviews/31405#l-110"

  q3="Der größte Teil der Logik im Commit `4100495` `validation: in invalidateblock,
  calculate m_best_header right away implementiert das Finden des neuen besten Headers.
  Was verhindert uns daran, einfach `RecalculateBestHeader()` hier zu verwenden?"
  a3="`RecalculateBestHeader()` durchläuft den gesamten `m_block_index`, was eine
  teure Operation ist. Commit `4100495` optimiert dies, indem es stattdessen eine
  Cache- und Iterationsmenge mit High-PoW-Headern verwendet."
  a3link="https://bitcoincore.reviews/31405#l-114"

  q4="Würden wir den `cand_invalid_descendants`-Cache noch benötigen, wenn wir in der
  Lage wären, vorwärts (d.h. weg vom Genesis-Block) über den Blockbaum zu iterieren?
  Was wären die Vor- und Nachteile eines solchen Ansatzes im Vergleich zu dem, der in
  diesem PR verwendet wird?"
  a4="Wenn `CBlockIndex`-Objekte Verweise auf alle ihre Nachfolger enthielten, müssten
  wir nicht den gesamten `m_block_index` durchlaufen, um Nachfolger zu ungültigen zu
  machen, und würden folglich den `cand_invalid_descendants`-Cache nicht benötigen.
  Allerdings hätte dieser Ansatz erhebliche Nachteile. Erstens würde er den Speicherbedarf
  jedes `CBlockIndex`-Objekts erhöhen, das im gesamten `m_block_index` im Speicher gehalten
  werden muss. Zweitens wäre die Iterationslogik immer noch nicht trivial, da jeder
  `CBlockIndex` genau einen Vorgänger hat, aber keine oder mehrere Nachfolger."
  a4link="https://bitcoincore.reviews/31405#l-136"
%}

## Releases und Release-Kandidaten

_Neue releases und Release-Kandidaten für beliebte Bitcoin-Infrastrukturprojekte.
Bitte denken Sie daran, auf neue Versionen zu aktualisieren oder Release-Kandidaten zu testen._

- [Eclair v0.12.0][] ist eine wichtige Veröffentlichung dieses LN-Knotens.
  Es "fügt Unterstützung für die Erstellung und Verwaltung von [BOLT12][]-Angeboten und ein
  neues Kanal-Schließungsprotokoll hinzu, das [RBF][topic rbf] unterstützt.
  [Es] fügt auch Unterstützung für die Speicherung kleiner Datenmengen für unsere Peers"
  ([Peer-Speicherung][topic peer storage]) hinzu, sowie weitere Verbesserungen und
  Fehlerkorrekturen. Die Veröffentlichungshinweise erwähnen, dass mehrere wichtige
  Abhängigkeiten aktualisiert wurden, was bedeutet, dass Benutzer diese Aktualisierungen
  vor der Bereitstellung der neuen Version von Eclair durchführen müssen.

## Wichtige Code- und Dokumentationsänderungen

_Wichtige kürzliche Änderungen in [Bitcoin Core][bitcoin core repo],
[Core Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet Interface (HWI)][hwi repo],
[Rust Bitcoin][rust bitcoin repo], [BTCPay Server][btcpay server repo], [BDK][bdk repo],
[Bitcoin-Verbesserungsvorschläge (BIPs)][bips repo], [Lightning-BOLTs][bolts repo],
[Lightning-BLIPs][blips repo], [Bitcoin-Inquisition][bitcoin inquisition repo] und
[BINANAs][binana repo]._

- [Bitcoin Core #31407][] fügt Unterstützung für die Notarisierung von macOS-Anwendungs-Bundles
  und -Binaries hinzu, indem das Skript `detached-sig-create.sh`  aktualisiert wird. Das Skript
  signiert jetzt auch eigenständige macOS- und Windows-Binaries. Das kürzlich aktualisierte
  [signapple]-Tool wird für diese Aufgaben verwendet.

- [Eclair #3027][] fügt Funktionen für die Routenfindung von [anonymen Routen][topic rv routing]
  hinzu, wenn [BOLT12][topic offers]-Rechnungen generiert werden, indem die Funktion
  `routeBlindingPaths` eingeführt wird. Diese Funktion berechnet einen Pfad von einem ausgewählten
  Initiator-Knoten zum Empfänger-Knoten, der nur Knoten verwendet, die anonymen Route unterstützen.
  Die anonyme Route wird dann in die Rechnung einbezogen.

- [Eclair #3007][] fügt einen `last_funding_locked`-TLV-Parameter in `channel_reestablish`
  Nachrichten hinzu, um die Synchronisation zwischen Peers während des Kanal-[Splicings][topic splicing]
  nach einer Trennung zu verbessern. Es behebt eine Rennbedingung, bei der ein Knoten ein `channel_update`
  sendet, nachdem er ein `channel_reestablish` erhalten hat, aber bevor `splice_locked` ist, was für
  reguläre Kanäle harmlos ist, aber [einfache Taproot-Kanäle][topic simple taproot channels] stören
  könnte, die einen Nonce-Austausch zwischen Peers erfordern.

- [Eclair #2976][] fügt Unterstützung für die Erstellung von [Angeboten][topic offers]
  ohne zusätzliche Plugins hinzu, indem es den `createoffer`-Befehl einführt, der optional
  Parameter für Beschreibung, Betrag, Ablauf in Sekunden, Aussteller und `blindedPathsFirstNodeId`
  zur Definition eines Initiator-Knotens für einen [anonyme Route][topic rv routing] annimmt.
  Darüber hinaus führt dieser PR die disableoffer- und `listoffers`-Befehle ein, um bestehende
  Angebote zu verwalten.

- [LDK #3608][] definiert die `CLTV_CLAIM_BUFFER`-Konstante neu, um das Doppelte der erwarteten
  maximalen Anzahl von Blöcken darzustellen, die benötigt werden, um eine Transaktion zu bestätigen.
  Dies passt sich an die [Anker][topic anchor outputs]-Kanäle an, in denen [HTLCs][topic htlc]
  Claim-Transaktionen durch ein `OP_CHECKSEQUENCEVERIFY` (CSV)-[Timelock][topic timelocks] von 1 Block
  verzögert werden. Zuvor war sie auf eine einzelne maximale Bestätigungsperiode gesetzt, was für
  vor-Anker-Kanäle ausreichend war, in denen HTLC-Claim-Transaktionen zusammen mit Commitment-Transaktionen
  ausgestrahlt wurden. Eine neue `MAX_BLOCKS_FOR_CONF`-Konstante wird als Basiswert hinzugefügt.

- [LDK #3624][] ermöglicht die Rotation von Funding-Schlüsseln nach erfolgreichen Kanal
  [Splicings][topic splicing], indem ein Skalar-Tweak auf den Basis-Funding-Schlüssel angewendet
  wird, um den 2-von-2-[Multisig][topic multisignature]-Schlüssel des Kanals zu erhalten.
  Dies ermöglicht es einem Knoten, zusätzliche Schlüssel aus dem gleichen Geheimnis abzuleiten.
  Die Tweak-Berechnung folgt der [BOLT3][]-Spezifikation, ersetzt jedoch `per_commitment_point`
  durch die Splice-Funding-Txid, um Eindeutigkeit sicherzustellen, und verwendet den `revocation_basepoint`,
  um die Ableitung auf Kanal-Teilnehmer zu beschränken.

- [LDK #3016][] fügt Unterstützung für externe Projekte hinzu, um Funktions-tests durchzuführen und
  Komponenten wie den Signierer zu ersetzen, indem ein `xtest`-Makro eingeführt wird. Es umfasst eine
  `MutGlobal`-Hilfsfunktion und eine `DynSigner`-Struktur, um dynamische Testkomponenten wie den
  Signierer zu unterstützen, stellt diese Tests unter dem `_externalize_tests`-Feature-Flag bereit
  und bietet eine `TestSignerFactory` für die Erstellung dynamischer Signierer.

- [LDK #3629][] verbessert die Protokollierung von Remote-Fehlern, die nicht zugeordnet oder
  interpretiert werden können, um mehr Einblick in diese Randfälle zu gewähren. Dieses PR ändert
  `onion_utils.rs`, um nicht zugeordnete Fehler zu protokollieren, die den Sender-Betrieb stören
  könnten, und führt eine `decrypt_failure_onion_error_packet`-Funktion für die
  Entschlüsselungshandhabung ein. Es behebt auch einen Fehler, bei dem ein nicht
  lesbarer Fehler mit einem gültigen hashbasierten Nachrichten-Authentifizierungscode
  (HMAC) nicht ordnungsgemäß einem Knoten zugeordnet wurde.
  Dies kann in Zusammenhang stehen mit der Erlaubnis für Ausgeber, Knoten zu vermeiden, die
  [hohe Verfügbarkeit][news342 qos] ankündigen, aber nicht liefern.

- [BDK #1838][] verbessert die Klarheit des Full-Scan- und Synchronisationsflusses durch
  Hinzufügen einer obligatorischen `sync_time` zu `SyncRequest` und `FullScanRequest`,
  verwendet diese `sync_time` als `seen_at` Eigenschaft für unbestätigte Transaktionen
  und erlaubt nicht-kanonischen Transaktionen (siehe Newsletter [#335][news335 noncanonical]),
  einen `seen_at` Zeitstempel auszuschließen. Es aktualisiert `TxUpdate::seen_ats` zu einem
  `HashSet` von (Txid, u64), um mehrere `seen_at` Zeitstempel pro Transaktion zu unterstützen,
  und ändert `TxGraph` zu nicht-exhaustiv, neben anderen Änderungen.

{% include snippets/recap-ad.md when="2025-03-18 15:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="31407,3027,3007,2976,3608,3624,3016,3629,1838,16974,25717" %}
[virtu traffic]: https://delvingbitcoin.org/t/bitcoin-node-p2p-traffic-analysis/1490/
[saraswathi path]: https://delvingbitcoin.org/t/an-exposition-of-pathfinding-strategies-within-lightning-network-clients/1500
[sk path]: https://arxiv.org/pdf/2410.13784
[linus pp]: https://delvingbitcoin.org/t/emulating-op-rand/1409/10
[eclair v0.12.0]: https://github.com/ACINQ/eclair/releases/tag/v0.12.0
[review club 31405]: https://bitcoincore.reviews/31405
[gh mzumsande]: https://github.com/mzumsande
[signapple]: https://github.com/achow101/signapple
[news335 noncanonical]: /en/newsletters/2025/01/03/#bdk-1670
[news342 qos]: /en/newsletters/2025/02/21/#continued-discussion-about-an-ln-quality-of-service-flag