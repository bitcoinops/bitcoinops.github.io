---
title: 'Bulletin Hebdomadaire Bitcoin Optech #345'
permalink: /fr/newsletters/2025/03/14/
name: 2025-03-14-newsletter-fr
slug: 2025-03-14-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine examine une analyse du trafic P2P vécu par un nœud complet typique,
résume la recherche sur le cheminement de LN (Lightning Network) et décrit une nouvelle approche
pour créer des paiements probabilistes. Sont également incluses nos sections régulières résumant une
réunion du Bitcoin Core PR Review Club, annonçant ddes mises à jour et des versions candidates,
et décrivant les changements notables dans les projets d'infrastructure Bitcoin populaires.

## Nouvelles

- **Analyse du trafic P2P :** le développeur Virtu a [posté][virtu traffic] sur Delving Bitcoin une
  analyse du trafic réseau généré et reçu par son nœud dans quatre modes différents : téléchargement
  initial de bloc (IBD), non-écoute (connexions sortantes uniquement), écoute non-archivale (tronquée)
  et écoute archivale. Bien que les résultats pour son seul nœud puissent ne pas être représentatifs
  dans tous les cas, nous avons trouvé plusieurs de ses découvertes intéressantes :

  - *Trafic de blocs élevé en tant que nœud d'écoute archivale :* le nœud de Virtu a servi plusieurs
    gigaoctets de blocs chaque heure à d'autres nœuds lorsqu'il fonctionnait comme un nœud d'écoute
    non-tronqué. De nombreux blocs étaient des blocs plus anciens demandés par des connexions entrantes
    afin qu'ils puissent effectuer l'IBD.

  - *Trafic inv élevé en tant qu'auditeur non-archival :* environ 20% du trafic total du nœud étaient
    des messages `inv` avant qu'il n'active le service de blocs plus anciens. [Erlay][topic erlay]
    pourrait réduire significativement cet excédent de 20%, qui représentait environ 100 mégaoctets par
    jour.

  - *La majorité des pairs entrants semblent être des nœuds espions :* "Intéressant, la majorité des
    pairs entrants n'échangent qu'environ 1MB de trafic avec mon nœud, ce qui est trop peu (en utilisant
    le trafic via mes connexions sortantes comme base) pour qu'ils soient des connexions régulières.
    Tout ce que ces nœuds font, c'est compléter la poignée de main P2P, et répondre poliment aux
    messages ping. À part ça, ils absorbent juste nos messages `inv`."

  Le post de Virtu contient des insights supplémentaires et plusieurs graphiques illustrant le trafic
  vécu par son nœud.

- **Recherche sur le cheminement de chemin unique LN :** Sindura Saraswathi a [posté][saraswathi
  path] sur Delving Bitcoin à propos de la [recherche][sk path] qu'elle a menée avec Christian
  Kümmerle sur la recherche de chemins optimaux entre les nœuds LN pour envoyer des paiements en une
  seule partie. Son post décrit les stratégies actuellement utilisées par Core Lightning, Eclair, LDK
  et LND. Les auteurs utilisent ensuite huit nœuds LN modifiés et non modifiés dans un réseau LN
  simulé (basé sur un instantané du réseau actuel) pour tester le cheminement, en évaluant des
  critères tels que le taux de succès le plus élevé, les ratios de frais les plus bas (coût le plus
  bas), le verrouillage total le plus court (période d'attente au pire des cas la moins pénible) et le chemin
  le plus court (moins susceptible de résulter en un paiement bloqué). Aucun algorithme n'a été
  meilleur que les autres dans tous les cas, et Saraswathi suggère que les implémentations fournissent
  de meilleures fonctions de pondération qui permettent aux utilisateurs de choisir les compromis
  qu'ils préfèrent pour différents paiements (par exemple, vous pouvez prioriser un taux de succès
  élevé pour un petit achat en personne mais
  préfèrer un ratio de frais faible pour payer une grosse facture mensuelle qui n'est pas due avant
  quelques semaines). Elle note également que "[bien que] au-delà du cadre de cette étude, nous
  remarquons que les insights obtenus dans cette étude sont également pertinents pour les
  améliorations futures dans les algorithmes de recherche de chemin pour les [paiements
  multi-parties][topic multipath payments]."

