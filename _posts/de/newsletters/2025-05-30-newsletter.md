---
title: 'Bitcoin Optech Newsletter #356'
permalink: /de/newsletters/2025/05/30/
name: 2025-05-30-newsletter-de
slug: 2025-05-30-newsletter-de
type: newsletter
layout: newsletter
lang: de
---
Der Newsletter dieser Woche fasst eine Diskussion über die möglichen Auswirkungen von zuordenbaren Fehlern auf die Privatsphäre im Lightning Netzwerk (LN) zusammen. Ebenfalls enthalten sind unsere regulären Abschnitte mit ausgewählten Fragen und Antworten von Bitcoin Stack Exchange, Ankündigungen neuer Releases und Release-Kandidaten sowie Beschreibungen aktueller Änderungen an beliebter Bitcoin-Infrastruktur-Software.

## Nachrichten

- **Beeinträchtigen zuordenbare Fehler die Privatsphäre im Lightning Netzwerk?** Carla Kirk-Cohen [veröffentlichte][kirkcohen af] auf Delving Bitcoin eine Analyse der möglichen Folgen für die Privatsphäre von LN-Zahlenden und -Empfangenden, falls das Netzwerk [zuordenbare Fehler][topic attributable failures] einführt – insbesondere, wenn dem Zahlenden die Weiterleitungszeit an jedem Hop mitgeteilt wird. Unter Bezugnahme auf mehrere Arbeiten beschreibt sie zwei Arten von Deanonymisierungsangriffen:

  - Ein Angreifer, der einen oder mehrere Weiterleitungsknoten betreibt, nutzt Zeitdaten, um die Anzahl der Hops einer Zahlung ([HTLC][topic htlc]) zu bestimmen. Kombiniert mit Kenntnissen über die Topologie des öffentlichen Netzwerks kann dies die Menge möglicher Empfänger einschränken.

  - Ein Angreifer verwendet einen IP-Netzwerk-Traffic-Forwarder ([autonomous system][]) zur passiven Überwachung des Traffics und kombiniert dies mit Kenntnissen über die IP-Latenz zwischen Knoten (Ping-Zeiten) sowie der Topologie und anderen Eigenschaften des öffentlichen Lightning Netzwerks.

  Sie beschreibt dann mögliche Gegenmaßnahmen, darunter:

  - Empfangende sollten das Akzeptieren eines HTLC um eine kleine, zufällige Zeit verzögern, um Timing-Angriffe zu erschweren, die den Empfänger identifizieren wollen.
  - Zahlende sollten das erneute Senden fehlgeschlagener Zahlungen (oder [MPP][topic multipath payments]-Teile) um eine kleine, zufällige Zeit verzögern und alternative Pfade nutzen, um Timing- und Fehlerangriffe zu erschweren, die den Zahlenden identifizieren wollen.
  - Mehr Zahlungssplitting mit MPP, um es schwieriger zu machen, den ausgegebenen Betrag zu erraten.
  - Zahlenden erlauben, sich für eine langsamere Weiterleitung ihrer Zahlungen zu entscheiden, wie zuvor vorgeschlagen (siehe [Newsletter #208][news208 slowln]). Dies könnte mit HTLC-Batching kombiniert werden, das in LND bereits implementiert ist (eine zusätzliche zufällige Verzögerung könnte die Privatsphäre weiter erhöhen).
  - Die Genauigkeit der Zeitstempel von zuordenbaren Fehlern verringern, um Weiterleitungsknoten, die kleine Zufallsverzögerungen einbauen, nicht zu benachteiligen.

  Die Diskussion verschiedener Teilnehmer bewertete die Bedenken und vorgeschlagenen Gegenmaßnahmen im Detail und betrachtete weitere mögliche Angriffe und Gegenmaßnahmen.

## Ausgewählte Fragen & Antworten von Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] ist eine der ersten Anlaufstellen für Optech-Mitwirkende, wenn sie Antworten suchen – oder wenn wir ein paar Minuten Zeit haben, um neugierigen oder ratlosen Nutzern zu helfen. In dieser monatlichen Rubrik heben wir einige der am höchsten bewerteten Fragen und Antworten seit unserem letzten Update hervor.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Welche Transaktionen gelangen in blockreconstructionextratxn?]({{bse}}116519)
  Glozow erklärt, wie die Extrapool-Datenstruktur (siehe [Newsletter #339][news339 extrapool]) abgelehnte und ersetzte Transaktionen, die vom Knoten gesehen wurden, zwischenspeichert und listet die Kriterien für Ausschluss und Entfernung auf.

- [Warum sollte jemand OP_RETURN anstelle von Inscriptions verwenden, abgesehen von den Gebühren?]({{bse}}126208)
  Sjors Provoost merkt an, dass `OP_RETURN` nicht nur manchmal günstiger ist, sondern auch für Protokolle genutzt werden kann, die Daten benötigen, die vor dem Ausgeben einer Transaktion verfügbar sind – im Gegensatz zu Witness-Daten, die erst bei der Ausgabe offenbart werden.

- [Warum erhält mein Bitcoin-Knoten keine eingehenden Verbindungen?]({{bse}}126338)
  Lightlike weist darauf hin, dass es bei einem neuen Knoten im Netzwerk einige Zeit dauern kann, bis seine Adresse im P2P-Netzwerk weit verbreitet ist, und dass Knoten ihre Adresse erst bewerben, wenn der Initial Block Download (IBD) abgeschlossen ist.

- [Wie konfiguriere ich meinen Knoten so, dass er Transaktionen größer als 400 Byte herausfiltert?]({{bse}}126347)
  Antoine Poinsot bestätigt, dass es in Bitcoin Core keine Konfigurationsoption gibt, um die maximale Standard-Transaktionsgröße anzupassen. Er erläutert, dass Nutzer, die diesen Wert anpassen möchten, den Quellcode ändern können, warnt aber vor möglichen Nachteilen sowohl bei größeren als auch bei kleineren Maximalwerten.

- [Was bedeutet „not publicly routable“ node im Bitcoin Core P2P?]({{bse}}126225)
  Pieter Wuille und Vasil Dimov geben Beispiele für P2P-Verbindungen, wie etwa [Tor][topic anonymity networks], die nicht über das globale Internet geroutet werden können und im `netinfo`-Output von Bitcoin Core im „npr“-Bucket erscheinen.

- [Warum sollte ein Knoten überhaupt eine Transaktion weiterleiten?]({{bse}}127391)
  Pieter Wuille listet Vorteile für Betreiber auf, die Transaktionen weiterleiten: Privatsphäre beim Weiterleiten eigener Transaktionen, schnellere Blockverbreitung beim Mining und verbesserte Dezentralisierung des Netzwerks bei minimalen Zusatzkosten gegenüber dem bloßen Weiterleiten von Blöcken.

- [Ist Selfish Mining mit Compact Blocks und FIBRE immer noch möglich?]({{bse}}49515)
  Antoine Poinsot antwortet auf eine Frage von 2016 und stellt klar: „Ja, Selfish Mining ist auch mit verbesserter Blockverbreitung weiterhin eine mögliche Optimierung. Es ist nicht korrekt zu sagen, dass Selfish Mining jetzt nur noch ein theoretischer Angriff ist.“ Er verweist außerdem auf eine von ihm erstellte [Mining-Simulation][miningsimulation github].

## Veröffentlichungen und Release-Kandidaten

_Neue Veröffentlichungen und Release-Kandidaten für beliebte Bitcoin-Infrastrukturprojekte. Bitte erwägen Sie ein Upgrade auf neue Versionen oder helfen Sie bei der Testung von Release-Kandidaten._

- [Core Lightning 25.05rc1][] ist ein Release-Kandidat für die nächste Hauptversion dieser beliebten LN-Knoten-Implementierung.

- [LDK 0.1.3][] und [0.1.4][ldk 0.1.4] sind Releases dieser beliebten Bibliothek zum Bau von LN-fähigen Anwendungen. Version 0.1.3, diese Woche als Release auf GitHub getaggt, aber letzten Monat datiert, enthält den Fix für einen Denial-of-Service-Angriff. Version 0.1.4, das aktuellste Release, „behebt eine Funds-Theft-Schwachstelle in extrem seltenen Fällen“. Beide Releases enthalten weitere Fehlerbehebungen.

## Wichtige Code- und Dokumentationsänderungen

_Bedeutende kürzliche Änderungen in [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo], [Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition repo] und [BINANAs][binana repo]._

- [Bitcoin Core #31622][] fügt ein Signature-Hash-(sighash)-Typfeld zu [PSBTs][topic psbt] hinzu, wenn dieser Wert von `SIGHASH_DEFAULT` oder `SIGHASH_ALL` abweicht. [MuSig2][topic musig] erfordert, dass alle mit demselben Sighash-Typ signieren, daher muss dieses Feld in der PSBT vorhanden sein. Zusätzlich wird der RPC-Befehl `descriptorprocesspsbt` aktualisiert, sodass er die Funktion `SignPSBTInput` verwendet, die sicherstellt, dass der Sighash-Typ der PSBT mit dem in der CLI angegebenen Wert übereinstimmt, falls zutreffend.

- [Eclair #3065][] fügt Unterstützung für zuordenbare Fehler (siehe [Newsletter #224][news224 failures]) gemäß [BOLTs #1044][] hinzu. Diese Funktion ist standardmäßig deaktiviert, da die Spezifikation noch nicht final ist, kann aber mit der Einstellung `eclair.features.option_attributable_failure = optional` aktiviert werden. Die Kompatibilität mit LDK wurde erfolgreich getestet, siehe [Newsletter #349][news349 failures] für weitere Informationen zur LDK-Implementierung und zum Protokoll.

- [LDK #3796][] verschärft die Überprüfung des Channel-Guthabens, sodass Finanzierer genügend Kapital für die Commitment-Transaktionsgebühr, die beiden 330 sat [Anchor Outputs][topic anchor outputs] und die Channel-Reserve haben müssen. Zuvor konnten Finanzierer auf die Channel-Reserve zurückgreifen, um die beiden Anchor Outputs zu decken.

- [BIPs #1760][] merged [BIP53][], das eine Konsens-Softfork-Regel spezifiziert, die 64-Byte-Transaktionen (ohne Witness-Daten gemessen) verbietet, um eine Art von [Merkle-Baum-Schwachstelle][topic merkle tree vulnerabilities] zu verhindern, die gegen SPV-Clients ausnutzbar wäre. Dieser PR schlägt eine ähnliche Korrektur wie eine der im [Consensus Cleanup Softfork][topic consensus cleanup] enthaltenen Korrekturen vor.

- [BIPs #1850][] macht eine frühere Änderung an [BIP48][] rückgängig, die den Script-Typ-Wert 3 für [Taproot][topic taproot] (P2TR)-Ableitungen reserviert hatte (siehe [Newsletter #353][news353 bip48]). Grund ist, dass [Tapscript][topic tapscript] kein `OP_CHECKMULTISIG` unterstützt, sodass das in [BIP67][] referenzierte Output-Skript (auf das sich [BIP48][] stützt) nicht als P2TR ausgedrückt werden kann. Der PR markiert außerdem den Status von [BIP48][] als „Final“, um widerzuspiegeln, dass der Zweck des BIPs die Definition der Branchenverwendung von `m/48'`-[HD wallet][topic bip32]-Ableitungspfaden war, nicht die Vorgabe neuen Verhaltens.

- [BIPs #1793][] merged [BIP443][], das den [OP_CHECKCONTRACTVERIFY][topic matt] (OP_CCV)-Opcode vorschlägt, mit dem überprüft werden kann, dass ein öffentlicher Schlüssel (sowohl von Outputs als auch Inputs) auf beliebige Daten verpflichtet. Siehe [Newsletter #348][news348 op_ccv] für weitere Informationen zu diesem vorgeschlagenen [Covenant][topic covenants].

{% include snippets/recap-ad.md when="2025-06-03 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="31622,3065,3796,1760,1850,1793,1044" %}
[Core Lightning 25.05rc1]: https://github.com/ElementsProject/lightning/releases/tag/v25.05rc1
[ldk 0.1.3]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.1.3
[ldk 0.1.4]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.1.4
[news208 slowln]: /en/newsletters/2022/07/13/#allowing-deliberately-slow-ln-payment-forwarding
[autonomous system]: https://en.wikipedia.org/wiki/Autonomous_system_(Internet)
[kirkcohen af]: https://delvingbitcoin.org/t/latency-and-privacy-in-lightning/1723
[news224 failures]: /de/newsletters/2022/11/02/#zuordnung-von-ln-routing-fehlern
[news349 failures]: /en/newsletters/2025/04/11/#ldk-2256
[news353 bip48]: /en/newsletters/2025/05/09/#bips-1835
[news348 op_ccv]: /de/newsletters/2025/04/04/#op-checkcontractverify-semantik
[news339 extrapool]: /de/newsletters/2025/01/31/#aktualisierte-statistiken-zur-kompaktblock-rekonstruktion
[miningsimulation github]: https://github.com/darosior/miningsimulationq