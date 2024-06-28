---
title: 'Bulletin Hebdomadaire Bitcoin Optech #291'
permalink: /fr/newsletters/2024/02/28/
name: 2024-02-28-newsletter-fr
slug: 2024-02-28-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine décrit une proposition de contrat sans nécessité de confiance pour des
futures sur les frais de transaction des mineurs, renvoie à un algorithme de sélection de pièces
pour les nœuds LN fournissant de la liquidité de double financement, détaille un prototype pour un
coffre utilisant `OP_CAT`, et discute de l'envoi et de la réception d'ecash en utilisant LN et
ZKCPs. Sont également incluses nos rubriques habituelles avec des questions et réponses populaires
de la communauté Bitcoin Stack Exchange, des annonces de nouvelles versions et
versions candidates, ainsi que les changements apportés aux principaux logiciels d'infrastructure Bitcoin.

## Nouvelles

- **Contrat sans confiance pour les futures sur les frais de transaction des mineurs :** ZmnSCPxj a
  [publié][zmnscpxj futures] sur Delving Bitcoin un ensemble de scripts qui permettront à deux parties
  de se payer mutuellement de manière conditionnelle en fonction du taux de frais marginal pour
  inclure une transaction dans un bloc futur. Par exemple, Alice est une utilisatrice qui prévoit
  d'inclure une transaction dans le bloc 1 000 000 (ou un bloc peu après). Bob est un mineur qui a une
  certaine chance de miner un bloc autour de ce moment. Ils déposent chacun une partie de leur argent
  dans une _transaction de financement_ qui peut être dépensée de trois manières :

  1. Bob reçoit son dépôt en retour et réclame le dépôt d'Alice en dépensant la sortie de la
     transaction de financement dans le bloc 1 000 000 (ou un bloc peu après). Le script qu'ils utilisent
     exige que la dépense unilatérale de Bob soit d'une certaine taille minimum, comme plus grande que
     deux dépenses typiques.

  2. Alternativement, Alice reçoit son dépôt en retour et réclame le dépôt de Bob en dépensant la
     sortie de la transaction de financement quelque temps après le bloc 1 000 000 (par exemple, un jour
     plus tard dans le bloc 1 000 144). La transaction d'Alice est relativement petite.

  3. Une autre alternative est qu'Alice et Bob peuvent dépenser de manière coopérative la sortie de la
     transaction de financement comme ils le souhaitent. Cela utilise une dépense de chemin de clé
     [taproot][topic taproot] pour une efficacité maximale.

  Si les taux de frais au bloc 1 000 000 sont inférieurs aux attentes, Bob peut inclure sa grande
  dépense dans ce bloc (ou un autre bloc peu après) et réaliser un profit. Profiter de ce moment de
  faibles taux de frais à l'échelle du réseau est particulièrement avantageux pour Bob en tant que
  mineur, car des taux de frais bas signifient qu'il ne gagne pas autant de récompenses des blocs
  qu'il produit.

  Si les taux de frais au bloc 1 000 000 sont supérieurs aux attentes, Bob ne voudra pas inclure sa
  grande dépense dans un bloc---cela coûterait plus en frais qu'il ne gagnerait en profit. Cela permet
  à Alice de réaliser un profit en incluant sa dépense plus petite dans le bloc 1 000 144 (ou plus
  tard). Profiter de ce moment de taux de frais élevés à l'échelle du réseau est particulièrement
  avantageux pour Alice, car cela compense le coût élevé des frais pour inclure la transaction
  régulière qu'elle prévoyait d'inclure dans le bloc 1 000 000.

  En outre, si Alice et Bob se rendent compte qu'il sera rentable pour Bob d'inclure ses dépenses dans
  le bloc 1 000 000, ils peuvent coopérer pour dépenser en faveur de Bob afin de créer une transaction
  plus petite que la version unilatérale de Bob. Cela profite à Bob en lui permettant d'économiser des
  frais et bénéficie à Alice en réduisant la quantité de données dans le bloc 1 000 000, ce qui signifie
  qu'Alice pourrait avoir à payer moins de frais pour la transaction qu'elle prévoyait d'inclure dans ce bloc.

  Il y a eu plusieurs réponses au sujet. Une réponse [a noté][harding futures] que le contrat a la
  propriété intéressante de ne pas seulement être sans confiance (une raison commune de préférer les
  contrats appliqués par consensus) mais évite également de corrompre la contrepartie. Par exemple,
  s'il y avait un marché à terme centralisé pour les taux de frais, Bob et d'autres mineurs pourraient
  [accepter des frais hors bande][topic out-of-band fees] ou utiliser d'autres astuces pour manipuler
  le taux de frais apparent ; mais, avec la construction de ZmnSCPxj, ce n'est pas un risque : le
  choix de Bob de savoir s'il utilise ou non la dépense de grande taille est purement informé par sa
  perspective sur les conditions actuelles de minage et de mempool. Cette réponse a également envisagé
  si les mineurs plus importants pourraient avoir un avantage sur les mineurs plus petits et
  Anthony Towns [a fourni][towns futures] un tableau des gains montrant qu'une tentative de
  manipuler le contrat résulterait en des profits plus importants pour les mineurs utilisant
  l'algorithme de sélection de transaction par défaut.

