---
title: 'Bulletin Hebdomadaire Bitcoin Optech #346'
permalink: /fr/newsletters/2025/03/21/
name: 2025-03-21-newsletter-fr
slug: 2025-03-21-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine résume une discussion sur le système de réajustement dynamique du
taux de frais de LND mis à jour. Sont également incluses nos sections régulières décrivant les
changements récents apportés aux services et aux logiciels clients, annonçant ddes mises à jour et des versions candidates,
et résumant les fusions récentes dans les logiciels d'infrastructure Bitcoin populaires.

## Nouvelles

- **Discussion sur le système de réajustement dynamique du taux de frais de LND :** Matt Morehouse a
  [posté][morehouse sweep] sur Delving Bitcoin une description du système _sweeper_ récemment réécrit
  de LND, qui détermine les taux de frais à utiliser pour les transactions onchain (y compris les
  augmentations de frais [RBF][topic rbf]). Il commence par une brève description des aspects
  critiques de la gestion des frais pour un nœud LN, ainsi que le désir naturel d'éviter de payer trop
  cher. Il décrit ensuite les deux stratégies générales utilisées par LND :

  - Interroger des estimateurs de taux de frais externes, tels qu'un nœud Bitcoin Core local ou un
    tiers. Cela est principalement utilisé pour choisir les taux de frais initiaux et pour augmenter les
    frais des transactions non urgentes.

  - Augmentation exponentielle des frais, utilisée lorsqu'une échéance approche pour s'assurer que les
    problèmes avec le mempool d'un nœud ou son [estimation de frais][topic fee estimation] n'empêchent
    pas une confirmation en temps voulu. Par exemple, Eclair utilise l'augmentation exponentielle des
    frais lorsque les échéances sont dans les six blocs.

  Morehouse décrit ensuite comment ces deux stratégies sont combinées dans le nouveau système sweeper
  de LND : "Les réclamations [HTLC][topic htlc] avec des échéances correspondantes [sont agrégées]
  dans une seule [transaction groupée][topic payment batching]. Le budget pour la transaction groupée
  est calculé comme la somme des budgets pour les HTLC individuels dans la transaction. En fonction du
  budget de la transaction et de l'échéance, une fonction de frais est calculée qui détermine combien
  du budget est dépensé à mesure que l'échéance approche. Par défaut, une fonction de frais linéaire
  est utilisée, qui commence à un faible taux de frais (déterminé par le taux de frais minimum de
  relais ou un estimateur externe) et se termine avec le budget total alloué aux frais lorsque
  l'échéance est à un bloc."

  Il décrit en outre comment la nouvelle logique aide à protéger contre les attaques de [cycle de
  remplacement][topic replacement cycling], concluant : "avec les paramètres par défaut de LND, un
  attaquant doit généralement dépenser au moins 20 fois la valeur du HTLC pour mener à bien une
  attaque de cycle de remplacement." Il ajoute que le nouveau système améliore également la défense
  de LND contre les [attaques d'épinglage'][topic transaction pinning].

  Il conclut avec un résumé rempli de liens de plusieurs "corrections de bugs et vulnérabilités
  spécifiques à LND" réalisées grâce à la logique améliorée. Abubakar Sadiq Ismail a [répondu][ismail
  sweep] avec quelques suggestions sur comment toutes les implémentations LN (en plus d'autres
  logiciels) peuvent utiliser plus efficacement l'estimation de frais de Bitcoin Core. Plusieurs
  autres développeurs ont également commenté, ajoutant à la fois des nuances à la description et des
  éloges pour la nouvelle approche.

## Changements dans les services et logiciels clients

*Dans cette rubrique mensuelle, nous mettons en lumière des mises à jour intéressantes des
portefeuilles et services Bitcoin.*

- **Wally 1.4.0 publié :** La [libwally-core version 1.4.0][wally 1.4.0] ajoute le support de
  [taproot][topic taproot], le support pour la dérivation des clés RSA [BIP85][], ainsi que des
  fonctionnalités supplémentaires pour [PSBT][topic psbt] et les [descripteurs][topic descriptors].

- **Générateur de configuration Bitcoin Core annoncé :**
  Le projet [Bitcoin Core Config Generator][bccg github] est une interface de terminal pour créer des
  fichiers de configuration `bitcoin.conf` pour Bitcoin Core.

- **Un conteneur d'environnement de développement regtest :**
  Le dépôt [regtest-in-a-pod][riap github] fournit un conteneur [Podman][podman website] configuré
  avec Bitcoin Core, Electrum et Esplora, comme décrit dans le billet de blog [Using Podman Containers
  for Regtest Bitcoin Development][podman bitcoin blog].

- **Outil de visualisation de transactions Explora :**
  [Explora][explora github] est un explorateur basé sur le web pour visualiser et naviguer entre les
  entrées et sorties de transactions.

