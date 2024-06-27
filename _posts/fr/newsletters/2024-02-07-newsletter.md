---
title: 'Bulletin Hebdomadaire Bitcoin Optech #288'
permalink: /fr/newsletters/2024/02/07/
name: 2024-02-07-newsletter-fr
slug: 2024-02-07-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine annonce la divulgation publique d'un bug de blocage dans Bitcoin Core qui affecte LN, soulève une
préoccupation concernant l'ouverture sécurisée de nouveaux canaux zero-conf compatibles avec la proposition de la version 3 des
restrictions de la topologie, décrit une règle que de nombreux protocoles de contrat doivent suivre lorsqu'ils permettent à une partie
externe de contribuer à une transaction, résume plusieurs discussions sur une proposition de nouvelles règles de remplacement de
transaction pour éviter le blocage des transactions, et fournit une brève mise à jour de la liste de diffusion Bitcoin-Dev.

## Actualités

- **Divulgation publique d'un bug de blocage dans Bitcoin Core affectant LN :**
  Eugene Siegel a [annoncé][siegel stall] à Delving Bitcoin un bug dans
  Bitcoin Core qu'il avait [divulgué de manière responsable][topic responsible
  disclosures] il y a près de trois ans. Bitcoin Core 22 et les versions ultérieures
  contiennent des correctifs pour le bug, mais de nombreuses personnes utilisent encore des versions affectées et certains de ces
  utilisateurs pourraient également utiliser des implémentations LN ou d'autres logiciels de protocole de contrat qui pourraient être
  vulnérables à l'exploitation du bug. Il est fortement recommandé de passer à Bitcoin Core 22 ou une version ultérieure. À notre
  connaissance, personne n'a perdu de fonds en raison de l'attaque décrite ci-dessous.

  Un attaquant trouve un nœud de transfert LN associé à un
  nœud Bitcoin de relais exécutant une version antérieure de
  Bitcoin Core version 22. L'attaquant ouvre de nombreuses connexions distinctes vers un nœud Bitcoin de la victime. L'attaquant tente
  ensuite de livrer les nouveaux blocs trouvés à la victime plus rapidement que tout autre pair honnête, ce qui a pour conséquence que
  le nœud de la victime attribue automatiquement des pairs contrôlés par l'attaquant à tous les emplacements à large bande passante de
  [relais de blocs compacts][topic compact block relay] de la victime.

  Après avoir obtenu le contrôle de nombreux emplacements de pair Bitcoin de la victime, l'attaquant utilise les canaux qu'il contrôle
  de chaque côté de la victime pour transférer les paiements qu'il crée. Par exemple :

  ```
  Dépensier de l'attaquant -> Transmetteur de la victime -> Récepteur de l'attaquant
  ```

  L'attaquant travaille avec un mineur pour créer un bloc qui ferme unilatéralement le côté récepteur du canal sans relayer la
  transaction dans un état non confirmé (cette assistance du mineur est uniquement nécessaire lors de l'attaque d'une implémentation
  LN qui surveille le mempool pour les transactions). Ce bloc, ou un autre bloc créé par le mineur, réclame également le paiement en
  libérant le préimage [HTLC][topic htlc]. Normalement, le nœud Bitcoin de la victime verrait le bloc, donnerait ce bloc à son nœud LN,
  et le nœud LN extraierait le préimage, ce qui lui permettrait de réclamer le montant du paiement du côté dépensier, maintenant ainsi
  son transfert équilibré.

  Cependant, dans ce cas, l'attaquant utilise cette attaque de blocage divulguée pour empêcher le nœud Bitcoin Core d'apprendre
  l'existence des blocs contenant le préimage. L'attaque de blocage profite du fait que les anciennes versions de Bitcoin Core sont
  prêtes à attendre jusqu'à 10 minutes qu'un pair livre un bloc qu'il a annoncé avant de demander ce bloc à un autre pair. Étant donné
  une moyenne de 10 minutes entre les blocs, cela signifie qu'un attaquant qui contrôle _x_ connexions peuvent retarder la réception
  d'un bloc par un nœud Bitcoin pendant environ le temps nécessaire pour produire _x_ blocs. Si le paiement de transfert doit être
  réclamé dans les 40 blocs, un attaquant contrôlant 50 connexions a de bonnes chances d'empêcher le nœud Bitcoin de voir le bloc
  contenant la préimage avant que le nœud dépensier ne puisse recevoir un remboursement du paiement. Si cela se produit, le nœud
  dépensier de l'attaquant n'a rien payé et le nœud receveur de l'attaquant a reçu une somme extraite du nœud de la victime.

  Comme le rapporte Siegel, deux modifications ont été apportées à Bitcoin Core pour éviter les blocages :

  - [Bitcoin Core #22144][] randomise l'ordre dans lequel les pairs sont servis dans le thread de traitement des messages. Voir le
    [Bulletin #154][news154 stall].

  - [Bitcoin Core #22147][] conserve au moins un pair compact à haut débit sortant même si les pairs entrants semblent mieux fonctionner.
    Le nœud local sélectionne ses pairs sortants, ce qui signifie qu'ils sont moins susceptibles d'être sous le contrôle d'un attaquant,
    il est donc utile de conserver au moins un pair sortant pour des raisons de sécurité.

- **Ouverture sécurisée de canaux sans confirmation avec des transactions v3 :** Matt Corallo a [publié][corallo 0conf] sur Delving
  Bitcoin pour discuter de la manière de permettre en toute sécurité l'[ouverture de canaux sans confirmation][topic zero-conf channels]
  lorsque la proposition de [politique de relais de transaction v3][topic v3 transaction relay] est utilisée. Les ouvertures de canaux
  sans confirmation sont de nouveaux canaux financés par une seule partie où le financeur donne une partie ou la totalité de ses fonds
  initiaux à l'accepteur. Ces fonds ne sont pas sécurisés tant que la transaction d'ouverture du canal ne reçoit pas un nombre suffisant
  de confirmations, il n'y a donc aucun risque que l'accepteur dépense une partie de ces fonds en utilisant le protocole LN standard.
  La proposition initiale de la politique de relais de transaction v3 ne permettrait qu'à une transaction v3 non confirmée d'avoir au
  maximum un seul enfant dans le mempool ; on s'attend à ce que l'enfant unique [augmente les frais CPFP][topic cpfp] de son parent si
  nécessaire.

  Ces règles v3 sont incompatibles avec la possibilité pour les deux parties d'augmenter les frais d'une ouverture de canal sans
  confirmation : la transaction de financement qui crée le canal est le parent d'une transaction v3 qui ferme le canal et le
  grand-parent d'une transaction v3 pour augmenter les frais. Étant donné que les règles v3 ne permettent qu'un seul parent et un seul
  enfant, il n'y a aucun moyen d'augmenter les frais de la transaction de financement sans modifier la manière dont elle est créée.
  Bastien Teinturier [remarque][teinturier splice] que [le splicing][topic splicing] rencontre un problème similaire.

  Au moment de la rédaction de cet article, la principale solution proposée semble être de modifier les transactions de financement
  et de raccordement pour inclure une sortie supplémentaire pour l'augmentation des frais CPFP, d'attendre que le [mempool en
  cluster][topic cluster mempool] permette espérons-le à v3 de permettre des topologies plus permissives (c'est-à-dire plus d'un
  parent, un enfant), puis de supprimer la sortie supplémentaire au profit de l'utilisation d'une topologie plus permissive.

- **Exigence de vérifier que les entrées utilisent SegWit dans les protocoles vulnérables à la malléabilité des txid :**
  Bastien Teinturier [a publié][teinturier segwit] sur Delving Bitcoin pour décrire une exigence facile à négliger pour les protocoles
  dans lesquels un tiers contribue à une transaction dont le txid ne doit pas changer après qu'un autre utilisateur ait contribué une à
  signature de transaction. Par exemple, dans un [canal LN à financement double][topic dual funding], Alice et Bob peuvent tous deux
  contribuer à une entrée. Pour s'assurer qu'ils reçoivent tous deux un remboursement si l'autre partie refuse de coopérer
  ultérieurement, ils créent et signent une dépense de la transaction de financement, qu'ils conservent off-chain sauf s'ils en ont
  besoin. Après avoir tous les deux signé la transaction de remboursement, ils peuvent tous les deux en toute sécurité signer et diffuser
  la transaction de financement parent. Étant donné que la transaction de remboursement enfant dépend de la transaction de financement
  parent ayant le txid attendu, ce processus est sûr uniquement s'il n'y a aucun risque de malléabilité du txid.

  Segwit empêche la malléabilité du txid, mais seulement si toutes les entrées de la transaction dépensent des sorties segwit de
  transactions précédentes. Pour segwit v0, la seule façon pour Alice d'être sûre que Bob dépense une sortie segwit v0 est qu'elle
  obtienne une copie de la transaction précédente complète qui contenait la sortie de Bob. Si Alice ne fait pas cette vérification,
  Bob peut mentir en prétendant dépenser une sortie segwit et dépenser plutôt une sortie héritée qui lui permet de muter le txid, ce
  qui lui permet d'invalider la transaction de remboursement et de refuser de rendre des fonds à Alice à moins qu'elle accepte de lui
  payer une rançon.

  Pour segwit v1 ([taproot][topic taproot]), chaque signature `SIGHASH_ALL` s'engage directement à chaque sortie précédente dépensée
  dans la transaction (voir le [Bulletin #97][news97 spk]), donc Alice peut exiger que Bob divulgue son scriptPubKey (qu'elle pourrait
  de toute façon apprendre à partir d'autres informations que Bob doit divulguer pour créer une transaction partagée). Alice vérifie
  que le scriptPubKey utilise segwit, soit v0 soit v1, et que sa signature s'y engage. Maintenant, si Bob a menti et avait en réalité
  une sortie non segwit, l'engagement fait par la signature d'Alice ne serait pas valide, donc la signature ne serait pas valide, la
  transaction de financement ne serait pas confirmée et il n'y aurait pas besoin de remboursement.

  Cela conduit à deux règles que les protocoles dépendant de remboursements pré-signés doivent suivre pour des raisons de sécurité :

  1. Si vous contribuez à une entrée, préférez contribuer à une entrée qui est la dépense d'une sortie segwit v1, obtenez les sorties
     précédentes de toutes les autres dépenses dans la transaction, vérifiez qu'elles utilisent toutes des scriptPubKeys segwit et
     engagez-vous à elles en utilisant votre signature.

  2. Si vous ne contribuez pas à une entrée ou si vous ne dépensez pas une sortie segwit v1, obtenez les transactions précédentes
     complètes pour toutes les entrées, vérifiez que leurs sorties dépensées dans cette transaction sont toutes des sorties segwit
     et engagez-vous à ces transactions en utilisant votre signature. Vous pouvez également utiliser cette deuxième procédure dans
     tous les cas, mais dans le pire des cas, elle consommera près de 20 000 fois plus de bande passante que la première procédure.  <!--
     ~4 000 000 octets de transaction divisés par ~22 octets de scriptPubKey P2WPKH -->

- **Proposition de remplacement par feerate pour échapper au pinning :** Peter Todd [a posté][todd rbfr] sur la liste de diffusion
  Bitcoin-Dev une proposition pour un ensemble de politiques de [remplacement de transaction][topic rbf] qui peuvent être appliquées même
  lorsque les politiques de remplacement par frais (RBF) existantes n'autorisent pas le remplacement d'une transaction. Sa proposition se
  décline en deux variations différentes :

  - *Remplacement pur par feerate (RBFr pur) :* une transaction actuellement dans le mempool peut être remplacée par une transaction
    en conflit qui paie un feerate significativement plus élevé (par exemple, le remplaçant paie un feerate 2 fois plus élevé que celui
    de la transaction remplacée).

  - *Remplacement ponctuel par feerate (RBFr ponctuel) :* une transaction actuellement dans le mempool peut être remplacée par une
    transaction en conflit qui paie un feerate légèrement plus élevé (par exemple, 1,25x), à condition que le feerate du remplaçant
    soit également suffisamment élevé pour le placer parmi les ~1 000 000 vbytes supérieurs du mempool (ce qui signifie que le
    remplaçant serait miné si un bloc était produit immédiatement après son acceptation).

  Mark Erhardt a décrit ([1][erhardt rbfr1], [2][erhardt rbfr2]) comment les politiques proposées pourraient être détournées
  pour permettre de gaspiller une quantité infinie de bande passante des nœuds à un coût minimal pour un attaquant. Peter Todd
  a mis à jour les politiques pour éliminer cet abus particulier, mais d'autres préoccupations ont été soulevées par Gregory Sanders et
  Gloria Zhao dans un fil de discussion [Delving Bitcoin][sz rbfr] :

  - "Pré-cluster mempool, il est très difficile de raisonner sur tout cela. La première itération de l'idée de Peter était défectueuse,
    permettant un relais gratuit illimité. Il prétend l'avoir corrigée en appliquant un correctif à chaud à l'idée avec des
    restrictions RBF supplémentaires, mais comme d'habitude, il est très difficile, voire impossible, de raisonner sur les règles RBF
    actuelles. Je pense qu'il serait préférable de se concentrer sur l'établissement des bons incitatifs RBF avant d'abandonner
    complètement l'idée de protection du relais gratuit." ---Sanders

  - "Le mempool tel qu'il existe aujourd'hui ne prend pas en charge un moyen efficace de calculer le "score du mineur" ou la
    compatibilité des incitations, en raison de la taille des clusters non bornée. [...] Un avantage du mempool en cluster est la
    possibilité de calculer des choses comme le score du mineur et la compatibilité des incitations dans l'ensemble du mempool. De
    même, un avantage de la version 3 est de pouvoir le faire avant le mempool en cluster en raison de la topologie restreinte. Avant
    que les gens ne relèvent le défi de concevoir et de mettre en œuvre le mempool en cluster, j'avais présenté la version 3 comme des
    "limites de cluster" sans avoir à implémenter réellement des limites de cluster, car c'est l'une des seules façons de codifier une
    limite de cluster (count=2) en utilisant les limites de package existantes (ancestors=2, descendants=2). Une fois que vous passez
    à 3, vous pouvez à nouveau avoir des clusters infinis). Un autre avantage de la version 3 est qu'elle aide à débloquer le mempool
    en cluster, ce qui, à mon avis, est une évidence. En résumé, je ne pense pas que la proposition de remplacement ponctuel par
    feerate fonctionne (c'est-à-dire qu'elle ne présente pas de problème de relais gratuit et qu'elle est réalisable à mettre en œuvre
    avec précision)." ---Zhao

  Les discussions séparées n'ont pas été conciliées à ce jour. Peter Todd a publié une [implémentation expérimentale][libre relay].
  des règles de remplacement par des règles de frais.

- **Mise à jour de la migration de la liste de diffusion Bitcoin-Dev :** au moment de la rédaction de ce texte, la liste de diffusion
  Bitcoin-Dev n'accepte plus de nouveaux e-mails dans le cadre du processus de migration vers un serveur de liste différent (voir le
  [Bulletin #276][news276 ml]). Optech fournira une mise à jour lorsque la migration sera terminée.

## Mises à jour et versions candidates

*Nouvelles versions et versions candidates pour les principaux projets d’infrastructure Bitcoin.
 Veuillez envisager de passer aux nouvelles versions ou d’aider à tester les versions candidates.*

- [LND v0.17.4-beta][] est une version de maintenance de cette implémentation populaire de nœud LN. Ses notes de version indiquent :
  "il s'agit d'une version de correction rapide qui corrige plusieurs bugs : ouverture du canal bloquée jusqu'au redémarrage, fuite de
  mémoire lors de l'utilisation du mode de sondage pour `bitcoind`, perte de synchronisation pour les nœuds élagués et le proxy REST
  qui ne fonctionne pas lorsque le chiffrement du certificat TLS est activé."

## Changements notables dans le code et la documentation

*Changements notables cette semaine dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning repo], [Eclair][eclair repo],
[LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Interface de portefeuille matériel (HWI)][hwi repo],
[Rust Bitcoin][rust bitcoin repo], [Serveur BTCPay][btcpay server repo], [BDK][bdk repo], [Propositions d'amélioration de Bitcoin
(BIP)][bips repo], [Lightning BOLTs][bolts repo], [Inquisition Bitcoin][bitcoin inquisition repo] et [BINANAs][binana repo].*

- [Bitcoin Core #29189][] déprécie libconsensus. Libconsensus était une tentative de rendre la logique de consensus de Bitcoin Core
  utilisable dans d'autres logiciels. Cependant, la bibliothèque n'a pas connu d'adoption significative et elle est devenue un fardeau
  pour la maintenance de Bitcoin Core. Le plan est de "ne pas la migrer vers CMake et de la laisser se terminer avec la version 27.
  Tous les cas d'utilisation restants pourraient être gérés à l'avenir par [libbitcoinkernel][]."

- [Bitcoin Core #28956][] supprime l'heure ajustée de Bitcoin Core et avertit les utilisateurs si l'horloge de leur ordinateur semble
  ne pas être synchronisée avec le reste du réseau. L'heure ajustée était un ajustement automatique de l'heure d'un nœud local basé sur
  l'heure rapportée par ses pairs. Cela pouvait aider un nœud avec une horloge légèrement incorrecte à apprendre de ses pairs, lui
  permettant d'éviter de rejeter inutilement des blocs et de donner également une heure plus précise aux blocs qu'il produisait.
  Cependant, l'heure ajustée a également causé des problèmes par le passé et n'apporte pas d'avantages significatifs aux nœuds du réseau
  actuel. Voir le [Bulletin #284][news284 adjtime] pour une couverture précédente de cette PR.

- [Bitcoin Core #29347][] active le [transport P2P v2][topic v2 p2p transport] par défaut. Les nouvelles connexions entre deux pairs qui
  prennent en charge tous les deux le protocole v2 utiliseront le chiffrement.

- [Core Lightning #6985][] ajoute des options à `hsmtool` qui lui permettent de renvoyer les clés privées du portefeuille onchain d'une
  manière qui permet d'importer ces clés dans un autre portefeuille.

- [Core Lightning #6904][] apporte diverses mises à jour au code de gestion de la connexion et du gossip de CLN. Un changement visible
  pour l'utilisateur est l'ajout de champs indiquant quand un pair a eu pour la dernière fois une connexion stable avec le nœud local
  pendant au moins une minute. Cela permet de supprimer les pairs ayant des connexions instables.

- [Core Lightning #7022][] supprime `lnprototest` de l'infrastructure de test de Core Lightning. Voir le [Bulletin #145][news145 lnproto]
  pour notre description de leur ajout.

- [Core Lightning #6936][] ajoute une infrastructure pour faciliter l'obsolescence des fonctionnalités de CLN. Les fonctionnalités sont
  maintenant dépréciées dans le code à l'aide de fonctions qui désactivent automatiquement ces fonctionnalités par défaut en fonction de
  la version actuelle du programme. Les utilisateurs peuvent toujours activer de force les fonctionnalités même après la version qui les désactive
  tant que le code existe toujours. Cela évite un problème occasionnel où une fonctionnalité de CLN serait signalée
  comme dépréciée mais continuerait de fonctionner par défaut pendant longtemps après la planification de sa suppression, ce qui pourrait
  amener les utilisateurs à continuer de dépendre de cette fonctionnalité et rendre la suppression réelle plus difficile.

- [LND #8345][] commence à tester si les transactions sont susceptibles d'être relayées avant de les diffuser en appelant le RPC
  `testmempoolaccept` d'un nœud complet lorsque cela est disponible. Cela permet au nœud de détecter d'éventuels problèmes avec la
  transaction avant d'envoyer quoi que ce soit à un tiers, ce qui peut accélérer la découverte d'un problème et limiter les dommages
  potentiels causés par un bug. Des versions du RPC `testmempoolaccept` sont disponibles dans Bitcoin Core, la plupart des forks
  logiciels modernes de Bitcoin Core et le nœud complet btcd.

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 15:00" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="29189,28956,29347,6985,6904,7022,6936,7022,6936,8345,22144,22147" %}
[news154 stall]: /en/newsletters/2021/06/23/#bitcoin-core-22144
[news145 lnproto]: /en/newsletters/2021/04/21/#c-lightning-4444
[siegel stall]: https://delvingbitcoin.org/t/block-stalling-issue-in-core-prior-to-v22-0/499/
[corallo 0conf]: https://delvingbitcoin.org/t/0conf-ln-channels-and-v3-anchors/494/
[teinturier splice]: https://delvingbitcoin.org/t/0conf-ln-channels-and-v3-anchors/494/2
[teinturier segwit]: https://delvingbitcoin.org/t/malleability-issues-when-creating-shared-transactions-with-segwit-v0/497
[news97 spk]: /en/newsletters/2020/05/13/#request-for-an-additional-taproot-signature-commitment
[todd rbfr]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2024-January/022298.html
[erhardt rbfr1]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2024-January/022302.html
[erhardt rbfr2]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2024-January/022316.html
[sz rbfr]: https://delvingbitcoin.org/t/replace-by-fee-rate-vs-v3/488/
[libre relay]: https://github.com/petertodd/bitcoin/tree/libre-relay-v26.0
[libbitcoinkernel]: https://github.com/bitcoin/bitcoin/issues/27587
[news284 adjtime]: /fr/newsletters/2024/01/10/#bitcoin-core-pr-review-club
[news276 ml]: /fr/newsletters/2023/11/08/#hebergement-de-la-liste-de-diffusion
[lnd v0.17.4-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.17.4-beta
