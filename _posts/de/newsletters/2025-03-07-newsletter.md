---
title: 'Bitcoin Optech Newsletter #344'
permalink: /de/newsletters/2025/03/07/
name: 2025-03-07-newsletter-de
slug: 2025-03-07-newsletter-de
type: newsletter
layout: newsletter
lang: de
---
Der Newsletter dieser Woche kündigt die Bekanntgabe einer Sicherheitslücke
an, die ältere Versionen von LND betrifft, und fasst eine Diskussion über
die Prioritäten des Bitcoin Core-Projekts zusammen. Daneben enthält er
unsere regelmäßigen Abschnitte, in denen über Änderungen im Konsens, neue
Releases und Release-Kandidaten sowie wichtige Änderungen an beliebter
Bitcoin-Infrastruktursoftware berichtet wird.

## Aktuelle Nachrichten

- **Offenlegung einer behobenen LND-Schwachstelle, die Diebstahl ermöglicht:**
  Matt Morehouse [veröffentlichte][morehouse failback] auf Delving Bitcoin die
  [verantwortungsvolle Offenlegung][topic responsible disclosures] einer
  Sicherheitslücke, die ältere Versionen von LND betraf. Es wird dringend
  empfohlen, auf Version 0.18 oder (idealerweise) auf die
  [aktuelle Version][lnd current] zu aktualisieren. Ein Angreifer, der einen
  Kanal mit einem betroffenen Knoten teilt und es zudem schafft, diesen zu einem
  bestimmten Zeitpunkt neu zu starten, kann LND dazu verleiten, denselben HTLC
  sowohl zu bezahlen als auch zu erstatten. Dies ermöglicht es ihm, nahezu den
  gesamten Kanalwert zu stehlen.

  Morehouse merkt an, dass andere LN-Implementierungen diese Sicherheitslücke
  unabhängig entdeckt und behoben haben, einschließlich frühestens im Jahr
  2018 (siehe [Newsletter #17][news17 cln2000]). Jedoch beschreibt die
  LN-Spezifikation möglicherweise das falsche Verhalten. Er hat eine
  [PR eröffnet][bolts #1233], um die Spezifikation zu aktualisieren.

- **Diskussion über die Prioritäten bei Bitcoin Core:**
  Mehrere Blogbeiträge von Antoine Poinsot über die Zukunft des Bitcoin
  Core-Projekts wurden in einem [Thread][poinsot pri] auf Delving Bitcoin
  verlinkt. Der [erste Blog-Beitrag][Poinsot Pri1] beschreibt die Vorteile
  einer langfristigen Zielsetzung und die Kosten einer fallweisen
  Entscheidungsfindung. Im [zweiten Beitrag][poinsot pri2] argumentiert
  er, dass "Bitcoin Core ein robustes Rückgrat für das Bitcoin-Netzwerk
  sein sollte, das einen Ausgleich zwischen der Sicherung der Bitcoin
  Core-Software und der Implementierung neuer Funktionen zur Stärkung
  und Verbesserung des Bitcoin-Netzwerks bietet."Im
  [dritten Beitrag][poinsot pri3] schlägt er vor, das bestehende Projekt
  in drei Teile aufzuteilen: einen Node, eine Wallet und eine GUI.
  Dies ist dank den jahrelangen Bemühungen des Multiprozess-Unterprojekts
  (siehe [Newsletter #39][news39 multiprocess] für unsere erste Erwähnung
  dieses Unterprojekts im Jahr 2019) bereitsmöglich.

  Anthony Towns stellt [Fragen][towns pri], ob das Multiprozess-Modell tatsächlich
  eine effektive Aufteilung des Bitcoin Core-Projekts ermöglichen würde, da die
  einzelnen Komponenten eng miteinander verbunden bleiben. Viele Änderungen an einem
  Projekt könnten auch Auswirkungen auf die anderen Projekte haben. Dennoch wäre es
  ein klarer Vorteil, Funktionen, die derzeit keinen Node erfordern, in eine separate
  Bibliothek oder ein eigenständiges Tool zu verlagern, das unabhängig gepflegt werden
  kann. Towns bezieht sich ferner auf die Nutzung von Nodes mit Middleware, die es Nutzern
  ermöglicht, ihre Wallets über Blockchain-Indizes (basiert auf einem
  [persönlichen Blockexplorer][topic block explorers]) mit ihren eigenen Nodes zu
  verbinden – etwas, was das Bitcoin Core-Projekt bisher ablehnte, direkt im Node zu
  integrieren. Schließlich [argumentiert er][towns pri2], dass die Bereitstellung von
  Wallet-Funktionen (primär) und einer grafischen Benutzeroberfläche (sekundär) ein
  Mittel sei, die Sicherheit der Nutzung von Bitcoin durch eine dezentrale Gemeinschaft
  von Entwicklern zu gewährleisten, anstatt nur großen Investoren oder etablierten
  Unternehmen mit umfangreichen Investitionen den Zugang zu ermöglichen.
  
  David Harding äußert [Bedenken][harding pri], dass eine Neuorientierung des Hauptprojekts
  Bitcoin Core ausschließlich auf Konsenscode und P2P-Relay es für Alltag Nutzer schwieriger
  machen könnte, einen Full Node zu betreiben, um ihre eigenen eingehenden Wallet
  Transaktionen zu validieren. Er fordert Poinsot und weitere Mitwirkende auf, stattdessen
  darauf zu konzentrieren, Bitcoin Core für Alltag Nutzer bequemer zu machen. Harding
  betont die Macht der Vollknotenvalidierung: Die Betreiber der Full Nodes, die einen
  überwiegenden Anteil der wirtschaftlichen Aktivität validieren, haben die Möglichkeit,
  Bitcoin's Konsens Regeln festzulegen. Er verweist auf ein Beispiel, wonach bereits
  eine 30-minütige Änderung der durchgesetzten Regeln zur politisch dauerhaften
  Zerstörung wertschätzer Eigenschaften von Bitcoin, wie dem 21M-BTC-Limit, führen
  könnte. Harding ist der Meinung, dass Alltagennutzer stärker an diesen Eigenschaften
  invested sind als Organisationen, die Nodes im Auftrag ihrer Kunden betreiben. Sollten
  die Entwickler von Bitcoin Core die aktuellen Konsensregeln schätzen, ist es ebenso
  wichtig, dass Normalusers in der Lage sind, ihre Transaktionen persönlich zu
  validieren, wie die Vorbeugung von Fehlerquelle, die zu schwerwiegenden Sicherheitslücken
  führen könnten.

## Konsensänderungen

_Ein monatlicher Abschnitt, der Vorschläge und Diskussionen über Änderungen der Konsensregeln von Bitcoin zusammenfasst._

- **Bitcoin Forking Guide:**
  Anthony Towns [kündigte][towns bfg] auf Delving Bitcoin einen Leitfaden an, wie man
  einen gemeinschaftlichen Konsens für Änderungen der Konsensregeln von Bitcoin aufbaut.
  Er unterteilt den sozialen Konsensbildungsprozess in vier Phasen – Forschung und
  Entwicklung, Power-User-Erkundung, Industrieevaluation und Investorenprüfung.
  Anschließend geht er kurz auf die technischen Schritte ein, die am Ende des
  Prozesses zur Aktivierung der Änderung in der Bitcoin-Software erforderlich sind.
  
  In seinem Beitrag stellt er fest, dass es sich bei dem Leitfaden um eine Richtlinie
  für einen kooperativen Prozess handelt, bei dem eine Änderung implementiert wird,
  die das Leben aller verbessert. Dies führt in der Regel zu einer breiten Zustimmung.
  Zudem warnt er davor, dass es sich bei dem Leitfaden um ein oberflächliches Dokument
  handelt.
  
- **Update zu BIP360 pay-to-quantum-resistant-hash (P2QRH):**
  Der Entwickler Hunter Beast [postete][beast p2qrh] ein Update zu seinen Untersuchungen
  zur [Quantenresistenz][topic quantum resistance] für [BIP360][] an die Bitcoin-Dev-Mailingliste.
  Er hat die Liste der vorgeschlagenen quantensicheren Algorithmen angepasst, sucht jemanden, der
  die Entwicklung eines pay-to-taproot-hash (P2TRH)-Schemas (siehe [Newsletter #141][news141 p2trh])
  übernimmt, und erwägt, dass ein Sicherheitsniveau wie aktuell von Bitcoin (NIST II)
  gefordert wird – anstelle eines höheren NIST V, welches mehr Blockplatz und CPU-Prüfzeit
  erfordert. Sein Beitrag erhielt mehrere Rückmeldungen.
  
- **Marktplatz für private Blockvorlagen zur Verhinderung der Zentralisierung von MEV:**
  Matt Corallo und der Entwickler 7d5x9 [posteten][c7 mev] auf Delving Bitcoin über die Möglichkeit,
  dass Parteien in öffentlichen Märkten auf ausgewählten Raum innerhalb von Miner-Blockvorlagen
  bieten können. Beispielsweise: „Ich zahle X [BTC], um Transaktion Y einzufügen, solange sie vor
  allen anderen Transaktionen erscheint, die mit dem Smart Contract Z interagieren.“ Dies ist
  etwas, das Transaktionsersteller bei Bitcoin bereits für verschiedene Protokolle wünschen – etwa
  für gewisse [colored coin protocols][topic client-side validation]. Es wird wahrscheinlich in
  Zukunft noch begehrter werden, da neue Protokolle entwickelt werden (einschließlich solcher,
  die Konsensänderungen, wie beispielsweise bestimmte [covenants][topic covenants], erfordern).
  
  Falls der Dienst der bevorzugten Transaktionsreihenfolge innerhalb von Blockvorlagen nicht durch
  einen vertrauensreduzierten öffentlichen Markt bereitgestellt wird, werden vermutlich große Miner
  diesen Service selbst anbieten. Dies würde erfordern, dass diese Miner große Mengen an Kapital
  und technischer Expertise aufbringen, was zu deutlich höheren Gewinnen im Vergleich zu kleineren
  Minern führen könnte – ein Umstand, der zur Zentralisierung im Mining beiträgt und es den großen
  Minern erleichtert, Bitcoin-Transaktionen zu zensieren.
  
  Die Entwickler schlagen vor, das Vertrauensverhältnis zu verringern, indem Miner an der Arbeit
  an verdeckten Blockvorlagen beteiligt werden, deren vollständige Transaktionen dem Miner erst
  bekannt werden, wenn sie ausreichend Proof-of-Work erbracht haben, um den Block zu
  veröffentlichen. Konkret werden zwei Mechanismen vorgeschlagen:
  
  - **Vertrauenswürdige Blockvorlagen:**  
    Ein Miner verbindet sich mit einem Marktplatz, wählt die Gebote aus, die in einen Block
    aufgenommen werden sollen, und fordert den Marktplatz auf, eine Blockvorlage zu erstellen.
    Der Marktplatz liefert daraufhin einen Blockheader, eine Coinbase-Transaktion und einen
    partiellen Merkle-Zweig, mit denen der Miner einen Proof-of-Work für diese Vorlage erstellen
    kann, ohne den exakten Inhalt zu erfahren. Erreicht der Miner das für den Proof-of-Work
    erforderliche Niveau, übermittelt er den Header und die Coinbase-Transaktion an den Marktplatz,
    der diese überprüft, in die Blockvorlage einfügt und den Block broadcastet. Möglicherweise
    enthält die Blockvorlage eine Transaktion, die den Miner bezahlt, oder die Bezahlung erfolgt
    separat.
  
  - **Trusted Execution Environments (TEE):**  
    Miner nutzen ein Gerät mit einer [TEE][tee]-sicheren Enklave, verbinden sich mit Marktplätzen,
    wählen die Gebote aus, die sie in ihren Blocks einfügen möchten, und erhalten die zugehörigen
    Transaktionen verschlüsselt mit dem Enklaveschlüssel des TEE. Die Blockvorlage wird innerhalb
    der TEE erstellt; anschließend stellt diese dem Hostbetriebssystem den Header, die
    Coinbase-Transaktion und den partiellen Merkle-Zweig zur Verfügung. Wird das erforderliche
    Proof-of-Work erreicht, übergibt der Miner den Proof an die TEE, die ihn verifiziert und dem
    Miner die vollständige, entschlüsselte Blockvorlage zurückgibt – damit er den Header
    vervollständigen und den Block senden kann. Auch hier könnte die Blockvorlage eine Zahlung an
    den Miner enthalten, entweder direkt aus einem UTXO des Marktplatzbetreibers oder als
    nachträgliche Bezahlung.
  
  Beide Ansätze würden effektiv mehrere konkurrierende Marktplätze erfordern. Es wird erwartet,
  dass einige Community-Mitglieder und Organisationen Marktplätze auf gemeinnütziger Basis betreiben,
  um die Dezentralisierung gegenüber der Dominanz eines einzelnen vertrauenswürdigen Marktplatzes
  zu bewahren.

## Releases und Release-Kandidaten

_Neue Releases und Release-Kandidaten für beliebte Bitcoin-Infrastruktursoftware. Bitte erwägen Sie ein Upgrade oder unterstützen Sie bei der Testung der Release-Kandidaten._

- [Core Lightning 25.02][] ist ein Release der nächsten Hauptversion dieses beliebten LN-Nodes.
Es beinhaltet unter anderem die Unterstützung für [Peer Storage][topic peer storage] (zur Speicherung
verschlüsselter Straftransaktionen, die abgerufen und entschlüsselt werden können, um eine Art
[Watchtower][topic watchtowers] bereitzustellen), neben weiteren Verbesserungen und Fehlerbehebungen.

## Wichtige Code- und Dokumentationsänderungen

_Wichtige aktuelle Änderungen in [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning repo],
[Eclair][eclair repo], [LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo],
[Hardware Wallet Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay Server][btcpay server repo],
[BDK][bdk repo], [Bitcoin Improvement Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition repo] und [BINANAs][binana repo]._

- [Eclair #3019][] ändert das Verhalten eines Nodes dahingehend, dass bei einem von einem Peer initiierten
einseitigen Abschluss nun die Remote-Commitment-Transaktion bevorzugt wird, wenn diese im Mempool sichtbar
ist, anstatt eine lokale zu senden. Zuvor hätte der Node seine lokale Commitment-Transaktion gesendet, was
zu einem Wettlauf beider Transaktionen führen konnte. Die Wahl der Remote-Commitment-Transaktion ist
vorteilhaft, da sie lokale [OP_CHECKSEQUENCEVERIFY]- (CSV) [Timelock][topic timelocks]-Verzögerungen
vermeidet und zusätzliche Transaktionen zur Auflösung ausstehender [HTLCs][topic htlc] überflüssig macht.

- [Eclair #3016][] führt Low-Level-Methoden zur Erstellung von Lightning-Transaktionen in
[Simple Taproot Channels][topic simple taproot channels] ein, ohne funktionale Änderungen vorzunehmen.
Diese Methoden werden mit [miniscript][topic miniscript] generiert und weichen von denen ab, die in der
[BOLTs #995][]-Spezifikation beschrieben sind.

- [LDK #3342][] fügt eine Struktur namens „RouteParametersConfig“ hinzu, die es Nutzern ermöglicht,
Routing-Parameter für [BOLT12][topic offers]-Rechnungszahlungen individuell anzupassen. Neben der
bisherigen Beschränkung auf `max_total_routing_fee_msat` umfasst die neue Struktur nun auch
[`max_total_cltv_expiry_delta`][topic cltv expiry delta], `max_path_count` und
`max_channel_saturation_power_of_half`. Damit werden die Parameter von [BOLT12][]
in Einklang mit jenen aus [BOLT11][] gebracht.

- [Rust Bitcoin #4114][] senkt die Mindestgröße für Nicht-Witness-Transaktionen von 85 Bytes
auf 65 Bytes und passt sich damit der Bitcoin Core-Policy an (siehe [Newsletter #222][news222 minsize]
und [#232][news232 minsize]). Diese Änderung ermöglicht minimalere Transaktionen, wie etwa
solche mit einem Input und einem `OP_RETURN`-Output.

- [Rust Bitcoin #4111][] fügt Unterstützung für den neuen Standardausgabetyp [P2A][topic ephemeral anchors]
hinzu, der in Bitcoin Core 28.0 eingeführt wurde (siehe [Newsletter #315][news315 p2a]).

- [BIPs #1758][] aktualisiert [BIP374][], das Discrete Log Equality Proofs (DLEQ) definiert
(siehe [Newsletter #335][news335 dleq]), indem das Nachrichtenfeld in die Berechnung von `rand`
einbezogen wird. Diese Änderung verhindert, dass der private Schlüssel `a` potenziell offengelegt
wird, falls zwei Beweise mit denselben Werten für `a`, `b` und `g` aber unterschiedlichen Nachrichten
und einem komplett nullen `r` erstellt werden.

- [BIPs #1750][] aktualisiert [BIP329][], das ein Format für den Export von [Wallet Labels][topic wallet labels]
definiert, durch das Hinzufügen optionaler Felder zu Adressen, Transaktionen und Outputs.
Ebenso wurde ein JSON-Typ-Fehler behoben.

- [BIPs #1712][] und [BIPs #1771][] aktualisieren [BIP3][], das [BIP2][] ersetzt, indem mehrere
Änderungen am BIP-Prozess vorgenommen wurden. Zu den Änderungen gehören die Reduzierung der möglichen
Statuswerte auf vier (statt neun), die Möglichkeit, einen Entwurfs-BIP nach einem Jahr ohne Fortschritt
von jedermann als „geschlossen“ markieren zu lassen, sofern der Autor keine laufende Arbeit bestätigt,
das dauerhafte Beibehalten des Status „Complete“, die kontinuierliche Aktualisierung von BIPs, die
Zuweisung einiger redaktioneller Entscheidungen vom BIP-Editor an die Autoren oder die Community, die
Abschaffung des Kommentarsystems sowie die Anforderung, dass ein BIP thematisch relevant sein muss,
um eine Nummer zu erhalten – neben weiteren Anpassungen am Format und der Präambel.

{% include snippets/recap-ad.md when="2025-03-11 15:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="3019,3016,3342,4114,4111,1758,1750,1712,1771,1233,995" %}
[Core Lightning 25.02]: https://github.com/ElementsProject/lightning/releases/tag/v25.02
[news39 multiprocess]: /en/newsletters/2019/03/26/#bitcoin-core-10973
[news141 p2trh]: /en/newsletters/2021/03/24/#we-could-add-a-hash-style-address-after-taproot-is-activated
[poinsot pri]: https://delvingbitcoin.org/t/antoine-poinsot-on-bitcoin-cores-priorities/1470/
[poinsot pri1]: https://antoinep.com/posts/core_project_direction/
[poinsot pri2]: https://antoinep.com/posts/stating_the_obvious/
[poinsot pri3]: https://antoinep.com/posts/bitcoin_core_scope/
[towns pri]: https://delvingbitcoin.org/t/antoine-poinsot-on-bitcoin-cores-priorities/1470/3
[towns pri2]: https://delvingbitcoin.org/t/antoine-poinsot-on-bitcoin-cores-priorities/1470/15
[harding pri]: https://delvingbitcoin.org/t/antoine-poinsot-on-bitcoin-cores-priorities/1470/10
[towns bfg]: https://delvingbitcoin.org/t/bitcoin-forking-guide/1451
[beast p2qrh]: https://mailing-list.bitcoindevs.xyz/bitcoindev/8797807d-e017-44e2-b419-803291779007n@googlegroups.com/
[c7 mev]: https://delvingbitcoin.org/t/best-worst-case-mevil-response/1465
[tee]: https://en.wikipedia.org/wiki/Trusted_execution_environment
[news17 cln2000]: /en/newsletters/2018/10/16/#c-lightning-2000
[morehouse failback]: https://delvingbitcoin.org/t/disclosure-lnd-excessive-failback-exploit/1493
[lnd current]: https://github.com/lightningnetwork/lnd/releases
[news222 minsize]: /en/newsletters/2022/10/19/#minimum-relayable-transaction-size
[news232 minsize]: /en/newsletters/2023/01/04/#bitcoin-core-26265
[news315 p2a]: /en/newsletters/2024/08/09/#bitcoin-core-30352
[news335 dleq]: /en/newsletters/2025/01/03/#bips-1689