- **Hashpool v0.1 tagué :**
  [Hashpool][hashpool github] est un [pool de minage][topic pooled mining] basé sur l'implémentation
  de référence [Stratum v2][news247 sri] où les parts de minage sont représentées comme des jetons
  [ecash][topic ecash] (voir le [Podcast #337][pod337 hashpool]).

- **DMND lance le minage en pool :**
  [DMND][dmnd website] lance le minage en pool Stratum v2, en s'appuyant sur leur précédente
  [annonce][news281 demand] de minage solo.

- **Krux ajoute taproot et miniscript :**
  [Krux][news273 krux] ajoute le support de [miniscript][topic miniscript] et taproot, en exploitant
  la bibliothèque [embit][embit website].

- **Élément sécurisé à source ouverte annoncé :**
  Le [TROPIC01][tropic01 website] est un élément sécurisé construit sur RISC-V avec une [architecture
  ouverte][tropicsquare github] pour l'auditabilité.

- **Nunchuk lance le Group Wallet :**
  [Group Wallet][nunchuk blog] prend en charge la [multisignature][topic multisignature],
  taproot, le contrôle des pièces, [Musig2][topic musig], et la communication sécurisée entre les
  participants en réutilisant les descripteurs de sortie dans le fichier [BIP129][] de Bitcoin Secure
  Multisig Setup (BSMS).

- **Protocole FROSTR annoncé :**
  [FROSTR][frostr github] utilise le schéma de signature [threshold signature][topic threshold
  signature] pour réaliser la signature k-de-n et la gestion des clés pour nostr.

- **Bark lancé sur signet :**
  L'implémentation [Bark][new325 bark] de [Ark][topic ark] est maintenant [disponible][second blog]
  sur [signet][topic signet] avec un faucet et un magasin de démonstration pour les tests.

- **Portefeuille Bitcoin Cove annoncé :**
  [Cove Wallet][cove wallet github] est un portefeuille mobile Bitcoin open source basé sur BDK qui
  prend en charge des technologies comme les PSBTs, [les labels][topic wallet labels], les
  dispositifs de signature matérielle, et plus encore.

## Mises à jour et versions candidates

_Nouvelles versions et versions candidates pour des projets d'infrastructure Bitcoin populaires.
Veuillez envisager de mettre à niveau vers les nouvelles versions ou d'aider à tester les versions candidates._

- [Bitcoin Core 29.0rc2][] est un candidat à la version pour la prochaine version majeure du nœud
  complet prédominant du réseau.

## Changements notables dans le code et la documentation

_Changements notables récents dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning
repo], [Eclair][eclair repo], [LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo],
[Interface de Portefeuille Matériel (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Propositions d'Amélioration de Bitcoin (BIPs)][bips
repo], [Lightning BOLTs][bolts repo], [Lightning BLIPs][blips repo], [Inquisition Bitcoin][bitcoin
inquisition repo], et [BINANAs][binana repo]._

- [Bitcoin Core #31649][] supprime toute la logique de point de contrôle, qui n'est plus nécessaire
  suite à l'étape de présynchronisation des en-têtes mise en œuvre il y a des années (voir le Bulletin
  [#216][news216 presync]) qui permet à un nœud pendant le Téléchargement Initial de Bloc (IBD) de
  déterminer si une chaîne d'en-têtes est valide en comparant son travail total prouvé (PoW) à un
  seuil prédéfini `nMinimumChainWork`. Seules les chaînes avec un travail prouvé total dépassant cette
  valeur sont considérées comme valides et stockées, empêchant efficacement les attaques DoS de
  mémoire par des en-têtes de faible travail. Cela élimine le besoin de points de contrôle, qui
  étaient souvent vus comme un élément centralisé.

- [Bitcoin Core #31283][] introduit une nouvelle méthode `waitNext()` à l'interface `BlockTemplate`,
  qui ne retournera un nouveau modèle que si le sommet de la chaîne change ou si les frais de la
  mempool augmentent au-dessus du seuil `MAX_MONEY`. Auparavant, les mineurs recevaient un nouveau
  modèle à chaque demande, résultant en une génération de modèle inutile. Ce changement est conforme à
  la spécification du protocole [Stratum V2][topic pooled mining].

- [Eclair #3037][] améliore la commande `listoffers` (Voir le Bulletin [#345][news345 offers]) pour
  retourner toutes les données pertinentes d'[offre][topic offers], y compris les horodatages
  `createdAt` et `disabledAt`, au lieu de simplement des données Type-Longueur-Valeur (TLV) brutes. De
  plus, ce PR corrige un bug qui causait le crash du nœud lors de la tentative d'enregistrement de la
  même offre deux fois.

- [LND #9546][] ajoute un drapeau `ip_range` à la sous-commande `lncli constrainmacaroon` (voir
  le Bulletin [#201][news201 constrain]), permettant aux utilisateurs de restreindre l'accès à une
  ressource à une plage IP spécifique lors de l'utilisation d'un macaroon (jeton d'authentification).
  Auparavant, les macaroons ne pouvaient autoriser ou refuser l'accès que sur la base d'adresses IP
  spécifiques, et non de plages.

- [LND #9458][] introduit des emplacements d'accès restreints pour certains pairs, configurables via
  le drapeau `--num-restricted-slots`, pour gérer les permissions d'accès initiales sur le serveur.
  Les pairs se voient attribuer des niveaux d'accès en fonction de leur historique de canal : ceux
  avec un canal confirmé reçoivent un accès protégé, ceux avec un canal non confirmé reçoivent un
  accès temporaire, et tous les autres reçoivent un accès restreint.

- [BTCPay Server #6581][] ajoute le support [RBF][topic rbf], permettant l'augmentation des frais
  pour les transactions qui n'ont pas de descendants, où tous les inputs proviennent du
  portefeuille du magasin, et qui incluent une des adresses de changement du magasin. Les utilisateurs
  peuvent maintenant choisir entre [CPFP][topic cpfp] et RBF lorsqu'ils décident d'augmenter les frais
  d'une transaction. L'augmentation des frais nécessite la version 2.5.22 de NBXplorer ou supérieure.

- [BDK #1839][] ajoute le support pour la détection et la gestion des transactions annulées (double
  dépense) en introduisant un nouveau champ `TxUpdate::evicted_ats`, qui met à jour les horodatages
  `last_evicted` dans `TxGraph`. Les transactions sont considérées comme évacuées si leur horodatage
  `last_evicted` dépasse leur horodatage `last_seen`. L'algorithme de canonicalisation (voir
  le Bulletin [#335][news335 algorithm]) est mis à jour pour ignorer les transactions évacuées sauf
  lorsqu'un descendant canonique existe en raison des règles de transitivité.

- [BOLTs #1233][] met à jour le comportement d'un nœud pour ne jamais échouer un [HTLC][topic htlc]
  en amont si le nœud connaît le préimage, assurant que le HTLC peut être correctement réglé.
  Auparavant, la recommandation était de faire échouer un HTLC en attente en amont s'il manquait d'un
  engagement confirmé, même si le préimage était connu. Un bug dans les versions de LND avant 0.18
  causait l'échec des HTLCs en amont après un redémarrage sous attaque DoS, malgré la connaissance du
  préimage, résultant dans la perte de la valeur du HTLC (voir le Bulletin [#344][news344 lnd]).

{% include snippets/recap-ad.md when="2025-03-25 15:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="31649,31283,3037,9546,9458,6581,1839,1233" %}
[bitcoin core 29.0rc2]: https://bitcoincore.org/bin/bitcoin-core-29.0/
[morehouse sweep]: https://delvingbitcoin.org/t/lnds-deadline-aware-budget-sweeper/1512
[ismail sweep]: https://delvingbitcoin.org/t/lnds-deadline-aware-budget-sweeper/1512/3
[news216 presync]: /en/newsletters/2022/09/07/#bitcoin-core-25717
[news345 offers]: /en/newsletters/2025/03/14/#eclair-2976
[news201 constrain]: /en/newsletters/2022/05/25/#lnd-6529
[news344 lnd]: /en/newsletters/2025/03/07/#disclosure-of-fixed-lnd-vulnerability-allowing-theft
[news335 algorithm]: /en/newsletters/2025/01/03/#bdk-1670
[wally 1.4.0]: https://github.com/ElementsProject/libwally-core/releases/tag/release_1.4.0
[bccg github]: https://github.com/jurraca/core-config-tui
[riap github]: https://github.com/thunderbiscuit/regtest-in-a-pod
[podman website]: https://podman.io/
[podman bitcoin blog]: https://thunderbiscuit.com/posts/podman-bitcoin/
[explora github]: https://github.com/lontivero/explora
[hashpool github]: https://github.com/vnprc/hashpool
[news247 sri]: /en/newsletters/2023/04/19/#stratum-v2-reference-implementation-update-announced
[pod337 hashpool]: /en/podcast/2025/01/21/#continued-discussion-about-rewarding-pool-miners-with-tradeable-ecash-shares-transcript
[news281 demand]: /en/newsletters/2023/12/13/#stratum-v2-mining-pool-launches
[dmnd website]: https://www.dmnd.work/
[embit website]: https://embit.rocks/
[news273 krux]: /en/newsletters/2023/10/18/#krux-signing-device-firmware
[tropic01 website]: https://tropicsquare.com/tropic01
[tropicsquare github]: https://github.com/tropicsquare
[nunchuk blog]: https://nunchuk.io/blog/group-wallet
[frostr github]: https://github.com/FROSTR-ORG
[new325 bark]: /en/newsletters/2024/10/18/#bark-ark-implementation-announced
[second blog]: https://blog.second.tech/try-ark-on-signet/
[cove wallet github]: https://github.com/bitcoinppl/cove
