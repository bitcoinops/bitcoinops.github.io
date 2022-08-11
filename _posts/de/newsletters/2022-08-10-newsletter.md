---
title: 'Bitcoin Optech Newsletter #212'
permalink: /de/newsletters/2022/08/10/
name: 2022-08-10-newsletter-de
slug: 2022-08-10-newsletter-de
type: newsletter
layout: newsletter
lang: de
---
Der Newsletter dieser Woche fasst eine Diskussion über die Senkung der
Standardminimumgebührenrate für Transaktionsweiterleitungen
in Bitcoin Core und anderen Nodes zusammen. Ebenfalls enthalten sind unsere
reguläre Zusammenfassung des Bitcoin Core PR Review Clubs, Ankündigungen neuer
Releases und Release-Kandidaten, sowie erwähnenswerte Änderungen an beliebten
Bitcoin Infrastrukturprojekten.

## News

- **Senkung der Standardminimumgebührenrate für Transaktionsweiterleitungen:**
  Bitcoin Core leitet nur einzelne unbestätigte Transaktionen weiter, wenn diese
  eine [Gebührenrate von mindestens einem Satoshi pro Vbyte][topic default
  minimum transaction relay feerates] (1 sat/vbyte) bezahlen. Wenn sich der
  Mempool eines Nodes mit Transaktionen füllt, die mindestens 1 sat/vbyte
  zahlen, dann muss eine höhere Gebührenrate gezahlt werden. Transaktionen,
  die eine niedrigere Gebührenrate zahlen, können durch Miner immer noch in
  Blöcken aufgenommen und dann als Teil dieser Blöcke weitergeleitet werden.
  Andere Node-Softwares implementieren ähnliche Richtlinien.

    Die Standardminimumgebührenrate zu senken wurde bereits in der
    Vergangenheit diskutiert (siehe [Newsletter #3][news3 min]), wurde aber
    [nicht in Bitcoin Core übernommen][bitcoin core #13922].
    Die [Diskussion um das Thema][chauhan min] erwachte in den letzten Wochen
    wieder:

    - *Wirksamkeit individueller Änderungen:* Es wurde von mehreren Personen
      [debattiert][todd min] wie effektiv es für einzelne Node-Betreiber war,
      die Richtlinien ihres eigenen Nodes zu ändern.

    - *Vergangene Fehlschläge:* Es wurde [erwähnt][harding min], dass der
      vorherige Versuch, die Standardgebührenrate zu senken dadurch behindert
      wurde, dass niedrigere Raten auch die Kosten für mehrere untergeordnete
      Denial-of-Service (DoS) Angriffe senken würden.

    - *Alternative Weiterleitungskriterien:*
      Es wurde [vorgeschlagen][todd min2], dass Transaktionen, die bestimmte
      Standardkriterien verletzen (z. B. die Standard-Minimumgebührenrate)
      stattdessen separate Kriterien erfüllen könnten, die DoS-Angriffe
      kostspielig machen würden. Zum Beispiel, wenn eine bescheidene Menge von
      Hashcash-ähnlichen Arbeitsnachweisen zur Transaktionsweiterleitung
      beitragen würde.

    Zum Zeitpunkt der Abfassung dieses Newsletters ist die Diskussion noch
    zu keinem eindeutigen Ergebnis gekommen.

## Bitcoin Core PR Review Club

*In dieser monatlichen Rubrik fassen wir ein kürzlich stattgefundenes Treffen
des [Bitcoin Core PR Review Club][] zusammen und stellen einige der wichtigsten
Fragen und Antworten vor. Klicke unten auf eine Frage, um eine Zusammenfassung
der Antwort anzusehen.*

[Entkopplung der Initialisierung des Validierungszwischenspeicher vom ArgsManager][review club 25527]
ist ein PR von Carl Dong, der die Logik der Node-Konfiguration von der
Initialisierung der Signatur- und Skript-Caches trennt.
Der PR ist Teil des [libbitcoinkernel project][libbitcoinkernel project].

{% include functions/details-list.md
  q0="Was genau macht der `ArgsManager`?  Warum gehört oder gehört er nicht in
`src/kernel` gegenüber `src/node`?"
  a0="ArgsManager ist eine globale Datenstruktur für die Handhabung von
Konfigurationsoptionen (`bitcoin.conf` und Kommandozeilenargumente). Während
die Konsens-Engine parametrierbare Werte enthalten kann (namentlich, die
Zwischenspeichergröße), braucht ein Node diese Datenstruktur nicht um im
Konsens zu verbleiben. Stattdessen gehört Code der diese Konfigurationsoptionen
handhabt, als Bitcoin Core-spezifische Funktionalität in `src/node`."
  a0link="https://bitcoincore.reviews/25527#l-35"

  q1="Was sind die Validierungszwischenspeicher? Warum gehören sie in
`src/kernel` gegenüber `src/node`?"
  a1="Wenn ein neuer Block empfangen wird, ist der rechenintensivste Teil der
Validierung die Skriptprüfung (d.h. die Prüfung der Signatur) der Transaktionen
des Blocks. Da Knoten, die einen Mempool führen, diese Transaktionen in der
Regel bereits gesehen und validiert haben, wird die Durchsatz der
Blockvalidierung durch das Zwischenspeichern (erfolgreicher) Skript- und
Signaturprüfungen erheblich gesteigert. Diese Zwischenspeicher sind daher
logischerweise Teil der Konsens-Engine, da sie vom konsenskritischen
Blockvalidierungscode benötigt werden. Als solche gehören diese Zwischenspeicher
in `src/kernel`."
  a1link="https://bitcoincore.reviews/25527#l-45"

  q2="Was bedeutet es wenn etwas konsenskritisch ist, es aber keine Konsensregel
ist? Enthält `src/consensus` den gesamten konsenskritischen Quellcode?"
  a2="Die Teilnehmer waren sich einig, dass die Überprüfung von Unterschriften
die Konsensregeln durchsetzt, die Zwischenspeicherung hingegen nicht. Wenn
jedoch der Quellcode für die Zwischenspeicherung einen Fehler enthält, der dazu
führt, dass ungültige Signaturen gespeichert werden, würde der Node die
Konsensregeln nicht mehr erzwingen. Daher wird die Zwischenspeicherung der
Signatur als konsenskritisch angesehen. Der Konsens-Code befindet sich jedoch
noch nicht in `src/kernel` oder `src/consensus`; ein Großteil der Konsensregeln
und des konsenskritischen Quellcodes befindet sich in `validation.cpp`."
  a2link="https://bitcoincore.reviews/25527#l-61"

  q3="Welche Werkzeuge werden für die “Quellcode-Archäologie“ verwendet,
um die Hintergründe zu verstehen, warum ein Wert existiert?"
  a3="Die Teilnehmer nannten mehrere Befehle und Werkzeuge, darunter `git blame`
, `git log`, die Eingabe des Commit-Hashs auf der Pull-Requests
Seite, die Verwendung der Github-Schaltfläche `Blame` beim Anzeigen einer Datei
und die Verwendung der Github-Suchleiste."
  a3link="https://bitcoincore.reviews/25527#l-132"

  q4="Dieser PR ändert den Typ der `signature_cache_bytes` und
`script_execution_cache_bytes` von `int64_t` auf `size_t`.
Was ist der Unterschied zwischen `int64_t`, `uint64_t`, und `size_t`,
und warum sollte ein `size_t` diese Werte aufnehmen?"
  a4="Die Typen `int64_t` und `uint64_t` sind 64-Bit (signiert  bzw. unsigniert)
auf allen Plattformen und Compilern. Der Typ `size_t` ist eine unsignierte
Ganzzahl, die garantiert die Länge (in Bytes) eines beliebigen Objekts im
Speicher aufnehmen kann; seine Größe hängt vom System ab. Daher eignet sich
`size_t` genau für jene Variablen, welche die Zwischenspeichergrößen als Anzahl
von Bytes aufnehmen."
  a4link="https://bitcoincore.reviews/25527#l-163"
%}

## Releases und Release-Kandidaten

*Neue Releases und Release-Kandidaten für beliebte Bitcoin
Infrastrukturprojekte. Bitte erwäge auf die neuen Versionen
zu wechseln oder beim Testen von Release candidates auszuhelfen.*

- [Core Lightning 0.12.0rc1][] ist ein Release-Kandidat für die nächste
  Hauptversion dieser beliebten LN Node Implementierung.


## Nennenswerte Code- und Dokumentationsänderungen

*Erwähnenswerte Änderungen diese Woche in [Bitcoin Core][bitcoin core repo],
[Core Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], und [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #25610][] aktiviert standardmäßig die `-walletrbf` Startoption
  und führt außerdem dazu, dass die RPCs  `createrawtransaction` und
  `createpsbt` standardmäßig ersetzbare Transaktionen erzeugen. Transaktionen
  die mit der grafischen Benutzeroberfläche erzeugt worden waren, verwendeten
  schon zuvor standardmäßig [eingewilligte Ersetzbarkeit (opt-in RBF)][topic rbf].
  Dies folgt auf die in [Newsletter #208][news208 core RBF] erwähnte
  Aktualisierung, die es Node-Betreibern ermöglicht das
  Transaktionsersetzungsverhalten ihres Nodes von der Standard-RBF (BIP125) auf
  Voll-RBF umzustellen. Standardmäßige RPC Einwilligung wurde im Jahr 2017 in
  [Bitcoin Core #9527][] vorgeschlagen. Die damaligen Haupteinwände waren:
  Neuartigkeit der Funktion, mangelnde Funktionalität zum Erhöhen von
  Transaktionsgebühren und fehlende Funktionalität der GUI RBF zu deaktivieren;
  welche seitdem alle behoben wurden.

- [Bitcoin Core #24584][] ändert die [Coin-Auswahl][topic coin selection], um
  Eingabe-Sets zu bevorzugen die aus einem einzigen Ausgabetyp bestehen.
  Dies adressiert Szenarien, in denen gemischte Eingabe-Sets die
  Wechselgeldausgabe vorangegangener Transaktionen enthüllen, und folgt auf
  eine damit verbundene Verbesserung des Datenschutzes, die immer den
  [Ausgabetyp des Wechselgelds mit einer Empfängerausgabe abgleicht][#23789].
  (siehe auch [Newsletter #181][news181 change matching]).

- [Core Lightning #5071][] fügt ein Buchhaltungs-Plugin hinzu, das eine
  Buchführung über die Bewegungen von Bitcoins durch den Node, auf dem das
  Plugin läuft, ermöglicht. Das Plugin bietet auch die Möglichkeit, die für
  Gebühren ausgegebenen Beträge zu verfolgen. Der zusammengeführte PR enthält
  mehrere neue RPC-Befehle.

- [BDK #645][] fügt eine Möglichkeit hinzu, [taproot][topic taproot]-Pfade
  anzugeben, die signiert werden sollen. Zuvor signierte BDK für den Keypath-
  Spend, wenn es dazu in der Lage war, sowie zusätzlich für alle
  Skriptpfade, für die Schlüssel zur Verfügung standen.

 [BOLTs #911][] erweitert LN-Knoten mit der Fähigkeit einen DNS Hostnamen
 bekanntzugeben, der in seine IP-Adresse aufgelöst wird. Eine frühere Diskussion
 dieser Idee wurde in [Newsletter #167][news167 ln dns] erwähnt.

{% include references.md %}
{% include linkers/issues.md v=2 issues="25610,24584,5071,645,911,13922,9527" %}
[core lightning 0.12.0rc1]: https://github.com/ElementsProject/lightning/releases/tag/v0.12.0rc1
[news208 core RBF]: /en/newsletters/2022/07/13/#bitcoin-core-25353
[news167 ln dns]: /en/newsletters/2021/09/22/#dns-records-for-ln-nodes
[news181 change matching]: /en/newsletters/2022/01/05/#bitcoin-core-23789
[chauhan min]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020784.html
[todd min]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020800.html
[vjudeu min]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-August/020821.html
[harding min]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020808.html
[todd min2]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-August/020815.html
[news3 min]: /en/newsletters/2018/07/10/#discussion-min-fee-discussion-about-minimum-relay-fee
[#23789]: https://github.com/bitcoin/bitcoin/issues/23789
[review club 25527]: https://bitcoincore.reviews/25527
[libbitcoinkernel project]: https://github.com/bitcoin/bitcoin/issues/24303
[`ArgsManager`]: https://github.com/bitcoin/bitcoin/blob/5871b5b5ab57a0caf9b7514eb162c491c83281d5/src/util/system.h#L172