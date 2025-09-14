---
title: 'Bitcoin Optech Newsletter #370'
permalink: /de/newsletters/2025/09/05/
name: 2025-09-05-newsletter-de
slug: 2025-09-05-newsletter-de
type: newsletter
layout: newsletter
lang: de
---
Der Newsletter dieser Woche enthält unsere regelmäßigen Abschnitte, die
Diskussionen über die Änderung der Konsensregeln von Bitcoin zusammenfassen,
neue Releases und Release-Kandidaten ankündigen und wichtige Änderungen an
beliebter Bitcoin-Infrastruktur-Software beschreiben.

## Nachrichten

_Diese Woche wurden in keiner unserer [Quellen][optech sources] wichtige Nachrichten gefunden._

## Konsensänderungen

_Ein monatlicher Abschnitt, der Vorschläge und Diskussionen über die Änderung
der Konsensregeln von Bitcoin zusammenfasst._

- **Details zum Design von Simplicity:** Russell O'Connor hat bisher
  drei Beiträge ([1][sim1], [2][sim2], [3][sim3]) in Delving Bitcoin
  über "die Philosophie und das Design der [Simplicity-Sprache][topic simplicity]"
  veröffentlicht. Die Beiträge untersuchen "die drei Hauptformen der
  Komposition zur Umwandlung grundlegender Operationen in komplexe
  Operationen", "das Typsystem, die Kombinatoren und die grundlegenden
  Ausdrücke von Simplicity" und "wie man logische Operationen von Bits
  bis hin zu kryptografischen Operationen wie SHA-256 und der
  Validierung von Schnorr-Signaturen nur mit unseren rechnerischen
  Simplicity-Kombinatoren aufbaut."

  Der jüngste Beitrag deutet darauf hin, dass weitere Einträge in der
  Serie erwartet werden.

- **BIP-Entwurf zur Hinzufügung von Elliptic-Curve-Operationen zu Tapscript:**
  Olaoluwa Osuntokun [veröffentlichte][osuntokun ec] in der Bitcoin-Dev-Mailingliste
  einen Link zu einem [BIP-Entwurf][osuntokun bip] zur Hinzufügung mehrerer
  Opcodes zu [Tapscript][topic tapscript], die es ermöglichen, Elliptic-Curve-Operationen
  auf dem Skript-Auswertungs-Stack durchzuführen. Die Opcodes sollen in
  Kombination mit Introspektions-Opcodes verwendet werden, um [Covenant][topic covenants]-Protokolle
  zu erstellen oder zu verbessern, zusätzlich zu anderen Fortschritten.

  Jeremy Rubin [antwortete][rubin ec1] mit Vorschlägen für zusätzliche
  Opcodes, um weitere Funktionen zu ermöglichen, sowie [andere Opcodes][rubin ec2],
  die die Nutzung einiger Funktionen des Basisvorschlags bequemer machen würden.

- **BIP-Entwurf für OP_TWEAKADD:** Jeremy Rubin [veröffentlichte][rubin ta1]
  in der Bitcoin-Dev-Mailingliste einen Link zu einem [BIP-Entwurf][rubin bip]
  zur Hinzufügung von `OP_TWEAKADD` zu [Tapscript][topic tapscript]. Er
  [veröffentlichte][rubin ta2] separat bemerkenswerte Beispiele für Skripte,
  die durch die Hinzufügung des Opcodes ermöglicht werden, darunter ein
  Skript zur Aufdeckung eines [Taproot][topic taproot]-Tweaks, ein Nachweis
  der Reihenfolge der Signierung einer Transaktion (z. B. muss Alice vor
  Bob signiert haben) und die [Delegierung von Signaturen][topic signer delegation].

## Releases und Release-Kandidaten

_Neue Releases und Release-Kandidaten für beliebte Bitcoin-Infrastrukturprojekte.
Bitte erwägen Sie, auf neue Versionen zu aktualisieren oder bei der Testung von
Release-Kandidaten zu helfen._

- [Core Lightning v25.09][] ist ein Release einer neuen Hauptversion
  dieser beliebten LN-Knoten-Implementierung. Es fügt dem `xpay`-Befehl
  Unterstützung für die Bezahlung von [BIP353][]-Adressen und einfachen
  [Offers][topic offers] hinzu, bietet verbesserte Buchhaltungsunterstützung,
  ein besseres Plugin-Abhängigkeitsmanagement und enthält weitere neue
  Funktionen und Fehlerbehebungen.

- [Bitcoin Core 29.1rc2][] ist ein Release-Kandidat für eine Wartungsversion
  der führenden Full-Node-Software.

## Wichtige Code- und Dokumentationsänderungen

_Wichtige aktuelle Änderungen in [Bitcoin Core][bitcoin core repo],
[Core Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], und [BINANAs][binana repo]._

