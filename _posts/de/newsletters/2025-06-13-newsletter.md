---
title: 'Bitcoin Optech Newsletter #358'
permalink: /de/newsletters/2025/06/13/
name: 2025-06-13-newsletter-de
slug: 2025-06-13-newsletter-de
type: newsletter
layout: newsletter
lang: de
---
Der Newsletter dieser Woche beschreibt, wie der Schwellenwert für die Gefahr von
Selfish Mining berechnet werden kann, fasst eine Idee zur Verhinderung des
Herausfilterns von Transaktionen mit hoher Gebühr zusammen, bittet um Feedback
zu einer vorgeschlagenen Änderung an BIP390-`musig()`-Deskriptoren und kündigt
eine neue Bibliothek zur Verschlüsselung von Deskriptoren an. Ebenfalls enthalten
sind unsere regulären Abschnitte mit der Zusammenfassung eines Bitcoin Core PR
Review Clubs, Ankündigungen neuer Releases und Release-Kandidaten sowie
Beschreibungen aktueller Änderungen an populärer Bitcoin-Infrastruktur.

## Nachrichten

- **Berechnung des Schwellenwerts für Selfish Mining:**
  Antoine Poinsot [veröffentlichte][poinsot selfish] auf Delving Bitcoin eine
  Erweiterung der Mathematik aus dem [Paper von 2013][es selfish], das dem
  [Selfish-Mining-Angriff][topic selfish mining] seinen Namen gab (obwohl der
  Angriff bereits [2010 beschrieben][bytecoin selfish] wurde). Er stellte außerdem
  einen vereinfachten Mining- und Block-Relay-[Simulator][darosior/miningsimulation]
  bereit, mit dem man mit dem Angriff experimentieren kann. Im Fokus steht die
  Reproduktion einer der Schlussfolgerungen des Papers von 2013: Ein unehrlicher
  Miner (oder ein Kartell gut vernetzter Miner), der 33 % der gesamten
  Netzwerk-Hashrate kontrolliert (ohne weitere Vorteile), kann auf lange Sicht
  marginal profitabler werden als die Miner mit den restlichen 67 % der Hashrate.
  Dies wird erreicht, indem der 33 %-Miner die Bekanntgabe einiger neu gefundener
  Blöcke selektiv verzögert. Steigt die Hashrate des unehrlichen Miners über 33 %,
  wird der Angriff noch profitabler, bis er bei über 50 % die Konkurrenz vollständig
  vom besten Blockchain-Zweig verdrängen kann.

  Wir haben Poinsots Beitrag nicht im Detail geprüft, sein Ansatz erscheint uns jedoch fundiert.
  Wir empfehlen ihn allen, die sich für die Mathematik interessieren und sie nachvollziehen
  oder besser verstehen möchten.

- **Zensurresistenz beim Relay durch Top-Mempool-Set-Abgleichungen:**
  Peter Todd [schrieb][todd feerec] auf der Bitcoin-Dev-Mailingliste über einen
  Mechanismus, mit dem Knoten Peers aussortieren könnten, die Transaktionen mit
  hoher Gebühr herausfiltern. Der Mechanismus basiert auf [Cluster Mempool][topic
  cluster mempool] und einem Set-Abgleich (Reconciliation) wie bei [Erlay][topic
  erlay]. Ein Knoten würde mit Cluster Mempool die profitabelste Menge
  unbestätigter Transaktionen berechnen, die z.B. in 8.000.000 Weight Units
  (maximal 8 MB) passen. Jeder Peer berechnet ebenfalls seine Top-8-MWU
  unbestätigter Transaktionen. Mit einem effizienten Algorithmus wie
  [minisketch][topic minisketch] gleicht der Knoten seine Transaktionsmenge mit
  jedem Peer ab und erfährt so, welche Transaktionen jeder Peer im oberen Bereich
  seines Mempools hat. Anschließend trennt der Knoten regelmäßig die Verbindung zu
  dem Peer, dessen Mempool im Durchschnitt am wenigsten profitabel ist.

  Durch das Entfernen der am wenigsten profitablen Verbindungen findet der Knoten
  schließlich Peers, die am wenigsten dazu neigen, Transaktionen mit hoher Gebühr
  herauszufiltern. Todd plant, an einer Implementierung zu arbeiten, sobald Cluster
  Mempool in Bitcoin Core integriert ist. Die Idee stammt von Gregory Maxwell und
  anderen; Optech erwähnte das Grundprinzip erstmals in [Newsletter #9][news9
  reconcile].

