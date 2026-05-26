---
title: 'Bulletin Hebdomadaire Bitcoin Optech #403'
permalink: /fr/newsletters/2026/05/01/
name: 2026-05-01-newsletter-fr
slug: 2026-05-01-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine décrit des recherches sur l'utilisation des filtres binary fuse comme alternative aux GCS utilisés dans les
filtres de blocs compacts. Sont également incluses nos rubriques habituelles résumant les propositions et discussions sur la modification
des règles de consensus de Bitcoin, annonçant de nouvelles versions et versions candidates, et décrivant les changements notables apportés
aux logiciels d'infrastructure Bitcoin populaires.

## Nouvelles

- **Filtres binary fuse comme alternative aux GCS de BIP158** : Csaba Purszki a [publié][bin fuse del] sur Delving Bitcoin ses recherches
  visant à trouver une meilleure alternative aux Golomb-Rice Coded Sets (GCS) utilisés pour les [filtres de blocs compacts][topic compact
  block filters] tels que définis dans le [BIP158][].

  Selon Purszki, une alternative appropriée peut être trouvée dans les filtres binary fuse, une famille de structures de données
  probabilistes pour l'appartenance approximative à un ensemble, et plus particulièrement dans la variante 16 bits, appelée Fuse16. La
  principale caractéristique de ce type d'algorithme est sa capacité à offrir un temps de requête en O(1) (à titre de référence, les GCS
  offrent O(N)), ce qui réduit la puissance CPU nécessaire pour interroger les filtres. De plus, ces filtres garantissent zéro faux négatif,
  avec un taux de faux positifs égal à `1/2^k`, `k` étant le nombre de bits.

  Purszki a fourni les résultats préliminaires de ses recherches, qui comparent les performances actuelles des GCS à celles des filtres
  binary fuse. Les tests ont été effectués sur 10 cas d'usage différents de portefeuilles (de 24 scripts jusqu'à 480), en exécutant les
  filtres sur 50 000 blocs du mainnet, sur deux CPU différents, un x86_64 de bureau et un ARM. Les filtres binary fuse ont pu obtenir une
  accélération de 6x à 45x sur ARM, selon les différents cas d'usage de portefeuilles, et de 9x à 80x sur ordinateur de bureau au prix d'une
  légère augmentation de la bande passante, de 0 % à 3 %. Pour une description complète de la méthodologie et des résultats complets, le
  lecteur peut se référer au [site web de Purszki][bin fuse web].

  Le développeur de Kyoto Robert Netzke a commenté les différences de taux de faux positifs par rapport aux GCS et les défaillances
  possibles pouvant se produire dans l'algorithme.

## Modification du consensus

_Une nouvelle section mensuelle résumant les propositions et discussions sur la modification des règles de consensus de Bitcoin._

- **Portefeuilles HD post-quantiques avec clés SPHINCS de secours :** Dans un [message][c ml pq bip32] sur la liste de diffusion
  Bitcoin-Dev, Conduition a décrit une conception de portefeuilles [hiérarchiques déterministes congruents][topic bip32] à [BIP32][]
  [post-quantiques][topic quantum resistance] avec des clés de secours [SPHINCS][news383 sphincs]. Cette conception remplace les fonctions de
  dérivation de clés enfants de BIP32 afin de générer des clés SPHINCS en parallèle des clés [secp256k1][secp256k1]. En raison de l'absence
  de relation algébrique au sein des clés SPHINCS, les clés enfants non renforcées partagent les mêmes clés SPHINCS que leurs parents et
  leurs frères et sœurs. Cela impose aux portefeuilles d'insérer un nonce (ou la clé secp256k1) dans les scripts dépensés à l'aide de la clé
  SPHINCS afin de conserver une confidentialité équivalente à celle des portefeuilles BIP32. Un avantage de ce choix de conception est que
  la dérivation complète coûteuse des clés SPHINCS peut être reportée à la première étape de dérivation non renforcée puis mise en cache
  pour toutes les clés non renforcées sous cette étape. Cette conception de portefeuille est destinée à être combinée avec des sorties P2MR
  [BIP360][] et un futur `OP_CHECKSPHINCS` (ou similaire) afin de permettre la migration vers des portefeuilles résistants au quantique.
  Conduition suggère qu'une telle structure de portefeuille pourrait également être combinée avec de futurs algorithmes de signature
  post-quantiques moins coûteux, SPHINCS fournissant une solution de secours fiable s'ils s'avéraient non sûrs.