- **Paiements probabilistes utilisant différentes fonctions de hachage comme une fonction xor :**
  Robin Linus [a répondu][linus pp] au fil de discussion Delving Bitcoin à propos des [paiements
  probabilistes][topic probabilistic payments] avec un script conceptuellement simple qui permet à
  deux parties de s'engager chacune sur une quantité arbitraire d'entropie qui peut plus tard être
  révélée et xorée ensemble, pour produire une valeur qui peut être utilisée pour déterminer lequel
  d'entre eux reçoit un paiement. En utilisant (et en étendant légèrement) l'exemple de Linus du post :

  - Alice choisit privément la valeur `1 0 0` plus un nonce séparé.
    Bob choisit privément la valeur `1 1 0` plus un autre nonce séparé.

  - Chaque partie hache successivement son nonce, avec les nombres dans leur valeur déterminant quelle
    fonction de hachage est utilisée. Quand la valeur en haut de la pile est `0`, ils utilisent l'opcode
    `HASH160`; quand la valeur est `1`, ils utilisent l'opcode `SHA256`. Dans le cas d'Alice, elle
    effectue `sha256(hash160(hash160(alice_nonce)))`; dans le cas de Bob, il effectue
    `sha256(sha256(hash160(bob_nonce)))`. Cela produit un engagement pour chacun d'eux, qu'ils
    s'envoient mutuellement sans révéler ni leur valeur ni leur nonce.

  - Avec les engagements partagés, ils créent une transaction de financement onchain avec un script
    qui validera les entrées en utilisant `OP_IF` pour choisir entre les différentes fonctions de
    hachage et permet à l'un d'eux de réclamer le paiement. Par exemple, si la somme de leurs deux
    valeurs xorées est 0 ou 1, Alice reçoit l'argent ; si c'est 2 ou 3, Bob le reçoit. Le contrat peut
    également avoir une clause de délai et une clause d'accord mutuel économisant de l'espace.

  - Après que la transaction de financement soit confirmée à une profondeur appropriée, Alice et Bob se
    divulguent mutuellement leurs valeurs et leurs nonces. Le xor de `1 0 0` et `1 1 0` est `0 1 0`, qui
    se somme à `1`, permettant à Alice de réclamer le paiement.

## Bitcoin Core PR Review Club

*Dans cette section mensuelle, nous résumons une récente réunion du [Bitcoin Core PR Review Club][],
en soulignant certaines des questions et réponses importantes. Cliquez sur une question ci-dessous
pour voir un résumé de la réponse de la réunion.*

[Un traitement interne plus strict des blocs invalides][review club 31405] est un PR par
[mzumsande][gh mzumsande] qui améliore la justesse de deux champs de validation non critiques pour
le consensus et coûteux à calculer en les mettant à jour immédiatement lorsqu'un bloc est marqué
comme invalide. Avant ce PR, ces mises à jour étaient retardées jusqu'à un événement ultérieur pour
minimiser l'utilisation des ressources. Cependant, depuis [Bitcoin Core #25717][], un attaquant
aurait besoin d'investir beaucoup plus de travail pour exploiter cela.

Plus précisément, cette PR garantit que le `m_best_header` de `ChainstateManager` pointe toujours
vers l'en-tête le plus travaillé qui n'est pas connu pour être valide, et que le `nStatus`
`BLOCK_FAILED_CHILD` d'un bloc est toujours correct.

Les avantages de cette approche seraient une meilleure performance
et une simplicité accrue lors de l'invalidation des descendants. Cependant, cela augmenterait la
complexité de la gestion de la mémoire et pourrait potentiellement introduire de nouveaux bugs liés
à la gestion des références circulaires entre les blocs. L'approche actuelle, bien que
potentiellement plus coûteuse en termes de performance, évite ces complications en maintenant une
séparation claire entre les blocs et leurs états d'invalidation.

