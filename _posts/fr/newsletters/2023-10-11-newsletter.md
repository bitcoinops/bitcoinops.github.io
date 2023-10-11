---
title: 'Bulletin Hebdomadaire Bitcoin Optech #272'
permalink: /fr/newsletters/2023/10/11/
name: 2023-10-11-newsletter-fr
slug: 2023-10-11-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine propose un lien vers une spécification pour un nouvel opcode `OP_TXHASH` et inclut nos
sections habituelles résumant une réunion du Bitcoin Core PR Review Club, annonçant de nouvelles versions et versions candidates,
et décrivant les changements apportés aux principaux logiciels d'infrastructure Bitcoin.

## Nouvelles

- **Spécification pour `OP_TXHASH` proposée :** Steven Roose a [publié][roose txhash] sur la liste de diffusion Bitcoin-Dev
  un [projet de BIP][bips #1500] pour un nouvel opcode `OP_TXHASH`. L'idée derrière cet opcode a déjà été discutée (voir le
  [Bulletin #185][news185 txhash]), mais c'est la première spécification de cette idée. En plus de décrire précisément comment
  l'opcode fonctionnerait, il examine également la manière d'atténuer certains inconvénients potentiels, tels que la possibilité
  que les nœuds complets aient besoin de hacher plusieurs mégaoctets de données à chaque invocation de l'opcode. Le projet de Roose
  comprend une implémentation d'exemple de l'opcode.

## Bitcoin Core PR Review Club

*Dans cette section mensuelle, nous résumons une récente réunion du [Club de révision des PR de Bitcoin Core][Bitcoin Core PR Review Club]
en mettant en évidence certaines des questions et réponses importantes. Cliquez sur
une question ci-dessous pour voir un résumé de la réponse de la réunion.*


[util: Identifiants de transaction sûrs sur le plan des types][review club 28107] est un PR de Niklas Gögge (dergoegge) qui améliore
la sécurité des types en introduisant des types distincts pour `txid` (l'identifiant ou le hachage de transaction qui n'inclut pas les
données de témoin segwit) et `wtxid` (identique mais incluant les données de témoin), plutôt que d'être tous deux représentés par un
`uint256` (un entier de 256 bits, qui peut contenir un hachage SHA256). Ce PR ne devrait avoir aucun effet opérationnel ; il vise à
prévenir les erreurs de programmation futures dans lesquelles un type d'identifiant de transaction est utilisé à la place de l'autre.
De telles erreurs seront détectées lors de la compilation.

Pour minimiser les perturbations et faciliter l'examen, ces nouveaux types seront initialement utilisés dans une seule partie du code
(l'"orphelinat" de transaction) ; les futurs PR utiliseront les nouveaux types dans d'autres parties de la base de code.

{% include functions/details-list.md
  q0="Qu'est-ce que signifie qu'un identifiant de transaction soit sûr sur le plan des types ? Pourquoi est-ce important ou utile ?
       Y a-t-il des inconvénients ?"
  a0="Étant donné qu'un identifiant de transaction a l'une des deux significations (`txid` ou `wtxid`), la sécurité des types est la
       propriété selon laquelle un identifiant ne peut pas être utilisé avec la mauvaise signification. Autrement dit, un `txid` ne
       peut pas être utilisé là où un `wtxid` est attendu, et vice versa, et cela est vérifié par la vérification de type standard du
       compilateur."
  a0link="https://bitcoincore.reviews/28107#l-38"
%}

## Mises à jour et verions candidates

*Nouvelles versions et versions candidates pour les principaux projets d’infrastructure
Bitcoin. Veuillez envisager de passer aux nouvelles versions ou d’aider à tester
les versions candidates.*

- [LDK 0.0.117][] est une version de cette bibliothèque pour la construction d'applications compatibles LN. Elle inclut des
  corrections de bugs de sécurité liés aux fonctionnalités [anchor outputs][topic anchor outputs] incluses dans la version précédente.
  La version améliore également la recherche de chemin, améliore le support des [watchtowers][topic watchtowers], permet le financement
  [groupé][topic payment batching] de nouveaux canaux, entre autres fonctionnalités et corrections de bugs.

- [BDK 0.29.0][] est une version de cette bibliothèque pour la construction d'applications de portefeuille. Elle met à jour les
  dépendances et corrige un bug (probablement rare) affectant les cas où un portefeuille recevait plus d'une sortie de transactions
  coinbase de mineur.

## Changements notables dans le code et la documentation

*Changements notables cette semaine dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning repo], [Eclair][eclair repo],
[LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Interface de Portefeuille Matériel (HWI)][hwi repo],
[Rust Bitcoin][rust bitcoin repo], [Serveur BTCPay][btcpay server repo], [BDK][bdk repo],
[Bitcoin Improvement Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo], et [Bitcoin Inquisition][bitcoin inquisition repo].*

- [Bitcoin Core #27596][bitcoin core #27596] termine la première phase du projet [assumeutxo][topic assumeutxo], contenant toutes les
  modifications restantes nécessaires pour utiliser un état instantané `assumedvalid` de la chaîne des transactions non dépensées (UTXO)
  et effectuer une synchronisation complète de validation en arrière-plan. Il rend les instantanés UTXO chargeables via RPC
  (`loadtxoutset`) et ajoute des paramètres `assumeutxo` à chainparams.

    Bien que l'ensemble de fonctionnalités ne soit pas disponible sur mainnet avant [activation][bitcoin core #28553], cette fusion
    marque la culmination d'un effort pluriannuel. Le projet, [proposé en 2018][assumeutxo core dev] et [formalisé en
    2019][assumeutxo 2019 mailing list], améliorera considérablement l'expérience des nouveaux utilisateurs de noeuds complets
    sur le réseau. Les suivis de la fusion comprennent [Bitcoin Core #28590][bitcoin core #28590], [#28562][bitcoin core #28562] et
    [#28589][bitcoin core #28589].

- [Bitcoin Core #28331][], [#28588][bitcoin core #28588], [#28577][bitcoin core #28577] et [GUI #754][bitcoin core gui #754] ajoutent
  la prise en charge du [transport P2P chiffré de version 2][topic v2 p2p transport] tel que spécifié dans [BIP324][]. Cette
  fonctionnalité est actuellement désactivée par défaut, mais peut être activée en utilisant l'option `-v2transport`.

    Le transport chiffré contribue à améliorer la confidentialité des utilisateurs de Bitcoin en empêchant les observateurs passifs
    (comme les fournisseurs d'accès Internet) de déterminer directement quelles transactions les nœuds relaient à leurs pairs. Il est
    également possible d'utiliser le transport chiffré pour contrer les observateurs actifs de type homme du milieu en comparant les
    identifiants de session. À l'avenir, l'ajout d'autres [fonctionnalités][topic countersign] pourrait permettre à un client léger de
    se connecter de manière sécurisée à un nœud de confiance via une connexion chiffrée P2P.

- [Bitcoin Core #27609][] rend la RPC `submitpackage` disponible sur les réseaux non-regtest. Les utilisateurs peuvent utiliser cette
  RPC pour soumettre des packages d'une seule transaction avec ses parents non confirmés, où aucun des parents ne dépense la sortie
  d'un autre parent. La transaction enfant peut être utilisée pour CPFP (Child Pays For Parent) les parents qui se trouvent en dessous
  du taux de frais minimum de la mempool dynamique du nœud. Cependant, tant que le [relais de package][topic package relay] n'est pas
  encore pris en charge, ces transactions ne se propageront pas nécessairement à d'autres nœuds du réseau.

- [Bitcoin Core GUI #764][] supprime la possibilité de créer un portefeuille hérité dans l'interface graphique. La possibilité de créer
  des portefeuilles hérités est supprimée ; tous les nouveaux portefeuilles créés dans les versions futures de Bitcoin Core seront basés
  sur des [descripteurs][topic descriptors].

- [Core Lightning #6676][] ajoute une nouvelle RPC `addpsbtoutput` qui ajoutera une sortie à un [PSBT][topic psbt] pour recevoir des
  fonds sur le portefeuille du nœud.

{% include references.md %}
{% include linkers/issues.md v=2 issues="27596,28590,28562,28589,28331,28588,28577,28553,754,27609,764,6676,1500" %}
[roose txhash]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-September/021975.html
[news185 txhash]: /en/newsletters/2022/02/02/#composable-alternatives-to-ctv-and-apo
[ldk 0.0.117]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.0.117
[bdk 0.29.0]: https://github.com/bitcoindevkit/bdk/releases/tag/v0.29.0
[review club 28107]: https://bitcoincore.reviews/28107
[wtxid example]: https://github.com/bitcoin/bitcoin/blob/3cd02806ecd2edd08236ede554f1685866625757/src/net_processing.cpp#L4334
[GenTxid]: https://github.com/bitcoin/bitcoin/blob/dcfbf3c2107c3cb9d343ebfa0eee78278dea8d66/src/primitives/transaction.h#L425[news104 wtxid]: /en/newsletters/2020/07/01/#bips-933
[assumeutxo core dev]: https://btctranscripts.com/bitcoin-core-dev-tech/2018-03/2018-03-07-priorities/#:~:text=“Assume%20UTXO”
[assumeutxo 2019 mailing list]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-April/016825.html