- **Discussion d'un type de sortie post-quantique** : Antoine Poinsot a [écrit][ap ml pqout] sur la liste de diffusion Bitcoin-Dev pour
  défendre un type de sortie post-quantique simple (par opposition à un type de sortie de type [P2TR][topic taproot] qui permet de
  désactiver ultérieurement par soft fork les dépenses utilisant des clés vulnérables au quantique). Le cœur de l'argument est que la
  décision de savoir si, ou quand, il est pertinent de désactiver les dépenses vulnérables au quantique devrait être séparée de l'activation
  permettant aux utilisateurs de migrer vers la cryptographie post-quantique à leur discrétion. Dans la conversation qui a suivi, les
  participants se sont accordés à la fois sur l'ajout de la signature post-quantique à [tapscript][topic tapscript] et sur l'ajout d'un type
  de sortie post-quantique simple. Plusieurs questions ouvertes demeurent, notamment sur la question de savoir si et dans quelle mesure il
  faut inciter à la migration, et quand / s'il faut désactiver les signatures vulnérables au quantique.

- **Proposition d'intégrer des clés post-quantiques dans tapscript sans modification du consensus** : Daniel Buchner a [envoyé][db ml
  minpqc] une proposition à la liste de diffusion Bitcoin-Dev décrivant une voie potentielle pour permettre des conceptions de portefeuilles
  post-quantiques flexibles sans décrire complètement les paramètres de validation des signatures. Parce que les opcodes de vérification de
  signature de [BIP342][] traitent toutes les clés qui ne font pas 32 octets comme des types de clés inconnus qui sont valides avec toute
  signature non vide, d'autres longueurs de clés (dans ce cas avec un octet d'étiquette initial) peuvent être utilisées dans les scripts dès
  aujourd'hui tant que soit les scripts restent secrets, soit qu'ils exigent également une signature [BIP340][] sûre en plus de la ou des
  clés inconnues. Si la proposition de Buchner venait à être standardisée, les portefeuilles pourraient commencer à construire dès
  maintenant des scripts avec divers types de clés post-quantiques tout en continuant à dépenser à l'aide de clés vulnérables au quantique
  jusqu'au moment où un soft fork activerait des dépenses sûres avec les clés post-quantiques. Comme beaucoup de propositions de migration
  quantique, cette proposition ne conserve la sécurité face à un adversaire quantique que si la réutilisation des clés est strictement
  empêchée. Buchner sollicite des retours sur la proposition.

- **Démonstration par BIP54 de blocs lents sur signet** : Sur Delving Bitcoin, Antoine Poinsot a [écrit][ap delving slowblocks] au sujet
  d'une démonstration des types de blocs lents à valider que [BIP54][] ([consensus cleanup][topic consensus cleanup]) empêche. Répétés trois
  fois au cours d'une journée, des lots de blocs lents à valider ont été signés sur le [signet][topic signet] Bitcoin le plus populaire puis
  ont fait l'objet d'une réorganisation afin de permettre de tester les comportements de propagation et de validation de ces blocs sans
  ralentir définitivement le téléchargement initial des blocs du signet. De nombreuses personnes à travers le monde ont observé les blocs
  lents atteindre leurs nœuds et ont journalisé les comportements de validation et de propagation. Comme prévu, les blocs lents à valider se
  sont propagés beaucoup plus lentement à travers le réseau et ont nécessité un temps significativement plus long pour être entièrement
  validés sur les nœuds individuels par rapport aux blocs typiques. Il convient de noter que ces blocs de démonstration étaient loin du pire
  cas empêché par BIP54.

