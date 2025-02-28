---
title: 'Bitcoin Optech Newsletter #341'
permalink: /de/newsletters/2025/02/14/
name: 2025-02-14-newsletter-de
slug: 2025-02-14-newsletter-de
type: newsletter
layout: newsletter
lang: de
---
In diesem Newsletter wird die anhaltende Diskussion zu probabilistischen Zahlungen
zusammengefasst, zusätzliche Aspekte zu ephemeren Anchorskripten bei Lightning Network
erläutert, Statistiken zur Bereinigung des Bitcoin Core Orphan Pools präsentiert und
ein aktualisierter Entwurf für einen überarbeiteten BIP-Prozess vorgestellt. Zudem werden
in den regelmäßigen Abschnitten das PR Review Club-Treffen, neue Releases sowie wichtige
Änderungen in Code und Dokumentation von Bitcoin-Infrastrukturprojekten kurz
und prägnant dargestellt.

## News

- **Diskussion zu probabilistischen Zahlungen:** Nach Oleksandr Kurbatovs
[Beitrag][kurbatov pp] im Delving Bitcoin-Forum zur Emulation des OP_RAND-Opcodes
(siehe [Newsletter #340][news340 pp]) wurden verschiedene Fragestellungen eingebracht:

  - _Eignung als Alternative zu „gekürzten“ HTLCs:_ Dave Harding [fragte][harding pp],
  ob Kurbatovs Methode in [LN-Penalty][topic ln-penalty]- oder [LN-Symmetry][topic eltoo]-Kanälen
  eingesetzt werden könne, bei denen HTLCs bei einer Force-Close an Wert verlieren – ein Problem,
  das derzeit mit „gekürzten“ HTLCs adressiert wird. Anthony Towns [äußerte Zweifel][towns pp1]
  aufgrund der invertierten Protokollrollen, sah aber Chancen durch gezielte Anpassungen.

  - _Erforderlicher Aufbauschritt:_ Towns [entdeckte][towns pp1], dass das ursprünglich
  veröffentlichte Protokoll einen Schritt fehlte. Kurbatov stimmte zu.

  - _Einfachere Null-Wissen-Beweis:_ Adam Gibson [schlug][gibson pp1] vor, dass die
  Verwendung von [schnorr][topic schnorr signatures] und [taproot][topic taproot] anstelle
  von gehashten öffentlichen Schlüsseln die Konstruktion und Überprüfung des erforderlichen
  Null-Wissen-Beweis erheblich vereinfachen und beschleunigen könnte. Towns [bot][towns pp2]
  einen vorläufigen Ansatz an, den [Gibson][gibson pp2] analysierte.

  Die Diskussion war zum Zeitpunkt des Schreibens noch im Gange.

- **Fortgesetzte Diskussion über ephemere Anchor-Skripte für LN:** Matt Morehouse
[hat geantwortet][morehouse eanchor] auf den Thread über das, was das
[ephemere Anchor][topic ephemeral anchors]-Skript für LN für zukünftige Kanäle verwenden
sollte (siehe [Newsletter #340][news340 eanchor]). Er äußerte Bedenken hinsichtlich der
Möglichkeit, dass Dritte Transaktionen mit [P2A][topic ephemeral anchors]-Ausgaben durch
ungewollte Gebühren beeinträchtigen könnten.

  Anthony Towns [hat bemerkt][towns eanchor], dass Griefing durch den Kontrahenten ein
  größeres Problem darstellt, da der Kontrahent eher in der Lage ist, Geld zu stehlen,
  wenn der Kanal nicht rechtzeitig oder in einem ordnungsgemäßen Zustand geschlossen wird.
  Dritte, die Ihre Transaktion verzögern oder versuchen, die Transaktionsgebühr moderat zu
  erhöhen, können einen Teil ihres Geldes verlieren, ohne dass sie direkt von Ihnen profitieren
  können.

  Greg Sanders [schlug vor][sanders eanchor], probabilistisch zu denken: Wenn das Schlimmste,
  was ein Dritter als Griefer tun kann, darin besteht, die Kosten Ihrer Transaktion um 50% zu
  erhöhen, aber die Verwendung einer griefing-resistenten Methode etwa 10% extra kostet, erwarten
  Sie wirklich, dass Sie von einem Dritten häufiger gegriefed werden als einmal bei fünf Force-Closes -
  insbesondere wenn der Dritte als Griefer Geld verlieren kann und nicht finanziell profitiert?

- **Statistiken über Orphan-Verweisungen:** Der Entwickler 0xB10C [hat gepostet][b10c orphan] auf
Delving Bitcoin Statistiken über die Anzahl der Transaktionen, die aus den Orphan-Pools seiner Knoten
vertrieben wurden. Orphan-Transaktionen sind unbestätigte Transaktionen, für die ein Knoten noch nicht
alle Eltern-Transaktionen hat, ohne die er nicht in einem Block aufgenommen werden kann. Bitcoin Core
speichert standardmäßig bis zu 100 Orphan-Transaktionen. Wenn eine neue Orphan-Transaktion ankommt,
nachdem der Pool voll ist, wird eine zuvor empfangene Orphan-Transaktion vertrieben.

  0xB10C fand heraus, dass an einigen Tagen mehr als 10 Millionen Orphan-Transaktionen von seinem Knoten
  vertrieben wurden, mit einem Höchstwert von über 100.000 Verweisungen pro Minute. Bei der Untersuchung
  fand er heraus, dass ">99% dieser [...] ähnlich sind wie diese [Transaktion][runestone tx], die
  offensichtlich mit Runestone-Münzen [einem farbigen Coin (NFT)-Protokoll] zusammenhängt". Es schien,
  dass viele der gleichen Orphan-Transaktionen wiederholt angefordert, kurze Zeit später zufällig
  vertrieben und dann erneut angefordert wurden.

- **Aktualisierter Vorschlag für den aktualisierten BIP-Prozess:** Mark "Murch" Erhardt [hat gepostet][erhardt bip3]
auf die Bitcoin-Dev-Mailingliste, um bekannt zu geben, dass sein Entwurf für einen überarbeiteten BIP-Prozess die
Identifikationsnummer BIP3 erhalten hat und bereit ist für eine weitere Überprüfung - möglicherweise die letzte
Überprüfungsrunde, bevor er zusammengeführt und aktiviert wird. Jeder, der eine Meinung hat, ist aufgerufen,
Feedback auf dem [Pull-Request][bips #1712] zu hinterlassen.


## Bitcoin Core PR Review Club

*In diesem monatlichen Abschnitt erfolgt eine Zusammenfassung einer kürzlich stattgefundenen Sitzung des
[Bitcoin Core PR Review Club][]. Dabei werden einige der wesentlichen Fragen und Antworten hervorgehoben.
Durch Anklicken einer Frage unten ist es möglich, eine Zusammenfassung der entsprechenden Antwort aus der
Sitzung einzusehen.*

[Cluster-Mempool: Einführung von TxGraph][review club 31363] ist ein PR von [sipa][gh sipa], der die
`TxGraph`-Klasse einführt, die Kenntnisse über die (effektiven) Gebühren, Größen und Abhängigkeiten
zwischen allen Mempool-Transaktionen kapselt, aber nichts anderes. Es ist Teil des [Cluster-Mempool][topic cluster mempool]-Projekts
und bringt eine umfassende Schnittstelle, die es ermöglicht, mit dem Mempool-Graphen über Mutation-,
Inspector- und Staging-Funktionen zu interagieren.

Bemerkenswerterweise hat `TxGraph` keine Kenntnisse über `CTransaction`, Eingaben, Ausgaben, Txids, Wtxids,
Priorisierung, Gültigkeit, Richtlinienregeln und vieles mehr. Dies macht es einfacher, das Verhalten der Klasse
(fast) vollständig zu spezifizieren, wodurch simulationsbasierte Tests ermöglicht werden - die im PR enthalten sind.

{% include functions/details-list.md
  q0='Was ist der Mempool "graph" und in welchem Umfang existiert er im Mempool-Code auf Master?'
  a0='Auf Master existiert der Mempool-Graph implizit als die Menge von `CTxMemPoolEntry`-Objekten als Knoten
  und ihre Vorfahr- und Abhängigkeitsbeziehungen, die rekursiv mit `GetMemPoolParents()` und `GetMemPoolChildren()`
  durchlaufen werden können.'
  a0link='https://bitcoincore.reviews/31363#l-26'
  q1='Was sind die Vorteile von einem `TxGraph`, in Ihren eigenen Worten? Können Sie mögliche Nachteile nennen?'
  a1='Vorteile sind: 1) `TxGraph` ermöglicht die Implementierung von [Cluster-Mempool][topic cluster mempool],
  mit all seinen Vorteilen. 2) Bessere Kapselung des Mempool-Codes, mit effizienteren Datenstrukturen. 3) Es ist
  einfacher, mit dem Mempool zu interagieren und über ihn nachzudenken, indem topologische Details wie das Vermeiden
  von Doppelzählung von Ersetzungen abstrahiert werden. <br><br>Nachteile sind: 1) Die bedeutenden Review- und
  Testbemühungen, die mit den großen Änderungen einhergehen. 2) Es beschränkt, wie die Validierung
  per-Transaktion-Topologie-Grenzen diktieren kann, wie z.B. für TRUC und andere Richtlinien. 3)
  Ein sehr geringer Laufzeit-Performance-Overhead, verursacht durch die Übersetzung
  von und zu den `TxGraph::Ref*`-Zeigern.'
  a1link='https://bitcoincore.reviews/31363#l-54'
  q2='Wie viele `Clusters` kann eine einzelne Transaktion innerhalb eines `TxGraph` sein?'
  a2='Obwohl eine Transaktion konzeptionell nur zu einem einzigen Cluster gehören kann, ist die Antwort 2 Stück.
  Dies liegt daran, dass ein `TxGraph` 2 parallele Graphen kapseln kann: "main", und optional "staging".'
  a2link='https://bitcoincore.reviews/31363#l-116'
  q3='Was bedeutet es, wenn ein `TxGraph` übergröße ist? Ist das dasselbe wie ein voller Mempool?'
  a3='Ein `TxGraph` ist übergröße, wenn mindestens einer seiner `Cluster` die `MAX_CLUSTER_COUNT_LIMIT` überschreitet.
  Dies ist nicht dasselbe wie ein voller Mempool, da ein `TxGraph` mehrere `Cluster` haben kann.'
  a3link='https://bitcoincore.reviews/31363#l-147'
  q4='Wenn ein `TxGraph` übergröße ist, welche Funktionen können noch aufgerufen werden und welche nicht?'
  a4='Operationen, die tatsächlich die Materialisierung eines übergrößen Clusters erfordern, sowie Funktionen,
  die O(n<sup>2</sup>)-Arbeit oder mehr erfordern, sind nicht erlaubt für einen übergrößen `Cluster`. Dies umfasst
  Operationen wie das Berechnen der Vorfahren/Abkömmlinge einer Transaktion. Mutationsoperationen
  (`AddTransaction()`, `RemoveTransaction()`, `AddDependency()` und `SetTransactionFee()`) und Operationen wie
  `Trim()` (ungefähr O(n log n)) sind noch erlaubt.'
  a4link='https://bitcoincore.reviews/31363#l-162'
%}

