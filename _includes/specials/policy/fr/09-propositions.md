[Le post de la semaine dernière][policy08] a décrit les [sorties d'ancrage][topic anchor outputs] et [l'exclusion
CPFP][topic cpfp carve out], garantissant à chaque partie du canal la possibilité d'augmenter les frais de leurs transactions
d'engagement partagées sans nécessiter de collaboration. Cette approche présente encore quelques inconvénients : les fonds du
canal sont bloqués pour créer des sorties d'ancrage, les frais des transactions d'engagement sont généralement surestimés pour
s'assurer qu'ils atteignent les frais minimaux du mempool, et l'exclusion CPFP ne permet qu'un seul descendant supplémentaire.
Les sorties d'ancrage ne peuvent pas garantir la même capacité d'augmentation des frais pour les transactions partagées entre
plus de deux parties, telles que les [coinjoins][topic coinjoin] ou les protocoles de contrat multi-parties. Ce post explore
les efforts actuels pour remédier à ces limitations et à d'autres.

[Package relay][topic package relay] comprend un protocole P2P et des modifications de politique pour permettre le transport et
la validation de groupes de transactions. Cela permettrait à une transaction d'engagement d'augmenter les frais même si la
transaction d'engagement ne respecte pas le taux de frais minimal du mempool. De plus, _Package RBF_ permettrait au descendant
qui augmente les frais de payer pour remplacer les transactions en conflit avec son parent. Package relay est conçu pour éliminer
une limitation générale au niveau du protocole de base. Cependant, en raison de son utilité pour l'augmentation des frais des
transactions partagées, il a également donné lieu à plusieurs efforts pour éliminer [l'épinglage][topic transaction pinning] pour
des cas d'utilisation spécifiques. Par exemple, Package RBF permettrait aux transactions d'engagement de se remplacer mutuellement
lorsqu'elles sont diffusées avec leurs descendants qui augmentent les frais, éliminant ainsi le besoin de plusieurs sorties
d'ancrage sur chaque transaction d'engagement.

Un inconvénient est que les règles RBF existantes exigent que la transaction de remplacement paie des frais absolus plus élevés
que les frais totaux payés par toutes les transactions à remplacer. Cette règle aide à prévenir les attaques de type DoS par des
remplacements répétés, mais permet à un utilisateur malveillant d'augmenter le coût de remplacement de sa transaction en attachant
un descendant avec des frais élevés mais un taux de frais faible. Cela empêche la transaction d'être extraite en empêchant
injustement son remplacement par un package à frais élevés, et est souvent appelé "épinglage de la règle 3".

Les développeurs ont également proposé des moyens totalement différents d'ajouter des frais aux transactions pré-signées.
Par exemple, la signature des entrées de la transaction en utilisant `SIGHASH_ANYONECANPAY | SIGHASH_ALL` pourrait permettre au
diffuseur de la transaction de fournir des frais en ajoutant des entrées supplémentaires à la transaction sans modifier les sorties.
Cependant, comme RBF n'a aucune règle exigeant que la transaction de remplacement ait un "score minier" plus élevé (c'est-à-dire
qu'elle serait sélectionnée plus rapidement pour un bloc), un attaquant pourrait épingler ces types de transactions en créant des
remplacements encombrés par des ancêtres à faible taux de frais. Ce qui complique l'évaluation précise du score de minage des
transactions et des packages de transactions, c'est que les limites existantes des ascendants et des descendants sont insuffisantes
pour limiter la complexité computationnelle de ce calcul. Toutes les transactions connectées peuvent influencer l'ordre dans lequel
les transactions sont sélectionnées pour être incluses dans un bloc. Un composant entièrement connecté, appelé un _cluster_, peut
avoir n'importe quelle taille compte tenu des limites actuelles des ascendants et des descendants.

Une solution à long terme pour remédier à certaines lacunes du mempool et aux attaques d'épinglage RBF consiste à [restructurer la
structure de données du mempool pour suivre les clusters][mempool clustering] au lieu de simplement les ensembles d'ancêtres et de
descendants. Ces clusters seraient limités en taille. Une limite de cluster restreindrait la manière dont les utilisateurs peuvent
dépenser des UTXO non confirmés, mais permettrait de linéariser rapidement l'ensemble du mempool en utilisant l'algorithme de minage
basé sur le score des ascendants, de construire des modèles de bloc extrêmement rapidement, et d'exiger que les transactions de
remplacement aient un score de minage plus élevé que la ou les transactions à remplacer.

