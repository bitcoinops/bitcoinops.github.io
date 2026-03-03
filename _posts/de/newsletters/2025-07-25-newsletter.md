---
title: 'Bitcoin Optech Newsletter #364'
permalink: /de/newsletters/2025/07/25/
name: 2025-07-25-newsletter-de
slug: 2025-07-25-newsletter-de
type: newsletter
layout: newsletter
lang: de
---
Der Newsletter dieser Woche fasst eine Schwachstelle zusammen, die ältere
Versionen von LND betrifft, beschreibt eine Idee zur Verbesserung der
Privatsphäre bei der Nutzung von Co-Signer-Diensten und untersucht die
Auswirkungen des Wechsels zu quantenresistenten Signaturalgorithmen auf
HD-Wallets, scriptlose Multisignaturen und Silent Payments.
Wie gewohnt enthält der Newsletter unsere regelmäßigen Abschnitte mit
Zusammenfassungen beliebter Fragen und Antworten aus Bitcoin Stack Exchange,
der Ankündigung neuer Releases und Release-Kandidaten sowie einer Übersicht
wichtiger Änderungen an beliebter Bitcoin-Infrastruktur-Software.

## Nachrichten

- **LND Gossip-Filter-DoS-Sicherheitslücke:** Matt Morehouse
  [berichtete][morehouse gosvuln] auf Delving Bitcoin über eine Schwachstelle,
  die frühere Versionen von LND betraf und die er zuvor [verantwortungsvoll
  gemeldet][topic responsible disclosures] hatte. Ein Angreifer konnte wiederholt
  historische Gossip-Nachrichten von einem LND-Knoten anfordern, bis der Speicher
  erschöpft war und der Knoten beendet wurde. Die Schwachstelle wurde in LND
  Version 0.18.3 behoben, die im September 2024 veröffentlicht wurde.

- **Chain-Code-Vorenthaltung bei Multisig-Skripten:** Jurvis Tan
  [berichtete][tan ccw] auf Delving Bitcoin über Forschung, die er gemeinsam mit
  Jesse Posner zur Verbesserung der Privatsphäre und Sicherheit bei gemeinsamer
  Multisig-Verwahrung durchgeführt hat. In einem typischen Custody-Service wird
  häufig eine 2-aus-3-Multisig verwendet, wobei die drei Schlüssel sind:

  - Ein Nutzer-"Hot Key", der auf einem mit dem Netzwerk verbundenen Gerät
    gespeichert ist und Transaktionen für den Nutzer signiert (manuell oder per
    Software).

  - Ein Anbieter-"Hot Key", der auf einem separaten Gerät unter exklusiver
    Kontrolle des Anbieters liegt. Dieser Schlüssel signiert Transaktionen nur
    gemäß einer zuvor vom Nutzer festgelegten Policy, z.B. maximal _x_ BTC pro Tag.

  - Ein Nutzer-"Cold Key", der offline gespeichert ist und nur verwendet wird,
    falls der Hot Key verloren geht oder der Anbieter keine autorisierten
    Transaktionen mehr signiert.

  Obwohl diese Konfiguration die Sicherheit deutlich erhöht, wird bei der
  Einrichtung fast immer verlangt, dass der Nutzer dem Anbieter die [BIP32
  Extended Public Keys][topic bip32] seiner Hot- und Cold-Wallets mitteilt. So
  kann der Anbieter alle eingehenden Zahlungen und Ausgaben des Nutzers
  nachverfolgen, auch wenn der Nutzer ohne Anbieter agiert. Es wurden bereits
  mehrere Ansätze zur Verbesserung der Privatsphäre beschrieben, die aber entweder
  mit typischer Nutzung inkompatibel sind (z.B. separate Tapleaves) oder komplex
  (z.B. [MPC][]). Tan und Posner schlagen eine einfache Alternative vor:

  - Der Anbieter generiert die Hälfte eines BIP32-HD-Extended-Keys (nur den
    Schlüsselteil) und übergibt den öffentlichen Schlüssel an den Nutzer.

  - Der Nutzer generiert die andere Hälfte (die Chain Code) und behält diese
    privat.

  Beim Empfang von Zahlungen kann der Nutzer beide Hälften kombinieren, um einen
  Extended Public Key (xpub) zu erstellen und wie gewohnt Multisig-Adressen
  abzuleiten. Der Anbieter kennt den Chain Code nicht und kann daher weder den
  xpub ableiten noch die Adresse herausfinden.

  Beim Ausgeben kann der Nutzer aus dem Chain Code das nötige "Tweak" ableiten,
  das der Anbieter mit seinem privaten Schlüssel kombinieren muss, um eine
  gültige Signatur zu erzeugen. Der Nutzer teilt dem Anbieter einfach das Tweak
  mit. Der Anbieter erfährt daraus nur, dass es für die jeweilige
  scriptPubKey-Ausgabe gültig ist.

  Manche Anbieter verlangen, dass das Wechselgeld bei einer Transaktion wieder an
  das gleiche Skript-Template gesendet wird. Tans Beitrag beschreibt, wie dies
  einfach umgesetzt werden kann.

