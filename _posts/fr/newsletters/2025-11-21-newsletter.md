---
title: 'Bulletin Hebdomadaire Bitcoin Optech #381'
permalink: /fr/newsletters/2025/11/21/
name: 2025-11-21-newsletter-fr
slug: 2025-11-21-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine examine une analyse de la manière dont les temps de propagation des
blocs peuvent affecter les revenus des mineurs et décrit une nouvelle approche pour résoudre les
protocoles où plusieurs parties partagent des fonds. Sont également incluses nos sections régulières
résumant les changements récents apportés aux clients et services et les résumés des modifications
notables apportées aux logiciels d'infrastructure Bitcoin populaires.

## Nouvelles

- **Modélisation des taux de blocs obsolètes par délai de propagation et centralisation du minage :**
  Antoine Poinsot a [posté sur Delving Bitcoin][antoine delving] à propos de la modélisation
  des taux de blocs obsolètes et comment le temps de propagation des blocs affecte les revenus d'un
  mineur en fonction de sa puissance de hachage. Il a établi un
  scénario de base dans lequel tous les mineurs agissent de manière réaliste (avec un nœud Bitcoin
  Core par défaut) : s'ils reçoivent un nouveau bloc, ils commenceraient immédiatement
  à miner dessus et à le publier. Cela conduirait à des revenus proportionnels à
  leur part de la puissance de hachage étant donné que le temps de propagation est nul.

  Dans son modèle avec propagation uniforme des blocs, il a décrit deux situations dans lesquelles un
  bloc devient obsolète.

  1. Un autre mineur a trouvé un bloc **avant** ce mineur. Tous les autres mineurs ont reçu
     le bloc du mineur concurrent en premier et ont commencé à miner dessus. N'importe lequel
     de ces mineurs peut alors trouver un second bloc basé sur le bloc reçu.

  2. Un autre mineur trouve un bloc **après** ce mineur. Il commence immédiatement à miner
     dessus. Le bloc suivant est également trouvé par le même mineur.

  Poinsot souligne qu'entre ces situations, il est plus probable qu'un
  bloc devienne obsolète dans la première situation. Cela suggère que les mineurs peuvent
  se soucier davantage d'entendre les blocs des autres plus rapidement qu'ils ne se soucient de
  publier les leurs. Il suggère également que la probabilité de la situation 2 augmente
  significativement avec la centralisation du minage. Alors que dans les deux situations la
  probabilité augmente à mesure que la puissance de hachage du mineur augmente, Poinsot voulait
  calculer de combien.

  Pour ce faire, il a créé les deux modèles suivants.

  Où **h** est la part de la puissance de hachage du réseau, **s** est le nombre de secondes
  que le reste du réseau a trouvé un bloc concurrent avant lui, **H** est l'
  ensemble des puissances de hachage sur le réseau représentant sa distribution.

  Modèle pour la situation 1 :
  ![Illustration de P(un autre mineur a trouvé un bloc avant)](/img/posts/2025-11-stale-rates1.png)

  Modèle pour la situation 2 :
  ![Illustration de P(un autre mineur a trouvé un bloc après)](/img/posts/2025-11-stale-rates2.png)

  Il a ensuite montré des graphiques des probabilités qu'un bloc d'un mineur devienne obsolète en
  fonction des temps de propagation, étant donné la distribution définie de la puissance de hachage.
  Les graphiques montrent comment les plus grands mineurs gagnent significativement plus, plus le temps
  de propagation est long.

  Par exemple, une opération de minage avec 5EH/s peut s'attendre à un revenu de 91 millions de
  dollars et si les blocs prenaient 10 secondes à se propager, le revenu augmenterait de 100 000
  dollars. Gardez à l'esprit que les 91 millions de dollars représentent le revenu et non le profit,
  donc l'augmentation du revenu de 100 000 dollars contribuerait à un facteur plus important en termes
  de profit net du mineur.
  Sous les graphiques, il fournit la méthodologie pour générer les graphiques et un lien vers sa
  [simulation][block prop simulation] qui corrobore les résultats du modèle utilisé pour générer les
  graphiques.

