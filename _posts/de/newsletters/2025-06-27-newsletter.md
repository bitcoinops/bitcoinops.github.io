---
title: 'Bitcoin Optech Newsletter #360'
permalink: /de/newsletters/2025/06/27/
name: 2025-06-27-newsletter-de
slug: 2025-06-27-newsletter-de
type: newsletter
layout: newsletter
lang: de
---
Der Newsletter dieser Woche fasst Forschungen zur Identifizierung von Full Nodes mittels
P2P-Protokoll-Nachrichten zusammen und bittet um Feedback zur möglichen Entfernung der
Unterstützung für `H` in BIP32-Pfaden in der BIP380-Spezifikation von Deskriptoren.
Ebenfalls enthalten sind unsere regulären Abschnitte mit Zusammenfassungen der wichtigsten
Fragen und Antworten auf der Bitcoin Stack Exchange, Ankündigungen neuer Releases und
Release-Kandidaten sowie Beschreibungen bemerkenswerter Änderungen an populärer
Bitcoin-Infrastruktursoftware.

## Nachrichten

- **Identifizierung von Knoten mittels `addr`-Nachrichten:**
  Daniela Brozzoni [postete][brozzoni addr] auf Delving Bitcoin über Forschungen, die sie
  zusammen mit Entwickler Naiyoma durchführte, um denselben Knoten in mehreren Netzwerken
  anhand der von ihm gesendeten `addr`-Nachrichten zu identifizieren. Knoten senden
  P2P-Protokoll-`addr`-(Adress-)Nachrichten an ihre Peers, um andere potenzielle Knoten
  zu bewerben und es Peers zu ermöglichen, sich über ein dezentrales Gossip-System zu
  finden. Brozzoni und Naiyoma konnten jedoch einzelne Knoten anhand von Details aus
  ihren spezifischen Adressnachrichten eindeutig identifizieren, was es ihnen ermöglichte,
  denselben Knoten zu erkennen, der in mehreren Netzwerken läuft (wie IPv4 und
  [Tor][topic anonymity networks]).

  Die Forscher schlagen zwei mögliche Gegenmaßnahmen vor: das Entfernen von Zeitstempeln
  aus Adressnachrichten oder, falls die Zeitstempel beibehalten werden, diese leicht zu
  randomisieren, um sie weniger spezifisch für bestimmte Knoten zu machen.

- **Verwendet irgendeine Software `H` in Deskriptoren?**
  Ava Chow [postete][chow hard] in der Bitcoin-Dev-Mailingliste die Frage, ob irgendeine
  Software Deskriptoren mit Großbuchstaben-H generiert, um einen gehärteten
  [BIP32][topic bip32]-Schlüssel-Ableitungsschritt anzuzeigen. Falls nicht, könnte die
  [BIP380][]-Spezifikation von [Output Script Deskriptoren][topic descriptors] so
  modifiziert werden, dass nur Kleinbuchstaben-h und `'` zur Anzeige der Härtung
  verwendet werden dürfen. Chow bemerkt, dass, obwohl BIP32 Großbuchstaben-H erlaubt,
  die BIP380-Spezifikation zuvor einen Test enthielt, der die Verwendung von
  Großbuchstaben-H verbietet, und Bitcoin Core derzeit Großbuchstaben-H nicht akzeptiert.

