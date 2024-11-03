---
title: 'Bitcoin Optech Newsletter #221'
permalink: /de/newsletters/2022/10/12/
name: 2022-10-12-newsletter-de
slug: 2022-10-12-newsletter-de
type: newsletter
layout: newsletter
lang: de
---
Der Newsletter dieser Woche fasst einen Vorschlag zusammen, der es
gelegentlichen LN-Nutzern erlaubt, bis zu mehreren Monaten offline zu bleiben
und beschreibt ein Dokument darüber wie Transaktionsinformationsserver
unbenutzte Wallet-Adressen bereitstellen könnten. Ebenfalls enthalten sind
unsere reguläre Zusammenfassung des Bitcoin Core PR Review Clubs, Ankündigungen
neuer Releases und Release-Kandidaten (einschließlich eines kritischen
LND-Fixes), sowie erwähnenswerte Änderungen an beliebten Bitcoin
Infrastrukturprojekten.

## News

- **Vorschlag für LN mit langen Timeouts:** John Law hat einen [Vorschlag][law pdf]
  auf der Lightning-Dev-Mailingliste [gepostet][law post], der es gelegentlichen
  Lightning-Benutzern erlauben würde, bis zu mehrere Monate offline zu bleiben,
  ohne Gefahr zu laufen, Kapital an ihre Channel-Partner zu verlieren. Obwohl im
  aktuellen LN-Protokoll technisch möglich, bedingt es, dass die
  Settlement-Verzögerung-Parameter auf hohe Werte gesetzt werden, was es in einem
  Störfall oder einem Griefing-Nutzer erlauben würde, die Verwendung von
  Kapital in mehr als einem Dutzend Channels für dieselben Monate zu verhindern.
  Der Vorschlag von Law entschärft dieses Problem durch zwei Protokolländerungen:

  - *Getriggerte HTLCs:* Bei einem standardmäßigen [HTLC][topic htlc],
    der für Zahlungen verwendet wird, bietet Alice Bob einen bestimmten Betrag
    in BTC an, wenn er ein zuvor unbekanntes *Preimage* für einen bekannten
    Hash Digest veröffentlichen kann. Wenn Bob das Preimage nicht bis zu einem
    bestimmten Zeitpunkt veröffentlicht, kann Alice den Betrag wieder in ihr
    eigenes Wallet zurückzahlen.

    Law schlägt vor, dass Bob mit der Veröffentlichung des Preimage die
    Zahlung jederzeit einfordern kann, Alice aber eine zusätzliche Bedingung
    erfüllen muss. Sie müsste Bob deutlich vor ihrer Absicht warnen, den
    Betrag an ihr Wallet zurückzuzahlen, indem sie eine Trigger-Transaktion
    on-chain bestätigen lässt. Erst wenn die Trigger-Transaktion mit einer
    bestimmten Anzahl von Blöcken (oder nach einer bestimmte Dauer) bestätigt
    worden ist, kann Alice das Geld ausgeben.

    Damit wäre sichergestellt, dass Bob sein Geld jederzeit abrufen kann,
    bis zum Zeitpunkt zu dem die auslösende Transaktion die vereinbarte
    Anzahl von Bestätigungen erhalten hat; auch wenn seit dem Ablauf eines
    normalen HTLC Monate vergangen sind. Wenn Bob für seine Wartezeit
    angemessen entschädigt wird, dann ist es in Ordnung, wenn Alice die
    ganze Zeit über offline bleibt. Bei einem HTLC, der von Alice über Bob
    zu einem weit entfernten Knoten geleitet wird, wäre nur der Channel
    zwischen Alice und Bob betroffen - alle anderen Kanäle würden den HTLC
    umgehend abwickeln (wie im aktuellen LN-Protokoll).

  - *Asymmetrisch-verzögerte Commitment-Transaktionen:* Jeder der beiden
    Partner in einem LN-Channel besitzt eine unveröffentlichte
    Commitment-Transaktion, die er jederzeit veröffentlichen und bestätigen
    lassen kann. Beide Versionen der Transaktion verwenden dieselbe UTXO, so
    dass sie miteinander kollidieren, d.h. nur eine kann tatsächlich bestätigt
    werden.

    Das bedeutet, dass Alice, wenn sie den Channel schließen will, nicht
    einfach ihre Version der Commitment-Transaktion mit einer angemessenen
    Gebührenrate senden und davon ausgehen kann, dass sie bestätigt wird.
    Sie muss auch abwarten und prüfen, ob Bob stattdessen seine Version der
    Commitment-Transaktion bestätigt bekommt. In diesem Fall muss sie
    möglicherweise zusätzliche Maßnahmen ergreifen, um zu überprüfen, ob
    seine Transaktion den neuesten Channel-Status enthält.

    Law schlägt vor, dass Alices Version der Commitment-Transaktion gleich
    bleibt wie heute, so dass sie diese jederzeit veröffentlichen kann, dass
    aber Bobs Version eine Zeitsperre enthält, so dass er sie nur
    veröffentlichen kann, wenn Alice lange Zeit inaktiv war. Im Idealfall
    ermöglicht dies Alice, den neuesten Channel-Status in der Gewissheit zu
    veröffentlichen, dass Bob keine gegenteilige Version veröffentlichen
    kann, was ihr erlaubt nach der Veröffentlichung sicher offline zugehen.

  Als diese Beschreibung verfasst wurde, waren die ersten Rückmeldungen auf
  die Vorschläge von Law noch nicht abgeschlossen.

