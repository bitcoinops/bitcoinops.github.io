---
title: 'Bulletin Hebdomadaire Bitcoin Optech #420'
permalink: /fr/newsletters/2026/08/28/
name: 2026-08-28-newsletter-fr
slug: 2026-08-28-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine transmet un préavis d'une prochaine version de sécurité de Core Lightning, résume une discussion sur la
protection contre la relecture par adhésion volontaire pour de potentiels futurs forks, note que le projet Hardware Wallet Interface (HWI)
passera en mode maintenance, et décrit une demande de commentaires sur l'utilisation de filtres par plage de blocs. Sont également incluses
nos rubriques habituelles annonçant les nouvelles versions et versions candidates et décrivant les changements notables dans des logiciels
populaires d'infrastructure Bitcoin.

## Éléments d'action

- **Préparez-vous à une prochaine version de sécurité de Core Lightning :** Christian Decker a [décrit][cln v26.06.7] une prochaine version
  de sécurité corrective CLN v26.06.7, en notant qu'aucune vulnérabilité n'est connue pour être activement exploitée. Le projet prévoit une
  publication sous embargo dans environ 24 heures, en publiant les binaires mais en retenant le code source pendant 14 jours afin de
  ralentir tout attaquant cherchant à rétroconcevoir les correctifs. Une fois le code source rendu disponible, le système de [build
  reproductible][topic reproducible builds] de CLN permettra aux utilisateurs de vérifier que les binaires correspondent au code source. Les
  opérateurs qui préfèrent attendre que le code source soit disponible pour effectuer la mise à jour devraient redémarrer avec l'option
  `--offline` (qui empêche le nœud d'établir ou d'accepter des connexions de pairs tout en conservant l'application onchain contre
  d'éventuels pairs tricheurs).

## Nouvelles

- **Discussion sur une protection universelle contre la relecture par adhésion volontaire** : Moonsettler a [publié][replay del] sur Delving
  Bitcoin pour discuter de la possibilité d'introduire un mécanisme de protection contre la relecture par adhésion volontaire en cas de
  futurs forks. L'idée faisait suite à des événements récents dans lesquels une chaîne minoritaire a fait l'objet d'attaques par relecture,
  un type d'attaque dans lequel une transaction signée valide sur une branche d'un fork est rediffusée sur l'autre, dépensant
  involontairement les pièces équivalentes sur les deux réseaux. L'auteur propose d'utiliser l'[annexe taproot][topic annex] en y engageant
  une charge utile de 34 octets qui inclut le hash du bloc précédent (c.-à-d. `<0xFAF0><32-byte-prior-block-hash>`).

  La discussion s'est poursuivie avec Anthony Towns proposant d'utiliser à la place la hauteur du bloc et un suffixe du hash du bloc, afin
  de réduire la quantité de données à 6 octets. Moonsettler a accepté l'approche et a ajouté qu'il serait utile que les nœuds annotent les
  UTXO avec l'engagement de bloc afin de fournir cette information aux utilisateurs. L'auteur a également proposé une limite sur la
  profondeur des nouveaux engagements, idéalement la hauteur `assumevalid`, et que les nœuds conservent la trace de l'engagement jusqu'à
  `100` blocs. De plus, Towns a proposé d'ajouter un mécanisme similaire à une contrainte de maturité en définissant un `nLocktime`
  explicite pour empêcher qu'une transaction soit minée avant un certain nombre de blocs afin de tenir compte des réorganisations de blocs.

- **Le dépôt HWI passera en mode maintenance** : Ava Chow (achow101) a [annoncé][hwi future] que le projet [Hardware Wallet Interface
  (HWI)][topic hwi] réduira son activité à de la maintenance uniquement et sera finalement archivé. HWI, qui permet à [Bitcoin Core][bitcoin
  core repo] et à d'autres logiciels de communiquer avec des dispositifs matériels de signature, a été développé presque entièrement par une
  seule personne et a reçu peu de nouveau développement depuis plusieurs années. Chow a déclaré qu'il avait atteint l'essentiel de son
  objectif initial consistant à apporter le support des portefeuilles matériels à Bitcoin Core, mais que sa base de code Python l'avait
  freiné dans cet objectif, puisqu'elle ne peut pas être [buildée de manière reproductible][topic reproducible builds] et regroupée avec
  Bitcoin Core.

  Avant d'entrer en mode maintenance, le projet terminera son support de [MuSig2][topic musig] actuellement en cours et publiera ce qui
  devrait être sa dernière version. Il cessera d'accepter de nouvelles fonctionnalités et le support d'appareils supplémentaires, à
  l'exception de MuSig2. Chow a cité [BHWI][bhwi], une implémentation Rust en cours de développement de Wizardsardine, comme remplaçant
  potentiel.

- **Demande de commentaires sur l'utilisation de filtres par plage de blocs** : Optout a [publié][rfc del] sur Delving Bitcoin une demande
  de commentaires (RFC) sur une proposition visant à utiliser des filtres par plage de blocs pour réduire la taille totale de téléchargement
  lors de l'utilisation de [filtres de blocs compacts][topic compact block filters]. Au lieu de télécharger tous les filtres de blocs
  individuels, des filtres pour des plages de blocs pourraient être créés. Si un script est trouvé à l'intérieur de l'une de ces plages, les
  filtres de blocs individuels sont téléchargés et le processus fonctionne comme décrit dans [BIP157][]. Bien que les filtres de plage et de
  blocs soient tous deux téléchargés pour les plages correspondantes, des économies de taille sont obtenues en évitant de télécharger tous
  les filtres de blocs dans les autres plages.

  Les résultats préliminaires semblent prometteurs. L'auteur a exécuté des simulations en utilisant différentes tailles de plage sur des
  données simulées d'environ 30k blocs. Deux ensembles différents de scripts ont été utilisés, l'un avec un très faible nombre de
  transactions (4-6 transactions) et l'autre avec un nombre plus élevé (20-30 transactions). La taille totale des filtres par plage de blocs
  diminue à mesure que la plage augmente. Cependant, la plupart des économies sont annulées lorsqu'on augmente trop la plage. Selon
  l'auteur, le meilleur compromis semble être trouvé avec une plage de 256 blocs, ce qui a réduit la taille totale de téléchargement
  d'environ 70–80 % pour les ensembles de scripts testés.

## Mises à jour et versions candidates

_Nouvelles versions et versions candidates pour des projets d'infrastructure Bitcoin populaires. Veuillez envisager de mettre à niveau vers
les nouvelles versions ou d'aider à tester les versions candidates._

- [BTCPay Server 2.4.3][] est une version de sécurité de ce processeur de paiement auto-hébergé. Les utilisateurs sont encouragés à
  effectuer la mise à niveau, surtout si leurs serveurs sont partagés entre plusieurs utilisateurs.

- [Eclair 0.14.2][] est une version de sécurité pour cette implémentation de nœud LN. Elle corrige des bogues d'échec de paiement et de
  gestion de canaux (voir le [Bulletin
  #418][news418 eclair fixes]), des vérifications manquantes de réserve de canal (voir le [Bulletin
  #419][news419 eclair reserves]), et des problèmes de financement
  [à la volée][topic jit channels] (voir le [Bulletin #419][news419 eclair funding]). Elle limite également les ressources consommées par les
  [requêtes de gossip][topic channel announcements] (voir le [Bulletin #419][news419 eclair gossip]) et les connexions entrantes en attente, et
  inclut des modifications de configuration des [messages onion][topic onion messages] et de Tor. La mise à niveau est fortement recommandée
  car des nœuds malveillants pourraient exploiter certains des bogues corrigés. Les opérateurs devraient exécuter `bitcoind` sur la même
  machine qu'Eclair ou se connecter via un tunnel chiffré et authentifié, et consulter les [notes de version][eclair 0.14.2 notes] pour les
  changements de configuration.

## Changements notables dans le code et la documentation

_Changements récents notables dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning repo], [Eclair][eclair repo],
[LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet Interface (HWI)][hwi repo], [Rust Bitcoin][rust
bitcoin repo], [BTCPay Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement Proposals (BIPs)][bips repo], [Lightning
BOLTs][bolts repo], [Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition repo], et [BINANAs][binana repo]._

- [Bitcoin Core #34075][] incorpore un [estimateur de taux de frais][topic fee estimation] basé sur le mempool à côté de l'estimateur
  existant de politique de bloc basé sur les confirmations. Le nouvel estimateur utilise les [taux de frais par chunk][topic cluster
  mempool] au milieu et au dernier quartile du bloc suivant pour des estimations conservatrices et économiques, respectivement. S'il y a
  trop peu de transactions en attente de confirmation, il revient à la plus élevée entre le taux de frais minimal de relais et le taux de
  frais minimal du mempool. Par défaut, `estimatesmartfee` renvoie désormais la plus basse des estimations du mempool et de politique de
  bloc, de sorte que les conditions du mempool peuvent abaisser les estimations de taux de frais mais pas les augmenter. La nouvelle option
  `fee_rate_estimator` peut être utilisée pour obtenir des estimations basées sur une seule des approches.

- [Bitcoin Core #35730][] ajoute une option de configuration `-rpcmaxconnections` (par défaut 16), qui limite le nombre de clients pouvant
  se connecter simultanément à son serveur HTTP (voir le [Bulletin #411][news411 http]). Une fois la limite atteinte, les connexions
  supplémentaires restent dans la file d'attente des sockets du système d'exploitation sans consommer de mémoire applicative jusqu'à ce
  qu'un emplacement devienne disponible. Bitcoin Core peut désormais limiter et suivre l'utilisation des descripteurs de fichiers de ces
  connexions, résolvant un problème de longue date dans lequel une utilisation intensive de RPC pouvait épuiser les descripteurs de fichiers
  disponibles, provoquant l'échec d'opérations non liées. Ce changement améliore également la gestion des connexions en acceptant toutes les
  connexions en file d'attente jusqu'à la limite lors de chaque itération de la boucle d'E/S, au lieu de n'accepter qu'une seule connexion
  par itération.

- [Bitcoin Core #35580][] corrige un bogue de construction de modèle de bloc qui comparait le poids ajusté selon les sigops d'un chunk de
  transaction (voir le [Bulletin
  #416][news416 sigops]), plutôt que son poids réel [BIP141][], au
  poids maximal du bloc. Le poids ajusté selon les sigops classe les chunks selon leur taux de frais effectif, tandis que la validité du
  bloc contraint séparément le poids réel et le coût en sigops. Par conséquent, le comportement précédent pouvait exclure à tort un chunk
  dense en sigops avec un taux de frais élevé même lorsqu'il satisfaisait les deux limites, réduisant ainsi les revenus de minage.

- [Bitcoin Core #35665][], [#36025][bitcoin core #36025], et [#35516][bitcoin core #35516] corrigent plusieurs problèmes lors de la
  combinaison ou de la jonction de [PSBT][topic psbt]. Le premier correctif traite un problème lors de la fusion de deux enregistrements
  xpub globaux. Auparavant, Bitcoin Core regroupait les enregistrements par origine de clé (empreinte et chemin de dérivation), même si la
  sérialisation PSBT les identifie par xpub. Il en résultait que le même xpub avec des origines conflictuelles était sérialisé sous forme de
  clés dupliquées, créant un PSBT invalide que le RPC `decodepsbt` rejette. La deuxième PR corrige le décalage analogue pour les
  enregistrements [tapscript][topic tapscript], qui sont regroupés en interne par script en feuille mais sérialisés par bloc de contrôle.
  Auparavant, la fusion pouvait créer des clés dupliquées lorsqu'un bloc de contrôle était associé à différents scripts, ou elle pouvait
  écarter des blocs de contrôle valides pour le même script. La troisième PR résout le problème du RPC `joinpsbts` qui supprimait les
  enregistrements xpub globaux et les métadonnées en mélangeant le PSBT fusionné sur place plutôt qu'en construisant un PSBT mélangé
  distinct qui omet certaines métadonnées globales.

- [Bitcoin Core #35933][] et [#34697][bitcoin core #34697] corrigent plusieurs problèmes de traitement [PSBT][topic psbt] de [MuSig2][topic
  musig] et de [descripteurs][topic descriptors]. La première PR empêche des métadonnées de dérivation MuSig2 invalides ou incohérentes de
  provoquer l'abandon des RPC `analyzepsbt`, `finalizepsbt`, et `descriptorprocesspsbt`. La dérivation publique renforcée échoue désormais
  normalement tandis qu'une clé agrégée non correspondante est ignorée afin qu'une autre clé correspondante puisse être essayée. La deuxième
  PR améliore la détection des clés dupliquées dans les descripteurs en utilisant les informations disponibles sur les clés privées pour
  comparer les expressions de clés avec dérivation renforcée lors de l'analyse des descripteurs. Auparavant, différentes expressions
  pouvaient toutes deux échouer à être résolues et être faussement traitées comme des doublons, ce qui rejetait des descripteurs `musig()`
  valides qui réutilisent les mêmes participants avec des chemins de dérivation différents. Elle empêche également que l'origine de clé d'un
  participant MuSig2 réutilisé soit préfixée deux fois aux métadonnées de dérivation [taproot][topic taproot] stockées dans un PSBT.

- [Core Lightning #9374][] corrige une erreur d'état de canal qui pouvait survenir lorsqu'une tentative antérieure de [RBF][topic rbf] pour
  un canal [financé par les deux parties][topic dual funding] se confirmait à la place de la tentative la plus récente (voir le [Bulletin
  #418][news418 eclair] pour un bogue similaire sur Eclair). Auparavant, si le pair
  se reconnectait pendant que Core Lightning était encore en train de rattraper la blockchain, il pouvait supposer que la dernière tentative
  de RBF était celle qui s'était confirmée et verrouiller le canal sur une transaction de financement non confirmée. Désormais, Core
  Lightning enregistre la tentative de financement qui s'est effectivement confirmée dès que son bloc est traité et utilise cette tentative
  lors du rétablissement du canal.

- [Eclair #3342][] implémente le bit de fonctionnalité `option_onion_messages_only_channels` spécifié dans [BOLTs #1343][] (voir le [Bulletin
  #416][news416 onion]). Lorsqu'il est configuré pour relayer des [messages onion][topic onion messages] uniquement pour des pairs avec des
  canaux, Eclair annonce désormais ce bit de fonctionnalité. Lorsqu'il relaie pour tous les pairs, Eclair annonce le bit de fonctionnalité
  `option_onion_messages`.

- [Eclair #3321][] implémente le support du champ optionnel `fulfillment_payload` ajouté au message `update_fulfill_htlc` tel que spécifié
  par [BOLTs
  #1344][], étendant les [échecs attribuables][topic attributable failures] aux
  paiements réussis (voir le [Bulletin #416][news416 fulfillment]). Eclair peut relayer les charges utiles d'acquittement et les authentifier
  comme faisant partie des données d'attribution, et peut les déchiffrer lorsqu'il est le payeur, mais n'en génère pas encore lorsqu'il est
  le destinataire du paiement. La PR signale une interopérabilité avec LDK, qui avait précédemment ajouté des données d'attribution au
  chemin des paiements réussis (voir le [Bulletin #364][news364 ldk attribution]).

- [LND #11008][] corrige un problème d'interblocage dans le flux d'ouverture de canal [PSBT][topic psbt] de LND. Auparavant, si la
  vérification du financement PSBT et le nettoyage d'une réservation de canal annulée s'exécutaient en même temps, chaque opération pouvait
  attendre des ressources détenues par l'autre. Cela pouvait bloquer l'unique gestionnaire de réservations de LND, empêchant le nœud
  d'ouvrir ou d'accepter des canaux et laissant les canaux nouvellement financés bloqués jusqu'à un redémarrage. Le correctif modifie
  l'ordre dans lequel l'état partagé est consulté, empêchant les deux opérations de se bloquer mutuellement indéfiniment.

- [HWI #841][] étend la commande `displayaddress` pour afficher sur un appareil matériel une adresse pour une politique de
  [descripteur][topic descriptors] de portefeuille [BIP388][] enregistrée, sélectionnée par index d'adresse et branche de réception ou de
  monnaie. La commande accepte les informations d'enregistrement renvoyées par la commande `registerdescriptor` et ajoute le support des
  appareils BitBox02, Coldcard, Jade, et Ledger, en s'appuyant sur le support d'enregistrement de descripteurs décrit dans le [Bulletin
  #419][news419 hwi].

- [HWI #849][] met à jour le support de Coldcard pour afficher des adresses [taproot][topic taproot] à signature unique sur les appareils
  Coldcard Edge. Il préserve également le format PSBTv2 lors de la signature avec un firmware Coldcard qui le prend en charge, au lieu de
  toujours convertir le PSBT en version 0. La PR ajoute une couverture du simulateur Coldcard Edge, rétablit les tests de signature de
  transaction à signature unique, et met à jour le firmware Coldcard testé vers la version 5.6.0.

- [Rust Bitcoin #6755][] corrige la vérification des signatures segwit v0 pour les transactions utilisant des valeurs de hash de signature
  ECDSA (sighash) non standard mais valides du point de vue du consensus. Auparavant, `EcdsaSighashType` associait ces valeurs à des types
  sighash standard au comportement équivalent `ALL`, `NONE`, `SINGLE`, et `ANYONECANPAY`, perdant la valeur d'origine. Comme la valeur
  exacte est également incluse dans le hash de signature segwit v0, cela pouvait conduire Rust Bitcoin à calculer un mauvais sighash et à
  échouer à vérifier les signatures de transactions valides du point de vue du consensus et déjà confirmées. La nouvelle représentation
  préserve la valeur d'origine, tandis que les appelants qui ont besoin de types sighash standard peuvent continuer à utiliser
  `from_standard` (voir [Bulletin
  #138][news138 sighash]).

{% include snippets/recap-ad.md when="2026-09-01 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="34075,35730,35580,35665,36025,35516,35933,34697,9374,3342,1343,3321,1344,11008,841,849,6755" %}

[cln v26.06.7]: https://x.com/Snyke/status/2092989040098181170
[replay del]: https://delvingbitcoin.org/t/universal-opt-in-replay-protection/2792
[hwi future]: https://github.com/bitcoin-core/HWI/issues/850
[bhwi]: https://github.com/wizardsardine/bhwi
[BTCPay Server 2.4.3]: https://github.com/btcpayserver/btcpayserver/releases/tag/v2.4.3
[Eclair 0.14.2]: https://github.com/ACINQ/eclair/releases/tag/v0.14.2
[eclair 0.14.2 notes]: https://github.com/ACINQ/eclair/blob/v0.14.2/docs/release-notes/eclair-v0.14.2.md
[news295 fee]: /fr/newsletters/2024/03/27/#estimation-du-taux-de-frais-basee-sur-le-mempool
[news349 fee]: /fr/newsletters/2025/04/11/#bitcoin-core-pr-review-club
[news411 http]: /fr/newsletters/2026/06/26/#bitcoin-core-35182
[news416 sigops]: /fr/newsletters/2026/07/31/#bitcoin-core-32800
[news418 eclair]: /fr/newsletters/2026/08/14/#eclair-3346
[news416 onion]: /fr/newsletters/2026/07/31/#bolts-1343
[news416 fulfillment]: /fr/newsletters/2026/07/31/#bolts-1344
[news419 hwi]: /fr/newsletters/2026/08/21/#hwi-842
[news364 ldk attribution]: /fr/newsletters/2025/07/25/#ldk-3801
[news138 sighash]: /en/newsletters/2021/03/03/#rust-bitcoin-573
[news418 eclair fixes]: /fr/newsletters/2026/08/14/#eclair-3346
[news419 eclair reserves]: /fr/newsletters/2026/08/21/#eclair-3352
[news419 eclair funding]: /fr/newsletters/2026/08/21/#eclair-3351
[news419 eclair gossip]: /fr/newsletters/2026/08/21/#eclair-3345
[rfc del]: https://delvingbitcoin.org/t/rfc-block-range-filters-a-k-a-hierarchical-filters/2735
