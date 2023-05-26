[L'article de la semaine dernière][policy01] traitait du mempool comme d'un cache de transactions non confirmées qui fournit une
méthode décentralisée permettant aux utilisateurs d'envoyer des transactions aux mineurs. Cependant, les mineurs ne sont pas obligés
de confirmer ces transactions ; un bloc contenant uniquement une transaction coinbase est valide selon les règles du consensus. Les
utilisateurs peuvent inciter les mineurs à inclure leurs transactions en augmentant la valeur totale d'entrée sans modifier la
valeur totale de sortie, ce qui permet aux mineurs de réclamer la différence en tant que frais de transaction.

Bien que les frais de transaction soient courants dans les systèmes financiers traditionnels, les nouveaux utilisateurs de Bitcoin
sont souvent surpris de constater que les frais sur la chaîne sont payés non pas en proportion du montant de la transaction, mais en
fonction du poids de la transaction. C'est l'espace disponible sur les blocs, et non la liquidité, qui est le facteur limitant. Le
taux de change est généralement libellé en satoshis par octet virtuel.

Les règles de consensus limitent l'espace utilisé par les transactions dans chaque bloc. Cette limite permet de maintenir des temps
de propagation des blocs faibles par rapport à l'intervalle entre les blocs, ce qui réduit le risque de blocs périmés. Elle permet
également de limiter la croissance de la chaîne de blocs et de l'ensemble d'UTXO, qui contribuent directement au coût de démarrage
et de maintenance d'un nœud complet.

Ainsi, dans le cadre de leur rôle de cache de transactions non confirmées, les mempools facilitent également une vente aux enchères
publique pour l'espace de bloc inélastique : lorsqu'elle fonctionne correctement, la vente aux enchères fonctionne selon les
principes du marché libre, c'est-à-dire que la priorité est basée uniquement sur les frais plutôt que sur les relations avec les
mineurs.

La maximisation des frais lors de la sélection des transactions pour un bloc (dont le poids total et les opérations de signature
sont limités) est un problème [NP-hard][]. Ce problème est encore compliqué par les relations entre les transactions : l'extraction
d'une transaction à taux élevé peut nécessiter l'extraction de son parent à taux faible. En d'autres termes, l'extraction d'une
transaction à faible taux de falsification peut ouvrir la possibilité d'extraire son enfant à taux de falsification élevé.

Le mempool de Bitcoin Core calcule le taux de frais de chaque entrée et de ses ascendants (appelé _ancestor feerate_), met en cache ce
résultat et utilise un algorithme de construction de modèle de bloc avide. Il trie le mempool dans l'ordre du _score d'ancêtre_ (le
minimum du taux de frais de l'ascendant et du taux de frais individuel) et sélectionne les paquets d'ascendants dans cet ordre, en mettant à jour les informations sur les frais et le poids des ascendants des transactions restantes au fur et à mesure. Cet algorithme offre un équilibre
entre performance et rentabilité et ne produit pas nécessairement des résultats optimaux. Son efficacité peut être améliorée en
limitant la taille des transactions et des paquets ascendants---Bitcoin Core fixe ces limites à 400 000 et 404 000 unités de poids,
respectivement.

De même, un _descendant score_ est calculé et utilisé lors de la sélection des paquets à expulser du mempool, car il serait
désavantageux d'expulser une transaction à faible taux de frais qui a un descendant à fort taux de frais.

La validation du Mempool fait également appel à des frais et à des tarifs lorsqu'il s'agit de transactions qui dépensent les mêmes
intrants, c'est-à-dire des transactions à double dépense ou des transactions conflictuelles. Au lieu de toujours conserver la
première transaction qu'ils voient, les nœuds utilisent un ensemble de règles pour déterminer quelle transaction est la plus
incitative à conserver. Ce comportement est connu sous le nom de [Replace by Fee][topic rbf].

Il est intuitif que les mineurs maximisent les frais, mais pourquoi un opérateur de nœud non-mineur devrait-il mettre en œuvre ces
politiques ? Comme indiqué dans le billet de la semaine dernière, l'utilité du pool de mémoire d'un nœud non-mineur est directement
liée à sa similarité avec les pools de mémoire des mineurs. Ainsi, même si un opérateur de nœud n'a jamais l'intention de produire
un bloc en utilisant le contenu de son mempool, il a intérêt à conserver les transactions les plus compatibles avec les incitations.

Bien qu'il n'y ait pas de règles consensuelles exigeant que les transactions paient des frais, les frais et le taux de frais jouent un
rôle important dans le réseau Bitcoin en tant que moyen "équitable" de résoudre la concurrence pour l'espace des blocs. Les mineurs
utilisent le taux de frais pour évaluer l'acceptation, l'expulsion et les conflits, tandis que les nœuds non mineurs suivent ces
comportements afin de maximiser l'utilité de leurs mempools.

La rareté de l'espace des blocs exerce une pression à la baisse sur la taille des transactions et encourage les développeurs à être
plus efficaces dans la construction des transactions. Le billet de la semaine prochaine explorera des stratégies et des techniques
pratiques pour minimiser les frais dans les transactions sur la chaîne.

[policy01]: /fr/newsletters/2023/05/17/#en-attente-de-confirmation-1-pourquoi-avons-nous-un-mempool
[np-hard problem]: https://en.wikipedia.org/wiki/NP-hardness
