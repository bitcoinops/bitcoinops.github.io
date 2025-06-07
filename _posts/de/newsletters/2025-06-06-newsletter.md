---
title: 'Bitcoin Optech Newsletter #357'
permalink: /de/newsletters/2025/06/06/
name: 2025-06-06-newsletter-de
slug: 2025-06-06-newsletter-de
type: newsletter
layout: newsletter
lang: de
---
Der Newsletter dieser Woche enthält eine Analyse zum Synchronisieren von Full Nodes ohne alte Witness-Daten. Ebenfalls enthalten sind unsere regulären Abschnitte mit Beschreibungen von Diskussionen zu Konsensänderungen, Ankündigungen neuer Veröffentlichungen und Release-Kandidaten sowie Zusammenfassungen wichtiger Änderungen an populärer Bitcoin-Infrastruktur.

## Nachrichten

- **Synchronisation von Full Nodes ohne Witness-Daten:**
  Jose SK [veröffentlichte][sk nowit] auf Delving Bitcoin eine Zusammenfassung einer [Analyse][sk nowit gist], in der er die Sicherheitserwägungen untersucht, wenn neu gestartete Full Nodes mit einer bestimmten Konfiguration auf das Herunterladen einiger historischer Blockchain-Daten verzichten. Standardmäßig verwenden Bitcoin-Core-Knoten die `assumevalid`-Konfiguration. Diese überspringt die Validierung von Scripts in Blöcken, die mehr als ein oder zwei Monate vor der aktuell ausgeführten Version von Bitcoin Core erstellt wurden. Viele Nutzer aktivieren außerdem die `prune`-Option, die Blöcke nach der Validierung nach einer gewissen Zeit löscht. Wie lange Blöcke aufbewahrt werden, hängt von der Blockgröße und der gewählten Einstellung ab.

  SK argumentiert, dass Witness-Daten, die nur zur Script-Validierung benötigt werden, von geprunten Nodes für assumevalid-Blöcke nicht heruntergeladen werden sollten, da sie nicht zur Script-Validierung genutzt und später ohnehin gelöscht werden. Das Überspringen des Witness-Downloads „kann den Bandbreitenverbrauch um über 40 % reduzieren“, schreibt er.

  Ruben Somsen [argumentiert][somsen nowit], dass dies das Sicherheitsmodell in gewissem Maße verändert. Auch wenn Scripts nicht validiert werden, wird die heruntergeladene Datenmenge gegen das Commitment vom Blockheader-Merkel-Root zur Coinbase-Transaktion bis zu den Witness-Daten geprüft. Das stellt sicher, dass die Daten zum Zeitpunkt der ersten Synchronisation verfügbar und unverfälscht waren. Wenn jedoch niemand regelmäßig die Existenz dieser Daten prüft, könnten sie verloren gehen – wie es [bei mindestens einem Altcoin][ripple loss] bereits passiert ist.

  Die Diskussion war zum Zeitpunkt des Schreibens noch im Gange.

## Änderungen am Konsens

_Ein monatlicher Abschnitt mit Zusammenfassungen von Vorschlägen und Diskussionen zu Änderungen der Bitcoin-Konsensregeln._

- **Bericht zu Quantencomputing:** Clara Shikhelman [veröffentlichte][shikelman quantum]
  auf Delving Bitcoin die Zusammenfassung eines [Berichts][sm report], den sie gemeinsam
  mit Anthony Milton verfasst hat. Darin geht es um Risiken für Bitcoin-Nutzer durch schnelle
  Quantencomputer, einen Überblick über verschiedene Wege zur
  [Quantenresistenz][topic quantum resistance] und eine Analyse der Abwägungen bei einer
  Protokollumstellung. Die Autoren schätzen, dass 4 bis 10 Millionen BTC potenziell durch
  Quantenangriffe gefährdet sind, einige Maßnahmen bereits jetzt möglich sind, Bitcoin-Mining
  kurzfristig und mittelfristig aber nicht bedroht ist und ein Upgrade breite Zustimmung erfordert.