- **Sélection de pièces pour les fournisseurs de liquidité :** Richard Myers [a posté][myers cs] sur
  Delving Bitcoin à propos de la création d'un algorithme de [sélection de pièces][topic coin
  selection] optimisé pour les nœuds LN offrant de la liquidité via [des annonces de liquidité][topic
  liquidity advertisements]. Son post décrit un algorithme qu'il a implémenté dans un [brouillon de
  PR][bitcoin core #29442] pour Bitcoin Core. En testant l'algorithme, il a trouvé "une réduction de
  15% des frais on-chain par rapport à la sélection de pièces par défaut de [Bitcoin Core]". Myers
  cherche des critiques de l'approche et des suggestions d'amélioration.

- **Prototype simple de coffre-fort utilisant `OP_CAT` :** le développeur Rijndael [a
  posté][rijndael vault] sur Delving Bitcoin à propos d'une implémentation de preuve de concept en
  Rust qu'il a écrite pour un [coffre-fort][topic vaults] qui dépend uniquement des règles de
  consensus actuelles plus la proposition d'opcode [OP_CAT][topic op_cat]. Un bref exemple de comment le
  coffre-fort pourrait être utilisé : Alice génère une adresse avec un script créé par le logiciel du
  coffre-fort et reçoit un paiement à cette adresse. Ensuite, une dépense est déclenchée soit par
  elle, soit par quelqu'un tentant de voler ses fonds.

  - *Dépense légitime :* Alice déclenche la dépense en créant une transaction initiatrice avec deux
    entrées et deux sorties ; les entrées sont la dépense du montant mis en coffre-fort et une entrée
    qui ajoute des frais ; les sorties sont une sortie intermédiaire pour le montant exact de la
    première entrée et une petite sortie qui paie l'adresse de retrait finale. Après qu'un certain
    nombre de blocs soit passé, Alice complète le retrait en créant une transaction avec deux entrées et
    une sortie ; les entrées sont la première sortie initiatrice d'avant plus une autre entrée payant
    des frais ; la sortie est l'adresse de retrait.

    Dans la première dépense, `OP_CAT` plus une astuce précédemment décrite utilisant [les signatures
    schnorr][topic schnorr signatures] (voir le [Bulletin #134][news134 cat]) vérifie que la sortie
    dépensée a le même script et même montant que la sortie correspondante créée, garantissant qu'aucun fonds ne soit
    retiré du coffre par la transaction initiatrice. La seconde transaction vérifie que sa première
    entrée a un verrou temporel relatif [timelock][topic timelocks] [BIP68][] pour un certain nombre de
    blocs (par exemple, 20 blocs), que la sortie paie le montant exact de la première entrée, et que la
    sortie paie à la même adresse que la seconde adresse de la transaction initiatrice. Le verrou
    temporel relatif offre une période de contestation (voir ci-dessous) ; la vérification du montant
    exact garantit qu'aucun fonds ne soit retiré sans autorisation ; et la vérification de l'adresse
    garantit qu'un voleur ne peut pas changer une adresse de retrait légitime en sa propre adresse à la
    dernière minute (un problème avec tous les coffres pré-signés dont nous avons connaissance, voir
    le [Bulletin #59][news59 vaults]).

  - *Dépense illégitime :* Mallory déclenche une dépense en créant une transaction initiatrice comme
    décrit ci-dessus. La [tour de guet][topic watchtowers] d'Alice réalise que la dépense est illégitime
    pendant la période de contestation (par exemple, le délai de 20 blocs) et crée une transaction de
    re-coffrage avec deux entrées et une sortie ; les entrées sont la première sortie de la transaction
    déclencheuse et une entrée payant des frais ; la sortie est un retour au coffre. Étant donné que la
    transaction de re-coffrage n'a qu'une seule sortie mais que les conditions de retrait du script
    exigent une dépense à partir d'une transaction initiatrice avec deux sorties, Mallory est incapable
    de voler les fonds d'Alice.

    Puisque l'argent est retourné au même script de coffre d'où il est parti, Mallory peut toujours
    créer une autre transaction initiatrice et forcer Alice à passer par le même cycle encore et
    encore, entraînant des coûts de frais pour Mallory et Alice. La [documentation étendue][cat vault
    readme] de Rijndael pour le projet note que vous voudriez probablement permettre à Alice de dépenser
    l'argent vers un script différent dans ce cas, et que les idées derrière sa construction le
    permettent mais cela n'est pas actuellement implémenté pour simplifier.

  Ces coffres basés sur CAT peuvent être comparés aux types de coffres pré-signés que nous pouvons
  créer aujourd'hui sans changements de consensus et les coffres `OP_VAULT` de style [BIP345][] qui
  fourniraient l'ensemble de fonctionnalités de coffre le mieux connu si leur support était ajouté
  dans un soft fork.

  <table>
  <tr>
    <th></th>
    <th>Pré-signé</th>
    <th markdown="span">

    BIP345 `OP_VAULT`

    </th>
    <th markdown="span">

    `OP_CAT` avec schnorr

    </th>
  </tr>

  <tr>
    <th>Disponibilité</th>
    <td markdown="span">

    **Maintenant**

    </td>
    <td markdown="span">

    Nécessite un soft fork de `OP_VAULT` et [OP_CTV][topic op_checktemplateverify]

    </td>
    <td markdown="span">

    Nécessite un soft fork de `OP_CAT`

    </td>
  </tr>

  <tr>
    <th markdown="span">Attaque de remplacement d'adresse de dernière minute</th>
    <td markdown="span">Vulnérable</td>
    <td markdown="span">

    **Non vulnérable**

    </td>
    <td markdown="span">

    **Non vulnérable**

    </td>
  </tr>
  <tr>
    <th markdown="span">Retraits partiels de montant</th>
    <td markdown="span">Seulement si préarrangé</td>
    <td markdown="span">

    **Oui**

    </td>
    <td markdown="span">Non</td>
  </tr>

  <tr>
    <th markdown="span">Adresses de dépôt calculables statiques et non interactives</th>
    <td markdown="span">Non</td>
    <td markdown="span">

    **Oui**

    </td>
    <td markdown="span">

    **Oui**

    </td>
  </tr>

  <tr>
    <th markdown="span">Regroupement pour re-vaulting/mise en quarantaine pour économie de frais</th>
    <td markdown="span">Non</td>
    <td markdown="span">

    **Oui**

    </td>
    <td markdown="span">Non</td>
  </tr>

  <tr>
    <th markdown="span">

    Efficacité opérationnelle dans le meilleur cas, c'est-à-dire uniquement les dépenses légitimes<br>*(estimé très approximativement par Optech)*

    </th>
    <td markdown="span">

    **2x la taille d'une signature unique régulière**

    </td>
    <td markdown="span">3x la taille d'une signature unique régulière</td>
    <td markdown="span">4x la taille d'une signature unique régulière</td>
  </tr>
  </table>

  Le prototype a suscité quelques discussions et analyses sur le forum à ce jour.

- **Envoyer et recevoir de l'ecash en utilisant LN et ZKCPs :** Anthony Towns a [posté][towns
  lnecash] sur Delving Bitcoin à propos de la liaison des "mint d'[ecash][topic ecash] au réseau
  lightning sans perdre l'anonymat de l'ecash ou ajouter une confiance supplémentaire". Sa proposition
  pour atteindre cet objectif utilise un paiement contingent en connaissance nulle ([ZKCP][topic acc])
  pour envoyer des paiements à l'utilisateur d'un mint ecash et un processus d'engagement sur une
  pré-image de hachage pour retirer des fonds ecash vers LN.

  Calle, le développeur principal de l'implémentation ecash [Cashu][], a [répondu][calle lnecash] avec
  quelques préoccupations mais aussi un soutien pour l'idée, une référence à un système de preuve en
  connaissance nulle déjà implémenté pour Cashu, et une note indiquant qu'il recherche activement et
  écrit du code pour soutenir les transferts atomiques ecash-vers-LN.

## Questions et réponses sélectionnées de Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] est l'un des premiers endroits où les contributeurs d'Optech cherchent des réponses à leurs
  questions, ou lorsque nous avons quelques moments libres pour aider les utilisateurs curieux ou confus. Dans cette rubrique
  mensuelle, nous mettons en évidence certaines des questions et réponses les plus votées publiées depuis notre dernière mise
  à jour.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aa
nswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Pourquoi les nœuds ne peuvent-ils pas avoir l'option de relais pour interdire certains types de transactions ?]({{bse}}121734)
  Ava Chow expose des réflexions sur le but de la [politique de mempool
  et de relais][policy series], les avantages de mempools plus homogènes incluant l'[estimation des
  frais][topic fee estimation] et le [relais de blocs compacts][topic compact block relay], et aborde
  sur les solutions de contournement des politiques telles que les mineurs acceptant des [frais hors
  bande][topic out-of-band fees].

- [Qu'est-ce que la dépendance circulaire dans la signature d'une chaîne de transactions non confirmées ?]({{bse}}121959)
  Ava Chow explique le problème des [dépendances circulaires][mastering 06 cds]
  lors de l'utilisation de transactions Bitcoin legacy non confirmées.

- [Comment fonctionne le schéma de paiement TIDES d'Ocean ?]({{bse}}120719)
  L'utilisateur Lagrang3 explique le schéma de paiement des mineurs Transparent Index of Distinct
  Extended Shares (TIDES) utilisé par le pool de minage Ocean.

- [Quelles données le portefeuille Bitcoin Core recherche-t-il lors d'un nouveau balayage de la blockchain ?]({{bse}}121563)
  Pieter Wuille et Ava Chow expliquent comment le logiciel de portefeuille Bitcoin Core
  identifie les transactions pertinentes pour un portefeuille legacy ou [descriptor][topic
  descriptors] particulier.

- [Comment fonctionne la retransmission des transactions pour les portefeuilles en observation seulement ?]({{bse}}121899)
  Ava Chow note que la logique de retransmission des transactions est la même
  quel que soit le type de portefeuille. Cependant, pour qu'une transaction originaire d'un
  portefeuille en observation seulement soit éligible à la retransmission par le nœud, la transaction
  doit avoir été ajoutée au mempool du nœud à un moment donné.

## Mises à jour et versions candidates

*Nouvelles versions et versions candidates pour les principaux projets d’infrastructure
Bitcoin. Veuillez envisager de passer aux nouvelles versions ou d’aider à tester
les versions candidates.*

- [Core Lightning 24.02][] est une sortie de la prochaine version majeure de
  ce nœud LN populaire. Il comprend des améliorations au plugin `recover`
  qui "rendent les récupérations d'urgence moins stressantes", des améliorations
  aux [canaux d'ancrage][topic anchor outputs], une synchronisation de la chaîne de blocs 50 % plus
  rapide, et un correctif de bug pour l'analyse d'une grande
  transaction trouvée sur le testnet.

## Modifications de code et de documentation notables

_Modifications notables cette semaine dans [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Interface de Portefeuille Matériel (HWI)][hwi
repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Propositions d'Amélioration de Bitcoin (BIPs)][bips
repo], [Lightning BOLTs][bolts repo],
[Inquisition Bitcoin][bitcoin inquisition repo], et [BINANAs][binana
repo]._

- [LDK #2770][] commence à préparer l'ajout ultérieur du support pour les [canaux à double
financement][topic dual funding].

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 15:00" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="2770,29442" %}
[Core Lightning 24.02]: https://github.com/ElementsProject/lightning/releases/tag/v24.02
[myers csliq]: https://delvingbitcoin.org/t/liquidity-provider-utxo-management/600
[news134 cat]: /en/newsletters/2021/02/03/#replicating-op-checksigfromstack-with-bip340-and-op-cat
[news59 vaults]: /en/newsletters/2019/08/14/#bitcoin-vaults-without-covenants
[cashu]: https://github.com/cashubtc/nuts
[zmnscpxj futures]: https://delvingbitcoin.org/t/an-onchain-implementation-of-mining-feerate-futures/547
[harding futures]: https://delvingbitcoin.org/t/an-onchain-implementation-of-mining-feerate-futures/547/2
[myers cs]: https://delvingbitcoin.org/t/liquidity-provider-utxo-management/600
[rijndael vault]: https://delvingbitcoin.org/t/basic-vault-prototype-using-op-cat/576
[cat vault readme]: https://github.com/taproot-wizards/purrfect_vault
[towns lnecash]: https://delvingbitcoin.org/t/ecash-et-lightning-via-zkcp/586
[towns futures]: https://delvingbitcoin.org/t/an-onchain-implementation-of-mining-feerate-futures/547/6?u=harding
[calle lnecash]: https://delvingbitcoin.org/t/ecash-et-lightning-via-zkcp/586/2
[policy series]: /fr/blog/waiting-for-confirmation/
[mastering 06 cds]: https://github.com/bitcoinbook/bitcoinbook/blob/develop/ch06_transactions.adoc#circular-dependencies
