---
title: 'Bitcoin Optech Newsletter #223'
permalink: /de/newsletters/2022/10/26/
name: 2022-10-26-newsletter-de
slug: 2022-10-26-newsletter-de
type: newsletter
layout: newsletter
lang: de
---
Der Newsletter dieser Woche fasst die Fortsetzung der Diskussion über die
Aktivierung von Full-RBF zusammen, bietet eine Übersicht über mehrere
Diskussionen aus einem CoreDev.tech Treffen und beschreibt einen Vorschlag für
flüchtige Anchor-Ausgaben, die für Vertragsprotokolle wie LN entwickelt wurden.
Ebenfalls enthalten sind unsere regelmäßigen Abschnitte mit Zusammenfassungen
beliebter Fragen und Antworten aus dem Bitcoin Stack Exchange, eine Liste neuer
Software-Releases und Release-Kandidaten, sowie erwähnenswerte Änderungen an
beliebten Bitcoin Infrastrukturprojekten.

## News

- **Fortsetzung der Diskussion über vollständige RBF:**
  Im [Newsletter][news222 rbf] von letzter Woche haben wir eine Diskussion auf
  der Bitcoin-Dev Mailingliste über die Aufnahme einer neuen
  `mempoolfullrbf`-Option zusammengefasst, die für einige Unternehmen, die
  Transaktionen mit Nullbestätigungen ("zero conf") als endgültige Zahlungen
  akzeptieren, Probleme verursachen könnte. Die Diskussion wurde diese Woche
  sowohl auf der Mailingliste als auch im IRC-Raum #bitcoin-core-dev fortgesetzt.
  Einige Highlights der Diskussion sind:

    - *Kostenlose Kaufoptionen Problem:* Sergej Kotliar
       [warnte][kotliar free option], dass seiner Meinung nach das größte
       Problem bei jeder Art von Transaktionsersatz darin besteht, dass dadurch
       eine kostenlose amerikanische Kaufoption entsteht. Beispiel: Die Kundin
       Alice möchte beim Händler Bob Widgets kaufen. Bob stellt Alice eine
       Rechnung über 1 BTC zum aktuellen Preis von 20.000 USD/BTC aus. Alice
       schickt Bob die 1 BTC in einer Transaktion mit einer niedrigen
       Gebührenrate. Die Transaktion bleibt unbestätigt als sich der Wechselkurs
       auf 25.000 USD/BTC ändert, was bedeutet, dass Alice nun 5.000 USD mehr
       zahlt. An diesem Punkt entscheidet sie sich ganz rational dafür, ihre
       Transaktion durch eine Transaktion zu ersetzen, bei der sie die BTC an
       sich selbst zurückbezahlt und die Transaktion somit annulliert. Hätte
       sich jedoch der Wechselkurs zu Alices Gunsten verändert (z.B. 15.000
       USD/BTC), kann Bob Alices Zahlung nicht stornieren und hat daher im
       normalen Onchain-Bitcoin-Transaktionsfluss keine Möglichkeit, die
       gleiche Option auszuüben, wodurch ein asymmetrisches Wechselkursrisiko
       entsteht. Im Vergleich dazu teilen sich Alice und Bob das gleiche
       Wechselkursrisiko, wenn ein Transaktionsersatz nicht möglich ist.

        Kotliar merkt an, dass das Problem bereits heute besteht, da [BIP125][]
        opt-in RBF zur Verfügung steht, ist aber der Ansicht, dass ein
        vollständiger [RBF][topic rbf] das Problem noch verschärfen würde.

        Greg Sanders und Jeremy Rubin [antworteten][sanders cpfp] in
        [separaten][rubin cpfp] E-Mails und wiesen darauf hin, dass Händler
        Bob den Minern einen Anreiz bieten könnte, die ursprüngliche Transaktion
        der Kundin Alice mit [CPFP][topic cpfp] zu bestätigen, insbesondere wenn
        [Paketweiterleitung][topic package relay] aktiviert ist.

        Antoine Riard [wies darauf hin][riard free option], dass das gleiche
        Risiko bei LN besteht, da Alice mit der Bezahlung der Rechnung des
        Händlers Bob bis kurz vor Ablauf der Frist warten könnte, so dass sie
        Zeit hätte, die Änderung des Wechselkurses abzuwarten. Wenn Bob jedoch
        feststellt, dass sich der Wechselkurs erheblich verändert hat, könnte er
        seinen Knoten anweisen, die Zahlung nicht anzunehmen und das Geld an
        Alice zurückzugeben.

    - *Bitcoin Core ist nicht für das Netzwerk verantwortlich:* Gloria Zhao
      [schrieb][zhao no control] in der IRC-Diskussion: "Ich denke, welche
      Option wir auch immer wählen, es sollte den Nutzern überdeutlich gemacht
      werden, dass Core nicht kontrolliert, ob Full RBF erfolgt oder nicht. Wir
      könnten [25353][bitcoin core #25353] rückgängig machen und es könnte immer
      noch vorkommen. [...]"

        Nach dem Treffen veröffentlichte Zhao auch einen detaillierten
        [Überblick][zhao overview] über die Situation.


    - *Keine Entfernung bedeutet, dass das Problem auftreten könnte:* In der
      IRC-Diskussion [wiederholte][towns uncoordinated] Anthony Towns seine
      Aussagen von letzter Woche: "Wenn wir die Option `mempoolfullrbf` nicht
      aus 24.0 entfernen, wird eine unkoordinierte Einführung stattfinden."

        Greg Sanders war [skeptisch][sanders doubt]: "Die Frage ist: Werden 5%+
        eine Variable setzen? Ich vermute nicht." Towns [entgegnete][towns uasf]:
        "[UASF][topic soft fork activation] `uacomment` hat gezeigt, dass es
        einfach ist, ~11% in nur ein paar Wochen dazu zu bewegen, eine Variable
        zu setzen".

    - *Sollte eine Option sein:* Martin Zumsande [sagte][zumsande option] in der
      IRC-Diskussion: "Ich denke, wenn eine bedeutende Anzahl von
      Knoten-Betreiber und Miner eine bestimmte Richtlinie wünscht, sollte es
      nicht den Entwicklern obliegen, ihnen zu sagen: 'Die könnt ihr jetzt
      nicht haben'. Die Entwickler können und sollten eine Empfehlung
      aussprechen (indem sie die Standardeinstellung setzen), aber es sollte nie
      ein Problem sein, informierten Nutzern Optionen zu bieten."


    Zum Zeitpunkt der Erstellung dieses Artikels war noch keine eindeutige
    Lösung erreicht worden. Die Option `mempoolfullrbf` ist immer noch in den
    Release Candidates für die kommende Version von Bitcoin Core 24.0 enthalten
    und es ist Optechs Empfehlung, dass jeder Dienst, der von
    Nullbestätigungs-Transaktionen abhängt, die Risiken sorgfältig abwägt,
    vielleicht beginnend mit dem Lesen der E-Mails, die im [Newsletter von letzter
    Woche][news222 rbf] verlinkt sind.

- **CoreDev.tech Transkripte:** vor der Atlanta Bitcoin Conference (TabConf)
  nahmen etwa 40 Entwickler an einer CoreDev.tech Veranstaltung teil.
  [Transkripte][coredev xs] für etwa die Hälfte der Veranstaltungstreffen wurden
  von Bryan Bishop zur Verfügung gestellt. Zu den bemerkenswerten Diskussionen
  gehörten:

    - [Transportverschlüsselung][p2p encryption]: ein Gespräch über die jüngste
      Aktualisierung des Vorschlags für ein verschlüsseltes
      [Transportprotokoll der Version 2][topic v2 p2p transport] (siehe
      [Newsletter #222][news222 bip324]). Dieses Protokoll würde es Lauschern im
      Netz erschweren, herauszufinden, von welcher IP-Adresse eine Transaktion
      ausgeht, und die Fähigkeit verbessern, Man-in-the-Middle-Angriffe zwischen
      ehrlichen Knoten zu erkennen und abzuwehren.

        Die Diskussion behandelt mehrere Überlegungen zum Protokollentwurf und
        ist eine empfehlenswerte Lektüre für alle, die sich fragen, warum die
        Protokollautoren bestimmte Entscheidungen getroffen haben. Außerdem wird
        der Zusammenhang mit dem früheren Protokoll zur Authentifizierung durch
        [Countersign][topic countersign] untersucht.

    - [Gebühren][fee chat]: eine weitreichende Diskussion über
      Transaktionsgebühren in der Vergangenheit, Gegenwart und in der Zukunft.
      Einige Themen beinhalteten Fragen darüber, warum Blöcke scheinbar fast
      immer voll sind, aber der Mempool nicht, eine Debatte darüber, wie lange
      wir Zeit haben, bis sich ein signifikanter Gebührenmarkt entwickelt,
      bevor wir uns um die langfristige Stabilität von Bitcoin
      [sorgen][topic fee sniping] müssen, und welche Lösungen wir einsetzen
      könnten, wenn wir glauben, dass ein Problem existiert.

    - [FROST][]: eine Präsentation über das FROST-Schwellenwert-Signaturverfahren.
      Die Mitschrift dokumentiert mehrere ausgezeichnete technische Fragen zu
      den kryptographischen Entscheidungen im Design und kann für jeden, der
      mehr über FROST im Speziellen oder kryptographisches Protokolldesign im
      Allgemeinen erfahren möchte, eine nützliche Lektüre sein. Siehe auch die
      TabConf-Mitschrift über [ROAST][], ein weiteres
      Schwellenwert-Signaturverfahren für Bitcoin.

    - [GitHub][github chat]: eine Diskussion über die Verlagerung des
      Git-Hostings des Bitcoin Core Projekts von GitHub zu einer anderen Lösung
      für die Verwaltung von Issues und PRs, sowie die Erwägung der Vorteile der
      weiteren Nutzung von GitHub.

    - [Beweisbare Spezifikationen in BIPs][hacspec chat]: Teil einer Diskussion
      über die Verwendung der [hacspec][]-Spezifikationssprache in BIPs, um
      beweisbar korrekte Spezifikationen zu erstellen. Siehe auch die Mitschrift
      eines entsprechenden Vortrags auf der TabConf.

    - [Paket- und v3-Transaktionsrelais][package relay chat]: die Abschrift
      einer Präsentation über Vorschläge zur Aktivierung des
      [Paket-Transaktionsrelais][topic package relay] und zur Verwendung neuer
      Transaktionsrelaisregeln, um [Pinning-Angriffe][topic transaction pinning]
      in bestimmten Fällen zu verhindern.

    - [Stratum v2][stratum v2 chat]: eine Diskussion, die mit der Ankündigung
      eines neuen Open-Source-Projekts begann, welches das gepoolte
      Mining-Protokoll Stratum Version 2 implementiert. Zu den Verbesserungen
      von Stratum v2 gehören authentifizierte Verbindungen und die Möglichkeit
      für einzelne Miner (mit lokaler Mining-Ausrüstung) zu wählen, welche
      Transaktionen sie schürfen wollen (anstatt dass der Pool die Transaktionen
      auswählt). Neben vielen anderen Vorteilen wurde in der Diskussion erwähnt,
      dass die Möglichkeit, dass einzelne Miner ihre eigene Blockvorlage wählen
      können, für Pools, die sich Sorgen machen, dass Regierungen vorschreiben,
      welche Transaktionen geschürft werden dürfen, wie in der Kontroverse um
      [Tornado Cash][], sehr wünschenswert sein könnte. Der größte Teil der
      Diskussion konzentrierte sich auf die Änderungen, die an Bitcoin Core
      vorgenommen werden müssten, um eine native Unterstützung für Stratum v2 zu
      ermöglichen. Siehe auch das TabConf-Protokoll über
      [Braidpool][braidpool chat], ein dezentrales gepooltes Mining-Protokoll.

    - [Merging][merging chat] ist eine Diskussion über Strategien, die helfen
      sollen, Code im Bitcoin Core Projekt zu überprüfen, obwohl viele
      Vorschläge auch für andere Projekte gelten. Ideen enthalten:

        - Große Änderungen in mehrere kleine PRs aufzuteilen

        - Es den Prüfern zu erleichtern, das eigentliche Ziel zu verstehen. Für
          alle PRs bedeutet dies, eine Motivations-PR-Beschreibung zu verfassen.
          Für Änderungen, die inkrementell gemacht werden, Tracking Issues,
          Projekt-Boards zu verwenden, und Refactorings zu begründen; für die
          auch PRs eröffnet werden sollten, die den überarbeiteten Code
          verwenden, um ein wünschenswertes Ziel zu erreichen

        - Erstellung von High-Level-Erklärungen für lang dauernde Projekte, die
          den Stand vor dem Projekt, den aktuellen Fortschritt, die notwendigen
          Schritte zur Erreichung des Ergebnisses und die Vorteile für die
          Nutzer beschreiben

        - Das Bilden von Arbeitsgruppen mit Personen, die an denselben Projekten
          oder Code-Teilsystemen interessiert sind

- **Flüchtige Verankerungen:** Greg Sanders hat im Anschluss an eine frühere
  Diskussion über v3-Transaktionsrelais (siehe [Newsletter #220][news220 ephemeral])
  in der Bitcoin-Dev-Mailingliste [einen Vorschlag][sanders ephemeral] für eine
  neue Art von [Ankerausgaben][topic anchor outputs] gemacht. Eine
  v3-Transaktion könnte keine Gebühren zahlen, aber eine Ausgabe enthalten, die
  das Skript `OP_TRUE` bezahlt, was es jedem erlaubt, sie nach den Konsensregeln
  in einer Child-Transaktion auszugeben. Die unbestätigte
  Null-Gebühr-Parent-Transaktion würde von Bitcoin Core nur weitergeleitet und
  geschürft werden, wenn sie Teil eines Transaktionspakets wäre, das auch die
  Child-Transaktion enthält, die den `OP_TRUE`-Output ausgibt. Dies würde nur die
  Richtlinien von Bitcoin Core beeinflussen; es würden keine Konsensregeln
  geändert.

    Zu den beschriebenen Vorteilen dieses Vorschlags gehört, dass er die
    Notwendigkeit beseitigt, Ein-Block relative Timelocks (nach dem Code, der
    sie ermöglicht,`1 OP_CSV` genannt) zu verwenden, um
    [Transaktions-Pinning][topic transaction pinning] zu verhindern, und dass er
    es jedem erlaubt, die Priorität der Parent-Transaktion gegen eine Gebühr zu
    erhöhen (ähnlich wie ein früherer Soft-Fork Vorschlag zu
    [Gebührensponsoring][topic fee sponsorship]).

    Jeremy Rubin [befürwortete][rubin ephemeral] den Vorschlag, merkte aber an,
    dass er nicht für Verträge funktioniert, die keine v3-Transaktionen verwenden
    können. Mehrere weitere Entwickler diskutierten das Konzept ebenfalls.
    Das Konzept schien, zum Zeitpunkt der Erstellung dieses Artikels, allseitigen
    Anklang zu finden.

## Ausgewählte Q&A aus dem Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] ist eine der Plattformen auf denen
Optech-Mitwirkende zuerst nach Antworten auf ihre Fragen suchen–oder wenn wir
einige Augenblicke Zeit haben, anderen neugierigen oder verwirrten Nutzern
aushelfen. In dieser monatlichen Rubrik stellen wir einige der populärsten
Fragen und Antworten des letzten Monats vor.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Warum würde jemand eine 1-von-1-Multisig verwenden?]({{bse}}115443)
  Vojtěch Strnad fragt, warum sich jemand für eine 1-von-1-Multisig gegenüber
  P2WPKH entscheiden würde, wenn P2WPKH billiger ist und größere Anonymität
  bietet. Murch listet eine Reihe von Quellen auf, die zeigen, dass mindestens
  ein Unternehmen im Laufe der Jahre Millionen von 1-of-1 UTXOs ausgegeben hat,
  obwohl die Beweggründe unklar bleiben.

- [Warum sollte die Sperrzeit einer Transaktion auf 1987 gesetzt sein?]({{bse}}115549)
  1440000bytes verweist auf einen Kommentar von Christian Decker, der sich auf
  [einen Abschnitt][bolt 3 commitment] der BOLT 3 Lightning-Spezifikation
  bezieht, in dem das Sperrzeitfeld wie folgt zugeordnet wird: "Die oberen 8
  Bits sind 0x20, die unteren 24 Bits sind die unteren 24 Bits der verdeckten
  Transaktionsnummer".

- [Was ist die Größenbeschränkung des UTXO-Sets, falls es eine gibt?]({{bse}}115439)
  Pieter Wuille antwortet, dass es keine einheitliche Grenze für die Größe des
  UTXO-Sets gibt und dass die Wachstumsrate des UTXO-Sets an die Blockgröße
  gebunden ist, welche die Anzahl der UTXOs limitiert, die pro Block erstellt
  werden können. In einer weiteren Antwort schätzt Murch, dass es etwa 11 Jahre
  dauern würde, für jeden Menschen auf der Erde einen UTXO zu erschaffen.

- [Warum ist -blockmaxweight standardmäßig auf 3996000 eingestellt?]({{bse}}115499)
  Vojtěch Strnad weist darauf hin, dass die Standardeinstellung für `-blockmaxweight`
  in Bitcoin Core 3.996.000 beträgt, was weniger ist als das Segwit-Limit von
  4.000.000 Gewichtseinheiten (WU). Pieter Wuille erklärt, dass dieser
  Unterschied einem Miner Pufferraum bietet, um eine größere Coinbase-Transaktion
  mit zusätzlichen Ausgaben, die über die Standard-Coinbase-Transaktion hinaus
  gehen, welche von der Blockvorlage erzeugt wird, hinzuzufügen.

- [Kann ein Miner einen Lightning-Channel mit einer Coinbase-Ausgabe eröffnen?]({{bse}}115588)
  Murch weist auf die Herausforderungen hin, die sich ergeben, wenn ein Miner
  einen Lightning-Channel mit einer Ausgabe seiner Coinbase-Transaktion erstellt.
  Dazu gehören Verzögerungen beim Schließen des Kanals aufgrund der
  Coinbase-Reifezeit sowie die Notwendigkeit, den offenen Channel während des
  Hashens ständig neu zu verhandeln, da sich der Hash der Coinbase-Transaktion
  während des Minings ständig ändert.

- [Wie wurden frühere Soft Forks getestet, bevor sie für die Aktivierung in Betracht gezogen wurden?]({{bse}}115434)
  Michael Folkson zitiert [einen aktuellen Post][aj soft fork testing] von
  Anthony Towns auf der Mailingliste, in dem die Tests für die Vorschläge P2SH,
  CLTV, CSV, segwit, [taproot][topic taproot], CTV und [Drivechain][topic sidechains]
  beschrieben werden.

## Releases und Release-Kandidaten

*Neue Releases und Release-Kandidaten für beliebte Bitcoin
Infrastrukturprojekte. Bitte erwäge auf die neuen Versionen
zu wechseln oder beim Testen von Release candidates auszuhelfen.*

- [LDK 0.0.112][] ist eine Version dieser Bibliothek zur Erstellung von
  LN-fähigen Anwendungen.

- [Bitcoin Core 24.0 RC2][] ist ein Release Candidate für die nächste Version
  der am weitesten verbreiteten Full-Node-Implementierung des Netzwerks. Eine
  [Anleitung zum Testen][bcc testing] ist verfügbar.

  **Warnung:** Dieser Release Candidate enthält die Konfigurationsoption
  `mempoolfullrbf`, von der mehrere Protokoll- und Anwendungsentwickler glauben,
  dass sie zu Problemen für Händlerdienste führen könnte; wie in den Newslettern
  dieser und der letzten Woche beschrieben. Optech fordert alle Dienste auf, die
  davon betroffen sein könnten, den RC zu evaluieren und sich an der
  öffentlichen Diskussion zu beteiligen.

## Nennenswerte Code- und Dokumentationsänderungen

*Erwähnenswerte Änderungen diese Woche in [Bitcoin Core][bitcoin core repo],
[Core Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], und [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #23443][] fügt eine neue P2P-Protokollnachricht, `sendtxrcncl`
  (send transaction reconciliation), hinzu, die es einem Knoten erlaubt, einem
  Peer zu signalisieren, dass er [erlay][topic erlay] unterstützt. Dieser PR
  fügt nur den ersten Teil des erlay-Protokolls hinzu - andere Teile werden
  benötigt, bevor es verwendet werden kann.

- [Eclair #2463][] und [#2461][eclair #2461] aktualisieren die Eclair-
  Implementierung der [interaktiven und beidseitigen Finanzierungsprotokolle]
  [topic dual funding], welche erfordert, dass sich jeder Finanzierungsinput als
  ersetzbar ([RBF][topic rbf])  gekennzeichnet wird und eine bereits bestätigte
  Ausgabe umsetzt (d.h. die Parent-Transaktion sich bereits in der Blockchain
  befindet). Diese Änderungen stellen sicher, dass RBF verwendet werden kann und
  dass keine der Gebühren, die ein Eclair-Benutzer beisteuert, dazu verwendet
  werden, frühere Transaktionen seiner Peers zu bestätigen.

{% include references.md %}
{% include linkers/issues.md v=2 issues="23443,2463,2461,25353" %}
[bitcoin core 24.0 rc2]: https://bitcoincore.org/bin/bitcoin-core-24.0/
[ldk 0.0.112]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.0.112
[bcc testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/24.0-Release-Candidate-Testing-Guide
[news222 rbf]: /en/newsletters/2022/10/19/#transaction-replacement-option
[kotliar free option]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-October/021056.html
[sanders cpfp]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-October/021060.html
[rubin cpfp]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-October/021059.html
[riard free option]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-October/021067.html
[zhao no control]: https://www.erisian.com.au/bitcoin-core-dev/log-2022-10-20.html#l-440
[towns uncoordinated]: https://www.erisian.com.au/bitcoin-core-dev/log-2022-10-20.html#l-488
[sanders doubt]: https://www.erisian.com.au/bitcoin-core-dev/log-2022-10-20.html#l-490
[towns uasf]: https://www.erisian.com.au/bitcoin-core-dev/log-2022-10-20.html#l-492
[zumsande option]: https://www.erisian.com.au/bitcoin-core-dev/log-2022-10-20.html#l-493
[coredev xs]: https://diyhpl.us/wiki/transcripts/bitcoin-core-dev-tech/
[p2p encryption]: https://diyhpl.us/wiki/transcripts/bitcoin-core-dev-tech/2022-10-10-p2p-encryption/
[news222 bip324]: /en/newsletters/2022/10/19/#bip324-update
[fee chat]: https://diyhpl.us/wiki/transcripts/bitcoin-core-dev-tech/2022-10-11-fee-market/
[frost]: https://diyhpl.us/wiki/transcripts/bitcoin-core-dev-tech/2022-10-11-frost/
[roast]: https://diyhpl.us/wiki/transcripts/tabconf/2022/roast/
[github chat]: https://diyhpl.us/wiki/transcripts/bitcoin-core-dev-tech/2022-10-11-github/
[hacspec chat]: https://diyhpl.us/wiki/transcripts/bitcoin-core-dev-tech/2022-10-11-hac-spec/
[hacspec]: https://hacspec.github.io/
[hacspec preso]: https://diyhpl.us/wiki/transcripts/tabconf/2022/hac-spec/
[package relay chat]: https://diyhpl.us/wiki/transcripts/bitcoin-core-dev-tech/2022-10-11-package-relay/
[stratum v2 chat]: https://diyhpl.us/wiki/transcripts/bitcoin-core-dev-tech/2022-10-11-stratum-v2/
[tornado cash]: https://www.coincenter.org/analysis-what-is-and-what-is-not-a-sanctionable-entity-in-the-tornado-cash-case/
[braidpool chat]: https://diyhpl.us/wiki/transcripts/tabconf/2022/braidpool/
[merging chat]: https://diyhpl.us/wiki/transcripts/bitcoin-core-dev-tech/2022-10-12-merging/
[news220 ephemeral]: /en/newsletters/2022/10/05/#ephemeral-dust
[sanders ephemeral]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-October/021036.html
[rubin ephemeral]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-October/021041.html
[zhao overview]: https://github.com/glozow/bitcoin-notes/blob/full-rbf/full-rbf.md
[bolt 3 commitment]: https://github.com/lightning/bolts/blob/316882fcc5c8b4cf9d798dfc73049075aa89d3e9/03-transactions.md#commitment-transaction
[se murch utxo calcs]: https://bitcoin.stackexchange.com/questions/111234/how-many-useable-utxos-are-possible-with-btc-inside-them/115451#115451
[aj soft fork testing]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-October/020964.html
