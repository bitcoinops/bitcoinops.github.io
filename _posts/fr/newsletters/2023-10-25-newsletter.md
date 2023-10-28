---
title: 'Bulletin Hebdomadaire Bitcoin Optech #274'
permalink: /fr/newsletters/2023/10/25/
name: 2023-10-25-newsletter-fr
slug: 2023-10-25-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine décrit l'attaque de remplacement cyclique contre les HTLC utilisés dans LN et d'autres systèmes, examine
les mesures d'atténuation déployées pour contrer l'attaque et résume plusieurs propositions de mesures d'atténuation supplémentaires.
On y décrit également un bogue notable affectant un RPC de Bitcoin Core, des recherches sur les covenants avec des modifications
minimales du script Bitcoin, et une proposition de BIP pour un opcode `OP_CAT`. On y trouve également notre section mensuelle
habituelle concernant les questions et réponses populaires sur le Bitcoin Stack Exchange

{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

## Nouvelles

- **Vulnérabilité de remplacement cyclique contre les HTLC :** Comme mentionné brièvement dans [la newsletter de la semaine
  dernière][news274 cycle], Antoine Riard a [publié][riard cycle1] sur les listes de diffusion Bitcoin-Dev et Lightning-Dev une
  vulnérabilité [divulguée de manière responsable][topic responsible disclosures] affectant toutes les implémentations LN. Depuis
  la divulgation, les implémentations ont été mises à jour pour inclure des mesures d'atténuation contre l'attaque et nous
  recommandons vivement de mettre à jour vers la dernière version de votre logiciel LN préféré. Seuls les nœuds utilisés pour
  transférer des paiements sont concernés ; les utilisateurs qui n'utilisent leurs canaux que pour initier et recevoir des paiements
  ne sont pas affectés.

  Nous avons organisé notre description de cette histoire en trois parties distinctes : une description de la vulnérabilité
  (cette partie), une description des mesures d'atténuation déployées jusqu'à présent par différentes implémentations LN, et un
  résumé des mesures d'atténuation supplémentaires et des solutions proposées sur la liste de diffusion.

  Pour comprendre le contexte, il est possible d'utiliser [le remplacement de transaction][topic rbf] pour supprimer une ou plusieurs
  entrées d'une transaction multi-entrées des mempools des nœuds. Prenons un exemple simple, légèrement différent de la description
  originale de Riard : Mallory diffuse une transaction avec deux entrées, qui dépensent les sorties _A_ et _B_. Elle remplace ensuite
  cette transaction par une version alternative à une seule entrée qui ne dépense que la sortie _B_. Après ce remplacement,
  l'entrée _A_---et toutes les données qui y sont incluses---ont été supprimées de tous les mempools des nœuds qui ont traité le
  remplacement.

  Bien qu'il ne soit pas sûr pour un portefeuille classique de faire cela[^rbf-warning], c'est un comportement que Mallory peut
  exploiter si elle souhaite supprimer une entrée des mempools des nœuds.

  En particulier, si Mallory partage le contrôle d'une sortie avec Bob, elle peut attendre qu'il dépense la sortie, remplacer sa
  dépense par une dépense de sa part qui contient une entrée supplémentaire, puis remplacer sa dépense par une transaction qui ne
  dépense plus leur sortie commune. C'est un _cycle de remplacement_. Les mineurs continueront à collecter les frais de transaction
  de Mallory, mais il y a une forte probabilité que les dépenses de Bob et de Mallory de la sortie ne soient confirmées nulle part
  près du moment où Bob diffuse sa dépense.

  Cela est important dans le cas de LN et de plusieurs autres protocoles car certaines transactions doivent avoir lieu dans des
  fenêtres de temps spécifiques pour garantir que les utilisateurs qui transfèrent des paiements ne perdent pas d'argent. Par exemple,
  Mallory utilise l'un de ses nœuds (que nous appellerons _MalloryA_) pour transférer un paiement à Bob, et Bob transfère ce paiement
  à un autre nœud de Mallory (_MalloryB_). MalloryB est censée soit donner à Bob un _préimage_ qui lui permet d'accepter le paiement
  transféré de MalloryA, soit MalloryB est censée annuler (révoquer) le paiement transféré qu'elle a reçu de Bob avant une certaine
  heure. Au lieu de cela, MalloryB ne fait rien à l'heure prévue et Bob est contraint de fermer le canal et de diffuser une
  transaction qui dépense le paiement transféré pour lui-même. Cette dépense devrait être confirmée rapidement, ce qui permet à Bob
  d'annuler (révoquer) la dépense qu'il a reçue de MalloryA, ce qui ramène les soldes de chacun aux montants qu'ils étaient avant la
  tentative de transfert du paiement (à l'exception des frais de transaction payés pour fermer et régler le canal Bob-MalloryB).

  Alternativement, lorsque Bob ferme le canal et tente de dépenser le paiement transféré pour lui-même, MalloryB peut remplacer sa
  dépense par une dépense contenant le préimage. Si cette transaction est confirmée rapidement, Bob apprendrait le préimage et
  serait en mesure de réclamer le paiement transféré de MalloryA, ce qui rendrait Bob heureux.

  Cependant, si MalloryB remplace la dépense de Bob par une dépense contenant le préimage, puis retire rapidement cette entrée, il
  est peu probable que la dépense de Bob ou le préimage de MalloryB apparaissent dans la chaîne de blocs. Cela empêche Bob de
  récupérer son argent auprès de MalloryB. Sans le préimage, le protocole LN sans confiance empêche Bob de pouvoir conserver le
  paiement transféré de MalloryA, il lui accorde donc un remboursement. À ce stade, MalloryB fait confirmer sa dépense contenant
  le préimage, ce qui lui permet de réclamer le paiement transféré de Bob. Cela signifie que si un montant _x_ a été transféré,
  MalloryA ne paie rien, MalloryB reçoit _x_, et Bob perd _x_ (sans tenir compte des divers frais).

  Pour que l'attaque soit rentable, MalloryB doit partager un canal avec Bob, mais MalloryA peut se trouver n'importe où le long du
  chemin de transfert vers Bob. Par exemple :

          MalloryA -> X -> Y -> Z -> Bob -> MalloryB

  Le remplacement cyclique a des conséquences similaires pour les nœuds LN aux attaques d'[épinglage des
  transactions][topic transaction pinning] existantes. Cependant, des techniques telles que [le relai de transaction v3][topic v3
  transaction relay] qui ont été conçues pour empêcher le pinning pour LN et des protocoles similaires ne permettent pas d'empêcher
  le remplacement cyclique.

- **Mesures d'atténuation déployées dans les nœuds LN pour le remplacement cyclique** : comme [décrit][riard cycle1] par Antoine Riard,
  plusieurs mesures d'atténuation ont été déployées par les implémentations LN.

     - **Rebroadcast fréquent** : après que le mempool d'un nœud relais ait remplacé la dépense de Bob par la dépense de Mallory,
         puis ait supprimé l'entrée de Mallory lors de son deuxième remplacement, ce nœud relais sera immédiatement prêt à accepter
         à nouveau la dépense de Bob. Tout ce que Bob a à faire est de rebroadcast sa dépense, ce qui ne lui coûte rien de plus que
         les frais de transaction qu'il était déjà prêt à payer.

         Avant la divulgation privée du remplacement cyclique, les implémentations LN ne rebroadcastaient leurs transactions
         que rarement (une fois par bloc ou moins). Il y a normalement un [coût de confidentialité][topic transaction origin privacy]
         à la diffusion et à la retransmission des transactions---cela pourrait faciliter aux tiers d'associer les activités LN sur
         la chaîne de Bob à son adresse IP---bien que peu de nœuds de transfert LN publics essaient actuellement de cacher cela.
         Maintenant, Core Lightning, Eclair, LDK et LND retransmettront tous plus fréquemment.

         Après chaque fois que Bob retransmet, Mallory peut utiliser la même technique pour remplacer à nouveau sa transaction.
         Cependant, les règles de remplacement BIP125 obligeront Mallory à payer des frais de transaction supplémentaires pour
         chacun de ses remplacements, ce qui signifie que chaque retransmission de Bob réduit la rentabilité pour Mallory d'une
         attaque réussie.

         Cela suggère une formule approximative pour le montant maximal d'un HTLC qu'un nœud devrait accepter. Si le coût que
         l'attaquant devra payer pour chaque cycle de remplacement est _x_, le nombre de blocs dont dispose le défenseur est _y_,
         et le nombre de retransmissions effectives que le défenseur effectuera par bloc en moyenne est _z_, un HTLC est
         probablement raisonnablement sécurisé jusqu'à une valeur légèrement inférieure à `x*y*z`.

     - **Délais d'expiration CLTV plus longs:** lorsque Bob accepte un HTLC de MalloryA, il accepte de lui permettre de réclamer un
         remboursement sur la chaîne après un certain nombre de blocs (disons 200 blocs). Lorsque Bob propose un HTLC équivalent à
         MalloryB, elle lui permet de réclamer un remboursement après un nombre plus petit de blocs (disons 100 blocs). Ces
         conditions d'expiration sont écrites à l'aide de l'opcode `OP_CHECKLOCKTIMEVERIFY` (CLTV), donc l'écart entre eux est appelé
         le _delta d'expiration CLTV_.

         Plus un delta d'expiration CLTV est long, plus le dépensier initial d'un paiement devra attendre pour récupérer ses fonds
         en cas d'échec du paiement, donc les dépensiers préfèrent acheminer les paiements à travers des canaux avec des deltas plus
         courts. Cependant, il est également vrai que plus un delta est long, plus un nœud de transfert comme Bob a de temps pour
         réagir aux problèmes tels que [l'épinglage de transaction][topic transaction pinning] et les fermetures massives de canaux.
         Ces intérêts concurrents ont conduit à des ajustements fréquents du delta par défaut dans les logiciels LN (voir les bulletins
         [#40][news40 delta], [#95][news95 delta], [#109][news109 delta], [#112][news112 delta], [#142][news142 delta],
         [#248][news248 delta] et [#255][news255 delta]).

         Dans le cas du cycle de remplacement, un delta CLTV plus long donne à Bob plus de cycles de retransmission, ce qui augmente
         le coût de l'attaque selon la formule approximative mentionnée dans la description de la mitigation de la retransmission.

         De plus, chaque fois que la dépense de retransmission de Bob se trouve dans le mempool d'un mineur, il y a une chance que
         le mineur l'inclue dans un modèle de bloc qui est miné, ce qui entraîne l'échec de l'attaque. Le remplacement initial de
         Mallory avec son préimage pourrait également être extrait avant qu'elle n'ait la possibilité de le remplacer davantage,
         ce qui entraînerait également l'échec de l'attaque. Si chaque cycle entraîne ces deux transactions passant un certain
         temps dans les mempools des mineurs, chaque retransmission de Bob multiplie ce temps. La durée d'expiration du CLTV
         multiplie encore ce temps.

         Par exemple, même si ces transactions ne passent que 1% du temps par bloc dans le mempool moyen du mineur, il y a environ
         50% de chances que l'attaque échoue avec un delta d'expiration du CLTV de seulement 70 blocs. En utilisant les valeurs par
         défaut actuelles du delta d'expiration du CLTV pour différentes implémentations de LN répertoriées dans l'e-mail de Riard,
         le graphique suivant montre la probabilité que l'attaque de Mallory échoue (et qu'elle perde tout l'argent qu'elle a dépensé
         en remplacements) en supposant que les dépenses HTLC attendues se trouvent dans les mempools des mineurs pendant 0,1% du
         temps, 1% du temps ou 5% du temps. Pour référence, compte tenu d'un temps moyen de 600 secondes entre les blocs, ces
         pourcentages correspondent à seulement 0,6 seconde, 6 secondes et 30 secondes sur chaque période de 10 minutes.

         ![Graphique de la probabilité que l'attaque échoue dans x blocs](/img/posts/2023-10-cltv-expiry-delta-cycling.png)

     - **Analyse du mempool:** Les HTLC ont été conçus pour inciter Mallory à faire confirmer son préimage dans la chaîne de blocs
         avant que Bob puisse réclamer son remboursement. C'est pratique pour Bob : la chaîne de blocs est largement disponible et de taille limitée, donc Bob peut facilement trouver n'importe quel préimage qui l'affecte. Si ce système fonctionnait comme prévu, Bob pourrait obtenir toutes les informations dont il a besoin pour utiliser LN de manière fiable à partir de la chaîne de blocs.

         Malheureusement, le remplacement cyclique signifie que Mallory peut ne plus être incitée à confirmer sa transaction avant que
         le remboursement de Bob puisse être réclamé. Cependant, pour initier un cycle de remplacement, Mallory doit toujours brièvement
         divulguer son préimage aux mempools des mineurs afin de remplacer la dépense de Bob. Si Bob exécute un nœud complet de relais,
         la transaction de préimage de Mallory peut se propager à travers le réseau jusqu'au nœud de Bob. Si Bob détecte ensuite le
         préimage avant qu'il ne soit censé donner un remboursement à Mallory, l'attaque est déjouée et Mallory perd tout l'argent
         qu'elle a dépensé pour la tenter.

         L'analyse du mempool n'est pas parfaite---il n'y a aucune garantie que la transaction de remplacement de Mallory se propagera
         jusqu'à Bob. Cependant, plus Bob rebroadcaste sa transaction (voir _mitigation de rebroadcast_) et plus Mallory a besoin de
         garder son préimage caché à Bob (voir _mitigation du delta d'expiration du CLTV_), plus il est probable qu'une des
         transactions de préimage parviendra à entrer dans le mempool de Bob à temps pour déjouer l'attaque.

         Eclair et LND implémentent actuellement l'analyse du mempool lorsqu'ils sont utilisés comme nœuds de transfert.

     - **Discussion sur l'efficacité des mesures d'atténuation :** L'annonce initiale de Riard disait : "Je pense que les attaques
         de remplacement cyclique sont toujours réalisables pour les attaquants avancés". Matt Corallo a [écrit][corallo cycle1] :
         "les mesures d'atténuation déployées ne sont pas censées résoudre ce problème ; on peut même se demander si elles apportent
         autre chose qu'un communiqué de relations publiques". Olaoluwa Osuntokun a soutenu : "[à mon avis], il s'agit d'une attaque
         plutôt fragile, qui nécessite : une configuration par nœud, une synchronisation et une exécution extrêmement précises,
         une superposition non confirmante de toutes les transactions et une propagation instantanée à travers l'ensemble du réseau".
         
             Nous chez Optech pensons qu'il est important de rappeler que cette attaque ne concerne que les nœuds de transfert. Un nœud
             de transfert est un portefeuille Bitcoin connecté à un service Internet toujours actif---un type de déploiement qui est
             constamment vulnérable au vol de tous ses fonds. Toute personne évaluant l'effet du remplacement cyclique sur le profil
             de risque de l'exploitation d'un nœud de transfert LN devrait le considérer dans le contexte du risque déjà toléré.
             Bien sûr, il vaut la peine de chercher d'autres moyens de réduire ce risque, comme discuté dans notre prochaine actualité.

- **Propositions d'atténuation supplémentaires pour le remplacement cyclique** : à ce jour, plus de 40 publications distinctes ont été
  faites sur les listes de diffusion Bitcoin-Dev et Lightning-Dev en réponse à la divulgation de l'attaque de remplacement cyclique.
  Les réponses suggérées comprenaient les éléments suivants :

     - **Augmentation des frais jusqu'à la terre brûlée** : Le document d'Antoine Riard sur l'attaque et les publications sur les
         listes de diffusion de [Ziggie][ziggie cycle] et [Matt Morehouse][morehouse cycle] suggèrent que, au lieu de simplement
         rebroadcaster sa dépense de remboursement, le défenseur (par exemple, Bob) commence à diffuser des dépenses alternatives
         conflictuelles qui paient des frais de plus en plus élevés à mesure que la date limite approche avec l'attaquant en amont
         (par exemple, MalloryA).

         Les règles BIP125 exigent que l'attaquant en aval (par exemple, MalloryB) paie des frais encore plus élevés pour chacun de
         ses remplacements de la dépense de Bob, ce qui signifie que Bob peut réduire davantage la rentabilité de l'attaque si Mallory
         réussit. Considérez notre formule approximative `x*y*z` décrite dans la section _atténuation du rebroadcasting_. Si le coût
         de _x_ est augmenté pour certaines des rediffusions, le coût global pour l'attaquant augmente et la valeur maximale sûre
         d'un HTLC est plus élevée.

         Riard soutient dans son document que les coûts peuvent ne pas être symétriques, en particulier pendant les périodes où les
         frais typiques augmentent et où l'attaquant peut parvenir à faire expulser certaines de ses transactions des pools de
         mémoire des mineurs. Sur la liste de diffusion, il [soutient également][riard cycle2] qu'un attaquant peut étendre son
         attaque à plusieurs victimes en utilisant une forme de [regroupement des paiements][topic payment batching], augmentant
         légèrement son efficacité.

         Matt Corallo [remarque][corallo cycle2] le principal inconvénient de cette approche par rapport au simple rebroadcasting :
         même si Bob bat l'attaquant, Bob perd une partie de la valeur HTLC (ou potentiellement la totalité). Théoriquement, un
         attaquant ne défierait pas un défenseur qu'il pense suivre une politique de destruction mutuelle assurée, donc Bob n'aurait
         jamais réellement besoin de payer des frais de plus en plus élevés. Si cela serait vrai en pratique sur le réseau Bitcoin
         reste à prouver.

     - **Nouvel essai automatique des transactions passées** : Corallo [a suggéré][corallo cycle1] que "la seule solution à ce problème
         sera lorsque les mineurs conserveront un historique des transactions qu'ils ont vues et les réessayeront après [...] une
         attaque de ce type". Bastien Teinturier [a répondu][teinturier cycle] : "Je suis d'accord avec Matt, cependant, il est
         probable qu'un travail plus fondamental doive être effectué au niveau de la couche bitcoin pour permettre aux protocoles
         L2 d'être plus robustes contre cette classe d'attaques." Riard a également déclaré quelque chose de similaire, "une solution
         durable ne peut se produire qu'au niveau de la couche de base, par exemple en ajoutant un historique intensif de toutes
         les transactions observées".

     - **Augmentation des frais pré-signés:** Peter Todd a soutenu que, "la bonne façon de faire des transactions pré-signées est de
         pré-signer suffisamment de transactions *différentes* pour couvrir tous les besoins raisonnables d'augmentation des frais.
         [...] Il n'y a aucune raison pour que les transactions B->C restent bloquées." (Emphase dans l'original.)

             Cela pourrait fonctionner comme ceci : pour le HTLC entre Bob et MalloryB, Bob donne à MalloryB dix signatures différentes
             pour la même dépense de préimage à des taux de frais différents. Notez que cela ne nécessite pas que MalloryB divulgue
             le préimage à Bob au moment de la signature. En même temps, MalloryB donne à Bob dix signatures différentes pour la même
             dépense de remboursement à des taux de frais différents. Cela peut être fait avant que le remboursement puisse être
             diffusé. Les taux de frais utilisés pourraient être (en sats/vbyte) : 1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024,
             ce qui devrait couvrir tout pour l'avenir prévisible.

             Si la dépense de préimage de MalloryB était pré-signée, la seule modification qu'elle pourrait apporter serait de passer
             d'un taux de frais à un taux de frais plus élevé. Elle ne pourrait pas ajouter de nouvelles entrées à la dépense de
             préimage, et sans cette capacité, elle serait incapable d'initier le cycle de remplacement.

     - **OP_EXPIRE:** dans un fil de discussion séparé, mais en citant le fil de discussion sur les cycles de remplacement, Peter Todd
         a proposé plusieurs modifications de consensus pour permettre un opcode `OP_EXPIRE` qui rendrait une transaction invalide
         pour l'inclusion après un bloc spécifié si le script de la transaction exécute `OP_EXPIRE`. Cela peut être utilisé pour
         rendre la condition de préimage de Mallory d'un HTLC utilisable uniquement avant que la condition de remboursement de Bob
         ne puisse être dépensée. Cela empêche Mallory de pouvoir remplacer la dépense de remboursement de Bob, rendant impossible
         pour Mallory d'exécuter une attaque de cycle de remplacement. `OP_EXPIRE` peut également résoudre certaines [attaques de
         blocage de transaction][topic transaction pinning] contre les HTLC.

             Le principal inconvénient de `OP_EXPIRE` est qu'il nécessite des modifications du consensus pour être activé et des
             modifications de la politique de relais et de la mémoire tampon pour éviter certains problèmes, tels que son utilisation
             pour gaspiller la bande passante des nœuds.

             Une [réponse][harding expire] à la proposition a suggéré un moyen plus faible d'atteindre certains des mêmes objectifs
             que `OP_EXPIRE`, mais sans nécessiter de modifications du consensus ou de la politique de relais. Cependant, Peter Todd
             a soutenu que cela n'empêche pas l'attaque de cycle de remplacement.

     Optech prévoit de poursuivre la discussion sur le sujet et résumera tout développement notable dans les futures newsletters.

- **Résumé du hachage du jeu de sorties UTXO de Bitcoin:** Fabian Jahr a publié sur la liste de diffusion Bitcoin-Dev pour annoncer
  la découverte d'un bogue dans le calcul du hachage de Bitcoin Core de l'ensemble UTXO actuel. Le hachage ne s'engageait pas à la
  hauteur et aux informations de coinbase pour chaque UTXO, des informations nécessaires pour appliquer la règle de maturité de
  coinbase de 100 blocs et les verrouillages temporels relatifs [BIP68][]. Toutes ces informations sont toujours présentes dans la
  base de données d'un nœud qui a été synchronisé à partir de zéro (tous les nœuds Bitcoin Core actuels) et elles sont toujours
  utilisées pour l'application, donc ce bogue n'affecte aucun logiciel publié connu. Cependant, la fonction expérimentale
  [assumeUTXO][topic assumeutxo] prévue pour la prochaine version majeure de Bitcoin Core permettra aux utilisateurs de partager
  leurs bases de données UTXO les uns avec les autres. L'engagement incomplet signifie qu'une base de données modifiée pourrait
  avoir le même hachage qu'une base de données vérifiée, ouvrant potentiellement une fenêtre étroite pour une attaque contre les
  utilisateurs d'assumeUTXO.

  Si vous connaissez un logiciel qui utilise le champ `hash_serialized_2`, veuillez en informer ses auteurs du problème et les
  encourager à lire l'e-mail de Jahr sur les modifications apportées pour la prochaine version majeure de Bitcoin Core afin de
  résoudre le bogue.

- **Recherche sur les conventions génériques avec des modifications minimales du langage Script :**
  Rusty Russell a [publié][russell scripts] sur la liste de diffusion Bitcoin-Dev un lien vers [une recherche][russell scripts blog]
  qu'il a réalisée sur l'utilisation de quelques nouveaux opcodes simples pour permettre à un script en cours d'exécution dans une
  transaction d'inspecter les scripts de sortie payés dans cette même transaction, une forme puissante d'_introspection_. La capacité
  à effectuer une introspection des scripts de sortie (et des engagements qu'ils font) permet la mise en œuvre de [conventions][topic
  covenants]. Certaines de ses conclusions que nous avons jugées importantes comprenaient :

     - *Simplicité :* avec trois nouveaux opcodes, plus l'un des plusieurs opcodes de convention précédemment proposés (comme
         [OP_TX][news187 op_tx]), un seul script de sortie et son engagement [taproot][topic taproot] peuvent être entièrement
         introspectés. Chacun des nouveaux opcodes est simple à comprendre et semble simple à mettre en œuvre.

     - *Assez concis :* l'exemple de Russell utilise environ 30 vbytes pour effectuer une introspection raisonnable (la taille du
          script à appliquer s'ajouterait à ces vbytes).

     - *Les changements OP_SUCCESS seraient bénéfiques :* la spécification [BIP342][] de [tapscript][topic tapscript] spécifie
         plusieurs opcodes `OP_SUCCESSx` qui font en sorte que tout script les incluant réussisse toujours, permettant aux futures
         forks logiciels d'attacher des conditions aux opcodes (les faisant fonctionner comme des opcodes réguliers). Cependant,
         ce comportement rend dangereux l'utilisation de l'introspection avec une convention qui permet d'inclure des parties d'un
         script arbitraire. Par exemple, Alice pourrait vouloir créer une convention qui lui permet de dépenser ses fonds vers une
         adresse arbitraire si elle dépense d'abord ses fonds dans une transaction de notification de [coffre-fort][topic vaults]
         et attend un certain nombre de blocs pour permettre à une transaction de gel de bloquer la dépense. Cependant, si l'adresse
         arbitraire inclut un opcode `OP_SUCCESSx`, n'importe qui pourra voler son argent. Russell suggère deux solutions possibles
         à ce problème dans sa recherche.

  La recherche a suscité quelques discussions et Russell a indiqué qu'il travaillait sur un article de suivi concernant
  l'introspection des montants de sortie.

- **Proposition de BIP pour OP_CAT:** Ethan Heilman a [posté][heilman cat] sur la liste de diffusion Bitcoin-Dev une [proposition de
  BIP][op_cat bip] visant à ajouter un opcode [OP_CAT][] à tapscript. L'opcode prendrait deux éléments en haut de la pile et les
  concaténerait en un seul élément. Il fournit plusieurs descriptions des capacités que `OP_CAT` ajouterait à Script. Son
  implémentation de référence proposée ne fait que 13 lignes de code (espaces blancs exclus).

     La proposition a suscité une quantité modérée de discussions, principalement axées sur les limites de tapscript qui pourraient
     affecter l'utilité et les coûts dans le pire des cas de l'activation de `OP_CAT` (et si certaines de ces limites devraient être
     modifiées).

## Sélection de Q&R du Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] est l'un des premiers endroits où les contributeurs
d'Optech cherchent des réponses à leurs questions---ou lorsque nous avons quelques moments
libres pour aider les utilisateurs curieux ou confus. Dans cette rubrique mensuelle, nous
mettons en avant certaines des questions et réponses les plus appréciées, postées depuis
notre dernière mise à jour.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}

- [Comment fonctionne l'algorithme de sélection de pièces Branch and Bound ?]({{bse}}119919)
  Murch résume son travail de recherche sur l'[algorithme Branch and Bound][branch
  and bound paper] pour la [sélection de pièces][topic coin selection] qui "recherche l'ensemble d'entrées le moins gaspilleur
  produisant une transaction sans changement".

- [Pourquoi chaque transaction est-elle diffusée deux fois dans le réseau Bitcoin ?]({{bse}}119819)
  Antoine Poinsot répond à un ancien message de la liste de diffusion de Satoshi qui indiquait "Chaque transaction doit être
  diffusée deux fois". Poinsot précise que bien qu'à cette époque une transaction était diffusée deux fois (une fois lors de la
  transmission de la transaction et une fois lors de la transmission du bloc), l'ajout ultérieur de [BIP152][] [compact block
  relay][topic compact block relay] signifie que les données de transaction ne doivent être diffusées qu'une seule fois à un pair.

