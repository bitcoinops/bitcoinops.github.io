---
title: 'Bulletin Hebdomadaire Bitcoin Optech #259'
permalink: /fr/newsletters/2023/07/12/
name: 2023-07-12-newsletter-fr
slug: 2023-07-12-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Ce bulletin décrit une proposition visant à supprimer des détails de la spécification LN qui ne sont plus pertinents pour les
nœuds modernes et inclut l'avant-dernière entrée de notre série hebdomadaire limitée sur la politique de mempool, ainsi que nos
sections habituelles résumant une réunion du Bitcoin Core PR Review Club, annonçant de nouvelles versions et versions candidates,
et décrivant les changements apportés aux principaux logiciels d'infrastructure Bitcoin.

## Nouvelles

- **Proposition de nettoyage de la spécification LN :** Rusty Russell [a posté][russell clean up] sur la liste de diffusion
  Lightning-Dev un lien vers un [PR][bolts #1092] où il propose de supprimer certaines fonctionnalités qui ne sont plus
  prises en charge par les implémentations LN modernes et de supposer que d'autres fonctionnalités seront toujours prises en charge.
  En lien avec les changements proposés, Russell fournit également les résultats d'une enquête qu'il a menée sur les fonctionnalités
  des nœuds publics en fonction de leurs messages de gossip. Ses résultats indiquent que presque tous les nœuds prennent en charge
  les fonctionnalités suivantes :

  - *Messages d'oignon de taille variable :* intégrés à la spécification en 2019
    (voir [Newsletter #58][news58 bolts619]) à peu près en même temps que la spécification a été mise à jour pour utiliser des
    champs Type-Length-Value (TLV). Cela a remplacé le format original pour le routage oignon chiffré qui nécessitait que chaque
    saut utilise un message de longueur fixe et limitait le nombre de sauts à 20. Le format de taille variable facilite beaucoup le
    relais de données arbitraires vers des sauts spécifiques, le seul inconvénient étant que la taille globale du message reste
    constante, de sorte que toute augmentation de la quantité de données envoyées diminue le nombre maximum de sauts.

  - *Requêtes de gossip :* intégrées à la spécification en 2018 (voir [BOLTs #392][]).
    Cela permet à un nœud de demander à ses pairs uniquement un sous-ensemble des messages de gossip envoyés par d'autres nœuds sur
    le réseau. Par exemple, un nœud peut demander uniquement les mises à jour de gossip récentes, en ignorant les mises à jour plus
    anciennes pour économiser la bande passante et réduire le temps de traitement.

  - *Protection contre la perte de données :* intégrée à la spécification en 2017 (voir [BOLTs #240][]).
    Les nœuds utilisant cette fonctionnalité envoient des informations sur leur dernier état de canal lorsqu'ils se reconnectent.
    Cela peut permettre à un nœud de détecter qu'il a perdu des données, et cela encourage un nœud qui n'a pas perdu de données à
    fermer le canal dans son dernier état. Voir [Newsletter #31][news31 data loss] pour des détails supplémentaires.

  - *Clés de partie distante statiques :* intégrées à la spécification en 2019
    (voir [Newsletter #67][news67 bolts642]), cela permet à un nœud de demander que chaque mise à jour de canal s'engage à envoyer
    les fonds non-[HTLC][topic htlc] du nœud à la même adresse. Auparavant, une adresse différente était utilisée à chaque mise à
    jour de canal. Après ce changement, un nœud qui a opté pour ce protocole et qui a perdu des données recevra presque toujours à
    un moment donné au moins une partie de ses fonds à l'adresse choisie, comme une adresse dans son [portefeuille HD][topic bip32].

  Les premières réponses au PR de proposition de nettoyage ont été positives. {% assign timestamp="0:58" %}

## En attente de confirmation #9 : Propositions de politique

_Une série hebdomadaire limitée [série][policy series] sur le relais des transactions, l'inclusion dans le mempool et la sélection
des transactions minières--y compris pourquoi Bitcoin Core a une politique plus restrictive que celle autorisée par consensus et
comment les portefeuilles peuvent utiliser cette politique de la manière la plus efficace._

{% include specials/policy/fr/09-propositions.md %} {% assign timestamp="18:59" %}

## Bitcoin Core PR Review Club

*Dans cette section mensuelle, nous résumons une récente réunion du [Club de révision des PR de Bitcoin Core][]
en mettant en évidence certaines des questions et réponses importantes. Cliquez sur
une question ci-dessous pour voir un résumé de la réponse de la réunion.*

[Arrêter de relayer les txs non-mempools][review club 27625]
est une PR de Marco Falke (MarcoFalke) qui simplifie le client Bitcoin Core
en supprimant une structure de données en mémoire, `mapRelay`, qui peut
causer une consommation élevée de mémoire et n'est plus nécessaire, ou du moins
n'apporte que des avantages marginaux.
Cette carte contient des transactions qui peuvent ou non être également dans le mempool,
et est parfois utilisée pour répondre aux demandes [`getdata`][wiki getdata] des pairs. {% assign timestamp="41:42" %}

{% include functions/details-list.md
  q0="Quelles sont les raisons de supprimer `mapRelay`?"
  a0="La consommation de mémoire de cette structure de données est illimitée.
      Bien qu'elle n'utilise généralement pas beaucoup de mémoire, il est préoccupant lorsque
      la taille de toute structure de données est déterminée par le comportement
      d'entités externes (pairs) et n'a pas de maximum, car cela peut créer
      une vulnérabilité DoS."
  a0link="https://bitcoincore.reviews/27625#l-19"

  q1="Pourquoi la consommation de mémoire de `mapRelay` est-elle difficile à déterminer?"
  a1="Chaque entrée dans `mapRelay` est un pointeur partagé vers une transaction
      (`CTransaction`), le mempool pouvant également contenir un autre pointeur.
      Un deuxième pointeur vers le même objet utilise très peu d'espace supplémentaire
      par rapport à un seul pointeur.
      Si une transaction partagée est supprimée du mempool,
      tout son espace devient attribuable à l'entrée `mapRelay`.
      Ainsi, l'utilisation de la mémoire de `mapRelay` ne dépend pas seulement du nombre
      de transactions et de leurs tailles individuelles, mais aussi du nombre
      de transactions qui ne sont plus dans le mempool, ce qui est difficile
      à prévoir."
  a1link="https://bitcoincore.reviews/27625#l-33"

  q2="Quel problème est résolu en introduisant `m_most_recent_block_txs`?
      (Il s'agit d'une liste des transactions uniquement dans le bloc le plus récemment reçu.)"
  a2="Sans cela, puisque `mapRelay` n'est plus disponible, nous ne pourrions pas
      servir les transactions nouvellement extraites (dans le bloc le plus récent)
      aux pairs qui les demandent, car nous les aurions supprimées de
      notre mempool."
  a2link="https://bitcoincore.reviews/27625#l-45"

  q3="Pensez-vous qu'il est nécessaire d'introduire `m_most_recent_block_txs`,
      plutôt que de simplement supprimer `mapRelay` sans le remplacer?"
  a3="Il y avait une certaine incertitude parmi les participants du club de révision concernant cette question.
      Il a été suggéré que `m_most_recent_block_txs` pourrait améliorer la vitesse de propagation des blocs,
      car si notre pair n'a pas encore le bloc que nous venons de recevoir, la capacité de notre nœud à fournir ses transactions
      peut aider à compléter notre pair avec le [bloc compact][topic compact block relay].
      Une autre suggestion était que cela pourrait aider en cas de division de la chaîne ;
      si notre pair est sur un point différent du nôtre, il se peut qu'il n'ait pas cette
      transaction via un bloc."
  a3link="https://bitcoincore.reviews/27625#l-54"

  q4="Quelles sont les exigences de mémoire pour `m_most_recent_block_txs`
      par rapport à `mapRelay`?"
  a4="Le nombre d'entrées dans `m_most_recent_block_txs` est limité par
      le nombre de transactions dans un bloc. Mais l'exigence de mémoire
      est encore inférieure à celui de nombreuses transactions, car les entrées
      de `m_most_recent_block_txs` sont des pointeurs partagés (vers des transactions), et ils sont
      également (déjà) pointés par `m_most_recent_block`."
  a4link="https://bitcoincore.reviews/27625#l-65"

  q5="Y a-t-il des scénarios dans lesquels les transactions seraient disponibles
      pendant une durée plus courte ou plus longue qu'auparavant en raison de ce changement?"
  a5="Plus longtemps lorsque le temps écoulé depuis le dernier bloc est supérieur à 15 minutes
      (qui est le temps pendant lequel les entrées restaient dans `mapRelay`), sinon plus court.
      Cela semble acceptable car le choix du délai de 15 minutes était plutôt arbitraire.
      Mais le changement peut réduire la disponibilité des transactions en cas de
      divisions de chaînes supérieures à un bloc de profondeur (qui sont extrêmement rares)
      car nous ne conservons pas les transactions qui sont uniques aux chaînes moins longues."
  a5link="https://bitcoincore.reviews/27625#l-70"
%}

## Mises à jour et verions candidates

*Nouvelles versions et versions candidates pour les principaux projets d’infrastructure
Bitcoin. Veuillez envisager de passer aux nouvelles versions ou d’aider à tester
les versions candidates.*

- [LND v0.16.4-beta][] est une version de maintenance de ce logiciel de nœud LN
  qui corrige une fuite de mémoire qui peut affecter certains utilisateurs. {% assign timestamp="50:43" %}

## Changements notables dans le code et la documentation

*Changements notables cette semaine dans [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Interface de portefeuille
matériel (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [Serveur BTCPay][btcpay server repo],
[BDK][bdk repo], [Propositions d'amélioration de Bitcoin (BIPs)][bips repo], [Lightning BOLTs][bolts repo] et
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [Bitcoin Core #27869][] émet un avertissement de dépréciation lors du chargement d'un
  portefeuille hérité dans le cadre des efforts continus décrits dans [Bitcoin Core #20160][]
  pour aider les utilisateurs à migrer des portefeuilles hérités vers des portefeuilles [descripteurs][topic descriptors]
  comme mentionné dans les bulletins d'information [#125][news125 descriptor wallets],
  [#172][news172 descriptor wallets] et [#230][news230 descriptor wallets]. {% assign timestamp="51:48" %}

{% include references.md %}
{% include linkers/issues.md v=2 issues="1092,392,240,20160,27869" %}
[news58 bolts619]: /en/newsletters/2019/08/07/#bolts-619
[policy series]: /fr/blog/waiting-for-confirmation/
[news31 data loss]: /en/newsletters/2019/01/29/#fn:fn-data-loss-protect
[news67 bolts642]: /en/newsletters/2019/10/09/#bolts-642
[lnd v0.16.4-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.16.4-beta
[russell clean up]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-June/004001.html
[review club 27625]: https://bitcoincore.reviews/27625
[wiki getdata]: https://en.bitcoin.it/wiki/Protocol_documentation#getdata
[news125 descriptor wallets]: /en/newsletters/2020/11/25/#how-will-the-migration-tool-from-a-bitcoin-core-legacy-wallet-to-a-descriptor-wallet-work
[news172 descriptor wallets]: /en/newsletters/2021/10/27/#bitcoin-core-23002
[news230 descriptor wallets]: /fr/newsletters/2022/12/14/#avec-la-dépréciation-des-anciens-portefeuilles-bitcoin-core-sera-t-il-capable-de-signer-des-messages-pour-une-adresse