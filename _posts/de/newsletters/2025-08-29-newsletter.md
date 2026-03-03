---
title: 'Bitcoin Optech Newsletter #369'
permalink: /de/newsletters/2025/08/29/
name: 2025-08-29-newsletter-de
slug: 2025-08-29-newsletter-de
type: newsletter
layout: newsletter
lang: de
---
Der Newsletter dieser Woche enthält ein Update zum differenziellen Fuzzing
von Bitcoin- und LN-Implementierungen und verweist auf eine neue Arbeit
zu "garbled locks" für nachvollziehbare Computing-Verträge. Außerdem
enthalten sind unsere regelmäßigen Abschnitte mit beliebten Fragen und
Antworten aus Bitcoin Stack Exchange, Ankündigungen neuer Releases und
Release-Kandidaten sowie einer Zusammenfassung bedeutender Änderungen
an wichtiger Bitcoin-Infrastruktur-Software.

## Nachrichten

- **Update zum differenziellen Fuzzing von Bitcoin- und LN-Implementierungen:**
  Bruno Garcia [berichtete][garcia fuzz] in Delving Bitcoin über aktuelle
  Fortschritte und Ergebnisse von [bitcoinfuzz][], einer Bibliothek und
  zugehörigen Daten für [fuzz testing][] von Bitcoin-basierter Software und
  Bibliotheken. Zu den Erfolgen zählt die Entdeckung von "über 35 Bugs in
  Projekten wie btcd, rust-bitcoin, rust-miniscript, Embit, Bitcoin Core,
  Core Lightning und LND". Gefundene Unterschiede zwischen LN-Implementierungen
  haben nicht nur Fehler aufgedeckt, sondern auch zu Klarstellungen in der
  LN-Spezifikation geführt. Entwickler von Bitcoin-Projekten werden ermutigt,
  ihre Software als unterstütztes Ziel für bitcoinfuzz zu prüfen.