{% include functions/details-list.md
  q0="Quels sont les objectifs de `ChainstateManager::m_best_header`?"
  a0="`m_best_header` représente l'en-tête avec le plus de PoW que le nœud a vu jusqu'à présent et
  qu'il n'a pas encore invalidé mais ne peut pas non plus garantir comme étant valide. Il a de
  nombreuses utilisations, mais la principale est de servir de cible vers laquelle le nœud peut faire
  progresser sa meilleure chaîne. D'autres cas d'utilisation incluent la fourniture d'une estimation
  du temps actuel, et une estimation de la hauteur de la meilleure chaîne lors de la demande
  d'en-têtes manquants à un pair. Un aperçu plus complet peut être trouvé dans la pull request vieille
  de ~6 ans [Bitcoin Core #16974][]."
  a0link="https://bitcoincore.reviews/31405#l-36"

  q1="Avant cette PR, lequel de ces énoncés est vrai, le cas échéant ?
  1) un `CBlockIndex` avec un prédécesseur INVALIDE aura TOUJOURS un `BLOCK_FAILED_CHILD` `nStatus`.
  2) un `CBlockIndex` avec un prédécesseur VALIDE n'aura JAMAIS un `BLOCK_FAILED_CHILD` `nStatus`"
  a1="L'énoncé 1) est faux, et est directement abordé dans cette PR. Avant cette PR, `AcceptBlock()`
  marquerait un bloc comme invalide, mais pour des raisons de performance, ne mettrait pas
  immédiatement à jour ses descendants comme tels. Les participants au Review Club n'ont pas pu penser
  à un scénario où l'énoncé 2) était faux."
  a1link="https://bitcoincore.reviews/31405#l-68"

  q2="L'un des objectifs de cette PR est de s'assurer que `m_best_header`, et le `nStatus` des
  successeurs d'un bloc invalide sont toujours correctement définis.
  Quelles fonctions sont directement responsables de la mise à jour de ces valeurs ?"
  a2="`SetBlockFailureFlags()` est responsable de la mise à jour de `nStatus`. En fonctionnement
  normal, `m_best_header` est le plus souvent défini via le paramètre de sortie dans
  `AddToBlockIndex()`, mais il peut également être calculé et défini via `RecalculateBestHeader()`."
  a2link="https://bitcoincore.reviews/31405#l-110"

  q3="La majorité de la logique dans le commit `4100495` `validation: in invalidateblock, calculate m_best_header right away`
  met en œuvre la recherche du nouvel meilleur en-tête.
  Qu'est-ce qui nous empêche d'utiliser simplement `RecalculateBestHeader()` ici ?"
  a3="`RecalculateBestHeader()` traverse l'ensemble de `m_block_index`, ce qui est une opération
  coûteuse. Le commit `4100495` optimise cela en mettant en cache et en itérant plutôt sur un ensemble
  de candidats avec des en-têtes à haute PoW."
  a3link="https://bitcoincore.reviews/31405#l-114"

  q4="Aurions-nous encore besoin du cache `cand_invalid_descendants` si nous pouvions itérer vers
  l'avant (c'est-à-dire, loin du bloc de genèse) sur l'arbre des blocs ? Quels seraient les avantages
  et les inconvénients d'une telle approche, comparée à celle prise dans cette PR ?"
  a4="Si les objets `CBlockIndex` contenaient des références à tous leurs descendants, nous n'aurions
  pas besoin d'itérer sur l'ensemble de `m_block_index` pour invalider les descendants, et par
  conséquent, nous n'aurions pas besoin du cache `cand_invalid_descendants`. Les avantages de cette
  approche seraient une meilleure performance et une simplicité accrue lors de l'invalidation des
  descendants. Cependant, cette approche aurait des inconvénients significatifs.
  Premièrement, cela augmenterait l'empreinte mémoire de chaque objet `CBlockIndex`, qui doit être
  conservé en mémoire pour l'ensemble du `m_block_index`. Deuxièmement, la logique d'itération
  resterait non triviale puisque, bien que chaque `CBlockIndex` ait exactement un ancêtre, il peut
  n'avoir aucun ou plusieurs descendants.
  a4link="https://bitcoincore.reviews/31405#l-136"

