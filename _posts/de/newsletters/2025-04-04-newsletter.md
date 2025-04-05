---
title: 'Bitcoin Optech Newsletter #348'
permalink: /de/newsletters/2025/04/04/
name: 2025-04-04-newsletter-de
slug: 2025-04-04-newsletter-de
type: newsletter
layout: newsletter
lang: de
---
Der Newsletter dieser Woche verweist auf eine lehrreiche Implementierung der elliptischen
Kurven-Kryptografie für Bitcoins secp256k1-Kurve. Ebenfalls enthalten sind unsere regulären
Abschnitte mit Beschreibungen von Diskussionen über Konsensänderungen, Ankündigungen neuer
Releases und Release-Kandidaten sowie Zusammenfassungen wichtiger Änderungen an populärer
Bitcoin-Infrastruktur-Software.

## Nachrichten

- **Lehrreiche und experimentelle Implementierung von secp256k1:**
  Sebastian Falbesoner, Jonas Nick und Tim Ruffing haben in der Bitcoin-Dev-Mailingliste
  bekanntgegeben, dass eine Python-[Implementierung][secp256k1lab] verschiedener Funktionen
  im Zusammenhang mit der in Bitcoin verwendeten Kryptografie vorliegt. Dabei wird
  ausdrücklich darauf hingewiesen, dass die Implementierung "INSECURE" (im Original in
  Großbuchstaben) und "für Prototyping, Experimente und Bildungszwecke" gedacht ist.

  Zudem weisen sie darauf hin, dass Referenz- und Testcode für mehrere BIPs
  ([340][bip340], [324][bip324], [327][bip327] und [352][bip352]) bereits "benutzerdefinierte
  und teils leicht abweichende Implementierungen von secp256k1" enthält. Man erhofft sich,
  die Situation in Zukunft zu verbessern – eventuell beginnend mit einem kommenden BIP für
  ChillDKG (siehe [Newsletter #312][news312 chilldkg]).

## Konsensänderungen

_Ein monatlicher Abschnitt, der Vorschläge und Diskussionen zu Änderungen der
Bitcoin-Konsensregeln zusammenfasst._

- **Zahlreiche Diskussionen über den Diebstahl durch Quantencomputer und entsprechende Gegenmaßnahmen:**
  In mehreren Gesprächen wurde erörtert, wie Bitcoin-Nutzer reagieren könnten,
  wenn Quantencomputer leistungsfähig genug wären, um Bitcoins zu stehlen.

  - *Sollten gefährdete Bitcoins vernichtet werden?*
    Jameson Lopp [veröffentlicht][lopp destroy] in der Bitcoin-Dev-Mailingliste verschiedene
    Argumente, die dafür sprechen, Bitcoins, die durch Quantenangriffe gefährdet sind, nach
    einer geltenden Migrationsfrist zu vernichten. Zu seinen Argumenten zählen:

    - *Argument der gemeinsamen Präferenz:*
      Er geht davon aus, dass die Mehrheit es vorziehen würde, ihr Geld zu vernichten,
      statt es einem Angreifer mit schnellem Quantencomputer zu überlassen – zumal dieser
      zu den wenigen privilegierten Personen gehören würde, die frühzeitig Zugang zu
      Quantencomputern erhalten.

    - *Argument des gemeinsamen Schadens:*
      Viele der gestohlenen Bitcoins wären entweder dauerhaft verloren oder für den
      langfristigen Halter vorgesehen. Durch einen schnellen Verbrauch der gestohlenen
      Coins könnte die Kaufkraft der verbleibenden Bitcoins sinken, was unter anderem
      die Miner-Einnahmen reduziert und die Netzwerksicherheit beeinträchtigt.

    - *Argument des minimalen Nutzens:*
      Obwohl der Diebstahl zur Finanzierung der Entwicklung von Quantencomputern beitragen
      könnte, bietet er keinen direkten Nutzen für ehrliche Teilnehmer des Bitcoin-Protokolls.

    - *Argument klarer Fristen:*
      Niemand kann lange im Voraus wissen, wann ein Quantencomputer Bitcoins stehlen kann,
      aber ein spezifisches Datum, an dem gefährdete Coins vernichtet werden, kann präzise
      angekündigt werden. Diese klare Frist würde den Nutzern mehr Anreiz geben, ihre Bitcoins
      rechtzeitig zu sichern, wodurch insgesamt weniger Coins verloren gehen.

    - *Argument der Miner-Anreize:*
      Wie oben erwähnt, würde der Diebstahl durch Quantencomputer wahrscheinlich die
      Miner-Einnahmen reduzieren. Eine Mehrheit der Hashrate könnte die Ausgabe von
      gefährdeten Bitcoins zensieren, selbst wenn der Rest der Bitcoin-Nutzer eine andere
      Lösung bevorzugt.

    Lopp führt auch mehrere Argumente gegen die Vernichtung gefährdeter Bitcoins an, kommt
    jedoch zu dem Schluss, dass die Vernichtung vorzuziehen ist.

    Nagaev Boris [fragt][boris timelock], ob UTXOs, die über die Migrationsfrist hinaus
    [timelocked][topic timelocks] sind, ebenfalls vernichtet werden sollten. Lopp weist
    auf bestehende Fallstricke bei langen Timelocks hin und sagt, dass er persönlich
    "etwas nervös wird, wenn er Gelder für mehr als ein oder zwei Jahre sperrt."

  - *Sicherer Nachweis des UTXO-Besitzes durch Offenlegung eines SHA256-Preimages:*
    Martin Habovštiak [veröffentlicht][habovstiak gfsig] in der Bitcoin-Dev-Mailingliste eine Idee,
    die es jemandem ermöglichen könnte, den Besitz eines UTXO nachzuweisen, selbst wenn ECDSA und
    [Schnorr-Signaturen][topic schnorr signatures] unsicher wären (z. B. nach der Existenz schneller
    Quantencomputer). Wenn das UTXO ein SHA256-Commitment (oder ein anderes quantensicheres Commitment)
    zu einem Preimage enthält, das nie zuvor offengelegt wurde, könnte ein mehrstufiges Protokoll zur
    Offenlegung dieses Preimages mit einer Konsensänderung kombiniert werden, um Quanten-Diebstahl zu
    verhindern. Dies ist im Wesentlichen dasselbe wie ein [früherer Vorschlag][ruffing gfsig] von Tim
    Ruffing (siehe [Newsletter #141][news141 gfsig]), der allgemein als [Guy Fawkes signature scheme][]
    bekannt ist. Es ist auch eine Variante eines [Schemas][back crsig], das Adam Back 2013 erfunden hat,
    um die Widerstandsfähigkeit gegen Miner-Zensur zu verbessern. Kurz gesagt, könnte das Protokoll
    wie folgt funktionieren:

    1. Alice erhält Gelder zu einem Output, der in irgendeiner Weise ein SHA256-Commitment macht.
    Dies kann ein direkt gehashter Output sein, wie P2PKH, P2SH, P2WPKH oder P2WSH – oder es kann ein
    [P2TR][topic taproot]-Output mit einem Skriptpfad sein.

    2. Wenn Alice mehrere Zahlungen an dasselbe Output-Skript erhält, muss sie entweder keine davon
    ausgeben, bis sie bereit ist, alle auszugeben (definitiv erforderlich für P2PKH und P2WPKH;
    wahrscheinlich auch praktisch erforderlich für P2SH und P2WSH), oder sie muss sehr vorsichtig
    sein, um sicherzustellen, dass mindestens ein Preimage von ihr nicht offengelegt wird (leicht
    möglich mit P2TR-Keypath gegenüber Scriptpath-Ausgaben).

    3. Wenn Alice bereit ist, auszugeben, erstellt sie privat ihre Ausgabetransaktion normal, sendet
    sie jedoch nicht. Sie erhält auch einige Bitcoins, die durch einen quantensicheren Signaturalgorithmus
    gesichert sind, damit sie Transaktionsgebühren zahlen kann.

    4. In einer Transaktion, die einige der quantensicheren Bitcoins ausgibt, verpflichtet sie sich zu den
    quantenunsicheren Bitcoins, die sie ausgeben möchte, und verpflichtet sich auch zu der privaten
    Ausgabetransaktion (ohne sie offenzulegen). Sie wartet darauf, dass diese Transaktion tief bestätigt wird.

    5. Nachdem sie sicher ist, dass ihre vorherige Transaktion praktisch nicht reorganisiert werden kann,
    offenbart sie ihr zuvor privates Preimage und die quantenunsichere Ausgabe.

    6. Knoten im Netzwerk durchsuchen die Blockchain, um die erste Transaktion zu finden, die sich zu dem
    Preimage verpflichtet. Wenn diese Transaktion sich zu Alices quantenunsicherer Ausgabe verpflichtet,
    führen sie ihre Ausgabe aus. Andernfalls tun sie nichts.

    Dies stellt sicher, dass Alice keine quantenanfälligen Informationen offenlegen muss, bis sie bereits
    sichergestellt hat, dass ihre Version der Ausgabetransaktion Vorrang vor jedem Versuch hat, von einem
    Quantencomputer-Betreiber ausgegeben zu werden. Für eine genauere Beschreibung des Protokolls siehe
    [Ruffings Beitrag von 2018][ruffing gfsig]. Obwohl im Thread nicht diskutiert, glauben wir, dass das
    oben beschriebene Protokoll als Soft Fork bereitgestellt werden könnte.

    Habovštiak argumentiert, dass Bitcoins, die sicher mit diesem Protokoll ausgegeben werden können
    (z. B. deren Preimage noch nicht offengelegt wurde), nicht vernichtet werden sollten, selbst wenn die
    Community beschließt, dass sie quantenanfällige Bitcoins im Allgemeinen vernichten möchte. Er
    argumentiert auch, dass die Fähigkeit, einige Bitcoins im Notfall sicher auszugeben, die Dringlichkeit
    der Einführung eines quantensicheren Schemas kurzfristig verringert.

    Lloyd Fournier [sagt][fournier gfsig], "wenn dieser Ansatz Akzeptanz findet, denke ich, dass die
    Hauptmaßnahme, die Benutzer ergreifen können, darin besteht, zu einer Taproot-Wallet zu wechseln",
    da diese die Möglichkeit bietet, Keypath-Ausgaben unter den aktuellen Konsensregeln zu ermöglichen,
    einschließlich im Fall von [Output linking][topic output linking], aber auch Widerstand gegen
    Quanten-Diebstahl, wenn Keypath-Ausgaben später deaktiviert werden.

    In einem separaten Thread (siehe nächster Punkt) stellt Pieter Wuille [fest][wuille nonpublic],
    dass UTXOs, die für Quanten-Diebstahl anfällig sind, auch Schlüssel umfassen, die nicht öffentlich
    verwendet wurden, aber mehreren Parteien bekannt sind, wie in verschiedenen Formen von Multisig
    (einschließlich LN, [DLCs][topic dlc] und Treuhanddiensten).

  - *Entwurf eines BIP zur Vernichtung quantenunsicherer Bitcoins:*
    Agustin Cruz [veröffentlicht][cruz qramp] in der Bitcoin-Dev-Mailingliste ein [Entwurf-BIP][cruz bip],
    das mehrere Optionen für einen allgemeinen Prozess zur Vernichtung von Bitcoins beschreibt, die für
    Quanten-Diebstahl anfällig sind (falls dies zu einem erwarteten Risiko wird). Cruz argumentiert,
    "indem wir eine Frist für die Migration durchsetzen, bieten wir rechtmäßigen Eigentümern eine klare,
    nicht verhandelbare Gelegenheit, ihre Gelder zu sichern [...] eine erzwungene Migration mit
    ausreichender Vorankündigung und robusten Schutzmaßnahmen ist sowohl realistisch als auch notwendig,
    um die langfristige Sicherheit von Bitcoin zu schützen."

    Sehr wenig der Diskussion im Thread konzentrierte sich auf das Entwurf-BIP. Die meisten Diskussionen
    drehten sich darum, ob die Vernichtung quantenanfälliger Bitcoins eine gute Idee ist, ähnlich
    wie der Thread, der später von Jameson Lopp gestartet wurde (wie im vorherigen Unterpunkt beschrieben).

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
[news347 bip119]: /en/newsletters/2025/03/28/#bips-1792
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