- **Garbled Locks für nachvollziehbare Computing-Verträge:** Liam Eagen
  [stellte][eagen glock] in der Bitcoin-Dev-Mailingliste eine
  [Arbeit][eagen paper] zu einem neuen Mechanismus für die Erstellung von
  [nachvollziehbaren Computing-Verträgen][topic acc] vor, der auf
  [garbled circuits][] basiert. Dies ähnelt (ist aber verschieden von)
  anderen aktuellen Arbeiten zu Garbled Circuits für BitVM (siehe
  [Newsletter #359][news359 delbrag]). Eagen behauptet, dass sein Ansatz
  "das erste (seiner Meinung nach) praktische Garbled Lock ist, dessen
  Betrugsnachweis eine einzelne Signatur ist, was eine über 550-fache
  Reduktion der Onchain-Daten gegenüber BitVM2 bedeutet." Zum Zeitpunkt
  des Schreibens gab es noch keine öffentlichen Antworten auf seinen Post.

## Ausgewählte Fragen & Antworten von Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] ist eine der ersten Anlaufstellen für
Optech-Mitwirkende, wenn sie Antworten auf ihre Fragen suchen – oder wenn wir
ein paar freie Minuten haben, um neugierigen oder ratlosen Nutzern zu helfen.
In dieser monatlichen Rubrik heben wir einige der am höchsten bewerteten Fragen
und Antworten hervor, die seit unserem letzten Update gepostet wurden.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

 - [Ist es möglich, einen privaten Schlüssel aus einem aggregierten öffentlichen Schlüssel unter starken Annahmen wiederherzustellen?]({{bse}}127723)
   Pieter Wuille erläutert aktuelle und hypothetische Sicherheitsannahmen rund um
   [MuSig2][topic musig] scriptless [Multisignaturen][topic multisignature].

 - [Sind alle Taproot-Adressen anfällig für Quantencomputing?]({{bse}}127660)
   Hugo Nguyen und Murch weisen darauf hin, dass selbst [Taproot][topic taproot]-Outputs,
   die nur über Skriptpfade ausgegeben werden können, gegenüber [Quanten][topic quantum resistance]
   verwundbar sind. Murch merkt an: "Interessanterweise könnte die Partei, die das Output-Skript
   erzeugt hat, zeigen, dass der interne Schlüssel ein NUMS-Punkt war und damit beweisen,
   dass eine Quantenentschlüsselung stattgefunden hat."

 - [Warum kann man den Chainstate-Verschlüsselungsschlüssel nicht setzen?]({{bse}}127814)
   Ava Chow hebt hervor, dass der Schlüssel, der die Inhalte des `blocksdir` auf der Festplatte
   verschleiert (siehe [Newsletter #339][news339 blocksxor]), nicht derselbe ist wie der Schlüssel,
   der die Inhalte von `chainstate` verschleiert (siehe [Bitcoin Core #6650][]).

 - [Ist es möglich, einen Ausgabepfad nach einer Blockhöhe zu widerrufen?]({{bse}}127683)
   Antoine Poinsot verweist auf eine [frühere Antwort]({{bse}}122224), die bestätigt,
   dass auslaufende Ausgabebedingungen oder "inverse Timelocks" nicht möglich und
   vielleicht auch nicht wünschenswert sind.

 - [Bitcoin Core so konfigurieren, dass Onion-Nodes zusätzlich zu IPv4- und IPv6-Nodes verwendet werden?]({{bse}}127727)
   Pieter Wuille stellt klar, dass die Einstellung der Option `onion` nur für ausgehende Peer-Verbindungen gilt.
   Er beschreibt außerdem, wie [Tor][topic anonymity networks] und `bitcoind` für eingehende Verbindungen
   konfiguriert werden können.

## Releases und Release-Kandidaten

_Neue Releases und Release-Kandidaten für beliebte Bitcoin-Infrastrukturprojekte.
Bitte erwägen Sie, auf neue Versionen zu aktualisieren oder bei der Testung von
Release-Kandidaten zu helfen._

 - [Bitcoin Core 29.1rc2][] ist ein Release-Kandidat für eine Wartungsversion
   der führenden Full-Node-Software.

 - [Core Lightning v25.09rc4][] ist ein Release-Kandidat für eine neue Hauptversion
   dieser beliebten LN-Knoten-Implementierung.

## Wichtige Code- und Dokumentationsänderungen

_Wichtige aktuelle Änderungen in [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning repo],
[Eclair][eclair repo], [LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo],
[Hardware Wallet Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay Server][btcpay server repo],
[BDK][bdk repo], [BIPs][bips repo], [BOLTs][bolts repo], [BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition repo]
und [BINANAs][binana repo]._

 - [Bitcoin Core #31802][] aktiviert standardmäßig die Interprozesskommunikation (IPC)
   (`ENABLE_IPC`) und fügt die Multiprozess-Binaries `bitcoin-node` und `bitcoin-gui`
   zu den Release-Builds auf allen Systemen außer Windows hinzu. Dadurch kann ein externer
   [Stratum v2][topic pooled mining]-Mining-Service, der Block-Templates erstellt, verwaltet und
   einreicht, mit dem Multiprozess-Layout experimentieren, ohne eigene Builds zu benötigen.
   Weitere Informationen zum Multiprozess-Projekt und zum `bitcoin-node`-Binary finden sich in den
   Newslettern [#99][news99 ipc], [#147][news147 ipc], [#320][news320 ipc] und [#323][news323 ipc].

 - [LDK #3979][] fügt Unterstützung für Splice-Out hinzu und ermöglicht einem LDK-Knoten,
   sowohl eine Splice-Out-Transaktion zu initiieren als auch Anfragen von Gegenparteien zu akzeptieren.
   Damit ist die [Splicing][topic splicing]-Implementierung in LDK abgeschlossen, da [LDK #3736][]
   bereits Splice-In-Unterstützung hinzugefügt hat. Der PR führt ein `SpliceContribution`-Enum ein,
   das sowohl In- als auch Out-Szenarien abdeckt und sicherstellt, dass die Output-Werte einer
   Splice-Out-Transaktion nach Abzug von Gebühren und Reserven den Kanal-Saldo nicht überschreiten.

 - [LND #10102][] fügt eine Option `gossip.ban-threshold` hinzu (Standardwert 100, 0 deaktiviert),
   mit der Nutzer den Schwellenwert konfigurieren können, ab dem ein Peer für das Senden ungültiger
   [Gossip][topic channel announcements]-Nachrichten gebannt wird. Das Peer-Banning-System wurde
   zuvor eingeführt und in [Newsletter #319][news319 ban] behandelt. Der PR behebt außerdem ein
   Problem, bei dem unnötige Node- und [Kanal Announcement][topic channel announcements]-Nachrichten
   als Antwort auf eine Backlog-Gossip-Abfrage gesendet wurden.

 - [Rust Bitcoin #4907][] führt Script-Tagging ein, indem ein generischer Tag-Parameter `T`
   zu `Script` und `ScriptBuf` hinzugefügt wird. Es werden die Typ-Aliase `ScriptPubKey`,
   `ScriptSig`, `RedeemScript`, `WitnessScript` und `TapScript` definiert, die durch ein
   versiegeltes `Tag`-Trait für Kompilierzeit-Rollensicherheit abgesichert sind.

{% include snippets/recap-ad.md when="2025-09-02 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="31802,3979,10102,4907,6650,3736" %}
[bitcoin core 29.1rc2]: https://bitcoincore.org/bin/bitcoin-core-29.1/
[core lightning v25.09rc4]: https://github.com/ElementsProject/lightning/releases/tag/v25.09rc4
[garcia fuzz]: https://delvingbitcoin.org/t/the-state-of-bitcoinfuzz/1946
[bitcoinfuzz]: https://github.com/bitcoinfuzz
[fuzz testing]: https://en.wikipedia.org/wiki/Fuzzing
[eagen glock]: https://mailing-list.bitcoindevs.xyz/bitcoindev/Aq_-LHZtVdSN5nODCryicX2u_X1yAQYurf9UDZXDILq6s4grUOYienc4HH2xFnAohA69I_BzgRCSKdW9OSVlSU9d1HYZLrK7MS_7wdNsLmo=@protonmail.com/
[eagen paper]: https://eprint.iacr.org/2025/1485
[garbled circuits]: https://en.wikipedia.org/wiki/Garbled_circuit
[news359 delbrag]: /de/newsletters/2025/06/20/#verbesserungen-bei-bitvm-artigen-vertragen
[news339 blocksxor]: /de/newsletters/2025/01/31/#wie-funktioniert-der-blocksxor-schalter-der-die-blocks-dat-dateien-verschleiert
[news99 ipc]: /en/newsletters/2020/05/27/#bitcoin-core-18677
[news147 ipc]: /en/newsletters/2021/05/05/#bitcoin-core-19160
[news320 ipc]: /en/newsletters/2024/09/13/#bitcoin-core-30509
[news323 ipc]: /en/newsletters/2024/10/04/#bitcoin-core-30510
[news319 ban]: /en/newsletters/2024/09/06/#lnd-9009
