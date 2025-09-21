---
title: 'Bitcoin Optech Newsletter #372'
permalink: /de/newsletters/2025/09/19/
name: 2025-09-19-newsletter-de
slug: 2025-09-19-newsletter-de
type: newsletter
layout: newsletter
lang: de
---
Der Newsletter dieser Woche fasst einen Vorschlag zur Verbesserung redundanter LN-Überzahlungen zusammen und verlinkt zu einer Diskussion über potenzielle
Partitionierungsangriffe gegen Full Nodes. Außerdem enthalten sind unsere regelmäßigen Abschnitte, die aktuelle Änderungen an Diensten und Client-Software
beschreiben, neue Releases und Release-Kandidaten ankündigen und bemerkenswerte Änderungen an beliebter Bitcoin-Infrastruktursoftware zusammenfassen.

## Nachrichten

- **LSP-finanzierte redundante Überzahlungen:** Entwickler ZmnSCPxj [veröffentlichte][zmnscpxj lspstuck] auf Delving Bitcoin einen Vorschlag, LSPs die
  zusätzliche Finanzierung (Liquidität) bereitstellen zu lassen, die für [redundante Überzahlungen][topic redundant overpayments] erforderlich ist. In den
  ursprünglichen Vorschlägen für redundante Überzahlungen zahlt Alice an Zed, indem sie mehrere Zahlungen über mehrere Routen sendet, wobei nur Zed eine der
  Zahlungen beanspruchen kann; die restlichen Zahlungen werden an Alice zurückerstattet. Der Vorteil dieses Ansatzes ist, dass die ersten Zahlungsversuche
  Zed erreichen können, während andere Versuche noch durch das Netzwerk reisen, was die Geschwindigkeit von Zahlungen im LN erhöht.

  Nachteile dieses Ansatzes sind, dass Alice zusätzliches Kapital (Liquidität) für die redundanten Zahlungen haben muss, Alice online bleiben muss, bis die
  redundante Überzahlung abgeschlossen ist, und jede festsitzende Zahlung verhindert, dass Alice dieses Geld ausgeben kann, bis der Zahlungsversuch abläuft
  (bis zu zwei Wochen bei häufig verwendeten Einstellungen).

  ZmnSCPxjs Vorschlag ermöglicht es Alice, nur den tatsächlichen Zahlungsbetrag (plus Gebühren) zu zahlen, während ihre Lightning Service Provider (LSPs) die
  Liquidität für das Senden der redundanten Zahlungen bereitstellen, wodurch der Geschwindigkeitsvorteil redundanter Überzahlungen erreicht wird, ohne dass
  sie zusätzliche Liquidität kurzzeitig oder bis zum Timeout benötigt. Die LSPs können auch die Zahlung abschließen, während Alice offline ist, sodass die
  Zahlung auch bei schlechter Verbindung von Alice abgeschlossen werden kann.

  Nachteile des neuen Vorschlags sind, dass Alice etwas Privatsphäre gegenüber ihren LSPs verliert und dass der Vorschlag mehrere Änderungen am
  LN-Protokoll zusätzlich zur Unterstützung redundanter Überzahlungen erfordert.

- **Partitionierungs- und Eclipse-Angriffe durch BGP-Abfangen:** Entwickler cedarctic [schrieb][cedarctic bgp] auf Delving Bitcoin über die Nutzung
  von Schwächen im Border Gateway Protocol (BGP), um Full Nodes daran zu hindern, sich mit Peers zu verbinden, was zur Partitionierung des Netzwerks oder
  zur Ausführung von [Eclipse-Angriffen][topic eclipse attacks] verwendet werden kann. Mehrere Gegenmaßnahmen wurden von cedarctic beschrieben, wobei
  andere Entwickler in der Diskussion weitere Gegenmaßnahmen und Wege zur Überwachung der Angriffserkennung beschrieben.

## Änderungen an Diensten und Client-Software

*In diesem monatlichen Feature heben wir interessante Updates zu Bitcoin-Wallets und -Diensten hervor.*

- **Zero-Knowledge-Proof-of-Reserve-Tool:** [Zkpoor][zkpoor github] generiert [Proof of Reserves][topic proof of reserves] mit STARK-Beweisen, ohne die
  Adressen oder UTXOs des Besitzers preiszugeben.

- **Alternative Submarine-Swap-Protokoll-Proof-of-Concept:** Der [Papa Swap][papa swap github] Protokoll-Proof-of-Concept erreicht
  [Submarine-Swap][topic submarine swaps]-Funktionalität, indem er eine Transaktion anstatt zwei erfordert.

## Releases und Release-Kandidaten

_Neue Releases und Release-Kandidaten für beliebte Bitcoin-Infrastrukturprojekte. Bitte erwägen Sie ein Upgrade auf neue Releases oder helfen Sie beim
Testen von Release-Kandidaten._

- [Bitcoin Core 30.0rc1][] ist ein Release-Kandidat für die nächste Hauptversion dieser Full Verification Node Software.

- [BDK Chain 0.23.2][] ist ein Release dieser Bibliothek zum Erstellen von Wallet-Anwendungen, das Verbesserungen beim Umgang mit Transaktionskonflikten
  einführt, die `FilterIter`-API neu gestaltet, um [BIP158][]-Filterfähigkeiten zu verbessern, und das Anchor- und Block-Reorg-Management verbessert.

## Wichtige Code- und Dokumentationsänderungen

_Wichtige aktuelle Änderungen in [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition repo], and [BINANAs][binana repo]._

