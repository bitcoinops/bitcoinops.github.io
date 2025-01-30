---
title: 'Bitcoin Optech Newsletter #338'
permalink: /de/newsletters/2025/01/24/
name: 2025-01-24-newsletter-de
slug: 2025-01-24-newsletter-de
type: newsletter
layout: newsletter
lang: de
---
Der Newsletter dieser Woche kündigt einen BIP-Entwurf für die
Referenzierung nicht ausgabefähiger Schlüssel in Deskriptoren an,
untersucht, wie Implementierungen PSBTv2 verwenden, und nimmt
ausführliche Korrekturen an unserer Beschreibung eines neuen
Off-Chain-DLC-Protokolls von der letzten Woche vor. Darüber hinaus
enthalten sind unsere regulären Abschnitte, in denen Änderungen an
Diensten und Client-Software beschrieben, neue Versionen und
Release-Kandidaten angekündigt und aktuelle Änderungen an beliebter
Bitcoin-Infrastruktursoftware zusammengefasst werden.

## News

- **BIP-Entwurf für nicht ausgabefähige Schlüssel in Deskriptoren:**
  Andrew Toth hat auf der [Delving Bitcoin][toth unspendable delv] und der
  [Bitcoin-Dev Mailingliste][toth unspendable ml] einen
  [BIP-Entwurf][bips #1746] veröffentlicht, der die Referenzierung
  von nachweislich nicht ausgabefähigen Schlüsseln in
  [Deskriptoren][topic descriptors] behandelt. Diese Veröffentlichung baut
  auf einer früheren Diskussion auf, die in unserem
  [Newsletter #283][news283 unspendable] näher ausgeführt ist.
  Die Verwendung eines nachweislich nicht ausgabefähigen Schlüssels,
  auch als "_nothing up my sleeve_" (NUMS)-Punkt bezeichnet,
  ist besonders relevant für den internen [Taproot][topic taproot]-Schlüssel.
  Sofern die Erstellung eines Keypath Spend mit dem internen Schlüssel nicht
  möglich ist, kann alternativ ein Scriptpath Spend mit einem Tapleaf
  erstellt werden (beispielsweise mit einem [Tapscript][topic tapscript]).

  Zum Zeitpunkt der Erstellung dieses Dokuments findet eine aktive
  Diskussion über die [PR][bips #1746] für den Entwurf des BIP statt.

- **PSBTv2 Integrationstests:**
  Sjors Provoost hat in der Bitcoin-Dev-Mailingliste nach
  Software [gesucht][provoost psbtv2], die Unterstützung für [PSBTs][topic psbt]
  der Version 2 implementiert hat (siehe [Newsletter #141] [news141 psbtv2]).
  Ziel ist es, beim Testen eines [PR][bitcoin core #21283] zu helfen, der
  Bitcoin Core-Unterstützung dafür hinzufügt. Auf dem Bitcoin Stack Exchange
  [findet][bse psbtv2] sich eine aktualisierte Liste der von ihm verwendeten Software.
  Zwei Antworten waren von Interesse:

  - **Merklized PSBTv2:**
    Salvatore Ingala [erläutert][ingala psbtv2], dass die Ledger Bitcoin App die
    Felder eines PSBTv2 in einen Merkle-Baum umwandelt und zunächst nur die
    Wurzel an ein Ledger-Hardware-Signaturgerät sendet. Bei Bedarf werden
    spezifische Felder zusammen mit dem entsprechenden Merkle-Proof gesendet.
    Diese Vorgehensweise erlaubt es dem Gerät, mit jedem Informationselement
    isoliert zu arbeiten, ohne dass eine Speicherung der gesamten PSBT im
    begrenzten Speicher erforderlich ist. Diese Funktionalität wird durch das
    PSBTv2-Format ermöglicht, da die Bestandteile der nicht signierten Transaktion
    bereits in separate Felder unterteilt sind. Im ursprünglichen
    PSBT-Format (v0) war eine zusätzliche Analyse notwendig.

  - **Silent payments PSBTv2:**
    [BIP352][] spezifiziert, dass [Silent Payments][topic silent payments]
    ausdrücklich von der [BIP370][]-Spezifikation von PSBTv2 abhängig ist.
    Andrew Toth [erklärt][toth psbtv2], dass Silent Payments das
    `PSBT_OUT_SCRIPT`-Feld der Version 2 benötigen, da das zu verwendende
    Ausgabescript für Silent Payments erst bekannt sein kann, nachdem alle
    Unterzeichner das PSBT bearbeitet haben.

- **Korrektur zu Off-Chain-DLCs:** In der jüngsten Ausgabe unseres
  [Newsletters][news337 dlc] wurde eine Verwechslung zwischen dem von dem
  Entwickler Conduition vorgeschlagenen neuen [Schema][conduition factories]
  für Off-Chain-DLCs und zuvor veröffentlichten und implementierten
  Off-Chain-[DLC][topic dlc]-Schemen festgestellt. Diese Verwechslung
  resultiert in einem signifikanten und interessanten Unterschied,
  der in der folgenden Analyse erörtert wird:

  - Bezüglich des in den [Newsletter#174][news174 channels] und
    [Newsletter#260][news260 channels] erwähnten _DLC channels_ Protokoll
    verwendet einen Mechanismus, der mit dem
    [LN-Penalty][topic ln-penalty]-Commit-and-Revoke vergleichbar ist.
    Bei diesem Mechanismus kommt es zur Interaktion der Parteien, die durch
    _commit_ auf einen neuen Status festgelegt werden und durch _revoke_
    den alten Status, indem sie ein Geheimnis freigeben. Dieses ermöglicht
    es der Gegenpartei, ihre private Version des alten Status vollständig
    auszugeben, falls dieser auf der Blockchain veröffentlicht wird. Dadurch kann
    ein DLC durch Interaktion zwischen den Parteien erneuert werden. Alice
    und Bob machen beispielsweise Folgendes:

    1. Die Beteiligten einigen sich unverzüglich auf einen DLC für den BTCUSD-Preis,
       der einen Monat von jetzt an gültig ist.

    2. Drei Wochen später einigen sie sich auf einen DLC für den BTCUSD-Preis,
       der zwei Monate von jetzt an gültig ist, und widerrufen das vorherige DLC.

  - Das neue _DLC factories_-Protokoll widerruft automatisch die Fähigkeit
    beider Parteien, Zustände onchain zu veröffentlichen, sobald der Vertrag ausläuft.
    Dies geschieht, indem jede Orakel-Bestätigung für den Vertrag als das Geheimnis dient,
    das es der Gegenpartei ermöglicht, einen privaten Zustand vollständig auszugeben,
    falls dieser onchain veröffentlicht wird. Dadurch werden alte Zustände automatisch
    aufgehoben, wodurch aufeinanderfolgende DLCs zu Beginn des Produktionssystems ohne
    weitere Interaktionen unterzeichnet werden können.
    Zum Beispiel führen Alice und Bob folgende Schritte aus:

    1. Sie einigen sich sofort auf einen DLC für den BTCUSD-Preis, der einen Monat
       von jetzt an gültig ist.

    2. Sie einigen sich ebenfalls sofort auf einen DLC für den BTCUSD-Preis, der zwei
       Monate von jetzt an gültig ist, mit einer [timelock][topic timelocks], die dessen
       Veröffentlichung erst einen Monat von jetzt an ermöglicht. Sie können dies für den
       dritten, vierten Monat usw. wiederholen.

   Im DLC-Channels-Protokoll können Alice und Bob den zweiten Vertrag nicht erstellen,
   bevor sie bereit sind, den ersten Vertrag zu widerrufen, was zu diesem Zeitpunkt eine
   Interaktion zwischen ihnen erfordert. Im DLC-Factories-Protokoll können alle Verträge
   zum Zeitpunkt der Erstellung der Produktionssystems erstellt werden und es ist keine weitere
   Interaktion erforderlich; jedoch kann jede Partei dennoch eine Reihe von Verträgen
   unterbrechen, indem sie die aktuelle sichere und veröffentlichbare Version onchain bringt.

  Wenn Produktionssystemsteilnehmer nach dem Abschluss des Vertrags interagieren können,
  können sie ihn verlängern – allerdings können sie nicht entscheiden,
  einen anderen Vertrag oder andere Orakel zu verwenden, bis alle zuvor
  unterzeichneten Verträge ausgereift sind (es sei denn, sie gehen onchain).
  Obwohl es möglicherweise möglich ist, dieses Manko zu beseitigen, ist dies
  derzeit der Kompromiss für die reduzierte Interaktivität im Vergleich zum
  DLC-Channels-Protokoll, das willkürliche Vertragsänderungen jederzeit
  durch gegenseitigen Widerruf ermöglicht.

  Wir danken Conduition dafür, dass sie uns über unseren Fehler in der letzten Ausgabe
  unseres Newsletters informiert haben und dafür, dass sie geduldig
  [geantwortet][conduition reply] haben.

## Änderungen an Diensten und Client-Software

*In diesem monatlichen Feature heben wir interessante Updates zu Bitcoin-Wallets
und -Diensten hervor.*

- **Bull Bitcoin Mobile Wallet fügt Payjoin hinzu:**
  Bull Bitcoin [kündigte an][bull bitcoin blog], dass das Senden und Empfangen von
  [Payjoin][topic payjoin] gemäß der [vorgeschlagenen][BIPs #1483] BIP77
  Payjoin Version 2: Serverloses Payjoin-Spezifikation unterstützt wird.

- **Bitcoin Keeper fügt Miniscript-Unterstützung hinzu:**
  Bitcoin Keeper [kündigte an][bitcoin keeper twitter], dass
  [Miniscript][topic miniscript] in der [v1.3.0-Version][bitcoin keeper v1.3.0]
  unterstützt wird.

- **Nunchuk fügt Taproot MuSig2-Funktionen hinzu:**
  Nunchuk [kündigte an][nunchuk blog] die Beta-Unterstützung für [MuSig2][topic musig]
  basierte [Taproot][topic taproot] Keypath [Inputs][topic multisignature],
  sowie die Unterstützung von k-von-n-[Threshold-Wallet-Konfigurationen][topic threshold signature]
  basierend auf mehreren alternativen Blättern mit MuSig2-Scripten im Skriptbaum.

- **Jade Plus Signing-Gerät angekündigt:**
  Das [Jade Plus][blockstream blog] Hardware-Signaturgerät beinhaltet
  [exfiltration-resistente Signatur-Funktionen][topic exfiltration-resistant signing]
  und Air-Gapped-Funktionalität, unter anderem.

- **Coinswap v0.1.0 veröffentlicht:**
  [Coinswap v0.1.0][coinswap v0.1.0] ist Beta-Software, die auf einem formalisierten
  [Coinswap][topic coinswap] Protokoll [Spezifikation][coinswap spec] aufbaut,
  [Testnet4][topic testnet] unterstützt und Kommandozeilenanwendungen zur
  Interaktion mit dem Protokoll beinhaltet.

- **Bitcoin Safe 1.0.0 veröffentlicht:**
  Die [Bitcoin Safe][bitcoin safe website] Desktop-Wallet-Software
  unterstützt eine Vielzahl von Hardware-Signaturgeräten mit der
  [1.0.0-Veröffentlichung][bitcoin safe 1.0.0].

- **Bitcoin Core 28.0 Policy-Demonstration:**
  Super Testnet [kündigte an][zero fee sn] eine [Zero fee Playground][zero fee website]
  Webseite zur Demonstration der [Mempool-Policy-Funktionen][28.0 guide]
  der Bitcoin Core 28.0 Release.

- **Rust-payjoin 0.21.0 veröffentlicht:**
  Das [rust-payjoin 0.21.0][rust-payjoin 0.21.0] Release fügt
  [Transaction Cut-Through][] Funktionen hinzu (siehe [Podcast #282][pod282 payjoin]).

- **PeerSwap v4.0rc1:**
  Die Lightning-Channel-Liquiditätssoftware PeerSwap veröffentlichte
  [v4.0rc1][peerswap v4.0rc1], die Protokoll-Upgrades beinhaltet.
  Das [PeerSwap FAQ][peerswap faq] erläutert, wie PeerSwap sich von
  [Submarine Swaps][topic submarine swaps], [Splicing][topic splicing]
  und [Liquiditätsanzeigen][topic liquidity advertisements] unterscheidet.

- **Joinpool-Prototyp mit CTV:**
  Der [CTV Payment Pool][ctv payment pool github] Proof-of-Concept verwendet die
  vorgeschlagene [OP_CHECKTEMPLATEVERIFY (CTV)][topic op_checktemplateverify]
  Opcode, um einen [Joinpool][topic joinpools] zu erstellen.

- **Rust Joinstr Library angekündigt:**
  Die experimentelle [Rust-Bibliothek][rust joinstr github] implementiert das Joinstr
  [CoinJoin][topic coinjoin] Protokoll.

- **Strata Bridge angekündigt:**
  Die [Strata Bridge][strata blog] ist eine auf [BitVM2][topic acc]-basierte
  Brücke zum Transfer von Bitcoins zu und von einer [Sidechain][topic sidechains],
  in diesem Fall einem Validity Rollup (siehe [Newsletter #222][news222 validity rollups]).

## Releases und Release-Kandidaten

Neue Releases und Release-Kandidaten für beliebte Bitcoin-Infrastrukturprojekte.
Bitte ziehen Sie ein Upgrade auf neue Releases in Betracht oder helfen Sie dabei,
Release-Kandidaten zu testen.

- [BTCPay Server 2.0.6][] enthält einen "Sicherheitsfix für Händler,
die Rücksendungen/Pull-Zahlungen onchain mit automatisierten
Auszahlungsverarbeitern verwenden." Ebenfalls enthalten sind mehrere neue
Funktionen und Fehlerbehebungen.

## Bedeutende Änderungen im Code und in der Dokumentation

_[Bemerkenswerte kürzliche Änderungen in [Bitcoin Core][bitcoin core repo],
[Core Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet Interface (HWI)][hwi repo],
[Rust Bitcoin][rust bitcoin repo], [BTCPay Server][btcpay server repo], [BDK][bdk repo],
[Bitcoin Improvement Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition repo],
und [BINANAs][binana repo].]_

- [Bitcoin Core #31397][] verbessert den [Orphan-Auflösungsprozess][news333 prclub],
indem alle potenziellen Peers, die fehlende Elterntransaktionen bereitstellen können,
verfolgt und genutzt werden. Bisher verlagerte sich der Auflösungsprozess ausschließlich
auf den Peer, der die verwaiste Transaktion ursprünglich bereitgestellt hat. Falls der
Peer nicht antwortete oder eine `notfound`-Nachricht zurückgab, gab es keinen
Wiederholungsmechanismus, was wahrscheinlich zu Transaktionsdownload-Fehlern führte.
Der neue Ansatz versucht, die Elterntransaktion von allen Kandidaten-Peers herunterzuladen,
während die Bandbreiteneffizienz, Zensurresistenz und effektive Lastverteilung
beibehalten werden. Dies ist besonders vorteilhaft für den ein-Elternteil-ein-Kind (1p1c)
[Package Relay][topic package relay] und bereitet den Boden für den empfänger-initiierten
[BIP331][] Ancestor Package Relay vor.

- [Eclair #2896][] ermöglicht das Speichern der partiellen Signatur eines
[MuSig2][topic musig] Peers anstelle einer traditionellen 2-von-2 Multisig-Signatur,
als Voraussetzung für eine zukünftige Implementierung von
[einfachen Taproot Channels][topic simple taproot channels]. Das Speichern dieser
Signaturen erlaubt einem Node, eine Commitment-Transaktion einseitig zu broadcasten,
wenn dies nötig ist.

- [LDK #3408][] führt Dienstprogramme zur Erstellung statischer Rechnungen und deren
entsprechenden [Offers][topic offers] im `ChannelManager` ein, um
[asynchrone Zahlungen][topic async payments] in [BOLT12][] gemäß den Spezifikationen der
[BOLTs #1149][]. Anders als das reguläre Dienstprogramm zur Erstellung von Offers,
das den Empfänger erfordert, um online zu sein, um Rechnungsanfragen zu bedienen,
ermöglicht das neue Dienstprogramm Empfängern, die häufig offline sind. Diese PR
fügt auch fehlende Tests für das Bezahlen statischer Rechnungen hinzu
(siehe Newsletter [#321][news321 async]) und stellt sicher, dass Rechnungsanfragen
abgerufen werden können, wenn der Empfänger wieder online kommt.

- [LND #9405][] macht den Parameter `ProofMatureDelta` konfigurierbar, welcher die
Anzahl der Bestätigungen bestimmt, die erforderlich sind, bevor eine
[Channel Announcement][topic channel announcements] im Gossip-Netzwerk verarbeitet
wird. Der Standardwert ist 6.

{% include snippets/recap-ad.md when="2025-01-28 15:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="1746,21283,31397,2896,3408,9405,1149,1483" %}
[news337 dlc]: /en/newsletters/2025/01/17/#offchain-dlcs
[conduition factories]: https://conduition.io/scriptless/dlc-factory/
[conduition reply]: https://mailmanlists.org/pipermail/dlc-dev/2025-January/000193.html
[news174 channels]: /en/newsletters/2021/11/10/#dlcs-over-ln
[news260 channels]: /en/newsletters/2023/07/19/#wallet-10101-beta-testing-pooling-funds-between-ln-and-dlcs
[condution reply]: https://mailmanlists.org/pipermail/dlc-dev/2025-January/000193.html
[news283 unspendable]: /en/newsletters/2024/01/03/#how-to-specify-unspendable-keys-in-descriptors
[toth unspendable delv]: https://delvingbitcoin.org/t/unspendable-keys-in-descriptors/304/31
[toth unspendable ml]: https://mailing-list.bitcoindevs.xyz/bitcoindev/a594150d-fd61-42f5-91cd-51ea32ba2b2cn@googlegroups.com/
[news141 psbtv2]: /en/newsletters/2021/03/24/#bips-1059
[provoost psbtv2]: https://mailing-list.bitcoindevs.xyz/bitcoindev/6FDAD97F-7C5F-474B-9EE6-82092C9073C5@sprovoost.nl/
[bse psbtv2]: https://bitcoin.stackexchange.com/a/125393/21052
[ingala psbtv2]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CAMhCMoGONKFok_SuZkic+T=yoWZs5eeVxtwJL6Ei=yysvA8rrg@mail.gmail.com/
[toth psbtv2]: https://mailing-list.bitcoindevs.xyz/bitcoindev/30737859-573e-40ea-9619-1d18c2a6b0f4n@googlegroups.com/
[btcpay server 2.0.6]: https://github.com/btcpayserver/btcpayserver/releases/tag/v2.0.6
[news321 async]: /en/newsletters/2024/09/20/#ldk-3140
[news333 prclub]: /en/newsletters/2024/12/13/#bitcoin-core-pr-review-club
[bull bitcoin blog]: https://www.bullbitcoin.com/blog/bull-bitcoin-wallet-payjoin
[bitcoin keeper twitter]: https://x.com/bitcoinKeeper_/status/1866147392892080186
[bitcoin keeper v1.3.0]: https://github.com/bithyve/bitcoin-keeper/releases/tag/v1.3.0
[nunchuk blog]: https://nunchuk.io/blog/taproot-multisig
[blockstream blog]: https://blog.blockstream.com/introducing-the-all-new-blockstream-jade-plus-simple-enough-for-beginners-advanced-enough-for-cypherpunks/
[coinswap v0.1.0]: https://github.com/citadel-tech/coinswap/releases/tag/v0.1.0
[coinswap spec]: https://github.com/citadel-tech/Coinswap-Protocol-Specification
[bitcoin safe website]: https://bitcoin-safe.org/en/
[bitcoin safe 1.0.0]: https://github.com/andreasgriffin/bitcoin-safe
[zero fee sn]: https://stacker.news/items/805544
[zero fee website]: https://supertestnet.github.io/zero_fee_playground/
[28.0 guide]: /en/bitcoin-core-28-wallet-integration-guide/
[rust-payjoin 0.21.0]: https://github.com/payjoin/rust-payjoin/releases/tag/payjoin-0.21.0
[transaction cut-through]: https://bitcointalk.org/index.php?topic=281848.0
[pod282 payjoin]: /en/podcast/2023/12/21/#payjoin-transcript
[peerswap v4.0rc1]: https://github.com/ElementsProject/peerswap/releases/tag/v4.0rc1
[peerswap faq]: https://github.com/ElementsProject/peerswap?tab=readme-ov-file#faq
[ctv payment pool github]: https://github.com/stutxo/op_ctv_payment_pool
[rust joinstr github]: https://github.com/pythcoiner/joinstr
[strata blog]: https://www.alpenlabs.io/blog/introducing-the-strata-bridge
[news222 validity rollups]: /en/newsletters/2022/10/19/#validity-rollups-research
