---
title: 'Bulletin Hebdomadaire Bitcoin Optech #404'
permalink: /fr/newsletters/2026/05/08/
name: 2026-05-08-newsletter-fr
slug: 2026-05-08-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine décrit des solutions possibles au fingerprinting des nœuds et renvoie à une discussion sur l'utilisation de
preuves publiques de fraude pour améliorer les incitations autour des canaux just-in-time. Sont également incluses nos sections régulières
décrivant les changements notables dans les logiciels d'infrastructure Bitcoin populaires.

## Nouvelles

- **Solutions possibles au fingerprinting des nœuds** : Naiyoma a [publié][fing del] sur Delving Bitcoin à propos de solutions possibles au
  problème de fingerprinting des nœuds qui utilise l'horodatage du message `addr` pour identifier le même nœud sur plusieurs réseaux (voir
  le [Bulletin #360][news360 fing]).

  Depuis la dernière mise à jour, les chercheurs ont pu recueillir davantage d'informations sur le problème et identifier de nouveaux
  facteurs à prendre en compte. L'un des principaux constats concernait l'`AddrMan`, la structure de code qui gère les adresses. `AddrMan`
  considère les adresses comme périmées si leur horodatage est plus ancien que 30 jours, généralement parce qu'un pair est hors ligne.
  Ainsi, il y a deux facteurs importants qu'une atténuation possible doit prendre en compte : rafraîchir les anciens horodatages vers des
  valeurs plus récentes peut faire en sorte que d'anciennes adresses continuent d'être propagées, et les rendre plus anciens peut les amener
  à cesser d'être propagées prématurément. Ces considérations ont conduit à écarter certaines solutions précédemment envisagées et à en
  proposer de nouvelles :

  1. **Brouillage simple** : appliquer une distorsion aléatoire à l'horodatage de l'adresse dans une plage de `[-5, +5] jours`. Cependant,
    la distorsion peut se moyenner avec le temps.

  2. **Horodatages fixes entre réseaux** : lors de la réponse à une requête, l'horodatage réel est préservé pour le réseau spécifique,
    tandis que sur les autres, les horodatages sont fixés à une valeur aléatoire dans le passé. Cependant, d'anciennes adresses pourraient
    rester en circulation plus longtemps que nécessaire.

  3. **Brouillage - adresses seulement plus anciennes** : rendre les adresses seulement plus anciennes, jamais plus récentes, en appliquant
    une distorsion aléatoire dans la plage `[1, 10] jours`. Cependant, les adresses peuvent atteindre le seuil des 30 jours trop rapidement.

  4. **Brouillage - bruit d'horodatage biaisé vers le vieillissement** : appliquer une distorsion aléatoire dans la plage `[-1, +5] jours`,
    de manière à rendre les adresses principalement plus anciennes, avec seulement une faible chance de devenir plus récentes. Cependant,
    les anciennes adresses pourraient rester en circulation plus longtemps que nécessaire.

  5. **Approche hybride** : l'option finale consiste à combiner ensemble deux des approches précédentes.

  Naiyoma a demandé des retours sur son travail aux autres développeurs intéressés, et a partagé sa [PR][fing gh] dans laquelle elle teste
  la solution 2.

- **Preuve publique de fraude pour les canaux just-in-time** : Thomas Voegtlin a [publié][jit del] sur Delving Bitcoin à propos d'une
  nouvelle proposition visant à améliorer la théorie des jeux derrière les [canaux just-in-time (JIT)][topic jit channels] en utilisant des
  preuves publiques de fraude pour démontrer qu'un LSP se comporte mal.

  Alice négocie l'ouverture d'un canal JIT avec un LSP, Bob. Quand Alice a besoin de recevoir des sats de Carol, elle crée une préimage.
  Carol envoie un [HTLC][topic htlc] à Bob. Alice révèle la préimage à Bob, en s'attendant à ce que le LSP diffuse la transaction de
  financement du canal. Que se passe-t-il si Bob réclame le HTLC sans ouvrir le canal avec Alice ?

  Voegtlin propose d'utiliser la chaîne comme couche d'arbitrage publique. Alice devrait publier la préimage en utilisant un `OP_RETURN`,
  afin que la divulgation puisse être vérifiée par n'importe qui et datée à une certaine hauteur de bloc. De son côté, Bob crée un
  engagement d'UTXO valable jusqu'à un nombre de blocs `n`. S'il dépense les mêmes UTXOs dans une transaction différente de celle à laquelle
  il s'est engagé, ne diffuse pas la transaction de financement, ou tente de la dépenser en double, il créerait une preuve de fraude,
  nuisant à sa réputation en tant que LSP sans obliger les autres clients à faire confiance à Alice.

  Voegtlin a fourni l'[article][jit paper gist] complet contenant l'explication détaillée, et a invité d'autres développeurs à donner leur
  avis sur la proposition.

## Changements notables dans le code et la documentation

_Changements récents notables dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning repo], [Eclair][eclair repo],
[LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet Interface (HWI)][hwi repo], [Rust Bitcoin][rust
bitcoin repo], [BTCPay Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement Proposals (BIPs)][bips repo], [Lightning
BOLTs][bolts repo], [Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition repo], et [BINANAs][binana repo]._

