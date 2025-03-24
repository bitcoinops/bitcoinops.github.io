---
title: 'Bitcoin Optech Newsletter #346'
permalink: /de/newsletters/2025/03/21/
name: 2025-03-21-newsletter-de
slug: 2025-03-21-newsletter-de
type: newsletter
layout: newsletter
lang: de
---
Diese Woche fasst der Newsletter eine Diskussion über das aktualisierte
dynamische Feerate-Anpassungssystem von LND zusammen. Außerdem stellen wir
wieder unsere regelmäßigen Rubriken vor, in denen wir kürzlich erfolgte
Änderungen an Diensten und Client-Software beschreiben, neue Releases
und Release-Kandidaten ankündigen und wichtige Merges in populäre
Bitcoin-Infrastruktursoftware zusammenfassen.

## News

- **Diskussion zum dynamischen Feerate-Anpassungssystem in LND:** Matt
  Morehouse [postete][morehouse sweep] im Delving-Bitcoin-Forum eine
  Beschreibung des kürzlich neu geschriebenen _sweeper_-Systems in LND,
  das die Feerates für Onchain-Transaktionen (einschließlich
  [RBF][topic rbf]-Fee-Bumps) festlegt. Zu Beginn erläutert er die
  sicherheitskritischen Aspekte des Feemanagements in einem LN-Knoten
  und beschreibt das natürliche Bestreben, Gebühren zu vermeiden.
  Anschließend stellt er zwei generelle Strategien vor, die
  LND verwendet:

  - Anfragen an externe Feerate-Schätzungen, z.B. an einen lokalen
    Bitcoin-Core-Knoten oder einen Drittanbieter. Das wird hauptsächlich
    verwendet, um anfängliche Feerates festzulegen und nicht-zeitkritische
    Transaktionen zu beschleunigen.

  - Exponentielles Fee-Bumping, sobald sich ein bestimmter Zeitdruck
    abzeichnet, um zu gewährleisten, dass Probleme mit dem lokalen Mempool
    oder der [Fee-Schätzung][topic fee estimation] nicht zu einer Verzögerung
    führen. Beispielsweise verwendet Eclair exponentielles Fee-Bumping, wenn
    die Deadline bei sechs Blöcken liegt.

  Im Anschluss beschreibt Morehouse, wie diese beiden Strategien im neuen
  Sweeper-System kombiniert werden: „[HTLC][topic htlc]-Auszahlungen mit
  ähnlichen Deadlines werden in einer einzigen
  [Batch-Transaktion][topic payment batching] zusammengefasst. Das Budget
  für die Batch-Transaktion wird als Summe der Budgets der einzelnen HTLCs
  berechnet. Auf Basis von Budget und Deadline wird
  dann eine Gebührenfunktion ermittelt, die steuert, wie viel des Budgets
  bis zum Erreichen der Deadline verbraucht wird. Standardmäßig wird eine
  lineare Gebührenfunktion genutzt, die auf einem niedrigen Gebührensatz
  (bestimmt durch das Minimum-Relay-Gebührenniveau oder einen externen
  Schätzer) startet und bei nur noch einem Block Restzeit das gesamte
  Budget für die Gebühr einsetzt.“

  Außerdem beschreibt er, wie die neue Logik effektiv gegen
  [Replacement Cycling][topic replacement cycling]-Angriffe schützt und
  kommt zu dem Schluss: „Mit den Standardparametern von LND muss ein
  Angreifer mindestens das 20-fache des HTLC-Werts aufwenden, um
  erfolgreich einen Replacement Cycling-Angriff durchzuführen.“ Er fügt
  hinzu, dass das neue System auch den Schutz von LND gegen
  [Pinning-Angriffe][topic transaction pinning] verbessert.

  Abschließend verlinkt er auf mehrere „LND-spezifische Fehler- und
  Verwundbarkeitsbehebungen“, die dank der überarbeiteten Logik den Schutz
  weiter erhöhen. Abubakar Sadiq Ismail [antwortete][ismail sweep] mit
  Vorschlägen, wie alle LN-Implementierungen (und andere Software)
  Bitcoin Cores Fee-Schätzung noch effektiver integrieren können. Auch
  weitere Entwickler kommentierten, fügten der Beschreibung einige Details
  hinzu.

