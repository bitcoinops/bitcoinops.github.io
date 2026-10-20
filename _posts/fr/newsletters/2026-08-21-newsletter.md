---
title: 'Bulletin Hebdomadaire Bitcoin Optech #419'
permalink: /fr/newsletters/2026/08/21/
name: 2026-08-21-newsletter-fr
slug: 2026-08-21-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine résume la divulgation d'une vulnérabilité de réorganisation corrigée dans les fermetures de canaux de LND et
décrit un projet de BIP pour le descripteur de script de sortie `rawtr()`. Sont également incluses nos rubriques habituelles décrivant les
changements récents dans les services et logiciels clients, ainsi que les changements notables dans les logiciels d'infrastructure Bitcoin
populaires.

## Nouvelles

- **Vulnérabilité de réorganisation dans les fermetures de canaux de LND** : Bastien Teinturier a [publié][lnd vuln del] sur Delving Bitcoin
  la [divulgation responsable][topic responsible disclosures] d'une vulnérabilité qui affectait les versions de LND antérieures à
  [0.20.0][lnd v20.0], qui l'a corrigée en février 2026. Les opérateurs exécutant une version plus ancienne devraient mettre à niveau. À la
  connaissance de Teinturier, personne n'a été affecté par la vulnérabilité.

  Avant cette version, un nœud LND oubliait un canal fermé de manière collaborative immédiatement après la première confirmation onchain,
  perdant la protection contre les réorganisations de chaîne. En cas de réorganisation, un attaquant pouvait publier une ancienne
  transaction d'engagement révoquée pour le canal et, parce que le nœud avait déjà oublié le canal, il ne publierait pas de transaction de
  pénalité, permettant à l'attaquant de vider tous les fonds du canal.

  La vulnérabilité a été découverte en février 2025 et corrigée dans [LND #10331][] (voir le [Bulletin #389][news389 lnd10331]). Le
  correctif fait attendre à un nœud davantage de confirmations avant de considérer qu'une fermeture de canal est finale (au moins six,
  conformément à la gestion de la sécurité contre les réorganisations de [BOLT5][]). Le message de Teinturier inclut une reproduction en
  regtest et une chronologie de la divulgation.

- **Projet de BIP pour le descripteur de script de sortie `rawtr()`** : Jean Pablo a [publié][rawtr ml] sur la liste de diffusion
  Bitcoin-Dev à propos d'une proposition de BIP pour le [descripteur de script de sortie][topic descriptors] `rawtr()`.

  Un descripteur `rawtr()` peut être utilisé pour exprimer directement une sortie P2TR par sa clé de sortie, sans avoir besoin d'une clé
  interne ni d'un arbre de scripts. La clé est utilisée comme clé de sortie [taproot][topic taproot] sans appliquer le tweak de [BIP341][].
  Cela est utile, par exemple, lorsque la structure interne n'est pas connue, ou que l'arbre de scripts n'a pas été révélé par le
  propriétaire.

  Ce descripteur est disponible dans Bitcoin Core depuis la version 24.0, mais n'avait pas encore été spécifié dans un BIP. Plusieurs
  implémentations contournent le problème soit en ne le prenant pas en charge, soit en citant d'autres BIP. La proposition vise à combler
  cette lacune. Le projet de BIP et les vecteurs de test sont disponibles et font l'objet de discussions dans [BIPs #2251][].

## Changements dans les services et logiciels clients

*Dans cette rubrique mensuelle, nous mettons en lumière des mises à jour intéressantes des portefeuilles et services Bitcoin.*

- **Publication de Payjoin Dev Kit (rust-payjoin) 1.0.0 :** Le projet Payjoin Dev Kit a [publié][payjoin 1.0.0] la première version stable
  de rust-payjoin, prenant en charge à la fois les [payjoins][topic payjoin] BIP78 synchrones et les payjoins BIP77 asynchrones avec des
  sessions persistantes et pouvant être reprises.

- **Plugin d'envoi Silent Payments pour Electrum :** Ali Sherief a [publié][sp electrum delving] un plugin qui ajoute l'envoi (sans
  réception) de [silent payments][topic silent payments] (BIP352) au portefeuille de bureau Electrum pour les portefeuilles logiciels à
  signature unique.

