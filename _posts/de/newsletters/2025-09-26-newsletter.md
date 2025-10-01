---
title: 'Bitcoin Optech Newsletter #373'
permalink: /de/newsletters/2025/09/26/
name: 2025-09-26-newsletter-de
slug: 2025-09-26-newsletter-de
type: newsletter
layout: newsletter
lang: de
---

Dieser Newsletter fasst eine Sicherheitslücke in älteren Eclair-Versionen sowie
Forschungsergebnisse zu Feerate-Einstellungen von Full Nodes zusammen. Außerdem
finden Sie wie gewohnt unsere Abschnitte mit ausgewählten Fragen & Antworten
von Bitcoin Stack Exchange, Ankündigungen zu neuen Releases und Release
Kandidaten sowie bemerkenswerte Änderungen an verbreiteter Bitcoin-Infrastruktur-Software.

## Nachrichten

- **Eclair-Sicherheitslücke:** Matt Morehouse [postete][morehouse eclair]
  auf Delving Bitcoin eine verantwortungsvolle Offenlegung
  ([responsible disclosure][topic responsible disclosures]) einer
  Sicherheitslücke in älteren Eclair-Versionen. Allen Eclair-Nutzern wird
  empfohlen, auf Version 0.12 oder neuer zu aktualisieren. Die Lücke ermöglichte
  es einem Angreifer, eine alte Commitment-Transaktion zu veröffentlichen und so
  alle aktuellen Mittel eines Kanals zu stehlen. Neben der Behebung der Lücke
  haben die Eclair-Entwickler eine umfangreiche Test-Suite hinzugefügt, um
  ähnliche Fehler künftig früher zu erkennen.

- **Untersuchung zu Feerate-Einstellungen:** Daniela Brozzoni [veröffentlichte][brozzoni feefilter]
  auf Delving Bitcoin die Ergebnisse eines Scans von fast 30.000 Full Nodes,
  die eingehende Verbindungen akzeptierten. Jeder Knoten wurde nach dem
  [BIP133][] Fee-Filter befragt, der die niedrigste Feerate angibt, bei welcher
  der Knoten aktuell unbestätigte, weitergeleitete Transaktionen akzeptiert.
  Solange die Mempools nicht voll sind, entspricht dies dem [standardmäßigen
  minimalen Relay-Feerate][topic default minimum transaction relay feerates]
  des Knotens. Die Auswertung zeigt, dass die meisten Knoten den bisherigen
  Standard von 1 sat/vbyte (s/v) verwenden. Etwa 4 % der Knoten nutzten 0,1 s/v,
  den Standard der kommenden Bitcoin Core 30.0, und rund 8 % antworteten gar
  nicht auf die Abfrage – was auf sogenannte Spy-Nodes hindeuten kann.

  Ein kleiner Anteil der Knoten gab den Wert 9.170.997 (10.000 s/v) als
  Feefilter an; Entwickler 0xB10C [merkte an][0xb10c feefilter], dass Bitcoin
  Core diesen, durch Rundung entstandenen, Wert setzt, wenn der Knoten mehr als
  100 Blöcke hinter dem Tip liegt und sich auf den Empfang von Blockdaten statt
  auf Transaktionen konzentriert, die in späteren Blöcken bestätigt werden könnten.

## Ausgewählte Fragen & Antworten von Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] ist eine der ersten Anlaufstellen für
Optech-Beitragende, wenn sie nach Antworten suchen – oder um in kurzen Pausen
fragenden Nutzern zu helfen. In diesem monatlichen Beitrag heben wir einige
der am besten bewerteten Fragen und Antworten seit unserem letzten Update hervor.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Auswirkungen der OP_RETURN-Änderungen in der kommenden Bitcoin Core-Version 30.0?]({{bse}}127895)
  Pieter Wuille erläutert seine Sicht auf Vor- und Nachteile der Nutzung von
  Mempool- und Relay-Policy, um den Inhalt geminter Blöcke zu beeinflussen
  ([policy series]).

