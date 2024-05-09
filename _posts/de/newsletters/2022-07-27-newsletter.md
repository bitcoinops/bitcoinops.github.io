---
title: 'Bitcoin Optech Newsletter #210'
permalink: /de/newsletters/2022/07/27/
name: 2022-07-27-newsletter-de
slug: 2022-07-27-newsletter-de
type: newsletter
layout: newsletter
lang: de
---
Der Newsletter dieser Woche beschreibt ein vorgeschlagenes BIP zur Erstellung
signierter Nachrichten für nicht-legacy Adressen und fasst eine Diskussion über
das nachweisliche Verbrennen kleiner Bitcoin-Beträge zum Schutz vor Denial-of-
Service Attacken zusammen. Ebenfalls enthalten sind unsere regelmäßigen
Abschnitte mit beliebten Fragen und Antworten aus dem Bitcoin Stack Exchange,
Ankündigungen neuer Releases und Release candidates sowie Zusammenfassungen
erwähnenswerter Änderungen an beliebter Bitcoin Infrastruktursoftware.

## News

- **Multiformat single-sig message signing:**
  Bitcoin Core und viele andere Wallets unterstützen seit langem das Signieren
  und Verifizieren beliebiger Nachrichten, wenn der Schlüssel mit dem sie
  signiert wurden zu einer P2PKH-Adresse gehört. Für alle andere Adresstypen,
  einschließlich Adressen die single-sig P2SH-P2WPKH, native P2WPKH und
  P2TR-Ausgaben abdecken, unterstützt Bitcoin Core das Signieren oder
  Verifizieren von beliebigen Nachrichten nicht.

  Ein früherer Vorschlag, [BIP322][], zur Bereitstellung
  [vollständig generischer Nachrichten Signierung][topic generic signmessage],
  die mit jedem Skript funktionieren könnte, wurde noch nicht
  in Bitcoin Core integriert ([bitcoin core #24058]) oder zu anderen uns bekannten,
  populären Wallets hinzugefügt.

  Diese Woche [schlug Ali Sherief vor][sherief gsm], dass derselbe
  Signieralgorithmus der für P2WPKH verwendet wird, auch für andere
  Outputtypen verwendet werden könnte. Für die Verifizierung sollten Programme
  herleiten, wie der Schlüssel abzuleiten sei (falls erforderlich)
  und die Signatur anhand des Adresstyps verifizieren. Z.B. wenn eine
  [bech32][topic bech32]-Adresse mit einem 20-Byte Datenelement vorliegt,
  ist anzunehmen, dass es sich um eine P2WPKH-Ausgabe handelt.

  Der Entwickler Peter Gray [merkte an][gray cc], dass ColdCard
  Wallets bereits auf diese Weise Signaturen erstellen und der Entwickler
  Craig Raw [entgegnete][raw sparrow], dass das Sparrow Wallet in der Lage
  ist diese Signaturen zu validieren. Der Ansatz sei, zuerst den
  [BIP137][] Validierungsregeln zu folgen und erst dann dem Vorgehen von
  Electrum.

  Sherief plant ein BIP zu schreiben, welches das Verhalten spezifiziert.

- **Proof of micro-burn:** mehrere Entwickler [diskutierten][pomb]
  Anwendungsfälle und Entwürfe von Onchain-Transaktionen, die bitcoins
  in kleinen Schritten zerstören ("burn" bitcoins) als Beweis des
  Ressourcenverbrauchs. Um ein Beispiel für einen Anwendungsfall von Ruben
  Somsen [aus dem Thread][somsen hashcash] zu erweitern, wäre die Idee es
  100 Nutzern zu erlauben ihren E-Mails jeweils einen Beweis, dass $1 in
  bitcoins verbrannt wurden anzuhängen, was die Art von Anti-Spam-Schutz bieten würde
  der ursprünglich als Vorteil von [hashcash][] vorgesehen war.

  Es wurden mehrere Lösungen mit Merkle-Bäumen diskutiert. Ein Teilnehmer
  meinte, dass die geringen Beträge um die es sich handelt nahelegen,
  dass Vertrauen (oder teilweises Vertrauen) der Beteiligten in eine zentrale
  Drittpartei eine vernünftige Lösung darstellen könnte, um unnötige
  Komplexität zu vermeiden.

## Ausgewählte Q&A aus dem Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] ist eine der Plattformen auf denen
Optech-Mitwirkende zuerst nach Antworten auf ihre Fragen suchen–oder wenn wir
einige Augenblicke Zeit haben, anderen neugierigen oder verwirrten Nutzern
aushelfen. In dieser monatlichen Rubrik stellen wir einige der populärsten
Fragen und Antworten des letzten Monats vor.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Warum werden ungültige Signaturen in `OP_CHECKSIGADD` nicht auf den Stack gepusht?]({{bse}}114446)
  Chris Stewart fragt warum "wenn eine ungültige
  Signatur gefunden wurde, die Ausführung des Interpreter fehlschlägt,
  anstelle dass sie fortgeführt wird." Pieter Wuille erklärt, dass dieses
  Verhalten in BIP340-342 definiert ist und dazu konzipiert wurde zukünftig
  Stapelvalidierungen von [Schnorr Signaturen][topic schnorr signatures] zu
  unterstützen. Andrew Chow nennt einen weiteren Grund für dieses Verhalten und
  merkt an, dass bestimmte Malleability-Bedenken durch diesen Ansatz ebenfalls
  entschärft werden.

- [Was sind Pakete in Bitcoin Core und was ist deren Anwendungsfall?]({{bse}}114305)
  Antoine Poinsot erklärt [Pakete][bitcoin docs packages]
  (eine Gruppierung von verwandten Transaktionen), deren Zusammenhang zu
  [Paketweiterleitung][topic package relay], und ein jüngstes
  [package relay BIP proposal][news201 package relay].

- [Wieviel Blockspace wird beansprucht wenn das komplette UTXO-Set ausgegeben werden würde?]({{bse}}114043)
  Murch erforscht ein hypothetisches Szenario in dem alle existierenden UTXOs
  konsolidiert würden. Er stellt Blockspace-Berechnungen für jeden Output-Typ zur
  Verfügung und schlussfolgert, dass der Prozess ca. 11,500 Blöcke in Anspruch
  nehmen würde.

- [Muss ein unwirtschaftlicher Output im UTXO-Set verbleiben?]({{bse}}114493)
  Stickies-v merkt an, dass während nachweislich unverbrauchbare UTXOs
  (einschließlich `OP_RETURN` oder Skripte, die größer als die maximale
  Skriptgröße sind), aus dem UTXO Satz entfernt werden, das Entfernen von
  [unwirtschaftlichen Outputs][topic uneconomical outputs] zu Probleme führen
  kann; einschließlich eines Hard Forks, falls diese Outputs ausgegeben werden,
  wie Pieter Wuille anmerkt.

- [Gibt es Code in libsecp256k1 welcher in die Bitcoin Core Codebasis verschoben werden sollte?]({{bse}}114467)
  Ähnlich wie bei anderen Bemühungen, Bereiche der Bitcoin Core Codebasis wie
  [libbitcoinkernel][libbitcoinkernel project] oder [process separation][devwiki process separation]
  zu modularisieren, stellt Pieter Wuille einen klaren Verantwortungsbereich des
  [libsecp256k1][]-Projekts fest: alles, was Operationen mit privaten oder
  öffentlichen Schlüsseln beinhaltet.

- [Schürfen von abgestandenen low-difficulty Blöcken als DoS-Attacke]({{bse}}114241)
  Andrew Chow erklärt dass [assumevalid][assumevalid notes] und seit neuerem
  [`nMinimumChainWork`][Bitcoin Core #9053] dabei helfen low-difficulty
  Chain-Attacken herauszufiltern.

## Releases und Release candidates

*Neue Releases und Release candidates für beliebte Bitcoin
Infrastrukturprojekte. Bitte erwäge auf die neuen Versionen
zu wechseln oder beim Testen von Release candidates auszuhelfen.*

- [BTCPay Server 1.6.3][] fügt neue Features, Verbesserungen und Bugfixes
  zu diesem populären, selbstgehosteten Zahlungsabwickler hinzu.

- [LDK 0.0.110][] fügt mehrere neue Features für den Bau von LN-aktivierten
  Applikationen zur Bibliothek hinzu (viele davon in früheren Newslettern
  behandelt).

## Nennenswerte Code- und Dokumentationsänderungen

*Erwähnenswerte Änderungen diese Woche in [Bitcoin Core][bitcoin core repo],
[Core Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], und [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #25351][] stellt sicher, dass nach einem Import von Adressen,
  Schlüsseln oder Deskriptoren in ein Wallet der anschließende Re-scan nicht nur
  die Blockchain scannt, sondern auch prüft ob Transaktionen im
  Mempool für das Wallet relevant sind.

- [Core Lightning #5370][] re-implementiert das `commando` Plugin und macht
  es zu einem Bestandteil von CLN. Commando erlaubt es einem Node, Befehle von
  autorisierten Peers über LN-Nachrichten zu empfangen. Peers werden autorisiert
  durch *runes*, einem selbsterstellten CLN-Protokoll, das auf einer vereinfachten
  Version von [macaroons][] basiert.  Obwohl Commando jetzt in CLN integriert
  ist, ist es nur funktionsfähig, wenn ein Benutzer Runen-Authentifizierungstoken
  erstellt. Weiter Informationen findest Du in den CLN-Handbuchseiten für
  [commando][] und [commando-rune][].

- [BOLTs #1001][] empfiehlt, dass Nodes, die eine Änderung ihrer
  Zahlungsweiterleitungsrichtlinien bekannt geben, noch für etwa 10 Minuten
  Zahlungen annehmen welche die alten Richtlinien erfüllen.
  Dadurch wird verhindert, dass Zahlungen fehlschlagen, wenn dem Absender
  die Aktualisierung der Richtlinien noch unbekannt war.
Im [Newsletter #169][news169 cln4806] findest Du ein Beispiel einer
  Implementierung, die eine solche Regel anwendet.

{% include references.md %}
{% include linkers/issues.md v=2 issues="25351,5370,1001,24058,9053" %}
[BTCPay Server 1.6.3]: https://github.com/btcpayserver/btcpayserver/releases/tag/v1.6.3
[LDK 0.0.110]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.0.110
[commando]: https://github.com/rustyrussell/lightning/blob/2e13b72f55080be07ea68de77976eb990a043f5d/doc/lightning-commando.7.md
[commando-rune]: https://github.com/rustyrussell/lightning/blob/2e13b72f55080be07ea68de77976eb990a043f5d/doc/lightning-commando-rune.7.md
[news169 cln4806]: /en/newsletters/2021/10/06/#c-lightning-4806
[sherief gsm]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020759.html
[gray cc]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020762.html
[raw sparrow]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020766.html
[pomb]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020745.html
[hashcash]: https://en.wikipedia.org/wiki/Hashcash
[somsen hashcash]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020746.html
[macaroons]: https://en.wikipedia.org/wiki/Macaroons_(computer_science)
[bitcoin docs packages]: https://github.com/bitcoin/bitcoin/blob/53b1a2426c58f709b5cc0281ef67c0d29fc78a93/doc/policy/packages.md#definitions
[news201 package relay]: /en/newsletters/2022/05/25/#package-relay-proposal
[libbitcoinkernel project]: https://github.com/bitcoin/bitcoin/issues/24303
[devwiki process separation]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/Process-Separation
[assumevalid notes]: https://bitcoincore.org/en/2017/03/08/release-0.14.0/#assumed-valid-blocks
