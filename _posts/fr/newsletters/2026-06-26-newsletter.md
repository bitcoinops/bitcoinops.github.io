---
title: 'Bulletin Hebdomadaire Bitcoin Optech #411'
permalink: /fr/newsletters/2026/06/26/
name: 2026-06-26-newsletter-fr
slug: 2026-06-26-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine décrit la divulgation responsable d'une vulnérabilité de déni de service qui affectait les anciennes versions
de LND. Sont également inclus nos sections régulières avec des questions et réponses sélectionnées de Bitcoin Stack Exchange, des annonces
de nouvelles versions et versions candidates, et des descriptions de changements notables dans des logiciels d'infrastructure Bitcoin
populaires.

## Nouvelles

- **Divulgation d'un DoS de gossip à horodatage nul dans LND :** Nishant Bansal a [publié][lnd gossip dos delving] sur Delving Bitcoin la
  divulgation d'une vulnérabilité de déni de service qu'il a découverte grâce au fuzzing de machine à états du traitement du gossip de LND.
  Les versions de LND antérieures à v0.20.1-beta pouvaient être plantées par un message de gossip `channel_update` ou `node_announcement`
  portant un horodatage de zéro. Bien que [BOLT7][] exige que les horodatages `channel_update` soient supérieurs à zéro, il ne précise pas
  comment les nœuds doivent gérer les messages qui violent cette règle, et le traitement de cette valeur par LND conduisait à un plantage.

  Lorsqu'un nœud vulnérable essayait de traiter l'un de ces messages à horodatage nul, une erreur interne de tenue des comptes laissait une
  structure de données dans un état invalide, provoquant une panique à l'exécution qui arrêtait le nœud. Un attaquant pouvait déclencher le
  bug en diffusant des annonces pour soit un véritable canal public, soit un canal synthétique créé en finançant une sortie 2-sur-2
  contrôlée par l'attaquant, cette dernière option étant moins coûteuse à répéter sans exécuter de nœud Lightning.

  La vulnérabilité a été [divulguée de manière responsable][topic responsible disclosures], confirmée indépendamment par Matt Morehouse, et
  corrigée dans [LND 0.20.1-beta][news393 lnd 0201] en rejetant les messages de gossip avec un horodatage nul au moment de l'analyse, avant
  qu'ils n'atteignent le code vulnérable.

## Questions et réponses sélectionnées de Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] est l'un des premiers endroits où les contributeurs d'Optech cherchent des réponses à leurs
questions---ou quand nous avons quelques moments libres pour aider les utilisateurs curieux ou confus. Dans cette rubrique mensuelle, nous
mettons en lumière certaines des questions et réponses les mieux votées postées depuis notre dernière mise à jour.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Est-ce un bug que `OP_IF` fasse partie des opcodes tapscript ?]({{bse}}130785) Antoine Poinsot explique que bien que toute politique de
  dépense puisse être exprimée comme une feuille [taproot][topic taproot] par chemin, ce n'est pas toujours l'encodage le plus efficace.
  Selon le nombre de chemins et la fréquence d'utilisation de chacun, un `OP_IF` à l'intérieur d'une seule feuille [tapscript][topic
  tapscript] peut produire des dépenses plus petites que de répartir les chemins entre les feuilles ou de passer à P2WSH.

- [Pourquoi interdire `OP_IF` dans tapscript serait-il un problème ?]({{bse}}130815) Murch note que parce qu'une sortie taproot engage ses
  scripts de feuille sous forme de hachage, il est impossible de savoir quels UTXOs existants dépendent de `OP_IF`, comme les portefeuilles
  multisig dégradables basés sur [miniscript][topic miniscript]. Les utilisateurs ayant de telles configurations pourraient verrouiller des
  fonds reçus après l'activation sans le savoir si ces chemins de dépense n'étaient plus valides.

- [Un softfork réussit-il toujours ?]({{bse}}130775) Murch décrit un scénario où une [bifurcation douce][topic soft fork activation]
  utilisant une signalisation obligatoire n'est prise en charge que par une minorité du hashrate, montrant que la chaîne de signalisation
  prend du retard en preuve de travail et stagne au lieu de forcer le reste du réseau à adopter les nouvelles règles.

