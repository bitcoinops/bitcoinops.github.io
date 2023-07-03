Nous avons [commencé][policy01] notre série en affirmant qu'une grande partie de la résistance de Bitcoin à la vie privée
et à la censure découle de la nature décentralisée du réseau. La pratique selon laquelle les utilisateurs gèrent leurs propres
nœuds réduit les points centraux de défaillance, de surveillance et de censure. Il s'ensuit que l'un des principaux objectifs
de conception du logiciel de nœud Bitcoin est l'accessibilité élevée de l'exploitation d'un nœud. Exiger de chaque utilisateur
de Bitcoin qu'il achète du matériel coûteux, qu'il utilise un système d'exploitation spécifique ou qu'il dépense des centaines
de dollars par mois en frais d'exploitation réduirait très probablement le nombre de nœuds sur le réseau.

Par ailleurs, un nœud du réseau Bitcoin est un ordinateur connecté à des entités inconnues qui peuvent lancer une attaque par
déni de service (DoS) en créant des messages qui font que le nœud manque de mémoire et tombe en panne, ou qu'il dépense ses
ressources informatiques et sa bande passante pour des données sans intérêt au lieu d'accepter de nouveaux blocs. Comme ces
entités sont anonymes de par leur conception, les nœuds ne peuvent pas déterminer à l'avance si un pair sera honnête ou
malveillant avant de se connecter, et ne peuvent pas l'interdire efficacement même après qu'une attaque a été observée. La mise
en œuvre de politiques de protection contre les attaques par déni de service et de limitation du coût de fonctionnement d'un
nœud complet n'est donc pas seulement un idéal, c'est un impératif.

Des protections générales contre les attaques par déni de service sont intégrées dans les implémentations des nœuds afin d'éviter
l'épuisement des ressources. Par exemple, si un nœud de Bitcoin Core reçoit de nombreux messages d'un seul pair, il ne traite que
le premier et ajoute le reste à une file d'attente pour qu'il soit traité après les messages des autres pairs. En règle générale,
un nœud télécharge d'abord l'en-tête d'un bloc et vérifie sa preuve de travail (PoW) avant de télécharger et de valider le reste
du bloc. Ainsi, tout attaquant souhaitant épuiser les ressources de ce nœud par le biais d'un relais de bloc doit d'abord dépenser
une quantité disproportionnée de ses propres ressources pour calculer une preuve de travail valide. L'asymétrie entre le coût énorme
du calcul du PoW et le coût trivial de la vérification fournit un moyen naturel d'intégrer la résistance aux attaques par déni de
service dans le relais de bloc.
Cette propriété ne s'étend pas au relais de transactions _non confirmées_.