- [Wenn OP_RETURN-Relay-Limits unwirksam sind: Warum das Schutzmittel entfernen statt es als Standardabschreckung zu belassen?]({{bse}}127904)
  Antoine Poinsot erklärt den Fehlanreiz, den der aktuelle Standardwert für
  OP_RETURN in Bitcoin Core erzeugt, und die Gründe für dessen Entfernung.

- [Was sind Worst-Case-Stress-Szenarien durch unbeschränkte OP_RETURNs in Bitcoin Core v30?]({{bse}}127914)
  Vojtěch Strnad und Pieter Wuille gehen auf eine Liste extremer Szenarien ein,
  die durch die Änderung der Standard-Policy für OP_RETURN entstehen könnten.

- [Wenn OP_RETURN mehr Platz gebraucht hätte: Warum wurde das 80-Byte-Limit entfernt statt auf 160 erhöht?]({{bse}}127915)
  Ava Chow und Antoine Poinsot führen Gründe gegen einen Standardwert von 160
  Bytes an, darunter die Abneigung, das Limit ständig anheben zu müssen, dass
  große Miner das Limit ohnehin umgehen, und Risiken, künftige On-Chain-Aktivität
  nicht ausreichend zu antizipieren.

- [Wenn beliebige Daten unvermeidlich sind: Führt das Entfernen des OP_RETURN-Limits zu mehr schädlichen Speicherpraktiken (z. B. UTXO-aufblähende Adressen)?]({{bse}}127916)
  Ava Chow weist darauf hin, dass das Entfernen des OP_RETURN-Limits Anreize
  schafft, für bestimmte Anwendungsfälle eine weniger schädliche Alternative zur
  Speicherung von Ausgabedaten zu nutzen.

- [Wenn OP_RETURN-Uncapping das UTXO-Set nicht vergrößert: Wie trägt es trotzdem zu Blockchain-Bloat und Zentralisierungsdruck bei?]({{bse}}127912)
  Ava Chow erklärt, wie vermehrte Nutzung von OP_RETURN-Ausgaben die
  Ressourcenbelastung von Bitcoin-Knoten erhöht.

- [Wie beeinflusst das Aufheben der OP_RETURN-Begrenzung die langfristige Qualität des Fee-Markts und das Security-Budget?]({{bse}}127906)
  Ava Chow beantwortet mehrere Fragen zu hypothetischer OP_RETURN-Nutzung und
  deren Auswirkungen auf zukünftige Mining-Einnahmen.

- [Ist die Blockchain vor illegalen Inhalten bei 100KB OP_RETURN geschützt?]({{bse}}127958)
  Nutzer jb55 liefert mehrere Beispiele möglicher Kodierschemata und kommt zu
  dem Schluss: "Nein, im Allgemeinen kann man solche Dinge in einem zensurresistenten,
  dezentralen Netzwerk nicht wirklich verhindern."

- [Welche Analyse zeigt, dass OP_RETURN-Uncapping die Block-Propagation oder das Orphan-Risiko nicht verschlechtert?]({{bse}}127905)
  Ava Chow weist darauf hin, dass es zwar keinen Datensatz gibt, der speziell
  große OP_RETURNs isoliert, frühere Analysen zu [compact blocks][topic compact block
  relay] und Stale-Blocks jedoch keinen Grund liefern, ein anderes Verhalten zu erwarten.

- [Wo speichert Bitcoin Core die XOR-Obfuskationsschlüssel für Blockdaten-Dateien und LevelDB-Indizes?]({{bse}}127927)
  Vojtěch Strnad erklärt, dass der Chainstate-Schlüssel in LevelDB unter dem
  Schlüssel "\000obfuscate_key" liegt, während der Schlüssel für Block- und
  Undo-Daten in der Datei blocks/xor.dat gespeichert wird.

