---
title: 'Bulletin Hebdomadaire Bitcoin Optech #322'
permalink: /fr/newsletters/2024/09/27/
name: 2024-09-27-newsletter-fr
slug: 2024-09-27-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine expose une vulnérabilité corrigée affectant les anciennes versions
de Bitcoin Core, fournit une mise à jour sur l'atténuation du brouillage de canaux hybrides, résume
un article sur la validation côté client plus efficace et privée, et annonce une proposition de mise
à jour du processus BIP. On y trouvera également nos
rubriques habituelles avec des questions et réponses populaires
de la communauté Bitcoin Stack Exchange, des annonces de nouvelles versions et
versions candidates, ainsi que les changements apportés aux principaux logiciels d'infrastructure Bitcoin.

## Actualités

- **Divulgation d'une vulnérabilité affectant les versions de Bitcoin Core antérieures à 24.0.1 :**
  Antoine Poinsot a [publié][poinsot headers] sur la liste de diffusion Bitcoin-Dev un lien vers
  l'annonce d'une vulnérabilité affectant les versions de Bitcoin Core qui sont obsolètes depuis au
  moins décembre 2023. Cela fait suite à des divulgations précédentes de vulnérabilités plus anciennes
  (voir les Bulletins [#310][news310 bcc] et [#314][news314 bcc]).

  La nouvelle divulgation discute d'une méthode connue depuis longtemps pour faire planter les nœuds
  complets Bitcoin Core : leur envoyer de longues chaînes d'en-têtes de blocs qui seront stockées en
  mémoire. Chaque en-tête de bloc fait 80 octets et, s'il n'y avait pas de protections, on pourrait en
  créé avec la difficulté minimale du protocole, ce qui permettrait à un attaquant disposant d'ASIC modernes
  de produire des millions par seconde. Bitcoin Core dispose depuis de nombreuses années d'une
  protection résultant indirectement des points de contrôle ajoutés dans une version antérieure : cela
  empêchait un attaquant de pouvoir créer les blocs initiaux dans une chaîne d'en-têtes à la
  difficulté minimale, le forçant à effectuer un travail de preuve significatif pour laquelle il pourrait
  être payé s'il créait des blocs valides.

  Cependant, le dernier point de contrôle a été ajouté il y a plus de 10 ans <!-- 15 Jul 2014 --> et
  les développeurs de Bitcoin Core ont été réticents à ajouter de nouveaux points de contrôle, car
  cela donne l'impression erronée que la finalité des transactions dépend finalement des développeurs
  créant des points de contrôle. Avec l'amélioration de l'équipement des mineurs et l'augmentation de la
  puissance de hachage du réseau, le coût de création d'une fausse chaîne d'en-têtes a diminué. À
  mesure que le coût diminuait, les chercheurs David Jaenson et Braydon Fuller ont [divulgué de
  manière responsable][topic responsible disclosures] l'attaque aux développeurs de Bitcoin Core. Les
  développeurs ont répondu que le problème leur était connu et ont encouragé Fuller à [publier][fuller
  dos] publiquement son [article][fuller paper] à ce sujet en 2019.

  En 2022, le coût de l'attaque ayant encore diminué, un groupe de développeurs a commencé à
  travailler sur une solution qui n'utilisait pas de points de contrôle. Le PR #25717 de Bitcoin Core
  (voir le [Bulletin #216][news216 checkpoints]) était le résultat de ce travail. Plus tard, Niklas
  Gögge a découvert un bug dans la logique du #25717 et a ouvert le [PR #26355][bitcoin core #26355]
  pour le corriger. Les deux PR ont été fusionnés et Bitcoin Core 24.0.1 a été publié avec la
  correction.

- **Tests et changements de mitigation du brouillage hybride :** Carla Kirk-Cohen a [publié][kc jam]
  sur Delving Bitcoin des détails sur diverses tentatives visant à contrecarrer une implémentation de
  l'atténuation du [brouillage de canaux][topic channel jamming attacks] initialement
  proposée par Clara Shikhelman et Sergei Tikhomirov. L'atténuation du brouillage hybride implique
  une combinaison d'[approbation de HTLC][topic htlc endorsement] et d'une petite _upfront fee_ qui est
  payée inconditionnellement, que le paiement réussisse ou échoue.

  Plusieurs développeurs ont été invités à tenter de
  [brouiller un canal pendant une heure][kc attackathon], avec Kirk-Cohen et
  Shikhelman développant les attaques qui semblaient prometteuses. La plupart des attaques ont
  échoué : soit l'attaquant dépensait plus pour son attaque qu'une autre attaque connue, soit
  le nœud cible gagnait plus de revenus pendant l'attaque qu'il n'aurait gagné à travers le trafic de
  transfert normal sur le réseau simulé.

  Une attaque a réussi : une [sink attack][] qui "vise à diminuer la réputation des pairs d'un nœud
  ciblé en créant des chemins plus courts/moins chers dans le réseau, et en sabotant les paiements
  transférés à travers ses canaux pour diminuer la réputation de tous les nœuds le précédant dans
  l'itinéraire." Pour contrer l'attaque, Kirk-Cohen et Shikhelman ont introduit la [réputation bidirectionnelle][]
  dans la manière dont l'approbation de HTLC est considéré. Quand Bob reçoit un paiement
  d'Alice à transférer à Carol, par exemple `A -> B -> C`, Bob considère à la fois si Alice a tendance
  à transférer des HTLCs qui sont rapidement réglés (comme avec l'approbation du HTLC précédemment) et si
  Carol a tendance à accepter des HTLCs qui sont rapidement réglés (c'est une nouveauté). Maintenant, quand
  Bob reçoit une approbation d'HTLC d'Alice :

  - Si Bob pense que Alice et Carol sont fiables, il transférera et approuvera l'HTLC d'Alice à Carol.

  - Si Bob pense qu'Alice seulement est fiable, il ne transférera pas un HTLC approuvé par Alice. Il le
    rejettera immédiatement, permettant à l'échec de se propager jusqu'à l'expéditeur initial,
    qui pourra rapidement le renvoyer en utilisant un itinéraire différent.

  - Si Bob pense que Carol seulement est fiable, il acceptera un HTLC approuvé d'Alice quand il a une
    capacité supplémentaire, mais il ne l'approuvera pas lors du transfert à Carol.

  Étant donné le changement de la proposition, Kirk-Cohen et Shikhelman planifient des expériences
  supplémentaires pour s'assurer que cela fonctionne comme prévu. Ils ont également créé un lien vers un [message d'une liste d'emails][posen bidir] de Jim Posen datant de mai 2018 qui décrit un système de réputation bidirectionnelle pour
  prévenir les attaques de brouillage (alors appelées _loop attacks_), un exemple de réflexion
  parallèle antérieure sur la résolution de ce problème.

- **Validation côté client protégée (CSV) :** Jonas Nick, Liam Eagen, et Robin Linus ont [posté][nel post] à
  la liste de diffusion Bitcoin-Dev un [article][nel paper] sur un nouveau protocole de [validation côté client][topic
  client-side validation].
  La validation côté client permet au transfert de jetons d'être protégé par la preuve de travail de
  Bitcoin sans révéler publiquement aucune information sur ces jetons ou transferts. La validation
  côté client est un composant clé de protocoles tels que [RGB][topic client-side validation] et [Taproot Assets][topic
  client-side validation].

  L’un des inconvénients des protocoles existants est que la quantité de données qui doit être validée par un
  client lors de la réception d'un jeton est, dans le pire des cas, aussi importante que l'historique de
  transfert de ce jeton et de chaque jeton associé.
  En d'autres termes, pour un ensemble de jetons aussi fréquemment échangés
  que les bitcoins, un client aurait besoin de valider une histoire presque aussi grande que la
  blockchain Bitcoin entière. En plus du coût de bande passante pour transférer ces données et du coût
  CPU pour les valider, transférer l'historique complet affaiblit la confidentialité des récepteurs
  précédents du jeton. En comparaison, Shielded CSV utilise des preuves à divulgation nulle de
  connaissance pour permettre la vérification avec une quantité fixe de ressources et sans révéler les
  transferts précédents.

  Un autre inconvénient des protocoles existants est que chaque transfert d'un jeton nécessite
  d'inclure des données dans une transaction Bitcoin. Shielded CSV permet de combiner plusieurs
  transferts ensemble dans la même mise à jour de 64 octets. Cela peut permettre de confirmer des
  milliers de transferts de jetons chaque fois qu'un nouveau bloc Bitcoin est trouvé en confirmant
  seulement une transaction Bitcoin avec un ajout de données de 64 octets.

  Le document entre dans les détails. Nous avons trouvé particulièrement intéressante l'idée de
  transférer de manière fiable des bitcoins de la blockchain principale vers un Shielded CSV (et
  inversement) sans changements de consensus en utilisant [BitVM][topic acc], l'utilisation de comptes
  (section 2), la discussion sur l'effet de la réorganisation de la blockchain sur les comptes et les
  transferts (également section 2), la discussion connexe sur la dépendance aux transactions non
  confirmées (section 5.2), et la liste des extensions possibles (annexe A).

- **Brouillon de processus BIP mis à jour :** Mark "Murch" Erhardt a [publié][erhardt post] sur la
  liste de diffusion Bitcoin-Dev pour annoncer la disponibilité d'un [PR][erhardt pr]
  pour un brouillon de BIP qui décrit un processus mis à jour pour le dépôt BIP. Toute personne
  intéressée est encouragée à examiner le brouillon et à laisser des commentaires. Si la communauté
  trouve la version finale du brouillon acceptable, elle deviendra le processus utilisé par les
  éditeurs de BIP.

## Questions et réponses sélectionnées de Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] est l'un des premiers endroits où les contributeurs d'Optech
cherchent des réponses à leurs questions - ou quand nous avons quelques moments libres pour aider
les utilisateurs curieux ou confus. Dans cette rubrique mensuelle, nous mettons en lumière certaines
des questions et réponses les plus votées publiées depuis notre dernière mise à jour.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Quelles vérifications spécifiques sont effectuées sur une nouvelle transaction Bitcoin et dans quel ordre ?]({{bse}}124221)
  Murch énumère les vérifications de validité effectuées par Bitcoin Core sur une nouvelle transaction
  lorsqu'elle est soumise à la mempool, y compris les vérifications effectuées dans les fonctions
  `CheckTransaction`, `PreChecks`, `AcceptSingleTransaction`, et fonctions associées.

- [Pourquoi mon répertoire bitcoin est-il plus grand que mon paramètre de limite de données de pruning ?]({{bse}}124197)
  Pieter Wuille note que bien que l'option `prune` limite la taille des données de la blockchain de
  Bitcoin Core, l'état de la chaîne, les index, la sauvegarde du mempool, les fichiers de portefeuille
  et d'autres fichiers ne sont pas soumis à la limite `prune` et peuvent augmenter en taille
  indépendamment.

- [Que dois-je avoir configuré pour que `getblocktemplate` fonctionne ?]({{bse}}124142)
  L'utilisateur CoinZwischenzug pose également une [question connexe]({{bse}}124160) sur la façon de
  calculer la racine de Merkle et la transaction coinbase pour un bloc. Les réponses à ces deux
  questions (de Vojtěch Strnad, RedGrittyBrick et Pieter Wuille) indiquent de manière similaire que,
  bien que le `getblocktemplate` de Bitcoin Core puisse construire des blocs candidats de transactions
  et des informations d'en-tête de bloc, lors du minage sur des réseaux non-test, les
  transactions coinbase sont créées par des logiciels de minage ou de [pool minier][topic
  pooled mining].

- [Peut-on forcer brutalement l'adresse d'un paiement silencieux?]({{bse}}124207)
  Josie, en référence à [BIP352][], décrit les étapes pour dériver une adresse de [paiement
  silencieux][topic silent payments], concluant qu'il est infaisable d'utiliser des techniques de
  force brute pour compromettre les avantages de confidentialité du paiement silencieux.

- [Pourquoi une tx échoue au `testmempoolaccept` pour un remplacement BIP125 mais est acceptée par `submitpackage`?]({{bse}}124269)
  Ava Chow souligne que `testmempoolaccept` évalue uniquement les transactions individuellement et, en
  conséquence, l'exemple [RBF][topic rbf] du guide de test de Bitcoin Core 28.0 [bcc testing rbf]
  indique un rejet. Cependant, puisque [`submitpackage`][news272 submitpackage] évalue à la fois les
  transactions parente et enfant ensemble comme un [package][topic package relay], les deux sont
  acceptées.

- [Comment l'algorithme de score de bannissement calcule-t-il un score de bannissement pour un pair?]({{bse}}117227)
  Brunoerg fait référence à [Bitcoin Core #29575][new309 ban score] qui a ajusté le score
  de mauvaise conduite des pairs pour certains comportements, qu'il a ensuite énumérés.

## Mises à jour et versions candidates

*Nouvelles mises-à-jours et candidates pour des projets d'infrastructure Bitcoin populaires.
Veuillez envisager de mettre à niveau vers les nouvelles mises-à-jour ou d'aider à tester les versions candidates.*

- [BDK 1.0.0-beta.4][] est une version candidate de cette bibliothèque pour construire des
  portefeuilles et d'autres applications activées par Bitcoin. Le paquet Rust original `bdk` a été
  renommée en `bdk_wallet`, et des modules de couche inférieure ont été extraits dans leurs propres
  paquets, incluant `bdk_chain`, `bdk_electrum`, `bdk_esplora`, et `bdk_bitcoind_rpc`. Le paquet
  `bdk_wallet` "est la première version à offrir une API stable 1.0.0."

- [Bitcoin Core 28.0rc2][] est un candidat à la sortie pour la prochaine version majeure de
  l'implémentation de nœud complet prédominante. Un [guide de test][bcc testing] est disponible.

## Changements notables dans le code et la documentation

_Changements récents notables dans [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], et [BINANAs][binana repo]._


- [Eclair #2909][] ajoute un paramètre `privateChannelIds` à la commande RPC `createinvoice` pour
  ajouter des indices de recherche de chemin pour les [canaux privés][topic unannounced channels] aux
  factures BOLT11. Cela corrige un bug qui empêchait les nœuds n'ayant que des canaux privés de
  recevoir des paiements. Pour éviter de divulguer le point de sortie du canal, `scid_alias` devrait
  être utilisé.

- [LND #9095][] et [LND #9072][] introduisent des changements au modificateur de facture [HTLC][topic htlc],
  au financement et à la clôture de canaux auxiliaires, et intègrent des données
  personnalisées dans le RPC/CLI dans le cadre de l'initiative de canaux personnalisés pour améliorer
  le support de LND pour les [actifs taproot][topic client-side validation]. Cette PR permet d'inclure
  des données spécifiques aux actifs personnalisés dans les commandes RPC et prend en charge la
  gestion des canaux auxiliaires via l'interface de ligne de commande.

- [LND #8044][] ajoute de nouveaux types de messages `announcement_signatures_2`,
  `channel_announcement_2` et `channel_update_2` pour le nouveau protocole de gossip v1.75 (voir le
  [Bulletin #261][news261 v1.75]) qui permet aux nœuds d'[annoncer][topic channel announcements] et
  de vérifier les [canaux taproot][topic simple taproot channels]. De plus, certaines modifications
  sont apportées aux messages existants tels que `channel_ready` et `gossip_timestamp_range` pour
  améliorer l'efficacité et la sécurité du gossiping avec les canaux taproot.

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="26355,2909,9095,9072,8044" %}
[BDK 1.0.0-beta.4]: https://github.com/bitcoindevkit/bdk/releases/tag/v1.0.0-beta.4
[bitcoin core 28.0rc2]: https://bitcoincore.org/bin/bitcoin-core-28.0/
[bcc testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/28.0-Release-Candidate-Testing-Guide
[news216 checkpoints]: /fr/newsletters/2022/09/07/#bitcoin-core-25717
[poinsot headers]: https://mailing-list.bitcoindevs.xyz/bitcoindev/WhFGS_EOQtdGWTKD1oqSujp1GW-v_ZUJemlNePPGaGBgzpmu6ThpqLwJpUVei85OiMu_xxjEzt_SeOWY7547C72BVISLENOd_qrdCwPajgk=@protonmail.com/
[fuller dos]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-October/017354.html
[fuller paper]: https://bcoin.io/papers/bitcoin-chain-expansion.pdf
[posen bidir]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-May/001232.html
[erhardt post]: https://mailing-list.bitcoindevs.xyz/bitcoindev/82a37738-a17b-4a8c-9651-9e241118a363@murch.one/
[erhardt pr]: https://github.com/murchandamus/bips/pull/2
[news310 bcc]: /fr/newsletters/2024/07/05/#divulgation-de-vulnerabilites-affectant-les-versions-de-bitcoin-core-anterieures-a-0-21-0
[news314 bcc]: /fr/newsletters/2024/08/02/#divulgation-de-vulnerabilites-affectant-les-versions-de-bitcoin-core-anterieures-a-0-21-0
[kc jam]: https://delvingbitcoin.org/t/hybrid-jamming-mitigation-results-and-updates/1147/
[kc attackathon]: https://github.com/carlaKC/attackathon
[sink attack]: https://delvingbitcoin.org/t/hybrid-jamming-mitigation-results-and-updates/1147#p-3212-manipulation-sink-attack-9
[réputation bidirectionnelle]: https://delvingbitcoin.org/t/hybrid-jamming-mitigation-results-and-updates/1147#p-3212-bidirectional-reputation-10
[nel post]: https://mailing-list.bitcoindevs.xyz/bitcoindev/b0afc5f2-4dcc-469d-b952-03eeac6e7d1b@gmail.com/
[nel paper]: https://github.com/ShieldedCSV/ShieldedCSV/releases/latest/download/shieldedcsv.pdf
[news261 v1.75]: /fr/newsletters/2023/07/26/#annonces-de-canaux-mises-a-jour
[bcc testing rbf]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/28.0-Release-Candidate-Testing-Guide#3-package-rbf
[news272 submitpackage]: /fr/newsletters/2023/10/11/#bitcoin-core-27609
[new309 ban score]: /fr/newsletters/2024/06/28/#bitcoin-core-29575
