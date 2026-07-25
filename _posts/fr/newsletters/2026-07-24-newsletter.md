---
title: 'Bulletin Hebdomadaire Bitcoin Optech #415'
permalink: /fr/newsletters/2026/07/24/
name: 2026-07-24-newsletter-fr
slug: 2026-07-24-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine décrit un projet de BIP pour l'agrégation complète des signatures BIP340. Sont également incluses nos sections
régulières décrivant les changements récents apportés aux services et aux logiciels clients, annonçant de nouvelles versions et versions
candidates, et résumant les changements notables dans les logiciels populaires d'infrastructure Bitcoin.

## Nouvelles

- **Projet de BIP pour l'agrégation complète des signatures BIP340** : Fabian Jahr a [publié][aggr ml] sur la liste de diffusion Bitcoin-Dev
  un nouveau projet de BIP pour l'agrégation complète des [signatures schnorr BIP340][topic schnorr signatures], une norme pour le schéma de
  signature agrégée DahLIAS (voir le [Bulletin #351][news351 dahlias]), qui décrit un processus permettant de combiner un ensemble de
  signatures en une seule signature agrégée, avec une taille de seulement 64 octets, quel que soit le nombre de signataires. Cependant, le
  protocole décrit est interactif et nécessite la coopération de tous les signataires et implique la présence d'un coordinateur non fiable
  afin de réduire la complexité des communications. Le rôle de coordinateur peut être assumé par n'importe lequel des signataires
  participant au processus.

  Le processus est divisé en deux tours :

  1. Chaque signataire commence la session de signature en calculant un nonce secret (`secnonce`) et un nonce public (`pubnonce`).
  `pubnonce` est envoyé au coordinateur, qui les agrège (`aggnonce`) et renvoie le résultat aux signataires, accompagné d'autres
  informations.

  2. Chaque signataire calcule une signature partielle à l'aide de la clé secrète, de `secnonce`, du message à signer et des informations
  fournies. Les signatures partielles sont ensuite envoyées au coordinateur, qui les agrège en une signature unique de 64 octets.

  Selon Jahr, l'une des applications possibles de la proposition serait l'[agrégation inter-entrées des signatures (CISA)][topic cisa], une
  modification du consensus de Bitcoin qui réduirait la taille et donc les frais onchain des transactions à entrées multiples. Cependant,
  l'auteur a précisé que la modification du consensus est hors du champ d'application de ce BIP.

  Le projet de BIP, désormais désigné sous le nom de BIP459, est actuellement discuté dans [BIPs #2210][] et la proposition recueille des
  retours de la communauté.

## Changements dans les services et logiciels clients

*Dans cette rubrique mensuelle, nous mettons en lumière des mises à jour intéressantes des portefeuilles et services Bitcoin.*

- **Wasabi Wallet 2.8.0 publié :** Wasabi Wallet [2.8.0][wasabi 2.8.0] télécharge les [filtres de blocs compacts][topic compact block
  filters] directement depuis le réseau P2P, supprimant ainsi le serveur backend centralisé auparavant requis. La version ajoute également
  la possibilité de payer des destinataires directement au sein d'un [coinjoin][topic coinjoin], la prise en charge de [taux de frais
  inférieurs à 1 sat/vbyte][topic default minimum transaction relay feerates], ainsi que le [batching de paiements][topic payment batching],
  entre autres fonctionnalités.

- **Coinswap v0.2.2 publié :** Coinswap [v0.2.2][coinswap v0.2.2] ajoute les swaps multi-transactions, des preuves de dénégation plausible,
  ainsi que des améliorations de la place de marché à son implémentation du protocole [coinswap][topic coinswap] (voir le Bulletin
  [#338][news338 coinswap]). La version inclut également des corrections pour des problèmes identifiés lors d'un audit de sécurité réalisé à
  l'aide de Loupe, le scanner de sécurité open source propulsé par IA de Spiral.

- **Annonce d'une bibliothèque secp256k1 pour Go :** Allocz a [annoncé][secp256k1 go delving] une [bibliothèque Go][secp256k1 go] qui
  utilise des liaisons vers [libsecp256k1][libsecp256k1 repo] lorsque l'interopérabilité avec C est activée et revient sinon à une
  implémentation pure Go, préservant ainsi la capacité de compilation croisée de Go. L'auteur rapporte que les temps de vérification ECDSA
  et des [signatures schnorr][topic schnorr signatures] diminuent de 70 % par rapport à l'implémentation pure Go.

- **Annonce d'un tableau de bord ASMap :** Joris Strakeljahn a [annoncé][asmap delving] un [tableau de bord ASMap][asmap dashboard] qui suit
  l'historique des publications de [données ASMap][github asmap-data] (voir le Bulletin [#394][news394 asmap]), y compris la part de
  l'espace d'adressage qui change d'opérateur d'une publication à l'autre et dans quelle mesure chaque publication couvre les nœuds Bitcoin
  réellement observés à mesure que les données vieillissent.

- **Publication de l'alpha de Wavelength :** Lightning Labs a [annoncé][wavelength blog] une version alpha de Wavelength, une boîte à outils
  permettant d'ajouter des paiements en auto-garde aux applications. Elle paie et reçoit des factures LN BOLT11, et regroupe des transferts
  off-chain en lots à l'aide d'une couche de règlement de type [Ark][topic ark], sans obliger les utilisateurs à gérer leurs propres canaux.
  L'alpha est disponible sur [signet][topic signet] et testnet.

## Mises à jour et versions candidates

_Nouvelles versions et versions candidates pour des projets d'infrastructure Bitcoin populaires. Veuillez envisager de mettre à niveau vers
les nouvelles versions ou d'aider à tester les versions candidates._

- [Core Lightning v26.06.6][] est une version de maintenance de cette implémentation de nœud LN. Elle met à jour la dépendance `coincurve`
  de la bibliothèque intégrée `pyln-proto` pour corriger les environnements de compilation Python et ajoute une vérification qui rejette
  tout canal réutilisant l'outpoint de financement d'un canal existant.

- [Bitcoin Inquisition 29.4][] est une version de ce nœud complet [signet][topic signet] conçu pour expérimenter avec des soft forks
  proposés et d'autres changements majeurs du protocole. Basée sur Bitcoin Core 29.4, elle ajoute l'activation de [BIP446][]
  (`OP_TEMPLATEHASH`), un opcode [tapscript][topic tapscript] proposé qui pousse sur la pile un hachage de la transaction de dépense (voir
  le [Bulletin #365][news365 templatehash]), à son ensemble existant de propositions de soft fork activées expérimentalement.

## Changements notables dans le code et la documentation

_Changements récents notables dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning repo], [Eclair][eclair repo],
[LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet Interface (HWI)][hwi repo], [Rust Bitcoin][rust
bitcoin repo], [BTCPay Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement Proposals (BIPs)][bips repo], [Lightning
BOLTs][bolts repo], [Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition repo], et [BINANAs][binana repo]._

- [Bitcoin Core #35215][] accélère les recherches dans le cache UTXO en mémoire (`CCoinsMap`) en remplaçant `SipHash-2-4`, la fonction
  utilisée pour hacher ses clés `COutPoint`, par une variante [SipHash][] plus rapide et conçue pour cet usage, `SipHasher13UJ`. Chaque coin
  est recherché à l'aide d'une clé qui combine son txid et son numéro de sortie, et chaque recherche fait passer cette clé dans une fonction
  de hachage. `SipHash-2-4` digère le txid de 32 octets d'un coin en quatre morceaux distincts de 64 bits, de sorte que le hachage d'un
  outpoint exécute 14 tours internes. `SipHasher13UJ`, au contraire, prend le txid entier en une seule étape de 256 bits et effectue moins
  de tours, ramenant ce total à cinq. L'auteur rapporte un débit de hachage environ deux fois supérieur dans des benchmarks isolés et une
  réduction d'environ 5 % lors d'une exécution de réindexation de chainstate.

- [Bitcoin Core #35766][] active le [transport p2p v2 BIP324][topic v2 p2p transport] par défaut lors de la première connexion à des
  adresses provenant des graines DNS et des graines fixes intégrées à la compilation. La prise en charge expérimentale de BIP324 a été
  livrée dans Bitcoin Core 26.0 et activée par défaut dans 27.0. Comme ces mécanismes de graines fournissent des adresses sans drapeaux de
  service, Bitcoin Core traitait auparavant ces pairs comme uniquement v1 et les premières connexions automatiques d'un nœud n'essayaient
  jamais le transport chiffré. La nouvelle fonction `SeedsAssumedServiceFlags()` suppose désormais `NODE_P2P_V2` pour ces adresses. Si cette
  hypothèse est incorrecte pour un pair donné, le nœud se reconnecte simplement en v1. Les connexions établies via l'option `-seednode` et
  la récupération d'adresses tentent déjà v2 par défaut.

- [BIPs #2075][] clarifie la description de [BIP174][] sur la manière dont les [PSBT][topic psbt] sont combinées. La spécification affirmait
  que la combinaison de PSBT mises à jour indépendamment était inconditionnellement indépendante de l'ordre, mais cela n'est vrai que
  lorsque les participants ajoutent des champs distincts. Lorsque deux PSBT contiennent la même clé avec des valeurs différentes, un
  combineur peut choisir l'une ou l'autre valeur ou refuser la combinaison, de sorte que la spécification note désormais que, dans ce cas,
  le résultat n'est pas commutatif.

- [BIPs #2204][] met à jour les projets de spécification [BIP440][] et [BIP441][] de la Great Script Restoration (voir le [Bulletin
  #400][news400 gsr]). Cette mise à jour introduit la notation `wordspan`, qui arrondit vers le haut la longueur en octets d'un élément de
  pile jusqu'à la prochaine frontière de huit octets, et retravaille de nombreuses formules de coût d'opération afin que les opérations qui
  traitent des données en mots de 64 bits soient tarifées selon `wordspan`, tandis que celles qui travaillent sur les octets exacts
  conservent un coût basé sur `length`. La mise à jour corrige également la définition de `OP_RIGHT` et clarifie les coûts et les
  vérifications de plage pour plusieurs autres opcodes.

- [Core Lightning #8935][] corrige un bug qui pouvait amener un nœud à [RBF][topic rbf] une transaction de manière répétée, même après qu'un
  remplacement avait déjà été confirmé. CLN stocke les transactions en attente dans un `outgoing_tx_map` indexé par le txid d'origine, mais
  remplace l'objet transaction à chaque version avec frais plus élevés sans modifier la clé. La boucle par bloc `rebroadcast_txs()`
  vérifiait la confirmation à l'aide de l'ancien txid d'origine, qui n'était jamais miné, et continuait donc à invoquer la logique de
  rediffusion et de remplacement même si la transaction la plus récente avait été confirmée. Comme le txid sert de clé de table de hachage
  et ne peut pas être mis à jour en place, la boucle calcule désormais le txid de la transaction courante à chaque itération et l'utilise
  pour les vérifications de confirmation.

- [Core Lightning #9324][] corrige une régression de `Renepay` (voir le [Bulletin
  #263][news263 renepay]) présente depuis la v26.04 qui construisait des [HTLC][topic htlc]
  avec des expirations CLTV environ un bloc de hauteur trop loin dans le futur. Les données de routage de Renepay incorporaient déjà la
  hauteur de bloc courante dans la valeur CLTV de chaque saut, mais `route_sendpay_request()` ajoutait une seconde fois la hauteur de bloc
  lors du passage de la route à `sendpay`, doublant approximativement l'expiration. Les nœuds de transfert pouvaient alors rejeter l'oignon
  avec `expiry_too_far`.

- [libsecp256k1 #1765][] ajoute un module optionnel `silentpayments` qui implémente les opérations sur courbe elliptique définies par les
  [paiements silencieux BIP352][topic silent payments]. Pour les expéditeurs, une fonction combine les clés privées d'entrée de
  l'expéditeur, l'outpoint le plus bas de la transaction, et les clés publiques de scan et de dépense publiées par le destinataire afin de
  dériver les clés de sortie que la transaction doit payer. Pour les récepteurs, le scan par nœud complet détecte quelles sorties d'une
  transaction appartiennent au destinataire et renvoie les tweaks nécessaires pour les dépenser, en travaillant uniquement à partir de la
  clé secrète de scan du destinataire et de sa clé publique de dépense, afin que la clé privée de dépense puisse rester hors ligne. Des
  fonctions séparées gèrent les labels, une fonctionnalité optionnelle de [BIP352][] qui permet aux destinataires de dériver des variantes
  distinguables de leur adresse afin de différencier les paiements entrants et de signaler leur propre monnaie rendue. La prise en charge du
  scan côté client léger a été reportée à une PR ultérieure.

- [Rust Bitcoin #6317][] met à jour son décodage du [relais de blocs compacts][topic compact block relay] afin de rejeter les messages
  `sendcmpct` dont le champ booléen d'annonce n'est pas exactement `0` ou `1`, comme l'exige [BIP152][]. Auparavant, Rust Bitcoin décodait
  le champ à l'aide d'un test non nul, acceptant toute valeur non nulle comme vraie (mode haute bande passante). Cette PR reproduit le
  durcissement équivalent dans Bitcoin Core (voir le [Bulletin #412][news412 sendcmpct]).

- [BTCPay Server #7457][] ajoute la possibilité d'importer des [labels de portefeuille][topic wallet labels] au format JSON Lines de
  [BIP329][], complétant ainsi la fonctionnalité d'export existante. Auparavant, les labels étaient effectivement perdus lors d'un
  déplacement vers un autre serveur, et les fichiers de labels produits par des portefeuilles compatibles BIP329 tels que Sparrow ou Envoy
  ne pouvaient pas du tout être chargés. L'importateur lit les enregistrements `tx`, `addr` et `output` du format et les associe aux objets
  transaction, adresse et UTXO de BTCPay, en ignorant les enregistrements qu'il ne peut pas appliquer.

- [BLIPs #71][] ajoute une réponse `dnssec_error` à [BLIP32][], le protocole qui résout les noms de paiement lisibles par l'humain de
  [BIP353][] en transportant des requêtes et preuves DNSSEC sur des messages onion Lightning (voir le [Bulletin
  #306][news306 blip32]). Auparavant, le protocole ne définissait que `dnssec_query`
  et `dnssec_proof`, de sorte que les résolveurs incapables de répondre n'avaient aucun moyen normalisé de l'indiquer au demandeur, qui
  continuait à attendre. Le nouveau TLV de saut final (type `65550`) reprend le `domain_name` interrogé et inclut un booléen
  `definitely_unresolvable` qu'un résolveur doit définir pour les échecs terminaux, tels que NXDOMAIN ou un nom non signé, et ne doit pas
  définir pour d'autres échecs, possiblement transitoires.

{% include snippets/recap-ad.md when="2026-07-28 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="2210,35215,35766,8935,9324,1765,6317,7457,2075,2204,71" %}

[aggr ml]: https://groups.google.com/g/bitcoindev/c/TF5mPfy58RQ/m/vAk1Mfg2AwAJ
[news351 dahlias]: /fr/newsletters/2025/04/25/#signatures-agregees-interactives-compatibles-avec-secp256k1
[wavelength blog]: https://lightning.engineering/posts/2026-07-21-wavelength-launch/
[wasabi 2.8.0]: https://github.com/WalletWasabi/WalletWasabi/releases/tag/v2.8.0
[coinswap v0.2.2]: https://github.com/citadel-tech/coinswap/releases/tag/v0.2.2
[news338 coinswap]: /fr/newsletters/2025/01/24/#sortie-de-coinswap-v0-1-0
[secp256k1 go delving]: https://delvingbitcoin.org/t/a-faster-go-golang-secp256k1-library/2658
[secp256k1 go]: https://github.com/allocz/secp256k1
[asmap delving]: https://delvingbitcoin.org/t/asmap-dashboard-tracking-the-asmap-data-history-against-the-observed-network/2652
[asmap dashboard]: https://jorisstrakeljahn.github.io/asmap-dashboard/
[github asmap-data]: https://github.com/bitcoin/bitcoin/blob/master/doc/asmap-data.md
[news394 asmap]: /fr/newsletters/2026/02/27/#bitcoin-core-28792
[news263 renepay]: /fr/newsletters/2023/08/09/#core-lightning-6376
[news412 sendcmpct]: /fr/newsletters/2026/07/03/#bitcoin-core-35550
[news400 gsr]: /fr/newsletters/2026/04/10/#bips-2118
[news306 blip32]: /fr/newsletters/2024/06/07/#blips-32
[news365 templatehash]: /fr/newsletters/2025/08/01/#proposition-de-op-templatehash-natif-a-taproot
[SipHash]: https://en.wikipedia.org/wiki/SipHash
[Core Lightning v26.06.6]: https://github.com/ElementsProject/lightning/releases/tag/v26.06.6
[Bitcoin Inquisition 29.4]: https://github.com/bitcoin-inquisition/bitcoin/releases/tag/v29.4-inq