- **Empfehlungen für eindeutige Adress-Server:** Ruben Somsen hat auf der
  Bitcoin-Dev-Mailingliste ein [Dokument][somsen gist] mit einem weiteren
  Vorschlag [gepostet][somsen post], wie Nutzer [Output-Linking][topic output linking]
  vermeiden können, ohne einem Drittanbieter-Service zu vertrauen oder ein
  kryptographisches Protokoll zu verwenden, das derzeit nicht weitgehend
  unterstützt wird; wie [BIP47][] oder [stille Zahlungen][topic silent payments].
  Die empfohlene Methode ist vor allem für Wallets gedacht, die ihre Adressen
  bereits an Dritte weitergeben. Z.B. solche, die öffentliche
  [Address-Verzeichnisserver][topic block explorers] verwenden (was vermutlich
  die Mehrheit der Lightweight Wallets betrifft).

  Ein Beispiel dafür, wie die Methode funktionieren könnte:
  Alices Wallet registriert 100 Adressen auf dem Electrum-Server example.com.
  Sie fügt dann "example.com/alice" in ihre E-Mail-Signatur ein. Wenn Bob
  Alice Geld spenden möchte, besucht er ihre URL, ruft eine Adresse ab,
  überprüft, ob Alice sie signiert hat, und überweist dann an die Adresse.

  Die Idee hat den Vorteil, dass sie durch einen teilweise manuellen Prozess
  bereits mit vielen Wallets kompatibel ist und sich möglicherweise leicht
  durch einen automatisierten Prozess umsetzen lässt. Der Nachteil ist, dass
  Nutzer, die bereits ihre Privatsphäre durch das Teilen von Adressen mit
  einem Server gefährden, darin bestärkt werden ihren Verlust von Privatsphäre
  fortzusetzen.

  Zum Zeitpunkt der Erstellung dieser Zusammenfassung wurden sowohl auf der
  Mailingliste als auch im Dokument die Vorschläge noch diskutiert.

## Bitcoin Core PR Review Club

*In dieser monatlichen Rubrik fassen wir ein kürzlich stattgefundenes Treffen
des [Bitcoin Core PR Review Club][] zusammen und stellen einige der wichtigsten
Fragen und Antworten vor. Klicke unten auf eine Frage, um eine Zusammenfassung
der Antwort anzusehen.*

[Make AddrFetch connections to fixed seeds][review club 26114]
ist ein PR von Martin Zumsande, der `AddrFetch` Verbindungen zu
den [fixen Seeds][fixed seeds] (fix kodierten IP-Adressen) herstellt,
anstatt sie nur zu `AddrMan` (der Datenbank unserer Peers) hinzuzufügen.

