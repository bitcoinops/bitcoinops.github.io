---
title: 'Bulletin Hebdomadaire Bitcoin Optech #425'
permalink: /fr/newsletters/2026/10/02/
name: 2026-10-02-newsletter-fr
slug: 2026-10-02-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine résume la divulgation responsable de deux vulnérabilités de déni de service affectant d'anciennes versions
d'Eclair et décrit une proposition de synchronisation des libellés de portefeuille entre appareils via un magasin non fiable. Sont également
incluses nos rubriques régulières résumant les propositions et discussions sur la modification des règles de consensus de Bitcoin, annonçant
de nouvelles versions et versions candidates, et décrivant des changements notables dans des logiciels d'infrastructure Bitcoin populaires.

## Nouvelles

- **Divulgation de deux vulnérabilités DoS dans Eclair** : Matt Morehouse a [publié][mm eclair dos] sur Delving Bitcoin la [divulgation
  responsable][topic responsible disclosures] de deux vulnérabilités de déni de service (DoS) affectant Eclair v0.13.1 et les versions
  antérieures. Les deux ont été corrigées dans [Eclair v0.14.0][news407 eclair], publiée en mai, et les utilisateurs exécutant encore une
  version plus ancienne devraient effectuer une mise à niveau. Chaque attaque ne nécessite qu'une poignée de main [BOLT8][] complétée, pas
  un canal.

  La première vulnérabilité se situe dans l'analyse des bits de fonctionnalités. Eclair analysait les bits de fonctionnalités dans un
  message `init` un par un, en allouant plusieurs objets par bit, de sorte qu'un seul message `init` de longueur maximale allouait puis
  libérait environ 300 Mo de mémoire et occupait un thread d'analyse pendant jusqu'à 300 ms. Dans les tests de Morehouse, un attaquant avec
  quelques dizaines de connexions répétant ce message déconnectait tous les pairs du nœud en moins d'une minute et épuisait sa mémoire en
  moins de cinq. Morehouse a trouvé le bogue avec [smite][smite repo], son fuzzer LN, en utilisant son test le plus basique, qui envoie des
  octets bruts comme un seul message et vérifie que la cible répond toujours rapidement à un `ping`. Le correctif a été fusionné en mars
  dans le cadre de [Eclair #3264][], une refactorisation de l'analyse des fonctionnalités qui ne mentionnait pas la vulnérabilité.

  La seconde vulnérabilité se situe dans les requêtes gossip. [BOLT7][] a supprimé l'encodage zlib pour les messages
  `query_short_channel_ids` en avril 2022, et Eclair a cessé de l'envoyer le même mois mais a continué à l'accepter. La décompression zlib
  n'avait aucune limite de sortie, de sorte qu'un message de 64 ko pouvait se dilater jusqu'à 64 Mo et environ 17 millions d'objets, et un
  flot de tels messages mettait un nœud hors ligne en quelques secondes. Morehouse l'a trouvée après le premier bogue en utilisant un LLM
  pour rechercher dans la base de code d'Eclair d'autres endroits où un pair pouvait imposer au nœud bien plus de travail que celui qu'il
  dépense lui-même. Le correctif est [Eclair #3263][].

- **Proposition de synchronisation des libellés de portefeuille** : Jakub a [publié][label sync ml] sur la liste de diffusion Bitcoin-Dev
  pour évaluer l'intérêt d'une standardisation de la synchronisation des [libellés de portefeuille][topic wallet labels] entre portefeuilles
  via un magasin partagé non fiable avant de rédiger une spécification. Bien que [BIP329][] ait standardisé un format d'exportation des
  libellés (voir le [Bulletin
  #215][news215 label]), le déplacement de libellés entre des portefeuilles
  utilisant le même [descripteur][topic descriptors], comme un coordinateur et un portefeuille en lecture seule, reste un cycle manuel
  d'exportation et d'importation, de sorte que les décisions de sélection de pièces sont prises sans les libellés associés.

  Dans le cadre de la proposition, les portefeuilles dérivent un emplacement de stockage et des clés de chiffrement à partir d'une forme
  canonique du descripteur, sans aucune clé privée, afin que les portefeuilles partageant un descripteur trouvent les mêmes données sans
  configuration. Des enregistrements BIP329 non modifiés circulent à l'intérieur d'une enveloppe de chiffrement authentifié. Chaque
  enregistrement est stocké avec l'heure à laquelle il a été écrit, de sorte que lorsque deux portefeuilles modifient le même libellé, la
  modification la plus récente prévaut. Comme BIP329 n'a aucun moyen de supprimer un libellé, une suppression est enregistrée comme un
  marqueur qui retire le libellé des autres portefeuilles. Jakub propose Nostr comme transport de référence, mais le protocole n'exige qu'un
  service capable de stocker et de renvoyer des données. Le portefeuille Bitcoin Safe synchronise déjà les libellés de cette manière via
  Nostr. Jakub a demandé si les clés de chiffrement devaient être dérivées du descripteur, ce qui permet à un portefeuille de restaurer ses
  libellés à partir du seul descripteur mais les expose à quiconque a détenu les xpubs, ou d'un secret séparé. Il a également demandé s'il
  fallait utiliser une paire de clés partagée entre appareils ou un appairage par appareil, et comment définir la forme canonique du
  descripteur.

  Craig Raw a répondu que la synchronisation des libellés devrait faire partie d'une spécification plus large de communication
  inter-portefeuilles, qui devrait inclure d'autres cas d'usage tels que les [PSBTs][topic psbt], les configurations multisig et les
  confirmations de paiement. Il s'est également opposé à l'utilisation de Nostr comme protocole de transport de référence, puisque l'échange
  de données financières devrait optimiser la confidentialité plutôt que la résistance à la censure, et a noté qu'il travaille sur un BIP
  pour les descripteurs de sortie canoniques.

## Modification du consensus

_Une nouvelle section mensuelle résumant les propositions et discussions sur la modification des règles de consensus de Bitcoin._

- **Poursuite de la discussion sur les types de sorties PQC** : Suite au [résumé][news421 pqout] du mois dernier du fil Delving Bitcoin de
  Pieter Wuille sur les types de sorties [post-quantiques][topic quantum resistance], Antoine Riard a [répondu][ar delving pqout] en
  affirmant qu'une sortie [P2TRv2][news403 pqout] dont les chemins de dépense vulnérables au quantique peuvent ensuite être désactivés
  uniquement à l'intérieur de ce type de sortie est acceptable parce que les utilisateurs y adhèrent en y recevant, évitant un gel générique
  des sorties existantes. Il préfère ne pas regrouper [CISA][topic cisa] avec ce changement, et a suggéré un type ultérieur basé sur
  [P2MR][news393 p2mr] avec un nouveau style de témoin, plus des versions de feuille optionnelles afin que certaines pièces puissent
  conserver un chemin sécurisé par secp256k1 après que d'autres aient été désactivées.

  Conduition a [soutenu][c delving pqout deriv] que même P2TRv2 n'est pas une simple augmentation de version de témoin : les portefeuilles
  qui utilisent réellement le chemin post-quantique ont toujours besoin de nouvelles normes pour dériver les clés PQ, remplaçant les flux de
  travail de type [BIP32][]. Wuille a [répondu][pw delving pqout cisa2] que CISA a peu de chances de faire bouger la longue traîne des
  portefeuilles dont les utilisateurs ne se soucient pas des frais ou du PQ, et que ni P2TRv2 ni P2MR ne sont des types de sorties
  catégoriquement résistants au quantique, car tous deux reposent sur le fait que quelqu'un décide quand cesser d'utiliser secp256k1. P2MR
  laisse le propriétaire décider, mais Wuille pense que la réutilisation d'adresse et le partage de clé publique sont trop ancrés pour que
  la plupart des utilisateurs en bénéficient.

  Antoine Poinsot a [convenu][ap delving pqout] que P2TRv2 et CISA tirent dans des directions opposées : les utilisateurs qui veulent CISA
  sans s'attendre à une désactivation précoce de secp256k1 peuvent refuser P2TRv2 ou, pire, l'adopter sans chemin de dépense post-quantique,
  compromettant une désactivation ultérieure de secp256k1. Il a également noté que les livrer en tant que types de sorties séparés pourrait
  laisser des traces distinctives si les deux deviennent largement utilisés. Conduition et Wuille ont poursuivi la discussion pour savoir si
  la protection de P2MR est réalisable en pratique, et Conduition a [proposé][c delving pqout both] de déployer les deux types de sorties et
  de laisser les utilisateurs choisir.

- **Agrégation de signatures à l'échelle du bloc via des SNARKs** : Conduition a [publié][c delving snark] sur Delving Bitcoin une esquisse
  de conception pour compresser de nombreuses signatures [post-quantiques][topic quantum resistance] dans un bloc en un seul SNARK (voir
  aussi la [proposition][eh delving stark] antérieure d'Ethan Heilman et le [Bulletin #412][news412 stark]). Les signatures basées sur le
  hachage sont peu coûteuses à vérifier mais volumineuses ; une remise témoin suffisamment grande pour les rendre compétitives en termes de
  frais ferait croître le stockage d'archives jusqu'à des téraoctets par an (voir Le [Bulletin #417][news417 pqwit]).

  Conduition s'attend à ce que de grands pools de minage produisent eux-mêmes les preuves et soutient que les nœuds ordinaires ne devraient
  jamais exécuter un prouveur. Sa conception utilise un circuit d'agrégation sur mesure plutôt qu'une machine virtuelle (VM) à usage
  général, une seule preuve plate plutôt que des preuves récursives, et une variante de [SPHINCS][news383 sphincs] avec WOTS+C plutôt que
  SLH-DSA. La vérification de la variante prend le même nombre d'opérations de hachage pour chaque signature, alors que ce nombre pour
  SLH-DSA dépend de choix faits par le signataire, de sorte qu'un circuit pour celui-ci devrait être dimensionné pour le cas le plus
  coûteux. Les plus petites preuves SNARK basées sur le hachage font typiquement 300 à 500 ko. Pour apaiser les inquiétudes sur la solidité
  de la preuve proposée, il a esquissé plusieurs mécanismes de récupération ou de retrait selon les conditions futures. Il s'oppose à ce
  qu'à la fois les signatures brutes et un SNARK soient autorisés comme formats de bloc valides, ce qui permettrait aux mineurs de miner
  pendant qu'une preuve est produite au lieu de miner des blocs vides, parce que les limites de ressources devraient supposer le pire cas.
  Une extrapolation naïve à partir des benchmarks SHA256 de Flock, un prouveur SNARK pour circuits de hachage, a suggéré environ 20 secondes
  pour prouver un bloc de 10 000 signatures sur un CPU à 10 threads, avec l'espoir de réduire ce chiffre en dessous de 10 secondes ;
  Conduition a noté que personne n'a encore testé un circuit de vérification SPHINCS dans Flock.

  Jonas Nick a [signalé][jn delving snark] des travaux montrant que la preuve en oracle aléatoire d'un SNARK ne couvre pas automatiquement
  l'utilisation récursive du même SNARK. ZmnSCPxj a [averti][zmn delving snark] qu'un DoS dans le code du prouveur utilisé par les mineurs
  pourrait bloquer la production de blocs, et a suggéré d'inclure le prouveur dans Bitcoin Core afin qu'il soit revu.

- **Bornes sur la longueur de chaîne avec les correctifs de time warp de BIP54** : Pieter Wuille a [publié][pw delving timewarp] sur Delving
  Bitcoin une preuve que les deux règles d'horodatage de la proposition de [nettoyage du consensus][topic consensus cleanup] ([BIP54][])
  suffisent à borner le nombre de blocs pouvant être minés dans une chaîne d'un travail donné. La borne est vérifiée par machine dans Lean,
  de sorte que seule l'affirmation prouvée a besoin d'être revue. La première règle ([time warp][topic time warp] classique) exige que le
  premier bloc d'une période de retargeting ne soit pas antérieur de plus de 7 200 secondes au bloc précédent ; la seconde (Murch–Zawy ;
  voir le [Bulletin #316][news316 timewarp]) exige que le dernier bloc d'une période ne soit pas antérieur au premier. Ensemble, elles
  bornent le taux de blocs à long terme à environ un bloc toutes les 9 minutes 56 secondes, plus un nombre borné de blocs supplémentaires
  payés par des augmentations de difficulté.

  Pour une chaîne à la hauteur 966 270, la formule autorise au plus 1 012 794 blocs, soit environ 3 300 fois plus serré qu'en l'absence des
  deux règles. Omettre l'une ou l'autre laisse une limite supérieure à 3,34 milliards de blocs. La plus longue chaîne construite rapportée
  par Wuille est de 1 007 326 blocs.

  La motivation de Wuille était la [protection DoS][news216 presync] du présync des en-têtes de Bitcoin Core, qui pourrait s'appuyer sur
  cette borne une fois BIP54 enfoui. Zawy a discuté de formulations alternatives. Wuille a ensuite prouvé une borne inférieure
  complémentaire sur le travail requis pour produire une chaîne d'une longueur donnée dans un temps donné.

- **Comparaison de propositions de covenants pour les coffres** : Lillian Wang a [publié][lw delving vaults] sur Delving Bitcoin et
  [cross-posté][lw ml vaults] sur la liste de diffusion Bitcoin-Dev un [rapport][vault report] comparant des constructions simplifiées de
  [coffres][topic vaults] utilisant des transactions présignées, [`OP_CHECKTEMPLATEVERIFY`][topic op_checktemplateverify] (CTV),
  [`SIGHASH_ANYPREVOUT`][topic sighash_anyprevout] / `SIGHASH_ANYPREVOUTANYSCRIPT` (APO/APOAS), `OP_TXHASH`,
  [`OP_CHECKCONTRACTVERIFY`][topic matt] (CCV, [BIP443][]), et un [Purrfect Vault][news291 cat vault] basé sur [`OP_CAT`][topic op_cat].

  Le rapport conclut que CTV convient aux coffres simples avec sorties précalculées, que CCV prend le mieux en charge les retraits partiels
  et le choix d'une adresse de retrait au moment du déclenchement, et que TXHASH offre davantage de flexibilité d'engagement au prix d'une
  responsabilité accrue pour le concepteur. APOAS et CAT peuvent être plus attrayants si leurs applications plus larges hors coffres sont
  également valorisées.

  askii21m a [noté][askii delving vaults] que les signatures APOAS peuvent être combinées à travers deux dépôts vers la même adresse de
  coffre dans une seule transaction qui ne crée la sortie attendue qu'une seule fois, la valeur du second dépôt allant aux frais (une
  demi-dépense), parce qu'APOAS ne s'engage ni sur le nombre d'entrées ni sur l'index de l'entrée, de sorte que ne jamais réutiliser une
  adresse de coffre est une exigence plutôt qu'une recommandation.

- **Depots pour des canaux Lightning probabilistes** : John Law a [publié][jl delving depots] sur Delving Bitcoin un [protocole][depots
  paper] dans lequel un opérateur finance une unique sortie taproot à durée limitée (un depot) pouvant héberger des canaux Lightning pour
  plusieurs milliers ou millions d'utilisateurs. Les utilisateurs achètent ces canaux à l'opérateur avec un paiement Lightning plutôt qu'en
  plaçant leurs propres fonds onchain. Ces soldes sont généralement trop faibles pour justifier une réclamation onchain, donc un depot
  remplace la petite réclamation garantie de chaque utilisateur par une chance d'en obtenir une grande de même valeur espérée, ce qui borne
  combien de réclamations peuvent jamais aller onchain.

  Chaque canal acheté se voit attribuer une supposition secrète, choisie par l'utilisateur, entre zéro et un grand nombre premier (P), et a
  une chance de 1/P d'être un "succès" après l'expiration du depot. Avant l'expiration, les utilisateurs sont censés vider leurs canaux du
  depot en payant via Lightning (potentiellement vers un depot ultérieur) et en révélant leurs suppositions pour révoquer ces canaux afin
  qu'ils ne puissent pas être des succès. Après expiration, l'opérateur révèle une cible : un canal est un succès si sa supposition
  correspond. Si aucun canal n'est un succès, l'opérateur récupère la sortie. Si exactement un canal est un succès, cet utilisateur peut
  forcer le depot onchain et recevoir P fois son solde offchain (ainsi, une probabilité de 1/P d'un paiement de P fois a la même valeur
  espérée que le solde réel de l'utilisateur). Si deux canaux ou plus sont des succès, le depot est brûlé, ce qui empêche les utilisateurs
  de collecter plus que ce que le depot contient.

  Selon Law, cela maintient l'empreinte onchain à environ 1 ou 2 vbytes par utilisateur et par an, et évite une ruée massive de transactions
  forcées onchain parce qu'un depot se résout dans un ensemble de transactions de taille constante quel que soit le nombre d'utilisateurs
  qu'il héberge. La sécurité repose sur la [pénalisation des perturbateurs][news329 opr] : une partie qui perturbe (par exemple en refusant
  de coopérer à un vidage) doit s'attendre à perdre une fraction configurée du dommage qu'elle inflige. Les depots nécessitent
  [`OP_CHECKSIGFROMSTACK`][topic op_checksigfromstack] et [`OP_CHECKTEMPLATEVERIFY`][topic op_checktemplateverify]. Ils sont plus efficaces
  avec `OP_PAIRCOMMIT` ([BIP442][]), `OP_MUL`, et `OP_MOD`, mais ne les requièrent pas.

  Anzus a demandé ce qui se passe si un utilisateur manque l'expiration ou perd un appareil. Law a [répondu][jl delving depots recover] que,
  contrairement à ses [arbres de temporisation][topic timeout trees], l'opérateur ne peut pas faire basculer un depot sans un secret fourni
  par l'utilisateur, que les portefeuilles peuvent automatiser un vidage anticipé, et que la récupération nécessite les paramètres du depot
  et l'état du canal en plus d'une seed.

## Mises à jour et versions candidates

_Nouvelles versions et versions candidates pour des projets d'infrastructure Bitcoin populaires. Veuillez envisager de mettre à niveau vers
les nouvelles versions ou d'aider à tester les versions candidates._

- [LND v0.21.4-beta.rc1][] est une version candidate pour une version de maintenance de cette implémentation populaire de nœud LN. Elle
  inclut le correctif de synchronisation des [annonces de canaux][topic channel announcements] et la restriction sur les nouveaux canaux
  hérités décrits dans la section des changements notables du code ci-dessous. D'autres correctifs traitent des [HTLCs][topic htlc] en
  attente, de l'annulation involontaire de factures [AMP][topic amp], et des échecs de migration du graphe SQL. `WalletKit` peut désormais
  réserver des sorties jusqu'à ce que leur transaction de dépense atteigne une profondeur de confirmation spécifiée. La version exige
  également des types de canaux explicites à l'ouverture des canaux.

- [LND v0.20.5-beta.rc1][] est une version candidate pour une version de maintenance de la branche 0.20 de LND. Elle rétroporte plusieurs
  correctifs également inclus dans 0.21.4-beta.rc1, y compris ceux pour les HTLCs en attente, l'annulation de factures AMP et la
  synchronisation des canaux, et ajoute des bornes à l'analyse des charges utiles onion.

## Changements notables dans le code et la documentation

_Changements récents notables dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning repo], [Eclair][eclair repo],
[LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet Interface (HWI)][hwi repo], [Rust Bitcoin][rust
bitcoin repo], [BTCPay Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement Proposals (BIPs)][bips repo], [Lightning
BOLTs][bolts repo], [Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition repo], et [BINANAs][binana repo]._

- [Bitcoin Core #29278][] ajoute une option de configuration `-maxfeerate` qui plafonne par défaut le taux de frais des transactions du
  portefeuille à 0,10 BTC/kvB (10 000 sat/vB). Auparavant, l'option `-maxtxfee` était documentée comme un plafond de frais absolu.
  Cependant, certaines vérifications interprétaient également le même montant comme des frais par 1 000 vB (voir le [Bulletin #54][news54
  maxtxfee]). La nouvelle option sépare la limite de taux de frais de la limite de frais totaux et s'applique à la création de transactions,
  à l'[augmentation des frais][topic rbf], au [CPFP][topic cpfp] et à la diffusion ordinaire des transactions du portefeuille.

- [Bitcoin Core #35984][] corrige un bogue où la signature de [PSBT][topic psbt] pouvait produire une signature `SIGHASH_SINGLE` sans sortie
  correspondante. Ce type de sighash s'engage sur la sortie au même index que l'entrée signée. Si la sortie correspondante est absente, la
  signature héritée produit une signature sur un hachage constant (voir le [Bulletin
  #207][news207 single]). Cette signature peut être réutilisée pour dépenser
  d'autres UTXOs contrôlés par la même clé, à condition que la sortie correspondante reste absente. Bitcoin Core laisse désormais ces
  entrées non signées pour l'hérité et segwit v0, tout en signant les autres entrées de la PSBT, étendant une vérification déjà présente
  dans la signature de transactions brutes.

- [Bitcoin Core #35301][] commence l'implémentation de [BIP352][] des [silent payments][topic silent payments] en ajoutant la prise en
  charge de l'encodage et du décodage des adresses, de la dérivation des sorties de paiement [taproot][topic taproot] à partir d'entrées de
  transaction éligibles, et de l'analyse des transactions pour détecter des paiements à un destinataire. Elle ajoute également la prise en
  charge de libellés pour distinguer les paiements vers différentes adresses dérivées et identifier la monnaie rendue. L'implémentation
  s'appuie sur le module silent-payments de libsecp256k1 (voir le [Bulletin #415][news415 silent]). Cependant, cette PR n'active pas encore
  l'envoi ou la réception de silent payments via les RPCs du portefeuille ou l'interface graphique.

- [Bitcoin Core #36312][] corrige une fuite de confidentialité dans la fonctionnalité expérimentale et optionnelle de diffusion privée de
  transactions (voir le [Bulletin #388][news388 private broadcast]). Auparavant, le fait de [décourager un pair au comportement
  incorrect][news106 discouragement] pouvait déconnecter à la fois les connexions ordinaires et les connexions de diffusion privée vers la
  même adresse. Un pair malveillant pouvait délibérément déclencher ces déconnexions pour relier une connexion de diffusion privée aux
  connexions ordinaires du nœud, affaiblissant la [confidentialité de l'origine des transactions][topic transaction origin privacy].
  Désormais, les pairs de diffusion privée au comportement incorrect sont déconnectés sans décourager leurs adresses, et le découragement
  des pairs ordinaires laisse intactes les connexions de diffusion privée vers les mêmes adresses.

- [Bitcoin Core #36284][] corrige un bogue où le portefeuille pouvait rejeter un paiement malgré des fonds éligibles suffisants lorsque
  l'évitement des dépenses partielles est activé via l'option `-avoidpartialspends` (voir Le [Bulletin #6][news6 avoidpartial]) ou le
  drapeau `avoid_reuse` du portefeuille (voir le [Bulletin #52][news52 avoid reuse]). L'évitement des dépenses partielles regroupe les
  sorties payées à la même adresse pendant la [sélection de pièces][topic coin selection] afin de réduire la [liaison des sorties][topic
  output linking]. Auparavant, si un groupe échouait aux vérifications d'éligibilité (p. ex. la limite sur les ancêtres non confirmés), sa
  valeur était soustraite deux fois du montant disponible pour la sélection. Désormais, la valeur de chaque groupe rejeté n'est soustraite
  qu'une seule fois.

- [Bitcoin Core #35752][] corrige la gestion des erreurs lors du chiffrement d'un portefeuille, du changement de sa phrase de passe de
  chiffrement, ou de l'ajout de clés privées. Auparavant, un échec d'écriture dans la base de données pouvait faire apparaître un changement
  de phrase de passe comme réussi, mais seule l'ancienne phrase de passe fonctionnait après le rechargement du portefeuille. Le processus de
  chiffrement pouvait également signaler un succès malgré l'absence d'enregistrements de clés requis ou le maintien de clés privées en clair
  dans la base de données, tandis qu'un échec du commit en base de données pouvait arrêter Bitcoin Core. Des échecs d'insertion de clés
  privées pouvaient laisser des clés uniquement en mémoire, les faisant disparaître du portefeuille au rechargement. Désormais, le
  portefeuille vérifie les opérations de base de données, annule les mises à jour de chiffrement échouées, et ne met à jour ses clés en
  mémoire qu'après la réussite des écritures correspondantes, permettant de réessayer les opérations échouées. La PR empêche également qu'un
  changement de phrase de passe échoué laisse un portefeuille précédemment verrouillé déverrouillé et signale séparément les échecs de base
  de données ou de chiffrement des erreurs de phrase de passe incorrecte.

- [Bitcoin Core #35813][] ajoute un RPC de portefeuille `listrawtransactions` capable de lister chaque transaction connue du portefeuille,
  en renvoyant une entrée par transaction avec son hexadécimal brut. Le RPC existant `listtransactions` renvoie des écritures comptables :
  un auto-transfert vers une adresse de réception peut apparaître à la fois comme un envoi et une réception, tandis qu'un transfert
  entièrement vers des adresses de monnaie rendue peut être omis. Les paramètres `count` et `skip` fournissent la pagination, et `verbose`
  ajoute les détails décodés de la transaction.

- [BIPs #2276][] et [#2277][bips #2277] corrigent des règles de finalisation de [PSBT][topic psbt] qui pouvaient supprimer des informations
  nécessaires à une signature ultérieure ou à l'extraction de transaction. Le premier supprime l'exigence de [BIP376][] de supprimer
  `PSBT_IN_WITNESS_UTXO` lors de la finalisation d'une entrée de [silent-payment][topic silent payments] (voir le [Bulletin #401][news401
  bip376]). D'autres entrées [taproot][topic taproot] dans la même transaction peuvent encore nécessiter le montant et le script de cette
  sortie dépensée pour calculer leurs signatures. Le second met à jour [BIP370][] afin de conserver les identifiants de sorties précédentes,
  les numéros de séquence et les [locktimes][topic timelocks] requis après la finalisation d'une entrée PSBTv2. La suppression de ces champs
  pouvait invalider la PSBT ou modifier la transaction extraite. Il supprime également une instruction erronée de [BIP371][] de supprimer
  les données de dérivation taproot de sortie pendant la finalisation de l'entrée.

- [LDK #4993][] corrige un bogue qui pouvait amener un portefeuille à dépenser des entrées réservées dans une transaction en conflit avec un
  [splice][topic splicing] non confirmé. Auparavant, si LDK rejetait une contribution d'augmentation de frais [RBF][topic rbf] parce que le
  canal avait déjà été fermé de force, il pouvait demander au portefeuille de libérer des entrées encore nécessaires au splice d'origine. Au
  fil des tentatives successives d'augmentation de frais, le portefeuille pouvait également recevoir des instructions de libération en
  double ou conserver des réservations après qu'elles n'étaient plus nécessaires. Désormais, chaque contribution de financement enregistre
  quelles entrées et sorties elle a héritées des tentatives précédentes, de sorte qu'un échec indique au portefeuille de ne libérer que les
  réservations propres à cette contribution. La PR ajoute également des informations d'erreur et des requêtes sur les réservations pour
  aider les applications à réessayer en sécurité des contributions échouées.

- [LND #11173][] corrige un bogue où une réponse de plage de canaux invalide ou surdimensionnée pouvait bloquer la synchronisation initiale
  des [annonces de canaux][topic channel announcements] jusqu'à la prochaine tentative planifiée. LND limite les réponses à un total de 100
  000 IDs courts de canaux (SCIDs) par requête (voir le [Bulletin #417][news417 scids]). Désormais, lorsqu'un autre pair éligible est
  disponible, LND réessaie immédiatement la synchronisation avec lui et exclut temporairement le pair défaillant de la sélection. La
  connexion existante au pair défaillant reste ouverte.

- [LND #11190][] met à jour LND pour rejeter les factures [BOLT11][] contenant plusieurs champs de hachage de paiement (`p`), même lorsque
  les hachages sont identiques. Auparavant, LND utilisait le premier hachage de paiement pris en charge et ignorait les autres, comme
  recommandé par la spécification BOLT11. Cependant, d'autres parseurs de factures peuvent choisir un hachage différent. Si le parseur de
  factures d'un service et son nœud Lightning utilisent des hachages différents, le service pourrait mal interpréter un retrait terminé
  comme impayé, ce qui pourrait conduire à deux paiements effectués. Rejeter les doublons supprime cette ambiguïté. BOLT11 exige déjà des
  créateurs de factures qu'ils incluent exactement un champ `p` ; [BOLTs #1357][] propose d'exiger des lecteurs qu'ils rejettent les
  doublons.

- [LND #11212][] supprime la prise en charge de l'ouverture ou de l'acceptation de nouveaux canaux utilisant le format d'engagement hérité,
  en accord avec [BOLT2][] (voir le [Bulletin #305][news305 commitments]). Les engagements hérités dérivent la clé de la sortie payant la
  contrepartie (`to_remote`) à l'aide d'un point par engagement. Si un nœud perd l'état de son canal, récupérer des fonds depuis la
  transaction d'engagement de son pair requiert donc que ce pair fournisse le point manquant. Les canaux à clé distante statique conservent
  cette clé de sortie inchangée à travers les mises à jour du canal, évitant cette dépendance (voir le [Bulletin
  #67][news67 static remote key]). Les canaux hérités existants restent
  utilisables. Eclair a effectué le même changement l'an dernier (voir Le [Bulletin #378][news378 eclair legacy]).

- [LND #11258][] corrige un bogue où des [HTLCs][topic htlc] relayés pouvaient rester non résolus si LND redémarrait après la fermeture du
  canal sortant et le nettoyage de ses enregistrements. Auparavant, le nettoyage du canal pouvait supprimer une réponse de règlement ou
  d'échec reçue avant qu'elle ne soit verrouillée dans le canal entrant. Cela pouvait laisser le HTLC entrant bloqué, entraînant une
  fermeture forcée inutile du canal entrant et des frais onchain supplémentaires. Désormais, LND enregistre les réponses en attente
  séparément du canal fermé, conserve les informations nécessaires pour les faire correspondre aux HTLCs entrants, et les rejoue au
  démarrage.

{% include snippets/recap-ad.md when="2026-10-06 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="3263,3264,29278,35984,35301,36312,36284,35752,35813,11173,11190,1357,11212,11258,2276,2277,4993" %}

[mm eclair dos]: https://delvingbitcoin.org/t/disclosure-dos-vulnerabilities-fixed-in-eclair-v0-14-0/2914
[news407 eclair]: /fr/newsletters/2026/05/29/#eclair-v0-14-0
[smite repo]: https://github.com/lnfuzz/smite
[label sync ml]: https://groups.google.com/g/bitcoindev/c/p6UUOdGi9YI
[news215 label]: /en/newsletters/2022/08/31/#wallet-label-export-format
[news421 pqout]: /fr/newsletters/2026/09/04/#poursuite-de-la-discussion-sur-les-types-de-sorties-pqc
[news403 pqout]: /fr/newsletters/2026/05/01/#discussion-d-un-type-de-sortie-post-quantique
[news393 p2mr]: /fr/newsletters/2026/02/20/#bips-1670
[ar delving pqout]: https://delvingbitcoin.org/t/pqc-output-type-discussion/2749/18
[c delving pqout deriv]: https://delvingbitcoin.org/t/pqc-output-type-discussion/2749/20
[pw delving pqout cisa2]: https://delvingbitcoin.org/t/pqc-output-type-discussion/2749/22
[ap delving pqout]: https://delvingbitcoin.org/t/pqc-output-type-discussion/2749/32
[c delving pqout both]: https://delvingbitcoin.org/t/pqc-output-type-discussion/2749/38
[c delving snark]: https://delvingbitcoin.org/t/block-wide-signature-aggregation-via-snarks/2875
[eh delving stark]: https://delvingbitcoin.org/t/post-quantum-signatures-and-scaling-bitcoin-with-starks/1584
[news383 sphincs]: /fr/newsletters/2025/12/05/#optimisations-de-signature-post-quantique-slh-dsa-sphincs
[news412 stark]: /fr/newsletters/2026/07/03/#evaluation-de-performance-de-l-agregation-stark-pour-slh-dsa
[news417 pqwit]: /fr/newsletters/2026/08/07/#engagement-segwit-vers-des-donnees-de-temoin-post-quantiques
[jn delving snark]: https://delvingbitcoin.org/t/block-wide-signature-aggregation-via-snarks/2875/8
[zmn delving snark]: https://delvingbitcoin.org/t/block-wide-signature-aggregation-via-snarks/2875/4
[pw delving timewarp]: https://delvingbitcoin.org/t/bounds-on-chain-length-with-bip-54-timewarp-fixes/2899
[news316 timewarp]: /fr/newsletters/2024/08/16/#nouvelle-vulnerabilite-de-manipulation-temporelle-dans-testnet4
[news216 presync]: /fr/newsletters/2022/09/07/#bitcoin-core-25717
[lw delving vaults]: https://delvingbitcoin.org/t/comparing-bitcoin-covenant-proposals-for-vaults/2877
[lw ml vaults]: https://groups.google.com/g/bitcoindev/c/Tv4k9kK5KYA
[vault report]: https://raw.githubusercontent.com/Skyler-Cloud/Bitcoin-Vault-Comparison/main/bitcoin-vault-comparison.pdf
[askii delving vaults]: https://delvingbitcoin.org/t/comparing-bitcoin-covenant-proposals-for-vaults/2877/4
[news291 cat vault]: /fr/newsletters/2024/02/28/#prototype-simple-de-coffre-fort-utilisant-op-cat
[jl delving depots]: https://delvingbitcoin.org/t/depots-theft-proof-self-custodial-bitcoin-for-billions-of-users/2892
[depots paper]: https://github.com/JohnLaw2/ln-depots/blob/main/depots_v1.0.pdf
[jl delving depots recover]: https://delvingbitcoin.org/t/depots-theft-proof-self-custodial-bitcoin-for-billions-of-users/2892/10
[news329 opr]: /fr/newsletters/2024/11/15/#protocole-de-resolution-de-paiement-offchain-base-sur-mad-opr
[LND v0.21.4-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.21.4-beta.rc1
[LND v0.20.5-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.20.5-beta.rc1
[news54 maxtxfee]: /en/newsletters/2019/07/10/#bitcoin-core-16257
[news207 single]: /en/newsletters/2022/07/06/#rust-bitcoin-1024
[news388 private broadcast]: /fr/newsletters/2026/01/16/#bitcoin-core-29415
[news106 discouragement]: /en/newsletters/2020/07/15/#bitcoin-core-19219
[news6 avoidpartial]: /fr/newsletters/2018/07/31/#bitcoin-core-12257
[news52 avoid reuse]: /en/newsletters/2019/06/26/#bitcoin-core-13756
[news305 commitments]: /fr/newsletters/2024/05/31/#bolts-1092
[news378 eclair legacy]: /fr/newsletters/2025/10/31/#eclair-3173
[news67 static remote key]: /en/newsletters/2019/10/09/#lnd-3365
[news415 silent]: /fr/newsletters/2026/07/24/#libsecp256k1-1765
[news417 scids]: /fr/newsletters/2026/08/07/#lnd-10992
[LDK #4993]: https://git.rust-bitcoin.org/lightningdevkit/rust-lightning/pulls/4993
[news401 bip376]: /fr/newsletters/2026/04/17/#bips-2089
