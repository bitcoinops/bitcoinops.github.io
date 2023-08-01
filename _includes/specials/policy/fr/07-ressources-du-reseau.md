Un article précédent traitait de la protection des ressources des nœuds, qui peut être unique
à chaque nœud et donc parfois configurable. Nous avons également expliqué pourquoi il est préférable
de converger vers une seule politique, mais qu'est-ce qui doit faire partie de cette politique ?
Ce billet aborde le concept de ressources à l'échelle du réseau, essentielles pour des aspects tels
que l'évolutivité, la mise à niveau et l'accessibilité du démarrage et de la maintenance d'un nœud complet.

Comme nous l'avons vu dans les [articles précédents][policy01], de nombreux objectifs idéologiques
du réseau Bitcoin sont incarnés par sa structure distribuée. La nature pair-à-pair de Bitcoin permet
aux règles du réseau d'émerger d'un consensus approximatif des choix des opérateurs de nœuds individuels
et limite les tentatives d'acquisition d'une influence indue sur le réseau. Ces règles sont ensuite
appliquées par chaque nœud qui valide individuellement chaque transaction. Une population de nœuds
diversifiée et saine exige que le coût d'exploitation d'un nœud soit maintenu à un niveau bas. Il est
difficile de faire évoluer un projet avec une audience mondiale, mais le faire sans sacrifier la
décentralisation revient à se battre avec une main attachée dans le dos. Le projet Bitcoin tente
de trouver cet équilibre en protégeant farouchement les ressources partagées du réseau : le stock
d'UTXO, l'empreinte des données de la blockchain et l'effort de calcul nécessaire pour les traiter,
ainsi que les mises à jour permettant de faire évoluer le protocole Bitcoin.

Il n'est pas nécessaire de revenir sur la guerre des tailles de blocs pour comprendre qu'une limite à
la croissance de la blockchain est nécessaire pour que l'exploitation de son propre nœud reste abordable.
Cependant, la croissance de la blockchain est également dissuadée au niveau politique par le `minRelayTxFee`
de 1 sat/vbyte, assurant un coût minimum pour exprimer une partie de la " [demande illimitée de stockage
perpétuel hautement répliqué][unbounded] ".

À l'origine, l'état du réseau était déterminé en conservant toutes les transactions dont les résultats
n'avaient pas encore été dépensés. Cette partie beaucoup plus importante de la blockchain a été réduite de
manière significative avec l'[introduction du jeu d'UTXO][ultraprune] comme moyen de suivre les fonds.
Depuis lors, le jeu d'UTXO est une structure de données centrale. En particulier pendant les IBD, mais
aussi de manière générale, les consultations d'UTXO représentent une part importante de tous les accès
à la mémoire d'un nœud. Bitcoin Core utilise déjà une [structure de données optimisée manuellement pour
le cache UTXO][pooled resource], mais la taille du jeu d'UTXO détermine la quantité qu'il ne peut pas
contenir dans le cache d'un nœud. Un ensemble d'UTXO plus important se traduit par un plus grand nombre
d'absences du cache, ce qui ralentit la vitesse de validation des blocs, de l'IBD et de la transaction.
La limite de poussière est un exemple de politique qui restreint la création d'UTXO, en particulier les
UTXO qui pourraient ne jamais être dépensés parce que leur montant [n'est pas à la hauteur][topic uneconomical outputs]
du coût de leur dépense. Malgré cela, des ["tempêtes de poussière" avec des milliers de transactions se
sont produites pas plus tard qu'en 2020][lopp storms].

Lorsqu'il est devenu populaire d'utiliser des sorties multisig brutes pour publier des données sur la
blockchain, la définition des transactions standard a été modifiée pour permettre une sortie OP_RETURN
unique en tant qu'alternative. Les gens ont réalisé qu'il serait impossible d'empêcher les utilisateurs
de publier des données sur la blockchain, mais qu'au moins ces données n'auraient pas besoin de vivre dans
le jeu d'UTXO pour toujours lorsqu'elles sont publiées dans des sorties qui ne peuvent jamais être dépensées.
Bitcoin Core 0.13.0 a introduit une option de démarrage `-permitbaremultisig` que les utilisateurs peuvent
activer pour rejeter les transactions non confirmées avec des sorties multisig brutes.

Bien que les règles de consensus permettent aux scripts de sortie d'être libres, seuls quelques modèles bien
compris sont relayés par les nœuds de Bitcoin Core. Il est ainsi plus facile de comprendre les nombreuses
préoccupations du réseau, notamment les coûts de validation et les mécanismes de mise à jour du protocole.
Par exemple, un script d'entrée qui contient des op-codes, une entrée P2SH avec plus de 15 signatures, ou une
entrée P2WSH dont la pile de témoins contient plus de 100 éléments chacun, rendrait une transaction non standard.
(Consultez cette [vue d'ensemble des politiques][instagibbs policy zoo] pour plus d'exemples de politiques et leurs motivations).

Finalement, le protocole Bitcoin est un projet logiciel vivant qui devra continuer à évoluer pour répondre aux
défis futurs et aux besoins des utilisateurs. À cette fin, il existe un certain nombre de mécanismes de mise à
jour qui ont délibérément laissé le consensus valide mais inutilisé, tels que l'annexe, les versions des leaf
taproots, les versions des témoins, OP_SUCCESS et un certain nombre d'opcodes no-op. Cependant, tout comme les
attaques sont entravées par l'absence de points centraux de défaillance, les mises à jour logicielles à l'échelle
du réseau impliquent un effort coordonné entre des dizaines de milliers d'opérateurs de nœuds indépendants.
Les nœuds ne relaieront pas les transactions qui utilisent les hooks de mise à niveau réservés tant que leur
signification n'aura pas été définie. Cette mesure vise à dissuader les applications de créer indépendamment des
normes contradictoires, ce qui rendrait impossible l'adoption de la norme d'une application dans le consensus sans
invalider celle d'une autre application. En outre, lorsqu'un changement de consensus se produit, les nœuds qui ne
sont pas mis à niveau immédiatement---et qui ne connaissent donc pas les nouvelles règles de consensus---ne peuvent
pas être "trompés" en acceptant une transaction désormais invalide dans leur pool de mémoires. Ce découragement
proactif aide les nœuds à être compatibles avec l'avenir et permet au réseau de mettre à jour les règles de
consensus en toute sécurité sans nécessiter une mise à jour logicielle entièrement synchronisée.

Nous pouvons voir que l'utilisation d'une politique pour protéger les ressources partagées du réseau aide à protéger
les caractéristiques du réseau, et maintient ouvertes les voies pour le développement de protocoles futurs. Pendant
ce temps, nous voyons comment la friction de la croissance du réseau contre une blockchain strictement limitée a
conduit à l'adoption de meilleures pratiques, d'une bonne conception technique et de l'innovation : le billet de
la semaine prochaine explorera la politique de mempool comme une interface pour les protocoles de deuxième couche
et les systèmes de contrats intelligents.

[policy01]: /fr/newsletters/2023/05/17/#en-attente-de-confirmation-1--pourquoi-avons-nous-un-mempool-
[unbounded]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2015-December/011865.html
[lopp storms]: https://blog.lopp.net/history-bitcoin-transaction-dust-spam-storms/
[ultraprune]: https://github.com/bitcoin/bitcoin/pull/1677
[pooled resource]: /fr/newsletters/2023/05/03/#bitcoin-core-25325
[instagibbs policy zoo]: https://gist.github.com/instagibbs/ee32be0126ec132213205b25b80fb3e8
