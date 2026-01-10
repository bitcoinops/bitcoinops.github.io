---
title: 'Bulletin Hebdomadaire Bitcoin Optech #386'
permalink: /fr/newsletters/2026/01/02/
name: 2026-01-02-newsletter-fr
slug: 2026-01-02-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---

Le bulletin de cette semaine résume un schéma de type coffre-fort utilisant MuSig2 aveuglé et décrit
une proposition pour que les clients Bitcoin annoncent et négocient le support de nouvelles
fonctionnalités P2P. Sont également incluses nos sections régulières résumant les récentes discussions sur
la modification des règles de consensus de Bitcoin, annonçant des mises à jour et des versions candidates,
et décrivant les changements notables dans les projets d'infrastructure Bitcoin populaires.

## Nouvelles

- **Construire un coffre-fort en utilisant des co-signataires aveuglés :** Johan T. Halseth a
  [publié][halseth post] sur Delving Bitcoin un prototype d'un schéma de type [coffre-fort][topic
  vaults] utilisant des co-signataires aveuglés. Contrairement aux configurations traditionnelles
  utilisant des co-signataires, ce schéma utilise une version [aveuglée][blinded musig] de
  [MuSig2][topic musig] pour s'assurer que les signataires connaissent le moins de choses possible sur
  les fonds dans lesquels ils sont impliqués dans la signature. Pour éviter que les signataires aient
  à signer aveuglément ce qui leur est donné, ce schéma attache une preuve à divulgation nulle de
  connaissance à la demande de signature prouvant que la transaction est valide selon une politique
  prédéterminée, dans ce cas un [verrouillage temporel][topic timelocks].

  Halseth a fourni un graphique du schéma montrant quatre transactions où les transactions de dépôt
  initial, de récupération, de déverrouillage et de récupération après déverrouillage seront
  pré-signées. Au moment du déverrouillage, les co-signataires exigeront une preuve à divulgation
  nulle de connaissance que la tx qu'ils signent a le verrouillage temporel relatif correctement
  défini. Cela donne l'assurance que l'utilisateur ou une tour de guet aura le temps de récupérer les
  fonds en cas de déverrouillage non autorisé.

  Halseth a également fourni un [prototype d'implémentation][halseth prototype] disponible pour regtest
  et signet.

- **Négociation de fonctionnalités entre pairs** : Anthony Towns a [posté][peer neg ml] sur la liste
  de diffusion Bitcoin-Dev à propos d'une proposition pour un nouveau [BIP][towns bip] pour définir un
  message P2P qui permettrait aux pairs d'annoncer et de négocier le support de nouvelles
  fonctionnalités. L'idée est similaire à une [précédente][feature negotiation ml] de 2020 et
  bénéficierait à divers cas d'utilisation P2P proposés, y compris le travail de Towns sur le [partage
  de modèles][news366 template].

  Historiquement, les changements dans le protocole P2P ont reposé sur l'augmentation de version pour
  signaler le support de nouvelles fonctionnalités, assurant que les pairs négocient uniquement avec
  des nœuds compatibles. Cependant, cette approche crée une coordination inutile entre les
  implémentations, surtout pour les fonctionnalités qui n'ont pas besoin d'une adoption universelle.

  Ce BIP propose de généraliser le mécanisme de [BIP339][] en introduisant un message P2P unique et
  réutilisable pour annoncer et négocier les futures mises à niveau P2P pendant la phase
  [pre-verack][verack]. Cela réduirait les charges de coordination, permettrait une extensibilité sans
  permission, préviendrait la partition du réseau et maximiserait la compatibilité avec divers
  clients.

## Modification du consensus

_Une nouvelle section mensuelle résumant les propositions et discussions sur la modification des
règles de consensus de Bitcoin._

- **Débordement de timestamp de l'année 2106 migration uint64** : Asher Haim a [posté][ah ml]
  uint64 ts] à la liste de diffusion Bitcoin-Dev demandant aux développeurs de Bitcoin d'agir
  rapidement pour préparer une migration de uint32 à uint64 pour les horodatages des blocs. Haim
  explique les raisons d'une action rapide en relation avec les contrats financiers à long terme qui
  pourraient commencer à faire référence à Bitcoin après 2106 assez rapidement. Ceci n'est pas encore
  une proposition concrète sous forme de BIP et nécessiterait de nombreux détails supplémentaires à
  élaborer en ce qui concerne les verrouillages temporels et d'autres parties de l'écosystème Bitcoin.
  La proposition [BitBlend][bb 2024] de janvier 2024 est une solution concrète possible.

