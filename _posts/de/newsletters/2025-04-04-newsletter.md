---
title: 'Bitcoin Optech Newsletter #348'
permalink: /de/newsletters/2025/04/04/
name: 2025-04-04-newsletter-de
slug: 2025-04-04-newsletter-de
type: newsletter
layout: newsletter
lang: de
---
Der Newsletter dieser Woche verweist auf eine lehrreiche Implementierung
der elliptischen Kurven-Kryptografie für Bitcoins secp256k1-Kurve.
Ebenfalls enthalten sind unsere regulären Abschnitte mit Beschreibungen
von Diskussionen über Konsensänderungen, Ankündigungen neuer Releases
und Release-Kandidaten sowie Zusammenfassungen wichtiger Änderungen an
populärer Bitcoin-Infrastruktur-Software.

## Nachrichten

- **Lehrreiche Implementierung für Versuchszwecke von secp256k1:**
  Sebastian Falbesoner, Jonas Nick und Tim Ruffing haben in der
  Bitcoin-Dev-Mailingliste [bekanntgegeben][fnr secp], dass eine
  Python-[Implementierung][secp256k1lab] verschiedener Funktionen
  im Zusammenhang mit der in Bitcoin verwendeten Kryptografie vorliegt.
  Dabei wird ausdrücklich darauf hingewiesen, dass die Implementierung
  "INSECURE" (im Original in Großbuchstaben) und "für Prototyping,
  Experimente und Bildungszwecke" gedacht ist.

  Zudem weisen sie darauf hin, dass Referenz- und Testcode für mehrere BIPs
  ([340][bip340], [324][bip324], [327][bip327] und [352][bip352]) bereits
  "benutzerdefinierte und teils leicht abweichende Implementierungen von secp256k1"
  enthält. Man erhofft sich, die Situation in Zukunft zu verbessern – eventuell
  beginnend mit einem kommenden BIP für ChillDKG (siehe [Newsletter #312][news312 chilldkg]).

## Konsensänderungen

_Ein monatlicher Abschnitt, der Vorschläge und Diskussionen zu
Änderungen der Bitcoin-Konsensregeln zusammenfasst._

- **Zahlreiche Diskussionen über den Diebstahl durch Quantencomputer und entsprechende Gegenmaßnahmen:**
  In mehreren Gesprächen wurde erörtert, wie Bitcoin-Nutzer reagieren könnten,
  wenn Quantencomputer leistungsfähig genug wären, um Bitcoins zu stehlen.

  - *Sollten gefährdete Bitcoins vernichtet werden?*
    Jameson Lopp [veröffentlicht][lopp destroy] in der
    Bitcoin-Dev-Mailingliste verschiedene Argumente, die
    dafür sprechen, Bitcoins, die durch [Quantenangriffe][topic quantum resistance]
    gefährdet sind, nach einer hinreichenden Migrationsfrist zu vernichten.
    Zu seinen Argumenten zählen:

    - *Argument der Präferenz der Allgemeinheit:*
      Er geht davon aus, dass die Mehrheit es vorziehen würde, ihr Geld zu vernichten,
      statt es einem Angreifer mit schnellem Quantencomputer zu überlassen – zumal dieser
      zu den wenigen privilegierten Personen gehören würde, die frühzeitig Zugang zu
      Quantencomputern erhalten.

    - *Argument des kollektiven Schadens:*
      Viele der gestohlenen Bitcoins wären entweder dauerhaft
      verloren oder für den langfristigen Halter vorgesehen.
      Durch einen schnellen Gebrauch der gestohlenen Coins
      könnte die Kaufkraft der verbleibenden Bitcoins
      sinken, was unter anderem die Miner-Einnahmen reduziert
      und die Netzwerksicherheit beeinträchtigt.

    - *Argument des minimalen Nutzens:*
      Obwohl der Diebstahl zur Finanzierung der
      Entwicklung von Quantencomputern beitragen
      könnte, bietet er keinen direkten Nutzen für
      ehrliche Teilnehmer des Bitcoin-Protokolls.

    - *Argument klarer Fristen:*
      Niemand kann lange im Voraus wissen, wann ein
      Quantencomputer Bitcoins stehlen kann, aber ein spezifisches Datum,
      an dem gefährdete Coins vernichtet werden, kann präzise
      angekündigt werden. Diese klare Frist würde den Nutzern
      mehr Anreiz geben, ihre Bitcoins rechtzeitig zu sichern,
      wodurch insgesamt weniger Coins verloren gehen.

    - *Argument der Miner-Anreize:*
      Wie oben erwähnt, würde der Diebstahl durch Quantencomputer
      wahrscheinlich die Miner-Einnahmen reduzieren. Eine Mehrheit
      der Hashrate könnte die Ausgabe von gefährdeten Bitcoins zensieren,
      selbst wenn der Rest der Bitcoin-Nutzer eine andere Lösung bevorzugt.

    Lopp führt auch mehrere Argumente gegen die Vernichtung gefährdeter Bitcoins
    an, kommt jedoch zu dem Schluss, dass die Vernichtung vorzuziehen ist.

    Nagaev Boris [fragt][boris timelock], ob UTXOs, die über die Migrationsfrist hinaus
    [timelocked][topic timelocks] sind, ebenfalls vernichtet werden sollten. Lopp weist
    auf bestehende Fallstricke bei langen Timelocks hin und sagt, dass er persönlich
    "etwas nervös wird, wenn er Gelder für mehr als ein oder zwei Jahre sperrt."

  - *Sicherer Nachweis des UTXO-Besitzes durch Offenlegung eines SHA256-Preimages:*
    Martin Habovštiak [veröffentlicht][habovstiak gfsig] in der Bitcoin-Dev-Mailingliste
    eine Idee, die es jemandem ermöglichen könnte, den Besitz eines UTXO nachzuweisen,
    selbst wenn ECDSA und [Schnorr-Signaturen][topic schnorr signatures] unsicher
    wären (z. B. nach der Existenz schneller Quantencomputer).
    Wenn das UTXO ein SHA256-Commitment (oder ein anderes quantensicheres Commitment)
    zu einem Preimage enthält, das nie zuvor offengelegt wurde, könnte ein
    mehrstufiges Protokoll zur Offenlegung dieses Preimages mit einer
    Konsensänderung kombiniert werden, um Quanten-Diebstahl zu verhindern.
    Dies ist im Wesentlichen dasselbe wie ein [früherer Vorschlag][ruffing gfsig]
    von Tim Ruffing (siehe [Newsletter #141][news141 gfsig]), der allgemein als
    [Guy Fawkes signature scheme][] bekannt ist.
    Es ist auch eine Variante eines [Schemas][back crsig],
    das Adam Back 2013 erfunden hat,
    um die Widerstandsfähigkeit gegen Miner-Zensur zu verbessern.
    Kurz gesagt, könnte das Protokoll wie folgt funktionieren:

    1. Alice erhält Gelder zu einem Output, der in irgendeiner Weise ein
       SHA256-Commitment macht. Dies kann ein direkt gehashter Output sein,
       wie P2PKH, P2SH, P2WPKH oder P2WSH – oder es kann ein
       [P2TR][topic taproot]-Output mit einem Skriptpfad sein.

    2. Wenn Alice mehrere Zahlungen an dasselbe Output-Skript erhält,
       muss sie entweder keine davon ausgeben, bis sie bereit ist,
       alle auszugeben (definitiv erforderlich für P2PKH und P2WPKH;
       wahrscheinlich auch praktisch erforderlich für P2SH und P2WSH),
       oder sie muss sehr vorsichtig sein, um sicherzustellen,
       dass mindestens ein Preimage von ihr nicht offengelegt wird
       (leicht möglich mit P2TR-Keypath gegenüber Scriptpath-Ausgaben).

    3. Wenn Alice bereit ist, auszugeben, erstellt sie privat ihre
       Ausgabetransaktion normal, sendet sie jedoch nicht.
       Sie erhält auch einige Bitcoins, die durch einen quantensicheren
       Signaturalgorithmus gesichert sind, damit sie Transaktionsgebühren zahlen kann.

    4. In einer Transaktion, die einige der quantensicheren Bitcoins ausgibt,
       verpflichtet sie sich zu den quantenunsicheren Bitcoins,
       die sie ausgeben möchte, und verpflichtet sich auch zu der privaten
       Ausgabetransaktion (ohne sie offenzulegen). Sie wartet darauf,
       dass diese Transaktion tief bestätigt wird.

    5. Nachdem sie sicher ist, dass ihre vorherige
       Transaktion praktisch nicht reorganisiert werden kann,
       offenbart sie ihr zuvor privates Preimage und die
       quantenunsichere Ausgabe.

    6. Knoten im Netzwerk durchsuchen die Blockchain, um die erste
       Transaktion zu finden, die sich zu dem Preimage verpflichtet.
       Wenn diese Transaktion sich zu Alices quantenunsicherer
       Ausgabe verpflichtet, führen sie ihre Ausgabe aus. Andernfalls tun sie nichts.

    Dies stellt sicher, dass Alice keine quantenanfälligen Informationen
    offenlegen muss, bis sie bereits sichergestellt hat, dass ihre Version der
    Ausgabetransaktion Vorrang vor jedem Versuch hat, von einem Quantencomputer-Betreiber
    ausgegeben zu werden. Für eine genauere Beschreibung des Protokolls siehe
    [Ruffings Beitrag von 2018][ruffing gfsig]. Obwohl im Thread nicht diskutiert,
    glauben wir, dass das oben beschriebene Protokoll als Soft Fork
    bereitgestellt werden könnte.

    Habovštiak argumentiert, dass Bitcoins, die sicher mit diesem Protokoll
    ausgegeben werden können (z. B. deren Preimage noch nicht offengelegt wurde),
    nicht vernichtet werden sollten, selbst wenn die Community beschließt,
    dass sie quantenanfällige Bitcoins im Allgemeinen vernichten möchte.
    Er argumentiert auch, dass die Fähigkeit, einige Bitcoins im Notfall
    sicher auszugeben, die Dringlichkeit der Einführung eines
    quantensicheren Schemas kurzfristig verringert.

    Lloyd Fournier [sagt][fournier gfsig], "wenn dieser Ansatz Akzeptanz
    findet, denke ich, dass die Hauptmaßnahme, die Benutzer ergreifen können,
    darin besteht, zu einer Taproot-Wallet zu wechseln", da diese die Möglichkeit bietet,
    Keypath-Ausgaben unter den aktuellen Konsensregeln zu ermöglichen, einschließlich
    im Fall von [Output linking][topic output linking], aber auch Widerstand gegen
    Quanten-Diebstahl, wenn Keypath-Ausgaben später deaktiviert werden.

    In einem separaten Thread (siehe nächster Punkt) stellt Pieter Wuille
    [fest][wuille nonpublic], dass UTXOs, die für Quanten-Diebstahl anfällig sind,
    auch Schlüssel umfassen, die nicht öffentlich verwendet wurden,
    aber mehreren Parteien bekannt sind, wie in verschiedenen Formen von Multisig
    (einschließlich LN, [DLCs][topic dlc] und Treuhanddiensten).

  - *Entwurf eines BIP zur Vernichtung quantenunsicherer Bitcoins:*
    Agustin Cruz [veröffentlicht][cruz qramp] in der Bitcoin-Dev-Mailingliste ein
    [Entwurf-BIP][cruz bip], das mehrere Optionen für einen allgemeinen Prozess zur
    Vernichtung von Bitcoins beschreibt, die für Quanten-Diebstahl anfällig sind
    (falls dies zu einem erwarteten Risiko wird). Cruz argumentiert,
    "indem wir eine Frist für die Migration durchsetzen, bieten wir rechtmäßigen
    Eigentümern eine klare, nicht verhandelbare Gelegenheit,
    ihre Gelder zu sichern [...] eine erzwungene Migration mit
    ausreichender Vorankündigung und robusten Schutzmaßnahmen ist sowohl
    realistisch als auch notwendig, um die langfristige Sicherheit von Bitcoin zu schützen."

    Sehr wenig der Diskussion im Thread konzentrierte sich auf das Entwurf-BIP.
    Die meisten Diskussionen drehten sich darum, ob die Vernichtung quantenanfälliger
    Bitcoins eine gute Idee ist, ähnlich wie der Thread, der später von Jameson Lopp
    gestartet wurde (wie im vorherigen Unterpunkt beschrieben).

- **Mehrere Diskussionen über ein CTV+CSFS-Softfork:** Mehrere Gespräche
  untersuchten verschiedene Aspekte eines Softforks in den
  [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify]
  (CTV) und [OP_CHECKSIGFROMSTACK][topic op_checksigfromstack] (CSFS) Opcodes.

  - *Kritik an der CTV-Motivation:* Anthony Towns [postete][towns ctvmot]
    eine Kritik an der in [BIP119][] beschriebenen Motivation für CTV,
    die er argumentierte, durch die Hinzufügung von CTV und CSFS zu
    Bitcoin untergraben würde.
    Einige Tage nach Beginn der Diskussion wurde BIP119 von seinem
    Autor aktualisiert, um den umstrittenen Text zu entfernen;
    siehe [Newsletter #347][news347 bip119] für unsere Zusammenfassung
    der Änderung und die [ältere Version][bip119 prechange]
    von BIP119 für den Referenzwert. Einige der diskutierten Themen umfassten:

    - *CTV+CSFS ermöglicht die Erstellung einer perpetuellen Covenant:*
      CTVs Motivation sagte: "Covenants wurden historisch gesehen als nicht
      geeignet für Bitcoin angesehen, da sie zu komplex sind und das
      Risiko bergen, die Fungibilität der durch sie gebundenen Coins zu
      verringern. Dieses BIP führt eine einfache Covenant namens
      *template* ein, die eine begrenzte Anzahl hochwertiger
      Anwendungsfälle ermöglicht, ohne ein signifikantes Risiko einzugehen.
      BIP119-Vorlagen ermöglichen **non-recursive** vollständig aufgezählte
      Covenants ohne dynamischen Zustand" (Hervorhebung im Original).

      Towns beschreibt ein Skript, das sowohl CTV als auch CSFS verwendet,
      und verlinkt auf eine [Transaktion][mn recursive], die es auf dem MutinyNet
      [Signet][topic signet] verwendet, die nur durch das Senden des gleichen
      Betrags an die Skript selbst ausgegeben werden kann.
      Obwohl es einige Debatten über Definitionen gab,
      hat der Autor von CTV zuvor eine funktional identische Konstruktion
      als rekursive Covenant beschrieben, und Optech folgte dieser Konvention in seiner
      Zusammenfassung dieses Gesprächs
      (siehe [Newsletter #190][news190 recursive]).

      Olaoluwa Osuntokun [verteidigte][osuntokun enum] CTVs
      Motivation in Bezug auf Skripte, die es verwenden,
      die "vollständig aufgezählt" und "ohne dynamischen Zustand" bleiben.
      Dies scheint einem [Argument][rubin enumeration] zu ähneln,
      das der Autor von CTV (Jeremy Rubin) 2022 gemacht hat, als er den
      Typ der pay-to-self-Covenant, den Towns entworfen hat, als "rekursiv,
      aber vollständig aufgezählt" bezeichnete. Towns [entgegnete][towns enum],
      dass die Hinzufügung von CSFS den angeblichen Vorteil der
      vollständigen Aufzählung untergräbt. Er bat um eine Aktualisierung der
      CTV- oder CSFS-BIPs, um Anwendungsfälle zu beschreiben, die "irgendwie
      sowohl beunruhigend als auch durch die Kombination von CTV und CSFS verhindert werden".
      Dies könnte in der jüngsten Aktualisierung von BIP119 geschehen sein, die eine
      "self-reproduzierende Automaten (umgangssprachlich als SpookChains bezeichnet)"
      beschreibt, die mit [SIGHASH_ANYPREVOUT][topic sighash_anyprevout] möglich wären,
      aber nicht mit CTV+CSFS.

    - *Werkzeuge für CTV und CSFS:* Towns [notierte][towns ctvmot],
      dass er es schwierig fand, bestehende Werkzeuge zu verwenden,
      um sein rekursives Skript zu entwickeln, was auf einen Mangel
      an Bereitschaft für die Bereitstellung hinweist. Osuntokun
      [sagte][osuntokun enum], dass die Werkzeuge, die er verwendet,
      "ziemlich einfach" seien. Weder Towns noch Osuntokun erwähnten,
      welche Werkzeuge sie verwendet haben. Nadav Ivgi [stelle][ivgi minsc]
      ein Beispiel mit seiner [Minsc][]-Sprache vor und sagte, dass er daran arbeitet,
      Minsc zu verbessern, um solche Dinge einfacher zu machen.
      Es unterstützt Taproot, CTV, PSBT, Deskriptoren, Miniscript, rohe Skripte,
      BIP32 und mehr. Allerdings gab er zu, dass viel davon noch nicht dokumentiert ist.

    - *Alternativen:* Towns vergleicht CTV+CSFS mit seinem Basic Bitcoin Lisp Language
      ([bll][topic bll]) und [Simplicity][topic simplicity], die eine alternative
      Skriptsprache bieten würden. Antoine Poinsot [schlägt vor][poinsot alt],
      dass eine alternative Sprache, die einfach zu verstehen ist,
      weniger riskant sein könnte als eine kleine Änderung des aktuellen Systems,
      die schwer zu verstehen ist. Der Entwickler Moonsettler [argumentiert][moonsettler express],
      dass die schrittweise Einführung neuer Funktionen in das
      Bitcoin-Skript es sicherer macht, weitere Funktionen hinzuzufügen,
      da jede Erhöhung der Ausdrucksfähigkeit es weniger wahrscheinlich macht,
      dass wir auf eine Überraschung stoßen.

      Sowohl Osuntokun als auch James O'Beirne [kritisierten][osuntokun enum]
      die [Bereitschaft][obeirne readiness] von bll und Simplicity
      im Vergleich zu CTV und CSFS.

  - *Vorteile von CTV+CSFS:* Steven Roose [postete][roose ctvcsfs]
    auf Delving Bitcoin, um vorzuschlagen, CTV und CSFS zu Bitcoin hinzuzufügen,
    als ersten Schritt zu weiteren Änderungen, welche die Ausdrucksfähigkeit weiter
    erhöhen würden. Der Großteil der Diskussion konzentrierte sich auf die
    Qualifizierung der möglichen Vorteile von CTV, CSFS oder beiden zusammen.
    Dies umfasste:

    - *DLCs:* Sowohl CTV als auch CSFS können einzeln die Anzahl der benötigten
      Signaturen reduzieren, um [DLCs][topic dlc] zu erstellen, insbesondere DLCs
      für das Unterzeichnen einer großen Anzahl von Varianten eines Vertrags
      (z. B. ein BTC-USD-Preisvertrag, der in Ein-Dollar-Schritten denominiert ist).
      Antoine Poinsot [verlinkte][poinsot ctvcsfs1] auf eine kürzliche
      [Ankündigung][10101 shutdown] eines DLC-Service-Providers, der seinen Betrieb einstellte,
      als Beweis dafür, dass Bitcoin-Benutzer nicht sehr an DLCs interessiert sind,
      und verlinkte auf einen [Beitrag][nick dlc] von Jonas Nick vor einigen Monaten,
      der sagte: "DLCs haben auf Bitcoin keine bedeutende Akzeptanz erlangt,
      und ihre begrenzte Verwendung scheint nicht auf Leistungsbeschränkungen zurückzuführen zu sein.
      " Antworten verlinkten auf andere noch funktionierende DLC-Service-Provider,
      einschließlich eines, der [behauptet][lava 30m],
      30 Millionen US-Dollar an Finanzierung aufgebracht zu haben.

    - *Vaults:* CTV vereinfacht die Implementierung von [Vaults][topic  vaults],
      die heute auf  Bitcoin mithilfe von presigned Transaktionen und (optional)
      privater Schlüssellöschung möglich sind. Anthony Towns [argumentiert][towns vaults],
      dass dieser Typ von Vault nicht sehr interessant ist. James O'Beirne
      [widerspricht][obeirne ctv-vaults], dass CTV oder etwas Ähnliches eine Voraussetzung
      für die Erstellung von fortgeschritteneren Vault-Typen ist, wie z.B. seinen [BIP345][]
      `OP_VAULT`-Vaults.

    - *Rechenschaftspflichtige Computing-Verträge:* CSFS kann viele Schritte in
      [rechenschaftspflichtigen Computing-Verträgen][topic acc] wie BitVM eliminieren,
      indem es die aktuelle Notwendigkeit ersetzt, Script-basierte Lamport-Signaturen
      auszuführen. CTV könnte in der Lage sein, einige zusätzliche Signaturoperationen zu
      reduzieren. Poinsot [fragt][poinsot ctvcsfs1] wieder , ob es eine signifikante
      Nachfrage nach BitVM gibt. Gregory Sanders [antwortet][sanders bitvm],
      dass er es interessant finden würde, Token in beide Richtungen zu überbrücken,
      als Teil der geschützten [Client-seitigen Validierung][topic client-side validation]
      (siehe [Newsletter #322][news322 csv-bitvm]). Allerdings bemerkt er auch,
      dass weder CTV noch CSFS das Vertrauensmodell von BitVM wesentlich verbessern,
      während andere Änderungen in der Lage sein könnten,
      das Vertrauen zu reduzieren oder die Anzahl der teuren Operationen auf andere
      Weise zu reduzieren.

    - *Verbesserung im Liquid-Timelock-Skript:* James O'Beirne
      [weiterleitete][obeirne liquid] Kommentare von zwei Blockstream-Ingenieuren,
      dass CTV, in seinen Worten, "drastisch das [Blockstream]
      Liquid Timelock-Fallback-Skript verbessern würde, das eine
      periodische Verschiebung von Coins erfordert."
      Nach Anfragen um Klarstellung erklärte der ehemalige Blockstream-Ingenieur
      Sanket Kanjalkar [kanjalkar liquid], dass der Vorteil eine signifikante
      Einsparung an On-Chain-Transaktionsgebühren sein könnte.
      O'Beirne teilte auch [weitere Details][poelstra liquid] von Andrew Poelstra,
      dem Forschungsdirektor von Blockstream, mit.

    - *LN-Symmetrie:* CTV und CSFS können gemeinsam verwendet werden,
      um eine Form von [LN-Symmetrie][topic eltoo] zu implementieren,
      die einige der Nachteile von [LN-Penalty][topic ln-penalty]-Kanälen
      eliminiert, die derzeit in LN verwendet werden, und möglicherweise
      die Erstellung von Kanälen mit mehr als zwei Parteien ermöglicht,
      was die Liquiditätsverwaltung und die On-Chain-Effizienz verbessern könnte.
      Gregory Sanders, der eine experimentelle Version von LN-Symmetrie
      (siehe [Newsletter #284][news284 lnsym]) mithilfe von
      [SIGHASH_ANYPREVOUT][topic sighash_anyprevout] (APO) implementiert hat,
      [bemerkt][sanders versus], dass die CTV+CSFS-Version von LN-Symmetrie
      nicht so funktionsreich ist wie die APO-Version und Kompromisse erfordert.
      Anthony Towns [fügt hinzu][towns nonrepo], dass niemand bekanntermaßen Sanders'
      experimentellen Code für APO aktualisiert hat, um ihn auf moderner Software zu
      verwenden und neu eingeführte Relay-Features wie [TRUC][topic v3 transaction relay]
      und [ephemeral Anchors][topic ephemeral anchors] zu nutzen, geschweige denn,
      dass jemand den Code auf CTV+CSFS portiert hat, was unsere Fähigkeit einschränkt,
      diese Kombination für LN-Symmetrie zu bewerten.

      Poinsot [fragt][poinsot ctvcsfs1], ob die Implementierung von
      LN-Symmetrie für LN-Entwickler eine Priorität wäre,
      wenn ein Soft Fork es ermöglichen würde. Zitate von zwei Core
      Lightning-Entwicklern (die auch Co-Autoren des Papiers sind,
      das wir jetzt LN-Symmetrie nennen), deuteten darauf hin, dass es
      für sie eine Priorität ist. Im Vergleich dazu sagte Matt Corallo,
      der Leitende Entwickler von LDK, [zuvor][corallo eltoo],
      "Ich finde [LN-Symmetrie] nicht besonders interessant in Bezug auf 'wir müssen das erledigen'".

    - *Ark:* Roose ist der CEO eines Unternehmens,
      das eine [Ark][topic ark]-Implementierung entwickelt. Er sagt:
      "CTV ist ein Game-Changer für Ark [...] die Vorteile von CTV für die
      Benutzererfahrung sind unbestreitbar, und es ist ohne Zweifel, dass beide
      [Ark]-Implementierungen CTV nutzen werden, sobald es verfügbar ist."
      Towns [bemerkte][towns nonrepo], dass niemand Ark mit entweder APO oder
      CTV für Tests implementiert hat; Roose schrieb [Code][roose ctv-ark]
      dazu kurz darauf, nannte es "erstaunlich einfach" und sagte, dass es die
      IntegrationsTests der bestehenden Implementierung bestanden hat.
      Er quantifizierte einige der Verbesserungen: Wenn sie zu CTV wechseln,
      "könnten wir etwa 900 Zeilen Code entfernen [...]
      und unser eigenes Rundprotokoll auf zwei statt drei reduzieren,
      [plus] die Bandbreitenverbesserung, da wir keine Signier-Nonces und
      Teil-Signaturen mehr übertragen müssen."

      Roose startete später einen separaten Thread, um die Vorteile von CTV
      für Ark-Benutzer zu diskutieren (siehe unsere Zusammenfassung unten).

  - *Vorteile von CTV für Ark-Benutzer:* Steven Roose [postete][roose ctv-for-ark]
      auf Delving Bitcoin eine kurze Beschreibung des
      [Ark][topic ark]-Protokolls, das derzeit auf [Signet][topic signet]
      bereitgestellt wird und [coventless Ark][clark doc] (clArk) genannt wird,
      und wie die Verfügbarkeit des [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify]
      (CTV)-Opcodes eine [Covenant][topic covenants]-nutzende
      Version des Protokolls für Benutzer attraktiver machen könnte,
      wenn es schließlich auf Mainnet bereitgestellt wird.

      Ein Designziel für Ark ist es, [asynchrone Zahlungen][topic async payments]
      zu ermöglichen: Zahlungen, die vorgenommen werden,
      wenn der Empfänger offline ist. In clArk wird dies durch den Ausgeber
      und einen Ark-Server erreicht, der die bestehende Kette von presigned
      Transaktionen des Ausgebers erweitert, sodass der Empfänger letztendlich
      die exklusive Kontrolle über die Mittel übernehmen kann. Die Zahlung wird
      als Ark-[out-of-round][oor doc]-Zahlung (arkoor) bezeichnet.
      Wenn der Empfänger online kommt, kann er wählen, was er tun möchte:

      - *Ausstieg nach einer Verzögerung:* Die gesamte Kette von presigned Transaktionen
      wird übertragen, um die [Joinpool][topic joinpools] (genannt Ark) zu verlassen.
      Dies erfordert das Warten auf die Ablaufzeit einer Timelock, die vom Ausgeber
      vereinbart wurde. Wenn die presigned Transaktionen zu einer angemessenen Tiefe
      bestätigt sind, kann der Empfänger sicher sein, dass er treuhänderische Kontrolle
      über die Mittel hat. Allerdings verliert er die Vorteile, die mit der Teilnahme an einer
      Joinpool verbunden sind, wie z.B. schnelle Abwicklung und geringere
      Gebühren durch UTXO-Teilung. Er muss möglicherweise auch Transaktionsgebühren
      zahlen, um die Kette von Transaktionen zu bestätigen.

      - *Nichts:* Im normalen Fall wird eine presigned Transaktion in der Kette
        von Transaktionen schließlich ablaufen und es dem Server ermöglichen,
        die Mittel zu beanspruchen. Dies ist kein Diebstahl - es ist ein erwarteter
        Teil des Protokolls - und der Server kann entscheiden, ob er einen Teil oder
        alle der beanspruchten Mittel an den Benutzer zurückgibt.
        Bis zum Ablauf kann der Empfänger einfach warten.

        Im pathologischen Fall können der Server und der Ausgeber jederzeit kolludieren,
        um eine alternative Kette von Transaktionen zu signieren und die Mittel zu stehlen,
        die an den Empfänger gesendet wurden. Beachten Sie: Die Privatsphäre-Eigenschaften von
        Bitcoin ermöglichen es sowohl dem Server als auch dem Ausgeber, dieselbe Person zu sein,
        sodass eine Kollusion möglicherweise nicht erforderlich ist. Wenn der Empfänger
        jedoch eine Kopie der Kette von Transaktionen aufbewahrt, die vom Server co-signiert wurde,
        kann er beweisen, dass der Server die Mittel gestohlen hat, was möglicherweise ausreicht,
        um andere Menschen davon abzuhalten, diesen Server zu verwenden.

      - *Aktualisierung:* Mit Hilfe des Servers kann der Empfänger atomar die
      Eigentumsrechte an den Mitteln in der vom Ausgeber co-signierten
      Transaktion auf eine andere presigned Transaktion mit dem
      Empfänger als Co-Signer übertragen. Dies verlängert das Ablaufdatum
      und eliminiert die Möglichkeit, dass der Server und
      der vorherige Ausgeber kolludieren, um die zuvor gesendeten Mittel zu stehlen.
      Allerdings erfordert die Aktualisierung, dass der Server die aktualisierten Mittel
      bis zum Ablaufdatum zurückhält, was die Liquidität des Servers reduziert.
      Deshalb verlangt der Server vom Empfänger einen Zinssatz bis zum Ablaufdatum
      (der im Voraus bezahlt wird, da das Ablaufdatum festgelegt ist).

      Ein weiteres Designziel für Ark ist es, es Teilnehmern zu ermöglichen,
      LN-Zahlungen zu empfangen. In seinem ursprünglichen Beitrag und einer
      [Antwort][roose ctv-ark-ln] beschreibt Roose, dass bestehende Teilnehmer,
      die bereits Mittel innerhalb der Joinpool haben, bis zu den Kosten einer
      On-Chain-Transaktion bestraft werden können, wenn sie die erforderliche
      Interaktivität für den Empfang einer LN-Zahlung nicht ausführen.
      Allerdings können diejenigen, die noch keine Mittel in der Joinpool haben,
      nicht bestraft werden, sodass sie die interaktiven Schritte verweigern und
      kostenlos Probleme für ehrliche Teilnehmer verursachen können.
      Dies scheint effektiv zu verhindern, dass Ark-Benutzer LN-Zahlungen empfangen können,
      es sei denn, sie haben bereits eine moderate Menge an Mitteln auf dem Ark-Server, den sie verwenden möchten.

      Roose beschreibt dann, wie die Verfügbarkeit von CTV es ermöglichen würde,
      das Protokoll zu verbessern. Die wichtigste Änderung betrifft die Erstellung von Ark-Runden.
      Eine Ark-Runde besteht aus einer kleinen On-Chain-Transaktion, die sich auf einen
      Baum von Off-Chain-Transaktionen bezieht. Dies sind presigned Transaktionen
      im Falle von clArk, die erfordern, dass alle Ausgeber in dieser Runde für die
      Signierung verfügbar sind. Wenn CTV verfügbar wäre, kann jede Zweigstelle
      im Baum von Transaktionen ihre Nachfolger mithilfe von CTV ohne Signierung verpflichten.
      Dies ermöglicht die Erstellung von Transaktionen sogar für Teilnehmer,
      die zum Zeitpunkt der Erstellung der Runde nicht verfügbar sind,
      mit folgenden Vorteilen:

    - *In-Runde nicht-interaktive Zahlungen:* Anstatt Ark-out-of-round
      (arkoor)-Zahlungen, kann ein Ausgeber, der bereit ist, auf die nächste
      Runde zu warten, den Empfänger in der Runde bezahlen. Für den Empfänger
      hat dies einen großen Vorteil: Sobald die Runde zu einer angemessenen
      Tiefe bestätigt ist, erhält er treuhänderische Kontrolle über die empfangenen
      Mittel (bis das Ablaufdatum näher kommt, zu dem Zeitpunkt kann er entweder
      aussteigen oder günstig aktualisieren). Anstatt auf mehrere Bestätigungen zu warten,
      kann der Empfänger wählen, sofort den Anreizen zu vertrauen, die durch das
      Ark-Protokoll für den Server geschaffen werden, um ehrlich zu operieren
      (siehe [Newsletter #253][news253 ark 0conf]). In einem separaten Punkt bemerkt Roose,
      dass diese nicht-interaktiven Zahlungen auch
      [batched][topic payment batching] werden können,
      um mehrere Empfänger auf einmal zu bezahlen.

    - *In-Runde-Akzeptanz von LN-Zahlungen:* Ein Benutzer könnte anfordern,
      dass eine LN-Zahlung ([HTLC][topic htlc]) an einen Ark-Server gesendet wird,
      der Server würde dann die Zahlung [halten][topic hold invoices],
      bis seine nächste Runde, und er würde CTV verwenden, um eine HTLC-gesperrte
      Zahlung an den Benutzer in die Runde aufzunehmen - nach dem der Benutzer den
      HTLC-Preimage bekanntgeben könnte, um die Zahlung zu erhalten. Allerdings bemerkte Roose,
      dass dies immer noch die Verwendung von "verschiedenen Missbrauchsschutzmaßnahmen"
      erfordern würde (wir glauben, dass dies aufgrund des Risikos ist,
      dass der Empfänger den Preimage nicht bekanntgibt, was dazu führt,
      dass die Mittel des Servers bis zum Ende der Ark-Runde gesperrt bleiben,
      was möglicherweise zwei oder mehr Monate dauern könnte).

      David Harding [antwortete][harding ctv-ark-ln] auf Roose und bat um weitere
      Details und verglich die Situation mit LN-[JIT-Kanälen][topic jit channels],
      die ein ähnliches Problem mit der Nicht-Offenlegung von HTLC-Preimages haben,
      das Probleme für Lightning-Service-Provider (LSPs) verursacht. LSPs lösen dieses
      Problem derzeit durch die Einführung von trust-basierten Mechanismen
      (siehe [Newsletter #256][news256 ln-jit]). Wenn dieselben Lösungen für
      CTV-Ark geplant wären, würden diese Lösungen auch sicherstellen,
      dass die in-Runde-Akzeptanz von LN-Zahlungen in clArk möglich ist.

    - *Weniger Runden, weniger Signaturen und weniger Speicher:* clArk verwendet
      [MuSig2][topic musig], und jede Partei muss an mehreren Runden teilnehmen,
      mehrere teilweise Signaturen generieren und abgeschlossene
      Signaturen speichern. Mit CTV müsste weniger
      Daten generiert und gespeichert werden und weniger
      Interaktion wäre erforderlich.

- **OP_CHECKCONTRACTVERIFY-Semantik:** Salvatore Ingala [postete][ingala ccv]
  auf Delving Bitcoin, um die Semantik des vorgeschlagenen
  [OP_CHECKCONTRACTVERIFY][topic matt] (CCV)-Opcodes zu beschreiben,
  und verlinkte zu einem [ersten Entwurf eines BIP][ccv bip] und einem
  [Implementierungsentwurf][bitcoin core #32080] für Bitcoin Core.
  Seine Beschreibung beginnt mit einer Übersicht über das Verhalten von CCV:
  Es ermöglicht die Überprüfung, ob ein öffentlicher Schlüssel sich auf eine
  beliebige Datenmenge bezieht. Es kann sowohl den öffentlichen Schlüssel der
  [Taproot][topic taproot]-Ausgabe, die ausgegeben wird, als auch den
  öffentlichen Schlüssel einer Taproot-Ausgabe, die erstellt wird, überprüfen.
  Dies kann verwendet werden, um sicherzustellen, dass Daten aus der ausgegebenen
  Ausgabe auf die erstellte Ausgabe übertragen werden. In Taproot kann eine
  Modifikation der Ausgabe sich auf Tapblätter wie [Tapscripts][topic tapscript] beziehen.
  Wenn die Modifikation sich auf ein oder mehrere Tapscripts bezieht,
  legt sie eine _encumbrance_ (Ausgabebedingung) auf die Ausgabe, die es ermöglicht, Bedingungen,
  die auf der ausgegebenen Ausgabe platziert wurden, auf die erstellte Ausgabe zu übertragen -
  allgemein (aber [umstritten][towns anticov]) als [Covenant][topic covenants] im Bitcoin-Jargon bezeichnet.
  Der Covenant kann die Erfüllung oder Modifikation der Belastung ermöglichen,
  was (respektive) den Covenant beenden oder seine Bedingungen für zukünftige Iterationen modifizieren würde.
  Ingala beschreibt einige der Vorteile und Nachteile dieses Ansatzes:

  - *Vorteile:* native Unterstützung für Taproot, erhöht nicht die Größe von
    Taproot-Einträgen im UTXO-Set und Ausgabewege, die keine zusätzlichen Daten erfordern,
    müssen diese nicht in ihrem Witness-Stack enthalten
    (es gibt also keine zusätzlichen Kosten in diesem Fall).

  - *Nachteile:* funktioniert nur mit Taproot und die Überprüfung von
    Modifikationen erfordert elliptische Kurvenoperationen,
    die teurer sind als (zum Beispiel) SHA256-Operationen.

  Die Übertragung der Ausgabebedingungen von der ausgegebenen Ausgabe
  auf eine erstellte Ausgabe kann nützlich sein, aber viele Covenants werden
  sicherstellen wollen, dass einige oder alle Bitcoins in der ausgegebenen Ausgabe
  an die erstellte Ausgabe weitergegeben werden.
  Ingala beschreibt die drei Optionen von CCV für die Handhabung von Werten.

  - *Ignorieren:* Die Beträge werden nicht überprüft.

  - *Abziehen:* Der Betrag einer Ausgabe, die an einem bestimmten Index
    (z.B. der dritten Ausgabe) erstellt wird, wird vom Betrag der Ausgabe
    abgezogen, die an demselben Index ausgegeben wird, und der verbleibende
    Wert wird verfolgt. Zum Beispiel, wenn die Ausgabe, die an Index drei
    ausgegeben wird, 100 BTC wert ist und die Ausgabe, die an Index drei
    erstellt wird, 70 BTC wert ist, dann verfolgt der Code den verbleibenden
    Wert von 30 BTC. Die Transaktion wird als ungültig markiert,
    wenn die erstellte Ausgabe größer ist als die ausgegebene Ausgabe
    (da dies den verbleibenden Wert verringern würde, vielleicht sogar unter Null).

  - *Standard:* Die Transaktion wird als ungültig markiert, es sei denn,
    der Betrag der Ausgabe, die an einem bestimmten Index erstellt wird,
    ist größer als der Betrag der ausgegebenen Ausgabe plus die Summe aller vorherigen Residuen,
    die noch nicht mit einem _default_ check verwendet wurden.

  Eine Transaktion ist gültig, wenn eine Ausgabe mehr als einmal mit _deduct_
  überprüft wird oder wenn sowohl _deduct_ als auch
  _default_ auf der gleichen Ausgabe verwendet werden.

  Ingala stellt mehrere visuelle Beispiele für Kombinationen der oben genannten
  Operationen bereit. Hier ist unsere textuelle Beschreibung seines Beispiels
  "Teilbetrag senden", das möglicherweise für ein [Vault][topic vaults]
  nützlich sein könnte: Eine Transaktion hat eine Eingabe (die eine Ausgabe ausgibt)
  im Wert von 100 BTC und zwei Ausgaben, eine im Wert von 70 BTC und die andere im Wert von 30 BTC.
  CCV wird während der Transaktionsvalidierung zweimal ausgeführt:

  1. CCV mit _deduct_ operiert auf Index 0 für 100 BTC, die ausgegeben werden,
     um 70 BTC zu erstellen, was einen Restbetrag von 30 BTC ergibt. In einem
     [BIP345][]-Style-Vault würde CCV diese 70 BTC zurück an das gleiche Skript geben,
     durch das sie zuvor gesichert waren.

  2. Beim zweiten Mal wird _default_ auf Index 1 verwendet. Obwohl es in dieser
     Transaktion eine Ausgabe gibt, die auf Index 1 erstellt wird, gibt es keine
     entsprechende Ausgabe, die auf Index 1 ausgegeben wird, so dass der implizite
     Betrag `0` verwendet wird. Zu diesem Nullbetrag wird der Restbetrag von 30 BTC
     aus dem _deduct_ Aufruf auf Index 0 addiert, was bedeutet, dass die erstellte
     Ausgabe mindestens 30 BTC entsprechen muss. In einem BIP345-Style-Vault würde
     CCV das Ausgabeskript anpassen, um es zu ermöglichen, diesen Wert an eine beliebige
     Adresse auszugeben, nachdem ein [Timelock][topic timelocks] abgelaufen ist,
     oder ihn jederzeit an die Haupt-Vault-Adresse des Benutzers zurückzugeben.

  Mehrere alternative Ansätze, die Ingala in Betracht gezogen und verworfen hat,
  werden sowohl in seinem Beitrag als auch in den Antworten diskutiert. Er schreibt:
  "Ich denke, die beiden Betragsverhaltensweisen (Standard und Abziehen) sind sehr
  ergonomisch und decken die überwiegende Mehrheit der wünschenswerten Betragsprüfungen in der Praxis ab."

  Er bemerkt auch, dass er "vollständig ausgestattete Vault-Implementierungen mit `OP_CCV`
  plus [OP_CTV][topic op_checktemplateverify] erstellt hat, die ungefähr äquivalent sind zu
  [...[BIP345][]...]". Darüber hinaus sei eine Version mit reduzierter Funktionalität, die nur
  `OP_CCV` verwendet, als FunktionsTest in der Bitcoin Core-Implementierung von
  `OP_CCV` implementiert worden.

- **Entwurf für BIP veröffentlicht für Konsens-Reinigung:** Antoine Poinsot
  [postete][poinsot cleanup] auf der Bitcoin-Dev-Mailingliste einen Link zu einem
  [Entwurf für ein BIP][cleanup bip], den er für den [Konsens-Reinigung][topic consensus cleanup]-Vorschlag
  für ein Soft-Fork geschrieben hat. Er enthält mehrere Korrekturen:

  - Korrekturen für zwei verschiedene [Time-Warp][topic time warp]-Angriffe,
    die von einer Mehrheit der Rechenleistung verwendet werden könnten,
    um Blöcke mit beschleunigter Rate zu produzieren.

  - Eine Begrenzung für Signaturen-Operationen (Sigops) auf Legacy-Transaktionen,
    um die Erstellung von Blöcken zu verhindern, die sehr langsam zu validieren sind.

  - Eine Korrektur für die [BIP34][]-Einzigartigkeit von Coinbase-Transaktionen,
    die [doppelte Transaktionen][topic duplicate transactions] vollständig verhindern sollte.

  - Ungültigmachung von zukünftigen 64-Byte-Transaktionen
    (berechnet mit der gestrippten Größe),
    um eine Art von [Merkle-Baum-Schwachstelle][topic merkle tree vulnerabilities]
    zu verhindern.

  Technische Antworten waren für alle Teile des Vorschlags außer zwei positiv.
  Der erste Einwand, der in mehreren Antworten geäußert wurde, war die Ungültigmachung
  von 64-Byte-Transaktionen. Die Antworten wiederholten vorherige Kritik (siehe
  [Newsletter #319][news319 64byte]). Es gibt eine alternative Methode,
  um Merkle-Baum-Schwachstellen zu adressieren. Diese Methode ist relativ
  einfach für leichte (SPV) Wallets zu verwenden, aber könnte Herausforderungen
  für die SPV-Validierung in Smart Contracts, wie z.B. Bridges zwischen Bitcoin
  und anderen Systemen, darstellen. Sjors Provoost [schlug vor][provoost bridge],
  dass jemand, der einen onchain-durchsetzbaren Bridge implementiert, Code bereitstellt,
  der den Unterschied zwischen der Annahme, dass 64-Byte-Transaktionen nicht existieren,
  und der Verwendung der alternativen Methode zur Verhinderung von
  Merkle-Baum-Schwachstellen illustriert.

  Der zweite Einwand betraf eine späte Änderung an den Ideen, die in dem BIP enthalten sind,
  die in einem [Beitrag][poinsot nsequence] auf Delving Bitcoin von Poinsot beschrieben wurde.
  Die Änderung erfordert, dass Blöcke, die nach der Aktivierung der Konsens-Reinigung
  erstellt werden, die Flagge setzen, der die Locktime ihrer Coinbase-Transaktion durchsetzbar macht.
  Wie zuvor vorgeschlagen, werden Coinbase-Transaktionen in Blöcken nach der Aktivierung ihre
  Locktime auf ihre Blockhöhe (minus 1) setzen. Diese Änderung bedeutet, dass kein Miner in der Lage ist,
  einen alternativen frühen Bitcoin-Block zu erstellen, der sowohl die Locktime nach der
  Aktivierung als auch die Durchsetzungsflagge verwendet (denn wenn sie es täten, wäre ihre
  Coinbase-Transaktion in dem Block, der sie enthält, aufgrund ihrer Verwendung einer weit
  in der Zukunft liegenden Locktime nicht gültig). Die Unfähigkeit, genau die gleichen
  Werte in einer vergangenen Coinbase-Transaktion zu verwenden, wie sie in einer zukünftigen
  Coinbase-Transaktion verwendet werden, verhindert die Schwachstelle von doppelten Transaktionen.
  Der Einwand gegen diesen Vorschlag war, dass es nicht klar war, ob alle Miner in der Lage sind,
  die Locktime-Durchsetzungsflagge zu setzen.

## Veröffentlichungen und Release-Kandidaten

_Neue Veröffentlichungen und Release-Kandidaten für beliebte Bitcoin-Infrastrukturprojekte.
Bitte ziehen Sie ein Upgrade auf neue Versionen in Betracht oder helfen Sie bei der Testung von Release-Kandidaten._

- [BDK wallet 1.2.0][] fügt Flexibilität für Zahlungen an benutzerdefinierte Skripte hinzu,
behebt einen Randfall im Zusammenhang mit Coinbase-Transaktionen und enthält mehrere weitere
Funktionen und Fehlerbehebungen.

- [LDK v0.1.2][] ist eine Veröffentlichung dieser Bibliothek für den Aufbau von LN-fähigen Anwendungen.
Sie enthält mehrere Leistungsverbesserungen und Fehlerbehebungen.

- [Bitcoin Core 29.0rc3][] ist ein Release-Kandidat für die nächste Hauptversion des vorherrschenden Full
Nodes des Netzwerks. Bitte sehen Sie sich den [Version 29 Testleitfaden][bcc29 testing guide] an.

- [LND 0.19.0-beta.rc1][] ist ein Release-Kandidat für diesen beliebten LN-Knoten. Eine der wichtigsten
Verbesserungen, die wahrscheinlich getestet werden sollte, ist das neue RBF-basierte Fee-Bumping für
kooperative Schließungen.

## Wichtige Code- und Dokumentationsänderungen

_Bedeutende kürzliche Änderungen in [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning repo],
[Eclair][eclair repo], [LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo],
[Hardware Wallet Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay Server][btcpay server repo],
[BDK][bdk repo], [Bitcoin Improvement Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition repo] und [BINANAs][binana repo]._

- [Bitcoin Core #31363][] führt die `TxGraph`-Klasse ein (siehe [Newsletter #341][news341 pr review]), ein
leichtgewichtiges In-Memory-Modell von Mempool-Transaktionen, das nur Feerates und Abhängigkeiten zwischen
Transaktionen verfolgt. Es enthält Mutationsfunktionen wie `AddTransaction`, `RemoveTransaction` und
`AddDependency` sowie Inspektionsfunktionen wie `GetAncestors`,
`GetCluster` und `CountDistinctClusters`. `TxGraph` unterstützt auch das Staging von Änderungen mit Commit-
und Abbruch-Funktionalität. Dies ist Teil des [Cluster-Mempool][topic cluster mempool]-Projekts und bereitet
zukünftige Verbesserungen der Mempool-Eviction, der Reorganisationsbehandlung und der clusterbewussten
Mining-Logik vor.

- [Bitcoin Core #31278][] veraltet den `settxfee`-RPC-Befehl und die `-paytxfee`-Startoption, die es
Benutzern ermöglichen, eine statische Gebühr für alle Transaktionen festzulegen. Benutzer sollten stattdessen
auf [Fee estimation][topic fee estimation] zurückgreifen oder eine gebührenbasierte Transaktion festlegen.
Sie sind für die Entfernung in Bitcoin Core 31.0 markiert.

- [Eclair #3050][] aktualisiert, wie [BOLT12][topic offers]-Zahlungsfehler weitergeleitet werden, wenn der
Empfänger ein direkt verbundener Knoten ist, um immer die Fehlermeldung weiterzuleiten, anstatt sie mit
einem nicht lesbaren `invalidOnionBlinding`-Fehler zu überschreiben. Wenn der Fehler ein `channel_update`
enthält, überschreibt Eclair ihn mit `TemporaryNodeFailure`, um Details über [unannounced channels][topic unannounced channels]
zu vermeiden. Für [blinded routes][topic rv routing], die andere Knoten betreffen, überschreibt Eclair weiterhin Fehler mit
`invalidOnionBlinding`. Alle Fehlermeldungen werden mit der `blinded_node_id` der Wallet verschlüsselt.

- [Eclair #2963][] implementiert das One-Parent-One-Child (1p1c)-[Package Relay][topic package relay], indem Bitcoin Cores
`submitpackage`-RPC-Befehl während Kanalzwangsabschlüssen aufgerufen wird, um sowohl die Commitment-Transaktion
als auch deren Anchor zusammen zu übertragen. Dies ermöglicht die Weiterleitung von Commitment-Transaktionen,
auch wenn deren Feerate unter dem Mempool-Minimum liegt, erfordert jedoch die Verbindung zu Peers, die
Bitcoin Core 28.0 oder höher ausführen. Diese Änderung entfernt die Notwendigkeit, die Feerate von
Commitment-Transaktionen dynamisch festzulegen, und stellt sicher, dass Zwangsabschlüsse nicht stecken
bleiben, wenn Knoten sich über die aktuelle Feerate uneinig sind.

- [Eclair #3045][] macht das `payment_secret`-Feld im äußeren Onion-Payload optional für
Single-Part-[Trampoline payments][topic trampoline payments]. Zuvor enthielt jede Trampoline-Zahlung ein `payment_secret`,
auch wenn keine [Multipath payments][topic multipath payments] (MPP) verwendet wurde. Da Zahlungsschlüssel möglicherweise
erforderlich sind, wenn moderne [BOLT11][]-Rechnungen verarbeitet werden, fügt Eclair einen Dummy ein, wenn keiner
bereitgestellt wird.

- [LDK #3670][] fügt Unterstützung für das Handling und den Empfang von [Trampoline payments][topic trampoline payments]
hinzu, implementiert jedoch noch keinen Trampoline-Routing-Service. Dies ist eine Voraussetzung für eine Art von
[Async payments][topic async payments], die LDK bereitstellen möchte.

- [LND #9620][] fügt [Testnet4][topic testnet]-Unterstützung hinzu, indem die erforderlichen Parameter
und Blockchain-Konstanten wie deren Genesis-Hash hinzugefügt werden.

{% include snippets/recap-ad.md when="2025-04-08 15:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="31363,31278,3050,2963,3045,3670,9620,32080" %}
[bitcoin core 29.0rc3]: https://bitcoincore.org/bin/bitcoin-core-29.0/
[bcc29 testing guide]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/29.0-Release-Candidate-Testing-Guide
[lnd 0.19.0-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.19.0-beta.rc1
[back crsig]: https://bitcointalk.org/index.php?topic=206303.msg2162962#msg2162962
[bip119 prechange]: https://github.com/bitcoin/bips/blob/9573e060e32f10446b6a2064a38bdc2047171d9c/bip-0119.mediawiki
[news75 ctv]: /en/newsletters/2019/12/04/#op-checktemplateverify-ctv
[news190 recursive]: /en/newsletters/2022/03/09/#limiting-script-language-expressiveness
[modern ctv]: /en/newsletters/2019/12/18/#proposed-changes-to-bip-ctv
[rubin enumeration]: https://gnusha.org/pi/bitcoindev/CAD5xwhjj3JAXwnrgVe_7RKx0AVDDy4X-L9oOnwhswXAQFoJ7Bw@mail.gmail.com/
[towns ctvmot]: https://mailing-list.bitcoindevs.xyz/bitcoindev/Z8eUQCfCWjdivIzn@erisian.com.au/
[mn recursive]: https://mutinynet.com/address/tb1p0p5027shf4gm79c4qx8pmafcsg2lf5jd33tznmyjejrmqqx525gsk5nr58
[rubin recurse]: https://gnusha.org/pi/bitcoindev/CAD5xwhjsVA7k7ZQ_QdrcZOxdi+L6L7dvqAj1Mhx+zmBA3DM5zw@mail.gmail.com/
[osuntokun enum]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CAO3Pvs-1H2s5Dso0z5CjKcHcPvQjG6PMMXvgkzLwXgCHWxNV_Q@mail.gmail.com/
[towns enum]: https://mailing-list.bitcoindevs.xyz/bitcoindev/Z8tes4tXo53_DRpU@erisian.com.au/
[ctv spookchain]: https://github.com/bitcoin/bips/pull/1792/files#diff-aaa82c3decf53fb4312de88fbb3cc081da786b72387c9fec7bfb977ad3558b91R589-R593
[ivgi minsc]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CAGXD5f3EGyUVBc=bDoNi_nXcKmW7M_-mUZ7LOeyCCab5Nqt69Q@mail.gmail.com/
[minsc]: https://min.sc/
[poinsot alt]: https://mailing-list.bitcoindevs.xyz/bitcoindev/1JkExwyWEPJ9wACzdWqiu5cQ5WVj33ex2XHa1J9Uyew-YF6CLppDrcu3Vogl54JUi1OBExtDnLoQhC6TYDH_73wmoxi1w2CwPoiNn2AcGeo=@protonmail.com/
[moonsettler express]: https://mailing-list.bitcoindevs.xyz/bitcoindev/Gfgs0GeY513WBZ1FueJBVhdl2D-8QD2NqlBaP0RFGErYbHLE-dnFBN_rbxnTwzlolzpjlx0vo9YSgZpC013Lj4SI_WZR0N1iwbUiNze00tA=@protonmail.com/
[obeirne readiness]: https://mailing-list.bitcoindevs.xyz/bitcoindev/45ce340a-e5c9-4ce2-8ddc-5abfda3b1904n@googlegroups.com/
[nick dlc]: https://gist.github.com/jonasnick/e9627f56d04732ca83e94d448d4b5a51#dlcs
[lava 30m]: https://x.com/MarediaShehzan/status/1896593917631680835
[news322 csv-bitvm]: /en/newsletters/2024/09/27/#shielded-client-side-validation-csv
[news253 ark 0conf]: /en/newsletters/2023/05/31/#making-internal-transfers
[clark doc]: https://ark-protocol.org/intro/clark/index.html
[oor doc]: https://ark-protocol.org/intro/oor/index.html
[lopp destroy]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CADL_X_cF=UKVa7CitXReMq8nA_4RadCF==kU4YG+0GYN97P6hQ@mail.gmail.com/
[boris timelock]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CAFC_Vt54W1RR6GJSSg1tVsLi1=YHCQYiTNLxMj+vypMtTHcUBQ@mail.gmail.com/
[habovstiak gfsig]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CALkkCJY=dv6cZ_HoUNQybF4-byGOjME3Jt2DRr20yZqMmdJUnQ@mail.gmail.com/
[news141 gfsig]: /en/newsletters/2021/03/24/#taproot-improvement-in-post-qc-recovery-at-no-onchain-cost
[guy fawkes signature scheme]: https://www.cl.cam.ac.uk/archive/rja14/Papers/fawkes.pdf
[fournier gfsig]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CALkkCJYaLMciqYxNFa6qT6-WCsSD3P9pP7boYs=k0htAdnAR6g@mail.gmail.com/T/#ma2a9878dd4c63b520dc4f15cd51e51d31d323071
[wuille nonpublic]: https://mailing-list.bitcoindevs.xyz/bitcoindev/pXZj0cBHqBVPjkNPKBjiNE1BjPHhvRp-MwPaBsQu-s6RTEL9oBJearqZE33A2yz31LNRNUpZstq_q8YMN1VsCY2vByc9w4QyTOmIRCE3BFM=@wuille.net/T/#mfced9da4df93e56900a8e591d01d3b3abfa706ed
[cruz qramp]: https://mailing-list.bitcoindevs.xyz/bitcoindev/08a544fa-a29b-45c2-8303-8c5bde8598e7n@googlegroups.com/
[news347 bip119]: /de/newsletters/2025/03/28/#bips-1792
[roose ctvcsfs]: https://delvingbitcoin.org/t/ctv-csfs-can-we-reach-consensus-on-a-first-step-towards-covenants/1509/
[poinsot ctvcsfs1]: https://delvingbitcoin.org/t/ctv-csfs-can-we-reach-consensus-on-a-first-step-towards-covenants/1509/4
[10101 shutdown]: https://10101.finance/blog/10101-is-shutting-down
[towns vaults]: https://delvingbitcoin.org/t/ctv-csfs-can-we-reach-consensus-on-a-first-step-towards-covenants/1509/14
[obeirne ctv-vaults]: https://delvingbitcoin.org/t/ctv-csfs-can-we-reach-consensus-on-a-first-step-towards-covenants/1509/23
[sanders bitvm]: https://delvingbitcoin.org/t/ctv-csfs-can-we-reach-consensus-on-a-first-step-towards-covenants/1509/7
[obeirne liquid]: https://delvingbitcoin.org/t/ctv-csfs-can-we-reach-consensus-on-a-first-step-towards-covenants/1509/24
[kanjalkar liquid]: https://delvingbitcoin.org/t/ctv-csfs-can-we-reach-consensus-on-a-first-step-towards-covenants/1509/28
[poelstra liquid]: https://delvingbitcoin.org/t/ctv-csfs-can-we-reach-consensus-on-a-first-step-towards-covenants/1509/32
[news284 lnsym]: /en/newsletters/2024/01/10/#ln-symmetry-research-implementation
[sanders versus]: https://delvingbitcoin.org/t/ctv-csfs-can-we-reach-consensus-on-a-first-step-towards-covenants/1509/7
[towns nonrepo]: https://delvingbitcoin.org/t/ctv-csfs-can-we-reach-consensus-on-a-first-step-towards-covenants/1509/14
[roose ctv-ark]: https://codeberg.org/ark-bitcoin/bark/src/branch/ctv
[roose ctv-for-ark]: https://delvingbitcoin.org/t/the-ark-case-for-ctv/1528/
[roose ctv-ark-ln]: https://delvingbitcoin.org/t/the-ark-case-for-ctv/1528/5
[harding ctv-ark-ln]: https://delvingbitcoin.org/t/the-ark-case-for-ctv/1528/8
[news256 ln-jit]: /en/newsletters/2023/06/21/#just-in-time-jit-channels
[ruffing gfsig]: https://gnusha.org/pi/bitcoindev/1518710367.3550.111.camel@mmci.uni-saarland.de/
[cruz bip]: https://github.com/chucrut/bips/blob/master/bip-xxxxx.md
[towns anticov]: https://gnusha.org/pi/bitcoindev/20220719044458.GA26986@erisian.com.au/
[ccv bip]: https://github.com/bitcoin/bips/pull/1793
[ingala ccv]: https://delvingbitcoin.org/t/op-checkcontractverify-and-its-amount-semantic/1527/
[news319 64byte]: /en/newsletters/2024/09/06/#mitigating-merkle-tree-vulnerabilities
[poinsot nsequence]: https://delvingbitcoin.org/t/great-consensus-cleanup-revival/710/79
[provoost bridge]: https://mailing-list.bitcoindevs.xyz/bitcoindev/19f6a854-674a-4e4d-9497-363af306e3a0@app.fastmail.com/
[poinsot cleanup]: https://mailing-list.bitcoindevs.xyz/bitcoindev/uDAujRxk4oWnEGYX9lBD3e0V7a4V4Pd-c4-2QVybSZNcfJj5a6IbO6fCM_xEQEpBvQeOT8eIi1r91iKFIveeLIxfNMzDys77HUcbl7Zne4g=@protonmail.com/
[cleanup bip]: https://github.com/darosior/bips/blob/consensus_cleanup/bip-cc.md
[news312 chilldkg]: /en/newsletters/2024/07/19/#distributed-key-generation-protocol-for-frost
[fnr secp]: https://mailing-list.bitcoindevs.xyz/bitcoindev/d0044f9c-d974-43ca-9891-64bb60a90f1f@gmail.com/
[secp256k1lab]: https://github.com/secp256k1lab/secp256k1lab
[corallo eltoo]: https://x.com/TheBlueMatt/status/1857119394104500484
[bdk wallet 1.2.0]: https://github.com/bitcoindevkit/bdk/releases/tag/wallet-1.2.0
[ldk v0.1.2]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.1.2
[news341 pr review]: /de/newsletters/2025/02/14/#bitcoin-core-pr-review-club