## Releases und Release-Kandidaten

_Neue Veröffentlichungen und Release-Kandidaten für populäre Projekte der Bitcoin-Infrastruktur.
Bitte erwägen Sie, auf die neuen Releases zu aktualisieren oder bei der Testung der Release-Kandidaten
mitzuhelfen._

- [LND v0.18.5-beta][] ist eine Bugfix-Veröffentlichung dieser populären LN-Node-Implementierung.
Die Fehlerbehebungen werden in den Release-Hinweisen als "wichtig" und "kritisch" beschrieben.

- [Bitcoin Inquisition 28.1][] ist eine kleinere Veröffentlichung dieses [signet][topic signet]
Full Node, der für Experimente mit vorgeschlagenen Soft Forks und anderen wesentlichen Protokolländerungen
entwickelt wurde. Sie enthält die in Bitcoin Core 28.1 enthaltenen Bugfixes sowie Unterstützung
für [ephemeral dust][topic ephemeral anchors].

## Wichtige Code- und Dokumentationsänderungen

_Kürzliche Änderungen in [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning repo],
[Eclair][eclair repo], [LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo],
[Hardware Wallet Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay Server][btcpay server repo],
[BDK][bdk repo], [Bitcoin Improvement Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition repo], und [BINANAs][binana repo]._