- **Passation de clé privée pour clôture collaborative** : ZmnSCPxj a [publié][privkeyhand post] sur
  Delving Bitcoin concernant la passation de clé privée, une optimisation que les protocoles peuvent
  mettre en œuvre lorsque des fonds, précédemment détenus par deux parties, doivent être remboursés à
  une seule entité. Cette amélioration nécessite le support de [taproot][topic taproot] et de
  [MuSig2][topic musig] pour fonctionner de la manière la plus efficace.

  Un exemple d'un tel protocole serait un [HTLC][topic htlc], où une partie paie l'autre si le
  préimage est révélé, créant une transaction de remboursement qui doit être signée par les deux
  parties. La passation de clé privée permettrait à une entité de simplement remettre une clé privée
  éphémère à l'autre après que le préimage ait été révélé, donnant ainsi au receveur un accès complet
  et unilatéral aux fonds.

  Les étapes pour réaliser une passation de clé privée sont :

  - Lors de la configuration d'un HTLC, Alice et Bob échangent chacun une clé publique éphémère et une
    clé publique permanente.

  - La branche de dépense par chemin de clé de la sortie taproot de l'HTLC est calculée comme le
    MuSig2 des clés publiques éphémères d'Alice et de Bob.

  - À la fin des opérations du protocole, Bob fournit le préimage à Alice, qui à son tour lui remet la
    clé privée éphémère.

  - Bob peut maintenant dériver la clé privée combinée pour la somme MuSig2, obtenant un contrôle
    total sur les fonds.

  Cette optimisation apporte certains avantages particuliers. Tout d'abord, en cas de pic soudain des
  frais onchain, Bob serait capable de [RBF][topic rbf] la transaction sans la collaboration de
  l'autre partie. Cette fonctionnalité est particulièrement utile pour les développeurs de protocoles,
  puisqu'ils n'auraient pas besoin d'implémenter RBF dans un simple prototype. Deuxièmement, le
  receveur serait capable de regrouper la transaction réclamant les fonds avec toute autre opération.

  La passation de clé privée est limitée aux protocoles qui nécessitent que les fonds restants soient
  entièrement transférés à un seul bénéficiaire. Ainsi, le [splicing][topic splicing] ou la clôture
  coopérative des canaux Lightning ne bénéficieraient pas de cela.

## Changements dans les services et logiciels clients

*Dans cette rubrique mensuelle, nous mettons en lumière des mises à jour intéressantes des
portefeuilles et services Bitcoin.*

- **Lancement d'Arkade :**
  [Arkade][ark labs blog] est une implémentation du [protocole Ark][topic ark] qui inclut également
  plusieurs SDKs pour différents langages de programmation, un portefeuille, un plugin BTCPayServer,
  et d'autres fonctionnalités.

- **Application mobile de surveillance du mempool :**
  L'application Android [Mempal][mempal gh] fournit diverses métriques et alertes concernant le réseau
  Bitcoin, en s'approvisionnant de données d'un serveur mempool auto-hébergé.

- **IDE basé sur le web pour la politique et miniscript :**
  [Miniscript Studio][miniscript studio site] fournit une interface pour interagir avec
  [miniscript][topic miniscript] et le langage de politique. Un [article de blog][miniscript studio
  blog] décrit les fonctionnalités et le [code source][miniscript studio gh] est disponible.

- **Phoenix Wallet ajoute des canaux taproot :**
  Phoenix Wallet a [ajouté][phoenix post] le support pour [taproot][topic taproot]

- **Lancement de Nunchuk 2.0 :**
  [Nunchuk 2.0][nunchuk blog] prend en charge les configurations de portefeuille utilisant le
  multisig, les [timelocks][topic timelocks], et miniscript. Il inclut également des fonctionnalités de multisig
  dégradant.

- **Outil d'analyse du trafic gossip LN annoncé :**
  [Gossip Observer][gossip observer gh] collecte les messages gossip du Lightning Network depuis
  plusieurs nœuds et fournit des métriques résumées. Les résultats peuvent informer un protocole de
  réconciliation de set semblable à [minisketch][topic minisketch] pour Lightning. Un [sujet Delving
  Bitcoin][gossip observer delving] inclut une discussion sur l'approche.