- **Transaktionsgewicht-Limit mit Ausnahme zur Vermeidung von Konfiskation:** Vojtěch Strnad
  [schlug][strnad limit] auf Delving Bitcoin eine Konsensänderung vor, die das maximale
  Gewicht der meisten Transaktionen in einem Block begrenzt. Die einfache Regel:
  Nur wenn eine Transaktion (außer der Coinbase) die einzige im Block ist, darf
  sie größer als 400.000 Weight Units (100.000 vbytes) sein. Strnad und andere
  nannten folgende Gründe für diese Begrenzung:

  - _Einfachere Blocktemplate-Optimierung:_ Je kleiner die einzelnen Transaktionen
  im Vergleich zum Gesamtlimit sind, desto leichter lässt sich eine nahezu optimale
  Lösung für das [Knapsack-Problem][knapsack problem] finden. Dadurch bleibt weniger
  Platz ungenutzt.

  - _Einfachere Relay-Policy:_ Die Policy für das Weiterleiten unbestätigter
  Transaktionen zwischen Knoten sagt vorher, welche Transaktionen gemined werden.
  Sehr große Transaktionen erschweren diese Vorhersage, da schon kleine Änderungen
  an der Top-Feerate zu Verzögerungen oder zum Entfernen führen können.

  - _Vermeidung von Mining-Zentralisierung:_ Wenn relayende Full Nodes fast alle
  Transaktionen weiterleiten können, müssen Nutzer spezieller Transaktionen keine
  [Out-of-Band-Fees][topic out-of-band fees] zahlen, was Mining-Zentralisierung
  verhindern hilft.

  Gregory Sanders [merkte an][sanders limit], dass es auch sinnvoll sein könnte,
  einfach per Soft Fork ein maximales Gewichtslimit ohne Ausnahmen einzuführen,
  da Bitcoin Core seit 12 Jahren eine konsistente Relay-Policy hat. Gregory Maxwell
  [fügte hinzu][maxwell limit], dass Transaktionen, die nur UTXOs ausgeben, die vor
  dem Soft Fork entstanden sind, eine Ausnahme erhalten könnten, um Konfiskation zu
  verhindern. Ein [transitorischer Soft Fork][topic transitory soft forks]
  könnte die Einschränkung zudem automatisch auslaufen lassen, falls die
  Community sie nicht verlängern möchte.

  Weitere Diskussionen befassten sich mit den Bedürfnissen von Nutzern großer
  Transaktionen, insbesondere [BitVM][topic acc], und möglichen Alternativen.

- **Entfernen von Outputs aus dem UTXO-Set basierend auf Wert und Zeit:** Robin Linus
  [schlug][linus dust] auf Delving Bitcoin einen Soft Fork vor, um Outputs mit geringem
  Wert nach einer gewissen Zeit aus dem UTXO-Set zu entfernen. Diskutiert wurden zwei
  Hauptvarianten:

  - _Alte, unwirtschaftliche Funds zerstören:_ Kleine Outputs, die lange nicht
  ausgegeben wurden, werden unspendable.

  - _Alte, unwirtschaftliche Funds nur mit Existenzbeweis ausgeben:_
  [utreexo][topic utreexo] oder ein ähnliches System könnte genutzt werden,
  damit Transaktionen beweisen können,
  dass die ausgegebenen Outputs Teil des UTXO-Sets sind. Alte und
  [unwirtschaftliche Outputs][topic uneconomical outputs] müssten diesen Beweis liefern,
  neuere und höherwertige Outputs würden weiterhin im UTXO-Set gespeichert.

  Beide Lösungen würden die maximale Größe des UTXO-Sets effektiv begrenzen
  (bei Mindestwert und 21 Millionen Bitcoin). Es wurden verschiedene technische
  Aspekte und Alternativen zu utreexo-Proofs für diesen Anwendungsfall diskutiert.

## Veröffentlichungen und Release-Kandidaten

_Neue Veröffentlichungen und Release-Kandidaten für populäre Bitcoin-Infrastrukturprojekte. Bitte erwäge, auf neue Veröffentlichungen zu aktualisieren oder Release-Kandidaten zu testen._

- [Core Lightning 25.05rc1][] ist ein Release-Kandidat für die nächste Hauptversion dieser beliebten LN-Knoten-Implementierung.

- [LND 0.19.1-beta.rc1][] ist ein Release-Kandidat für eine Wartungsversion dieser beliebten LN-Knoten-Implementierung.

