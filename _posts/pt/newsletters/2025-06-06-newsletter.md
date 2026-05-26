---
title: 'Newsletter Bitcoin Optech #357'
permalink: /pt/newsletters/2025/06/06/
name: 2025-06-06-newsletter-pt
slug: 2025-06-06-newsletter-pt
type: newsletter
layout: newsletter
lang: pt
---

A newsletter desta semana compartilha uma análise sobre sincronização de full-nodes
sem witness antigas. Também incluídas estão nossas seções regulares com
descrições de discussões sobre mudanças de consenso, anúncios de
novos lançamentos e candidatos a lançamento, e resumos de mudanças notáveis em
software popular de infraestrutura do Bitcoin.

## Notícias

- **Sincronizando nós completos sem dados de testemunha (witness):** Jose SK [postou][sk nowit]
  no Delving Bitcoin um resumo de uma [análise][sk nowit gist] que ele
  fez sobre os tradeoffs de segurança de permitir que nós completos recém-iniciados
  com uma configuração em particular evitem baixar alguns
  dados da blockchain. Por padrão, nós Bitcoin Core usam a
  configuração `assumevalid` que pula a validação de scripts
  em blocos criados mais de um mês ou dois antes do lançamento da
  versão do Bitcoin Core sendo executada. Embora desabilitado por padrão, muitos
  usuários do Bitcoin Core também definem uma configuração `prune` que
  exclui blocos algum tempo após validá-los (por quanto tempo os blocos são
  mantidos depende do tamanho dos blocos e da configuração específica selecionada
  pelo usuário).

  SK argumenta que dados de testemunha (witness), que são usados apenas para validar
  scripts, não deveriam ser baixados por nós prunados para blocos `assumevalid`
  porque eles não os usarão para validar scripts e eventualmente serão excluídos.
  Pular o download de testemunhas "pode reduzir o uso de banda em mais de 40%", ele escreve.

  Ruben Somsen [argumenta][somsen nowit] que isso muda o modelo de segurança
  até certo ponto. Embora scripts não sejam validados, os
  dados baixados são validados contra o commitment da raiz merkle do cabeçalho do bloco
  para a transação coinbase para os dados da testemunha.
  Isso garante que os dados estavam disponíveis e não corrompidos no momento em que o
  nó foi inicialmente sincronizado. Se ninguém rotineiramente valida a
  existência dos dados, eles poderiam eventualmente ser perdidos, como [aconteceu][ripple loss]
  com pelo menos uma altcoin.

  A discussão estava em andamento no momento da escrita.

## Mudando consenso

_Uma seção mensal resumindo propostas e discussões sobre mudanças
nas regras de consenso do Bitcoin._

- **Relatório de computação quântica:** Clara Shikhelman [postou][shikhelman
  quantum] no Delving Bitcoin o resumo de um [relatório][sm report] que ela
  co-autorou com Anthony Milton sobre os riscos para usuários Bitcoin de
  computadores quânticos rápidos, uma visão geral de várias vias para [resistência
  quântica][topic quantum resistance], e uma análise de _tradeoffs_
  envolvidos na atualização do protocolo do Bitcoin. Os autores encontraram 4 a 10
  milhões de BTC potencialmente vulneráveis a roubo quântico, alguma
  mitigação é agora possível, e é improvável que a mineração do Bitcoin seja
  ameaçada pela computação quântica no curto ou médio prazo, e
  atualizar requer acordo generalizado.

- **Limite de peso de transação com exceção para prevenir confisco:**
  Vojtěch Strnad [postou][strnad limit] no Delving Bitcoin a proposta de uma
  ideia de mudança de consenso para limitar o peso máximo da maioria
  das transações em um bloco. A regra simples apenas permitiria uma transação
  maior que 400.000 unidades de peso (100.000 vbytes) em um bloco se fosse
  a única transação naquele bloco além da transação coinbase.
  Strnad e outros descreveram a motivação para limitar o peso máximo
  da transação:

  - _Otimização de template de bloco mais fácil:_ é mais fácil encontrar uma
    solução quase ótima para o [problema da mochila][] quanto menores forem os
    itens comparados ao limite geral. Isso é parcialmente
    devido à minimização da quantidade de espaço sobrado no final, com
    itens menores deixando menos espaço não utilizado.

  - _Política de retransmissão mais fácil:_ a política para retransmitir transações não confirmadas
    entre nós prevê quais transações serão
    mineradas para evitar desperdiçar largura de banda. Transações gigantes tornam
    previsões precisas mais difíceis, pois mesmo uma pequena mudança na taxa de topo pode causar
    que sejam atrasadas ou removidas.

  - _Evitando centralização de mineração:_ garantir que nós completos de retransmissão sejam
    capazes de lidar com quase todas as transações impede que usuários de transações especiais
    precisem pagar [taxas fora de banda][topic
    out-of-band fees], o que pode levar à centralização de mineração.

  Gregory Sanders [notou][sanders limit] que poderia ser razoável
  simplesmente fazer um soft fork de limite de peso máximo sem exceções baseado
  na política de retransmissão consistente de 12 anos do Bitcoin Core. Gregory
  Maxwell [adicionou][maxwell limit] que transações gastando apenas UTXOs
  criados antes do soft fork poderiam ter uma exceção permitida para prevenir
  confisco, e que um [soft fork transitório][topic transitory soft
  forks] permitiria que a restrição expirasse se a
  comunidade decidisse não renová-la.

  Uma discussão adicional examinou as necessidades de partes querendo
  transações grandes, principalmente usuários [BitVM][topic acc] no curto prazo,
  e se abordagens alternativas estavam disponíveis para eles.

