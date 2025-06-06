---
title: 'Bitcoin Optech Newsletter #352'
permalink: /de/newsletters/2025/05/02/
name: 2025-05-02-newsletter-de
slug: 2025-05-02-newsletter-de
type: newsletter
layout: newsletter
lang: de
---
Der Newsletter dieser Woche verweist auf Vergleiche verschiedener Cluster-Linearisierungstechniken und fasst kurz die Diskussion über die Erhöhung oder Abschaffung des `OP_RETURN`-Größenlimits in Bitcoin Core zusammen. Ebenfalls enthalten sind unsere regulären Abschnitte mit Ankündigungen neuer Releases und Release-Kandidaten sowie Zusammenfassungen wichtiger Änderungen an populärer Bitcoin-Infrastruktur.

## Nachrichten

- **Vergleich von Cluster-Linearisationstechniken:**
  Pieter Wuille [veröffentlichte][wuille clustrade] auf Delving Bitcoin einige grundlegende Abwägungen zwischen drei verschiedenen Cluster-Linearisationstechniken und ergänzte dies durch [Benchmarks][wuille clusbench] der jeweiligen Implementierungen. Mehrere andere Entwickler diskutierten die Ergebnisse und stellten Rückfragen, auf die Wuille antwortete.

- **Erhöhung oder Abschaffung des `OP_RETURN`-Größenlimits in Bitcoin Core:**
  In einem Thread auf der Bitcoin-Dev-Mailingliste diskutierten mehrere Entwickler, das Standardlimit für `OP_RETURN`-Data-Carrier-Outputs in Bitcoin Core zu ändern oder ganz abzuschaffen. Eine nachfolgende [Pull-Request-Diskussion][bitcoin core #32359] brachte weitere Argumente. Anstatt die gesamte umfangreiche Diskussion zusammenzufassen, stellen wir das aus unserer Sicht überzeugendste Argument für und gegen die Änderung vor.

  - *Für die Erhöhung (oder Abschaffung) des Limits:*
    Pieter Wuille [argumentierte][wuille opr], dass die Standardness-Policy von Transaktionen kaum verhindern kann, dass gut finanzierte Organisationen Daten tragende Transaktionen direkt an Miner senden und so in Blöcke bringen. Außerdem seien Blöcke ohnehin meist voll, egal ob sie Daten enthalten oder nicht, sodass sich die Gesamtmenge der zu speichernden Daten für einen Knoten kaum ändert.

  - *Gegen die Erhöhung des Limits:*
    Jason Hughes [argumentierte][hughes opr], dass eine Erhöhung des Limits es einfacher machen würde, beliebige Daten auf Rechnern zu speichern, die Full Knoten betreiben – darunter auch potenziell anstößige oder in vielen Ländern illegale Inhalte. Selbst wenn der Knoten die Daten auf der Festplatte verschlüsselt (siehe [Newsletter #316][news316 blockxor]), könnte das Speichern und Abrufen solcher Daten über Bitcoin Core RPCs für viele Nutzer problematisch sein.


## Veröffentlichungen und Release-Kandidaten

_Neue Veröffentlichungen und Release-Kandidaten für beliebte Bitcoin-Infrastrukturprojekte. Bitte erwägen Sie ein Upgrade auf neue Versionen oder helfen Sie bei der Testung von Release-Kandidaten._

- [LND 0.19.0-beta.rc3][] ist ein Release-Kandidat für diesen beliebten LN-Knoten. Eine der wichtigsten Verbesserungen, die getestet werden sollten, ist das neue RBF-basierte Fee-Bumping für kooperative Schließungen.

## Wichtige Code- und Dokumentationsänderungen

_Bedeutende kürzliche Änderungen in [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo], [Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition repo] und [BINANAs][binana repo]._

- [Bitcoin Core #31250][] deaktiviert die Erstellung und das Laden von Legacy-Wallets und schließt damit die Migration zu [Deskriptor][topic descriptors]-Wallets ab, die seit Oktober 2021 Standard sind (siehe Newsletter [#172][news172 descriptors]). Berkeley DB-Dateien von Legacy-Wallets können nicht mehr geladen werden, und alle Unit- und Funktionstests für Legacy-Wallets werden entfernt. Ein Teil des Legacy-Wallet-Codes bleibt noch erhalten, wird aber in Folge-PRs entfernt. Bitcoin Core kann weiterhin Legacy-Wallets in das neue Deskriptor-Wallet-Format migrieren (siehe [Newsletter #305][news305 bdbro]).

- [Eclair #3064][] überarbeitet das Channel-Key-Management durch Einführung einer `ChannelKeys`-Klasse. Jeder Channel hat nun ein eigenes `ChannelKeys`-Objekt, das zusammen mit den Commitment-Points ein `CommitmentKeys`-Set für die Signierung von Remote/Local-Commitment- und [HTLC][topic htlc]-Transaktionen ableitet. Die Logik für Zwangsschließungen und das Erstellen von Script/Witness wird ebenfalls angepasst. Zuvor war die Schlüsselerzeugung auf mehrere Teile des Codes verteilt, was fehleranfällig war, da die richtige Pubkey-Übergabe nicht typgesichert war.

- [BTCPay Server #6684][] fügt Unterstützung für einen Teil der [BIP388][]-Wallet-Policy-[Deskriptoren][topic descriptors] hinzu, sodass Nutzer sowohl Single-Sig- als auch k-of-n-Policies importieren und exportieren können. Unterstützt werden die von Sparrow verwendeten Formate wie P2PKH, P2WPKH, P2SH-P2WPKH und P2TR sowie die entsprechenden Multisig-Varianten (außer P2TR). Ziel dieses PR ist die Verbesserung der Multisig-Wallet-Nutzung.

- [BIPs #1555][] merged [BIP321][], das ein URI-Schema für Bitcoin-Zahlungsanweisungen vorschlägt, das [BIP21][] modernisiert und erweitert. Es behält den alten pfadbasierten Adressstil bei, standardisiert aber die Nutzung von Query-Parametern, sodass neue Zahlungsarten über eigene Parameter identifiziert werden können. Das Adressfeld kann leer bleiben, wenn mindestens eine Anweisung als Query-Parameter angegeben ist. Optional kann ein Zahlungsnachweis für den Sender bereitgestellt werden, und es gibt Hinweise zur Integration neuer Zahlungsanweisungen.

{% include references.md %}
{% include linkers/issues.md v=2 issues="31250,3064,6684,1555,32359" %}
[lnd 0.19.0-beta.rc3]: https://github.com/lightningnetwork/lnd/releases/tag/v0.19.0-beta.rc3
[wuille clustrade]: https://delvingbitcoin.org/t/how-to-linearize-your-cluster/303/68
[wuille clusbench]: https://delvingbitcoin.org/t/how-to-linearize-your-cluster/303/73
[hughes opr]: https://mailing-list.bitcoindevs.xyz/bitcoindev/f4f6831a-d6b8-4f32-8a4e-c0669cc0a7b8n@googlegroups.com/
[wuille opr]: https://mailing-list.bitcoindevs.xyz/bitcoindev/QMywWcEgJgWmiQzASR17Dt42oLGgG-t3bkf0vzGemDVNVnvVaD64eM34nOQHlBLv8nDmeBEyTXvBUkM2hZEfjwMTrzzoLl1_62MYPz8ZThs=@wuille.net/
[news316 blockxor]: /en/newsletters/2024/08/16/#bitcoin-core-28052
[news172 descriptors]: /en/newsletters/2021/10/27/#bitcoin-core-23002
[news305 bdbro]: /en/newsletters/2024/05/31/#bitcoin-core-26606