- **Forschungsergebnisse deuten darauf hin, dass Bitcoin-Grundfunktionen mit quantenresistenten Signaturalgorithmen kompatibel sind:**
  Jesse Posner [veröffentlichte][posner qc] auf Delving Bitcoin mehrere Links zu
  Forschungsarbeiten, die darauf hinweisen, dass [quantenresistente][topic quantum
  resistance] Signaturalgorithmen vergleichbare Grundfunktionen wie die aktuell in
  Bitcoin verwendeten bieten – etwa für [BIP32-HD-Wallets][topic bip32],
  [Silent Payment Adressen][topic silent payments], [scriptlose Multisignaturen][topic multisignature]
  und [scriptlose Threshold-Signaturen][topic threshold signature].

## Ausgewählte Fragen & Antworten von Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] ist eine der ersten Anlaufstellen für Optech-
Mitwirkende, wenn sie Antworten auf ihre Fragen suchen – oder wenn sie ein paar
Minuten Zeit haben, um neugierigen oder ratlosen Nutzern zu helfen. In diesem
monatlichen Abschnitt stellen wir einige der am höchsten bewerteten Fragen und
Antworten vor, die seit unserem letzten Update gepostet wurden.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Wie geht Bitcoin Core mit Reorgs von mehr als 10 Blöcken um?]({{bse}}127512)
  TheCharlatan verweist auf Bitcoin-Core-Code, der Chain-Reorganisationen so
  behandelt, dass maximal 10 Blöcke an Transaktionen wieder in den Mempool
  aufgenommen werden.

- [Vorteile eines Signiergeräts gegenüber einer verschlüsselten Festplatte?]({{bse}}127596)
  RedGrittyBrick hebt hervor, dass Daten auf einer verschlüsselten Festplatte
  extrahiert werden können, solange die Festplatte entschlüsselt ist, während
  Hardware-Signiergeräte genau solche Angriffe verhindern sollen.

- [Ausgabe eines Taproot-Outputs über Keypath und Scriptpath?]({{bse}}127601)
  Antoine Poinsot erklärt, wie Merkle-Bäume, Key-Tweaks und Leaf-Skripte
  Taproots Keypath- und Scriptpath-Ausgabefähigkeiten ermöglichen.

## Releases und Release-Kandidaten

_Neue Releases und Release-Kandidaten für beliebte Bitcoin-Infrastrukturprojekte.
Bitte erwägen Sie ein Upgrade auf neue Releases oder helfen Sie beim Testen von
Release-Kandidaten._

- [Libsecp256k1 v0.7.0][] ist ein Release dieser Bibliothek mit
  kryptografischen Grundfunktionen für Bitcoin. Es enthält einige kleine
  Änderungen, die nicht mit früheren Versionen kompatibel sind.

## Wichtige Code- und Dokumentationsänderungen

_Wichtige kürzliche Änderungen in [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning repo],
[Eclair][eclair repo], [LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo],
[Hardware Wallet Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay Server][btcpay server repo],
[BDK][bdk repo], [Bitcoin Improvement Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition repo] und [BINANAs][binana repo]._

