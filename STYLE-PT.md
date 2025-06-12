# Optech Style Guide para Traduções em português

## Básico

A tradução para português de conteúdos do Optech devem seguir as regres o [Guia principal](STYLE.md) sempre que possivel.

## Títulos de seção (traduções padrão)

| Englisch                                 | Deutsch                                                      |
|------------------------------------------|--------------------------------------------------------------|
| News                                     | Notícias                                                     |
| Changes to services and client software  | Alterações nos serviços e software do cliente                |
| Releases and release candidates          |                                                              |
| Notable code and documentation changes   | Alterações importantes de código e documentação              |
| Selected Q&A from Bitcoin Stack Exchange | Perguntas e respostas selecionadas do Bitcoin Stack Exchange |
| Correction                               | correção                                                     |
| Consensus changes                        | Mudanças de consenso                                         |

## Vocabulário

### Eigennamen

Conforme descrito no guia principal, a tradução em alemão também Nomes apropriados capitalizados.


### Abreviações

Ver [Guia principal](STYLE.md).

#### Abreviações não intruduzidas

Ver [Guia principal](STYLE.md).

#### Termos e abreviaturas inadmissíveis

Ver [Guia principal](STYLE.md).

### Ortografia

As traduções devem seguir as regras da nova ortografia da lingua portuguesa.

### Termos preferidos para tradução para a lingua portuguesa

Quando apropriado e propício à compreensão, os termos técnicos devem ser traduzidos, exceto quando sua utização
estiver estabelecida no cenario bitcoin lusofonico. Para alguns termos, segue a tradução preferencial:

| Expressão em inglês               | Preferido                     | Evitar        | Notas                               |
|-----------------------------------|-------------------------------|----------------------|-------------------------------------------|
| blinded transaction               |                               |                      |                                           |
| Countersign                       |                               |                      |                                           |
| channel                           | channel                       | canal                |                                           |
| derivation path                   |                               |                      |                                           |
| descriptor                        |                               |                      |                                           |
| dual funding                      |                               |                      |                                           |
| fee                               | taxa                          |                      |                                           |
| funds                             | fundos                        |                      |                                           |
| HTLC                              |                               |                      |                                           |
| lightning network                 | rede lightning                |                      |                                           |
| node                              | nó                            |                      |                                           |
| relay                             | relay                         |                      |                                           |
| input/output                      | entrada/saida                 |                      |                                           |
| silent payment                    |                               |                      |                                           |
| UTXO                              | UTXO                          |                      |                                           |
| wallet                            | carteira                      | carteira             |                                           |
| work                              | trabalho                      |                      |                                           |
| Scriptpath                        |                               |                      |                                           |
| Tapleaf                           |                               |                      |                                           |
| Tapscript                         |                               |                      |                                           |
| Timelock                          |                               |                      |                                           |
| non-custodial                     | não custodial                 | não custodial        |                                           |

### Termos não traduzidos

#### Termos de mineração

| Expressão em inglês           | Justificativa                                                                                                                                     |
|-------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------|
| Pool-Miner                    | termo técnico estabelecido                                                                                                                        |
| Mining                        | termo técnico estabelecido                                                                                                                        |
| Pool                          | termo técnico estabelecido                                                                                                                        |
| E-Cash-Shares                 |                                                                                                                                                   |
| Pay-per-Last-N-Shares         | termo técnic                                                                                                                                      |
| PPLNS                         | "Pay-Per-Last-N-Shares", um sistema de pagamento para pools de mineração, no qual as últimas ações N são usadas para calcular o pagamento         |
| TIDES                         | Name des Systems                                                                                                                                  |
| FPPS                          | "Full Pay-Per-Share", um sistema de pagamento que paga a recompensa do bloco completo (incluindo taxas) por ação                                  |
| Proxy                         | termo técnic                                                                                                                                      |

#### Lightning Network & DLC Begriffe

| Expressão em inglês           | Justificativa                                                                                                                                     |
|-------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------|
| LN                            | "Lightning Network", um protocolo de camada 2 para transações rápidas de Bitcoin                                                                  |
| DLC                           | "Discreet Log Contract", um protocolo para Contratos Inteligentes baseados em Bitcoin                                                             |
| Offchain                      | descreve transações fora da blockchain                                                                                                            |
| On-Chain                      | descreve transações no blockchain                                                                                                                 |
| HTLC                          | "Hash Time-Locked Contract", uma construção de contrato para encaminhamento de pagamento seguro na Lightning Network                              |
| Oracle                        | termo técnico estabelecido                                                                                                                        |
| Simple Taproot Channels       | Tipo de g Network                                                                                                                                 |

#### Software e desenvolvimento

| Expressão em inglês           | Justificativa                                                                                                                                     |
|-------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------|
| Release                       | termo estabelecido                                                                                                                                |
| Release candidate             |                                                                                                                                                   |
| LDK                           | "Lightning Development Kit", eine Bibliothek zur Entwicklung von Lightning-Network-Anwendungen                                                    |
| Wallet                        | etablierter Begriff                                                                                                                               |
| LSPS                          | "Lightning Service Provider Specification", , um padrão para provedores de serviços da Lightning Network                                          |
| Human Readable Names          | termo estabelecido                                                                                                                                |
| Core Lightning                | Nome do produto                                                                                                                                   |
| Eclair                        | Nome do produto                                                                                                                                   |
| BTCPay Server                 | Nome do produto                                                                                                                                   |
| BDK                           | Nome do produto                                                                                                                                   |
| Rust Bitcoin                  | Nome do produto                                                                                                                                   |
| PR                            | "Pull Request", uma função do Git / GitHub, na qual um desenvolvedor sugere uma mudança para um repositório                                       |

#### Protocolos e normas

| Expressão em inglês           | Justificativa                                                                                                                                     |
|-------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------|
| BIP                           | "Bitcoin Improvement Proposal", sugestões padronizadas para melhorar o protocolo Bitcoin                                                          |
| BOLT                          | "Basis of Lightning Technology", as especificações técnicas da Lightning Network                                                                  |
| BLIP                          | "Bitcoin Lightning Improvement Proposal"", sugestões de melhoria para a Lightning Network                                                         |
| PSBT                          | "Partially Signed Bitcoin Transaction", um formato para transações Bitcoin parcialmente assinadas                                                 |
| DLEQ                          | "Discrete Logarithm Equality", uma prova criptográfica da igualdade de logaritmos discretos                                                       |
| Splice                        | termo técnico                                                                                                                                     |
| Short Channel Identifier(SCID)| termo técnico                                                                                                                                     |
| PIB331                        | Abreviação de uma Proposta de Melhoria de Bitcoin específica                                                                                      |
| OP_CHECKTEMPLATEVERIFY (CTV)  | opcode específico no protocolo Bitcoin                                                                                                            |
| CTV                           | "Check Template Verify", consulte OP_CHECKTEMPLATEVERIFY acima                                                                                    |

#### Plataformas e listas

| Expressão em inglês           | Justificativa                                                                                                                                     |
|-------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------|
| Delving Bitcoin               | Nome da plataforma                                                                                                                                |
| DLC-Dev                       | Nome da lista de discussão                                                                                                                        |

#### Entwicklungsbegriffe

| Expressão em inglês           | Justificativa                                                                                                                                     |
|-------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------|
| merged                        | Terminologia do Git/GitHub                                                                                                                        |

### Unidades de medida

Ver [Guia principal](STYLE.md).