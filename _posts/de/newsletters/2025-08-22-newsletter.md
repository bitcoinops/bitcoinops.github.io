---
title: 'Bitcoin Optech Newsletter #368'
permalink: /de/newsletters/2025/08/22/
name: 2025-08-22-newsletter-de
slug: 2025-08-22-newsletter-de
type: newsletter
layout: newsletter
lang: de
---

Der Newsletter dieser Woche fasst einen BIP-Entwurf zum Austausch von Block-Templates
zwischen Full Nodes zusammen und stellt eine Bibliothek vor, die eine vertrauenswürdige
Delegation der Skriptauswertung ermöglicht (auch für Funktionen, die in Bitcoins
nativen Skriptsprachen nicht verfügbar sind). Außerdem enthalten sind unsere
regelmäßigen Abschnitte mit aktuellen Updates zu Services und Client-Software,
Ankündigungen neuer Releases und Release-Kandidaten sowie einer Zusammenfassung
Änderungen an wichtiger Bitcoin-Infrastruktur-Software.


## Nachrichten

- **BIP-Entwurf zum Teilen von Block-Templates:** Anthony Towns
  [veröffentlichte][towns bipshare] in der Bitcoin-Dev-Mailingliste den
  [Entwurf][towns bipdraft] eines BIPs, wie Knoten ihren Peers die
  Transaktionen mitteilen können, die sie im nächsten Block schürfen
  würden (Mining) (siehe [Newsletter #366][news366 templshare]). Dadurch kann
  ein Knoten Transaktionen teilen, die er laut Mempool- und Mining-
  Policy akzeptiert, die seine Peers aber normalerweise ablehnen
  würden. Diese Peers können die Transaktionen für den Fall cachen,
  dass sie gemint werden (was die Effizienz des
  [Compact Block Relay][topic compact block relay] verbessert).
  Die Transaktionen im Block-Template eines Knotens sind meist
  die profitabelsten unbestätigten Transaktionen, sodass Peers,
  die sie zuvor aus Policy-Gründen abgelehnt haben, sie erneut
  bewerten können.

  Das im Entwurf spezifizierte Protokoll ist einfach: kurz nach
  Verbindungsaufbau sendet der Knoten eine `sendtemplate`-Nachricht,
  um die Bereitschaft zum Senden von Block-Templates zu signalisieren.
  Später kann der Peer mit einer `gettemplate`-Nachricht ein Template
  anfordern. Der Knoten antwortet mit einer `template`-Nachricht, die
  eine Liste von kurzen Transaktions-IDs im [BIP152][]-Format enthält.
  Der Peer kann dann gewünschte Transaktionen per `sendtransactions`-
  Nachricht anfordern (ebenfalls wie in BIP152). Der Entwurf erlaubt
  Templates, die bis etwas mehr als doppelt so groß sind wie das aktuelle
  Blockgewichtslimit.

  In einem Delving-Bitcoin-[Thread][delshare] gab es weitere
  Diskussionen zur Verbesserung der Bandbreiteneffizienz. Vorgeschlagen
  wurden: nur die [Differenz][towns templdiff] zum vorherigen Template
  zu senden (ca. 90% Ersparnis), ein [Set-Reconciliation][jahr templerlay]
  -Protokoll wie [minisketch][topic minisketch] (ermöglicht
  effizientes Teilen großer Templates) und Golomb-Rice
  [Kodierung][wuille templgr] ähnlich wie bei
  [Compact Block Filters][topic compact block filters] (ca. 25% Ersparnis).

- **Vertrauenswürdige Delegation der Skriptauswertung:** Josh Doman
  [stellte][doman tee] in Delving Bitcoin eine Bibliothek vor, die ein
  _Trusted Execution Environment_ ([TEE][]) nutzt. Dieses signiert
  einen [Taproot][topic taproot]-Keypath-Spend nur, wenn die
  Transaktion ein Skript erfüllt. Das Skript kann Opcodes enthalten,
  die aktuell in Bitcoin nicht aktiv sind, oder eine ganz andere
  Skriptsprache (z. B. [Simplicity][topic simplicity] oder [bll][topic
  bll]).

  Empfänger von Geldern müssen dem TEE vertrauen – sowohl dass es
  zukünftig verfügbar bleibt, als auch dass es nur dann signiert, wenn
  das Skript erfüllt ist. Dies ermöglicht schnelle Experimente mit
  neuen Bitcoin-Features mit echtem Wert. Um das Vertrauen ins TEE zu
  reduzieren, kann ein Backup-Spend-Pfad eingebaut werden, z. B. ein
  [timelocked][topic timelocks] Pfad, der nach einem Jahr eine
  einseitige Ausgabe erlaubt.

  Die Bibliothek ist für die Nutzung mit Amazon Web Services (AWS)
  Nitro Enclave konzipiert.


## Änderungen bei Services und Client-Software

*In dieser monatlichen Rubrik stellen wir interessante Updates zu Bitcoin-
Wallets und Services vor.*

- **ZEUS v0.11.3 veröffentlicht:**
  Das [v0.11.3][zeus v0.11.3] Release bringt Verbesserungen beim Peer-Management,
  bei [BOLT12][topic offers] und den [Submarine Swap][topic submarine swaps]-Funktionen.

- **Rust-Utreexo-Ressourcen:**
  Abdelhamid Bakhta [veröffentlichte][abdel tweet] Rust-basierte Ressourcen für
  [Utreexo][topic utreexo], darunter interaktive [Lernmaterialien][rustreexo webapp]
  und [WASM-Bindings][rustreexo wasm].

- **Peer-Observer-Tooling und Aufruf zur Mitarbeit:**
  0xB10C [stellte][b10c blog] Motivation, Architektur, Code, unterstützende
  Bibliotheken und Erkenntnisse seines [Peer-Observer][peer-observer github]-Projekts vor.
  Ziel ist eine lose, dezentrale Gruppe von Menschen, die das Bitcoin-Netzwerk
  überwachen und gemeinsam Ideen, Daten, Tools und Erkenntnisse teilen.

- **Bitcoin Core Kernel-basierter Knoten angekündigt:**
  Bitcoin Backbone wurde [angekündigt][bitcoin backbone] als Demonstration für
  die Nutzung der [Bitcoin Core Kernel][kernel blog]-Bibliothek als Basis eines Bitcoin-Nodes.

- **SimplicityHL veröffentlicht:**
  [SimplicityHL][simplcityhl github] ist eine Rust-ähnliche Programmiersprache,
  die in die Low-Level-[Simplicity][simplicity]-Sprache [kürzlich aktiviert][simplicity post]
  auf Liquid kompiliert. Weitere Infos im [Delving-Thread][simplicityhl delving].

- **LSP-Plugin für BTCPay Server:**
  Das [LSP-Plugin][lsp btcpay github] implementiert Client-Funktionen von
  [BLIP51][], der Spezifikation für eingehende Kanäle, in BTCPay Server.

- **Proto Mining-Hardware und -Software angekündigt:**
  Proto [stellte][proto blog] neue Bitcoin-Mining-Hardware und Open-Source-
  Mining-Software vor, entwickelt mit vorherigem [Community-Feedback][news260 mdk].

- **Oracle-Resolution-Demo mit CSFS:**
  Abdelhamid Bakhta [zeigte][abdel tweet2] eine Oracle-Demo mit
  [CSFS][topic op_checksigfromstack], nostr und MutinyNet zur Signierung
  einer Ereignisbestätigung.

- **Relai unterstützt Taproot:**
  Relai hat die Unterstützung für das Senden an [Taproot][topic taproot]-Adressen hinzugefügt.


## Releases und Release-Kandidaten

_Neue Releases und Release-Kandidaten für beliebte Bitcoin-Infrastrukturprojekte.
Bitte erwägen Sie, auf neue Versionen zu aktualisieren oder bei der Testung von
Release-Kandidaten zu helfen._

- [LND v0.19.3-beta][] ist ein Release für eine Wartungsversion dieser beliebten
  LN-Knoten-Implementierung, das "wichtige Bugfixes" enthält. Besonders
  erwähnenswert ist "eine optionale Migration [...], die Festplatten- und
  Speicheranforderungen für Knoten erheblich senkt."

- [Bitcoin Core 29.1rc1][] ist ein Release-Kandidat für eine Wartungsversion der
  führenden Full-Node-Software.

- [Core Lightning v25.09rc2][] ist ein Release-Kandidat für eine neue Hauptversion
  dieser beliebten LN-Knoten-Implementierung.


## Wichtige Code- und Dokumentationsänderungen

_Wichtige aktuelle Änderungen in [Bitcoin Core][bitcoin core repo],
[Core Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet Interface (HWI)][hwi repo],
[Rust Bitcoin][rust bitcoin repo], [BTCPay Server][btcpay server repo], [BDK][bdk repo],
[BIPs][bips repo], [BOLTs][bolts repo], [BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition repo]
und [BINANAs][binana repo]._

- [Bitcoin Core #32896][] ermöglicht das Erstellen und Ausgeben unbestätigter
  Topologically Restricted Until Confirmation ([TRUC][topic v3 transaction relay])-Transaktionen
  durch Hinzufügen eines `version`-Parameters zu den folgenden RPCs:
  `createrawtransaction`, `createpsbt`, `send`, `sendall` und `walletcreatefundedpsbt`.
  Die Wallet erzwingt die TRUC-Beschränkungen für Gewichtslimit, Konflikte mit
  Geschwister-Transaktionen und die Unvereinbarkeit zwischen unbestätigten TRUC-
  und Nicht-TRUC-Transaktionen.

- [Bitcoin Core #33106][] senkt die Standardwerte für `blockmintxfee` auf 1 sat/kvB (Minimum)
  sowie für [`minrelaytxfee`][topic default minimum transaction relay feerates] und
  `incrementalrelayfee` auf 100 sat/kvB (0,1 sat/vB). Diese Werte sind konfigurierbar,
  Nutzer sollten `minrelaytxfee` und `incrementalrelayfee` gemeinsam anpassen.
  Andere Mindest-Feerates bleiben unverändert, aber die Standardwerte für Wallet-Feerates
  werden voraussichtlich in einer zukünftigen Version gesenkt. Gründe für die Änderung sind
  das starke Wachstum von Blöcken mit Transaktionen unter 1 sat/vB, die Anzahl der Pools,
  die solche Transaktionen minen, und der gestiegene Bitcoin-Kurs.

- [Core Lightning #8467][] erweitert `xpay` (siehe [Newsletter #330][news330 xpay])
  um die Unterstützung für Zahlungen an [BIP353][] Human Readable Names (HRN)
  (z. B. satoshi@bitcoin.com) und ermöglicht direkte Zahlungen an
  [BOLT12 offers][topic offers], ohne vorher den Befehl `fetchinvoice` ausführen zu müssen.
  Intern holt sich `xpay` die Zahlungsanweisungen über den RPC-Befehl `fetchbip353`
  aus dem `cln-bip353`-Plugin, das in [Core Lightning #8362][] eingeführt wurde.

- [Core Lightning #8354][] beginnt mit der Veröffentlichung von
  `pay_part_start`- und `pay_part_end`-Event-Benachrichtigungen zum Status
  einzelner Zahlungsteile, die mit [MPP][topic multipath payments] gesendet wurden.
  Die `pay_part_end`-Benachrichtigung zeigt die Dauer der Zahlung und ob sie
  erfolgreich war oder fehlgeschlagen ist. Bei Fehlschlag wird eine Fehlermeldung
  und, falls der Error-Onion nicht beschädigt ist, zusätzliche Information zur
  Ursache und zum Fehlercode bereitgestellt.

- [Eclair #3103][] führt Unterstützung für [Simple Taproot Channels][topic simple taproot channels]
  ein und nutzt [MuSig2][topic musig] scriptless [Multisignature][topic multisignature]-Signaturen,
  um das Transaktionsgewicht um 15% zu reduzieren und die Privatsphäre zu verbessern.
  Funding-Transaktionen und kooperative Schließungen sind von anderen [P2TR][topic taproot]-Transaktionen
  nicht zu unterscheiden. Dieser PR enthält auch Unterstützung für [Dual Funding][topic dual funding]
  und [Splicing][topic splicing] in Simple Taproot Channels und ermöglicht
  [Channel Commitment Upgrades][topic channel commitment upgrades] auf das neue Taproot-Format
  während einer Splice-Transaktion.

- [Eclair #3134][] ersetzt den Strafgewicht-Multiplikator für hängende [HTLCs][topic htlc]
  durch das [CLTV expiry delta][topic cltv expiry delta] bei der Bewertung der
  [HTLC endorsement][topic htlc endorsement]-Peer-Reputation (siehe [Newsletter #363][news363 reputation]),
  um besser abzubilden, wie lange ein hängender HTLC Liquidität bindet. Um die übermäßige Strafe
  für HTLCs mit maximalem CLTV expiry delta zu mildern, werden die Reputation-Decay-Parameter
  (`half-life`) von 15 auf 30 Tage und der Schwellenwert für hängende Zahlungen
  (`max-relay-duration`) von 12 Sekunden auf 5 Minuten angepasst.

- [LDK #3897][] erweitert die [Peer Storage][topic peer storage]-Implementierung,
  indem verlorener Channel-State beim Wiederherstellen von Backups erkannt wird:
  Die Kopie des Peers wird deserialisiert und mit dem lokalen Zustand verglichen.

{% include snippets/recap-ad.md when="2025-08-26 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="32896,33106,8467,8354,3103,3134,3897,8362" %}
[bitcoin core 29.1rc1]: https://bitcoincore.org/bin/bitcoin-core-29.1/
[lnd v0.19.3-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.19.3-beta
[core lightning v25.09rc2]: https://github.com/ElementsProject/lightning/releases/tag/v25.09rc2
[towns bipshare]: https://mailing-list.bitcoindevs.xyz/bitcoindev/aJvZwR_bPeT4LaH6@erisian.com.au/
[towns bipdraft]: https://github.com/ajtowns/bips/blob/202508-sendtemplate/bip-ajtowns-sendtemplate.md
[news366 templshare]: /de/newsletters/2025/08/08/#peer-block-template-sharing-zur-milderung-von-mempool-richtlinien-problemen
[delshare]: https://delvingbitcoin.org/t/sharing-block-templates/1906/13
[towns templdiff]: https://delvingbitcoin.org/t/sharing-block-templates/1906/7
[jahr templerlay]: https://delvingbitcoin.org/t/sharing-block-templates/1906/6
[wuille templgr]: https://delvingbitcoin.org/t/sharing-block-templates/1906/9
[doman tee]: https://delvingbitcoin.org/t/confidential-script-emulate-soft-forks-using-stateless-tees/1918/
[tee]: https://en.wikipedia.org/wiki/Trusted_execution_environment
[news330 xpay]: /en/newsletters/2024/11/22/#core-lightning-7799
[news363 reputation]: /de/newsletters/2025/07/18/#eclair-2716
[zeus v0.11.3]: https://github.com/ZeusLN/zeus/releases/tag/v0.11.3
[abdel tweet]: https://x.com/dimahledba/status/1951213485104181669
[rustreexo webapp]: https://rustreexo-playground.starkwarebitcoin.dev/
[rustreexo wasm]: https://github.com/AbdelStark/rustreexo-wasm
[b10c blog]: https://b10c.me/projects/024-peer-observer/
[peer-observer github]: https://github.com/0xB10C/peer-observer
[bitcoin backbone]: https://mailing-list.bitcoindevs.xyz/bitcoindev/9812cde0-7bbb-41a6-8e3b-8a5d446c1b3cn@googlegroups.com
[kernel blog]: https://thecharlatan.ch/Kernel/
[simplcityhl github]: https://github.com/BlockstreamResearch/SimplicityHL
[simplicity]: https://blockstream.com/simplicity.pdf
[simplicityhl delving]: https://delvingbitcoin.org/t/writing-simplicity-programs-with-simplicityhl/1900
[simplicity post]: https://blog.blockstream.com/simplicity-launches-on-liquid-mainnet/
[lsp btcpay github]: https://github.com/MegalithicBTC/BTCPayserver-LSPS1
[proto blog]: https://proto.xyz/blog/posts/proto-rig-and-proto-fleet-a-paradigm-shift
[news260 mdk]: /en/newsletters/2023/07/19/#mining-development-kit-call-for-feedback
[abdel tweet2]: https://x.com/dimahledba/status/1946223544234659877
