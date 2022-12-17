---
title: 'Bitcoin Optech Newsletter #229'
permalink: /fr/newsletters/2022/12/07/
name: 2022-12-07-newsletter-fr
slug: 2022-12-07-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
La lettre d'information de cette semaine décrit une mise en œuvre des
ancrages éphémères et comprend nos sections habituelles avec le résumé
d'une réunion du club de révision des PR de Bitcoin Core, des annonces
de nouvelles versions et de versions candidates, et des descriptions
de changements notables dans les projets d'infrastructure Bitcoin
les plus répandus.

## Nouvelles

- **Mise en œuvre d'ancrages éphémères :** Greg Sanders [a posté][sanders
  ephemeral] sur la liste de diffusion de Bitcoin-Dev qu'il a mis en œuvre
  son idée d'ancres éphémères (voir [Newsletter #223][news223 anchors]).
  [Les sorties d'ancrages][topic anchor outputs] sont une technique existante
  [d'exclusions du CPFP][topic cpfp carve out] mise à disposition par Bitcoin Core
  et utilisée dans le protocole LN pour s'assurer que les deux parties
  impliquées dans un contrat peuvent percevoir des frais pour une transaction
  liée à ce contrat [CPFP][topic cpfp]. Les sorties d'ancrages présentent
  plusieurs inconvénients, dont certains sont fondamentaux (voir la
  [Newsletter #224][news224 anchors]), mais d'autres peuvent être résolus.

    Les ancrages éphémères s'appuient sur la [proposition de relais de
    transaction v3][topic v3 transaction relay] pour permettre aux transactions v3
    d'inclure une sortie à valeur nulle payant un script qui est essentiellement
    `OP_TRUE`, ce qui permet à cette transaction d'avoir des frais majorés en CPFP
    par n'importe qui sur le réseau avec un UTXO dépensable. La transaction enfant
    peut elle-même être payée par n'importe qui d'autre avec un UTXO dépensable.
    En combinaison avec d'autres parties de la proposition de relais de transaction v3,
    on espère que cela éliminera toutes les préoccupations basées sur la politique
    concernant les [attaques par épinglage de transaction][topic transaction pinning]
    contre les transactions de protocole de contrat sensibles au temps.

    Qui plus est, puisque n'importe qui peut faire payer une transaction contenant
    un résultat éphémère, elle peut être utilisée pour les protocoles contractuels
    impliquant plus de deux participants. La règle d'exclusion existante de Bitcoin
    Core ne fonctionne de manière fiable que pour deux participants et les [tentatives
    précédentes][bitcoin core #18725] pour l'augmenter nécessitaient une limite
    supérieure arbitraire de participants.

    La [mise en œuvre][bitcoin core #26403] des ancres éphémères par Sanders permet de
    commencer à tester l'idée conjointement avec les autres comportements de relais de
    transaction v3 précédemment mis en œuvre par l'auteur de cette proposition.

## Bitcoin Core PR Review Club

*Dans cette section mensuelle, nous résumons une récente réunion du
[Bitcoin Core PR Review Club][] en soulignant certaines des questions
et réponses importantes. Cliquez sur une question ci-dessous pour voir
un résumé de la réponse de la réunion.*

[Faire passer les transactions d'ascendants non confirmés au taux de frais cible][review club 26152]
est une PR de Xekyo (Murch) et glozow qui améliore la précision du calcul des
frais du portefeuille dans le cas où des UTXOs non confirmés sont sélectionnés
comme entrées. Sans le PR, les frais sont fixés trop bas si les taux de frais
de certaines transactions non confirmées utilisées comme entrées sont inférieurs
à ceux de la transaction en cours de construction. Le PR corrige ce problème en
ajoutant des frais suffisants pour "accélérer" ces transactions sources à faible
taux de frais vers le même taux de frais que celui visé par la nouvelle transaction.

Notez que même sans ce PR, le processus de sélection des pièces essaiera d'éviter
les dépenses provenant de transactions non confirmées de faible valeur.
Ce PR sera bénéfique dans les cas où cela ne peut être évité.

Ajuster les frais pour tenir compte de ces transactions ancestrales s'avère être
similaire au choix des transactions à inclure dans un bloc, donc ce PR ajoute une
classe appelée `MiniMiner`.

Cette revue des PR [s'étendait sur][review club 26152] deux [semaines][review club 26152-2].

{% include functions/details-list.md
  q0="Quel est le problème que cette PR règle ?"
  a0="L'estimation des frais du portefeuille ne tient pas compte du fait
      qu'il peut également avoir à payer pour tous les ascendants non confirmés
      dont le taux de frais est inférieur à celui de l'objectif."
  a0link="https://bitcoincore.reviews/26152#l-30"

  q1="En quoi consiste le \"cluster\" d'une transaction ?"
  a1="L'ensemble de transactions constitué de lui-même et de toutes les
      transactions \"connectées\". Cela inclut tous ses ascendants et descendants,
      mais aussi les frères et sœurs et les cousins, c'est-à-dire les enfants
      des parents qui peuvent ne pas être ascendants ou descendants de la
      transaction donnée."
  a1link="https://bitcoincore.reviews/26152#l-72"

  q2="Ce PR introduit `MiniMiner` qui duplique certains des algorithmes
      du mineur actuel ; aurait-il été préférable d'unifier ces deux implémentations
      par une refactorisation ?"
  a2="Nous avons seulement besoin d'opérer sur un cluster et non sur le pool de
      mémoire entier, et n'avons pas besoin d'appliquer les vérifications que
      `BlockAssembler` fait. Il a également été suggéré de faire ce calcul sans
      tenir le verrou du pool de mémoire. Nous devrions aussi changer l'assembleur
      de blocs pour qu'il suive les chocs de frais plutôt que de construire le
      modèle de bloc ; la quantité de refactoring nécessaire était équivalente
      à réécrire."
  a2link="https://bitcoincore.reviews/26152#l-94"

  q3="Pourquoi le `MiniMiner` nécessite-t-il un cluster entier ? Pourquoi ne peut-il pas
      simplement utiliser l'union des ensembles d'ascendants de chaque transaction ?"
  a3="Il se peut que certains des ascendants aient déjà été payés par certains de leurs
      autres descendants ; il n'est pas nécessaire d'en rajouter. Nous devons donc
      inclure ces autres descendants dans nos calculs."
  a3link="https://bitcoincore.reviews/26152#l-129"

  q4="Si la transaction X a un _taux de frais d'ancêtre_ plus élevé que la transaction
      indépendante Y, est-il possible pour un mineur de donner la priorité à Y sur X
      (c'est-à-dire de miner Y avant X) ?"
  a4="Oui. Si certains des ascendants à faible taux de frais de Y ont d'autres descendants
      qui ont un taux de frais élevé, Y n'a pas besoin de \"payer\" pour ces ascendants.
      L'ensemble des ascendants de Y est mis à jour pour exclure ces transactions, ce qui a
      pour effet d'augmenter le taux de frais des ascendants de Y."
  a4link="https://bitcoincore.reviews/26152#l-169"

  q5="Est-ce que `CalculateBumpFees()` peut surestimer, sous-estimer, les deux, ou aucun
      des deux ? De combien ?"
  a5="Ce sera surestimé si deux sorties dont l'ascendance se chevauchent sont choisies
      puisque chaque saut est indépendant de ses ascendants (sans tenir compte de l'ascendance
      partagée). Les participants ont conclu qu'il n'est pas possible que les frais de saut
      soient sous-estimés."
  a5link="https://bitcoincore.reviews/26152#l-194"

  q6="On donne au `MiniMiner` une liste d'UTXOs (outpoints) que le portefeuille pourrait
      être intéressé à dépenser. Étant donné un point de sortie, quels sont ses cinq
      états possibles ?"
  a6="Il pourrait être (1) confirmé et non dépensé, (2) confirmé mais déjà dépensé par
      une transaction existante dans la mempool, (3) non confirmé
      (dans la mempool) et non dépensé, (4) non confirmé mais déjà dépensé par une transaction
      existante dans la mempool, ou (5) il pourrait être un point de sortie dont
      nous n'avons jamais entendu parler."
  a6link="https://bitcoincore.reviews/26152-2#l-21"

  q7="Quelle est l'approche adoptée dans la commande \"Transactions parentes de sauts non
      confirmées sur taux de frais cible\" ?"
  a7="Ce commit est le principal changement de comportement du PR. Nous utilisons le `MiniMiner`
      pour calculer les frais de saut (les frais nécessaires pour faire passer leurs ascendants
      respectifs à la fréquence cible) de chaque UTXO et les déduire de leurs valeurs effectives.
      Ensuite, nous exécutons la sélection des pièces comme précédemment."
  a7link="https://bitcoincore.reviews/26152-2#l-100"

  q8="Comment le PR gère-t-il le fait de dépenser des UTXO non confirmés dont les ancêtres se chevauchent ?"
  a8="Après la sélection des pièces, nous exécutons une variante de l'algorithme `MiniMiner`
      sur le _résultat_ de chaque sélection de pièces afin d'obtenir un prix exact pour le saut.
      Si nous avons trop bossé en raison d'une ascendance partagée, nous pouvons réduire les
      frais en augmentant la valeur de changement si elle existe, ou en ajoutant une sortie
      de changement si elle n'existe pas."
  a8link="https://bitcoincore.reviews/26152-2#l-111"
%}

## Mises à jour et version candidate

*Nouvelles versions et versions candidates pour les principaux projets d'infrastructure Bitcoin.
Veuillez envisager de passer aux nouvelles versions ou d'aider à tester les versions candidates.*

- [BTCPay Server 1.7.1][] est la dernière version du logiciel de traitement des paiements
  auto hébergés le plus largement utilisé pour Bitcoin.

- [Core Lightning 22.11][] est la prochaine version majeure de CLN. C'est également la
  première version à utiliser un nouveau système de numérotation des versions [^semver].
  Plusieurs nouvelles fonctionnalités sont incluses, notamment un nouveau gestionnaire
  de plugins, et de multiples corrections de bogues.

- [LND 0.15.5-beta][] est une version de maintenance de LND. Elle ne contient que des
  corrections de bogues mineurs, selon ses notes de publication.

- [BDK 0.25.0][] est une nouvelle version de cette bibliothèque pour la création de portefeuilles.

## Changements principaux dans le code et la documentation

*Changements notables cette semaine dans [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], et [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #19762][] met à jour l'interface RPC (et, par extension,
  (`Bitcoin-cli`) pour permettre aux arguments nommés et positionnels d'être
  utilisés ensemble. Ce changement rend plus pratique l'utilisation de
  valeurs de paramètres nommés sans avoir à les nommer tous. La description
  de la PR fournit des exemples démontrant la commodité accrue de cette
  approche ainsi qu'un alias shell pratique pour les utilisateurs fréquents
  de `bitcoin-cli`.

- [Core Lightning #5722][] ajoute la [documentation][grpc doc] sur la manière
  d'utiliser le plugin d'interface GRPC.

- [Eclair #2513][] met à jour la façon dont il utilise le portefeuille Bitcoin
  Core pour s'assurer qu'il envoie toujours de la monnaie aux sorties P2WPKH.
  Ceci est le résultat de [Bitcoin Core #23789][] (voir [Newsletter #181][news181 bcc23789])
  où le projet a abordé un problème de confidentialité pour les utilisateurs
  de nouveaux types de sortie (par exemple [taproot][topic taproot]). Auparavant,
  un utilisateur qui définissait le type d'adresse par défaut de son portefeuille
  sur taproot créait également des sorties de changement taproot lorsqu'il payait
  quelqu'un. S'il payait quelqu'un qui n'utilisait pas taproot, il était facile
  pour les tiers de déterminer quelle sortie était le paiement (la sortie
  non-taproot) et quelle sortie était la modification (la sortie taproot). Après
  le changement de Bitcoin Core, le système essayera par défaut d'utiliser le
  même type de sortie de changement que la sortie payée, par exemple, un paiement
  vers une sortie segwit native entraînera également une sortie de changement
  segwit native.

    Cependant, le protocole LN requiert certains types de sortie. Par exemple
    une sortie P2PKH ne peut pas être utilisée pour ouvrir un canal LN. Pour
    cette raison, les utilisateurs d'Eclair avec Bitcoin Core doivent s'assurer
    qu'ils ne génèrent pas de sorties de monnaie d'un type incompatible avec LN.

- [Rust Bitcoin #1415][] commence à utiliser le [Kani Rust Verifier][] pour prouver
  certaines propriétés du code de Rust Bitcoin. Cela complète les autres tests
  d'intégration continue effectués sur le code, comme le fuzzing.

- [BTCPay Server #4238][] ajoute un endpoint de remboursement de facture à l'API
  Greenfield de BTCPay, une API plus récente différente de l'API originale
  inspirée de BitPay.

## Notes de pied de page

[^semver]:
    Les éditions précédentes de ce bulletin d'information affirmaient que Core
    Lightning utilisait le schéma de [versionnement sémantique][] et que les
    nouvelles versions continueraient à utiliser ce schéma à l'avenir. Rusty
    Russell a [décrit] [rusty semver] pourquoi CLN ne peut pas adhérer complètement
    à ce schéma. Nous remercions Matt Whitlock de nous avoir informés de notre
    précédente erreur.

{% include references.md %}
{% include linkers/issues.md v=2 issues="19762,5722,2513,1415,4238,18725,26403,23789" %}
[lnd 0.15.5-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.15.5-beta
[core lightning 22.11]: https://github.com/ElementsProject/lightning/releases/tag/v22.11
[btcpay server 1.7.1]: https://github.com/btcpayserver/btcpayserver/releases/tag/v1.7.1
[bdk 0.25.0]: https://github.com/bitcoindevkit/bdk/releases/tag/v0.25.0
[semantic versioning]: https://semver.org/spec/v2.0.0.html
[grpc doc]: https://github.com/cdecker/lightning/blob/20bc743840bf5d948efbf62d32a21a00ed233e31/plugins/grpc-plugin/README.md
[news181 bcc23789]: /en/newsletters/2022/01/05/#bitcoin-core-23789
[kani rust verifier]: https://github.com/model-checking/kani
[news223 anchors]: /fr/newsletters/2022/10/26/#ephemeral-anchors
[news224 anchors]: /fr/newsletters/2022/11/02/#solution-de-contournement-des-sorties-d-ancrage
[news220 v3tx]: /fr/newsletters/2022/10/05/#proposition-de-nouvelle-politique-de-relai-de-transaction-concue-pour-les-penalites-sur-ln
[sanders ephemeral]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-November/021222.html
[review club 26152]: https://bitcoincore.reviews/26152
[review club 26152-2]: https://bitcoincore.reviews/26152-2
[rusty semver]: https://github.com/ElementsProject/lightning/issues/5716#issuecomment-1322745630