## Mises à jour et versions candidates

_Nouvelles versions et versions candidates pour des projets d'infrastructure Bitcoin populaires.
Veuillez envisager de mettre à niveau vers les nouvelles versions ou d'aider à tester les versions candidates._

- [Eclair v0.12.0][] est une sortie majeure de ce nœud LN. Elle "ajoute le support pour créer et
  gérer des offres [BOLT12][] et un nouveau protocole de fermeture de canal qui supporte [RBF][topic
  rbf]. [Elle] ajoute également le support pour stocker de petites quantités de données pour nos
  pairs" ([stockage de pairs][topic peer storage]), parmi d'autres améliorations et corrections de
  bugs. Les notes de version mentionnent que plusieurs dépendances majeures ont été mises à jour,
  nécessitant que les utilisateurs effectuent ces mises à jour avant de déployer la nouvelle version
  d'Eclair.

## Changements notables dans le code et la documentation

_Changements récents notables dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core
lightning repo], [Eclair][eclair repo], [LDK][ldk repo], [LND][lnd repo],
[libsecp256k1][libsecp256k1 repo], [Interface de Portefeuille Matériel (HWI)][hwi repo], [Rust
Bitcoin][rust bitcoin repo], [Serveur BTCPay][btcpay server repo], [BDK][bdk repo], [Propositions
d'Amélioration de Bitcoin (BIPs)][bips repo], [Lightning BOLTs][bolts repo], [Lightning BLIPs][blips
repo], [Inquisition Bitcoin][bitcoin inquisition repo], et [BINANAs][binana repo]._

