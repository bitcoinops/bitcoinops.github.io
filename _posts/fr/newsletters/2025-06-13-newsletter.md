---
title: 'Bulletin Hebdomadaire Bitcoin Optech #358'
permalink: /fr/newsletters/2025/06/13/
name: 2025-06-13-newsletter-fr
slug: 2025-06-13-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
La newsletter de cette semaine décrit comment le seuil de danger du minage égoïste peut être
calculé, résume une idée pour prévenir le filtrage des transactions à frais élevés, sollicite des
retours sur une proposition de modification du BIP390 de descripteur `musig()`, et annonce une nouvelle
bibliothèque pour le chiffrement des descripteurs. Sont également inclus nos sections régulières
avec le résumé d'un Bitcoin Core PR Review Club, les annonces de nouvelles versions et candidates à
la sortie, et les descriptions des changements récents dans les projets d'infrastructure Bitcoin
populaires.

## Nouvelles

- **Calcul du seuil de danger du minage égoïste :** Antoine Poinsot a [publié][poinsot selfish] sur
  Delving Bitcoin une expansion des calculs de l'article de 2013 [paper][es selfish] qui a donné
  son nom à l'[attaque par minage égoïste][topic selfish mining] (bien que l'attaque ait été
  [précédemment décrite][bytecoin selfish] en 2010). Il a également fourni un
  [simulateur][darosior/miningsimulation] de minage et de relais de blocs simplifié qui permet
  d'expérimenter avec l'attaque. Il se concentre sur la reproduction d'une des conclusions de
  l'article de 2013 : qu'un mineur malhonnête (ou un cartel de mineurs bien connectés) contrôlant 33 %
  du hashrate total du réseau, sans avantages supplémentaires, peut devenir marginalement plus
  rentable à long terme que les mineurs contrôlant 67 % du hashrate. Ceci est réalisé en retardant
  sélectivement l'annonce de certains des nouveaux blocs qu'il trouve. À mesure que le hashrate du
  mineur malhonnête augmente au-dessus de 33 %, il devient encore plus rentable jusqu'à ce qu'il
  dépasse 50 % du hashrate et puisse empêcher ses concurrents de conserver de nouveaux blocs sur la
  meilleure blockchain.

  Nous n'avons pas examiné attentivement le post de Poinsot, mais son approche nous a semblé solide et
  nous la recommanderions à quiconque intéressé à valider les calculs ou à mieux les comprendre.

- **Résistance à la censure de relais par réconciliation de l'ensemble supérieur du mempool :**
  Peter Todd a [posté][todd feerec] sur la liste de diffusion Bitcoin-Dev à propos d'un mécanisme qui
  permettrait aux nœuds de se déconnecter des pairs qui filtrent les transactions à frais élevés. Le
  mécanisme dépend du [mempool en cluster][topic cluster mempool] et d'un mécanisme de réconciliation
  d'ensemble tel que celui utilisé par [erlay][topic erlay]. Un nœud utiliserait le mempool en cluster
  pour calculer son ensemble de transactions non confirmées le plus rentable qui pourrait tenir dans
  (par exemple) 8 000 000 d'unités de poids (un maximum de 8 MB). Chacun des pairs du nœud calculerait
  également ses 8 MWU supérieurs de transactions non confirmées. En utilisant un algorithme hautement
  efficace, tel que [minisketch][topic minisketch], le nœud réconcilierait son ensemble de
  transactions avec chacun de ses pairs. Ce faisant, il apprendrait exactement quelles transactions
  chaque pair a dans le haut de son mempool. Ensuite, le nœud se déconnecterait périodiquement du pair
  ayant en moyenne le mempool le moins rentable.

  En se déconnectant des connexions les moins rentables, le nœud aurait
  finalement trouvé des pairs qui étaient les moins susceptibles de filtrer les transactions à frais
  élevés. Todd a mentionné qu'il espère travailler sur une implémentation après que le support du
  mempool en cluster soit intégré dans Bitcoin Core. Il a attribué l'idée à Gregory Maxwell et à d'autres;
  Optech a mentionné pour la première fois l'idée sous-jacente dans le [Bulletin #9][news9 reconcile].