- [Pourquoi les opcodes OP_MUL et OP_DIV sont-ils désactivés dans Bitcoin ?]({{bse}}119785)
  Antoine Poinsot souligne que les opcodes `OP_MUL` et `OP_DIV` ont probablement été désactivés, en plus d'[autres opcodes][github
  disable opcodes], en raison des bugs ["1 RETURN"]({{bse}}38037) et [OP_LSHIFT crash][CVE-2010-5137] découverts dans les semaines
  précédentes.

- [Pourquoi les hashSequence et hashPrevouts sont-ils calculés séparément ?]({{bse}}119832)
  Pieter Wuille explique que, en divisant les données de hachage de transaction à signer en sorties précédentes et en séquences,
  ces valeurs de hachage peuvent être utilisées une fois pour toute la transaction impliquant tous les types de sighashes.

- [Pourquoi Miniscript ajoute-t-il une vérification de taille supplémentaire pour les comparaisons de préimages de
  hachage ?]({{bse}}119892)
  Antoine Poinsot note que les préimages de hachage sont limitées en taille dans [miniscript][topic miniscript] pour éviter les
  transactions Bitcoin non standard, éviter les échanges atomiques inter-chaînes invalides pour le consensus et garantir que les
  coûts des témoins peuvent être calculés avec précision.

