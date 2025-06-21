---
title: 'Bulletin Hebdomadaire Bitcoin Optech #357'
permalink: /fr/newsletters/2025/06/06/
name: 2025-06-06-newsletter-fr
slug: 2025-06-06-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
La newsletter de cette semaine partage une analyse sur la synchronisation des nœuds complets sans
anciens témoins. Sont également incluses nos sections régulières avec des descriptions des
discussions sur le changement de consensus, annonçant de nouvelles versions et versions candidates,
et décrivant les changements notables apportés aux logiciels d'infrastructure Bitcoin populaires.

## Nouvelles

- **Synchronisation des nœuds complets sans témoins :** Jose SK a [publié][sk nowit] sur Delving
  Bitcoin un résumé d'une [analyse][sk nowit gist] qu'il a réalisée concernant les compromis de
  sécurité permettant aux nœuds complets nouvellement démarrés avec une configuration particulière
  d'éviter de télécharger certaines données historiques de la blockchain. Par défaut, les nœuds
  Bitcoin Core utilisent le paramètre de configuration `assumevalid` qui saute la validation des
  scripts dans les blocs créés plus d'un mois ou deux avant la sortie de la version de Bitcoin Core
  utilisée. Bien que désactivé par défaut, de nombreux utilisateurs de Bitcoin Core définissent
  également un paramètre de configuration `prune` qui supprime les blocs un certain temps après les
  avoir validés (la durée de conservation des blocs dépend de la taille des blocs et du paramètre
  spécifique sélectionné par l'utilisateur).

  SK soutient que les données de témoins, qui sont uniquement utilisées pour la validation des
  scripts, ne devraient pas être téléchargées par les nœuds élagués pour les blocs assumevalid car ils
  ne les utiliseront pas pour valider les scripts et finiront par les supprimer. Omettre le
  téléchargement des témoins "peut réduire l'utilisation de la bande passante de plus de 40 %",
  écrit-il.

  Ruben Somsen [soutient][somsen nowit] que cela change le modèle de sécurité dans une certaine
  mesure. Bien que les scripts ne soient pas validés, les données téléchargées sont validées contre
  l'engagement du merkle root de l'en-tête du bloc à la transaction coinbase jusqu'aux données du
  témoin. Cela garantit que les données étaient disponibles et non corrompues au moment où le nœud a
  été synchronisé initialement. Si personne ne valide régulièrement l'existence des données, il
  pourraient être concevable qu'elles soient perdues, comme cela [s'est produit][ripple loss]
  pour au moins un altcoin.

  La discussion était en cours au moment de la rédaction.

## Modification du consensus

_Une nouvelle section mensuelle résumant les propositions et discussions sur la modification des
règles de consensus de Bitcoin._

- **Rapport sur l'informatique quantique :** Clara Shikhelman a [publié][shikelman quantum] sur
  Delving Bitcoin le résumé d'un [rapport][sm report] qu'elle a co-écrit avec Anthony Milton sur les
  risques pour les utilisateurs de Bitcoin des ordinateurs quantiques rapides, un aperçu de plusieurs
  voies vers la [résistance quantique][topic quantum resistance], et une analyse des compromis
  impliqués dans la mise à niveau du protocole Bitcoin. Les auteurs trouvent que 4 à 10 millions de
  BTC sont potentiellement vulnérables au vol quantique, certaines mesures d'atténuation sont
  possibles maintenant, l'exploitation minière de Bitcoin est peu susceptible d'être menacée par
  l'informatique quantique à court ou moyen terme, et la mise à niveau nécessite un large accord.

