---
title: 'Bulletin Hebdomadaire Bitcoin Optech #422'
permalink: /fr/newsletters/2026/09/11/
name: 2026-09-11-newsletter-fr
slug: 2026-09-11-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine décrit une proposition de protocole pour des coinjoins probabilistes déguisés en paris dissimulés et résume des
benchmarks d'un serveur d'indexation de silent payments comparé aux filtres de blocs compacts pour les clients légers. Sont également
incluses nos rubriques habituelles annonçant de nouvelles versions et versions candidates et décrivant les changements notables apportés aux
logiciels populaires d'infrastructure Bitcoin.

## Nouvelles

- **Un protocole pour coinjoin probabiliste et paris dissimulés** : Adam Gibson a [posté][bab del] sur Delving Bitcoin à propos de
  Babilonia, une proposition pour un nouveau protocole probabiliste de [coinjoin][topic coinjoin] et de paris dissimulés. L'idée derrière
  cette proposition est de fournir un comportement recherchant la confidentialité avec un déni plausible. Au lieu d'actions reconnaissables,
  qui peuvent être suivies, signalées et criminalisées, Gibson propose un protocole de paris dissimulés, dans lequel les utilisateurs
  participent afin de briser l'heuristique de propriété commune des entrées. Le pari ressemble à un pile ou face onchain où l'argent change
  de mains, mais qui, vu de l'extérieur, ressemble à un paiement normal.

  Le protocole, décrit dans un [article][bab paper], fonctionne ainsi :
  - Alice et Bob fournissent leurs entrées pour construire un UTXO partagé. Ils signent également une transaction de remboursement, qui rend
      les fonds à leurs propriétaires en cas de long délai d'expiration, et une transaction de paiement, pour régler le pari.

  - Alice génère deux nombres secrets `a_1` et `a_2`, en choisissant l'un comme son choix, et publie les clés publiques correspondantes
      `A_1` et `A_2`.

  - Bob en choisit un comme supposition et construit une clé publique `K` qui ne peut être dépensée que si son choix et celui d'Alice sont
      identiques.

  - La transaction de paiement envoie les fonds vers une sortie dépensable par `K`. Alice signe cette transaction avec une [signature
      adaptatrice][topic adaptor signatures] partielle. Après que Bob a signé avec sa signature partielle et que la transaction de
      financement est confirmée, Alice fournit hors bande le secret caché de l'adaptateur, permettant à Bob de déchiffrer le nombre qu'elle
      a choisi. S'il a gagné, il complète et diffuse la transaction de paiement pour réclamer les fonds.

  Selon l'auteur, plusieurs tours du protocole permettraient statistiquement aux utilisateurs de conserver leurs fonds initiaux, moins les
  frais, tout en améliorant leur confidentialité. Cela est vrai en moyenne, mais peut varier pour des utilisateurs individuels. Cependant,
  dans l'article, Gibson indique qu'il n'existe toujours pas de mesure claire de l'efficacité réelle du protocole. Dans un message de suivi,
  Gibson a noté qu'un seul pari révèle sa taille, puisque le paiement du gagnant est un multiple entier de sa contribution au pot, et il a
  publié une seconde version de l'article qui divise chaque pari en plusieurs sous-paris inégaux.

