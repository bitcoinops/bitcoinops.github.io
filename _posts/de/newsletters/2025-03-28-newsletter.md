---
title: 'Bitcoin Optech Newsletter #347'
permalink: /de/newsletters/2025/03/28/
name: 2025-03-28-newsletter-de
slug: 2025-03-28-newsletter-de
type: newsletter
layout: newsletter
lang: de
---
Der Newsletter dieser Woche beschreibt einen Vorschlag, der es dem
Lightning Network ermöglichen soll, Vorab- und Haltegebühren auf Basis
von verbrennbaren Outputs zu unterstützen. Zudem fasst er die Diskussionen
zu Testnetzen 3 und 4 (inklusive eines Hard-Fork-Vorschlags) zusammen und kündigt
einen Plan an, bestimmte Transaktionen mit Taproot-Anhängen weiterzuleiten.
Außerdem enthält der Newsletter unsere üblichen Rubriken, in denen ausgewählte
Fragen und Antworten vom Bitcoin Stack Exchange, neue Releases und Release-Kandidaten
sowie wesentliche Änderungen populärer Bitcoin-Infrastrukturprojekte vorgestellt werden.

## News

- **LN-Vorab- und Haltegebühren mittels verbrennbarer Outputs:**  
  John Law hat im Delving Bitcoin-Forum [einen Beitrag][law fees] veröffentlicht,
  in dem er ein [Papier][law fee paper] zusammenfasst, das ein Protokoll beschreibt,
  mit dem Nodes zwei zusätzliche Gebührenarten für das Weiterleiten von Zahlungen erheben
  können. Eine _Vorabgebühr_ würde vom Endzahler entrichtet, um Weiterleitungsnodes für
  die temporäre Nutzung eines _HTLC-Slots_ (eine der begrenzten, gleichzeitig verfügbaren
  Ressourcen in einem Kanal zur Durchsetzung von [HTLCs][topic htlc]) zu entschädigen.
  Eine _Haltegebühr_ würde von einem Node gezahlt, der die Abwicklung eines HTLC verzögert;
  die Höhe dieser Gebühr würde mit der Dauer der Verzögerung ansteigen – bis zum Erreichen des
  maximalen Betrags, der beim Ablauf des HTLC festgelegt wurde. Sein Beitrag und das Papier
  verweisen auf mehrere frühere Diskussionen zu Vorab- und Haltegebühren, wie sie in den
  Newslettern [#86][news86 reverse upfront], [#119][news119 trusted upfront], [#120][news120 upfront],
  [#122][news122 bi-directional], [#136][news136 more fee] und [#263][news263 dos philosophy]
  zusammengefasst wurden.

  Das vorgeschlagene Protokoll baut auf den Ideen von Laws _Offchain Payment Resolution_
  (OPR)-Protokoll auf (siehe [Newsletter #329][news329 opr]), bei dem die Kanalmitbesitzer
  jeweils 100 % der streitigen Gelder (also insgesamt 200 %) einem _verbrennbaren Output_
  zuweisen, den jeder von ihnen einseitig zerstören kann. Die streitigen Gelder umfassen
  in diesem Fall die Vorabgebühr plus die maximalen Haltegebühren. Wenn beide Parteien
  später zufrieden sind, dass das Protokoll korrekt befolgt wurde, z. B. dass alle Gebühren
  korrekt gezahlt wurden, entfernen sie den verbrennbaren Output aus zukünftigen Versionen
  ihrer Offchain-Transaktionen. Wenn eine Partei unzufrieden ist, schließen sie den Kanal
  und zerstören die verbrennbaren Gelder. Obwohl die unzufriedene Partei in diesem Fall
  Gelder verliert, tut dies auch die andere Partei, wodurch verhindert wird, dass eine
  Partei von der Verletzung des Protokolls profitiert.

  Law beschreibt das Protokoll als Lösung für [Channel Jamming Angriffe][topic channel jamming attacks],
  eine Schwachstelle im Lightning Network, die erstmals [vor fast einem Jahrzehnt][russell loop]
  beschrieben wurde und es einem Angreifer ermöglicht, fast kostenlos zu verhindern, dass andere
  Nodes einige oder alle ihrer Gelder nutzen können. In einer [Antwort][harding fee] wurde
  darauf hingewiesen, dass die Einführung von Haltegebühren möglicherweise
  [Hold Invoices][topic hold invoices] für das Netzwerk nachhaltiger machen könnte.

- **Diskussion zu Testnetzen 3 und 4:**  
  Sjors Provoost fragte in der Bitcoin-Dev-Mailingliste [nach][provoost testnet3],
  ob noch jemand Testnet3 verwendet, da Testnet4 nun seit etwa sechs Monaten im Einsatz
  ist (siehe [Newsletter #315][news315 testnet4]). Andres Schildbach antwortete
  [dahingehend][schildbach testnet3], dass er vorhat, Testnet3 in der Testversion seiner
  beliebten Wallet mindestens noch ein Jahr lang zu nutzen. Olaoluwa Osuntokun bemerkte,
  [dass Testnet3][osuntokun testnet3] in letzter Zeit deutlich stabiler ist als Testnet4.
  Er untermauerte seinen Standpunkt durch Screenshots der Blockbäume beider Testnets, die
  von der [Fork.Observer][]-Website stammen. Nachfolgend siehst du unseren eigenen Screenshot,
  der den Zustand von Testnet4 zum Zeitpunkt der Erstellung zeigt:

  ![Fork Monitor zeigt den Blockbaum von Testnet4 am 25.03.2025](/img/posts/2025-03-fork-monitor-testnet3.png)

  Nach Osuntokuns Beitrag startete Antoine Poinsot einen [separaten Thread][poinsot testnet4],
  um sich auf die Probleme von Testnet4 zu konzentrieren. Er argumentiert, dass die Probleme
  von Testnet4 eine Folge der Regel zum Schwierigkeits-Reset sind. Diese Regel, die nur für
  Testnet gilt, erlaubt es einem Block, mit minimaler Schwierigkeit gültig zu sein, wenn seine
  Header-Zeit 20 Minuten später als die seines Elternblocks ist. Provoost geht in
  [Detail][provoost testnet4] auf das Problem ein. Poinsot schlägt einen Hard Fork für
  Testnet4 vor, um die Regel zu entfernen. Mark Erhardt [schlägt][erhardt testnet4] ein
  Datum für den Fork vor: 08.01.2026.

- **Plan zur Weiterleitung bestimmter Taproot-Anhänge:**  
  Peter Todd kündigte in der Bitcoin-Dev-Mailingliste [an][todd annex], dass er plant,
  seinen auf Bitcoin Core basierenden Node, Libre Relay, so zu aktualisieren, dass er
  Transaktionen mit Taproot-[annexes][topic annex] weiterleitet – vorausgesetzt, diese
  erfüllen bestimmte Regeln:

  - _0x00-Präfix:_ "Alle nicht-leeren Anhänge beginnen mit dem Byte 0x00, um sie von
  [zukünftigen] konsensrelevanten Anhängen zu unterscheiden."

  - _Alles oder nichts:_ "Alle Inputs müssen einen Anhang besitzen. Dies stellt sicher,
  dass die Verwendung des Anhangs freiwillig erfolgt und verhindert dadurch
  [Transaction Pinning][topic transaction pinning]-Angriffe in Mehrparteien-Protokollen."

  Der Plan basiert auf einem 2023er [Pull Request][bitcoin core #27926] von Joost Jager,
  der seinerseits auf einer früheren Diskussion beruhte (siehe [Newsletter #255][news255 annex]).
  Nach Jagers Worten begrenzte der frühere Pull Request auch "die maximale Größe unstrukturierter
  Anhangsdaten auf 256 Bytes [...] und bot dadurch einen gewissen Schutz vor einer Inflation
  des Anhangs in Mehrparteien-Transaktionen." Todds Version sieht diese Regel nicht vor;
  er ist der Ansicht, dass "die Voraussetzung, den Einsatz des Anhangs freiwillig zu wählen,
  ausreichend sein sollte." Falls dies nicht ausreicht, beschreibt er eine zusätzliche
  Änderung im Relay, die ein Counterparty Pinning verhindern könnte.

## Ausgewählte Fragen & Antworten von Bitcoin Stack Exchange

*Der Bitcoin Stack Exchange ist eine der ersten Anlaufstellen für Optech-Mitwirkende, wenn es darum geht, Antworten auf technische Fragen zu finden – oder wenn gerade freie Momente vorhanden sind, um neugierigen oder etwas verwirrten Nutzern zu helfen.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Warum ist das Witness Commitment optional?]({{bse}}125948)
  Pieter Wuille und Antoine Poinsot erklären [BIP30][] "Duplicate transactions",
  [BIP34][] "Block v2, Height in Coinbase" und [consensus cleanup][topic consensus cleanup]
  -Überlegungen rund um das [Block 1,983,702 Problem][topic duplicate transactions]
  und wie die verpflichtende Einführung des Witness Commitments das Problem lösen würde.

- [Können alle konsensgültigen 64-Byte-Transaktionen (von Dritten) manipuliert werden,um ihre Größe zu ändern?]({{bse}}125971)
  Sjors Provoost untersucht Ideen zur Manipulation von [64-Byte-Transaktionen][news27 64tx],
  die konsensungültig wären, wenn der [consensus cleanup][topic consensus cleanup]-Soft Fork
  aktiviert würde. Vojtěch Strnad argumentiert, dass nicht jede 64-Byte-Transaktion von Dritten
  manipuliert werden kann, aber es wäre dennoch der Fall, dass der Output einer 64-Byte-Transaktion
  entweder unsicher (von jedem ausgebbar) oder nachweislich unspendbar (z. B. ein `OP_RETURN`) wäre.

- [Wie lange dauert es, bis eine Transaktion im Netzwerk propagiert(verbreitet) wird?]({{bse}}125776)
  Sr_gi weist darauf hin, dass ein einzelner Node keine netzwerkweiten Transaktionspropagationszeiten
  messen kann und dass mehrere Nodes im gesamten Bitcoin-Netzwerk erforderlich wären, um
  Propagationszeiten zu messen und zu schätzen. Er verweist auf eine [Website][dsn kit],
  die von der Decentralized Systems and Network Services Research Group am KIT betrieben
  wird und unter anderem Transaktionspropagationszeiten misst. Diese zeigt, dass "eine
  Transaktion etwa ~7 Sekunden benötigt, um 50 % des Netzwerks zu erreichen, und etwa
  ~17 Sekunden, um 90 % zu erreichen".

- [Nützlichkeit der langfristigen Gebührenabschätzung]({{bse}}124227)
  Abubakar Sadiq Ismail sucht Feedback von Projekten, Protokollen oder Nutzern, die
  sich auf langfristige Gebührenabschätzungen verlassen, für seine Arbeit zur
  [Gebührenabschätzung][topic fee estimation].

- [Warum werden zwei Anchor Outputs im LN verwendet?]({{bse}}125883)
  Instagibbs bietet historischen Kontext zu den [Anchor Outputs][topic anchor outputs],
  die derzeit im Lightning Network verwendet werden, und weist darauf hin, dass mit
  Änderungen an den [Bitcoin Core Policies in 28.0][28.0 wallet guide] ein geplantes
  Update zu [v3 Commitments][topic v3 commitments] erfolgt.

- [Warum gibt es keine BIPs im Bereich 2xx?]({{bse}}125914)
  Michael Folkson weist darauf hin, dass BIP-Nummern 200-299 zu einem bestimmten
  Zeitpunkt für Lightning-bezogene BIPs reserviert wurden.

- [Warum verwendet Bech32 nicht das Zeichen "b"?]({{bse}}125902)
  Bordalix antwortet, dass die visuelle Ähnlichkeit zwischen "B" und "8" der Grund
  dafür war, "B" in den [Bech32 und Bech32m][topic bech32]-Adressformaten nicht
  zuzulassen. Er liefert auch zusätzliche Trivia(Wissenswertes) rund um Bech32.

- [Bech32 Fehlererkennung und -korrektur Referenzimplementierung]({{bse}}125961)
  Pieter Wuille merkt an, dass Bech32 bis zu vier Fehler in der Adresscodierung
  erkennen und zwei Substitutionsfehler korrigieren kann.

- [Wie kann man sicher Staub ausgeben/verbrennen?]({{bse}}125702)
  Murch listet Dinge auf, die beim Senden von [Staub][topic uneconomical outputs]
  aus einer bestehenden Wallet zu beachten sind.

- [Wie wird die Rückerstattungstransaktion in Asymmetric Revocable Commitments konstruiert?]({{bse}}125905)
  Biel Castellarnau geht die Beispiele von Commitment-Transaktionen aus dem
  Buch Mastering Bitcoin durch.

- [Welche Anwendungen nutzen ZMQ mit Bitcoin Core?]({{bse}}125920)
  Sjors Provoost sucht Nutzer der ZMQ-Dienste von Bitcoin Core im Rahmen der
  Untersuchung, ob [IPC][news320 ipc] diese Anwendungen ersetzen könnte.

## Releases und Release-Kandidaten

_Neuerscheinungen und Release-Kandidaten populärer Bitcoin-Infrastrukturprojekte – bitte erwägen Sie ein Upgrade oder helfen Sie beim Testen neuer Versionen._

- [Bitcoin Core 29.0rc2][] ist ein Release-Kandidat für die nächste Hauptversion
des am weitesten verbreiteten Full Nodes. Bitte sehen Sie sich den
[Version 29 Testing Guide][bcc29 testing guide] an.

- [LND 0.19.0-beta.rc1][] ist ein Release-Kandidat für diesen beliebten
LN-Knoten. Einer der wesentlichen Verbesserungsansätze, der sicherlich weiterer
Tests bedarf, ist das neue, auf RBF-basierte Fee-Bumping für kooperative Kanal-Schließungen,
das unten im Abschnitt zu den wesentlichen Codeänderungen beschrieben wird.

## Wichtige Änderungen an Code und Dokumentation

_Bedeutende jüngste Änderungen in [Bitcoin Core][bitcoin core repo],
[Core Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet Interface (HWI)][hwi repo],
[Rust Bitcoin][rust bitcoin repo], [BTCPay Server][btcpay server repo], [BDK][bdk repo],
[Bitcoin Improvement Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition repo]
und [BINANAs][binana repo]._

- [Bitcoin Core #31603][] aktualisiert den Parser `ParsePubkeyInner`, um öffentliche
Schlüssel mit führenden oder nachgestellten Leerzeichen abzulehnen – entsprechend dem
Parsing-Verhalten des [rust-miniscript][rust miniscript]-Projekts. Es sollte zuvor
nicht möglich gewesen sein, versehentlich Leerzeichen hinzuzufügen, da der Schutz der
Descriptor-Prüfsumme dies verhindert. Die RPC-Befehle `getdescriptorinfo` und
`importdescriptors` werfen jetzt einen Fehler, wenn das öffentliche Schlüssel-Fragment
eines [Descriptors][topic descriptors] solche Leerzeichen enthält.

- [Eclair #3044][] erhöht die standardmäßige Mindestanzahl an Bestätigungen für die
Kanalsicherheit gegen Block-Reorganisationen von 6 auf 8. Es entfernt auch die
Skalierung dieses Werts basierend auf dem Kanal-Finanzierungsbetrag, da die
Kanal-Kapazität während des [Splicing][topic splicing] erheblich geändert werden
kann, was den Node dazu bringen könnte, eine niedrige Anzahl von Bestätigungen für
tatsächlich große Geldbeträge zu akzeptieren.

- [Eclair #3026][] fügt Unterstützung für Bitcoin Core Wallets mit
[Pay-to-Taproot (P2TR)][topic taproot]-Adressen hinzu, einschließlich Watch-Only-Wallets,
die von Eclair verwaltet werden, als Grundlage für die Implementierung
[einfacher Taproot-Kanäle][topic simple taproot channels]. P2WPKH-Skripte sind
weiterhin für einige gegenseitige Schließungstransaktionen erforderlich, auch bei
Verwendung einer P2TR-Wallet.

- [LDK #3649][] ermöglicht das Bezahlen von Lightning Service Providern (LSPs) mit
[BOLT12 offers][topic offers] durch zusätzliche Felder. Zuvor waren nur [BOLT11][]
und On-Chain-Zahlungsoptionen aktiviert. Dies wurde auch in [BLIPs #59][] vorgeschlagen.

- [LDK #3665][] vergrößert das Limit für [BOLT11][]-Invoices von 1.023 auf 7.089 Bytes,
um LNDs Limit anzupassen, das auf der maximalen Anzahl von Bytes basiert, die auf einen
QR-Code passen. Der PR-Autor argumentiert, dass QR-Codes, die mit der Codierung in einer
BOLT11-Rechnung kompatibel sind, tatsächlich auf 4.296 Zeichen begrenzt sind, aber der
Wert von 7.089 wird für LDK gewählt, da "systemweite Konsistenz wahrscheinlich wichtiger ist."

- [LND #8453][], [#9559][lnd #9559], [#9575][lnd #9575], [#9568][lnd #9568], und [LND #9610][]
führen einen [RBF][topic rbf] kooperativen Close-Flow basierend auf [BOLTs #1205][]
(siehe [Newsletter #342][news342 closev2]) ein, der es beiden Peers ermöglicht, durch
eigene Kanal-Fonds die Gebühr zu erhöhen. Zuvor mussten Peers manchmal ihre Gegenpartei
überzeugen, für Gebührenanhebungen zu zahlen, was oft zu gescheiterten Versuchen führte.
Um diese Funktion zu aktivieren, muss die Konfigurationsflagge `protocol.rbf-coop-close`
gesetzt werden.

- [BIPs #1792][] aktualisiert [BIP119][], das [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify]
spezifiziert, durch eine überarbeitete Formulierung, die Sprache
für bessere Klarheit überarbeitet, die Aktivierungslogik entfernt, Eltoo in [LN-Symmetry][topic eltoo]
umbenennt und Erwähnungen neuer [Covenant][topic covenants]-Vorschläge und Projekte wie [Ark][topic ark]
hinzufügt, die `OP_CTV` verwenden.

- [BIPs #1782][] reformatiert den Spezifikationsabschnitt von [BIP94][], der die Konsensregeln von
[Testnet4][topic testnet] klarer und leserlicher darstellt.

{% include snippets/recap-ad.md when="2025-04-01 15:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="31603,3044,3026,3649,3665,9610,1792,1782,27926,8453,9559,9575,9568,1205,59" %}
[bitcoin core 29.0rc2]: https://bitcoincore.org/bin/bitcoin-core-29.0/
[bcc29 testing guide]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/29.0-Release-Candidate-Testing-Guide
[lnd 0.19.0-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.19.0-beta.rc1
[news255 annex]: /en/newsletters/2023/06/14/#discussion-about-the-taproot-annex
[news315 testnet4]: /en/newsletters/2024/08/09/#bitcoin-core-29775
[fork.observer]: https://fork.observer/
[law fees]: https://delvingbitcoin.org/t/fee-based-spam-prevention-for-lightning/1524/
[law fee paper]: https://github.com/JohnLaw2/ln-spam-prevention
[news329 opr]: /en/newsletters/2024/11/15/#mad-based-offchain-payment-resolution-opr-protocol
[harding fee]: https://delvingbitcoin.org/t/fee-based-spam-prevention-for-lightning/1524/4
[provoost testnet3]: https://mailing-list.bitcoindevs.xyz/bitcoindev/9FAA7EEC-BD22-491E-B21B-732AEA15F556@sprovoost.nl/
[schildbach testnet3]: https://mailing-list.bitcoindevs.xyz/bitcoindev/7c28f8e9-d221-4633-8b71-53b4db07fa78@schildbach.de/
[osuntokun testnet3]: https://groups.google.com/g/bitcoindev/c/jYBlh24OB-Y/m/vbensqcZAwAJ
[poinsot testnet4]: https://mailing-list.bitcoindevs.xyz/bitcoindev/hU75DurC5XToqizyA-vOKmVtmzd3uZGDKOyXuE_ogE6eQ8tPCrvX__S08fG_nrW5CjH6IUx7EPrq8KwM5KFy9ltbFBJZQCHR2ThoimRbMqU=@protonmail.com/
[provoost testnet4]: https://mailing-list.bitcoindevs.xyz/bitcoindev/2064B7F4-B23A-44B0-A361-0EC4187D8E71@sprovoost.nl/
[erhardt testnet4]: https://mailing-list.bitcoindevs.xyz/bitcoindev/7c6800f0-7b77-4aca-a4f9-2506a2410b29@murch.one/
[todd annex]: https://mailing-list.bitcoindevs.xyz/bitcoindev/Z9tg-NbTNnYciSOh@petertodd.org/
[russell loop]: https://diyhpl.us/~bryan/irc/bitcoin/bitcoin-dev/linuxfoundation-pipermail/lightning-dev/2015-August/000135.txt
[news263 dos philosophy]: /en/newsletters/2023/08/09/#denial-of-service-dos-protection-design-philosophy
[news136 more fee]: /en/newsletters/2021/02/17/#renewed-discussion-about-bidirectional-upfront-ln-fees
[news122 bi-directional]: /en/newsletters/2020/11/04/#bi-directional-upfront-fees-for-ln
[news86 reverse upfront]: /en/newsletters/2020/02/26/#reverse-up-front-payments
[news119 trusted upfront]: /en/newsletters/2020/10/14/#trusted-upfront-payment
[news120 upfront]: /en/newsletters/2020/10/21/#more-ln-upfront-fees-discussion
[news342 closev2]: /en/newsletters/2025/02/21/#bolts-1205
[rust miniscript]: https://github.com/rust-bitcoin/rust-miniscript
[dsn kit]: https://www.dsn.kastel.kit.edu/bitcoin/#propdelaytx
[28.0 wallet guide]: /en/bitcoin-core-28-wallet-integration-guide/
[news320 ipc]: /en/newsletters/2024/09/13/#bitcoin-core-30509
[news27 64tx]: /en/newsletters/2018/12/28/#cve-2017-12842