- **BIP390-Update: Doppelte Teilnehmer-Schlüssel in `musig()`-Ausdrücken erlauben:**
  Ava Chow [fragte][chow dupsig] auf der Bitcoin-Dev-Mailingliste, ob es Einwände
  dagegen gibt, [BIP390][] so zu ändern, dass `musig()`-Ausdrücke in [Output Script
  Deskriptoren][topic descriptors] denselben Teilnehmer-Public-Key mehrfach
  enthalten dürfen. Das vereinfacht die Implementierung und ist explizit durch die
  [BIP327][]-Spezifikation von [MuSig2][topic musig] erlaubt. Bis Redaktionsschluss
  gab es keine Einwände, und Chow hat einen [Pull Request][bips #1867] zur Änderung
  der BIP390-Spezifikation eingereicht.

- **Bibliothek zur Verschlüsselung von Deskriptoren:**
  Josh Doman [kündigte][doman descrypt] auf Delving Bitcoin eine Bibliothek an, die
  sensible Teile eines [Output Script Deskriptors][topic descriptors] oder
  [Miniscript][topic miniscript] für die darin enthaltenen Public Keys verschlüsselt.

  Er beschreibt, welche Informationen zum Entschlüsseln benötigt werden:

  > - Wenn deine Wallet 2-von-3 Schlüsseln zum Ausgeben benötigt, werden genau
  >   2-von-3 Schlüssel zum Entschlüsseln benötigt.
  >
  > - Wenn deine Wallet eine komplexe Miniscript-Policy wie „Entweder 2 Schlüssel
  >   ODER (ein Timelock UND ein weiterer Schlüssel)“ verwendet, folgt die
  >   Verschlüsselung derselben Struktur, als wären alle Timelocks und Hash-Locks
  >   erfüllt.

  Dies unterscheidet sich vom in [Newsletter #351][news351 salvacrypt] diskutierten
  Backup-Schema, bei dem jeder Public Key im Deskriptor zur Entschlüsselung genügt.
  Doman argumentiert, dass sein Ansatz mehr Privatsphäre bietet, wenn der
  verschlüsselte Deskriptor z.B. öffentlich oder halböffentlich (etwa auf einer
  Blockchain) gesichert wird.

## Bitcoin Core PR Review Club

*In diesem monatlichen Abschnitt fassen wir ein aktuelles [Bitcoin Core PR Review
Club][]-Meeting zusammen und heben wichtige Fragen und Antworten hervor. Ein Klick
auf eine Frage zeigt die Zusammenfassung der Antwort aus dem Meeting.*

[Separate UTXO set access from validation functions][review club 32317] ist ein PR
von [TheCharlatan][gh thecharlatan], der es ermöglicht, Validierungsfunktionen
aufzurufen, indem nur die benötigten UTXOs übergeben werden, statt das komplette
UTXO-Set vorauszusetzen. Dies ist Teil des [`bitcoinkernel`-Projekts][Bitcoin Core
#27587] und ein wichtiger Schritt, um die Bibliothek für Full-Node-Implementierungen
nutzbar zu machen, die kein UTXO-Set implementieren, wie z.B. [Utreexo][topic
utreexo] oder [SwiftSync][somsen swiftsync] Knoten (siehe [Newsletter #349][news349
swiftsync]).

In den ersten vier Commits reduziert dieser PR die Kopplung zwischen
Transaktionsvalidierungsfunktionen und dem UTXO-Set, indem der Aufrufer die
benötigten `Coin`s oder `CTxOut`s selbst holen und an die Validierungsfunktion
übergeben muss, statt dass diese direkt auf das UTXO-Set zugreift.

In späteren Commits wird die Abhängigkeit von `ConnectBlock()` zum UTXO-Set
vollständig entfernt, indem die verbleibende Logik, die UTXO-Set-Interaktion
benötigt, in eine eigene Methode `SpendBlock()` ausgelagert wird.

{% comment %}
Die Fragen und Antworten aus dem Review Club werden wie im Original übernommen,
da sie für das technische Verständnis wichtig sind.
{% endcomment %}

{% include functions/details-list.md
  q0="Warum ist das Auslagern der neuen `SpendBlock()`-Funktion aus `ConnectBlock()`
  für diesen PR hilfreich? Wie würdest du den Zweck der beiden Funktionen vergleichen?"
  a0="Die Funktion `ConnectBlock()` führte ursprünglich sowohl die Blockvalidierung
  als auch die Modifikation des UTXO-Sets durch. Dieses Refactoring trennt diese
  Verantwortlichkeiten: `ConnectBlock()` ist jetzt nur noch für die Validierungslogik
  zuständig, die kein UTXO-Set benötigt, während die neue Funktion `SpendBlock()`
  alle Interaktionen mit dem UTXO-Set übernimmt. Dadurch kann ein Aufrufer
  `ConnectBlock()` zur Blockvalidierung verwenden, ohne ein UTXO-Set zu benötigen."
  a0link="https://bitcoincore.reviews/32317#l-37"

  q1="Siehst du einen weiteren Vorteil dieser Entkopplung, außer der Ermöglichung
  der Kernel-Nutzung ohne UTXO-Set?"
  a1="Neben der Ermöglichung der Kernel-Nutzung für Projekte ohne UTXO-Set
  erleichtert diese Entkopplung das Testen des Codes in Isolation und vereinfacht die Wartung.
  Ein Reviewer merkt auch an, dass die Beseitigung der Notwendigkeit für den Zugriff
  auf das UTXO-Set die parallele Validierung von Blöcken ermöglicht, was ein wichtiges
  Merkmal von SwiftSync ist."
  a1link="https://bitcoincore.reviews/32317#l-64"

  q2="`SpendBlock()` benötigt einen `CBlock block`, `CBlockIndex pindex` und
  `uint256 block_hash` Parameter, die alle auf den ausgegebenen Block verweisen.
  Warum benötigen wir 3 Parameter dafür?"
  a2="Validierungscode ist leistungskritisch, er beeinflusst wichtige
  Parameter wie die Blockverbreitungsgeschwindigkeit. Den Blockhash
  aus einem `CBlock` oder `CBlockIndex` zu berechnen, ist nicht umsonst, da der Wert nicht
  zwischengespeichert wird. Aus diesem Grund hat der Autor beschlossen, die Leistung
  zu priorisieren, indem er einen bereits berechneten `block_hash` als separaten Parameter übergibt.
  Ebenso könnte `pindex` aus dem Blockindex abgerufen werden, 
  aber dies würde jedoch eine zusätzliche Map-Abfrage erfordern, der nicht unbedingt notwendig ist.
  <br>_Hinweis: Der Autor hat später den
  Ansatz [geändert][32317 updated approach], indem er die `block_hash`-Leistungsoptimierung entfernt hat._"
  a2link="https://bitcoincore.reviews/32317#l-97"

  q3="Die ersten Commits in diesem PR refaktorisieren `CCoinsViewCache` aus der
  Funktionssignatur einiger Validierungsfunktionen. Hält
  `CCoinsViewCache` das gesamte UTXO-Set? Warum ist das (nicht) ein
  Problem? Ändert sich durch diesen PR dieses Verhalten?"
  a3="`CCoinsViewCache` hält nicht das gesamte UTXO-Set; es ist ein
  Zwischenspeicher im Speicher, der vor `CCoinsViewDB` sitzt, welche das
  vollständige UTXO-Set auf der Festplatte speichert. Wenn ein angeforderter
  Coin nicht im Cache ist, muss sie von der Festplatte abgerufen werden.
  Dieser PR ändert nicht dasCaching Verhalten selbst. Durch das Entfernen von
  `CCoinsViewCache` aus den Funktionssignaturen wird die UTXO-Abhängigkeit explizit,
  was den Aufrufer verpflichtet, die Coins vor dem Aufruf der Validierungsfunktion abzurufen."
  a3link="https://bitcoincore.reviews/32317#l-116"
%}

## Releases und Release-Kandidaten

_Neue Releases und Release-Kandidaten für populäre Bitcoin-Infrastrukturprojekte.
Bitte erwäge, auf neue Releases zu aktualisieren oder Release-Kandidaten zu testen._

- [Core Lightning 25.05rc1][] ist ein Release-Kandidat für die nächste Hauptversion
  dieser beliebten LN-Knoten-Implementierung.

- [LND 0.19.1-beta][] ist ein Release dieser beliebten LN-Knoten-Implementierung und
  enthält [mehrere Fehlerbehebungen][lnd rn].

## Wichtige Code- und Dokumentationsänderungen

_Bemerkenswerte aktuelle Änderungen in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo], [LND][lnd
repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet Interface (HWI)][hwi
repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay Server][btcpay server repo],
[BDK][bdk repo], [Bitcoin Improvement Proposals (BIPs)][bips repo], [Lightning
BOLTs][bolts repo], [Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin
inquisition repo] und [BINANAs][binana repo]._

- [Bitcoin Core #32406][] hebt das Größenlimit für `OP_RETURN`-Outputs
  (Standardness-Regel) auf, indem die Standardeinstellung für `-datacarriersize`
  von 83 auf 100.000 Bytes (das maximale Transaktionsgrößenlimit) erhöht wird.
  Die Optionen `-datacarrier` und `-datacarriersize` bleiben erhalten, sind aber
  als veraltet markiert und werden in einer zukünftigen Version entfernt. Außerdem
  wird die Beschränkung auf ein `OP_RETURN` pro Transaktion aufgehoben; das
  Größenlimit gilt nun für alle `OP_RETURN`-Outputs einer Transaktion zusammen.
  Siehe [Newsletter #352][news352 opreturn] für weitere Hintergründe.

- [LDK #3793][] fügt eine neue Nachricht `start_batch` hinzu, die Peers signalisiert,
  die nächsten `n` (`batch_size`) Nachrichten als eine logische Einheit zu behandeln.
  Außerdem wird `PeerManager` so angepasst, dass dies für `commitment_signed`-Nachrichten
  beim [Splicing][topic splicing] genutzt wird, statt für jede Nachricht ein TLV- und
  `batch_size`-Feld zu verwenden. Ziel ist es, auch weitere LN-Protokollnachrichten zu
  bündeln, nicht nur `commitment_signed`, wie es die LN-Spezifikation vorsieht.

- [LDK #3792][] führt erste Unterstützung für [v3 Commitment-Transaktionen][topic v3
  commitments] (siehe [Newsletter #325][news325 v3]) ein, die auf [TRUC-Transaktionen][topic
  v3 transaction relay] und [ephemeralen Anchors][topic ephemeral anchors] basieren
  (hinter einem Test-Flag). Ein Knoten lehnt jetzt `open_channel`-Vorschläge mit nicht-null
  Feerate ab, initiiert selbst keine solchen Channels mehr und akzeptiert v3-Channels erst,
  nachdem ein UTXO für spätere Fee-Bumps reserviert wurde. Außerdem wird das pro-Channel-
  [HTLC][topic htlc]-Limit von 483 auf 114 gesenkt, da TRUC-Transaktionen unter 10 kB
  bleiben müssen.

- [LND #9127][] fügt der Option `lncli addinvoice` den Parameter
  `--blinded_path_incoming_channel_list` hinzu, mit dem ein Empfänger eine oder mehrere
  bevorzugte Channel-IDs für den Zahler angeben kann, die beim Routing über einen
  [Blinded Path][topic rv routing] bevorzugt werden sollen.

- [LND #9858][] beginnt, das Produktions-Feature-Bit 61 für den [RBF][topic rbf]-
  Cooperative-Close-Flow (siehe [Newsletter #347][news347 rbf]) zu signalisieren, um die
  Interoperabilität mit Eclair zu ermöglichen. Das Staging-Bit 161 bleibt erhalten, um die
  Interoperabilität mit Test-Knoten sicherzustellen.

- [BOLTs #1243][] aktualisiert die [BOLT11][]-Spezifikation dahingehend, dass ein Reader
  (Sender) eine Rechnung nicht bezahlen darf, wenn ein Pflichtfeld wie p (Payment Hash),
  h (Description Hash) oder s (Secret) die falsche Länge hat. Zuvor konnten Knoten dieses
  Problem ignorieren. Außerdem wird im Examples-Abschnitt ergänzt, dass [Low-R-Signaturen][topic
  low-r grinding], auch wenn sie ein Byte sparen, nicht vorgeschrieben sind.

{% include snippets/recap-ad.md when="2025-06-17 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="32406,3793,3792,9127,1867,9858,1243,27587" %}
[Core Lightning 25.05rc1]: https://github.com/ElementsProject/lightning/releases/tag/v25.05rc1
[lnd 0.19.1-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.19.1-beta
[poinsot selfish]: https://delvingbitcoin.org/t/where-does-the-33-33-threshold-for-selfish-mining-come-from/1757
[bytecoin selfish]: https://bitcointalk.org/index.php?topic=2227.msg30083#msg30083
[darosior/miningsimulation]: https://github.com/darosior/miningsimulation
[todd feerec]: https://mailing-list.bitcoindevs.xyz/bitcoindev/aDWfDI03I-Rakopb@petertodd.org/
[news9 reconcile]: /en/newsletters/2018/08/21/#bandwidth-efficient-set-reconciliation-protocol-for-transactions
[chow dupsig]: https://mailing-list.bitcoindevs.xyz/bitcoindev/08dbeffd-64ec-4ade-b297-6d2cbeb5401c@achow101.com/
[doman descrypt]: https://delvingbitcoin.org/t/rust-descriptor-encrypt-encrypt-any-descriptor-such-that-only-authorized-spenders-can-decrypt/1750/
[news351 salvacrypt]: /de/newsletters/2025/04/25/#standardisiertes-backup-fur-wallet-deskriptoren
[es selfish]: https://arxiv.org/pdf/1311.0243
[lnd rn]: https://github.com/lightningnetwork/lnd/blob/v0.19.1-beta/docs/release-notes/release-notes-0.19.1.md
[news352 opreturn]: /de/newsletters/2025/05/02/#erhohung-oder-abschaffung-des-op-return-grossenlimits-in-bitcoin-core
[news325 v3]: /en/newsletters/2024/10/18/#version-3-commitment-transactions
[news347 rbf]: /de/newsletters/2025/03/28/#lnd-8453
[review club 32317]: https://bitcoincore.reviews/32317
[gh thecharlatan]: https://github.com/TheCharlatan
[somsen swiftsync]: https://gist.github.com/RubenSomsen/a61a37d14182ccd78760e477c78133cd
[32317 updated approach]: https://github.com/bitcoin/bitcoin/pull/32317#issuecomment-2883841466
[news349 swiftsync]: /de/newsletters/2025/04/11/#swiftsync-beschleunigung-fur-initial-block-download
