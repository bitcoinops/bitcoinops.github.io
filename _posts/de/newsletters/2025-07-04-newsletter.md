---
title: 'Bitcoin Optech Newsletter #361'
permalink: /de/newsletters/2025/07/04/
name: 2025-07-04-newsletter-de
slug: 2025-07-04-newsletter-de
type: newsletter
layout: newsletter
lang: de
---
Der Newsletter dieser Woche beschreibt einen Vorschlag, die Netzwerkverbindungen und das
Peer-Management für Onion-Message-Weiterleitung von denen für HTLC-Weiterleitung im LN zu trennen.
Ebenfalls enthalten sind unsere regulären Abschnitte mit Zusammenfassungen zu Diskussionen über
Konsensänderungen in Bitcoin sowie Beschreibungen aktueller Änderungen an populärer
Bitcoin-Infrastruktursoftware.

## Nachrichten

- **Trennung von Onion-Message- und HTLC-Weiterleitung:** Olaluwa Osuntokun
  [postete][osuntokun onion] auf Delving Bitcoin einen Vorschlag, Knoten zu erlauben,
  separate Verbindungen für die Weiterleitung von [Onion Messages][topic onion messages]
  zu nutzen, statt dieselben wie für [HTLCs][topic htlc]. Obwohl dies bereits möglich
  ist, etwa bei direkter Weiterleitung (siehe Newsletter [#283][news283 oniondirect]
  und [#304][news304 onionreply]), schlägt Osuntokun vor, dass getrennte Verbindungen
  immer möglich sein sollten. So könnten Knoten für Onion Messages ein anderes Set an
  Peers nutzen als für Zahlungen. Vorteile wären klarere Trennung der Aufgaben,
  günstigere Unterstützung vieler Onion-Message-Peers (Channels kosten onchain-Gebühren),
  bessere Privatsphäre durch Schlüsselrotation und schnellere Zustellung von Onion
  Messages, da sie nicht durch das HTLC-Protokoll blockiert werden. Osuntokun liefert
  Details zum vorgeschlagenen Protokoll.

  Einige Entwickler äußerten Bedenken, dass ein Onion-Message-Netzwerk Knoten mit zu
  vielen Peers fluten könnte. Aktuell haben Knoten meist nur Verbindungen zu ihren
  Channel-Partnern. Das Erstellen eines UTXO für einen Channel kostet Geld und ist
  eindeutig für Knoten und Partner – also ein UTXO pro Verbindung. Selbst wenn
  Onion-Message-Verbindungen onchain abgesichert werden müssten, könnte ein UTXO für
  tausende Verbindungen genutzt werden.

  Mindestens ein Teilnehmer unterstützte Osuntokuns Vorschlag, mehrere äußerten aber
  Bedenken wegen DoS-Risiken. Die Diskussion war zum Redaktionsschluss noch im Gange.

## Konsensänderungen

_Ein monatlicher Abschnitt mit Zusammenfassungen zu Vorschlägen und Diskussionen über
Konsensänderungen in Bitcoin._

- **CTV+CSFS-Vorteile für PTLCs:** Entwickler setzten eine frühere Diskussion (siehe
  [Newsletter #348][news348 ctvstep]) über die Vorteile von [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify]
  (CTV), [OP_CHECKSIGFROMSTACK][topic op_checksigfromstack] (CSFS) oder beide für verschiedene
  Protokolle fort. Besonders interessant: Gregory Sanders [schrieb][sanders ptlc], dass CTV+CSFS
  „das Update des [LN] auf [PTLCs][topic ptlc] beschleunigen würde, selbst wenn [LN-Symmetry][topic eltoo]
  nie übernommen wird. Re-bindable Signaturen vereinfachen das Stapeln von Protokollen erheblich.“
  Sjors Provoost [fragte][provoost ptlc] nach Details, Sanders [antwortete][sanders ptlc2] mit
  einem [Link][sanders gist] zu früheren Forschungsergebnissen (siehe [Newsletter #268][news268 ptlc]) und
  ergänzte, dass PTLCs mit heutigen Protokollen zwar möglich, aber mit rebindable (flexibel neu zuzuweisenden Signaturen)
  deutlich einfacher wären.

  Anthony Towns [merkte zusätzlich an][towns ptlc], dass es auch an Werkzeugen und Standardisierung fehlt,
  um eine PTLC-Offenlegung in Kombination mit einer [MuSig][topic musig] 2-von-2-Signatur (was onchain effizient wäre)
  oder sogar mit allgemeinen Transaktionssignaturen (z.B. `x CHECKSIGVERIFY y CHECKSIG`) durchzuführen.
  Dafür wäre Unterstützung für [Adaptor-Signaturen][topic adaptor signatures] in MuSig2 nötig, die aber weder Teil
  der Spezifikation sind noch in secp256k1 implementiert wurden (sie wurden [entfernt][libsecp256k1 #1479]).
  Weniger effizient wäre es, eine separate Adaptor-Signatur zu verwenden, aber selbst einfache Adaptor-Signaturen
  für [Schnorr-Signaturen][topic schnorr signatures] sind in secp256k1 nicht verfügbar. Auch im experimentellen
  secp256k1-zkp-Projekt sind sie nicht enthalten. Sobald das Tooling bereit ist, könnte der PTLC-Support hinzugefügt
  werden. Derzeit hält es jedoch offenbar niemand für prioritär genug, um die Kryptografie zu standardisieren und zu
  optimieren. Mit [CAT][topic op_cat]+CSFS könnte man das Tooling-Problem umgehen, allerdings auf Kosten der
  Onchain-Effizienz. Mit nur CSFS bestehen die Tooling-Probleme weiterhin, da Adaptor-Signaturen nötig sind, um zu
  verhindern, dass der Gegenpart einen anderen R-Wert für die Signatur wählt. Diese Probleme sind unabhängig von der
  Update-Komplexität und den Peer-Protokoll-Änderungen, die Gregory Sanders oben beschreibt.

- **Vault-Output-Script-Deskriptor:** Sjors Provoost [postete][provoost ctvdesc] auf Delving
  Bitcoin zur Diskussion, wie die Wiederherstellungsinformationen für eine Wallet mit
  [Vaults][topic vaults] per [Output Script Deskriptor][topic descriptors] spezifiziert werden
  könnten. Im Fokus standen Vaults auf Basis von [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify]
  (CTV), wie sie James O'Beirnes [simple-ctv-vault][] (siehe [Newsletter #191][news191 simple-ctv-vault])
  implementiert.

  Provoost zitierte einen [Kommentar][ingala vaultdesc] von Salvatore Ingala, der meinte,
  Deskriptoren seien das falsche Werkzeug für diesen Zweck – eine Meinung, die Sanket
  Kanjalkar [teilte][kanjalkar vaultdesc1], aber [einen Workaround][kanjalkar vaultdesc2]
  fand: Ein Vault, bei dem Kapital zunächst in einen normalen Deskriptor eingezahlt und
  dann in einen CTV-Vault verschoben wird. So können Nutzer nicht versehentlich Geld
  verlieren, und der CTV-Vault-Deskriptor bleibt einfach und vollständig.

- **Weitere Diskussion zu CTV+CSFS-Vorteilen für BitVM:** Entwickler setzten die frühere
  Diskussion (siehe [Newsletter #354][news354 bitvm]) fort, wie [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify]
  (CTV) und [OP_CHECKSIGFROMSTACK][topic op_checksigfromstack] (CSFS) BitVM-Transaktionsgrößen
  um etwa das 10-fache reduzieren und nicht-interaktive Peg-ins ermöglichen könnten.
  Anthony Towns [identifizierte][towns ctvbitvm] eine Schwachstelle im ursprünglichen
  Vertragsvorschlag; er und andere Entwickler beschrieben Workarounds. Weitere Diskussionen
  drehten sich um Vorteile des vorgeschlagenen [OP_TXHASH][]-Opcodes gegenüber CTV.
  Chris Stewart [implementierte][stewart ctvimp] einige Ideen mit Bitcoin Core-Testsoftware.

- **Offener Brief zu CTV und CSFS:** James O'Beirne [postete][obeirne letter] einen offenen
  Brief an die Bitcoin-Dev-Mailingliste, unterzeichnet von 66 Personen (Stand Redaktionsschluss),
  viele davon Bitcoin-Entwickler. Der Brief fordert, dass Bitcoin-Core-Mitwirkende die
  Überprüfung und Integration von [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify] (CTV)
  und [OP_CHECKSIGFROMSTACK][topic op_checksigfromstack] (CSFS) in den nächsten sechs Monaten
  priorisieren. Der Thread enthält über 60 Antworten. Einige technische Highlights:

  - *Bedenken und Alternativen zu Legacy-Support:* [BIP119][] spezifiziert CTV für
    Witness Script v1 ([Tapscript][topic tapscript]) und Legacy Script. Gregory Sanders
    [schreibt][sanders legacy], dass Legacy-Support die Prüfoberfläche unnötig vergrößert,
    ohne Mehrwert. O'Beirne [entgegnet][obeirne legacy], dass Legacy-Support in manchen
    Fällen 8 vbytes sparen kann, Sanders [verweist][sanders p2ctv] auf eine P2CTV-
    Implementierung, die diese Ersparnis auch im Witness Script ermöglicht.

  - *Grenzen von CTV-only-Vaults:* Jameson Lopp [merkte an][lopp ctvvaults], dass er
    besonders an [Vaults][topic vaults] interessiert ist, und diskutierte, welche
    Eigenschaften CTV-Vaults bieten, wie sie sich von Vaults mit presig-Transaktionen
    unterscheiden und ob sie echte Sicherheitsgewinne bringen. Wichtige Erkenntnisse:

    - *Adresswiederverwendung:* Sowohl presig- als auch CTV-Vaults müssen verhindern,
      dass Nutzer Vault-Adressen wiederverwenden, da sonst Kapitalverlust droht. Eine
      Möglichkeit ist ein zweistufiges Verfahren mit zwei Onchain-Transaktionen, um
      Kapital in den Vault einzuzahlen. Fortgeschrittene Vaults, die zusätzliche
      Konsensänderungen benötigen, hätten dieses Problem nicht und erlauben Einzahlungen
      auch auf wiederverwendete Adressen (was allerdings die
      [Privatsphäre verringert][topic output linking]).

    - *Diebstahl gestaffelter Gelder:* Beide Vault-Arten erlauben den Diebstahl
      autorisierter Auszahlungen. Beispiel: Vault-Nutzer Bob möchte 1 BTC an Alice
      zahlen. Mit presig- und CTV-Vaults nutzt Bob folgendes Verfahren:

      - Er zieht 1 BTC (ggf. plus Gebühren) aus seinem Vault auf eine Zwischenadresse ab.

      - Er wartet die vom Vault definierte Zeit ab.

      - Er transferiert 1 BTC an Alice.

      Wenn Mallory Bobs Schlüssel für die Zwischenadresse gestohlen hat, kann sie den
      1 BTC nach Abschluss der Auszahlung, aber vor Bestätigung der Transaktion an Alice
      stehlen. Selbst wenn Mallory auch den Auszahlungsschlüssel kompromittiert, kann sie
      kein Kapital mehr aus dem Vault stehlen, da Bob jede ausstehende Auszahlung
      abbrechen und die Mittel auf eine sichere Adresse mit einem besonders geschützten
      Schlüssel umleiten kann.

      Fortgeschrittene Vaults benötigen keinen Zwischenstopp
      mehr: Bobs Auszahlung kann nur an Alice oder die sichere Adresse gehen. Das
      verhindert, dass Mallory zwischen Auszahlung und Ausgabe Kapital stehlen kann.
    - *Key-Deletion:* Vorteil von CTV-Vaults ist, dass keine privaten Schlüssel gelöscht
      werden müssen, um sicherzustellen, dass nur die presig-Transaktionen ausgegeben
      werden können. Gregory Maxwell [merkt an][maxwell autodelete], dass es einfach ist,
      Software so zu gestalten, dass der Schlüssel direkt nach dem Signieren gelöscht
      wird, ohne ihn dem Nutzer preiszugeben. Aktuell ist kein Hardware-Signiergerät
      bekannt, das dies direkt unterstützt, eines unterstützt es manuell. Allerdings
      unterstützt auch kein Hardwaregerät CTV, selbst zu Testzwecken nicht. Fortgeschrittene
      Vaults hätten ebenfalls diesen Vorteil, müssten aber in Software und Hardware
      integriert werden.

    - *Statischer Zustand:* Ein behaupteter Vorteil von CTV-Vaults gegenüber presig-Vaults
      ist, dass sich alle Informationen zur Wiederherstellung der Wallet aus einem
      statischen Backup (z.B. einem Output Script Deskriptor) berechnen lassen könnten.
      Es gibt jedoch bereits presig-Vaults, die ebenfalls statische Backups erlauben,
      indem sie die nicht-deterministischen Teile des presig-Zustands in den Onchain-
      Transaktionen selbst speichern (siehe [Newsletter #255][news255 presig vault state]).
      Optech geht davon aus, dass auch fortgeschrittene Vaults aus statischem Zustand
      wiederhergestellt werden könnten, konnte dies aber bis Redaktionsschluss nicht
      verifizieren.
  - *Antworten von Bitcoin-Core-Mitwirkenden:* Zum Zeitpunkt des Schreibens antworteten vier
    von Optech als aktiv anerkannte Bitcoin-Core-Mitwirkende auf den Brief in der Mailingliste.
    Sie sagten:

    - [Gregory Sanders][sanders ctvcom]: „Dieser Brief bittet um Feedback aus der technischen
      Community und das ist mein Feedback. Nicht implementierte BIPs, die seit Jahren nicht
      aktualisiert wurden, sind generell kein Zeichen für einen gesunden Vorschlag und
      sicher keine Grundlage, technische Ratschläge von jemandem abzulehnen, der sich intensiv
      damit beschäftigt hat. Ich lehne dieses Framing, die Anhebung der Hürde für Änderungen
      an diesem Vorschlag auf nur noch grobe Fehler und natürlich ein zeitbasiertes Ultimatum
      für BIP119 ab. Ich halte CTV (im Sinne der Fähigkeiten) + CSFS weiterhin für prüfenswert,
      aber das ist ein sicherer Weg, es zu versenken.“

    - [Anthony Towns][towns ctvcom]: „Aus meiner Sicht hat die CTV-Diskussion wichtige Schritte
      ausgelassen, und statt diese nachzuholen, versuchen Befürworter seit mindestens drei
      Jahren, durch öffentlichen Druck eine beschleunigte Umsetzung zu erzwingen. Ich habe
      versucht, CTV-Befürwortern bei den fehlenden Schritten zu helfen, aber meist führte das
      zu Schweigen oder Beleidigungen statt zu etwas Konstruktivem. Für mich schafft das nur
      Anreizprobleme, löst sie aber nicht.“

    - [Antoine Poinsot][poinsot ctvcom]: „Die Wirkung dieses Briefs war, wie zu erwarten,
      ein erheblicher Rückschritt beim Fortschritt dieses Vorschlags (oder allgemein dieses
      Bündels an Fähigkeiten). Ich weiß nicht, wie wir davon zurückkommen, aber es erfordert
      unbedingt, dass jemand aufsteht und tatsächlich die Arbeit macht, technisches Feedback
      aus der Community zu adressieren und echte Anwendungsfälle zu demonstrieren. Der Weg
      nach vorn muss auf Konsensbildung durch starke objektive, technische Argumente basieren,
      nicht durch viele Interessensbekundungen ohne aktives Vorantreiben des Vorschlags.“

    - [Sjors Provoost][provoost ctvcom]: „Ich möchte auch meine eigene Motivation darlegen.
      Vaults scheinen das einzige Feature zu sein, das durch den Vorschlag ermöglicht wird,
      das ich persönlich wichtig genug finde, um daran zu arbeiten. [...] Bis vor kurzem
      schien mir, dass der Schwung für Vaults bei OP_VAULT lag, was wiederum OP_CTV erfordern
      würde. Aber ein einzelner, zweckgebundener Opcode ist nicht ideal, daher schien dieses
      Projekt nicht voranzukommen. [...] Andererseits habe ich nichts gegen CTV + CSFS; ich
      habe kein Argument gesehen, dass sie schädlich wären. Da das MeVil-Potenzial gering ist,
      kann ich mir vorstellen, dass andere Entwickler diese Änderungen vorsichtig entwickeln
      und einführen. Ich würde den Prozess nur beobachten. Was ich ablehnen würde, ist eine
      alternative Python-Implementierung und ein Aktivierungsclient wie von Co-Signer Paul
      Sztorc vorgeschlagen.“

  - *Statements der Unterzeichner:* Die Unterzeichner des Briefs präzisierten ihre Absichten
    in Folgebeiträgen:
    - [James O'Beirne][obeirne ctvcom]: „Alle Unterzeichner wollen ausdrücklich die zeitnahe
      Überprüfung, Integration und Aktivierungsplanung speziell für CTV+CSFS sehen.“

    - [Andrew Poelstra][poelstra ctvcom]: „Frühere Entwürfe des Briefs forderten tatsächlich
      Integration und sogar Aktivierung, aber ich habe keinen dieser frühen Entwürfe
      unterzeichnet. Erst als die Formulierung auf Priorisierung und Planung (und eine
      'respektvolle Bitte' statt einer Forderung) abgeschwächt wurde, habe ich unterschrieben.“

    - [Steven Roose][roose ctvcom]: „[Der Brief] bittet Core-Mitwirkende lediglich, diesen
      Vorschlag mit einer gewissen Dringlichkeit auf ihre Agenda zu setzen. Keine Drohungen,
      keine harten Worte. Da bisher nur wenige Core-Mitwirkende an der Diskussion teilgenommen
      hatten, schien es ein sinnvoller nächster Schritt, sie um eine Positionierung zu bitten.
      Ich lehne einen Ansatz mit unabhängigen Aktivierungsclients entschieden ab und denke, die
      Haltung dieser E-Mail entspricht der Präferenz, dass Core bei Protokoll-
      Upgrades eingebunden ist.“

    - [Harsha Goli][goli ctvcom]: „Die meisten haben unterschrieben, weil sie wirklich nicht
      wussten, was der nächste Schritt sein sollte, und der Druck für Transaktions-Commitments
      so groß war, dass eine schlechte Option (Unterschriftenaktion) besser erschien als
      Untätigkeit. In Vorgesprächen (ermittelt durch meine Branchenumfrage) erhielt ich von
      vielen Unterzeichnern nur Ermahnungen zum Brief. Ich kenne tatsächlich niemanden, der
      ihn explizit für eine gute Idee hielt. Und trotzdem haben sie unterschrieben. Das ist
      ein Signal.“

- **OP_CAT ermöglicht Winternitz-Signaturen:** Entwickler Conduition [postete][conduition winternitz]
  auf der Bitcoin-Dev-Mailingliste eine [Prototyp-Implementierung][conduition impl], die mit dem
  vorgeschlagenen [OP_CAT][topic op_cat]-Opcode und weiteren Script-Befehlen
  quantenresistente Signaturen nach dem Winternitz-Protokoll durch Konsenslogik verifizierbar macht.
  Die Implementierung benötigt fast 8.000 Bytes für Schlüssel, Signatur und Script (wobei der Großteil
  durch den Witness-Discount auf etwa 2.000 vbytes onchain reduziert wird). Das ist etwa 8.000 vbytes
  kleiner als ein anderes, zuvor von Jeremy Rubin  [vorgeschlagenes][rubin lamport], auf `OP_CAT` basierendes, quantenresistentes
  [Lamport-Signaturverfahren][rubin lamport].

- **Commit/Reveal-Funktion für Post-Quantum-Recovery:** Tadge Dryja [postete][dryja fawkes] auf
  der Bitcoin-Dev-Mailingliste eine Methode, wie man UTXOs mit [quantenanfälligen][topic quantum
  resistance] Signaturalgorithmen
  auch dann sicher ausgeben kann, wenn schnelle Quantencomputer es sonst erlauben würden, die Ausgabe
  einer Transaktion umzuleiten (zu stehlen). Dies würde einen Soft Fork erfordern und ist eine Variante
  eines früheren Vorschlags von Tim Ruffing (siehe [Newsletter #348][news348 fawkes]).

  Um einen Output in Dryjas Schema auszugeben, erstellt der Ausgebende ein Commitment zu drei Daten:

  1. Ein Hash des Public Keys, der zum Private Key gehört, der die Mittel kontrolliert, `h(pubkey)`.
     Dies ist der _Address Identifier_.

  2. Ein Hash aus Public Key und der txid der Transaktion, die der Ausgebende letztlich senden will,
     `h(pubkey, txid)`. Dies ist der _Sequence Dependent Proof_.

  3. Die txid der geplanten Transaktion. Dies ist die _Commitment txid_.

  Keine dieser Informationen gibt den zugrundeliegenden Public Key preis, der in diesem Schema nur dem
  Besitzer des UTXO bekannt ist.

  Das dreiteilige Commitment wird in einer Transaktion mit einem quantensicheren Algorithmus, z.B. als
  `OP_RETURN`-Output, veröffentlicht. Ein Angreifer könnte versuchen, ein eigenes Commitment mit demselben
  Address Identifier, aber einer anderen Commitment-txid zu senden, das die Mittel an seine eigene Wallet
  leitet. Da er aber den Public Key nicht kennt, kann er keinen gültigen Sequence Dependent Proof erzeugen.
  Das ist für Full Nodes zunächst nicht offensichtlich, aber sie können das Angreifer-Commitment ablehnen,
  sobald der UTXO-Besitzer den Public Key offenlegt.

  Nach ausreichender Bestätigung des Commitments offenbart der Ausgebende die vollständige Transaktion,
  die zur Commitment-txid passt. Full Nodes prüfen, ob der Public Key zum Address Identifier passt und
  ob er zusammen mit der txid dem Sequence Dependent Proof entspricht. Dann löschen Full Nodes alle
  Commitments für diesen Address Identifier bis auf das älteste (am tiefsten bestätigte). Nur die zuerst
  bestätigte txid mit gültigem Sequence Dependent Proof kann in eine bestätigte Transaktion aufgelöst werden.

  Dryja beschreibt weitere Details, wie dieses Schema als Soft Fork eingeführt werden könnte, wie das
  Commitment-Byte halbiert werden kann und was Nutzer und Software heute tun können, um sich auf das
  Verfahren vorzubereiten – sowie Einschränkungen für Nutzer von Script- und [Scriptless-Multisignaturen][topic multisignature].

- **OP_TXHASH-Variante mit Sponsorship:** Steven Roose [postete][roose txsighash] auf Delving
  Bitcoin über eine Variante von `OP_TXHASH` namens `TXSIGHASH`, die 64-Byte-[Schnorr-Signaturen][topic schnorr signatures]
  um zusätzliche Bytes erweitert, um festzulegen, auf welche Felder in der Transaktion (oder in
  verwandten Transaktionen) sich die Signatur bezieht. Neben den bisher vorgeschlagenen Commitment-Feldern
  für `OP_TXHASH` merkt Roose an, dass die Signatur auch auf eine frühere Transaktion im Block committen
  könnte, was eine effiziente Form von [Transaction Sponsorship][topic fee sponsorship] ermöglicht
  (siehe [Newsletter #295][news295 sponsor]). Er analysiert die Onchain-Kosten dieses Mechanismus im
  Vergleich zu bestehendem [CPFP][topic cpfp] und einem früheren Sponsorship-Vorschlag und kommt zu dem Schluss:
  „Mit [TXSIGHASH] Stacking können die Kosten in virtuellen Bytes jeder gestapelten Transaktion sogar
  niedriger sein als ihre ursprünglichen Kosten ohne Sponsor. [...] Außerdem sind alle Inputs einfache
  Key-Spends, was bedeutet, dass sie mit [CISA][topic cisa] aggregiert werden könnten.“

  Zum Redaktionsschluss gab es noch keine öffentlichen Antworten auf den Beitrag.

## Wichtige Code- und Dokumentationsänderungen

_Bemerkenswerte aktuelle Änderungen in [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning repo],
[Eclair][eclair repo], [LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet Interface (HWI)][hwi repo],
[Rust Bitcoin][rust bitcoin repo], [BTCPay Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement Proposals (BIPs)][bips repo],
[Lightning BOLTs][bolts repo], [Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition repo] und [BINANAs][binana repo]._

- [Bitcoin Core #32540][] führt den REST-Endpunkt `/rest/spenttxouts/BLOCKHASH` ein, der
  eine Liste ausgegebener Transaction Outputs (Prevouts) für einen Block liefert, primär
  im kompakten Binärformat, aber auch als JSON und Hex. Das verbessert die Performance
  externer Indexer.

- [Bitcoin Core #32638][] prüft, ob jeder gelesene Block von der Festplatte zum erwarteten
  Blockhash passt, um Bitrot und Index-Verwechslungen zu erkennen. Dank Header-Hash-Cache
  (siehe [Bitcoin Core #32487][]) ist diese Prüfung praktisch ohne Overhead.

- [Bitcoin Core #32819][] und [#32530][Bitcoin Core #32530] setzen die Maximalwerte für
  `-maxmempool` und `-dbcache` auf 500 MB bzw. 1 GB auf 32-Bit-Systemen. Höhere Werte
  könnten zu OOM-Fehlern führen.

- [LDK #3618][] implementiert die Client-Logik für [Async Payments][topic async payments],
  sodass ein Offline-Empfänger [BOLT12 Offers][topic offers] und statische Rechnungen mit
  einem immer-online LSP vorbereiten kann. Der PR führt einen Async-Offer-Cache im
  `ChannelManager` ein und definiert neue Onion-Messages und Hooks für die Kommunikation
  mit dem LSP und integriert die Zustandsmaschine in den `OffersMessageFlow`.

{% include snippets/recap-ad.md when="2025-07-08 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="32540,32638,32819,3618,1479,32487,32530" %}
[news255 presig vault state]: /en/newsletters/2023/06/14/#discussion-about-the-taproot-annex
[news348 ctvstep]: /de/newsletters/2025/04/04/#vorteile-von-ctv-csfs
[news268 ptlc]: /en/newsletters/2023/09/13/#ln-messaging-changes-for-ptlcs
[news191 simple-ctv-vault]: /en/newsletters/2022/03/16/#continued-ctv-discussion
[news354 bitvm]: /de/newsletters/2025/05/16/#beschreibung-der-vorteile-fur-bitvm-durch-op-ctv-und-op-csfs
[rubin lamport]: https://gnusha.org/pi/bitcoindev/CAD5xwhgzR8e5r1e4H-5EH2mSsE1V39dd06+TgYniFnXFSBqLxw@mail.gmail.com/
[osuntokun onion]: https://delvingbitcoin.org/t/reimagining-onion-messages-as-an-overlay-layer/1799/
[news283 oniondirect]: /en/newsletters/2024/01/03/#ldk-2723
[news304 onionreply]: /en/newsletters/2024/05/24/#core-lightning-7304
[sanders ptlc]: https://delvingbitcoin.org/t/ctv-csfs-can-we-reach-consensus-on-a-first-step-towards-covenants/1509/7
[provoost ptlc]: https://delvingbitcoin.org/t/ctv-csfs-can-we-reach-consensus-on-a-first-step-towards-covenants/1509/80
[sanders ptlc2]: https://delvingbitcoin.org/t/ctv-csfs-can-we-reach-consensus-on-a-first-step-towards-covenants/1509/81
[sanders gist]: https://gist.github.com/instagibbs/1d02d0251640c250ceea1c66665ec163
[towns ptlc]: https://delvingbitcoin.org/t/ctv-csfs-can-we-reach-consensus-on-a-first-step-towards-covenants/1509/82
[provoost ctvdesc]: https://delvingbitcoin.org/t/ctv-vault-output-descriptor/1766/
[simple-ctv-vault]: https://github.com/jamesob/simple-ctv-vault
[ingala vaultdesc]: https://github.com/bitcoin/bips/pull/1793#issuecomment-2749295131
[kanjalkar vaultdesc1]: https://delvingbitcoin.org/t/ctv-vault-output-descriptor/1766/3
[kanjalkar vaultdesc2]: https://delvingbitcoin.org/t/ctv-vault-output-descriptor/1766/9
[towns ctvbitvm]: https://delvingbitcoin.org/t/how-ctv-csfs-improves-bitvm-bridges/1591/8
[op_txhash]: /en/newsletters/2022/02/02/#composable-alternatives-to-ctv-and-apo
[stewart ctvimp]: https://delvingbitcoin.org/t/how-ctv-csfs-improves-bitvm-bridges/1591/25
[obeirne letter]: https://mailing-list.bitcoindevs.xyz/bitcoindev/a86c2737-db79-4f54-9c1d-51beeb765163n@googlegroups.com/
[sanders legacy]: https://mailing-list.bitcoindevs.xyz/bitcoindev/b17d0544-d292-4b4d-98c6-fa8dc4ef573cn@googlegroups.com/
[obeirne legacy]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CAPfvXfKEgA0RCvxR=mP70sfvpzTphTZGidy=JuSK8f1WnM9xYA@mail.gmail.com/
[sanders p2ctv]: https://delvingbitcoin.org/t/ctv-csfs-can-we-reach-consensus-on-a-first-step-towards-covenants/1509/72?u=harding
[lopp ctvvaults]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CADL_X_fxwKLdst9tYQqabUsJgu47xhCbwpmyq97ZB-SLWQC9Xw@mail.gmail.com/
[maxwell autodelete]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CAAS2fgSmmDmEhi3y39MgQj+pKCbksMoVmV_SgQmqMOqfWY_QLg@mail.gmail.com/
[sanders ctvcom]: https://groups.google.com/g/bitcoindev/c/KJF6A55DPJ8/m/XVhyLCJiBQAJ
[towns ctvcom]: https://mailing-list.bitcoindevs.xyz/bitcoindev/aEu8CqGH0lX5cBRD@erisian.com.au/
[poinsot ctvcom]: https://mailing-list.bitcoindevs.xyz/bitcoindev/GLGZ3rEDfqaW8jAfIA6ac78uQzjEdYQaJf3ER9gd4e-wBXsiS2NK0wAj8LWK8VHf7w6Zru3IKbtDU5NM102jD8wMjjw8y7FmiDtQIy9U7Y4=@protonmail.com/
[provoost ctvcom]: https://mailing-list.bitcoindevs.xyz/bitcoindev/0B7CEBEE-FB2B-41CF-9347-B9C1C246B94D@sprovoost.nl/
[obeirne ctvcom]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CAPfvXfLc5-=UVpcvYrC=VP7rLRroFviLTjPQfeqMQesjziL=CQ@mail.gmail.com/
[poelstra ctvcom]: https://mailing-list.bitcoindevs.xyz/bitcoindev/aEsvtpiLWoDsfZrN@mail.wpsoftware.net/
[roose ctvcom]: https://mailing-list.bitcoindevs.xyz/bitcoindev/035f8b9c-9711-4edb-9d01-bef4a96320e1@roose.io/
[goli ctvcom]: https://mailing-list.bitcoindevs.xyz/bitcoindev/mc0q6r14.59407778-1eb1-4e57-bcf2-c781d6f70b01@we.are.superhuman.com/
[conduition winternitz]: https://mailing-list.bitcoindevs.xyz/bitcoindev/uCSokD_EM3XBQBiVIEeju5mPOy2OU-TTAQaavyo0Zs8s2GhAdokhJXLFpcBpG9cKF03dNZfq2kqO-PpxXouSIHsDosjYhdBGkFArC5yIHU0=@proton.me/
[conduition impl]: https://gist.github.com/conduition/c6fd78e90c21f669fad7e3b5fe113182
[lamport signature]: https://en.wikipedia.org/wiki/Lamport_signature
[dryja fawkes]: https://mailing-list.bitcoindevs.xyz/bitcoindev/cc2f8908-f6fa-45aa-93d7-6f926f9ba627n@googlegroups.com/
[news348 fawkes]: /de/newsletters/2025/04/04/#sicherer-nachweis-des-utxo-besitzes-durch-offenlegung-eines-sha256-preimages
[roose txsighash]: https://delvingbitcoin.org/t/jit-fees-with-txhash-comparing-options-for-sponsorring-und-stacking/1760
[news295 sponsor]: /en/newsletters/2024/03/27/#transaction-fee-sponsorship-improvements