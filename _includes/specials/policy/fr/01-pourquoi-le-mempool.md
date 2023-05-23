<!--
  300 to 1000 words
  put title in main newsletter
  put links in this file
  for any subheads use h3 (i.e., ###)
  illustrations welcome (max width 800px)
  if uncertain about anything, just do what seems best and harding will edit
-->

De nombreux nœuds du réseau Bitcoin stockent les transactions non confirmées dans un réservoir de mémoire, ou _mempool_. Ce cache
est une ressource importante pour chaque nœud et permet au réseau de relais de transactions de pair à pair de fonctionner.

Les nœuds qui participent au relais de transaction téléchargent et valident les blocs progressivement plutôt que par pics. Toutes
les 10 minutes environ, lorsqu'un bloc est trouvé, les nœuds sans mempool connaissent un pic de bande passante, suivi d'une période
de calcul intensif pour valider chaque transaction.  D'un autre côté, les nœuds disposant d'un mempool ont généralement déjà vu
toutes les transactions du bloc et les stockent dans leurs mempools. Avec [compact block relay][topic compact block relay], ces
nœuds téléchargent simplement un en-tête de bloc avec des shortids, puis reconstruisent le bloc à l'aide des transactions de leurs
mempools.
La quantité de données utilisées pour relayer les blocs compacts est minime par rapport à la taille du bloc. La validation des
transactions est également beaucoup plus rapide : le nœud a déjà vérifié (et mis en cache) les signatures et les scripts, calculé
les exigences en matière de timelock, et chargé les UTXO pertinents à partir du disque si nécessaire. Le nœud peut également
transmettre rapidement le bloc à ses autres pairs, ce qui augmente considérablement la vitesse de propagation des blocs à l'échelle
du réseau et réduit ainsi le risque de blocs périmés.

Les Mempools peuvent également être utilisés pour construire un estimateur de frais indépendant. Le marché de l'espace de blocs est
une vente aux enchères payante, et la tenue d'un mempool permet aux utilisateurs d'avoir une meilleure idée de ce que les autres
proposent et des offres qui ont été retenues dans le passé.

Cependant, il n'existe pas "un mempool"---chaque nœud peut recevoir des transactions différentes. Le fait de soumettre une
transaction à un nœud ne signifie pas nécessairement qu'elle a été transmise aux mineurs. Certains utilisateurs sont frustrés par
cette incertitude et se demandent pourquoi ils ne soumettent pas leurs transactions directement aux mineurs.

Considérons un réseau Bitcoin dans lequel toutes les transactions sont envoyées directement des utilisateurs aux mineurs. Il serait
possible de censurer et de surveiller l'activité financière en demandant au petit nombre d'entités d'enregistrer les adresses IP
correspondant à chaque transaction et de refuser toute transaction correspondant à un modèle particulier. Ce type de Bitcoin peut
parfois être plus pratique, mais il serait dépourvu de quelques-unes des propriétés les plus précieuses de Bitcoin.

La résistance à la censure et la confidentialité de Bitcoin proviennent de son réseau peer-to-peer. Pour relayer une transaction,
chaque nœud peut se connecter à un ensemble anonyme de pairs, dont chacun peut être un mineur ou une personne liée à un mineur.
Cette méthode permet d'obscurcir le nœud d'où provient une transaction ainsi que le nœud qui peut être chargé de la confirmer. Une
personne souhaitant censurer des entités particulières peut cibler des mineurs, des bourses populaires ou d'autres services de
soumission centralisés, mais il serait difficile de bloquer complètement quoi que ce soit.

La disponibilité générale des transactions non confirmées permet également de minimiser le coût d'entrée pour devenir un producteur
de blocs---une personne qui n'est pas satisfaite des transactions sélectionnées (ou exclues) peut commencer à miner immédiatement.
Le fait de traiter chaque nœud comme un candidat égal pour la diffusion des transactions évite de donner à un mineur un accès
privilégié aux transactions et à leurs frais.

En résumé, un mempool est un cache extrêmement utile qui permet aux nœuds de répartir les coûts de téléchargement et de validation
des blocs dans le temps, et qui donne aux utilisateurs l'accès à une meilleure estimation des frais. Au niveau du réseau, les
mempools soutiennent un réseau distribué de transactions et de relais de blocs.
Tous ces avantages sont plus prononcés lorsque tout le monde voit toutes les transactions avant que les mineurs ne les incluent dans
les blocs - tout comme n'importe quel cache, un mempool est le plus utile lorsqu'il est "chaud" et doit être limité en taille pour
tenir dans la mémoire. La semaine prochaine, nous étudierons l'utilisation de la compatibilité incitative comme mesure permettant de
conserver les transactions les plus utiles dans les mempools.
