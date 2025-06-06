---
title: 'Bitcoin Optech Newsletter #353'
permalink: /de/newsletters/2025/05/09/
name: 2025-05-09-newsletter-de
slug: 2025-05-09-newsletter-de
type: newsletter
layout: newsletter
lang: de
---
Dieser Newsletter beschreibt eine kürzlich entdeckte theoretische Konsensfehler-Sicherheitslücke und verweist auf einen Vorschlag, die Wiederverwendung von BIP32-Wallet-Pfaden zu vermeiden. Außerdem gibt es wie gewohnt Zusammenfassungen eines Bitcoin Core PR Review Club Meetings, Ankündigungen neuer Releases und Release-Kandidaten sowie bemerkenswerte Code-Änderungen in populärer Bitcoin-Infrastruktur-Software.

## Nachrichten

- **BIP30-Konsensfehler-Sicherheitslücke:** Ruben Somsen [berichtete][somsen bip30] auf der Bitcoin-Dev-Mailingliste über eine theoretische Konsensfehler-Situation, die nun auftreten könnte, nachdem Checkpoints aus Bitcoin Core entfernt wurden (siehe [Newsletter #346][news346 checkpoints]). Kurz gesagt: Die Coinbase-Transaktionen der Blöcke 91722 und 91812 sind [dupliziert][topic duplicate transactions] in den Blöcken 91880 und 91842. [BIP30][] legt fest, dass diese beiden Blöcke so behandelt werden sollen, wie es die historische Version von Bitcoin Core 2010 tat, indem die früheren Coinbase-Einträge im UTXO-Set durch die späteren Duplikate überschrieben werden. Somsen merkt jedoch an, dass eine Reorganisation eines oder beider späteren Blöcke dazu führen würde, dass der doppelte Eintrag (oder die Einträge) aus dem UTXO-Set entfernt werden, wodurch auch die früheren Einträge fehlen würden. Ein neu gestarteter Knoten, der die doppelten Transaktionen nie gesehen hat, hätte jedoch noch die früheren Transaktionen, was zu einem unterschiedlichen UTXO-Set führen könnte und im Falle einer Ausgabe zu einem Konsensfehler führen kann.

  Solange Bitcoin Core Checkpoints hatte, war das kein Problem, da diese alle vier genannten Blöcke als Teil der besten Blockchain erforderten. Jetzt ist es nur noch ein theoretisches Problem, außer im Fall, dass der Proof-of-Work-Sicherheitsmechanismus von Bitcoin versagt. Es wurden mehrere mögliche Lösungen diskutiert, z.B. das Hardcoden zusätzlicher Sonderfälle für diese beiden Ausnahmen.

- **Vermeidung von BIP32-Pfad-Wiederverwendung:** Kevin Loaec [diskutierte][loaec bip32reuse] auf Delving Bitcoin verschiedene Möglichkeiten, zu verhindern, dass derselbe [BIP32][topic bip32] Wallet-Pfad mit unterschiedlichen Wallets verwendet wird, was zu einem Verlust der Privatsphäre durch [Output Linking][topic output linking] und theoretisch auch zu einem Sicherheitsverlust (z.B. durch [Quantencomputer][topic quantum resistance]) führen könnte. Er schlug drei Ansätze vor: einen zufälligen Pfad, einen Pfad basierend auf dem Wallet-Geburtstag und einen Pfad mit einem inkrementierenden Zähler. Er empfahl den Ansatz mit dem Geburtstag.

  Außerdem empfahl er, die meisten der [BIP48][]-Pfad-Elemente wegzulassen, da durch die zunehmende Nutzung von [Descriptor][topic descriptors] Wallets, insbesondere für Multisig und komplexe Script-Wallets, diese nicht mehr nötig seien. Salvatore Ingala [antwortete][ingala bip48] jedoch, dass das _coin type_-Element im BIP48-Pfad beibehalten werden sollte, da es hilft, Schlüssel für verschiedene Kryptowährungen zu trennen, was von einigen Hardware-Signiergeräten erzwungen wird.

## Bitcoin Core PR Review Club

*In diesem monatlichen Abschnitt fassen wir ein aktuelles [Bitcoin Core PR Review Club][]-Meeting zusammen und heben wichtige Fragen und Antworten hervor. Klicke auf eine Frage, um eine Zusammenfassung der Antwort aus dem Meeting zu sehen.*

[Bitcoin-Wrapper-Executable hinzufügen][review club 31375] ist ein PR von [ryanofsky][gh ryanofsky], der ein neues `bitcoin`-Binary einführt, mit dem verschiedene Bitcoin Core Binaries gefunden und gestartet werden können.

Bitcoin Core v29 wurde mit 7 Binaries ausgeliefert (z.B. `bitcoind`, `bitcoin-qt` und `bitcoin-cli`), aber diese Zahl wird in Zukunft [steigen][Bitcoin Core #30983], wenn auch [Multiprozess][multiprocess design] Binaries ausgeliefert werden. Der neue `bitcoin`-Wrapper ordnet Befehle (z.B. `gui`) dem richtigen monolithischen (`bitcoin-qt`) oder Multiprozess-(`bitcoin-gui`) Binary zu. Neben der besseren Auffindbarkeit sorgt der Wrapper auch für Forward-Kompatibilität, sodass Binaries reorganisiert werden können, ohne dass sich die Benutzeroberfläche ändert.

Mit diesem PR kann ein Nutzer Bitcoin Core mit `bitcoin daemon` oder `bitcoin gui` starten. Das direkte Starten der Binaries `bitcoind` oder `bitcoin-qt` ist weiterhin möglich und von diesem PR nicht betroffen.

{% include functions/details-list.md
  q0="Im Issue #30983 wurden vier Packaging-Strategien aufgelistet. Welche spezifischen Nachteile des „Side‑Binaries“-Ansatzes adressiert dieser PR?"
  a0="Der Side-Binaries-Ansatz, wie in diesem PR angenommen, sieht vor, die neuen Multiprozess-Binaries neben den bestehenden monolithischen Binaries zu veröffentlichen. Bei so vielen Binaries kann es für Nutzer verwirrend sein, das richtige Binary für ihren Zweck zu finden. Dieser PR nimmt viel von dieser Verwirrung, indem er einen einzigen Einstiegspunkt mit einer Übersicht der Optionen und einer Hilfeseite bietet. Ein Reviewer schlug außerdem die Ergänzung einer Fuzzy-Suche vor, um dies weiter zu erleichtern."
  a0link="https://bitcoincore.reviews/31375#l-40"
  q1="`GetExePath()` verwendet unter Linux nicht `readlink(\"/proc/self/exe\")`, obwohl das direkter wäre. Welche Vorteile hat die aktuelle Implementierung? Welche Randfälle könnten übersehen werden?"
  a1="Es könnte andere Nicht-Windows-Plattformen geben, die kein proc-Dateisystem haben. Abgesehen davon konnten weder der Autor noch die Gäste Nachteile bei der Verwendung von procfs identifizieren."
  a1link="https://bitcoincore.reviews/31375#l-71"
  q2="Erkläre in `ExecCommand` den Zweck des Booleans `fallback_os_search`. Unter welchen Umständen ist es besser, das Suchen des Binaries durch das Betriebssystem auf dem `PATH` zu vermeiden?"
  a2="Wenn es so aussieht, als ob das Wrapper-Executable per Pfad (z.B. \"/build/bin/bitcoin\") und nicht per Suche (z.B. \"bitcoin\") aufgerufen wurde, wird angenommen, dass der Nutzer einen lokalen Build verwendet, und `fallback_os_search` wird auf `false` gesetzt. Dieses Boolean wurde eingeführt, um zu verhindern, dass Binaries aus verschiedenen Quellen unbeabsichtigt gemischt werden. Zum Beispiel: Wenn der Nutzer `gui` nicht lokal gebaut hat, sollte `/build/bin/bitcoin gui` nicht auf das systemweit installierte `bitcoin-gui` zurückfallen. Der Autor erwägt, die `PATH`-Suche ganz zu entfernen, und Nutzerfeedback wäre hilfreich."
  a2link="https://bitcoincore.reviews/31375#l-75"
  q3="Der Wrapper durchsucht `${prefix}/libexec` nur, wenn er erkennt, dass er aus einem installierten `bin/`-Verzeichnis läuft. Warum wird nicht immer `libexec` durchsucht?"
  a3="Der Wrapper sollte vorsichtig sein, welche Pfade er ausführt, und Standard-Layouts wie `PREFIX/{bin,libexec}` fördern, statt Packager zu ermutigen, unübliche Layouts zu erstellen oder zu unterstützen, wenn Binaries unerwartet angeordnet sind."
  a3link="https://bitcoincore.reviews/31375#l-75"
  q4="Der PR fügt eine Ausnahme in `security-check.py` hinzu, weil der Wrapper keine gehärteten `glibc`-Aufrufe enthält. Warum enthält er diese nicht, und würde das Hinzufügen eines trivialen `printf` zu `bitcoin.cpp` reproduzierbare Builds unter den aktuellen Regeln brechen?"
  a4="Das Wrapper-Binary ist so einfach, dass es keine Aufrufe enthält, die gehärtet werden können. Falls dies in Zukunft der Fall ist, kann die Ausnahme in security-check.py entfernt werden."
  a4link="https://bitcoincore.reviews/31375#l-117"
%}

## Veröffentlichungen und Release-Kandidaten

_Neue Releases und Release-Kandidaten für populäre Bitcoin-Infrastrukturprojekte. Bitte erwäge, auf neue Releases zu aktualisieren oder Release-Kandidaten zu testen._

- [LND 0.19.0-beta.rc4][] ist ein Release-Kandidat für diesen populären LN-Knoten. Eine der wichtigsten Verbesserungen, die getestet werden sollte, ist das neue RBF-basierte Fee-Bumping für kooperative Channel-Schließungen.

## Wichtige Code- und Dokumentationsänderungen

_Bemerkenswerte aktuelle Änderungen in [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo], [Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition repo] und [BINANAs][binana repo]._

- [Core Lightning #8227][] fügt Rust-basierte `lsps-client`- und `lsps-service`-Plugins hinzu, die ein Kommunikationsprotokoll zwischen LSP-Knoten und deren Clients implementieren. Sie verwenden ein JSON-RPC-Format über [BOLT8][] Peer-to-Peer-Nachrichten, wie in [BLIP50][] spezifiziert (siehe Newsletter [#335][news335 blip50]). Dies legt die Grundlage für die Implementierung eingehender Liquiditätsanfragen gemäß [BLIP51][] und [JIT-Channels][topic jit channels] gemäß [BLIP52][].

- [Core Lightning #8162][] aktualisiert die Behandlung von Peers initiierten, ausstehenden Channel-Öffnungen, indem sie unbegrenzt (bis zu den 100 neuesten) gespeichert werden. Zuvor wurden unbestätigte Channel-Öffnungen nach 2016 Blöcken vergessen. Zusätzlich werden geschlossene Channels nun im Speicher gehalten, damit ein Knoten auf die `channel_reestablish`-Nachricht eines Peers reagieren kann.

- [Core Lightning #8166][] verbessert den `wait`-RPC-Befehl, indem das einzelne `details`-Objekt durch subsystemspezifische Objekte ersetzt wird: `invoices`, `forwards`, `sendpays` und [`htlcs`][topic htlc]. Außerdem unterstützt der RPC-Befehl `listhtlcs` jetzt Paginierung über neue Felder `created_index` und `updated_index` sowie die Parameter `index`, `start` und `end`.

- [Core Lightning #8237][] ergänzt den RPC-Befehl `listpeerchannels` um einen `short_channel_id`-Parameter, um nur einen bestimmten Channel zurückzugeben, falls angegeben.

- [LDK #3700][] fügt dem Event `HTLCHandlingFailed` ein neues Feld `failure_reason` hinzu, das zusätzliche Informationen darüber liefert, warum das [HTLC][topic htlc] fehlgeschlagen ist und ob die Ursache lokal oder downstream lag. Das Feld `failed_next_destination` wird in `failure_type` umbenannt und die Variante `UnknownNextHop` wird zugunsten der allgemeineren Variante `InvalidForward` als veraltet markiert.

- [Rust Bitcoin #4387][] überarbeitet das Fehlerhandling von [BIP32][topic bip32], indem der bisherige einzelne `bip32::Error` durch separate Enums für Ableitung, Child-Nummer/Pfad-Parsing und Extended-Key-Parsing ersetzt wird. Außerdem wird eine neue Variante `DerivationError::MaximumDepthExceeded` für Pfade mit mehr als 256 Ebenen eingeführt. Diese API-Änderungen sind nicht abwärtskompatibel.

- [BIPs #1835][] aktualisiert [BIP48][] (siehe Newsletter [#135][news135 bip48]), um den Skripttyp-Wert 3 für [taproot][topic taproot] (P2TR)-Ableitungen in deterministischen Multisig-Wallets mit dem Präfix m/48' zu reservieren, zusätzlich zu den bestehenden Skripttypen P2SH-P2WSH (1′) und P2WSH (2′).

- [BIPs #1800][] merged [BIP54][], das den [Consensus Cleanup Soft Fork][topic consensus cleanup] spezifiziert, um eine Reihe langjähriger Schwachstellen im Bitcoin-Protokoll zu beheben. Siehe Newsletter [#348][news348 cleanup] für eine ausführliche Beschreibung dieses BIPs.

- [BOLTs #1245][] verschärft [BOLT11][], indem nicht-minimale Längen-Codierungen in Rechnungen verboten werden: Das Ablaufdatum (x), das [CLTV expiry delta][topic cltv expiry delta] für den letzten Hop (c) und die Feature-Bits (9) müssen in minimaler Länge ohne führende Nullen serialisiert werden, und Leser sollten jede Rechnung ablehnen, die führende Nullen enthält. Diese Änderung wurde durch Fuzz-Tests motiviert, die zeigten, dass beim Reserialisieren nicht-minimaler Rechnungen durch LDK die ECDSA-Signatur der Rechnung fehlschlägt.

{% include snippets/recap-ad.md when="2025-05-13 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="8227,8162,8166,8237,3700,4387,1835,1800,1245,50,51,52,30983" %}
[lnd 0.19.0-beta.rc4]: https://github.com/lightningnetwork/lnd/releases/tag/v0.19.0-beta.rc4
[wuille clustrade]: https://delvingbitcoin.org/t/how-to-linearize-your-cluster/303/68
[somsen bip30]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CAPv7TjZTWhgzzdps3vb0YoU3EYJwThDFhNLkf4XmmdfhbORTaw@mail.gmail.com/
[loaec bip32reuse]: https://delvingbitcoin.org/t/avoiding-xpub-derivation-reuse-across-wallets-in-a-ux-friendly-manner/1644
[ingala bip48]: https://delvingbitcoin.org/t/avoiding-xpub-derivation-reuse-across-wallets-in-a-ux-friendly-manner/1644/3
[news346 checkpoints]: /de/newsletters/2025/03/21/#bitcoin-core-31649
[news335 blip50]: /en/newsletters/2025/01/03/#blips-52
[news135 bip48]: /en/newsletters/2021/07/28/#bips-1072
[news348 cleanup]: /de/newsletters/2025/04/04/#draft-bip-published-for-consensus-cleanup
[review club 31375]: https://bitcoincore.reviews/31375
[gh ryanofsky]: https://github.com/ryanofsky
[multiprocess design]: https://github.com/bitcoin/bitcoin/blob/master/doc/design/multiprocess.md