## Änderungen an Diensten und Client-Software

*In diesem monatlichen Abschnitt stellen wir interessante Aktualisierungen
bei Bitcoin-Wallets und -Diensten vor.*

- **Wally 1.4.0 veröffentlicht:**
  Die [libwally-core 1.4.0 Version][wally 1.4.0] fügt Unterstützung für
  [Taproot][topic taproot] hinzu, erlaubt das Ableiten von
  [BIP85][]-RSA-Schlüsseln und bietet erweiterte
  [PSBT][topic psbt]- und [Descriptor][topic descriptors]-Funktionen.

- **Bitcoin Core Config Generator angekündigt:**
  Das Projekt [Bitcoin Core Config Generator][bccg github] ist eine
  Terminal-Anwendung zum Erstellen von `bitcoin.conf`-Konfigurationsdateien
  für Bitcoin Core.

- **Regtest Entwicklungsumgebung im Container:**
  Das Repository [regtest-in-a-pod][riap github] stellt einen
  [Podman][podman website]-Container bereit, der mit Bitcoin Core,
  Electrum und Esplora eingerichtet ist, wie im Blog-Beitrag
  [Using Podman Containers for Regtest Bitcoin Development][podman bitcoin blog]
  beschrieben.

- **Explora Transaktions-Visualisierungstool:**
  [Explora][explora github] ist ein webbasiertes Tool zum Anzeigen und
  Navigieren von Transaktionsinputs und -outputs.