{% include functions/details-list.md
  q0="Wenn ein neuer Knoten von Grund auf neu startet, muss er sich zunächst mit
einigen Peers verbinden, von denen er den Initial Block Download (IBD)
durchführen wird. Unter welchen Umständen verbindet er sich mit den Fixed-
Seeds?"
  a0="Nur wenn er nicht in der Lage ist, sich mit Peers zu verbinden, deren
Adressen von den fix kodierten Bitcoin DNS Seed Nodes bereitgestellt werden.
Dies tritt am häufigsten auf, wenn der Knoten so konfiguriert ist, dass er
weder IPv4 noch IPv6 verwendet (zum Beispiel `-onlynet=tor`)."
  a0link="https://bitcoincore.reviews/26114#l-27"

  q1="Welche beobachtbare Verhaltensänderung führt dieser PR ein?
Welche Arten von Adressen fügen wir zu `AddrMan` hinzu, und unter welchen
Umständen?"
  a1="Anstatt die festen Seeds sofort zu seiner `AddrMan` hinzuzufügen und
vollständige Verbindungen zu einigen von ihnen herzustellen, stellt der Knoten
stattdessen `AddrFetch`-Verbindungen zu einigen von ihnen her und fügt die
_zurückgegebenen Adressen_ zu `AddrMan` hinzu. (`AddrFetch` sind
Kurzzeitverbindungen, die nur zum Abrufen von Adressen verwendet werden.)
Der Knoten verbindet sich dann mit einigen der Adressen, die sich jetzt in
seiner `AddrMan` befinden, um den IBD durchzuführen. Dies führt dazu, dass
eine geringere Anzahl vollständiger Verbindungen zu den Fixed-Seed-Knoten
hergestellt werden; stattdessen wird versucht mehr Verbindungen aus dem viel
größeren Set von Knoten, über die uns die Fixed-Seed-Knoten informieren,
herzustellen. `AddrFetch`-Verbindungen können _jede_ Art von Adressen
zurückgeben, z.B. `tor`; die Ergebnisse sind nicht auf IPv4 und IPv6 beschränkt."
  a1link="https://bitcoincore.reviews/26114#l-63"

  q2="Warum würden wir eine `AddrFetch`-Verbindung anstelle einer vollständigen,
ausgehenden Verbindung zu festen Seeds herstellen wollen? Warum könnte der
Knotenbetreiber hinter einem festen Seed dies ebenfalls bevorzugen?"
  a2="Eine `AddrFetch`-Verbindung ermöglicht es unserem Knoten, IBD-Peers aus
einer viel größeren Anzahl von Peers auszuwählen, was die Gesamtverteilung der
Netzwerkkonnektivität erhöht. Die Wahrscheinlichkeit, dass Betreiber fester
Seed-Knoten mehrere gleichzeitige IBD-Peers haben, wäre geringer; was den
Ressourcenbedarf ihrer Knoten verringert."
  a2link="https://bitcoincore.reviews/26114#l-77"

  q3="Von den DNS-Seed-Knoten wird erwartet, dass sie ansprechbar sind und
aktuelle Adressen von Bitcoin-Knoten liefern. Warum hilft das einem
`-onlynet=tor` Knoten nicht?"
  a3="Die DNS-Seed-Knoten bieten nur IPv4- und IPv6-Adressen an; sie sind nicht
in der Lage, andere Adresstypen zu liefern."
  a3link="https://bitcoincore.reviews/26114#l-35"
%}

## Releases und Release-Kandidaten

*Neue Releases und Release-Kandidaten für beliebte Bitcoin
Infrastrukturprojekte. Bitte erwäge auf die neuen Versionen
zu wechseln oder beim Testen von Release candidates auszuhelfen.*

- [LND v0.15.2-beta][] ist eine sicherheitskritischer Notfallrelease der einen
  Parsing-Fehler behebt, der LND daran hinderte, bestimmte Blöcke zu parsen.
  Es wird empfohlen dass alle Benutzer LND aktualisieren.

- [Bitcoin Core 24.0 RC1][] ist der erste Release-Kandidat für die nächste
  Version der am weitesten verbreiteten Full-Node-Implementierung des Netzwerks.
  Eine [Testanleitung][bcc testing] ist verfügbar.

## Nennenswerte Code- und Dokumentationsänderungen

*Erwähnenswerte Änderungen diese Woche in [Bitcoin Core][bitcoin core repo],
[Core Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], und [Lightning BOLTs][bolts repo].*

- [LND #6500][] fügt die Möglichkeit hinzu, den privaten Tor-Schlüssel auf der
  Festplatte mit dem privaten Schlüssel des Wallets zu verschlüsseln, anstatt
  ihn im Klartext zu speichern. Mit dem Flag `--tor.encryptkey` verschlüsselt
  LND den privaten Schlüssel und der verschlüsselte Blob wird in dieselbe Datei
  auf der Festplatte geschrieben. Dies erlaubt Benutzern dieselbe Funktionalität
  (wie das Aktualisieren eines versteckten Dienstes) zu behalten, bietet aber
  einen zusätzlichen Schutz in nicht vertrauenswürdigen Umgebungen.

{% include references.md %}
{% include linkers/issues.md v=2 issues="6500" %}
[review club 26114]: https://bitcoincore.reviews/26114
[bitcoin core 24.0 rc1]: https://bitcoincore.org/bin/bitcoin-core-24.0/
[bcc testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/24.0-Release-Candidate-Testing-Guide
[law post]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-October/003707.html
[law pdf]: https://raw.githubusercontent.com/JohnLaw2/ln-watchtower-free/main/watchtowerfree10.pdf
[somsen post]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-September/020952.html
[somsen gist]: https://gist.github.com/RubenSomsen/960ae7eb52b79cc826d5b6eaa61291f6
[news113 witasym]: /en/newsletters/2020/09/02/#witness-asymmetric-payment-channels
[lnd v0.15.2-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.15.2-beta
[fixed seeds]: https://github.com/bitcoin/bitcoin/tree/master/contrib/seeds
