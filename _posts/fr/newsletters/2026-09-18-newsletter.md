---
title: 'Bulletin Hebdomadaire Bitcoin Optech #423'
permalink: /fr/newsletters/2026/09/18/
name: 2026-09-18-newsletter-fr
slug: 2026-09-18-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine résume une analyse des contrôleurs de difficulté des pools de minage qui laissent de côté les mineurs ralentis,
décrit une proposition d'amélioration au téléchargement initial des blocs d'Utreexo, et renvoie vers une ébauche de BIP pour spécifier des clés
internes taproot non dépensables. Sont également incluses nos rubriques régulières décrivant les changements récents dans les services et
logiciels clients, annonçant de nouvelles versions et versions candidates, et décrivant des changements notables dans des logiciels
d'infrastructure Bitcoin populaires.

## Nouvelles

- **Contrôleurs vardiff qui laissent de côté les mineurs ralentis :** Eric Price a [publié][price vardiff] sur Delving Bitcoin une analyse
  de la manière dont les [pools de minage][topic pooled mining] ajustent la difficulté pour un mineur qui ralentit. Un pool attribue à
  chaque mineur une difficulté de share, une cible plus facile que celle du réseau qu'un candidat d'en-tête de bloc doit satisfaire pour
  être soumis comme share. Un logiciel appelé contrôleur de difficulté variable (vardiff), exécuté dans le pool ou dans un proxy entre le
  mineur et le pool, augmente ou diminue cette difficulté en fonction de la rapidité d'arrivée des shares du mineur, dans le but d'obtenir
  un rythme stable. Un mineur qui ralentit conserve la difficulté réglée pour sa vitesse précédente, et ne produit donc que peu de shares.
  Un contrôleur qui ne se met à jour que lorsque des shares arrivent peut ne pas remarquer le ralentissement.

  Price soutient qu'ajuster les paramètres du contrôleur ne peut pas corriger cela, car le contrôleur ne peut pas estimer un débit à partir
  de shares qui n'arrivent pas. Un contrôleur qui ne recalcule qu'à la réception d'une share peut maintenir la difficulté trop élevée
  indéfiniment. Sa correction consiste en un minuteur qui abaisse la difficulté chaque fois qu'un intervalle fixe s'écoule sans qu'une share
  ne provienne du mineur. L'implémentation de référence de Stratum v2 le fait déjà, bien qu'elle récupère lentement pour les mineurs ayant
  des connexions de longue durée. Ckpool ne recalcule qu'à partir des shares. Il a publié un [proxy de shaping][shape proxy] qui supprime
  une fraction des shares d'un mineur afin que les opérateurs puissent tester si leur pool abaisse bien la difficulté.

  Anthony Towns a [suggéré][towns vardiff] de gérer cela dans le proxy local ou la passerelle utilisés dans les déploiements de Stratum v2
  et de [DATUM][news325 datum], par exemple en divisant par deux la difficulté d'une connexion après 30 secondes sans share. Price a
  approuvé cette idée et a soutenu dans un [fil séparé][price frontier] que le contrôle par mineur doit se trouver au dernier saut qui voit
  encore les shares de chaque mineur.