- **Assouplir la restriction d'horodatage BIP54 pour le soft fork de 2106** : Josh Doman a posté sur
  la [liste de diffusion][jd ml bip54 ts] Bitcoin-Dev et [Delving Bitcoin][jd delving bip54 ts]
  demandant s'il pourrait être judicieux de modifier la proposition de [nettoyage du consensus][topic
  consensus cleanup] pour être plus permissive envers les comportements étranges d'horodatage des
  blocs afin de permettre une solution de soft fork potentielle au problème de débordement
  d'horodatage des blocs de 2106. ZmnSCPxj avait précédemment [proposé][zman ml ts2106] quelque chose
  de similaire en 2021. Les discussions sur les deux forums se sont concentrées sur la question de
  savoir si éviter un hard fork vaut la peine quand il y a de solides raisons d'ingénierie pour en
  poursuivre un. Greg Maxwell [a écrit][gm delving bip54] que le risque de défaire les attaques de
  [timewarp][topic time warp] que [BIP54][] vise à résoudre peut être une raison suffisante pour ne
  pas tenter d'assouplir ses restrictions de cette manière.

- **Comprendre et atténuer un piège CTV** : Chris Stewart a [posté][cs delving ctv] sur Delving
  Bitcoin une discussion sur un "piège" avec [`OP_CHECKTEMPLATEVERIFY` (CTV)][topic
  op_checktemplateverify]. Spécifiquement, si un montant inférieur au total des montants de sortie
  spécifiés dans un hash CTV à 1 entrée est envoyé à un `scriptPubKey` qui exige inconditionnellement
  ce hash CTV, la sortie résultante est définitivement inexploitable. Il propose que les utilisateurs
  de CTV puissent atténuer cela en faisant en sorte que tous leurs hash CTV s'engagent sur 2 entrées
  ou plus. De cette manière, une entrée supplémentaire peut toujours être construite permettant à de
  telles sorties d'être dépensées.

  Greg Sanders a répondu avec certaines limitations de cette approche et 1440000bytes a mentionné que
  cela s'applique uniquement lorsque le modèle de transaction suivant est appliqué
  inconditionnellement. Greg Maxwell a soutenu que c'est une raison d'éviter toute la classe de
  [covenants][topic covenants] de modèle de transaction. Brandon Black a suggéré que l'utilisation de
  CTV sur une adresse de réception est en effet une conception d'application risquée, et qu'un autre
  opcode tel que [`OP_CHECKCONTRACTVERIFY`][topic matt] ([BIP443][]) en combinaison avec CTV peut
  permettre des applications plus sûres.

- **Réunion d'activation CTV** : Le développeur 1440000bytes a [organisé][fd0 ml ctv] une [réunion][ctv notes1]
  d'activation CTV ([BIP119][]). Les participants à la réunion ont convenu qu'un
  client d'activation CTV devrait utiliser des paramètres conservateurs (c.-à-d.
  périodes de signalisation et d'activation longues) et [BIP9][]. Au moment de la rédaction, d'autres
  développeurs n'ont pas encore donné leur avis sur la liste de diffusion.

- **`OP_CHECKCONSOLIDATION` pour permettre des consolidations moins chères** : billymcbip
  [a proposé][bmb delving cc] un opcode spécifiquement optimisé pour
  les consolidations. `OP_CHECKCONSOLIDATION` (CC) serait évalué à 1 si et seulement si
  il est exécuté sur une entrée ayant le même `scriptPubKey` qu'une entrée antérieure
  dans la même transaction. Beaucoup de discussions ont tourné autour de la
  nécessité d'utiliser le même `scriptPubKey` encourageant la réutilisation d'adresse et
  nuisant à la confidentialité. Brandon Black a proposé une fonctionnalité similaire (mais pas aussi
  efficace en termes de bytes) en utilisant `OP_CHECKCONTRACTVERIFY` ([BIP443][]). Cette proposition est
  similaire au [travail antérieur][news379 civ] de Tadge Dryja sur `OP_CHECKINPUTVERIFY`, mais nettement
  plus efficace en termes de bytes et moins généralisée.

- **Signatures basées sur le hachage pour le futur post-quantique de Bitcoin** : Mikhail Kudinov
  et Jonas Nick [ont posté][mk ml hash] sur la liste de diffusion Bitcoin-Dev à propos de leur travail
  sur l'évaluation des signatures basées sur le hachage pour une utilisation dans Bitcoin. Leur travail
  a trouvé des opportunités significatives d'optimisation de la taille des signatures par rapport
  aux approches standardisées actuelles, mais n'a pas trouvé d'alternatives applicables à [BIP32][],
  [BIP327][], ou [FROST][news315 frost]. Plusieurs développeurs ont participé
  à la discussion, évoquant ce travail et d'autres mécanismes de signature [résistants aux attaques
  quantiques][topic quantum resistance] et les chemins potentiels pour le développement de Bitcoin.

  Il y a eu également une discussion sur ce qui est le plus approprié pour comparer les nouveaux
  mécanismes de vérification de signature basés sur leurs cycles CPU par byte ou
  leurs cycles CPU par signature. Par byte semble plus applicable si les nouvelles vérifications de
  signature seront limitées par le poids existant et les multiplicateurs, réduisant le débit de paiement.
  Par signature pourrait être la meilleure comparaison si les nouvelles signatures avaient leur
  propre limite pour permettre un débit de paiement proche de l'actuel dans un Bitcoin post-quantique.

