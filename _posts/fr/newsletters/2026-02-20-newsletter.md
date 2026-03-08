---
title: 'Bulletin Hebdomadaire Bitcoin Optech #393'
permalink: /fr/newsletters/2026/02/20/
name: 2026-02-20-newsletter-fr
slug: 2026-02-20-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
La newsletter de cette semaine résume une discussion sur l'utilisation récente de OP_RETURN et
décrit un protocole pour faire respecter des conditions de dépense similaires à des covenants sans
changement de consensus.
Sont également incluses nos sections régulières résumant les changements récents apportés aux clients
et services, les annonces de nouvelles versions et de candidats à la publication, et les résumés des
modifications notables apportées aux logiciels d'infrastructure Bitcoin populaires.

## Nouvelles

- **Statistiques récentes sur les sorties OP_RETURN** : Anthony Towns a posté sur
  [Delving][post op_return stats] à propos des statistiques récentes de OP_RETURN depuis
  la sortie de Bitcoin Core v30.0 le 10 octobre, qui comprenait des changements dans
  les limites de politique de mempool pour les sorties OP_RETURN (permettant plusieurs sorties OP_RETURN
  et autorisant jusqu'à 100kB de données dans les sorties OP_RETURN). La plage de
  blocs examinée était de hauteur 915800 à 936000, avec les résultats suivants :

  - 24 362 310 tx avec des sorties OP_RETURN

  - 61 tx avec plusieurs sorties OP_RETURN

  - 396 tx avec des tailles totales de script de sortie OP_RETURN supérieures à 83 octets

  - Le total des données de script de sortie OP_RETURN sur la période était de 473 815 552 octets (dont les grands OP_RETURNS représentaient 0,44 %)

  - Il y a 34 283 tx brûlant des sats dans des sorties OP_RETURN, pour un total de
    1 463 488 sats brûlés

  - Il y a 949 003 tx avec entre 43 et 83 octets de données OP_RETURN, et
    23 412 911 tx avec des données OP_RETURN de 42 octets ou moins

  Towns a également inclus un graphique montrant la fréquence des tailles pour les 396
  transactions avec de grandes sorties OP_RETURN. 50 % de ces transactions avaient moins
  de 210 octets de données OP_RETURN. De plus, 10 % avaient plus de 10 Ko de données OP_RETURN.

  Il a ajouté plus tard que Murch avait ensuite publié une [analyse similaire][murch twitter] sur
  X et un [tableau de bord][murch dashboard] des statistiques OP_RETURN, et que orangesurf a publié un [rapport][orangesurf report] sur
  OP_RETURN pour la recherche sur le mempool.

- **Bitcoin PIPEs v2** : Misha Komarov a [posté][pipes del] sur Delving Bitcoin
  à propos de Bitcoin PIPEs, un protocole qui permet de faire respecter des conditions de dépense
  sans nécessiter de changements de consensus ou de mécanismes de défi optimistes.

  Le protocole Bitcoin est basé sur un modèle de validation de transaction minimal, qui
  consiste à vérifier qu'un UTXO dépensé est autorisé par une signature numérique valide. Ainsi,
  au lieu de s'appuyer sur des conditions de dépense exprimées par Bitcoin
  Script, Bitcoin PIPEs ajoute des prérequis sur la possibilité de produire ou non une signature valide.
  En d'autres termes, une clé privée est cryptographiquement verrouillée derrière une
  condition prédéterminée. Si et seulement si la condition est remplie, la clé privée
  est révélée, permettant une signature valide. Alors que le protocole Bitcoin
  n'a qu'à valider une seule [signature schnorr][topic schnorr signatures],
  toute la logique conditionnelle est traitée hors chaîne.

  Formellement, Bitcoin PIPEs consiste en deux phases principales :
  - *Configuration* : Un couple de clés Bitcoin standard `(sk, pk)` est généré. `sk` est ensuite chiffré derrière
    une déclaration de condition de dépense utilisant le chiffrement par témoin.

  - *Signature* : Un témoin `w` est fourni pour la déclaration. Si `w` est valide, `sk` est révélé et une signature schnorr
    peut être produite. Sinon, récupérer `sk` devient computationnellement infaisable.

  Selon Komarov, les PIPEs Bitcoin peuvent être utilisés pour reproduire la sémantique des [covenants][topic covenants].
  En particulier, [Bitcoin PIPEs v2][pipes v2 paper] se concentre sur un ensemble limité de conditions de dépense,
  imposant des covenants binaires. Ce modèle capture naturellement une large gamme de conditions utiles dont les résultats
  sont binaires, tels que fournir une preuve zk valide, satisfaire une condition de sortie, ou l'existence d'une preuve de fraude.
  En gros, tout se résume à une seule question : "La condition est-elle satisfaite ou non ?".

  Enfin, Komarov a fourni des exemples réels de la manière dont les PIPEs pourraient être utilisés à la place de nouveaux opcodes,
  et comment ils pourraient être utilisés pour améliorer le flux de vérification optimiste du protocole [BitVM][topic acc].

### Changements dans les services et logiciels clients

*Dans cette rubrique mensuelle, nous mettons en lumière des mises à jour intéressantes des
portefeuilles et services Bitcoin.*

- **Second lance la version hArk-based du logiciel Ark :**
  Les bibliothèques [Ark][topic ark] de Second ont été mises à jour pour utiliser hArk, hash-lock Ark,
  dans la version [0.1.0-beta.6][second 0.1.0 beta6]. Le nouveau protocole élimine le besoin d'interactivité synchrone
  pour les utilisateurs pendant les tours, avec son propre ensemble de compromis. La version inclut diverses autres
  mises à jour, y compris des changements majeurs.

- **Amboss annonce RailsX :**
  L'[annonce de RailsX][amboss blog] décrit une plateforme utilisant LN et [Taproot Assets][topic client-side validation]
  pour soutenir les échanges et divers autres services financiers.

- **Nunchuk ajoute le support des paiements silencieux :**
  Nunchuk [a annoncé][nunchuk post] le support pour l'envoi à des adresses de [paiement silencieux][topic silent payments].

- **Electrum ajoute des fonctionnalités de swaps sous-marins :**
  [Electrum 4.7.0][electrum release notes] permet aux utilisateurs de payer onchain en utilisant leur solde Lightning
  (voir [submarine swaps][topic submarine swaps]), parmi d'autres fonctionnalités et corrections.

- **Annonce de Sigbash v2 :**
  [Sigbash v2][sigbash post] utilise désormais [MuSig2][topic musig], WebAssembly (WASM) et des preuves à connaissance nulle
  pour obtenir une meilleure confidentialité du service de cosignature. Voir notre [couverture précédente][news298 sigbash]
  sur Sigbash pour plus de détails.

## Mises à jour et versions candidates

_Nouvelles versions et versions candidates pour des projets d'infrastructure Bitcoin populaires.
Veuillez envisager de mettre à niveau vers les nouvelles versions ou d'aider à tester les versions candidates._

- [BTCPay Server 2.3.5][] est une version mineure de cette solution de paiement auto-hébergée qui ajoute des widgets
  de solde de portefeuille multi-crypto sur le tableau de bord, une zone de texte personnalisée pour le paiement,
  de nouveaux fournisseurs de taux de change, et comprend plusieurs corrections de bugs.

- [LND 0.20.1-beta][] est une version de maintenance de cette implémentation populaire de nœud LN, qui ajoute une récupération
  d'urgence pour le traitement des messages de gossip, améliore la protection contre les réorganisations, implémente
  des heuristiques de détection LSP, et corrige de multiples bugs et conditions de concurrence.

## Changements notables dans le code et la documentation

_Changements notables récents dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning repo], [Eclair][eclair repo],
[LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Interface de Portefeuille Matériel (HWI)][hwi repo],
[Rust Bitcoin][rust bitcoin repo], [Serveur BTCPay][btcpay server repo], [BDK][bdk repo], [Propositions d'Amélioration de Bitcoin (BIPs)][bips repo],
[Lightning BOLTs][bolts repo], [Lightning BLIPs][blips repo], [Inquisition Bitcoin][bitcoin inquisition repo], et [BINANAs][binana repo]._

- [Bitcoin Core #33965][] corrige un bug où la configuration de démarrage `-blockreservedweight` (voir le [Bulletin #342][news342 weight])
  pouvait silencieusement remplacer la valeur `block_reserved_weight` définie par les clients de l'IPC minier (voir le [Bulletin #310][news310 mining]).
  Maintenant, lorsque un appelant IPC définit cette dernière, elle prend la priorité. Pour les appelants RPC qui n'ont jamais défini cette valeur,
  la configuration de démarrage `-blockreservedweight` prend toujours effet. Ce PR applique également le `MINIMUM_BLOCK_RESERVED_WEIGHT`
  pour les appelants IPC, les empêchant de définir une valeur en dessous de celle-ci.

- [Eclair #3248][] commence à prioriser les canaux privés par rapport aux canaux publics lors de la transmission des [HTLCs][topic htlc],
  si les deux options sont disponibles. Cela maintient plus de liquidité disponible dans les canaux publics, qui sont visibles par le réseau.
  Lorsque deux canaux ont la même visibilité, Eclair priorise maintenant le canal avec le solde le plus petit.

- [Eclair #3246][] ajoute de nouveaux champs à plusieurs événements internes : `TransactionPublished` divise le champ unique `miningFee`
  en `localMiningFee` et `remoteMiningFee`, ajoute un `feerate` calculé et une `LiquidityAds.PurchaseBasicInfo` optionnelle
  liant la transaction à un [achat de liquidité][topic liquidity advertisements]. Les événements du cycle de vie du canal incluent
  maintenant le `commitmentFormat` pour décrire le type de canal, et `PaymentRelayed` ajoute un champ `relayFee`.

- [LDK #4335][] ajoute un support initial pour les paiements vers des nœuds fantômes (voir le [Bulletin #188][news188 phantom])
  en utilisant les [offres BOLT12][topic offers]. Dans la version [BOLT11][], les factures incluaient des indices de route
  pointant vers un nœud "fantôme" inexistant, chaque chemin ayant pour dernier saut un vrai nœud qui pouvait accepter le paiement
  en utilisant des [factures sans état][topic stateless invoices]. Dans [BOLT12][], l'offre inclut simplement plusieurs
  [chemins aveuglés][topic rv routing] se terminant à chaque nœud participant. L'implémentation actuelle permet à plusieurs nœuds
  de répondre à la demande de facture, bien que la facture résultante ne puisse être payée qu'au nœud répondant.

- [LDK #4318][] supprime le champ `max_funding_satoshis` de la structure `ChannelHandshakeLimits`, éliminant ainsi effectivement
  la limite de taille de canal par défaut pré-[wumbo][topic large channels]. LDK annonçait déjà le support pour les [canaux larges][topic large channels]
  via le drapeau de fonctionnalité `option_support_large_channels` par défaut, ce qui aurait pu signaler incorrectement le support
  aux pairs en conflit avec le paramètre précédent. Les utilisateurs souhaitant limiter les risques peuvent utiliser le flux d'acceptation
  de canal manuel.

- [LND #10542][] étend la couche de base de données graphique pour supporter gossip v1.75 (voir les Bulletins [#261][news261 gossip]
  et [#326][news326 gossip]). LND peut maintenant stocker et récupérer [les annonces de canal][topic channel announcements]
  pour [canaux taproot simples][topic simple taproot channels]. Gossip v1.75 reste désactivé au niveau du réseau, en attendant
  la complétion des sous-systèmes de validation et de gossip.

- [BIPs #1670][] publie [BIP360][], qui spécifie Pay-to-Merkle-Root (P2MR), un nouveau type de sortie qui fonctionne comme [P2TR][topic taproot]
  mais sans la dépense par chemin de clé. Les sorties P2MR sont résistantes aux attaques par exposition prolongée par des ordinateurs quantiques
  cryptographiquement pertinents (CRQCs) car elles s'engagent directement sur la racine de Merkle de l'arbre de script, un hash SHA256,
  plutôt que sur une clé publique. Cependant, la protection contre les attaques par exposition courte, telles que la récupération de clé privée
  pendant qu'une transaction est non confirmée, nécessite une proposition de signature [post-quantique][topic quantum resistance] séparée.
  Voir le [Bulletin #344][news344 p2qrh] pour une couverture antérieure lorsque la proposition était connue sous le nom de P2QRH
  et le [Bulletin #385][news385 bip360] lorsque la proposition était connue sous le nom de P2TSH.

- [BOLTs #1236][] met à jour la spécification de [financement double][topic dual funding] pour permettre à l'un ou l'autre nœud
  d'envoyer `tx_init_rbf` pendant l'établissement du canal, permettant ainsi aux deux parties d'[augmenter les frais][topic rbf]
  de la transaction de financement. Auparavant, seul l'initiateur du canal pouvait le faire. Ce changement aligne le financement double
  avec [l'épissage][topic splicing], où chaque côté pouvait déjà initier un RBF. La PR ajoute également une exigence que les expéditeurs
  de `tx_init_rbf` et `tx_ack_rbf` doivent réutiliser au moins une entrée d'une tentative précédente, assurant que la nouvelle transaction
  annule toutes les tentatives antérieures.

- [BOLTs #1289][] change la manière dont `commitment_signed` est retransmis pendant la reconnexion dans le protocole de transaction interactif
  utilisé à la fois par [le financement double][topic dual funding] et [l'épissage][topic splicing]. Auparavant, `commitment_signed` était
  toujours retransmis lors de la reconnexion, même si le pair l'avait déjà reçue. Désormais, `channel_reestablish` inclut un champ de bits explicite
  qui permet à un nœud de demander `commitment_signed` uniquement s'il en a encore besoin. Cela évite une retransmission inutile,
  ce qui est particulièrement important pour les futurs [canaux simple taproot][topic simple taproot channels] où retransmettre nécessiterait
  un tour complet de signature [MuSig2][topic musig] en raison des changements de nonce.

% include snippets/recap-ad.md when="2026-02-24 17:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="33965,3248,3246,4335,4318,10542,1670,1236,1289" %}

[post op_return stats]: https://delvingbitcoin.org/t/recent-op-return-output-statistics/2248
[pipes del]: https://delvingbitcoin.org/t/bitcoin-pipes-v2/2249
[pipes v2 paper]: https://eprint.iacr.org/2026/186
[second 0.1.0 beta6]: https://docs.second.tech/changelog/changelog/#010-beta6
[amboss blog]: https://amboss.tech/blog/railsx-first-lightning-native-dex
[nunchuk post]: https://x.com/nunchuk_io/status/2021588854969414119
[electrum release notes]: https://github.com/spesmilo/electrum/blob/master/RELEASE-NOTES
[news298 sigbash]: /en/newsletters/2024/04/17/#key-agent-sigbash-launches
[sigbash post]: https://x.com/arbedout/status/2020885323778044259
[BTCPay Server 2.3.5]: https://github.com/btcpayserver/btcpayserver/releases/tag/v2.3.5
[LND 0.20.1-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.20.1-beta
[news342 weight]: /en/newsletters/2025/02/21/#bitcoin-core-31384
[news310 mining]: /en/newsletters/2024/07/05/#bitcoin-core-30200
[news188 phantom]: /en/newsletters/2022/02/23/#ldk-1199
[news261 gossip]: /en/newsletters/2023/07/26/#updated-channel-announcements
[news326 gossip]: /en/newsletters/2024/10/25/#updates-to-the-version-1-75-channel-announcements-proposal
[news344 p2qrh]: /en/newsletters/2025/03/07/#update-on-bip360-pay-to-quantum-resistant-hash-p2qrh
[news385 bip360]: /en/newsletters/2025/12/19/#quantum
[murch dashboard]: https://dune.com/murchandamus/opreturn-counts
[murch twitter]: https://x.com/murchandamus/status/2022930707820269670
[orangesurf report]: https://research.mempool.space/opreturn-report/
