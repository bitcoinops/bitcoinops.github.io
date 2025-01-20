---
title: 'Bitcoin Optech Newsletter #337'
permalink: /de/newsletters/2025/01/17/
name: 2025-01-17-newsletter-de
slug: 2025-01-17-newsletter-de
type: newsletter
layout: newsletter
lang: de
---
Der Newsletter dieser Woche fasst die anhaltende Diskussion über
die Belohnung von Pool-Minern mit handelbaren E-Cash-Anteilen zusammen
und beschreibt einen neuen Vorschlag zur Ermöglichung der
Offchain-Auflösung von DLCs. Des Weiteren beinhalten die Abschnitte
die regulären Ankündigungen neuer Versionen und Release-Kandidaten sowie
die Beschreibung wichtiger Änderungen an der Bitcoin-Infrastruktursoftware,
die sich großer Beliebtheit erfreut.

## News

- ***Fortsetzung der Diskussion über Miner-Auszahlungen mit Ecash:**
  Die vorliegende [Diskussion][ecash tides] wurde auf Basis der [vorangegangenen Zusammenfassung]
  [news304 ecashtides] eines Delving Bitcoin-Threads fortgesetzt, in welcher die Bezahlung von
  [Pool-Minern][topic pooled mining] mit E-Cash für jeden von ihnen eingereichten
  Anteil erörtert wurde. Zuvor [erörterte][corallo whyecash] Matt Corallo die Notwendigkeit
  der Implementierung eines zusätzlichen Codes und der Buchhaltung für die Handhabung handelbarer
  Ecash-Anteile durch einen Pool, wenn die Miner doch einfach mit einer regulären Ecash-Mine
  (oder über LN) entlohnt werden könnten.
  David Caseria [führte][caseria pplns] aus, dass bei einigen Pay-per-Last-N-Shares-Systemen
  ([PPLNS][topic pplns]), wie beispielsweise [TIDES][recap291 tides], ein Miner
  möglicherweise warten muss, bis der Pool mehrere Blöcke gefunden hat, was bei
  einem kleinen Pool Tage oder Wochen dauern kann.
  Anstatt abzuwarten, könnte ein Miner mit E-Cash-Anteilen diese unmittelbar auf
  einem offenen Markt veräußern (ohne dem Pool oder Dritten seine Identität preiszugeben,
  nicht einmal eine flüchtige Identität, die er beim Mining verwendet hat).

  Caseria wies zudem darauf hin, dass es für existierende Mining-Pools finanziell herausfordernd
  ist, das System der _vollständigen Bezahlung pro Anteil_ ([FPPS][topic fpps]) zu unterstützen.
  Bei diesem System wird ein Miner proportional zur gesamten Blockbelohnung
  (Subvention plus Transaktionsgebühren) entlohnt, sofern er einen Anteil erstellt.
  Er äußerte sich nicht explizit zu den Gründen, jedoch wird in Fachkreisen davon ausgegangen,
  dass die Problematik in den divergierenden Gebühren liegt, welche die Pools dazu veranlassen,
  signifikante Rücklagen zu bilden. Wenn ein Pool-Miner die Kontrolle über 1 % der Hashrate erhält
  und Anteile an einer Vorlage mit etwa 1.000 BTC an Gebühren und 3 BTC an Subventionen durch den
  Pool-Miner erstellt, dann ergibt sich eine Schuld des Pools in Höhe von 10 BTC.
  Im Falle der Nicht-Abbauung des Blocks durch den Pool und der damit verbundenen Reduzierung
  der Gebühren auf einen Bruchteil der Blockbelohnung besteht die Möglichkeit, dass der Pool
  lediglich über 3 BTC verfügt, die er unter allen seinen Minern aufteilen muss. Dies führt dazu,
  dass der Pool gezwungen ist, aus seinen Reserven zu zahlen. Wenn dieser Zustand zu häufig
  vorkommt, sind die Reserven des Pools erschöpft und das Geschäft muss geschlossen werden.
  Pools verfahren hierbei auf unterschiedliche Weise, beispielsweise durch die
  Verwendung von Proxys für die [tatsächlichen Gebühren][news304 fpps proxy].

  Der Entwickler vnprc [beschreibt][vnprc ehash] die Funktionsweise seiner [Lösung]
  [hashpool], die sich auf die im PPLNS-Auszahlungsplan aufgeführten E-Cash-Aktien fokussiert.
  Er ist der Auffassung, dass dies insbesondere für die Einführung neuer Pools von Nutzen sein
  könnte: Derzeit ist der erste Miner, der einem Pool beitritt, der gleichen hohen Varianz
  ausgesetzt wie beim Solo-Mining. In der Regel sind demnach die einzigen Personen, die einen Pool
  starten können, bestehende große Miner oder diejenigen, die bereit sind, eine erhebliche Hashrate
  zu mieten. In Bezug auf die PPLNS-Ecash-Anteile geht vnprc jedoch davon aus, dass ein Pool als
  Kunde eines größeren Pools starten könnte, so dass selbst der erste Miner, der dem neuen Pool
  beitritt, eine geringere Varianz als beim Solo-Mining hat. Der Zwischenpool könnte dann die
  erworbenen E-Cash-Anteile verkaufen, um das von ihm gewählte Auszahlungsschema für seine Miner
  zu finanzieren. Sobald der Zwischenpool eine signifikante Menge an Hashrate erworben hat,
  könnte er auch mit größeren Pools über die Erstellung alternativer Blockmodelle verhandeln,
  die für seine Miner geeignet sind.

