---
title: 'Bulletin Hebdomadaire Bitcoin Optech #376'
permalink: /fr/newsletters/2025/10/17/
name: 2025-10-17-newsletter-fr
slug: 2025-10-17-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine partage une mise à jour sur la proposition pour que les nœuds
partagent leur modèle de bloc actuel et résume un article décrivant une construction de coffre-fort
sans covenant. Sont également incluses nos sections régulières résumant les changements récents apportés
aux clients et services, les annonces de nouvelles versions et de candidats à la publication, et les
résumés des modifications notables apportées aux logiciels d'infrastructure Bitcoin populaires.

## Nouvelles

- **Discussion continue sur le partage de modèle de bloc :** La discussion [a continué][towns
  tempshare] autour de la proposition pour que les pairs de nœuds complets s'envoient
  occasionnellement leur modèle actuel pour le prochain bloc en utilisant le codage [compact block
  relay][topic compact block relay] (voir les Bulletins [#366][news366 block template sharing] et
  [#368][news368 bts]). Des préoccupations ont été soulevées concernant la vie privée et l'empreinte
  digitale des nœuds, et l'auteur a décidé de déplacer le brouillon actuel vers le dépôt [Bitcoin
  Inquisition Numbers and Names Authority][binana repo] (BINANA), pour aborder ces considérations et
  affiner le document. Le brouillon a reçu le code [BIN-2025-0002][bin].

- **B-SSL, une couche de signature Bitcoin sécurisée :** Francesco Madonna a [posté][francesco post]
  sur Delving Bitcoin à propos d'un concept qui est un modèle de coffre-fort sans covenant utilisant
  [taproot][topic taproot], [`OP_CHECKSEQUENCEVERIFY`][op_csv], et
  [`OP_CHECKLOCKTIMEVERIFY`][op_cltv]. Dans le post, il mentionne qu'il utilise des primitives Bitcoin
  existantes, ce qui est important car la plupart des propositions de coffre-fort nécessitent un soft
  fork.

  Dans la conception, il y a trois chemins de dépense différents :

  1. Un chemin rapide pour le fonctionnement normal où un Service de Commodité (CS) optionnel peut
  faire respecter le délai choisi.

  2. Un retour d'un an avec le gardien B.

  3. Un chemin de gardien de trois ans en cas de disparition ou d'événements d'héritage.

  Il y a 6 clés différentes A, A₁, B, B₁, C et CS où B₁, et C sont détenues en garde et sont utilisées
  uniquement en même temps dans le chemin de récupération.

  Cette configuration crée un environnement où l'utilisateur peut verrouiller ses fonds et être assez
  sûr que les gardiens auxquels il a confié ses fonds ne voleront pas. Bien que cela ne restreigne pas
  où les fonds peuvent se déplacer comme le ferait un [covenant][topic covenants], cette configuration
  offre un schéma plus résilient pour l'auto-garde avec des gardiens. Dans le post, Francesco appelle
  les lecteurs à examiner et discuter du [livre blanc][bssl whitepaper] avant que quiconque essaie de
  mettre en œuvre cette idée.

## Mises à jour et versions candidates

_Nouvelles versions et versions candidates pour des projets d'infrastructure Bitcoin populaires.
Veuillez envisager de mettre à niveau vers les nouvelles versions ou d'aider à tester les versions candidates._

- [Bitcoin Core 30.0][] est la dernière version du nœud complet prédominant du réseau. Ses [notes de
  version][notes30] décrivent plusieurs améliorations significatives, y compris un nouveau plafond de
  2500 sigops legacy dans les transactions standard, plusieurs sorties de porteur de données
  (OP_RETURN) désormais standard, une `datacarriersize` par défaut augmentée à 100 000, un
  [taux de frais minimum de relais][topic default minimum transaction relay feerates] par défaut
  et un taux de frais de relais incrémental de 0.1sat/vb, un taux de frais minimum de bloc par défaut
  de 0.001sat/vb, des protections améliorées contre les attaques DoS par orphelinage de transactions,
  un nouvel outil CLI `bitcoin`, une interface de communication inter-processus (IPC) expérimentale
  pour les intégrations de [Stratum v2][topic pooled mining], une nouvelle implémentation de
  `coinstatsindex`, l'option `natpmp` désormais activée par défaut, le support pour les portefeuilles
  hérités étant retiré au profit des portefeuilles [descriptor][topic descriptors], et le support
  pour dépenser et créer des transactions [TRUC][topic v3 transaction relay], parmi de nombreuses
  autres mises à jour.

- [Bitcoin Core 29.2][] est une version mineure contenant plusieurs corrections de bugs pour P2P,
  mempool, RPC, CI, documentation et d'autres problèmes. Veuillez consulter les [notes de
  version][notes29.2] pour plus de détails.

- [LDK 0.1.6][] est une version de cette bibliothèque populaire pour la construction d'applications
  compatibles LN qui inclut des correctifs de vulnérabilités de sécurité liées aux DoS et au vol de
  fonds, des améliorations de performance, et plusieurs corrections de bugs.

## Changements notables dans le code et la documentation

_Changements notables récents dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning
repo], [Eclair][eclair repo], [LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo],
[Hardware Wallet Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Propositions d'Amélioration de Bitcoin (BIPs)][bips
repo], [Lightning BOLTs][bolts repo], [Lightning BLIPs][blips repo], [Inquisition Bitcoin][bitcoin
inquisition repo], et [BINANAs][binana repo]._