- **Annonce d'une implémentation de Superscalar :** 8144225309 a [annoncé][superscalar delving] une implémentation de Superscalar, la
  conception de [fabrique de canaux][topic channel factories] de ZmnSCPxj qui place de nombreux clients Lightning en auto-garde derrière un
  seul UTXO onchain sans soft fork (voir notre [podcast d'analyse approfondie de Superscalar][superscalar deepdive]).

- **Annonce du portefeuille multisig Cofund :** Cofund a [annoncé][cofund x] un portefeuille [multisig][topic multisignature] en auto-garde
  construit sur une architecture [taproot][topic taproot] (P2TR) basée sur des politiques, avec enregistrement de clés multi-fournisseurs et
  multisig hiérarchique.

- **Lexe ajoute des adresses lisibles par les humains et LNURL-withdraw :** Lexe, un portefeuille Lightning en auto-garde qui exécute le
  nœud de chaque utilisateur dans un environnement d'exécution de confiance (TEE) afin qu'il reste en ligne sans que l'opérateur n'en prenne
  la garde, a [annoncé][lexe x] la prise en charge des adresses bitcoin lisibles par les humains [BIP353][] (qui fonctionnent également
  comme adresses Lightning) et de [LNURL-withdraw][topic lnurl].

- **L'application Bitcoin Ledger 2.5.0 ajoute des descriptions de politiques lisibles par les humains :** Salvatore Ingala a
  [annoncé][salvatoshi x] la version 2.5.0 de l'application Bitcoin de Ledger, qui affiche une description lisible par les humains pour de
  nombreuses politiques de portefeuille [taproot][topic taproot] [miniscript][topic miniscript] et [multisig][topic multisignature] lors de
  l'enregistrement, au lieu de n'afficher que le modèle opaque de [descripteur][topic descriptors]. Cela facilite pour un utilisateur la
  vérification d'une politique et la détection d'une substitution malveillante (par exemple un 3-sur-5 remplacé par un 1-sur-5) avant son
  enregistrement.

- **Publication de Bark 0.5.0 :** Second a [publié][second x] la version 0.5.0 de Bark, son implémentation d'[Ark][topic ark], ajoutant la
  restauration du solde complet hors chaîne (VTXOs) d'un portefeuille à partir de sa phrase mnémonique et la prise en charge de réceptions
  Lightning vers des adresses Ark externes, ce qui permet des serveurs d'adresses Lightning non dépositaires.

- **Bitcoin-PIR pour des requêtes UTXO privées :** Weikeng Chen a [annoncé][bitcoinpir] Bitcoin-PIR, un système de récupération privée
  d'information (PIR) qui permet à un client léger de vérifier l'ensemble UTXO pour ses propres adresses ou scriptPubKeys sans révéler au
  serveur lesquels l'intéressent. Il offre un choix de quatre backends PIR : DPF-PIR, HarmonyPIR, OnionPIRv2 et un schéma ORAM soutenu par
  un environnement d'exécution de confiance (TEE).

- **Démonstration Ark avec OP_TEMPLATEHASH :** Steven Roose a [lancé][templatehash] une démonstration sur signet de Bark, l'implémentation
  d'[Ark][topic ark] de Second, fonctionnant avec `OP_TEMPLATEHASH`, un opcode de [covenant][topic covenants] de style [CTV][topic
  op_checktemplateverify] natif à taproot. La démo est construite à partir de la branche `templatehash` du [dépôt][bark gitlab] Bark.

- **Signatures basées sur des hachages formellement vérifiées de libshrincs :** Jonas Nick a [annoncé][libshrincs delving] libshrincs, une
  implémentation en C de signatures basées sur des hachages [post-quantiques][topic quantum resistance] avec une preuve de sécurité vérifiée
  par machine, écrite par remix7531.

## Changements notables dans le code et la documentation

_Changements récents notables dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning repo], [Eclair][eclair repo],
[LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet Interface (HWI)][hwi repo], [Rust Bitcoin][rust
bitcoin repo], [BTCPay Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement Proposals (BIPs)][bips repo], [Lightning
BOLTs][bolts repo], [Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition repo], et [BINANAs][binana repo]._