- **Améliorations du téléchargement initial des blocs d'Utreexo** : Davidson Souza a [publié][utreexo ibd del] sur Delving Bitcoin une
  manière d'améliorer les performances de [Utreexo][topic utreexo] pendant le téléchargement initial des blocs (IBD). Utreexo est un
  accumulateur dynamique qui représente l'ensemble UTXO comme une forêt d'arbres de merkle parfaits, permettant aux nœuds de ne stocker que
  les racines. L'objectif est de réduire les exigences de stockage d'un nœud validant au prix d'une augmentation de la bande passante,
  puisque chaque vérification de transaction nécessite une preuve d'inclusion qui lui est ajoutée. Chaque preuve d'inclusion a une taille
  similaire à celle du bloc auquel elle est liée, pour un volume total de données d'environ 1,3 To. Même avec une mise en cache étendue des
  UTXO récemment dépensés, les données de preuve pour les suppressions explicites pèsent environ 200 Go. La proposition éliminerait le
  besoin de preuves de suppression pendant l'IBD, ce qui aboutirait à une surcharge de preuve proche de zéro.

  Selon le BIP181, actuellement en discussion dans [BIPs #1923], Utreexo dispose d'une opération `modify` qui effectue à la fois l'ajout et
  la suppression d'une sortie dans l'arbre. La première suit un processus en plusieurs étapes qui exploite un cycle de
  destruction-et-déplacement, tandis que la seconde fonctionne en supprimant un nœud de l'arbre et en poussant le sibling à la position où
  se trouvait leur parent. Souza et d'autres développeurs ont proposé de modifier l'opération d'ajout pour inclure une suppression
  implicite. Si vous savez à l'avance qu'un UTXO a été dépensé, vous pouvez éviter de l'ajouter à l'arbre et simplement pousser directement
  la racine vers le haut dans l'arbre, comme l'exige l'opération de suppression.

  L'un des points critiques est de savoir comment déterminer quels UTXO ont déjà été dépensés. La proposition de Souza exploite le fichier
  d'indices [SwiftSync][topic swiftsync], un fichier dont l'objectif est précisément de garder la trace des sorties dépensées, tout en
  conservant aussi un agrégat de hachage pour vérifier si le fichier fourni est correct. Cela signifie que l'opération de suppression
  implicite ne peut être exploitée que pendant l'IBD. Après cela, un client Utreexo reviendra aux opérations normales d'ajout et de
  suppression. Une implémentation SwiftSync `assumevalid` est en cours de développement dans [Floresta #1115][flor PR115], tandis qu'une
  version sans `assumevalid` est activement en cours de développement.

- **Nouvelle ébauche de BIP pour les clés internes non dépensables :** NTL a [publié][unspendable ml] sur la liste de diffusion Bitcoin-Dev
  sa proposition d'une nouvelle ébauche de BIP pour spécifier comment rendre non dépensable le chemin par clé de [taproot][topic taproot].
  La nouvelle spécification s'appuie sur une discussion précédente sur Delving Bitcoin entre Salvatore Ingala, Pieter Wuille, Josie Baker et
  d'autres développeurs (voir le [Bulletin #283][news283 unspendable]) ainsi que sur une tentative antérieure d'Andrew Toth de définir un
  BIP dédié dans [BIPs #1746][] (voir le [Bulletin #338][news338 unspendable]).

  La proposition, déjà disponible sous forme d'[ébauche][unspendable gh], spécifie `_` comme espace réservé pour la clé interne
  lorsqu'aucune clé de signature n'est connue. Elle indique aussi que la clé interne doit être dérivée d'une clé publique étendue [BIP32][]
  synthétique en utilisant le point Nothing Up My Sleeve (NUMS) de [BIP341][], qui est un point dont le logarithme discret est inconnu,
  ainsi qu'un chaincode, qui est un hachage tagué de la politique normalisée, ce qui permet à différentes implémentations de reproduire
  indépendamment la même adresse.

  Selon l'auteur, la nouvelle proposition suit trois principes directeurs : elle ne contrôle pas le respect des autres BIP sauf lorsqu'ils
  affectent directement cette question spécifique, elle ne propose pas de nouvelle cryptographie ni de nouvelles structures mais utilise
  uniquement ce qui est déjà disponible, et elle ne revendique pas de canonicalisation sémantique du script.

## Changements dans les services et logiciels clients

*Dans cette rubrique mensuelle, nous mettons en lumière des mises à jour intéressantes des portefeuilles et services Bitcoin.*

- **BitBoxApp ajoute des paiements Lightning basés sur Spark :** BitBox a [annoncé][bitbox ln blog] un portefeuille chaud en bêta publique
  dans l'application mobile BitBoxApp [4.52.0][bitboxapp 4.52.0], construit sur le SDK Breez et les [statechains][topic statechains] Spark.

- **Éditeur de scripts Covenants.diy :** [covenants.diy][covenants diy] est un éditeur permettant de construire des scripts de
  [covenant][topic covenants] et de parcourir leur exécution dans le navigateur. Il prend en charge notamment [`OP_CTV`][topic
  op_checktemplateverify], [`OP_CSFS`][topic op_checksigfromstack], [`OP_CAT`][topic op_cat], [ANYPREVOUT][topic sighash_anyprevout],
  `OP_TEMPLATEHASH`, `OP_INTERNALKEY`, `OP_PAIRCOMMIT` et `OP_TXHASH`, et est destiné à être utilisé sur des réseaux de test.

- **Calculateur hors ligne de clés EntropyLab :** [EntropyLab][entropylab gh] est un fichier HTML autonome pour une utilisation sur machine
  isolée qui convertit l'entropie fournie par l'utilisateur ou un matériel de clé existant en seeds [BIP39][], clés étendues,
  [descriptors][topic descriptors], adresses, entropie enfant [BIP85][], et adresses de [paiement silencieux][topic silent payments]
  [BIP352][], entre autres fonctionnalités.

## Mises à jour et versions candidates

_Nouvelles versions et versions candidates pour des projets d'infrastructure Bitcoin populaires. Veuillez envisager de mettre à niveau vers
les nouvelles versions ou d'aider à tester les versions candidates._

- [Eclair 0.14.3][] est une version de sécurité pour cette implémentation de nœud LN qui corrige des vulnérabilités exploitables par des
  pairs malveillants et la mise à niveau est fortement recommandée. Elle corrige des problèmes liés à la fermeture de canaux, au
  [splicing][topic splicing], et au [financement à la volée][topic jit channels]. Elle ajoute également des limites configurables sur les
  taux de frais de financement et permet aux [nœuds trampoline][topic trampoline payments] de conserver des frais plus faibles afin
  d'améliorer le succès des paiements, comme décrit dans les changements notables ci-dessous.

## Changements notables dans le code et la documentation

_Changements récents notables dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning repo], [Eclair][eclair repo],
[LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet Interface (HWI)][hwi repo], [Rust Bitcoin][rust
bitcoin repo], [BTCPay Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement Proposals (BIPs)][bips repo], [Lightning
BOLTs][bolts repo], [Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition repo], et [BINANAs][binana repo]._

- [Bitcoin Core #35445][] corrige un bogue de compatibilité qui empêchait les portefeuilles [descriptor][topic descriptors] existants avec
  des expressions [miniscript][topic miniscript] utilisant des marqueurs de dérivation durcie de style `h` de se charger après une mise à
  niveau vers la version 31.0. Un changement antérieur, [#31734][bitcoin core #31734], a modifié la façon dont Bitcoin Core représentait les
  chemins de dérivation durcie lors du calcul des identifiants internes de descriptor, ce qui amenait le logiciel plus récent à signaler à
  tort que le portefeuille existant était corrompu. Les identifiants stockés sont désormais traités comme des liens entre des
  enregistrements de portefeuille liés plutôt que comme des valeurs à recalculer et valider. Les RPC `importdescriptors` et
  `createwalletdescriptor` comparent désormais les chaînes de descriptor canoniques lorsqu'ils vérifient si un descriptor est déjà présent.

- [Bitcoin Core #36076][] corrige un bogue où `combinepsbt` pouvait supprimer le type de hachage de signature (sighash) demandé pour une
  entrée lors de la combinaison de [PSBT][topic psbt]. Si le premier PSBT omettait `PSBT_IN_SIGHASH_TYPE`, les signatures d'un autre PSBT
  étaient copiées sans ce champ, ce qui pouvait conduire la finalisation à rejeter des signatures valides utilisant un type de sighash non
  par défaut, tel que `ALL|ANYONECANPAY`. Le champ est maintenant copié lorsqu'il est absent du premier PSBT, permettant la finalisation
  indépendamment de l'ordre des arguments.

- [Bitcoin Core #36150][] corrige un bogue où l'activation du pruning avec un nouvel [index de filtres de blocs compacts][topic compact
  block filters] (`-blockfilterindex`) ou un index de statistiques de l'ensemble UTXO (`-coinstatsindex`) (voir le [Bulletin #198][news198
  coinstats]) pouvait empêcher l'index de se synchroniser. Lorsqu'un nœud non élagué était redémarré avec les deux paramètres activés, les
  fichiers de blocs pouvaient être élagués avant que le nouvel index ne détermine quels blocs étaient nécessaires. Désormais, l'index
  installe un verrou de pruning à la hauteur zéro, avant même de traiter son premier bloc.

- [Bitcoin Core #36174][] ajoute une contre-pression côté envoi au serveur HTTP de remplacement (voir le [Bulletin #411][news411 http]),
  complétant la protection côté réception décrite dans le [Bulletin #422][news422 http]. Auparavant, les clients pouvaient envoyer de
  nombreuses requêtes sans lire les réponses, ce qui faisait croître indéfiniment les données de réponse en file d'attente. Désormais, le
  serveur suspend le traitement des requêtes supplémentaires pour une connexion lorsque son tampon d'envoi dépasse 32 Mio, et reprend
  lorsque le client vide les réponses. La correction précédente empêchait l'accumulation des requêtes entrantes plus vite qu'elles ne
  pouvaient être traitées.

- [Bitcoin Core #34743][] modifie la manière dont les pairs sélectionnés manuellement sont traités lorsqu'ils bloquent le téléchargement des
  blocs pendant l'IBD (voir le [Bulletin #237][news237 stall]). Auparavant, si un pair ne livrait pas un bloc et que le téléchargement ne
  pouvait pas progresser sans lui, le nœud déconnectait le pair. Désormais, pour les pairs sélectionnés avec `-addnode`, `-connect`, ou le
  RPC `addnode`, le nœud rend leurs blocs en attente disponibles pour être demandés à d'autres pairs et suspend les nouvelles requêtes de
  blocs vers le pair bloquant pendant deux minutes. Les pairs manuels restent soumis à des délais distincts pour le téléchargement de blocs
  et la synchronisation des en-têtes.

- [Bitcoin Core #36081][] ajoute un champ `bestblockhash` à la réponse du RPC `getmininginfo`. Avec l'objet `next` existant
  (voir le [Bulletin #339][news339 mininginfo]), cela permet au logiciel de minage d'obtenir le hachage de la
  pointe actuelle et la cible de difficulté du bloc suivant via un seul appel RPC. Auparavant, obtenir le hachage et les informations de
  minage via des appels RPC séparés pouvait entrer en concurrence avec un changement de pointe, produisant des valeurs se référant à des
  pointes différentes.

- [Bitcoin Core #35975][] corrige un plantage du portefeuille qui se produisait lors de l'appel de `bumpfee` sur deux versions malléées de
  la même transaction. Auparavant, augmenter les frais d'une version ne marquait pas immédiatement l'autre comme remplacée. Tenter ensuite
  d'augmenter les frais de l'autre version pouvait déclencher un échec d'assertion et faire planter le nœud. Désormais, augmenter les frais
  de l'une ou l'autre version marque toutes ses variantes malléées comme remplacées. Tenter d'augmenter les frais d'une variante déjà
  remplacée entraîne une erreur. La PR garantit également que les commentaires et les métadonnées de [remplacement][topic rbf] sont copiés
  vers les transactions malléées, y compris les remplacements malléés par augmentation de frais, et persistent après rechargement du
  portefeuille.

- [BIPs #2241][] ajoute [BIP332][], qui spécifie le relais optionnel des pointes récentes de chaînes périmées, précédemment discuté dans le
  [Bulletin #417][news417 staletip]. Le message `staletip` inclut le hachage d'un bloc connu comme point de bifurcation, les en-têtes de la
  branche périmée, et un indicateur signalant si l'expéditeur est disposé à servir les données de blocs de la pointe périmée. Les pairs
  négocient cette prise en charge à l'aide de [BIP434][], implémenté dans Bitcoin Core comme décrit dans le [Bulletin #410][news410 bip434].
  Les limites de ressources recommandées incluent 20 en-têtes par annonce et une fenêtre de récence de 1 000 blocs.

- [BIPs #2258][] met à jour [BIP93][] [codex32][topic codex32] pour inclure la contribution du préfixe lors de la vérification des limites
  de longueur de somme de contrôle. Auparavant, ces vérifications ne comptaient que la portion des données, ce qui permettait à certaines
  chaînes de dépasser les longueurs couvertes par les garanties annoncées de détection d'erreurs de la somme de contrôle. La spécification
  et l'implémentation de référence utilisent désormais la longueur complète, développée, pour sélectionner et valider la somme de contrôle.
  En outre, la PR restreint les encodages de seed maître à des seeds de 16, 20, 24, 28, 32 ou 64 octets, réduisant l'ambiguïté lors de la
  correction de caractères insérés ou supprimés accidentellement. Les encodages existants à ces tailles restent inchangés, mais les
  encodages d'autres tailles qui étaient auparavant autorisés ne sont plus conformes.

- [Eclair #3380][] rejette les requêtes API contenant un en-tête `Origin`, y compris les connexions WebSocket, afin d'empêcher des attaques
  cross-site request forgery utilisant des identifiants HTTP Basic mis en cache. Les interfaces frontales basées sur navigateur doivent
  désormais utiliser leur propre backend au lieu d'appeler Eclair directement. Les clients en ligne de commande tels que `curl` et
  `eclair-cli` restent inchangés lorsqu'ils ne définissent pas cet en-tête.

- [Eclair #3376][] corrige plusieurs problèmes liés à la fermeture de canaux, au [splicing][topic splicing], et au [financement à la
  volée][topic jit channels]. Lorsque Eclair paie les frais, la négociation des frais de fermeture rejette les propositions du pair qui
  dépassent le taux maximal de frais de fermeture configuré et qui sont en dehors de la plage de frais locale. Auparavant, le mécanisme de
  repli de négociation pouvait accepter des frais excessifs susceptibles d'épuiser le solde local du canal. Lors d'une fermeture forcée
  pendant un splice incomplet, Eclair utilise désormais le plus récent engagement dont la transaction de financement est entièrement signée
  si les signatures du pair nécessaires pour publier le splice sont manquantes. Si le pair diffuse le splice et qu'il se confirme en
  premier, Eclair ferme alors en utilisant l'engagement qui dépense la nouvelle sortie de financement. En outre, la PR vérifie les frais de
  relais et les [deltas d'expiration CLTV][topic cltv expiry delta] avant d'exécuter un financement à la volée pour des paiements via des
  [chemins aveuglés][topic rv routing], empêchant des transferts dangereux qui pourraient entraîner une perte de fonds. La PR ajoute un
  nouveau paramètre `on-chain-fees.max-funding-feerate`, valant par défaut 50 sat/vB, qui plafonne les [taux de frais estimés
  automatiquement][topic fee estimation] pour les ouvertures de canaux et les splices.

- [Eclair #3372][] permet aux nœuds Eclair agissant comme [nœuds trampoline][topic trampoline payments] de conserver des frais plus faibles,
  rendant ainsi une plus grande partie du budget de frais de l'expéditeur disponible pour le routage en aval. Pour les paiements avec des
  indices de routage ou des [chemins aveuglés][topic rv routing], le nouveau paramètre `relay.fees.min-local-trampoline` définit les frais
  minimaux qu'Eclair conserve. Les opérateurs peuvent définir ce minimum en dessous de leurs frais standard de canal sortant pour aider les
  paiements à réussir lorsque les frais totaux en aval, y compris ceux facturés par le Lightning Service Provider (LSP) du destinataire,
  dépasseraient autrement le budget. Les paiements sans ces indices continuent d'inclure le coût habituel du canal local. En outre, la PR
  augmente le budget minimal total de frais requis par `relay.fees.min-trampoline` de 1 sat plus 0,01 % du montant transféré à 2 sats plus
  0,04 %.

- [LND #11163][] corrige le traitement des [HTLC][topic htlc] rejoués lors de l'utilisation de l'intercepteur de transfert (voir le
  [Bulletin #104][news104 intercept]), qui permet à un logiciel externe d'approuver ou de rejeter le transfert. Après la reconnexion d'un
  pair ou le redémarrage d'un nœud, LND peut retraiter un HTLC entrant qu'il a déjà transféré. Auparavant, LND pouvait traiter cela comme
  une nouvelle interception et le rejeter si l'expiration était trop proche, par exemple, même si le HTLC sortant restait actif. Désormais,
  LND vérifie les enregistrements de transfert existants, permettant au rejeu de se poursuivre jusqu'à la résolution du paiement d'origine.
  Pour les paiements toujours en attente de la décision de l'intercepteur, LND conserve au contraire le HTLC en attente avec sa date limite
  d'échec automatique d'origine (voir le [Bulletin #224][news224 intercept]), évitant une seconde vérification d'expiration lors du rejeu.

- [BDK #2246][] et [#2263][bdk #2263] améliorent la classification du solde du portefeuille (voir le [Bulletin #213][news213 balance]) en
  vérifiant l'ascendance transactionnelle non réglée d'une sortie. Auparavant, la monnaie rendue issue de la dépense d'un paiement entrant
  non confirmé pouvait être considérée comme fiable, même si elle dépendait de la confirmation d'une transaction entrante. BDK propage
  désormais ce statut non fiable à travers les transactions descendantes. La nouvelle API `classify_outpoints` expose des classifications
  par sortie, tandis que l'API `balance` mise à jour permet aux applications de définir séparément quelles transactions sont non fiables et
  quand les transactions sont considérées comme réglées. La seconde PR ajoute `ChainPosition::confirmations_lower_bound`, pour aider les
  applications à définir des règles de règlement telles qu'exiger six confirmations. Elle renvoie un nombre conservateur de confirmations,
  incluant le bloc de confirmation, et renvoie zéro pour les transactions non confirmées ou les hauteurs de confirmation supérieures à la
  pointe fournie.

{% include snippets/recap-ad.md when="2026-09-22 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="1923,1746,35445,31734,36076,36150,36174,34743,36081,2241,3380,2258,3376,3372,11163,2246,2263,35975" %}

[price vardiff]: https://delvingbitcoin.org/t/research-a-clockless-vardiff-strands-a-slowing-miner/2718
[shape proxy]: https://github.com/marafoundation/sv2-apps/tree/shape-proxy-v0.1.0/test-tools/shape-proxy
[towns vardiff]: https://delvingbitcoin.org/t/research-a-clockless-vardiff-strands-a-slowing-miner/2718/4
[news325 datum]: /fr/newsletters/2024/10/18/#annonce-du-protocole-datum
[price frontier]: https://delvingbitcoin.org/t/vardiff-belongs-at-the-frontier/2734
[utreexo ibd del]: https://delvingbitcoin.org/t/implicit-deletions-and-improvements-in-utreexo-ibd/2881
[flor PR115]: https://github.com/getfloresta/Floresta/pull/1115
[bitbox ln blog]: https://blog.bitbox.swiss/en/introducing-lightning-in-the-bitboxapp/
[bitboxapp 4.52.0]: https://github.com/BitBoxSwiss/bitbox-wallet-app/releases/tag/v4.52.0
[covenants diy]: https://covenants.diy/
[entropylab gh]: https://github.com/OogaBoogaX/entropylab
[unspendable ml]: https://groups.google.com/g/bitcoindev/c/se3TkNnbno4
[news283 unspendable]: /fr/newsletters/2024/01/03/#comment-specifier-des-cles-non-depensables-dans-les-descripteurs
[news338 unspendable]: /fr/newsletters/2025/01/24/#ebauche-de-bip-pour-les-cles-non-depensables-dans-les-descripteurs
[unspendable gh]: https://github.com/bitryonix/bips/blob/bip-xxxx-unspendable-internal-keys/bip-xxxx-unspendable-internal-keys.mediawiki
[news198 coinstats]: /en/newsletters/2022/05/04/#bitcoin-core-21726
[news237 stall]: /fr/newsletters/2023/02/08/#bitcoin-core-25880
[news339 mininginfo]: /fr/newsletters/2025/01/31/#bitcoin-core-31583
[news417 staletip]: /fr/newsletters/2026/08/07/#ebauche-de-bip-pour-le-relais-des-pointes-perimees
[news410 bip434]: /fr/newsletters/2026/06/19/#bitcoin-core-35221
[news411 http]: /fr/newsletters/2026/06/26/#bitcoin-core-35182
[news422 http]: /fr/newsletters/2026/09/11/#bitcoin-core-36123
[Eclair 0.14.3]: https://github.com/ACINQ/eclair/releases/tag/v0.14.3
[news104 intercept]: /en/newsletters/2020/07/01/#lnd-4018
[news224 intercept]: /fr/newsletters/2022/11/02/#lnd-6831
[news213 balance]: /en/newsletters/2022/08/17/#bdk-640
