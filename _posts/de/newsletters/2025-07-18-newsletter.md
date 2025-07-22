---
title: 'Bitcoin Optech Newsletter #363'
permalink: /de/newsletters/2025/07/18/
name: 2025-07-18-newsletter-de
slug: 2025-07-18-newsletter-de
type: newsletter
layout: newsletter
lang: de
---
Der Newsletter dieser Woche enthält wie gewohnt unsere regelmäßigen Abschnitte mit Zusammenfassungen
zu Updates bei Diensten und Client-Software, der Ankündigung neuer Releases und Release-Kandidaten
sowie einer Übersicht wichtiger Änderungen an beliebter Bitcoin-Infrastruktur-Software.

## Nachrichten

_In dieser Woche wurden in unseren [Quellen][] keine besonderen Nachrichten gefunden._

## Änderungen an Diensten und Client-Software

*In diesem monatlichen Abschnitt stellen wir interessante Neuerungen bei Bitcoin-Wallets und
-Diensten vor.*

- **Floresta v0.8.0 veröffentlicht:**
  Das [Floresta v0.8.0][floresta v0.8.0] Release dieses [Utreexo][topic utreexo] Knotens unterstützt nun [Version 2 P2P-Transport (BIP324)][topic v2 p2p transport],
  [testnet4][topic testnet], erweiterte Metriken und Monitoring sowie weitere Funktionen und Fehlerbehebungen.

- **RGB v0.12 angekündigt:**
  Der [Blogpost zu RGB v0.12][rgb blog] kündigt die Veröffentlichung der Konsensschicht für RGBs [clientseitig validierte][topic client-side validation] Smart Contracts
  auf Bitcoin-Testnet und Mainnet an.

- **FROST-Signiergerät verfügbar:**
  [Frostsnap][frostsnap website] Signiergeräte unterstützen k-aus-n [Threshold-Signaturen][topic threshold signature] mit dem FROST-Protokoll, wobei nur eine einzige
  Signatur on-chain erscheint.

- **Gemini unterstützt Taproot:**
  Gemini Exchange und Gemini Custody unterstützen nun das Senden (Abheben) an [Taproot][topic taproot] Adressen.

- **Electrum 4.6.0 veröffentlicht:**
  [Electrum 4.6.0][electrum 4.6.0] bietet jetzt Unterstützung für [Submarine Swaps][topic submarine swaps] mit nostr zur Auffindbarkeit.

## Releases und Release-Kandidaten

_Neue Releases und Release-Kandidaten für beliebte Bitcoin-Infrastrukturprojekte. Bitte erwägen Sie ein Upgrade auf neue Releases oder helfen Sie beim Testen von
Release-Kandidaten._

- [LND v0.19.2-beta][] ist das Release einer Wartungsversion dieses beliebten LN-Knotens. Es "enthält wichtige Fehlerbehebungen und
  Leistungsverbesserungen."

## Wichtige Code- und Dokumentationsänderungen

_Wichtige kürzliche Änderungen in [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo], [LND][lnd repo],
[libsecp256k1][libsecp256k1 repo], [Hardware Wallet Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay Server][btcpay server repo], [BDK][bdk repo],
[Bitcoin Improvement Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo], [Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition repo] und
[BINANAs][binana repo]._

