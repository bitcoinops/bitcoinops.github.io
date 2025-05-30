---
title: 'Bitcoin Optech Newsletter #349'
permalink: /de/newsletters/2025/04/11/
name: 2025-04-11-newsletter-de
slug: 2025-04-11-newsletter-de
type: newsletter
layout: newsletter
lang: de
---
Der Newsletter dieser Woche beschreibt einen Vorschlag zur Beschleunigung des Initial Block Download (IBD) von Bitcoin Core, mit einer Proof-of-Concept-Implementierung, die etwa eine 5-fache Beschleunigung gegenüber den Standard-Einstellungen von Bitcoin Core zeigt. Ebenfalls enthalten sind unsere regulären Abschnitte mit einer Zusammenfassung eines Bitcoin Core PR Review Club Meetings, Ankündigungen neuer Releases und Release-Kandidaten sowie Beschreibungen wichtiger Änderungen an populärer Bitcoin-Infrastruktur.

## Nachrichten

- **SwiftSync-Beschleunigung für Initial Block Download:** Sebastian Falbesoner [veröffentlichte][falbesoner ss1] auf Delving Bitcoin eine Beispielimplementierung und Performance-Ergebnisse für _SwiftSync_, eine Idee, die von Ruben Somsen während eines kürzlichen Bitcoin Core Entwicklermeetings [vorgeschlagen][somsen ssgist] und später [auf der Mailingliste gepostet][somsen ssml] wurde. Die [aktuellsten Ergebnisse][falbesoner ss2] im Thread zeigen eine 5,28-fache Beschleunigung des _Initial Block Downloads_ (IBD) gegenüber den Standard-IBD-Einstellungen von Bitcoin Core (die [assumevalid][] aber nicht [assumeUTXO][topic assumeutxo] verwenden), wodurch die anfängliche Synchronisationszeit von etwa 41 Stunden auf etwa 8 Stunden reduziert wird.

  Vor der Verwendung von SwiftSync erstellt jemand, der seinen Knoten bereits bis zu einem aktuellen Block synchronisiert hat, eine _Hints-Datei_, die angibt, welche Transaktionsausgänge im UTXO-Set zu diesem Block enthalten sein werden (d.h. welche Ausgänge unspent sind). Diese Datei kann für die aktuelle UTXO-Set-Größe effizient auf einige hundert Megabyte komprimiert werden. Die Datei gibt auch an, bei welchem Block sie generiert wurde, den wir als _terminalen SwiftSync-Block_ bezeichnen.

  Der Nutzer, der SwiftSync durchführt, lädt die Hints-Datei herunter und verwendet sie beim Verarbeiten jedes Blocks vor dem terminalen SwiftSync-Block, um nur solche Outputs in der UTXO-Datenbank zu speichern, die laut Hints-Datei im UTXO-Set verbleiben werden, wenn der terminale SwiftSync-Block erreicht ist. Dadurch wird die Anzahl der Einträge, die während des IBD in die UTXO-Datenbank eingefügt und später wieder entfernt werden, massiv reduziert.

  Um sicherzustellen, dass die Hints-Datei korrekt ist, wird jeder erzeugte Output, der nicht in der UTXO-Datenbank gespeichert wird, zu einem [kryptographischen Akkumulator][cryptographic accumulator] hinzugefügt. Jeder ausgegebene Output wird aus dem Akkumulator entfernt. Wenn der Knoten den terminalen SwiftSync-Block erreicht, stellt er sicher, dass der Akkumulator leer ist, was bedeutet, dass jeder gesehene Output später ausgegeben wurde. Falls das nicht zutrifft, war die Hints-Datei fehlerhaft und der IBD muss ohne SwiftSync erneut durchgeführt werden. So müssen Nutzer dem Ersteller der Hints-Datei nicht vertrauen – eine bösartige Datei kann keinen falschen UTXO-Zustand erzeugen, sondern nur einige Stunden Rechenzeit verschwenden.

  Eine zusätzliche Eigenschaft von SwiftSync, die noch nicht implementiert ist, ist die parallele Validierung von Blöcken während des IBD. Dies ist möglich, weil assumevalid die Skripte älterer Blöcke nicht prüft, Einträge vor dem terminalen SwiftSync-Block nie aus der UTXO-Datenbank entfernt werden und der verwendete Akkumulator nur die Nettoeffekte von hinzugefügten (erzeugten) und entfernten (ausgegebenen) Outputs verfolgt. Dadurch entfallen Abhängigkeiten zwischen Blöcken vor dem terminalen SwiftSync-Block. Parallele Validierung während des IBD ist auch ein Feature von [Utreexo][topic utreexo] aus ähnlichen Gründen.

  Die Diskussion beleuchtete mehrere Aspekte des Vorschlags. Falbesoners ursprüngliche Implementierung nutzte den [MuHash][]-Akkumulator (siehe [Newsletter #123][news123 muhash]), der [als resistent][wuille muhash] gegen den [generalisierten Geburtstagsangriff][generalized birthday attack] gilt. Somsen [beschrieb][somsen ss1] einen alternativen Ansatz, der schneller sein könnte. Falbesoner zweifelte an der kryptographischen Sicherheit des alternativen Ansatzes, implementierte ihn aber dennoch aufgrund seiner Einfachheit und stellte fest, dass SwiftSync dadurch weiter beschleunigt wurde.

  James O'Beirne [fragte][obeirne ss], ob SwiftSync sinnvoll ist, da assumeUTXO eine noch größere Beschleunigung bietet. Somsen [antwortete][somsen ss2], dass SwiftSync die Hintergrundvalidierung von assumeUTXO beschleunigt und somit eine sinnvolle Ergänzung für assumeUTXO-Nutzer ist. Außerdem merkt er an, dass jeder, der die für assumeUTXO benötigten Daten (die UTXO-Datenbank zu einem bestimmten Block) herunterlädt, keine separate Hints-Datei benötigt, wenn er denselben Block als terminalen SwiftSync-Block verwendet.

  Vojtěch Strnad, 0xB10C und Somsen [diskutierten][b10c ss] die Komprimierung der Hints-Datei, mit einer erwarteten Einsparung von etwa 75 %, wodurch die Testdatei (für Block 850.900) auf etwa 88 MB schrumpft.

  Die Diskussion war zum Zeitpunkt des Schreibens noch im Gange. {% assign timestamp="0:34" %}

## Bitcoin Core PR Review Club

*In diesem monatlichen Abschnitt fassen wir ein aktuelles [Bitcoin Core PR Review Club][]-Meeting zusammen, heben einige wichtige Fragen und Antworten hervor. Klicken Sie auf eine Frage, um eine Zusammenfassung der Antwort aus dem Meeting zu sehen.*

[Add Fee rate Forecaster Manager][review club 31664] ist ein PR von [ismaelsadeeq][gh ismaelsadeeq], der die Logik zur Transaktionsgebühr-Vorhersage (auch [Schätzung][topic fee estimation] genannt) verbessert. Es führt eine neue `ForecasterManager`-Klasse ein, bei der mehrere `Forecaster` registriert werden können. Der bestehende `CBlockPolicyEstimator` (der nur bestätigte Transaktionen betrachtet) wird zu einem solchen Forecaster umgebaut, aber insbesondere wird ein neuer `MemPoolForecaster` eingeführt. `MemPoolForecaster` berücksichtigt unbestätigte Transaktionen im Mempool und kann daher schneller auf Änderungen der Feerate reagieren.

{% include functions/details-list.md
  q0="Warum heißt das neue System „Forecaster“ und „ForecasterManager“ statt „Estimator“ und „Fee Estimation Manager“?"
  a0=" Das System zeigt an, was in Zukunft passieren wird. Dafür benutzt es aktuelle und vergangene Daten. Ein Forecaster ist anders als ein Estimator. Ein Forecaster zeigt zukünftige Ereignisse an. Das ist die prädiktive Natur dieses Systems. Und es zeigt Unsicherheits-/Risikolevels an. Im Gegensatz zu einem Estimator, der aktuelle Bedingungen mit Zufall approximiert, projiziert ein Forecaster zukünftige Ereignisse, was der prädiktiven Natur dieses Systems und seiner Ausgabe von Unsicherheits-/Risikolevels entspricht."
  a0link="https://bitcoincore.reviews/31664#l-19"

  q1="Warum wird `CBlockPolicyEstimator` nicht so geändert, dass er eine Referenz auf den Mempool hält, ähnlich wie in PR #12966? Was ist der aktuelle Ansatz und warum ist er besser als eine Referenz auf den Mempool zu halten? (Hinweis: siehe PR #28368)"
  a1="`CBlockPolicyEstimator` erbt von `CValidationInterface` und implementiert deren virtuelle Methoden `TransactionAddedToMempool`, `TransactionRemovedFromMempool` und `MempoolTransactionsRemovedForBlock`. Das gibt `CBlockPolicyEstimator` alle nötigen Mempool-Informationen, ohne unnötig eng an den Mempool gekoppelt zu sein."
  a1link="https://bitcoincore.reviews/31664#l-26"

  q2="Was sind die Vor- und Nachteile der neuen Architektur im Vergleich zu einer direkten Änderung von `CBlockPolicyEstimator`?"
  a2="Die neue Architektur mit einer `FeeRateForecasterManager`-Klasse, bei der mehrere `Forecaster` registriert werden können, ist modularer, besser testbar und erzwingt eine bessere Trennung der Verantwortlichkeiten. Sie ermöglicht es, später einfach neue Vorhersagestrategien einzubinden. Das geht auf Kosten von etwas mehr Code und potenziell verwirrten Nutzern bezüglich der zu verwendenden Schätzmethode."
  a2link="https://bitcoincore.reviews/31664#l-43"
%}

{% assign timestamp="29:33" %}

## Veröffentlichungen und Release-Kandidaten

_Neue Veröffentlichungen und Release-Kandidaten für beliebte Bitcoin-Infrastrukturprojekte. Bitte erwägen Sie ein Upgrade auf neue Versionen oder helfen Sie bei der Testung von Release-Kandidaten._

- [Core Lightning 25.02.1][] ist ein Wartungsrelease für die aktuelle Hauptversion dieses beliebten LN-Knotens, das mehrere Fehlerbehebungen enthält. {% assign timestamp="46:54" %}

- [Core Lightning 24.11.2][] ist ein Wartungsrelease für eine frühere Hauptversion dieses beliebten LN-Knotens. Es enthält mehrere Fehlerbehebungen, einige davon sind die gleichen wie in Version 25.02.1. {% assign timestamp="47:03" %}

- [BTCPay Server 2.1.0][] ist ein Major Release dieser selbstgehosteten Zahlungsabwicklungssoftware. Es enthält Breaking Changes für Nutzer einiger Altcoins, Verbesserungen für [RBF][topic rbf] und [CPFP][topic cpfp] Fee-Bumping sowie einen besseren Ablauf für Multisig, wenn alle Signierer BTCPay Server verwenden. {% assign timestamp="48:14" %}

- [Bitcoin Core 29.0rc3][] ist ein Release-Kandidat für die nächste Hauptversion des dominierenden Full Nodes im Netzwerk. Siehe den [Version 29 Testleitfaden][bcc29 testing guide]. {% assign timestamp="49:25" %}

- [LND 0.19.0-beta.rc2][] ist ein Release-Kandidat für diesen beliebten LN-Knoten. Eine der wichtigsten Verbesserungen, die getestet werden sollten, ist das neue RBF-basierte Fee-Bumping für kooperative Schließungen. {% assign timestamp="51:21" %}

## Wichtige Code- und Dokumentationsänderungen

_Bedeutende kürzliche Änderungen in [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo], [Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition repo] und [BINANAs][binana repo]._

- [LDK #2256][] und [LDK #3709][] verbessern die Zuordenbarkeit von Fehlern (siehe [Newsletter #224][news224 failures]) wie in [BOLTs #1044][] spezifiziert, indem sie ein optionales `attribution_data`-Feld zur `UpdateFailHTLC`-Struktur und die `AttributionData`-Struktur einführen. In diesem Protokoll fügt jeder weiterleitende Node der Fehlermeldung ein `hop_payload`-Flag, ein Dauerfeld (wie lange der Node das HTLC gehalten hat) und HMACs für verschiedene angenommene Positionen in der Route hinzu. Wenn ein Node die Fehlermeldung beschädigt, hilft die Abweichung in der HMAC-Kette, das Node-Paar zu identifizieren, zwischen dem dies geschah. {% assign timestamp="53:52" %}

- [LND #9669][] stuft [Simple Taproot Channels][topic simple taproot channels] so zurück, dass immer der Legacy-Cooperative-Close-Flow verwendet wird, auch wenn der [RBF][topic rbf] Cooperative-Close-Flow (siehe [Newsletter #347][news347 coop]) konfiguriert ist. Zuvor konnte ein Node, bei dem beide Features konfiguriert waren, nicht starten. {% assign timestamp="56:16" %}

- [Rust Bitcoin #4302][] fügt der Script-Builder-API eine neue Methode `push_relative_lock_time()` hinzu, die einen relativen [Timelock][topic timelocks] als Parameter nimmt, und depreziert `push_sequence()`, die eine rohe Sequenznummer als Parameter nimmt. Diese Änderung behebt eine potenzielle Verwirrung, bei der Entwickler versehentlich eine rohe Sequenznummer in Skripte einfügen, anstatt einen relativen Timelock-Wert, der dann mit `CHECKSEQUENCEVERIFY` gegen die Sequenznummer eines Inputs geprüft wird. {% assign timestamp="57:24" %}

{% include snippets/recap-ad.md when="2025-04-15 15:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="2256,3709,9669,4302,1044" %}
[bitcoin core 29.0rc3]: https://bitcoincore.org/bin/bitcoin-core-29.0/
[bcc29 testing guide]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/29.0-Release-Candidate-Testing-Guide
[lnd 0.19.0-beta.rc2]: https://github.com/lightningnetwork/lnd/releases/tag/v0.19.0-beta.rc2
[wuille muhash]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2017-May/014337.html
[falbesoner ss1]: https://delvingbitcoin.org/t/ibd-booster-speeding-up-ibd-with-pre-generated-hints-poc/1562/
[somsen ssgist]: https://gist.github.com/RubenSomsen/a61a37d14182ccd78760e477c78133cd
[falbesoner ss2]: https://delvingbitcoin.org/t/ibd-booster-speeding-up-ibd-with-pre-generated-hints-poc/1562/7
[assumevalid]: https://bitcoincore.org/en/2017/03/08/release-0.14.0/#assumed-valid-blocks
[cryptographic accumulator]: https://en.wikipedia.org/wiki/Accumulator_(cryptography)
[news123 muhash]: /en/newsletters/2020/11/11/#bitcoin-core-pr-review-club
[muhash]: https://cseweb.ucsd.edu/~mihir/papers/inchash.pdf
[generalized birthday attack]: https://www.iacr.org/archive/crypto2002/24420288/24420288.pdf
[somsen ss1]: https://delvingbitcoin.org/t/ibd-booster-speeding-up-ibd-with-pre-generated-hints-poc/1562/2
[obeirne ss]: https://delvingbitcoin.org/t/ibd-booster-speeding-up-ibd-with-pre-generated-hints-poc/1562/5
[somsen ss2]: https://delvingbitcoin.org/t/ibd-booster-speeding-up-ibd-with-pre-generated-hints-poc/1562/6
[b10c ss]: https://delvingbitcoin.org/t/ibd-booster-speeding-up-ibd-with-pre-generated-hints-poc/1562/4
[somsen ssml]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CAPv7TjaM0tfbcBTRa0_713Bk6Y9jr+ShOC1KZi2V3V2zooTXyg@mail.gmail.com/T/#u
[core lightning 25.02.1]: https://github.com/ElementsProject/lightning/releases/tag/v25.02.1
[core lightning 24.11.2]: https://github.com/ElementsProject/lightning/releases/tag/v24.11.2
[btcpay server 2.1.0]: https://github.com/btcpayserver/btcpayserver/releases/tag/v2.1.0
[news224 failures]: /de/newsletters/2022/11/02/#zuordnung-von-ln-routing-fehlern
[news347 coop]: /de/newsletters/2025/03/28/#lnd-8453
[review club 31664]: https://bitcoincore.reviews/31664
[gh ismaelsadeeq]: https://github.com/ismaelsadeeq
[forecastresult compare]: https://github.com/bitcoin-core-review-club/bitcoin/commit/1e6ce06bf34eb3179f807efbddb0e9bca2d27f28#diff-5baaa59bccb2c7365d516b648dea557eb50e63837de71531dc460dbcc62eb9adR74-R77
