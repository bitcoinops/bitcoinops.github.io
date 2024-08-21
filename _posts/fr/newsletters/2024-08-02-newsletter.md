---
title: 'Bulletin Hebdomadaire Bitcoin Optech #314'
permalink: /fr/newsletters/2024/08/02/
name: 2024-08-02-newsletter-fr
slug: 2024-08-02-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine annonce la divulgation de deux vulnérabilités affectant les anciennes
versions de Bitcoin Core et résume une approche proposée pour optimiser la sélection des
transactions par les mineurs lorsque le cluster de mempool est utilisé. Sont également incluses nos sections habituelles avec
des annonces de mises à jour et versions candidates, ainsi que les changements
apportés aux principaux logiciels d'infrastructure Bitcoin.

## Nouvelles

- **Divulgation de vulnérabilités affectant les versions de Bitcoin Core antérieures à 0.21.0 :**
  Niklas Gögge a [publié][goegge disclosure] sur la liste de diffusion Bitcoin-Dev un lien vers les
  annonces de
  deux vulnérabilités affectant des versions de Bitcoin Core qui sont
  dépassées depuis au moins octobre 2022. Cela fait suite à une
  divulgation précédente le mois dernier de vulnérabilités plus anciennes (voir le
  [Bulletin #310][news310 disclosure]). Nous résumons ci-dessous les divulgations :

  - [Crash à distance en envoyant des messages `addr` excessifs][] : avant
    Bitcoin Core 22.0 (sorti en septembre 2021), un nœud qui était informé de
    plus de 2<sup>32</sup> autres nœuds possibles se crasherait en raison de
    l'épuisement d'un compteur 32 bits. Cela pourrait être accompli par un
    attaquant envoyant un grand nombre de messages P2P `addr` (au moins 4
    millions de messages). Eugene Siegel a [divulgué de manière responsable][topic responsible
    disclosures]
    la vulnérabilité et un correctif a été inclus dans Bitcoin Core 22.0. Voir le
    [Bulletin #159][news159 bcc22387] pour notre résumé du correctif,
    qui a été écrit sans savoir qu'il corrigeait une
    vulnérabilité.

  - [Crash à distance sur le réseau local lorsque UPnP est activé][] : avant Bitcoin Core
    22.0, les nœuds qui activaient [UPnP][] pour configurer automatiquement [NAT
    traversal][] (désactivé par défaut en raison de vulnérabilités précédentes,
    voir le [Bulletin #310][news310 miniupnpc]) étaient vulnérables à un
    dispositif malveillant sur le réseau local envoyant à plusieurs reprises des variantes
    d'un message UPnP. Chaque message pourrait entraîner l'allocation de
    mémoire supplémentaire jusqu'à ce que le nœud se crashe ou soit arrêté par le
    système d'exploitation. Un bug de boucle infinie dans la dépendance de Bitcoin Core
    miniupnpc a été signalé au projet miniupnpc par Ronald Huveneers,
    avec Michael Ford découvrant et divulguant de manière responsable comment il
    pourrait être utilisé pour crasher Bitcoin Core. Un correctif a été inclus dans Bitcoin
    Core 22.0.

  Des vulnérabilités supplémentaires affectant les versions ultérieures de Bitcoin Core
  devraient être divulguées dans quelques semaines.

- **Optimisation de la construction de blocs avec le cluster de mempool :** Pieter Wuille
    a [posté][wuille selection] sur Delving Bitcoin concernant l'assurance que
    les modèles de blocs des mineurs peuvent inclure le meilleur ensemble de transactions lorsque
    le [cluster de mempool][topic cluster mempool] est utilisé. Dans la conception pour
    le cluster de mempool, les _clusters_ de transactions liées sont divisés en
    une liste ordonnée de _morceaux_, chaque morceau respectant deux contraintes :

  1. Si des transactions au sein du segment dépendent d’autres transactions non confirmées,
     ces autres transactions doivent soit faire partie de ce segment,
     soit apparaître dans un segment antérieur dans la liste ordonnée des segments.

  3. Chaque segment doit avoir un taux de frais égal ou supérieur à celui des segments
     qui le suivent dans la liste ordonnée.

  Cela permet de placer chaque segment de chaque cluster dans le mempool dans une seule liste, classée
  par taux de frais---du plus élevé au plus bas. Avec un mempool segmenté classé par taux de frais, un
  mineur peut construire un modèle de bloc en itérant simplement sur chaque segment et en l'incluant
  dans son modèle jusqu'à ce qu'il atteigne un segment qui ne rentre pas dans le poids maximal
  souhaité pour le bloc (qui est généralement un peu en dessous de la limite de 1 million de vbytes
  pour laisser de la place à la transaction coinbase du mineur).

  Cependant, les clusters et les segment varient en taille, avec une limite supérieure par défaut
  pour un cluster dans Bitcoin Core attendue à environ 100 000 vbytes. Cela signifie qu'un mineur
  construisant un modèle de bloc ciblant 998 000 vbytes, et qui a déjà 899 001 vbytes remplis, peut
  rencontrer un segment de 99 000 vbytes qui ne rentre pas, laissant environ 10% de l'espace de son
  bloc inutilisé. Ce mineur ne peut pas simplement sauter ce segment de 99 000 vbytes et essayer
  d'inclure le segment suivant car il pourrait inclure une transaction qui dépend du
  segment de 99 000 vbytes. Si un mineur échoue à inclure une transaction dépendante dans son modèle
  de bloc, tout bloc qu'il produit à partir de ce modèle sera invalide.

  Pour contourner ce problème de cas limite, Wuille décrit comment de grands segment peuvent être
  décomposés en plus petits _sous-segments_ qui peuvent être envisagés pour l'inclusion dans l'espace
  restant du bloc en fonction de leurs taux de frais. Un sous-segment peut être créé en retirant
  simplement la dernière transaction dans n'importe quel segment ou sous-segment existant qui a deux
  transactions ou plus. Cela produira toujours au moins un sous-segment plus petit que son segment
  original et cela peut parfois résulter en plusieurs sous-segments. Wuille démontre que le nombre de
  segments et de sous-segments équivaut au nombre de transactions, chaque transaction appartenant à un
  segment ou sous-segment unique. Cela rend possible de précalculer le segment ou sous-segment de
  chaque transaction, appelé son _ensemble d'absorption_, et d'associer cela à la transaction. Wuille
  montre comment l'algorithme de morcellement existant calcule déjà l'ensemble d'absorption de chaque
  transaction.

  Lorsqu'un mineur a rempli un modèle avec tous les segments complets possibles, il peut prendre les
  ensembles d'absorption précalculés pour toutes les transactions pas encore incluses dans le bloc et
  les considérer dans l'ordre des taux de frais. Cela ne nécessite qu'une seule opération de tri sur
  une liste avec le même nombre d'éléments qu'il y a de transactions dans le mempool (presque toujours
  moins d'un million avec les paramètres actuels). Les ensembles d'absorption avec les meilleurs taux
  de frais (segments et sous-segments) peuvent ensuite être utilisés pour remplir l'espace restant du
  bloc. Cela nécessite de suivre le nombre de transactions d'un cluster qui ont été incluses jusqu'à
  présent et de sauter tout sous-segment qui ne rentre pas ou dont certaines transactions ont déjà été
  incluses.

  Cependant, bien que les segments puissent être comparés les uns aux autres pour fournir le meilleur
  ordre pour l'inclusion dans le bloc, l'ordre individuel des transactions au sein d'un segment ou
  sous-segment n'ont pas la garantie d’être dans le meilleur ordre pour n’inclure
  que certaines de ces transactions. Cela peut conduire à une sélection non optimale lorsque un
  bloc est presque plein. Par exemple, lorsqu'il ne reste que 300 vbytes, l'algorithme pourrait
  sélectionner une transaction de 200 vbytes à 5 sats/vbyte (1 000 sats au total) au lieu de deux
  transactions de 150 vbytes à 4 sats/vbyte (1 200 sats au total).

  Wuille décrit comment les ensembles d'absorption précalculés sont particulièrement utiles dans ce
  cas : parce qu'ils ne nécessitent que le suivi du nombre de transactions de chaque cluster qui ont
  été incluses jusqu'à présent, ils facilitent la restauration à un état antérieur dans l'algorithme
  de remplissage du modèle et le remplacement du choix précédemment effectué par une alternative pour
  voir si cela résulte en la collecte de frais totaux plus élevés. Cela permet de mettre en œuvre une
  recherche [branch-and-bound][] qui peut essayer de nombreuses combinaisons de remplissage du dernier
  bit d'espace de bloc dans l'espoir de trouver un meilleur résultat que l'algorithme simple.

- **Simulateur d'événements réseau Hyperion pour le réseau P2P Bitcoin :**
  Sergi Delgado [a posté][delgado hyperion] sur Delving Bitcoin à propos de [Hyperion][], un
  simulateur de réseau qu'il a écrit qui suit comment les données se propagent à travers un réseau
  Bitcoin simulé. Le travail est initialement motivé par le désir de comparer la méthode actuelle de
  Bitcoin pour relayer les annonces de transactions (messages d'inventaire `inv`) à la méthode
  proposée [Erlay][topic erlay].

## Mises à jour et versions candidates

*Nouvelles sorties et candidats à la sortie pour les projets d'infrastructure Bitcoin populaires.
Veuillez envisager de passer aux nouvelles versions ou d'aider à tester les candidats à la sortie.*

- [BDK 1.0.0-beta.1][] est un candidat à la sortie pour "la première version bêta de `bdk_wallet`
  avec une API stable 1.0.0".

### Changements notables dans le code et la documentation

_Changes récents notables dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning
repo], [Eclair][eclair repo], [LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo],
[Interface de Portefeuille Matériel (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [Serveur
BTCPay][btcpay server repo], [BDK][bdk repo], [Propositions d'Amélioration de Bitcoin (BIPs)][bips
repo], [Lightning BOLTs][bolts repo], [Lightning BLIPs][blips repo], [Inquisition Bitcoin][bitcoin
inquisition repo], et [BINANAs][binana repo]._

- [Bitcoin Core #30515][] ajoute le hash du bloc UTXO et le nombre de confirmations comme champs
  supplémentaires à la réponse de la commande RPC `scantxoutset`. Cela fournit un identifiant plus
  fiable pour le bloc UTXO que juste la hauteur du bloc, surtout puisque des réorganisations de la
  chaîne peuvent se produire.

- [Bitcoin Core #30126][] introduit une fonction de [linéarisation de cluster][wuille cluster]
  `Linearize` qui opère sur des clusters de transactions liées pour créer ou améliorer des
  linéarisations, dans le cadre du projet de [cluster de mempool][topic cluster mempool]. Les linéarisations
  de cluster suggèrent un ordre maximisant les frais dans lequel les transactions d'un cluster
  pourraient être ajoutées aux modèles de blocs (ou un ordre de perte de frais minimaux dans lequel
  elles peuvent être évacuées d'un mempool plein). Ces fonctions
  ne sont pas encore intégrés dans le mempool, donc il n'y a pas de changement de comportement dans
  cette PR.

- [Bitcoin Core #30482][] améliore la validation des paramètres pour le point d'accès REST
  `getutxos` en rejetant les txids tronqués ou trop grands et en lançant une erreur de parse
  `HTTP_BAD_REQUEST`. Auparavant, cela échouait également, mais était géré silencieusement.

- [Bitcoin Core #30275][] change le mode par défaut de la commande RPC `estimatesmartfee` de
  conservateur à économique. Ce changement est basé sur les observations des utilisateurs et des
  développeurs selon lesquelles le mode conservateur conduit souvent à un paiement excessif des frais
  de transaction car il est moins réactif aux baisses à court terme du marché des frais que le mode
  économique lors de [l'estimation des frais][topic fee estimation].

- [Bitcoin Core #30408][] remplace l'utilisation de l'expression "public key script" par "output
  script" pour faire référence à un `scriptPubKey` dans le texte d'aide pour les commandes RPC
  suivantes `decodepsbt`, `decoderawtransaction`, `decodescript`, `getblock` (si verbosity=3),
  `getrawtransaction` (si verbosity=2,3), et `gettxout`. C'est la même formulation utilisée dans le
  BIP proposé pour la terminologie des transactions (Voir le Bulletin [#246][news246 bipterminology]).

- [Core Lightning #7474][] met à jour le plugin [offres][topic offers] pour permettre les plages
  expérimentales nouvellement définies pour les types Type-Length-Value (TLV) utilisés dans les
  offres, les demandes de facture et les factures. Cela a été récemment ajouté à la pull request
  [BOLT12][bolt12 pr] non fusionnée dans le dépôt BOLTs.

- [LND #8891][] ajoute un nouveau champ `min_relay_fee_rate` à la réponse attendue d'une source
  externe d'[estimation des frais][topic fee estimation], permettant au service de spécifier le taux
  minimum de frais de relais. Si non spécifié, le `FeePerKwFloor` par défaut de 1012 sats/kvB (1.012
  sats/vbyte) sera utilisé. Le PR améliore également la fiabilité du démarrage en retournant une
  erreur de `EstimateFeePerKW` si appelé avant que l'estimateur de frais ne soit complètement
  initialisé.

- [LDK #3139][] améliore la sécurité des [offres][topic offers] BOLT12 en authentifiant
  l'utilisation de [chemins aveuglés][topic rv routing]. Sans cette authentification, l'attaquant
  Mallory peut prendre l'offre de Bob et demander une facture à chaque nœud du réseau pour déterminer
  lequel d'entre eux appartient à Bob, annulant l'avantage de confidentialité de l'utilisation d'un
  chemin aveuglé. Pour corriger cela, un nonce de 128 bits est maintenant inclus dans le chemin
  aveuglé crypté de chaque offre, plutôt que dans les métadonnées non cryptées de l'offre. Ce
  changement invalide les paiements sortants et les remboursements avec des chemins aveuglés non vides
  créés dans les versions précédentes. D'autre part, les offres créées dans les versions précédentes
  sont toujours valides mais sont vulnérables aux attaques de désanonymisation, donc les utilisateurs
  peuvent vouloir les régénérer après avoir mis à jour vers une version de LDK qui inclut ce
  correctif.

- [Rust Bitcoin #3010][] introduit un champ de longueur à `sha256::Midstate`, permettant un suivi
  plus flexible et précis de l'état du hachage lors de la génération incrémentielle d'un digest
  SHA256. Ce changement peut affecter les implémentations existantes qui se fient à la structure
  `Midstate` précédente.

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="30515,30126,30482,30275,30408,7474,8891,3139,3010" %}
[BDK 1.0.0-beta.1]: https://github.com/bitcoindevkit/bdk/releases/tag/v1.0.0-beta.1
[wuille selection]: https://delvingbitcoin.org/t/cluster-mempool-block-building-with-sub-chunk-granularity/1044
[branch-and-bound]: https://en.wikipedia.org/wiki/Branch_and_bound
[delgado hyperion]: https://delvingbitcoin.org/t/hyperion-a-discrete-time-network-event-simulator-for-bitcoin-core/1042
[hyperion]: https://github.com/sr-gi/hyperion
[news310 disclosure]: /fr/newsletters/2024/07/05/#divulgation-de-vulnerabilites-affectant-les-versions-de-bitcoin-core-anterieures-a-0-21-0
[Crash à distance en envoyant des messages `addr` excessifs]: https://bitcoincore.org/en/2024/07/31/disclose-addrman-int-overflow/
[news159 bcc22387]: /en/newsletters/2021/07/28/#bitcoin-core-22387
[news310 miniupnpc]: /fr/newsletters/2024/07/05/#execution-de-code-a-distance-due-a-un-bug-dans-miniupnpc
[Crash à distance sur le réseau local lorsque UPnP est activé]: https://bitcoincore.org/en/2024/07/31/disclose-upnp-oom/
[upnp]: https://en.wikipedia.org/wiki/Universal_Plug_and_Play
[nat traversal]: https://en.wikipedia.org/wiki/NAT_traversal
[wuille cluster]: https://delvingbitcoin.org/t/introduction-to-cluster-linearization/1032
[goegge disclosure]: https://mailing-list.bitcoindevs.xyz/bitcoindev/bf5287e8-0960-45e8-9c90-64ffc5fdc9aan@googlegroups.com/
[news246 bipterminology]: /fr/newsletters/2023/04/12/#proposition-de-bip-pour-la-terminologie-des-transactions
[bolt12 pr]: https://github.com/lightning/bolts/pull/798
