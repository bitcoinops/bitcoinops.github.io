<!--
  300 to 1000 words
  put title in main newsletter
  put links in this file
  for any subheads use h3 (i.e., ###)
  illustrations welcome (max width 800px)
  if uncertain about anything, just do what seems best and harding will edit
-->

La semaine dernière, nous avons indiqué que les transactions payaient des frais pour l'espace de blocs utilisé plutôt que pour le
montant transféré, et nous avons établi que les mineurs optimisent leur sélection de transactions pour maximiser les frais perçus.
Il s'ensuit que seules sont confirmées les transactions qui se trouvent en tête du pool de mémoire lorsqu'un bloc est trouvé.
Dans ce billet, nous discuterons de stratégies pratiques pour tirer le meilleur parti de nos frais. Supposons que nous disposons
d'une source décente d'estimations de taux de change---nous parlerons plus en détail de l'estimation des taux de change dans
l'article de la semaine prochaine.

Lors de l'élaboration des transactions, certaines parties de la transaction sont plus flexibles que d'autres. Chaque transaction
nécessite les champs d'en-tête, les sorties du destinataire sont déterminées par les paiements effectués, et la plupart des
transactions nécessitent une sortie de changement. L'expéditeur et le destinataire doivent privilégier les types de sorties
efficaces en termes d'espace de blocs afin de réduire le coût futur de la dépense de leurs sorties de transaction, mais c'est au
cours de la [sélection des entrées][topic coin selection] qu'il est le plus possible de modifier la composition et le poids finaux
de la transaction. Comme les transactions se concurrencent par taux [frais/poids], une transaction plus légère nécessite des frais
moins élevés pour atteindre le même taux.

Certains portefeuilles, comme le portefeuille Bitcoin Core, essaient de combiner les entrées de manière à éviter d'avoir besoin de
changer les sorties. Éviter le changement permet d'économiser le poids d'une sortie maintenant, mais aussi le coût futur de la
dépense de la sortie de changement plus tard. Malheureusement, de telles combinaisons d'entrées ne seront que rarement disponibles,
à moins que le portefeuille ne dispose d'un grand pool d'UTXO avec une grande variété de montants.

Les types de sortie modernes sont plus efficaces en termes d'espace de blocs que les types de sortie plus anciens. Par exemple,
dépenser une entrée P2TR coûte moins de 2/5e du poids d'une entrée P2PKH (essayez-le avec notre [calculateur de taille de transaction
[]). (Pour les portefeuilles à plusieurs signatures, le schéma [MuSig2][topic musig] et le protocole FROST récemment finalisés
permettent de réaliser d'énormes économies en autorisant l'encodage d'une fonctionnalité à plusieurs signatures dans ce qui
ressemble à une entrée à une seule signature. En particulier à une époque où la demande d'espace de blocs explose, un portefeuille
utilisant des types de sortie modernes se traduit à lui seul par d'importantes économies.

{:.center}
![Overview of input and output weights](/img/posts/specials/input-output-weights.png)

Les portefeuilles intelligents modifient leur stratégie de sélection en fonction du taux : lorsque le taux est élevé, ils utilisent
peu d'entrées et des types d'entrées modernes afin d'obtenir le poids le plus faible possible pour l'ensemble d'entrées. Le fait de
toujours sélectionner l'ensemble d'entrées le plus léger minimiserait localement le coût de la transaction en cours, mais réduirait
également le pool d'UTXO d'un portefeuille en petits fragments. Cela pourrait préparer l'utilisateur à effectuer plus tard des
transactions avec des ensembles d'entrées énormes à des taux élevés. Par conséquent, il est judicieux que les portefeuilles
sélectionnent également des entrées plus nombreuses et plus lourdes à des taux faibles afin de consolider de manière opportuniste
les fonds dans des sorties modernes moins nombreuses en prévision de pics de demande ultérieurs dans l'espace de blocs.

Les portefeuilles à fort volume regroupent souvent plusieurs paiements en une seule transaction afin de réduire le poids de la
transaction par paiement. Au lieu de supporter les frais généraux liés aux octets d'en-tête et à la sortie des modifications pour
chaque paiement, ils ne supportent les frais généraux qu'une seule fois, pour tous les paiements. Le simple fait de regrouper
quelques paiements permet de réduire rapidement le coût par paiement.

![Savings from payment batching with
P2WPKH](/img/posts/payment-batching/p2wpkh-batching-cases-combined.png)

Néanmoins, même si de nombreux portefeuilles estiment que les taux se trompent sur les paiements excessifs, en cas de bloc lent ou
d'augmentation des soumissions de transactions, les transactions restent parfois non confirmées plus longtemps que prévu. Dans ce
cas, l'expéditeur ou le destinataire peuvent souhaiter redéfinir les priorités de la transaction.

Les utilisateurs disposent généralement de deux outils pour accroître la priorité de leur transaction : l'enfant paie pour le parent
([CPFP][topic cpfp]) et le remplacement par des frais ([RBF][topic rbf]). Dans CPFP, un utilisateur dépense le résultat de sa
transaction pour créer une transaction enfant à haut degré de priorité. Comme décrit dans l'article de la semaine dernière, les
mineurs sont incités à choisir le parent dans le bloc afin d'inclure l'enfant riche en frais. Le CPFP est accessible à tout
utilisateur rémunéré par la transaction, de sorte que le destinataire ou l'expéditeur (s'il a créé une sortie de changement) peut
l'utiliser.

Dans le cas du RBF, l'expéditeur est l'auteur d'un remplacement de la transaction d'origine à un taux plus élevé. La transaction de
remplacement doit réutiliser au moins une entrée de la transaction originale pour garantir un conflit avec l'original et pour qu'une
seule des deux transactions puisse être incluse dans la blockchain. En général, ce remplacement inclut les paiements de la
transaction originale, mais l'expéditeur peut également rediriger les fonds dans la transaction de remplacement ou combiner les
paiements de plusieurs transactions en une seule lors du remplacement. Comme décrit dans l'article de la semaine dernière, les nœuds
évincent la transaction initiale en faveur de la transaction de remplacement, plus compatible avec les incitations.

Bien que la demande et la production d'espace de blocs soient hors de notre contrôle, il existe de nombreuses techniques que les
portefeuilles peuvent utiliser pour faire des offres d'espace de blocs de manière efficace. Les portefeuilles peuvent économiser des
frais en créant des transactions plus légères en éliminant la sortie de changement, en dépensant les sorties segwit natives et en
défragmentant leur pool UTXO dans les environnements à faible taux de feerate. Les portefeuilles qui prennent en charge CPFP et RBF
peuvent également commencer avec un taux de rafraîchissement conservateur, puis mettre à jour la priorité de la transaction à l'aide
de CPFP ou de RBF si nécessaire.

[calculateur de taille de transaction]: /en/tools/calc-size