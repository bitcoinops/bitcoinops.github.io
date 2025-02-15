---
title: 'Bulletin Hebdomadaire Bitcoin Optech #341'
permalink: /fr/newsletters/2025/02/14/
name: 2025-02-14-newsletter-fr
slug: 2025-02-14-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine résume la discussion continue sur les paiements probabilistes, décrit
des opinions supplémentaires sur les scripts d'ancrage éphémères pour LN, relaye des statistiques
sur les expulsions du pool d'orphelins de Bitcoin Core, et annonce un brouillon mis à jour pour un
processus BIP révisé. Sont également incluses nos sections habituelles avec le résumé d'une réunion
du Bitcoin Core PR Review Club,
l'annonce les mises à jour et les versions candidates, et présente les changements
apportés aux principaux logiciels d'infrastructure Bitcoin.

## Nouvelles

- **Discussion continue sur les paiements probabilistes :** suite au [post][kurbatov pp] d'Oleksandr
  Kurbatov sur Delving Bitcoin la semaine dernière concernant l'émulation d'un opcode `OP_RAND` (voir
  le [Bulletin #340][news340 pp]), plusieurs discussions ont été lancées :

  - _Adéquation comme alternative aux HTLCs réduits :_ Dave Harding [a demandé][harding pp] si la
    méthode de Kurbatov était adaptée pour être utilisée à l'intérieur d'un canal de paiement
    [LN-Penalty][topic ln-penalty] ou [LN-Symmetry][topic eltoo] pour router des [HTLCs][topic htlc] qui
    sont actuellement [non économiques][topic uneconomical outputs], ce qui est actuellement réalisé en
    utilisant des [HTLCs réduits][topic trimmed htlc] dont la valeur est perdue s'ils sont en attente
    lors d'une fermeture forcée du canal. Anthony Towns [ne pensait pas que cela fonctionnerait][towns
    pp1] avec les rôles existants du protocole en raison de leur inverse par rapport aux rôles
    correspondants utilisés pour résoudre les HTLCs. Cependant, il pensait que des ajustements au
    protocole pourraient le rendre compatible avec les HTLCs.

  - _Étape de configuration requise :_ Towns [a découvert][towns pp1] qu'il manquait une étape dans le
    protocole publié à l'origine. Kurbatov était d'accord.

  - _Preuves à connaissance nulle plus simples :_ Adam Gibson [a suggéré][gibson pp1] que
    l'utilisation de [schnorr][topic schnorr signatures] et [taproot][topic taproot] plutôt que des clés
    publiques hashées pourrait considérablement simplifier et accélérer la construction et la
    vérification de la preuve à connaissance nulle requise. Towns [a proposé][towns pp2] une approche
    tentante, que [Gibson][gibson pp2] a analysée.

  La discussion était en cours au moment de la rédaction.

- **Discussion continue sur les scripts d'ancrage éphémères pour LN :** Matt Morehouse [a
  répondu][morehouse eanchor] au fil de discussion sur quel script d'[ancrage éphémère][topic
  ephemeral anchors] LN devrait utiliser pour les futurs canaux (voir le [Bulletin #340][news340 eanchor]).
  Il a exprimé des préoccupations concernant le griefing des frais par des
  tiers sur les transactions avec des sorties [P2A][topic ephemeral anchors].

  Anthony Towns [a noté][towns eanchor] que le griefing de la contrepartie est une préoccupation plus
  grande, puisque la contrepartie est plus susceptible d'être en position de voler des fonds si le
  canal n'est pas fermé à temps ou dans l'état approprié. Les tiers qui retardent votre transaction ou
  tentent d'augmenter modérément son taux de frais pourrait perdre une partie de son argent, sans moyen direct
  de tirer profit de vous.

  Greg Sanders [a suggéré][sanders eanchor] de penser de manière probabiliste :
  si le pire qu'un griefer tiers puisse faire est d'augmenter le coût de votre
  transaction de 50%, mais utiliser une méthode résistante au griefing coûte environ 10% de plus, vous
  attendez-vous vraiment à être griefé par un tiers plus souvent qu'une fermeture forcée sur cinq---surtout si le
  griefer tiers peut perdre de l'argent et ne bénéficie pas financièrement ?

- **Statistiques sur les évictions d'orphelins :** le développeur 0xB10C [a posté][b10c orphan]
  sur Delving Bitcoin avec des statistiques sur le nombre de transactions
  évincées des pools d'orphelins pour ses nœuds. Les transactions orphelines sont
  des transactions non confirmées pour lesquelles un nœud n'a pas encore toutes ses
  transactions parentes, sans lesquelles elle ne peut pas être incluse dans un bloc.
  Bitcoin Core garde par défaut jusqu'à 100 transactions orphelines. Si une nouvelle
  transaction orpheline arrive après que le pool soit plein, une transaction orpheline précédemment
  reçue est évincée.

  0xB10C a trouvé que, certains jours, plus de 10 millions d'orphelins étaient
  évincés par son nœud, avec un taux de pointe de plus de 100 000 évictions par
  minute. En enquêtant, il a trouvé ">99% de celles-ci [...] sont similaires
  à cette [transaction][runestone tx], qui semble liée aux frappes de runestone [un protocole de pièce
  colorée (NFT)]" Il est apparu que beaucoup des
  mêmes transactions orphelines étaient demandées à plusieurs reprises, aléatoirement évincées peu de
  temps après, puis demandées à nouveau.

- **Proposition mise à jour pour le processus BIP mis à jour :** Mark "Murch" Erhardt
  [a posté][erhardt bip3] sur la liste de diffusion Bitcoin-Dev pour annoncer que son brouillon
  BIP pour un processus BIP révisé a reçu l'identifiant BIP3
  et est prêt pour une révision supplémentaire---possiblement son dernier cycle de révision
  avant d'être fusionné et activé. Toute personne ayant des opinions est encouragée
  à laisser un retour sur la [pull request][bips #1712].

## Bitcoin Core PR Review Club

*Dans cette section mensuelle, nous résumons une récente réunion du [Bitcoin Core PR Review Club][],
en soulignant certaines des questions et réponses importantes. Cliquez sur une question ci-dessous
pour voir un résumé de la réponse de la réunion.*

[Cluster mempool : introduire TxGraph][review club 31363] est un PR par
[sipa][gh sipa] qui introduit la classe `TxGraph`, encapsulant
la connaissance des frais (effectifs), tailles, et dépendances entre
toutes les transactions du mempool, mais rien d'autre. Il fait partie du projet [cluster
mempool][topic cluster mempool] et apporte une interface complète
qui permet l'interaction avec le graphe du mempool à travers
des fonctions de mutation, d'inspection et de mise en scène.

Notamment, `TxGraph` n'a aucune connaissance sur `CTransaction`,
les entrées, sorties, txids, wtxids, la priorisation, la validité, les règles de politique,
et bien plus. Cela rend plus facile de (presque) pleinement spécifier
le comportement de la classe, permettant des tests basés sur la simulation---qui sont
inclus dans le PR.

{% include functions/details-list.md
  q0="Qu'est-ce que le \"graphe\" du mempool et dans quelle mesure existe-t-il dans le code du mempool sur master ?"
  a0="Sur la branche master, le graphe du mempool existe implicitement sous forme d'ensemble d'objets
  `CTxMemPoolEntry` comme nœuds, et leurs relations ancêtre/dépendant qui peuvent être parcourues de
  manière récursive avec `GetMemPoolParents()` et `GetMemPoolChildren()`."
  a0link="https://bitcoincore.reviews/31363#l-26"

  q1="Quels sont les avantages d'avoir un `TxGraph`, en vos propres mots ? Pouvez-vous penser à des inconvénients ?"
  a1="Les avantages incluent : 1) `TxGraph` permet la mise en œuvre d'un [mempool en cluster][topic
  cluster mempool], avec tous ses avantages. 2) Une meilleure encapsulation du code mempool, utilisant
  des structures de données plus efficaces. 3) Facilite l'interface avec le mempool et sa
  compréhension, en abstrayant les détails topologiques tels que l'évitement de compter deux fois les
  remplacements.
  <br><br>Les inconvénients incluent : 1) Les efforts importants de révision et de test associés aux
  grands changements introduits. 2) Cela restreint la manière dont la validation peut dicter les
  limites de topologie par transaction, comme c'est par exemple pertinent pour TRUC et d'autres
  politiques. 3) Un très léger surcoût de performance d'exécution causé par la traduction vers et
  depuis les pointeurs `TxGraph::Ref*`."
  a1link="https://bitcoincore.reviews/31363#l-54"

  q2="Combien de `Clusters` une transaction individuelle peut-elle faire partie, au sein d'un `TxGraph` ?"
  a2="Même si conceptuellement une transaction ne peut appartenir qu'à un seul cluster, la réponse est
  2. Cela est dû au fait qu'un `TxGraph` peut encapsuler 2 graphes parallèles : \"principal\" et,
  optionnellement, \"staging\"."
  a2link="https://bitcoincore.reviews/31363#l-116"

  q3="Que signifie pour un `TxGraph` d'être surdimensionné ? Est-ce la même chose que le mempool étant plein ?"
  a3="Un `TxGraph` est surdimensionné lorsqu'au moins l'un de ses `Cluster`s dépasse le
  `MAX_CLUSTER_COUNT_LIMIT`. Ce n'est pas la même chose que le mempool étant plein, car un `TxGraph`
  peut avoir plus d'un `Cluster`."
  a3link="https://bitcoincore.reviews/31363#l-147"

  q4="Si un `TxGraph` est surdimensionné, quelles fonctions peuvent encore être appelées, et lesquelles ne le peuvent pas ?"
  a4="Les opérations qui pourraient nécessiter de matérialiser réellement un cluster surdimensionné,
  ainsi que les fonctions nécessitant un travail en O(n<sup>2</sup>) ou plus, ne sont pas autorisées
  pour un `Cluster` surdimensionné. Cela inclut des opérations telles que le calcul des
  ancêtres/descendants d'une transaction. Les opérations de mutation (`AddTransaction()`,
  `RemoveTransaction()`, `AddDependency()`, et `SetTransactionFee()`), et des opérations telles que
  `Trim()` (approximativement `O(n log n)`) sont encore autorisées."
  a4link="https://bitcoincore.reviews/31363#l-162"