- **Mise à jour de BIP390 pour permettre des clés de participants dupliquées dans les expressions `musig()`:**
  Ava Chow a [posté][chow dupsig] sur la liste de diffusion Bitcoin-Dev pour demander si quelqu'un
  s'opposait à la mise à jour de [BIP390][] pour permettre aux expressions `musig()` dans les
  [descripteurs de script de sortie][topic descriptors] de contenir la même clé publique de
  participant plus d'une fois. Cela simplifierait l'implémentation et est explicitement autorisé par
  la spécification [BIP327][] de [MuSig2][topic musig]. À l'heure actuelle, personne ne s'est opposé,
  et Chow a ouvert une [pull request][bips #1867] pour changer la spécification de BIP390.

- **Bibliothèque de chiffrement de descripteur :** Josh Doman a [posté][doman descrypt] sur Delving
  Bitcoin pour annoncer une bibliothèque qu'il a construite qui chiffre les parties sensibles d'un
  [descripteur de script de sortie][topic descriptors] ou [miniscript][topic miniscript] aux clés
  publiques contenues en son sein. Il décrit les informations nécessaires pour déchiffrer :

  > - Si votre portefeuille nécessite 2 clés sur 3 pour dépenser, il nécessitera exactement 2 clés sur
      3 pour déchiffrer.
  >
  > - Si votre portefeuille utilise une politique miniscript complexe comme "Soit 2 clés OU (un
      timelock ET une autre clé)", le chiffrement suit la même structure, comme si tous les timelocks et
      hash-locks sont satisfaits.

  Cela diffère du schéma de sauvegarde de descripteur chiffré discuté dans le [Bulletin #351][news351
  salvacrypt], dans lequel la connaissance de n'importe quelle clé publique contenue dans le
  descripteur permet le déchiffrement du descripteur. Doman argue que son schéma offre une meilleure
  confidentialité pour les cas où le descripteur chiffré est sauvegardé sur une source publique ou
  semi-publique, comme une blockchain.

## Bitcoin Core PR Review Club

*Dans cette section mensuelle, nous résumons une récente réunion du [Bitcoin Core PR Review Club][],
en soulignant certaines des questions et réponses importantes. Cliquez sur une question ci-dessous
pour voir un résumé de la réponse de la réunion.*

[Séparer l'accès à l'ensemble UTXO des fonctions de validation][review club 32317] est un PR de
[TheCharlatan][gh thecharlatan] qui permet d'appeler des fonctions de validation en passant juste
les UTXOs requis, au lieu de nécessiter l'ensemble UTXO complet. Il fait partie du projet
[`bitcoinkernel`][Bitcoin Core #27587], et est une étape importante pour rendre la bibliothèque plus
utilisable pour les implémentations de nœuds complets qui n'implémentent pas un ensemble UTXO, comme
les nœuds [Utreexo][topic utreexo] ou [SwiftSync][somsen swiftsync] (voir le [Bulletin #349][news349
swiftsync]).

Dans les 4 premiers commits, ce PR réduit le couplage entre les fonctions de validation des
transactions et l'ensemble UTXO en exigeant que l'appelant récupère d'abord les `Coin`s ou `CTxOut`s
dont ils ont besoin et en les passant à la fonction de validation, au lieu de permettre à la
fonction de validation d'accéder directement à l'ensemble UTXO.
Dans les commits suivants, la dépendance de `ConnectBlock()` par rapport à l'ensemble UTXO est
entièrement supprimée en extrayant la logique restante nécessitant une interaction avec l'ensemble
UTXO dans une méthode séparée `SpendBlock()`.

{% include functions/details-list.md
  q0="Pourquoi est-il utile d'extraire la nouvelle fonction `SpendBlock()` de `ConnectBlock()` pour
  cette PR ? Comment compareriez-vous le but des deux fonctions ?"
  a0="La fonction `ConnectBlock()` effectuait à l'origine à la fois la validation des blocs et les
  modifications de l'ensemble UTXO. Cette refactortorisation divise ces responsabilités : `ConnectBlock()` est
  maintenant uniquement responsable de la logique de validation qui ne nécessite pas l'ensemble UTXO,
  tandis que la nouvelle fonction `SpendBlock()` gère toutes les interactions avec l'ensemble UTXO.
  Cela permet à un appelant d'utiliser `ConnectBlock()` pour effectuer la validation des blocs sans un
  ensemble UTXO."
  a0link="https://bitcoincore.reviews/32317#l-37"

  q1="Voyez-vous un autre avantage à cette séparation, à part permettre l'utilisation du noyau sans un
  ensemble UTXO ?"
  a1="Outre la possibilité d'utiliser le noyau pour des projets sans ensemble UTXO, cette séparation
  rend le code plus facile à tester isolément et plus simple à maintenir. Un examinateur note
  également que la suppression de la nécessité d'accéder à l'ensemble UTXO ouvre la porte à la
  validation des blocs en parallèle, ce qui est une caractéristique importante de SwiftSync."
  a1link="https://bitcoincore.reviews/32317#l-64"

  q2="`SpendBlock()` prend un `CBlock block`, `CBlockIndex pindex` et `uint256 block_hash` en
  paramètres, tous faisant référence au bloc dépensé. Pourquoi avons-nous besoin de 3 paramètres pour
  cela ?"
  a2="Le code de validation est critique en termes de performance, il affecte des paramètres
  importants tels que la vitesse de propagation des blocs. Calculer le hash d'un bloc à partir d'un
  `CBlock` ou d'un `CBlockIndex` n'est pas gratuit, car la valeur n'est pas mise en cache. Pour cette
  raison, l'auteur a décidé de prioriser la performance en passant un `block_hash` déjà calculé comme
  paramètre séparé. De même, le `pindex` pourrait être récupéré à partir de l'index des blocs, mais
  cela impliquerait une recherche supplémentaire dans une map qui n'est pas strictement nécessaire.
  <br>_Note : l'auteur a plus tard [changé][32317 updated approach] l'approche, en supprimant
  l'optimisation de performance `block_hash`._"
  a2link="https://bitcoincore.reviews/32317#l-97"

  q3="Les premiers commits de cette PR refactorisent `CCoinsViewCache` hors de la signature de
  fonction de plusieurs fonctions de validation. Est-ce que `CCoinsViewCache` contient l'ensemble UTXO
  complet ? Pourquoi est-ce (ou pas) un problème ? Cette PR change-t-elle ce comportement ?"
  a3="`CCoinsViewCache` ne contient pas l'ensemble UTXO complet ; c'est un cache en mémoire qui se
  trouve devant `CCoinsViewDB`, qui stocke l'ensemble UTXO complet sur le disque. Si une pièce demandée
  n'est pas dans le cache, elle doit être récupérée depuis le disque. Cette PR ne change pas ce
  comportement de mise en cache en soi. En retirant `CCoinsViewCache` des signatures de fonction, cela
  rend la dépendance UTXO explicite, nécessitant que l'appelant récupère les pièces avant d'appeler la
  fonction de validation."
  a3link="https://bitcoincore.reviews/32317#l-116"%}"
%}