- [Bitcoin Core #33268][] ändert, wie Transaktionen als Teil einer Benutzer-Wallet erkannt werden, indem die Anforderung entfernt wird, dass der Gesamtbetrag der Inputs einer Transaktion null Sats übersteigt. Solange eine Transaktion mindestens einen Output einer Wallet ausgibt, wird sie als Teil dieser Wallet erkannt. Dies ermöglicht es, Transaktionen mit null-wertigen Inputs, wie das Ausgeben eines [P2A ephemeral Anchor][topic ephemeral anchors], in der Transaktionsliste eines Benutzers zu erscheinen.

- [Eclair #3157][] aktualisiert die Art, wie es Remote-Commitment-Transaktionen bei Wiederverbindung signiert und sendet. Anstatt das zuvor signierte
  Commitment erneut zu senden, signiert es mit den neuesten Nonces aus `channel_reestablish` neu. Peers, die keine deterministischen Nonces in
  [Simple Taproot Channels][topic simple taproot channels] verwenden, haben bei Wiederverbindung eine neue Nonce, wodurch die vorherige
  Commitment-Signatur ungültig wird.

- [LND #9975][] fügt [P2TR][topic taproot] Fallback-On-Chain-Adress-Unterstützung zu [BOLT11][]-Rechnungen hinzu, entsprechend dem in
  [BOLTs #1276][] hinzugefügten Test-Vektor. BOLT11-Rechnungen haben ein optionales `f`-Feld, das es Benutzern ermöglicht, eine Fallback-On-Chain-Adresse
  einzuschließen, falls eine Zahlung nicht über das LN abgeschlossen werden kann.

- [LND #9677][] fügt die Felder `ConfirmationsUntilActive` und `ConfirmationHeight` zur `PendingChannel`-Response-Message hinzu, die vom
  `PendingChannels`-RPC-Befehl zurückgegeben wird. Diese Felder informieren Benutzer über die Anzahl der Bestätigungen, die für die Channel-Aktivierung
  erforderlich sind, und die Blockhöhe, bei der die Finanzierungstransaktion bestätigt wurde.

- [LDK #4045][] implementiert den Empfang einer [Async Payment][topic async payments] durch einen LSP-Knoten, indem er ein eingehendes
  [HTLC][topic htlc] im Namen eines oft-offline Empfängers akzeptiert, es hält und später bei Signalisierung an den Empfänger weitergibt. Dieser PR
  führt ein experimentelles `HtlcHold`-Feature-Bit ein, fügt ein neues `hold_htlc`-Flag zu `UpdateAddHtlc` hinzu und definiert den Freigabepfad.

- [LDK #4049][] implementiert die Weiterleitung von [BOLT12][topic offers]-Rechnungsanfragen von einem LSP-Knoten an einen online Empfänger, der dann
  mit einer neuen Rechnung antwortet. Wenn der Empfänger offline ist, kann der LSP-Knoten mit einer Fallback-Rechnung antworten, wie durch die
  serverseitige Logik-Implementierung für [Async Payments][topic async payments] ermöglicht (siehe [Newsletter #363][news363 async]).

- [BDK #1582][] refaktoriert die Typen `CheckPoint`, `LocalChain`, `ChangeSet` und `spk_client`, um generisch zu sein und eine `T`-Payload zu
  akzeptieren, anstatt auf Block-Hashes fixiert zu sein. Dies bereitet `bdk_electrum` darauf vor, vollständige Block-Header in Checkpoints zu speichern,
  was Header-Redownloads vermeidet und gecachte Merkle-Beweise sowie Median Time Past (MTP) ermöglicht.

- [BDK #2000][] fügt Block-Reorg-Behandlung zu einer refaktorierten `FilterIter`-Struktur hinzu (siehe [Newsletter #339][news339 filters]). Anstatt
  ihren Ablauf über mehrere Methoden zu verteilen, verknüpft dieser PR alles mit der `next()`-Funktion und vermeidet so Timing-Risiken. Ein Checkpoint
  wird bei jeder Blockhöhe ausgegeben, um sicherzustellen, dass der Block nicht veraltet ist und das BDK auf der gültigen Chain ist. `FilterIter`
  scannt alle Blöcke und holt diejenigen, die Transaktionen enthalten, die für eine Liste von Script-Pubkeys relevant sind, unter Verwendung von
  [Compact Block Filters][topic compact block filters] wie in [BIP158][] spezifiziert.

- [BDK #2028][] fügt ein `last_evicted`-Timestamp-Feld zur `TxNode`-Struktur hinzu, um anzuzeigen, wann eine Transaktion aus dem Mempool
  ausgeschlossen wurde, nachdem sie durch [RBF][topic rbf] ersetzt wurde. Dieser PR entfernt auch die `TxGraph::get_last_evicted`-Methode (siehe
  [Newsletter #346][news346 evicted]), da das neue Feld sie ersetzt.

{% include snippets/recap-ad.md when="2025-09-23 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="33268,3157,9975,1276,9677,4045,4049,1582,2000,2028" %}
[bitcoin core 30.0rc1]: https://bitcoincore.org/bin/bitcoin-core-30.0/
[zkpoor github]: https://github.com/AbdelStark/zkpoor
[papa swap github]: https://github.com/supertestnet/papa-swap
[news363 async]: /de/newsletters/2025/07/18/#ldk-3628
[news339 filters]: /de/newsletters/2025/01/31/#bdk-1614
[news346 evicted]: /de/newsletters/2025/03/21/#bdk-1839
[BDK Chain 0.23.2]: https://github.com/bitcoindevkit/bdk/releases/tag/chain-0.23.2
[zmnscpxj lspstuck]: https://delvingbitcoin.org/t/multichannel-and-multiptlc-towards-a-global-high-availability-cp-database-for-bitcoin-payments/1983/
[cedarctic bgp]: https://delvingbitcoin.org/t/eclipsing-bitcoin-nodes-with-bgp-interception-attacks/1965/
