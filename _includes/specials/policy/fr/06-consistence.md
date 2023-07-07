Le billet de la semaine dernière présentait la politique, un ensemble de règles de validation des transactions appliquées en plus
des règles de consensus. Ces règles ne s'appliquent pas aux transactions dans les blocs, de sorte qu'un nœud peut rester dans le
consensus même si sa politique diffère de celle de ses pairs. Tout comme un opérateur de nœud peut décider de ne pas participer
au relais de transaction, il est également libre de choisir n'importe quelle politique, voire aucune (exposant son nœud au risque
de déni de service). Cela signifie que nous ne pouvons pas supposer une homogénéité totale des politiques de mempool dans le réseau.
Cependant, pour que la transaction d'un utilisateur soit reçue par un mineur, elle doit passer par un chemin de nœuds qui
l'acceptent tous dans leur mempool---la divergence de politique entre les nœuds affecte directement la fonctionnalité du relais
de transaction.

Pour donner un exemple extrême des différences de politique entre les nœuds, imaginons une situation dans laquelle chaque
opérateur de nœud choisirait une `nVersion` aléatoire et n'accepterait que les transactions avec cette `nVersion`.  Comme
la plupart des relations d'égal à égal auraient des politiques incompatibles, les transactions ne se propageraient pas aux mineurs.

De l'autre côté du spectre, des politiques identiques à travers le réseau aident à faire converger les contenus des mempools.
Un réseau avec des mempools correspondants relaie les transactions le plus facilement, et est également idéal pour
[l'estimation des frais][policy04] et [le relais de bloc compact][policy01] comme mentionné dans les posts précédents.

Étant donné la complexité de la validation des mempools et les difficultés qui découlent des disparités entre les politiques,
Bitcoin Core a [historiquement été conservateur][aj mempool consistency] avec la configurabilité des politiques. Alors que les
utilisateurs peuvent facilement modifier la façon dont les sigops sont comptés (`bytespersigop`) et limiter la quantité de
données intégrées dans les sorties `OP_RETURN` (`datacarriersize` et `datacarrier`), ils ne peuvent pas renoncer au poids
standard maximum de 400 000 unités de poids ou appliquer un ensemble différent de règles RBF liées aux frais sans modifier
le code source.

Certaines options de configuration de la politique de Bitcoin Core existent pour tenir compte des différences entre les
environnements d'exploitation des nœuds et les objectifs d'exploitation d'un nœud. Par exemple, les ressources matérielles
d'un mineur et la raison pour laquelle il conserve un mempool diffèrent de celles d'un utilisateur quotidien qui fait
fonctionner un nœud léger sur son ordinateur portable ou son Raspberry Pi. Un mineur peut choisir d'augmenter la capacité
de son mempool (`maxmempool`) ou son délai d'expiration (`mempoolexpiry`) pour stocker des transactions à faible taux d'échange
pendant les pics de trafic, puis les exploiter plus tard lorsque le trafic diminue. Les sites web fournissant des visualisations,
des archives et des statistiques sur le réseau peuvent utiliser plusieurs noeuds pour collecter autant de données que possible
et afficher le comportement par défaut du mempool.

Sur un nœud individuel, le choix de la capacité du mempool affecte la disponibilité des outils de substitution de frais.
Lorsque les taux minimums du mempool augmentent en raison de soumissions de transactions dépassant la taille par défaut du
mempool, les transactions purgées du "bas" du mempool et les nouvelles qui sont en dessous de ce taux ne peuvent plus être
surtaxées en utilisant [CPFP][topic cpfp].

D'un autre côté, puisque les entrées utilisées par les transactions purgées ne sont plus dépensées par aucune transaction
dans le mempool, il peut être possible de faire du fee-bump via [RBF][topic rbf] alors que ce n'était pas le cas auparavant.
La nouvelle transaction ne remplace rien dans le mempool du noeud, donc elle n'a pas besoin de prendre en compte les règles
habituelles de RBF. Cependant, les nœuds qui n'ont pas expulsé la transaction originale (parce qu'ils ont une plus grande
capacité de mempool) traitent la nouvelle transaction comme un remplacement proposé et exigent qu'elle respecte les règles RBF.
Si la transaction purgée ne signalait pas la remplaçabilité BIP125, ou si les frais de la nouvelle transaction ne répondent
pas aux exigences RBF en dépit d'un taux élevé, le mineur peut refuser la nouvelle transaction. Les portefeuilles doivent
traiter les transactions purgées avec précaution : les résultats de la transaction ne peuvent pas être considérés comme
disponibles pour la dépense, mais les entrées sont également indisponibles pour la réutilisation.

À première vue, il peut sembler qu'un nœud ayant une plus grande capacité de mempool rend le CPFP plus utile et le RBF moins utile.
Cependant, le relais des transactions est soumis au comportement émergent du réseau et il se peut qu'il n'y ait pas de chemin
de nœuds acceptant le CPFP depuis l'utilisateur jusqu'au mineur. Les nœuds ne transmettent généralement les transactions
qu'une fois qu'ils les ont acceptées dans leur mempool et ignorent les annonces de transactions qui existent déjà dans leur
mempool - les nœuds qui stockent davantage de transactions [agissent comme des trous noirs][se maxmempool] lorsque ces
transactions leur sont rediffusées. À moins que l'ensemble du réseau n'augmente la capacité de ses mempools - ce qui serait
un signe de changement de la valeur par défaut - les utilisateurs ne doivent pas s'attendre à ce que l'augmentation de la
capacité de leurs propres mempools leur apporte beaucoup d'avantages. Le taux de frais minimum fixé par les mempools par
défaut limite l'utilité de CPFP pendant les périodes de fort trafic. Un utilisateur ayant réussi à soumettre
une transaction CPFP à son propre mempool, dont la taille a été augmentée, pourrait ne pas remarquer que la transaction ne
s'est pas propagée à d'autres utilisateurs.

Le réseau de relais de transactions est composé de nœuds individuels qui rejoignent et quittent dynamiquement le réseau,
chacun d'entre eux devant se protéger contre l'exploitation. En tant que tel, le relais de transaction ne peut être que le
fruit d'un effort et nous ne pouvons pas garantir que chaque nœud est informé de chaque transaction non confirmée. En même
temps, le réseau Bitcoin est plus performant si les nœuds convergent vers un ensemble de politiques de relais de transactions
qui rend les mempools aussi homogènes que possible. Le prochain article examinera les mesures qui ont été adoptées afin de
répondre aux intérêts du réseau dans son ensemble.

[policy01]: /fr/newsletters/2023/05/17/#en-attente-de-confirmation-1--pourquoi-avons-nous-un-mempool-
[policy04]: /fr/newsletters/2023/06/07/#en-attente-de-confirmation-4--estimation-du-taux-de-frais
[aj mempool consistency]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-October/021116.html
[se maxmempool]: https://bitcoin.stackexchange.com/questions/118137/how-does-it-contribute-to-the-bitcoin-network-when-i-run-a-node-with-a-bigger-th

