# Optech Style Guide für deutsche Übersetzungen

## Grundsätzliches

Die deutsche Übersetzung von Optech Inhalten sollte wo immer möglich den Regeln
des englischen [Hauptleitfaden](STYLE.md) folgen.

## Vokabular

### Eigennamen

Wie im Hauptleitfaden beschrieben, werden auch in der deutschen Übersetzung
Eigennamen groß geschrieben.

### Gebräuchliche Substantive

Anders als im Englischen, wird, mit Ausnahme der unten aufgelisteten Begriffe,
der erste Buchstabe von gebräuchlichen Substantiven groß geschrieben.

- Bech32
- Bitcoin (die Währung)
- BIPxxx

### Abkürzungen

Siehe [Hauptleitfaden](STYLE.md).

#### Nicht eingeführte Abkürzungen

Siehe [Hauptleitfaden](STYLE.md).

#### Unzulässige Begriffe und Abkürzungen

Siehe [Hauptleitfaden](STYLE.md).

### Zusammengesetzte Begriffe
Zusammengesetzte Fremdwörter sollten, zwecks besserer Lesbarkeit, nach
Möglichkeit mit Bindestrich geschrieben werden. Siehe dazu auch [Duden, D41](https://www.duden.de/sprachwissen/rechtschreibregeln/fremdwoerter#D41)

### Rechtschreibung

Übersetzungen sollten den Regeln der neuen deutschen Rechtschreibung folgen.

### Bevorzugte Begriffe für deutsche Übersetzung

Wo sinnvoll und verständnisfördernd sollten Fachbegriffe nur dann übersetzt,
und Fremd- bzw. Lehnwörter nur dann verwendet werden, wenn sich diese in der
deutschen Bitcoin-Szene etabliert haben. Für einige Begriffe werden folgende
Übersetzungen bevorzugt:

| Englischer Ausdruck               | Bevorzugt                     | Zu vermeiden         | Anmerkungen                               |
|-----------------------------------|-------------------------------|----------------------|-------------------------------------------|
| blinded transaction               | verdeckte Zahlung             |                      |                                           |
| Countersign                       | Countersign                   |                      | Eigenname des Verfahrens                  |
| channel                           | Channel                       | Kanal                |                                           |
| derivation path                   | Ableitungspfad                |                      |                                           |
| descriptor                        | Deskriptor                    |                      |                                           |
| dual funding                      | beidseitige Finanzierung      |                      |                                           |
| fee                               | Gebühr                        |                      |                                           |
| funds                             | Kapital                       |                      |                                           |
| HTLC                              |                               |                      | Genus Maskulinum                          |
| lightning network                 | Lightning Netzwerk            |                      |                                           |
| node                              | Knoten                        | Node                 |                                           |
| relay                             | Weiterleitung                 |                      |                                           |
| output                            | Ausgabe                       | Output               | Im Kontext von UTXO                       |
| silent payment                    | Stille Zahlung                |                      |                                           |
| UTXO                              |                               |                      | Genus Maskulinum                          |
| wallet                            | Wallet                        | Geldbörse            | Genus Neutrum                             |
| work                              | Arbeitsnachweis               | Arbeit               | Im Kontext von PoW                        |
| nothing up my sleeve (NUMS)-Punkt |                               |                      |                                           |
| Scriptpath                        |                               |                      |                                           |
| Tapleaf                           |                               |                      |                                           |
| Tapscript                         |                               |                      |                                           |
| Orakel-Bestätigung                |                               |                      |                                           |
| Timelock                          |                               |                      |                                           |

### Nicht übersetzte Begriffe

#### Mining und Pool-Begriffe

| Englischer Ausdruck           | Begründung                                                                                                                                        |
|-------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------|
| Pool-Miner                    | ist ein etablierter Fachbegriff                                                                                                                   |
| Mining                        | etablierter Fachbegriff                                                                                                                           |
| Pool                          | etablierter Fachbegriff                                                                                                                           |
| E-Cash-Shares                 | wurde von "E-Cash-Anteile" korrigiert                                                                                                             |
| Pay-per-Last-N-Shares         | technischer Begriff                                                                                                                               |
| PPLNS                         | "Pay-Per-Last-N-Shares", ein Auszahlungssystem bei Mining-Pools, bei dem die letzten N Shares für die Berechnung der Auszahlung verwendet werden  |
| TIDES                         | Name des Systems                                                                                                                                  |
| FPPS                          | "Full Pay-Per-Share", ein Auszahlungssystem, das die volle Blockbelohnung (inkl. Gebühren) pro Share auszahlt                                     |
| Proxy                         | technischer Begriff                                                                                                                               |

#### Lightning Network & DLC Begriffe

| Englischer Ausdruck           | Begründung                                                                                                                                        |
|-------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------|
| LN                            | "Lightning Network", ein Layer-2-Protokoll für schnelle Bitcoin-Transaktionen                                                                     |
| DLC                           | "Discreet Log Contract", ein Protokoll für Bitcoin-basierte Smart Contracts                                                                       |
| Offchain                      | beschreibt Transaktionen außerhalb der Blockchain                                                                                                 |
| On-Chain                      | beschreibt Transaktionen auf der Blockchain                                                                                                       |
| HTLC                          | "Hash Time-Locked Contract", ein Vertragskonstrukt für sichere Zahlungsweiterleitung im Lightning Network                                         |
| Oracle                        | technischer Begriff                                                                                                                               |
| Simple Taproot Channels       | Lightning Network Typ                                                                                                                             |

#### Software & Entwicklung

| Englischer Ausdruck           | Begründung                                                                                                                                        |
|-------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------|
| Release                       | etablierter Begriff                                                                                                                               |
| Release-Kandidaten            | teilweise etablierter Begriff                                                                                                                     |
| LDK                           | "Lightning Development Kit", eine Bibliothek zur Entwicklung von Lightning-Network-Anwendungen                                                    |
| Wallet                        | etablierter Begriff                                                                                                                               |
| LSPS                          | "Lightning Service Provider Specification", ein Standard für Lightning Network Dienstleister                                                      |
| Human Readable Names          | technischer Begriff                                                                                                                               |
| Core Lightning                | Produktname                                                                                                                                       |
| Eclair                        | Produktname                                                                                                                                       |
| BTCPay Server                 | Produktname                                                                                                                                       |
| BDK                           | Produktname                                                                                                                                       |
| Rust Bitcoin                  | Produktname                                                                                                                                       |
| PR                            | "Pull Request", eine Funktion von Git/GitHub, bei der ein Entwickler eine Änderung an einem Repository vorschlägt                                 |

#### Protokolle & Standards

| Englischer Ausdruck           | Begründung                                                                                                                                        |
|-------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------|
| BIP                           | "Bitcoin Improvement Proposal", standardisierte Vorschläge zur Verbesserung des Bitcoin-Protokolls                                                |
| BOLT                          | "Basis of Lightning Technology", die technischen Spezifikationen des Lightning Networks                                                           |
| BLIP                          | "Bitcoin Lightning Improvement Proposal", Verbesserungsvorschläge für das Lightning Network                                                       |
| PSBT                          | "Partially Signed Bitcoin Transaction", ein Format für teilweise signierte Bitcoin-Transaktionen                                                  |
| DLEQ                          | "Discrete Logarithm Equality", ein kryptographischer Beweis für die Gleichheit diskreter Logarithmen                                              |
| Splice                        | technischer Begriff                                                                                                                               |
| Short Channel Identifier(SCID)| technischer Begriff                                                                                                                               |
| BIP331                        | Abkürzung für ein spezifisches Bitcoin Improvement Proposal                                                                                       |
| OP_CHECKTEMPLATEVERIFY (CTV)  | spezifischer Opcode im Bitcoin-Protokoll                                                                                                          |
| CTV                           | "Check Template Verify", siehe oben OP_CHECKTEMPLATEVERIFY                                                                                        |

#### Plattformen & Listen

| Englischer Ausdruck           | Begründung                                                                                                                                        |
|-------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------|
| Delving Bitcoin               | Name der Plattform                                                                                                                                |
| DLC-Dev                       | Name der Mailingliste                                                                                                                             |

#### Entwicklungsbegriffe

| Englischer Ausdruck           | Begründung                                                                                                                                        |
|-------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------|
| merged                        | Git/GitHub Terminologie                                                                                                                           |

### Maßeinheiten

Siehe [Hauptleitfaden](STYLE.md).