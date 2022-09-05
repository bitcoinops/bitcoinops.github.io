---
title: 'Bitcoin Optech Newsletter #214'
permalink: /de/newsletters/2022/08/24/
name: 2022-08-24-newsletter-de
slug: 2022-08-24-newsletter-de
type: newsletter
layout: newsletter
lang: de
---
Der Newsletter dieser Woche verweist auf die Übersicht eines Leitfadens über
Channel-Jamming-Angriffe und fasst mehrere Aktualisierungen eines PRs für stille
Zahlungen zusammen. Ebenfalls enthalten sind unsere regelmäßigen Abschnitte mit
Änderungen an beliebten Diensten und Clients, Ankündigungen neuer Releases und
Release-Candidates, sowie Zusammenfassungen erwähnenswerter Änderungen an
beliebter Bitcoin Infrastruktursoftware.

## News

- **Übersicht über Channel-Jamming-Angriffe und Abhilfemaßnahmen:** Antoine
  Riard und Gleb Naumenko [kündigten][riard jam] auf der Lightning-Dev
  Mailingliste die [Publikation][rn jam] eines Leitfaden zu
  [Channel-Jamming-Angriffen][topic channel jamming attacks], sowie mehrere
  dazugehörige Lösungen an. Der Leitfaden untersucht auch, wie auf LN aufbauende
  Protokolle, wie Swap-Protokolle und kurzzeitige [DLCs][topic dlc], von den
  vorgeschlagenen Lösungen profitieren können.

- **Aktualisierter PR für stille Zahlungen:** woltx [postete][woltx sp] auf der
  Bitcoin-Dev Mailingliste, dass der Bitcoin Core PR für [stille Zahlungen]
  [topic silent payments] aktualisiert wurde. Stille Zahlungen
  bieten eine Adresse, die von verschiedenen Zahlern wiederverwendet werden
  kann, ohne dass eine Verbindung zwischen diesen Ausgaben geschaffen wird, die
  onchain beobachtet werden kann. Der Empfänger muss jedoch darauf achten, dass
  die Privatsphäre nicht durch nachfolgenden Handlungen geschwächt wird. Die
  wichtigste Änderung am PR ist das Hinzufügen eines neuen Typs von
  [Output-Script Deskriptor][topic descriptors] für stille Zahlungen.

    Das Design des neuen Deskriptors wurde sehr ausführlich im PR
    diskutiert. Es wurde angemerkt, dass es am effizientesten für die
    Überwachung von neuen Transaktionen wäre, für Deskriptoren von stillen
    Zahlungen, pro Wallet nur einen einzigen Deskriptor zuzulassen. Dies könne
    jedoch in vielen Fälle zu einem schlechten Benutzererlebnis führen. Um
    dieses Problem zu adressieren wurde eine geringfügige Änderung am Design
    vorgeschlagen, welche allerdings auch Nachteile mit sich bringt.

## Änderungen an Services und Client Software
*In dieser monatlichen Rubrik beleuchten wir interessante Updates zu
Bitcoin-Wallets und Dienstleistungen.*

- **Purse.io unterstützt künftig Lightning:**
  In einem [aktuellen Tweet][purse ln tweet] kündigte Purse.io die Unterstützung
  für Einzahlungen(Empfangen) und Abhebungen(Senden) über das Lightning Netzwerk
  an.

- **Proof-of-concept coinjoin Implementierung joinstr:**
  1440000bytes entwickelt [joinstr][joinstr github], eine Proof-of-Concept
  [coinjoin][topic coinjoin] Implementierung unter Verwendung des
  [nostr-Protokolls][nostr github]; eines auf öffentlichen Schlüsseln
  basierenden Relay-Netzwerks ohne zentralen Server.

- **Coldcard Firmware 5.0.6 veröffentlicht:**
  Coldcard’s Version 5.0.6 fügt mehr Unterstützung für [BIP85][], `OP_RETURN`
  Skripte und Multisig-[Deskriptoren][topic descriptors] hinzu.