Même ainsi, il est possible qu'aucun ensemble unique de politiques ne puisse répondre à la large gamme de besoins et d'attentes en
matière de relais de transactions. Par exemple, bien que les destinataires d'une transaction de paiement groupé bénéficient de la
possibilité de dépenser leurs sorties non confirmées, une limite de descendant plus souple laisse place à l'épinglage du package RBF
d'une transaction partagée par des frais absolus. Une proposition pour [la politique de relais de transactions
v3][topic v3 transaction relay] a été développée pour permettre aux protocoles de contrat d'opter pour un ensemble plus restrictif
de limites de package. Les transactions V3 ne permettraient que des packages de taille deux (un parent et un enfant) et limiteraient
le poids de l'enfant. Ces limites atténueraient l'épinglage RBF par des frais absolus et offriraient certains avantages du mempool
en cluster sans nécessiter une restructuration du mempool.

[Les Ancres Éphémères][topic ephemeral anchors] s'appuient sur les propriétés des transactions V3 et du relais de packages pour
améliorer davantage les sorties d'ancrage. Elles exemptent les sorties d'ancrage appartenant à une transaction V3 à frais nuls de la
[limite de poussière][topic uneconomical outputs], à condition que la sortie d'ancrage soit dépensée par un descendant qui augmente
les frais. Étant donné que la transaction sans frais doit être augmentée de frais par exactement un descendant (sinon un mineur ne
serait pas incité à l'inclure dans un bloc), cette sortie d'ancrage est "éphémère" et ne fera pas partie de l'ensemble UTXO. La
proposition d'ancres éphémères empêche implicitement les sorties autres que les sorties d'ancrage d'être dépensées lorsqu'elles ne
sont pas confirmées sans verrouillages temporels `1 OP_CSV`, puisque le seul descendant autorisé doit dépenser la sortie d'ancrage.
Cela rendrait également [la symétrie LN][topic eltoo] réalisable avec [CPFP][topic cpfp] en tant que mécanisme de provisionnement
des frais pour les transactions de fermeture de canal. Cela rend également ce mécanisme disponible pour les transactions partagées
entre plus de deux participants. Les développeurs ont utilisé [bitcoin-inquisition][bitcoin inquisition repo] pour déployer les
Ancres Éphémères et ont proposé des soft forks pour construire et tester ces changements multi-couches sur un [signet][topic signet].

Les problèmes d'épinglage mis en évidence dans ce post, entre autres, ont donné lieu à une [multitude de discussions et de
propositions pour améliorer la politique RBF][2022 rbf] l'année dernière, sur les listes de diffusion, les PR, les
réseaux sociaux et les réunions en personne. Les développeurs ont proposé et mis en œuvre des solutions allant de petites
modifications à une refonte complète. L'option `-mempoolfullrbf`, destinée à résoudre les problèmes d'épinglage et les divergences
dans les implémentations de BIP125, a mis en évidence la difficulté et l'importance de la collaboration dans la politique de relais
de transactions. Bien qu'un véritable effort ait été fait pour impliquer la communauté en utilisant des moyens habituels, notamment
en lançant la conversation sur la liste de diffusion bitcoin-dev un an à l'avance, il était clair que les méthodes de communication
et de prise de décision existantes n'avaient pas produit le résultat escompté et nécessitaient des améliorations.

La prise de décision décentralisée est un processus complexe, mais nécessaire pour soutenir l'écosystème diversifié des protocoles
et des applications qui utilisent le réseau de relais de transactions de Bitcoin. La semaine prochaine, nous publierons notre
dernier post de cette série, dans lequel nous espérons encourager nos lecteurs à participer et à améliorer ce processus.

[mempool clustering]: https://github.com/bitcoin/bitcoin/issues/27677
[policy08]: /fr/newsletters/2023/07/05/#en-attente-de-confirmation-8--la-politique-comme-interface
[2022 rbf]: /fr/newsletters/2022/12/21/#rbf