Les protections générales contre les attaques par déni de service n'offrent pas une résistance suffisante pour permettre au
moteur de consensus d'un nœud d'être exposé à des données provenant du réseau pair-à-pair. Un attaquant tentant de [fabriquer
une transaction à forte intensité de calcul][max cpu tx], validée par consensus, peut envoyer une transaction comme la
["mégatransaction"][megatx mempool space] de 1 Mo dans le bloc #364292, dont la validation a pris un temps anormalement long en
raison de [la vérification de la signature et de l'ajustement quadratique][rusty megatx]. Un attaquant peut également rendre
toutes les signatures valides, sauf la dernière, ce qui amène le nœud à passer plusieurs minutes sur sa transaction, pour
finalement découvrir qu'elle est inutile. Pendant ce temps, le nœud retarderait le traitement d'un nouveau bloc. On peut
imaginer que ce type d'attaque vise des mineurs concurrents afin de prendre de l'avance sur le bloc suivant.

Afin d'éviter de travailler sur des transactions très coûteuses en termes de calcul, les nœuds de Bitcoin Core imposent une
taille standard maximale et un nombre maximal d'opérations de signature (ou "sigops") pour chaque transaction, ce qui est plus
restrictif que la limite de consensus par bloc. Les nœuds de Bitcoin Core imposent également des limites sur la taille des
paquets d'ancêtres et de descendants, ce qui rend les algorithmes de production et d'éviction de modèles de blocs plus efficaces
et [limite la complexité de calcul][se descendant limits] de l'insertion et de la suppression du mempool, qui nécessitent la mise
à jour des ensembles d'ancêtres et de descendants d'une transaction.
Bien que cela signifie que certaines transactions légitimes peuvent ne pas être acceptées ou relayées, ces transactions devraient
être rares.

Ces règles sont des exemples de _politique de relais de transaction_, un ensemble de règles de validation en plus du consensus
que les nœuds appliquent aux transactions non confirmées.

Par défaut, les nœuds de Bitcoin Core n'acceptent pas les transactions inférieures au taux de relais minimum de 1sat/vB
("minrelaytxfee"), ne vérifient pas les signatures avant de contrôler cette exigence et ne transmettent pas les transactions à
leurs mempools à moins qu'elles ne soient acceptées.
D'une certaine manière, cette règle de taux de frais  fixe un "prix" minimum pour la validation et le relais du réseau. Un nœud
non-mineur ne reçoit jamais de frais - ils sont uniquement payés au mineur qui confirme la transaction.
Cependant, les frais représentent un coût pour l'attaquant. Quelqu'un qui "gaspille" les ressources du réseau en envoyant un
nombre extrêmement élevé de transactions finit par manquer d'argent pour payer les frais.

La politique [Replace by Fee][topic rbf] [mise en œuvre par Bitcoin Core] [bitcoin core rbf docs] exige que la transaction de
remplacement paie des frais plus élevés que chaque transaction avec laquelle elle entre directement en conflit, mais aussi
qu'elle paie des frais totaux plus élevés que toutes les transactions qu'elle remplace. Les frais supplémentaires divisés par
la taille virtuelle de la transaction de remplacement doivent être d'au moins 1sat/vB.
En d'autres termes, quels que soient les taux des transactions d'origine et de remplacement, la nouvelle transaction doit payer
de "nouveaux" frais pour couvrir le coût de sa propre bande passante à 1sat/vB.
Cette politique tarifaire n'est pas principalement axée sur la compatibilité des incitations. Il s'agit plutôt d'un coût minimum
pour les remplacements répétés de transactions afin de limiter les attaques qui gaspillent la bande passante, par exemple en
ajoutant seulement 1 satoshi supplémentaire à chaque remplacement.

Un nœud qui valide entièrement les blocs et les transactions nécessite des ressources, notamment de la mémoire, des ressources
informatiques et de la bande passante. Les exigences en matière de ressources doivent rester faibles afin de rendre l'exploitation
d'un nœud accessible et de défendre le nœud contre l'exploitation. Les protections générales contre les attaques par déni de
service n'étant pas suffisantes, les nœuds appliquent des politiques de relais de transaction en plus des règles de consensus
lorsqu'ils valident des transactions non confirmées. Toutefois, la politique n'étant pas un consensus, deux nœuds peuvent avoir
des politiques différentes mais être d'accord sur l'état actuel de la chaîne. Le billet de la semaine prochaine traitera de la
politique en tant que choix individuel.

[policy01]: /fr/newsletters/2023/05/17/#en-attente-de-confirmation-1--pourquoi-avons-nous-un-mempool-
[max cpu tx]: https://bitcointalk.org/?topic=140078
[megatx mempool space]: https://mempool.space/tx/bb41a757f405890fb0f5856228e23b715702d714d59bf2b1feb70d8b2b4e3e08
[rusty megatx]: https://rusty.ozlabs.org/?p=522
[bitcoin core rbf docs]: https://github.com/bitcoin/bitcoin/blob/v25.0/doc/policy/mempool-replacements.md
[pr 6722]: https://github.com/bitcoin/bitcoin/pull/6722
[se descendant limits]: https://bitcoin.stackexchange.com/questions/118160/whats-the-governing-motivation-for-the-descendent-size-limit
