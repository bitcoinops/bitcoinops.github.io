---
title: 'Bitcoin Optech Newsletter #359'
permalink: /de/newsletters/2025/06/20/
name: 2025-06-20-newsletter-de
slug: 2025-06-20-newsletter-de
type: newsletter
layout: newsletter
lang: de
---
Der Newsletter dieser Woche beschreibt einen Vorschlag, die öffentliche
Teilnahme an den Bitcoin-Core-Repositories zu beschränken, kündigt eine
signifikante Verbesserung bei BitVM-artigen Verträgen an und fasst die
Forschung zum Rebalancing von LN-Channels zusammen. Ebenfalls enthalten
sind unsere regulären Abschnitte mit Zusammenfassungen der jüngsten
Änderungen an Clients und Diensten, Ankündigungen neuer Releases und
Release-Kandidaten sowie Beschreibungen der jüngsten Änderungen an
populärer Bitcoin-Infrastruktursoftware.

## Nachrichten

- **Vorschlag zur Beschränkung des Zugangs zur Diskussion im Bitcoin-Core-Projekt:**
  Bryan Bishop [postete][bishop priv] in der Bitcoin-Dev-Mailingliste den
  Vorschlag, dass das Bitcoin-Core-Projekt die Möglichkeit der Öffentlichkeit
  zur Teilnahme an Projekt-Diskussionen einschränken sollte, um die durch
  Nicht-Beitragende verursachten Störungen zu reduzieren. Er nannte dies die
  „Privatisierung von Bitcoin Core“, verweist auf Beispiele, bei denen diese
  Privatisierung bereits ad hoc in privaten Büros mit mehreren
  Bitcoin-Core-Mitwirkenden stattfindet, und warnt davor, dass eine
  persönliche Privatisierung entfernte Mitwirkende ausschließt.

  Bishops Beitrag schlägt eine Methode zur Online-Privatisierung vor, aber
  Antoine Poinsot [stellte in Frage][poinsot priv], ob diese Methode das Ziel
  erreichen würde. Poinsot schlug auch vor, dass viele private Bürodiskussionen
  nicht aus Angst vor öffentlicher Kritik stattfinden könnten, sondern wegen
  der „natürlichen Vorteile von persönlichen Diskussionen“.

  Mehrere Antworten deuteten darauf hin, dass größere Änderungen derzeit
  wahrscheinlich nicht gerechtfertigt sind, aber eine stärkere Moderation von
  Kommentaren im Repository die bedeutendste Art von Störung lindern könnte.
  Andere Antworten wiesen jedoch auf mehrere Herausforderungen bei einer
  stärkeren Moderation hin.

  Poinsot, Sebastian „The Charlatan“ Kung und Russell Yanofsky – die einzigen
  sehr aktiven Bitcoin-Core-Mitwirkenden, die zum Zeitpunkt des Schreibens auf
  den Thread geantwortet haben – [gaben entweder an][kung priv],
  [dass][yanofsky priv] sie keine größere Änderung für notwendig halten oder
  dass alle Änderungen schrittweise im Laufe der Zeit vorgenommen werden
  sollten.

- **Verbesserungen bei BitVM-artigen Verträgen:**
  Robin Linus [postete][linus bitvm3] auf Delving Bitcoin, um eine signifikante
  Reduzierung des On-Chain-Speicherplatzes anzukündigen, der für
  [BitVM][topic acc]-artige Verträge benötigt wird. Basierend auf einer
  [Idee][rubin garbled] von Jeremy Rubin, die auf neuen kryptografischen
  Grundbausteinen aufbaut, reduziert der neue Ansatz „die On-Chain-Kosten eines
  Streitfalls um mehr als das 1.000-fache im Vergleich zum vorherigen Design“,
  wobei Widerlegungstransaktionen „nur 200 Bytes“ groß sind.

  Allerdings weist Linus' Paper auf den Kompromiss dieses Ansatzes hin: Er
  „erfordert ein Multi-Terabyte-Off-Chain-Daten-Setup“. Das Paper gibt ein
  Beispiel für eine SNARK-Verifizierer-Schaltung mit etwa 5 Milliarden Gattern
  und vernünftigen Sicherheitsparametern, die ein 5 TB Off-Chain-Setup, eine
  56 kB On-Chain-Transaktion zur Bestätigung des Ergebnisses und eine minimale
  On-Chain-Transaktion (~200 B) erfordert, falls eine Partei beweisen muss,
  dass die Bestätigung ungültig war.

