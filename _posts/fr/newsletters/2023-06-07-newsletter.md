---
title: 'Bulletin Hebdomadaire Bitcoin Optech #254'
permalink: /fr/newsletters/2023/06/07/
name: 2023-06-07-newsletter-fr
slug: 2023-06-07-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
La bulletin de cette semaine résume les discussions de la liste de diffusion sur l'utilisation de la proposition MATT pour gérer
les joinpools et répliquer les fonctions de la proposition `OP_CHECKTEMPLATEVERIFY`. Vous y trouverez également une autre
contribution à notre série hebdomadaire limitée sur la politique mempool, ainsi que nos sections régulières pour annoncer les
nouvelles versions de logiciels et les versions candidates, et pour décrire les changements notables apportés aux principaux
logiciels de l'infrastructure Bitcoin.

## Nouvelles

- **Utilisation de MATT pour répliquer CTV et gérer les joinpools :** Johan Torås Halseth a [posté][halseth matt-ctv]
sur la liste de diffusion Bitcoin-Dev à propos de l'utilisation de l'opcode `OP_CHECKOUTPUTCONTRACTVERIFY` (COCV) de la
proposition Merklize All The Things (MATT) (voir les lettres d'information [#226][news226 matt] et [#249][news249 matt])
pour répliquer la fonctionnalité de la proposition [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify]. Pour engager une
transaction avec plusieurs sorties, chaque sortie nécessiterait l'utilisation d'un opcode COCV différent. En comparaison,
un seul opcode CTV pourrait valider toutes les sorties. COCV est donc moins efficace, mais, comme il le fait remarquer,
"suffisamment simple pour être intéressant".

    Au-delà de la simple description de la fonctionnalité, Halseth fournit également une [démo][halseth demo] de l'opération
    à l'aide de [Tapsim][], un outil de "débogage des transactions Bitcoin Tapscript [...] destiné aux développeurs souhaitant
    jouer avec les primitives de script Bitcoin, faciliter le débogage des scripts et visualiser l'état de la VM lors de
    l'exécution des scripts".

    Dans un autre fil de discussion, Halseth a [posté][halseth matt-joinpool] sur l'utilisation de MATT plus [OP_CAT][]
    pour créer un [joinpool][topic joinpools] (également appelé _coinpool_ ou _payment pool_). Là encore, il fournit une
    [démo interactive][démo joinpool] utilisant Tapsim. Il a également suggéré plusieurs modifications aux opcodes de la
    proposition MATT sur la base des résultats de sa mise en œuvre expérimentale.  Salvatore Ingala, l'auteur de la proposition
    MATT, [a répondu][ingala matt] favorablement.

## En attente de confirmation #4 : Estimation du taux de frais

_Une [série][policy series] hebdomadaire limitée sur le relais de transaction, l'inclusion dans le mempool et la sélection
des transactions minières---y compris pourquoi Bitcoin Core a une politique plus restrictive que celle permise par le
consensus et comment les portefeuilles peuvent utiliser cette politique de la manière la plus efficace._

{% include specials/policy/en/04-feerate-estimation.md %}

## Mises à jour et versions candidates

*Nouvelles versions et versions candidates pour les principaux projets d’infrastructure
Bitcoin. Veuillez envisager de passer aux nouvelles versions ou d’aider à tester
les versions candidates.*

- [LND 0.16.3-beta][] est une version de maintenance pour cette implémentation populaire de nœuds LN. Les notes de version
  indiquent que "cette version ne contient que des corrections de bogues et a pour but d'optimiser la logique de surveillance
  du mempool récemment ajoutée, ainsi que de corriger plusieurs vecteurs de fermeture forcée par inadvertance". Pour plus
  d'informations sur la logique de surveillance du mempool, voir [Newsletter #248][news248 lnd mempool].

## Changements notables dans le code et la documentation

*Changements notables cette semaine dans [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo], et
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [Bitcoin Core #26485][] permet aux méthodes RPC qui acceptent un paramètre objet `options` d'accepter les mêmes champs que les
  paramètres nommés. Par exemple, la méthode RPC `bumpfee` peut maintenant être appelée avec `src/bitcoin-cli -named bumpfee txid
  fee_rate=10` au lieu de `src/bitcoin-cli -named bumpfee txid options='{"fee_rate" : 10}'`.

- [Eclair #2642][] ajoute une RPC `closedchannels` qui fournit des données sur les canaux fermés du noeud.
  Voir aussi une PR similaire de Core Lightning mentionnée dans [Newsletter #245][news245 listclosedchannels].

- [LND #7645][] s'assure que tout taux de frais fourni par l'utilisateur dans les appels RPC à `OpenChannel`, `CloseChannel`,
  `SendCoins`, et `SendMany` n'est pas inférieur à un "taux de frais de relais". Le changement note que "le taux de frais de relais
  peut avoir une signification légèrement différente selon le backend. Pour bitcoind, c'est effectivement max(relay fee, min
  mempool fee)".

- [LND #7726][] dépensera toujours tous les HTLCs en payant le nœud local si un canal doit être réglé onchain. Il balayera ces
  HTLC même si cela peut coûter plus cher en frais de transaction qu'ils ne valent. Comparez cela à un PR d'Eclair décrit dans
  [la newsletter de la semaine dernière][news253 sweep] où ce programme n'essaiera plus de réclamer un HTLC qui est [non économique]
  topic uneconomical outputs]. Les commentaires dans le fil des RP mentionnent que LND travaille à d'autres changements qui
  amélioreront sa capacité à calculer les coûts et les gains liés au règlement des HTLC (à la fois offchain et onchain), ce qui lui
  permettra de prendre des décisions optimales à l'avenir.

- [LDK #2293][] se déconnecte puis se reconnecte aux pairs s'ils n'ont pas répondu dans un délai raisonnable. Cela peut atténuer
  un problème avec d'autres logiciels LN qui cessent parfois de répondre, ce qui entraîne la fermeture forcée des canaux.

{% include references.md %}
{% include linkers/issues.md v=2 issues="2642,26485,7645,7726,2293" %}
[policy series]: /en/blog/waiting-for-confirmation/
[news226 matt]: /fr/newsletters/2022/11/16/#contrats-intelligents-generaux-en-bitcoin-via-des-clauses-restrictives
[news249 matt]: /fr/newsletters/2023/05/03/#coffres-forts-bases-sur-matt
[news253 sweep]: /fr/newsletters/2023/05/31/#eclair-2668
[news245 listclosedchannels]: /fr/newsletters/2023/04/05/#core-lightning-5967
[halseth matt-ctv]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-June/021730.html
[halseth demo]: https://github.com/halseth/tapsim/blob/b07f29804cf32dce0168ab5bb40558cbb18f2e76/examples/matt/ctv2/README.md
[tapsim]: https://github.com/halseth/tapsim
[halseth matt-joinpool]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-May/021719.html
[demo joinpool]: https://github.com/halseth/tapsim/tree/matt-demo/examples/matt/coinpool
[ingala matt]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-May/021724.html
[news248 lnd mempool]: /fr/newsletters/2023/04/26/#lnd-7564
[lnd 0.16.3-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.16.3-beta