## Changements notables dans le code et la documentation

_Changements notables récents dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning
repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Interface de Portefeuille Matériel (HWI)][hwi
repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay Server][btcpay server repo], [BDK][bdk repo],
[Propositions d'Amélioration de Bitcoin (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Inquisition Bitcoin][bitcoin inquisition
repo], et [BINANAs][binana repo]._

- [Bitcoin Core #33745][] assure que les blocs soumis par un client externe [StratumV2][topic pooled
  mining] via la nouvelle interface de communication inter-processus (IPC) de minage
  `submitSolution()` (voir le [Bulletin #325][news325 ipc]) ont leur engagement de témoin revalidé.
  Auparavant, Bitcoin Core ne vérifiait cela que lors de la construction du modèle original, ce qui
  permettait à un bloc avec un engagement de témoin invalide ou manquant d'être accepté comme le
  meilleur sommet de chaîne.

- [Core Lightning #8537][] fixe la limite `maxparts` (voir le [Bulletin #379][news379 parts]) sur
  `xpay` à six lors de la première tentative de paiement à un nœud non publiquement accessible en
  utilisant [MPP][topic multipath payments]. Cela se conforme à la limite de réception de six
  [HTLCs][topic htlc] sur les nœuds basés sur Phoenix pour le financement à la volée (voir le [Bulletin
  #323][news323 fly]) d'un type de [canal JIT][topic jit channels]. Si le routage échoue sous cette
  limite, `xpay` retire la limite et réessaie.

- [Core Lightning #8608][] introduit des biais au niveau du nœud pour `askrene` (voir le [Bulletin
  #316][news316 askrene]), en complément des biais de canal existants. Une nouvelle commande RPC
  `askrene-bias-node` est ajoutée pour favoriser ou défavoriser tous les canaux sortants ou entrants
  d'un nœud spécifié. Un champ `timestamp` est ajouté aux biais pour qu'ils expirent après une
  certaine période.

- [Core Lightning #8646][] met à jour la logique de reconnexion pour les canaux [splicé][topic
  splicing], l'alignant avec les changements de spécification proposés dans [BOLTs #1160][] et [BOLTs
  #1289][]. Spécifiquement, cela améliore les TLVs `channel_reestablish` afin que les pairs puissent
  synchroniser de manière fiable l'état de splice et communique ce qui doit être retransmis.
  Cette mise à jour constitue un changement majeur pour les canaux épissés, donc les deux parties
  doivent se mettre à niveau simultanément pour éviter des perturbations.
  Voir le [Bulletin #374][news374 ldk] pour un changement similaire dans LDK.

- [Core Lightning #8569][] ajoute un support expérimental pour les [canaux JIT][topic jit channels],
  tel que spécifié par [BLIP52][] (LSPS2), dans le mode `lsp-trusts-client` et sans support pour
  [MPP][topic multipath payments]. Cette fonctionnalité est activée derrière les options
  `experimental-lsps-client` et `experimental-lsps2-service` et représente le premier pas vers le
  support complet des canaux JIT.

- [Core Lightning #8558][] ajoute une commande RPC `listnetworkevents`, qui affiche l'historique des
  connexions, déconnexions, échecs et latences de ping entre pairs. Elle introduit également une
  option de configuration `autoclean-networkevents-age` (par défaut 30 jours) pour contrôler la durée
  de conservation des journaux d'événements réseau.

- [LDK #4126][] introduit une vérification de l'authentification basée sur `ReceiveAuthKey` sur les
  [chemins de paiement aveuglés][topic rv routing], remplaçant l'ancien schéma par hop HMAC/nonce
  (voir le [Bulletin #335][news335 hmac]). Cela s'appuie sur [LDK #3917][], qui a ajouté
  `ReceiveAuthKey` pour les chemins de messages aveuglés. Réduire les données par hop diminue la
  charge utile et ouvre la voie à des sauts de paiement fictifs dans une future PR, similaire aux
  sauts de messages fictifs (voir le [Bulletin #370][news370 dummy]).

- [LDK #4208][] met à jour son estimation de poids pour supposer de manière consistante des
  signatures encodées en DER de 72 octets, au lieu d'utiliser 72 dans certains cas et 73 dans
  d'autres. Les signatures de 73 octets ne sont pas standard et LDK ne les produit jamais. Voir
  le [Bulletin #379][news379 sign] pour un changement lié dans Eclair.

- [LND #9432][] ajoute une nouvelle option de configuration globale `upfront-shutdown-address`, qui
  spécifie une adresse Bitcoin par défaut pour les fermetures de canal coopératives, à moins qu'elle
  ne soit remplacée lors de l'ouverture ou de l'acceptation d'un canal spécifique. Cela s'appuie sur
  la fonctionnalité de fermeture anticipée spécifiée dans [BOLT2][]. Voir le [Bulletin #76][news76
  upfront] pour une couverture précédente de l'implémentation par LND.

- [BOLTs #1284][] met à jour BOLT11 pour clarifier que lorsqu'un champ `n` est présent dans une
  facture, la signature doit être sous forme normalisée en S inférieur, et lorsqu'il est absent, la
  récupération de clé publique peut accepter les signatures en S supérieur et en S inférieur. Voir les
  Bulletins [#371][news371 eclair] et [#373][news373 ldk] pour les changements récents de LDK et
  Eclair qui implémentent ce comportement.

- [BOLTs #1044][] spécifie la fonctionnalité optionnelle [échecs attribuables][topic attributable
  failures], qui ajoute des données d'attribution aux messages d'échec afin que les sauts s'engagent
  sur les messages qu'ils envoient. Si un nœud corrompt un message d'échec, l'expéditeur peut
  identifier et pénaliser le nœud plus tard. Pour plus de détails sur le mécanisme et les
  implémentations LDK et Eclair, voir les Bulletins [#224][news224 fail], [#349][news349 fail] et
  [#356][news356 fail].

% include snippets/recap-ad.md when="2025-11-25 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="33745,8537,8608,8646,1160,1289,8569,8558,4126,3917,4208,9432,1284,1044" %}
[antoine delving]: https://delvingbitcoin.org/t/propagation-delay-and-mining-centralization-modeling-stale-rates/2110
[block prop simulation]: https://github.com/darosior/miningsimulation
[privkeyhand post]: https://delvingbitcoin.org/t/private-key-handover/2098
[news325 ipc]: /fr/newsletters/2024/10/18/#bitcoin-core-30955
[news379 parts]: /fr/newsletters/2025/11/07/#core-lightning-8636
[news323 fly]: /fr/newsletters/2024/10/04/#eclair-2861
[news316 askrene]: /fr/newsletters/2024/08/16/#core-lightning-7517
[news374 ldk]: /fr/newsletters/2025/10/03/#ldk-4098
[news335 hmac]: /fr/newsletters/2025/01/03/#ldk-3435
[news370 dummy]: /fr/newsletters/2025/09/05/#ldk-3726
[news379 sign]: /fr/newsletters/2025/11/07/#eclair-3210
[news76 upfront]: /en/newsletters/2019/12/11/#lnd-3655
[news371 eclair]: /fr/newsletters/2025/09/12/#eclair-3163
[news373 ldk]: /fr/newsletters/2025/09/26/#ldk-4064
[news224 fail]: /fr/newsletters/2022/11/02/#attribution-de-l-echec-du-routage-ln
[news349 fail]: /fr/newsletters/2025/04/11/#ldk-2256
[news356 fail]: /fr/newsletters/2025/05/30/#eclair-3065
[ark labs blog]: https://blog.arklabs.xyz/press-start-arkade-goes-live/
[mempal gh]: https://github.com/aeonBTC/Mempal
[miniscript studio gh]: https://github.com/adyshimony/miniscript-studio
[miniscript studio blog]: https://adys.dev/blog/miniscript-studio-intro
[miniscript studio site]: https://adys.dev/miniscript
[phoenix post]: https://x.com/PhoenixWallet/status/1983524047712391445
[nunchuk blog]: https://nunchuk.io/blog/autonomous-inheritance
[gossip observer gh]: https://github.com/jharveyb/gossip_observer
[gossip observer delving]: https://delvingbitcoin.org/t/gossip-observer-new-project-to-monitor-the-lightning-p2p-network/2105