- **Mise à jour sur les clients légers pour silent payments** : Rob Segers a [posté][sp light ml] sur la liste de diffusion Bitcoin-Dev à
  propos de mises à jour d'une ancienne discussion sur Delving Bitcoin (voir le [Bulletin #305][news305 sp light]). Cette discussion, qui
  s'était arrêtée en juin 2024, était centrée sur la fourniture de spécifications pour les clients légers de [silent payments][topic silent
  payments] et sur la mesure des performances de différentes manières de récupérer des données à partir des blocs.

  Segers a exécuté une instance de [BlindBit Oracle v2][blindbit gh], une implémentation du serveur d'indexation [BIP352][] qui abandonne
  complètement les filtres et diffuse à la place des données par sortie (txid, tweak et préfixe de sortie de 8 octets), et a comparé ses
  performances à celles des [filtres de blocs compacts BIP158][topic compact block filters] et des filtres réservés à [taproot][topic
  taproot]. La comparaison a été effectuée sur des données de blocs non échantillonnées depuis l'activation de taproot jusqu'au bloc 965 089
  (soit un total de 255 434 blocs). Les [résultats][results gh] montrent que l'approche BlindBit Oracle télécharge environ 2,1x autant
  d'octets qu'un filtre réservé à taproot plus les données brutes de tweak dont un client à filtres a encore besoin, sans compter le bloc
  complet qu'un client à filtres doit récupérer à chaque correspondance, en échange de l'absence de faux positifs et d'aucune récupération
  de bloc par correspondance.

  Segers a également noté qu'un client léger ne peut actuellement pas savoir si un serveur a omis un tweak pour un bloc, ce qui ferait
  silencieusement perdre de l'argent au destinataire. Son serveur publie des engagements par bloc sur l'ensemble trié des tweaks et les
  checkpoint sur nostr toutes les six heures, rendant les omissions attribuables après coup, bien que les clients devraient toujours
  récupérer le bloc complet en cas de correspondance.

  Enfin, Segers a noté que la nouvelle version de BlindBit Oracle s'était fortement écartée des spécifications d'origine. Ainsi, l'auteur a
  fourni un [brouillon de convergence][sp light draft] ouvert à la discussion.

## Mises à jour et versions candidates

_Nouvelles versions et versions candidates pour des projets d'infrastructure Bitcoin populaires. Veuillez envisager de mettre à niveau vers
les nouvelles versions ou d'aider à tester les versions candidates._

- [LDK v0.3-rc1][] est une version candidate pour la prochaine version majeure de cette bibliothèque permettant de construire des
  portefeuilles et applications compatibles LN. Elle ajoute l'augmentation des frais [RBF][topic rbf] pour les [splices][topic splicing] en
  attente ainsi que la prise en charge de l'ajout et du retrait de fonds dans le même splice. Elle négocie aussi les [canaux anchor][topic
  anchor outputs] par défaut et exige des applications qu'elles acceptent explicitement les canaux entrants. La mise à niveau invalide les
  factures [BOLT11][] précédemment émises contenant des métadonnées de paiement. Les développeurs devraient examiner les [changements d'API
  et de compatibilité ascendante][ldk 0.3 notes] avant de tester.

- [LDK v0.2.6][] est une version de sécurité de cette bibliothèque permettant de construire des portefeuilles et applications compatibles
  LN. Elle corrige une vulnérabilité de déni de service dans laquelle un paiement invalide, rejeté après qu'un second HTLC avec le même
  hachage de paiement a été transféré avec succès, pouvait laisser le gestionnaire de canaux dans un état ne parvenant pas à être
  désérialisé. Elle corrige également une vulnérabilité de gonflement des frais qui permettait à une contrepartie malveillante de faire
  sur-allouer les frais à un nœud lors de sa contribution à un splice qu'elle avait initié, l'excédent allant vers la sortie de la
  contrepartie.