- [Comment configurer Bitcoin Core pour miner un bloc valide après l'activation de BIP110 en août 2026 ?]({{bse}}130770) Antoine Poinsot
  note que Bitcoin Core n'applique pas les règles de BIP110 et ne dispose d'aucune fonctionnalité pour construire un modèle de bloc qui
  exclut les transactions que BIP110 traite comme invalides. Un opérateur de nœud souhaitant miner des blocs conformes à BIP110 devrait
  sélectionner les transactions avec un logiciel externe de construction de modèles de blocs, ou pourrait miner des blocs vides.

- [Les blocs BIP110 sur une branche avec une difficulté plus faible sont-ils valides ?]({{bse}}130827) Pieter Wuille distingue le fait
  qu'une chaîne soit valide du fait qu'elle soit active. L'ajustement de difficulté de chaque branche ne dépend que de ses propres blocs,
  donc une branche BIP110 potentiellement plus lente est toujours valide pour les nœuds suivant les règles actuelles, mais ils n'en feront
  jamais leur chaîne active à moins qu'elle n'accumule plus de preuve totale de travail que la chaîne principale.

- [Quelle est l'histoire des réseaux de test Bitcoin ?]({{bse}}130806) Murch et Antoine Poinsot retracent l'histoire de [testnet][topic
  testnet] depuis testnet1 jusqu'au testnet5 proposé, y compris les réinitialisations répétées après que chaque réseau a été monétisé et
  l'exception de difficulté de 20 minutes qui a conduit aux tempêtes de blocs récurrentes de testnet3 (voir le [Bulletin #311][news311 block
  storm]).

- [Pourquoi `-datacarriersize` a-t-il été redéfini en 2022, et pourquoi la proposition de 2023 visant à l'étendre n'a-t-elle pas été
  fusionnée ?]({{bse}}128027) Revenant sur une question à laquelle il a d'abord été répondu l'année dernière, Murch ajoute une réponse
  complémentaire documentant que les options `datacarrier` et `datacarriersize` n'ont fait référence qu'aux sorties `OP_RETURN` depuis leur
  introduction dans Bitcoin Core 0.10.0, en citant le code d'origine et les notes de version.

- [Les chaînes de 26 transactions non confirmées sont-elles interdites par le portefeuille dans Bitcoin Core 31.0 ?]({{bse}}130777) Pol
  Espinasa clarifie que le mempool lui-même autorise des chaînes plus longues sous les nouvelles limites de [cluster mempool][topic cluster
  mempool], mais le portefeuille Bitcoin Core applique toujours une limite de 25 transactions pendant la sélection des pièces, donc des
  chaînes plus longues doivent être construites sans le portefeuille.

- [Y a-t-il des changements dans Bitcoin Core 29.0 qui affectent l'utilisation de la mémoire ?]({{bse}}127887) Antoine Poinsot clarifie que
  l'augmentation apparente est un artefact de rapport plutôt qu'une utilisation plus élevée de la mémoire du processus. Bitcoin Core 29.0
  permet à sa base de données chainstate de mettre davantage de données en cache lorsque de la mémoire libre est disponible, et ce cache est
  libéré lorsque d'autres processus ont besoin de la mémoire.

- [Quel est le calendrier de publication de Bitcoin Core ?]({{bse}}130817) Murch décrit que Bitcoin Core publie des versions majeures selon
  un calendrier fixe en avril et en octobre, remplaçant la pratique précédente consistant à viser six mois après la version précédente, où
  les échéances pouvaient glisser. Les versions mineures continuent de livrer des corrections de bugs selon les besoins.

## Mises à jour et versions candidates

_Nouvelles versions et versions candidates pour des projets d'infrastructure Bitcoin populaires. Veuillez envisager de mettre à niveau vers
les nouvelles versions ou d'aider à tester les versions candidates._

- [LDK v0.1.10][] est une version de maintenance de cette bibliothèque pour construire des portefeuilles et applications compatibles LN.
  Elle corrige plusieurs vulnérabilités de déni de service et un problème d'assainissement, ainsi que des bugs affectant la persistance
  asynchrone du moniteur de canal, la synchronisation Electrum, la validation des [offres BOLT12][topic offers], la gestion des messages
  onion, les [HTLCs][topic htlc] [keysend][topic spontaneous payments] en [MPP][topic multipath payments], et l'envoi de paiements basé sur
  les routes.

- [LDK v0.2.3][] est une version de maintenance de cette bibliothèque pour construire des portefeuilles et applications compatibles LN. Elle
  corrige plusieurs problèmes de sécurité, y compris des vulnérabilités de déni de service, des erreurs de calcul de réserve pour les canaux
  anchor, et un problème d'assainissement, ainsi que des bugs affectant la persistance asynchrone du moniteur de canal, la gestion LSPS, les
  [canaux zero-fee-commitment][topic v3 commitments], les offres BOLT12, la messagerie onion, et l'utilisation mémoire de rapid gossip sync.

- [BTCPay Server 2.4.0][] est une version de ce processeur de paiement auto-hébergé. Elle ajoute la recherche globale, l'authentification
  par passkey, la configuration guidée de portefeuille multisig, des permissions de portefeuille plus granulaires, des améliorations des
  abonnements et du point de vente, la recherche et le filtrage des transactions de portefeuille, des améliorations de l'écosystème des
  plugins, et une prise en charge Lightning mise à jour, tout en supprimant plusieurs backends Lightning obsolètes.

## Changements notables dans le code et la documentation

_Changements notables récents dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning repo], [Eclair][eclair repo],
[LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet Interface (HWI)][hwi repo], [Rust Bitcoin][rust
bitcoin repo], [BTCPay Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement Proposals (BIPs)][bips repo], [Lightning
BOLTs][bolts repo], [Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition repo], et [BINANAs][binana repo]._