- [Wie robust ist der 1p1c-Transaction-Relay in Bitcoin Core 28.0?]({{bse}}127873)
  Glozow stellt klar, dass mit "nicht robust" in dem ursprünglichen PR zum
  opportunistischen "one parent one child (1P1C) relay" gemeint ist, dass das
  Verhalten nicht garantiert funktioniert, besonders in Gegenwart von
  Angreifern oder bei sehr hohem Transaktionsaufkommen.

- [Wie kann ich getblocktemplate erlauben, Transaktionen unter 1 sat/vbyte einzuschließen?]({{bse}}127881)
  Nutzer inersha beschreibt die nötigen Einstellungen, um nicht nur sub-1-sat/vbyte
  Transaktionen weiterzuleiten, sondern diese auch in einem Kandidatenblock-Template
  aufzunehmen.

## Releases und Release-Kandidaten

_Neue Releases und Release-Kandidaten für verbreitete Bitcoin-Infrastrukturprojekte.
Bitte erwägen Sie ein Upgrade auf neue Releases oder helfen Sie beim Testen von Release-Candidates._

- [Bitcoin Core 30.0rc1][] ist ein Release Candidate für die nächste
  Hauptversion der vollständigen Verifikations-Knoten-Software. Siehe bitte den
  [Testing-Guide für Version 30][bcc30 testing].

## Wichtige Code- und Dokumentationsänderungen

_Bemerkenswerte Änderungen in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo], [Lightning
BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition repo] und
[BINANAs][binana repo]._

