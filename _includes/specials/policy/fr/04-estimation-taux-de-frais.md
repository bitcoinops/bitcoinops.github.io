La semaine dernière, nous avons exploré les techniques permettant de minimiser les frais payés sur une transaction donnée.
Mais quel doit être ce taux ? Idéalement, le plus bas possible pour économiser de l'argent, mais suffisamment élevé pour
garantir une place dans un bloc correspondant aux préférences temporelles de l'utilisateur.

L'objectif de l'estimation des frais (taux) est de traduire un délai de confirmation cible en un taux minimal que la
transaction devrait payer.

L'estimation des frais est compliquée par l'irrégularité de la production d'espace de bloc. Supposons qu'un utilisateur doive
payer un commerçant dans un délai d'une heure pour recevoir ses marchandises. L'utilisateur peut s'attendre à ce qu'un bloc soit
extrait toutes les 10 minutes, et donc viser un emplacement dans les 6 blocs suivants. Cependant, il est tout à fait possible
qu'il faille 45 minutes pour trouver un bloc. Les évaluateurs de frais doivent faire le lien entre l'urgence ou le délai souhaité
par l'utilisateur (quelque chose comme "Je veux que cela soit confirmé avant la fin de la journée") et l'offre d'espace
de blocs (un certain nombre de blocs). De nombreux estimateurs de frais relèvent ce défi en exprimant les objectifs de confirmation
en nombre de blocs, en plus du temps.

En l'absence d'informations sur les transactions avant leur confirmation, il est possible de construire un estimateur de frais naïf
qui utilise des données historiques sur les taux des transactions qui ont tendance à intégrer les blocs. Comme cet estimateur ne
tient pas compte des transactions en attente de confirmation dans les pools de mémoire, il deviendrait très imprécis en cas de
fluctuations inattendues de la demande d'espace de bloc et d'intervalles de bloc occasionnellement longs. Son autre faiblesse réside
dans le fait qu'il s'appuie sur des informations contrôlées entièrement par les mineurs, qui seraient en mesure de faire grimper les
taux de frais en incluant de fausses transactions à taux de frais élevé dans leurs blocs.

Heureusement, le marché de l'espace de blocs n'est pas une vente aux enchères à l'aveugle. Nous avons mentionné dans notre
[premier article][policy01] que le fait de conserver un mempool et de participer au réseau de relais de transactions de pair à pair
permet à un nœud de voir les offres des utilisateurs. L'estimateur de frais de Bitcoin Core utilise également des données
historiques pour calculer la probabilité qu'une transaction à un taux `t` soit confirmée. L'estimateur de frais de Bitcoin Core
utilise également des données historiques pour calculer la probabilité qu'une transaction à la fréquence `t` soit confirmée dans un
délai de `n` blocs, mais il suit spécifiquement la hauteur à laquelle le nœud voit une transaction pour la première fois et le
moment où elle est confirmée. Cette méthode permet de contourner les activités qui se déroulent en dehors du marché public en les
ignorant. Si les mineurs incluent dans leurs propres blocs des transactions dont le taux de confirmation est artificiellement élevé,
cet estimateur de frais n'est pas faussé car il n'utilise que les données des transactions qui ont été relayées publiquement avant
la confirmation.

Nous avons également des informations sur la manière dont les transactions sont sélectionnées pour les blocs. Dans un
[précédent article][policy02], nous avons mentionné que les nœuds simulent les politiques des mineurs afin de conserver les
transactions compatibles avec les incitations dans leurs mempools. En développant cette idée, au lieu de regarder uniquement les
données passées, nous pourrions construire un estimateur de frais qui simule ce qu'un mineur ferait. Pour déterminer le taux de
frais qu'une transaction devrait confirmer dans les `n` blocs suivants, l'estimateur de frais pourrait utiliser l'algorithme
d'assemblage de blocs pour projeter les modèles des `n` blocs suivants à partir de son mempool et calculer le taux de frais qui
battrait la (les) dernière(s) transaction(s) parvenue(s) dans le bloc `n`.

Il est clair que l'efficacité de l'approche de cet estimateur de frais dépend de la similitude entre le contenu de son mempool et
celui des mineurs, ce qui ne peut jamais être garanti. Elle ne tient pas compte non plus des transactions qu'un mineur pourrait
inclure pour des raisons extérieures, par exemple des transactions qui appartiennent au mineur ou qui ont payé des frais externes
pour être confirmées. La projection doit également tenir compte des diffusions de transactions supplémentaires entre maintenant et
le moment où les blocs projetés sont trouvés. Elle peut le faire en diminuant la taille des blocs projetés pour tenir compte des
autres transactions - mais de combien ?

Cette question souligne une fois de plus l'utilité des données historiques. Un modèle intelligent pourrait être en mesure
d'intégrer des modèles d'activité et de tenir compte d'événements externes qui influencent les taux de frais, tels que les heures
d'ouverture habituelles, la consolidation UTXO programmée d'une entreprise et l'activité en réponse aux changements du prix
d'échange du bitcoin. Le problème de la prévision de la demande d'espace de blocs reste mûr pour l'exploration, et il est probable
qu'il y aura toujours de la place pour l'innovation.

L'estimation des frais est un problème difficile aux multiples facettes. Une mauvaise estimation des frais peut entraîner un
gaspillage de fonds par un paiement excessif des frais, ajouter des frictions à l'utilisation de Bitcoin pour les paiements et
faire perdre de l'argent aux utilisateurs de L2 en manquant une fenêtre dans laquelle une UTXO bloquée dans le temps disposait
d'un autre chemin de dépense. Une bonne estimation des frais permet aux utilisateurs de communiquer clairement et précisément
l'urgence de la transaction aux mineurs, et [CPFP][topic cpfp] et [RBF][topic rbf] permettent aux utilisateurs de mettre à jour
leurs offres si les estimations initiales sont inférieures à la réalité. Les politiques de mempool compatibles avec les incitations,
associées à des outils d'estimation des frais bien conçus et aux [wallets] [policy03], permettent aux utilisateurs de participer à
une vente aux enchères publique efficace pour l'espace des blocs.

Les estimateurs de frais ne renvoient généralement jamais moins que 1sat/vB, quelle que soit la durée de l'horizon temporel ou le
nombre de transactions en attente de confirmation. Beaucoup considèrent que 1sat/vB est le taux plancher de facto dans le réseau
Bitcoin, en raison du fait que la plupart des nœuds du réseau (y compris les mineurs) [n'acceptent jamais][topic default minimum
transaction relay feerates] tout ce qui est en dessous de ce taux, indépendamment du fait que leurs mempools soient vides. Le billet
de la semaine prochaine explorera cette politique des nœuds et une autre motivation pour l'utilisation du taux de frais dans le
relais de transaction : la protection contre l'épuisement des ressources.

[policy01]: /fr/newsletters/2023/05/17/#en-attente-de-confirmation-1--pourquoi-avons-nous-un-mempool-
[policy02]: /fr/newsletters/2023/05/24/#en-attente-de-confirmation-2--mesures-dincitation
[policy03]: /fr/newsletters/2023/05/31/#attente-de-la-confirmation-3--enchères-pour-lachat-dun-bloc-despace
