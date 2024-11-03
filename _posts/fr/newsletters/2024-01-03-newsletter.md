---
title: 'Bulletin Hebdomadaire Bitcoin Optech #283'
permalink: /fr/newsletters/2024/01/03/
name: 2024-01-03-newsletter-fr
slug: 2024-01-03-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine revient sur deux vulnérabilités corrigées dans LND, résume une proposition de timelocks dépendant
des frais, décrit une proposisiton d'amélioration de l'estimation des frais par des clusters de transactions, explique comment spécifier
des clés non dépensables dans les descripteurs, examine le coût du pinning dans la proposition de relais de transaction v3, évoque
une proposition de BIP pour permettre l'inclusion de descripteurs dans les PSBT, annonce un outil pouvant être utilisé avec la
proposition MATT pour prouver qu'un programme s'est exécuté correctement, examine une proposition permettant des sorties de groupe très
efficaces à partir d'un UTXO groupé, et pointe vers de nouvelles stratégies de sélection de pièces proposées pour Bitcoin Core. Il
comprend également nos sections habituelles annonçant les nouvelles versions et décrivant les changements importants apportés aux
logiciels d'infrastructure Bitcoin les plus populaires.

## Nouvelles

- **Divulgation de vulnérabilités passées dans LND :** Niklas Gögge [a publié][gogge lndvuln] sur Delving Bitcoin deux vulnérabilités
  qu'il avait précédemment [divulguées de manière responsable][topic responsible disclosures], ce qui a conduit à la publication de
  versions corrigées de LND. Toute personne utilisant LND 0.15.0 ou une version ultérieure n'est pas vulnérable ; toute personne
  utilisant une version antérieure de LND devrait envisager de mettre à jour immédiatement en raison de ces vulnérabilités et d'autres
  vulnérabilités connues affectant les anciennes versions. En bref, les deux vulnérabilités divulguées étaient les suivantes :

  - Une vulnérabilité de déni de service (DoS) qui aurait pu entraîner l'épuisement de la mémoire de LND et sa fermeture. Si LND ne
    fonctionne pas, il ne peut pas diffuser de transactions sensibles au temps, ce qui peut entraîner une perte de fonds.

  - Une vulnérabilité de censure qui aurait pu permettre à un attaquant d'empêcher un nœud LND de prendre connaissance des mises à
    jour des canaux ciblés à travers le réseau. Un attaquant aurait pu l'utiliser pour orienter un nœud vers certaines routes pour
    les paiements qu'il envoie, lui donnant ainsi plus de frais de transfert et plus d'informations sur les paiements envoyés par
    le nœud.

  Gögge a d'abord divulgué ces deux vulnérabilités aux développeurs de LND il y a plus de deux ans et des versions de LND contenant des
  correctifs sont disponibles depuis plus de 18 mois. Optech n'a connaissance d'aucun utilisateur ayant été affecté
  par l'une ou l'autre vulnérabilité.