- [Bitcoin Core #33333][] gibt nun eine Startwarnung aus, wenn die `dbcache`
  Einstellung eines Knotens einen Schwellenwert überschreitet, der aus dem
  verfügbaren Arbeitsspeicher des Systems abgeleitet wird. Das soll
  Out-of-Memory-Fehler oder intensives Swapping verhindern. Für Systeme mit
  weniger als 2 GB RAM liegt die `dbcache`-Warnschwelle bei 450 MB; andernfalls
  beträgt die Schwelle 75 % des gesamten RAM. Das frühere `dbcache`-Limit von
  16 GB wurde im September 2024 entfernt (siehe [Newsletter #321][news321 dbcache]).

- [Bitcoin Core #28592][] erhöht die pro-Peer-Transaktions-Relay-Rate für
  eingehende Verbindungen von 7 auf 14, um der gestiegenen Präsenz kleinerer
  Transaktionen im Netzwerk Rechnung zu tragen. Für ausgehende Peers ist die
  Rate 2,5-mal höher und steigt auf 35 Transaktionen pro Sekunde. Die Relay-Rate
  begrenzt, wie viele Transaktionen ein Knoten seinen Peers sendet.

- [Eclair #3171][] entfernt `PaymentWeightRatios`, eine Pfadfindungsmethode,
  die Uniformität in Kanal-Balances annahm, und ersetzt sie durch einen
  neu eingeführten probabilistischen Ansatz, der auf vergangenen Zahlungsversuchen
  basiert (siehe [Newsletter #371][news371 path]).

- [Eclair #3175][] lehnt nun unbezahllbare [BOLT12][] [Offers][topic offers]
  ab, bei denen die Felder `offer_chains`, `offer_paths`, `invoice_paths` und
  `invoice_blindedpay` vorhanden, aber leer sind.

- [LDK #4064][] aktualisiert die Signaturprüfungslogik, sodass, wenn das Feld
  `n` (Payee-Pubkey) vorhanden ist, die Signatur gegen diesen Wert verifiziert
  wird. Andernfalls wird der Pubkey des Empfängers aus der [BOLT11][] Invoice
  extrahiert; sowohl High-S- als auch Low-S-Signaturen werden berücksichtigt.
  Dieser PR bringt die Prüfungen in Einklang mit dem vorgeschlagenen [BOLTs #1284][]
  und anderen Implementierungen wie Eclair (siehe [Newsletter #371][news371 pubkey]).

- [LDK #4067][] fügt Unterstützung dafür hinzu, [P2A ephemeral anchor][topic
  ephemeral anchors] Ausgaben aus [zero-fee commitment][topic v3 commitments]
  Transaktionen auszugeben, sodass Kanalpartner ihre Mittel on-chain zurückfordern
  können. Siehe [Newsletter #371][news371 p2a] für LDKs Implementierung von
  Zero-Fee-Commitment-Kanälen.

- [LDK #4046][] ermöglicht es einem häufig-offline Sender, [async payments][topic
  async payments] an einen häufig-offline Empfänger zu senden. Der Sender setzt
  ein Flag in der `update_add_htlc` Nachricht, damit das [HTLC][topic htlc]
  beim LSP gehalten wird, bis der Empfänger wieder online ist und eine
  `release_held_htlc` [Onion-Nachricht][topic onion messages] sendet, um die
  Zahlung zu beanspruchen.

- [LDK #4083][] markiert den Endpoint `pay_for_offer_from_human_readable_name`
  als veraltet, um doppelte [BIP353][] HRN-Zahlungs-APIs zu entfernen. Wallets
  sollten die `bitcoin-payment-instructions`-Crate verwenden, um Zahlungsanweisungen
  zu parsen und aufzulösen, bevor sie `pay_for_offer_from_hrn` aufrufen (z. B.
  satoshi@nakamoto.com).

- [LND #10189][] aktualisiert sein `sweeper`-System (siehe [Newsletter #346][news346
  sweeper]), sodass der Fehlercode `ErrMinRelayFeeNotMet` korrekt erkannt wird
  und fehlgeschlagene Transaktionen durch erneutes Senden mit erhöhter Gebühr
  ([Fee Bumping][topic rbf]) solange neu versucht werden, bis die Übertragung
  erfolgreich ist. Zuvor wurde der Fehler falsch zugeordnet, sodass kein Retry
  erfolgte. Außerdem verbessert der PR die Gewichtsschätzung, indem ein mögliches
  zusätzliches Change-Output berücksichtigt wird; relevant für Taproot-Overlay-Kanäle
  und LNDs [Taproot Assets][topic client-side validation].

- [BIPs #1963][] ändert den Status der BIPs, die kompakte Blockfilter spezifizieren
  ([BIP157][] und [BIP158][]) von `Draft` zu `Final`, da sie seit 2020 in
  Bitcoin Core und anderer Software eingesetzt werden.

{% include snippets/recap-ad.md when="2025-09-30 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="33333,28592,3171,3175,4064,4067,4046,4083,10189,1963,1284" %}
[morehouse eclair]: https://delvingbitcoin.org/t/disclosure-eclair-preimage-extraction-exploit/2010
[brozzoni feefilter]: https://delvingbitcoin.org/t/measuring-minrelaytxfee-across-the-bitcoin-network/1989
[0xb10c feefilter]: https://delvingbitcoin.org/t/measuring-minrelaytxfee-across-the-bitcoin-network/1989/3
[bitcoin core 30.0rc1]: https://bitcoincore.org/bin/bitcoin-core-30.0/
[bcc30 testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/30.0-Release-Candidate-Testing-Guide/
[news321 dbcache]: /en/newsletters/2024/09/20/#bitcoin-core-28358
[news371 path]: /de/newsletters/2025/09/12/#eclair-2308
[news371 pubkey]: /de/newsletters/2025/09/12/#eclair-3163
[news371 p2a]: /de/newsletters/2025/09/12/#ldk-4053
[news346 sweeper]: /de/newsletters/2025/03/21/#diskussion-zum-dynamischen-feerate-anpassungssystem-in-lnd
[policy series]: /en/blog/waiting-for-confirmation/
[28.0 1p1c]: /en/bitcoin-core-28-wallet-integration-guide/#one-parent-one-child-1p1c-relay