- [Bitcoin Core #25832][] fügt fünf neue Tracepoints und Dokumentation hinzu, um Ereignisse bei
Peer-Verbindungen wie Verbindungsdauer, Wiedereinbindungsfrequenz nach IP und Netgroup,
Peer-Abschreckung, Entfernung, Fehlverhalten und mehr zu überwachen. Bitcoin Core-Benutzer, die
Extended Berkeley Packet Filter (eBPF)-Tracing aktiviert haben, können über die bereitgestellten
Beispielscripte an die Tracepoints anbinden oder eigene Trace-Skripte schreiben (siehe Newsletter
[#160][news160 ebpf] und [#244][news244 ebpf]).

- [Eclair #2989][] fügt Unterstützung für [gebündelte][topic payment batching] Splices im Router
hinzu, wodurch das Nachverfolgen mehrerer Kanäle in einer einzigen [Splice][topic splicing]-Transaktion
ermöglicht wird. Aufgrund der Unmöglichkeit, neue [Channel-Bekanntmachungen][topic channel announcements]
deterministisch ihren jeweiligen Kanälen zuzuordnen, aktualisiert der Router den ersten übereinstimmenden
Kanal.

- [LDK #3440][] vervollständigt die Unterstützung für den Empfang von [asynchronen Zahlungen][topic async payments],
indem die eingebettete Rechnung des Senders in der Onion-Nachricht des [HTLC][topic htlc] (verwaltet von einem
vorgelagerten Knoten) überprüft und der korrekte PaymentPurpose generiert wird, um die Zahlung anzufordern.
Eine absolute Ablaufzeit wird nun für eingehende asynchrone Zahlungen festgelegt, um ein unbefristetes Abtasten
des Online-Status eines Knotens zu verhindern, und der erforderliche Kommunikationsfluss ist hinzugefügt, um
einen von einem vorgelagerten Knoten gehaltenen HTLC freizugeben, sobald der empfangende Knoten wieder online kommt.
Um die vollständige Implementierung des asynchronen Zahlungsflusses abzuschließen, müssen Knoten außerdem in der Lage
sein, als LSP aufzutreten, der im Auftrag asynchroner Empfänger Rechnungen stellt.

- [LND #9470][] fügt den RPC-Befehlen BumpFee und BumpForceCloseFee einen Parameter deadline_delta hinzu, der die
Anzahl der Blöcke angibt, über die ein bestimmtes Budget (ebenfalls anzugeben) vollständig für das Fee-Bumping
zugewiesen wird und ein [RBF][topic rbf] durchgeführt wird. Zudem wird der Parameter conf_target neu definiert,
sodass er die Anzahl an Blöcken angibt, in denen der Fee-Estimator abgefragt wird, um den aktuellen Gebührenwert
zu erhalten – sowohl für die genannten RPC-Befehle als auch für den veralteten BumpCloseFee.

- [BTCPay Server #6580][] entfernt eine Überprüfung, die das Vorhandensein und die Korrektheit des
Beschreibungshash in [BOLT11][]-Rechnungen für [LNURL][topic lnurl]-pay verifiziert. Diese Änderung steht
im Einklang mit einer [vorgeschlagenen Abschaffung][ludpr] in der LNURL-Dokumentation (LUD), da die
Anforderung nach minimalen Sicherheitsvorteilen kaum Nutzen bringt, jedoch die LNURL-pay-Implementierung
erheblich erschwert. Das Parameterfeld für den Beschreibungshash wurde in Core-Lightning implementiert
(siehe Newsletter [#194][news194 deschash] und [#232][news232 deschash]).

## Korrekturen

In einer [Fußnote][fn sigops] zum Newsletter der letzten Woche haben wir fälschlicherweise geschrieben:
"Im P2SH und bei der vorgeschlagenen Zählung der Sigops für Eingaben wird ein OP_CHECKMULTISIG mit mehr als
16 öffentlichen Schlüsseln als 20 Sigops gewertet." Dies ist eine Vereinfachung; für die tatsächlichen Regeln
siehe bitte diesen [Beitrag][towns sigops] von Anthony Towns in dieser Woche.

{% include snippets/recap-ad.md when="2025-02-18 15:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="25832,2989,3440,9470,6580,1712" %}
[lnd v0.18.5-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.18.5-beta
[Bitcoin Inquisition 28.1]: https://github.com/bitcoin-inquisition/bitcoin/releases/tag/v28.1-inq
[news340 pp]: /de/newsletters/2025/02/07/#emulieren-von-op-rand
[towns sigops]: https://delvingbitcoin.org/t/great-consensus-cleanup-revival/710/69
[kurbatov pp]: https://delvingbitcoin.org/t/emulating-op-rand/1409
[harding pp]: https://delvingbitcoin.org/t/emulating-op-rand/1409/2
[towns pp1]: https://delvingbitcoin.org/t/emulating-op-rand/1409/3
[gibson pp1]: https://delvingbitcoin.org/t/emulating-op-rand/1409/5
[towns pp2]: https://delvingbitcoin.org/t/emulating-op-rand/1409/6
[gibson pp2]: https://delvingbitcoin.org/t/emulating-op-rand/1409/7
[morehouse eanchor]: https://delvingbitcoin.org/t/which-ephemeral-anchor-script-should-lightning-use/1412/8
[news340 eanchor]: /de/newsletters/2025/02/07/#kompromisse-in-ln-ephemeral-anker-skripten
[towns eanchor]: https://delvingbitcoin.org/t/which-ephemeral-anchor-script-should-lightning-use/1412/9
[sanders eanchor]: https://delvingbitcoin.org/t/which-ephemeral-anchor-script-should-lightning-use/1412/11
[b10c orphan]: https://delvingbitcoin.org/t/stats-on-orphanage-overflows/1421/
[runestone tx]: https://mempool.space/tx/ac8990b04469bad8630eaf2aa51561086d81a241deff6c95d96d27e41fa19f90
[erhardt bip3]: https://mailing-list.bitcoindevs.xyz/bitcoindev/25449597-c5ed-42c5-8ac1-054feec8ad88@murch.one/
[fn sigops]: /en/newsletters/2025/02/07/#fn:2kmultisig
[review club 31363]: https://bitcoincore.reviews/31363
[gh sipa]: https://github.com/sipa
[news244 ebpf]: /en/newsletters/2023/03/29/#bitcoin-core-26531
[news160 ebpf]: /en/newsletters/2021/08/04/#bitcoin-core-22006
[ludpr]: https://github.com/lnurl/luds/pull/234
[news232 deschash]: /en/newsletters/2023/01/04/#btcpay-server-4411
[news194 deschash]: /en/newsletters/2022/04/06/#c-lightning-5121
