---
title: 'Bitcoin Optech Newsletter #215'
permalink: /de/newsletters/2022/08/31/
name: 2022-08-31-newsletter-de
slug: 2022-08-31-newsletter-de
type: newsletter
layout: newsletter
lang: de
---
Der Newsletter dieser Woche beschreibt einen Vorschlag für ein standardisiertes
Wallet-Label-Exportformat und enthält unsere regelmäßigen Abschnitte mit
Zusammenfassungen von Fragen und Antworten aus dem Bitcoin Stack Exchange, eine
Liste von neuen Software Releases und Release Candidates, sowie Beschreibungen
von erwähnenswerten Änderungen an beliebter Bitcoin Infrastruktursoftware.

## News

- **Wallet-label Exportformat:** Craig Raw hat auf der Bitcoin-Dev-Mailingliste
  einen Vorschlag für ein BIP [gepostet][raw interchange], um das von Wallets
  verwendete Format für den Export von Labels für Adressen und Transaktionen zu
  standardisieren. Ein standardisiertes Exportformat könnte es theoretisch
  ermöglichen, dass zwei Wallet-Programme, welche die gleiche [BIP32][topic bip32]
  Kontenhierarchie verwenden, die Backups der jeweils anderen Software zu öffnen
  und nicht nur die Mittel, sondern auch alle vom Benutzer manuell eingegebenen
  Informationen über seine Transaktionen, wiederherzustellen.

  In Anbetracht der bisherigen Schwierigkeiten, BIP32-Wallets untereinander
  kompatibel zu machen wäre es vielleicht einfacher, den Transaktionsverlauf
  aus einem Wallet zu exportieren, damit er in anderen Programmen verwendet
  werden kann; etwa für die Buchhaltung.

  Die Entwickler Clark Moody und Pavol Rusnak [antworteten beide][moody slip15]
  mit einem [Verweis][rusnak slip15] auf [SLIP15][], welches das offene
  Exportformat beschreibt, das für Wallets der Marke Trezor entwickelt
  wurde. Craig Raw [verwies][raw slip15] auf mehrere signifikante Unterschiede
  zwischen dem, was sein vorgeschlagenen Format zu erreichen versucht, und
  dem, was SLIP15 zur Verfügung zu stellen scheint. Mehrere andere
  Designaspekte wurden ebenfalls diskutiert. Zum Zeitpunkt der Publikation
  dieser Zusammenfassung, schien die Diskussion noch nicht abgeschlossen
  zu sein.