- [Bitcoin Core #33796][] ajoute `btck_check_transaction()` à l'API C de `libbitcoinkernel` (voir le [Bulletin #380][news380 kernel]) pour
  exécuter des vérifications de structure d'une transaction au niveau du consensus et sans contexte. Cela inclut le rejet des listes
  d'entrées ou de sorties vides, des longueurs de scriptSig coinbase invalides, des entrées dupliquées, des prevouts nuls dans les
  transactions non-coinbase, et des valeurs de sortie en dehors de la plage monétaire valide, sans nécessiter chainstate, l'ensemble d'UTXO,
  ou la vérification de script.

- [Bitcoin Core #21283][] implémente la prise en charge de [BIP370][] et de [PSBTv2][topic psbt], tout en maintenant la rétrocompatibilité
  avec PSBTv0. PSBTv2 stocke les données de construction de transaction, telles que la version, le locktime, les entrées, les sorties et la
  modifiabilité de la transaction, directement dans les champs PSBT, au lieu d'exiger une transaction non signée complète.

- [BIPs #2150][] ajoute [BIP451][], une spécification pour un Dust UTXO Disposal Protocol, qui définit une norme permettant aux
  portefeuilles de se débarrasser en toute sécurité des UTXOs [dust][topic uneconomical outputs] indésirables en les dépensant vers une
  unique sortie `OP_RETURN` de valeur nulle, avec la totalité de la valeur d'entrée payée en frais de transaction. Le protocole inclut des
  règles de construction préservant la vie privée, telles que l'élimination par adresse des UTXOs dust confirmés, et des signatures
  `ALL|ANYONECANPAY` qui permettent à des transactions non liées d'élimination de dust trouvées dans la mempool d'être regroupées via le
  [RBF][topic rbf].

- [Eclair #3144][] met à jour les [canaux taproot simples][topic simple taproot channels] pour utiliser le bit de fonctionnalité officiel et
  les active par défaut, sans prendre encore en charge l'annonce de ces canaux. Des vecteurs de test sont ajoutés pour s'aligner sur la
  spécification des BOLTs et l'implémentation de LND (voir le [Bulletin
  #401][news401 lnd]).

- [Eclair #2887][] ajoute la prise en charge du protocole officiel de [splicing][topic splicing] fusionné dans la spécification des BOLTs
  (voir le [Bulletin #398][news398 splicing]), tout en maintenant la rétrocompatibilité avec l'ancienne implémentation expérimentale du
  splicing d'Eclair.

- [LDK #4592][] commence à vérifier si un nœud dispose de réserves suffisantes avant d'ouvrir de nouveaux canaux à [engagement sans
  frais][topic v3 commitments] (0FC) en les comptant comme des canaux [anchor][topic anchor outputs]. Auparavant, la vérification des
  réserves de LDK ne comptait que les canaux utilisant l'ancienne fonctionnalité `anchors_zero_fee_htlc_tx`, permettant à un nœud d'ouvrir
  plus de canaux 0FC que son portefeuille ne pouvait raisonnablement augmenter en frais lors de fermetures forcées simultanées.

- [LND #9153][] ajoute un champ `source_pub_key` au message proto `Route` afin de construire et désérialiser des routes du point de vue d'un
  nœud autre que le nœud local. Si aucune source n'est fournie, LND continue d'utiliser le nœud local comme auparavant.

- [Rust Bitcoin #5835][] ajoute un constructeur pour `V1MessageHeader` qui calcule la somme de contrôle de quatre octets de la charge utile
  utilisée dans l'en-tête des messages P2P de Bitcoin. Cela simplifie la construction de messages réseau en permettant aux appelants de
  construire l'en-tête pour une charge utile sérialisée et une commande avant d'envoyer le message sur le réseau.

- [BOLTs #995][] ajoute une extension BOLT pour les [canaux taproot simples][topic simple taproot channels], attribuant les bits de
  fonctionnalité 80/81. La spécification définit un type minimal de canal basé sur [taproot][topic taproot] qui utilise une sortie de
  financement P2TR avec agrégation de clés [MuSig2][topic musig], des scripts d'engagement et de HTLC taproot, ainsi que de nouveaux champs
  TLV pour échanger des signatures partielles et des nonces MuSig2 pendant l'ouverture du canal, les mises à jour d'engagement, les
  fermetures coopératives et la reconnexion. Les champs de nonce dans `revoke_and_ack` et `channel_reestablish` sont indexés par le txid de
  financement afin de prendre en charge plusieurs transactions d'engagement actives, comme pendant le [splicing][topic splicing].
  L'extension exclut intentionnellement les changements de gossip, de sorte que les [canaux taproot annoncés][topic channel announcements]
  restent un travail futur.

- [BOLTs #1228][] spécifie les canaux à [engagement sans frais][topic v3 commitments] (0FC) et attribue les bits de fonctionnalité 40/41.
  Pour ce type de canal, `feerate_per_kw` est défini à 0, les transactions d'engagement et de [HTLC][topic htlc] utilisent le [relay de
  transaction v3][topic v3 transaction relay] (TRUC), et les frais de minage sont fournis par des transactions enfants utilisant
  [CPFP][topic cpfp]. Les transactions d'engagement incluent une sortie partagée [pay-to-anchor (P2A)][topic ephemeral anchors] financée à
  partir des sorties élaguées et des millisatoshis arrondis à l'inférieur, plafonnée à 240 sats, permettant à la transaction d'engagement
  parente de ne payer aucun frais direct dans la plupart des cas. La spécification limite également le nombre maximal de HTLCs à 114 pour ce
  type de canal en raison de la limite de taille de transaction TRUC de 10 kvB.

- [BOLTs #1327][] met à jour la règle d'augmentation de feerate du [RBF][topic rbf] pour garantir la conformité avec les règles de
  remplacement de [BIP125][] aux faibles feerates. Au lieu d'appliquer seulement le multiplicateur de feerate 25/24 existant, la
  spécification exige désormais que le feerate de remplacement augmente de la plus grande de deux valeurs : le multiplicateur ou 25 sat/kw
  supplémentaires. Cela correspond au comportement de LDK couvert dans le [Bulletin #400][news400 rbf].

{% include snippets/recap-ad.md when="2026-05-12 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="33796,21283,2150,3144,2887,4592,9153,5835,995,1228,1327" %}
[fing del]: https://delvingbitcoin.org/t/fingerprinting-nodes-possible-solutions/2466
[news360 fing]: /fr/newsletters/2025/06/27/#identification-des-noeuds-utilisant-les-messages-addr
[fing gh]: https://github.com/naiyoma/bitcoin/pull/16
[jit del]: https://delvingbitcoin.org/t/proposal-public-fraud-proofs-for-just-in-time-channels/2451
[jit paper gist]: https://gist.github.com/ecdsa/dfa2d76a5fe845fd283c01b5ed12d274
[news380 kernel]: /fr/newsletters/2025/11/14/#bitcoin-core-30595
[news398 splicing]: /fr/newsletters/2026/03/27/#bolts-1160
[news400 rbf]: /fr/newsletters/2026/04/10/#ldk-4494
[news401 lnd]: /fr/newsletters/2026/04/17/#lnd-9985
