---
title: 'Bitcoin Optech Newsletter #342'
permalink: /de/newsletters/2025/02/21/
name: 2025-02-21-newsletter-de
slug: 2025-02-21-newsletter-de
type: newsletter
layout: newsletter
lang: de
---
In diesem Wochen-Newsletter wird eine Idee für die Möglichkeit vorgestellt,
mobile Wallets zu ermöglichen, Lightning-Kanäle abzuwickeln, ohne zusätzliche
ungenutzte UTXOs zu benötigen. Außerdem wird die
fortlaufende Diskussion über die Einführung eines Qualitätsflags für die
Pfadfindung in Lightning-Netzwerken zusammengefasst. Ebenfalls enthalten
sind unsere regelmäßigen Abschnitte, in denen wir über aktuelle Änderungen
an Clients, Diensten und beliebter Bitcoin-Infrastruktur-Software berichten.

## News

- **Ermöglichen von mobile Wallets, Kanäle abzuwickeln ohne zusätzliche UTXOs:**
  Bastien Teinturier [veröffentlichte][teinturier mobileclose] auf Delving Bitcoin
  eine opt-in-Variante von [v3-Verpflichtungen][topic v3 commitments]
  für LN-Kanäle, die es mobile Wallets ermöglichen würde, Kanäle abzuwickeln,
  indem sie die Mittel innerhalb des Kanals für alle Fälle verwenden, in denen
  Diebstahl möglich ist. Sie müssten nicht mehr eine on-chain-UTXO in
  Reserve halten, um Schließgebühren zu bezahlen.

  Teinturier beginnt damit, die vier Fälle zu skizzieren, in denen ein mobiles
  Wallet eine Transaktion übertragen muss:

  1. Der Peer sendet eine widerrufene v3-Verpflichtungstransaktion, z.B.
     versucht der Peer, Geld zu stehlen. In diesem Fall erhält das mobile
     Wallet sofort die Möglichkeit, alle Mittel des Kanals auszugeben,
     und kann diese Mittel verwenden, um Gebühren zu bezahlen.

  2. Das mobile Wallet hat eine Zahlung gesendet, die noch nicht abgeschlossen
     wurde. In diesem Fall ist Diebstahl unmöglich, da der entfernte Peer die
     Zahlung nur dann beanspruchen kann, wenn er die [HTLC][topic htlc]-Präimage
     (d.h. den Beweis, dass der endgültige Empfänger bezahlt wurde) liefert.
     Da Diebstahl nicht möglich ist, kann das mobile Wallet Zeit nehmen,
     um eine UTXO zu finden, um Schließgebühren zu bezahlen.

  3. Es gibt keine ausstehenden Zahlungen, aber der entfernte Peer antwortet
     nicht. Auch hier ist Diebstahl nicht möglich, so dass das mobile Wallet
     Zeit nehmen kann, um den Kanal zu schließen.

  4. Das mobile Wallet erhält eine HTLC. In diesem Fall kann der entfernte
     Peer die HTLC-Präimage akzeptieren (und damit Geld von seinen
     Upstream-Peers beanspruchen), aber nicht den abgewickelten Kanalsaldo
     aktualisieren und die HTLC widerrufen. In diesem Fall muss das mobile
     Wallet den Kanal zwangsweise innerhalb einer relativ kleinen Anzahl
     von Blöcken schließen.


  Teinturier schlägt vor, dass der entfernte Peer zwei verschiedene Versionen
  jeder HTLC unterzeichnet, die das mobile Wallet bezahlen: eine Version ohne
  Gebühren gemäß der Standardrichtlinie für Verpflichtungen ohne Gebühren und
  eine Version mit Gebühren zu einem Satz, der derzeit schnell bestätigt wird.
  Die Gebühren werden vom HTLC-Wert abgezogen, der an das mobile Wallet gezahlt
  wird, so dass es dem entfernten Peer nichts kostet, diese Option anzubieten,
  und das mobile Wallet hat einen Anreiz, sie nur zu verwenden, wenn es wirklich
  notwendig ist. Teinturier [weist darauf hin][teinturier mobileclose2], dass
  es einige Sicherheitsaspekte für den entfernten Peer gibt, der zu viele
  Gebühren zahlt, aber er geht davon aus, dass diese leicht zu beheben sind.

