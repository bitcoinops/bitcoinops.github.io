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

[Faire passer les transactions d'ancêtres non confirmés au taux de frais cible][review club 26152]
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

Cette revue des PR [s'étendait sur][review club 26152] deux [semaines][review club
26152-2].

{% include functions/details-list.md
  q0="Quel est le problème que cette PR règle ?"
  a0="L'estimation des frais du portefeuille ne tient pas compte du fait
      qu'il peut également avoir à payer pour tous les ancêtres non confirmés
      dont le taux de frais est inférieur à celui de l'objectif."
  a0link="https://bitcoincore.reviews/26152#l-30"

  q1="En quoi consiste le \"cluster\" d'une transaction ?"
  a1="L'ensemble de transactions constitué de lui-même et de toutes les
      transactions \"connectées\". Cela inclut tous ses ancêtres et descendants,
      mais aussi les frères et sœurs et les cousins, c'est-à-dire les enfants
      des parents qui peuvent ne pas être ancêtres ou descendants de la
      transaction donnée."
  a1link="https://bitcoincore.reviews/26152#l-72"

  q2="Ce PR introduit `MiniMiner` qui duplique certains des algorithmes
      du mineur actuel; aurait-il été préférable d'unifier ces deux implémentations
      par une refactorisation ?"
  a2="Nous avons seulement besoin d'opérer sur un cluster et non sur le pool de
      mémoire entier, et n'avons pas besoin d'appliquer les vérifications que
      `BlockAssembler` fait. Il a également été suggéré de faire ce calcul sans
      tenir le verrou du pool de mémoire. Nous devrions aussi changer l'assembleur
      de blocs pour qu'il suive les chocs de frais plutôt que de construire le
      modèle de bloc; la quantité de refactoring nécessaire était équivalente
      à réécrire."
  a2link="https://bitcoincore.reviews/26152#l-94"

  q3="Pourquoi le `MiniMiner` nécessite-t-il un cluster entier ? Pourquoi ne peut-il pas
      pas simplement utiliser l'union des ensembles d'ancêtres de chaque transaction ?"
  a3="Il se peut que certains des ancêtres aient déjà été payés par certains de leurs
      autres descendants; il n'est pas nécessaire d'en rajouter. Nous devons donc
      inclure ces autres descendants dans nos calculs."
  a3link="https://bitcoincore.reviews/26152#l-129"

  q4="Si la transaction X a un _taux de frais d'ancêtre_ plus élevé que la transaction
      indépendante Y, est-il possible pour un mineur de donner la priorité à Y sur X
      (c'est-à-dire de miner Y avant X) ?"
  a4="Oui. Si certains des ancêtres à faible taux de frais de Y ont _d'autres_ descendants
      qui ont un taux de frais élevé, Y n'a pas besoin de "payer" pour ces ancêtres.
      L'ensemble des ancêtres de Y est mis à jour pour exclure ces transactions, ce qui a
      pour effet d'augmenter le taux de frais des ancêtres de Y."
  a4link="https://bitcoincore.reviews/26152#l-169"

  q5="Est-ce que `CalculateBumpFees()` peut surestimer, sous-estimer, les deux, ou aucun
      des deux ? De combien ?
  a5="Elle sera surestimée si deux sorties dont l'ascendance se chevauche sont choisies,
      puisque chaque saut est indépendant de ses ancêtres (sans tenir compte de l'ascendance
      partagée). Les participants ont conclu qu'il n'est pas possible que les frais de saut
      soient sous-estimés."
  a5link="https://bitcoincore.reviews/26152#l-194"

  q6="On donne au `MiniMiner` une liste d'UTXOs (outpoints) que le portefeuille pourrait
      être intéressé à dépenser. Étant donné un point de sortie, quels sont ses cinq
      états possibles ?"
  a6="Il pourrait être (1) confirmé et non dépensé, (2) confirmé mais déjà dépensé par
      une transaction existante dans le pool de mémoires, (3) non confirmé (dans le pool
      de mémoires) et non dépensé, (4) non confirmé mais déjà dépensé par une transaction
      existante dans le pool de mémoires, ou (5) il pourrait être un point de sortie dont
      nous n'avons jamais entendu parler."
  a6link="https://bitcoincore.reviews/26152-2#l-21"

  q7="Quelle est l'approche adoptée dans la commande \"Transactions parentes de sauts non
      confirmées sur taux de frais cible\"?"
  a7="Ce commit est le principal changement de comportement du PR. Nous utilisons le `MiniMiner`
      pour calculer les frais de saut (les frais nécessaires pour faire passer leurs ancêtres
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

- [Core Lightning 22.11][] est la prochaine version majeure de CLN.  C'est également la
  première version à utiliser un nouveau système de numérotation des versions [^semver].
  Plusieurs nouvelles fonctionnalités sont incluses, notamment un nouveau gestionnaire
  de plugins, et de multiples corrections de bogues.

- [LND 0.15.5-beta][] st une version de maintenance de LND.  Elle ne contient que des
  corrections de bogues mineurs, selon ses notes de publication.

- [BDK 0.25.0][] est une nouvelle version de cette bibliothèque pour la création de portefeuilles.

## Changements principaux dans le code et la documentation

*Changements notables cette semaine dans [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], et [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #19762][] updates the RPC (and, by extension,
  `bitcoin-cli`) interface to allow named and positional arguments to be
used together. This change makes it more convenient to use named
parameter values without having to name every one.  The PR description
provides examples demonstrating the increased convenience of this
approach as well as a handy shell alias for frequent users of
`bitcoin-cli`.

- [Core Lightning #5722][] adds [documentation][grpc doc] about how to
  use the GRPC interface plugin.

- [Eclair #2513][] updates how it uses the Bitcoin Core wallet to ensure
  it always sends change to P2WPKH outputs.  This
  is the result of [Bitcoin Core #23789][] (see [Newsletter
  #181][news181 bcc23789]) where the project addressed a privacy
  concern for adopters of new output types (e.g. [taproot][topic
  taproot]).  Previously, a user who set their wallet default address
  type to taproot would also create taproot change outputs when they
  paid someone.  If they paid someone who didn't use taproot, it was
  easy for third parties to determine which output was the payment (the
  non-taproot output) and which was the change output (the taproot
  output).  After the change to Bitcoin Core, it would default to trying
  to use the same type of change output as the paid output, e.g. a
  payment to a native segwit output would also result in a native segwit
  change output.

    However, the LN protocol requires certain output types.  For
    example, a P2PKH output can't be used to open an LN channel.
    For that reason, users of Eclair with Bitcoin Core need to ensure
    they don't generate change outputs of an LN-incompatible type.

- [Rust Bitcoin #1415][] begins using the [Kani Rust Verifier][] to
  prove some properties of Rust Bitcoin's code.  This complements other
  continuous integration tests performed on the code, such as fuzzing.

- [BTCPay Server #4238][] adds an invoice refund endpoint to BTCPay's
  Greenfield API, a more recent API different from the original BitPay-inspired API.

## Notes de pied de page

[^semver]:
    Previous editions of this newsletter claimed Core Lightning used the
    [semantic versioning][] scheme and new versions would continue using
    that scheme in the future.  Rusty Russell has [described][rusty
    semver] why CLN can't completely adhere to that scheme.  We thank
    Matt Whitlock for notifying us about our previous error.

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
[news224 anchors]: /fr/newsletters/2022/11/02/#solution-de-contournement-des-sorties-d'ancrage
[news220 v3tx]: /fr/newsletters/2022/10/05/#proposition-de-nouvelle-politique-de-relai-de-transaction-conçue-pour-les-pénalités-sur-ln
[sanders ephemeral]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-November/021222.html
[review club 26152]: https://bitcoincore.reviews/26152
[review club 26152-2]: https://bitcoincore.reviews/26152-2
[rusty semver]: https://github.com/ElementsProject/lightning/issues/5716#issuecomment-1322745630