- **Limite de poids de transaction avec exception pour prévenir la confiscation :** Vojtěch Strnad a
  [publié][strnad limit] sur Delving Bitcoin pour proposer l'idée d'un changement de consensus pour
  limiter le poids maximum de la plupart des transactions dans un bloc. La règle simple ne permettrait
  qu'une transaction de plus de 400 000 unités de poids (100 000 vbytes) dans un bloc s'il était la seule transaction dans
  ce bloc à part la transaction coinbase. Strnad et d'autres ont décrit la motivation pour limiter le
  poids maximum de la transaction :

  - _Optimisation plus facile du modèle de bloc :_ il est plus facile de trouver une solution presque
    optimale au [problème du sac à dos][] lorsque les éléments sont plus petits par rapport à la limite
    globale. Cela est en partie dû à la minimisation de la quantité d'espace restant à la fin, avec des
    éléments plus petits laissant moins d'espace inutilisé.

  - _Politique de relais plus facile :_ la politique pour le relais des transactions non confirmées
    entre les nœuds prédit quelles transactions seront minées afin d'éviter le gaspillage de bande
    passante. Les transactions géantes rendent les prédictions précises plus difficiles car même un
    petit changement dans le taux de frais le plus élevé peut les faire retarder ou être évincées.

  - _Éviter la centralisation de l'extraction :_ s'assurer que les nœuds complets de relais peuvent
    gérer presque toutes les transactions empêche les utilisateurs de transactions spéciales de devoir
    payer des [frais hors bande][topic out-of-band fees], ce qui peut conduire à la centralisation de
    l'extraction.

  Gregory Sanders [a noté][sanders limit] qu'il pourrait être raisonnable de simplement appliquer une
  limite maximale de poids par un soft fork sans aucune exception basée sur les 12 années de politique
  de relais cohérente de Bitcoin Core. Gregory Maxwell [a ajouté][maxwell limit] que les transactions
  dépensant uniquement des UTXOs créés avant le soft fork pourraient être autorisées une exception
  pour prévenir la confiscation, et qu'un [soft fork transitoire][topic transitory soft forks]
  permettrait à la restriction d'expirer si la communauté décidait de ne pas la renouveler.

  Des discussions supplémentaires ont examiné les besoins des parties souhaitant de grandes
  transactions, principalement les utilisateurs de [BitVM][topic acc] à court terme, et si des
  approches alternatives étaient disponibles pour eux.

- **Suppression des sorties de l'ensemble UTXO basée sur la valeur et le temps :** Robin Linus [a
  posté][linus dust] sur Delving Bitcoin pour proposer un soft fork pour retirer les sorties de faible
  valeur de l'ensemble UTXO après un certain temps. Plusieurs variations de l'idée ont été discutées,
  les deux principales alternatives étant :

  - _Détruire les fonds économiquement non rentables anciens :_ les sorties de petite valeur qui
    n'avaient pas été dépensées pendant longtemps deviendraient inexploitables.

  - _Exiger que les fonds économiquement non rentables anciens soient dépensés avec une preuve
    d'existence :_ [utreexo][topic utreexo] ou un système similaire pourrait être utilisé pour permettre
    à une transaction de prouver que les sorties qu'elle dépense font partie de l'ensemble UTXO. Les
    sorties anciennes et [économiquement non rentables][topic uneconomical outputs] devraient inclure
    cette preuve, mais les sorties plus récentes et de plus grande valeur seraient toujours stockées
    dans l'ensemble UTXO.

  L'une ou l'autre solution limiterait efficacement la taille maximale de l'ensemble UTXO (en
  supposant une valeur minimale et la limite de 21 millions de bitcoins). Plusieurs aspects techniques
  intéressants d'une conception ont été discutés, y compris des alternatives aux preuves utreexo pour
  cette application qui pourraient être plus pratiques.

## Mises à jour et versions candidates

_Nouvelles mises à jour et versions candidates pour des projets d'infrastructure Bitcoin populaires.
Veuillez envisager de passer aux nouvelles versions ou d'aider à tester
les versions candidates._

- [Core Lightning 25.05rc1][] est un candidat à la sortie pour la prochaine version majeure
  version de cette populaire implémentation de nœud LN.

- [LND 0.19.1-beta.rc1][] est un candidat à la version pour une maintenance
  version de cette populaire implémentation de nœud LN.

## Changements de code et de documentation notables

_Changements récents notables dans [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Interface de Portefeuille Matériel (HWI)][hwi
repo], [Rust Bitcoin][rust bitcoin repo], [Serveur BTCPay][btcpay server repo], [BDK][bdk repo],
[Propositions d'Amélioration de Bitcoin (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Inquisition Bitcoin][bitcoin inquisition
repo], et [BINANAs][binana repo]._

