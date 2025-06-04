---
title: 'Bitcoin Optech Newsletter #351'
permalink: /de/newsletters/2025/04/25/
name: 2025-04-25-newsletter-de
slug: 2025-04-25-newsletter-de
type: newsletter
layout: newsletter
lang: de
---
Der Newsletter dieser Woche kündigt ein neues Aggregat-Signaturprotokoll an, das mit secp256k1 kompatibel ist, und beschreibt ein standardisiertes Backup-Schema für Wallet-Deskriptoren. Ebenfalls enthalten sind unsere regulären Abschnitte mit Zusammenfassungen aktueller Fragen und Antworten von Bitcoin Stack Exchange, Ankündigungen neuer Releases und Release-Kandidaten sowie Beschreibungen wichtiger Änderungen an populärer Bitcoin-Infrastruktur.

## Nachrichten

- **Interaktive Aggregat-Signaturen kompatibel mit secp256k1:** Jonas Nick, Tim Ruffing und Yannick Seurin [veröffentlichten][nrs dahlias] in der Bitcoin-Dev-Mailingliste einen Hinweis auf ein [Paper][dahlias paper], das sie über die Erstellung von 64-Byte-Aggregat-Signaturen geschrieben haben, die mit den bereits in Bitcoin verwendeten kryptographischen Primitiven kompatibel sind. Aggregat-Signaturen sind die kryptographische Voraussetzung für [Cross-Input Signature Aggregation][topic cisa] (CISA), ein vorgeschlagenes Feature für Bitcoin, das die Größe von Transaktionen mit mehreren Inputs reduzieren könnte. Dadurch würden die Kosten vieler verschiedener Arten von Ausgaben sinken – einschließlich datenschutzfreundlicher Ausgaben durch [Coinjoins][topic coinjoin] und [Payjoins][topic payjoin].

  Zusätzlich zu einem Aggregat-Signaturschema wie dem von den Autoren vorgeschlagenen DahLIAS-Schema würde die Unterstützung von CISA in Bitcoin eine Konsensänderung erfordern. Mögliche Wechselwirkungen zwischen Signaturaggregation und anderen vorgeschlagenen Konsensänderungen könnten weitere Untersuchungen erfordern.

- **Standardisiertes Backup für Wallet-Deskriptoren:** Salvatore Ingala [veröffentlichte][ingala backdes] auf Delving Bitcoin eine Zusammenfassung verschiedener Abwägungen beim Backup von Wallet-[Deskriptoren][topic descriptors] und ein vorgeschlagenes Schema, das für viele verschiedene Wallet-Typen nützlich sein sollte, einschließlich solcher mit komplexen Skripten. Sein Schema verschlüsselt Deskriptoren mit einem deterministisch generierten 32-Byte-Geheimnis. Für jeden öffentlichen Schlüssel (oder Extended Public Key) im Deskriptor wird eine Kopie des Geheimnisses mit einer Variante des öffentlichen Schlüssels XOR-verknüpft, wodurch _n_ 32-Byte-Geheimnisverschlüsselungen für _n_ öffentliche Schlüssel entstehen. Jeder, der einen der im Deskriptor verwendeten öffentlichen Schlüssel kennt, kann diesen mit der 32-Byte-Geheimnisverschlüsselung XORen, um das 32-Byte-Geheimnis zu erhalten, das den Deskriptor entschlüsseln kann. Dieses einfache und effiziente Schema ermöglicht es, viele verschlüsselte Kopien eines Deskriptors auf verschiedenen Medien und an verschiedenen Orten zu speichern und dann mit dem [BIP32-Wallet-Seed][topic bip32] den eigenen xpub zu generieren, mit dem sich der Deskriptor im Notfall wiederherstellen lässt.

## Ausgewählte Q&A von Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] ist einer der ersten Orte, an denen Optech-Mitwirkende nach Antworten suchen – oder wenn wir ein paar Minuten Zeit haben, um neugierigen oder ratlosen Nutzern zu helfen. In dieser monatlichen Rubrik heben wir einige der am höchsten bewerteten Fragen und Antworten hervor, die seit unserem letzten Update gepostet wurden.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Wie praktikabel sind halbaggregierte Schnorr-Signaturen?]({{bse}}125982)
  Fjahr erläutert, warum unabhängige, nicht aggregierte Signaturen nicht erforderlich sind, um eine halbaggregierte Signatur bei [Cross-Input Signature Aggregation (CISA)][topic cisa] zu validieren, und warum nicht aggregierte Signaturen tatsächlich problematisch sein können.

- [Was ist die größte jemals erstellte OP_RETURN-Payload?]({{bse}}126131)
  Vojtěch Strnad [verlinkt][op_return tx] auf eine Runes-[Meta-Protokoll][topic client-side validation]-Transaktion mit 79.870 Bytes als größtem `OP_RETURN`.

