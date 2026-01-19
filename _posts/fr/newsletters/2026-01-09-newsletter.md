---
title: 'Bulletin Hebdomadaire Bitcoin Optech #387'
permalink: /fr/newsletters/2026/01/09/
name: 2026-01-09-newsletter-fr
slug: 2026-01-09-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine met en garde contre un bug de migration de portefeuille dans Bitcoin Core,
résume un post sur l'utilisation du protocole Ark comme une fabrique de canaux LN, et
renvoie à un projet de BIP pour des descripteurs de paiement silencieux. Sont également incluses nos
sections régulières décrivant les candidats à la version finale et les changements notables
dans les logiciels d'infrastructure Bitcoin populaires.

## Nouvelles

- **Bug de migration de portefeuille Bitcoin Core** : Bitcoin Core a publié un [avis][bitcoin
  core notice] concernant un bug dans la fonctionnalité de migration de portefeuille legacy dans les
  versions 30.0 et 30.1. Les utilisateurs d'un portefeuille legacy Bitcoin Core qui utilisent un
  portefeuille sans nom, qui n'avaient pas précédemment migré leur portefeuille vers un portefeuille
  descripteur, et qui tentent une migration dans ces versions, pourraient, si la migration échoue, voir
  leur répertoire de portefeuille supprimé, entraînant potentiellement une perte de fonds.
  Les utilisateurs de portefeuille ne devraient pas tenter de migrations de portefeuille via
  l'interface graphique ou RPC jusqu'à ce que la version v30.2 soit publiée (voir [Bitcoin
  Core 30.2rc1](#bitcoin-core-30-2rc1) ci-dessous). Les utilisateurs d'autres fonctionnalités
  que la migration de portefeuille legacy peuvent continuer à utiliser ces versions de Bitcoin Core
  normalement.

- **Utiliser Ark comme une fabrique de canaux** :
  René Pickhardt a [écrit][rp delving ark cf] sur Delving Bitcoin à propos de ses
  discussions et idées concernant si le meilleur cas d'utilisation d'[Ark][topic ark] pourrait
  être comme une fabrique de canaux [channel factory][topic channel factories] flexible plutôt que
  comme une solution de paiement pour l'utilisateur final.
  Les recherches précédentes de Pickhardt se sont concentrées sur les techniques pour optimiser le
  succès des paiements sur le Lightning Network à travers le [routage][news333 rp routing] et
  l'[équilibrage des canaux][news359 rp balance]. Des structures similaires à Ark contenant
  des canaux Lightning ont été discutées précédemment ([1][optech superscalar],
  [2][news169 jl tt], [3][news270 jl cov]).

  Les idées de Pickhardt se concentrent sur la possibilité pour de nombreux propriétaires de canaux de
  regrouper leurs changements de liquidité de canal (c'est-à-dire ouvertures, fermetures, épissures) en
  utilisant la structure vTXO d'Ark comme moyen de réduire significativement le coût onchain de l'opération
  du Lightning Network au détriment d'un surcoût de liquidité
  pendant le temps entre le moment où un canal est abandonné et quand son lot Ark expire complètement.
  En utilisant des lots Ark comme fabriques de canaux efficaces,
  les LSP pourraient fournir de la liquidité à plus d'utilisateurs finaux de manière efficace,
  et l'expiration intégrée des lots garantit
  qu'ils peuvent récupérer la liquidité des canaux inactifs sans une séquence couteuse de fermeture forcée onchain.
  Les nœuds de routage bénéficieraient également d'opérations de gestion de canal plus efficaces en utilisant
  des lots réguliers pour transférer la liquidité entre leurs canaux plutôt que des opérations d'épissure individuelles.

  Greg Sanders a [répondu][delving ark hark] qu'il a étudié des possibilités similaires,
  spécifiquement en utilisant [hArk][sr delving hark] pour faciliter le transfert (principalement) en
  ligne de l'état d'un canal Lightning d'un lot à un autre. hArk nécessiterait
  [CTV][topic op_checktemplateverify], `OP_TEMPLATEHASH`, ou un opcode similaire.

  Vincenzo Palazzo a [répondu][delving ark poc] avec son code de preuve de concept mettant en œuvre
  une fabrique de canaux Ark.

- **Projet de BIP pour descripteurs de paiement silencieux** : Craig Raw a [posté][sp ml] sur la
  liste de diffusion Bitcoin-Dev une proposition pour un projet de [BIP][BIPs #2047], qui définit une
  nouvelle expression de script de descripteur de niveau supérieur `sp()` pour les [paiements
  silencieux][topic silent payments]. Selon Raw, le descripteur fournit un moyen standardisé de
  représenter les sorties de paiement silencieux dans le cadre du descripteur de sortie, permettant
  l'interopérabilité des portefeuilles et la récupération en utilisant l'infrastructure basée sur les
  descripteurs existants.

  L'expression `sp()` prend comme argument l'une des deux nouvelles expressions de clé, toutes deux
  définies dans la même proposition :

  - `spscan1q..` : Un encodage
    [bech32m][topic bech32] de la clé privée de scan et de la clé publique
    de dépense, avec le caractère `q` représentant la version de paiement silencieux `0`.

  - `spspend1q..` : Un encodage bech32m de la clé privée de scan et de la clé privée de dépense, avec
    le caractère `q` représentant la version de paiement silencieux `0`.

  Facultativement, l'expression `sp()` peut prendre comme arguments d'entrée un `BIRTHDAY`, défini
  comme un entier positif représentant la hauteur de bloc à laquelle le scan doit commencer (doit être >842579,
  la hauteur de bloc à laquelle [BIP352][] a été fusionné), et zéro ou plusieurs `LABEL`s
  sous forme d'entiers utilisés avec le portefeuille.

  Les scripts de sortie produits par `sp()` sont des sorties taproot [BIP341][] telles que spécifiées
  dans BIP352.

## Mises à jour et versions candidates

_Nouvelles versions et versions candidates pour des projets d'infrastructure Bitcoin populaires.
Veuillez envisager de mettre à niveau vers les nouvelles versions ou d'aider à tester les versions candidates._

- [Bitcoin Core 30.2rc1][] est un candidat à la sortie d'une version mineure qui corrige (voir
  [Bitcoin Core #34156](#bitcoin-core-34156)) un bug où le répertoire `wallets` entier pouvait être
  supprimé accidentellement lors de la migration d'un portefeuille hérité anonyme (voir
  [ci-dessus](#bug-de-migration-de-portefeuille-bitcoin-core)).

## Changements notables dans le code et la documentation

_Changements notables récents dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning
repo], [Eclair][eclair repo], [LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo],
[Interface de Portefeuille Matériel (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Propositions d'Amélioration de Bitcoin (BIPs)][bips
repo], [Lightning BOLTs][bolts repo], [Lightning BLIPs][blips repo], [Inquisition Bitcoin][bitcoin
inquisition repo], et [BINANAs][binana repo]._

- [Bitcoin Core #34156][] et [Bitcoin Core #34215][] corrigent un bug dans les versions 30.0 et 30.1
  où le répertoire `wallets` entier pouvait être supprimé accidentellement. Lorsque la migration d'un
  portefeuille hérité anonyme échoue, la logique de nettoyage est censée supprimer uniquement le
  nouveau répertoire de portefeuille [descripteur][topic descriptors] créé. Cependant, puisqu'un
  portefeuille anonyme réside directement dans le répertoire de portefeuilles de niveau supérieur, le
  répertoire entier était supprimé. Le second PR aborde un problème similaire avec la commande
  `createfromdump` de `wallettool` (voir
  Les bulletins [#45][news45 wallettool] et [#130][news130 createfrom]) lorsque le nom d'un
  portefeuille est une chaîne vide et que le fichier de dump contient une erreur de checksum.
  Ces corrections garantissent que seuls les fichiers de portefeuille nouvellement créés sont
  supprimés.

- [Bitcoin Core #34085][] élimine la fonction séparée `FixLinearization()` en intégrant sa
  fonctionnalité dans `Linearize()` ; `TxGraph` reporte désormais la correction des clusters jusqu'à
  leur première re-linéarisation. Le nombre d'appels à `PostLinearize` est réduit car l'algorithme de
  linéarisation de forêt couvrante (SFL) (voir le [Bulletin #386][news386 sfl]) effectue un travail
  similaire lors du chargement d'une linéarisation existante. Cela fait partie du projet [cluster
  mempool][topic cluster mempool].

- [Bitcoin Core #34197][] supprime le champ `startingheight` de la réponse RPC `getpeerinfo`, le
  dépréciant de fait. Utiliser l'option de configuration `deprecatedrpc=startingheight` conserve le
  champ dans la réponse. Le `startingheight` indique la hauteur de la chaîne auto-déclarée par un pair
  lors de l'initiation de la connexion. Cette dépréciation est basée sur l'idée que la hauteur de
  départ rapportée dans le message `VERSION` d'un pair est peu fiable. Elle sera complètement
  supprimée dans la prochaine version majeure.

- [Bitcoin Core #33135][] ajoute un avertissement lorsque `importdescriptors` est appelé avec un
  [miniscript][topic miniscript] [descriptor][topic descriptors] contenant une valeur `older()` (qui
  spécifie un [timelock][topic timelocks]) qui n'a pas de signification de consensus dans [BIP68][]
  (timelocks relatifs) et [BIP112][] (OP_CSV). Bien que certains protocoles, comme Lightning,
  utilisent intentionnellement des valeurs non standard pour encoder des données supplémentaires,
  cette pratique est risquée car la valeur peut sembler fortement verrouillée dans le temps alors
  qu'elle n'est en réalité pas retardée.

- [LDK #4213][] définit les valeurs par défaut pour les [chemins aveuglés][topic rv routing] : lors
  de la construction d'un chemin aveuglé qui n'est pas destiné à un contexte d'[offres][topic offers],
  il vise à maximiser la confidentialité en utilisant un chemin aveuglé non compact et en le
  remplissant jusqu'à quatre sauts (y compris le destinataire). Lorsque le chemin aveuglé est pour une
  offre, la taille en octets est minimisée en réduisant le remplissage et en tentant de construire un
  chemin aveuglé compact.

- [Eclair #3217][] ajoute un signal de responsabilité pour les [HTLCs][topic htlc], remplaçant le
  signal expérimental [endorsement HTLC][topic htlc endorsement]. Cela s'aligne sur les dernières
  mises à jour de spécifications dans [BOLTs #1280][] pour les atténuations des [attaques par blocage
  de canal][topic channel jamming attacks]. La nouvelle proposition traite le signal comme un drapeau
  de responsabilité pour les ressources rares, indiquant que la capacité HTLC protégée a été utilisée,
  et que les pairs en aval peuvent être tenus responsables d'une résolution en temps opportun.

- [LND #10367][] renomme le signal expérimental `endorsement` de [BLIP4][] en `accountable` pour
  s'aligner sur la dernière proposition dans [BLIPs #67][], qui est basée sur la proposition [BOLTs
  #1280][].

- [Rust Bitcoin #5450][] ajoute une validation au décodeur de transaction pour rejeter les
  transactions non-coinbase qui contiennent un `null` prevout, comme dicté par une règle de consensus.

- Rust Bitcoin #5434 ajoute une validation au décodeur de transactions, rejetant les transactions
  coinbase avec une longueur de `scriptSig` en dehors de la plage de 2 à 100 octets.

{% include snippets/recap-ad.md when="2026-01-13 17:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="2047,34156,34215,34085,34197,33135,4213,3217,1280,10367,67,5450,5434" %}
[rp delving ark cf]: https://delvingbitcoin.org/t/ark-as-a-channel-factory-compressed-liquidity-management-for-improved-payment-feasibility/2179
[news333 rp routing]: /fr/newsletters/2024/12/13/#apercus-sur-l-epuisement-des-canaux
[news359 rp balance]: /fr/newsletters/2025/06/20/#recherche-sur-le-reequilibrage-des-canaux
[optech superscalar]: /en/podcast/2024/10/31/
[news169 jl tt]: /en/newsletters/2021/10/06/#proposal-for-transaction-heritage-identifiers
[news270 jl cov]: /fr/newsletters/2023/09/27/#utilisation-de-covenants-pour-ameliorer-la-scalabilite-de-ln
[delving ark hark]: https://delvingbitcoin.org/t/ark-as-a-channel-factory-compressed-liquidity-management-for-improved-payment-feasibility/2179/2
[delving ark poc]: https://delvingbitcoin.org/t/ark-as-a-channel-factory-compressed-liquidity-management-for-improved-payment-feasibility/2179/4
[sr delving hark]: https://delvingbitcoin.org/t/evolving-the-ark-protocol-using-ctv-and-csfs/1602
[bitcoin core notice]: https://bitcoincore.org/en/2026/01/05/wallet-migration-bug/
[Bitcoin Core 30.2rc1]: https://bitcoincore.org/bin/bitcoin-core-30.2/test.rc1/
[news45 wallettool]: /en/newsletters/2019/05/07/#new-wallet-tool
[news130 createfrom]: /en/newsletters/2021/01/06/#bitcoin-core-19137
[news386 sfl]: /fr/newsletters/2026/01/02/#bitcoin-core-32545
[sp ml]:https://groups.google.com/g/bitcoindev/c/bP6ktUyCOJI