- [Comment le frais du prochain bloc peut-il être inférieur au taux de purge de la mempool ?]({{bse}}120015)
  L'utilisateur Steven fait référence aux tableaux de bord de mempool.space montrant une purge par défaut de la mempool avec des
  transactions à 1,51 sat/vb tout en indiquant une estimation du prochain bloc contenant des transactions à 1,49 sat/vb. Glozow
  explique probablement que cela est dû à une mempool pleine entraînant l'éviction d'une transaction qui a augmenté le taux de
  frais minimum de la mempool du nœud (par `-incrementalRelayFee`), mais qui a laissé certaines transactions à des taux de frais
  inférieurs dans la mempool qui n'avaient pas besoin d'être évacuées pour rester dans la taille maximale de la mempool.

  Elle mentionne également l'asymétrie entre le [score des ancêtres][waiting for confirmation 2] pour la sélection du modèle de bloc
  et le score des descendants pour l'éviction de la mempool comme une autre explication possible et renvoie à un [mempool de
  cluster][cluster mempool]-[problème][Bitcoin Core #27677] expliquant l'asymétrie et une nouvelle approche potentielle.

## Mises à jour et versions candidates

*Nouvelles versions et versions candidates pour les principaux projets d’infrastructure Bitcoin.
 Veuillez envisager de passer aux nouvelles versions ou d’aider à tester les versions candidates.*

- [Bitcoin Core 25.1][] est une version de maintenance contenant principalement des corrections de bugs. C'est la version recommandée
  actuelle de Bitcoin Core.

- [Bitcoin Core 24.2][] est une version de maintenance contenant principalement des corrections de bugs. Elle est recommandée pour
  toute personne utilisant encore la version 24.0 ou 24.1 et qui est incapable ou refuse de passer à la version 25.1 pour le moment.

- [Bitcoin Core 26.0rc1][] est un candidat à la version suivante de la principale implémentation de nœud complet. Les binaires de test
  vérifiés n'ont pas encore été publiés au moment de la rédaction de cet article, bien que nous nous attendions à ce qu'ils soient
  publiés à l'URL précédente peu de temps après la publication de la lettre d'information. Les précédents candidats aux versions
  majeures ont eu un guide de test sur le [wiki des développeurs de Bitcoin Core][] et une réunion du [Bitcoin Core PR Review Club][]
  dédiée aux tests. Nous encourageons les lecteurs intéressés à vérifier périodiquement si ces ressources deviennent disponibles pour
  le nouveau candidat à la version.

## Changements notables dans le code et la documentation

_En raison du volume d'actualités cette semaine et d'autres contraintes sur le temps de notre rédacteur principal, nous n'avons pas
pu passer en revue les modifications du code de la semaine dernière. Nous les inclurons dans la lettre d'information de la semaine
prochaine. Nous nous excusons pour le retard._

## Notes de bas de page

[^rbf-warning]:
    L'attaque du cycle de remplacement décrite ici est basée sur une transaction de remplacement comprenant moins d'inputs que la
    transaction originale qu'elle remplace. C'est un comportement que les auteurs de portefeuilles sont généralement avertis d'éviter.
    Par exemple, le livre _Mastering Bitcoin, 3rd edition_ dit :

    > Soyez très prudent lorsque vous créez plus d'une version de remplacement de la même transaction. Vous devez vous assurer que
    > toutes les versions des transactions entrent en conflit les unes avec les autres. Si elles ne sont pas toutes en conflit, il est
    > possible que plusieurs transactions distinctes soient confirmées, ce qui vous amènerait à payer en trop les destinataires.
    > Par exemple :
    >
    > - La version 0 de la transaction inclut l'input A.
    >
    > - La version 1 de la transaction inclut les inputs A et B (par exemple, vous avez dû ajouter l'input B pour payer les frais
    >   supplémentaires).
    >
    > - La version 2 de la transaction inclut les inputs B et C (par exemple, vous avez dû
    >   ajouter l'entrée C pour payer les frais supplémentaires, mais C était suffisamment grande pour que vous n'ayez plus besoin
    >   de l'entrée A).
    >
    > Dans le scénario ci-dessus, tout mineur qui a enregistré la version 0 de la transaction pourra confirmer à la fois cette version
    > et la version 2 de la transaction. Si les deux versions paient les mêmes destinataires, ils seront payés deux fois (et le mineur
    > recevra des frais de transaction provenant de deux transactions distinctes).
    >
    > Une méthode simple pour éviter ce problème est de s'assurer que la transaction de remplacement inclut toujours toutes les
    > mêmes entrées que la version précédente de la transaction.

{% include references.md %}
{% include linkers/issues.md v=2 issues="27677" %}
[news274 cycle]: /fr/newsletters/2023/10/18/#divulgation-de-securite-concernant-ln
[riard cycle1]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-October/021999.html
[corallo cycle1]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-October/022015.html
[osuntokun cycle1]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-October/022044.html
[riard cycle paper]: https://github.com/ariard/mempool-research/blob/2023-10-replacement-paper/replacement-cycling.pdf
[ziggie cycle]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-October/022005.html
[morehouse cycle]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-October/022024.html
[riard cycle2]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-October/022029.html
[corallo cycle2]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-October/022025.html
[teinturier cycle]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-October/022022.html
[riard cycle3]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-October/022032.html
[todd cycle1]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-October/022033.html
[todd expire1]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-October/022042.html
[harding expire]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-October/022050.html
[todd expire2]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-October/022051.html
[hash_serialized_2]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-October/022038.html
[russell scripts]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-October/022031.html
[russell scripts blog]: https://rusty.ozlabs.org/2023/10/20/examining-scriptpubkey-in-script.html
[news187 op_tx]: /en/newsletters/2022/02/16/#simplified-alternative-to-op-txhash
[heilman cat]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-October/022049.html
[op_cat bip]: https://github.com/EthanHeilman/op_cat_draft/blob/main/cat.mediawiki
[jahr hash_serialized_2]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-October/022038.html
[Bitcoin Core 25.1]: https://bitcoincore.org/bin/bitcoin-core-25.1/
[Bitcoin Core 24.2]: https://bitcoincore.org/bin/bitcoin-core-24.2/
[Bitcoin Core 26.0rc1]: https://bitcoincore.org/bin/bitcoin-core-26.0/
[news40 delta]: /en/newsletters/2019/04/02/#lnd-2759
[news95 delta]: /en/newsletters/2020/04/29/#new-attack-against-ln-payment-atomicity
[news109 delta]: /en/newsletters/2020/08/05/#lnd-4488
[news112 delta]: /en/newsletters/2020/08/26/#bolts-785
[news142 delta]: /en/newsletters/2021/03/31/#rust-lightning-849
[news248 delta]: /fr/newsletters/2023/04/26/#lnd-v0-16-1-beta
[news255 delta]: /fr/newsletters/2023/06/14/#eclair-2677
[bitcoin core developer wiki]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki
[bitcoin core pr review club]: https://bitcoincore.reviews/#upcoming-meetings
[branch and bound paper]: https://murch.one/erhardt2016coinselection.pdf
[github disable opcodes]: https://github.com/bitcoin/bitcoin/commit/4bd188c4383d6e614e18f79dc337fbabe8464c82#diff-27496895958ca30c47bbb873299a2ad7a7ea1003a9faa96b317250e3b7aa1fefR94
[CVE-2010-5137]: https://en.bitcoin.it/wiki/Common_Vulnerabilities_and_Exposures#CVE-2010-5137
[waiting for confirmation 2]: /fr/newsletters/2023/05/24/#en-attente-de-confirmation-2--mesures-dincitation