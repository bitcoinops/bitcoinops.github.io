---
title: 'Bitcoin Optech Newsletter #343'
permalink: /de/newsletters/2025/02/28/
name: 2025-02-28-newsletter-de
slug: 2025-02-28-newsletter-de
type: newsletter
layout: newsletter
lang: de
---
Der Newsletter dieser Woche fasst einen Beitrag darüber zusammen, dass
Full Nodes Transaktionen ignorieren sollen, die ohne vorherige Anforderung
weitergeleitet werden. Außerdem enthalten sind unsere regelmäßigen Abschnitte
mit beliebten Fragen und Antworten aus dem Bitcoin Stack Exchange, Ankündigungen
neuer Releases und Release-Kandidaten sowie Zusammenfassungen wichtiger
Änderungen an beliebter Bitcoin-Infrastruktursoftware.

## News

- **Ignorieren unaufgeforderter Transaktionen:** Antoine Riard
  [postete][riard unsol] auf Bitcoin-Dev zwei Entwürfe für BIPs, die es
  einem Node ermöglichen würden zu signalisieren, dass er keine `tx`-Nachrichten
  mehr akzeptiert, die nicht zuvor mit einer `inv`-Nachricht angefordert wurden,
  sogenannte _unaufgeforderte Transaktionen_. Riard hatte die allgemeine Idee bereits
  2021 vorgeschlagen (siehe [Newsletter #136][news136 unsol]). Das erste vorgeschlagene
  BIP enthält einen Mechanismus, der es Knoten erlaubt, ihre Möglichkeiten zur Weiterleitung von
  Transaktionsrouting und Präferenzen zu signalisieren. Das zweite vorgeschlagene
  BIP verwendet diesen Signalisierungsmechanismus, um anzuzeigen, dass der Node
  unaufgeforderte Transaktionen ignorieren wird.

  Es gibt mehrere kleine Vorteile des Vorschlags, wie in einem
  [Bitcoin Core Pull Request][bitcoin core #30572] diskutiert, aber es widerspricht dem
  Design einiger älterer Lightweight-Clients und könnte Benutzer dieser Software daran
  hindern, ihre Transaktionen zu senden, so dass eine sorgfältige Implementierung erforderlich
  sein könnte. Obwohl Riard den erwähnten Pull Request eröffnete, schloss er ihn später wieder,
  nachdem er angedeutet hatte, dass er an seiner eigenen Full Node Implementierung auf Basis von
  libbitcoinkernel arbeiten wolle. Er deutete auch an, dass der Vorschlag helfen würde, einige der
  Angriffe zu adressieren, die er kürzlich offengelegt hatte (siehe [Newsletter #332][news332 txcen]).

## Ausgewählte Fragen und Antworten aus dem Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] ist einer der ersten Orte, an denen
Optech-Mitwirkende nach Antworten auf ihre Fragen suchen - oder wenn wir
ein paar freie Momente haben, um neugierigen oder verwirrten Benutzern zu
helfen. In diesem monatlichen Feature heben wir einige der am besten bewerteten
Fragen und Antworten hervor, die seit unserem letzten Update gepostet wurden.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Was ist der Grund für die Einrichtung des loadtxsoutset RPC?]({{bse}}125627)
  Pieter Wuille erklärt, warum der Wert von [assumeUTXO][topic assumeUTXO] zur
  Darstellung des UTXO-Sets auf eine bestimmte Blockhöhe festgelegt ist,
  Möglichkeiten zur Verteilung von assumeUTXO-Snapshots in der Zukunft und die
  Vorteile von assumeUTXO im Vergleich zum einfachen Kopieren der internen
  Datenspeicher von Bitcoin Core.

- [Gibt es Klassen von Pinning-Angriffen, die RBF-Regel #3 unmöglich macht?]({{bse}}125461)
  Murch weist darauf hin, dass [RBF][topic rbf] Regel #3 nicht dazu gedacht ist,
  [Pinning][topic transaction pinning] Angriffe zu verhindern, und geht auf die
  [Ersatzrichtlinie][bitcoin core replacements] von Bitcoin Core ein.

- [Unerwartete Locktime-Werte]({{bse}}125562)
  Benutzer polespinasa listet die verschiedenen Gründe auf, warum Bitcoin Core
  bestimmte [nLockTime][topic timelocks] Werte setzt: auf `block_height`, um
  [Fee Sniping][topic fee sniping] zu vermeiden, einen zufälligen Wert unterhalb
  der Blockhöhe 10% der Zeit für die Privatsphäre oder 0, wenn die Blockchain
  nicht aktuell ist.

- [Warum ist es notwendig,]({{bse}}125502) ein Bit in einem Skriptpfad auszugeben
  und zu überprüfen, ob es mit der Parität der Y-Koordinate von Q übereinstimmt?
  Pieter Wuille erläutert die [BIP341-Rationale][bip341 rationale], die
  Y-Koordinaten-Paritätsprüfung während des [Taproot][topic taproot]
  Skriptpfad-Ausgebens beizubehalten, um die potenzielle zukünftige
  Hinzufügung von Batch-Validierungsfunktionen zu ermöglichen.

- [Warum verwendet Bitcoin Core Checkpoints und nicht den assumevalid Block?]({{bse}}125626)
  Pieter Wuille beschreibt die Geschichte der Checkpoints in Bitcoin Core und
  welchen Zweck sie erfüllten, und verweist auf einen offenen PR und die
  Diskussion über das [Entfernen von Checkpoints][Bitcoin Core #31649].

- [Wie geht Bitcoin Core mit langen Blockchain-Reorganisationen um?]({{bse}}105525)
  Pieter Wuille beschreibt, wie Bitcoin Core mit Reorganisationen der Blockchain
  umgeht und kommentiert, dass bei größeren Reorganisationen "das erneute Hinzufügen
  von Transaktionen zum Mempool nicht durchgeführt wird".

- [Was ist die Definition der discard feerate?]({{bse}}125623)
  Murch definiert die discard feerate als die maximale Feerate zum Verwerfen von
  Wechselgeld und fasst den Code zur Berechnung der discard feerate zusammen als
  "die 1000-Block-Ziel-Feerate, die auf 3–10 ṩ/vB beschnitten wird, wenn sie
  außerhalb dieses Bereichs liegt".

- [Policy zu Miniscript-Compiler]({{bse}}125406)
  Brunoerg stellt fest, dass die Liana-Wallet die Policy-Sprache verwendet und
  verweist sowohl auf die [sipa/miniscript][miniscript github] als auch auf die
  [rust-miniscript][rust-miniscript github] Bibliotheken als Beispiele für
  Policy-Compiler.

## Releases und Release-Kandidaten

_Neue Releases und Release-Kandidaten für beliebte Bitcoin-Infrastrukturprojekte.
Bitte erwägen Sie ein Upgrade auf neue Releases oder helfen Sie bei der Testung
von Release-Kandidaten._

- [Core Lightning 25.02rc3][] ist ein Release-Kandidat für die nächste Hauptversion
dieses beliebten LN-Nodes.

## Wichtiger Code- und Dokumentationsänderungen

_Wichtiger aktuelle Änderungen in [Bitcoin Core][bitcoin core repo],
[Core Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet Interface
(HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay Server][btcpay server repo],
[BDK][bdk repo], [Bitcoin Improvement Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition repo] und
[BINANAs][binana repo]._

- [Core Lightning #8116][] ändert die Handhabung unterbrochener Kanalabschlussverhandlungen,
um den Prozess auch dann erneut zu versuchen, wenn dies nicht erforderlich ist. Dies behebt
ein Problem, bei dem ein Node, dem die `CLOSING_SIGNED`-Nachricht seines Peers fehlt, beim
erneuten Verbinden einen Fehler erhält und eine einseitige Abschluss-Transaktion sendet.
In der Zwischenzeit hat der Peer, der sich bereits im Zustand `CLOSINGD_COMPLETE` befindet,
die gegenseitige Abschluss-Transaktion gesendet, was potenziell zu einem Wettlauf zwischen
den beiden Transaktionen führen kann. Diese Korrektur ermöglicht es, die Verhandlungen
fortzusetzen, bis die gegenseitige Abschluss-Transaktion bestätigt ist.

- [Core Lightning #8095][] fügt dem `setconfig`-Befehl ein `transient`-Flag hinzu
(siehe Newsletter [#257][news257 setconfig]), das dynamische Konfigurationsvariablen
einführt, die vorübergehend angewendet werden, ohne die Konfigurationsdatei zu ändern.
Diese Änderungen werden beim Neustart zurückgesetzt.

- [Core Lightning #7772][] fügt dem `chanbackup`-Plugin einen `commitment_revocation`-Hook
hinzu, der die `emergency.recover`-Datei (siehe Newsletter [#324][news324 emergency])
aktualisiert, wann immer ein neues Widerrufsgeheimnis empfangen wird. Dies ermöglicht es
Benutzern, eine Straftransaktion zu senden, wenn sie Mittel mit `emergency.recover` abheben,
falls der Peer einen veralteten widerrufenen Zustand veröffentlicht hat. Dieser PR erweitert
das [statische Kanal-Backup][topic static channel backups] SCB-Format und aktualisiert das
`chanbackup`-Plugin, um sowohl das neue als auch das alte Format zu serialisieren.

- [Core Lightning #8094][] führt eine zur Laufzeit konfigurierbare `xpay-slow-mode`-Variable
in das `xpay`-Plugin ein (siehe Newsletter [#330][news330 xpay]), das die Rückgabe von Erfolg
oder Misserfolg verzögert, bis alle Teile einer [Multipath-Zahlung][topic multipath payments]
(MPP) aufgelöst sind. Ohne diese Einstellung könnte ein Fehlerstatus zurückgegeben werden,
selbst wenn einige [HTLCs][topic htlc] noch ausstehen. Wenn ein Benutzer erneut versucht und
die Rechnung von einem anderen Node erfolgreich bezahlt, könnte eine Überzahlung auftreten,
wenn das ausstehende HTLC ebenfalls beglichen wird.

- [Eclair #2993][] ermöglicht es dem Empfänger, die Gebühren für den [geblendeten][topic rv routing]
Teil eines Zahlungspfads zu übernehmen, während der Absender die Gebühren für den nicht
geblendeten Teil übernimmt. Zuvor zahlte der Absender alle Gebühren, was es ihm ermöglichen
könnte, den Pfad zu entschlüsseln und potenziell zu entblenden.

- [LND #9491][] fügt Unterstützung für kooperative Kanalabschlüsse hinzu, wenn aktive
[HTLCs][topic htlc] mit dem `lncli closechannel`-Befehl verwendet werden. Wenn dies initiiert
wird, wird LND den Kanal anhalten, um die Erstellung neuer HTLCs zu verhindern, und warten,
bis alle bestehenden HTLCs aufgelöst sind, bevor der Verhandlungsprozess beginnt. Benutzer
müssen den Parameter `no_wait` festlegen, um dieses Verhalten zu aktivieren; andernfalls wird
eine Fehlermeldung angezeigt, die sie auffordert, ihn anzugeben. Dieser PR stellt auch sicher,
dass die Einstellung `max_fee_rate` für beide Parteien bei einem kooperativen Kanalabschluss
durchgesetzt wird; zuvor wurde sie nur auf die entfernte Partei angewendet.

{% include snippets/recap-ad.md when="2025-03-04 15:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="30572,8116,8095,7772,8094,2993,9491,31649" %}
[riard unsol]: https://mailing-list.bitcoindevs.xyz/bitcoindev/e98ec3a3-b88b-4616-8f46-58353703d206n@googlegroups.com/
[news136 unsol]: /en/newsletters/2021/02/17/#proposal-to-stop-processing-unsolicited-transactions
[news332 txcen]: /en/newsletters/2024/12/06/#transaction-censorship-vulnerability
[Core Lightning 25.02rc3]: https://github.com/ElementsProject/lightning/releases/tag/v25.02rc3
[news257 setconfig]: /en/newsletters/2023/06/28/#core-lightning-6303
[news324 emergency]: /en/newsletters/2024/10/11/#core-lightning-7539
[news330 xpay]: /en/newsletters/2024/11/22/#core-lightning-7799
[bitcoin core replacements]: https://github.com/bitcoin/bitcoin/blob/master/doc/policy/mempool-replacements.md#current-replace-by-fee-policy
[bip341 rationale]: https://github.com/bitcoin/bips/blob/master/bip-0341.mediawiki#cite_note-10
[miniscript github]: https://github.com/sipa/miniscript
[rust-miniscript github]: https://github.com/rust-bitcoin/rust-miniscript