- **Forschung zum Channel-Rebalancing:**
  Rene Pickhardt [postete][pickhardt rebalance] auf Delving Bitcoin Gedanken
  zum Rebalancing von Channels, um die Rate erfolgreicher Zahlungen im
  gesamten Netzwerk zu maximieren. Seine Ideen können mit Ansätzen verglichen
  werden, die kleinere Gruppen von Channels betrachten, wie z.B. das
  [Friend-of-a-Friend-Rebalancing][topic jit routing] (siehe
  [Newsletter #54][news54 foaf rebalance]).

  Pickhardt stellt fest, dass es bei einem globalen Ansatz mehrere
  Herausforderungen gibt, und bittet Interessierte, einige Fragen zu
  beantworten, z.B. ob dieser Ansatz verfolgenswert ist und wie bestimmte
  Implementierungsdetails angegangen werden können.

## Änderungen an Diensten und Client-Software

*In diesem monatlichen Abschnitt heben wir interessante Updates für
Bitcoin-Wallets und -Dienste hervor.*

- **Cove v1.0.0 veröffentlicht:**
  Die jüngsten Cove-[Releases][cove github] beinhalten
  Coin-Control-Unterstützung und zusätzliche
  [BIP329][]-Wallet-Label-Funktionen.

- **Liana v11.0 veröffentlicht:**
  Die jüngsten [Releases][liana github] von Liana beinhalten Funktionen für
  mehrere Wallets, zusätzliche Coin-Control-Funktionen und mehr Unterstützung
  für Hardware-Signiergeräte, neben anderen Funktionen.

- **Stratum v2 STARK-Proof-Demo:**
  StarkWare [demonstrierte][starkware tweet] einen [modifizierten Stratum v2
  Mining-Client][starkware sv2], der einen STARK-Proof verwendet, um zu
  beweisen, dass die Gebühren eines Blocks zu einem gültigen Block-Template
  gehören, ohne die Transaktionen im Block preiszugeben.

- **Breez SDK fügt BOLT12 und BIP353 hinzu:**
  Breez SDK Nodeless [0.9.0][breez github] fügt Unterstützung für den Empfang
  mit [BOLT12][] und [BIP353] hinzu.

## Releases und Release-Kandidaten

*Neue Releases und Release-Kandidaten für populäre
Bitcoin-Infrastrukturprojekte. Bitte erwägen Sie, auf neue Releases zu
aktualisieren oder beim Testen von Release-Kandidaten zu helfen.*

- [Core Lightning 25.05][] ist ein Release der nächsten Hauptversion dieser
  populären LN-Knoten-Implementierung. Es reduziert die Latenz bei der
  Weiterleitung und Auflösung von Zahlungen, verbessert das Gebührenmanagement,
  bietet mit Eclair kompatible [Splicing][topic splicing]-Unterstützung und
  aktiviert standardmäßig [Peer Storage][topic peer storage]. Hinweis: Die
  [Release-Dokumentation][core lightning 25.05] enthält eine Warnung für
  Benutzer der Konfigurationsoption `--experimental-splicing`.

## Wichtige Code- und Dokumentationsänderungen

*Bemerkenswerte aktuelle Änderungen in [Bitcoin Core][bitcoin core repo],
[Core Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay Server][btcpay server repo],
[BDK][bdk repo], [Bitcoin Improvement Proposals (BIPs)][bips repo],
[Lightning BOLTs][bolts repo], [Lightning BLIPs][blips repo], [Bitcoin
Inquisition][bitcoin inquisition repo] und [BINANAs][binana repo].*

- [Eclair #3110][] erhöht die Verzögerung für das Markieren eines Channels als
  geschlossen, nachdem sein Finanzierungs-Output ausgegeben wurde, von 12
  (siehe Newsletter [#337][news337 delay]) auf 72 Blöcke, wie in [BOLTs
  #1270][] spezifiziert, um die Verbreitung eines [Splicing][topic
  splicing]-Updates zu ermöglichen. Sie wurde erhöht, weil einige
  Implementierungen standardmäßig 8 Bestätigungen abwarten, bevor sie
  `splice_locked` senden, und es Knoten-Betreibern erlauben, diesen
  Schwellenwert zu erhöhen, sodass sich 12 Blöcke als zu kurz erwiesen. Die
  Verzögerung ist jetzt zu Testzwecken konfigurierbar und ermöglicht es
  Knoten-Betreibern, länger zu warten.

- [Eclair #3101][] führt den `parseoffer`-RPC ein, der [BOLT12-Offer][topic
  offers]-Felder in ein menschenlesbares Format dekodiert, sodass Benutzer den
  Betrag anzeigen können, bevor sie ihn an den `payoffer`-RPC übergeben.
  Letzterer wird erweitert, um einen in einer Fiat-Währung angegebenen Betrag
  zu akzeptieren.

- [LDK #3817][] rollt die Unterstützung für [attributable failures(zurechenbare Fehler)][topic
  attributable failures] (siehe Newsletter [#349][news349 attributable])
  zurück, indem sie unter ein reines Test-Flag gestellt wird. Dies deaktiviert
  die Peer-Bestrafungslogik und entfernt das Feature-TLV aus den
  Fehler [onion-messages][topic onion messages]. Knoten, die noch nicht
  aktualisiert hatten, wurden fälschlicherweise bestraft, was zeigt, dass eine
  breitere Netzwerkakzeptanz erforderlich ist, damit es ordnungsgemäß
  funktioniert.

- [LDK #3623][] erweitert [Peer Storage][topic peer storage] (siehe Newsletter
  [#342][news342 peer]), um automatische, verschlüsselte Peer-Backups
  bereitzustellen. Für jeden Block verpackt `ChainMonitor` die Daten aus einer
  versionierten, mit Zeitstempel versehenen und serialisierten
  `ChannelMonitor`-Struktur in ein `OurPeerStorage`-Blob. Dann verschlüsselt
  es die Daten und löst ein `SendPeerStorage`-Ereignis aus, um das Blob als
  `peer_storage`-Nachricht an jeden Channel-Peer weiterzuleiten. Zusätzlich
  wird `ChannelManager` aktualisiert, um `peer_storage_retrieval`-Anfragen zu
  bearbeiten, indem ein neuer Blob-Versand ausgelöst wird.

- [BTCPay Server #6755][] verbessert die Coin-Control-Benutzeroberfläche mit
  neuen Filtern für Mindest- und Höchstbeträge, Filtern für Erstellungsdatum
  vor und nach, einem Hilfebereich für die Filter, einem „Alle
  auswählen“-Kontrollkästchen für UTXOs und Optionen für große Seitengrößen
  (100, 200 oder 500 UTXOs).

- [Rust libsecp256k1 #798][] vervollständigt die [MuSig2][topic
  musig]-Implementierung in der Bibliothek und gibt nachgelagerten Projekten
  Zugang zu einem robusten [skriptlosen Multisignatur][topic
  multisignature]-Protokoll.

{% include snippets/recap-ad.md when="2025-06-24 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="3110,3101,3817,3623,6755,1270" %}
[Core Lightning 25.05]: https://github.com/ElementsProject/lightning/releases/tag/v25.05
[bishop priv]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CABaSBax-meEsC2013zKYJnC3phFFB_W3cHQLroUJcPDZKsjB8w@mail.gmail.com/
[poinsot priv]: https://mailing-list.bitcoindevs.xyz/bitcoindev/4iW61M7NCP-gPHoQZKi8ZrSa2U6oSjziG5JbZt3HKC_Ook_Nwm1PchKguOXZ235xaDlhg35nY8Zn7g1siy3IADHvSHyCcgTHrJorMKcDzZg=@protonmail.com/
[kung priv]: https://mailing-list.bitcoindevs.xyz/bitcoindev/58813483-7351-487e-8f7f-82fb18a4c808n@googlegroups.com/
[linus bitvm3]: https://delvingbitcoin.org/t/garbled-circuits-and-bitvm3/1773
[rubin garbled]: https://rubin.io/bitcoin/2025/04/04/delbrag/
[pickhardt rebalance]: https://delvingbitcoin.org/t/research-update-a-geometric-approach-for-optimal-channel-rebalancing/1768
[rust libsecp256k1 #798]: https://github.com/rust-bitcoin/rust-secp256k1/pull/798
[news54 foaf rebalance]: /en/newsletters/2019/07/10/#brainstorming-just-in-time-routing-and-free-channel-rebalancing
[yanofsky priv]: https://github.com/bitcoin-core/meta/issues/19#issuecomment-2961177626
[cove github]: https://github.com/bitcoinppl/cove/releases
[liana github]: https://github.com/wizardsardine/liana/releases
[breez github]: https://github.com/breez/breez-sdk-liquid/releases/tag/0.9.0
[starkware tweet]: https://x.com/dimahledba/status/1935354385795592491
[starkware sv2]: https://github.com/keep-starknet-strange/stratum
[news337 delay]: /de/newsletters/2025/01/17/#eclair-2936
[news349 attributable]: /de/newsletters/2025/04/11/#ldk-2256
[news342 peer]:/de/newsletters/2025/02/21/#ldk-3575