- [Bitcoin Core #32521][] macht Legacy-Transaktionen mit mehr als 2.500
  Signaturoperationen (sigops) nicht-standardkonform, um einen möglichen
  [Consensus-Cleanup-Softfork][topic consensus cleanup] vorzubereiten, der das
  Limit auf Konsensebene durchsetzt. Ohne diese Änderung könnten Miner, die
  nicht aktualisieren, Ziel trivialer DoS-Angriffe werden. Weitere Details zum
  Legacy-Sigops-Limit finden sich im Newsletter [#340][news340 sigops].

- [Bitcoin Core #31829][] fügt dem Orphan-Transaktionshandler `TxOrphanage`
  (siehe Newsletter [#304][news304 orphan]) Ressourcenlimits hinzu, um die
  opportunistische One-Parent-One-Child-(1p1c)-[Package-Relay][topic package relay]
  gegen DoS-Spam-Angriffe zu schützen. Es gelten vier Limits: ein globales Limit
  von 3.000 Orphan-Ankündigungen (zur Minimierung von CPU- und Latenzkosten),
  ein proportionales Peer-Limit, eine Peer-Gewichtsreservierung von 24 × 400 kWU
  und ein variables globales Speicherlimit. Wird ein Limit überschritten, entfernt
  der Knoten die älteste Orphan-Ankündigung vom Peer mit dem höchsten DoS-Score.
  Die PR entfernt außerdem die Option `-maxorphantxs` (Standard: 100), deren
  zufällige Entfernung von Ankündigungen Angreifern erlaubte, das gesamte Orphan-
  Set zu ersetzen und das 1p1c-Relay nutzlos zu machen. Siehe auch Newsletter
  [#362][news362 orphan].

- [LDK #3801][] erweitert [attributable failures][topic attributable failures]
  auf erfolgreiche Zahlungen, indem aufgezeichnet wird, wie lange ein Knoten ein
  [HTLC][topic htlc] hält und diese Haltezeiten im Attribution-Payload nach oben
  weitergibt. Zuvor wurden Haltezeiten nur für fehlgeschlagene Zahlungen
  erfasst (siehe Newsletter [#349][news349 attributable]).

- [LDK #3842][] erweitert die [interaktive Transaktionskonstruktion][topic dual
  funding] (siehe Newsletter [#295][news295 dual]) um die Signaturkoordination
  für gemeinsame Inputs in [Splicing][topic splicing]-Transaktionen. Das Feld
  `prevtx` der `TxAddInput`-Nachricht ist nun optional, um Speicher zu sparen
  und die Validierung zu vereinfachen.

- [BIPs #1890][] ändert das Trennzeichen von `+` zu `-` in [BIP77][], da manche
  HTML-2.0-URI-Bibliotheken `+` als Leerzeichen interpretieren. Außerdem müssen
  Fragment-Parameter nun lexikografisch statt rückwärts sortiert werden, um das
  asynchrone [Payjoin][topic payjoin]-Protokoll zu vereinfachen.

- [BOLTs #1232][] macht das Feld `channel_type` (siehe Newsletter [#165][news165
  type]) beim Öffnen eines Channels verpflichtend, da jede Implementierung es
  erzwingt. Die PR aktualisiert außerdem [BOLT9][] und fügt einen neuen
  Kontexttyp `T` für Features hinzu, die im Feld `channel_type` enthalten sein
  können.

{% include snippets/recap-ad.md when="2025-07-29 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="32521,31829,3801,3842,1890,1232" %}
[morehouse gosvuln]: https://delvingbitcoin.org/t/disclosure-lnd-gossip-timestamp-filter-dos/1859
[tan ccw]: https://delvingbitcoin.org/t/chain-code-delegation-private-access-control-for-bitcoin-keys/1837
[mpc]: https://en.wikipedia.org/wiki/Secure_multi-party_computation
[posner qc]: https://delvingbitcoin.org/t/post-quantum-hd-wallets-silent-payments-key-aggregation-and-threshold-signatures/1854
[Libsecp256k1 v0.7.0]: https://github.com/bitcoin-core/secp256k1/releases/tag/v0.7.0
[news340 sigops]: /de/newsletters/2025/02/07/#einfuhrung-einer-legacy-eingabe-sigops-begrenzung
[news304 orphan]: /en/newsletters/2024/05/24/#bitcoin-core-30000
[1p1c relay]: /en/bitcoin-core-28-wallet-integration-guide/#one-parent-one-child-1p1c-relay
[news349 attributable]: /de/newsletters/2025/04/11/#ldk-2256
[news295 dual]: /en/newsletters/2024/03/27/#ldk-2419
[news165 type]: /en/newsletters/2021/09/08/#bolts-880
[news362 orphan]: /de/newsletters/2025/07/11/#bitcoin-core-pr-review-club
