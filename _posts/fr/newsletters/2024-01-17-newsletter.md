---
title: 'Bulletin Hebdomadaire Bitcoin Optech #285'
permalink: /fr/newsletters/2024/01/17/
name: 2024-01-17-newsletter-fr
slug: 2024-01-17-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine révèle une vulnérabilité passée affectant Core Lightning, annonce deux nouvelles propositions de soft fork,
donne un aperçu de la proposition de mempool en cluster, transmet des informations sur une spécification et une implémentation mises à
jour de la compression des transactions, et résume une discussion sur la valeur extractible par les mineurs (MEV) dans les ancres
éphémères non nulles. Sont également incluses nos sections régulières avec les annonces de nouvelles versions et les changements
apportés aux principaux logiciels d'infrastructure Bitcoin.

## Nouvelles

- **Divulgation d'une vulnérabilité passée dans Core Lightning :** Matt Morehouse a utilisé Delving Bitcoin pour
  [annoncer][morehouse delving] une vulnérabilité qu'il avait précédemment [divulguée de manière
  responsable][topic responsible disclosures] et qui affectait les versions 23.02 à 23.05.2 de Core Lightning. Les versions plus récentes
  de 23.08 ou supérieures ne sont pas affectées.

  La nouvelle vulnérabilité a été découverte par Morehouse lorsqu'il a poursuivi ses travaux précédents sur le financement fictif,
  qu'il a également divulgué de manière responsable (voir le [Bulletin #266][news266 lnbugs]). Lorsqu'il a retesté des nœuds qui
  avaient mis en place des correctifs pour le financement fictif, il a déclenché une [condition de concurrence][] qui a fait planter
  CLN avec environ 30 secondes d'effort. Si un nœud LN est hors ligne, il ne peut pas protéger un utilisateur contre des contreparties
  malveillantes ou défectueuses, ce qui met les fonds de l'utilisateur en danger. L'analyse a indiqué que CLN avait corrigé la
  vulnérabilité initiale du financement fictif, mais n'avait pas pu inclure en toute sécurité un test pour celle-ci avant que la
  vulnérabilité ne soit divulguée, ce qui a entraîné la fusion ultérieure d'un plugin introduisant la condition de concurrence
  exploitable. Après la divulgation de Morehouse, un correctif rapide a été fusionné dans CLN pour empêcher la condition de
  concurrence de faire planter le nœud.

  Pour plus d'informations, nous vous recommandons de lire l'excellent [article de divulgation complète][morehouse full] de Morehouse.

- **Nouvelle proposition de soft fork combinant LNHANCE :** Brandon Black a [publié][black lnhance] sur Delving Bitcoin des détails sur
  un soft fork qui combine les propositions précédentes pour [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify] (CTV) et
  [OP_CHECKSIGFROMSTACK][topic op_checksigfromstack] (CSFS) avec une nouvelle proposition pour un `OP_INTERNALKEY` qui place la
  [clé interne taproot][] sur la pile. Les auteurs de scripts doivent connaître la clé interne avant de pouvoir payer à une sortie,
  ils pourraient donc directement inclure une clé interne dans un script. Cependant, `OP_INTERNALKEY` est une version simplifiée d'une
  [ancienne suggestion][rubin templating] de l'auteur original de CTV, Jeremy Rubin, pour économiser plusieurs vbytes et rendre
  potentiellement les scripts plus réutilisables en permettant de récupérer la valeur de la clé à partir de l'interpréteur de script.

  Dans le fil de discussion, Black et d'autres décrivent certains des protocoles qui seraient activés par cette combinaison de
  changements de consensus : [LN-Symmetry][topic eltoo] (eltoo), [Ark][topic ark]-style [joinpools][topic joinpools], les
  [DLC][topic dlc] avec signature réduite, et les [coffres-forts][topic vaults] sans transactions pré-signées, parmi les autres
  avantages décrits des propositions sous-jacentes, tels que le contrôle de congestion de style CTV et la délégation de signature
  de style CSFS.

  Au moment de la rédaction de cet article, la discussion technique était limitée à la demande concernant les protocoles que la
  proposition combinée permettrait.

