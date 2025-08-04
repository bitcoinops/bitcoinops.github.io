---
title: 'Bitcoin Optech Newsletter #365'
permalink: /de/newsletters/2025/08/01/
name: 2025-08-01-newsletter-de
slug: 2025-08-01-newsletter-de
type: newsletter
layout: newsletter
lang: de
---
Der Newsletter dieser Woche fasst die Ergebnisse eines Tests zum Prefilling beim
Compact-Block-Relay zusammen und verweist auf eine mempool-basierte Bibliothek
zur Gebührenabschätzung. Wie gewohnt enthält der Newsletter unsere regelmäßigen
Abschnitte mit Zusammenfassungen zu Diskussionen über Änderungen der
Konsensregeln von Bitcoin, der Ankündigung neuer Releases und Release-Kandidaten
sowie einer Übersicht wichtiger Änderungen an beliebter Bitcoin-Infrastruktur-Software.

## Nachrichten

- **Test zu Compact-Block-Prefilling:** David Gumberg [antwortete][gumberg prefilling]
  in einem Delving-Bitcoin-Thread zur Effizienz der Compact-Block-Rekonstruktion
  (siehe auch [Newsletter #315][news315 cb] und [#339][news339 cb]) mit einer
  Zusammenfassung seiner Testergebnisse zum [Compact-Block-Relay][topic compact block relay]
  und dem sogenannten Prefilling. Dabei sendet ein Knoten proaktiv einige oder alle
  Transaktionen eines neuen Blocks an seine Peers, wenn er annimmt, dass diese die
  Transaktionen noch nicht haben. Gumbergs Beitrag ist ausführlich und enthält einen
  Link zu einem Jupyter-Notebook, mit dem andere selbst experimentieren können. Die
  wichtigsten Erkenntnisse:

  - Unabhängig vom Netzwerktransport erhöhte eine einfache Regel zur Auswahl der
    zu prefillenden Transaktionen die Erfolgsrate der Blockrekonstruktion von etwa
    62 % auf etwa 98 %.

  - Unter Berücksichtigung des Netzwerktransports führten einige Prefills zu einem
    zusätzlichen Roundtrip, was den Vorteil in diesen Fällen aufhob und die Leistung
    leicht verschlechterte. Viele Prefills hätten jedoch so konstruiert werden können,
    dass das Problem vermieden wird, wodurch die Rekonstruktionsrate auf etwa 93 %
    stieg und weitere Verbesserungen möglich bleiben.

- **Mempool-basierte Gebührenabschätzungs-Bibliothek:** Lauren Shareshian
  [kündigte][shareshian estimation] auf Delving Bitcoin eine von Block entwickelte
  Bibliothek zur [Gebührenabschätzung][topic fee estimation] an. Im Gegensatz zu
  anderen Tools nutzt sie ausschließlich den Zufluss von Transaktionen in den
  Mempool eines Knotens als Grundlage für ihre Schätzungen. Im Beitrag wird die
  Bibliothek „Augur“ mit mehreren anderen Gebührenabschätzungsdiensten verglichen
  und festgestellt, dass Augur eine niedrige Fehlerrate aufweist (über 85 % der
  Transaktionen werden im gewünschten Zeitfenster bestätigt) und eine geringe
  durchschnittliche Überschätzung (Transaktionen zahlen im Schnitt nur etwa 16 % zu
  viel Gebühr).

  Abubakar Sadiq Ismail [antwortete][ismail estimation] im Delving-Thread und
  eröffnete zudem ein informatives [Issue][augur #3] im Augur-Repository, um einige
  der in der Bibliothek verwendeten Annahmen zu untersuchen.

## Konsensänderungen

_Monatlicher Abschnitt mit Zusammenfassungen zu Vorschlägen und Diskussionen über Änderungen der
Bitcoin-Konsensregeln._

- **Migration von quantenanfälligen Outputs:** Jameson Lopp
  [veröffentlichte][lopp qmig] in der Bitcoin-Dev-Mailingliste einen dreistufigen
  Vorschlag, um das Ausgeben von [quantenanfälligen Outputs][topic quantum resistance]
  schrittweise zu beenden.

  - Drei Jahre nach der Konsensaktivierung des
    [BIP360][]-Signaturschemas (oder eines alternativen quantenresistenten Schemas)
    würde ein Softfork Transaktionen mit Ausgaben an quantenanfällige Adressen ablehnen.
    Nur Ausgaben an quantenresistente Outputs wären dann erlaubt.

  - Zwei Jahre später würde ein zweiter Softfork das Ausgeben von
    quantenanfälligen Outputs vollständig verbieten. Alle verbleibenden
    Mittel auf solchen Outputs wären dann nicht mehr ausgebbar.

  - Optional könnte zu einem späteren, noch nicht definierten Zeitpunkt
    eine Konsensänderung das Ausgeben von quantenanfälligen Outputs mit
    einem quantenresistenten Nachweisverfahren erlauben (siehe
    [Newsletter #361][news361 pqcr] für ein Beispiel).

  Ein Großteil der Diskussion im Thread wiederholte frühere Debatten darüber,
  ob es notwendig ist, das Ausgeben von quantenanfälligen Bitcoins zu verhindern,
  bevor sicher ist, dass ein ausreichend leistungsfähiger Quantencomputer existiert
  (siehe [Newsletter #348][news348 destroy]). Für beide Seiten wurden nachvollziehbare
  Argumente vorgebracht, und es ist zu erwarten, dass diese Debatte weitergeführt wird.

- **Taproot-nativer `OP_TEMPLATEHASH`-Vorschlag:** Greg Sanders
  [veröffentlichte][sanders th] in der Bitcoin-Dev-Mailingliste einen Vorschlag,
  drei neue Opcodes zu [Tapscript][topic tapscript] hinzuzufügen. Zwei davon sind die
  bereits vorgeschlagenen [OP_CHECKSIGFROMSTACK][topic op_checksigfromstack] und
  `OP_INTERNALKEY` (siehe [Newsletter #285][news285 ik]). Der dritte Opcode ist
  `OP_TEMPLATEHASH`, eine taproot-native Variante von
  [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify] (`OP_CTV`) mit folgenden,
  von den Autoren hervorgehobenen Unterschieden:

  - Keine Änderungen an Legacy-Skripten (vor Segwit). Siehe
    [Newsletter #361][news361 ctvlegacy] für frühere Diskussionen zu dieser Alternative.

  - Die zu hashenden Daten (und deren Reihenfolge) ähneln stark denen, die für Signaturen
    in [Taproot][topic taproot] verwendet werden. Das vereinfacht die Implementierung für
    Software, die Taproot bereits unterstützt.

  - Es bindet den Taproot
    [Annex][topic annex] ein, was `OP_CTV` nicht tut.
    Damit kann z.B. sichergestellt werden, dass bestimmte Daten als Teil einer
    Transaktion veröffentlicht werden – etwa für Protokolle, die einer Gegenpartei
    die Wiederherstellung nach der Veröffentlichung eines alten Zustands ermöglichen.

  - Es wird ein `OP_SUCCESSx`-Opcode statt eines `OP_NOPx`-Opcodes redefiniert.
    Softforks, die `OP_NOPx`-Opcodes neu belegen, müssen als `VERIFY`-Opcodes
    implementiert werden, die eine Transaktion bei Fehlschlag ungültig machen.
    Redefinitionen von `OP_SUCCESSx` können einfach `1` (Erfolg) oder `0` (Fehlschlag)
    auf den Stack legen. Dadurch können sie direkt verwendet werden, wo bei
    `OP_NOPx`-Redefinitionen zusätzliche Bedingungen wie `OP_IF` nötig wären.

  - „Es verhindert unerwartete Eingaben mit ... `scriptSig`“ (siehe
    [Newsletter #361][news361 bitvm]).

  Brandon Black [antwortete][black th] mit einem Vergleich des Vorschlags zu seinem
  früheren LNHANCE-Bundle-Vorschlag (siehe [Newsletter #285][news285 ik]) und stellte
  fest, dass beide in den meisten Punkten vergleichbar sind. Allerdings merkte er an,
  dass der neue Vorschlag für _Congestion Control_ (eine Form des verzögerten
  [Payment Batchings][topic payment batching]) weniger effizient im Onchain-Speicherbedarf ist.

- **Vorschlag für längere relative Timelocks:** Entwickler Pyth
  [schlug][pyth timelock] auf Delving Bitcoin vor, die [BIP68][]-basierten relativen Timelocks
  von derzeit maximal etwa einem Jahr auf bis zu zehn Jahre zu verlängern. Dies würde einen
  Softfork und die Nutzung eines zusätzlichen Bits im _sequence_-Feld des Transaktionseingangs
  erfordern.

  Fabian Jahr [antwortete][jahr timelock] mit dem Hinweis, dass zu weit in die Zukunft
  reichende [Timelocks][topic timelocks] zu einem Verlust von Geldern führen könnten, etwa
  durch die Entwicklung von Quantencomputern (oder, ergänzen wir, durch die Einführung von
  Quantenabwehr-Protokollen wie dem weiter oben beschriebenen Vorschlag von Jameson Lopp).
  Steven Roose [merkte an][roose timelock], dass weit in der Zukunft liegende Timelocks
  bereits heute mit anderen Mechanismen möglich sind (z.B. mit vorab signierten
  Transaktionen und [BIP65 CLTV][bip65]). Pyth ergänzte, dass der gewünschte Anwendungsfall
  ein Wallet-Wiederherstellungspfad sei, bei dem der lange Timelock nur genutzt würde, wenn
  der Hauptpfad nicht mehr verfügbar ist und die Alternative ohnehin der dauerhafte Verlust
  der Mittel wäre.

- **Sicherheit gegen Quantencomputer mit Taproot als Commitment-Schema:**
  Tim Ruffing [veröffentlichte][ruffing qtr] einen Link zu einem [Paper][ruffing paper],
  in dem er die Sicherheit von [Taproot][topic taproot]-Commitments gegen Manipulation
  durch Quantencomputer analysiert. Er untersucht, ob Taproot-Commitments zu Tapleaves
  weiterhin die _Bindungs_- und _Verbergungseigenschaften_ besitzen, die sie auch gegen
  klassische Computer haben. Sein Fazit:

  > Ein Quantenangreifer müsste mindestens 2^81 SHA256-Auswertungen durchführen, um ein
  > Taproot-Output zu erzeugen und es mit einer Wahrscheinlichkeit von 1/2 zu einem
  > unerwarteten Merkle-Root öffnen zu können. Falls der Angreifer nur Quantenmaschinen
  > besitzt, deren längste SHA256-Berechnungskette auf 2^20 begrenzt ist, benötigt er
  > mindestens 2^92 solcher Maschinen, um eine Erfolgswahrscheinlichkeit von 1/2 zu erreichen.

  Wenn Taproot-Commitments gegen Manipulation durch Quantencomputer sicher sind, könnte
  Bitcoin quantenresistent gemacht werden, indem Keypath-Spends deaktiviert und
  quantenresistente Signatur-OpCodes zu [Tapscript][topic tapscript] hinzugefügt werden.
  Ein aktuelles Update zu [BIP360][] pay-to-quantum-resistant-hash, das Ethan Heilman
  [veröffentlichte][heilman bip360], schlägt genau diese Änderung vor.

## Releases und Release-Kandidaten

_Neue Releases und Release-Kandidaten für beliebte Bitcoin-Infrastrukturprojekte. Bitte erwägen Sie,
auf neue Versionen zu aktualisieren oder bei der Testung von Release-Kandidaten zu helfen._

- [Bitcoin Core 29.1rc1][] ist ein Release-Kandidat für eine Wartungsversion der führenden Full-Node-Software.


## Bedeutende Code- und Dokumentationsänderungen

_Bedeutende aktuelle Änderungen in [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning repo],
[Eclair][eclair repo], [LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet Interface (HWI)][hwi repo],
[Rust Bitcoin][rust bitcoin repo], [BTCPay Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement Proposals (BIPs)][bips repo],
[Lightning BOLTs][bolts repo], [Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition repo] und [BINANAs][binana repo]._

- [Bitcoin Core #29954][] erweitert das `getmempoolinfo`-RPC um zwei neue Relay-Policy-Felder:
  `permitbaremultisig` (ob der Knoten bare Multisig-Outputs weiterleitet) und
  `maxdatacarriersize` (maximale Gesamtanzahl an Bytes in OP_RETURN-Outputs pro Transaktion im Mempool).
  Andere Policy-Flags wie [`fullrbf`][topic rbf] und `minrelaytxfee` waren bereits verfügbar, sodass diese
  Ergänzungen nun eine vollständige Übersicht der Relay-Policy ermöglichen.

- [Bitcoin Core #33004][] aktiviert die Option `-natpmp` standardmäßig, wodurch automatische
  Portweiterleitung über das [Port Control Protocol (PCP)][pcp] mit Fallback auf das
  [NAT Port Mapping Protocol (NAT-PMP)][natpmp] ermöglicht wird (siehe
  [Newsletter #323][news323 natpmp]). Ein lauschender Knoten hinter einem Router, der PCP oder NAT-PMP
  unterstützt, wird dadurch ohne manuelle Konfiguration erreichbar.

- [LDK #3246][] ermöglicht die Erstellung von [BOLT12-Angeboten][topic offers] und Rückerstattungen
  ohne [Blinded Path][topic rv routing], indem der `signing_pubkey` des Angebots als Ziel verwendet wird.
  Die Funktionen `create_offer_builder` und `create_refund_builder` delegieren die Erstellung des Blinded Path
  nun an `MessageRouter::create_blinded_paths`. Ein Aufrufer kann so einen kompakten Pfad mit
  `DefaultMessageRouter`, einen vollständigen Pubkey-Pfad mit `NodeIdMessageRouter` oder gar keinen Pfad mit
  `NullMessageRouter` erzeugen.

- [LDK #3892][] macht die Merkle-Tree-Signatur von [BOLT12][topic offers]-Rechnungen öffentlich
  zugänglich. Dadurch können Entwickler CLI-Tools oder andere Software bauen, um die Signatur zu
  überprüfen oder Rechnungen zu rekonstruieren. Außerdem wird mit diesem PR ein `OfferId`-Feld zu
  BOLT12-Rechnungen hinzugefügt, um das ursprüngliche Angebot nachzuverfolgen.

- [LDK #3662][] implementiert [BLIPs #55][], auch bekannt als LSPS05. Damit können Clients
  sich über einen Endpunkt für Webhooks registrieren, um Push-Benachrichtigungen von einem LSP zu erhalten.
  Die API stellt zusätzliche Endpunkte bereit, mit denen Clients alle Webhook-Registrierungen auflisten oder
  eine bestimmte entfernen können. Das ist nützlich, um z.B. beim Empfang einer [asynchronen Zahlung][topic async payments]
  benachrichtigt zu werden.

{% include snippets/recap-ad.md when="2025-08-05 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="29954,33004,3246,3892,3662,55" %}
[bitcoin core 29.1rc1]: https://bitcoincore.org/bin/bitcoin-core-29.1/
[augur #3]: https://github.com/block/bitcoin-augur/issues/3
[news315 cb]: /en/newsletters/2024/08/09/#statistics-on-compact-block-reconstruction
[news339 cb]: /de/newsletters/2025/01/31/#aktualisierte-statistiken-zur-kompaktblock-rekonstruktion
[gumberg prefilling]: https://delvingbitcoin.org/t/stats-on-compact-block-reconstructions/1052/34
[shareshian estimation]: https://delvingbitcoin.org/t/augur-block-s-open-source-bitcoin-fee-estimation-library/1848/
[ismail estimation]: https://delvingbitcoin.org/t/augur-block-s-open-source-bitcoin-fee-estimation-library/1848/2
[news361 pqcr]: /de/newsletters/2025/07/04/#commit-reveal-funktion-fur-post-quantum-recovery
[sanders th]: https://mailing-list.bitcoindevs.xyz/bitcoindev/26b96fb1-d916-474a-bd23-920becc3412cn@googlegroups.com/
[news285 ik]: /en/newsletters/2024/01/17/#new-lnhance-combination-soft-fork-proposed
[news361 ctvlegacy]: /de/newsletters/2025/07/04/#bedenken-und-alternativen-zu-legacy-support
[pyth timelock]: https://delvingbitcoin.org/t/exploring-extended-relative-timelocks/1818/
[jahr timelock]: https://delvingbitcoin.org/t/exploring-extended-relative-timelocks/1818/2
[roose timelock]: https://delvingbitcoin.org/t/exploring-extended-relative-timelocks/1818/3
[ruffing qtr]: https://mailing-list.bitcoindevs.xyz/bitcoindev/bee6b897379b9ae0c3d48f53d40a6d70fe7915f0.camel@real-or-random.org/
[ruffing paper]: https://eprint.iacr.org/2025/1307
[heilman bip360]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CAEM=y+W=rtU2PLmHve6pUVkMQQmqT67KOg=9hp5oMspuHrgMow@mail.gmail.com/
[lopp qmig]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CADL_X_fpv-aXBxX+eJ_EVTirkAJGyPRUNqOCYdz5um8zu6ma5Q@mail.gmail.com/
[news348 destroy]: /de/newsletters/2025/04/04/#sollten-gefahrdete-bitcoins-vernichtet-werden
[black th]: https://mailing-list.bitcoindevs.xyz/bitcoindev/aG9FEHF1lZlK6d0E@console/
[news361 bitvm]: /de/newsletters/2025/07/04/#weitere-diskussion-zu-ctv-csfs-vorteilen-fur-bitvm
[news323 natpmp]: /en/newsletters/2024/10/04/#bitcoin-core-30043
[pcp]: https://datatracker.ietf.org/doc/html/rfc6887
[natpmp]: https://datatracker.ietf.org/doc/html/rfc6886