- **Offchain DLCs:** In der vorliegenden Arbeit werden Offchain DLCs (DLCs, die außerhalb der
  Blockchain erstellt werden) thematisiert.
  Der Entwickler Conduition hat hierzu einen Beitrag über ein Vertragsprotokoll auf der DLC-Dev
  Mailingliste [gepostet][conduition offchain] verfasst, das eine Offchain-Ausgabe der von beiden
  Parteien unterzeichneten Finanzierungstransaktion ermöglicht, um mehrere [DLCs][topic dlc] zu
  erstellen. Nachdem der Offchain-DLC verarbeitet wurde (z.B. wurden alle erforderlichen
  Oracle-Signaturen eingeholt), kann ein neuer Offchain-DLC von beiden Parteien unterzeichnet
  werden. Dadurch werden die Ressourcen entsprechend der Vertragslösung neu zugeordnet.
  Eine dritte alternative Option besteht darin, die Mittel neuen DLCs zuzuweisen.

  Die von Kulpreet Singh und Philipp Hoenisch präsentierten Antworten bezogen sich auf frühere
  Forschungen und Entwicklungen dieser Grundidee, einschließlich Ansätzen, die es ermöglichen,
  denselben Fondspool sowohl für Offchain-DLCs als auch LN zu verwenden (siehe Newsletter
  [#174][news174 dlc-ln] und [#260][news260 dlc]).
  Eine [Antwort][conduition offchain2] von Conduition legte den signifikantesten Unterschied
  zwischen seinem Vorschlag und früheren Vorschlägen dar.


## Releases und Release-Kandidaten

  _Es werden neue Releases und Release-Kandidaten für populäre Bitcoin-Infrastrukturprojekte
  offeriert. Zudem wird empfohlen, ein Upgrade auf neue Releases zu erwägen oder Unterstützung
  beim Testen von Release-Kandidaten zu leisten._

- [LDK v0.1][] stellt eine Meilensteinversion dieser Bibliothek dar,
  die für die Erstellung von LN-fähigen Wallets und Anwendungen konzipiert wurde. Zu den neu
  implementierten Funktionen gehören die Unterstützung für beide Seiten der
  LSPS-Kanal-Open-Negotiation-Protokolle, die Unterstützung der Auflösung von BIP353 Human
  Readable Names sowie die Reduktion der On-Chain-Gebührenkosten bei der
  Auflösung mehrerer HTLCs für eine erzwungene Schließung eines einzelnen Kanals.

## Wichtige Code- und Dokumentationsänderungen

  _Wichtige Änderungen in [Bitcoin Core][bitcoin core repo], [Core
  Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
  [LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
  Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
  Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
  Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
  [Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
  repo], und [BINANAs][binana repo]._

- [Eclair #2936][] führt eine Verzögerung von 12 Blöcken ein,
  bevor ein Kanal als geschlossen markiert wird, nachdem seine Finanzierungsausgabe ausgegeben
  wurde. So soll die Verbreitung eines [Splice ][topic splicing]-Updates zu ermöglichen (siehe
  Newsletter [#214][news214 splicing] und eine Beschreibung der [Motivation][tbast splice]
  durch einen Eclair-Entwickler). Verbrauchte Kanäle werden vorübergehend in einer neuen
  `spentChannels`-Karte verfolgt, wo sie entweder nach 12 Blöcken entfernt oder als gespleißte
  Kanäle aktualisiert werden. Bei einem Splice werden die Short Channel Identifier (SCID),
  die Kapazität und die Saldogrenzen des übergeordneten Kanals aktualisiert,
  anstatt einen neuen Kanal zu erstellen.

- [Rust Bitcoin #3792][] fügt die Möglichkeit hinzu, [BIP324][]s [v2 P2P
  transport][topic v2 P2P transport]-Nachrichten zu kodieren und zu dekodieren
  (siehe Newsletter [#306][news306 v2]).
  Dies wird durch das Hinzufügen einer `V2NetworkMessage`-Struktur erreicht, welche die
  ursprüngliche `NetworkMessage`-Aufzählung umschließt und v2-Kodierung und -Dekodierung
  bereitstellt.

- [BDK #1789][] aktualisiert die Standardtransaktionsversion von 1 auf 2,
  um die Privatsphäre der Wallets zu verbessern. Zuvor waren BDK-Wallets besser
  identifizierbar, da nur 15 % des Netzwerks Version 1 verwendeten. Darüber hinaus ist
  Version 2 für eine zukünftige Implementierung des auf nSequence basierenden
  [Anti-Fee-Sniping][thema fee sniping]-Mechanismus von
  [BIP326][] für [Taproot][thema taproot]-Transaktionen erforderlich.

- [BIPs #1687][] führt [BIP375][] zusammen, um das Senden von [stillen Zahlungen][topic
  silent payments] mit [PSBTs][topic psbt] anzugeben. Wenn es mehrere unabhängige
  Unterzeichner gibt, ist ein [DLEQ][topic dleq]-Nachweis erforderlich, damit alle Unterzeichner
  den Mitunterzeichnern nachweisen können,
  dass ihre Unterschrift keine Gelder zweckentfremdet, ohne ihren
  privaten Schlüssel preiszugeben (siehe [Newsletter #335][news335 dleq] und [Recap
  #327][recap327 dleq]).

- [BIPs #1396][] aktualisiert die [payjoin][topic payjoin]-Spezifikation von [BIP78][], um sie
  mit der [PSBT][topic psbt]-Spezifikation von [BIP174][] in Einklang zu bringen und so einen
  vorherigen Konflikt zu lösen. In BIP78 löschte ein Empfänger zuvor UTXO-Daten, nachdem er
  seine Eingaben abgeschlossen hatte, selbst wenn der Absender die Daten benötigte. Mit diesem
  Update bleiben UTXO-Daten jetzt erhalten.

{% include snippets/recap-ad.md when="2025-01-21 15:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="3792,1789,1687,1396,2936" %}
[ldk v0.1]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.1
[news174 dlc-ln]: /en/newsletters/2021/11/10/#dlcs-over-ln
[news260 dlc]: /en/newsletters/2023/07/19/#wallet-10101-beta-testing-pooling-funds-between-ln-and-dlcs
[ecash tides]: https://delvingbitcoin.org/t/ecash-tides-using-cashu-and-stratum-v2/870
[news304 ecashtides]: /en/newsletters/2024/05/24/#challenges-in-rewarding-pool-miners
[corallo whyecash]: https://delvingbitcoin.org/t/ecash-tides-using-cashu-and-stratum-v2/870/27
[caseria pplns]: https://delvingbitcoin.org/t/ecash-tides-using-cashu-and-stratum-v2/870/29
[recap291 tides]: /en/podcast/2024/02/29/#how-does-ocean-s-tides-payout-scheme-work-transcript
[vnprc ehash]: https://delvingbitcoin.org/t/ecash-tides-using-cashu-and-stratum-v2/870/32
[hashpool]: https://github.com/vnprc/hashpool
[conduition offchain]: https://mailmanlists.org/pipermail/dlc-dev/2025-January/000186.html
[news304 fpps proxy]: /en/newsletters/2024/05/24/#pay-per-share-pps
[tbast splice]: https://github.com/ACINQ/eclair/pull/2936#issuecomment-2595930679
[conduition offchain2]: https://mailmanlists.org/pipermail/dlc-dev/2025-January/000189.html
[news214 splicing]: /en/newsletters/2022/08/24/#bolts-1004
[news306 v2]: /en/newsletters/2024/06/07/#rust-bitcoin-2644
[news335 dleq]: /en/newsletters/2025/01/03/#bips-1689
[recap327 dleq]: /en/podcast/2024/11/05/#draft-bip-for-dleq-proofs
