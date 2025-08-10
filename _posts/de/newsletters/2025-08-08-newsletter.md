---
title: 'Bitcoin Optech Newsletter #366'
permalink: /de/newsletters/2025/08/08/
name: 2025-08-08-newsletter-de
slug: 2025-08-08-newsletter-de
type: newsletter
layout: newsletter
lang: de
---
Der Newsletter dieser Woche kündigt Entwürfe für BIPs zu Utreexo an, fasst die
anhaltende Diskussion über die Senkung der minimalen Transaktions-Relay-Gebühr
zusammen und beschreibt einen Vorschlag, der es Knoten ermöglicht, ihre
Block-Templates zu teilen, um Probleme mit unterschiedlichen Mempool-Richtlinien
zu mildern. Außerdem enthalten sind unsere regelmäßigen Abschnitte mit einer
Zusammenfassung eines Bitcoin Core PR Review Club Meetings, der Ankündigung neuer
Releases und Release-Kandidaten sowie einer Beschreibung wichtiger Änderungen
an beliebter Bitcoin-Infrastruktur-Software. Wir fügen auch eine Korrektur zum
Newsletter der letzten Woche und eine Empfehlung für unsere Leser hinzu.

## Nachrichten

- **Entwürfe für BIPs zu Utreexo vorgeschlagen:** Calvin Kim [veröffentlichte][kim bips]
  in der Bitcoin-Dev-Mailingliste drei Entwürfe für BIPs, die er gemeinsam mit
  Tadge Dryja und Davidson Souza über das [Utreexo][topic utreexo]-Validierungsmodell
  verfasst hat. Der [erste BIP][ubip1] spezifiziert die Struktur des Utreexo-Akkumulators,
  der es einem Knoten ermöglicht, ein einfach aktualisierbares Commitment zum
  vollständigen UTXO-Set in nur "wenigen Kilobytes" zu speichern. Der [zweite BIP][ubip2]
  spezifiziert, wie ein Full Node neue Blöcke und Transaktionen mit dem Akkumulator
  validieren kann, anstatt mit einem traditionellen Set von ausgegebenen
  Transaktions-Outputs (STXOs, verwendet in frühem Bitcoin Core und aktuellem libbitcoin)
  oder nicht ausgegebenen Transaktions-Outputs (UTXOs, verwendet in aktuellem
  Bitcoin Core). Der [dritte BIP][ubip3] spezifiziert die Änderungen am Bitcoin-P2P-Protokoll,
  der die Übertragung der zusätzlichen Daten ermöglichen, die für die Utreexo-Validierung
  benötigt werden.

  Die Autoren suchen ein konzeptionelles Review und werden die Entwürfe der BIPs
  basierend auf weiteren Entwicklungen aktualisieren.

