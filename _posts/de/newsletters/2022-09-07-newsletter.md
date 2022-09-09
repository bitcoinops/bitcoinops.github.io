---
title: 'Bitcoin Optech Newsletter #216'
permalink: /de/newsletters/2022/09/07/
name: 2022-09-07-newsletter-de
slug: 2022-09-07-newsletter-de
type: newsletter
layout: newsletter
lang: de
---
Der Newsletter dieser Woche fasst einige erwähnenswerte Änderungen an beliebter
Bitcoin Infrastruktursoftware zusammen.

## News

*Diese Woche keine wesentlichen Neuigkeiten.*

## Nennenswerte Code- und Dokumentationsänderungen

*Erwähnenswerte Änderungen diese Woche in [Bitcoin Core][bitcoin core repo],
[Core Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], und [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #25717][] fügt einen "Headers Presync"-Schritt während des
  anfänglichen Block Downloads (IBD) hinzu, um Denial-of-Service (DoS) Angriffe
  zu verhindern, und macht einen Schritt in Richtung Entfernung von Checkpoints.
  Knoten verwenden die Pre-Sync-Phase, um zu überprüfen, ob die Header-Kette
  eines Peers genügend Arbeitsnachweise hat, bevor sie dauerhaft gespeichert
  wird.

  Während des IBD können böswillige Peers versuchen, den
  Synchronisierungsprozess hinzuhalten, Blöcke zu liefern, die nicht zur
  Kette mit den meisten Arbeitsnachweisen führen, oder einfach die Ressourcen
  des Knotens erschöpfen. Während die Synchronisierungsgeschwindigkeit und
  die Bandbreitennutzung während des IBD ein wichtiges Anliegen sind, ist ein
  primäres Designziel die Vermeidung von Denial-of-Service-Angriffen.
  Seit v0.10.0 synchronisieren Bitcoin Core Knoten zuerst die Block-Header,
  bevor sie die Blockdaten herunterladen und lehnen Header ab, die nicht mit
  einer Reihe von Checkpoints verbunden sind. Anstatt hart kodierte Werte zu
  verwenden, nutzt das neue Design die inhärente DoS-resistente Eigenschaft von
  Proof of Work (PoW) Puzzles, um die Menge des zugewiesenen Speichers zu
  minimieren bevor die Hauptkette gefunden wird.

  Mit diesen Änderungen laden die Knoten die Header bei der ersten
  Header-Synchronisation zweimal: in einem ersten Durchgang zur Überprüfung des
  PoW der Header (ohne sie zu speichern), bis die angesammelten Arbeitsnachweise
  einen Schwellenwert erreichen. Und dann in einem zweiten Durchgang, um sie zu
  speichern. Damit verhindert werden kann, dass ein Angreifer bei der
  Vorsynchronisierung die Hauptkette und während des erneute Herunterladens
  eine andere, bösartige Kette sendet, speichert der Knoten
  Verpflichtungen zur Kette des Headers während der Vorsynchronisierung.

- [Bitcoin Core #25355][] fügt Unterstützung für kurzlebige, einmalige I2P
  Adressen hinzu, wenn nur ausgehende [I2P Verbindungen][topic anonymity networks]
  erlaubt sind. In I2P erfährt der Empfänger die I2P Adresse des
  Verbindungsinitiators. Nicht-lauschende I2P Knoten verwenden nun standardmäßig
  transiente I2P Adressen, wenn sie ausgehende Verbindungen herstellen.

- [BDK #689][] fügt eine `allow_dust`-Methode hinzu, die es einem Wallet erlaubt
  eine Transaktion zu erstellen, die das [Dust-Limit][topic uneconomical
  outputs] verletzt. Bitcoin Core und andere Knoten, welche die gleichen
  Einstellungen verwenden, leiten unbestätigte Transaktionen nicht weiter, es
  sei denn, jeder Output (außer `OP_RETURN`) erhält mehr Satoshis als das
  Dust-Limit. BDK hindert normalerweise Benutzer daran, solche unbestätigte
  Transaktionen zu erzeugen, indem es das Dust-Limit für die von ihm erstellten
  Transaktionen erzwingt. Die neue Option erlaubt es, diese Policy zu
  ignorieren. Der Autor des PRs erwähnt dass sie diese Option zum Testen
  ihrer Wallet verwenden.

- [BDK #682][] fügt Signiermöglichkeiten für Hardware-Signiergeräte hinzu,
  welche das [HWI][topic hwi] und die [rust-hwi][rust-hwi github]-Bibliothek
  verwenden. Der PR führt auch einen Ledger Geräteemulator fürs Testen ein.

{% include references.md %}
{% include linkers/issues.md v=2 issues="25717,25355,689,682" %}
[rust-hwi github]: https://github.com/bitcoindevkit/rust-hwi