- [Bitcoin Core #32604][] begrenzt das bedingungslose Schreiben von Logs auf die Festplatte, z.B. für `LogPrintf`, `LogInfo`, `LogWarning` und `LogError`, um Angriffe zu verhindern, bei denen die Festplatte gefüllt wird. Jeder Ursprungsort erhält ein Kontingent von 1 MB pro Stunde. Alle Logzeilen werden mit einem Stern (*) versehen, wenn ein Ursprungsort unterdrückt wird. Konsolenausgaben, Logs mit explizitem Kategorie-Argument und `UpdateTip`-Meldungen beim Initial Block Download (IBD) sind von der Begrenzung ausgenommen. Wenn das Kontingent zurückgesetzt wird, gibt Core die Anzahl der verworfenen Bytes aus.

- [Bitcoin Core #32618][] entfernt die Option `include_watchonly` und ihre Varianten sowie das Feld `iswatchonly` aus allen Wallet-RPCs, da [Deskriptor][topic descriptors]-Wallets keine Mischung aus Watch-only- und ausgebbaren Deskriptoren unterstützen. Zuvor konnten Nutzer eine Watch-only-Adresse oder ein Skript in eine Legacy-Wallet importieren. Legacy-Wallets wurden nun entfernt.

- [Bitcoin Core #31553][] fügt dem [Cluster-Mempool][topic cluster mempool] Projekt eine Behandlung von Block-Reorgs hinzu, indem die Funktion
  `TxGraph::Trim()` eingeführt wird. Wenn durch eine Blockchain-Neuordnung (Reorg) bereits bestätigte Transaktionen wieder in den Mempool
  gelangen und dadurch die erlaubte Anzahl oder das Gewicht eines Transaktions-Clusters überschritten wird, sortiert die Funktion `Trim()` die
  Transaktionen nach Gebühr und Abhängigkeiten. Sie entfernt dann alle Transaktionen (und deren Nachfolger), die das Limit überschreiten.

- [Core Lightning #7725][] fügt einen leichtgewichtigen JavaScript-Logviewer hinzu, der CLN-Logdateien im Browser lädt und es Nutzern ermöglicht, Nachrichten nach Daemon, Typ, Channel oder Regex zu filtern. Dieses Tool erhöht den Wartungsaufwand des Repos nur minimal und verbessert das Debugging für Entwickler und Knoten-Betreiber.

- [Eclair #2716][] implementiert ein lokales Peer-Reputationssystem für [HTLC-Endorsements][topic htlc endorsement], das die durch jeden eingehenden Peer verdienten Routing-Gebühren im Vergleich zu den Gebühren verfolgt, die basierend auf Liquidität und [HTLC][topic htlc]-Slots hätten verdient werden sollen. Erfolgreiche Zahlungen führen zu einer perfekten Bewertung, fehlgeschlagene Zahlungen senken sie, und HTLCs, die nach Ablauf der konfigurierten Schwelle noch ausstehen, werden stark bestraft. Beim Weiterleiten gibt der Knoten seine aktuelle Peer-Bewertung im `update_add_htlc` Endorsement-TLV an (siehe Newsletter [#315][news315 htlc]). Betreiber können den Reputationsverfall (`half-life`), die Schwelle für festsitzende Zahlungen (`max-relay-duration`), das Strafgewicht für festsitzende HTLCs (`pending-multiplier`) anpassen oder das System komplett deaktivieren. Dieser PR sammelt primär Daten zur Verbesserung der Forschung zu [Channel Jamming Attacks][topic channel jamming attacks] und implementiert noch keine Strafen.

- [LDK #3628][] implementiert die Serverlogik für [asynchrone Zahlungen][topic async payments], sodass ein LSP-Knoten [BOLT12][topic offers] statische Rechnungen im Namen eines Empfängers bereitstellen kann, der häufig offline ist. Der LSP-Knoten kann `ServeStaticInvoice`-Nachrichten vom Empfänger annehmen, die bereitgestellten Rechnungen speichern und auf Zahlungsanfragen des Zahlers reagieren, indem er die gespeicherte Rechnung über [Blinded Paths][topic rv routing] zurückgibt.

- [LDK #3890][] ändert die Bewertung von Routen im Pfadfindungsalgorithmus, indem die Gesamtkosten durch das Kanalbetragslimit (Kosten pro nutzbarem Sat) geteilt werden, anstatt nur die Gesamtkosten zu betrachten. Dies bevorzugt Routen mit höherer Kapazität und reduziert übermäßiges [MPP][topic multipath payments] Sharding, was zu einer höheren Erfolgsquote bei Zahlungen führt. Obwohl die Änderung kleine Kanäle übermäßig benachteiligt, ist dieser Kompromiss besser als das bisherige starke Sharding.

- [LND #10001][] aktiviert das Quieszenz-Protokoll in der Produktion (siehe Newsletter [#332][news332 quiescence]) und fügt einen neuen Konfigurationswert `--htlcswitch.quiescencetimeout` hinzu, der die maximale Dauer angibt, für die ein Channel quieszent sein kann. Der Wert stellt sicher, dass abhängige Protokolle wie [dynamische Commitments][topic channel commitment upgrades] innerhalb des Zeitlimits abgeschlossen werden. Der Standardwert beträgt 60 Sekunden, das Minimum 30 Sekunden.

{% include snippets/recap-ad.md when="2025-07-22 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="32604,32618,31553,7725,2716,3628,3890,10001" %}
[LND v0.19.2-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.19.2-beta
[Quellen]: /en/internal/sources/
[floresta v0.8.0]: https://github.com/vinteumorg/Floresta/releases/tag/v0.8.0
[rgb blog]: https://rgb.tech/blog/release-v0-12-consensus/
[frostsnap website]: https://frostsnap.com/
[electrum 4.6.0]: https://github.com/spesmilo/electrum/releases/tag/4.6.0
[news315 htlc]: /en/newsletters/2024/08/09/#eclair-2884
[news332 quiescence]: /en/newsletters/2024/12/06/#lnd-8270
