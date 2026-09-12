---
title: 'Bulletin Hebdomadaire Bitcoin Optech #421'
permalink: /fr/newsletters/2026/09/04/
name: 2026-09-04-newsletter-fr
slug: 2026-09-04-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine décrit une idée permettant aux pools de payer les mineurs en utilisant des silent payments dans la transaction
coinbase et résume la divulgation responsable d'une vulnérabilité de déni de service affectant les anciennes versions de Core Lightning.
Sont également incluses nos rubriques habituelles résumant les propositions et discussions sur la modification des règles de consensus de
Bitcoin, annonçant les nouvelles versions et versions candidates, et décrivant les changements notables dans les logiciels d'infrastructure
Bitcoin populaires.

## Nouvelles

- **Utilisation des silent payments pour les paiements aux mineurs dans la transaction coinbase** : average_gary a [publié][spc del] sur
  Delving Bitcoin son idée concernant la manière dont les [pools][topic pooled mining] pourraient payer les mineurs à différentes adresses
  directement dans la transaction coinbase. Au lieu de fournir un `xpub` au pool pour dériver une nouvelle adresse à chaque paiement, ce qui
  pourrait entraîner des problèmes de confidentialité si la base de données du pool était compromise, un mineur pourrait partager une
  adresse de [silent payment][topic silent payments], qui est statique et peut être utilisée plusieurs fois sans fuite de confidentialité,
  via le canal de communication chiffré fourni par Stratum v2.

  Pour les silent payments [BIP352][], le destinataire dérive le secret partagé à partir des clés publiques d'entrée de la transaction, ce
  qu'une transaction coinbase n'a pas. Le pool peut créer une clé privée éphémère qui sera utilisée pour dériver la clé publique d'envoi
  `A_send`. Pour empêcher le pool de faire du grinding sur une clé privée malveillante `a_send`, `A_send` est hachée avec la hauteur du bloc
  en cours de minage, ce qui remplace l'unicité dérivée de l'outpoint. Le `A_send` de 34 octets est finalement inclus dans le scriptSig de
  la coinbase en remplacement du soi-disant pool tag, afin que le mineur puisse scanner la chaîne pour y trouver les fonds.

  L'auteur recherche des retours et des critiques sur l'idée proposée, afin qu'elle puisse être formalisée en une véritable spécification.

