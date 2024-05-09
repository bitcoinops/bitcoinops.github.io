---
title: 'Bulletin Hebdomadaire Bitcoin Optech #252'
permalink: /fr/newsletters/2023/05/24/
name: 2023-05-24-newsletter-fr
slug: 2023-05-24-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin d'information de cette semaine s'intéresse aux recherches autour des preuves de validité à connaissance nulle pour Bitcoin et les
protocoles connexes. Vous y trouverez également une nouvelle contribution à notre série hebdomadaire limitée sur la politique du
mempool, ainsi que nos sections régulières décrivant les mises à jour des clients et des services, les nouvelles versions et les
versions candidates, ainsi que les changements apportés aux principaux projets d'infrastructure de Bitcoin.

## Nouvelles

- **Compression d'états avec preuves de validité à connaissance nulle :** Robin Linus
  a [posté][linus post] sur la liste de diffusion Bitcoin-Dev un [article][lg paper]
  qu'il a co-écrit avec Lukas George sur l'utilisation des preuves de validité pour
  réduire la quantité d'état qu'un client doit télécharger afin de vérifier sans confiance
  les opérations futures dans un système. Ils appliquent d'abord leur système à Bitcoin.
  Ils indiquent qu'ils disposent d'un prototype qui prouve la quantité cumulative de
  preuves de travail dans une chaîne d'en-têtes de blocs et permet à un client de
  vérifier qu'un en-tête de bloc particulier fait partie de cette chaîne.
  Cela permet à un client qui reçoit plusieurs preuves de déterminer laquelle démontre
  la plus grande preuve de travail.

  Ils disposent également d'un prototype sous-optimal qui prouve que tous les
  changements d'état des transactions de la chaîne de blocs respectent les règles
  monétaires (par exemple, le nombre de bitcoins pouvant être créés par un nouveau
  bloc, le fait que chaque transaction, en dehors des transactions coinbase, ne doit pas créer
  d'UTXO ayant une valeur supérieure à celle des bitcoins qu'elle détruit (dépense),
  et qu'un mineur peut réclamer toute différence entre les UTXO détruits dans un
  bloc et ceux qui ont été créés). Un client recevant cette preuve et une copie de
  l'ensemble d'UTXO actuel serait en mesure de vérifier que l'ensemble est exact et
  complet. Ils appellent cela une preuve _assumevalid_, d'après la [fonctionnalité de Bitcoin Core][assumevalid]
  qui permet de ne pas vérifier les scripts des anciens blocs lorsque de nombreux contributeurs
  s'accordent à dire que leurs nœuds ont tous validé ces blocs avec succès.

  Pour minimiser la complexité de leur preuve, ils utilisent une version de [utreexo][topic utreexo]
  avec une fonction de hachage optimisée pour leur système. Ils suggèrent séparément que
  la combinaison de leur preuve avec un client utreexo permettra à ce dernier de commencer
  à fonctionner comme un nœud complet presque immédiatement après avoir téléchargé une très
  petite quantité de données.

  En ce qui concerne la facilité d'utilisation de leurs prototypes, ils écrivent que
  "nous avons mis en œuvre la preuve de la chaîne d'en-tête et la preuve de l'état
  supposé valide en tant que prototypes. Il est possible de prouver la première, tandis
  que la seconde nécessite encore des améliorations de performance pour prouver des blocs
  de taille raisonnable". Ils travaillent également sur la validation de blocs complets,
  y compris les scripts, mais affirment qu'ils ont besoin d'une augmentation de la vitesse
  d'au moins 40 fois pour que cela soit viable.

  Outre la compression de l'état de la chaîne de blocs Bitcoin, ils décrivent également
  un protocole qui peut être utilisé pour un protocole de jetons à validation côté client
  similaire à celui utilisé pour les actifs Taproot de Lightning Labs et certaines utilisations
  de RGB (voir les lettres d'information [#195][news195 taro] et [#247][news247 rgb]).
  Lorsque Alice transfère à Bob une certaine quantité de jetons, Bob doit vérifier l'historique
  de tous les transferts précédents de ces jetons spécifiques depuis leur création. Dans
  un scénario idéal, cet historique croît linéairement avec le nombre de transferts. Mais
  si Bob veut payer à Carole un montant supérieur à celui qu'il a reçu d'Alice, il devra
  combiner certains des jetons qu'il a reçus d'Alice avec d'autres jetons qu'il a reçus
  lors d'une autre transaction. Carol devra alors vérifier à la fois l'historique de la
  transaction avec Alice et l'historique des autres jetons de Bob. C'est ce qu'on appelle
  une fusion. Si les fusions sont fréquentes, la taille de l'historique qui doit être vérifié
  approche la taille de l'historique de chaque transfert de ce jeton entre les utilisateurs.
  En termes comparatifs, dans Bitcoin, chaque nœud complet vérifie chaque transaction effectuée
  par chaque utilisateur ; dans les protocoles de jetons utilisant la validation côté client,
  cela n'est pas strictement nécessaire mais finit par le devenir si les fusions sont fréquentes.

  Cela signifie qu'un protocole capable de comprimer l'état de Bitcoin peut également
  être adapté pour comprimer l'état de l'historique d'un jeton, même si les fusions sont
  fréquentes. Les auteurs décrivent comment ils y parviendraient. Leur objectif est de
  produire une preuve que chaque transfert précédent du jeton a suivi les règles du jeton,
  y compris en utilisant leurs preuves pour Bitcoin afin de prouver que chaque transfert
  précédent a été ancré dans la chaîne de blocs. Alice pourrait alors transférer les jetons
  à Bob et lui donner une courte preuve de validité de taille constante ; Bob pourrait
  vérifier la preuve pour savoir que le transfert a eu lieu à une certaine hauteur de bloc
  et payer son portefeuille de jetons, ce qui lui donnerait le contrôle exclusif des jetons.

  Bien que le document mentionne fréquemment des recherches et des développements supplémentaires,
  nous estimons qu'il s'agit d'un progrès encourageant vers une [fonctionnalité][coinwitness] que
  les développeurs de Bitcoin souhaitent depuis plus d'une décennie.

## En attente de confirmation #2 : Mesures d'incitation

Une série hebdomadaire limitée sur le relais de transaction, l'inclusion dans le mempool et la
sélection des transactions minières---y compris pourquoi Bitcoin Core a une politique plus
restrictive que celle autorisée par le consensus et comment les portefeuilles peuvent utiliser
cette politique de la manière la plus efficace.

{% include specials/policy/fr/02-utilite-du-cache.md %}

## Modifications apportées aux services et aux logiciels clients

*Dans cette rubrique mensuelle, nous mettons en évidence les mises à jour
intéressantes des portefeuilles et services Bitcoin.*

- **Sortie du firmware 2.1.1 de Passport :**
  Le [dernier micrologiciel][passport 2.1.1] pour le dispositif de signature matérielle
  Passport prend en charge l'envoi aux adresses [taproot][topic taproot], les fonctionnalités
  [BIP85][] et les améliorations apportées à la gestion des configurations [PSBT][topic psbt] et multisig.

- **Lancement du portefeuille MuSig Munstr :**
  Le [logiciel Munstr][munstr github] bêta utilise le [protocole nostr][] afin de faciliter les cycles de
  communication nécessaires à la signature des transactions multi-signatures [MuSig][topic musig].

- **Le gestionnaire de plugins CLN Coffee est disponible :**
  [Coffee][coffee github] est un gestionnaire de plugins CLN qui améliore certains aspects de l'installation,
  de la configuration, de la gestion des dépendances et de la mise à jour des [plugins CLN][news22 plugins].

- **Sortie d'Electrum 4.4.3 :**
  Les [dernières][electrum release notes] versions d'Electrum contiennent des améliorations du contrôle des pièces,
  un outil d'analyse de la confidentialité UTXO et la prise en charge des identificateurs de canaux courts (SCID),
  parmi d'autres corrections et améliorations.

- **La suite Trezor prend en charge le coinjoin :**
  Le logiciel Trezor Suite [a annoncé][trezor blog] la prise en charge des [coinjoins][topic coinjoin]
  qui utilisent le coordinateur de coinjoin zkSNACKs.

- **Lightning Loop est par défaut MuSig2 :**
  [Lightning Loop][news53 loop] utilise désormais [MuSig2][topic musig] comme protocole d'échange par défaut,
  ce qui permet de réduire les frais et d'améliorer la protection de la vie privée.

- **Mutinynet annonce un nouveau signet pour les tests :**
  [Mutinynet][mutinynet blog] est une enseigne personnalisée avec des blocs de 30 secondes qui fournit une infrastructure
  de test comprenant un [explorateur de blocs][topic block explorers], un faucet, ainsi que des nœuds LN de test et des LSP
  fonctionnant sur le réseau.

- **Le Nunchuk ajoute coin control et la prise en charge du BIP329:**
  Les dernières versions Android et iOS de Nunchuk ajoutent les fonctionnalités [coin control][nunchuk blog] et l'export de
  l'étiquette du portefeuille [BIP329][].

- **Le portefeuille MyCitadel ajoute une prise en charge améliorée des miniscripts :**
  La version [v1.3.0][mycitadel v1.3.0] ajoute des fonctionnalités [miniscript][topic miniscript] plus complexes,
  notamment les [timelocks][topic timelocks].

- **Annonce d'un micrologiciel Edge pour Coldcard :**
  Coinkite [annonce][coinkite blog] un firmware expérimental pour le matériel de signature Coldcard,
  conçu pour les développeurs de portefeuilles et les utilisateurs chevronnés afin d'expérimenter de nouvelles fonctionnalités.
  La version initiale 6.0.0X inclut les paiements taproot keypath, les paiements multisig [tapscript][topic tapscript]
  et la prise en charge de [BIP129][].

## Mises à jour et versions candidates

*Nouvelles versions et versions candidates pour les principaux projets d’infrastructure
Bitcoin. Veuillez envisager de passer aux nouvelles versions ou d’aider à tester
les versions candidates.*

- [Core Lightning 23.05][] est la version la plus récente de l'implémentation du LN.
  Elle inclut la prise en charge des [paiements en aveugle][topic rv routing], la version 2 des [PSBT][topic psbt],
  et une gestion plus souple des délais parmi de nombreuses autres améliorations.

- [Bitcoin Core 23.2][] est une version de maintenance pour la version majeure précédente de Bitcoin Core.

- [Bitcoin Core 24.1][] est une version de maintenance pour la version actuelle de Bitcoin Core.

- [Bitcoin Core 25.0rc2][] est une version candidate de la prochaine version majeure de Bitcoin Core.

## Changements notables dans le code et la documentation

*Changements notables cette semaine dans [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo], et
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [Bitcoin Core #27021][] ajoute une interface pour calculer combien cela coûterait d'amener les transactions ascendantes non
confirmées d'une sortie à un taux donné, une valeur connue sous le nom de _fee deficit_. Lorsque [la sélection de
pièces][topic coin selection] envisage d'utiliser une sortie particulière à une fréquence particulière, le déficit de frais de ses
ascendants pour cette fréquence est calculé et le résultat est déduit de sa valeur effective. Cela décourage le portefeuille de
choisir des produits fortement déficitaires pour une nouvelle transaction lorsque d'autres produits pouvant être dépensés sont
disponibles. Dans un [PR de suivi][bitcoin core #26152], l'interface sera également utilisée pour permettre au portefeuille de
payer les frais supplémentaires (appelés _bump fees_) s'il doit de toute façon choisir des sorties déficientes, garantissant ainsi
  que la nouvelle transaction paie le taux effectif demandé par l'utilisateur.

  L'algorithme est capable d'évaluer les frais de majoration pour n'importe quelle constellation d'ascendants en évaluant l'ensemble
  de la grappe de transactions non confirmées de l'UTXO non confirmée et en élaguant les transactions qui auront été sélectionnées
  dans un bloc au niveau de la date cible. Une deuxième méthode permet de calculer un montant global pour plusieurs sorties non
  confirmées afin de corriger les éventuels chevauchements d'ascendances.

- [LND #7668][] ajoute la possibilité d'associer jusqu'à 500 caractères de texte privé à un canal lors de son ouverture et permet à
  l'opérateur de retrouver ces informations ultérieurement, ce qui peut l'aider à se souvenir de la raison pour laquelle il a ouvert
  ce canal en particulier.

- [LDK #2204][] ajoute la possibilité de définir des bits de fonctionnalité personnalisés pour l'annonce aux pairs,
  ou pour l'utilisation lors de la tentative d'analyse de l'annonce d'un pair.

- [LDK #1841][] met en œuvre une version d'une recommandation de sécurité précédemment ajoutée à la spécification LN (voir
  [Newsletter #128][news128 bolts803]) selon laquelle un nœud utilisant des [sorties d'ancrage][topic anchor outputs] ne devrait
  pas tenter de regrouper des entrées contrôlées par plusieurs parties lorsque la transaction doit être confirmée rapidement.
  Cela permet d'éviter que d'autres parties puissent retarder la confirmation.

- [BIPs #1412][] met à jour [BIP329][] pour [l'exportation d'étiquettes de portefeuilles][topic wallet labels] avec un champ pour
stocker les informations sur l'origine de la clé. En outre, la spécification suggère désormais une longueur maximale de 255
caractères pour les étiquettes.

{% include references.md %}
{% include linkers/issues.md v=2 issues="27021,7668,2204,1841,1412,26152" %}
[Core Lightning 23.05]: https://github.com/ElementsProject/lightning/releases/tag/v23.05
[bitcoin core 23.2]: https://bitcoincore.org/bin/bitcoin-core-23.2/
[bitcoin core 24.1]: https://bitcoincore.org/bin/bitcoin-core-24.1/
[bitcoin core 25.0rc2]: https://bitcoincore.org/bin/bitcoin-core-25.0/
[linus post]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-May/021679.html
[lg paper]: https://zerosync.org/zerosync.pdf
[news128 bolts803]: /en/newsletters/2020/12/16/#bolts-803
[news247 rgb]: /fr/newsletters/2023/04/19/#mise-a-jour-rgb
[news195 taro]: /en/newsletters/2022/04/13/#transferable-token-scheme
[coinwitness]: https://bitcointalk.org/index.php?topic=277389.0
[assumevalid]: https://bitcoincore.org/en/2017/03/08/release-0.14.0/#assumed-valid-blocks
[passport 2.1.1]: https://foundationdevices.com/2023/05/passport-version-2-1-0-is-now-live/
[munstr github]: https://github.com/0xBEEFCAF3/munstr
[protocole nostr]: https://github.com/nostr-protocol/nostr
[coffee github]: https://github.com/coffee-tools/coffee
[news22 plugins]: /en/newsletters/2018/11/20/#c-lightning-2075
[electrum release notes]: https://github.com/spesmilo/electrum/blob/master/RELEASE-NOTES
[trezor blog]: https://blog.trezor.io/coinjoin-privacy-for-bitcoin-11aaf291f23
[mutinynet blog]: https://blog.mutinywallet.com/mutinynet/
[news53 loop]: /en/newsletters/2019/07/03/#lightning-loop-supports-user-loop-ins
[nunchuk blog]: https://nunchuk.io/blog/coin-control
[mycitadel v1.3.0]: https://github.com/mycitadel/mycitadel-desktop/releases/tag/v1.3.0
[coinkite blog]: https://blog.coinkite.com/edge-firmware/
