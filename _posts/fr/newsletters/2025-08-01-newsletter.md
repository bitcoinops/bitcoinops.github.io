---
title: 'Bulletin Hebdomadaire Bitcoin Optech #365'
permalink: /fr/newsletters/2025/08/01/
name: 2025-08-01-newsletter-fr
slug: 2025-08-01-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine résume les résultats d'un test de préremplissage de bloc compact et
fournit un lien vers une bibliothèque d'estimation des frais basée sur le mempool.
Sont également incluses nos sections régulières résumant les récentes discussions sur
la modification des règles de consensus de Bitcoin, annonçant des mises à jour et des versions candidates,
et décrivant les changements notables dans les projets d'infrastructure Bitcoin populaires.

## Nouvelles

- **Test du préremplissage de bloc compact :** David Gumberg a [répondu][gumberg prefilling] à un
  fil de discussion Delving Bitcoin sur l'efficacité de la reconstruction de bloc compact
  (précédemment couverte dans les Bulletins [315][news315 cb] et [339][news339 cb]) avec un résumé
  des résultats qu'il a obtenus en testant le [relais de bloc compact][topic compact block relay]
  _préremplir_---une node relayant de manière préventive certaines ou toutes les transactions
  d'un nouveau bloc à ses pairs lorsqu'elle pense que les pairs peuvent ne pas déjà avoir ces
  transactions. Le post de Gumberg est détaillé et fournit un lien vers un cahier Jupyter pour
  permettre à d'autres d'expérimenter par eux-mêmes. Les points clés incluent :

  - Considéré indépendamment du transport réseau, une règle simple pour déterminer quelles
    transactions préremplir a augmenté le taux de reconstructions de blocs réussies d'environ 62% à
    environ 98%.

  - Lors de la prise en compte du transport réseau, certains préremplissages peuvent avoir résulté en
    un aller-retour supplémentaire---annulant tout bénéfice dans ce cas et possiblement dégradant
    légèrement la performance. Cependant, de nombreux préremplissages auraient pu être construits pour
    éviter le problème, augmentant le taux de reconstruction probable à environ 93% et soutenant encore
    des améliorations.

