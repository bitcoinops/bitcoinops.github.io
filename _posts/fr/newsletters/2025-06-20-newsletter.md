---
title: 'Bulletin Hebdomadaire Bitcoin Optech #359'
permalink: /fr/newsletters/2025/06/20/
name: 2025-06-20-newsletter-fr
slug: 2025-06-20-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
La newsletter de cette semaine décrit une proposition visant à limiter la participation du public
dans les dépôts de Bitcoin Core, annonce des améliorations significatives pour les contrats de style
BitVM, et résume la recherche sur le rééquilibrage des canaux LN. Sont également incluses nos
sections régulières résumant les changements récents apportés aux clients et services, les
annonces de nouvelles versions et de candidats à la publication, et les résumés des modifications
notables apportées aux logiciels d'infrastructure Bitcoin populaires.

## Nouvelles

- **Proposition pour restreindre l'accès à la discussion du projet Bitcoin Core :**
  Bryan Bishop a [posté][bishop priv] sur la liste de diffusion Bitcoin-Dev pour
  suggérer que le projet Bitcoin Core limite la capacité du public à
  participer aux discussions du projet afin de réduire la quantité
  de perturbations causées par les non-contributeurs. Il a appelé cela
  "privatiser Bitcoin Core",
  pointant des exemples de cette privatisation se produisant déjà sur une base ad
  hoc dans des bureaux privés avec plusieurs contributeurs de Bitcoin Core,
  et avertit que la privatisation en personne exclut les contributeurs à distance.

  Le post de Bishop suggère une méthode pour la privatisation en ligne, mais
  Antoine Poinsot a [questionné][poinsot priv] si cette méthode
  atteindrait l'objectif. Poinsot a également suggéré que de nombreuses discussions en bureau privé
  pourraient se produire non pas par peur du reproche public mais
  en raison des "avantages naturels des discussions en personne".

  Plusieurs réponses ont suggéré que faire des changements majeurs n'est
  probablement pas justifié à ce moment mais qu'une modération plus forte des
  commentaires sur le dépôt pourrait atténuer le type le plus
  significatif de perturbation. Cependant, d'autres réponses ont noté plusieurs
  défis liés à une modération plus forte.

  Poinsot, Sebastian "The Charlatan" Kung, et Russell Yanofsky---les seuls contributeurs très
  actifs de Bitcoin Core à répondre au fil jusqu'à la rédaction de cet article---[ont indiqué][kung
  priv] soit [que][yanofsky priv] ils ne pensent pas qu'un changement majeur soit nécessaire, soit que
  tout changement devrait se faire progressivement au fil du temps.

- **Améliorations des contrats de style BitVM :** Robin Linus a [posté][linus
  bitvm3] sur Delving Bitcoin pour annoncer une réduction significative de la
  quantité d'espace sur la chaîne requise par les contrats de style [BitVM][topic acc].
  Basé sur une [idée][rubin garbled] de Jeremy Rubin qui
  s'appuie sur de nouveaux primitives cryptographiques, la nouvelle approche "réduit le
  coût sur la chaîne d'un litige de plus de 1 000 fois par rapport à la conception précédente", avec
  des transactions de réfutation étant "juste de 200 octets".

  Cependant, le document de Linus note le compromis pour cette approche : elle
  "nécessite une configuration de données offchain de plusieurs téraoctets". Le document donne un
  exemple d'un circuit vérificateur SNARK avec environ 5 milliards de portes et
  des paramètres de sécurité raisonnables nécessitant une configuration offchain de 5 To, 56 kB
  de transaction onchain pour affirmer le résultat, et une transaction onchain minimale
  (~200 B) dans le cas où une partie doit prouver que l'affirmation était invalide.