- [Bitcoin Core #32582][] ajoute de nouveaux journaux pour mesurer la performance de
  [reconstruction de bloc compact][topic compact block relay] en suivant la
  taille totale des transactions qu'un nœud demande à ses pairs
  (`getblocktxn`), le nombre et la taille totale des transactions qu'un nœud envoie
  à ses pairs (`blocktxn`), et ajoutant un horodatage au début de
  `PartiallyDownloadedBlock::InitData()` pour suivre combien de temps l'étape de recherche dans le
  mempool prend seule (dans les modes à bande passante élevée et faible). Voir le Bulletin
  [#315][news315 compact] pour un rapport de statistiques précédent sur la reconstruction de bloc
  compact.

- [Bitcoin Core #31375][] ajoute un nouvel outil CLI `bitcoin -m` qui enveloppe et
  exécute les binaires [multiprocess][multiprocess project] `bitcoin node`
  (`bitcoind`), `bitcoin gui` (`bitcoinqt`), `bitcoin rpc` (`bitcoin-cli-named`).
  Actuellement, ceux-ci fonctionnent de la même manière que les binaires monolithiques, sauf
  qu'ils prennent en charge l'option `-ipcbind` (voir le Bulletin
  [#320][news320 ipc]), mais les améliorations futures permettront à un opérateur de nœud de
  démarrer et arrêter les composants indépendamment sur différentes machines et
  environnements. Voir le [Bulletin #353][news353 pr review] dans la section Bitcoin Core PR
  Review Club couvrant ce point.

- [BIPs #1483][] fusionne [BIP77][] qui propose [payjoin v2][topic payjoin], une
  variante asynchrone sans serveur dans laquelle l'expéditeur et le récepteur passent leurs
  PSBTs chiffrés à un serveur annuaire payjoin qui stocke et transmet uniquement
  les messages. Comme l'annuaire ne peut ni lire ni modifier les charges utiles, aucun des
  portefeuilles n'a besoin d'héberger un serveur public ou d'être en ligne en même temps.
  Voir le Bulletin [#264][news264 payjoin] pour un contexte supplémentaire sur payjoin v2.

{% include snippets/recap-ad.md when="2025-06-10 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="32582,31375,1483" %}
[Core Lightning 25.05rc1]: https://github.com/ElementsProject/lightning/releases/tag/v25.05rc1
[ripple loss]: https://x.com/JoelKatz/status/1919233214750892305
[sk nowit]: https://delvingbitcoin.org/t/witnessless-sync-for-pruned-nodes/1742/
[sk nowit gist]: https://gist.github.com/JoseSK999/df0a2a014c7d9b626df1e2b19ccc7fb1
[somsen nowit]: https://gist.github.com/JoseSK999/df0a2a014c7d9b626df1e2b19ccc7fb1?permalink_comment_id=5597316#gistcomment-5597316
[shikelman quantum]: https://delvingbitcoin.org/t/bitcoin-et-le-calcul-quantique/1730/
[sm report]: https://chaincode.com/bitcoin-post-quantum.pdf
[strnad limit]: https://delvingbitcoin.org/t/limite-de-poids-de-transaction-non-confiscatoire/1732/
[problème du sac à dos]: https://fr.wikipedia.org/wiki/Probl%C3%A8me_du_sac_%C3%A0_dos
[sanders limit]: https://delvingbitcoin.org/t/limite-de-poids-de-transaction-non-confiscatoire/1732/2
[maxwell limit]: https://delvingbitcoin.org/t/limite-de-poids-de-transaction-non-confiscatoire/1732/4
[linus dust]: https://delvingbitcoin.org/t/expiry-de-la-poussière-nettoyer-lensemble-utxo-des-spams/1707/
[lnd 0.19.1-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.19.1-beta.rc1
[news315 compact]: /fr/newsletters/2024/08/09/#statistiques-sur-la-reconstruction-de-blocs-compacts
[multiprocess project]: https://github.com/ryanofsky/bitcoin/blob/pr/ipc/doc/design/multiprocess.md
[news320 ipc]: /fr/newsletters/2024/09/13/#bitcoin-core-30509
[news264 payjoin]: /fr/newsletters/2023/08/16/#payjoin-sans-serveur
[news353 pr review]: /fr/newsletters/2025/05/09/#club-de-revue-de-pr-bitcoin-core