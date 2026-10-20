---
title: 'Bulletin Hebdomadaire Bitcoin Optech #412'
permalink: /fr/newsletters/2026/07/03/
name: 2026-07-03-newsletter-fr
slug: 2026-07-03-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine comprend nos rubriques régulières résumant les discussions sur la modification des règles de consensus de
Bitcoin, annonçant de nouvelles versions et versions candidates, et décrivant des changements notables dans les logiciels d'infrastructure
Bitcoin populaires.

## Nouvelles

*Aucune nouvelle significative cette semaine n'a été trouvée dans nos [sources][].*

## Modification du consensus

_Une nouvelle section mensuelle résumant les propositions et discussions sur la modification des règles de consensus de Bitcoin._

- **Évaluation de performance de l'agrégation STARK pour SLH-DSA** : Remix7531 a [publié][rs ml starkbench] sur la liste de diffusion
  Bitcoin-Dev ses résultats de benchmark pour agréger de nombreuses vérifications de signatures [SPHINCS][news383 sphincs] en une seule
  preuve STARK. Cela fait suite à la [proposition][eh ml starkagg] antérieure d'Ethan Heilman d'utiliser les STARKs pour faire évoluer les
  blocs [post-quantiques][topic quantum resistance]. Dans cette suite de benchmarks (construite dans le zkVM de RISC Zero), le temps de
  génération de preuve évolue de manière approximativement linéaire avec le nombre de signatures (~3,1 secondes par signature sur une RTX
  5090), la taille de preuve croît de façon sous-linéaire (218 Kio pour une signature jusqu'à 454 Kio pour 512 signatures, contre 3,8 Mio de
  signatures brutes), et la vérification reste proche de 12-15 millisecondes quelle que soit la taille du lot. Générer une preuve pour un
  bloc entier sur un seul GPU prendrait toujours des heures, mais Remix suggère que des circuits AIR dédiés (contraintes polynomiales
  adaptées à la vérification de signatures plutôt que le zkVM généraliste utilisé ici), le prétraitement du mempool, et la génération de
  preuve sur plusieurs GPU pourraient améliorer cela. Les benchmarks utilisent également SPHINCS standard plutôt que la variante
  [SPHINCS+][news386 jn hash] plus compacte et optimisée pour Bitcoin.

- **Bird of Prey 2 (BoP-2) : signatures schnorr et PQ non malléables** : Pieter Wuille a [publié][pw delving bop2] sur Delving Bitcoin à
  propos d'un article d'EuroCrypt 2026 sur la construction de schémas de signature hybrides fortement infalsifiables à partir d'un schéma de
  type [schnorr][topic schnorr signatures] et d'un schéma de signature [post-quantique][topic quantum resistance] arbitraire. Bien que la
  simple concaténation des signatures des deux schémas soit infalsifiable si au moins l'un des deux reste sûr, elle n'est pas fortement
  infalsifiable. Si l'un des schémas est compromis, un attaquant peut remplacer la signature partielle de ce schéma tandis que la signature
  dans son ensemble reste valide. La construction BoP-2 de l'article évite cela en faisant en sorte que la signature schnorr engage la
  signature post-quantique dans son hachage de défi.

  Adam Gibson et Conduition ont discuté de la question de savoir si la forte infalsifiabilité importe encore après [segwit][topic segwit],
  puisque les témoins n'affectent plus les txids. Wuille a expliqué que la préoccupation concerne une compromission quantique ou classique
  permettant à n'importe qui de malléabiliser la composante de signature du schéma compromis. Conduition a comparé cette construction au
  design hybride économisant de l'espace basé sur le hachage de Boris Nagaev (voir l'élément sur les signatures sur réseau euclidien
  ci-dessous) et a conclu que BoP-2 semble être le candidat hybride unifié le plus robuste, bien que Wuille et Conduition aient tous deux
  mis en doute l'intérêt des schémas hybrides unifiés au vu de leur complexité, lorsque des feuilles [BIP360][] ([P2MR][news393 p2mr])
  séparées, ou de simples combinaisons de script, peuvent obtenir des résultats similaires.

