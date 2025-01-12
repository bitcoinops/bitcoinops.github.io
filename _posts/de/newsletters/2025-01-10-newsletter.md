---

title: 'Bitcoin Optech Newsletter #336'
permalink: /de/newsletters/2025/01/10/
name: 2025-01-10-newsletter
slug: 2025-01-10-newsletter
type: newsletter
layout: newsletter
lang: de
---

Der Newsletter dieser Woche beschreibt eine mögliche Änderung an Bitcoin Core
die Miner betrifft, fasst die Diskussion über die Schaffung von relativen Zeitsperren auf Vertragsebene
relativen Timelocks und diskutiert einen Vorschlag für eine LN-Symmetrie-Variante
mit optionalen Strafen.  Ebenfalls enthalten sind unsere regelmäßigen Abschnitte
die neue Releases und Release Candidates ankündigen und bemerkenswerte
Änderungen an beliebter Bitcoin-Infrastruktur-Software.

## Nachrichten

- **Untersuchung des Verhaltens von Mining Pools vor der Behebung eines Bitcoin Core Fehlers:**
  Abubakar Sadiq Ismail [postete][ismail double] auf Delving Bitcoin über
  einen [Bug][bitcoin core #21950], der im Jahr 2021 von Antoine Riard entdeckt wurde und
  dazu führt, dass Nodes 2.000 Vbytes in Blockvorlagen für Coinbase
  Transaktionen reservieren, anstatt der vorgesehenen 1.000 Vbytes.  Jede Vorlage
  könnte etwa fünf zusätzliche kleine Transaktionen enthalten, wenn die
  Doppelreservierung beseitigt würde.  Dies könnte jedoch dazu führen, dass Miner
  die von der doppelten Reservierung abhängig sind, ungültige Blöcke produzieren,
  was zu einem großen Einkommensverlust führen würde.  Ismail analysierte vergangene Blöcke, um
  um festzustellen, welche Mining-Pools gefährdet sein könnten.  Er stellte fest
  Ocean.xyz, F2Pool und ein unbekannter Miner verwenden offenbar
  nicht-standardmäßige Einstellungen, obwohl keiner von ihnen gefährdet zu sein scheint
  Geld zu verlieren, wenn der Fehler behoben ist.

  Um dieses Risiko zu minimieren, wird derzeit vorgeschlagen, eine neue Startoption
  einzuführen, die standardmäßig 2.000 Vbytes für Coinbase reserviert.  Miner, die keine Abwärtskompatibilität benötigen, können einfach die Reservierung
  auf 1.000 Vbytes reduzieren (oder weniger, wenn sie weniger benötigen).

  Jay Beddict [relayed][beddict double] die Nachricht an die Mining-Dev
  Mailingliste weiter.

- **Relative Timelocks auf Vertragsebene:** Gregory Sanders
  [postete][sanders clrt] an Delving Bitcoin über die Suche nach einer Lösung
  für eine Komplikation, die er vor etwa einem Jahr entdeckte (siehe [Newsletter
  #284][news284 deltas]) bei der Erstellung einer Proof-of-Concept-Implementierung
  von [LN-Symmetry][Thema eltoo]. In diesem Protokoll kann jeder Kanalstatus
  onchain bestätigt werden, aber nur der letzte Zustand, der vor einer
  Frist bestätigt wurde, kann die Mittel des Kanals verteilen. Normalerweise würden die Parteien eines
  Kanals versuchen, nur den letzten Status zu bestätigen; wenn jedoch
  Alice eine neue Statusaktualisierung einleitet, indem sie eine Transaktion teilweise signiert
  und sie an Bob sendet, kann nur Bob diese Transaktion abschließen. Wenn Bob
  den Kanal nur in dem vorletzten Zustand von Alice schließen kann,
  dauert es etwa doppelt so lange, bis der Kanal
  aufgelöst wird, was als _2x Verzögerungsproblem_ bezeichnet wird. Das bedeutet,
  [Timelocks][Thema timelocks] für [HTLCs][Thema htlc] in LN-Symmetrie
  müssen bis zu doppelt so lang sein, was es Angreifern erleichtert,
  Weiterleitungsknoten daran zu hindern, Erträge aus ihrem Kapital zu erwirtschaften (durch
  [Channel Jamming Attacks][topic channel jamming attacks] und andere
  Probleme).

  Sanders schlägt vor, das Problem mit einer relativen Zeitsperre zu lösen, die
  für alle Transaktionen gelten würde, die für die Abwicklung eines Vertrags erforderlich sind. Wenn
  LN-Symmetrie eine solche Funktion hätte und Alice den vorletzten Zustand bestätigt,
  müsste Bob den letzten Zustand vor der
  Frist des vorletzten Zustands bestätigen. In einem [späteren Beitrag][sanders tpp]
  verweist Sanders auf ein Kanalprotokoll von John Law (siehe [Newsletter
  #244][news244 tpp]), das zwei relative Timelocks auf Transaktionsebene verwendet,
  um eine relative Zeitsperre auf Vertragsebene ohne Konsensänderungen
  zu ermöglichen. Das funktioniert jedoch nicht bei der LN-Symmetrie, die es jedem
  Zustand ermöglicht, von jedem vorherigen Zustand aus ausgegeben zu werden.

  Sanders skizziert eine Lösung, merkt aber an, dass sie auch Nachteile hat. Er erwähnt auch,
  wie das Problem mit Hilfe von Chia's `coinid`-Feature gelöst werden könnte,
  das der Idee von John Law aus dem Jahr 2021 für vererbte
  Identifikatoren (IIDs) entspricht. Jeremy Rubin [antwortete][rubin muon] mit einem Link zu
  seinem Vorschlag vom letzten Jahr für _muon_-Ausgaben, die im selben
  Block wie die Transaktion, die sie erzeugt hat, ausgegeben werden
  könnten, um zu einer Lösung beizutragen. Sanders erwähnt, und Anthony Towns
  [erweitert][Towns coinid] die Funktion `coinid` der Chia
  Blockchain und zeigt, wie sie die erforderlichen Daten auf
  eine konstante Menge reduzieren könnte. Salvatore Ingala [postete][ingala cat]
  über einen ähnlichen Mechanismus mit [OP_CAT][topic op_cat], von dem er vom
  Entwickler Rijndael erfuhr, der später [Details][rijndael
  cat] veröffentlichte. Brandon Black [beschrieb][black penalty] eine
  alternative Art der Lösung - eine strafbasierte Variante von
  LN-Symmetrie - und zitierte Arbeiten von Daniel Roberts darüber (siehe nächsten News
  Artikel).

- **Mehrparteien-LN-Symmetrie-Variante mit Strafen zur Begrenzung veröffentlichter Aktualisierungen:**
  Daniel Roberts [postete][roberts sympen] auf Delving Bitcoin über
  die Verhinderung, dass eine böswillige Kanal-Gegenpartei (Mallory) in der Lage ist,
  die Kanalabrechnung zu verzögern, indem sie absichtlich alte Zustände mit einer
  höheren Feerate als eine ehrliche Gegenpartei (Bob) für die
  Bestätigung des endgültigen Zustands zahlt. Theoretisch kann Bob seinen Endzustand
  an Mallorys alten Zustand binden, und beide Transaktionen könnten im
  selben Block bestätigt werden, sodass Mallory Geld für Gebühren verliert und Bob den
  Endzustand für die gleichen Gebühren bestätigt, die er bereits bereit war zu
  zahlen. Wenn Mallory jedoch wiederholt verhindern kann, dass Bob
  von alten Zuständen erfährt, bevor diese bestätigt sind, kann sie
  verhindern, dass er antwortet, bis die [HTLCs][topic htlc] im Kanal
  ablaufen und Mallory in der Lage ist, Geld zu stehlen.

  Roberts schlug ein Verfahren vor, das es einem Kanalteilnehmer erlaubt,
  nur einen einzigen Status zu bestätigen. Wenn ein späterer Status bestätigt wird, muss der
  Teilnehmer, der den letzten Status übermittelt hat, und jeder Teilnehmer, der
  keine Zustände übermittelt hat, das Geld der Teilnehmer, die
  veraltete Zustände eingereicht haben, zurückhalten.

    Leider entdeckte Roberts nach der Veröffentlichung des Schemas
  einen kritischen Fehler: Ähnlich wie beim _2x delay
  Problem_, das in der vorigen Meldung beschrieben wurde, kann die letzte Partei, die unterschreibt,
  einen Zustand vervollständigen, den keine andere Partei vervollständigen kann, wodurch
  der letzte Unterzeichner exklusiven Zugriff auf den aktuellen Endzustand erhält. Wenn eine
  andere Partei versucht, im vorherigen Zustand abzuschließen, wird sie Geld verlieren,
  wenn der letzte Unterzeichner den Endzustand verwendet.

  Roberts untersucht derzeit alternative Ansätze, aber das Thema hat eine
  interessante Diskussion darüber angestoßen, ob die Hinzufügung eines Strafmechanismus
  zur LN-Symmetrie sinnvoll ist. Gregory Sanders, dessen frühere
  Proof-of-Concept-Implementierung von LN-Symmetry ihn zu der Überzeugung brachte,
  dass ein Strafmechanismus unnötig ist (siehe [Newsletter
  #284][news284 sympen]), merkte an, dass der "repeated-old-state"-Angriff
  ähnlich ist wie ein [replacement cycling attack][topic replacement cycling].
  Er hält "diesen Angriff für ziemlich schwach, da der Angriff[er]
  zu einem negativen EV [Erwartungswert] getrieben werden kann", selbst wenn der Verteidiger
  bescheidene Ressourcen und keinen Einblick in die Transaktionen hat, die die Miner
  versuchen, zu bestätigen.

## Releases und Release-Kandidaten

Neue Releases und Release-Kandidaten für beliebte Bitcoin-Infrastruktur
Projekte. Bitte erwägen Sie ein Upgrade auf neue Versionen oder helfen Sie beim Testen von
Release-Kandidaten.

- [Bitcoin Core 28.1][] ist ein Release einer Wartungsversion
  Version der vorherrschenden Full-Node-Implementierung.

- [BDK 0.30.1][] ist ein Wartungsrelease für die vorherige Release
  Serie, die Fehlerkorrekturen enthält.  Projekten wird empfohlen, ein Upgrade auf
  BDK wallet 1.0.0 zu aktualisieren, wie im Newsletter von letzter Woche angekündigt, für den
  die [Migrationsanleitung][bdk migration] bereitgestellt wurde.

- [LDK v0.1.0-beta1][] ist ein Release-Kandidat dieser Bibliothek für
  Erstellung von LN-fähigen Geldbörsen und Anwendungen.

## Bemerkenswerte Änderungen an Code und Dokumentation

Bemerkenswerte aktuelle Änderungen in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Verbesserungs
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], und [BINANAs][binana repo]._

- [Bitcoin Core #28121][] fügt ein neues `reject-details` Feld zur Antwort von
  RPC-Befehls "testmempoolaccept" ein neues Feld "reject-details", das nur enthalten ist, wenn die Transaktion
  aufgrund von Konsens- oder Richtlinienverstößen vom Mempool abgelehnt würde. Die
  Fehlermeldung ist identisch mit der, die von `sendrawtransaction` zurückgegeben wird, wenn die
  Transaktion auch dort abgelehnt wird.

- [BDK #1592][] führt Architectural Decision Records (ADRs) ein, um
  signifikante Änderungen zu dokumentieren, die das behandelte Problem, die Entscheidungsfaktoren
  in Betracht gezogene Alternativen, Vor- und Nachteile und die endgültige Entscheidung. Dies ermöglicht
  Neueinsteigern, sich mit der Geschichte des Repositorys vertraut zu machen. Diese PR
  fügt eine ADR-Vorlage und die ersten beiden ADRs hinzu: eines zum Entfernen des `persist`
  Modul aus `bdk_chain` zu entfernen und ein weiteres, um einen neuen `PersistedWallet` Typ einzuführen
  der eine `BDKWallet` umhüllt.

{% include snippets/recap-ad.md when="2025-01-14 15:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="28121,1592,21950" %}
[bitcoin core 28.1]: https://bitcoincore.org/bin/bitcoin-core-28.1/
[ldk v0.1.0-beta1]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.1.0-beta1
[bdk migration]: https://bitcoindevkit.github.io/book-of-bdk/getting-started/migrating/
[ismail double]: https://delvingbitcoin.org/t/analyzing-mining-pool-behavior-to-address-bitcoin-cores-double-coinbase-reservation-issue/1351
[beddict double]: https://groups.google.com/g/bitcoinminingdev/c/aM9SDXSMZDs
[sanders clrt]: https://delvingbitcoin.org/t/contract-level-relative-timelocks-or-lets-talk-about-ancestry-proofs-and-singletons/1353/
[news284 deltas]: /de/newsletters/2024/01/10/#expiry-deltas
[sanders tpp]: https://delvingbitcoin.org/t/contract-level-relative-timelocks-or-lets-talk-about-ancestry-proofs-and-singletons/1353/2
[news244 tpp]: /de/newsletters/2023/03/29/#preventing-stranded-capital-with-multiparty-channels-and-channel-factories
[rubin muon]: https://delvingbitcoin.org/t/contract-level-relative-timelocks-or-lets-talk-about-ancestry-proofs-and-singletons/1353/3
[towns coinid]: https://delvingbitcoin.org/t/contract-level-relative-timelocks-or-lets-talk-about-ancestry-proofs-and-singletons/1353/7
[ingala cat]: https://delvingbitcoin.org/t/contract-level-relative-timelocks-or-lets-talk-about-ancestry-proofs-and-singletons/1353/8
[rijndael katze]: https://delvingbitcoin.org/t/contract-level-relative-timelocks-or-lets-talk-about-ancestry-proofs-and-singletons/1353/11
[schwarze strafe]: https://delvingbitcoin.org/t/contract-level-relative-timelocks-or-lets-talk-about-ancestry-proofs-and-singletons/1353/12
[roberts sympen]: https://delvingbitcoin.org/t/broken-multi-party-eltoo-with-bounded-settlement/1364/
[news284 sympen]: /de/newsletters/2024/01/10/#penalties
[bdk 0.30.1]: https://github.com/bitcoindevkit/bdk/releases/tag/v0.30.1