- **Récupération post-quantique BIP86 à l'aide de preuves zk-STARK de seeds BIP32** : Olaoluwa Osuntokun (roasbeef) a [publié][oo ml
  pqrecovery] sur la liste de diffusion Bitcoin-Dev son projet visant à démontrer la récupération par zk-STARK de coins vulnérables au
  quantique sécurisés par des clés dérivées à l'aide de [BIP32][]. Ce mécanisme possible de récupération de coins dans l'éventualité où
  [secp256k1][secp256k1] serait désactivé face à un ordinateur quantique cryptographiquement pertinent est discuté depuis longtemps, mais
  n'avait jamais été entièrement démontré. Osuntokun a produit une implémentation entièrement fonctionnelle du prouveur et du vérificateur
  requis et a fourni des benchmarks montrant que la récupération à l'aide de cette méthode est, au minimum, possible. L'implémentation
  d'origine n'était volontairement pas optimisée et plusieurs développeurs ont proposé des optimisations rendant la récupération moins
  coûteuse à la fois pour la preuve et pour la vérification.

## Mises à jour et versions candidates

_Nouvelles versions et versions candidates pour des projets d'infrastructure Bitcoin populaires. Veuillez envisager de mettre à niveau vers
les nouvelles versions ou d'aider à tester les versions candidates._

- [Core Lightning 26.04.1][] est une version de maintenance qui inclut des correctifs du protocole de [gossip][topic channel announcements],
  ainsi que des correctifs du système de build pour les environnements ayant rencontré des problèmes immédiatement après la version majeure.

- [BTCPay Server 2.3.8][] est une version mineure de cette solution de paiement auto-hébergée qui comprend des mises à jour des abonnements
  et du point de vente, la prise en charge de LUD21 [LNURL-pay][topic lnurl], une surface API supplémentaire pour gérer les offres
  d'abonnement, et d'autres correctifs et améliorations.

- [BTCPay Server 2.3.9][] est une version de maintenance qui corrige la récupération du serveur après un crash de plugin et résout un
  problème d'analyse d'xpub qui avait été introduit dans la v2.3.8.

## Changements notables dans le code et la documentation

_Changements récents notables dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning repo], [Eclair][eclair repo],
[LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet Interface (HWI)][hwi repo], [Rust Bitcoin][rust
bitcoin repo], [BTCPay Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement Proposals (BIPs)][bips repo], [Lightning
BOLTs][bolts repo], [Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition repo], et [BINANAs][binana repo]._

