---
title: 'Bulletin Hebdomadaire Bitcoin Optech #276'
permalink: /fr/newsletters/2023/11/08/
name: 2023-11-08-newsletter-fr
slug: 2023-11-08-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine annonce un prochain changement sur la liste de diffusion Bitcoin-Dev et résume brièvement une proposition
permettant d'agréger plusieurs HTLC (Hashed Time-Locked Contracts) ensemble. Sont également incluses nos sections habituelles avec le
résumé d'une réunion du Bitcoin Core PR Review Club, des annonces de mises à jour et versions candidates, ainsi que les changements
apportés aux principaux logiciels d'infrastructure Bitcoin.

## Nouvelles

- **Hébergement de la liste de diffusion :** les administrateurs de la liste de diffusion Bitcoin-Dev [ont annoncé][bishop lists] que
  l'organisation hébergeant la liste prévoit de cesser d'héberger toutes les listes de diffusion à partir de la fin de l'année.
  Les archives des courriels précédents devraient continuer à être hébergées à leurs URL actuelles dans un avenir prévisible.
  Nous supposons que la fin de la transmission des courriels affecte également la liste de diffusion Lightning-Dev, qui est hébergée
  par la même organisation.

    Les administrateurs ont sollicité les commentaires de la communauté sur les options, notamment la migration de la liste de diffusion
    vers Google Groups. Si une telle migration se produit, Optech commencera à l'utiliser comme l'une de nos [sources
    d'informations][sources].

    Nous sommes également conscients que, dans les mois précédant l'annonce, certains développeurs bien établis avaient commencé à
    expérimenter des discussions sur le forum web [DelvingBitcoin][]. Optech commencera à surveiller ce forum pour les discussions
    intéressantes ou importantes à partir de maintenant. {% assign timestamp="1:05" %}

- **Agrégation HTLC avec des covenants :** Johan Torås Halseth [a posté][halseth agg] sur la liste de diffusion Lightning-Dev une
  suggestion pour utiliser un [covenant][topic covenants] afin d'agréger plusieurs [HTLC][topic htlc] en une seule sortie qui pourrait
  être dépensée en une seule fois si une partie connaissait tous les préimages. Si une partie ne connaissait que certaines des préimages,
  elle pourrait simplement les réclamer, puis le solde restant pourrait être remboursé à l'autre partie. Halseth note que cela serait
  plus efficace on-chain et pourrait rendre plus difficile la réalisation de certains types [d'attaques de blocage de
  canal][topic channel jamming attacks]. {% assign timestamp="5:36" %}

## Bitcoin Core PR Review Club

*Dans cette section mensuelle, nous résumons une récente réunion du
[Bitcoin Core PR Review Club][] en soulignant certaines des questions
et réponses importantes. Cliquez sur une question ci-dessous pour voir
un résumé de la réponse de la réunion.*

[Les mises à jour de l'estimateur de frais à partir de l'interface de validation/du thread CScheduler][review club 28368] est un PR
d'Abubakar Sadiq Ismail (ismaelsadeeq)
qui modifie la manière dont les données de l'estimateur de frais des transactions sont mises à jour.
(L'estimation des frais est utilisée lorsque le propriétaire du nœud lance une transaction.)
Il déplace les mises à jour de l'estimateur de frais qui se produisent de manière synchrone lors des mises à jour de la mempool
(ajout ou suppression de transactions) pour les faire se produire de manière asynchrone.
Bien que cela ajoute une complexité de traitement supplémentaire, cela améliore les performances du chemin critique (comme le montre
la discussion suivante).

Lorsqu'un nouveau bloc est trouvé, ses transactions présentes dans la mempool sont supprimées, ainsi que toutes les transactions en
conflit avec les transactions du bloc.
Étant donné que le traitement et la transmission des blocs sont critiques en termes de performances, cela est bénéfique pour réduire
la quantité de travail nécessaire lors du traitement d'un nouveau bloc, tel que la mise à jour de l'estimateur de frais.
{% assign timestamp="16:47" %}

{% include functions/details-list.md
  q0="Pourquoi est-il bénéfique de supprimer la dépendance de `CTxMempool` à `CBlockPolicyEstimator`?"
  a0="Actuellement, lors de la réception d'un nouveau bloc, son traitement est bloqué pendant que l'estimateur de frais est mis à jour.
      Cela retarde l'achèvement du traitement du nouveau bloc et retarde également la transmission du bloc aux pairs. En supprimant la
      dépendance de `CTxMempool` à `CBlockPolicyEstimator`, les estimations de frais peuvent être mises à jour de manière asynchrone
      (dans un thread différent) afin que la validation et la transmission puissent être effectuées plus rapidement. Cela peut
      également faciliter les tests de `CTxMempool`. Enfin, cela permet l'utilisation future d'algorithmes d'estimation de frais plus
      complexes sans affecter les performances de validation et de transmission des blocs."
  a0link="https://bitcoincore.reviews/28368#l-30"

  q1="Est-ce que l'estimation des frais est actuellement mise à jour de manière synchrone lorsque des transactions sont ajoutées ou
      supprimées de la mempool même sans l'arrivée d'un nouveau bloc?"
  a1="Oui, mais les performances ne sont pas aussi critiques à ces moments-là que lors de la validation et de la transmission des blocs."
  a1link="https://bitcoincore.reviews/28368#l-41"

  q2="Y a-t-il des avantages à ce que `CBlockPolicyEstimator` soit un membre de `CTxMempool` et à ce qu'il soit mis à jour de manière
      synchrone (l'arrangement actuel)? Y a-t-il des inconvénients à le supprimer?"
  a2="Le code synchrone est plus simple et plus facile à comprendre. De plus, l'estimateur de frais a une meilleure visibilité sur
      l'ensemble de la mempool ; un inconvénient est la nécessité d'encapsuler toutes les informations nécessaires à l'estimation des
      frais dans une nouvelle structure `NewMempoolTransactionInfo`. Cependant, peu d'informations sont nécessaires pour l'estimateur
      de frais."
  a2link="https://bitcoincore.reviews/28368#l-43"

  q3="Quels sont, selon vous, les avantages et les inconvénients de l'approche adoptée dans ce PR, par rapport à celle adoptée dans
      le [PR 11775][] qui divise `CValidationInterface`?"
  a3="Bien qu'il semble agréable de les diviser, ils avaient toujours un backend partagé (pour maintenir les événements bien ordonnés),
      donc ils n'étaient pas vraiment indépendants les uns des autres. Il ne semble pas y avoir beaucoup d'avantages pratiques à la
      division. Le PR actuel est plus étroit et vise uniquement à rendre les mises à jour des estimations de frais asynchrones."
  a3link="https://bitcoincore.reviews/28368#l-71"

  q4="Dans une sous-classe, pourquoi implémenter une méthode `CValidationInterface` équivaut à s'abonner à l'événement?"
  a4="Toutes les sous-classes de `CValidationInterface` sont des clients. La sous-classe peut implémenter certaines ou toutes les
      méthodes `CValidationInterface` (rappels), par exemple, connecter ou déconnecter un bloc, ou une transaction [ajoutée][tx add]
      ou [supprimée][tx remove] de la mempool. Après avoir été enregistrée (en appelant `RegisterSharedValidationInterface()`),
      toute méthode `CValidationInterface` implémentée sera exécutée à chaque fois que le rappel de la méthode sera déclenché en
      utilisant `CMainSignals`. Les rappels sont déclenchés chaque fois que l'événement correspondant se produit."
  a4link="https://bitcoincore.reviews/28368#l-90"

q5="[`BlockConnected`][BlockConnected] et [`NewPoWValidBlock`][NewPoWValidBlock] sont des rappels différents.
      Lequel est asynchrone et lequel est synchrone ? Comment pouvez-vous le dire ?"
  a5="`BlockConnected` est asynchrone ; `NewPoWValidBlock` est synchrone.
      Les rappels asynchrones mettent en file d'attente un \"événement\" qui sera exécuté ultérieurement dans le thread `CScheduler`."
  a5link="https://bitcoincore.reviews/28368#l-105"

  q6="Dans [l'engagement 4986edb][], pourquoi ajoutons-nous un nouveau rappel,
      `MempoolTransactionsRemovedForConnectedBlock`, au lieu d'utiliser
      `BlockConnected` (qui indique également une transaction supprimée
      du mempool) ?"
  a6="L'estimateur de frais doit savoir quand les transactions sont supprimées du
      mempool pour n'importe quelle raison, pas seulement lorsqu'un bloc est connecté.
      De plus, l'estimateur de frais a besoin des frais de base d'une transaction, ce qui n'est pas
      fourni via `BlockConnected` (qui fournit un `CBlock`).
      Nous pourrions ajouter les frais de base aux entrées de la liste des transactions `block.vtx`,
      mais il est indésirable de modifier une structure de données aussi importante et omniprésente
      juste pour prendre en charge l'estimation des frais."
  a6link="https://bitcoincore.reviews/28368#l-130"

  q7="Pourquoi n'utilisons-nous pas un `std::vector<CTxMempoolEntry>` comme paramètre du
      rappel `MempoolTransactionsRemovedForBlock` ?
      Cela éliminerait la nécessité d'un nouveau type de structure pour contenir les
      informations par transaction nécessaires à l'estimation des frais."
  a7="L'estimateur de frais n'a pas besoin de tous les champs de `CTxMempoolEntry`."
  a7link="https://bitcoincore.reviews/28368#l-159"

  q8="Comment le frais de base d'une `CTransactionRef` est-il calculé ?"
  a8="C'est la somme des valeurs d'entrée moins la somme des valeurs de sortie.
      Cependant, le rappel ne peut pas accéder aux valeurs d'entrée car elles sont stockées
      dans les sorties de transaction précédentes (auxquelles le rappel n'a pas accès).
      C'est pourquoi les frais de base sont inclus dans la structure `TransactionInfo`."
  a8link="https://bitcoincore.reviews/28368#l-166"
%}

## Mises à jour et versions candidates

*Nouvelles versions et versions candidates pour les principaux projets
d'infrastructure Bitcoin. Veuillez envisager de passer aux nouvelles
versions ou d'aider à tester les versions candidates.*

- [Bitcoin Core 26.0rc2][] est un candidat à la version pour la prochaine version majeure
  de l'implémentation principale du nœud complet. Il y a un bref aperçu à propos de [suggestions de tests][26.0 testing]
  et une réunion prévue du [Bitcoin Core PR Review Club][] dédiée aux tests le 15 novembre 2023. {% assign timestamp="26:14" %}

- [Core Lightning 23.11rc1][] est un candidat à la version pour la prochaine
  version majeure de cette implémentation de nœud LN. {% assign timestamp="29:26" %}

- [LND 0.17.1-beta.rc1][] est un candidat à la version pour une version de maintenance
  de cette implémentation de nœud LN. {% assign timestamp="31:28" %}

## Changements notables dans le code et la documentation

*Changements notables cette semaine dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning repo], [Eclair][eclair repo],
[LDK][ldk repo],[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Interface Portefeuille Matériel (HWI)][hwi repo],
[Rust Bitcoin][rust bitcoin repo], [Serveur BTCPay][btcpay server repo], [BDK][bdk repo], [Propositions d'Amélioration Bitcoin
(BIPs)][bips repo], [Lightning BOLTs][bolts repo], et [Inquisition Bitcoin][bitcoin inquisition repo].*

- [Core Lightning #6824][] met à jour la mise en œuvre du [protocole de financement interactif][topic dual funding] pour "stocker l'état
  lors de l'envoi de `commitment_signed`, et [ajouter] un champ `next_funding_txid` à `channel_reestablish` pour demander à notre pair
  de retransmettre les signatures que nous n'avons pas reçues." Cela est basé sur une [mise à jour][36c04c8ac] de la proposition [de
  financement interactif][bolts #851]. {% assign timestamp="32:38" %}

- [Core Lightning #6783][] déprécie l'option de configuration `large-channels`, rendant les [grands canaux][topic large channels] et
  les montants de paiement importants toujours activés. {% assign timestamp="34:59" %}

- [Core Lightning #6780][] améliore la prise en charge de l'augmentation des frais des transactions onchain associées aux [sorties
  d'ancrage][topic anchor outputs]. {% assign timestamp="36:29" %}

- [Core Lightning #6773][] permet à la RPC `decode` de vérifier que le contenu d'un fichier de sauvegarde est valide et contient les
  dernières informations nécessaires pour effectuer une récupération complète. {% assign timestamp="39:06" %}

- [Core Lightning #6734][] met à jour la RPC `listfunds` pour fournir aux utilisateurs les informations nécessaires s'ils souhaitent
  augmenter les frais [CPFP][topic cpfp] d'une transaction de fermeture mutuelle de canal. {% assign timestamp="39:58" %}

- [Eclair #2761][] permet de transférer un nombre limité de [HTLC][topic htlc] à une partie même s'ils sont inférieurs à leur réserve
  de canal requise. Cela peut aider à résoudre un problème de _fonds bloqués_ qui pourrait survenir après [un splicing][topic splicing]
  ou [le financement double][topic dual funding]. Voir le [Bulletin #253][news253 stuck] pour une autre atténuation par Eclair pour un
  problème de fonds bloqués. {% assign timestamp="41:02" %}

<div markdown="1" class="callout">
## Vous en voulez plus?

Pour plus de discussions sur les sujets mentionnés dans ce bulletin, rejoignez-nous pour le récapitulatif hebdomadaire Bitcoin Optech
sur [Twitter Spaces][@bitcoinoptech] à 15h00 UTC le jeudi (le jour suivant la publication de la newsletter). La discussion est également
enregistrée et sera disponible sur notre page de [podcasts][podcast].

</div>

{% include references.md %}
{% include linkers/issues.md v=2 issues="6824,6783,6780,6773,6734,2761,851" %}
[bitcoin core 26.0rc2]: https://bitcoincore.org/bin/bitcoin-core-26.0/
[core lightning 23.11rc1]: https://github.com/ElementsProject/lightning/releases/tag/v23.11rc1
[lnd 0.17.1-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.17.1-beta.rc1[sources]: /internal/sources/
[bishop lists]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-November/022134.html
[delvingbitcoin]: https://delvingbitcoin.org/
[halseth agg]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-October/004181.html
[36c04c8ac]: https://github.com/lightning/bolts/pull/851/commits/36c04c8aca48e04d1fba64d968054eba221e63a1
[news253 stuck]: /fr/newsletters/2023/05/31/#eclair-2666
[bitcoin core pr review club]: https://bitcoincore.reviews/#upcoming-meetings
[26.0 testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/26.0-Testing-Guide-Topics
[review club 28368]: https://bitcoincore.reviews/28368
[pr 11775]: https://github.com/bitcoin/bitcoin/pull/11775
[tx add]: https://github.com/bitcoin/bitcoin/blob/eca2e430acf50f11da2220f56d13e20073a57c9b/src/validation.cpp#L1217
[tx remove]: https://github.com/bitcoin/bitcoin/blob/eca2e430acf50f11da2220f56d13e20073a57c9b/src/txmempool.cpp#L504
[BlockConnected]: https://github.com/bitcoin/bitcoin/blob/d53400e75e2a4573229dba7f1a0da88eb936811c/src/validationinterface.cpp#L227
[NewPoWValidBlock]: https://github.com/bitcoin/bitcoin/blob/d53400e75e2a4573229dba7f1a0da88eb936811c/src/validationinterface.cpp#L260
[l'engagement 4986edb]: https://github.com/bitcoin-core-review-club/bitcoin/commit/4986edb99f8aa73f72e87f3bdc09387c3e516197