- [Nicht-LN-Erklärung zu Pay-to-Anchor?]({{bse}}126098)
  Murch erläutert die Motivation und Struktur von [Pay-to-Anchor (P2A)][topic ephemeral anchors]-Ausgabe-Skripten.

- [Aktuelle Statistiken zu Chain Reorganizations?]({{bse}}126019)
  0xb10c und Murch nennen Quellen für Reorg-Daten, darunter das [stale-blocks][stale-blocks github]-Repository, die Website [forkmonitor.info][] und die Website [fork.observer][].

- [Sind Lightning-Channels immer P2WSH?]({{bse}}125967)
  Polespinasa weist auf die laufende Entwicklung von P2TR-[Simple Taproot Channels][topic simple taproot channels] hin und fasst die aktuelle Unterstützung in Lightning-Implementierungen zusammen.

- [Child-pays-for-parent als Verteidigung gegen Double-Spend?]({{bse}}126056)
  Murch listet Komplikationen bei der Verwendung einer hoch gebührenbehafteten [CPFP][topic cpfp]-Child-Transaktion auf, um eine Blockchain-Reorg als Verteidigung gegen einen bereits bestätigten Double-Spend zu incentivieren.

- [Welche Werte hasht CHECKTEMPLATEVERIFY?]({{bse}}126133)
  Average-gray beschreibt die Felder, auf die [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify] verpflichtet: nVersion, nLockTime, Input-Anzahl, Sequences-Hash, Output-Anzahl, Outputs-Hash, Input-Index und in manchen Fällen der ScriptSig-Hash.

- [Warum können Lightning-Knoten nicht einfach Channel-Bilanzen offenlegen, um Routing-Effizienz zu verbessern?]({{bse}}125985)
  Rene Pickhardt erklärt Bedenken hinsichtlich der Aktualität und Vertrauenswürdigkeit der Daten, Datenschutzaspekte und verweist auf einen [ähnlichen Vorschlag][BOLTs #780] aus dem Jahr 2020.

- [Erfordert Post-Quantum einen Hard Fork oder Soft Fork?]({{bse}}126122)
  Vojtěch Strnad skizziert einen Ansatz, wie ein [Post-Quantum][topic quantum resistance] (PQC)-Signaturschema per [Soft Fork aktiviert][topic soft fork activation] werden könnte und wie ein Hard oder Soft Fork quantenanfällige Coins sperren könnte.

## Veröffentlichungen und Release-Kandidaten

_Neue Veröffentlichungen und Release-Kandidaten für beliebte Bitcoin-Infrastrukturprojekte. Bitte erwägen Sie ein Upgrade auf neue Versionen oder helfen Sie bei der Testung von Release-Kandidaten._

- [LND 0.19.0-beta.rc3][] ist ein Release-Kandidat für diesen beliebten LN-Knoten. Eine der wichtigsten Verbesserungen, die getestet werden sollten, ist das neue RBF-basierte Fee-Bumping für kooperative Schließungen.

## Wichtige Code- und Dokumentationsänderungen

_Bedeutende kürzliche Änderungen in [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo], [Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition repo] und [BINANAs][binana repo]._

- [Bitcoin Core #31247][] fügt Unterstützung für das Serialisieren und Parsen von [MuSig2][topic musig]-[PSBT][topic psbt]-Feldern gemäß [BIP373][] hinzu, damit Wallets [MuSig2][topic musig]-Inputs signieren und ausgeben können. Auf der Input-Seite besteht dies aus einem Feld mit den Teilnehmer-Pubkeys, einem separaten Public-Nonce-Feld und einem separaten Partial-Signature-Feld für jeden Signer. Auf der Output-Seite ist es ein einzelnes Feld mit den Teilnehmer-Pubkeys für das neue UTXO.

- [LDK #3601][] fügt ein neues `LocalHTLCFailureReason`-Enum hinzu, das jeden Standard-[BOLT4][]-Fehlercode abbildet, zusammen mit einigen Varianten, die dem Nutzer zusätzliche Informationen liefern, die zuvor aus Datenschutzgründen entfernt wurden.

{% include references.md %}
{% include linkers/issues.md v=2 issues="31247,3601,780" %}
[lnd 0.19.0-beta.rc3]: https://github.com/lightningnetwork/lnd/releases/tag/v0.19.0-beta.rc3
[nrs dahlias]: https://mailing-list.bitcoindevs.xyz/bitcoindev/be3813bf-467d-4880-9383-2a0b0223e7e5@gmail.com/
[dahlias paper]: https://eprint.iacr.org/2025/692.pdf
[ingala backdes]: https://delvingbitcoin.org/t/a-simple-backup-scheme-for-wallet-accounts/1607
[op_return tx]: https://mempool.space/tx/fd3c5762e882489a62da3ba75a04ed283543bfc15737e3d6576042810ab553bc
[stale-blocks github]: https://github.com/bitcoin-data/stale-blocks
[forkmonitor.info]: https://forkmonitor.info/nodes/btc
[fork.observer]: https://fork.observer/