- [Bitcoin Core #33671][] ajoute un champ `nonmempool` à la RPC `getbalances` (voir le [Bulletin #46][news46 getbalances]) pour les UTXOs du
  portefeuille dépensés par des transactions qui ne sont ni confirmées ni dans le mempool du nœud, comme des transactions non diffusées, non
  standard, expulsées, ou des transactions faisant partie de chaînes de mempool trop longues. Auparavant, les compartiments de solde
  pouvaient omettre la valeur liée à ces dépenses en cours même si le portefeuille enregistrait toujours les transactions, de sorte que
  `getbalances` ne reflétait pas complètement la manière dont le portefeuille comptabilisait ces pièces. La PR compte cette valeur dans les
  compartiments `mine` habituels où elle doit se trouver et applique un décalage via `nonmempool` afin que les champs s'additionnent au
  solde global du portefeuille tout en rendant explicite le décalage avec le mempool.

- [Bitcoin Core #34885][] ajoute `btck_block_tree_entry_get_ancestor()` à l'API C `libbitcoinkernel` (voir le [Bulletin #380][news380 kernel])
  pour récupérer l'ancêtre d'un bloc à une hauteur spécifiée sur sa branche de chaîne. Au lieu de remonter un bloc à la fois avec des appels
  répétés à `btck_block_tree_entry_get_previous()`, les appelants qui construisent des localisateurs de blocs depuis une pointe obsolète ou
  issue d'un fork peuvent demander directement les ancêtres aux hauteurs nécessaires.

- [Bitcoin Core #33920][] ajoute une RPC `exportasmap` qui exporte les données ASMap du nœud intégrées à la compilation (voir le [Bulletin
  #394][news394 asmap]) vers un fichier. Cela permet aux utilisateurs d'inspecter, valider et analyser les données à l'aide d'outils tels
  que `contrib/asmap-tool.py`.

- [Bitcoin Core #34911][] supprime plusieurs champs booléens obsolètes liés au [RBF][topic rbf] de plusieurs réponses RPC du mempool à moins
  qu'ils ne soient explicitement demandés à l'aide de l'option de configuration `deprecatedrpc`. La RPC `getmempoolinfo` ne renvoie plus le
  champ `fullrbf` par défaut, car le comportement full-RBF est la valeur par défaut depuis Bitcoin Core 28.0 et l'option `mempoolfullrbf` a
  été supprimée dans Bitcoin Core 29.0. Les RPC `getrawmempool`, `getmempoolentry`, `getmempoolancestors` et `getmempooldescendants` ne
  renvoient plus par défaut le champ obsolète `bip125-replaceable` décrit dans [BIP125][].

- [BIPs #1548][] ajoute [BIP391][], une spécification pour les Binary Output Descriptors (BOD), un format conteneur efficace pour les
  [descripteurs de scripts de sortie][topic descriptors] basé sur des maps clé-valeur de style [PSBT][topic psbt]. Ce BIP a un statut fermé
  et liste [BIP393][] comme remplacement proposé, en notant que [BIP391][] a été retiré après que [BIP393][] a proposé une méthode
  alternative pour gérer les métadonnées de portefeuille telles que les annotations de descripteur (voir le [Bulletin #400][news400 bip393]).

- [HWI #831][] ajoute la prise en charge du dispositif matériel de signature Ledger Nano Gen5.

- [BDK #2188][] commence à vérifier qu'une transaction renvoyée par un serveur Electrum correspond bien au txid demandé avant de la mettre
  en cache ou de l'utiliser. Auparavant, un serveur pouvait répondre à une requête `fetch_tx()` avec n'importe quelles données de
  transaction et un txid différent, et BDK l'acceptait.

- [BDK #2115][] ajoute la prise en compte du hash du bloc précédent à `CheckPoint` en étendant le trait `ToBlockHash` avec une méthode
  optionnelle `prev_blockhash()`. Cela permet à BDK de vérifier que des checkpoints adjacents se connectent lorsque leurs charges utiles
  contiennent des informations sur le hash du bloc précédent, comme dans les en-têtes de blocs. Cela empêche également `merge_chains()` de
  traiter un checkpoint conflictuel à la hauteur 0 comme une réorganisation normale et de le remplacer. Désormais, si deux chaînes de
  checkpoints sont en désaccord sur le bloc genesis, la fusion échoue. Voir les bulletins [#372][news372 checkpoint] et [#390][news390
  checkpoint] pour les travaux précédents sur `CheckPoint`.

{% include snippets/recap-ad.md when="2026-05-05 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="33671,34885,33920,34911,831,2188,2115,1548" %}
[c ml pq bip32]: https://groups.google.com/g/bitcoindev/c/5tLKm8RsrZ0
[news383 sphincs]: /fr/newsletters/2025/12/05/#optimisations-de-signature-post-quantique-slh-dsa-sphincs
[secp256k1]: https://en.bitcoin.it/wiki/Secp256k1
[ap ml pqout]: https://groups.google.com/g/bitcoindev/c/JA3kDl8AmQg
[db ml minpqc]: https://groups.google.com/g/bitcoindev/c/jn7COyeHtW0
[ap delving slowblocks]: https://delvingbitcoin.org/t/consensus-cleanup-demo-of-slow-blocks-on-signet/2367
[oo ml pqrecovery]: https://groups.google.com/g/bitcoindev/c/Q06piCEJhkI
[bin fuse del]: https://delvingbitcoin.org/t/binary-fuse-filters-as-an-alternative-to-bip-158-gcs/2428
[bin fuse web]: https://purszki.github.io/bitcoin_research_01/
[BTCPay Server 2.3.8]: https://github.com/btcpayserver/btcpayserver/releases/tag/v2.3.8
[BTCPay Server 2.3.9]: https://github.com/btcpayserver/btcpayserver/releases/tag/v2.3.9
[Core Lightning 26.04.1]: https://github.com/ElementsProject/lightning/releases/tag/v26.04.1
[LUD-21]: https://github.com/lnurl/luds/blob/luds/21.md
[news372 checkpoint]: /fr/newsletters/2025/09/19/#bdk-1582
[news380 kernel]: /fr/newsletters/2025/11/14/#bitcoin-core-30595
[news390 checkpoint]: /fr/newsletters/2026/01/30/#bdk-2037
[news394 asmap]: /fr/newsletters/2026/02/27/#bitcoin-core-28792
[news400 bip393]: /fr/newsletters/2026/04/10/#bips-2099
[news46 getbalances]: /en/newsletters/2019/05/14/#bitcoin-core-15930