- [BTCPay Server 2.4.4][] est une version de sécurité de ce processeur de paiement auto-hébergé. Elle supprime les clés API héritées BitPay
  Basic-auth et retire cette méthode d'authentification, exigeant des intégrations concernées qu'elles migrent vers une authentification
  prise en charge. Les clés API Greenfield existantes continuent de fonctionner. La version exige également une autorisation pour modifier
  les états de facture, empêche les clés API restreintes de créer des clés non restreintes, et inclut les changements de stockage des clés
  API décrits ci-dessous. Les mises à jour Docker associées restreignent l'accès à la gestion de l'hôte, remplacent le mot de passe de
  portefeuille par défaut partagé de LND par des mots de passe uniques, et bloquent les routes de gestion de portefeuille non authentifiées
  de LND au niveau du proxy inverse. Ces changements concernant LND répondent à des observations de sondage du point de terminaison non
  authentifié de changement de mot de passe de LND sur des serveurs où des opérateurs avaient de nouveau exposé l'API LND après l'incident
  2.4.2 (voir le [Bulletin #418][news418 btcpay]). Les opérateurs qui l'ont fait devraient supprimer cet accès. Tous les administrateurs de
  serveur sont encouragés à mettre à niveau et à examiner les [changements incompatibles][btcpay 2.4.4 announcement]. Pour le plugin de
  facturation d'hébergement web, la migration nécessite une mise à niveau vers la version 4.0.0 et le remplacement de l'ancienne clé API par
  une nouvelle clé API Greenfield ; voir son [guide de migration][btcpay billing migration].

## Changements notables dans le code et la documentation

_Changements récents notables dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning repo], [Eclair][eclair repo],
[LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet Interface (HWI)][hwi repo], [Rust Bitcoin][rust
bitcoin repo], [BTCPay Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement Proposals (BIPs)][bips repo], [Lightning
BOLTs][bolts repo], [Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition repo] et [BINANAs][binana repo]._

- [Bitcoin Core #35949][] met à jour la création de modèles de blocs pour suivre l'atténuation proposée par [BIP54][] contre l'attaque
  Murch–Zawy de [time warp][topic time warp] (voir le [Bulletin #316][news316 timewarp]). Pour le dernier bloc de chaque période de
  difficulté de 2 016 blocs, l'horodatage minimal doit être au moins celui du premier bloc de la période. Auparavant, si l'horloge du nœud
  était en retard sur le premier bloc de la période, l'horodatage proposé pouvait également être antérieur, à condition qu'il dépasse
  l'horodatage médian des 11 blocs précédents. Le RPC `getblocktemplate` ajuste désormais à la fois `mintime` et le `curtime` proposé
  lorsque c'est nécessaire, y compris lorsque l'horloge du nœud est en retard sur ce minimum. Cela s'applique à tous les réseaux en
  préparation à l'éventuelle activation du soft fork de [consensus cleanup][topic consensus cleanup], sans modifier la validation du
  consensus.

- [Bitcoin Core #34931][] corrige un bug où une entrée de base de données UTXO qui ne pouvait pas être désérialisée était traitée comme une
  pièce manquante. En conséquence, un bloc valide dépensant la pièce illisible pouvait être marqué de façon permanente comme invalide, ce
  qui laisserait le nœud affecté incapable de suivre la meilleure chaîne du réseau. Bitcoin Core distingue désormais ces résultats et
  s'interrompt avec une erreur de base de données lorsque la désérialisation échoue. Un bug supplémentaire de sérialisation des pièces ou
  une corruption mémoire avant le stockage serait nécessaire pour que ce bug se produise, puisque les sommes de contrôle de LevelDB
  détectent déjà la corruption ordinaire du disque.

- [Bitcoin Core #36048][] corrige une injection de commande via l'option de configuration `-walletnotify` (voir le [Bulletin #86][news86
  walletnotify]) sur les systèmes non Windows. Un appelant RPC authentifié pouvait créer un portefeuille avec un nom spécialement conçu à
  l'aide de la commande `createwallet`. Si l'opérateur configurait l'option `-walletnotify` avec l'espace réservé au nom du portefeuille,
  `%w`, les notifications de transaction ultérieures pour ce portefeuille pouvaient exécuter des commandes intégrées dans le nom du
  portefeuille sur le système d'exploitation du nœud. Bien que le nom du portefeuille ait été échappé pour le shell, la fonction de
  substitution interprétait à l'intérieur de celui-ci les caractères de remplacement d'expression régulière, ce qui cassait le quoting
  shell. La substitution des espaces réservés traite désormais les noms de portefeuille littéralement, préservant l'échappement shell. Ce
  comportement a été introduit dans Bitcoin Core 24.0.

- [Bitcoin Core #36123][] et [#36169][bitcoin core #36169] corrigent une croissance de mémoire non bornée et le partage de port sous Windows
  dans le serveur HTTP de remplacement (voir les bulletins [#411][news411 http] et [#420][news420 http]). La première empêche un client de
  faire croître indéfiniment le tampon de réception par connexion du serveur en envoyant des requêtes plus vite que le serveur ne peut les
  traiter. Les lectures sur socket sont désormais interrompues lorsque des requêtes mises en tampon attendent d'être traitées, permettant à la
  contre-pression TCP de ralentir l'expéditeur. La seconde PR réserve l'adresse et le port exclusivement aux sockets d'écoute Windows.
  Auparavant, un autre processus local pouvait se lier au même point de terminaison et potentiellement recevoir des connexions contenant des
  identifiants RPC. Dans le test d'un relecteur, seize connexions REST ont augmenté l'utilisation mémoire de 3,2 Go avant la correction du
  buffering et de seulement 3 Mo ensuite sur 90 secondes.

- [Bitcoin Core #36176][] corrige une erreur qui se produit lorsqu'une opération de portefeuille tente d'enregistrer sa préférence de
  chargement au démarrage alors que le fichier dynamique de paramètres est désactivé avec l'option `-nosettings`. Lors de la création, du
  chargement ou du déchargement d'un portefeuille, les utilisateurs peuvent également spécifier s'il doit être chargé automatiquement au
  prochain démarrage (voir le [Bulletin #111][news111 load]). Auparavant, tenter d'enregistrer cette préférence avec les paramètres
  désactivés produisait une erreur RPC ou provoquait le plantage de Bitcoin-Qt avec une exception non interceptée après que l'état du
  portefeuille avait déjà changé. Désormais, l'opération se termine avec un avertissement indiquant que la préférence n'a pas pu être
  enregistrée.

- [Core Lightning #9434][] et [#9473][core lightning #9473] corrigent des plantages impliquant des préférences de routage persistantes dans
  `askrene` (voir le [Bulletin
  #316][news316 askrene]). `askrene` stocke les informations de routage dans des couches,
  qui peuvent inclure des biais favorisant ou décourageant des nœuds ou canaux particuliers (voir le [Bulletin #381][news381 biases]). La
  première PR corrige un plantage au démarrage lors de la restauration d'un biais de nœud avec une description provenant d'une couche
  persistante. La restauration des valeurs de biais entrant et sortant réutilisait le tampon de description après sa libération, ce qui
  faisait planter `askrene` et entraînait l'arrêt de `lightningd` parce qu'il traite `askrene` comme un plugin important. La seconde corrige
  un plantage lors de la suppression de biais de canal ou de nœud en les réinitialisant à zéro. Auparavant, l'enregistrement de biais de
  valeur nulle était retiré de la mémoire avant d'être sauvegardé, provoquant un déréférencement de pointeur nul. Désormais, la valeur zéro
  est sauvegardée avant que l'enregistrement ne soit retiré de la mémoire, empêchant la restauration de l'ancien biais après un redémarrage.

- [LND #11061][] poursuit l'implémentation des [offres BOLT12][topic offers] en ajoutant la prise en charge de la signature et de la
  vérification des demandes de facture et des factures à l'aide des [signatures Schnorr][topic schnorr signatures] [BIP340][]. Les
  signatures s'engagent sur une racine de Merkle construite à partir des enregistrements TLV signés des messages. Les validateurs de lecture
  rejettent désormais les signatures invalides au lieu de simplement vérifier qu'une signature est présente. Cela s'appuie sur le codec de
  demande de facture décrit dans le [Bulletin #413][news413 bolt12].

- [LND #11125][] permet aux appelants de réserver des UTXOs du portefeuille jusqu'à ce que la transaction qui les dépense atteigne un nombre
  choisi de confirmations. Auparavant, les réservations expiraient soit après une durée spécifiée, soit étaient supprimées à la première
  confirmation de la transaction de dépense. Des confirmations lentes pouvaient donc dépasser la durée de la réservation, tandis qu'une
  réorg pouvait laisser les entrées non réservées. Désormais, les RPC `LeaseOutput` (voir le [Bulletin #182][news182 leaseoutput]) et
  `FundPsbt` acceptent un nombre de confirmations, permettant aux réservations de rester actives à travers les réorgs et d'ignorer
  l'expiration basée sur le temps. Les appelants peuvent toujours libérer explicitement les réservations, ce qui est nécessaire si une
  transaction est abandonnée. Les réservations temporisées existantes restent le comportement par défaut.

- [LND #11064][] fait en sorte que les messages d'ouverture de canal spécifient explicitement le type de canal, comme l'exige [BOLT2][]. LND
  inclut désormais `channel_type` dans `open_channel`, le répercute dans `accept_channel`, et rejette les messages entrants `open_channel`
  qui l'omettent. Les appelants RPC peuvent toujours omettre un type, auquel cas LND en choisit un en fonction des types de canaux pris en
  charge par les deux pairs.

- [BTCPay Server #7561][] et [#7542][btcpay server #7542] mettent à jour la manière dont les clés API sont stockées et gérées. La première
  PR stocke des hachages et des identifiants de clé dérivés au lieu de conserver indéfiniment en base de données les identifiants en clair.
  Une tâche de nettoyage efface les nouveaux secrets en clair créés une fois qu'ils ont plus de cinq minutes. Après migration, les clés
  Greenfield existantes continuent de s'authentifier, mais leurs secrets ne peuvent plus être récupérés depuis le serveur. La mise à niveau
  supprime également les anciennes clés API Basic-auth de type BitPay et retire cette méthode d'authentification. La révocation d'une clé
  API spécifiée requiert désormais son identifiant plutôt que son secret, et les réponses concernant les clés incluent un champ `id`. La
  seconde PR retire la clé API nouvellement générée de l'URL de redirection vers la page de gestion des clés API, empêchant l'URL d'exposer
  des identifiants via l'historique du navigateur ou les journaux de requêtes.

- [BTCPay Server #7559][] étend la surveillance des paiements Lightning au-delà de la date limite de paiement d'une facture BTCPay, sur
  toute sa période de surveillance configurée. Auparavant, un client pouvait payer une facture Lightning après l'expiration de la facture
  BTCPay, mais BTCPay n'enregistrait pas le paiement. Désormais, l'écouteur utilise la période de surveillance existante, permettant
  d'enregistrer les paiements tardifs reçus pendant cette période. Cela ne modifie pas la date limite de paiement de l'une ou l'autre
  facture et ne détecte pas les paiements indéfiniment.

{% include snippets/recap-ad.md when="2026-09-15 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="35949,34931,36048,36123,36169,36176,9434,9473,11061,11125,11064,7561,7542,7559" %}

[bab del]: https://delvingbitcoin.org/t/babilonia-probabilistic-coinjoin-and-covert-betting/2704
[bab paper]: https://github.com/AdamISZ/babilonia-paper
[sp light ml]: https://groups.google.com/g/bitcoindev/c/qqDYHnnoM7k
[news305 sp light]: /fr/newsletters/2024/05/31/#protocole-client-leger-pour-les-paiements-silencieux
[blindbit gh]: https://github.com/setavenger/blindbit-oracle
[results gh]: https://github.com/bitsagarob/silentpayments-measurements
[sp light draft]: https://github.com/bitsagarob/silentpayments-measurements/blob/master/LIGHT-CLIENT-PROTOCOL-DRAFT.md
[LDK v0.3-rc1]: https://github.com/lightningdevkit/rust-lightning/tree/v0.3-rc1
[ldk 0.3 notes]: https://github.com/lightningdevkit/rust-lightning/blob/v0.3-rc1/CHANGELOG.md
[LDK v0.2.6]: https://github.com/lightningdevkit/rust-lightning/blob/v0.2.6/CHANGELOG.md
[BTCPay Server 2.4.4]: https://github.com/btcpayserver/btcpayserver/releases/tag/v2.4.4
[btcpay 2.4.4 announcement]: https://blog.btcpayserver.org/btcpay-server-2-4-4/
[btcpay billing migration]: https://github.com/btcpayserver/whmcs-plugin/blob/master/GUIDE.md#upgrade-from-v3x-to-v4x
[news418 btcpay]: /fr/newsletters/2026/08/14/#btcpay-server-2-4-2
[news316 timewarp]: /fr/newsletters/2024/08/16/#nouvelle-vulnerabilite-de-manipulation-temporelle-dans-testnet4
[news86 walletnotify]: /en/newsletters/2020/02/26/#bitcoin-core-13339
[news411 http]: /fr/newsletters/2026/06/26/#bitcoin-core-35182
[news420 http]: /fr/newsletters/2026/08/28/#bitcoin-core-35730
[news111 load]: /en/newsletters/2020/08/19/#bitcoin-core-15937
[news316 askrene]: /fr/newsletters/2024/08/16/#core-lightning-7517
[news381 biases]: /fr/newsletters/2025/11/21/#core-lightning-8608
[news413 bolt12]: /fr/newsletters/2026/07/10/#lnd-10832
[news182 leaseoutput]: /en/newsletters/2022/01/12/#lnd-5964