- **Signatures basées sur des réseaux euclidiens** : Nikita Karetnikov a [publié][nk delving lattice] sur Delving Bitcoin et
  [cross-posté][nk ml lattice] sur la liste de diffusion Bitcoin-Dev au sujet d'un [article de blog][bs blog lattice] de Blockstream
  comparant les familles de signatures post-quantiques, où les schémas basés sur des réseaux euclidiens apparaissent favorables en taille et
  en fonctionnalité. Il a demandé pourquoi les travaux post-quantiques pour Bitcoin se sont plutôt concentrés sur les signatures basées sur
  le hachage.

  Conduition a [répondu][c ml lattice] que les signatures basées sur le hachage restent attrayantes pour Bitcoin en raison d'hypothèses de
  sécurité plus faibles, de la simplicité d'implémentation, de la rapidité de vérification, et de leur adéquation comme solution de secours
  à long terme. Mikhail Kudinov a noté que, bien que naïvement les signatures basées sur des réseaux euclidiens nécessitent souvent des
  calculs en virgule flottante, les opérations en virgule flottante de Falcon peuvent être simulées avec des entiers. Conduition et Jesse
  Posner ont discuté de la nécessité éventuelle de schémas hybrides unifiés schnorr+réseau euclidien par rapport à l'obtention d'une
  sécurité similaire avec des feuilles [BIP360][] (P2MR) séparées. D'un autre côté, Boris Nagaev a décrit les économies d'espace obtenues en
  traitant la signature hybride comme une construction unique plutôt que comme une simple concaténation de plusieurs schémas de signature,
  puisqu'ils pourraient vraisemblablement partager certains paramètres de randomisation requis, par exemple.

- **Récupération de clé publique pour les feuilles EC de P2MR** : starius a [publié][st delving recover] sur Delving Bitcoin une proposition
  visant à ajouter un type de feuille de clé à courbe elliptique (EC) récupérable à [BIP360][] (P2MR). L'idée consiste à récupérer la clé
  publique EC à partir de la signature [schnorr][topic schnorr signatures]. La clé publique est engagée dans l'arbre de Merkle P2MR au lieu
  d'un script, et le défi de la signature schnorr est modifié pour inclure la racine de Merkle et le bloc de contrôle au lieu de la clé
  publique elle-même. Comme la racine de Merkle et le bloc de contrôle sont tous deux connus au moment de la signature comme de la
  vérification, la signature peut être vérifiée sans connaissance de la clé publique, puis l'inclusion de la clé publique dans la racine de
  Merkle peut être vérifiée via le bloc de contrôle. En utilisant cette technique, le témoin d'une feuille schnorr de profondeur 1 passe de
  135 octets à 100 octets, soit entre la taille d'une dépense par clé [P2TR][topic taproot] et celle d'une dépense [P2WPKH][topic segwit],
  au prix de l'abandon de la vérification par lots de BIP340. starius et Conduition ont expliqué que l'inclusion du bloc de contrôle dans le
  défi empêche une attaque par clés liées lorsque plusieurs de ces feuilles partagent un arbre. Pieter Wuille a examiné la construction
  favorablement. Anthony Towns, Pieter Wuille, et Conduition ont discuté des implications pour la dérivation [BIP32][topic bip32], des
  réductions de coût de vérification par lots, et de l'interaction avec l'interdiction des arbres de profondeur zéro de Conduition (des
  feuilles récupérables de profondeur zéro pourraient correspondre aux tailles de témoin [P2TR][topic taproot] sans solution de secours
  post-quantique). starius a expliqué que cela devrait être intégré à BIP360 avant activation car cela modifie les règles d'analyse des
  témoins.