## Mises à jour et versions candidates

_Nouvelles versions et candidats à la version pour les projets d'infrastructure Bitcoin populaires.
Veuillez envisager de mettre à jour vers les nouvelles versions ou d'aider à tester les versions candidates ._

- [LND v0.18.5-beta][] est une version de correction de bugs de cette implémentation populaire de
  nœud LN. Ses corrections de bugs sont décrites comme "importantes" et "critique" dans ses notes de version.

- [Bitcoin Inquisition 28.1][] est une version mineure de ce noeud complet en [signet][topic signet]
  conçu pour expérimenter avec des propositions de soft forks et d'autres changements majeurs de
  protocole. Il inclut les corrections de bugs présentes dans Bitcoin Core 28.1 ainsi que le support
  pour [ephemeral dust][topic ephemeral anchors].

## Changements notables dans le code et la documentation

_Changements récents notables dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning
repo], [Eclair][eclair repo], [LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo],
[Hardware Wallet Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement Proposals (BIPs)][bips repo],
[Lightning BOLTs][bolts repo], [Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin
inquisition repo], et [BINANAs][binana repo]._

- [Bitcoin Core #25832][] ajoute cinq nouveaux points de trace et de la documentation pour
  surveiller les événements de connexion des pairs tels que la durée de vie de la connexion, la
  fréquence de reconnexion par IP et netgroup, la découragement des pairs, l'éviction, le mauvais
  comportement, et plus. Les utilisateurs de Bitcoin Core qui ont le filtrage Extended Berkeley Packet
  Filter (eBPF) activé peuvent se brancher sur les points de trace en utilisant les scripts d'exemple
  fournis, ou écrire leurs propres scripts de traçage (voir les Bulletins [#160][news160 ebpf] et
  [#244][news244 ebpf]).

- [Eclair #2989][] ajoute le support pour les [batched][topic payment batching] splices dans le
  routeur, permettant le suivi de plusieurs canaux dépensés dans une seule transaction de
  [splice][topic splicing]. En raison de l'impossibilité de cartographier de manière déterministe les
  nouvelles [annonces de canal][topic channel announcements] à leurs canaux respectifs, le routeur met
  à jour le premier canal correspondant qu'il trouve.

- [LDK #3440][] complète le support pour la réception de [paiements asynchrones][topic async
  payments] en vérifiant la demande de facture de l'expéditeur intégrée dans le message onion du
  [HTLC][topic htlc] (détenu par un nœud en amont) et en générant le `PaymentPurpose` correct pour
  réclamer le paiement. Un temps d'expiration absolu est maintenant fixé pour les paiements
  asynchrones entrants, empêchant la sonde indéfinie du statut en ligne d'un nœud, et le flux de
  communication nécessaire est ajouté pour libérer un HTLC détenu par un nœud en amont lorsque le nœud
  destinataire se reconnecte en ligne. Pour compléter l'implémentation complète du flux de paiement
  asynchrone, les nœuds doivent également être capables d'agir en tant que LSP qui émet des factures
  au nom des récepteurs asynchrones.

- [LND #9470][] ajoute un paramètre `deadline_delta` aux commandes RPC `BumpFee` et
  `BumpForceCloseFee`, spécifiant le nombre de blocs sur lesquels un budget donné (également à
  spécifier) sera entièrement alloué pour le bumping de frais et un [RBF][topic rbf] sera effectué. De
  plus, le paramètre `conf_target` est redéfini pour spécifier le nombre de blocs pour lesquels
  l'estimateur de frais sera interrogé pour obtenir le taux de frais actuel, pour les deux commandes
  RPC mentionnées ci-dessus ainsi que le `BumpCloseFee` déprécié.

- [BTCPay Server #6580][] supprime une vérification qui confirme la présence et la justesse du hash
  de description dans les factures [BOLT11][] pour [LNURL][topic lnurl]-pay. Ce changement est en
  accord avec une [proposition de dépréciation][ludpr] dans la spécification des Documents LNURL
  (LUD), qui considère que l'exigence offre des bénéfices de sécurité minimaux tout en posant un défi
  significatif à l'implémentation de LNURL-pay. Le champ du paramètre hash de description est
  implémenté dans Core-Lightning (voir les Bulletins [#194][news194 deschash] et [#232][news232
  deschash]).

## Corrections

Dans une [note de bas de page][fn sigops] du bulletin de la semaine dernière, nous avons
incorrectement écrit : "Dans P2SH et le comptage de sigops d'entrée proposé, un OP_CHECKMULTISIG
avec plus de 16 clés publiques est compté comme 20 sigops." C'est une simplification excessive ;
pour les règles actuelles, veuillez consulter un [post][towns sigops] cette semaine par Anthony
Towns.

{% include snippets/recap-ad.md when="2025-02-18 15:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="25832,2989,3440,9470,6580,1712" %}
[lnd v0.18.5-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.18.5-beta
[Bitcoin Inquisition 28.1]: https://github.com/bitcoin-inquisition/bitcoin/releases/tag/v28.1-inq
[news340 pp]: /en/newsletters/2025/02/07/#emulating-op-rand
[towns sigops]: https://delvingbitcoin.org/t/great-consensus-cleanup-revival/710/69
[kurbatov pp]: https://delvingbitcoin.org/t/emulating-op-rand/1409
[harding pp]: https://delvingbitcoin.org/t/emulating-op-rand/1409/2
[towns pp1]: https://delvingbitcoin.org/t/emulating-op-rand/1409/3
[gibson pp1]: https://delvingbitcoin.org/t/emulating-op-rand/1409/5
[towns pp2]: https://delvingbitcoin.org/t/emulating-op-rand/1409/6
[gibson pp2]: https://delvingbitcoin.org/t/emulating-op-rand/1409/7
[morehouse eanchor]: https://delvingbitcoin.org/t/which-ephemeral-anchor-script-should-lightning-use/1412/8
[news340 eanchor]: /en/newsletters/2025/02/07/#tradeoffs-in-ln-ephemeral-anchor-scripts
[towns eanchor]: https://delvingbitcoin.org/t/which-ephemeral-anchor-script-should-lightning-use/1412/9
[sanders eanchor]: https://delvingbitcoin.org/t/which-ephemeral-anchor-script-should-lightning-use/1412/11
[b10c orphan]: https://delvingbitcoin.org/t/stats-on-orphanage-overflows/1421/
[runestone tx]: https://mempool.space/tx/ac8990b04469bad8630eaf2aa51561086d81a241deff6c95d96d27e41fa19f90
[erhardt bip3]: https://mailing-list.bitcoindevs.xyz/bitcoindev/25449597-c5ed-42c5-8ac1-054feec8ad88@murch.one/
[fn sigops]: /en/newsletters/2025/02/07/#fn:2kmultisig
[review club 31363]: https://bitcoincore.reviews/31363
[gh sipa]: https://github.com/sipa
[news244 ebpf]: /fr/newsletters/2023/03/29/#bitcoin-core-26531
[news160 ebpf]: /en/newsletters/2021/08/04/#bitcoin-core-22006
[ludpr]: https://github.com/lnurl/luds/pull/234
[news232 deschash]: /fr/newsletters/2023/01/04/#btcpay-server-4411
[news194 deschash]: /en/newsletters/2022/04/06/#c-lightning-5121