## Mises à jour et versions candidates

_Nouvelles versions et versions candidates pour des projets d'infrastructure Bitcoin populaires.
Veuillez envisager de mettre à niveau vers les nouvelles versions ou d'aider à tester les versions candidates._

- [Core Lightning 25.05rc1][] est un candidat à la version pour la prochaine version majeure de
  cette implémentation populaire de nœud LN.

- [LND 0.19.1-beta][] est une version de maintenance de cette implémentation populaire de nœud LN.
  Elle [contient][lnd rn] de multiples corrections de bugs.

## Changements de code et de documentation notables

_Changements récents dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core
lightning repo], [Eclair][eclair repo], [LDK][ldk repo], [LND][lnd repo],
[libsecp256k1][libsecp256k1 repo], [Interface de Portefeuille Matériel (HWI)][hwi repo], [Rust
Bitcoin][rust bitcoin repo], [Serveur BTCPay][btcpay server repo], [BDK][bdk repo], [Propositions
d'Amélioration de Bitcoin (BIPs)][bips repo], [Lightning BOLTs][bolts repo], [Lightning BLIPs][blips
repo], [Inquisition Bitcoin][bitcoin inquisition repo], et [BINANAs][binana repo]._

- [Bitcoin Core #32406][] supprime la limite de taille de sortie `OP_RETURN` (règle de
  standardisation) en augmentant le paramètre `-datacarriersize` par défaut de 83 à 100 000 octets (la
  limite de taille maximale de transaction). Les options `-datacarrier` et `-datacarriersize` restent,
  mais sont marquées comme obsolètes et devraient être retirées dans une future version non
  déterminée. De plus, ce PR lève également la restriction de politique d'une par transaction pour les
  sorties OP_RETURN, et la limite de taille est maintenant allouée à travers toutes ces sorties dans
  une transaction. Voir le [Bulletin #352][news352 opreturn] pour un contexte supplémentaire sur ce
  changement.

- [LDK #3793][] ajoute un nouveau message `start_batch` qui signale aux pairs de traiter les `n`
  messages suivants (`batch_size`) comme une seule unité logique. Il met également à jour
  `PeerManager` pour s'appuyer sur cela pour les messages `commitment_signed` pendant le
  [splicing][topic splicing], plutôt que d'ajouter un TLV et un champ `batch_size` à chaque message
  dans le lot. C'est une tentative de permettre à des messages de protocole LN supplémentaires d'être
  regroupés plutôt que seulement les messages `commitment_signed`, qui sont les seuls regroupements
  définis dans la spécification LN.

- [LDK #3792][] introduit un support initial pour les [transactions d'engagement v3][topic v3
  commitments] (voir le [Bulletin #325][news325 v3]) qui s'appuient sur les [transactions TRUC][topic
  v3 transaction relay] et les [ancres éphémères][topic ephemeral anchors], derrière un drapeau de
  test. Un nœud rejette maintenant toute proposition `open_channel` qui définit un taux de frais non
  nul, s'assure qu'il n'initie jamais de tels canaux lui-même, et arrête d'accepter automatiquement
  les canaux v3 pour d'abord réserver un UTXO pour une augmentation de frais ultérieure. Le PR abaisse
  également la limite [HTLC][topic htlc] par canal de 483 à 114 parce que les transactions TRUC
  doivent rester en dessous de 10 kvB.

  - [LND #9127][] ajoute une option `--blinded_path_incoming_channel_list` à la commande `lncli addinvoice`,
    permettant à un destinataire d'intégrer un ou plusieurs (pour de multiples sauts) ID de
    canaux préférés pour que le payeur tente de les emprunter via un [chemin aveuglé][topic rv routing].

- [LND #9858][] commence à signaler le bit de fonctionnalité de production 61 pour le flux de
  fermeture coopérative [RBF][topic rbf] (voir le [Bulletin #347][news347 rbf]) pour permettre une
  interopérabilité correcte avec Eclair. Il conserve le bit de mise en scène 161 pour maintenir
  l'interopérabilité avec les nœuds testant la fonctionnalité.

- [BOLTs #1243][] met à jour la spécification [BOLT11][] pour indiquer qu'un lecteur (expéditeur) ne
  doit pas payer une facture si un champ obligatoire, tel que p (hash de paiement), h (hash de
  description), ou s (secret), a une longueur incorrecte. Auparavant, les nœuds pouvaient ignorer ce
  problème. Cette PR ajoute également une note à la section Exemples expliquant que les [signatures
  Low R][topic low-r grinding], même si elles économisent un octet d'espace, ne sont pas imposées dans
  la spécification.

{% include snippets/recap-ad.md when="2025-06-17 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="32406,3793,3792,9127,1867,9858,1243,27587" %}
[Core Lightning 25.05rc1]: https://github.com/ElementsProject/lightning/releases/tag/v25.05rc1
[lnd 0.19.1-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.19.1-beta
[poinsot selfish]: https://delvingbitcoin.org/t/where-does-the-33-33-threshold-for-selfish-mining-come-from/1757
[bytecoin selfish]: https://bitcointalk.org/index.php?topic=2227.msg30083#msg30083
[darosior/miningsimulation]: https://github.com/darosior/miningsimulation
[todd feerec]: https://mailing-list.bitcoindevs.xyz/bitcoindev/aDWfDI03I-Rakopb@petertodd.org/
[news9 reconcile]: /en/newsletters/2018/08/21/#bandwidth-efficient-set-reconciliation-protocol-for-transactions
[chow dupsig]: https://mailing-list.bitcoindevs.xyz/bitcoindev/08dbeffd-64ec-4ade-b297-6d2cbeb5401c@achow101.com/
[doman descrypt]: https://delvingbitcoin.org/t/rust-descriptor-encrypt-encrypt-any-descriptor-such-that-only-authorized-spenders-can-decrypt/1750/
[news351 salvacrypt]: /fr/newsletters/2025/04/25/#sauvegarde-standardisee-pour-les-descripteurs-de-portefeuille
[es selfish]: https://arxiv.org/pdf/1311.0243
[lnd rn]: https://github.com/lightningnetwork/lnd/blob/v0.19.1-beta/docs/release-notes/release-notes-0.19.1.md
[news352 opreturn]: /fr/newsletters/2025/05/02/#augmentation-ou-suppression-de-la-limite-de-taille-op-return-de-bitcoin-core
[news325 v3]: /fr/newsletters/2024/10/18/#transactions-d-engagement-de-version-3
[news347 rbf]: /fr/newsletters/2025/03/28/#lnd-8453
[club de révision 32317]: https://bitcoincore.reviews/32317
[gh thecharlatan]: https://github.com/TheCharlatan
[somsen swiftsync]: https://gist.github.com/RubenSomsen/a61a37d14182ccd78760e477c78133cd
[approche mise à jour 32317]: https://github.com/bitcoin/bitcoin/pull/32317#issuecomment-2883841466
[news349 swiftsync]: /fr/newsletters/2025/04/11/#acceleration-swiftsync-pour-le-telechargement-initial-des-blocs