## Mises à jour et versions candidates

_Nouvelles versions et versions candidates pour des projets d'infrastructure Bitcoin populaires.
Veuillez envisager de mettre à niveau vers les nouvelles versions ou d'aider à tester les versions candidates._

- [BTCPay Server 2.3.0][] est une version de cette solution de paiement auto-hébergée populaire
  qui ajoute la fonctionnalité Abonnements (voir le [Bulletin #379][news379
  btcpay]) à l'interface utilisateur et à l'API, améliore les demandes de paiement, et
  inclut plusieurs autres fonctionnalités et corrections de bugs.

## Changements notables dans le code et la documentation

_Changements notables récents dans [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet Interface
(HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement Proposals
(BIPs)][bips repo], [Lightning BOLTs][bolts repo], [Lightning
BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition repo], and
[BINANAs][binana repo]._

- [Bitcoin Core #33657][] introduit un nouveau point de terminaison REST
  `/rest/blockpart/<BLOCKHASH>.bin?offset=X&size=Y` qui retourne une plage d'octets d'un bloc. Cela
  permet à des index externes tels que Electrs de ne récupérer que des transactions spécifiques, au
  lieu de télécharger le bloc entier.

- [Bitcoin Core #32414][] ajoute des vidages périodiques du cache UTXO sur le disque pendant le
  réindexage, en plus de la couverture existante pendant l'IBD. Auparavant, le vidage ne se produisait
  que lorsque le sommet était atteint, donc un crash pendant le réindexage pourrait entraîner une
  perte substantielle de progrès avec un `dbcache` important défini.

- [Bitcoin Core #32545][] remplace l'algorithme de linéarisation en cluster précédemment introduit
  (voir le [Bulletin #314][news314 cluster]) par un algorithme de linéarisation en forêt couvrante
  conçu pour gérer plus efficacement les clusters difficiles. Les tests sur des données historiques de
  mempool indiquent que le nouvel algorithme peut linéariser tous les clusters observés jusqu'à 64
  transactions en dizaines de microsecondes. Cela fait partie du projet [cluster mempool][topic
  cluster mempool].

- [Bitcoin Core #33892][] assouplit la politique de relais, permettant le [relais de paquets][topic package relay]
  opportunistes 1-parent-1-enfant (1p1c) où le parent paie en
  dessous du frais de relais minimum même si le parent n'est pas [TRUC][topic v3 transaction relay],
  tant que le taux de frais du paquet dépasse le frais de relais minimum actuel du nœud et que
  l'enfant n'a pas d'autres ancêtres avec un frais en dessous du minimum. Cela était auparavant limité
  aux transactions TRUC uniquement pour simplifier le raisonnement sur la taille du mempool, mais cela
  n'est plus une préoccupation avec le [cluster mempool][topic cluster mempool].

- [Core Lightning #8784][] ajoute un champ `payer_note` à la commande RPC `xpay` (voir le [Bulletin
  #330][news330 xpay]) pour permettre à un payeur de fournir une description de paiement lors de la
  demande d'une facture. La commande `fetchinvoice` a déjà un champ `payer_note` similaire, donc cette
  PR l'ajoute à `xpay` et relie la valeur au flux sous-jacent.

- [LND #9489][] et [#10049][lnd #10049] introduisent un sous-système gRPC `switchrpc` expérimental
  avec les RPCs `BuildOnion`, `SendOnion`, et `TrackOnion`, permettant à un contrôleur externe de
  gérer la recherche de chemin et la gestion du cycle de vie des paiements tout en utilisant LND pour
  la livraison de [HTLC][topic htlc]. La compilation du serveur est cachée derrière la balise de
  construction non standard `switchrpc`. [LND #10049][]ajoute spécifiquement la base de stockage pour
  le suivi des tentatives externes, jetant ainsi les bases d'une future version idempotente. Actuellement,
  il est plus sûr de n'autoriser qu'une seule entité à la fois à envoyer des tentatives via le commutateur,
  afin d'éviter toute perte de fonds.

- [BIPs #2051][] apporte plusieurs changements à la spécification [BIP3][] : il annule les conseils
  récemment ajoutés contre l'utilisation des LLMs (voir le [Bulletin #378][news378 bips2006]), élargit
  les formats d'implémentation de référence, ajoute un journal des modifications, et réalise plusieurs
  autres améliorations et clarifications.

- [BOLTs #1299][] met à jour la spécification [BOLT3][] pour supprimer une note ambiguë concernant
  l'utilisation du point d'engagement `localpubkey` dans la sortie qui paie le contrepartie
  `to_remote`. Avec l'`option_static_remotekey`, cela n'est plus valide car la sortie `to_remote` est
  censée utiliser le `payment_basepoint` statique du destinataire pour permettre la récupération des
  fonds sans le point d'engagement.

- [BOLTs #1305][] met à jour la spécification [BOLT11][] pour clarifier que le champ `n` (clé
  publique de 33 octets du nœud payeur) n'est pas obligatoire. Cela corrige une phrase antérieure qui
  disait qu'il était obligatoire.

{% include snippets/recap-ad.md when="2026-01-06 17:30" %}
{% include references.md %} {% include linkers/issues.md v=2 issues="33657,32414,32545,33892,8784,9489,10049,2051,1299,1305" %}
[news315 frost]: /fr/newsletters/2024/08/09/#proposition-de-bip-pour-les-signatures-a-seuil-sans-script
[mk ml hash]: https://groups.google.com/g/bitcoindev/c/gOfL5ag_bDU/m/0YuwSQ29CgAJ
[fd0 ml ctv]: https://groups.google.com/d/msgid/bitcoindev/CALiT-Zr9JnLcohdUQRufM42OwROcOh76fA1xjtqUkY5%3Dotqfwg%40mail.gmail.com
[ctv notes1]: https://ctv-activation.github.io/meeting/18dec2025.html
[news379 civ]: /fr/newsletters/2025/11/07/#agregation-de-signatures-post-quantique
[bmb delving cc]: https://delvingbitcoin.org/t/op-cc-a-simple-introspection-opcode-to-enable-cheaper-consolidations/2177
[cs delving ctv]: https://delvingbitcoin.org/t/understanding-and-mitigating-a-op-ctv-footgun-the-unsatisfiable-utxo/1809
[bb 2024]: https://bitblend2106.github.io/bitcoin/BitBlend2106.pdf
[ah ml uint64 ts]: https://groups.google.com/g/bitcoindev/c/PHZEIRb04RY/m/ryatIL5RCwAJ
[jd ml bip54 ts]: https://groups.google.com/g/bitcoindev/c/L4Eu9bA5iBw/m/jo9RzS-HAQAJ
[jd delving bip54 ts]: https://delvingbitcoin.org/t/modifying-bip54-to-support-future-ntime-soft-fork/2163
[zman ml ts2106]: https://gnusha.org/pi/bitcoindev/eAo_By_Oe44ra6anVBlZg2UbfKfzhZ1b1vtaF0NuIjdJcB_niagHBS-SoU2qcLzjDj8Kuo67O_FnBSuIgskAi2_fCsLE6_d4SwWq9skHuQI=@protonmail.com/
[gm delving bip54]: https://delvingbitcoin.org/t/modifying-bip54-to-support-future-ntime-soft-fork/2163/6
[halseth post]: https://delvingbitcoin.org/t/building-a-vault-using-blinded-co-signers/2141
[halseth prototype]: https://github.com/halseth/blind-vault
[blinded musig]: https://github.com/halseth/ephemeral-signing-service/blob/main/doc/general.md
[peer neg ml]: https://groups.google.com/g/bitcoindev/c/DFXtbUdCNZE
[news366 template]: /fr/newsletters/2025/08/08/#partage-de-modele-de-bloc-entre-pairs-pour-attenuer-les-problemes-lies-aux-politiques-de-mempool-divergentes
[feature negotiation ml]: https://gnusha.org/pi/bitcoindev/CAFp6fsE=HPFUMFhyuZkroBO_QJ-dUWNJqCPg9=fMJ3Jqnu1hnw@mail.gmail.com/
[towns bip]: https://github.com/ajtowns/bips/blob/202512-p2p-feature/bip-peer-feature-negotiation.md
[verack]:https://developer.bitcoin.org/reference/p2p_networking.html#verack
[BTCPay Server 2.3.0]: https://github.com/btcpayserver/btcpayserver/releases/tag/v2.3.0
[news379 btcpay]: /fr/newsletters/2025/11/07/#btcpay-server-6922
[news314 cluster]: /fr/newsletters/2024/08/02/#bitcoin-core-30126
[news330 xpay]: /fr/newsletters/2024/11/22/#core-lightning-7799
[lnd #10049]: https://github.com/lightningnetwork/lnd/pull/10049
[news378 bips2006]: /fr/newsletters/2025/10/31/#bips-2006