- **Aligner les incitations à la confidentialité dans P2MR** : Conduition a [publié][c ml p2mrdepth] sur la liste de diffusion Bitcoin-Dev
  une propostion de modification à [BIP360][] (P2MR) afin d'exiger que chaque bloc de contrôle P2MR inclue au moins un chemin d'authentification
  de Merkle de 32 octets (c.-à-d. interdire les arbres de script de profondeur zéro). Les arbres de profondeur zéro rendent certains
  protocoles ne nécessitant qu'un seul chemin de script plus efficaces dans P2MR que dans [P2TR][topic taproot], créant une incitation
  perverse à ignorer les chemins de signature coopérative et rendant certains protocoles contractuels plus faciles à reconnaître sur la
  chaîne.

  Antoine Poinsot a convenu que cela répondrait à cette préoccupation de confidentialité mais préfère toujours [P2TRv2][news403 pqout] pour
  une migration de masse parce que les dépenses P2MR typiques à clé unique coûtent environ 15 % de plus que P2TRv2 (peut-être moins avec la
  récupération de clé discutée ci-dessus). Pieter Wuille a soutenu que les incitations à l'adoption pré-quantique importent davantage que
  l'efficacité post-quantique à long terme et que P2TRv2 minimise mieux les coûts de migration. Il a aussi noté que P2MR n'a de sens que si
  les utilisateurs peuvent compter sur un futur soft fork désactivant les chemins à courbe elliptique au sein de P2MR. Conduition a prédit
  des taux de migration volontaire tout aussi faibles pour les deux designs et a mentionné une optimisation à venir de la taille des témoins
  pour les dépenses courantes à courbe elliptique (voir l'élément suivant). Hayashi a [suggéré][h ml p2mrdepth] une remise supplémentaire
  sur le témoin pour les feuilles schnorr de P2MR afin de réduire davantage l'écart de coût.

- **Interdire les préimages de nœuds internes de Merkle qui encodent des transactions minimales de 64 octets** : Jeremy Rubin a [publié][jr
  ml merkle64] sur la liste de diffusion Bitcoin-Dev un brouillon de BIP proposant une alternative à la règle de [consensus cleanup][topic
  consensus cleanup] ([BIP54][]) rendant invalides au consensus les transactions de 64 octets sans witness. Au lieu d'interdire les
  transactions elles-mêmes, la règle de Rubin invaliderait tout bloc dont l'arbre de Merkle des transactions contient une préimage de nœud
  interne ayant la disposition en octets d'une transaction minimale sans witness à une entrée et une sortie. Cela vise la même
  [vulnérabilité de l'arbre de Merkle][topic merkle tree vulnerabilities] à la frontière des nœuds internes tout en préservant des
  transactions de 64 octets potentiellement utiles (voir [Bulletin #408][news408 64byte]). Les vérificateurs SPV devraient rejeter les
  preuves dont les préimages de branche correspondent au motif interdit. Le brouillon inclut des indications de récupération pour les
  mineurs (réordonner ou supprimer les transactions en cause) et note que les violations accidentelles devraient être rares.

  Plusieurs réponses ont préféré l'interdiction pure et simple, plus simple, des transactions de 64 octets de BIP54. Antoine Poinsot a
  soutenu que tout système sécurisant de la valeur valide déjà correctement ces transactions, de sorte que la distinction faite par Rubin
  importe peu en pratique. Matt Corallo a noté que cela exigerait des mineurs qu'ils modifient leur logiciel de construction de blocs ou
  risquent de produire des blocs invalides. Murch a souligné qu'ajouter occasionnellement un octet de bourrage est une charge plus faible
  que d'obliger chaque nœud à vérifier des milliers de hachages pendant la validation des blocs. Sjors Provoost a suggéré de reporter une
  correction plus propre à un futur changement du format des en-têtes de bloc.

- **Déclencher la désactivation d'EC par une dépense vers un point NUMS ou par une majorité de hashrate** : Pieter Wuille a [écrit][pw ml
  p2xx] sur la liste de diffusion Bitcoin-Dev au sujet de la codification de la désactivation future attendue des chemins de dépense à
  courbe elliptique (EC) dans de nouveaux types de sorties [post-quantiques][topic quantum resistance] tels que [BIP360][] (P2MR) et
  [P2TRv2][news403 pqout]. Sans déclencheurs imposés par le consensus, les utilisateurs n'auront pas confiance dans le fait que la dépense
  EC sera réellement désactivée, ce qui affaiblit l'argument de résistance quantique pour des types de sorties qui autorisent initialement
  des dépenses EC peu coûteuses.

  Wuille a proposé deux mécanismes regroupés avec le soft fork d'introduction : tripwire (P2XX-T), qui désactive les chemins EC dans le
  nouveau type de sortie après toute dépense réussie `<NUMS> OP_CHECKSIG` prouvant que secp256k1 est compromis, plaçant une borne supérieure
  non confiscatoire sur la disponibilité d'EC ; et miner lockdown (P2XX-ML), qui permet à une majorité du hashrate d'activer la même
  désactivation via un soft fork signalé séparément avec une fenêtre d'activation très longue. Boris Nagaev a soutenu tripwire mais a
  soulevé des préoccupations de faux positifs pour miner lockdown après d'importants vols classiques. Sjors Provoost a suggéré de longs
  délais et une migration des utilisateurs vers [P2TR][topic taproot] comme remède. Conduition a soutenu tripwire, a noté que la preuve n'a
  pas besoin d'être minée on-chain, et a averti qu'un miner lockdown précoce pourrait être incité par les frais. Wuille a précisé que la
  désactivation doit couvrir tout usage d'EC au sein du type de sortie (pas seulement les chemins de clé) et que la signature hybride
  devrait utiliser des opcodes dédiés plutôt que des combinaisons de script arbitraires pour garantir la dépensabilité après la
  désactivation d'EC.

## Mises à jour et versions candidates

_Nouvelles versions et versions candidates pour des projets d'infrastructure Bitcoin populaires. Veuillez envisager de mettre à niveau vers
les nouvelles versions ou d'aider à tester les versions candidates._

- [Bitcoin Core 31.1rc1][] est une version candidate pour une version de maintenance de l'implémentation de nœud complet prédominante. Elle
  corrige une fuite d'adresse IP dans `-privatebroadcast` qui pourrait compromettre la [confidentialité de l'origine des transactions][topic
  transaction origin privacy] (voir [Bulletin #409][news409 privatebroadcast]), et inclut des correctifs pour la compaction du chainstate,
  la migration de portefeuille, l'estimation de taille des entrées, l'agrégation de clés [MuSig2][topic musig], et la gestion des proxys
  lors des reconnexions du [transport P2P v2][topic v2 p2p transport].

- [Bitcoin Core 30.3rc1][] est une version candidate pour une version de maintenance de l'implémentation de nœud complet prédominante. Elle
  corrige un problème de base de données du chainstate qui pouvait provoquer des lectures et écritures disque excessives pendant le
  fonctionnement normal, ainsi que des correctifs pour le portefeuille, [PSBT][topic psbt], [miniscript][topic miniscript], le réseau, la
  compilation, les tests et la documentation.

- [Bitcoin Core 29.4rc1][] est une version candidate pour une version de maintenance de l'implémentation de nœud complet prédominante. Elle
  corrige le même problème de réécriture de base de données du chainstate que 30.3rc1 et inclut une sélection de correctifs pour la
  validation, le portefeuille, la compilation, les tests, la documentation, l'intégration continue et la compatibilité.

- [Core Lightning v26.06.2][] est une version de maintenance qui corrige `cln-currencyrate` sur les environnements OS minimaux et les
  installations Docker sans certificats racines TLS installés.

- [LND v0.20.2-beta.rc1][] est une version candidate pour une version de maintenance de cette implémentation populaire de nœud LN. Elle
  corrige une panique du mécanisme de repli DNS et un bogue de règlement onchain du forward-interceptor, et ajoute la validation de
  l'expiration CLTV du dernier saut [HTLC][topic htlc] décrite dans la section des changements notables du code ci-dessous.

- [LND v0.21.1-beta][] est une version de maintenance de cette implémentation populaire de nœud LN. Elle corrige la création de service
  onion v3 [Tor][topic anonymity networks] pour les nouveaux nœuds activés avec Tor, une panique du mécanisme de repli DNS, et un bogue de
  règlement onchain du forward-interceptor, et renforce la validation de l'expiration CLTV des HTLC du dernier saut.

- [LDK v0.2.4][] est une version de maintenance de cette bibliothèque pour la création de portefeuilles et d'applications compatibles LN.
  Elle corrige une régression dans v0.2.3 qui augmentait la version minimale prise en charge de Rust pour le crate `lightning` ; le crate
  compile désormais à nouveau avec `rustc` 1.63.

## Changements notables dans le code et la documentation

_Changements notables récents dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning repo], [Eclair][eclair repo],
[LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet Interface (HWI)][hwi repo], [Rust Bitcoin][rust
bitcoin repo], [BTCPay Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement Proposals (BIPs)][bips repo], [Lightning
BOLTs][bolts repo], [Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition repo], et [BINANAs][binana repo]._

- [Bitcoin Core #35266][] ajoute un argument `load_wallet` (vrai par défaut) à la RPC `migratewallet`, permettant de migrer un portefeuille
  hérité vers des portefeuilles [descriptor][topic descriptors] sans charger immédiatement le portefeuille migré. Cela aide les utilisateurs
  à migrer un portefeuille hérité sur un nœud élagué dont l'état de chaîne est élagué en dessous de la date de naissance du portefeuille, où
  le chargement du portefeuille migré nécessiterait des données de blocs indisponibles même si la migration elle-même n'en a pas besoin.

- [Bitcoin Core #35550][] met à jour la négociation du [relay de blocs compacts][topic compact block relay] pour rejeter les messages
  `sendcmpct` dont le champ booléen d'annonce n'est pas exactement `0` ou `1`, comme l'exige [BIP152][]. Auparavant, Bitcoin Core décodait
  directement le champ comme un `bool` C++, ce qui faisait qu'une valeur non nulle était acceptée comme vraie. La PR lit désormais le champ
  comme un entier et traite les valeurs supérieures à 1 comme un mauvais comportement du pair, en déconnectant ce pair.

- [Bitcoin Core #35610][] ajoute une commande `netmagic` à `bitcoin-util` qui affiche l'identifiant réseau de quatre octets utilisé dans les
  messages P2P de Bitcoin pour la chaîne sélectionnée, y compris les [signets][topic signet] personnalisés. Cette commande est utile pour la
  prise en charge proposée d'un datadir multi-signet, dans lequel les signets personnalisés seraient stockés dans des datadirs suffixés par
  leurs identifiants réseau. Cela permet aux scripts de sélectionner le bon répertoire avant de démarrer `bitcoind`.

- [BIPs #2196][] ajoute [BIP95][], une spécification brouillon pour [testnet5][topic testnet], un nouveau réseau de test destiné à remplacer
  testnet4 (voir [Bulletin #409][news409 testnet5]). Testnet4 a une exception de difficulté qui permet des blocs à difficulté minimale après
  de longues interruptions. Cependant, cette exception a été exploitée de façon persistante, entraînant de fréquentes petites
  réorganisations et rendant le réseau difficile à utiliser pour les tests. Testnet5 supprime l'exception, relève la difficulté minimale à
  environ 1 048 561, et applique les règles de [consensus cleanup][topic consensus cleanup] de [BIP54][] à partir du bloc
  1. Le brouillon spécifie aussi les octets de début de message `0x46495645` (`FIVE`) et le port P2P par défaut `18335`, bien que les
  valeurs de son bloc genesis restent pour l'instant des espaces réservés.

- [BIPs #2165][] met à jour [BIP52][], la proposition d'Optical Proof-of-Work décrite dans [Bulletin #181][news181 bip52], en changeant son
  statut de Draft à Closed. BIP52 proposait un hard fork qui prétendait déplacer les coûts du minage de l'électricité et des opérations vers
  un équipement de minage optique spécialisé. Après plusieurs années sans progrès et de récentes tentatives infructueuses pour contacter les
  auteurs, la proposition a été close.

- [BIPs #2201][] fait passer [BIP110][], la proposition Reduced Data Temporary Softfork, au statut Complete (voir [Bulletin #392][news392
  bip110]). Cette mise à jour souligne que les UTXOs créés avant l'activation sont maintenus et peuvent être dépensés selon les anciennes
  règles pendant le déploiement. Elle ajoute également une couverture de tests de l'implémentation de référence et des vecteurs de test au
  niveau transaction. De plus, elle clarifie l'impact de l'interdiction temporaire d'exécuter `OP_IF` et `OP_NOTIF` dans les feuilles
  [tapscript][topic tapscript] : les UTXOs existants sont exemptés, mais les nouvelles constructions utilisant ces opcodes nécessiteraient
  des alternatives, telles que des feuilles séparées.

- [LND #10900][] ajoute une RPC `WalletKit.SubmitPackage` et une commande `lncli wallet submitpackage` pour soumettre un [paquet de
  transactions][topic package relay] 1p1c au backend de chaîne de LND. Pour les backends bitcoind, LND transmet le paquet à la RPC
  `submitpackage` de Bitcoin Core, permettant qu'une transaction parente [v3 relay][topic v3 transaction relay] sans frais avec une [ancre
  éphémère][topic ephemeral anchors] soit acceptée avec un enfant [CPFP][topic cpfp] payant des frais. Les autres backends ne fournissent
  pas la même soumission de paquet : btcd renvoie non implémenté, et neutrino diffuse les transactions individuellement.

- [LND #10927][] renforce la validation des expirations CLTV des [HTLC][topic htlc] du dernier saut. Auparavant, un HTLC du dernier saut
  pouvait spécifier une expiration bien plus éloignée dans le futur que ne l'autorisait la politique du receveur, immobilisant de la
  liquidité pendant une durée excessive même si les deltas CLTV de transfert étaient déjà bornés. LND rejette désormais les HTLC finaux en
  dehors de la politique CLTV du receveur avec `incorrect_or_unknown_payment_details`, valide les bornes de configuration associées, et
  applique les mêmes vérifications si le canal est fermé de force avant de décider s'il faut réclamer le HTLC on-chain avec une préimage.

- [LDK #4748][] et [#4751][ldk #4751] corrigent deux cas limites de machine à états de [splicing][topic splicing] impliquant des messages
  retardés. [LDK #4748][] corrige un cas dans lequel des `tx_signatures` de splice retardées pouvaient arriver alors qu'une mise à jour de
  channel monitor non liée, contenant une préimage de [HTLC][topic htlc], était en attente, poussant LDK à bloquer à tort l'achèvement du
  flux de splice. LDK n'attend désormais que lorsque la mise à jour de monitor en attente est la mise à jour liée au splice qui doit d'abord
  être durablement persistée. [#4751][ldk #4751] corrige un cas dans lequel le `commitment_signed` de splice en vol d'un pair pouvait
  arriver après que l'utilisateur local a annulé sa contribution au financement, amenant LDK à valider une signature pour une transaction de
  financement de splice obsolète et potentiellement à fermer de force le canal toujours actif. LDK vérifie désormais le `funding_txid`
  optionnel dans `commitment_signed` et ignore les signatures pour des transactions de financement de splice obsolètes.

{% include snippets/recap-ad.md when="2026-07-07 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="2165,2196,2201,35266,35550,35610,10900,10927,4748,4751" %}

[rs ml starkbench]: https://groups.google.com/g/bitcoindev/c/0IdqdnlC4Og
[eh ml starkagg]: https://groups.google.com/g/bitcoindev/c/wKizvPUfO7w
[pw delving bop2]: https://delvingbitcoin.org/t/bird-of-prey-2-non-malleable-schnorr-pq-signatures/2514
[c ml p2mrdepth]: https://groups.google.com/g/bitcoindev/c/p8AVEmAtWdA
[h ml p2mrdepth]: https://groups.google.com/g/bitcoindev/c/p8AVEmAtWdA/m/D3hERI8wCwAJ
[st delving recover]: https://delvingbitcoin.org/t/public-key-recovery-for-ec-leaves-in-p2mr-bip-360/2603
[nk ml lattice]: https://groups.google.com/g/bitcoindev/c/nMO4hyEm5qc
[nk delving lattice]: https://delvingbitcoin.org/t/pqc-lattice-based-signatures/2522
[c ml lattice]: https://groups.google.com/g/bitcoindev/c/nMO4hyEm5qc/m/XFpCuylPCQAJ
[bs blog lattice]: https://blog.blockstream.com/schnorr-but-with-vectors-lattice-based-signatures-explained/
[jr ml merkle64]: https://groups.google.com/g/bitcoindev/c/ZVDEzxG6Sq8
[pw ml p2xx]: https://groups.google.com/g/bitcoindev/c/aWYtPLVPZ3U
[news383 sphincs]: /fr/newsletters/2025/12/05/#optimisations-de-signature-post-quantique-slh-dsa-sphincs
[news386 jn hash]: /fr/newsletters/2026/01/02/#signatures-basees-sur-le-hachage-pour-le-futur-post-quantique-de-bitcoin
[news393 p2mr]: /fr/newsletters/2026/02/20/#bips-1670
[news403 pqout]: /fr/newsletters/2026/05/01/#discussion-d-un-type-de-sortie-post-quantique
[news408 64byte]: /fr/newsletters/2026/06/05/#transactions-de-64-octets-de-bip54-et-usages-legitimes-potentiels
[Core Lightning v26.06.2]: https://github.com/ElementsProject/lightning/releases/tag/v26.06.2
[LND v0.20.2-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.20.2-beta.rc1
[LND v0.21.1-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.21.1-beta
[LDK v0.2.4]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.2.4
[Bitcoin Core 31.1rc1]: https://bitcoincore.org/bin/bitcoin-core-31.1/test.rc1/
[Bitcoin Core 30.3rc1]: https://bitcoincore.org/bin/bitcoin-core-30.3/test.rc1/
[Bitcoin Core 29.4rc1]: https://bitcoincore.org/bin/bitcoin-core-29.4/test.rc1/
[news181 bip52]: /en/newsletters/2022/01/05/#bips-1126
[news392 bip110]: /fr/newsletters/2026/02/13/#bips-2017
[news409 testnet5]: /fr/newsletters/2026/06/12/#projet-de-bip-pour-testnet5
[news409 privatebroadcast]: /fr/newsletters/2026/06/12/#bitcoin-core-35410
[sources]: /en/internal/sources/
