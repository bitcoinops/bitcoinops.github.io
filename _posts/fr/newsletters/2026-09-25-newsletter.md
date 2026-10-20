---
title: 'Bulletin Hebdomadaire Bitcoin Optech #424'
permalink: /fr/newsletters/2026/09/25/
name: 2026-09-25-newsletter-fr
slug: 2026-09-25-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine décrit une proposition de mise à niveau des protocoles hors chaîne du Lightning Network vers une sécurité
post-quantique. Sont également incluses nos rubriques régulières avec une sélection de questions et réponses de Bitcoin Stack Exchange, des
annonces de nouvelles versions et versions candidates, ainsi que des descriptions de changements notables dans des logiciels
d'infrastructure Bitcoin populaires.

## Nouvelles

- **Proposition pour un Lightning Network post-quantique** : Ahmet Kurt a [publié][pqln del] sur Delving Bitcoin une nouvelle proposition de
  mise à niveau des surfaces hors chaîne du Lightning Network afin qu'elles soient [résistantes aux ordinateurs quantiques][topic quantum
  resistance], appelée PQLN, s'appuyant sur l'analyse couche par couche couverte dans le [Bulletin #408][news408 pq ln]. L'auteur et ses
  collaborateurs ont également publié un [article][pqln paper] sur le sujet et une [implémentation][pqln repo] fonctionnelle basée sur
  rust-lightning est disponible pour des tests.

  Kurt a expliqué comment les différentes couches du Lightning Network ont été modifiées pour atteindre une sécurité post-quantique (PQ).
  Cependant, il a souligné qu'aucune modification n'a été effectuée dans les couches qui gèrent les opérations onchain, car cette partie
  nécessiterait un changement de consensus. Voici les principaux changements :

  - Gossip ([BOLT7][]) : les clés PQ sont distribuées directement via le gossip lui-même. Le message `node_announcement` transporte les clés
    publiques ML-DSA et ML-KEM du nœud ainsi que la signature ML-DSA. Le message `channel_update` ne transporte que la signature. Les clés
    sont épinglées, de sorte que le nœud peut rejeter toute annonce tentant de les remplacer. L'auteur a noté que le message
    `channel_announcement` n'a pas été modifié, car le message serait falsifiable à moitié en raison du fait que deux de ses quatre
    signatures sont réalisées avec les clés de financement onchain.
  - Transport ([BOLT8][]) : la poignée de main Noise devient hybride en utilisant deux encapsulations ML-KEM. La première est destinée à la
    clé statique épinglée, l'autre va à une nouvelle clé éphémère afin de fournir la confidentialité persistante. Aucune négociation in-band
    n'est effectuée, car un attaquant PQ pourrait facilement falsifier les messages concernés.
  - Factures ([BOLT11][]) : étant donné qu'un champ balisé dans une facture contient au maximum 639 octets, la signature ML-DSA-44, qui a
    une taille de 2420 octets, doit être répartie sur 4 champs différents.
  - Offres ([BOLT12][]) : puisqu'une [offre][topic offers] transporte sa propre ancre, le nœud engage une nouvelle clé ML-DSA pour chacune
    d'entre elles. Le payeur vérifie la facture par rapport à cette clé avant qu'un quelconque [HTLC][topic htlc] ne soit envoyé.
  - Oignon ([BOLT4][]) : puisqu'un texte chiffré ML-KEM ne peut pas être placé à l'intérieur d'un oignon en raison de sa taille, l'oignon
    conserve son format, tandis que le secret Sphinx devient hybride. Les textes chiffrés sont envoyés avec l'oignon dans le message
    `update_add_htlc` dans une liste de 20 emplacements. Pour empêcher un nœud de déduire la longueur de la route, chaque emplacement
    inutilisé est rempli avec un texte chiffré factice.

  Selon Kurt, le véritable coût de cette transition est la bande passante. Un nœud doit télécharger 10 fois plus de données et en stocker 9
  fois plus qu'un simple nœud LN. D'autre part, le calcul ne pose pas problème. En fait, l'opération la plus coûteuse, la signature ML-DSA,
  ne prend que 0,33 ms. L'auteur a testé l'interopérabilité avec des nœuds classiques sur regtest. Les résultats ont été positifs, les nœuds
  PQLN revenant au protocole classique lorsqu'un nœud classique se trouvait sur la route de paiement, ou échouant avant qu'un quelconque
  HTLC ne soit envoyé lorsque le drapeau require-PQ était défini.

  Enfin, l'auteur a présenté certains problèmes ouverts, tels que l'épinglage, qui protège uniquement les nœuds qui s'étaient déjà
  rencontrés avant qu'un ordinateur quantique cryptographiquement pertinent ne soit disponible, la limite `MAX_EXCESS_BYTES_FOR_RELAY` de 1
  024 octets dans rust-lightning qui empêche les nœuds non-PQ de relayer le gossip PQ, ainsi que l'attribution encore en attente des bits de
  fonctionnalité et des types TLV.

## Questions et réponses sélectionnées de Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] est l'un des premiers endroits où les contributeurs d'Optech cherchent des réponses à leurs
questions---ou quand nous avons quelques moments libres pour aider les utilisateurs curieux ou confus. Dans cette rubrique mensuelle, nous
mettons en lumière certaines des questions et réponses les mieux votées postées depuis notre dernière mise à jour.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Quel inconvénient si la somme au lieu de SHA256 des montants était utilisée dans le message de signature taproot ?]({{bse}}130977)
  L'utilisateur 1uba explique que s'engager uniquement sur la somme des montants d'entrée dans un hash de signature
  (sighash) [taproot][topic taproot] empêcherait toujours l'attaque de surpaiement des frais citée par [BIP341][], mais que le logiciel
  préparant une transaction pour un dispositif de signature pourrait alors permuter les montants entre les entrées tant que le total restait
  le même. Cela affecte les signataires hors ligne et les transactions collaboratives, où un signataire doit vérifier le montant de sa
  propre entrée.