- **Anhaltende Diskussion über die Senkung der minimalen Relay-Gebühr:**
  Gloria Zhao [veröffentlichte][zhao minfee] auf Delving Bitcoin einen Beitrag über
  die Senkung der [default minimum relay feerate][topic default minimum transaction relay feerates]
  um 90% auf 0,1 sat/vbyte. Sie ermutigte zu einer konzeptionellen Diskussion über
  die Idee und darüber, wie sie andere Software beeinflussen könnte. Für Bedenken
  spezifisch zu Bitcoin Core verwies sie auf einen [Pull Request][bitcoin core #33106].

- **Peer-Block-Template-Sharing zur Milderung von Mempool-Richtlinien-Problemen:** Anthony Towns [veröffentlichte][towns tempshare] auf
  Delving Bitcoin den Vorschlag, dass Full-Node-Peers sich gelegentlich ihre
  aktuellen Templates für den nächsten Block unter Verwendung der
  [Compact-Block-Relay][topic compact block relay]-Kodierung zusenden. Der
  empfangende Peer könnte dann alle Transaktionen aus dem Template anfordern,
  die ihm fehlen, und sie entweder zum lokalen Mempool hinzufügen oder in einem
  Cache speichern. Dies würde es Peers mit unterschiedlichen Mempool-Richtlinien
  ermöglichen, Transaktionen trotz ihrer Unterschiede zu teilen. Es bietet eine
  Alternative zu einem früheren Vorschlag, der die Verwendung von _Weak Blocks_
  vorschlug (siehe [Newsletter #299][news299 weak blocks]). Towns veröffentlichte
  eine [Proof-of-Concept-Implementierung][towns tempshare poc].

## Bitcoin Core PR Review Club

*In diesem monatlichen Abschnitt fassen wir ein kürzliches [Bitcoin Core PR Review
Club][] Meeting zusammen und heben einige der wichtigen Fragen und Antworten hervor.
Klicken Sie auf eine Frage unten, um eine Zusammenfassung der Antwort aus dem Meeting
zu sehen.*

[Add exportwatchonlywallet RPC to export a watchonly version of a
wallet][review club 32489] ist ein PR von [achow101][gh achow101], der die Menge
der manuellen Arbeit reduziert, die zum Erstellen einer Watch-Only-Wallet erforderlich
ist. Vor dieser Änderung mussten Benutzer das durch Eingabe oder Skripting von
`importdescriptors`-RPC-Aufrufen, Kopieren von Adresslabels usw. erledigen.

Neben öffentlichen [Deskriptoren][topic descriptors] enthält der Export auch:
- Caches mit abgeleiteten xpubs wenn nötig, z.B. bei gehärteten Ableitungspfaden
- Adressbuch-Einträge, Wallet-Flags und Benutzer-Labels
- alle historischen Wallet-Transaktionen, sodass Rescans unnötig sind

Die exportierte Wallet-Datenbank kann dann mit dem `restorewallet`-RPC importiert werden.

{% include functions/details-list.md
  q0="Warum können die bestehenden `IsRange()`/`IsSingleType()`-Informationen
  uns nicht sagen, ob ein Deskriptor auf der Watch-Only-Seite erweitert werden kann?
  Erklären Sie die Logik hinter `CanSelfExpand()` für a) einen gehärteten
  `wpkh(xpub/0h/*)`-Pfad und b) einen `pkh(pubkey)`-Deskriptor."
  a0="`IsRange()` und `IsSingleType()` waren unzureichend, weil sie
  nicht auf gehärtete Ableitung prüfen, die private Schlüssel erfordert,
  die in einer Watch-Only-Wallet nicht verfügbar sind. `CanSelfExpand()` wurde hinzugefügt,
  um rekursiv nach gehärteten Pfaden zu suchen; wenn es einen findet, gibt es
  `false` zurück und signalisiert, dass ein vorab gefüllter Cache für die
  Watch-Only-Wallet exportiert werden muss, um Adressen abzuleiten. Ein `pkh(pubkey)`-Deskriptor
  ist nicht ranged und hat keine Ableitung, daher kann er sich immer selbst erweitern."
  a0link="https://bitcoincore.reviews/32489#l-27"

  q1="`ExportWatchOnlyWallet` kopiert den Deskriptor-Cache nur, wenn
  `!desc->CanSelfExpand()`. Was genau wird in diesem Cache gespeichert? Wie
  könnte ein unvollständiger Cache die Adressableitung auf der Watch-Only-Wallet beeinträchtigen?"
  a1="Der Cache speichert `CExtPubKey`-Objekte für Deskriptoren mit
  gehärteten Ableitungspfaden, die auf der ausgabenfähigen Wallet vorab abgeleitet werden.
  Wenn dieser Cache unvollständig ist, kann die Watch-Only-Wallet die fehlenden Adressen
  nicht ableiten, weil ihr die notwendigen privaten Schlüssel fehlen. Dies würde dazu führen,
  dass sie Transaktionen an diese Adressen nicht sieht, was zu einem falschen Guthaben führt."
  a1link="https://bitcoincore.reviews/32489#l-52"

  q2="Der Exporter setzt `create_flags = GetWalletFlags() |
  WALLET_FLAG_DISABLE_PRIVATE_KEYS`. Warum ist es wichtig, die ursprünglichen
  Flags (z.B. `AVOID_REUSE`) zu bewahren, anstatt alles zu löschen und
  neu zu beginnen?"
  a2="Das Bewahren der Flags stellt Verhaltenskonsistenz zwischen der
  ausgabenfähigen und der Watch-Only-Wallet sicher. Zum Beispiel beeinflusst das `AVOID_REUSE`-Flag,
  welche Coins als verfügbar für Ausgaben betrachtet werden. Wenn es nicht bewahrt wird,
  würde die Watch-Only-Wallet ein anderes verfügbares Guthaben melden als die Haupt-Wallet,
  was zu Benutzerverwirrung führt."
  a2link="https://bitcoincore.reviews/32489#l-68"

  q3="Warum liest der Exporter den Locator aus der Quell-Wallet und
  schreibt ihn wörtlich in die neue Wallet, anstatt die neue Wallet
  von Block 0 starten zu lassen?"
  a3="Der Block-Locator wird kopiert, um der neuen Watch-Only-Wallet zu sagen,
  wo sie das Scannen der Blockchain nach neuen Transaktionen fortsetzen soll,
  wodurch die Notwendigkeit eines vollständigen Rescans verhindert wird."
  a3link="https://bitcoincore.reviews/32489#l-93"

  q4="Betrachten Sie einen Multisig-Deskriptor `wsh(multi(2,xpub1,xpub2))`. Wenn ein
  Mitunterzeichner eine Watch-Only-Wallet exportiert und sie mit einem Dritten teilt,
  welche neuen Informationen lernt dieser Dritte im Vergleich zu nur
  den Deskriptor-Strings zu geben?"
  a4="Die Watch-Only-Wallet-Daten enthalten zusätzliche Metadaten wie
  Adressbuch, Wallet-Flags und Coin-Control-Labels. Für Wallets mit
  gehärteter Ableitung kann der Dritte nur Informationen über
  historische und zukünftige Transaktionen durch den Watch-Only-Wallet-Export erhalten."
  a4link="https://bitcoincore.reviews/32489#l-100"

  q5="In `wallet_exported_watchonly.py`, warum ruft der Test
  `wallet.keypoolrefill(100)` auf, bevor er die Ausgabefähigkeit über das
  Online/Offline-Paar prüft?"
  a5="Der `keypoolrefill(100)`-Aufruf zwingt die Offline-(Ausgaben-)Wallet,
  100 Schlüssel für ihre gehärteten Deskriptoren vorab abzuleiten und ihren
  Cache zu füllen. Dieser Cache wird dann in den Export einbezogen, wodurch die Online
  Watch-Only-Wallet diese 100 Adressen generieren kann. Es stellt auch sicher, dass die
  Offline-Wallet diese Adressen erkennt, wenn sie eine PSBT zum Signieren erhält."
  a5link="https://bitcoincore.reviews/32489#l-122"
%}

## Optech empfiehlt

[Bitcoin++ Insider][] hat damit begonnen, leserfinanzierte Nachrichten über
technische Bitcoin-Themen zu veröffentlichen. Zwei ihrer kostenlosen wöchentlichen
Newsletter, _Last Week in Bitcoin_ und _This Week in Bitcoin Core_, könnten
besonders interessant für regelmäßige Leser des Optech-Newsletters sein.

## Releases und Release-Kandidaten

_Neue Releases und Release-Kandidaten für beliebte Bitcoin-Infrastrukturprojekte.
Bitte erwägen Sie, auf neue Versionen zu aktualisieren oder bei der Testung von
Release-Kandidaten zu helfen._

- [LND v0.19.3-beta.rc1][] ist ein Release-Kandidat für eine Wartungsversion dieser
  beliebten LN-Knoten-Implementierung, die "wichtige Bugfixes" enthält. Besonders
  erwähnenswert ist "eine optionale Migration [...], die Festplatten- und Speicheranforderungen
  für Knoten erheblich senkt".

- [BTCPay Server 2.2.0][] ist ein Release dieser beliebten selbst gehosteten
  Zahlungslösung. Es fügt Unterstützung für Wallet-Richtlinien und [Miniscript][topic miniscript]
  hinzu, bietet zusätzliche Unterstützung für Transaktionsgebühren-Management und
  -Überwachung und beinhaltet mehrere andere neue Verbesserungen und Bugfixes.

- [Bitcoin Core 29.1rc1][] ist ein Release-Kandidat für eine Wartungsversion der
  führenden Full-Node-Software.

## Wichtige Code- und Dokumentationsänderungen

_Wichtige aktuelle Änderungen in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo] und [BINANAs][binana repo]._

- [Bitcoin Core #32941][] vervollständigt die Überarbeitung von `TxOrphanage` (siehe
  [Newsletter #364][news364 orphan]), indem es das automatische Trimmen des
  Orphanage aktiviert, wann immer dessen Limits überschritten werden.
  Es fügt eine Warnung für `maxorphantx`-Benutzer hinzu, um sie darüber zu informieren,
  dass es veraltet ist. Dieser PR festigt das opportunistische
  One-Parent-One-Child (1p1c) [Package Relay][topic package relay].

- [Bitcoin Core #31385][] lockert die
  `package-not-child-with-unconfirmed-parents`-Regel des `submitpackage`-RPC,
  um die Nutzung von 1p1c [Package Relay][topic package relay] zu verbessern. Pakete
  müssen nicht mehr die Eltern-Transaktionen enthalten, die bereits im Mempool des Knotens sind.

- [Bitcoin Core #31244][] implementiert das Parsen von
  [MuSig2][topic musig][Deskriptoren][topic descriptors] wie in [BIP390][]
  definiert, was erforderlich ist
  für das Empfangen und Ausgeben von Inputs von [Taproot][topic taproot]-Adressen mit
  MuSig2-Aggregatschlüsseln.

- [Bitcoin Core #30635][] beginnt damit, die `waitfornewblock`,
  `waitforblock` und `waitforblockheight` RPCs in der Hilfe-Kommando-Antwort
  anzuzeigen, was signalisiert, dass sie für normale Benutzer gedacht sind. Dieser PR
  fügt auch ein optionales `current_tip`-Argument zum `waitfornewblock`-RPC hinzu,
  um Race Conditions zu mildern, indem der Block-Hash der aktuellen Chain-Spitze
  spezifiziert wird.

- [Bitcoin Core #28944][] fügt Anti-[Fee Sniping][topic fee sniping]-Schutz
  zu Transaktionen hinzu, die mit den `send`- und `sendall`-RPC-Kommandos gesendet werden,
  indem eine zufällige spitzenrelative [Locktime][topic timelocks] hinzugefügt wird,
  falls noch keine spezifiziert ist.

- [Eclair #3133][] erweitert sein [HTLC-Endorsement][topic htlc endorsement] lokales
  Peer-Reputations-System (siehe [Newsletter #363][news363 reputation]), um die
  Reputation von ausgehenden Peers zu bewerten, genau wie bei eingehenden Peers.
  Eclair würde nun eine gute Reputation in beide Richtungen berücksichtigen, wenn
  ein HTLC weitergeleitet wird, implementiert aber noch keine Strafen. Die Bewertung
  ausgehender Peers ist notwendig, um Sink-Attacken zu verhindern (siehe
  [Newsletter #322][news322 sink]), eine spezifische Art von
  [Channel Jamming Attack][topic channel jamming attacks].

- [LND #10097][] führt eine asynchrone, peer-spezifische Warteschlange für Backlog
  [Gossip][topic channel announcements]-Anfragen (`GossipTimestampRange`) ein, um
  das Risiko von Deadlocks zu eliminieren, wenn ein Peer zu viele Anfragen auf einmal sendet.
  Falls ein Peer eine Anfrage sendet, bevor die vorherige abgeschlossen ist, wird die
  zusätzliche Nachricht stillschweigend verworfen. Eine neue `gossip.filter-concurrency`-Einstellung
  (Standard 5) wird hinzugefügt, um die Anzahl gleichzeitiger Worker über alle Peers hinweg
  zu begrenzen. Der PR fügt auch Dokumentation hinzu, die erklärt, wie alle
  Gossip-Rate-Limit-Konfigurationseinstellungen funktionieren.

- [LND #9625][] fügt ein `deletecanceledinvoice`-RPC-Kommando (und sein `lncli`-Äquivalent)
  hinzu, das es Benutzern ermöglicht, stornierte [BOLT11][]-Rechnungen zu entfernen (siehe
  [Newsletter #33][news33 canceled]), indem sie deren Payment-Hash angeben.

- [Rust Bitcoin #4730][] fügt einen `Alert`-Typ-Wrapper für die [finale Alert][final alert]-Nachricht
  hinzu, die Peers mit einer verwundbaren Version von Bitcoin Core (vor 0.12.1)
  benachrichtigt, dass ihr Alert-System unsicher ist. Satoshi führte das Alert-System
  ein, um Benutzer über bedeutende Netzwerk-Ereignisse zu informieren, aber es wurde
  in Version 0.12.1 [eingestellt][retired], außer für die finale Alert-Nachricht.

- [BLIPs #55][] fügt [BLIP55][] hinzu, um zu spezifizieren, wie mobile Clients sich
  für Webhooks über einen Endpunkt registrieren können, um Push-Benachrichtigungen
  von einem LSP zu erhalten. Dieses Protokoll ist nützlich für Clients, um benachrichtigt
  zu werden, wenn sie eine [asynchrone Zahlung][topic async payments] erhalten, und
  wurde kürzlich in LDK implementiert (siehe [Newsletter #365][news365 webhook]).

## Korrektur

Im [Newsletter der letzten Woche][news365 p2qrh] haben wir fälschlicherweise die
aktualisierte Version von [BIP360][], _Pay to Quantum-Resistant Hash_, als
"genau die Änderung machend" beschrieben, die Tim Ruffing in seinem
[kürzlichen Paper][ruffing paper] als sicher gezeigt hat. Was BIP360 tatsächlich macht,
ist das Ersetzen des elliptischen Kurven-Commitments zu einer SHA256-basierten
Merkle-Root (plus einer Keypath-Alternative) durch ein SHA256-Commitment direkt
zur Merkle-Root. Ruffings Paper zeigte, dass Taproot, wie es derzeit verwendet wird,
sicher ist, wenn ein quantum-resistentes Signaturschema zur [Tapscript][topic tapscript]-Sprache
hinzugefügt und Keypath-Ausgaben deaktiviert würden. BIP360 erfordert stattdessen,
dass Wallets auf eine Variante von Taproot upgraden (wenn auch eine triviale Variante),
eliminiert den Keypath-Mechanismus aus seiner Variante und beschreibt das Hinzufügen
eines quantum-resistenten Signaturschemas zur Skriptsprache, die in seinen Tapleaves
verwendet wird. Obwohl Ruffings Paper nicht auf die in BIP360 vorgeschlagene
Taproot-Variante anwendbar ist, folgt die Sicherheit dieser Variante (wenn als
Commitment betrachtet) unmittelbar aus der Sicherheit des Merkle-Baums.

Wir entschuldigen uns für den Fehler und danken Tim Ruffing dafür, dass er uns
auf unseren Fehler aufmerksam gemacht hat.

{% include snippets/recap-ad.md when="2025-08-12 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="33106,32941,31385,31244,30635,28944,3133,10097,9625,4730,55" %}
[bitcoin core 29.1rc1]: https://bitcoincore.org/bin/bitcoin-core-29.1/
[bitcoin++ insider]: https://insider.btcpp.dev/
[news365 p2qrh]: /de/newsletters/2025/08/01/#sicherheit-gegen-quantencomputer-mit-taproot-als-commitment-schema
[zhao minfee]: https://delvingbitcoin.org/t/changing-the-minimum-relay-feerate/1886/
[towns tempshare]: https://delvingbitcoin.org/t/sharing-block-templates/1906
[towns tempshare poc]: https://github.com/ajtowns/bitcoin/commit/ee12518a4a5e8932175ee57c8f1ad116f675d089
[news299 weak blocks]: /en/newsletters/2024/04/24/#weak-blocks-proof-of-concept-implementation
[ruffing paper]: https://eprint.iacr.org/2025/1307
[kim bips]: https://mailing-list.bitcoindevs.xyz/bitcoindev/3452b63c-ff2b-4dd9-90ee-83fd9cedcf4an@googlegroups.com/
[ubip1]: https://github.com/utreexo/biptreexo/blob/7ae65222ba82423c1a3f2edd6396c0e32679aa37/utreexo-accumulator-bip.md
[ubip2]: https://github.com/utreexo/biptreexo/blob/7ae65222ba82423c1a3f2edd6396c0e32679aa37/utreexo-validation-bip.md
[ubip3]: https://github.com/utreexo/biptreexo/blob/7ae65222ba82423c1a3f2edd6396c0e32679aa37/utreexo-p2p-bip.md
[btcpay server 2.2.0]: https://github.com/btcpayserver/btcpayserver/releases/tag/v2.2.0
[lnd v0.19.3-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.19.3-beta.rc1
[review club 32489]: https://bitcoincore.reviews/32489
[gh achow101]: https://github.com/achow101
[news363 reputation]: /de/newsletters/2025/07/18/#eclair-2716
[news322 sink]: /en/newsletters/2024/09/27/#hybrid-jamming-mitigation-testing-and-changes
[news33 canceled]: /en/newsletters/2019/02/12/#lnd-2457
[final alert]: https://bitcoin.org/en/release/v0.14.0#final-alert
[retired]: https://bitcoin.org/en/alert/2016-11-01-alert-retirement#updates
[news365 webhook]: /de/newsletters/2025/08/01/#ldk-3662
[news364 orphan]: /de/newsletters/2025/07/25/#bitcoin-core-31829