- **Recherche sur le rééquilibrage des canaux :** Rene Pickhardt a [posté][pickhardt
  rebalance] sur Delving Bitcoin ses réflexions sur le rééquilibrage des canaux
  pour maximiser le taux de paiements réussis à travers
  le réseau entier. Ses idées peuvent être comparées à des approches qui examinent des groupes plus
  petits de canaux, tels que le [rééquilibrage entre amis][topic jit routing] (voir le [Bulletin
  #54][news54 foaf rebalance]).

  Pickhardt note qu'il existe plusieurs défis à une approche globale et demande aux parties
  intéressées de répondre à quelques questions, telles que si cette approche vaut la peine d'être
  poursuivie et comment aborder certains détails de mise en œuvre.

## Changements dans les services et logiciels clients

*Dans cette rubrique mensuelle, nous mettons en lumière des mises à jour intéressantes des
portefeuilles et services Bitcoin.*

- **Cove v1.0.0 publié :**
  Les récentes [versions][cove github] de Cove incluent le support du contrôle des pièces et des
  fonctionnalités supplémentaires de libellé de portefeuille [BIP329][].

- **Liana v11.0 publié :**
  Les récentes [versions][liana github] de Liana incluent des fonctionnalités pour plusieurs
  portefeuilles, des fonctionnalités de contrôle des pièces supplémentaires, et plus de support pour
  les dispositifs de signature matérielle, parmi d'autres fonctionnalités.

- **Démonstration de preuve STARK Stratum v2 :**
  StarkWare a [démontré][starkware tweet] un client de minage [Stratum v2 modifié][starkware sv2]
  utilisant une preuve STARK pour prouver que les frais d'un bloc appartiennent à un modèle de bloc
  valide sans révéler les transactions dans le bloc.

- **Breez SDK ajoute BOLT12 et BIP353 :**
  Breez SDK Nodeless [0.9.0][breez github] ajoute le support pour la réception en utilisant [BOLT12][]
  et [BIP353].

## Mises à jour et versions candidates

_Nouvelles versions et versions candidates pour des projets d'infrastructure Bitcoin populaires.
Veuillez envisager de mettre à niveau vers les nouvelles versions ou d'aider à tester les versions candidates._

- [Core Lightning 25.05][] est une sortie de la prochaine version majeure de cette implémentation
  populaire de nœud LN. Elle réduit la latence de transmission et de résolution des paiements,
  améliore la gestion des frais, fournit un support de [splicing][topic splicing] compatible avec
  Eclair, et active le [stockage des pairs][topic peer storage] par défaut. Note : sa [documentation
  de sortie][core lightning 25.05] contient un avertissement pour les utilisateurs de l'option de
  configuration `--experimental-splicing`.

## Changements notables dans le code et la documentation

_Changements notables récents dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core
lightning repo], [Eclair][eclair repo], [LDK][ldk repo], [LND][lnd repo],
[libsecp256k1][libsecp256k1 repo], [Interface de Portefeuille Matériel (HWI)][hwi repo], [Rust
Bitcoin][rust bitcoin repo], [BTCPay Server][btcpay server repo], [BDK][bdk repo], [Propositions
d'Amélioration de Bitcoin (BIPs)][bips repo], [Lightning BOLTs][bolts repo], [Lightning BLIPs][blips
repo], [Inquisition Bitcoin][bitcoin inquisition repo], et [BINANAs][binana repo]._

- [Eclair #3110][] augmente le délai pour marquer un canal comme fermé après que sa sortie de
  financement est dépensée de 12 (voir le Bulletin [#337][news337 delay]) à 72 blocs comme spécifié
  dans [BOLTs #1270][], pour permettre la propagation d'une mise à jour de [splice][topic splicing].
  Il a été augmenté parce que certaines implémentations par défaut, attendent 8 confirmations
  avant d'envoyer `splice_locked` et permettre aux opérateurs de
  nœuds d'augmenter ce seuil, donc 12 blocs se sont avérés trop courts. Le délai est maintenant
  configurable à des fins de test et pour permettre aux opérateurs de nœuds d'attendre plus longtemps.

- [Eclair #3101][] introduit le RPC `parseoffer`, qui décode les champs d'[offre BOLT12][topic
  offers] en un format lisible par l'homme, permettant aux utilisateurs de voir le montant avant de le
  passer au RPC `payoffer`. Ce dernier est étendu pour accepter un montant spécifié dans une devise
  fiat.

- [LDK #3817][] revient sur le support des [échecs attribuables][topic attributable failures] (voir
  le Bulletin [#349][news349 attributable]) en le plaçant sous un drapeau de test uniquement. Cela
  désactive la logique de pénalisation des pairs et retire la fonctionnalité TLV des messages d'échec
  en [onion][topic onion messages]. Les nœuds qui n'avaient pas encore été mis à jour étaient pénalisés à
  tort, montrant qu'une adoption plus large du réseau est nécessaire pour que cela fonctionne correctement.

- [LDK #3623][] étend le [stockage de pairs][topic peer storage] (voir le Bulletin [#342][news342
  peer]) pour fournir des sauvegardes de pairs automatiques et cryptées. À chaque bloc, `ChainMonitor`
  emballe les données d'une structure `ChannelMonitor` versionnée, horodatée et sérialisée dans un
  blob `OurPeerStorage`. Ensuite, il crypte les données et déclenche un événement `SendPeerStorage`
  pour relayer le blob comme un message `peer_storage` à chaque pair de canal. De plus,
  `ChannelManager` est mis à jour pour gérer les demandes de `peer_storage_retrieval` en déclenchant
  un nouvel envoi de blob.

- [BTCPay Server #6755][] améliore l'interface utilisateur de contrôle des pièces avec de nouveaux
  filtres de montant minimum et maximum, des filtres de date de création avant et après, une section
  d'aide pour les filtres, une case à cocher "sélectionner tout" pour les UTXO, et des options de
  taille de page importante (100, 200 ou 500 UTXO).

- [Rust libsecp256k1 #798][] complète l'implémentation de [MuSig2][topic musig] dans la
  bibliothèque, donnant aux projets en aval accès à un protocole de [multisignature sans script][topic
  multisignature] robuste.

{% include snippets/recap-ad.md when="2025-06-24 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="3110,3101,3817,3623,6755,1270" %}
[Core Lightning 25.05]: https://github.com/ElementsProject/lightning/releases/tag/v25.05
[bishop priv]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CABaSBax-meEsC2013zKYJnC3phFFB_W3cHQLroUJcPDZKsjB8w@mail.gmail.com/
[poinsot priv]: https://mailing-list.bitcoindevs.xyz/bitcoindev/4iW61M7NCP-gPHoQZKi8ZrSa2U6oSjziG5JbZt3HKC_Ook_Nwm1PchKguOXZ235xaDlhg35nY8Zn7g1siy3IADHvSHyCcgTHrJorMKcDzZg=@protonmail.com/
[kung priv]: https://mailing-list.bitcoindevs.xyz/bitcoindev/58813483-7351-487e-8f7f-82fb18a4c808n@googlegroups.com/
[linus bitvm3]: https://delvingbitcoin.org/t/garbled-circuits-and-bitvm3/1773
[rubin garbled]: https://rubin.io/bitcoin/2025/04/04/delbrag/
[pickhardt rebalance]: https://delvingbitcoin.org/t/research-update-a-geometric-approach-for-optimal-channel-rebalancing/1768
[rust libsecp256k1 #798]: https://github.com/rust-bitcoin/rust-secp256k1/pull/798
[news54 foaf rebalance]: /en/newsletters/2019/07/10/#brainstorming-just-in-time-routing-and-free-channel-rebalancing
[yanofsky priv]: https://github.com/bitcoin-core/meta/issues/19#issuecomment-2961177626
[cove github]: https://github.com/bitcoinppl/cove/releases
[liana github]: https://github.com/wizardsardine/liana/releases
[breez github]: https://github.com/breez/breez-sdk-liquid/releases/tag/0.9.0
[starkware tweet]: https://x.com/dimahledba/status/1935354385795592491
[starkware sv2]: https://github.com/keep-starknet-strange/stratum
[news337 delay]: /fr/newsletters/2025/01/17/#eclair-2936
[news349 attributable]: /fr/newsletters/2025/04/11/#ldk-2256
[news342 peer]: /fr/newsletters/2025/02/21/#ldk-3575