---
title: 'Bulletin Bitcoin Optech #284'
permalink: /fr/newsletters/2024/01/10/
name: 2024-01-10-newsletter-fr
slug: 2024-01-10-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine résume les discussions sur les ancres LN et les éléments de la proposition de relais de transaction v3,
et annonce la mise en œuvre d'une recherche sur LN-Symmetry. Nous incluons également nos sections habituelles avec le résumé de la
réunion du Bitcoin Core PR Review Club et la description des changements notables apportés aux principaux logiciels d'infrastructure
Bitcoin.

## Nouvelles

- **Discussion sur les ancres LN et la proposition de relais de transaction v3 :**
  Antoine Poinsot a [publié][poinsot v3] sur Delving Bitcoin pour encourager la discussion sur les propositions de [relais de transaction
  v3][topic v3 transaction relay] et [d'ancres éphémères][topic ephemeral anchors]. Le fil de discussion semble avoir été motivé par
  la critique de Peter Todd [sur][todd v3] la politique de relais v3 sur son blog. Nous avons arbitrairement divisé la discussion en
  plusieurs parties :

  - **L'utilisation fréquente de frais exogènes peut compromettre la décentralisation du minage :**
    Une version idéale du protocole Bitcoin récompenserait chaque mineur proportionnellement à sa puissance de hachage. Les frais
    implicites payés dans les transactions préservent cette propriété : un mineur possédant 10 % de la puissance de hachage totale
    a 10 % de chances de capturer des frais pour le prochain bloc, tandis qu'un mineur possédant 1 % de la puissance de hachage a 1 % de
    chances. Les frais payés en dehors des transactions et directement aux mineurs, appelés [frais hors bande][topic out-of-band fees],
    violent cette propriété : un système qui rémunère les mineurs contrôlant ensemble plus de 55 % de la puissance de hachage a 99 % de
    chances de confirmer une transaction dans les 6 blocs suivants<!-- 1 - (1 - 0.55)**6 -->, ce qui risque de réduire les efforts pour
    rémunérer les petits mineurs possédant 1 % ou moins de la puissance de hachage. Si les petits mineurs sont rémunérés de manière
    proportionnellement inférieure aux grands mineurs, le minage se centralisera naturellement, ce qui réduira le nombre d'entités à
    compromettre pour censurer les transactions à confirmer.

    Les protocoles utilisés activement tels que [LN-Penalty avec ancres][topic anchor outputs] (LN-Ancres), [DLC][dlc cpfp] et
    [validation côté client][topic client-side validation] permettent à au moins certaines de leurs transactions onchain de payer des
    frais _exogènes_, c'est-à-dire que les frais payés par le cœur de la transaction peuvent être augmentés avec des frais payés à
    l'aide d'un ou plusieurs UTXO indépendants. Par exemple, dans LN-Ancres, la transaction d'engagement comprend une sortie pour
    chaque partie permettant d'augmenter les frais à l'aide de [CPFP][topic cpfp] (la transaction enfant dépensant un UTXO
    supplémentaire) et les transactions HTLC-Success et HTLC-Failure (transactions HTLC-X) sont partiellement signées à l'aide de
    `SIGHASH_SINGLE|SIGHASH_ANYONECANPAY` afin de pouvoir être agrégées dans une seule transaction avec au moins une entrée
    supplémentaire pour payer les frais (l'entrée supplémentaire étant un UTXO séparé).

    En se concentrant sur une version de réflexion de LN utilisant [P2TR][topic taproot] et la proposition des ancres éphémères,
    Peter Todd soutient que sa dépendance aux frais exogènes incite fortement à payer des frais hors bande. En particulier, la
    fermeture unilatérale d'un canal sans paiements en attente ([HTLC][topic htlc]) permettrait à un grand mineur acceptant des frais
    hors bande d'inclure deux fois plus de transactions de fermeture dans un bloc qu'un mineur plus petit qui n'accepte que des frais
    en bande payés via le CPFP. Le grand mineur pourrait encourager cela de manière rentable en offrant une remise modérée aux
    utilisateurs payant hors bande. Peter Todd considère cela comme une menace pour la décentralisation.

    Le message suggère également que certaines utilisations de frais exogènes dans les protocoles sont acceptables, donc la
    préoccupation pourrait être liée à la fréquence de leur utilisation attendue et à la différence de taille relative entre leur
    utilisation et le paiement hors bande. En d'autres termes, des fermetures unilatérales fréquentes sans paiements en attente avec
    un surcoût de 100% seraient probablement considérées comme plus risquées que des fermetures unilatérales potentiellement plus
    rares avec 20 HTLC en attente où le surcoût est inférieur à 10%.

- **Implications des frais exogènes sur la sécurité, la scalabilité et les coûts :** Le message de Peter Todd note également que les
  conceptions existantes telles que [LN-Anchors][topic anchor outputs] et les conceptions futures qui utilisent [des ancres
  éphémères][topic ephemeral anchors] nécessitent que chaque utilisateur conserve un UTXO supplémentaire dans son portefeuille pour
  utiliser l'augmentation de frais essentielle. Étant donné que la création d'UTXO coûte de l'espace dans les blocs, cela réduit de
  moitié ou plus le nombre maximum d'utilisateurs indépendants du protocole en théorie. Cela signifie également qu'un utilisateur ne
  peut pas allouer en toute sécurité l'intégralité de son solde de portefeuille à ses canaux LN, ce qui aggrave l'expérience utilisateur
  de LN. Enfin, l'utilisation de [l'augmentation de frais CPFP][topic cpfp] ou l'ajout de transactions supplémentaires pour payer des
  frais de manière exogène nécessite plus d'espace dans les blocs et le paiement de frais de transaction plus élevés que le paiement
  direct des frais à partir de la valeur d'entrée d'une transaction (frais endogènes), ce qui le rend plus cher en théorie même si les
  autres problèmes ne sont pas une préoccupation.

- **Les ancres éphémères introduisent une nouvelle attaque de blocage :** comme décrit dans [la newsletter de la semaine
  dernière][news283 pinning], Peter Todd décrit une attaque mineure de blocage contre les utilisations d'ancres éphémères. Pour une
  transaction d'engagement sans paiements en attente (HTLC), un attaquant non privilégié pourrait créer une situation où un utilisateur
  honnête devrait payer de 1,5x à 3,7x plus de frais pour obtenir le taux de frais qu'il avait prévu. Cependant, si l'utilisateur honnête
  choisissait d'être [patient][harding pinning] au lieu de payer des frais supplémentaires, l'attaquant finirait par payer une partie ou
  la totalité des frais de l'utilisateur honnête. Étant donné que les transactions d'engagement sans paiements en attente n'ont pas
  d'urgence liée à un verrouillage temporel, de nombreux utilisateurs honnêtes pourraient choisir d'être patients et de faire confirmer
  leur transaction aux frais de l'attaquant. L'attaque fonctionne également lorsque des HTLC sont utilisés, mais cela coûte moins cher
  à l'utilisateur honnête de s'en libérer et peut toujours entraîner une perte d'argent pour l'attaquant.

- **Une alternative : utiliser des frais endogènes avec des augmentations RBF incrémentielles pré-signées :** Peter Todd suggère et
  analyse une approche alternative, consistant à signer plusieurs versions de chaque transaction d'engagement à des taux de frais
  différents. Par exemple, il suggère de signer 50 versions différentes de la transaction d'engagement LN-Penalty à des taux de frais
  commençant à 10 sats/vbyte et augmentant à chaque version de 10% jusqu'à ce qu'une transaction payant 1 000 sats/vbyte soit signée.
  Pour une transaction d'engagement sans paiements en attente (HTLC), son analyse indique que le temps de signature serait d'environ
  5 millisecondes. Cependant, pour chaque HTLC attaché à la transaction d'engagement, le nombre de signatures augmenterait de 50 et le
  temps de signature augmenterait de 5 millisecondes. Bastien Teinturier a fait référence à une [discussion précédente][bolts #1036]
  qu'il avait lancée sur une approche similaire.

  Bien que l'idée puisse fonctionner dans certaines situations, le message de Peter Todd souligne que les frais endogènes avec des
  augmentations de frais incrémentielles pré-signées ne sont pas un remplacement satisfaisant pour les frais exogènes dans tous les cas.
  Lorsque les délais requis pour la pré-signature des transactions d'engagement contenant plusieurs HTLC sont multipliés par les
  plusieurs sauts sur un chemin de paiement typique, les [délais][harding delays] peuvent facilement dépasser une seconde et, du moins
  en théorie, s'étendre à des délais de plus d'une minute. Peter Todd note que le délai pourrait être réduit à un temps
  approximativement constant si l'opcode [SIGHASH_ANYPREVOUT][topic sighash_anyprevout] proposé (APO) était disponible.

  Même si le délai était constant à 5 millisecondes, il est [possible][harding stuckless] que cela puisse conduire à ce que les nœuds
  de transfert utilisant des frais endogènes gagnent moins de frais de transfert que les nœuds utilisant des frais exogènes en raison
  des effets anticipés des payeurs LN effectuant éventuellement des [surpaiements redondants][topic redundant overpayments] qui
  récompenseront économiquement un transfert plus rapide par rapport à un transfert plus lent, même lorsque la différence est de
  l'ordre des millisecondes.

  Un défi supplémentaire consisterait à utiliser les mêmes frais endogènes pour les transactions HTLC-Success et HTLC-Timeout
  pré-signées (transactions HTLC-X). Même avec APO, cela impliquerait naïvement de créer <i>n<sup>2</sup></i> signatures, bien que
  Peter Todd note que le nombre de signatures pourrait être réduit en supposant que les transactions HTLC-X paieraient un taux de frais
  similaire à la transaction d'engagement.

  <p><!-- En utilisant notre calculateur de transactions, 1 entrée, 22 sorties pour 20 HTLC représente 1014 vbytes ;
        BOLT3 "poids attendu" donne un poids HTLC-X dans le pire des cas de 705
        = 176,25 vbytes, multiplié par 20 donne 3525, plus 1014 donne 4539. Multipliez
        tout par 1 000 s/vb pour obtenir le total en sats --></p>

  Il y a eu un [débat non résolu][teinturier fees] sur le fait de savoir si les frais endogènes entraîneraient une quantité excessive
  de capital réservée aux frais. Par exemple, si Alice signe des variantes de frais de 10 s/vb à 1 000 s/vb, elle doit prendre des
  décisions en fonction de la possibilité que son homologue Bob mette la variante de 1 000 s/vb on-chain, même si elle ne paierait pas
  ce taux de frais elle-même. Cela signifie qu'elle ne peut pas accepter les paiements de Bob où il dépense l'argent dont il aurait
  besoin pour la variante de 1 000 s/vb. Par exemple, une transaction d'engagement avec 20 HTLCs ferait 1 million de sats temporairement
  non dépensables (450 USD au moment de l'écriture). Si des frais endogènes étaient également utilisés pour les transactions HTLC-X,
  le montant temporairement non dépensable pour 20 HTLCs serait plus proche de 4,5 millions de sats (2 050 USD). En comparaison, si Bob
  devait payer ses frais de manière exogène, alors Alice n'aurait pas besoin de réduire la capacité du canal pour sa sécurité.

- **Conclusions générales :** la discussion était en cours au moment de l'écriture. Peter Todd a conclu que "l'utilisation existante
  des sorties d'ancrage devrait être progressivement abandonnée en raison des risques de décentralisation des mineurs mentionnés
  ci-dessus ; le support des nouvelles sorties d'ancrage ne devrait pas être ajouté aux nouveaux protocoles ou à Bitcoin Core". Le
  développeur LN Rusty Russell a [posté][russell inline] à propos de l'utilisation d'une forme plus efficace de frais exogènes dans les
  nouveaux protocoles pour minimiser les préoccupations concernant les frais hors bande. Dans le fil Delving Bitcoin, d'autres
  développeurs travaillant sur LN, les transactions v3 et les ancres éphémères ont défendu l'utilité des ancres et il semblait probable
  qu'ils continueraient à travailler sur des protocoles liés à la v3. Nous fournirons des mises à jour dans les prochains bulletins si
  quelque chose de significatif change.

- **Implémentation de recherche LN-Symmetry** Gregory Sanders a [posté][sanders lns] sur Delving Bitcoin à propos d'une [implémentation
  de proof-of-concept][poc lns] qu'il a réalisée du protocole [LN-Symmetry][topic eltoo] (originellement appelé _eltoo_) en utilisant une
  version modifiée du logiciel Core Lightning. LN-Symmetry fournit des canaux de paiement bidirectionnels qui garantissent la possibilité
  de publier l'état le plus récent du canal on-chain sans avoir besoin de transactions de pénalité. Cependant, ils nécessitent
  d'autoriser une transaction enfant à dépenser n'importe quelle version possible d'une transaction parent, ce qui n'est possible qu'avec
  un changement de protocole de soft fork tel que [SIGHASH_ANYPREVOUT][topic sighash_anyprevout]. Sanders présente plusieurs points forts
  de son travail :

  - *Simplicité :* LN-Symmetry est un protocole beaucoup plus simple que le protocole LN-Penalty/[LN-Anchors][topic anchor outputs]
    actuellement utilisé.

  - *Pinning :* "Il est très difficile d'éviter [l'épinglage][topic transaction pinning]." Le travail de Sanders sur cette
    préoccupation lui a donné des idées et de l'inspiration qui ont conduit à ses contributions à [package relay][topic package relay]
    et à sa proposition largement saluée pour les [ancres éphémères][topic ephemeral anchors].

  - *CTV :* "[CTV][topic op_checktemplateverify] (par émulation) [...] a permis des 'avancées rapides' qui sont extrêmement simples et
    pourraient réduire les délais de paiement s'ils étaient largement adoptés."

  - *Pénalités :* Les pénalités ne semblaient vraiment pas nécessaires. C'était l'espoir pour LN-Symmetry, mais certaines personnes
    pensaient qu'un protocole de pénalité serait toujours nécessaire pour dissuader les contreparties malveillantes de tenter un vol.
    Le support des pénalités augmente considérablement la complexité du protocole et nécessite de réserver une partie des fonds du
    canal pour payer les pénalités, il est donc préférable de les éviter s'ils ne sont pas nécessaires pour la sécurité.

  - *Deltas d'expiration :* LN-Symmetry nécessite des deltas d'expiration HTLC plus longs que prévu. Lorsqu'Alice transfère un HTLC à
    Bob, elle lui donne un certain nombre de blocs pour réclamer ses fonds avec un préimage ; après l'expiration de ce délai, elle peut
    récupérer les fonds. Lorsque Bob transfère ensuite le HTLC à Carol, il lui donne un nombre inférieur de blocs pendant lesquels elle
    doit révéler le préimage. Le delta entre ces deux expirations est le "delta d'expiration HTLC". Sanders a constaté que le delta
    devait être suffisamment long pour empêcher la contrepartie de bénéficier si elle abandonnait le protocole en cours de route lors
    d'un engagement.

 Sanders travaille actuellement à l'amélioration de la mempool et de la politique de relais de Bitcoin Core, ce qui facilitera le
 déploiement de LN-Symmetry et d'autres protocoles à l'avenir.

## Bitcoin Core PR Review Club

*Dans cette section mensuelle, nous résumons une récente réunion du [Club de révision des PR de Bitcoin Core][Bitcoin Core PR Review Club]
en mettant en évidence certaines des questions et réponses importantes. Cliquez sur
une question ci-dessous pour voir un résumé de la réponse de la réunion.*

[Temps ajusté par Nuke (essai 2)][review club 28956] est un PR de Niklas Gögge qui modifie une vérification de validité de bloc liée à
l'horodatage du bloc. En gros, si l'horodatage d'un bloc (contenu dans son en-tête) est trop éloigné dans le passé ou dans le futur, le
nœud rejette le bloc comme étant invalide. Notez que si le bloc est invalide parce que son horodatage est trop éloigné dans le futur, il
peut devenir valide ultérieurement (bien que la chaîne puisse avoir avancé).

{% include functions/details-list.md
  q0="Est-il nécessaire que les en-têtes de bloc aient un horodatage ? Si oui, pourquoi ?"
  a0="Oui, l'horodatage est utilisé pour l'ajustement de la difficulté et pour valider les verrouillages temporels des transactions."
  a0link="https://bitcoincore.reviews/28956#l-39"

  q1="Quelle est la différence entre le temps médian passé (MTP) et le temps ajusté au réseau ? Lesquels de ces éléments sont pertinents
      pour le PR ?"
  a1="MTP est le temps médian des 11 derniers blocs et constitue la limite inférieure de validité de l'horodatage du bloc. Le temps
      ajusté au réseau est calculé en ajoutant notre propre temps à la médiane des décalages entre notre temps et celui d'une sélection
      aléatoire de 199 de nos pairs sortants (Cette médiane peut être négative). Le temps ajusté au réseau plus 2 heures est
      l'horodatage maximal valide du bloc. Seul le temps ajusté au réseau est pertinent pour ce PR."
  a1link="https://bitcoincore.reviews/28956#l-67"

  q2="Pourquoi ces temps sont-ils conceptuellement très différents ?"
  a2="MTP est uniquement défini pour tous les nœuds synchronisés sur la même chaîne ; il y a consensus sur l'heure. Le temps ajusté au
      réseau peut varier d'un nœud à l'autre."
  a2link="https://bitcoincore.reviews/28956#l-74"

  q3="Pourquoi n'utilisons-nous pas simplement MTP pour tout et abandonnons-nous le temps ajusté au réseau ?"
  a3="MTP est utilisé comme limite inférieure de validité de l'horodatage du bloc, mais il ne peut pas être utilisé comme limite
      supérieure car les horodatages futurs des blocs sont inconnus."
  a3link="https://bitcoincore.reviews/28956#l-77"

  q4="Pourquoi des limites sont-elles imposées sur l'écart autorisé entre l'horodatage de l'en-tête d'un bloc et l'horloge interne du
      nœud ? Et puisque nous n'exigeons pas un accord exact sur l'heure, ces limites peuvent-elles être rendues plus strictes ?"
  a4="Avoir une plage d'horodatage du bloc restreinte limite la capacité des nœuds malveillants à manipuler les ajustements de difficulté
      et la durée de verrouillage. Ces types d'attaques sont appelées attaques de manipulation temporelle. La plage valide peut être
      rendue plus stricte dans une certaine mesure, mais la rendre trop stricte pourrait entraîner des divisions temporaires de la
      chaîne, car certains nœuds peuvent rejeter des blocs que d'autres nœuds acceptent. Les horodatages des blocs n'ont pas besoin
      d'être exactement corrects, mais ils doivent suivre le temps réel sur le long terme."
  a4link="https://bitcoincore.reviews/28956#l-82"

  q5="Avant cette proposition de modification, pourquoi un attaquant essaierait-il de manipuler l'heure ajustée du réseau d'un nœud ?"
  a5="Si le nœud est un mineur, l'attaquant pourrait manipuler l'heure pour que les blocs qu'il mine soient rejetés par le réseau
      ou pour qu'il n'accepte pas un bloc valide, ou pour qu'il continue de gaspiller sa puissance de calcul sur une ancienne chaine
      (ces deux situations donneraient un avantage à un mineur concurrent) ;
      il pourrait aussi avoir pour objectif d'amener le nœud attaqué à suivre la mauvaise chaîne ; ou d'empêcher une transaction
      verrouillée dans le temps
      d'être minée quand elle devrait l'être ; ou encore d'effectuer une [attaque de dilatation temporelle][] sur le réseau Lightning."
  a5link="https://bitcoincore.reviews/28956#l-89"

  q6="Avant cette proposition de modification, comment un attaquant pouvait-il essayer de manipuler l'heure ajustée du réseau d'un nœud ?
      Quel(s) message(s) réseau utiliserait-il ?"
  a6="Un attaquant aurait dû vous envoyer des messages de version avec des horodatages manipulés provenant de plusieurs pairs qu'il
      contrôle. Il aurait dû vous amener à établir plus de 50 % de vos connexions sortantes vers ses nœuds, ce qui est difficile mais
      beaucoup plus facile que d'éclipser complètement le nœud."
  a6link="https://bitcoincore.reviews/28956#l-100"

  q7="Cette proposition de modification utilise l'horloge locale du nœud comme limite supérieure pour la validation des blocs, plutôt que
      l'heure ajustée du réseau. Pouvons-nous être sûrs que cela réduit les surfaces d'attaque ésotériques plutôt que de les augmenter ?"
  a7="Une discussion a eu lieu sans résolution claire quant à savoir s'il est plus facile pour un attaquant d'affecter l'ensemble de
      pairs d'un nœud ou son horloge interne (en utilisant des logiciels malveillants ou des manipulations NTP, par exemple), mais la
      plupart des participants ont convenu que cette proposition de modification est une amélioration."
  a7link="https://bitcoincore.reviews/28956#l-102"

  q8="Cette proposition de modification modifie-t-elle le comportement du consensus ? Si oui, s'agit-il d'un soft fork, d'un hard fork
      ou aucun des deux ? Pourquoi ?"
  a8="Étant donné que les règles de consensus ne peuvent pas prendre en compte des données extérieures à la chaîne de blocs (comme
      l'horloge de chaque nœud), cette proposition de modification ne peut pas être considérée comme un changement de consensus ; il
      s'agit simplement d'un changement de politique d'acceptation du réseau. Mais cela ne signifie pas que c'est facultatif ; avoir
      une règle de politique limitant l'écart possible entre l'horodatage d'un bloc et l'heure actuelle est
      [essentiel][se timestamp accecptance] pour la sécurité du réseau."
  a8link="https://bitcoincore.reviews/28956#l-141"

  q9="Quelles opérations dépendaient de l'heure ajustée du réseau avant cette proposition de modification ?"
  a9="Les fonctions [`TestBlockValidity`][TestBlockValidity function], [`CreateNewBlock`][CreateNewBlock function] (utilisée par les
      mineurs pour construire des modèles de blocs) et la fonction [`CanDirectFetch`][CanDirectFetch function] (utilisée dans la couche
      P2P). La variété de ces utilisations montre que cette proposition de modification n'affectent que la validité des blocs, mais il
      y a d'autres implications, que nous devons valider."
  a9link="https://bitcoincore.reviews/28956#l-197"
%}

## Changements notables dans le code et la documentation

*Changements notables cette semaine dans [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo], et
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [LND #8308][] augmente le `min_final_cltv_expiry_delta` de 9 à 18 comme recommandé par BOLT 02 pour les paiements par terminal.
  Cette valeur affecte les factures externes qui ne fournissent pas le paramètre `min_final_cltv_expiry`. Cette modification résout
  le problème d'interopérabilité découvert après que CLN a cessé d'inclure le paramètre lorsque la valeur par défaut de 18 était
  utilisée, comme [mentionné][cln hotfix] dans la bulletin de la semaine dernière.

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 15:00" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="1036,8308" %}
[poinsot v3]: https://delvingbitcoin.org/t/v3-transaction-policy-for-anti-pinning/340
[todd v3]: https://petertodd.org/2023/v3-transactions-review
[dlc cpfp]: https://github.com/discreetlogcontracts/dlcspecs/blob/master/Non-Interactive-Protocol.md
[news283 pinning]: /fr/newsletters/2024/01/03/#couts-d-epinglage-des-transactions-v3
[harding pinning]: https://delvingbitcoin.org/t/v3-transaction-policy-for-anti-pinning/340/22
[harding delays]: https://delvingbitcoin.org/t/v3-transaction-policy-for-anti-pinning/340/6
[harding stuckless]: https://delvingbitcoin.org/t/v3-transaction-policy-for-anti-pinning/340/5
[teinturier fees]: https://github.com/bitcoin/bitcoin/pull/28948#issuecomment-1873793179
[russell inline]: https://rusty.ozlabs.org/2024/01/08/txhash-tx-stacking.html
[sanders lns]: https://delvingbitcoin.org/t/ln-symmetry-project-recap/359
[poc lns]: https://github.com/instagibbs/lightning/tree/eltoo_support
[cln hotfix]: /fr/newsletters/2024/01/03/#core-lightning-6957
[review club 28956]: https://bitcoincore.reviews/28956
[attaque de dilatation temporelle]: /en/newsletters/2020/06/10/#time-dilation-attacks-against-ln
[se timestamp accecptance]: https://bitcoin.stackexchange.com/a/121251/97099
[TestBlockValidity function]: https://github.com/bitcoin/bitcoin/blob/063a8b83875997068b3eb506b5f30f2691d18052/src/validation.cpp#L4228
[CreateNewBlock function]: https://github.com/bitcoin/bitcoin/blob/063a8b83875997068b3eb506b5f30f2691d18052/src/node/miner.cpp#L106
[CanDirectFetch function]: https://github.com/bitcoin/bitcoin/blob/063a8b83875997068b3eb506b5f30f2691d18052/src/net_processing.cpp#L1314
