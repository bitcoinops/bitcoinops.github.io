---
title: 'Bitcoin Optech Newsletter #339'
permalink: /de/newsletters/2025/01/31/
name: 2025-01-31-newsletter-de
slug: 2025-01-31-newsletter-de
type: newsletter
layout: newsletter
lang: de
---
Der Newsletter dieser Woche beschreibt eine Sicherheitslücke, die ältere Versionen von LDK
betrifft, beleuchtet einen neu bekannt gewordenen Aspekt einer ursprünglich im Jahr 2023
veröffentlichten Sicherheitslücke und fasst die erneute Diskussion über Statistiken zur
kompakten Blockrekonstruktion zusammen. Außerdem enthält er unsere regulären Rubriken, in denen
populäre Fragen auf der Bitcoin Stack Exchange zusammengefasst, neue Releases und
Release-Kandidaten angekündigt sowie aktuelle Änderungen an populärer
Bitcoin-Infrastruktursoftware beschrieben werden.

## News

- **Sicherheitslücke in der LDK-HTLC-Abwicklung:**
  Matt Morehouse hat auf Delving Bitcoin einen Beitrag [veröffentlicht][morehouse ldkclaim], in dem
  er eine Schwachstelle in LDK aufdeckte – eine Schwachstelle, die er
  [verantwortungsvoll offengelegt][topic responsible disclosures] hat und die in LDK Version 0.1 behoben wurde.

  Wenn ein Kanal einseitig geschlossen wird und dabei mehrere ausstehende [HTLCs][topic htlc]
  vorhanden sind, versucht LDK, möglichst viele HTLCs in einer einzigen Sammeltransaktion
  abzuwickeln, um Transaktionsgebühren zu sparen. Sollte allerdings die Gegenpartei in der Lage
  sein, einen der zusammengefassten HTLCs zuerst zu bestätigen, führt dies zu einem _Konflikt_ mit
  der Sammeltransaktion und macht diese ungültig. In diesem Fall erstellt LDK korrekt eine
  aktualisierte Sammeltransaktion, in der der Konflikt entfernt wurde. Unglücklicherweise
  aktualisiert LDK, falls die Transaktion der Gegenpartei mit mehreren separaten
  Sammeltransaktionen in Konflikt steht, fälschlicherweise nur die erste, sodass die übrigen nicht
  bestätigt werden können.

  Die Knoten müssen ihre HTLCs vor Ablauf einer festgelegten Frist abwickeln, da die Gegenpartei
  sonst in der Lage ist, die Gelder zurückzuholen. Ein [Timelock][topic timelocks] verhindert,
  dass die Gegenpartei die HTLCs vor ihren individuellen Fristen ausgibt.

  Die meisten älteren Versionen von LDK legten diese HTLCs in eine separate Sammeltransaktion, von
  der sichergestellt war, dass sie bestätigt wurde, bevor die Gegenpartei eine widersprüchliche
  Transaktion durchführen konnte – so wurde verhindert, dass Gelder gestohlen werden. Bei HTLCs,
  die zwar einen Gelddiebstahl nicht zuließen, jedoch von der Gegenpartei umgehend abgewickelt
  werden konnten, bestand das Risiko, dass diese Gelder blockiert werden. Morehouse schreibt, dass
  dieses Problem behoben werden kann, indem man „auf LDK Version 0.1 aktualisiert und die Abfolge
  der Commitment- und HTLC-Transaktionen, die zur Blockade geführt haben, erneut abspielt."

  Der Release-Kandidat LDK 0.1-beta änderte jedoch seine Logik (siehe [Newsletter #335][news335 ldk3340])
  und begann damit, alle Arten von HTLCs zusammenzufassen, wodurch ein Angreifer in die
  Lage versetzt würde, einen Konflikt mit einem HTLC, der einem Timelock unterliegt, zu erzeugen.
  Bleibt die Auflösung dieses HTLCs auch nach Ablauf des Timelocks blockiert, wäre ein Diebstahl
  möglich. Ein Upgrade auf die Release-Version von LDK 0.1 behebt auch diese Art der Schwachstelle.

  Morehouses Beitrag liefert weitere Details und diskutiert mögliche Ansätze, um zukünftige
  Schwachstellen, die aus derselben Grundursache resultieren, zu verhindern.

- **Angriffe durch Replacement Cycling mit Ausnutzung von Minern:**
  Antoine Riard hat auf der Bitcoin-Dev-Mailingliste einen Beitrag [veröffentlicht][riard minecycle],
  um eine weitere Schwachstelle offenzulegen, die mit dem [Replacement Cycling][topic replacement cycling]
  Angriff möglich ist – einem Angriff, den er ursprünglich
  2023 öffentlich bekannt machte (siehe [Newsletter #274][news274 cycle]).

  Kurz zusammengefasst:

  1. Bob sendet eine Transaktion, in der er an Mallory (und möglicherweise an weitere Empfänger)
     zahlt.

  2. Mallory [pinnt][topic transaction pinning] Bobs Transaktion.

  3. Bob bemerkt nicht, dass seine Transaktion gepinnt wurde, und erhöht die Gebühren (entweder
     mittels [RBF][topic rbf] oder [CPFP][topic cpfp]).

  4. Da Bobs ursprüngliche Transaktion gepinnt wurde, wird seine Gebührenanhebung nicht
     weiterverbreitet – dennoch gelangt sie irgendwie zu Mallory. Die Schritte 3 und 4 können
     mehrfach wiederholt werden, um Bobs Gebühren erheblich in die Höhe zu treiben.

  5. Mallory baut Bobs höchste Gebührenanhebung in einen Block ein – diesen versucht sonst kein
     anderer Miner zu verarbeiten, da er aufgrund der fehlenden Propagation nicht im Netzwerk
     ankommt. Dadurch kann Mallory mehr Gebühren verdienen als andere Miner.

  6. Mallory kann nun das Replacement Cycling einsetzen, um ihren Transaktions-Pin auf eine andere
     Transaktion zu übertragen und den Angriff zu wiederholen (möglicherweise sogar mit einem
     anderen Opfer), ohne zusätzliche Mittel aufzubringen. Somit erweist sich der Angriff als
     wirtschaftlich effizient.

  Wir beurteilen diese Schwachstelle nicht als ein signifikantes Risiko. Die Ausnutzung setzt
  spezielle, möglicherweise seltene Umstände voraus und kann dazu führen, dass ein Angreifer Geld
  verliert, wenn er die Netzbedingungen falsch einschätzt. Sollte ein Angreifer die Schwachstelle
  regelmäßig ausnutzen, gehen wir davon aus, dass sein Verhalten von Community-Mitgliedern, die
  [Block-Monitoring-Tools][miningpool.observer] entwickeln und einsetzen, erkannt wird.

- **Aktualisierte Statistiken zur Kompaktblock-Rekonstruktion:**
  Auf einen vorherigen Thread (siehe [Newsletter #315][news315 cb]) folgend, hat Entwickler 0xB10C
  in einem Beitrag an Delving Bitcoin aktualisierte Statistiken darüber veröffentlicht, wie häufig
  seine Bitcoin Core-Knoten zusätzliche Transaktionen anfordern müssen, um die
  [Kompaktblock][topic compact block relay]-Rekonstruktion durchzuführen.

  Wenn ein Knoten einen Kompaktblock empfängt, muss er alle Transaktionen anfordern, die in diesem
  Block enthalten sind, sich aber nicht bereits in seinem Mempool (oder in seinem _Extrapool_,
  einem speziellen Reservenpool zur Unterstützung der Kompaktblock-Rekonstruktion) befinden. Diese
  zusätzliche Anforderung verlangsamt die Blockpropagation erheblich und trägt zur
  Zentralisierung der Miner bei.

  0xB10C stellte fest, dass die Häufigkeit der Anfragen signifikant zunimmt, je größer der
  Mempool wird. Mehrere Entwickler diskutierten mögliche Ursachen, wobei erste Daten darauf
  hindeuteten, dass es sich bei den fehlenden Transaktionen um _Orphan-Transaktionen_ handelt –
  Kindtransaktionen von unbekannten Eltern, die Bitcoin Core nur kurzfristig speichert, falls
  deren Eltern in einem kurzen Zeitfenster eintreffen. Eine verbesserte Verfolgung und das
  Anfordern der Eltern von Orphan-Transaktionen, die kürzlich in Bitcoin Core integriert wurden
  (siehe [Newsletter #338][news338 orphan]), könnte diese Situation verbessern.

  Die Entwickler diskutierten auch andere mögliche Lösungen. Knoten können Orphan-Transaktionen
  nicht lange speichern, da ein Angreifer diese kostenlos erstellen kann – es könnte jedoch
  möglich sein, eine größere Anzahl von Orphan-Transaktionen und anderen verworfenen
  Transaktionen länger im Extrapool vorzuhalten. Die Diskussion war zum Zeitpunkt der Erstellung
  dieses Beitrags noch nicht abschließend geklärt.

## Ausgewählte Q&A vom Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] ist einer der ersten Orte, an denen die Optech-Mitwirkenden
nach Antworten auf ihre Fragen suchen – oder wenn wir ein paar freie Momente haben, um neugierige
oder verwirrte Nutzer zu unterstützen. In diesem monatlichen Feature heben wir einige der
bestbewerteten Fragen und Antworten hervor, die seit unserem letzten Update gepostet wurden.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Wer nutzt oder möchte PSBTv2 (BIP370) verwenden?](../../en/newsletters/{{bse}}125384)
  Neben seinem Posting in der Bitcoin-Dev-Mailingliste (siehe [Newsletter #338][news338 psbtv2])
  hat Sjors Provoost auch im Bitcoin Stack Exchange nach Nutzern und potenziellen Anwendern von
  [PSBTv2][topic psbt] gesucht. Leser von Optech, die an [BIP370][] interessiert sind, werden
  gebeten, auf die Frage oder den entsprechenden Mailinglisten-Beitrag zu antworten.

- [Im Bitcoin-Genesisblock, welche Teile können beliebig belegt werden?](../../en/newsletters/{{bse}}125274)
  Pieter Wuille weist darauf hin, dass keines der Felder des [Genesis-Blocks][mempool genesis block]
  den üblichen Blockvalidierungsregeln unterliegt. Er erklärt: "Buchstäblich alle könnten
  jeglichen Inhalt enthalten haben. Dort, wo es möglich war, wurde es wie ein normaler Block
  gestaltet – es hätte aber auch anders sein können."

- [Erkennung von Lightning-Force-Close](../../en/newsletters/{{bse}}122504)
  Sanket1729 und Antoine Poinsot diskutieren, wie der [Block-Explorer][topic block explorers] von
  mempool.space die Felder [`nLockTime`][topic timelocks] und `nSequence` verwendet, um
  festzustellen, ob eine Transaktion eine Lightning force close Transaktion ist.

- [Ist eine segwit-formatierte Transaktion mit allen Eingaben vom Typ „Nicht-Witness-Programm" gültig?](../../en/newsletters/{{bse}}125240)
  Pieter Wuille unterscheidet zwischen [BIP141][], das die Struktur und Gültigkeit im
  Zusammenhang mit den Segwit-Konsensänderungen und der Berechnung von wtxids festlegt, und
  [BIP144][], das das Serialisierungsformat für die Übertragung von Segwit-Transaktionen
  definiert.

- [P2TR-Sicherheitsfrage](../../en/newsletters/{{bse}}125334)
  Pieter Wuille zitiert aus [BIP341][], das [Taproot][topic taproot] spezifiziert, um zu
  erklären, warum ein öffentlicher Schlüssel direkt in einer Ausgabe enthalten ist, und geht auf
  damit verbundene Überlegungen zum Thema Quantencomputing ein.

- [Was genau wird heute unternommen, um Bitcoin quantensicher zu machen?](../../en/newsletters/{{bse}}125171)
  Murch kommentiert den aktuellen Stand der quantentechnologischen Fähigkeiten, kürzlich
  eingeführte [post-quantum Signaturschemata][topic quantum resistance] und den vorgeschlagenen
  [QuBit – Pay to Quantum Resistant Hash][BIPs #1670]-BIP.

- [Welche schädlichen Auswirkungen hat eine kürzere Inter-Block-Zeit?](../../en/newsletters/{{bse}}125318)
  Pieter Wuille hebt den Vorteil hervor, den ein Miner aufgrund der Blockpropagation erlangt,
  kurz nachdem er einen Block gefunden hat, wie dieser Vorteil bei kürzeren Blockzeiten verstärkt
  wird und welche potenziellen Auswirkungen daraus resultieren können.

- [Kann Proof-of-Work eingesetzt werden, um Richtlinienregeln zu ersetzen?](../../en/newsletters/{{bse}}124931)
  Jgmontoya fragt sich, ob das Anhängen von Proof-of-Work an nicht-standardmäßige Transaktionen
  ähnliche Ziele des [Schutzes von Node-Ressourcen][policy series] erreichen könnte wie die
  Mempool-Policy. Antoine Poinsot weist darauf hin, dass die Mempool-Policy neben dem Schutz der
  Node-Ressourcen auch weitere Ziele verfolgt – etwa eine effiziente Erstellung von
  Blocktemplates, das Abschrecken bestimmter Transaktionstypen und den Schutz von Upgrade-Hooks
  bei [Soft Forks][topic soft fork activation].

- [Wie funktioniert MuSig in realen Bitcoin-Szenarien?](../../en/newsletters/{{bse}}125030)
  Pieter Wuille erläutert die Unterschiede zwischen den [MuSig][topic musig]-Versionen, hebt die
  Interactive Aggregated Signature (IAS)-Variante von MuSig1 und deren Zusammenspiel mit der
  [Cross-Input-Signaturaggregation (CISA)][topic cisa] hervor und erwähnt [Threshold Signatures][topic threshold signature],
  bevor er detailliertere Fragen zu den Spezifikationen beantwortet.

- [Wie funktioniert der -blocksxor-Schalter, der die blocks.dat-Dateien verschleiert?](../../en/newsletters/{{bse}}125055)
  Vojtěch Strnad beschreibt die `-blocksxor`-Option zum Verschleiern der Bitcoin Core
  Blockdaten-Dateien auf der Festplatte (siehe [Newsletter #316][news316 xor]).

- [Wie funktioniert der Related-Key-Angriff auf Schnorr-Signaturen?](../../en/newsletters/{{bse}}125328)
  Pieter Wuille erklärt, dass „der Angriff anwendbar ist, wenn das Opfer einen verwandten
  Schlüssel auswählt und der Angreifer die Beziehung kennt" und dass verwandte Schlüssel äußerst
  verbreitet sind.

## Releases und Release-Kandidaten

_Neue Releases und Release-Kandidaten für beliebte Bitcoin-Infrastrukturprojekte. Bitte erwägen
Sie, auf die neuen Releases zu aktualisieren oder bei der Erprobung der Release-Kandidaten zu
helfen._

- [LDK v0.1.1][] ist ein Sicherheits-Release dieser beliebten Bibliothek zum Erstellen von
  LN-fähigen Anwendungen. Ein Angreifer, der bereit ist, mindestens 1 % der Kanalgelder zu
  opfern, könnte das Opfer dazu verleiten, andere, nicht damit zusammenhängende Kanäle zu
  schließen, was dazu führen könnte, dass das Opfer unnötig Transaktionsgebühren zahlt. Matt
  Morehouse, der die Schwachstelle entdeckt hat,
  [hat darüber bei Delving Bitcoin berichtet][morehouse ldk-dos];
  Optech wird in der nächsten Ausgabe des Newsletters eine detailliertere Zusammenfassung
  liefern. Das Release beinhaltet außerdem API-Updates und Fehlerbehebungen.

## Wesentliche Änderungen im Code und in der Dokumentation

_Wichtige aktuelle Änderungen in [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning repo],
[Eclair][eclair repo], [LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo],
[Hardware Wallet Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay Server][btcpay server repo],
[BDK][bdk repo], [Bitcoin Improvement Proposals (BIPs)][bips repo],
[Lightning BOLTs][bolts repo], [Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition repo] und
[BINANAs][binana repo]._

- [Bitcoin Core #31376][] erweitert eine Prüfung, die verhindert, dass Miner Blockvorlagen
  erstellen, welche den [Timewarp][topic time warp]-Fehler ausnutzen – und zwar für alle
  Netzwerke, nicht nur für [testnet4][topic testnet]. Diese Änderung dient als Vorbereitung für
  einen möglichen zukünftigen Soft Fork, der den Timewarp-Fehler dauerhaft beheben würde.

- [Bitcoin Core #31583][] aktualisiert die RPC-Befehle `getmininginfo`, `getblock`,
  `getblockheader`, `getblockchaininfo` und `getchainstates`, sodass nun ein `nBits`-Feld (die
  kompakte Darstellung des Block-Schwierigkeitsziels) sowie ein `target`-Feld zurückgegeben
  werden. Zusätzlich fügt `getmininginfo` ein `next`-Objekt hinzu, das die Höhe, `nBits`, den
  Schwierigkeitsgrad und das Ziel für den nächsten Block spezifiziert. Um das Ziel abzuleiten und
  zu erhalten, führt dieser PR die Hilfsfunktionen `DeriveTarget()` und `GetTarget()` ein. Diese
  Änderungen sind nützlich für die Implementierung von [Stratum V2][topic pooled mining].

- [Bitcoin Core #31590][] überarbeitet die Methode `GetPrivKey()`, sodass beim Abrufen privater
  Schlüssel für einen [x-only-Pubkey][topic x-only public keys] in einem [Descriptor][topic descriptors]
  beide möglichen Werte des Paritätsbits überprüft werden. Zuvor konnte, wenn der
  gespeicherte Pubkey nicht das korrekte Paritätsbit aufwies, der private Schlüssel nicht
  abgerufen werden, und Transaktionen konnten nicht signiert werden.

- [Eclair #2982][] führt die Konfigurationseinstellung `lock-utxos-during-funding` ein, die es
  Verkäufern von [liquidity advertisements][topic liquidity advertisements] ermöglicht, einen
  bestimmten Liquiditätsgriefing-Angriff abzumildern, der ehrlichen Nutzern verhindern könnte,
  ihre UTXOs über längere Zeiträume zu verwenden. Die Standardeinstellung ist auf true gesetzt,
  was bedeutet, dass UTXOs während des Funding-Prozesses gesperrt werden und somit anfällig für
  Missbrauch sind. Wird der Wert auf false gesetzt, wird die UTXO-Sperrung deaktiviert und der
  Angriff kann vollständig verhindert werden – dies könnte jedoch negative Auswirkungen auf
  ehrliche Peers haben. Dieses PR fügt außerdem einen konfigurierbaren Timeout-Mechanismus hinzu,
  der eingehende Kanäle automatisch abbricht, wenn ein Peer nicht reagiert.

- [BDK #1614][] fügt Unterstützung für die Verwendung von [kompakten Blockfiltern][topic compact
  block filters] hinzu, wie sie in [BIP158][] spezifiziert sind, um bestätigte Transaktionen
  herunterzuladen. Dies wird erreicht, indem dem `bdk_bitcoind_rpc` Crate ein BIP158-Modul
  hinzugefügt wird, zusammen mit einem neuen `FilterIter`-Typ, der verwendet werden kann, um
  Blöcke abzurufen, die Transaktionen enthalten, welche für eine Liste von Script-Pubkeys
  relevant sind.

- [BOLTs #1110][] führt die Spezifikation für das [Peer Storage][topic peer storage]-Protokoll
  zusammen, welches es Knoten ermöglicht, verschlüsselte Blobs von bis zu 64kB für anfragende
  Peers zu speichern und für diesen Dienst Gebühren zu erheben. Diese Funktion wurde bereits in
  Core Lightning (siehe Newsletter [#238][news238 peer]) und Eclair (siehe Newsletter
  [#335][news335 peer]) implementiert.

{% include snippets/recap-ad.md when="2025-02-04 15:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="31376,31583,31590,2982,1614,1110,1670" %}
[morehouse ldkclaim]: https://delvingbitcoin.org/t/disclosure-ldk-invalid-claims-liquidity-griefing/1400
[news335 ldk3340]: /en/newsletters/2025/01/03/#ldk-3340
[riard minecycle]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CALZpt+EnDUtfty3X=u2-2c5Q53Guc6aRdx0Z4D75D50ZXjsu2A@mail.gmail.com/
[miningpool.observer]: https://miningpool.observer/template-and-block
[b10c cb]: https://delvingbitcoin.org/t/stats-on-compact-block-reconstructions/1052/5
[news315 cb]: /en/newsletters/2024/08/09/#statistics-on-compact-block-reconstruction
[news338 orphan]: /en/newsletters/2025/01/24/#bitcoin-core-31397
[news274 cycle]: /en/newsletters/2023/10/25/#replacement-cycling-vulnerability-against-htlcs
[ldk v0.1.1]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.1.1
[morehouse ldk-dos]: https://delvingbitcoin.org/t/disclosure-ldk-duplicate-htlc-force-close-griefing/1410
[news281 griefing]: /en/newsletters/2023/12/13/#discussion-about-griefing-liquidity-ads
[news238 peer]: /en/newsletters/2023/02/15/#core-lightning-5361
[news335 peer]: /en/newsletters/2025/01/03/#eclair-2888
[news338 psbtv2]: /en/newsletters/2025/01/24/#psbtv2-integration-testing
[mempool genesis block]: https://mempool.space/block/000000000019d6689c085ae165831e934ff763ae46a2a6c172b3f1b60a8ce26f
[policy series]: /en/blog/waiting-for-confirmation/#policy-for-protection-of-node-resources
[news316 xor]: /en/newsletters/2024/08/16/#bitcoin-core-28052
