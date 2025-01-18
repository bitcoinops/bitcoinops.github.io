---
title: 'Bitcoin Optech Newsletter #336'
permalink: /de/newsletters/2025/01/10/
name: 2025-01-10-newsletter-de
slug: 2025-01-10-newsletter-de
type: newsletter
layout: newsletter
lang: de
---
In der vorliegenden Newsletter-Ausgabe wird eine potenzielle Modifikation im Bereich von Bitcoin Core erörtert, die sich auf die Aktivitäten der Miner bezieht. Des Weiteren werden die Debatten über die Implementierung relativer Zeitsperren auf der Ebene von Verträgen (relative Timelocks) sowie ein Vorschlag für eine LN-Symmetrie-Variante mit optionalen Sanktionen dargelegt. Darüber hinaus werden in dieser Ausgabe unsere regelmäßigen Abschnitte, die Ankündigung neuer Releases und Release Candidates sowie signifikante Änderungen an populärer Bitcoin-Infrastruktur-Software behandelt.

## Nachrichten

- **Untersuchung des Verhaltens von Mining-Pools vor der Behebung eines Bitcoin-Core-Fehlers:**
  Im Rahmen einer Analyse wurde das Verhalten von Mining-Pools vor der Behebung eines Bitcoin-Core-Bugs untersucht. Die Untersuchung wurde von Abubakar Sadiq Ismail auf Delving Bitcoin [durchgeführt][[ismail double] und bezog sich auf einen [Bug][bitcoin core #21950], der 2021 von Antoine Riard entdeckt wurde. Dieser Bug führte dazu, dass Nodes 2.000 Vbytes in Blockvorlagen für Coinbase-Transaktionen reservieren, anstatt der vorgesehenen 1.000 Vbytes. Jede Vorlage könnte etwa fünf zusätzliche kleine Transaktionen enthalten, wenn die Doppelreservierung beseitigt würde. Dies könnte jedoch dazu führen, dass Miner, die von der doppelten Reservierung abhängig sind, ungültige Blöcke produzieren, was zu einem großen Einkommensverlust führen würde. Ismail analysierte vergangene Blöcke, um festzustellen, welche Mining-Pools gefährdet sein könnten. Er stellte fest, dass Ocean.xyz, F2Pool und ein unbekannter Miner offenbar nicht standardmäßige Einstellungen verwenden, obwohl keiner von ihnen gefährdet zu sein scheint, Geld zu verlieren, wenn der Fehler behoben ist.

  Um das Risiko jedoch zu minimieren, wird derzeit vorgeschlagen, eine neue Startoption einzuführen, die standardmäßig 2.000 Vbytes für die Coinbase vorsieht.  Miner, die keine Abwärtskompatibilität benötigen, können die Reservierung auf 1.000 vbytes reduzieren (oder weniger, wenn sie weniger brauchen).

  Jay Beddict hat diese Nachricht an die Mining-Dev-Mailingliste [weitergeleitet][beddict double] .

- **Relative Timelocks auf Vertragsebene:**
  Gregory Sanders [postete][sanders clrt] bei Delving Bitcoin über eine Lösung für eine Komplikation, die er vor etwa einem Jahr entdeckt hat (siehe [Newsletter #284][news284 deltas]). Bei der Erstellung einer Proof-of-Concept-Implementierung von [LN-Symmetry][topic eltoo]. In dem beschriebenen Protokoll ist es möglich, den Status jedes Kanals onchain zu bestätigen. Allerdings kann nur der letzte Zustand, der vor einer Frist bestätigt wurde, die Verteilung der Mittel des Kanals bewirken. Normalerweise versuchen die Parteien eines Kanals, nur den letzten Status zu bestätigen. Wenn jedoch Alice eine neue Statusaktualisierung einleitet, indem sie eine Transaktion teilweise signiert und sie an Bob sendet, kann nur Bob diese Transaktion abschließen.  Infolgedessen kann Bob den Kanal nur im vorletzten Zustand schließen, und wenn er wartet, bis der vorletzte Zustand von Alice bestätigt wurde, und dann den letzten Zustand bestätigt, dauert es doppelt so lange wie die Frist, bis der Kanal bis zur Auflösung des Kanals, was als "2x-Verzögerungsproblem" bezeichnet wird.  Dies impliziert, dass die für [timelocks][topic timelocks] für [HTLCs][topic htlc] in LN-Symmetrie erforderliche Zeit bis zu doppelt so lang sein muss, was es Angreifern erleichtert, Weiterleitungsknoten daran zu hindern, Erträge aus ihrem Kapital zu erwirtschaften (durch [channel jamming attacks][topic channel jamming attacks] und andere Probleme).

  Sanders schlägt eine Lösung für das Problem vor, die darin besteht, eine relative Zeitsperre einzuführen, die für die Erfüllung eines Vertrags zwischen allen Parteien erforderlich ist. Wenn die LN-Symmetrie über eine solche Funktion verfügen würde und Alice den vorletzten Zustand bestätigen würde, müsste Bob den letzten Zustand vor der Frist des vorletzten Zustands bestätigen. In einem späteren Beitrag verweist Sanders auf ein Kanalprotokoll von John Law (siehe [Newsletter
  #244][news244 tpp]), das zwei relative Timelocks auf Transaktionsebene verwendet, um eine relative Zeitsperre auf Vertragsebene ohne Konsensänderungen zu implementieren. Dieses Protokoll funktioniert jedoch nicht bei der LN-Symmetrie, die es jedem Zustand von jedem vorherigen Zustand ausgeben kann.

  In einem [späteren Beitrag][sanders tpp] wird auf ein Kanalprotokoll von John Law (siehe [Newsletter
  #244][news244 tpp]) verwiesen, das zwei relative Timelocks auf Transaktionsebene verwendet, um eine relative Zeitsperre auf Vertragsebene ohne Konsensänderungen zu implementieren. Allerdings funktioniert dies nicht bei der LN-Symmetrie, die es jedem Zustand von jedem vorherigen Zustand ausgeben kann.
  Sanders skizziert eine Lösung, merkt jedoch an, dass diese auch Nachteile aufweist. Er erwähnt auch, wie das Problem mit Hilfe von Chia's `coinid` feature gelöst werden könnte, das der Idee von John Law aus dem Jahr 2021 für vererbte Identifikatoren (IIDs) entspricht. Jeremy Rubin [antwortete][rubin muon] mit einem Link zu seinem Vorschlag vom letzten Jahr für _muon_ Ausgaben, die im selben Block wie die Transaktion, die sie erzeugt hat, ausgegeben werden könnten, um eine Lösung zu bilden.
  Sanders erwähnt, und Anthony Towns [erweitert][Towns coinid] die Funktion `coinid` der Chia Blockchain und zeigt, wie sie die erforderlichen Daten auf eine konstante Menge reduzieren könnte.  Salvatore Ingala [postete][ingala cat] über einen ähnlichen Mechanismus mit [OP_CAT][topic op_cat], den er vom Entwickler [Rijndael][rijndael cat] erfuhr, der später Details beschrieb. Brandon Black [beschrieb][black penalty] eine alternative Art der Lösung – eine strafbasierte Variante von LN-Symmetrie – und zitierte Arbeiten von Daniel Roberts darüber (siehe nächster News-Artikel).

- **Die Veröffentlichung von Aktualisierungen wird in der Mehrparteien-LN-Symmetrie-Variante durch Strafen begrenzt:**
  Daniel Roberts [veröffentlichte][roberts sympen]auf der Plattform "Delving Bitcoin" einen Beitrag, in dem er darlegte, wie man eine böswillige Kanal-Gegenpartei (Mallory) daran hindern kann, die Kanalabrechnung zu verzögern. Zu diesem Zweck zahlt Mallory einer ehrlichen Gegenpartei (Bob) absichtlich eine höhere Gebühr für die Bestätigung des endgültigen Zustands, als es bei einer böswilligen Gegenpartei der Fall wäre.  In der Theorie besteht für Bob die Möglichkeit, seinen Endzustand an Mallorys alten Zustand zu binden. Beide Transaktionen könnten in demselben Block bestätigt werden, was dazu führen würde, dass Mallory Geld für Gebühren verliert und Bob den Endzustand für die gleichen Gebühren bestätigt, die er bereits bereit war zu zahlen.  Es besteht jedoch die Möglichkeit, dass Mallory verhindern kann, dass Bob alten Zuständen erfährt, bevor diese bestätigt sind. In diesem Fall kann sie verhindern, dass er antwortet, bis die [HTLCs][topic htlc] im Kanal ablaufen und sie in der Lage ist, Geld zu stehlen.

  Roberts Vorschlag sieht ein Verfahren vor, das es einem Kanalteilnehmer erlaubt, nur einen einzigen Status zu bestätigen.  Gemäß der von Roberts vorgeschlagenen Methode ist es einem Kanalteilnehmer möglich, lediglich einen einzigen Status zu bestätigen. Im Falle einer späteren Bestätigung eines weiteren Status durch einen anderen Teilnehmer oder Teilnehmer, der keinen Status übermittelt hat, ist es den zuvor genannten Teilnehmern möglich, das Geld der Teilnehmer zu erhalten, die veraltete Zustände eingereicht haben.



  Leider wurde nach der Publikation des Schemas ein kritischer Fehler darin festgestellt. Ähnlich wie bei dem in der vorherigen Meldung beschriebenen "_2x delay Problem_", das in der vorherigen Nachricht thematisiert wurde, kann die letzte Partei, die unterschreibt, einen Zustand vervollständigen, den keine andere Partei vervollständigen kann. Dadurch erhält der letzte Unterzeichner exklusiven Zugriff auf den aktuellen Endzustand.  Roberts stellte nach der Veröffentlichung des Schemas einen kritischen Fehler darin fest. Ähnlich wie bei dem in der vorherigen Meldung beschriebenen 2x-Delay-Problem kann die letzte Partei, die unterschreibt, einen Zustand vervollständigen, den keine andere Partei vervollständigen kann. Dadurch erhält der letzte Unterzeichner exklusiven Zugriff auf den aktuellen Endzustand. Wenn eine andere Partei versucht, im vorherigen Zustand abzuschließen, wird sie Geld verlieren, wenn der Endunterzeichner den Endzustand verwendet. Roberts untersucht derzeit alternative Ansätze, aber das Thema hat eine interessante Diskussion darüber ausgelöst, ob die Hinzufügung eines Strafmechanismus zur LN-Symmetrie sinnvoll ist.  Gregory Sanders, dessen frühere Proof-of-Concept-Implementierung von LN-Symmetry ihn zu der Überzeugung brachte, dass ein Strafmechanismus unnötig ist (siehe [Newsletter #284][news284 sympen]), merkte an, dass der "repeated-old-state"-Angriff ähnlich ist wie ein [replacement cycling attack][topic replacement cycling].
  Sanders kommt zu dem Schluss, dass der genannte Angriff als schwach einzustufen ist, da er zu einem negativen Erwartungswert getrieben werden kann, selbst wenn der Verteidiger über bescheidene Ressourcen verfügt und keinen Einblick in die Transaktionen hat, welche die Miner versuchen, zu bestätigen.

## Releases und Release-Kandidaten

Neue Releases und Release-Kandidaten für beliebte Bitcoin-Infrastruktur
Projekte. Bitte erwägen Sie ein Upgrade auf neue Versionen oder helfen Sie beim Testen von
Release-Kandidaten.

- [Bitcoin Core 28.1][] ist ein Release einer Wartungsversion
  Version der vorherrschenden Full-Node-Implementierung.

- [BDK 0.30.1][] ist ein Wartungsrelease für die vorherige Release
  Serie mit Fehlerkorrekturen. Projekten wird empfohlen, ein Upgrade auf
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

- [Bitcoin Core #28121][] wird ein neues Feld namens `reject-details` eingeführt, das in der Antwort des RPC-Befehls `testmempoolaccept` enthalten ist.
  Dieses Feld wird nur angezeigt, wenn die Transaktion aufgrund  von Konsens- oder Richtlinienverstößen vom Mempool abgelehnt wurde.
  Die Fehlermeldung ist identisch mit der, die von `sendrawtransaction` zurückgegeben wird, wenn die Transaktion auch dort abgelehnt wird.

- [BDK #1592][] erfolgt die Einführung von Architectural Decision Records (ADRs), um signifikante Änderungen zu dokumentieren.
Dies umfasst das behandelte Problem, die Entscheidungsfaktoren, in Betracht gezogene Alternativen, Vor- und Nachteile sowie die endgültige Entscheidung.
Hierdurch wird es Neueinsteigern ermöglicht, sich mit der Geschichte des Repositorys vertraut zu machen.
Die vorliegende PR-Anwendung ergänzt die vorhandene ADR-Vorlage um zwei weitere ADRs:
Die erste dient der Entfernung des `persist`-Moduls aus `bdk_chain`, die zweite der Einführung eines neuen `PersistedWallet`-Typs, der eine `BDKWallet` umhüllt.

{% include snippets/recap-ad.md when="2025-01-14 15:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="28121,1592,21950" %}
[bitcoin core 28.1]: https://bitcoincore.org/bin/bitcoin-core-28.1/
[ldk v0.1.0-beta1]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.1.0-beta1
[bdk migration]: https://bitcoindevkit.github.io/book-of-bdk/getting-started/migrating/
[ismail double]: https://delvingbitcoin.org/t/analyzing-mining-pool-behavior-to-address-bitcoin-cores-double-coinbase-reservation-issue/1351
[beddict double]: https://groups.google.com/g/bitcoinminingdev/c/aM9SDXSMZDs
[sanders clrt]: https://delvingbitcoin.org/t/contract-level-relative-timelocks-or-lets-talk-about-ancestry-proofs-and-singletons/1353/
[news284 deltas]: /en/newsletters/2024/01/10/#expiry-deltas
[sanders tpp]: https://delvingbitcoin.org/t/contract-level-relative-timelocks-or-lets-talk-about-ancestry-proofs-and-singletons/1353/2
[news244 tpp]: /en/newsletters/2023/03/29/#preventing-stranded-capital-with-multiparty-channels-and-channel-factories
[rubin muon]: https://delvingbitcoin.org/t/contract-level-relative-timelocks-or-lets-talk-about-ancestry-proofs-and-singletons/1353/3
[towns coinid]: https://delvingbitcoin.org/t/contract-level-relative-timelocks-or-lets-talk-about-ancestry-proofs-and-singletons/1353/7
[ingala cat]: https://delvingbitcoin.org/t/contract-level-relative-timelocks-or-lets-talk-about-ancestry-proofs-and-singletons/1353/8
[rijndael cat]: https://delvingbitcoin.org/t/contract-level-relative-timelocks-or-lets-talk-about-ancestry-proofs-and-singletons/1353/11
[black penalty]: https://delvingbitcoin.org/t/contract-level-relative-timelocks-or-lets-talk-about-ancestry-proofs-and-singletons/1353/12
[roberts sympen]: https://delvingbitcoin.org/t/broken-multi-party-eltoo-with-bounded-settlement/1364/
[news284 sympen]: /en/newsletters/2024/01/10/#penalties
[bdk 0.30.1]: https://github.com/bitcoindevkit/bdk/releases/tag/v0.30.1