- [Bitcoin Core #35070][] empêche l'ajout d'entrées en double dans `m_blocks_unlinked`, une structure interne à la validation qui suit les
  blocs téléchargés qui ne peuvent pas encore être connectés en raison de données de blocs antérieurs manquantes. Auparavant, un nœud élagué
  confronté à une réorganisation profonde pouvait accidentellement ajouter des entrées en double à cette structure, amenant la fonction
  `ReceivedBlockTransactions()` à reconsidérer le même bloc plus d'une fois après réception des données manquantes et à le réajouter à
  `setBlockIndexCandidates` après avoir modifié son `nSequenceId`. Cela pouvait corrompre l'ordre en mémoire de l'ensemble des pointes de
  chaînes candidates, conduisant potentiellement à un comportement indéfini. La PR fait passer les insertions par un nouvel assistant
  `AddUnlinkedBlock()` qui déduplique les entrées et renforce `CheckBlockIndex()` afin de garantir qu'aucun doublon n'est présent.

- [Bitcoin Core #35182][], [#34411][bitcoin core #34411] remplacent le serveur HTTP basé sur libevent, utilisé pour RPC et REST, par une
  nouvelle implémentation HTTP et de gestion des sockets maintenue dans Bitcoin Core. Le nouveau serveur exécute son propre thread d'E/S,
  gère directement les sockets, et distribue les requêtes acceptées au pool existant de workers HTTP. La PR de suivi supprime le build
  libevent restant, la CI, les dépendances et l'infrastructure CMake. Ces changements poursuivent les efforts du projet pour réduire les
  dépendances externes et simplifier la compilation de Bitcoin Core à partir du code source.

- [BIPs #2198][] met à jour [BIP360][], la proposition P2MR (voir [Bulletin
  #393][news393 p2mr]), de sorte que toute personne connaissant et révélant l'unique feuille d'un
  arbre de scripts de profondeur zéro puisse dépenser la sortie sans que ce script soit exécuté. Cela rend intentionnellement les sorties
  P2MR à un seul chemin non sûres : une fois qu'un utilisateur révèle la feuille dans une tentative de dépense, un mineur pourrait utiliser
  cette même feuille révélée pour dépenser la sortie vers lui-même à la place. Le changement décourage les portefeuilles d'omettre une
  feuille de secours [post-quantique][topic quantum resistance] ou autre simplement pour économiser des octets de witness.

- [LDK #4713][] ajoute un durcissement contre le déni de service pour Rapid Gossip Sync (RGS) (voir [Bulletin #308][news308 rgs]), le format
  de LDK pour importer rapidement les données de gossip du Lightning Network. La documentation avertit désormais que les sources RGS doivent
  être considérées comme semi-fiables, puisqu'elles peuvent empêcher une recherche de chemin réussie en omettant des données et qu'elles
  peuvent aussi tenter de gonfler le graphe réseau d'un client. LDK rejette désormais les instantanés avec des nombres absurdes de nœuds ou
  de mises à jour de canaux, et cesse d'ajouter de nouvelles [annonces de canal][topic channel announcements] une fois que le graphe
  contient plus de dix fois le nombre attendu de canaux.

- [LDK #4684][] corrige un bug rare d'ordonnancement entre le signataire asynchrone et le moniteur de canal qui pouvait provoquer l'envoi
  d'un `revoke_and_ack` en double après une reconnexion. Auparavant, si un chemin débloqué par le signataire régénérait et envoyait un
  `revoke_and_ack` dû alors qu'une mise à jour du moniteur était encore en attente, le chemin restauré par le moniteur pouvait ensuite
  régénérer le même message, amenant le pair à rejeter le secret en double et à forcer la fermeture. LDK efface désormais le drapeau
  `revoke_and_ack` en attente côté moniteur lorsque le chemin en attente côté signataire renvoie un `revoke_and_ack`, puisque ce message
  satisfait également le renvoi en attente côté moniteur.

{% include snippets/recap-ad.md when="2026-06-30 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="2198,34411,35070,35182,4684,4713" %}

[news311 block storm]: /fr/newsletters/2024/07/12/#bitcoin-core-pr-review-club
[lnd gossip dos delving]: https://delvingbitcoin.org/t/lnd-zero-timestamp-gossip-dos-disclosure/2621
[news393 lnd 0201]: /fr/newsletters/2026/02/20/#lnd-0-20-1-beta
[LDK v0.1.10]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.1.10
[LDK v0.2.3]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.2.3
[BTCPay Server 2.4.0]: https://github.com/btcpayserver/btcpayserver/releases/tag/v2.4.0
[news393 p2mr]: /fr/newsletters/2026/02/20/#bips-1670
[news308 rgs]: /fr/newsletters/2024/06/21/#ldk-3098