- **Timelocks dépendant des frais :** John Law [a publié][law fdt] sur les listes de diffusion Bitcoin-Dev et Lightning-Dev une
  proposition approximative pour un soft fork qui pourrait permettre aux transactions [timelocks][topic timelocks] de se déverrouiller
  (d'expirer) uniquement lorsque les frais médians des blocs sont inférieurs à un niveau choisi par l'utilisateur. Par exemple, Alice
  souhaite déposer de l'argent dans un canal de paiement avec Bob, mais elle souhaite également pouvoir recevoir un remboursement si
  Bob devient indisponible, elle lui donne donc la possibilité de réclamer les fonds qu'elle lui paie à tout moment, mais elle se
  donne également la possibilité de réclamer un remboursement de son dépôt après l'expiration d'un timelock. À mesure que l'expiration
  du timelock approche, Bob tente de réclamer ses fonds, mais les frais actuels sont beaucoup plus élevés que ce à quoi ils s'attendaient
  à la création du contrat. Bob ne parvient pas à faire confirmer la transaction réclamant ses fonds,
  soit parce qu'il n'a pas accès à assez de bitcoins pour payer les frais ou parce qu'il serait prohibitif de créer une transaction de
  réclamation compte tenu des frais élevés. Dans le protocole Bitcoin actuel, si Bob ne peut pas agir, Alice peut réclamer son
  remboursement. Avec la proposition de Law, l'expiration du verrou temporel qui empêche Alice de réclamer son remboursement serait
  retardée jusqu'à ce qu'il y ait eu une série de blocs avec des taux de frais médians inférieurs à un montant spécifié par Alice et
  Bob lors de la négociation de leur contrat. Cela garantirait que Bob ait une chance de confirmer sa transaction à un taux de frais
  acceptable.

  Law note que cela répond à l'une des préoccupations de longue date mentionnées dans le [document original sur le réseau Lightning][]
  concernant les "inondations d'expiration forcée" où trop de canaux se ferment simultanément, ce qui peut entraîner un espace de bloc
  insuffisant pour tous les confirmer avant l'expiration de leurs verrous temporels, ce qui pourrait entraîner des pertes d'argent pour
  certains utilisateurs. Avec la mise en place de verrous temporels dépendant des frais, les utilisateurs des canaux fermés enchériront
  simplement sur les taux de frais jusqu'à ce qu'ils dépassent le verrou dépendant des frais, après quoi l'expiration des verrous
  temporels sera retardée jusqu'à ce que les frais soient suffisamment bas pour que toutes les transactions payant ce taux de frais
  soient confirmées. Les canaux LN n'impliquent actuellement que deux utilisateurs chacun, mais des propositions telles que les
  [usines de canaux][topic channel factories] et les [joinpools][topic joinpools] où plus de deux utilisateurs partagent un UTXO sont
  encore plus vulnérables aux inondations d'expiration forcée, donc cette solution renforce considérablement leur sécurité. Law note
  également que, dans au moins certaines de ces constructions, la partie qui détient la condition de remboursement (par exemple, Alice
  dans notre exemple précédent) est la plus désavantagée par l'augmentation des frais, étant donné que son capital est bloqué dans le
  contrat jusqu'à ce que les frais diminuent. Les verrous dépendant des frais donnent à cette partie un incitatif supplémentaire à
  agir de manière à maintenir les taux de frais bas, par exemple en ne fermant pas de nombreux canaux dans un court laps de temps.

  Les détails de mise en œuvre des verrous temporels dépendant des frais sont choisis pour les rendre faciles à utiliser en option
  pour les participants au contrat et pour minimiser la quantité d'informations supplémentaires que les nœuds complets doivent stocker
  pour les valider.

  La proposition a suscité un débat modéré, les répondants suggérant de [stocker][riard fdt] les paramètres des verrous temporels
  dépendant des frais dans l'annexe [taproot][topic taproot], de faire en sorte que les blocs [s'engagent][boris fdt] à leur taux
  de frais médian pour prendre en charge les clients légers, et des [détails][harding pruned] sur la manière dont les nœuds prunés
  mis à niveau pourraient prendre en charge le soft-fork. Il y a également eu un débat entre Law et [d'autres][evo fdt] sur l'effet
  des mineurs acceptant des frais payés en dehors du mécanisme normal de
  frais de transaction (par exemple, en payant directement un mineur particulier).

- **Estimation des frais de cluster :** Abubakar Sadiq Ismail a [publié][ismail cluster] sur Delving Bitcoin à propos de l'utilisation
  de certains outils et d'informations issus de la conception du [cluster mempool][topic cluster mempool] pour améliorer l'estimation
  des frais dans Bitcoin Core. L'algorithme d'estimation des frais actuel dans Bitcoin Core suit le nombre de blocs nécessaires aux
  transactions entrant dans le mempool du nœud local pour être confirmées. Lors de la confirmation, le taux de frais de transaction
  est utilisé pour prédire le temps qu'il faudra pour que les transactions avec des taux de frais similaires soient
  confirmées.

  Dans cette approche, certaines transactions ne sont pas comptabilisées par Bitcoin Core, tandis que d'autres sont
  potentiellement mal comptées. Cela est dû à [CPFP][topic cpfp], où les transactions enfants (et autres descendants) incitent les
  mineurs à confirmer leurs parents (et autres ascendants). Les transactions enfants peuvent avoir un taux de frais élevé par
  elles-mêmes,
  mais lorsque leurs frais et ceux de leurs ancêtres sont considérés ensemble, le taux de frais peut être significativement plus bas,
  ce qui les amène à prendre plus de temps que prévu pour être confirmées. Pour éviter que cela ne provoque une surestimation des frais,
  Bitcoin Core ne met pas à jour ses estimations en utilisant une transaction qui entre dans le mempool lorsque
  son parent n'est pas confirmé. De même, une transaction parent peut avoir un taux de frais faible par elle-même, mais lorsque les
  frais de ses descendants sont également pris en compte, le taux de frais peut être significativement plus élevé, ce qui les amène à
  être confirmées plus rapidement que prévu. Les estimations de frais de Bitcoin Core ne compensent pas cette situation.

  Le cluster de mempool regroupera les transactions connexes et les divisera en fragments qui seront rentables à miner ensemble. Ismail
  suggère de suivre les taux de frais des fragments plutôt que des transactions individuelles (bien qu'un fragment puisse être une seule
  transaction) et ensuite d'essayer de trouver ces mêmes fragments dans les blocs. Si un fragment est confirmé, alors les estimations de
  frais sont mises à jour en utilisant son taux de frais de fragment plutôt que les taux de frais des transactions individuelles.

  La proposition a été bien accueillie, avec les développeurs discutant des détails qu'un algorithme mis à jour devrait prendre en
  compte.

- **Comment spécifier des clés non dépensables dans les descripteurs :** Salvatore Ingala a lancé une [discussion][ingala undesc] sur
  Delving Bitcoin sur la façon de permettre aux [descripteurs][topic descriptors], en particulier ceux pour [taproot][topic taproot],
  de spécifier une clé pour laquelle aucune clé privée n'est connue (empêchant les dépenses à partir de cette clé). Un contexte important
  pour cela est l'envoi d'argent à une sortie taproot qui ne peut être dépensée que via une dépense de scriptpath. Pour ce faire, la clé
  qui permet les dépenses de keypath doit être définie sur une clé non dépensable.

  Ingala a relevé plusieurs problèmes à résoudre liés à l'utilisation de clés non dépensables dans les descripteurs et plusieurs
  solutions proposées
  avec différents compromis. Pieter Wuille en personne a résumé plusieurs discussions récentes sur les descripteurs, y compris une
  [idée particulière][wuille undesc2] concernant les clés non dépensables. Josie Baker a demandé des détails sur la raison pour laquelle
  la clé non dépensable ne peut pas être une valeur constante (comme le point nothing-up-my-sleeve (NUMS) dans BIP341), ce qui
  permettrait à tout le monde de savoir immédiatement qu'une clé non dépensable a été utilisée---un avantage possible pour certains
  protocoles, tels que les [paiements silencieux][topic silent payments]. Ingala a répondu à Baker que "c'est une forme de marquage.
  Vous pouvez toujours révéler cette information vous-même si vous le souhaitez ou en avez besoin, mais c'est mieux que les normes ne
  vous
  obligent pas à le faire." Wuille a ensuite répondu avec un algorithme pour générer la preuve. Dans le dernier message du fil au
  moment de l'écriture, Ingala a noté que certaines tâches de spécification des politiques liées aux clés non dépensables peuvent être
  réparties entre les descripteurs et les politiques de portefeuille [BIP388][].

- **Coûts d'épinglage des transactions V3 :** Peter Todd a [publié][todd v3] sur la liste de diffusion Bitcoin-Dev une analyse de la
  politique des [relais des transactions V3][topic v3 transaction relay] proposée pour les protocoles de contrat tels que LN. Par
  exemple, Bob et Mallory peuvent partager un canal LN. Bob souhaite fermer le canal, il diffuse donc sa transaction d'engagement
  actuelle ainsi qu'une petite transaction enfant qui contribue aux frais via [CPFP][topic cpfp], avec une taille totale de 500 vbytes.
  Mallory détecte les transactions de Bob sur le réseau P2P avant qu'elles n'atteignent les mineurs et envoie sa propre transaction
  d'engagement ainsi qu'une très grande transaction enfant, donnant à ses deux transactions une taille combinée de 100 000 vbytes avec
  un taux de frais combiné inférieur à la version originale de Bob. En utilisant la politique de relais par défaut actuelle de Bitcoin
  Core et la proposition actuelle pour [le relais des paquets][topic package relay], Bob peut essayer de [remplacer][topic rbf] les deux
  transactions de Mallory, mais il devra payer la bande passante utilisée par la transaction de Mallory selon la règle #3 de [BIP125][].
  Si Bob utilisait initialement un taux de frais de 10 sat/vbyte (5 000 sats au total) et que l'alternative de Mallory utilisait un taux
  de frais de 5 sat/vbyte (500 000 sats au total), Bob devra payer 100 fois plus dans son remplacement que ce qu'il a initialement payé.
  Si cela dépasse ce que Bob est prêt à payer, la transaction de Mallory, grande et à faible taux de frais, peut ne pas être confirmée
  avant l'expiration d'un verrouillage temporel critique et permettre à Mallory de voler de l'argent à Bob.

  Dans la proposition de relais de transaction V3, les règles permettent à une transaction optant pour la politique V3 de n'avoir qu'un
  maximum d'une transaction enfant non confirmée qui sera relayée, stockée dans les mempools et minée par les nœuds qui acceptent de
  suivre la politique V3. Comme le montre Peter Todd dans son message, cela permettrait toujours à Mallory d'augmenter les coûts de Bob
  d'environ 1,5 fois ce qu'il voulait payer. Les répondants ont largement convenu qu'il y avait un risque que Bob doive payer plus en
  cas de contrepartie malveillante, mais ils ont noté qu'un multiple faible est bien meilleur que les 100 fois ou plus que Bob pourrait
  devoir payer selon les règles de relais actuelles.

  Des discussions supplémentaires dans la conversation ont porté sur les détails des règles de relais V3, les
  [ancrages éphémères][topic ephemeral anchors] et leur comparaison avec les [exclusions CPFP][topic cpfp carve out] et les
  [sorties d'ancrage][topic anchor outputs] actuellement disponibles.

- **Descripteurs dans le projet de BIP PSBT :** l'équipe SeedHammer a [publié][seedhammer descpsbt] un projet de BIP sur la liste de
  diffusion Bitcoin-Dev pour inclure des [descripteurs][topic descriptors] dans les [PSBT][topic psbt]. L'utilisation principale semble
  être l'encapsulation des descripteurs dans le format PSBT pour le transfert entre portefeuilles, conformément à la norme proposée
  permettant  aux PSBT d'omettre les données de transaction lorsqu'un descripteur est inclus. Cela peut être utile pour un portefeuille
  logiciel afin de transférer des informations de sortie vers un appareil de signature matériel ou pour plusieurs portefeuilles dans une
  fédération multisig afin de transférer des informations sur les sorties qu'ils souhaitent créer. Au moment de la rédaction de cet
  article, le projet de BIP n'a reçu aucune réponse sur la liste de diffusion, bien qu'un précédent [message][seedhammer descpsbt2] en
  novembre concernant une proposition préliminaire ait reçu des [commentaires][black descpsbt].

- **Vérification de programmes arbitraires à l'aide d'une opcode proposée par MATT :**
  Johan Torås Halseth a [publié][halseth ccv] sur Delving Bitcoin à propos de
  [elftrace][], un programme de preuve de concept qui peut utiliser l'opcode
  `OP_CHECKCONTRACTVERIFY` de la proposition de fork logiciel [MATT][]
  pour permettre à une partie dans un protocole de contrat de réclamer de l'argent si un programme arbitraire
  s'exécute avec succès. C'est similaire en concept à BitVM (voir
  [Newsletter #273][news273 bitvm]) mais plus simple dans son
  implémentation Bitcoin en raison de l'utilisation d'un opcode spécifiquement conçu pour
  la vérification de l'exécution du programme. Elftrace fonctionne avec des programmes compilés
  pour l'architecture RISC-V utilisant le format [ELF][] de Linux ; presque n'importe quel
  programmeur peut facilement créer des programmes pour cette cible, rendant l'utilisation
  d'elftrace très accessible. Le message du forum n'a reçu aucune
  réponse au moment de la rédaction de cet article.

- **Regroupement des paiements de sortie de pool avec délégation à l'aide de preuves de fraude :**
  Salvatore Ingala a [publié][ingala exit] sur Delving Bitcoin une proposition
  qui peut améliorer les contrats multiparties où plusieurs utilisateurs partagent un
  UTXO, comme un [joinpool][topic joinpools] ou une [channel factory][topic
  channel factories], et certains utilisateurs veulent quitter le contrat à
  un moment où d'autres utilisateurs ne répondent pas (que ce soit intentionnellement ou
  involontairement). La manière typique de construire de tels protocoles est de
  donner à chaque utilisateur une transaction off-chain que l'utilisateur peut diffuser
  au cas où il voudrait quitter. Cela signifie que, même dans le meilleur des cas, si cinq
  utilisateurs veulent quitter, ils doivent chacun diffuser une transaction distincte,
  et chacune de ces transactions aura au moins une entrée et une sortie, soit un total de cinq entrées et cinq sorties.
  Ingala suggère une façon dont ces utilisateurs pourraient travailler ensemble pour sortir avec une
  seule transaction qui pourrait avoir une seule entrée et cinq sorties,
  leur donnant la réduction typique de la taille de transaction du [regroupement des paiements][topic payment batching]
  d'environ 50%.

  Dans des contrats multiparties complexes avec un très grand nombre d'utilisateurs, la
  réduction de la taille on-chain peut facilement être significativement supérieure à 50%.
  Mieux encore, si les cinq utilisateurs actifs voulaient simplement déplacer leurs
  fonds vers un nouvel UTXO partagé les concernant, ils pourraient utiliser une
  transaction à une seule entrée et une seule sortie, économisant environ 80% dans le
  cas de cinq utilisateurs ou environ 99% dans le cas de cent utilisateurs. Ces
  énormes économies pour de grands groupes d'utilisateurs déplaçant leurs fonds d'un
  contrat à un autre peuvent être critiques lorsque les frais de transaction sont élevés
  et que de nombreux utilisateurs ont des soldes relativement faibles dans le contrat. Par
  exemple, 100 utilisateurs ont chacun un solde de 10 000 sats ($4 USD au moment de la rédaction,
  si chaque utilisateur devait payer des frais de transaction pour sortir du contrat et entrer dans un nouveau contrat,
  alors, même avec une taille de transaction de dépense très petite de 100 vbytes, des frais de transaction de 100 sats/vbyte
  consommeraient l'intégralité de leur solde. S'ils peuvent déplacer leurs fonds combinés de 1 million de sats dans une seule
  transaction de 200 vbytes à 100 sats/vbyte, alors chaque utilisateur ne paiera que 200 sats (2% de leur solde).

  Le regroupement des paiements est réalisé en demandant à l'un des participants du protocole de contrat multipartie de construire une
  dépense des fonds partagés vers les sorties convenues par les autres participants actifs. Le contrat le permet, mais seulement
  si celui qui construit la dépense finance une caution qu'il perdra si quelqu'un peut prouver qu'il a mal
  dépensé les fonds du contrat ; le montant du dépôt devrait être considérablement plus élevé que ce que la partie qui construit peut
  gagner en tentant un transfert incorrect de fonds. Si personne ne génère de preuve de fraude montrant que la partie qui construit a
  agi de manière inappropriée dans un délai donné, le dépôt est remboursé à celui qui a construit la dépense. Ingala décrit
  approximativement
  comment cette fonctionnalité pourrait être ajoutée à un protocole de contrat multipartie en utilisant [OP_CAT][],
  `OP_CHECKCONTRACTVERIFY`, et l'introspection du montant de la proposition de soft fork [MATT][], en notant que cela serait plus facile
  avec l'ajout également de [OP_CSFS][topic op_checksigfromstack] et d'opérateurs arithmétiques sur 64 bits dans
  [tapscript][topic tapscript].

  L'idée a fait l'objet d'un petit nombre de discussions à l'heure actuelle.

- **Nouvelles stratégies de sélection de pièces :** Mark Erhardt [a posté][erhardt coin] sur Delving Bitcoin à propos des cas
  particuliers que les utilisateurs ont pu rencontrer avec la stratégie de sélection d'UTXO de Bitcoin Core et propose deux nouvelles
  stratégies qui traitent ces cas particuliers en essayant de réduire le nombre d'inputs utilisés dans les transactions du portefeuille à
  des taux de frais élevés. Il résume également les avantages et les inconvénients de toutes les stratégies pour Bitcoin Core, celles qui
  ont été mises en œuvre et celles qu'il a proposées, puis fournit plusieurs résultats de simulations qu'il a réalisées en utilisant les
  différents algorithmes. L'objectif ultime est que Bitcoin Core sélectionne généralement l'ensemble des inputs qui minimisera le
  pourcentage de la valeur UTXO dépensée en frais à long terme, tout en ne créant pas de transactions inutilement volumineuses lorsque
  les taux de frais sont élevés.

## Mises à jour et versions candidates

*Nouvelles versions et versions candidates pour les principaux projets d’infrastructure
Bitcoin. Veuillez envisager de passer aux nouvelles versions ou d’aider à tester
les versions candidates.*

- [Core Lightning 23.11.2][] est une version de correction de bugs qui aide à garantir que les nœuds LND peuvent payer les factures
  créées par les utilisateurs de Core Lightning. Voir la description de Core Lightning #6957 dans la section des _changements notables_
  ci-dessous pour plus de détails.

- [Libsecp256k1 0.4.1][] est une version mineure qui "augmente légèrement la vitesse de l'opération ECDH et améliore considérablement
  les performances de nombreuses fonctions de la bibliothèque lors de l'utilisation de la configuration par défaut sur x86_64."

## Changements notables dans le code et la documentation

*Changements notables cette semaine dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning repo], [Eclair][eclair repo],
[LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet Interface (HWI)][hwi repo],
[Rust Bitcoin][rust bitcoin repo], [BTCPay Server][btcpay server repo], [BDK][bdk repo],
[Bitcoin Improvement Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo], et [Bitcoin Inquisition][bitcoin inquisition repo].*

- [Bitcoin Core #28349][] commence à exiger l'utilisation de compilateurs compatibles avec C++20, permettant aux futurs PR de commencer
  à utiliser les fonctionnalités de C++20. Comme le précise la description du PR, "C++20 permet d'écrire un code plus sûr, car il permet
  d'imposer plus de choses lors de la compilation".

- [Core Lightning #6957][] corrige une incompatibilité involontaire qui empêchait les utilisateurs de LND de pouvoir payer les factures
  générées par Core Lightning avec les paramètres par défaut. Le problème concerne le `min_final_cltv_expiry`, qui spécifie le nombre
  maximum de blocs dont dispose un destinataire pour réclamer un paiement. [BOLT2][] suggère de fixer cette valeur par défaut à 18, mais
  LND utilise une valeur de 9, qui est inférieure à celle acceptée par défaut par Core Lightning. Le problème est résolu en incluant
  désormais un champ dans les factures de Core Lightning qui demande une valeur de 18.

- [Core Lightning #6869][] met à jour le RPC `listchannels` pour ne plus répertorier les [canaux non annoncés][topic unannounced channels]
  Les utilisateurs ayant besoin de ces informations peuvent utiliser le RPC `listpeerchannels`.

- [Eclair #2796][] met à jour sa dépendance à [logback-classic][] pour corriger une vulnérabilité. Eclair n'utilise pas directement la
  fonctionnalité affectée par la vulnérabilité, mais la mise à niveau garantit que les plugins ou autres logiciels connexes utilisant
  la fonctionnalité ne seront pas vulnérables.

- [Eclair #2787][] met à jour son support de la récupération des en-têtes depuis BitcoinHeaders.net vers la dernière API. La récupération
  des en-têtes via DNS aide à protéger les nœuds contre les [attaques d'éclipse][topic eclipse attacks]. Voir [Newsletter #123][news123
  headers] pour la description d'Eclair prenant initialement en charge la récupération des en-têtes basée sur DNS. D'autres logiciels
  utilisant BitcoinHeaders.net devront peut-être bientôt effectuer une mise à niveau vers la nouvelle API.

- [LDK #2781][] et [#2688][ldk #2688] mettent à jour le support de l'envoi et de la réception de [paiements masqués][topic rv routing],
  en particulier des chemins masqués à plusieurs sauts, ainsi que la conformité à l'exigence selon laquelle les [offres][topic offers]
  doivent toujours inclure au moins un saut masqué.

- [LDK #2723][] ajoute la prise en charge de l'envoi de [messages en oignon][topic onion messages] en utilisant des connexions directes.
  Dans le cas où l'expéditeur ne peut pas trouver un chemin vers le destinataire mais connaît le réseau du destinataire, il peut
  maintenant envoyer des messages en oignon via des connexions directes vers une adresse (par exemple, parce que le destinataire est un
  nœud public qui a divulgué son adresse IP), l'expéditeur peut simplement ouvrir une connexion directe avec le destinataire, envoyer le
  message, puis éventuellement fermer la connexion. Cela permet aux messages en oignon de fonctionner même si seul un petit nombre de
  nœuds du réseau les prend en charge (ce qui est le cas actuellement).

- [BIPs #1504][] met à jour BIP2 pour permettre à n'importe quel BIP d'être rédigé en Markdown. Auparavant, tous les BIP devaient être
  rédigés en balisage Mediawiki.

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 15:00" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="28349,6957,6869,2796,2787,2781,2723,1504,2688" %}
[gogge lndvuln]: https://delvingbitcoin.org/t/denial-of-service-bugs-in-lnds-channel-update-gossip-handling/314/1
[law fdt]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-December/004254.html
[document original sur le réseau Lightning]: https://lightning.network/lightning-network-paper.pdf
[riard fdt]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-December/004256.html
[boris fdt]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-December/004256.html
[harding pruned]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-December/004256.html
[evo fdt]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-December/004260.html
[ismail cluster]: https://delvingbitcoin.org/t/package-aware-fee-estimator-post-cluster-mempool/312/1
[ingala undesc]: https://delvingbitcoin.org/t/unspendable-keys-in-descriptors/304/1
[wuille undesc]: https://delvingbitcoin.org/t/unspendable-keys-in-descriptors/304/2
[wuille undesc2]: https://gist.github.com/sipa/06c5c844df155d4e5044c2c8cac9c05e#unspendable-keys
[todd v3]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-December/022211.html
[seedhammer descpsbt]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-December/022200.html
[seedhammer descpsbt2]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-November/022184.html
[black descpsbt]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-November/022186.html
[halseth ccv]: https://delvingbitcoin.org/t/verification-of-risc-v-execution-using-op-ccv/313
[elftrace]: https://github.com/halseth/elftrace
[matt]: /fr/newsletters/2022/11/16/#contrats-intelligents-generaux-en-bitcoin-via-des-clauses-restrictives
[news273 bitvm]: /fr/newsletters/2023/10/18/#paiements-conditionnels-a-une-computation-arbitraire
[elf]: https://en.m.wikipedia.org/wiki/Executable_and_Linkable_Format
[ingala exit]: https://delvingbitcoin.org/t/aggregate-delegated-exit-for-l2-pools/297
[erhardt coin]: https://delvingbitcoin.org/t/gutterguard-and-coingrinder-simulation-results/279/1
[logback-classic]: https://logback.qos.ch/
[news123 headers]: /en/newsletters/2020/11/11/#eclair-1545
[bip388]: https://github.com/bitcoin/bips/pull/1389
[core lightning 23.11.2]: https://github.com/ElementsProject/lightning/releases/tag/v23.11.2
[libsecp256k1 0.4.1]: https://github.com/bitcoin-core/secp256k1/releases/tag/v0.4.1