- [Après le fork post-BIP110, est-il nécessaire de resynchroniser depuis le bloc 0 ?]({{bse}}131037) Murch s'attend à ce qu'un nœud Bitcoin
  Knots élagué qui appliquait les règles BIP110 (voir le [Bulletin #418][news418 bip110]) conserve toujours le dernier bloc commun aux deux
  chaînes, car peu de blocs ont été ajoutés à la chaîne BIP110 avant la dernière exécution du nœud. Installer Bitcoin Core à sa place
  devrait fonctionner, mais si le nœud ne se réorganise pas de lui-même, il suggère d'essayer `reconsiderblock` sur le premier bloc que le
  nœud BIP110 a rejeté.

- [Un nœud Bitcoin peut-il construire un ensemble UTXO partiel uniquement à partir des blocs les plus récents et l'utiliser pour valider de nouvelles transactions ?]({{bse}}131051)
  Pieter Wuille explique qu'un tel nœud ne peut pas savoir si une entrée manquante a déjà été
  dépensée ou a été créée dans un bloc qu'il a ignoré. Parce qu'il ne peut pas rejeter une transaction comme invalide, ce schéma n'effectue
  aucune validation utile et est équivalent en matière de sécurité au SPV, qui repose entièrement sur la preuve de travail.

## Mises à jour et versions candidates

_Nouvelles versions et versions candidates pour des projets d'infrastructure Bitcoin populaires. Veuillez envisager de mettre à niveau vers
les nouvelles versions ou d'aider à tester les versions candidates._

- [Bitcoin Core 32.0rc2][] est une version candidate pour la prochaine version majeure de l'implémentation de nœud complet prédominante. Un
  [guide de test][bcc32 testing] est disponible.

- [Core Lightning 26.06.8][] est une version de sécurité de cette implémentation populaire de nœud LN. Elle inclut des corrections de bugs
  pour des vulnérabilités signalées de manière responsable. Le code source est disponible immédiatement. Cependant, quelques tests sont
  temporairement retenus afin de donner aux utilisateurs plus de temps pour mettre à niveau avant que les attaquants ne puissent facilement
  identifier les vulnérabilités. Les nœuds ayant exécuté des builds de développement ne peuvent pas rétrograder vers cette version car leur
  schéma de base de données est plus récent. Le projet recommande fortement la mise à niveau.

- [LDK v0.3-rc2][] est une deuxième version candidate pour la prochaine version majeure de cette bibliothèque permettant de construire des
  portefeuilles et applications compatibles LN. Elle ajoute l'augmentation de frais [RBF][topic rbf] pour les [splices][topic splicing] en
  attente et la prise en charge de l'ajout et de la suppression de fonds dans le même splice. Elle négocie également les [canaux
  anchor][topic anchor outputs] par défaut et exige des applications qu'elles acceptent explicitement les canaux entrants. La mise à niveau
  invalide les factures [BOLT11][] précédemment émises contenant des métadonnées de paiement. Les développeurs devraient examiner les
  [changements d'API et de compatibilité descendante][ldk 0.3 notes] avant de tester.

## Changements notables dans le code et la documentation

_Changements récents notables dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning repo], [Eclair][eclair repo],
[LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet Interface (HWI)][hwi repo], [Rust Bitcoin][rust
bitcoin repo], [BTCPay Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement Proposals (BIPs)][bips repo], [Lightning
BOLTs][bolts repo], [Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition repo], et [BINANAs][binana repo]._

- [Bitcoin Core #34566][] ajoute la prise en charge de répertoires de données multi-signet (voir Le [Bulletin #412][news412 netmagic]),
  permettant à des [signets][topic signet] personnalisés de partager un répertoire de données de base sans que leurs données de chaîne
  n'entrent en conflit. Chaque signet personnalisé utilise un sous-répertoire `signet_XXXXXXXX`, suffixé par son identifiant réseau de
  quatre octets dérivé du défi signet. Pour éviter une resynchronisation après la mise à niveau, les utilisateurs existants de signet
  personnalisé devraient manuellement renommer leur répertoire selon le nouveau format.

- [BIPs #1951][] ajoute [BIP138][], une spécification pour un schéma de chiffrement compact pour des données de portefeuille autres que les
  seeds, telles que des sauvegardes de [descripteurs][topic descriptors] et des politiques de portefeuille [BIP388][] (voir le [Bulletin
  #351][news351 backup]). La clé de chiffrement est dérivée des clés publiques racines des clés publiques étendues (xpubs) admissibles du
  descripteur, et la sauvegarde stocke des données de récupération qui permettent à toute personne détenant l'une de ces clés de la
  déchiffrer. Un cosignataire peut récupérer un descripteur multisig à partir de sa propre seed sans avoir besoin des clés des autres
  cosignataires. Puisque le déchiffrement n'utilise que du matériel de clé publique, la charge utile doit exclure les clés privées. La
  confidentialité dépend du fait que les xpubs ne soient jamais divulgués. Les portefeuilles à signature unique qui envoient un xpub de
  compte à un serveur, comme les applications de bureau Ledger et Trezor, permettraient à ce serveur de déchiffrer chaque sauvegarde d'un
  multisig réutilisant cet xpub ; ainsi, le BIP recommande de construire les multisigs à partir de comptes, tels que BIP48 ou BIP87, dont
  les xpubs n'ont jamais été partagés.

- [BIPs #2224][] ajoute [BIP461][], qui spécifie un algorithme unique déterministe de signature ECDSA, garantissant qu'une clé privée et un
  message donnés produiront toujours la même signature. Les signataires dérivent les nonces avec la RFC 6979, appliquent le [low-r
  grinding][topic low-r grinding] en réessayant avec un compteur jusqu'à ce que `r` s'encode sans octet zéro en tête, et normalisent `s`
  vers sa forme basse. Parce que la sortie est déterministe, un détenteur de clé peut charger la même clé dans deux signataires
  indépendants, signer le même message, et comparer les résultats. Toute différence révèle qu'au moins un signataire ne suit pas la
  spécification, ce qui pourrait indiquer une tentative de [fuite de matériel de clé][topic exfiltration-resistant signing] via la sélection
  de nonce, comme dans l'attaque Dark Skippy (voir le [Bulletin #315][news315 dark skippy]).

- [Core Lightning #9507][] ajoute des bornes de taux de frais manquantes et corrige des dépassements qui pouvaient transformer de très
  grandes estimations de frais en taux presque nuls ou provoquer des crashs répétés du nœud. Auparavant, les [splices][topic splicing]
  proposées par les pairs et les tentatives [RBF][topic rbf] sur des ouvertures [dual-funded][topic dual funding] n'avaient pas de borne
  supérieure de taux de frais, tandis que les ouvertures dual-funded elles-mêmes n'avaient ni vérification basse ni haute. Un taux de frais
  stocké suffisamment grand pour provoquer un dépassement dans le calcul du prochain taux de frais RBF, ou un zéro stocké, déclenchait une
  assertion dans `listpeerchannels`. Comme les plugins l'appellent au démarrage, le nœud plantait à chaque redémarrage. La PR ajoute un
  plafond de 4 000 sat/vB sur les propositions des pairs et les [estimations de frais][topic fee estimation] du backend, même avec
  `--ignore-fee-limits` activé. Elle plafonne également les taux de frais que CLN propose pour ses propres ouvertures, splices, mises à jour
  de commitment et RBF à 400 sat/vB, et répare lors de la mise à niveau les taux de frais stockés hors plage.

- [Core Lightning #9508][] corrige plusieurs problèmes liés aux [splices][topic splicing] et à l'ouverture de canaux. Auparavant, avant que
  CLN reçoive le `splice_locked` du pair, il pouvait manquer la diffusion par un pair d'une transaction de commitment pour un splice en
  attente. Désormais, CLN surveille la sortie de financement de chaque splice en attente et reconnaît la dépense. CLN force également
  correctement la fermeture du canal si un pair envoie `tx_abort` pour un splice après que CLN a envoyé ses signatures. Auparavant, la
  vérification ne reconnaissait pas un splice qui avait déjà été signé, et l'indicateur montrant qu'une signature avait été envoyée n'était
  pas conservé entre les redémarrages. Cela amenait CLN à accepter `tx_abort` sans forcer la fermeture. La PR rejette également une nouvelle
  ouverture [dual-funded][topic dual funding] provenant d'un pair qui a déjà trois négociations d'ouverture de canal en cours, y compris des
  ouvertures single-funded. Les pairs qui dépassent cette limite ou gardent un canal quiescent pendant plus de dix minutes sont déconnectés.

- [Core Lightning #9509][] corrige plusieurs problèmes liés à la résolution onchain des canaux. Auparavant, CLN pouvait traiter une
  fermeture forcée comme une fermeture coopérative si toutes ses sorties payaient vers des scripts de fermeture connus. Un pair qui ne
  s'était pas engagé sur un script upfront shutdown à l'ouverture du canal pouvait envoyer un message `shutdown` nommant le script de sortie
  d'un ancien commitment révoqué comme script de fermeture, abandonner la fermeture coopérative, puis diffuser ce commitment sans être
  pénalisé. Désormais, CLN identifie les transactions de commitment par leur encodage de locktime et de séquence avant de vérifier les
  sorties. La PR redémarre également `onchaind` lorsqu'un descendant surveillé d'une transaction de commitment toujours confirmée est
  réorganisé hors de la chaîne, au lieu de laisser le canal non surveillé jusqu'au redémarrage du nœud. CLN exécute désormais le
  [HTLC][topic htlc] entrant non résolu correspondant lorsque son préimage est appris onchain, même si l'échec du HTLC sortant était en
  attente. Des corrections supplémentaires empêchent des crashs impliquant des sorties de fermeture réorganisées et des paiements onchain
  vers les adresses de repli de factures sans montant.

- [Core Lightning #9510][] et [#9511][core lightning #9511] renforcent l'analyse des entrées et la journalisation. La première corrige un
  dépassement de tampon qui pouvait faire planter `connectd` lors d'une connexion via un proxy à un nœud ayant annoncé un nom d'hôte DNS
  très long. CLN rejette désormais au démarrage les adresses `dns:` dans sa propre configuration qui ne sont pas des noms d'hôte valides, et
  ignore les adresses DNS invalides dans les annonces de nœuds reçues. Elle limite également l'imbrication JSON à 256 niveaux et les corps
  de requêtes REST à 2 MiB, et corrige un bug d'analyse TLV [BOLT12][topic offers] qui permettait à un message mal formé de faire planter
  CLN. La seconde PR corrige un dépassement de pile qui permettait à une requête REST non authentifiée avec un très grand paramètre de faire
  planter le nœud. Elle supprime également les journaux d'E/S de `getlog`, car le trafic RPC brut et celui des plugins peuvent contenir des
  runes (jetons d'authentification qui accordent un accès RPC restreint) et d'autres secrets.

- [Core Lightning #9513][] corrige la validation du montant lorsque `xpay` récupère une facture pour une [offre BOLT12][topic offers].
  Auparavant, il utilisait le montant de la facture récupérée sans le vérifier par rapport au montant autorisé, permettant au destinataire
  de demander un paiement plus élevé. Désormais, la facture doit soit correspondre au montant demandé, soit, si aucun montant n'a été
  fourni, ne pas dépasser le montant de l'offre. La PR empêche également qu'un [message onion][topic onion messages] contenant un chemin de
  réponse sans saut, que n'importe quel nœud pouvait envoyer, n'arrête le nœud. CLN traite désormais un tel chemin comme absent et
  journalise les autres chemins de réponse impossibles à analyser au lieu d'arrêter le plugin `offers`.

- [LND #11198][] corrige un bug où une facture entière était annulée en raison d'un échec de reconstruction de préimage de paiement
  [AMP][topic amp]. Une facture AMP réutilisable peut accepter plusieurs ensembles de paiements indépendants, chacun composé de plusieurs
  [HTLCs][topic htlc]. Auparavant, un ensemble invalide pouvait annuler la facture et interférer avec d'autres ensembles acceptés, même si
  l'échec de reconstruction n'affectait que cet ensemble. Désormais, LND échoue le HTLC arrivant et annule les HTLCs précédemment acceptés
  appartenant à l'ensemble en échec. La facture reste payable, et d'autres ensembles acceptés peuvent toujours se terminer et être réglés.

- [LND #11146][] poursuit son implémentation des [offres BOLT12][topic offers] en ajoutant des encodeurs et décodeurs de chaînes validés
  pour les offres, les demandes de facture et les factures. Ceux-ci combinent l'analyse avec les vérifications applicables du réseau, des
  fonctionnalités, de l'expiration et de la signature, en s'appuyant sur la prise en charge des signatures décrite dans le [Bulletin
  #422][news422 bolt12]. La nouvelle fonction `ValidateInvoiceForPayment` vérifie également une facture par rapport à la demande d'origine
  et au nœud que le payeur s'attendait à voir la signer. Une signature valide seule est insuffisante : un nœud le long d'un [chemin
  aveuglé][topic rv routing] pourrait sinon renvoyer une facture signée avec sa propre clé.

- [LND #11132][] rétablit la conformité à [BOLT1][] en répondant à chaque `ping` valide admis par sa politique anti-inondation. Auparavant,
  un limiteur séparé de `pong` pouvait silencieusement supprimer des réponses requises (voir le [Bulletin #421][news421 ping]). LND utilise
  désormais un seul seau par pair contenant 200 jetons, réapprovisionné à un rythme de 10 par seconde. Les réponses demandées plus
  volumineuses coûtent davantage de jetons ; une réponse de taille maximale coûte dix jetons, ce qui préserve la limite de bande passante
  précédente. L'épuisement du budget déconnecte le pair.

{% include snippets/recap-ad.md when="2026-09-29 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="34566,1951,2224,9507,9508,9509,9510,9511,9513,11198,11146,11132" %}

[news418 bip110]: /fr/newsletters/2026/08/14/#bips-2225
[pqln del]: https://delvingbitcoin.org/t/pqln-post-quantum-security-for-the-bitcoin-lightning-networks-off-chain-surfaces/2893
[pqln paper]: https://arxiv.org/abs/2609.13781
[pqln repo]: https://github.com/ahmet-kurt/pq-rust-lightning
[news408 pq ln]: /fr/newsletters/2026/06/05/#discussion-sur-lightning-post-quantique
[Bitcoin Core 32.0rc2]: https://bitcoincore.org/bin/bitcoin-core-32.0/test.rc2/
[bcc32 testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/32.0-Release-Candidate-Testing-Guide
[Core Lightning 26.06.8]: https://github.com/ElementsProject/lightning/releases/tag/v26.06.8
[LDK v0.3-rc2]: https://github.com/lightningdevkit/rust-lightning/tree/v0.3-rc2
[ldk 0.3 notes]: https://github.com/lightningdevkit/rust-lightning/blob/v0.3-rc2/CHANGELOG.md
[news412 netmagic]: /fr/newsletters/2026/07/03/#bitcoin-core-35610
[news351 backup]: /fr/newsletters/2025/04/25/#sauvegarde-standardisee-pour-les-descripteurs-de-portefeuille
[news315 dark skippy]: /fr/newsletters/2024/08/09/#attaque-d-exfiltration-de-seed-plus-rapide
[news422 bolt12]: /fr/newsletters/2026/09/11/#lnd-11061
[news421 ping]: /fr/newsletters/2026/09/04/#lnd-11090