## Ausgewählte Q&A aus dem Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] ist eine der Plattformen auf denen
Optech-Mitwirkende zuerst nach Antworten auf ihre Fragen suchen–oder wenn wir
einige Augenblicke Zeit haben, anderen neugierigen oder verwirrten Nutzern
aushelfen. In dieser monatlichen Rubrik stellen wir einige der populärsten
Fragen und Antworten des letzten Monats vor.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Warum ist es nicht möglich, in einen taproot-Skriptpfad mit einem Deskriptor ein OP_RETURN-Commitment (oder ein beliebiges Skript) einzufügen?]({{bse}}114948)
  Antoine Poinsot erklärt, dass [Skript-Deskriptoren][topic descriptors] derzeit
  um [Miniscript][topic miniscript] für die Verwendung in Bitcoin Core erweitert
  werden, und in der Bitcoin Core Version 24.0 erwartet werden.
  Während anfänglich die miniscript-Funktionen nur Segwit v0-Unterstützung
  beinhalten wird, könnte die Unterstützung für [Tapscript][topic tapscript] und
  [partielle Deskriptoren][Bitcoin Core #24114] es möglich machen, Commitments
  innerhalb von Tapscript hinzuzufügen, ohne ausschliesslich den
  `raw()` -Deskriptor verwenden zu müssen.

- [Warum wiederholt Bitcoin Core das Übertragen von Transaktionen?]({{bse}}114973)
  Amir reza Riahi fragt sich, warum Bitcoin Core das Übertragen von
  Transaktionen wiederholt (re-broadcasting) und warum es eine Verzögerung gibt.
  Pieter Wuille weist auf die fehlende Transaktionsausbreitungsgarantie des
  P2P-Netzwerks als Grund für die Notwendigkeit des Re-Broadcastings hin, und
  verweist auf die geleistete Arbeit die Verantwortung für das Re-Broadcasting
  aus dem Wallet auf den Mempool zu übertragen. Leser, die sich für
  Re-Broadcasting interessieren, können auch die PR Review Club Meetings vom
  [24 Aug 2022][prreview 25768], [07 Apr 2021][prreview 21061], und
  [27 Nov 2019][prreview 16698] lesen.

- [Wann hat Bitcoin Core die Mining-Funktion entfernt?]({{bse}}114687)
  Pieter Wuille gibt einen historischen Überblick über Mining-bezogene
  Funktionen in Bitcoin Core im Laufe der Jahre.

- [UTXO, die ich ausgeben kann, oder Pfand, das ich nach 5 Jahren umtauschen kann?]({{bse}}114901)
  Stickies-v bietet einen Überblick über Bitcoin Script Operatoren, wie
  [Taproot][topic taproot] mit [MAST][topic mast] die Ausgabebedingungen aus
  Sicht der Privatsphäre und der Gebührenrate verbessert, und weist darauf hin,
  dass Scripts Mangel an [covenants][topic covenants] die vorgeschlagenen
  Bedingungen allein in Script unmöglich macht. Vojtěch Strnad weist darauf hin,
  dass vorsignierte Transaktionen helfen können die vorgeschlagenen
  Ausgabenbedingungen zu erfüllen.

- [Was war der Bitcoin value-overflow-Bug im Jahr 2010?]({{bse}}114694)
  Andrew Chow fasst den [value overflow-Bug][value overflow bug] und seine
  mehrfach-inflationären Auswirkungen zusammen: die Erzeugung von grossen
  Outputs sowie die falsch berechnete Transaktionsgebühr.

## Releases und Release-Kandidaten

*Neue Releases und Release-Kandidaten für beliebte Bitcoin
Infrastrukturprojekte. Bitte erwäge auf die neuen Versionen
zu wechseln oder beim Testen von Release candidates auszuhelfen.*

- [LND 0.15.1-beta][] ist ein Release der "Unterstützung für [zero conf channels]
  [topic zero-conf channels], Short Channel ID (scid)-[Aliase][aliases] enthält,
  [und der] überall auf die Verwendung von [Taproot][topic taproot]-Adressen
  wechselt".

## Nennenswerte Code- und Dokumentationsänderungen

*Erwähnenswerte Änderungen diese Woche in [Bitcoin Core][bitcoin core repo],
[Core Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], und [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #23202][] erweitert den `psbtbumpfee`-RPC um die Fähigkeit
  eine [PSBT][topic psbt] zu erstellen, welche die Gebühren einer Transaktion
  selbst dann erhöht, wenn einige oder alle Eingaben der Transaktion nicht dem
  Wallet gehören. Die PSBT kann dann mit den Wallets geteilt werden, die diese
  signieren können.

- [Eclair #2275][] fügt Unterstützung für Gebührenerhöhung einer
  [dual finanzierten][topic dual funding] LN-Setuptransaktion ein. Der PR
  hält fest, dass mit diesem PR "duale Finanzierung vollständig von Eclair
  unterstützt wird!". Es wird jedoch auch darauf hingewiesen dass duale
  Finanzierung standardmäßig deaktiviert ist und dass in Zukunft Tests für
  [Cross Kompatibilität mit Core Lightning][news143 cln df] hinzugefügt werden.

- [Eclair #2387][] fügt Unterstützung für [signet][topic signet] hinzu.

- [LDK #1652][] aktualisiert die Unterstützung für [Onion-Nachrichten]
  [topic onion messages] mit der Möglichkeit, *Antwortpfade* zu senden und sie
  beim Empfang zu dekodieren. Das Onion-Nachrichtenprotokoll erfordert nicht,
  dass ein Knoten der eine Onion-Nachricht weiterleitet, Informationen
  über diese Nachricht verfolgt, nachdem sie weitergeleitet wurde. Somit kann
  der Knoten nicht automatisch eine Antwort entlang ursprüngliche Nachrichtwegs
  senden. Dies bedeutet, dass ein Knoten der eine Antwort auf seine Nachricht
  erwartet, dem Empfänger Hinweise über den Pfad, welcher er für das Senden
  einer Antwort verwenden soll, geben muss.

- [HWI #627][] fügt Unterstützung für [P2TR][topic taproot] Keypath-Ausgaben,
  bei der Verwendung von BitBox02-Hardware-Signiergeräten, hinzu.

- [BDK #718][] beginnt damit sowohl ECDSA- als auch [Schnorr-Signaturen]
  [topic schnorr signatures], sofort nachdem das Wallet sie erstellt, zu
  verifizieren. Dies ist eine Empfehlung von [BIP340][] (siehe [Newsletter #87]
  [news87 verify]), wurde in [Newsletter #83][news83 verify] diskutiert, und
  wurde zuvor in Bitcoin Core implementiert (siehe [Newsletter #175]
  [news175 verify]).

- [BDK #705][] und [#722][bdk #722] gibt Software, welche die BDK-Bibliothek
  verwendet, die Möglichkeit auf zusätzliche serverseitige Methoden zuzugreifen,
  die durch Electrum- und Esplora-Dienste bereitgestellt werden.

{% include references.md %}
{% include linkers/issues.md v=2 issues="23202,2275,2387,1652,627,718,705,722,24114" %}
[lnd 0.15.1-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.15.1-beta
[news175 verify]: /en/newsletters/2021/11/17/#bitcoin-core-22934
[news87 verify]: /en/newsletters/2020/03/04/#bips-886
[news83 verify]: /en/newsletters/2020/02/05/#safety-concerns-related-to-precomputed-public-keys-used-with-schnorr-signatures
[raw interchange]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-August/020887.html
[moody slip15]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-August/020888.html
[rusnak slip15]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-August/020892.html
[raw slip15]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-August/020893.html
[aliases]: /en/newsletters/2022/07/13/#lnd-5955
[slip15]: https://github.com/satoshilabs/slips/blob/master/slip-0015.md
[news143 cln df]: /en/newsletters/2021/04/07/#c-lightning-0-10-0
[prreview 25768]: https://bitcoincore.reviews/25768
[prreview 21061]: https://bitcoincore.reviews/21061
[prreview 16698]: https://bitcoincore.reviews/16698
[value overflow bug]: /en/topics/soft-fork-activation/#fix-value-overflow-bug-august-2010