- [LDK #3726][] fügt Unterstützung für Dummy-Hops auf [verdeckten Pfaden][topic rv routing]
  hinzu, sodass Empfänger beliebige Hops hinzufügen können, die keinem
  Routing-Zweck dienen, sondern als Täuschung fungieren. Eine zufällige
  Anzahl von Dummy-Hops wird jedes Mal hinzugefügt, ist aber auf 10 begrenzt,
  wie durch `MAX_DUMMY_HOPS_COUNT` definiert. Das Hinzufügen zusätzlicher
  Hops erschwert es erheblich, die Entfernung zum oder die Identität des
  Empfängerknotens zu bestimmen.

- [LDK #4019][] integriert [Splicing][topic splicing] mit dem
  [Quiescence-Protokoll][topic channel commitment upgrades], indem ein
  ruhiger Kanalzustand vor der Initialisierung einer Splicing-Transaktion
  erforderlich ist, wie von der Spezifikation vorgeschrieben.

- [LND #9455][] fügt Unterstützung für die Zuordnung eines gültigen
  DNS-Domainnamens zur IP-Adresse und zum öffentlichen Schlüssel eines
  Lightning-Knotens in seiner Ankündigungsnachricht hinzu, wie es die
  Spezifikation erlaubt und von anderen Implementierungen wie Eclair und
  Core Lightning unterstützt wird (siehe Newsletter [#212][news212 dns],
  [#214][news214 dns] und [#178][news178 dns]).

- [LND #10103][] führt eine neue Option `gossip.peer-msg-rate-bytes`
  (Standard 51200) ein, die ausgehende Bandbreite begrenzt, die jeder
  Peer für ausgehende [Gossip-Nachrichten][topic channel announcements]
  verwendet. Dieser Wert begrenzt die durchschnittliche Bandbreitengeschwindigkeit
  in Bytes pro Sekunde, und wenn ein Peer sie überschreitet, beginnt LND,
  Nachrichten an diesen Peer in eine Warteschlange zu stellen und zu
  verzögern. Diese neue Option verhindert, dass ein einzelner Peer die
  gesamte globale Bandbreite verbraucht, die durch `gossip.msg-rate-bytes`
  in [LND #10096][] eingeführt wurde. Siehe Newsletter [#366][news366 gossip]
  und [#369][news369 gossip] für verwandte LND-Arbeiten zum Ressourcenmanagement
  von Gossip-Anfragen.

- [HWI #795][] fügt Unterstützung für die BitBox02 Nova hinzu, indem die
  `bitbox02`-Bibliothek auf Version 7.0.0 aktualisiert wird. Es werden
  auch mehrere CI-Aktualisierungen vorgenommen.

{% include snippets/recap-ad.md when="2025-09-09 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="3726,4019,9455,10103,795,10096" %}
[bitcoin core 29.1rc2]: https://bitcoincore.org/bin/bitcoin-core-29.1/
[core lightning v25.09]: https://github.com/ElementsProject/lightning/releases/tag/v25.09
[sim1]: https://delvingbitcoin.org/t/delving-simplicity-part-three-fundamental-ways-of-combining-computations/1902
[sim2]: https://delvingbitcoin.org/t/delving-simplicity-part-combinator-completeness-of-simplicity/1935
[sim3]: https://delvingbitcoin.org/t/delving-simplicity-part-building-data-types/1956
[osuntokun ec]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CAO3Pvs-Cwj=5vJgBfDqZGtvmoYPMrpKYFAYHRb_EqJ5i0PG0cA@mail.gmail.com/
[osuntokun bip]: https://github.com/bitcoin/bips/pull/1945
[rubin ec1]: https://mailing-list.bitcoindevs.xyz/bitcoindev/f118d974-8fd5-42b8-9105-57e215d8a14an@googlegroups.com/
[rubin ec2]: https://mailing-list.bitcoindevs.xyz/bitcoindev/1c2539ba-d937-4a0f-b50a-5b16809322a8n@googlegroups.com/
[rubin ta1]: https://mailing-list.bitcoindevs.xyz/bitcoindev/bc9ff794-b11e-47bc-8840-55b2bae22cf0n@googlegroups.com/
[rubin ta2]: https://mailing-list.bitcoindevs.xyz/bitcoindev/c51c489c-9417-4a60-b642-f819ccb07b15n@googlegroups.com/
[rubin bip]: https://github.com/bitcoin/bips/pull/1944
[news212 dns]: /de/newsletters/2022/08/10/#bolts-911
[news214 dns]: /de/newsletters/2022/08/24/#eclair-2234
[news178 dns]: /en/newsletters/2021/12/08/#c-lightning-4829
[news366 gossip]: /de/newsletters/2025/08/08/#lnd-10097
[news369 gossip]: /de/newsletters/2025/08/29/#lnd-10102
