---
title: 'Bitcoin Optech Newsletter #224'
permalink: /de/newsletters/2022/11/02/
name: 2022-11-02-newsletter-de
slug: 2022-11-02-newsletter-de
type: newsletter
layout: newsletter
lang: de
---
Der Newsletter dieser Woche berichtet beschreibt die laufende Diskussion über
die Option, dass Knoten Full-RBF aktivieren können, erbittet Feedback zu einem
Designelement des verschlüsselten Transportprotokolls BIP324 Version 2, fasst
einen Vorschlag für die zuverlässige Zuordnung von LN-Ausfällen und
-Verzögerungen zu bestimmten Knoten zusammen und verlinkt zu einer Diskussion
über eine Alternative zur Verwendung von Ankerausgaben für moderne LN-HTLCs.
Ebenfalls enthalten sind unsere regelmäßigen Abschnitte mit den Ankündigungen
neuer Software-Releases und Release Candidates - einschließlich eines
sicherheitskritischen Updates für LND - sowie erwähnenswerte Änderungen an
beliebten Bitcoin Infrastrukturprojekten.

## News

- **Mempool-Konsistenz:** Anthony Towns begann eine [Diskussion][towns consistency]
  auf der Bitcoin-Dev Mailingliste über die Konsequenzen einer einfacheren
  Konfiguration der Bitcoin Core Richtlinien für Transaktionsweiterleitung und
  Mempool-Akzeptanz, wie sie durch das Hinzufügen der `mempoolfullrbf`-Option
  zum Development-Branch von Bitcoin Core gemacht wurde (siehe Newsletters
  [#205][news205 rbf], [#208][news208 rbf], [#222][news222 rbf], und
  [#223][news223 rbf]). Er behauptet, dass "dies sich von dem unterscheidet, was
  Core in der Vergangenheit getan hat, da wir bisher versucht haben,
  sicherzustellen, dass eine neue Richtlinie für alle gut ist (oder so gut wie
  möglich), und sie dann aktiviert haben, sobald sie implementiert wurde. Alle
  Optionen, die hinzugefügt wurden, dienten entweder dazu, die Ressourcennutzung
  so zu kontrollieren, dass die tx-Verbreitung nicht signifikant [beeinflusst]
  wird, oder um es den Leuten zu ermöglichen, zum alten Verhalten zurückzukehren,
  wenn das neue Verhalten umstritten ist (z.B. die Option -mempoolreplacement=0
  von 0.12 auf 0.18), und um es einfacher zu machen, die Implementierung zu
  testen/debuggen. Den Leuten ein neues Relay-Verhalten zu geben, für das sie
  sich entscheiden können, wenn wir nicht sicher genug sind, es standardmäßig zu
  aktivieren, entspricht nicht dem Ansatz, den ich in der Vergangenheit bei Core
  gesehen habe."

    Towns denkt dann darüber nach, ob dies eine neue Richtung für die
    Entwicklung sei: "Full-[RBF][topic RBF] ist seit Ewigkeiten umstritten, aber
    bei den Entwicklern sehr beliebt [...] also ist dies vielleicht nur ein
    Sonderfall und kein Präzedenzfall. Und wenn Leute andere Default-False-Optionen
    vorschlagen, wird es trotz des ganzen Geredes darüber, dass die Benutzer
    Optionen haben, das im Moment stattfindet, wesentlich mehr Widerstand gegen
    das Merging geben". Aber davon ausgehend, dass es sich um eine neue
    Richtung handelt, bewertet er einige mögliche Folgen dieser
    Entscheidung:

    - *Es sollte einfacher sein, standardmäßig deaktivierte alternative Weiterleitungsoptionen zu mergen:*
      Wenn es als besser angesehen wird, den Benutzern mehr Optionen zu geben,
      gibt es viele Aspekte der Weiterleitungsrichtlinien, die konfigurierbar
      gemacht werden können. Zum Beispiel bietet Bitcoin Knots eine Option für
      Skript-Pubkey-Wiederverwendung(`spkreuse`), um einen Knoten so zu
      konfigurieren, dass er die Weiterleitung von Transaktionen, die eine
      [Adresse wiederverwenden][topic output linking], ablehnt.

    - *Tolerantere Richtlinien erfordern eine breite Akzeptanz oder ein besseres Peering:*
      Ein Bitcoin Core Knoten leitet standardmäßig Transaktionen zu acht Peers
      über ausgehende Verbindungen weiter. Also müssen mindestens 30% des
      Netzwerks eine tolerantere Richtlinie unterstützen, bevor ein Knoten eine
      95%ige Chance hat, mindestens einen zufällig ausgewählten Peer zu finden,
      der die gleiche Richtlinie unterstützt. Je weniger Knoten eine Richtlinie
      unterstützen, desto geringer ist die Wahrscheinlichkeit, dass ein Knoten
      einen Peer findet, der diese Richtlinie unterstützt.

    - *Besseres Peering bringt Kompromisse mit sich:* Bitcoin-Knoten können ihre
      Fähigkeiten über das Service-Feld der P2P-Nachrichten `addr`,
      [`addrv2`][topic addr v2] und `version` bekannt geben, so dass Knoten mit
      gemeinsamen Interessen einander finden und Teilnetze bilden können (so
      genanntes *preferential peering*). Alternativ können Betreiber von
      Fullnodes mit gemeinsamen Interessen andere Software verwenden, um
      unabhängige Weiterleitungsnetze zu bilden (z. B. ein Netz zwischen
      LN-Knoten). Auf diese Weise können Weiterleitungsnetzwerke auch dann
      effektiv sein, wenn nur wenige Knoten eine Richtlinie umsetzen. Aber
      Knoten, die eine seltene Richtlinie umsetzen, sind leichter zu
      identifizieren und zu zensieren. Außerdem müssen sich die Miner diesen
      Sub-Netzwerken und alternativen Netzwerken anschließen, was die
      Komplexität und die  Miningkosten erhöht, was wiederum den Druck die
      Transaktionsauswahl zu zentralisieren erhöht, und somit auch die Zensur
      erleichtert.

        Außerdem können Knoten, die andere Richtlinien als einige ihrer Peers
        implementieren, die Vorteile von Technologien wie
        [kompakte Blockweiterleitung][topic compact block relay] und
        [Erlay][topic erlay] zur Minimierung von Latenzzeiten und Bandbreite
        nicht voll ausschöpfen, wenn zwei Peers bereits über einige der gleichen
        Informationen verfügen.

    Auf den Beitrag von Towns gingen zahlreiche aufschlussreiche Antworten ein,
    und die Diskussion ist noch nicht abgeschlossen. Wir werden im Newsletter
    der nächsten Woche ein Update geben.

-  **BIP324 Nachrichtenbezeichner**: Pieter Wuille hat auf der
  Bitcoin-Dev-Mailingliste eine [Antwort][wuille bip324] auf die Aktualisierung
  des [BIP324][bips #1378]-Spezifikationsentwurfs für die
  [verschlüsselte zweite Version des P2P-Transportprotokoll][topic v2 p2p transport]
  (v2 transport) veröffentlicht. Um Bandbreite zu sparen, erlaubt v2 transport
  das Ersetzen der 12-Byte-Nachrichtennamen des bestehenden Protokolls durch
  Bezeichner, die nur 1 Byte lang sind. So könnte beispielsweise der `version`
  -Nachrichtenname, der auf 12 Byte aufgefüllt wird, durch 0x00 ersetzt werden.
  Kürzere Nachrichtennamen erhöhen jedoch das Risiko von Konflikten zwischen
  verschiedenen zukünftigen Vorschlägen zur Aufnahme von Nachrichten in das Netz.
  Wuille beschreibt die Kompromisse zwischen vier verschiedenen Ansätzen zu
  diesem Problem und bittet die Community um ihre Meinung zu diesem Thema.

- **Zuordnung von LN-Routing-Fehlern:** LN-Zahlungsversuche können aus einer
  Vielzahl von Gründen fehlschlagen. Von der Weigerung des endgültigen
  Empfängers, das Zahlungs-Preimage freizugeben, bis hin zum vorübergehenden
  Ausfall eines der Routing-Knoten. Informationen darüber, welche Knoten eine
  fehlgeschlagene Zahlung verursacht haben, wären für Zahler äußerst nützlich,
  um diese Knoten für zukünftige Zahlungen zu meiden. Das LN-Protokoll bietet
  jedoch zurzeit keine authentifizierte Methode für Routing-Knoten, um diese
  Informationen an einen Zahler zu übermitteln.

    Vor einigen Jahren schlug Joost Jager eine Lösung vor (siehe
    [Newsletter #51][news51 attrib]), die er nun mit Verbesserungen und
    zusätzlichen Details [aktualisiert][jager attrib] hat. Der Mechanismus würde
    die Identifikation des Knotenpaars sicherstellen, zwischen dem
    eine Zahlung fehlgeschlagen ist (oder zwischen dem eine frühere
    Fehlermeldung zensiert oder unverständlich wurde). Der größte Nachteil von
    Jagers Vorschlag besteht darin, dass er die LN-Onion-Nachrichtengrösse für
    Fehlschläge deutlich erhöhen würde, sofern andere LN-Eigenschaften erhalten
    blieben. Wenn die maximale Anzahl der LN-Hops verringert würde, könnte die
    Onion-Nachrichtengröße bei Fehlschlägen aber kleiner sein.

    Alternativ [schlug][russell attrib] Rusty Russell vor, dass ein Zahler einen
    Mechanismus verwenden könnte, der [spontanen Zahlungen][topic spontaneous payments]
    ähnelt; bei dem jeder Routing-Knoten einen Satoshi bezahlt bekommt, auch
    wenn die endgültige Zahlung fehlschlägt. Der Zahler könnte dann feststellen,
    bei welchem Hop die Zahlung fehlgeschlagen ist, indem er vergleicht, wie
    viele Satoshi er gesendet und wie viele Satoshi er zurückerhalten hat.

- **Ankerausgaben-Workaround**: Bastien Teinturier hat auf der
  Lightning-Dev-Mailingliste einen [Vorschlag][bolts #1036] für die Verwendung
  von [Ankerausgaben][topic anchor outputs] mit mehreren vorsignierten Varianten
  jeder [HTLC][topic htlc] zu unterschiedlichen Gebührenraten
  [veröffentlicht][teinturier fees]. Ankerausgaben wurden mit der Entwicklung
  der [CPFP-Carve-Out-Regel][topic cpfp carve out] eingeführt, die es ermöglicht,
  einer Transaktion über den [CPFP][topic cpfp]-Mechanismus Gebühren
  hinzuzufügen, die für das LN-Zweiparteien-Vertragsprotokoll nicht
  [angreifbar][topic transaction pinning] wären. Teinturier
  [merkt jedoch an][bolts #845], dass die Verwendung von CPFP voraussetzt, dass
  jeder LN-Knoten einen Pool von Nicht-LN-UTXOs bereithält, die jederzeit
  ausgegeben werden können. Im Vergleich dazu ermöglicht das Vorsignieren
  mehrerer Versionen von HTLCs mit jeweils unterschiedlichen Gebühren, dass
  diese Gebühren direkt aus dem Wert des HTLC bezahlt werden können ---
  abgesehen von Fällen, in denen keine der vorgegebenen Gebühren hoch genug war,
  ist keine zusätzliche UTXO-Verwaltung erforderlich.

    Er bittet andere LN-Entwickler um Unterstützung für die Idee, HTLCs mit
    mehreren Gebührenraten anzubieten. Zum Zeitpunkt der Erstellung dieses
    Artikels wurde die gesamte Diskussion auf [Teinturiers PR][bolts #1036]
    geführt.

## Releases und Release-Kandidaten

*Neue Releases und Release-Kandidaten für beliebte Bitcoin
Infrastrukturprojekte. Bitte erwäge auf die neuen Versionen
zu wechseln oder beim Testen von Release-Kandidaten auszuhelfen.*

- [LND 0.15.4-beta][] und [0.14.4-beta][lnd 0.14.4-beta] sind
  **sicherheitskritische** Veröffentlichungen, die Fehlerbehebungen für ein
  Problem bei der Verarbeitung neuer Blöcke enthalten. Alle Benutzer sollten ein
  Upgrade durchführen.

- [Bitcoin Core 24.0 RC2][] ist ein Release Candidate für die nächste Version
  der am weitesten verbreiteten Full-Node-Implementierung des Netzwerks. Eine
  [Anleitung zum Testen][bcc testing] ist verfügbar.

  **Warnung:** Dieser Release Candidate enthält die Konfigurationsoption
  `mempoolfullrbf`, von der mehrere Protokoll- und Anwendungsentwickler glauben,
  dass sie zu Problemen für Händlerdienste führen könnte; wie in den Newslettern
  [#222][news222 rbf] and [#223][news223 rbf] beschrieben. Optech fordert alle
  Dienste auf, die davon betroffen sein könnten, den RC zu evaluieren und sich
  an der öffentlichen Diskussion zu beteiligen.

## Nennenswerte Code- und Dokumentationsänderungen

*Erwähnenswerte Änderungen diese Woche in [Bitcoin Core][bitcoin core repo],
[Core Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], und [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #23927][] schränkt `getblockfrompeer` auf pruned Knoten auf
  Blockhöhen unterhalb des aktuellen Synchronisationsfortschritts des Knotens
  ein. Dies verhindert, dass ein Footgun entsteht, bei dem das Abrufen
  unsynchronisierter Blöcke die Blockdateien des Knotens für Pruning ungeeignet
  macht.

  Bitcoin Core speichert Blöcke in Dateien von etwa 130 MB in der Reihenfolge,
  in der sie empfangen werden. Beim Pruning werden ganze Blockdateien verworfen,
  aber keine Datei, die einen Block enthält, der nicht durch die Synchronisation
  verarbeitet wurde. Die Kombination aus einer kleinen Datenmenge und der
  wiederholten Verwendung des `getblockfrompeer`-RPC könnte dazu führen, dass
  mehrere Blockdateien nicht für das Pruning in Frage kommen und dass ein
  beschnittener Knoten seine Datenmenge überschreitet.

- [Bitcoin Core #25957][] verbessert die Leistung von Rescans für
  Deskriptor-Wallets, indem der [Blockfilter-Index][topic compact block filters]
  (falls aktiviert) verwendet wird, um Blöcke zu überspringen, die keine für das
  Wallet relevanten UTXOs ausgeben oder erzeugen.

- [Bitcoin Core #23578][] nutzt [HWI][topic hwi] und die kürzlich eingefügte
  Unterstützung für [BIP371][] (siehe [Newsletter #207][news207 bc22558]), um
  externe Signierunterstützung für [Taproot][topic taproot] Schlüsselpfadausgaben
  zu ermöglichen.

- [Core Lightning #5646][] aktualisiert die experimentelle Implementierung von
  [Angeboten][topic offers], um [x-only öffentliche Schlüssel][news72 xonly] zu
  entfernen (stattdessen werden [komprimierte Pubkeys][compressed pubkeys]
  verwendet, die ein zusätzliches Byte enthalten). Er implementiert auch die
  Weiterleitung von [verdeckten Zahlungen][blinded payments]; ein weiteres
  experimentelles Protokoll. In der PR-Beschreibung wird davor gewarnt, dass er
  "nicht die Erstellung und tatsächliche Bezahlung von Rechnungen mit verdeckten
  Zahlungen beinhaltet."

- [LND #6517][] fügt eine neue RPC und einen Event hinzu, die es einem Benutzer
  ermöglichen, zu überwachen, wann eine eingehende Zahlung ([HTLC][topic htlc])
  abgeschlossen ist, nachdem die Verpflichtungstransaktion aktualisiert wurde,
  um die neue Channel-Saldoverteilung widerzuspiegeln.

- [LND #7001][] fügt der Weiterleitungshistorie-RPC (`fwdinghistory`) neue
  Felder hinzu, die angeben, welcher Channel-Partner eine Zahlung (HTLC) an uns
  weitergeleitet hat und an welchen Partner wir die Zahlung weitergeleitet haben.

- [LND #6831][] aktualisiert die HTLC-Interceptor-Implementierung (siehe
  [Newsletter #104][news104 intercept]), um eine eingehende Zahlung (HTLC)
  automatisch abzulehnen, wenn der mit dem Interceptor verbundene Client die
  Verarbeitung nicht innerhalb einer angemessenen Zeitspanne abgeschlossen hat.
  Wenn ein HTLC nicht akzeptiert oder abgelehnt wird, bevor er abläuft, muss der
  Channel-Partner den Channel zwangsweise schließen, um sein Kapital zu schützen.
  Im zusammengefassten PR, wird durch die automatische Ablehnung vor Ablauf der
  Frist sichergestellt, dass der Kanal offen bleibt. Der Zahler kann
  jederzeit versuchen, die Zahlung erneut zu senden.

<!-- The commit below appears to be a direct push to LND's master branch -->
- [LND 609cc8b][] fügt eine [Sicherheitsrichtlinie][lnd secpol] hinzu, die
  Anweisungen zum Melden von Schwachstellen enthält.

- [Rust Bitcoin #957][] fügt eine API zum Signieren von [PSBTs][topic psbt]
  hinzu. Sie unterstützt jedoch noch nicht das Signieren von
  [Taproot][topic taproot]-Ausgaben.

- [BDK #779][] fügt Unterstützung für das [Low-R-Grinding][topic low-r grinding]
  von ECDSA-Signaturen hinzu, wodurch die Größe von etwa der Hälfte solcher
  Signaturen um ein Byte reduziert werden kann.

{% include references.md %}
{% include linkers/issues.md v=2 issues="23927,25957,5646,6517,7001,6831,957,779,1036,845,1378,23578,22558" %}
[bitcoin core 24.0 rc2]: https://bitcoincore.org/bin/bitcoin-core-24.0/
[bcc testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/24.0-Release-Candidate-Testing-Guide
[lnd 609cc8b]: https://github.com/LightningNetwork/lnd/commit/609cc8b883c7e6186e447e8d7e6349688d78d4fd
[lnd secpol]: https://github.com/lightningnetwork/lnd/security/policy
[towns consistency]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-October/021116.html
[news205 rbf]: /en/newsletters/2022/06/22/#full-replace-by-fee
[news208 rbf]: /en/newsletters/2022/07/13/#bitcoin-core-25353
[news222 rbf]: /en/newsletters/2022/10/19/#transaction-replacement-option
[news223 rbf]: /de/newsletters/2022/10/26/#fortsetzung-der-diskussion-uber-vollstandige-rbf
[wuille bip324]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-October/021115.html
[news72 xonly]: /en/newsletters/2019/11/13/#x-only-pubkeys
[compressed pubkeys]: https://developer.bitcoin.org/devguide/wallets.html#public-key-formats
[blinded payments]: /en/topics/rendez-vous-routing/
[news104 intercept]: /en/newsletters/2020/07/01/#lnd-4018
[news51 attrib]: /en/newsletters/2019/06/19/#authenticating-messages-about-ln-delays
[jager attrib]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-October/003723.html
[russell attrib]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-October/003727.html
[teinturier fees]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-October/003729.html
[lnd 0.15.4-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.15.4-beta
[lnd 0.14.4-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.14.5-beta
[news207 bc22558]: /en/newsletters/2022/07/06/#bitcoin-core-22558