## Wichtige Code- und Dokumentationsänderungen

_Bemerkenswerte aktuelle Änderungen in [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo], [Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition repo] und [BINANAs][binana repo]._

- [Bitcoin Core #32582][] fügt neues Logging hinzu, um die Performance der [Compact-Block-Rekonstruktion][topic compact block relay] zu messen: Es werden die Gesamtgröße der von Peers angeforderten Transaktionen (`getblocktxn`), die Anzahl und Gesamtgröße der an Peers gesendeten Transaktionen (`blocktxn`) sowie ein Timestamp am Start von `PartiallyDownloadedBlock::InitData()` geloggt, um die Dauer des Mempool-Lookups zu messen (sowohl im High- als auch im Low-Bandwidth-Modus). Siehe Newsletter [#315][news315 compact] für einen früheren Statistikbericht zur Compact-Block-Rekonstruktion.

- [Bitcoin Core #31375][] fügt ein neues CLI-Tool `bitcoin -m` hinzu, das die [Multiprozess][multiprocess project]-Binaries `bitcoin node` (`bitcoind`), `bitcoin gui` (`bitcoinqt`), `bitcoin rpc` (`bitcoin-cli -named`) kapselt und ausführt. Aktuell funktionieren diese wie die monolithischen Binaries, unterstützen aber die Option `-ipcbind` (siehe Newsletter [#320][news320 ipc]). Zukünftige Verbesserungen werden es ermöglichen, Node-Komponenten unabhängig auf verschiedenen Maschinen und Umgebungen zu starten und zu stoppen. Siehe [Newsletter #353][news353 pr review] für einen Bitcoin Core PR Review Club zu diesem PR.

- [BIPs #1483][] merged [BIP77][], das [Payjoin v2][topic payjoin] vorschlägt – eine asynchrone, serverlose Variante, bei der Sender und Empfänger ihre verschlüsselten PSBTs an einen Payjoin-Directory-Server übergeben, der nur Nachrichten speichert und weiterleitet. Da das Directory die Payloads weder lesen noch verändern kann, muss keine Wallet einen öffentlichen Server betreiben oder gleichzeitig online sein. Siehe Newsletter [#264][news264 payjoin] für weitere Informationen zu Payjoin v2.

{% include snippets/recap-ad.md when="2025-06-10 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="32582,31375,1483" %}
[Core Lightning 25.05rc1]: https://github.com/ElementsProject/lightning/releases/tag/v25.05rc1
[ripple loss]: https://x.com/JoelKatz/status/1919233214750892305
[sk nowit]: https://delvingbitcoin.org/t/witnessless-sync-for-pruned-nodes/1742/
[sk nowit gist]: https://gist.github.com/JoseSK999/df0a2a014c7d9b626df1e2b19ccc7fb1
[somsen nowit]: https://gist.github.com/JoseSK999/df0a2a014c7d9b626df1e2b19ccc7fb1?permalink_comment_id=5597316#gistcomment-5597316
[shikelman quantum]: https://delvingbitcoin.org/t/bitcoin-and-quantum-computing/1730/
[sm report]: https://chaincode.com/bitcoin-post-quantum.pdf
[strnad limit]: https://delvingbitcoin.org/t/non-confiscatory-transaction-weight-limit/1732/
[knapsack problem]: https://en.wikipedia.org/wiki/Knapsack_problem
[sanders limit]: https://delvingbitcoin.org/t/non-confiscatory-transaction-weight-limit/1732/2
[maxwell limit]: https://delvingbitcoin.org/t/non-confiscatory-transaction-weight-limit/1732/4
[linus dust]: https://delvingbitcoin.org/t/dust-expiry-clean-the-utxo-set-from-spam/1707/
[lnd 0.19.1-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.19.1-beta.rc1
[news315 compact]: /en/newsletters/2024/08/09/#statistics-on-compact-block-reconstruction
[multiprocess project]: https://github.com/ryanofsky/bitcoin/blob/pr/ipc/doc/design/multiprocess.md
[news320 ipc]: /en/newsletters/2024/09/13/#bitcoin-core-30509
[news264 payjoin]: /en/newsletters/2023/08/16/#serverless-payjoin
[news353 pr review]: /de/newsletters/2025/05/09/#bitcoin-core-pr-review-club