## Ausgewählte Fragen & Antworten von Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] ist einer der ersten Orte, an denen die
Optech-Mitwirkenden nach Antworten auf ihre Fragen suchen – oder wenn wir etwas Zeit
haben, um neugierige oder verwirrte Nutzer zu unterstützen. In diesem monatlichen
Abschnitt heben wir einige der bestbewerteten Fragen und Antworten hervor, die seit
unserem letzten Update gepostet wurden.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3A1m..%20is%3Aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Gibt es eine Möglichkeit, Bitcoin Knots-Knoten als meine Peers zu blockieren?]({{bse}}127456)
  Vojtěch Strnad bietet einen Ansatz zum Blockieren von Peers basierend auf
  User-Agent-Strings mit zwei Bitcoin Core RPCs, rät jedoch von einem solchen Ansatz ab
  und verweist auf ein verwandtes [Bitcoin Core GitHub Issue][Bitcoin Core #30036] mit
  ähnlicher Abratung.

- [Was macht OP_CAT mit Ganzzahlen?]({{bse}}127436)
  Pieter Wuille erklärt, dass Bitcoin Script Stack-Elemente keine Datentypinformationen
  enthalten und verschiedene Opcodes die Bytes des Stack-Elements auf unterschiedliche
  Weise interpretieren.

- [Asynchrones Block-Relay mit Compact Block Relay (BIP152)]({{bse}}127420)
  Benutzer bca-0353f40e skizziert Bitcoin Cores Behandlung von [Compact Blocks][topic
  compact block relay] und schätzt die Auswirkungen fehlender Transaktionen auf die
  Blockpropagation.

- [Warum sind Angreifer-Einnahmen beim Selfish Mining disproportional zu ihrer Hash-Power?]({{bse}}53030)
  Antoine Poinsot folgt auf diese und [eine andere]({{bse}}125682) ältere [Selfish
  Mining][topic selfish mining]-Frage und weist darauf hin: „Die Schwierigkeitsanpassung
  berücksichtigt verwaiste Blöcke nicht, was bedeutet, dass die Verringerung der
  effektiven Hashrate konkurrierender Miner die Gewinne eines Miners (über einen
  ausreichend langen Zeitraum) genauso stark erhöht wie die Erhöhung seiner eigenen"
  (siehe [Newsletter #358][news358 selfish mining]).

## Releases und Release-Kandidaten

*Neue Releases und Release-Kandidaten für populäre Bitcoin-Infrastrukturprojekte.
Bitte erwägen Sie, auf neue Releases zu aktualisieren oder beim Testen von
Release-Kandidaten zu helfen.*

- [Bitcoin Core 28.2][] ist ein Wartungs-Release für die vorherige Release-Serie der
  vorherrschenden Full-Node-Implementierung. Es enthält mehrere Fehlerbehebungen.

## Wichtige Code- und Dokumentationsänderungen

*Bemerkenswerte aktuelle Änderungen in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo], [LND][lnd repo],
[libsecp256k1][libsecp256k1 repo], [Hardware Wallet Interface (HWI)][hwi repo],
[Rust Bitcoin][rust bitcoin repo], [BTCPay Server][btcpay server repo], [BDK][bdk repo],
[Bitcoin Improvement Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition repo] und
[BINANAs][binana repo].*

- [Bitcoin Core #31981][] fügt eine `checkBlock`-Methode zur Inter-Process-Communication
  (IPC) `Mining`-Schnittstelle hinzu (siehe Newsletter [#310][news310 ipc]), die
  dieselben Gültigkeitsprüfungen wie der `getblocktemplate`-RPC im `proposal`-Modus
  durchführt. Dies ermöglicht es Mining-Pools, die [Stratum v2][topic pooled mining]
  verwenden, Block-Templates von Minern über die schnellere IPC-Schnittstelle zu
  validieren, anstatt bis zu 4 MB JSON über RPC zu serialisieren. Die Proof-of-Work-
  und Merkle-Root-Prüfungen können in den Optionen deaktiviert werden.

- [Eclair #3109][] erweitert seine Unterstützung für [attributable failures][topic
  attributable failures] (siehe Newsletter [#356][news356 failures]) auf [Trampoline
  Payments][topic trampoline payments]. Ein Trampoline-Knoten entschlüsselt und
  speichert nun den für ihn bestimmten Teil der Attributions-Payload und bereitet den
  verbleibenden Blob für den nächsten Trampoline-Hop vor. Dieser PR implementiert nicht
  die Weiterleitung der Attributionsdaten für Trampoline-Knoten, was in einem
  Follow-up-PR erwartet wird.

- [LND #9950][] fügt ein neues `include_auth_proof`-Flag zu den `DescribeGraph`-,
  `GetNodeInfo`- und `GetChanInfo`-RPCs und zu ihren entsprechenden `lncli`-Befehlen
  hinzu. Die Einbeziehung dieses Flags gibt die [Channel-Announcement][topic channel
  announcements]-Signaturen zurück, was die Validierung von Channel-Details durch
  Drittanbieter-Software ermöglicht.

- [LDK #3868][] reduziert die Präzision der [HTLC][topic htlc]-Haltezeit für
  [attributable failure][topic attributable failures]-Payloads (siehe Newsletter
  [#349][news349 attributable]) von 1-Millisekunden- auf 100-Millisekunden-Einheiten,
  um Timing-Fingerprint-Lecks zu mindern. Dies bringt LDK mit den neuesten Updates zum
  [BOLTs #1044][]-Entwurf in Einklang.

- [LDK #3873][] erhöht die Verzögerung für das Vergessen eines Short Channel Identifier
  (SCID), nachdem sein Finanzierungs-Output ausgegeben wurde, von 12 auf 144 Blöcke, um
  die Verbreitung eines [Splicing][topic splicing]-Updates zu ermöglichen. Dies ist das
  Doppelte der 72-Block-Verzögerung, die in [BOLTs #1270][] eingeführt und von Eclair
  implementiert wurde (siehe Newsletter [#359][news359 eclair]). Dieser PR implementiert
  auch zusätzliche Änderungen am `splice_locked`-Nachrichtenaustauschprozess.

- [Libsecp256k1 #1678][] fügt eine `secp256k1_objs` CMake-Interface-Bibliothek hinzu,
  die alle Objektdateien der Bibliothek bereitstellt, um es übergeordneten Projekten wie
  Bitcoin Cores geplantem [libbitcoinkernel][libbitcoinkernel project] zu ermöglichen,
  diese Objekte direkt in ihre eigenen statischen Bibliotheken zu verlinken. Dies löst
  das Problem, dass CMake keinen nativen Mechanismus zum Verlinken statischer
  Bibliotheken in eine andere hat, und erspart nachgelagerten Nutzern die Bereitstellung
  ihrer eigenen `libsecp256k1`-Binärdatei.

- [BIPs #1803][] klärt die [BIP380][]-[Deskriptor][topic descriptors]-Grammatik, indem
  alle gängigen gehärteten Pfad-Markierungen erlaubt werden, während [#1871][bips #1871],
  [#1867][bips #1867] und [#1866][bips #1866] [BIP390][]s [MuSig2][topic
  musig]-Deskriptoren verfeinern, indem Schlüsselpfad-Regeln verschärft, wiederholte
  Teilnehmerschlüssel erlaubt und Multipath-Kind-Ableitungen explizit eingeschränkt
  werden.

{% include snippets/recap-ad.md when="2025-07-01 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="31981,3109,9950,3868,3873,1678,1803,1871,1867,1866,30036,1044,1270" %}
[bitcoin core 28.2]: https://bitcoincore.org/bin/bitcoin-core-28.2/
[brozzoni addr]: https://delvingbitcoin.org/t/fingerprinting-nodes-via-addr-requests/1786/
[chow hard]: https://mailing-list.bitcoindevs.xyz/bitcoindev/848d3d4b-94a5-4e7c-b178-62cf5015b65f@achow101.com/T/#u
[news358 selfish mining]: /de/newsletters/2025/06/13/#berechnung-des-schwellenwerts-fur-selfish-mining
[news310 ipc]: /en/newsletters/2024/07/05/#bitcoin-core-30200
[news356 failures]: /de/newsletters/2025/05/30/#eclair-3065
[news349 attributable]: /de/newsletters/2025/04/11/#ldk-2256
[news359 eclair]: /de/newsletters/2025/06/20/#eclair-3110
[libbitcoinkernel project]: https://github.com/bitcoin/bitcoin/issues/27587