- **Removendo saídas do conjunto UTXO baseado em valor e tempo:** Robin
  Linus [postou][linus dust] no Delving Bitcoin para propor um soft fork
  para remover saídas de baixo valor do conjunto UTXO após algum
  tempo. Várias variações da ideia foram discutidas, sendo as duas
  principais alternativas:

  - _Destruir fundos antigos não econômicos:_ saídas de pequeno valor que não
    foram gastas por muito tempo se tornariam ingastáveis.

  - _Requerer que fundos antigos não econômicos sejam gastos com prova de existência:_
    [utreexo][topic utreexo] ou um sistema similar poderia ser usado para permitir
    que uma transação prove que as saídas que ela gasta são parte do
    UTXO set. Saídas antigas e [não econômicas][topic uneconomical outputs] precisariam
    incluir esta prova, mas saídas mais novas e de maior valor ainda seriam
    armazenadas no conjunto UTXO.

  Qualquer solução efetivamente limitaria o tamanho máximo do conjunto UTXO
  (assumindo um valor mínimo e o limite de 21 milhões de bitcoins).
  Vários aspectos técnicos interessantes de um design foram discutidos,
  incluindo alternativas às provas Utreexo para esta aplicação que
  poderiam ser mais práticas.

## Lançamentos e candidatos a lançamento

_Novos lançamentos e candidatos a lançamento para projetos populares de infraestrutura
do Bitcoin. Por favor, considere atualizar para novos lançamentos ou ajudar a testar
candidatos a lançamento._

- [Core Lightning 25.05rc1][] é um candidato a lançamento para a próxima versão principal
  desta implementação popular de nó LN.

- [LND 0.19.1-beta.rc1][] é um candidato a lançamento para uma versão de manutenção
  desta implementação popular de nó LN.

## Mudanças notáveis em código e documentação

_Mudanças recentes notáveis no [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], e [BINANAs][binana repo]._

- [Bitcoin Core #32582][] adiciona novo logging para medir o desempenho da
  [reconstrução de bloco compacto][topic compact block relay] rastreando o
  tamanho total de transações que um nó solicita de seus pares
  (`getblocktxn`), o número e tamanho total de transações que um nó envia
  para seus pares (`blocktxn`), e adicionando um timestamp no início de
  `PartiallyDownloadedBlock::InitData()` para rastrear quanto tempo apenas o passo
  de busca no mempool leva (em modos de alta e baixa largura de banda). Veja Newsletter
  [#315][news315 compact] para um relatório de estatísticas anterior sobre reconstrução
  de bloco compacto.

- [Bitcoin Core #31375][] adiciona uma nova ferramenta CLI `bitcoin -m` que envolve e
  executa os binários [multiprocesso][multiprocess project] `bitcoin node`
  (`bitcoind`), `bitcoin gui` (`bitcoinqt`), `bitcoin rpc` (`bitcoin-cli
  -named`). Atualmente, estes funcionam da mesma forma que os
  binários monolíticos, exceto que suportam a opção `-ipcbind` (veja Newsletter
  [#320][news320 ipc]), mas melhorias futuras permitirão que um operador de nó
  inicie e pare componentes independentemente em diferentes máquinas e
  ambientes. Veja [Newsletter #353][news353 pr review] para um Bitcoin Core PR
  Review Club cobrindo este PR.

- [BIPs #1483][] incorpora [BIP77][] que propõe [payjoin v2][topic payjoin], uma
  variante assíncrona sem servidor na qual o remetente e receptor entregam seus
  PSBTs criptografados para um servidor de diretório payjoin que apenas armazena e encaminha
  mensagens. Como o diretório não pode ler ou alterar as cargas úteis, nenhuma carteira
  precisa hospedar um servidor público ou estar online ao mesmo tempo. Veja Newsletter
  [#264][news264 payjoin] para contexto adicional sobre payjoin v2.

{% include snippets/recap-ad.md when="2025-06-10 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="32582,31375,1483" %}
[Core Lightning 25.05rc1]: https://github.com/ElementsProject/lightning/releases/tag/v25.05rc1
[ripple loss]: https://x.com/JoelKatz/status/1919233214750892305
[sk nowit]: https://delvingbitcoin.org/t/witnessless-sync-for-pruned-nodes/1742/
[sk nowit gist]: https://gist.github.com/JoseSK999/df0a2a014c7d9b626df1e2b19ccc7fb1
[somsen nowit]: https://gist.github.com/JoseSK999/df0a2a014c7d9b626df1e2b19ccc7fb1?permalink_comment_id=5597316#gistcomment-5597316
[shikhelman quantum]: https://delvingbitcoin.org/t/bitcoin-and-quantum-computing/1730/
[sm report]: https://chaincode.com/bitcoin-post-quantum.pdf
[strnad limit]: https://delvingbitcoin.org/t/non-confiscatory-transaction-weight-limit/1732/
[problema da mochila]: https://en.wikipedia.org/wiki/Knapsack_problem
[sanders limit]: https://delvingbitcoin.org/t/non-confiscatory-transaction-weight-limit/1732/2
[maxwell limit]: https://delvingbitcoin.org/t/non-confiscatory-transaction-weight-limit/1732/4
[linus dust]: https://delvingbitcoin.org/t/dust-expiry-clean-the-utxo-set-from-spam/1707/
[lnd 0.19.1-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.19.1-beta.rc1
[news315 compact]: /en/newsletters/2024/08/09/#statistics-on-compact-block-reconstruction
[multiprocess project]: https://github.com/ryanofsky/bitcoin/blob/pr/ipc/doc/design/multiprocess.md
[news320 ipc]: /en/newsletters/2024/09/13/#bitcoin-core-30509
[news264 payjoin]: /en/newsletters/2023/08/16/#serverless-payjoin
[news353 pr review]: /en/newsletters/2025/05/09/#bitcoin-core-pr-review-club