- [Eclair #3184][] améliore le flux de fermeture coopérative en renvoyant un message `shutdown` lors
  de la reconnexion quand un avait déjà été envoyé avant la déconnexion, comme spécifié dans
  [BOLT2][]. Pour les [canaux simple taproot][topic simple taproot channels], Eclair génère un nouveau
  nonce de fermeture pour le renvoi et le stocke, permettant au nœud de produire une `closing_sig`
  valide plus tard.

- [Core Lightning #8597][] empêche un crash qui se produisait lorsqu'un pair direct renvoyait une
  réponse `failmsg` après que CLN a envoyé un [message onion][topic onion messages] malformé via
  `sendonion` ou `injectpaymentonion`. Désormais, CLN traite cela comme un échec de premier saut
  simple et retourne une erreur propre au lieu de planter. Auparavant, cela était traité comme un
  `failonion` crypté venant de plus loin en aval.

- [LDK #4117][] introduit une dérivation déterministe et facultative de la `remote_key` qui utilise
  la `static_remote_key`. Cela permet aux utilisateurs de récupérer des fonds en cas de fermeture
  forcée en utilisant uniquement la phrase de sauvegarde. Auparavant, la `remote_key` dépendait de
  l'aléatoire spécifique à chaque canal, nécessitant l'état du canal pour récupérer les fonds. Ce
  nouveau schéma est facultatif pour les nouveaux canaux, mais s'applique automatiquement lors du
  [splicing][topicsplicing] des existants.

- [LDK #4077][] ajoute les événements `SplicePending` et `SpliceFailed`, le premier étant émis une
  fois qu'une transaction de financement [splice][topic splicing] est négociée, diffusée et
  verrouillée par les deux parties (sauf dans le cas d'un [RBF][topic rbf]). Le dernier événement est
  émis lorsque un splice avorte avant le verrouillage en raison d'un échec `interactive-tx`, d'un
  message `tx_abort`, d'une fermeture de canal, ou d'une déconnexion/rechargement pendant un état
  [quiescent][topic channel commitment upgrades].

- [LDK #4154][] met à jour la gestion de la surveillance on-chain de preimage pour s'assurer que les
  transactions de réclamation sont uniquement créées pour les [HTLCs][topic htlc] dont le hash de
  paiement correspond au preimage récupéré. Auparavant, LDK tentait de réclamer tout HTLC réclamable
  (ceux expirés et ceux avec un preimage connu), ce qui risquait de créer des transactions de
  réclamation invalides et une perte potentielle de fonds si la contrepartie expirait un autre HTLC en
  premier.

{% include snippets/recap-ad.md when="2025-10-21 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="3184,8597,4117,4077,4154" %}
[francesco post]: https://delvingbitcoin.org/t/concept-review-b-ssl-bitcoin-secure-signing-layer-covenant-free-vault-model-using-taproot-csv-and-cltv/2047
[op_cltv]: https://github.com/bitcoin/bips/blob/master/bip-0065.mediawiki
[op_csv]: https://github.com/bitcoin/bips/blob/master/bip-0112.mediawiki
[bssl whitepaper]: https://github.com/ilghan/bssl-whitepaper/blob/main/B-SSL_WP_Oct_11_2025.pdf
[towns tempshare]: https://delvingbitcoin.org/t/sharing-block-templates/1906/13
[news366 block template sharing]: /fr/newsletters/2025/08/08/#partage-de-modele-de-bloc-entre-pairs-pour-attenuer-les-problemes-lies-aux-politiques-de-mempool-divergentes
[binana repo]: https://github.com/bitcoin-inquisition/binana
[bin]: https://github.com/bitcoin-inquisition/binana/blob/master/2025/BIN-2025-0002.md
[news368 bts]: /fr/newsletters/2025/08/22/#projet-de-bip-pour-le-partage-de-modeles-de-bloc
[Bitcoin Core 30.0]: https://bitcoincore.org/bin/bitcoin-core-30.0/
[notes30]: https://bitcoincore.org/en/releases/30.0/
[Bitcoin Core 29.2]: https://bitcoincore.org/bin/bitcoin-core-29.2/
[notes29.2]: https://bitcoincore.org/en/releases/29.2/
[LDK 0.1.6]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.1.6