- **Bibliothèque d'estimation des frais basée sur le mempool :** Lauren Shareshian a
  [posté][shareshian estimation] sur Delving Bitcoin pour annoncer une bibliothèque pour l'[estimation
  des frais][topic fee estimation] développée par Block. Contrairement à certains autres outils
  d'estimation des frais, elle utilise uniquement le flux de transactions entrant dans le mempool d'un
  nœud comme base de ses estimations. Le post compare la bibliothèque, Augur, à plusieurs services
  d'estimation des frais et trouve qu'Augur a un faible taux d'échec (c'est-à-dire, plus de 85% des
  transactions se confirment dans leur fenêtre prévue) et un faible taux de surestimation moyen
  (c'est-à-dire, les transactions paient des frais supérieurs d'environ 16% à ce qui est nécessaire).

  Abubakar Sadiq Ismail a [répondu][ismail estimation] au fil Delving et a également commencé un
  [problème][augur #3] informatif sur le dépôt Augur pour examiner certaines des hypothèses utilisées
  par la bibliothèque.

## Modification du consensus

_Une nouvelle section mensuelle résumant les propositions et discussions sur la modification des
règles de consensus de Bitcoin._

- **Migration à partir des sorties vulnérables aux quantiques :** Jameson Lopp a [posté][lopp qmig]
  sur la liste de diffusion Bitcoin-Dev une proposition en trois étapes pour éliminer progressivement
  les dépenses à partir des [sorties vulnérables aux quantiques][topic quantum resistance].

  - Trois ans après l'activation par consensus du schéma de signature résistant aux quantiques
    [BIP360][] (ou un schéma alternatif), un soft fork rejetterait les transactions avec des sorties
    payant des adresses vulnérables au quantique. Seules les dépenses vers des sorties résistantes au quantique
    seraient autorisées.

  - Deux ans plus tard, un second soft fork rejetterait les dépenses provenant de sorties vulnérables
    au quantique. Tout fond restant dans des sorties vulnérables au quantique deviendrait inutilisable.

  - Optionnellement, à un moment non défini ultérieurement, un changement de consensus pourrait
    permettre les dépenses depuis des sorties vulnérables aux quantique en utilisant un schéma de preuve
    résistant aux quantique (voir le [Bulletin #361][news361 pqcr] pour un exemple).

  La plupart des discussions dans le fil de discussion ont largement répété les discussions
  précédentes sur la nécessité d'empêcher les gens de dépenser des bitcoins vulnérables aux quantique
  avant qu'il soit certain qu'un ordinateur quantique assez rapide pour les voler existait (voir le
  [Bulletin 348][news348 destroy]). Des arguments raisonnables ont été avancés des deux côtés et
  nous devons nous attendre à ce que ce débat continue.

- **Proposition de `OP_TEMPLATEHASH` natif à Taproot :** Greg Sanders a [posté][sanders th] sur la
  liste de diffusion Bitcoin-Dev une proposition pour ajouter trois opcodes à [tapscript][topic
  tapscript]. Deux des opcodes sont les [OP_CHECKSIGFROMSTACK][topic op_checksigfromstack] et
  `OP_INTERNALKEY` précédemment proposés (voir le [Bulletin 285][news285 ik]). Le dernier opcode est
  `OP_TEMPLATEHASH`, une variation native à taproot de [OP_CHECKTEMPLATEVERIFY][topic
  op_checktemplateverify] (`OP_CTV`) avec les différences suivantes soulignées par les auteurs :

  - Pas de changements pour les scripts legacy (pré-segwit). Voir le [Bulletin #361][news361 ctvlegacy]
    pour une précédente discussion sur cette alternative.

  - Les données qui sont hashées (et l'ordre dans lequel elles sont hashées) sont très similaires aux
    données hashées pour les signatures afin de s'engager dans [taproot][topic taproot], simplifiant
    l'implémentation pour tout logiciel qui supporte déjà taproot.

  - Cela s'engage sur l'[annexe][topic annex] de taproot, ce que `OP_CTV` ne fait pas. Une manière
    d'utiliser cela est de s'assurer que certaines données sont publiées dans le cadre d'une
    transaction, comme des données utilisées dans un protocole de contrat pour permettre à une
    contrepartie de se récupérer de la publication d'un ancien état.

  - Cela redéfinit un opcode `OP_SUCCESSx` plutôt qu'un opcode `OP_NOPx`. Les soft forks redéfinissant
    les opcodes `OP_NOPx` doivent être des opcodes `VERIFY` qui marquent la transaction comme invalide
    s'ils échouent. Les redéfinitions d'opcodes `OP_SUCCESSx` peuvent simplement placer soit `1`
    (succès) soit `0` (échec) sur la pile après exécution ; cela leur permet d'être utilisés directement
    dans des cas où les redéfinitions de `OP_NOPx` devraient être enveloppées par des conditionnels tels
    que les instructions `OP_IF`.

  - "Cela empêche de surprendre les entrées avec ... `scriptSig`" (voir le [Bulletin #361][news361 bitvm] ).

  Brandon Black a [répondu][black th] avec une comparaison de la proposition à sa précédente
  proposition de bundle LNHANCE (voir le [Bulletin 285][news285 ik]) et l'a trouvée comparable à bien
  des égards, bien qu'il ait noté qu'elle est moins efficace en espace onchain pour le _contrôle de
  congestion_ (une forme de paiement différé de [regroupement des paiements][topic payment batching]).

- **Proposition pour permettre des timelocks relatifs plus longs :** le développeur Pyth a
  [posté][pyth timelock] sur Delving Bitcoin pour suggérer de permettre aux timelocks relatifs
  [BIP68][] d'être étendus de leur maximum actuel d'environ un an à un nouveau maximum d'environ dix
  ans. Cela nécessiterait un soft fork et l'utilisation d'un bit supplémentaire du champ _sequence_ de
  l'entrée de transaction.

  Fabian Jahr a [répondu][jahr timelock] avec une préoccupation que des [timelocks][topic timelocks]
  trop éloignés dans le futur pourraient conduire à une perte de fonds, comme en raison du
  développement des ordinateurs quantiques (ou, nous ajoutons, le déploiement de protocoles de défense
  quantique tels que la proposition de Jameson Lopp décrite plus tôt dans ce bulletin). Steven
  Roose a [noté][roose timelock] que des timelocks très éloignés dans le futur sont déjà possibles en
  utilisant d'autres mécanismes de verrouillage temporel (tels que les transactions pré-signées et
  [BIP65 CLTV][bip65]), et Pyth a ajouté que leur cas d'utilisation souhaité est pour un chemin de
  récupération de portefeuille où le long timelock ne serait utilisé que si le chemin principal
  devenait indisponible et l'alternative serait de toute façon la perte permanente des fonds.

- **Sécurité contre les ordinateurs quantiques avec taproot comme schéma d'engagement :** Tim
  Ruffing a [posté][ruffing qtr] un lien vers un [papier][ruffing paper] qu'il a écrit analysant la
  sécurité des engagements [taproot][topic taproot] contre la manipulation par des ordinateurs
  quantiques. Il examine si les engagements taproot aux tapleaves continueraient de posséder les
  propriétés de _liaison_ et de _masquage_ qu'ils ont contre les ordinateurs classiques. Il conclut
  que :
    > Un attaquant quantique doit effectuer au moins 2^81 évaluations de
    > SHA256 pour créer une sortie Taproot et être capable de l'ouvrir à une
    > racine Merkle inattendue avec une probabilité de 1/2. Si l'attaquant
    > dispose uniquement de machines quantiques dont la plus longue séquence de calculs SHA256
    > est limitée à 2^20, alors l'attaquant a besoin d'au moins 2^92 de ces
    > machines pour obtenir une probabilité de succès de 1/2.

  Si les engagements taproot sont sécurisés contre la manipulation par des ordinateurs quantiques,
  alors la résistance quantique peut être ajoutée à Bitcoin en désactivant les dépenses de chemin de
  clé et en ajoutant des opcodes de vérification de signature résistants aux quantiques à
  [tapscript][topic tapscript]. Une mise à jour récente à [BIP360][] pay-to-quantum-resistant-hash
  qu'Ethan Heilman a [posté][heilman bip360] sur la mailing list Bitcoin-Dev fait exactement ce
  changement.

## Mises à jour et versions candidates

_Nouvelles versions et versions candidates pour des projets d'infrastructure Bitcoin populaires.
Veuillez envisager de mettre à niveau vers les nouvelles versions ou d'aider à tester les versions candidates._

- [Bitcoin Core 29.1rc1][] est un candidat à la sortie pour une version de maintenance du logiciel
  de nœud complet prédominant.

## Changements notables dans le code et la documentation

_Changements notables récents dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core
lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware WalletInterface (HWI)][hwi repo],
[Rust Bitcoin][rust bitcoin repo], [BTCPay Server][btcpay server repo], [BDK][bdk repo], [Bitcoin
Improvement Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo], [Lightning BLIPs][blips
repo], [Bitcoin Inquisition][bitcoin inquisition repo], et [BINANAs][binana repo]._

- [Bitcoin Core #29954][] étend le RPC `getmempoolinfo` en ajoutant deux champs de politique de
  relais à son objet de réponse : `permitbaremultisig` (si le nœud relaie les sorties multisig nues)
  et `maxdatacarriersize` (le nombre maximal d'octets agrégés autorisés dans les sorties OP_RETURN
  pour une transaction dans le mempool). D'autres drapeaux de politique, tels que [`fullrbf`][topic
  rbf] et `minrelaytxfee`, étaient déjà exposés, donc ces ajouts permettent d'avoir un aperçu complet
  de la politique de relais.

- [Bitcoin Core #33004][] active par défaut l'option `-natpmp`, permettant le transfert automatique
  de port via le [Port Control Protocol (PCP)][pcp] avec un recours au [NAT Port Mapping Protocol
  (NAT-PMP)][natpmp] (voir le Bulletin [323][news323 natpmp]). Un nœud en écoute derrière un routeur
  qui supporte soit PCP soit NAT-PMP devient accessible sans configuration manuelle.

- [LDK #3246][] permet la création d'offres [BOLT12][topic offers] et de remboursements sans un
  [chemin aveuglé][topic rv routing] en utilisant le `signing_pubkey` de l'offre comme destination.
  Les fonctions `create_offer_builder` et `create_refund_builder` délèguent désormais la création de
  chemin aveuglé à `MessageRouter::create_blinded_paths`, où un appelant peut générer un chemin
  compact en passant `DefaultMessageRouter`, un chemin de pubkey de longueur complète avec
  `NodeIdMessageRouter`, ou aucun chemin du tout avec `NullMessageRouter`.

- [LDK #3892][] expose publiquement la signature de l'arbre de Merkle des factures [BOLT12][topic
  offers], permettant aux développeurs de construire des outils CLI ou d'autres logiciels pour
  vérifier la signature ou recréer des factures. Cette PR ajoute également un champ `OfferId` aux
  factures BOLT12 pour suivre l'offre d'origine.

- [LDK #3662][] implémente [BLIPs #55][], également connu sous le nom de LSPS05, qui définit comment
  les clients peuvent s'inscrire à des webhooks via un point de terminaison pour recevoir des
  notifications push d'un LSP. L'API expose des points de terminaison supplémentaires qui permettent
  aux clients de lister toutes les inscriptions de webhook ou de supprimer une inscription spécifique.
  Cela peut être utile pour les clients afin d'être notifiés lors de la réception d'un [paiement
  asynchrone][topic async payments].

{% include snippets/recap-ad.md when="2025-08-05 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="29954,33004,3246,3892,3662,55" %}
[bitcoin core 29.1rc1]: https://bitcoincore.org/bin/bitcoin-core-29.1/
[augur #3]: https://github.com/block/bitcoin-augur/issues/3
[news315 cb]: /fr/newsletters/2024/08/09/#statistiques-sur-la-reconstruction-de-blocs-compacts
[news339 cb]: /fr/newsletters/2025/01/31/#statistiques-mises-a-jour-sur-la-reconstruction-de-blocs-compacts
[gumberg prefilling]: https://delvingbitcoin.org/t/stats-on-compact-block-reconstructions/1052/34
[shareshian estimation]: https://delvingbitcoin.org/t/augur-block-s-open-source-bitcoin-fee-estimation-library/1848/
[ismail estimation]: https://delvingbitcoin.org/t/augur-block-s-open-source-bitcoin-fee-estimation-library/1848/2
[news361 pqcr]: /fr/newsletters/2025/07/04/#fonction-de-commit-reveal-pour-la-recuperation-post-quantique
[sanders th]: https://mailing-list.bitcoindevs.xyz/bitcoindev/26b96fb1-d916-474a-bd23-920becc3412cn@googlegroups.com/
[news285 ik]: /fr/newsletters/2024/01/17/#nouvelle-proposition-de-soft-fork-combinant-lnhance
[news361 ctvlegacy]: /fr/newsletters/2025/07/04/#preoccupations-et-alternatives-au-support-legacy
[pyth timelock]: https://delvingbitcoin.org/t/exploring-extended-relative-timelocks/1818/
[jahr timelock]: https://delvingbitcoin.org/t/exploring-extended-relative-timelocks/1818/2
[roose timelock]: https://delvingbitcoin.org/t/exploring-extended-relative-timelocks/1818/3
[ruffing qtr]: https://mailing-list.bitcoindevs.xyz/bitcoindev/bee6b897379b9ae0c3d48f53d40a6d70fe7915f0.camel@real-or-random.org/
[ruffing paper]: https://eprint.iacr.org/2025/1307
[heilman bip360]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CAEM=y+W=rtU2PLmHve6pUVkMQQmqT67KOg=9hp5oMspuHrgMow@mail.gmail.com/
[lopp qmig]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CADL_X_fpv-aXBxX+eJ_EVTirkAJGyPRUNqOCYdz5um8zu6ma5Q@mail.gmail.com/
[news348 destroy]: /fr/newsletters/2025/04/04/#faut-il-detruire-les-bitcoins-vulnerables
[black th]: https://mailing-list.bitcoindevs.xyz/bitcoindev/aG9FEHF1lZlK6d0E@console/
[news361 bitvm]: /fr/newsletters/2025/07/04/#discussion-continue-sur-les-avantages-de-ctv-csfs-pour-bitvm
[news323 natpmp]: /fr/newsletters/2024/10/04/#bitcoin-core-30043
[pcp]: https://datatracker.ietf.org/doc/html/rfc6887
[natpmp]: https://datatracker.ietf.org/doc/html/rfc6886