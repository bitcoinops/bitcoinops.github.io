---
titte: 'Bulletin Hebdomadaire Bitcoin Optech #335'
permalink: /fr/newsletters/2025/01/03/
name: 2025-01-03-newsletter-fr
slug: 2025-01-03-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---

Le bulletin de cette semaine contient des liens vers des informations concernant des
vulnérabilités de deanonymisation de longue date dans les logiciels utilisant des protocoles de
coinjoin centralisés et résume une mise à jour d'un brouillon de BIP concernant le protocole de génération
de clés distribuées ChillDKG compatible avec la signature seuil sans script. Sont également incluses
nos sections régulières résumant les discussions sur la modification des règles de consensus de
Bitcoin, annonçant de nouvelles versions et versions candidates, et décrivant les changements
notables apportés aux logiciels d'infrastructure Bitcoin populaires.

## Nouvelles

- **Attaques de deanonymisation contre le coinjoin centralisé :** Yuval Kogman a [posté][kogman cc]
sur la liste de diffusion Bitcoin-Dev des détails sur plusieurs vulnérabilités réduisant la
confidentialité dans les protocoles de [coinjoin][topic coinjoin] centralisés utilisés par les
versions actuelles des portefeuilles Wasabi et Ginger, ainsi que par les versions passées des
logiciels portefeuilles Samourai, Sparrow, et Trezor Suite. Kogman a aidé à concevoir le protocole
WabiSabi utilisé dans Wasabi et Ginger (voir le [Bulletin #102][news102 wabisabi]) mais "a quitté en
protestant avant sa sortie." Si elles sont exploitées, les vulnérabilités permettent au
coordinateur centralisé de déterminer quel utilisateur a reçu quels outputs, éliminant tout avantage
de l'utilisation d'un protocole sophistiqué par rapport à un simple serveur web. Kogman fournit des
preuves que les vulnérabilités étaient connues de plusieurs développeurs de portefeuilles depuis des
années. Une vulnérabilité similaire affectant certains des mêmes logiciels a été mentionnée
précédemment dans le [Bulletin #333][news333 vuln].

- **Proposition ChillDKG mis à jour :** Tim Ruffing et Jonas Nick ont [posté][rn chilldkg] sur la liste de
  diffusion Bitcoin-Dev un lien vers la [proposition de BIP actuelle pour ChillDKG][bip-chilldkg], qui décrit un
  protocole de génération de clés distribuées compatible avec les [signatures seuil sans script][topic
  threshold signature] pour Bitcoin. Depuis leur annonce initiale (voir le [Bulletin #312][news312
  chilldkg]), ils ont corrigé une vulnérabilité de sécurité, ajouté une phase d'investigation qui
  permet d'identifier les participants défectueux, et rendu la sauvegarde et la récupération plus
  faciles. Ils ont également travaillé avec Sivaram Dhakshinamoorthy pour synchroniser leur
  proposition avec sa proposition de signature FROST compatible avec Bitcoin (voir le [Bulletin #315][news315 frost]).

## Modification du consensus

_Une nouvelle section mensuelle résumant les propositions et discussions sur la modification des
règles de consensus de Bitcoin._

- **Opcodes d'amélioration CTV :** le développeur moonsettler a posté à la fois sur
  [Bitcoin-Dev][moonsettler ctvppml] et [Delving Bitcoin][moonsettler ctvppdelv] pour proposer deux
  opcodes supplémentaires à utiliser conjointement avec l'[OP_CHECKTEMPLATEVERIFY][topic
  op_checktemplateverify] déjà proposé :

  - _OP_TEMPLATEHASH_ prend une liste d'éléments de transaction et la convertit en un hash compatible
    CTV. Cela permet aux opérations de pile de spécifier des détails sur les inputs à utiliser, le
    nombre d'inputs, le locktime, la valeur de chaque output, le script de chaque output, le nombre
    d'outputs, et la version de la transaction à utiliser.

  - _OP_INPUTAMOUNTS_ place la valeur en satoshi de certains ou de toutes les entrées sur la pile, qui
    peut être utilisée comme paramètre pour `OP_TEMPLATEHASH` (par exemple, pour exiger une valeur de
    sortie égale).

  Ensemble, ces opcodes peuvent créer des [coffre-forts][topic vaults] avec des propriétés similaires à
  celles possibles avec `OP_VAULT` de [BIP345][]. Les opcodes peuvent également être pratiques pour
  mettre en œuvre des types de [calcul responsable][topic acc] plus efficaces onchain, en plus
  d'autres protocoles de contrat. La discussion sur le fil Delving Bitcoin était en cours au moment de
  la rédaction.

- **Ajuster la difficulté au-delà de 256 bits :** Anders a [posté][anders diff] sur la liste de
  diffusion Bitcoin-Dev avec une préoccupation concernant l'ajustement de la difficulté de la
  preuve-de-travail (PoW) au-delà des 256 bits disponibles dans un en-tête de bloc. Cela nécessiterait
  une augmentation inimaginable du taux de hachage (une augmentation d'environ 2<sup>176</sup> fois le
  taux actuel), mais si cela devait se produire, Michael Cassano [note][cassano diff] qu'un fork
  pourrait ajouter une cible de hachage secondaire et que les deux cibles, primaire et secondaire,
  devraient être atteintes pour qu'un bloc soit valide. Cela est similaire à une proposition pour
  atténuer les attaques de rétention de blocs (voir le [Bulletin #315][news315 withholding]). Ces types
  de forks, qui incluent des propositions comme les _forward blocks_ (voir le [Bulletin #16][news16
  forward]), peuvent techniquement être des soft forks car ils ne font que renforcer les règles
  existantes, mais certains développeurs préfèrent ne pas utiliser cette étiquette car ils facilitent
  la tromperie des nœuds complets non mis à jour et potentiellement de tous les clients légers (SPV)
  en leur faisant croire qu'une transaction a des centaines ou des milliers de confirmations alors
  qu'elle a en réalité zéro confirmation ou est en conflit avec une transaction réellement confirmée.

- **Soft forks transitoires pour les soft forks de nettoyage :** Jeremy Rubin a [posté][rubin
  transitory] sur Delving Bitcoin à propos de l'application temporaire des règles de consensus conçues
  pour atténuer ou corriger les vulnérabilités. L'idée avait précédemment été proposée pour les soft
  forks qui ajoutent de nouvelles fonctionnalités (voir le [Bulletin #197][news197 transitory]) mais
  n'avait reçu aucun soutien ni des défenseurs de nouvelles fonctionnalités ni des membres de la
  communauté ambivalents quant aux changements proposés. Rubin suggère que l'idée pourrait mieux
  s'appliquer aux soft forks qui tentent de corriger les vulnérabilités mais comportent un risque
  d'empêcher accidentellement les utilisateurs de dépenser leurs bitcoins (appelé _risque de
  confiscation_) ou de limiter la capacité à corriger facilement les vulnérabilités futures. David
  Harding a [argumenté][harding transitory] que le manque de soutien précédent pour l'idée de soft
  forks transitoires provenait du fait que ni les défenseurs ni les membres de la communauté
  ambivalents ne voulaient avoir à rediscuter pour ou contre un changement de consensus tous les
  quelques années, et que cette préoccupation s'applique de la même manière qu'un changement ajoute
  une fonctionnalité ou adresse une vulnérabilité.

- **Chemin de mise à niveau pour ordinateur quantique :** Matt Corallo a [posté][corallo qc] sur la
  liste de diffusion Bitcoin-Dev à propos de l'ajout d'un opcode de vérification de signature
  résistant aux quantiques dans [tapscript][topic tapscript] pour permettre aux fonds d'être dépensés
  même si les opérations de signature ECDSA et [schnorr][topic schnorr signatures] étaient désactivées
  en raison du risque de contrefaçon par des ordinateurs quantiques rapides.
  Luke Dashjr a [noté][dashjr qc] qu'un soft fork est inutile pour le moment
  tant qu'il y a un accord général actuellement sur le fonctionnement futur d'un opcode de vérification
  de signature résistant aux quantiques, car les utilisateurs n'ont besoin que de s'engager sur cette
  option qui pourrait devenir disponible plus tard. Tadge Dryja a [suggéré][dryja qc] un soft fork
  transitoire qui restreindrait temporairement l'utilisation des signatures ECDSA et schnorr non
  sécurisées contre les quantiques si cela semblait que les ordinateurs quantiques étaient sur le
  point de pouvoir voler des bitcoins. Ensuite, si quelqu'un résolvait un contrat de puzzle onchain
  qui n'est solvable qu'avec un ordinateur quantique (ou la découverte d'une vulnérabilité
  cryptographique fondamentale), le soft fork transitoire deviendrait automatiquement permanent ;
  sinon, le soft fork transitoire pourrait être renouvelé ou autorisé à expirer (rendant les bitcoins
  protégés par ECDSA et schnorr à nouveau dépensables).

- **Période de grâce de nettoyage de consensus timewarp :** Sjors Provoost a [posté][provoost
  timewarp] sur Delving Bitcoin à propos de la proposition pour le soft fork de [nettoyage de
  consensus][topic consensus cleanup] afin de mitiger l'[attaque timewarp][topic time warp] en
  interdisant au premier bloc d'une nouvelle période de difficulté d'avoir un temps inférieur de plus
  de 600 secondes par rapport au dernier bloc de la période précédente. Provoost est préoccupé par le
  fait qu'un mineur honnête utilisant un logiciel qui étend son espace de nonce en utilisant une plage
  de timestamps (appelée _time rolling_) produira accidentellement un bloc que les nœuds avec des
  horloges lentes pourraient ne pas accepter immédiatement, ralentissant la propagation du bloc par
  rapport à des blocs concurrents avec des timestamps moins variables qui peuvent être produits en
  même temps. Si un bloc concurrent reste sur la meilleure blockchain, le mineur du bloc time-rolling
  perdra des revenus. Provoost suggère plutôt une limite moins restrictive, comme interdire au temps
  de reculer de plus de 7,200 secondes (deux heures). Antoine Poinsot [défend][poinsot timewarp] le
  choix de 600 secondes comme évitant tout problème connu et offrant la meilleure défense contre les
  futurs timewarpings.

## Mises à jour et versions candidates

_Nouvelles mises à jour et versions candidates pour des projets d'infrastructure Bitcoin populaires.
Veuillez envisager de passer aux nouvelles versions ou d'aider à tester
les versions candidates._

- [BDK wallet-1.0.0][] est la première sortie majeure de cette bibliothèque pour construire des
  portefeuilles Bitcoin et d'autres applications activées par Bitcoin. Le paquet Rust `bdk` original a
  été renommé en `bdk_wallet` (avec une API destinée à rester stable) et des modules de couche
  inférieure ont été extraits dans leurs propres paquets, incluant `bdk_chain`, `bdk_electrum`,
  `bdk_esplora`, et `bdk_bitcoind_rpc`.

- [LND 0.18.4-beta][] est une sortie mineure de cette implémentation LN populaire qui "livre les
  fonctionnalités requises pour construire des canaux personnalisés, à côté des habituelles
  corrections de bugs et améliorations de stabilité."

- [Core Lightning v24.11.1][] est une sortie mineure qui améliore la compatibilité entre le plugin
  expérimental `xpay` et l'ancien RPC `pay` et apporte plusieurs autres améliorations pour les
  utilisateurs de xpay.

- [Bitcoin Core 28.1rc2][] est un candidat à la sortie pour une version de maintenance de
  l'implémentation de nœud complet prédominante.

- [LDK v0.1.0-beta1][] est un candidat à la version de cette bibliothèque pour la construction de
  portefeuilles et d'applications compatibles LN.

## Changements notables dans le code et la documentation

_Changements récents notables dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core
lightning repo], [Eclair][eclair repo], [LDK][ldk repo], [LND][lnd repo],
[libsecp256k1][libsecp256k1 repo], [Interface de Portefeuille Matériel (HWI)][hwi repo], [Rust
Bitcoin][rust bitcoin repo], [Serveur BTCPay][btcpay server repo], [BDK][bdk repo], [Propositions
d'Amélioration de Bitcoin (BIPs)][bips repo], [Lightning BOLTs][bolts repo], [Lightning BLIPs][blips
repo], [Inquisition Bitcoin][bitcoin inquisition repo], et [BINANAs][binana repo]._

- [Bitcoin Core #31223][] modifie la manière dont un nœud dérive son "objectif de service de port P2P
  [Tor][topic anonymity networks]" (voir le Bulletin [#118][news118 tor]), en utilisant la
  valeur `-port` spécifiée par l'utilisateur plus une au lieu de la valeur par défaut de 8334, si une
  valeur `-port` est donnée. Cela corrige un problème où plusieurs nœuds locaux se liaient tous à 8334
  et plantaient en raison d'une collision de ports. Cependant, dans le cas rare où deux nœuds locaux
  se voient attribuer des valeurs `-port` consécutives, ils peuvent encore entrer en collision sur le
  port onion dérivé, mais cela devrait être évité en totalité.

- [Eclair #2888][] implémente le support pour le protocole de [stockage de pairs][topic peer
  storage] tel que spécifié dans [BOLTs #1110][], qui permet aux nœuds de stocker des sauvegardes
  chiffrées pour les pairs qui les demandent, jusqu'à 65kB par défaut. Cette fonctionnalité est
  destinée aux Prestataires de Services Lightning (LSPs) servant des portefeuilles mobiles, et dispose
  de paramètres configurables permettant à un opérateur de nœud de spécifier combien de temps il
  conservera les données. Cela fait d'Eclair la deuxième implémentation à supporter le stockage de
  pairs, après CLN (voir le Bulletin [#238][news238 storage]).

- [LDK #3495][] affine le modèle de notation de probabilité de succès historique dans la recherche
  de chemin LN en améliorant la [fonction de densité de probabilité (PDF)][probability density] et les
  paramètres associés basés sur des données réelles collectées à partir de sondes aléatoires. Cette PR
  aligne les modèles historiques et à priori avec le comportement du monde réel, améliore les
  pénalités par défaut, et améliore la fiabilité de la recherche de chemin.

- [LDK #3436][] déplace le paquet `lightning-liquidity` vers le dépôt `rust-lightning`. Ce paquet
  fournit des types et des primitives pour intégrer un LSP (tel que spécifié [ici][lsp spec]) avec un
  nœud basé sur LDK.

- [LDK #3435][] ajoute un champ d'authentification au message de contexte de paiement de [chemin
  aveuglé][topic rv routing] pour qu'un payeur puisse inclure un Code d'Authentification de Message
  basé sur un Hash (HMAC) et un nonce et permettre à un destinataire d'authentifier le payeur. Cela
  corrige un problème où un attaquant pourrait prendre un `payment_secret` d'une facture [BOLT11][]
  émise par le nœud victime et forger un paiement, même s'il ne correspondait pas au montant attendu
  pour cette [offre][topic offers]. Cela aide également à prévenir les attaques de désanonymisation
  utilisant la même technique.

- [LDK #3365][] assure que le `holder_commitment_point` (prochain point d'engagement) est
  immédiatement marqué comme disponible lors des mises à niveau en le récupérant dans
  `get_channel_reestablish`, au lieu de le laisser dans l'état précédemment utilisé `PendingNext`. Ce
  changement prévient les fermetures forcées lorsqu'un canal est dans un état stable pendant une mise
  à niveau puis reçoit un message `commitment_signed` qui nécessite que le prochain point d'engagement
  soit disponible.

- [LDK #3340][] introduit le [batching][topic payment batching] des transactions de réclamation
  on-chain avec des sorties [époinglable][topic transaction pinning], réduisant l'utilisation de l'espace
  de bloc et les frais dans les scénarios de fermeture forcée. Auparavant, les sorties étaient
  uniquement regroupées si elles étaient exclusivement réclamables par le nœud, et donc non-épinglables.
  Désormais, toute sortie à moins de 12 blocs de la hauteur à laquelle une contrepartie peut la
  dépenser est traitée comme épinglable et regroupée en conséquence, à condition que leurs [temps de
  blocage][topic timelocks] [HTLC][topic htlc]-timeout puissent être combinés.

- [BDK #1670][] introduit un nouvel algorithme de canonicalisation en O(n) qui identifie les
  transactions canoniques et supprime les conflits non confirmés qui ont peu de chances d'être
  confirmés (non canoniques) de la meilleure vue de la chaîne locale du portefeuille. Cette approche
  significativement plus efficace remplace et supprime l'ancienne méthode `get_chain_position`, qui
  offrait une solution en O(n²) qui [aurait pu représenter un risque de DoS][canalgo] pour certains
  cas d'utilisation.

- [BIPs #1689][] fusionne [BIP374][] pour spécifier une manière standard de générer et de vérifier
  les [Preuves d'Égalité de Logarithme Discret (DLEQs)][topic dleq] pour la courbe elliptique utilisée
  par Bitcoin (secp256k1). Ce BIP est motivé par le soutien aux [paiements silencieux][topic silent
  payments] créés à l'aide de plusieurs signataires indépendants ; un DLEQ permettrait à tous les
  signataires de prouver aux co-signataires que leur signature est valide et ne risque pas de perdre
  des fonds, sans révéler leur clé privée.

- [BIPs #1697][] met à jour [BIP388][] pour ajouter le support de [MuSig][topic musig] dans
  l'ensemble modélisé des [descripteurs de script de sortie][topic descriptors] en effectuant des
  changements grammaticaux précis.

- [BLIPs #52][] ajoute [BLIP50][] pour spécifier un protocole utilisé pour la communication entre
  les nœuds LSP et leurs clients, avec un format JSON-RPC sur les messages peer-to-peer [BOLT8][].
  Cela fait partie d'un ensemble de BLIPs qui sont remontés du [répertoire de spécification LSP][lsp
  spec], et qui sont considérés comme stables car ils sont en production en direct sur plusieurs
  implémentations de LSP et clients.

- [BLIPs #54][] ajoute [BLIP52][] pour spécifier un protocole pour les [canaux JIT][topic jit
  channels] qui permet aux clients sans aucun canal LN de commencer à recevoir des paiements.
  Lorsqu'un paiement entrant est reçu par le LSP, un canal est ouvert en réponse au client, et le coût
  d'ouverture du canal est déduit du premier paiement reçu. Cela fait également partie d'un ensemble
  de BLIPs qui sont remontés du [répertoire de spécification LSP][lsp spec].

{% include snippets/recap-ad.md when="2025-01-07 15:30" %}{% include references.md %}
{% include linkers/issues.md v=2
issues="31223,2888,3495,3436,3435,3365,3340,1670,1689,1697,54,52,1110" %}
[news315 withholding]: /fr/newsletters/2024/08/09/#attaques-de-retention-de-blocs-et-solutions-potentielles
[news16 forward]: /en/newsletters/2018/10/09/#forward-blocks-on-chain-capacity-increases-without-a-hard-fork
[moonsettler ctvppml]: https://groups.google.com/g/bitcoindev/c/1P1aqkfwE7E
[moonsettler ctvppdelv]: https://delvingbitcoin.org/t/ctv-op-templatehash-and-op-inputamounts/1344/
[anders diff]: https://groups.google.com/g/bitcoindev/c/JhEyfW7YKhY/m/qR4ucBeMCAAJ
[cassano diff]: https://groups.google.com/g/bitcoindev/c/JhEyfW7YKhY/m/gPNAMn3ICAAJ
[corallo qc]: https://groups.google.com/g/bitcoindev/c/8O857bRSVV8/m/4cM-7pf4AgAJ
[dashjr qc]: https://groups.google.com/g/bitcoindev/c/8O857bRSVV8/m/YT0fR2j_AgAJ
[dryja qc]: https://groups.google.com/g/bitcoindev/c/8O857bRSVV8/m/8nr6I5NIAwAJ
[rubin transitory]: https://delvingbitcoin.org/t/transitory-soft-forks-for-consensus-cleanup-forks/1333
[news197 transitory]: /en/newsletters/2022/04/27/#relayed
[harding transitory]: https://delvingbitcoin.org/t/transitory-soft-forks-for-consensus-cleanup-forks/1333/2
[provoost timewarp]: https://delvingbitcoin.org/t/timewarp-attack-600-second-grace-period/1326
[poinsot timewarp]: https://delvingbitcoin.org/t/timewarp-attack-600-second-grace-period/1326/11
[news333 vuln]: /fr/newsletters/2024/12/13/#vulnerabilite-de-desanonymisation-affectant-wasabi-et-les-logiciels-associes
[news315 frost]: /fr/newsletters/2024/08/09/#proposition-de-bip-pour-les-signatures-a-seuil-sans-script
[news312 chilldkg]: /fr/newsletters/2024/07/19/#protocole-de-generation-de-cles-distribue-pour-frost
[kogman cc]: https://groups.google.com/g/bitcoindev/c/CbfbEGozG7c/m/w2B-RRdUCQAJ
[news102 wabisabi]: /en/newsletters/2020/06/17/#wabisabi-coordinated-coinjoins-with-arbitrary-output-values
[rn chilldkg]: https://groups.google.com/g/bitcoindev/c/HE3HSnGTpoQ/m/Y2VhaMCrCAAJ
[bip-chilldkg]: https://github.com/BlockstreamResearch/bip-frost-dkg
[lnd 0.18.4-beta] : https://github.com/lightningnetwork/lnd/releases/tag/v0.18.4-beta
[bitcoin core 28.1rc2]: https://bitcoincore.org/bin/bitcoin-core-28.1/
[bdk wallet-1.0.0]: https://github.com/bitcoindevkit/bdk/releases/tag/wallet-1.0.0
[core lightning v24.11.1]: https://github.com/ElementsProject/lightning/releases/tag/v24.11.1
[ldk v0.1.0-beta1]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.1.0-beta1
[news118 tor]: /en/newsletters/2020/10/07/#bitcoin-core-19991
[news238 storage]: /fr/newsletters/2023/02/15/#core-lightning-5361
[lsp spec]: https://github.com/BitcoinAndLightningLayerSpecs/lsp
[probability density]: https://fr.wikipedia.org/wiki/Fonction_de_densité_de_probabilité
[canalgo]: https://github.com/evanlinjin/bdk/blob/e9854455ca77875a6ff79047726064ba42f94f29/docs/adr/0003_canonicalization_algorithm.md