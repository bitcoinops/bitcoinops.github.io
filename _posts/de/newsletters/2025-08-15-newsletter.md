---
title: 'Bitcoin Optech Newsletter #367'
permalink: /de/newsletters/2025/08/15/
name: 2025-08-15-newsletter-de
slug: 2025-08-15-newsletter-de
type: newsletter
layout: newsletter
lang: de
---
Der Newsletter dieser Woche enthält unsere üblichen Abschnitte zur
Ankündigung neuer Release-Kandidaten und zur Zusammenfassung wichtiger
Änderungen an populärer Bitcoin-Infrastruktur-Software.

## Nachrichten

_In unseren [Quellen][optech sources] wurden diese Woche keine nennenswerten
Neuigkeiten gefunden._

## Releases und Release-Kandidaten

_Neue Releases und Release-Kandidaten für beliebte Bitcoin-Infrastrukturprojekte.
Bitte erwägen Sie, auf neue Versionen zu aktualisieren oder beim Testen von
Release-Kandidaten zu helfen._

- [LND v0.19.3-beta.rc1][] ist ein Release-Kandidat für eine Wartungsversion
  dieser beliebten LN-Knoten-Implementierung, der "wichtige Bugfixes" enthält.
  Besonders erwähnenswert ist "eine optionale Migration [...], die Festplatten-
  und Speicheranforderungen für Knoten erheblich senkt."

- [Bitcoin Core 29.1rc1][] ist ein Release-Kandidat für eine Wartungsversion der
  führenden Full-Node-Software.

## Bedeutende Code- und Dokumentationsänderungen

_Bedeutende aktuelle Änderungen in [Bitcoin Core][bitcoin core repo],
[Core Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet Interface (HWI)][hwi repo],
[Rust Bitcoin][rust bitcoin repo], [BTCPay Server][btcpay server repo],
[BDK][bdk repo], [BIPs][bips repo], [BOLTs][bolts repo],
[BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition repo] und
[BINANAs][binana repo]._

- [Bitcoin Core #33050][] entfernt das Peer-Discouragement (siehe [Newsletter
  #309][news309 peer]) für konsensus-invalide Transaktionen, da der
  zugehörige DoS-Schutz unwirksam war. Ein Angreifer konnte den Schutz durch
  Spam mit policy-invaliden Transaktionen umgehen. Dadurch, dass nicht mehr zwischen dem Scheitern an Konsensregeln und Mempool-Richtlinien unterschieden wird, macht das Update doppelte
  Script-Validierung überflüssig und spart CPU-Ressourcen.

- [Bitcoin Core #32473][] führt einen pro-Input-Cache zur Vorausberechnung von
  Sighash-Werten im Script-Interpreter für Legacy- (z. B. baremultisig), P2SH,
  P2WSH (und implizit P2WPKH)-Inputs ein, um die Auswirkungen quadratischer
  Hashing-Angriffe auf Standard-Transaktionen zu reduzieren. Core cached
  nahezu fertige Hashes kurz vor dem Anhängen des Sighash-Bytes, sodass
  wiederholte Hash-Berechnungen für Standard-Multisig-Transaktionen größtenteils
  vermieden werden. Die Änderung ist in Policy (Mempool) und Consensus (Block)
  aktiviert. [Taproot][topic taproot]-Inputs zeigen dieses Verhalten bereits
  standardmäßig.

- [Bitcoin Core #33077][] erzeugt eine monolithische statische Bibliothek
  `libbitcoinkernel.a`, die alle Objektdateien privater Abhängigkeiten in einem
  Archiv bündelt, sodass Downstream-Projekte nur noch gegen diese einzelne
  Datei linken müssen. Siehe [Newsletter #360][news360 kernel] für zugehörige
  `libsecp256k1`-Vorarbeiten.

- [Core Lightning #8389][] macht das Feld `channel_type` beim Öffnen eines
  Channels verpflichtend, in Einklang mit einer aktuellen Spezifikations-
  änderung (siehe [Newsletter #364][news364 spec]). Die RPC-Kommandos
  `fundchannel` und `fundchannel_start` melden nun den Channel-Typ inkl. der
  Option für [zero-conf channels][topic zero-conf channels], wenn ein
  Mindest-Depth von 0 dies impliziert.

{% include snippets/recap-ad.md when="2025-08-19 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="33050,32473,33077,8389" %}
[bitcoin core 29.1rc1]: https://bitcoincore.org/bin/bitcoin-core-29.1/
[lnd v0.19.3-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.19.3-beta.rc1
[news309 peer]: /en/newsletters/2024/06/28/#bitcoin-core-29575
[news360 kernel]: /de/newsletters/2025/06/27/#libsecp256k1-1678
[libbitcoinkernel project]: https://github.com/bitcoin/bitcoin/issues/27587
[news364 spec]: /de/newsletters/2025/07/25/#bolts-1232