- **Weiterführende Diskussion über ein LN-Qualitätsflag:** Joost Jager
  [postete][jager lnqos] auf Delving Bitcoin, um die Diskussion über die
  Einführung eines Qualitätsflags (QoS) für das LN-Protokoll fortzusetzen,
  das es ermöglicht, dass Knoten signalisieren, dass einer ihrer Kanäle sehr
  zuverlässig ist - d.h. in der Lage ist, Zahlungen bis zu einem bestimmten
  Betrag mit 100% Zuverlässigkeit weiterzuleiten (siehe [Newsletter #239][news239 qos]).
  Wenn ein Sender einen sehr zuverlässigen Kanal wählt und die Zahlung an
  diesem Kanal fehlschlägt, wird der Sender den Betreiber bestrafen, indem
  er diesen Kanal nie wieder verwendet. Seit der vorherigen Diskussion hat
  Jager vorgeschlagen, ein Knoten-Levels-Signal zu verwenden (vielleicht durch
  einfaches Anhängen von "HA" an den Text-Alias des Knotens), bemerkt, dass die
  aktuellen Fehlermeldungen des Protokolls nicht garantieren, dass der Kanal,
  an dem die Zahlung fehlgeschlagen ist, erkannt wird, und vorgeschlagen,
  dass dies nicht etwas ist, das sowohl signalisiert als auch auf einer
  vollständig opt-in-Basis verwendet werden kann - also ohne weit verbreitete
  Zustimmung - also sollte es für die Kompatibilität spezifiziert werden,
  auch wenn nur sehr wenige Ausgabeknoten und Weiterleitungs-Knoten es
  letztendlich verwenden.

  Matt Corallo [antwortete][corallo lnqos], dass die LN-Pfadfindung derzeit
  gut funktioniert und auf ein [detailliertes Dokument][ldk path] verwies,
  das den Ansatz von LDK zur Pfadfindung beschreibt, der den Ansatz erweitert,
  der ursprünglich von René Pickhardt und Stefan Richter beschrieben wurde
  (siehe [Newsletter #163][news163 pr paper] und [zwei Punkte][news270 ldk2547]
  in [Newsletter #270][news270 ldk2534]). Allerdings ist er besorgt, dass ein
  QoS-Flag zukünftige Software dazu ermutigen wird, weniger zuverlässige
  Pfadfindung zu implementieren und einfach nur HA-Kanäle zu bevorzugen.
  In diesem Fall können große Knoten Vereinbarungen mit ihren großen Peers
  abschließen, um vorübergehend Liquidität auf Basis von Vertrauen zu verwenden,
  wenn ein Kanal erschöpft ist, aber kleinere Knoten, die von trustlosen
  Kanälen abhängig sind, müssen teure [JIT-Neubilanzierung][topic jit routing]
  verwenden, die ihre Kanäle weniger profitabel macht (wenn sie die Kosten absorbieren)
  oder weniger attraktiv (wenn sie die Kosten an Ausgeber weitergeben).

  Jager und Corallo setzten die Diskussion fort, ohne zu einer klaren
  Lösung zu gelangen.

## Änderungen an Diensten und Client-Software

*In dieser monatlichen Rubrik stellen wir interessante Updates zu
Bitcoin-Wallets und -Diensten vor.*

- **Ark Wallet SDK veröffentlicht:**
  Die [Ark Wallet SDK][ark sdk github] ist eine TypeScript-Bibliothek
  für den Bau von Wallets, die sowohl On-Chain-Bitcoin als auch das
  [Ark][topic ark]-Protokoll auf [Testnet][topic testnet],
  [Signet][topic signet], [Mutinynet][new252 mutinynet]
  und Mainnet (derzeit nicht empfohlen) unterstützen.

- **Zaprite fügt BTCPay Server-Unterstützung hinzu:**
  Der Bitcoin- und Lightning-Zahlungs-Integrator [Zaprite][zaprite website]
  fügt BTCPay Server zu seiner Liste der unterstützten Wallet-Verbindungen hinzu.

- **Iris Wallet Desktop veröffentlicht:**
  Der [Iris Wallet][iris github] unterstützt das Senden, Empfangen und Ausstellen
  von Assets unter Verwendung des [RGB][topic client-side validation] Protokolls.

- **Sparrow 2.1.0 veröffentlicht:**
  Die Sparrow [2.1.0-Veröffentlichung][sparrow 2.1.0] ersetzt die vorherige
  [HWI][topic hwi]-Implementierung durch [Lark][news333 lark] und fügt Unterstützung
  für [PSBTv2][topic psbt] hinzu, sowie weitere Updates.

- **Scure-btc-signer 1.6.0 veröffentlicht:**
  Die [Scure-btc-signer][scure-btc-signer github]-Version
  [1.6.0][scure-btc-signer 1.6.0] fügt Unterstützung für Version 3
  ([TRUC][topic v3 transaction relay])-Transaktionen und
  [Pay-to-Anchors (P2A)][topic ephemeral anchors] hinzu. Scure-btc-signer
  ist Teil der [scure][scure website]-Bibliothekssammlung.

- **Py-bitcoinkernel Alpha:**
  [Py-bitcoinkernel][py-bitcoinkernel github] stellt eine Python-Bibliothek dar,
  die für die Interaktion mit [libbitcoinkernel][Bitcoin Core #27587] konzipiert wurde.
  Letztere ist eine Bibliothek, die spezifische Regeln der [Validierungslogik von Bitcoin
  Core kapselt][kernel blog].

- **Rust-bitcoinkernel-Bibliothek:**
  [Rust-bitcoinkernel][rust-bitcoinkernel github] ist eine experimentelle
  Rust-Bibliothek zum Verwenden von libbitcoinkernel, um Blockdaten zu lesen
  und Transaktionsausgaben und Blöcke zu validieren.

- **BIP32 cbip32-Bibliothek:**
  Die [cbip32-Bibliothek][cbip32 library] implementiert [BIP32][]
  in C mit Hilfe von libsecp256k1 und libsodium.

- **Lightning Loop wechselt zu MuSig2:**
  Der Swap-Service von Lightning Loop verwendet jetzt [MuSig2][topic musig],
  wie in einem [jüngsten Blog-Beitrag][loop blog] beschrieben.

## Wichtige Code- und Dokumentationsänderungen

_Wichtige jüngste Änderungen in [Bitcoin Core][bitcoin core repo],
[Core Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet Interface (HWI)][hwi repo],
[Rust Bitcoin][rust bitcoin repo], [BTCPay Server][btcpay server repo],
[BDK][bdk repo], [Bitcoin-Verbesserungsvorschläge (BIPs)][bips repo],
[Lightning-BOLTs][bolts repo], [Lightning-BLIPs][blips repo],
[Bitcoin Inquisition][bitcoin inquisition repo] und [BINANAs][binana repo]._

- [Bitcoin Core #27432][] führt ein Python-Skript ein, das den kompakten
  serialisierten UTXO-Satz, der von dem `dumptxoutset`-RPC-Befehl generiert wird
  (der speziell für [AssumeUTXO][topic assumeutxo]-Snapshots konzipiert ist),
  in eine SQLite3-Datenbank umwandelt. Obwohl eine Erweiterung des `dumptxoutset`-RPC-Befehls
  selbst, um eine SQLite3-Datenbank als Ausgabe zu liefern, in Betracht gezogen wurde,
  wurde sie letztendlich aufgrund der erhöhten Wartungsbelastung abgelehnt. Das Skript
  benötigt keine zusätzlichen Abhängigkeiten und die resultierende Datenbank ist etwa
  doppelt so groß wie der kompakten serialisierte UTXO-Satz.

- [Bitcoin Core #30529][] behebt die Handhabung von negierten Optionen wie `noseednode`,
  `nobind`, `nowhitebind`, `norpcbind`, `norpcallowip`, `norpcwhitelist`, `notest`,
  `noasmap`, `norpcwallet`, `noonlynet`, und `noexternalip`, so dass sie wie erwartet
  funktionieren. Zuvor verursachte die Negierung dieser Optionen verwirrende und nicht
  dokumentierte Nebeneffekte, aber jetzt löscht sie einfach die angegebenen Einstellungen,
  um das Standardverhalten wiederherzustellen.

- [Bitcoin Core #31384][] löst ein Problem, bei dem die 4.000 Gewichtseinheiten
  (WU), die für den Blockheader, die Transaktionsanzahl und die Coinbase-Transaktion
  reserviert sind, unbeabsichtigt doppelt angewendet wurden, was die maximale Block-Template-Größe
  um unnötige 4.000 WU auf 3.992.000 WU reduzierte (siehe Newsletter [#336][news336 weightbug]).
  Diese Korrektur konsolidiert das reservierte Gewicht in einer einzigen Instanz und führt eine
  neue Startoption `-blockreservedweight` ein, die es den Benutzern ermöglicht, das reservierte
  Gewicht anzupassen. Sicherheitsprüfungen werden hinzugefügt, um sicherzustellen, dass das
  reservierte Gewicht auf einen Wert zwischen 2.000 WU und 4.000.000 WU gesetzt ist,
  andernfalls startet Bitcoin Core nicht.

- [Core Lightning #8059][] implementiert die Unterdrückung von
  [Multipath-Zahlungen][topic multipath payments] (MPP) im `xpay`-Plugin (siehe Newsletter
  [#330][news330 xpay]), wenn eine [BOLT11][]-Rechnung bezahlt wird, die diese Funktion nicht
  unterstützt. Die gleiche Logik wird auf [BOLT12][topic offers]-Rechnungen ausgeweitet, muss
  jedoch bis zum nächsten Release warten, da dieser PR auch die Werbung von BOLT12-Funktionen
  an Plugins ermöglicht, um explizit BOLT12-Rechnungen mit MPP zu ermöglichen.

- [Core Lightning #7985][] fügt Unterstützung für die Bezahlung von [BOLT12][topic offers]
  -Rechnungen im `renepay`-Plugin (siehe Newsletter [#263][news263 renepay]) hinzu, indem
  die Routing durch [verblindete Pfade][topic rv routing] ermöglicht und die interne
  Verwendung des `sendpay`-RPC-Befehls durch `sendonion` ersetzt wird.

- [Core Lightning #7887][] fügt Unterstützung für die Verarbeitung der neuen [BIP353][]
  -Felder für die Auflösung von Human-Readable-Names (HRN) hinzu, um den neuesten
  BOLTs-Updates zu entsprechen (siehe Newsletter [#290][news290 hrn] und [#333][news333 hrn]).
  Der PR fügt auch das `invreq_bip_353_name`-Feld zu Rechnungen hinzu, erzwingt Einschränkungen
  für eingehende BIP353-Namefelder und ermöglicht Benutzern, BIP353-Namen auf dem
  `fetchinvoice`-RPC anzugeben, sowie Wortänderungen.

- [Eclair #2967][] fügt Unterstützung für das `option_simple_close`-Protokoll hinzu,
  wie in [BOLTs #1205][] spezifiziert. Diese vereinfachte Variante des Mutual-
  Close-Protokolls ist eine Voraussetzung für [einfache Taproot-Kanäle][topic simple taproot channels],
  da sie es ermöglicht, dass Knoten während der Phasen `shutdown`, `closing_complete`
  und `closing_sig` sicher Nonces austauschen, was erforderlich ist,
  um einen [MuSig2][topic musig]-Kanalausgang auszugeben.

- [Eclair #2979][] fügt einen Überprüfungsschritt hinzu, um zu bestätigen, dass ein
  Knoten Wake-Up-Benachrichtigungen unterstützt (siehe Newsletter [#319][news319 wakeup]),
  bevor der Wake-Up-Fluss zum Weiterleiten einer [Trampolin-Zahlung][topic trampoline payments]
  initiiert wird. Für Standard-Kanalzahlungen ist diese Überprüfung nicht erforderlich, da die
  [BOLT11][]- oder [BOLT12][topic offers]-Rechnung bereits die Unterstützung für
  Wake-Up-Benachrichtigungen anzeigt.

- [Eclair #3002][] führt einen sekundären Mechanismus ein, um Blöcke und ihre bestätigten
  Transaktionen zu verarbeiten und Watches auszulösen, um die Sicherheit zu erhöhen.
  Dies ist besonders nützlich, wenn ein Kanal ausgegeben wird, aber die Ausgabetransaktion
  nicht im Mempool erkannt wurde. Obwohl das ZMQ-`rawtx`-Thema dies handhabt, kann es unzuverlässig
  sein und Ereignisse stillschweigend verwerfen, wenn Remote-`bitcoind`-Instanzen verwendet werden.
  Wenn ein neuer Block gefunden wird, holt das sekundäre System die letzten N Blöcke (6 standardmäßig)
  und verarbeitet ihre Transaktionen erneut.

- [LDK #3575][] implementiert das [Peer-Speicher-Protokoll][topic peer storage]
  als eine Funktion, die es ermöglicht, dass Knoten Backups für Kanal-Peers verteilen
  und speichern. Es führt zwei neue Nachrichtentypen ein, `PeerStorageMessage` und
  `PeerStorageRetrievalMessage`, zusammen mit ihren jeweiligen Handlern, um den Austausch
  dieser Backups zwischen Knoten zu ermöglichen. Peer-Daten werden innerhalb von
  `PeerState` im `ChannelManager` persistent gespeichert.

- [LDK #3562][] führt einen neuen Scorer (siehe Newsletter [#308][news308 scorer]) ein,
  der Bewertungsbenchmark-Werte auf der Grundlage von häufigen [Sondierungen][topic payment probes]
  von tatsächlichen Zahlungspfaden aus einer externen Quelle kombiniert. Dies ermöglicht es
  Lichtknoten, die typischerweise eine begrenzte Sicht auf das Netzwerk haben, die Erfolgsraten
  von Zahlungen durch die Einbeziehung externer Daten wie Bewertungen, die von einem
  Lightning-Service-Provider (LSP) bereitgestellt werden, zu verbessern. Der externe
  Bewertungswert kann entweder mit dem lokalen Bewertungswert kombiniert oder diesen überschreiben.

- [BOLTs #1205][] integriert das `option_simple_close`-Protokoll, das eine vereinfachte
  Variante des Mutual-Close-Protokolls ist, das für [einfache Taproot-Kanäle][topic simple taproot channels]
  erforderlich ist. Änderungen werden an [BOLT2][] und [BOLT3][] vorgenommen.

{% include snippets/recap-ad.md when="2025-02-25 17:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="27432,30529,31384,8059,7985,7887,2967,2979,3002,3575,3562,1205,27587" %}
[news239 qos]: /en/newsletters/2023/02/22/#ln-quality-of-service-flag
[news163 pr paper]: /en/newsletters/2021/08/25/#zero-base-fee-ln-discussion
[news270 ldk2547]: /en/newsletters/2023/09/27/#ldk-2547
[news270 ldk2534]: /en/newsletters/2023/09/27/#ldk-2534
[teinturier mobileclose]: https://delvingbitcoin.org/t/zero-fee-commitments-for-mobile-wallets/1453
[teinturier mobileclose2]: https://delvingbitcoin.org/t/zero-fee-commitments-for-mobile-wallets/1453/3
[jager lnqos]: https://delvingbitcoin.org/t/highly-available-lightning-channels-revisited-route-or-out/1438
[corallo lnqos]: https://delvingbitcoin.org/t/highly-available-lightning-channels-revisited-route-or-out/1438/4
[ldk path]: https://lightningdevkit.org/blog/ldk-pathfinding/
[news330 xpay]: /en/newsletters/2024/11/22/#core-lightning-7799
[news263 renepay]: /en/newsletters/2023/08/09/#core-lightning-6376
[news290 hrn]: /en/newsletters/2024/02/21/#dns-based-human-readable-bitcoin-payment-instructions
[news333 hrn]: /en/newsletters/2024/12/13/#bolts-1180
[news319 wakeup]: /en/newsletters/2024/09/06/#eclair-2865
[news308 scorer]: /en/newsletters/2024/06/21/#ldk-3103
[news336 weightbug]: /de/newsletters/2025/01/10#untersuchung-des-verhaltens-von-mining-pools-vor-der-behebung-eines-bitcoin-core-fehlers
[ark sdk github]: https://github.com/arklabshq/wallet-sdk
[new252 mutinynet]: /en/newsletters/2023/05/24/#mutinynet-announces-new-signet-for-testing
[zaprite website]: https://zaprite.com
[iris github]: https://github.com/RGB-Tools/iris-wallet-desktop
[sparrow 2.1.0]: https://github.com/sparrowwallet/sparrow/releases/tag/2.1.0
[news333 lark]: /en/newsletters/2024/12/13/#java-based-hwi-released
[scure-btc-signer github]: https://github.com/paulmillr/scure-btc-signer
[scure-btc-signer 1.6.0]: https://github.com/paulmillr/scure-btc-signer/releases
[scure website]: https://paulmillr.com/noble/#scure
[py-bitcoinkernel github]: https://github.com/stickies-v/py-bitcoinkernel
[rust-bitcoinkernel github]: https://github.com/TheCharlatan/rust-bitcoinkernel
[kernel blog]: https://thecharlatan.ch/Kernel/
[cbip32 library]: https://github.com/jamesob/cbip32
[loop blog]: https://lightning.engineering/posts/2025-02-13-loop-musig2/