- **Hashpool v0.1 getaggt:**
  [Hashpool][hashpool github] ist ein auf dem
  [Stratum v2 Reference-Implementation][news247 sri] basierender
  [Mining-Pool][topic pooled mining], bei dem Mining-Shares als
  [ecash][topic ecash]-Token repräsentiert werden (siehe
  [Podcast #337][pod337 hashpool]).

- **DMND startet Pool-Mining:**
  [DMND][dmnd website] führt Stratum v2 Pool-Mining ein und baut damit auf
  der früheren [Ankündigung][news281 demand] von Solo-Mining auf.

- **Krux fügt Taproot und Miniscript hinzu:**
  [Krux][news273 krux] integriert [Miniscript][topic miniscript] und Taproot
  mithilfe der [embit][embit website]-Bibliothek.

- **Quelloffene Secure Element-Lösung angekündigt:**
  Das [TROPIC01][tropic01 website] ist ein Secure Element, das auf RISC-V
  basiert und mit einer [offenen Architektur][tropicsquare github]
  für Auditierbarkeit entwickelt wurde.

- **Nunchuk startet Group Wallet:**
  [Group Wallet][nunchuk blog] bietet [Multisignature][topic multisignature]-Signaturen,
  Taproot, Coin-Control, [Musig2][topic musig] sowie eine
  gesicherte Kommunikation zwischen den Teilnehmern durch die
  Wiederverwendung von Output-Deskriptoren in der [BIP129][] Bitcoin Secure
  Multisig Setup (BSMS)-Datei.

- **FROSTR-Protokoll angekündigt:**
  [FROSTR][frostr github] verwendet das FROST
  [Threshold Signature][topic threshold signature]-Verfahren für k-of-n
  Signaturen und Schlüsselverwaltung in nostr.

- **Bark auf Signet gestartet:**
  Die [Bark][new325 bark]-Implementierung von [Ark][topic ark] ist
  nun [verfügbar][second blog] auf [Signet][topic signet], mit einem
  Faucet und einem Demo-Shop zu Testzwecken.

- **Cove Bitcoin Wallet angekündigt:**
  [Cove Wallet][cove wallet github] ist eine quelloffene Bitcoin-Mobile-Wallet
  auf Basis von BDK, die Technologien wie PSBTs, [Wallet-Labels][topic wallet labels],
  Hardware-Signaturen und mehr unterstützt.

## Releases und Release-Kandidaten

_Neue Veröffentlichungen und Release-Kandidaten populärer
Bitcoin-Infrastrukturprojekte. Bitte erwägen Sie ein Upgrade oder helfen
Sie beim Testen neuer Versionen._

- [Bitcoin Core 29.0rc2][] ist ein Release-Kandidat für die nächste
  Hauptversion des am weitesten verbreiteten Full-Nodes im Netzwerk.

## Wichtige Änderungen an Code und Dokumentation

_Bedeutende jüngste Änderungen in [Bitcoin Core][bitcoin core repo],
[Core Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo],
[BTCPay Server][btcpay server repo], [BDK][bdk repo],
[Bitcoin Improvement Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition repo]
und [BINANAs][binana repo]._

- [Bitcoin Core #31649][] entfernt alle Checkpoint-Logik, die nach der
  Einführung des Headers-Presync-Verfahrens schon seit einigen Jahren
  nicht mehr nötig ist (siehe Newsletter [#216][news216 presync]). Durch
  den Vergleich der gesamten Proof-of-Work (PoW) mit dem vordefinierten
  Schwellenwert `nMinimumChainWork` kann ein Node während des Initial
  Block Download (IBD) feststellen, ob eine Header-Kette gültig ist.
  Nur Ketten, deren gesamte PoW diesen Wert übertrifft, werden
  gespeichert. Dadurch wird effektiv verhindert, dass das Node massenhaft
  nutzlose Header laden muss. Diese Änderung macht Checkpoints, die oft
  als zentralisiertes Element galten, überflüssig.

- [Bitcoin Core #31283][] führt eine neue Methode `waitNext()` in das
  `BlockTemplate`-Interface ein. Sie gibt nur dann ein neues Template
  zurück, wenn sich die Chain-Spitze ändert oder die Mempool-Gebühren
  über die `MAX_MONEY`-Grenze steigen. Zuvor erhielten Miner bei jeder
  Anfrage ein neues Template, was unnötige Template-Erzeugung
  verursachte. Diese Änderung bringt das Vorgehen in Einklang mit der
  [Stratum V2][topic pooled mining]-Protokollspezifikation.

- [Eclair #3037][] erweitert den Befehl `listoffers` (siehe Newsletter
  [#345][news345 offers]), sodass alle relevanten [Offer][topic offers]-Daten,
  einschließlich der Zeitstempel `createdAt` und `disabledAt`, ausgegeben
  werden und nicht nur rohe Type-Length-Value (TLV)-Daten. Zusätzlich
  behebt das PR einen Fehler, bei dem der Node abstürzte, wenn das
  gleiche Angebot zweimal registriert werden sollte.

- [LND #9546][] ergänzt den Befehl `lncli constrainmacaroon` (siehe
  Newsletter [#201][news201 constrain]) um das Flag `ip_range`, das
  den Zugriff über ein bestimmtes IP-Adressspektrum einschränkt, sofern
  man ein entsprechendes Macaroon (Authentifizierungstoken) nutzt.
  Bisher konnten Macaroons nur auf bestimmte IP-Adressen beschränkt
  oder freigegeben werden.

- [LND #9458][] führt für bestimmte Peers beschränkte Zugriffsslots ein,
  konfigurierbar über das Flag `--num-restricted-slots`, um anfängliche
  Zugriffsberechtigungen zu steuern. Peers erhalten Stufen für den
  Zugriff basierend auf ihrer Channel-Historie: Wer einen bestätigten
  Channel hatte, besitzt „geschützten“ Zugriff; mit einem unbestätigten
  Channel gibt es vorübergehenden Zugriff; alle anderen bekommen
  „eingeschränkten“ Zugriff.

- [BTCPay Server #6581][] fügt [RBF][topic rbf]-Unterstützung hinzu und
  ermöglicht damit Fee-Bumping für Transaktionen, die keine Nachkommen
  haben und deren Inputs aus der Wallet des jeweiligen Stores stammen.
  Nutzer können nun zwischen [CPFP][topic cpfp] und RBF wählen, um
  eine Transaktion zuFee-bumpen. Fee-Bumping benötigt NBXplorer
  Version 2.5.22 oder höher.

- [BDK #1839][] erweitert die Logik zum Erkennen und Behandeln
  zurückgezogener (doppelt ausgegebener) Transaktionen durch ein neues
  Feld `TxUpdate::evicted_ats`, welches die Timestamps `last_evicted` in
  `TxGraph` aktualisiert. Transaktionen gelten als evicted, wenn der
  Eintrag in `last_evicted` über ihrem `last_seen`-Wert liegt. Der
  Algorithmus zur Kanonisierung (siehe Newsletter [#335][news335 algorithm])
  ignoriert solche Transaktionen, solange kein kanonischer Nachfolger
  aufgrund von Transitivitätsregeln existiert.

- [BOLTs #1233][] ändert das Node-Verhalten derart, dass ein
  [HTLC][topic htlc] niemals upstream beendet wird, wenn dem Node
  das zugehörige Preimage bekannt ist, was die Begleichung des HTLC
  sicherstellt. Zuvor empfahl die Spezifikation, ein nicht mehr in
  einem bestätigten Commitment enthaltenes HTLC upstream zu beenden,
  selbst wenn man das Preimage kannte. Ein Fehler in älteren LND-Versionen
  vor 0.18 sorgte bei DoS-Angriffen dafür, dass HTLCs nach
  einem Neustart abgelehnt wurden, obwohl das Preimage bekannt war,
  was den Verlust des HTLC-Werts bedeutete (siehe Newsletter
  [#344][news344 lnd]).

{% include snippets/recap-ad.md when="2025-03-25 15:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="31649,31283,3037,9546,9458,6581,1839,1233" %}
[bitcoin core 29.0rc2]: https://bitcoincore.org/bin/bitcoin-core-29.0/
[morehouse sweep]: https://delvingbitcoin.org/t/lnds-deadline-aware-budget-sweeper/1512
[ismail sweep]: https://delvingbitcoin.org/t/lnds-deadline-aware-budget-sweeper/1512/3
[news216 presync]: /de/newsletters/2022/09/07/#bitcoin-core-25717
[news345 offers]: /de/newsletters/2025/03/14/#eclair-2976
[news201 constrain]: /en/newsletters/2022/05/25/#lnd-6529
[news344 lnd]: /de/newsletters/2025/03/07/#offenlegung-einer-behobenen-lnd-schwachstelle-die-diebstahl-ermoglicht
[news335 algorithm]: /en/newsletters/2025/01/03/#bdk-1670
[wally 1.4.0]: https://github.com/ElementsProject/libwally-core/releases/tag/release_1.4.0
[bccg github]: https://github.com/jurraca/core-config-tui
[riap github]: https://github.com/thunderbiscuit/regtest-in-a-pod
[podman website]: https://podman.io/
[podman bitcoin blog]: https://thunderbiscuit.com/posts/podman-bitcoin/
[explora github]: https://github.com/lontivero/explora
[hashpool github]: https://github.com/vnprc/hashpool
[news247 sri]: /en/newsletters/2023/04/19/#stratum-v2-reference-implementation-update-announced
[pod337 hashpool]: /en/podcast/2025/01/21/#continued-discussion-about-rewarding-pool-miners-with-tradeable-ecash-shares-transcript
[news281 demand]: /en/newsletters/2023/12/13/#stratum-v2-mining-pool-launches
[dmnd website]: https://www.dmnd.work/
[embit website]: https://embit.rocks/
[news273 krux]: /en/newsletters/2023/10/18/#krux-signing-device-firmware
[tropic01 website]: https://tropicsquare.com/tropic01
[tropicsquare github]: https://github.com/tropicsquare
[nunchuk blog]: https://nunchuk.io/blog/group-wallet
[frostr github]: https://github.com/FROSTR-ORG
[new325 bark]: /en/newsletters/2024/10/18/#bark-ark-implementation-announced
[second blog]: https://blog.second.tech/try-ark-on-signet/
[cove wallet github]: https://github.com/bitcoinppl/cove
