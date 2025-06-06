---
title: 'Bitcoin Optech Newsletter #354'
permalink: /de/newsletters/2025/05/16/
name: 2025-05-16-newsletter-de
slug: 2025-05-16-newsletter-de
type: newsletter
layout: newsletter
lang: de
---
Der Newsletter dieser Woche beschreibt eine behobene Schwachstelle, die ältere Versionen von Bitcoin Core betrifft. Ebenfalls enthalten sind unsere regulären Abschnitte mit Zusammenfassungen aktueller Diskussionen über Änderungen der Bitcoin-Konsensregeln, Ankündigungen neuer Releases und Release-Kandidaten sowie Beschreibungen wichtiger Änderungen an populärer Bitcoin-Infrastruktur.

## Nachrichten

- **Offenlegung einer Schwachstelle in alten Versionen von Bitcoin Core:**
  Antoine Poinsot [berichtete][poinsot addrvuln] auf der Bitcoin-Dev-Mailingliste über eine Schwachstelle, die Bitcoin Core-Versionen vor 29.0 betrifft. Die Schwachstelle wurde ursprünglich von Eugene Siegel [verantwortungsvoll gemeldet][topic responsible disclosures], zusammen mit einer weiteren, eng verwandten Schwachstelle, die in [Newsletter #314][news314 excess addr] beschrieben wurde. Ein Angreifer konnte eine übermäßige Anzahl von Knoten-Adressanzeigen senden, um einen 32-Bit-Identifier zum Überlaufen zu bringen, was zu einem Absturz des Knotens führte. Dies wurde teilweise dadurch entschärft, dass die Anzahl der Updates auf eins pro Peer alle zehn Sekunden begrenzt wurde, was bei etwa 125 Peers im Standardfall ein Überlaufen nur dann ermöglicht hätte, wenn der Knoten über mehr als 10 Jahre kontinuierlich angegriffen worden wäre. <!-- 2**32 * 10 / 125 / (60 * 60 * 24 * 365) --> Die Schwachstelle wurde vollständig behoben, indem ab Version 29.0 von Bitcoin Core 64-Bit-Identifier verwendet werden.

## Änderungen am Konsens

_Ein monatlicher Abschnitt mit Zusammenfassungen von Vorschlägen und Diskussionen zu Änderungen der Bitcoin-Konsensregeln._

- **Vorgeschlagenes BIP für 64-Bit-Arithmetik in Script:**
  Chris Stewart [veröffentlichte][stewart bippost] auf der Bitcoin-Dev-Mailingliste einen [BIP-Entwurf][64bit bip], der vorschlägt, die bestehenden Opcodes von Bitcoin so zu erweitern, dass sie mit 64-Bit-Zahlen arbeiten. Dies folgt auf seine frühere Forschung (siehe Newsletter [#285][news285 64bit], [#290][news290 64bit] und [#306][news306 64bit]). Im Unterschied zu früheren Diskussionen verwendet der neue Vorschlag Zahlen im gleichen compactSize-Datenformat, das derzeit in Bitcoin genutzt wird. Weitere [Diskussionen][stewart inout] dazu fanden in zwei [Threads][stewart overflow] auf Delving Bitcoin statt.

- **Vorgeschlagene Opcodes für rekursive Covenants mittels Quines:**
  Auf Delving Bitcoin [schlug][cohen quine] Bram Cohen eine Reihe einfacher Opcodes vor, mit denen sich rekursive [Covenants][topic covenants] durch selbstreproduzierende Skripte ([Quines][]) erstellen ließen. Cohen beschreibt, wie die Opcodes genutzt werden könnten, um einen einfachen [Vault][topic vaults] zu bauen, und erwähnt ein fortgeschritteneres System, an dem er arbeitet.

- **Beschreibung der Vorteile für BitVM durch `OP_CTV` und `OP_CSFS`:**
  Robin Linus [beschrieb][linus bitvm-sf] auf Delving Bitcoin mehrere Verbesserungen für [BitVM][topic acc], die durch die vorgeschlagenen Opcodes [OP_CTV][topic op_checktemplateverify] und [OP_CSFS][topic op_checksigfromstack] per Soft Fork möglich würden. Zu den Vorteilen zählen eine höhere Anzahl von Operatoren ohne Nachteile, „etwa 10-fach kleinere Transaktionen“ (was die Worst-Case-Kosten reduziert) und die Möglichkeit nicht-interaktiver Peg-ins für bestimmte Verträge.

## Veröffentlichungen und Release-Kandidaten

_Neue Veröffentlichungen und Release-Kandidaten für populäre Bitcoin-Infrastrukturprojekte. Bitte erwäge, auf neue Releases zu aktualisieren oder Release-Kandidaten zu testen._

- [LND 0.19.0-beta.rc4][] ist ein Release-Kandidat für diesen populären LN-Knoten. Eine der wichtigsten Verbesserungen, die getestet werden sollte, ist das neue RBF-basierte Fee-Bumping für kooperative Channel-Schließungen.

## Wichtige Code- und Dokumentationsänderungen

_Wichtige aktuelle Änderungen in [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo], [Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition repo] und [BINANAs][binana repo]._

- [Bitcoin Core #32155][] aktualisiert den internen Miner, sodass Coinbase-Transaktionen per [Timelock][topic timelocks] versehen werden, indem das Feld `nLockTime` auf die aktuelle Blockhöhe minus eins gesetzt und das Feld `nSequence` nicht final gesetzt wird (um das Timelock zu erzwingen). Obwohl der eingebaute Miner normalerweise nicht im Mainnet verwendet wird, sollen Mining-Pools durch dieses Update frühzeitig zur Übernahme dieser Änderungen in ihrer eigenen Software motiviert werden – als Vorbereitung auf den vorgeschlagenen [Consensus Cleanup][topic consensus cleanup] Soft Fork ([BIP54][]). Das Timelocking von Coinbase-Transaktionen löst die [Duplicate Transaction][topic duplicate transactions]-Schwachstelle und würde erlauben, die aufwändigen [BIP30][]-Prüfungen zu entfernen.

- [Bitcoin Core #28710][] entfernt den verbleibenden Legacy-Wallet-Code, die zugehörige Dokumentation und Tests. Dazu gehören die ausschließlich für Legacy-Wallets bestimmten RPCs wie `importmulti`, `sethdseed`, `addmultisigaddress`, `importaddress`, `importpubkey`, `dumpwallet`, `importwallet` und `newkeypool`. Als letzter Schritt für die Entfernung der Legacy-Wallets werden auch die BerkeleyDB-Abhängigkeit und zugehörige Funktionen entfernt. Das absolute Minimum an Legacy-Code und ein unabhängiger BDB-Parser (siehe Newsletter [#305][news305 bdb]) bleiben jedoch erhalten, um die Migration zu [Descriptor][topic descriptors]-Wallets zu ermöglichen.

- [Core Lightning #8272][] deaktiviert das DNS-Seed-Lookup-Fallback für die Peer-Discovery im Verbindungs-Daemon `connectd`, um Blockierungsprobleme durch Offline-DNS-Seeds zu vermeiden.

- [LND #8330][] fügt dem bimodalen Wahrscheinlichkeitsmodell für das Pathfinding eine kleine Konstante (1/c) hinzu, um numerische Instabilitäten zu beheben. In Randfällen, in denen die Berechnung sonst aufgrund von Rundungsfehlern fehlschlagen und eine Wahrscheinlichkeit von Null liefern würde, sorgt diese Regularisierung dafür, dass das Modell auf eine Gleichverteilung zurückfällt. Damit werden Normalisierungsfehler behoben, die bei sehr großen Channels oder solchen auftreten, die nicht in eine bimodale Verteilung passen. Außerdem überspringt das Modell jetzt unnötige Wahrscheinlichkeitsberechnungen und korrigiert automatisch veraltete Channel-Liquiditätsbeobachtungen und widersprüchliche historische Informationen.

- [Rust Bitcoin #4458][] ersetzt die Struktur `MtpAndHeight` durch ein explizites Paar aus dem neu hinzugefügten `BlockMtp` und dem bereits existierenden `BlockHeight`, um Blockhöhe und Median Time Past (MTP) bei relativen [Timelocks][topic timelocks] besser modellieren zu können. Im Gegensatz zu `locktime::absolute::MedianTimePast`, das auf Werte über 500 Millionen (etwa nach 1985) beschränkt ist, kann `BlockMtp` jeden 32-Bit-Timestamp darstellen. Das macht ihn geeignet für theoretische Spezialfälle, wie Chains mit ungewöhnlichen Zeitstempeln. Das Update führt außerdem `BlockMtpInterval` ein und benennt `BlockInterval` in `BlockHeightInterval` um.

- [BIPs #1848][] aktualisiert den Status von [BIP345][] auf „Withdrawn“, da der Autor [glaubt][obeirne vaultwithdraw], dass der vorgeschlagene Opcode `OP_VAULT` durch [`OP_CHECKCONTRACTVERIFY`][topic matt] (OP_CCV), ein allgemeineres [Vault][topic vaults]-Design und eine neue Art von [Covenant][topic covenants] ersetzt wurde.

- [BIPs #1841][] merged [BIP172][], das vorschlägt, die unteilbare Basiseinheit von Bitcoin als „Satoshi“ formell zu definieren, um die aktuelle, weit verbreitete Nutzung widerzuspiegeln und die Terminologie in Anwendungen und Dokumentation zu standardisieren.

- [BIPs #1821][] merged [BIP177][], das vorschlägt, „Bitcoin“ als die kleinste unteilbare Einheit (üblicherweise als 1 Satoshi bezeichnet) und nicht mehr als 100.000.000 Einheiten zu definieren. Das Ziel ist, die Terminologie an die tatsächliche Basiseinheit anzupassen und Verwirrung durch willkürliche Dezimal-Konventionen zu vermeiden.

{% include snippets/recap-ad.md when="2025-05-20 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="32155,28710,8272,8330,4458,1848,1841,1821" %}
[lnd 0.19.0-beta.rc4]: https://github.com/lightningnetwork/lnd/releases/tag/v0.19.0-beta.rc4
[news314 excess addr]: /en/newsletters/2024/08/02/#remote-crash-by-sending-excessive-addr-messages
[stewart bippost]: https://groups.google.com/g/bitcoindev/c/j1zEky-3QEE
[64bit bip]: https://github.com/Christewart/bips/blob/2025-03-17-64bit-pt2/bip-XXXX.mediawiki
[news285 64bit]: /en/newsletters/2024/01/17/#proposal-for-64-bit-arithmetic-soft-fork
[news290 64bit]: /en/newsletters/2024/02/21/#continued-discussion-about-64-bit-arithmetic-and-op-inout-amount-opcode
[news306 64bit]: /en/newsletters/2024/06/07/#updates-to-proposed-soft-fork-for-64-bit-arithmetic
[stewart inout]: https://delvingbitcoin.org/t/op-inout-amount/549/4
[stewart overflow]: https://delvingbitcoin.org/t/overflow-handling-in-script/1549
[poinsot addrvuln]: https://mailing-list.bitcoindevs.xyz/bitcoindev/EYvwAFPNEfsQ8cVwiK-8v6ovJU43Vy-ylARiDQ_1XBXAgg_ZqWIpB6m51fAIRtI-rfTmMGvGLrOe5Utl5y9uaHySELpya2ojC7yGsXnP90s=@protonmail.com/
[cohen quine]: https://delvingbitcoin.org/t/a-simple-approach-to-allowing-recursive-covenants-by-enabling-quines/1655/
[linus bitvm-sf]: https://delvingbitcoin.org/t/how-ctv-csfs-improves-bitvm-bridges/1591/
[quines]: https://en.wikipedia.org/wiki/Quine_(computing)
[news305 bdb]: /en/newsletters/2024/05/31/#bitcoin-core-26606
[obeirne vaultwithdraw]: https://delvingbitcoin.org/t/withdrawing-op-vault-bip-345/1670/