- [Bitcoin Core #32784][] ajoute une commande RPC de portefeuille `derivehdkey` qui dérive un xpub et, facultativement, un xprv à partir
  d'une [clé HD][topic bip32] connue du portefeuille selon un chemin de dérivation spécifié par l'appelant qui contient au moins une étape
  durcie. Cela est utile pour coordonner des portefeuilles multisig, dans lesquels chaque participant fournit un xpub dérivé d'un chemin
  différent du chemin par défaut du portefeuille pour les [descripteurs][topic descriptors] à signature unique. Étant donné que la
  dérivation durcie requiert le matériel de clé privée, le RPC n'est pas disponible pour les portefeuilles en surveillance seule, et les
  portefeuilles chiffrés doivent être déverrouillés.

- [Bitcoin Core #35797][] permet de renseigner les métadonnées de sortie [PSBT][topic psbt]v2 avant l'ajout de toute entrée lors de
  l'utilisation du RPC [`descriptorprocesspsbt`][topic descriptors] (voir le [Bulletin
  #253][news253 descriptorpsbt]). Auparavant, `UpdatePSBTOutput` utilisait la
  première entrée de la transaction non signée du PSBT lors du parcours d'un script de sortie, ce qui pouvait échouer lorsqu'un PSBTv2
  contenait des sorties mais aucune entrée. Désormais, il utilise une transaction temporaire contenant une entrée factice pour le parcours
  des métadonnées sans modifier le PSBT.

- [Bitcoin Core #35531][] réduit l'espace disque utilisé par l'option `-txindex` (voir le [Bulletin #161][news161 txindex]) en modifiant la
  manière dont les identifiants de transaction et les positions sont stockés. Au lieu de stocker chaque txid de 32 octets et la position
  disque de la transaction, le nouveau format utilise un préfixe de cinq octets d'un [SipHash][] salé du txid et encode le numéro de
  séquence du bloc ainsi que le décalage de la transaction dans un suffixe compact de six octets dans la clé de base de données, avec une
  valeur vide. Les recherches parcourent toutes les entrées qui partagent le préfixe, déterminent l'emplacement de bloc de chaque candidat à
  l'aide de l'index de blocs et vérifient le txid complet après lecture de la transaction depuis le disque, gérant les collisions en toute
  sécurité. Dans les tests sur le mainnet de l'auteur de la PR, un index entièrement reconstruit est passé d'environ 66 Go à 26 Go, tandis
  que le temps d'indexation a chuté d'environ 1 heure 50 minutes à 1 heure 19 minutes. Bien que les index existants restent lisibles, ils
  doivent être reconstruits pour récupérer de l'espace. Après reconstruction, les anciennes versions de Bitcoin Core ne peuvent pas lire les
  nouvelles entrées et devront également reconstruire l'index en cas de rétrogradation.

- [Bitcoin Core #35889][] améliore les performances du RPC `gettxspendingprevout` lors de la vérification de grands lots d'outpoints.
  Auparavant, lorsqu'une transaction dépensant un outpoint était trouvée dans le mempool, l'outpoint était effacé au milieu d'un vecteur
  pendant que le verrou du mempool était détenu, forçant le décalage des entrées restantes. Désormais, le RPC parcourt chaque requête une
  seule fois, stocke les résultats résolus à leurs index d'origine et ne collecte que les outpoints non résolus dans une liste de travail
  séparée pour recherche via l'index optionnel `txospenderindex` (voir le [Bulletin #394][news394 txospender]). Cela rend le passage sur le
  mempool linéaire au lieu de quadratique. Selon les benchmarks de l'auteur de la PR, de grands lots de requêtes ne visant que le mempool se
  sont exécutés environ 9 fois plus vite sur un Ryzen 7 3700X et 31 fois plus vite sur un Raspberry Pi 5.

- [Bitcoin Core #35605][] déprécie le RPC de portefeuille `removeprunedfunds` et le désactive par défaut. Les utilisateurs qui en ont encore
  besoin doivent utiliser l'option de démarrage `-deprecatedrpc=removeprunedfunds`. La suppression du RPC est prévue pour la prochaine
  version majeure. Il est retiré parce qu'il expose un comportement dangereux sans offrir d'utilité connue : il peut supprimer n'importe
  quelle transaction appartenant au portefeuille, y compris des transactions qui n'ont pas été ajoutées via le RPC connexe
  `importprunedfunds`. Il constitue également une charge de maintenance ; voir le [Bulletin #391][news391 removeprunedfunds] pour une
  couverture d'un précédent bug impliquant ce RPC.

- [Eclair #3352][] corrige des vérifications manquantes de la réserve de canal [BOLT2][] lorsque Eclair est le receveur de financement d'un
  canal à financement unique, garantissant que la limite de poussière d'aucune des deux parties ne dépasse la réserve de canal de l'autre
  partie. Sans ces vérifications, un pair pourrait dépenser son solde jusqu'à une réserve inférieure à la limite de poussière applicable,
  entraînant l'omission de sa sortie d'une transaction d'engagement et lui laissant aucun fonds onchain en risque lors de la publication
  d'un état révoqué. La PR ajoute également une limite configurable de taille de canal `eclair.channel.max-funding-satoshis`, qui vaut par
  défaut 5 milliards de satoshis (50 BTC). Cela rétablit une borne supérieure après que la prise en charge des [canaux wumbo][topic large
  channels] a permis des canaux au-dessus de l'ancienne limite du protocole.

- [Eclair #3351][] corrige plusieurs bugs dans le [financement à la volée][topic jit channels] (voir le [Bulletin #323][news323 fly]), une
  fonctionnalité actuellement utilisée par le nœud de fournisseur de services Lightning (LSP) d'ACINQ dans Phoenix Wallet. Plus précisément,
  après un redémarrage, Eclair pouvait ne pas reconnaître qu'un [HTLC][topic htlc] avait déjà été entièrement cosigné parce qu'il ne
  vérifiait que les changements de canal en attente. Cela pouvait potentiellement entraîner la retransmission deux fois du même paiement.
  Eclair vérifie désormais également les états d'engagement actuels avant de relayer. De plus, la PR résout plusieurs chemins d'échec dus
  aux délais d'attente et on-chain afin d'empêcher Eclair de payer un pair en aval après avoir échoué sur le HTLC amont correspondant.

- [Eclair #3345][] limite les ressources que chaque pair peut consommer lors de la demande et de la synchronisation des [annonces de
  canal][topic channel announcements] via les requêtes gossip [BOLT7][]. Une limite de débit configurable, fixée à 5 requêtes par seconde
  par défaut, s'applique par connexion à `query_channel_range` et `query_short_channel_ids`. Eclair attend que les réponses à une requête
  aient été envoyées avant d'accepter du travail supplémentaire afin de préserver la contre-pression du transport. Eclair ignore les
  identifiants courts de canaux (SCID) dupliqués pour empêcher l'amplification des réponses et rejette les requêtes malformées ou se
  chevauchant. Il limite également l'utilisation mémoire pendant la synchronisation en plafonnant chaque pair à 2 000 requêtes
  `query_short_channel_ids` en file d'attente. Des protections similaires de gestion des ressources avaient auparavant été ajoutées à LND
  (voir les bulletins [#366][news366 lnd gossip] et [#417][news417 lnd gossip]).

- [LND #8754][] implémente un mode expérimental de connexion sortante pour le signataire distant (voir le [Bulletin #172][news172 remote]),
  dans lequel les opérations sur clé privée sont déléguées à un serveur signataire séparé. Le signataire ne valide toujours pas
  indépendamment les requêtes qu'il reçoit ; il signera donc toute requête envoyée par le nœud en surveillance seule. Le nouveau mode ne
  change que la manière dont les deux se connectent. Au lieu que le signataire écoute une connexion entrante, il initie une connexion
  sortante vers un écouteur RPC dédié sur le nœud en surveillance seule, ce qui lui permet de fonctionner sans accepter de connexions
  entrantes. Cette configuration avait déjà été discutée dans le [Bulletin #326][news326 signer] en lien avec la génération déterministe de
  macaroons.

- [LND #11065][] ajoute un RPC expérimental `XCreateAccount` et une commande correspondante `lncli wallet accounts create`, afin de créer un
  compte nommé entièrement dépensable dont les clés sont dérivées de la clé maîtresse du portefeuille de LND. Cela diffère du RPC existant
  `ImportAccount` (voir le [Bulletin #144][news144 lnd xpub]), qui importe un xpub en surveillance seule. La [sélection de pièces][topic
  coin selection], les soldes, la dérivation d'adresses et la monnaie peuvent être limités à ce compte, fournissant des poches de fonds
  isolées au sein d'un même portefeuille. Le type d'adresse sélectionné est permanent et vaut par défaut [taproot][topic taproot].

- [HWI #842][] ajoute une commande `registerdescriptor` pour enregistrer un [descripteur de script de sortie][topic descriptors] nommé
  auprès des appareils matériels de signature pris en charge avant de signer des transactions depuis ce portefeuille. Des implémentations
  sont ajoutées pour BitBox02, Coldcard, Jade et les appareils Ledger non hérités. Pour les appareils qui utilisent les politiques de
  portefeuille [BIP388][] (voir le [Bulletin #302][news302 bip388]), HWI convertit le descripteur en un modèle de descripteur de
  portefeuille et un vecteur d'informations de clés ; il renvoie également toute donnée d'enregistrement spécifique à l'appareil nécessaire
  pour la signature ultérieure.

{% include snippets/recap-ad.md when="2026-08-25 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="10331,2251,32784,35797,35531,35889,35605,3352,3351,3345,8754,11065,842" %}

[payjoin 1.0.0]: https://github.com/payjoin/rust-payjoin/releases/tag/payjoin-1.0.0
[sp electrum delving]: https://delvingbitcoin.org/t/silent-payments-sender-bip352-plugin-for-electrum/2743
[superscalar delving]: https://delvingbitcoin.org/t/superscalar-an-implementation-report/2705
[superscalar deepdive]: /en/podcast/2024/10/31/
[cofund x]: https://x.com/getcofund/status/2085389177193972164
[lexe x]: https://x.com/lexeapp/status/2079245197817548964
[salvatoshi x]: https://x.com/salvatoshi/status/2086727660353261863
[second x]: https://x.com/secondhq/status/2084716752789991614
[bitcoinpir]: https://bitcoinpir.org
[templatehash]: https://templatehash.com
[bark gitlab]: https://gitlab.com/ark-bitcoin/bark
[libshrincs delving]: https://delvingbitcoin.org/t/libshrincs-a-c-implementation-with-a-machine-checked-security-proof/2795
[lnd vuln del]: https://delvingbitcoin.org/t/disclosure-lnd-doesnt-wait-for-enough-confirmations-when-closing-channels/2800
[lnd v20.0]: https://github.com/lightningnetwork/lnd/releases/tag/v0.20.0-beta
[rawtr ml]: https://groups.google.com/g/bitcoindev/c/CCZN_qQ5C1s
[SipHash]: https://en.wikipedia.org/wiki/SipHash
[news389 lnd10331]: /fr/newsletters/2026/01/23/#lnd-10331
[news253 descriptorpsbt]: /fr/newsletters/2023/05/31/#bitcoin-core-25796
[news161 txindex]: /en/newsletters/2021/08/11/#bitcoin-core-pr-review-club
[news394 txospender]: /fr/newsletters/2026/02/27/#bitcoin-core-24539
[news391 removeprunedfunds]: /fr/newsletters/2026/02/06/#bitcoin-core-34358
[news323 fly]: /fr/newsletters/2024/10/04/#eclair-2861
[news172 remote]: /en/newsletters/2021/10/27/#lnd-5689
[news326 signer]: /fr/newsletters/2024/10/25/#lnd-9172
[news366 lnd gossip]: /fr/newsletters/2025/08/08/#lnd-10097
[news417 lnd gossip]: /fr/newsletters/2026/08/07/#lnd-10992
[news302 bip388]: /fr/newsletters/2024/05/15/#bips-1389
[news144 lnd xpub]: /en/newsletters/2021/04/14/#lnd-5047