- **Nunchuk fügt taproot Unterstützung hinzu:**
  In der neuesten Versions von [Nunchuk's mobilem Wallet][nunchuk appstore],
  wurden [taproot][topic taproot] (single-sig), [signet][topic signet] und
  erweiterte [PSBT][topic psbt]-unterstützung hinzugefügt.

## Releases und Release-Kandidaten

*Neue Releases und Release-Kandidaten für beliebte Bitcoin
Infrastrukturprojekte. Bitte erwäge auf die neuen Versionen
zu wechseln oder beim Testen von Release candidates auszuhelfen.*

- [BDK 0.21.0][] ist der neueste Release dieser Bibliothek für den Bau von
  Wallets.

- [Core Lightning 0.12.0][] ist ein Release der nächsten Hauptversion dieser
  beliebten LN-Node-Implementierung. Er enthält ein neues `bookkeeper`-Plugin
  (siehe [Newsletter #212][news212 bookkeeper]), ein `commando`-Plugin
  (siehe [Newsletter #210][news210 commando]), fügt Unterstützung für
  [statische Channel-Backups][topic static channel backups] hinzu, und gibt
  explizit berechtigten Peers die Möglichkeit [zero-conf Kanäle]
  [topic zero-conf channels] für ihren Node zu öffnen. Zu diese Funktionen
  kommen zusätzlich viele andere neue Funktionen und Fehlerkorrekturen hinzu.

- [LND 0.15.1-beta.rc1][] ist ein Release-Kandidat, der "Unterstützung
  für [Zero-Conf-Kanäle][topic zero-conf channels] und scid-[Aliase][aliases]
  enthält, [und der] überall zur Verwendung von [taproot]
  [topic taproot]-Adressen wechselt".

## Nennenswerte Code- und Dokumentationsänderungen

*Erwähnenswerte Änderungen diese Woche in [Bitcoin Core][bitcoin core repo],
[Core Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], und [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #25504][] ergänzt die Antworten auf `listsinceblock`,
  `listtransactions`, und `gettransactions` um die zugehörigen
  Deskriptoren in dem neuen Feld `parent_descs`. Zusätzlich, kann
  `listsinceblock` nun angewiesen werden, explizit die Wechselgeld-Outputs mit
  dem optionalen Parameter `include_change` aufzulisten. Normalerweise werden
  Wechselgeld-Outputs als implizite Nebenprodukte von ausgehenden Zahlungen
  weggelassen. Ihre Auflistung könnte im Kontext von Watch-Only-Deskriptoren
  aber interessant sein.

- [Eclair #2234][] fügt Unterstützung für DNS-Namen in Ankündigungen von Nodes
  hinzu, wie es jetzt von [BOLTs #911][] erlaubt wird (siehe [Newsletter
  #212][news212 bolts911]).

- [LDK #1503][] fügt Unterstützung für [Onion-Nachrichten][topic onion messages]
  hinzu, wie in [BOLTs #759][] definiert. Der PR deutet an, dass diese Änderung
  eine Vorbereitung für die Unterstützung von [Offers][topic offers] ist, welche
  später hinzugefügt werden kann.

- [LND #6596][] fügt einen neuen `wallet addresses list`-RPC hinzu, der alle
  Adressen eines Wallets und deren aktuelle Kontostände auflistet.

- [BOLTs #1004][] empfiehlt, dass Nodes, welche routing-relevante Informationen
  über Kanäle aufbewahren, mit dem Löschen dieser Informationen mindestens 12
  Blöcke warten, nachdem ein Kanal geschlossen wurde. Die verzögerte Löschung
  ermöglicht das Erkennen von [splices][topic splicing], worin ein Kanal nicht
  wirklich geschlossen wird, sondern stattdessen weitere Mittel in einer
  Onchain-Transaktion hinzugefügt oder entfernt werden.

{% include references.md %}
{% include linkers/issues.md v=2 issues="25504,2234,1503,911,759,6596,1004" %}
[core lightning 0.12.0]: https://github.com/ElementsProject/lightning/releases/tag/v0.12.0
[bdk 0.21.0]: https://github.com/bitcoindevkit/bdk/releases/tag/v0.21.0
[lnd 0.15.1-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.15.1-beta.rc1
[news212 bolts911]: /de/newsletters/2022/08/10/#bolts-911
[aliases]: /en/newsletters/2022/07/13/#lnd-5955
[woltx sp]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-August/020883.html
[riard jam]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-August/003673.html
[rn jam]: https://jamming-dev.github.io/book/
[news210 commando]: /de/newsletters/2022/07/27/#core-lightning-5370
[news212 bookkeeper]: /en/newsletters/2022/08/10/#core-lightning-5071
[joinstr github]: https://github.com/1440000bytes/joinstr
[nostr github]: https://github.com/nostr-protocol/nostr
[nunchuk appstore]: https://apps.apple.com/us/app/nunchuk-bitcoin-wallet/id1563190073
[purse ln tweet]: https://twitter.com/PurseIO/status/1557495102641246210