- **Proposition de soft fork pour l'arithmétique sur 64 bits :** Chris Stewart a [publié][stewart 64] un [projet de BIP][bip 64] pour
  Delving Bitcoin afin de permettre des opérations arithmétiques à 64 bits sur Bitcoin lors d'un futur soft fork. Bitcoin
  [autorise actuellement][script wiki] uniquement des opérations à 32 bits (en utilisant des entiers signés, de sorte que les nombres
  de plus de 31 bits ne peuvent pas être utilisés). Le support des valeurs sur 64 bits serait particulièrement utile dans toute
  construction qui nécessite de travailler sur le nombre de satoshis payés dans une sortie, car cela est spécifié à l'aide d'un entier
  sur 64 bits. Par exemple, les protocoles de sortie de [joinpool][topic joinpools] bénéficieraient de l'introspection des montants
  (voir les bulletins [#166][news166 tluv] et [#283][news283 exits]).

  Au moment de la rédaction de cet article, la discussion portait sur les détails de la proposition, tels que la manière d'encoder la
  valeur entière, quelle fonctionnalité de mise à niveau [taproot][topic taproot] utiliser et s'il est préférable de créer un nouvel
  ensemble d'opcodes arithmétiques ou de mettre à niveau ceux existants.

- **Aperçu de la proposition de mempool en cluster :** Suhas Daftuar a [publié][daftuar cluster] un résumé de la proposition de
  [mempool en cluster][topic cluster mempool] sur Delving Bitcoin. Optech a tenté de résumer l'état actuel de la discussion sur le
  mempool en cluster dans le [Bulletin #280][news280 cluster], mais nous recommandons vivement de lire l'aperçu de Daftuar, l'un des
  architectes de la proposition. Un détail que nous n'avons pas encore abordé a attiré notre attention :

  - *La suppression du découpage CPFP est nécessaire :* la politique de mempool de [décuopage CPFP][topic cpfp carve out] ajoutée à
    Bitcoin Core en [2019][news56 carveout] tente de résoudre la version CPFP d'[épinglage de transaction][topic transaction pinning],
    où un attaquant contrepartie utilise les limites de Bitcoin Core sur le nombre et la taille des transactions connexes pour retarder
    l'examen d'une transaction enfant appartenant à un pair honnête. Le découpage permet à une transaction de dépasser légèrement les
    limites. Dans le mempool en cluster, les transactions connexes sont placées dans un cluster et les limites sont appliquées par
    cluster, et non par transaction. Selon cette politique, il n'y a aucun moyen connu de garantir qu'un cluster ne contient qu'un
    maximum de découpage, à moins de restreindre les relations autorisées entre les transactions relayées sur le réseau bien au-delà
    des restrictions actuelles. Un cluster avec plusieurs découpage pourrait dépasser considérablement ses limites, auquel cas le
    protocole devrait être conçu pour ces limites beaucoup plus élevées. Cela permettrait de répondre aux besoins des utilisateurs
    de découpage, mais restreindrait ce que les diffuseurs de transactions régulières peuvent faire, ce qui est---une proposition
    indésirable.

    Une solution proposée à l'incompatibilité entre découpage et mempool en cluster est le
    [relais de transaction v3][topic v3 transaction relay], qui permettrait aux utilisateurs réguliers de transactions v1 et v2
    de pouvoir continuer à les utiliser de toutes les manières historiquement typiques, mais aussi permettre aux utilisateurs de
    protocoles de contrat comme LN d'opter pour des transactions v3 qui imposent un ensemble restreint de relations entre les
    transactions (_topology_). La topologie restreinte permettrait d'atténuer les attaques de blocage de transaction et pourrait être
    combinée avec des remplacements presque intégraux pour les transactions de découpage telles que les [ancres
    éphémères][topic ephemeral anchors].

 Il est important qu'un changement majeur des algorithmes de gestion du mempool de Bitcoin Core prenne en compte toutes les façons dont
 les gens utilisent Bitcoin aujourd'hui, ou pourraient l'utiliser dans un avenir proche, nous encourageons donc les développeurs
 travaillant sur des logiciels pour l'extraction minière, les portefeuilles ou les protocoles de contrat à lire la description de Daftuar
 et à poser des questions sur tout ce qui n'est pas clair ou qui pourrait affecter négativement l'interaction du logiciel Bitcoin avec
 le mempool en cluster.

- **Spécification et implémentation mise à jour de la compression des transactions Bitcoin :** Tom Briar a [publié][briar compress] sur
  la liste de diffusion Bitcoin-Dev une [spécification mise à jour][compress spec] et une [proposition
  d'implémentation][bitcoin core #28134] des transactions Bitcoin compressées. Les transactions plus petites seraient plus pratiques à
  relayer via des supports à bande passante limitée, tels que par satellite ou par stéganographie (par exemple, en encodant une
  transaction dans une image bitmap). Voir le [Bulletin #267][news267 compress] pour notre description de la proposition originale.
  Briar décrit les principaux changements : "suppression du blocage de nLocktime au profit d'une hauteur de bloc relative, utilisée par
  toutes les entrées compressées, et utilisation d'un deuxième type d'entier variable."

- **Discussion sur la valeur extractible par les mineurs (MEV) dans les ancres éphémères non nulles :** Gregory Sanders a
  [publié][sanders mev] sur Delving Bitcoin pour discuter des préoccupations concernant les sorties d'[ancres éphémères][topic ephemeral
  anchors] qui contiennent plus de 0 satoshis. Une ancre éphémère paie un script de sortie standardisé que n'importe qui peut dépenser.

 Une façon d'utiliser les ancres éphémères serait de leur attribuer un montant de sortie nul, ce qui est raisonnable étant donné que les
 règles de politique les concernant exigent qu'elles soient accompagnées d'une transaction enfant dépensant la sortie de l'ancre.
 Cependant, dans le protocole LN actuel, lorsqu'une partie souhaite créer un HTLC [non économique][topic uneconomical outputs], le
 montant du paiement est utilisé pour surpayer les frais de transaction d'engagement ; on parle alors d'un HTLC tronqué (_trimmed HTLC_).
 Si le découpage HTLC est effectué dans une transaction d'engagement utilisant des ancres éphémères, il pourrait être rentable pour un
 mineur de confirmer la transaction d'engagement sans une transaction enfant qui dépense la sortie de l'ancre éphémère. Une fois qu'une
 transaction d'engagement est confirmée, il n'y a aucune incitation pour quiconque à dépenser une sortie d'ancre éphémère d'un montant
 nul, ce qui signifie qu'elle occupera de l'espace dans les ensembles UTXO des nœuds complets pour toujours, ce qui est un résultat
 indésirable.

 Une proposition alternative consiste à mettre les montants HTLC tronqués dans la valeur des sorties d'ancres éphémères. De cette façon,
 ils incitent à la fois à confirmer la transaction d'engagement et à dépenser la sortie de l'ancre éphémère. Dans son message, Sanders
 analyse cette possibilité et constate qu'elle peut créer plusieurs problèmes de sécurité.
 Ces problèmes peuvent être résolus par les mineurs en analysant les transactions, en déterminant quand il serait plus rentable pour eux
 de dépenser eux-mêmes une sortie d'ancrage éphémère, et en créant la transaction nécessaire. Il s'agit d'un type de
 [valeur extractible par les mineurs][news201 mev] (MEV). Plusieurs solutions alternatives ont également été proposées :

 - *Ne relayer que les transactions entièrement compatibles avec les incitations des mineurs :* si quelqu'un essaie de dépenser une ancre
   éphémère d'une manière qui ne maximise pas les revenus d'un mineur, cette transaction ne sera pas relayée par Bitcoin Core.

 - *Brûler la valeur réduite :* au lieu de convertir le montant des HTLC réduits en frais, le montant serait plutôt dépensé dans une
   sortie `OP_RETURN`, détruisant ainsi ces satoshis en les rendant définitivement non dépensables. Cela ne se produirait que si une
   transaction d'engagement contenant un HTLC réduit était mise sur la chaîne ; normalement, les HTLC réduits sont résolus off-chain
   et leur valeur est transférée avec succès d'une partie à l'autre.

 - *Assurer une propagation facile des transactions MEV :* au lieu de demander aux mineurs d'exécuter un code spécial qui maximise leur
   valeur, veiller à ce que les transactions maximisant leur valeur se propagent facilement à travers le réseau. De cette façon,
   n'importe qui peut exécuter le code MEV et transmettre les résultats aux mineurs de manière à ce que tous les mineurs et nœuds de
   relais puissent obtenir le même ensemble de transactions.

 Aucune conclusion claire n'a été atteinte au moment de la rédaction.

## Mises à jour et versions candidates

*Nouvelles versions et versions candidates pour les principaux projets
d'infrastructure Bitcoin. Veuillez envisager de passer aux nouvelles
versions ou d'aider à tester les versions candidates.*

- [LDK 0.0.119][] est une nouvelle version de cette bibliothèque pour la création d'applications compatibles avec le LN. De nouvelles
  fonctionnalités sont ajoutées, notamment la réception de paiements sur des [chemins aveugles][topic rv routing] multi-sauts, ainsi
  que plusieurs corrections de bugs et autres améliorations.

## Changements notables dans le code et la documentation

*Changements notables cette semaine dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning repo], [Eclair][eclair repo],
[LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Interface de portefeuille matériel (HWI)][hwi repo],
[Rust Bitcoin][rust bitcoin repo], [Serveur BTCPay][btcpay server repo], [BDK][bdk repo],
[Propositions d'amélioration de Bitcoin (BIP)][bips repo], [Lightning BOLTs][bolts repo]
et [Bitcoin Inquisition][bitcoin inquisition repo].*

- [Bitcoin Core #29058][] est une étape de préparation pour activer le [transport P2P de version 2 (BIP324)][topic v2 p2p transport] par
  défaut. Ce correctif ajoute la prise en charge du transport v2 pour les arguments de configuration `-connect`, `-addnode` et `-seednode`
  si `-v2transport` est activé et se reconnecte avec v1 si le pair ne prend pas en charge v2. De plus, cette mise à jour ajoute une
  colonne affichant la version du protocole de transport au tableau de bord de connexion de pair `netinfo` de `bitcoin-cli`.

- [Bitcoin Core #29200][] permet à la prise en charge du réseau [I2P][topic anonymity networks] d'utiliser des connexions chiffrées avec
  "ECIES-X25519" et ElGamal (types 4 et 0, respectivement). Cela permet de se connecter à des pairs I2P de l'un ou l'autre type, et le
  plus récent et plus rapide ECIES-X25519 sera préféré."

- [Bitcoin Core #28890][] supprime le paramètre de configuration `-rpcserialversion` qui était précédemment déprécié (voir le
  [Bulletin #269][news269 rpc]). Cette option a été introduite lors de la transition vers segwit v0 pour permettre aux anciens programmes
  de continuer à accéder aux blocs et aux transactions au format réduit (sans aucun champ segwit). À ce stade, tous les programmes
  doivent être mis à jour pour gérer les transactions segwit et cette option ne devrait plus être nécessaire.

- [Eclair #2808][] met à jour la commande `open` avec un paramètre `--fundingFeeBudgetSatoshis` qui définit le montant maximum que le
  nœud est prêt à payer en frais onchain pour ouvrir un canal, avec une valeur par défaut de 0,1% du montant payé dans le canal. Eclair
  essaiera de payer des frais inférieurs si possible, mais il paiera jusqu'au montant budgété si nécessaire. La commande `rbfopen` est
  également mise à jour pour accepter le même paramètre qui définit le montant maximum à dépenser pour [l'augmentation des frais
  RBF][topic rbf].

- [LND #8188][] ajoute plusieurs nouvelles RPC pour obtenir rapidement des informations de débogage, les chiffrer avec une clé publique
  et les déchiffrer avec une clé privée. Comme l'explique le PR, "L'idée serait de publier une clé publique dans le modèle de
  problème GitHub et de demander aux utilisateurs d'exécuter la commande `lncli encryptdebugpackage` puis de télécharger les fichiers
  de sortie chiffrés sur la page GitHub réservée au signalement de problèmes afin de nous fournir les informations dont nous avons
  besoin pour résoudre les problèmes des utilisateurs."

- [LND #8096][] ajoute un "tampon d'augmentation des frais". Dans le protocole LN actuel, la partie qui finance seule un canal est
  responsable du paiement de tous les frais onchain inclus directement <!-- endogenously --> dans la transaction d'engagement et les
  transactions HTLC-Success et HTLC-Timeout pré-signées (transactions HTLC-X). Si la partie qui finance manque de fonds dans le canal
  et si les taux de frais augmentent, la partie qui finance peut ne pas être en mesure d'accepter un nouveau paiement entrant car elle
  n'a pas suffisamment de fonds pour payer ses frais, bien qu'un paiement entrant augmenterait le solde de la partie qui
  finance, si le paiement est réglé. Pour éviter ce type de problème de canal bloqué, une recommandation dans [BOLT2][] (ajoutée il y a
  plusieurs années dans [BOLTs #740][]) suggère que le financeur conserve volontairement une réserve supplémentaire de fonds pour
  garantir qu'un paiement supplémentaire puisse être reçu même si les taux de frais augmentent. LND met maintenant en œuvre cette
  solution, qui est également mise en œuvre par Core Lightning et Eclair (voir les Bulletins [#85][news85 stuck] et [#89][news89 stuck]).

- [LND #8095][] et [#8142][lnd #8142] ajoutent une logique supplémentaire à certaines parties du code source de LND pour gérer les
  [chemins aveugles][topic rv routing]. Cela fait partie du travail en cours visant à ajouter une prise en charge complète des chemins
  aveugles à LND.

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 15:00" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="28134,29058,29200,28890,2808,8188,8096,8095,8142,740" %}
[morehouse delving]: https://delvingbitcoin.org/t/dos-disclosure-channel-open-race-in-cln/385
[morehouse blog]: https://morehouse.github.io/lightning/cln-channel-open-race/
[news266 dos]: /fr/newsletters/2023/08/30/#divulgation-d-une-vulnerabilite-passee-de-ln-liee-au-financement-fictif
[script wiki]: https://en.bitcoin.it/wiki/Script#Arithmetic
[news166 tluv]: /en/newsletters/2021/09/15/#amount-introspection
[news283 exits]: /fr/newsletters/2024/01/03/#regroupement-des-paiements-de-sortie-de-pool-avec-delegation-a-l-aide-de-preuves-de-fraude
[daftuar cluster]: https://delvingbitcoin.org/t/an-overview-of-the-cluster-mempool-proposal/393/
[news280 cluster]: /fr/newsletters/2023/12/06/#discussion-sur-le-cluster-mempool
[news267 compress]: /fr/newsletters/2023/09/06/#compression-des-transactions-bitcoin
[briar compress]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2024-January/022274.html
[compress spec]: https://github.com/bitcoin/bitcoin/blob/7e8511c1a8229736d58bd904595815636f410aa8/doc/compressed_transactions.md
[news201 mev]: /en/newsletters/2022/05/25/#miner-extractable-value-discussion
[news266 lnbugs]: /fr/newsletters/2023/08/30/#divulgation-d-une-vulnerabilite-passee-de-ln-liee-au-financement-fictif
[condition de concurrence]: https://fr.wikipedia.org/wiki/Condition_de_course
[morehouse full]: https://morehouse.github.io/lightning/cln-channel-open-race/
[black lnhance]: https://delvingbitcoin.org/t/lnhance-bips-and-implementation/376/
[stewart 64]: https://delvingbitcoin.org/t/64-bit-arithmetic-soft-fork/397/
[daftuar cluster]: https://delvingbitcoin.org/t/an-overview-of-the-cluster-mempool-proposal/393/
[sanders mev]: https://delvingbitcoin.org/t/ephemeral-anchors-and-mev/383/
[bip 64]: https://github.com/bitcoin/bips/pull/1538
[clé interne taproot]: /en/newsletters/2019/05/14/#complex-spending-with-taproot
[news56 carveout]: /en/newsletters/2019/07/24/#bitcoin-core-15681
[news269 rpc]: /fr/newsletters/2023/09/20/#bitcoin-core-28448
[news85 stuck]: /en/newsletters/2020/02/19/#c-lightning-3500
[news89 stuck]: /en/newsletters/2020/03/18/#eclair-1319
[ldk 0.0.119]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.0.119
[rubin templating]: https://freenode.irclog.whitequark.org/bitcoin-wizards/2019-05-24#24661606;
