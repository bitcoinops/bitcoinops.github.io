---
title: 'Bulletin Hebdomadaire Bitcoin Optech #431'
permalink: /fr/newsletters/2026/11/13/
name: 2026-11-13-newsletter-fr
slug: 2026-11-13-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine présente des projets de BIP sur la signature résistante à l'exfiltration, résume la divulgation de trois
vulnérabilités touchant d'anciennes versions de Bitcoin Core, annonce un plan pour miner le bloc de genèse de testnet5 et décrit une enquête
sur la dégradation de la reconstruction des blocs compacts. Nos sections habituelles présentent les nouvelles versions et versions
candidates ainsi que les changements notables apportés aux principaux logiciels d'infrastructure Bitcoin.

## Nouvelles

- **Projets de BIP pour la signature anti-exfiltration :** Connor Avila a [présenté][anti ex ml] sur la liste de diffusion Bitcoin-Dev une
  proposition visant à normaliser la [signature résistante à l'exfiltration][topic exfiltration-resistant signing] pour les
  appareils de signature matériels. Comme l'appareil choisit le nonce, il pourrait divulguer sa graine s'il était compromis. La proposition permet à l'hôte
  de contribuer à la génération du nonce, une technique déjà utilisée par plusieurs fabricants mais jamais normalisée (voir le [Bulletin #136][news136 anti ex]). Ce n'est pas la première fois que ce sujet est
  abordé : Stepan Snigirev a fait une première proposition en 2020 pour normaliser la signature résistante à l'exfiltration (voir le
  [Bulletin #87][news87 anti ex]), Pieter Wuille a fourni une vue d'ensemble des différentes techniques disponibles (voir le
  [Bulletin #88][news88 anti ex]), Moonsettler a proposé un protocole anti-exfiltration en 2024 (voir le [Bulletin #317][news317 anti ex]), et le
  [BIP461][] récemment intégré permet de détecter d'éventuelles tentatives de fuite de données cryptographiques par un
  appareil de signature (voir le [Bulletin #424][news424 bip461]).

  La proposition d'Avila s'accompagne de deux projets de BIP. [Le premier][anti ex bip] couvre la signature anti-exfiltration pour les
  signatures [schnorr][topic schnorr signatures] et ECDSA, en définissant un protocole en deux tours dans lequel un hôte fournit ses propres
  données aléatoires pour la génération du nonce et vérifie que le dispositif de signature l'a effectivement utilisée. [Le second projet][anti ex psbt]
  ajoute trois champs dédiés par entrée aux [PSBT][topic psbt] pour exécuter ce protocole. La proposition comprend
  également des vecteurs de test, une implémentation de référence en Python et un module C pour libsecp256k1.

  Avila a noté que Sjors Provoost avait déjà publié un [brouillon expérimental][anti ex sjors] sur la signature Taproot par chemin de clé avec un
  seul signataire. Selon l'auteur, Provoost prévoit d'aligner ses implémentations sur la spécification d'Avila. Enfin, Avila a sollicité l'avis
  d'autres développeurs, car les mécanismes cryptographiques de sa proposition n'avaient pas encore été audités.

- **Divulgation de trois vulnérabilités dans Bitcoin Core :** Antoine Poinsot a [publié][poinsot adv ml] sur la liste de diffusion
  Bitcoin-Dev trois avis de sécurité Bitcoin Core, un de gravité élevée et deux de gravité moyenne, concernant des vulnérabilités qui ont
  été corrigées dans Bitcoin Core 29.2 et 30.0. Selon la [politique de divulgation][disc pol] (voir le [Bulletin #306][news306 disclosures]),
  les vulnérabilités de gravité moyenne et élevée sont divulguées deux semaines après que la dernière version affectée a
  atteint sa fin de vie, ce qui s'est produit le 27 octobre pour la série 29.x. Les trois vulnérabilités divulguées sont les suivantes :

  - [La création de modèles de blocs interrompue par l'éviction d'une transaction sœur TRUC pendant une réorganisation][CVE-2025-62861] : Ce bogue de
    gravité élevée n'affectait que les nœuds utilisés pour le minage, les empêchant de créer des modèles de blocs après certaines
    réorganisations jusqu'à leur redémarrage. La règle d'éviction des transactions sœurs [TRUC][topic v3 transaction relay] s'appliquait encore lorsque les
    transactions de blocs retirés de la chaîne réintégraient la mempool, ce qui pouvait évincer une transaction sans évincer ses descendantes. Le bogue affectait les versions 28.0 à 29.1. Il a été [divulgué de manière responsable][topic responsible disclosures]
    par Niklas Gögge en septembre 2025 et corrigé par Greg Sanders dans [Bitcoin Core #33504][] (voir le [Bulletin #375][news375 truc]).

  - [Les connexions Tor entrantes reçoivent à tort les permissions `-whitelist`][CVE-2025-62860] : Ce bogue de gravité moyenne levait les
    limites anti-DoS et les protections contre les fuites de confidentialité pour chaque pair connecté via une connexion entrante [Tor][topic anonymity networks] sur
    les nœuds dont la plage `-whitelist` incluait l'adresse de leur démon Tor, une configuration utilisée par des milliers de nœuds
    joignables. Le bogue a été divulgué de manière responsable par Martin Zumsande et Antoine Poinsot en septembre 2025 et corrigé par
    Zumsande dans [Bitcoin Core #33395][].

  - [Blocage du traitement des blocs par malléabilité du témoin][CVE-2025-62859] : Ce bogue de gravité moyenne permettait à un pair qui
    annonçait en premier un [bloc compact][topic compact block relay] de bloquer le traitement de ce bloc par un nœud jusqu'à 10
    minutes et de répéter ce blocage indéfiniment dans certaines conditions. Le bogue a été divulgué de manière responsable par Eugene
    Siegel en avril 2025 et corrigé par Greg Sanders dans [Bitcoin Core #32646][].

  Les correctifs pour les deux premières vulnérabilités ont également été inclus dans Bitcoin Core 28.3. Toutes les séries de versions
  affectées ont désormais atteint leur fin de vie, donc toute personne utilisant encore l'une d'elles devrait migrer vers une version
  maintenue.

- **Minage du bloc de genèse de testnet5 :** Anthony Towns a [publié][towns tn5] sur la liste de diffusion Bitcoin-Dev un plan pour
  miner le bloc de genèse de [testnet5][topic testnet], le remplacement proposé de testnet4 spécifié dans [BIP95][] (voir les Bulletins
  [#409][news409 testnet5] et [#412][news412 bip95]). Le minage doit commencer une fois que le mainnet atteindra son prochain ajustement de
  difficulté au bloc 975 744, attendu le 13 novembre. Le bloc de genèse contiendra un engagement envers le hachage d'un bloc du réseau principal à cette hauteur ou à une hauteur
  supérieure, ce qui empêchera de miner des blocs testnet5 à l'avance. Comme la difficulté minimale de testnet5 est environ un million de
  fois plus élevée que celle de testnet4 (pour empêcher qu'un grand nombre de blocs soient minés rapidement après le lancement, avant
  l'ajustement de la difficulté), le minage des premiers blocs nécessite des ASIC, et Towns a [décrit][towns tn5 gist] un pool public vers
  lequel n'importe qui peut diriger de la puissance de hachage afin que les développeurs n'aient aucune avance.

  Après le minage du bloc de genèse, ses valeurs remplaceront les valeurs provisoires dans BIP95. Towns a noté que le logiciel de nœud aura
  encore besoin des paramètres testnet5 et de la logique de [nettoyage du consensus][topic consensus cleanup] BIP54, ainsi que de nœuds d'amorçage DNS,
  de robinets à bitcoins de test et d'explorateurs, avant que le réseau ne soit prêt pour une utilisation générale.

- **Poursuite de la discussion sur les statistiques de reconstruction des blocs compacts :** 0xB10C a [publié][b10c cb summary] dans son fil
  Delving Bitcoin (voir le [Bulletin #382][news382 cb]) une explication de la baisse des performances du
  [relais des blocs compacts][topic compact block relay] de la mi-juillet à la mi-octobre. En septembre, il a [signalé][b10c cb sept] que
  ses nœuds ne pouvaient reconstruire que 1 % à 5 % des blocs sans demander de transactions et demandaient environ 100 ko par bloc. Gregory
  Sanders a [constaté][sanders cb investigation] que presque toutes les transactions manquantes sur son nœud appartenaient à des chaînes de transactions
  de création de runes, qui atteignaient les pools de minage plusieurs minutes avant les autres nœuds.

  Des investigations sur le forum Bitcoin Network Operations Collective ([une][bnoc fleet], [deux][bnoc degradation]) ont retracé ces
  chaînes jusqu'à une personne qui créait des jetons au coût le plus bas possible. Chaque transaction faisait environ 100 octets virtuels, avait une
  entrée [pay-to-anchor (P2A)][topic ephemeral anchors] et des sorties P2A et `OP_RETURN`, et payait environ 10 sats de frais. Des pairs
  envoyaient les chaînes directement aux nœuds sans les annoncer, et d'autres pairs envoyaient des transactions qui dépensaient chacune une
  sortie P2A provenant du milieu d'une chaîne, en versant la totalité de sa valeur en frais. Chacune de ces transactions [remplaçait][topic rbf] le
  reste de sa chaîne dans toute mempool qui l'acceptait, et le fait qu'un nœud conserve la chaîne ou le remplacement dépendait en partie de
  celui qui arrivait en premier. Le contenu des mempools différait donc des transactions incluses par les pools dans les blocs. Les nœuds devaient demander les
  transactions manquantes.

## Mises à jour et versions candidates

_Nouvelles versions et versions candidates pour des projets d'infrastructure Bitcoin populaires. Veuillez envisager de mettre à niveau vers
les nouvelles versions ou d'aider à tester les versions candidates._

- [LDK v0.3-rc4][] est la quatrième version candidate pour la prochaine version majeure de cette bibliothèque pour construire des
  portefeuilles et applications compatibles LN, après la candidate décrite dans le [Bulletin #426][news426 ldk rc]. Les développeurs devraient examiner les
  [changements d'API et ruptures de rétrocompatibilité][ldk 0.3 notes] avant de tester, y compris l'invalidation des factures [BOLT11][]
  précédemment émises contenant des métadonnées de paiement.

- [LDK v0.2.8][] et [v0.1.14][ldk v0.1.14] sont des versions de sécurité pour les branches 0.2 et 0.1 de cette bibliothèque, respectivement.
  Les deux corrigent des vulnérabilités pouvant entraîner une perte de fonds ou une attaque DoS, ainsi que les problèmes de fermeture
  coopérative décrits ci-dessous et un problème de gestion des indications de routage. La version 0.2.8 corrige également une vulnérabilité de
  surpaiement des frais affectant les paiements de factures [BOLT12][] statiques et des vulnérabilités DoS affectant les services LSPS2.

- [LND v0.21.8-beta][] et [v0.20.8-beta][lnd v0.20.8-beta] sont des versions de maintenance de cette implémentation de nœud LN. Les deux
  incluent les correctifs de récupération AMP, de financement de canal, de fermeture forcée d'un canal restauré et d'indice de confirmation
  décrits ci-dessous. Elles corrigent également la récupération des HTLC relayés après le rétablissement d'une connexion et incluent des
  correctifs pour le module de récupération des fonds et l'état des canaux.

## Changements notables dans le code et la documentation

_Changements récents notables dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning repo], [Eclair][eclair repo],
[LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo], [Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition repo], et [BINANAs][binana repo]._

- [Bitcoin Core #36142][] corrige une injection de commande via l'interface de contrôle [Tor][topic anonymity networks]. Un attaquant
  contrôlant ou usurpant ce point de terminaison pouvait renvoyer une clé privée de service onion malveillante. Bitcoin Core enregistrait
  alors et réutilisait cette clé, ce qui permettait d'injecter des commandes ou des arguments supplémentaires dans l'interface de contrôle de Tor.
  Bitcoin Core valide désormais les clés avant de les enregistrer ou de les réutiliser et vérifie les identifiants de service onion renvoyés. Si une
  clé déjà en cache ne passe pas la validation, le service onion sera indisponible. Supprimer la clé en cache et redémarrer générera
  une nouvelle adresse onion.

- [BIPs #2251][] ajoute [BIP394][], une spécification provisoire pour le descripteur de script de sortie `rawtr()` précédemment discuté dans
  le [Bulletin #419][news419 rawtr]. Contrairement à `tr()`, qui dérive une clé de sortie [taproot][topic taproot] à partir d'une clé
  interne et d'un arbre de scripts optionnel, `rawtr()` prend directement la clé de sortie sans appliquer d'ajustement cryptographique. Cela permet à un
  portefeuille de décrire une sortie sans connaître sa structure interne. Cependant, un [descripteur][topic descriptors] `rawtr()` ne prouve
  pas que d'autres chemins de dépense sont absents. Par conséquent, les logiciels qui en importent un depuis une source non fiable devraient
  avertir les utilisateurs de la possibilité de chemins de dépense par script cachés. Bitcoin Core prend en charge ce descripteur depuis la version 24.0 (voir
  le [Bulletin #213][news213 rawtr]).

- [BIPs #2347][] met à jour [BIP95][], la spécification provisoire pour [testnet5][topic testnet] (voir le [Bulletin #412][news412 bip95]),
  afin de rendre son bloc de genèse proposé plus facile à miner en utilisant une [infrastructure de pool][topic pooled mining] (voir la
  [nouvelle ci-dessus](#minage-du-bloc-de-genese-de-testnet5)). L'engagement envers le hachage d'un bloc récent du réseau principal est déplacé d'un champ de
  clé publique dans la sortie coinbase vers un texte lisible dans le script d'entrée coinbase. La sortie utilise `OP_RETURN` à la place, ce
  qui la marque explicitement comme impossible à dépenser et fournit huit octets supplémentaires d'espace de nonce. Le projet autorise
  également les mineurs à faire varier la version du bloc, élargissant l'espace de recherche disponible pour le minage. Le bloc de genèse
  d'exemple reste une valeur provisoire.

- [BIPs #2342][] clarifie l'encodage par [BIP34][] de la hauteur du bloc au début du script d'entrée coinbase pour les chaînes qui
  appliquent la règle immédiatement après le bloc de genèse, comme [signet][topic signet] et [testnet4][topic testnet]. Les hauteurs 1 à 16 doivent
  utiliser les opcodes sur un seul octet `OP_1` à `OP_16`, sans préfixe de longueur. La formulation antérieure pouvait être interprétée
  comme exigeant un nombre précédé d'un préfixe de longueur. Cette clarification s'aligne sur le comportement existant de Bitcoin Core. Elle
  note également que le script d'entrée coinbase doit toujours contenir au moins deux octets, de sorte que l'opcode de hauteur seul est
  insuffisant (voir le [Bulletin #406][news406 coinbase]).

- [Core Lightning #9610][] corrige un plantage déclenché par un pair causé par un montant excessif dans un [HTLC][topic htlc]. Ce plantage
  pouvait être déclenché par un pair de canal proposant un HTLC avec un montant erroné d'au moins environ 92 millions de BTC, ce qui mettait à 1 le
  bit de poids fort du champ de montant. La valeur pouvait alors être interprétée comme négative lors d'une vérification de solde signée,
  contournant le contrôle de la disponibilité des fonds. La construction ultérieure de la transaction d'engagement déclenchait une assertion et
  terminait `channeld`, le sous-processus du canal affecté. Désormais, CLN rejette les montants supérieurs au plafond [BOLT1][] de 21
  millions de BTC, exprimé en millisatoshis, avant d'effectuer l'arithmétique des soldes.

- [LDK #5507][] et [#5532][ldk #5532] corrigent des bogues de fermeture coopérative qui pouvaient combiner des signatures pour différentes
  transactions. Le premier garantit que LDK signe la transaction proposée par le pair, au lieu de réutiliser une signature en cache
  provenant d'une transaction de fermeture différente simplement parce que les frais proposés correspondent. La seconde PR efface l'état de
  signature en attente lorsqu'un pair se déconnecte alors que le signataire asynchrone était indisponible, empêchant qu'une ancienne
  signature du pair soit combinée avec une nouvelle proposition locale après reconnexion. Auparavant, dans les deux cas, LDK pouvait
  tenter de diffuser une transaction de fermeture invalide tout en traitant le canal comme fermé, laissant des fonds à récupérer.

- [LND #11492][] corrige la récupération sur la chaîne des paiements atomiques multichemins reçus ([AMP][topic amp]) après une fermeture forcée.
  Auparavant, LND pouvait ne pas trouver la préimage nécessaire pour réclamer un [HTLC][topic htlc] en attente, même s'il avait déjà
  enregistré le paiement comme réglé. LND vérifiait à tort la présence d'une préimage au niveau de la facture plutôt que la préimage stockée
  pour le HTLC AMP individuel. Il récupère désormais la préimage de ce HTLC. La PR empêche également que des vérifications d'expiration
  destinées aux nouveaux paiements rejettent des HTLC AMP spontanés et [keysend][topic spontaneous payments] précédemment enregistrés
  lors de leur retraitement pendant la récupération (voir le [Bulletin #412][news412 cltv] pour la présentation des
  contrôles d'expiration de LND).

- [LND #11479][] corrige la gestion des erreurs lors de la publication d'une [transaction qui ouvre plusieurs canaux][topic payment batching] (voir le [Bulletin #166][news166 batch]).
  Auparavant, une erreur pendant la diffusion amenait LND à abandonner les canaux en attente et à libérer les entrées réservées dans le portefeuille, même si la transaction avait atteint le réseau et pouvait encore être
  confirmée. Désormais, LND conserve l'état des canaux en attente une fois la publication tentée, préservant les informations nécessaires
  pour surveiller la transaction et récupérer les canaux. Si la transaction ne peut pas être confirmée, les canaux en attente conservés
  nécessitent un nettoyage manuel.

- [LND #11340][] et [#11374][lnd #11374] étendent la prise en charge expérimentale dans LND des [offres BOLT12][topic offers] (voir le
  [Bulletin #424][news424 bolt12]) avec la création d'offres et la gestion des demandes de facture. La première PR ajoute un gestionnaire qui vérifie
  les demandes à partir des offres enregistrées et renvoie des factures signées. La seconde PR connecte le gestionnaire aux [messages onion][topic onion messages]
  entrants et ajoute la RPC `CreateOffer` et la commande `lncli createoffer`. Cependant, le gestionnaire ne
  conserve pas encore l'état de facture nécessaire pour régler les paiements associés aux factures émises. La fonctionnalité n'est
  disponible que dans les versions de développement et nécessite une configuration supplémentaire.

- [LND #11480][] corrige un plantage lors d'une tentative de fermeture forcée d'un canal restauré à partir d'une
  [sauvegarde statique de canal][topic static channel backups]. Une telle sauvegarde ne contient pas de transaction d'engagement locale exploitable.
  La récupération exige que la contrepartie publie sa transaction d'engagement. Auparavant, la procédure de fermeture forcée vérifiait si des données locales
  avaient été perdues, sans tenir compte du statut du canal restauré. Une tentative d'accès à la transaction d'engagement absente
  provoquait alors un plantage. LND rejette désormais cette tentative locale de fermeture forcée et gère de manière sûre
  l'indisponibilité de la transaction, y compris lors de la reprise d'une fermeture interrompue après redémarrage.

- [LND #11481][] corrige la manière dont LND met en cache la hauteur de bloc de départ pour les recherches de confirmation
  d'une transaction. Auparavant, un attaquant pouvait proposer une fausse sortie de financement de canal avec le txid d'une transaction d'engagement
  révoquée et un script de sortie différent. Comme LND mettait en cache les hauteurs de départ des recherches uniquement par txid, la fausse
  demande de financement partageait son entrée de cache avec la demande suivant l'engagement révoqué. La demande de financement non
  correspondante pouvait faire avancer la hauteur de départ au-delà du bloc de confirmation de la transaction révoquée, provoquant son
  omission lors d'une recherche ultérieure. Cela pouvait retarder la détection par LND de l'engagement révoqué et de sa [transaction de pénalité][topic ln-penalty]. LND stocke désormais des hauteurs de départ distinctes pour chaque txid et script de sortie. Le problème
  affecte les recherches dans l'historique, y compris celles effectuées par Neutrino et par Bitcoin Core sans index des transactions.

{% include snippets/recap-ad.md when="2026-11-17 17:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="33504,33395,32646,36142,2251,2347,2342,9610,11492,11479,11340,11374,11480,11481,5507,5532" %}

[anti ex ml]: https://groups.google.com/g/bitcoindev/c/cB37_jChkEI/m/3paRGQ_IBgAJ
[news136 anti ex]: /en/newsletters/2021/02/17/#anti-exfiltration
[anti ex bip]: https://github.com/AvilaLabs/anti-exfil/blob/main/spec/bip-anti-exfil.md
[anti ex psbt]: https://github.com/AvilaLabs/anti-exfil/blob/main/spec/bip-anti-exfil-psbt.md
[news87 anti ex]: /en/newsletters/2020/03/04/#proposal-to-standardize-an-exfiltration-resistant-nonce-protocol
[news88 anti ex]: /en/newsletters/2020/03/11/#exfiltration-resistant-nonce-protocols
[news317 anti ex]: /fr/newsletters/2024/08/23/#protocole-anti-exfiltration-simple-mais-imparfait
[news424 bip461]: /fr/newsletters/2026/09/25/#bips-2224
[anti ex sjors]: https://github.com/Sjors/bips/pull/2/
[poinsot adv ml]: https://groups.google.com/g/bitcoindev/c/tOLTRSOz87k/m/7eiOFoHIAQAJ
[disc pol]: https://bitcoincore.org/en/security-advisories/
[news306 disclosures]: /fr/newsletters/2024/06/07/#divulgation-a-venir-de-vulnerabilites-affectant-les-anciennes-versions-de-bitcoin-core
[CVE-2025-62861]: https://bitcoincore.org/en/2026/11/10/disclose-cve-2025-62861/
[CVE-2025-62860]: https://bitcoincore.org/en/2026/11/10/disclose-cve-2025-62860/
[CVE-2025-62859]: https://bitcoincore.org/en/2026/11/10/disclose-cve-2025-62859/
[news375 truc]: /fr/newsletters/2025/10/10/#bitcoin-core-33504
[towns tn5]: https://groups.google.com/g/bitcoindev/c/DmFiHeo-xRw/m/YI3cpl5vAQAJ
[towns tn5 gist]: https://gist.github.com/ajtowns/ebb148819c6028387271e6f0dce5e1da
[news409 testnet5]: /fr/newsletters/2026/06/12/#projet-de-bip-pour-testnet5
[news412 bip95]: /fr/newsletters/2026/07/03/#bips-2196
[b10c cb summary]: https://delvingbitcoin.org/t/stats-on-compact-block-reconstructions/1052/63
[news382 cb]: /fr/newsletters/2025/11/28/#statistiques-sur-les-mises-a-jour-de-reconstruction-de-blocs-compacts
[b10c cb sept]: https://delvingbitcoin.org/t/stats-on-compact-block-reconstructions/1052/53
[sanders cb investigation]: https://delvingbitcoin.org/t/stats-on-compact-block-reconstructions/1052/56
[bnoc fleet]: https://bnoc.xyz/t/satoshi-31-0-0-peers-with-no-service-flags-and-protocol-70015-pushed-transactions-then-stopped-together-on-oct-18/193/
[bnoc degradation]: https://bnoc.xyz/t/compact-block-reconstruction-degradation-between-september-october-2026/198/

[LDK v0.3-rc4]: https://github.com/lightningdevkit/rust-lightning/tree/v0.3-rc4
[ldk 0.3 notes]: https://github.com/lightningdevkit/rust-lightning/blob/v0.3-rc4/CHANGELOG.md
[LDK v0.2.8]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.2.8
[ldk v0.1.14]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.1.14
[LND v0.21.8-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.21.8-beta
[lnd v0.20.8-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.20.8-beta
[LDK #5507]: https://git.rust-bitcoin.org/lightningdevkit/rust-lightning/pulls/5507
[LDK #5532]: https://git.rust-bitcoin.org/lightningdevkit/rust-lightning/pulls/5532
[news426 ldk rc]: /fr/newsletters/2026/10/09/#ldk-v0-3-rc3
[news412 cltv]: /fr/newsletters/2026/07/03/#lnd-10927
[news166 batch]: /en/newsletters/2021/09/15/#lnd-5356
[news424 bolt12]: /fr/newsletters/2026/09/25/#lnd-11146
[news419 rawtr]: /fr/newsletters/2026/08/21/#projet-de-bip-pour-le-descripteur-de-script-de-sortie-rawtr
[news213 rawtr]: /en/newsletters/2022/08/17/#bitcoin-core-23480
[news406 coinbase]: /fr/newsletters/2026/05/22/#bitcoin-core-34860
