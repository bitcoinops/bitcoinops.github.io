---
title: 'Bitcoin Optech Newsletter #211'
permalink: /de/newsletters/2022/08/03/
name: 2022-08-03-newsletter-de
slug: 2022-08-03-newsletter-de
type: newsletter
layout: newsletter
lang: de
---
Der Newsletter dieser Woche beschreibt einen Vorschlag, der mehrere
Ableitungspfade (Derivation paths) in einem einzigen Outputskript-Deskriptor
zulässt und enthält unseren üblichen Abschnitt mit Zusammenfassungen
erwähnenswerter Änderungen an beliebten Bitcoin Infrastrukturprojekten.

## News

- **Multi-Ableitungspfad-Deskriptoren:** Andrew Chow hat einen
  [BIP-Vorschlag][bip-multipath-descs] in der Bitcoin-Dev Mailingliste
  [geposted][chow desc], um Spezifizierung zweier
  verwandter [BIP32][]-Pfade für [HD-Schlüsselgenerierung][topic bip32]
  in einem einzelnen Deskriptor zu erlauben. Der erste Pfad würde zur Erzeugung von Adressen verwendet werden,
  an die eingehende Zahlungen empfangen werden können. Der zweite Adresspfad wäre
  für interne Zahlungen innerhalb des Wallets gedacht; nämlich zur Rückgabe von
  Wechselgeld an das Wallet, nachdem eine UTXO ausgegeben wurde.

    Für besseren Datenschutz verwenden die meisten Wallets separate Pfade
    zur Erzeugung externer und interner Adressen wie per BIP32
    [spezifiziert][bip32 wallet layout]. Ein externer Pfad, der für den
    Empfang von Zahlungen verwendet wird, kann mit weniger vertrauenswürdigen
    Geräten geteilt werden. Z.B. durch Hochladen auf einen Webserver, damit
    Zahlungen empfangen werden können. Der interne Pfad, der nur für Wechselgeld
    verwendet wird, wird möglicherweise nur dann benötigt, wenn der private
    Schlüssel ebenfalls benötigt wird, so dass diese beiden die gleiche Sicherheit
    erhalten könnte. Würde der Beispiel-Webserver kompromittiert und die
    externen Adressen sickerten durch, würden Angreifer jedes Mal erfahren,
    ob der Nutzer Geld erhalten hat, wie viel er erhalten hat und wann das
    Geld ursprünglich ausgegeben wurde - aber sie würden nicht unbedingt
    erkennen können, wie viel Geld in dieser Transaktion an den Empfänger gesandt wurde,
    und sie würden auch nichts über Ausgaben erfahren, die ausschließlich
    Wechselgeld ausgeben.

    Antworten von [Pavol Rusnak][rusnak desc] und [Craig Raw][raw desc]
    wiesen darauf hin, dass das Trezor- und das Sparrow Wallet bereits das von
    Chow vorgeschlagene System unterstützen. Rusnak fragte auch, ob ein
    einzelner Deskriptor in der Lage sein sollte, mehr als zwei zusammenhängende
    Pfade zu beschreiben. Dmitry Petukhov [merkte an][petukhov desc], dass
    bis dato nur interne und externe Pfade weite Verbreitung fänden und dass
    zusätzlichen Pfaden in bestehende Wallets keine klare Bedeutung zukomme.
    Dies könne Interoperabilitätsprobleme verursachen. Er schlug vor,
    das BIP auf zwei Pfade zu beschränken und dass für zusätzliche Pfade
    Folge-BIPs geschrieben werden sollten.

## Nennenswerte Code- und Dokumentationsänderungen

*Erwähnenswerte Änderungen diese Woche in [Bitcoin Core][bitcoin core repo],
[CoreLightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], und [Lightning BOLTs][bolts repo].*

- [Core Lightning #5441][] aktualisiert `hsmtool` um den Vergleich der
  [BIP39][] Passphrase mit dem [HD seed][topic bip32], der vom
  CLN internen Wallet verwendet wird, zu vereinfachen.

- [Eclair #2253][] fügt Support für das Weiterleiten von
  [verdeckten Zahlungen (blinded payments)][topic rv routing] wie in [BOLTs #765][] spezifiziert
  hinzu. (siehe [Newsletter #187][news178 eclair 2061])

- [LDK #1519][] fügt immer das `htlc_maximum_msat`-Feld in
  `channel_update`-Nachrichten ein, was erforderlich wird wenn [BOLTs #996][] in die
  LN-Spezifikation aufgenommen wird. Die im Pullrequest angegebene Begründung
  für die Änderung ist die Vereinfachung des Nachrichtenparsings.

- [Rust Bitcoin #994][] fügt einen `LockTime`-Typ hinzu, der zusammen mit
  nLockTime und [BIP65][] `OP_CHECKLOCKTIME`-Feldern verwendet werden kann.
  Locktime-Felder in Bitcoin können entweder eine Blockhöhe oder den
  [Unix epoch time][]-Wert enthalten.

- [Rust Bitcoin #1088][] fügt notwendige Strukturen für [kompakte
  Blöcke][topic compact block relay], wie in [BIP152][] beschrieben, sowie
  eine Methode zur Erstellung eines kompakten Blocks aus einem regulären Block,
  hinzu. Kompakte Blöcke ermöglichen es einem Node seinen Peers mitzuteilen,
  welche Transaktionen der Block enthält, ohne vollständige Kopien dieser
  Transaktionen übermitteln zu müssen. Wenn ein Peer diese Transaktionen bereits
  empfangen und gespeichert hat, als sie noch unbestätigt waren, müssen die
  Transaktionen nicht erneut heruntergeladen werden. Das spart Bandbreite und
  beschleunigt die Weiterleitung neuer Blöcke.

{% include references.md %}
{% include linkers/issues.md v=2 issues="5441,2253,1519,994,1088,996,765" %}
[bip32 wallet layout]: https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki#specification-wallet-structure
[chow desc]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020791.html
[bip-multipath-descs]: https://github.com/achow101/bips/blob/bip-multipath-descs/bip-multipath-descs.mediawiki
[rusnak desc]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020792.html
[raw desc]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020799.html
[petukhov desc]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020804.html
[unix epoch time]: https://en.wikipedia.org/wiki/Unix_time
[news178 eclair 2061]: /en/newsletters/2021/12/08/#eclair-2061