- **Divulgation responsable d'une vulnérabilité de déni de service dans CLN** : Erick Cestari a [publié][cln dos del] sur Delving Bitcoin la
  divulgation responsable d'une vulnérabilité critique de déni de service (DoS) affectant les nœuds CLN exécutant des versions antérieures à
  [25.09][cln v25.09]. Un attaquant aurait été capable d'inonder un nœud de messages `ping` demandant la plus grande réponse `pong` possible
  sans jamais lire la socket TCP, provoquant un crash par dépassement de mémoire (OOM), en n'ayant besoin que de compléter la poignée de
  main [BOLT8][], sans canal.

  Le problème était lié à la manière dont CLN gère ses connexions. Chaque pair ouvre avec le nœud un canal Noise chiffré BOLT8 et la
  connexion est gérée par un démon spécifique, `connectd`. Le démon gère la connexion TCP, déchiffre les messages entrants, et les achemine
  vers le sous-démon spécifique gérant un canal de paiement avec le pair expéditeur. Cependant, certains messages sont pris en charge
  localement par le démon. L'un d'eux est le message `ping` et l'expéditeur peut choisir la taille de la réponse `pong`.

  Alors que CLN applique un mécanisme de backpressure aux messages acheminés vers les sous-démons, `connectd` attendant qu'ils soient prêts
  avant de lire un nouveau message, cela ne s'appliquait pas au démon lui-même, qui continuait à lire les messages gérés localement. Un
  attaquant aurait été capable d'envoyer de façon répétée des messages `ping` demandant une réponse de la taille maximale autorisée de 65531
  octets et de ne jamais lire la réponse, remplissant ainsi d'abord son tampon de socket TCP, puis celui du pair. Cela aurait empêché la
  file `peer_outq` de se vider, conduisant au crash OOM.

  Le problème a été corrigé en dotant le démon `connectd` de son propre mécanisme de backpressure, activé par le vidage effectif de la file
  `peer_outq` avant de lire le message entrant suivant. Le correctif a été introduit dans [Core Lightning #8525][] et publié dans la version
  25.09.

## Modification du consensus

_Une nouvelle section mensuelle résumant les propositions et discussions sur la modification des règles de consensus de Bitcoin._

- **Poursuite de la discussion sur les types de sorties PQC** : Suite au [résumé][news417 pqout] du mois dernier du fil Delving Bitcoin de
  Pieter Wuille sur les types de sorties [post-quantiques][topic quantum resistance], Wuille a [répondu][pw delving pqout cisa] à l'argument
  de Conduition selon lequel associer [CISA][topic cisa] à [P2TRv2][news403 pqout] inciterait fortement à la migration. Wuille n'était pas
  convaincu que les économies de feerate, qu'il estimait à une réduction de poids maximale d'environ 28% et seulement pour des transactions
  comportant de nombreuses entrées, feraient bouger la longue traîne : la prise en charge par les portefeuilles et les dépositaires est le
  goulot d'étranglement, CISA ajoute une complexité de spécification et d'implémentation qui pourrait retarder un soft fork P2TRv2, et
  certaines entités pourraient reporter tout travail PQC jusqu'à pouvoir livrer P2TRv2 et CISA ensemble. Il préfère toujours P2TRv2 comme
  choix par défaut pour les utilisateurs occasionnels et [P2MR][news393 p2mr] pour les utilisateurs plus sophistiqués qui veulent masquer
  les points EC, et a noté qu'après le Q-day, les signatures basées sur des hachages auront probablement besoin d'une nouvelle règle de coût
  de witness qui pèse davantage le CPU et moins la taille sérialisée (voir le [Bulletin
  #417][news417 pqwit]). Il a également averti que le fait d'avoir des nœuds de
  relais tiers agrégeant progressivement les signatures masquerait le vrai coût de bande passante dans la couche de consensus et pourrait
  renforcer les pools de minage existants en incitant à la soumission directe aux mineurs. Conduition a [répliqué][c delving pqout cisa]
  qu'un type de sortie prenant en charge CISA peut être adopté d'abord avec des signatures BIP340 ordinaires, l'agrégation étant ajoutée
  plus tard, et qu'une augmentation de taille de bloc sérialisée de 8x (ou plus) pour rendre les signatures basées sur des hachages
  compétitives en frais par rapport à l'EC pousserait le stockage d'archives dans les téraoctets par an, à moins qu'une agrégation SNARK à
  l'échelle du bloc ne puisse élaguer les witnesses. Adam Gibson s'est [accordé][ag delving pqout] avec Wuille sur le fait qu'intégrer CISA
  dans P2TRv2 s'accorde mal avec l'objectif de P2TRv2 privilégiant d'abord l'adoption.

- **Sauvetage PQC commit/reveal DropKick** : Conduition a [publié][c ml dropkick] sur la liste de diffusion Bitcoin-Dev une esquisse de
  DropKick, un protocole de sauvetage [post-quantique][topic quantum resistance] commit/reveal (voir aussi le [Bulletin #361][news361 pqcr] et le
  [Bulletin #348][news348 utxo proving]) pour les utilisateurs n'ayant pas déplacé leurs pièces vers des sorties compatibles PQC avant le
  Q-day. Un utilisateur masque un engagement envers sa clé publique post-quantique et sa preuve de propriété (proof of knowledge asymmetry)
  quelque part dans un bloc (par exemple dans un `OP_RETURN` ou un tweak taproot). Les utilisateurs ne disposant pas de leur propre UTXO sûr
  face au PQ peuvent remettre leurs engagements à des agrégateurs non fiables, qui engagent par merkle les engagements de nombreux
  utilisateurs sous une seule racine onchain, éventuellement moyennant des frais payés à partir des pièces sauvées. Après un délai, ils
  révèlent la preuve, une signature de leur clé publique post-quantique, et une preuve d'ouverture de style SPV montrant que l'engagement
  est apparu dans un bloc antérieur. DropKick peut être déployé comme un soft fork non confiscatoire s'il ne grève que les UTXOs ayant des
  asymétries de connaissance décidables, où les validateurs peuvent déterminer à partir de la seule sortie que des données cachées telles
  qu'une clé publique hachée existent. Couvrir des cas indécidables comme la dérivation de clé BIP32 permettrait de sauver plus de pièces
  mais pourrait en confisquer certaines. Les pièces P2PK ne peuvent pas être couvertes. Comparé au Lifeboat de Tadge Dryja, qui exige que
  chaque utilisateur dispose d'un UTXO sûr vis-à-vis du PQ pour publier un engagement, DropKick supprime l'exigence d'indexer et d'ordonner
  chaque engagement onchain, au prix d'un risque de censure par les mineurs sur la phase de révélation : Conduition soutient qu'un long
  délai (environ 100 blocs si les utilisateurs paient 1% de l'UTXO aux mineurs honnêtes) plus des frais proportionnels à la valeur peuvent
  rendre la censure non rentable, en supposant que les censeurs ne soient pas capables de réorganiser ou réticents à réorganiser les blocs
  qui sapent la tentative de censure.

- **BIP préliminaire SHRINCS** : Conduition a [publié][c ml shrincs] sur la liste de diffusion Bitcoin-Dev, au nom du groupe de travail
  SHRINCS, un premier [brouillon][shrincs bip] spécifiant SHRINCS comme schéma de signature [basé sur des hachages][news386 jn hash]
  semi-stateful pour Bitcoin (voir le [Bulletin #391][news391 shrincs]). Les clés publiques font 48 octets. Les signatures stateful font 548
  octets au minimum ; un repli stateless intégré produit des signatures de 5 777 octets (le brouillon relève le budget stateless à 2^40
  signatures afin que des protocoles à haute fréquence tels que LN puissent utiliser ce repli). La vérification est de 4x à 16x plus rapide
  par octet que [BIP340][] [schnorr][topic schnorr signatures] avec accélération matérielle SHA256, ou dans le pire des cas 2 792
  compressions SHA256 pour une signature stateless. Parmi les changements notables depuis la proposition d'origine figurent la compatibilité
  black-box avec SLH-DSA (FIPS-205), des arbres XMSS flexibles de n'importe quelle structure, et des paramètres stateful plus rapides (plus
  volumineux). Le brouillon ne spécifie qu'un schéma de signature ; le déploiement des nouvelles signatures via de nouveaux opcodes ou un
  nouveau type de sortie ferait l'objet d'une proposition distincte. Réutiliser un compteur stateful permet à un observateur de forger des
  signatures. Antoine Riard a [noté][ar ml shrincs] que des signatures stateless de 5 777 octets représenteraient environ 90x le coût
  onchain des transactions actuelles, à moins que ces champs ne bénéficient d'une remise. La bibliothèque C [libshrincs][news419 libshrincs]
  de Jonas Nick et remix7531, avec preuves WOTS+C vérifiées par machine, a également été publiée séparément afin d'apporter un support
  d'implémentation à ceux qui souhaitent intégrer SHRINCS.

- **BIP448 et démonstrations et applications de CSFS/CTV** : Les travaux autour de [BIP448][] (le lot [tapscript][topic tapscript] composé
  de `OP_TEMPLATEHASH`, [`OP_CHECKSIGFROMSTACK`][topic op_checksigfromstack] (CSFS), et `OP_INTERNALKEY` ; voir le [Bulletin #397][news397
  bip448]) se poursuivent avec de nouveaux sites agrégeant démonstrations, implémentations et preuves de concept. Une organisation GitHub
  [BIP448][bip448 org] rassemble des implémentations (Bitcoin Inquisition, un patch Bitcoin Core sans activation, l'[intégration miniscript
  et PSBT][news395 thikcs], des BOLTs [LN-Symmetry][topic eltoo] en brouillon et une implémentation Core Lightning, et une [démo][news419
  thark] signet Ark [OP_TEMPLATEHASH][topic ark]). L'organisation note que le lot complet sera utilisable sur le [signet][topic signet] par
  défaut avec la prochaine version de Bitcoin Inquisition. askii21m a [annoncé][askii delving cvd] covenants.diy, un éditeur dans le
  navigateur qui construit des sorties [taproot][topic taproot] et exécute pas à pas du tapscript sous des ensembles d'opcodes
  sélectionnables, avec des exemples à liens permanents incluant l'état réassignable de BIP448, les vaults et le contrôle de congestion de
  [BIP119][], et la délégation BIP348. Jesus Najera (setzeus) de Cofund a [publié][cofund atlas] un Atlas interactif des cas d'usage des
  covenants comprenant plus de deux douzaines de constructions, dont des vaults, le contrôle de congestion, l'émission Ark, et LN-Symmetry.

  Ademan a [publié][ademan delving lark] une construction connexe pour les affectations de sortie de transaction virtuelle (VTXO) Ark hors
  tour (OOR) utilisées pour ouvrir de petits canaux Lightning just-in-time ([JIT][topic jit channels]). Comme le serveur Ark est à la fois
  opérateur et détenteur initial du VTXO, il peut actuellement réaffecter le même VTXO de nombreuses fois. La caution d'équivoque d'Ademan
  peut être confisquée en publiant deux signatures validées par CSFS depuis la clé d'affectation sur des sighashes [BIP341][] distincts. La
  caution et l'arbre de transactions préalloué ont besoin d'un [covenant][topic covenants] de transaction suivante, qui peut être soit
  [`OP_CHECKTEMPLATEVERIFY`][topic op_checktemplateverify] (CTV) soit `OP_TEMPLATEHASH`.

## Mises à jour et versions candidates

_Nouvelles versions et versions candidates pour des projets d'infrastructure Bitcoin populaires. Veuillez envisager de mettre à niveau vers
les nouvelles versions ou d'aider à tester les versions candidates._

- [Core Lightning 26.06.7][] est une version de sécurité pour la version majeure actuelle de cette implémentation populaire de nœud LN. Elle
  corrige plusieurs vulnérabilités divulguées de manière responsable, dont aucune n'est connue pour être activement exploitée, signalées par
  des chercheurs dont Erick Cestari, dont la divulgation précédente est décrite dans la section Nouvelles ci-dessus. Le projet encourage
  fortement tous les utilisateurs à mettre à niveau. Comme décrit dans le [Bulletin #420][news420 cln embargo], le code source est retenu
  pendant 14 jours après la publication binaire du 28 août afin de ralentir les attaquants dans leur rétro-ingénierie des correctifs. Après
  cela, les [builds reproductibles][topic reproducible builds] de CLN permettront aux utilisateurs de vérifier les binaires. Entre le 28
  août et le 1er septembre, les utilisateurs Docker ayant récupéré les tags `v26.06.7` ou `latest` ont reçu des images qui indiquaient la
  nouvelle version mais ne contenaient pas les correctifs. Ces utilisateurs devraient vérifier le digest de leur image et la récupérer à nouveau.

- [LND v0.21.3-beta][] est une version de maintenance de cette implémentation populaire de nœud LN. Elle inclut les limites de ressources
  par pair, le correctif d'encodage de `channel_update`, et le correctif de résolution des [HTLC][topic htlc] de poussière décrits dans la
  section des changements notables du code ci-dessous, ainsi que le correctif du blocage mutuel de financement [PSBT][topic psbt] du
  [Bulletin #420][news420 lnd deadlock]. Elle corrige également un bogue de frais de fermeture coopérative pour les canaux avec sorties
  auxiliaires tels que les canaux [Taproot Assets][topic client-side validation], un échec de migration native SQL des factures [AMP][topic
  amp] héritées, une panique du proxy REST WebSocket, ainsi que plusieurs bogues de requêtes gossip et de fermeture coopérative, et ajoute
  le RPC expérimental `XCreateAccount` (voir le [Bulletin #419][news419 lnd account]).

- [LND v0.20.4-beta][] est une version de maintenance de la branche de version 0.20 de LND. Elle rétroporte la plupart des correctifs de la
  0.21.3-beta, y compris les limites de ressources par pair, le correctif d'encodage de `channel_update`, et le correctif de résolution des
  HTLC de poussière, et rejette en outre les enregistrements TLV de taille fixe tels que les frais entrants et les nonces [MuSig2][topic
  musig] dont la longueur déclarée est incorrecte, au lieu de les accepter silencieusement et de les réencoder.

## Changements notables dans le code et la documentation

_Changements notables récents dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning repo], [Eclair][eclair repo],
[LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet Interface (HWI)][hwi repo], [Rust Bitcoin][rust
bitcoin repo], [BTCPay Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement Proposals (BIPs)][bips repo], [Lightning
BOLTs][bolts repo], [Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition repo], et [BINANAs][binana repo]._

- [Bitcoin Core #36111][] limite la mémoire utilisée par la RPC `validateaddress` lors du signalement d'erreurs pour des chaînes
  [bech32][topic bech32] excessivement longues. Auparavant, pour les chaînes dépassant la limite de 90 caractères fixée par [BIP173][],
  chaque position au-delà de la limite était renvoyée comme emplacement d'erreur (voir le [Bulletin #177][news177 bech32]) et convertie en une
  valeur JSON distincte. Désormais, la RPC ne renvoie que la position 90, là où la violation de longueur commence. Dans les tests de
  l'auteur, une requête authentifiée proche de la taille maximale de requête HTTP utilisait environ 5,7 Gio de mémoire avant le changement
  et 240 Mio après.

- [Bitcoin Core #36032][] améliore les performances de `createrawtransaction`, `createpsbt`, `sendmany`, et d'autres RPC construisant une
  transaction en rendant l'analyse des sorties linéaire au lieu de quadratique. Auparavant, l'analyseur itérait sur les clés de sortie et
  recherchait séparément chaque valeur correspondante individuellement, rescannant à chaque fois la même liste interne. De plus, `sendmany`
  conservait le verrou du portefeuille pendant l'analyse. Désormais, l'analyseur parcourt ensemble les clés et les valeurs par index, de
  manière similaire au correctif de `gettxspendingprevout` dans le [Bulletin #419][news419 gettxspendingprevout]. L'auteur indique
  qu'analyser 10 000 sorties dans une build de débogage prend maintenant 0,5 seconde au lieu de 1,8 seconde.

- [Core Lightning #9435][] met à jour CLN pour forcer la fermeture d'un canal lorsqu'un pair envoie un message `channel_reestablish` avec un
  `next_commitment_number` de zéro, comme requis par [BOLT2][]. Une valeur de zéro indique que le pair a perdu l'état de son canal, et la
  diffusion de la transaction d'engagement la plus récente lui permet de récupérer son solde à l'aide d'une [sauvegarde statique de
  canal][topic static channel backups]. Auparavant, CLN n'appliquait cela qu'à un canal fraîchement ouvert. Pour tout autre canal, CLN
  détectait d'abord le `next_revocation_number` périmé du pair, envoyait un avertissement, et laissait le canal ouvert.

- [Eclair #3368][] corrige un bogue où un message `commitment_signed` reçu d'un pair sur un canal non-[taproot][topic taproot] pouvait
  contenir le TLV `partial_signature_with_nonce` utilisé par les [simple taproot channels][topic simple taproot channels] pour leurs
  signatures partielles [MuSig2][topic musig] (voir le [Bulletin #404][news404 eclair taproot]). Bien qu'Eclair vérifiait correctement la
  signature ECDSA ordinaire du message, il stockait incorrectement la signature partielle non sollicitée comme étant la signature du pair.
  Cela empêchait Eclair de forcer la fermeture du canal plus tard. Désormais, Eclair sélectionne le type de signature correspondant au
  format d'engagement du canal avant la vérification et ne stocke que la signature vérifiée.

- [Eclair #3366][] renforce le [splicing][topic splicing] contre des pairs qui ne suivent pas la spécification. Eclair déconnecte désormais
  un pair qui envoie des mises à jour de canal après son propre message de [quiescence][topic channel commitment upgrades] `stfu`, ou qui
  envoie un message `commitment_signed` alors que le splice est encore en cours de négociation. Eclair force la fermeture au lieu d'accepter
  si un pair tente de faire avancer l'engagement existant du canal pendant que le splice est en cours de signature. Il refuse aussi
  d'achever une tentative de splice ou de [dual funding][topic dual funding] [RBF][topic rbf] dont les numéros d'engagement ne correspondent
  plus à ceux du canal. Enfin, lorsqu'un splice dans lequel Eclair vend de la liquidité via des [annonces de liquidité][topic liquidity
  advertisements] est abandonné après le début de la signature, Eclair échoue désormais immédiatement les [HTLCs][topic htlc] entrants qui
  le paient (voir le [Bulletin #379][news379 eclair liquidity] pour un correctif connexe).

- [LND #11090][] limite le débit des messages `ping` entrants et plafonne la file des messages sortants de chaque pair, empêchant le type
  d'épuisement de ressources décrit pour CLN dans la section Nouvelles ci-dessus. Pour chaque connexion de pair, LND maintient désormais
  deux seaux à jetons. Le seau des requêtes `ping` entrantes commence avec 200 jetons et se reconstitue à un rythme de 10 par seconde.
  L'épuisement de ce seau entraîne la déconnexion du pair. Le seau des réponses `pong` sortantes commence avec 20 jetons et se reconstitue
  au rythme d'un par seconde. L'épuisement de ce seau amène LND à cesser de répondre, ce qui constitue un écart délibéré par rapport à
  [BOLT1][]. La file sortante de chaque pair est également plafonnée à 10 000 messages ou environ 16 Mio. De plus, la PR corrige l'encodage
  des [messages gossip][topic channel announcements] `channel_update` afin que les propres mises à jour de LND annonçant des [frais
  entrants][topic inbound forwarding fees] soient signées exactement sur les octets qu'il diffuse. Auparavant, ces octets pouvaient
  différer, ce qui amenait les pairs à rejeter la mise à jour. Les mises à jour que LND relaie depuis d'autres nœuds conservent désormais
  aussi tous les enregistrements TLV qu'il ne reconnaît pas, au lieu de les supprimer et d'invalider la signature de l'émetteur d'origine
  (voir le [Bulletin #418][news418 eclair flags] pour un correctif similaire dans Eclair).

- [LND #11140][] corrige la façon dont LND gère un [HTLC][topic htlc] relayé lorsque le canal sortant force sa fermeture et que le HTLC est
  [élagué][topic trimmed htlc] comme [poussière][topic uneconomical outputs] sur la transaction d'engagement d'une des parties mais pas de
  l'autre. Auparavant, si le HTLC avait une sortie sur l'engagement de LND mais que l'engagement du pair confirmait sans sortie
  correspondante, LND ne renvoyait jamais l'échec du HTLC entrant, parce qu'il avait évalué le HTLC sur la base de son propre engagement. Le
  HTLC entrant restait alors en attente jusqu'à ce que le canal amont force sa fermeture près de son expiration. Désormais, LND décide en
  fonction de l'engagement qui a effectivement été confirmé. LND ne fait également plus échouer de façon anticipée un HTLC entrant lorsque
  le HTLC sortant est de la poussière sur son engagement mais a une sortie sur l'engagement du pair, puisque le pair pourrait toujours
  réclamer la sortie avec la préimage.

- [HWI #792][] ajoute une option `--registration` à la commande `signtx` pour signer des [PSBTs][topic psbt] à l'aide de politiques de
  portefeuille [BIP388][] ayant été précédemment enregistrées sur un dispositif matériel de signature avec la commande `registerdescriptor`
  (voir les Bulletins [#419][news419 hwi] et [#420][news420 hwi]). L'option accepte l'enregistrement sérialisé renvoyé par
  `registerdescriptor`, y compris le nom de la politique, le [descriptor][topic descriptors], le type d'appareil, et toute donnée
  d'enregistrement spécifique à l'appareil telle que le HMAC de Ledger. La prise en charge est implémentée pour BitBox02, Coldcard Edge,
  Jade, et les appareils Ledger non hérités.

- [BDK #2262][] corrige un bogue où la réindexation du graphe de transactions d'un portefeuille pouvait manquer certaines des propres
  sorties du portefeuille. Le `KeychainTxOutIndex` de BDK surveille une [fenêtre d'adresses][topic gap limits] d'anticipation au-delà du
  plus grand index de dérivation [BIP32][] qu'il a vu, en étendant la fenêtre à chaque fois qu'une sortie à un index plus élevé est trouvée.
  Auparavant, la réindexation examinait chaque sortie une seule fois, si bien qu'une sortie au-delà de la fenêtre actuelle était jugée comme
  n'appartenant pas au portefeuille et n'était jamais réexaminée, même après qu'une sortie ultérieure avait étendu la fenêtre. Comme les
  sorties étaient examinées dans un ordre aléatoire, le même portefeuille pouvait afficher des soldes différents selon les exécutions. La
  réindexation répète désormais le processus jusqu'à ce que la fenêtre cesse de s'étendre.

{% include snippets/recap-ad.md when="2026-09-08 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="8525,36111,36032,9435,3368,3366,11090,11140,792,2262" %}
[spc del]: https://delvingbitcoin.org/t/silent-payments-coinbase/2833
[cln dos del]: https://delvingbitcoin.org/t/disclosure-crashing-cln-with-a-flood-of-pings/2846
[cln v25.09]: https://github.com/ElementsProject/lightning/releases/tag/v25.09
[news417 pqout]: /fr/newsletters/2026/08/07/#discussion-sur-les-types-de-sortie-pqc
[news417 pqwit]: /fr/newsletters/2026/08/07/#engagement-segwit-vers-des-donnees-de-temoin-post-quantiques
[news403 pqout]: /fr/newsletters/2026/05/01/#discussion-d-un-type-de-sortie-post-quantique
[news393 p2mr]: /fr/newsletters/2026/02/20/#bips-1670
[pw delving pqout cisa]: https://delvingbitcoin.org/t/pqc-output-type-discussion/2749/6
[c delving pqout cisa]: https://delvingbitcoin.org/t/pqc-output-type-discussion/2749/7
[ag delving pqout]: https://delvingbitcoin.org/t/pqc-output-type-discussion/2749/15
[c ml dropkick]: https://groups.google.com/g/bitcoindev/c/6SqWPfBf-p0
[news361 pqcr]: /fr/newsletters/2025/07/04/#fonction-de-commit-reveal-pour-la-recuperation-post-quantique
[news348 utxo proving]: /fr/newsletters/2025/04/04/#prouver-de-maniere-securisee-la-propriete-d-une-utxo-en-revelant-une-preimage-sha256
[c ml shrincs]: https://groups.google.com/g/bitcoindev/c/HbVboXIFiG8
[shrincs bip]: https://github.com/SHRINCS/shrincs-bip/blob/main/SHRINCS.md
[ar ml shrincs]: https://gnusha.org/pi/bitcoindev/b4bb949d-bd35-424d-a1d1-459e6cca263an@googlegroups.com/
[news386 jn hash]: /fr/newsletters/2026/01/02/#signatures-basees-sur-le-hachage-pour-le-futur-post-quantique-de-bitcoin
[news391 shrincs]: /fr/newsletters/2026/02/06/#shrincs-signatures-post-quantiques-etatiques-de-324-octets-avec-sauvegardes-statiques
[news419 libshrincs]: /fr/newsletters/2026/08/21/#signatures-basees-sur-des-hachages-formellement-verifiees-de-libshrincs
[news397 bip448]: /fr/newsletters/2026/03/20/#bips-1974
[news395 thikcs]: /fr/newsletters/2026/03/06/#extensions-aux-outils-standards-pour-le-support-de-templatehash-csfs-ik
[bip448 org]: https://github.com/bip448
[news419 thark]: /fr/newsletters/2026/08/21/#demonstration-ark-avec-op-templatehash
[askii delving cvd]: https://delvingbitcoin.org/t/covenants-diy-a-node-editor-for-covenant-scripts/2826
[cofund atlas]: https://getcofund.com/research/covenants-use-case-atlas
[ademan delving lark]: https://delvingbitcoin.org/t/improving-the-security-of-lark-oor-channels-with-equivocation-bonds/2816
[news177 bech32]: /en/newsletters/2021/12/01/#bitcoin-core-16807
[news419 gettxspendingprevout]: /fr/newsletters/2026/08/21/#bitcoin-core-35889
[news379 eclair liquidity]: /fr/newsletters/2025/11/07/#eclair-3206
[news418 eclair flags]: /fr/newsletters/2026/08/14/#eclair-3341
[news419 hwi]: /fr/newsletters/2026/08/21/#hwi-842
[news404 eclair taproot]: /fr/newsletters/2026/05/08/#eclair-3144
[news420 hwi]: /fr/newsletters/2026/08/28/#hwi-841
[Core Lightning 26.06.7]: https://github.com/ElementsProject/lightning/releases/tag/v26.06.7
[LND v0.21.3-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.21.3-beta
[LND v0.20.4-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.20.4-beta
[news420 cln embargo]: /fr/newsletters/2026/08/28/#preparez-vous-a-une-prochaine-version-de-securite-de-core-lightning
[news420 lnd deadlock]: /fr/newsletters/2026/08/28/#lnd-11008
[news419 lnd account]: /fr/newsletters/2026/08/21/#lnd-11065
