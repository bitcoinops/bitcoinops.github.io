---
title: 'Bulletin Hebdomadaire Bitcoin Optech #394'
permalink: /fr/newsletters/2026/02/27/
name: 2026-02-27-newsletter-fr
slug: 2026-02-27-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
La newsletter de cette semaine examine une proposition de BIP pour inclure des informations supplémentaires avec les descripteurs de script de sortie.
Sont également incluses nos sections régulières résumant les récentes questions et réponses de Bitcoin
Stack Exchange, annoncant de nouvelles versions et des candidats à la publication, ainsi que les
résumés des modifications notables apportées aux logiciels d'infrastructure Bitcoin populaires.

## Nouvelles

- **Brouillon de BIP pour les annotations de descripteur de script de sortie** : Craig Raw a [posté][annot ml] sur la liste de diffusion
  Bitcoin-Dev à propos d'une nouvelle idée de BIP pour répondre aux retours qui ont émergé lors de la discussion autour du BIP392
  (voir le [Bulletin #387][news387 sp]). Selon Raw, les métadonnées, telles que l'anniversaire du portefeuille exprimé en hauteur de bloc,
  pourraient rendre le balayage des [paiements silencieux][topic silent payments] plus efficace. Cependant, les métadonnées ne sont pas
  techniquement nécessaires pour déterminer les scripts de sortie, donc elles sont jugées inappropriées pour inclusion dans un [descripteur][topic descriptors].

  Le BIP de Raw propose de fournir des métadonnées utiles sous forme d'annotations, exprimées en paires clé/valeur, ajoutées directement
  à la chaîne de descripteur en utilisant des délimiteurs de requête similaires à ceux d'une URL. Un descripteur annoté ressemblerait à ceci :
  `SCRIPT?key=value&key=value#CHECKSUM`. Notamment, les caractères `?`, `&`, et `=` sont déjà définis dans le [BIP380][],
  donc l'algorithme de checksum n'aurait pas besoin d'être mis à jour.

  Dans le [brouillon de BIP][annot draft], Raw définit également trois clés d'annotation initiales spécifiquement pour rendre
  le balayage des fonds pour paiements silencieux plus efficace :

  - Hauteur de Bloc `bh` : La hauteur de bloc à laquelle un portefeuille a reçu les premiers fonds ;

  - Limite de Gap `gl` : Le nombre d'adresses inutilisées à dériver avant d'arrêter ;

  - Étiquette Max `ml` : L'indice d'étiquette maximum à scanner pour les portefeuilles de paiements silencieux.

  Enfin, Raw a noté que les annotations ne devraient pas être utilisées dans le processus général de sauvegarde de portefeuille,
  mais uniquement pour rendre la récupération de fonds plus efficace sans altérer les scripts produits par le descripteur.

## Questions et réponses sélectionnées de Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] est l'un des premiers endroits où les contributeurs d'Optech
cherchent des réponses à leurs questions---ou quand nous avons quelques moments libres pour aider
les utilisateurs curieux ou confus. Dans cette rubrique mensuelle, nous mettons en lumière certaines
des questions et réponses les mieux votées postées depuis notre dernière mise à jour.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Le transport P2P v2 de Bitcoin BIP324 est-il distinguable du trafic aléatoire ?]({{bse}}130500)
  Pieter Wuille souligne que le protocole de transport chiffré [v2][topic v2 p2p transport] de [BIP324][] prend en charge
  la formation de modèles de trafic, bien qu'aucun logiciel connu n'implémente cette fonctionnalité, concluant que
  "les implémentations actuelles ne déjouent que les signatures de protocole qui impliquent des modèles dans les octets envoyés, pas dans le trafic".

- [Que se passe-t-il si un mineur diffuse simplement l'en-tête et ne donne jamais le bloc ?]({{bse}}130456)
  L'utilisateur bigjosh décrit comment un mineur pourrait se comporter après avoir reçu un en-tête de bloc sur le réseau P2P
  mais avant de recevoir le contenu du bloc : en minant un bloc vide par-dessus. Pieter Wuille précise qu'en pratique,
  de nombreux mineurs voient effectivement les nouveaux en-têtes de blocs en surveillant le travail que d'autres pools de minage
  distribuent à leurs mineurs, une technique connue sous le nom de spy mining.

## Mises à jour et versions candidates

_Nouvelles versions et versions candidates pour des projets d'infrastructure Bitcoin populaires.
Veuillez envisager de mettre à niveau vers les nouvelles versions ou d'aider à tester les versions candidates._

- [Bitcoin Core 28.4rc1][] est un candidat à la version pour une maintenance de la série de versions majeures précédente.
  Il contient principalement des corrections de migration de portefeuille et la suppression d'un DNS seed peu fiable.

- [Rust Bitcoin 0.33.0-beta][] est une version beta de cette bibliothèque pour travailler avec les structures de données Bitcoin.
  C'est une mise à jour importante avec plus de 300 commits qui introduit une nouvelle crate `bitcoin-consensus-encoding`,
  ajoute des traits d'encodage de messages du réseau P2P, rejette les transactions avec des entrées dupliquées ou
  des sommes de sortie dépassant `MAX_MONEY` lors du décodage, et augmente les versions majeures de toutes les sous-crates.

## Changements notables dans le code et la documentation

_Changements notables récents dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo],
[BTCPay Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition repo], et [BINANAs][binana repo]._

- [Bitcoin Core #34568][] apporte plusieurs changements majeurs à l'interface IPC de minage (voir le [Bulletin #310][news310 mining]).
  Les méthodes obsolètes `getCoinbaseRawTx()`, `getCoinbaseCommitment()` et `getWitnessCommitmentIndex()` (voir le [Bulletin #388][news388 mining])
  sont supprimées, des paramètres `context` sont ajoutés à `createNewBlock` et `checkBlock` pour qu'ils puissent s'exécuter
  sur des threads séparés sans bloquer la boucle d'événements [Cap'n Proto][capn proto], et les valeurs d'option par défaut sont déclarées dans le schéma.
  Le numéro de version de `Init.makeMining` est augmenté pour que les clients plus anciens reçoivent une erreur claire
  au lieu d'interpréter silencieusement le nouveau schéma. Le changement de threading est une condition préalable pour la fonction de cooldown couverte ensuite.

- [Bitcoin Core #34184][] ajoute un cooldown optionnel à la méthode `createNewBlock()` sur l'interface IPC de minage.
  Lorsqu'activé, la méthode attend toujours que le Téléchargement Initial du Bloc (IBD) soit complet et que le sommet soit rattrapé
  avant de retourner un modèle de bloc. Cela empêche les clients [Stratum v2][topic pooled mining] d'être inondés de modèles
  rapidement obsolètes pendant le démarrage. Une nouvelle méthode `interrupt()` est également ajoutée pour que les clients IPC
  puissent interrompre proprement un appel bloquant à `createNewBlock()` ou `waitTipChanged()`.

- [Bitcoin Core #24539][] ajoute une nouvelle option `-txospenderindex` qui maintient un index de quelle transaction a dépensé chaque sortie confirmée.
  Lorsqu'activé, le RPC `gettxspendingprevout` est étendu pour retourner le `spendingtxid` et le `blockhash` pour les transactions confirmées,
  en plus de ses recherches existantes dans le mempool. Deux nouveaux arguments optionnels sont également ajoutés au RPC :
  `mempool_only` limite les recherches au mempool même lorsque l'index est disponible, et `return_spending_tx` retourne la transaction de dépense complète.
  L'index ne nécessite pas `-txindex` et est incompatible avec le pruning. Ceci est particulièrement utile pour Lightning
  et d'autres protocoles de seconde couche qui ont besoin de suivre des chaînes de transactions de dépense.

- [Bitcoin Core #34329][] ajoute deux nouveaux RPCs pour gérer les diffusions de transactions privées (voir le [Bulletin #388][news388 private]):
  `getprivatebroadcastinfo` retourne des informations sur les transactions actuellement dans la file d'attente de diffusion privée,
  y compris les adresses des pairs choisis et le moment où chaque diffusion a été envoyée, et
  `abortprivatebroadcast` annule la diffusion d'une transaction spécifique et ses connexions en attente.

- [Bitcoin Core #28792][] complète la série de PRs ASMap intégrée en regroupant les données ASMap directement dans le binaire de Bitcoin Core,
  de sorte que les utilisateurs qui activent `-asmap` n'ont plus besoin d'obtenir séparément un fichier de données. La suppression de l'option de build
  `WITH_EMBEDDED_ASMAP` permet d'exclure les données. ASMap améliore la résistance aux [attaques par éclipse][topic eclipse attacks] en diversifiant
  les connexions entre pairs à travers les systèmes autonomes (voir les Bulletins [#52][news52 asmap] et [#290][news290 asmap]).
  La fonctionnalité reste désactivée par défaut ; l'utilisateur doit toujours spécifier `-asmap` pour l'activer.
  Un nouveau [fichier de documentation][github asmap-data] décrit le processus pour obtenir les données et les inclure dans une version de Bitcoin Core.

- [Bitcoin Core #32138][] supprime le RPC `settxfee` et l'option de démarrage `-paytxfee`, qui permettaient aux utilisateurs de définir
  un taux de frais statique pour toutes les transactions. Les deux ont été dépréciés dans Bitcoin Core 30.0 (voir le [Bulletin #349][news349 settxfee]).
  Les utilisateurs devraient plutôt se fier à [l'estimation des frais][topic fee estimation] ou définir un taux de frais par transaction.

- [Bitcoin Core #34512][] ajoute un champ `coinbase_tx` à la réponse du RPC `getblock` au niveau de verbosité 1 et au-dessus,
  contenant les données `version`, `locktime`, `sequence`, `coinbase` script, et `witness` de la transaction coinbase. Les sorties sont
  intentionnellement exclues pour garder la réponse compacte. Auparavant, l'accès aux propriétés coinbase nécessitait la verbosité 2,
  qui décode chaque transaction dans le bloc. Ceci est utile pour surveiller les exigences de locktime coinbase de [BIP54][]
  ([nettoyage du consensus][topic consensus cleanup]) ou identifier les pools de minage à partir du script coinbase.

- [Core Lightning #8490][] ajoute une nouvelle option de configuration `payment-fronting-node` qui spécifie un ou plusieurs nœuds à utiliser
  toujours comme points d'entrée pour les paiements entrants. Lorsqu'elle est définie, les indices de route dans les factures [BOLT11][]
  et les points d'introduction de [chemin masqué][topic rv routing] dans les offres [BOLT12][topic offers], factures et demandes de facture
  sont construits pour utiliser uniquement les nœuds de façade spécifiés. Auparavant, CLN sélectionnait automatiquement parmi les pairs de canaux du nœud,
  exposant potentiellement différents pairs à travers les factures. L'option peut être définie globalement ou remplacée par offre.

- [Eclair #3250][] permet à `OpenChannelInterceptor` de sélectionner automatiquement un `channel_type` lorsque le nœud local ouvre un canal
  sans en avoir explicitement défini un. Auparavant, la création automatique de canal (par exemple, par un LSP ouvrant des canaux vers des clients)
  échouait à moins qu'un type ne soit fourni. Le choix par défaut actuel préfère les [canaux ancrés][topic anchor outputs],
  avec les [canaux taproot simples][topic simple taproot channels] qui devraient être privilégiés dans les PRs suivants.

- [LDK #4373][] ajoute le support pour l'envoi de [paiements multipath][topic multipath payments] où le nœud local paie seulement
  une portion du montant total de la facture. Un nouveau champ `total_mpp_amount_msat` dans `RecipientOnionFields` permet de déclarer
  un total MPP plus grand que ce que ce nœud envoie, permettant à plusieurs portefeuilles ou nœuds de payer collaborativement une seule facture
  en contribuant chacun une partie du paiement. Le receveur collecte les HTLCs de tous les nœuds contributeurs et réclame le paiement
  une fois le montant total arrivé. Le support de [BOLT12][topic offers] est laissé pour un suivi.

- [BDK #2081][] ajoute les méthodes `spent_txouts()` et `created_txouts()` à `SpkTxOutIndex` et `KeychainTxOutIndex` qui, étant donné une transaction,
  retournent quels outputs suivis elle a dépensés et quels nouveaux outputs suivis elle a créés. Cela permet aux portefeuilles de déterminer
  facilement les adresses et les montants impliqués dans les transactions qui les concernent.

{% include snippets/recap-ad.md when="2026-03-03 17:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="34568,34184,24539,34329,28792,32138,34512,8490,3250,4373,2081" %}

[annot ml]: https://groups.google.com/g/bitcoindev/c/ozjr1lF3Rkc
[news387 sp]: /en/newsletters/2026/01/09/#draft-bip-for-silent-payment-descriptors
[annot draft]: https://github.com/craigraw/bips/blob/descriptorannotations/bip-descriptorannotations.mediawiki
[news310 mining]: /fr/newsletters/2024/07/05/#bitcoin-core-30200
[news388 mining]: /fr/newsletters/2026/01/16/#bitcoin-core-33819
[news388 private]: /fr/newsletters/2026/01/16/#bitcoin-core-29415
[capn proto]: https://capnproto.org/
[news52 asmap]: /en/newsletters/2019/06/26/#differentiating-peers-based-on-asn-instead-of-address-prefix
[news290 asmap]: /fr/newsletters/2024/02/21/#amelioration-du-processus-de-creation-de-asmap-reproductible
[github asmap-data]: https://github.com/bitcoin/bitcoin/blob/master/doc/asmap-data.md
[news349 settxfee]: /fr/newsletters/2025/04/04/#bitcoin-core-31278
[Bitcoin Core 28.4rc1]: https://bitcoincore.org/bin/bitcoin-core-28.4/test.rc1/
[Rust Bitcoin 0.33.0-beta]: https://github.com/rust-bitcoin/rust-bitcoin/releases/tag/bitcoin-0.33.0-beta