- [Bitcoin Core #31407][] ajoute le support pour la notarisation des paquets d'applications macOS et
  des binaires en mettant à jour le script `detached-sig-create.sh`. Le script signe maintenant
  également les binaires macOS et Windows en autonomie. L'outil récemment mis à jour [signapple][] est
  utilisé pour effectuer ces tâches.

- [Eclair #3027][] ajoute une fonctionnalité de recherche de chemin pour [les chemins
  aveuglés][topic rv routing] lors de la génération de factures [BOLT12][topic offers] en introduisant
  la fonction `routeBlindingPaths`, qui calcule un chemin d'un nœud initiateur sélectionné au nœud
  récepteur en utilisant uniquement des nœuds qui supportent les chemins aveuglés. Le chemin aveuglé
  est ensuite inclus dans la facture.

- [Eclair #3007][] ajoute un paramètre TLV `last_funding_locked` dans les messages
  `channel_reestablish` pour améliorer la synchronisation entre pairs pendant le [splicing][topic
  splicing] de canal après une déconnexion. Cela corrige une condition de concurrence où un nœud
  envoie une `channel_update` après avoir reçu un `channel_reestablish` mais avant `splice_locked`, ce
  qui est sans conséquence pour les canaux réguliers mais pourrait perturber [les canaux taproot
  simples][topic simple taproot channels] qui nécessitent des échanges de nonce entre pairs.

- [Eclair #2976][] ajoute le support pour créer des [offres][topic offers] sans plugins additionnels
  en introduisant la commande `createoffer`, qui prend des paramètres optionnels pour la description,
  le montant, l'expiration en secondes, l'émetteur,
  et `blindedPathsFirstNodeId` pour définir un nœud initiateur pour un [chemin masqué][topic rv
  routing]. De plus, cette PR introduit les commandes `disableoffer` et `listoffers` pour gérer les
  offres existantes.

- [LDK #3608][] redéfinit le `CLTV_CLAIM_BUFFER` pour représenter le double du nombre maximum
  attendu de blocs nécessaires pour confirmer une transaction, s'adaptant aux canaux [anchor][topic
  anchor outputs] où les transactions de réclamation [HTLCs][topic htlc] sont retardées par un
  [verrouillage temporel][topic timelocks] `OP_CHECKSEQUENCEVERIFY` (CSV) d'1 bloc. Auparavant, il
  était fixé à une seule période de confirmation maximale, ce qui était suffisant pour les canaux
  pré-anchor où les transactions de réclamation HTLC étaient diffusées en même temps que les
  transactions d'engagement. Une nouvelle constante `MAX_BLOCKS_FOR_CONF` est ajoutée comme valeur de
  base.

- [LDK #3624][] permet la rotation de la clé de financement après une [épissure][topic splicing] de
  canal réussi en appliquant une modification scalaire à la clé de financement de base pour obtenir la
  clé [multisig][topic multisignature] 2-sur-2 du canal. Cela permet à un nœud de dériver des clés
  supplémentaires à partir du même secret. Le calcul de la modification suit la spécification
  [BOLT3][], mais remplace `per_commitment_point` par le txid de financement de l'épissure pour
  garantir l'unicité, et utilise le `revocation_basepoint` pour restreindre la dérivation aux
  participants du canal.

- [LDK #3016][] ajoute un support pour que les projets externes exécutent des tests fonctionnels et
  remplacent des composants comme le signataire en introduisant une macro `xtest`. Il inclut un
  utilitaire `MutGlobal` et une structure `DynSigner` pour supporter des composants de test dynamiques
  comme le signataire, expose ces tests sous le drapeau de fonctionnalité `_externalize_tests`, et
  fournit une `TestSignerFactory` pour créer des signataires dynamiques.

- [LDK #3629][] améliore la journalisation des échecs distants qui ne peuvent pas être attribués ou
  interprétés pour offrir plus de visibilité sur ces cas limites. Cette PR modifie `onion_utils.rs`
  pour journaliser les échecs non attribuables qui pourraient perturber l'opération de l'expéditeur,
  et introduit une fonction `decrypt_failure_onion_error_packet` pour la gestion du déchiffrement.
  Elle corrige également un bug où un échec illisible avec un code d'authentification de message basé
  sur un hash (HMAC) valide n'était pas correctement attribué à un nœud. Cela peut être lié à
  permettre aux dépensiers d'éviter d'utiliser des nœuds qui annoncent une [haute
  disponibilité][news342 qos] mais ne tiennent pas leurs promesses.

- [BDK #1838][] améliore la clarté du flux de synchronisation et d'analyse complète en ajoutant un
  `sync_time` obligatoire à `SyncRequest` et `FullScanRequest`, appliquant ce `sync_time` comme
  propriété `seen_at` pour les transactions non confirmées tout en permettant aux transactions non
  canoniques (voir le Bulletin [#335][news335 noncanonical]) d'exclure un horodatage `seen_at`. Il met
  à jour `TxUpdate::seen_ats` en un `HashSet` de (Txid, u64) pour supporter plusieurs horodatages
  `seen_at` par transaction, et change `TxGraph` pour être non exhaustif, parmi d'autres changements.

{% include snippets/recap-ad.md when="2025-03-18 15:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="31407,3027,3007,2976,3608,3624,3016,3629,1838,16974,25717" %}
[virtu traffic]: https://delvingbitcoin.org/t/bitcoin-node-p2p-traffic-analysis/1490/
[saraswathi path]: https://delvingbitcoin.org/t/an-exposition-of-pathfinding-strategies-within-lightning-network-clients/1500
[sk path]: https://arxiv.org/pdf/2410.13784
[linus pp]: https://delvingbitcoin.org/t/emulating-op-rand/1409/10
[eclair v0.12.0]: https://github.com/ACINQ/eclair/releases/tag/v0.12.0
[review club 31405]: https://bitcoincore.reviews/31405
[gh mzumsande]: https://github.com/mzumsande
[signapple]: https://github.com/achow101/signapple
[news335 noncanonical]: /en/newsletters/2025/01/03/#bdk-1670
[news342 qos]: /en/newsletters/2025/02/21/#continued-discussion-about-an-ln-quality-of-service-flag
