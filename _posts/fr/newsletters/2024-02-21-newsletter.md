---
title: 'Bulletin Hebdomadaire Bitcoin Optech #290'
permalink: /fr/newsletters/2024/02/21/
name: 2024-02-21-newsletter-fr
slug: 2024-02-21-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine décrit une proposition pour fournir des instructions de paiement
Bitcoin lisibles par l'homme basées sur DNS, résume un post avec des réflexions sur la compatibilité
des incitations de mempool, renvoie à un fil de discussion sur la conception de Cashu et d'autres
systèmes d'ecash, examine brièvement la discussion en cours sur l'arithmétique 64 bits dans les
scripts Bitcoin (incluant une spécification pour un opcode précédemment proposé), et donne un aperçu
d'un processus amélioré de création d'ASMap reproductible. Sont également incluses nos sections
régulières décrivant les mises à jour des clients et services, avec les annonces de nouvelles versions et les changements
apportés aux principaux logiciels d'infrastructure Bitcoin.

## Nouvelles

- **Instructions de paiement Bitcoin lisibles par l'homme basées sur DNS :** suite à des discussions
  précédentes (voir le [Bulletin #278][news278 dns]), Matt Corallo a [publié][corallo dns] sur Delving
  Bitcoin une [proposition de BIP][dns bip] qui permettra à une chaîne comme `example@example.com` de se
  résoudre en une adresse DNS telle que `example.user._bitcoin-payment.example.com`, qui retournera un
  enregistrement TXT signé par [DNSSEC][] contenant une URI [BIP21][] telle que
  `bitcoin:bc1qexampleaddress0123456`. Les URI BIP21 peuvent être étendues pour supporter plusieurs
  protocoles (voir le [protocole de paiement BIP70][topic bip70 payment protocol]) ; par exemple,
  l'enregistrement TXT suivant pourrait indiquer une adresse [bech32m][topic bech32] à utiliser comme
  solution de secours par les portefeuilles onchain simples, une adresse de [paiement
  silencieux][topic silent payments] à utiliser par les portefeuilles onchain qui supportent ce
  protocole, et une [offre][topic offers] LN à utiliser par les portefeuilles compatibles LN:

  ```text
  bitcoin:bc1qexampleaddress0123456?sp=sp1qexampleaddressforsilentpayments0123456&b12=lno1qexampleblindedpathforanoffer...
  ```

  Les spécificités des différents protocoles de paiement pris en charge ne sont pas définies dans la
  proposition de BIP. Corallo a deux autres propositions, un [BOLT][dns bolt] et un [BLIP][dns BLIP] pour décrire les
  détails pertinents pour les nœuds LN. Le BOLT permet à un propriétaire de domaine de définir un
  enregistrement générique tel que `*.user._bitcoin-payment.example.com` qui se résoudra en une URI
  BIP21 contenant le paramètre `omlookup` (recherche de [message en onion][topic onion messages]) et un
  [chemin aveuglé][topic rv routing] vers un nœud LN particulier. Une personne souhaitant effectuer
  une transaction vers `example@example.com` passera alors la partie récepteur (`example`) à ce nœud LN pour
  permettre à un nœud multi-utilisateur de gérer correctement le paiement. Le BLIP décrit une option
  permettant à tout nœud LN de résoudre de manière sécurisée les instructions de paiement pour tout
  autre nœud via le protocole de communication LN.

  Au moment de la rédaction de cet article, la plupart des discussions sur la proposition pouvaient être trouvées sur
  la [PR du dépôt BIP][bips #1551]. Quelqu'un suggère d'utiliser une solution HTTPS qui pourrait
  être plus accessible à de nombreux développeurs web mais nécessiterait des dépendances
  supplémentaires ; Corallo a dit
  qu'il ne changera pas cette partie de la spécification, mais il a écrit une [petite
  bibliothèque][dnssec-prover] avec un [site de démonstration][dns demo] qui fait tout le travail pour
  les développeurs web. Une autre suggestion était d'utiliser le système existant de résolution
  d'adresse de paiement basé sur le DNS [OpenAlias][], qui est déjà pris en charge par certains logiciels
  Bitcoin, comme Electrum. Un troisième sujet largement discuté était la manière dont les adresses
  devraient être affichées, par exemple `example@example.com`, `@example@example.com`,
  `example$example.com`, etc.

- **Réflexion sur la compatibilité des incitations du mempool :** Suhas Daftuar a [publié][daftuar
  incentive] sur Delving Bitcoin plusieurs réflexions sur les critères que les nœuds complets peuvent
  utiliser pour sélectionner les transactions à accepter dans leurs mempools, à relayer à d'autres
  nœuds, et à miner pour un revenu maximal. Le post part des principes de base et avance jusqu'à la
  pointe de la recherche actuelle avec des descriptions accessibles qui devraient être compréhensibles
  pour quiconque s'intéresse à la conception de la politique de relais de transactions de Bitcoin
  Core. Parmi les réflexions que nous avons trouvées les plus intéressantes, on note :

  - *Le simple remplacement par taux de frais ne garantit pas la compatibilité des incitations :* il
    semble que [remplacer][topic rbf] une transaction payant un taux de frais inférieur par une
    transaction payant un taux de frais supérieur devrait être un gain strict pour les mineurs. Daftuar
    fournit un [exemple illustré][daftuar feerate rule] expliquant pourquoi ce n'est pas toujours le
    cas. Pour une discussion précédente sur le remplacement par taux de frais, voir le [Bulletin
    #288][news288 rbfr].

  - *Les mineurs avec différents taux de hachage ont des priorités différentes :* un mineur avec 1 %
    du taux de hachage total du réseau qui renonce à inclure une transaction particulière dans ses
    modèles de blocs et parvient à trouver le prochain bloc n'aura que 1 % de chance de miner un bloc
    successeur immédiat qui pourrait inclure cette transaction. Cela encourage fortement le petit mineur
    à collecter autant de frais que possible maintenant, même si cela signifie réduire considérablement
    le montant des frais disponibles pour les mineurs des blocs futurs (y compris lui-même,
    potentiellement).

    En comparaison, un mineur avec 25 % du taux de hachage total du réseau qui renonce à inclure une
    transaction dans le prochain bloc aura 25 % de chances de miner le bloc suivant qui
    pourrait inclure cette transaction. Ce mineur important est incité à éviter de collecter certains frais
    maintenant si cela est susceptible d'augmenter significativement les frais disponibles dans le
    futur.

    Daftuar donne un [exemple][daftuar incompatible] de deux transactions conflictuelles. La transaction
    plus petite paie un taux de frais plus élevé ; la transaction plus grande paie plus de frais
    en valeur absolue. S'il n'y a pas beaucoup de transactions dans le mempool proches du taux de frais de la
    transaction plus grande, un bloc la contenant paierait plus de frais à son mineur qu'un bloc
    contenant la transaction plus petite (taux de frais plus élevé). Cependant, s'il y a beaucoup de
    transactions dans le mempool avec des taux de frais similaires à la grande transaction, un mineur
    avec une petite part du taux de hachage total du réseau pourrait être motivé à miner la version plus
    petite (taux de frais plus élevé) pour obtenir autant de frais maintenant---mais un mineur avec une
    plus grande part du taux de hachage total du réseau pourrait être motivé à attendre qu'il soit
    rentable de miner la plus grande transaction (taux de frais inférieur)
    (ou jusqu'à ce que le dépensier, lassé d'attendre, crée une nouvelle version de la transaction
    avec un taux de frais plus élevé). Les incitations différentes de différents mineurs peuvent
    impliquer qu'il n'y a pas de politique universelle pour la compatibilité des incitations.

  - *Trouver des comportements compatibles avec les incitations qui ne peuvent pas résister aux attaques DoS serait utile :*
    Daftuar décrit comment le projet Bitcoin Core
    essaie d'[implémenter][mempool series] des règles de politique qui sont
    à la fois compatibles avec les incitations et résistantes aux attaques par déni de service (DoS).
    Cependant, il note "un domaine de recherche intéressant et précieux serait de déterminer s'il existe
    des comportements compatibles avec les incitations qui ne seraient pas résistants aux DoS à déployer
    sur l'ensemble du réseau (et de les caractériser, s'ils existent). Si c'est le cas, de tels
    comportements pourraient introduire une incitation pour les utilisateurs à se connecter directement
    aux mineurs, ce qui pourrait être mutuellement bénéfique pour ces parties mais
    nuisible à la décentralisation du minage sur le réseau dans son ensemble.
    [...] Comprendre ces scénarios peut également nous être utile alors que nous
    essayons de concevoir des protocoles compatibles avec les incitations qui sont résistants aux DoS,
    afin que nous sachions où se trouvent les limites de ce qui est possible."

- **Discussion sur Cashu et d'autres conceptions de système ecash :** il y a plusieurs semaines, le
  développeur
  Thunderbiscuit a [posté][thunderbiscuit ecash] sur Delving Bitcoin une
  description du [schéma de signature aveugle][] derrière le système [Chaumian
  ecash][] utilisé dans [Cashu][], qui dénomme les soldes en
  satoshis et permet d'envoyer et de recevoir de l'argent en utilisant Bitcoin et LN.
  Les développeurs Moonsettler et Zmnscpxj ont répondu cette semaine pour parler de
  certaines des contraintes de la version simple de la signature aveugle et
  comment des protocoles alternatifs pourraient offrir des avantages supplémentaires. La discussion
  était entièrement théorique mais nous pensons qu'elle
  pourrait être intéressante pour quiconque s'intéresse aux systèmes de style ecash.

- **Discussion continue sur l'arithmétique 64 bits et l'opcode `OP_INOUT_AMOUNT` :**
  plusieurs développeurs ont [continué à discuter][64bit discuss] d'un
  potentiel soft fork qui pourrait ajouter des opérations arithmétiques 64 bits
  à Bitcoin (voir le [Bulletin #285][news285 64bit]). La plupart des discussions
  depuis notre mention précédente ont continué à se concentrer sur comment encoder
  les valeurs 64 bits dans les scripts, la principale différence étant de savoir si
  utiliser un format qui minimise les données onchain ou un format qui est
  le plus simple à opérer de manière programmatique. On a également discuté de l'utilisation de
  nombres signés ou de permettre uniquement des nombres non signés (pour ceux qui
  ne savent pas, ce qui semble inclure un innovateur avancé de Bitcoin auto-proclamé, les nombres
  signés indiquent quel _signe_ ils utilisent (signe positif ou signe négatif) ; les nombres non
  signés permettent seulement d'exprimer zéro et des nombres positifs). Il a également été envisagé de
  permettre
  d'opérer sur des nombres plus grands, potentiellement jusqu'à 4 160 bits (ce qui
  correspond à la limite actuelle de taille d'élément de pile Bitcoin de 520 octets).

  Cette semaine, Chris Stewart a créé un nouveau [fil de discussion][stewart
  inout] pour un [brouillon de BIP][bip inout] pour un opcode initialement proposé dans le cadre de
  `OP_TAPLEAF_UPDATE_VERIFY` (voir le [Bulletin #166][news166 tluv]).
  L'opcode, `OP_INOUT_AMOUNT`, pousse sur la pile la valeur de l'
  entrée actuelle (qui est la valeur de la sortie qu'elle dépense) et
  la valeur de sortie dans la transaction qui a le même index que
  cette entrée. Par exemple, si la première entrée d'une transaction vaut 4 millions de sats, la
  seconde 3 millions de sats, le premier paiement sortant est de 2 millions de sats, et le second
  paiement sortant est de 1 million de sats, alors un `OP_INOUT_AMOUNT` exécuté dans le cadre de
  l'évaluation de la seconde entrée mettrait sur la pile `3_000_000 1_000_000` (encodé, si nous
  comprenons correctement le projet de BIP, comme un entier non signé de 64 bits en little-endian, par
  exemple `0xc0c62d0000000000 0x40420f0000000000`). Si l'opcode était ajouté à Bitcoin dans un soft
  fork, cela faciliterait grandement pour les contrats la vérification que les montants des entrées et
  des sorties sont dans la plage attendue par le contrat, par exemple, qu'un utilisateur n'a retiré
  d'un [joinpool][topic joinpools] que le montant auquel il avait droit.

- **Amélioration du processus de création de ASMap reproductible :** Fabian Jahr a [publié][jahr
  asmap] sur Delving Bitcoin concernant les avancées dans la création d'une carte des [systèmes
  autonomes][] (ASMap) qui contrôlent chacun le routage pour de grandes parties de l'internet. Bitcoin
  Core essaie actuellement de maintenir des connexions avec des pairs provenant d'une collection
  diversifiée de sous-réseaux de l'espace de noms global afin de compliquer la tâche des attaquants qui, dès lors,
  doivent obtenir des adresses IP sur chaque sous-réseau pour réaliser le type le plus simple d'[attaque par
  éclipse][topic eclipse attacks] contre un nœud. Cependant, certains FAI et services d'hébergement
  contrôlent des adresses IP sur plusieurs sous-réseaux, affaiblissant cette protection. Le projet
  ASMap vise à fournir des informations approximatives sur quels FAI contrôlent quelles adresses IP
  directement à Bitcoin Core (voir les bulletins [#52][news52 asmap] et [#83][news83 asmap]). Un défi
  majeur auquel ce projet est confronté est de permettre à plusieurs contributeurs de créer une carte
  de manière reproductible, permettant une vérification indépendante que son contenu était précis au
  moment de sa création.

  Dans le post de cette semaine, Jahr décrit les outils et techniques qui ont permis de découvrir "qu'il y
  a de bonnes chances que dans un groupe de 5 ou plus, la majorité des participants auront le même
  résultat. [...] Ce processus peut être initié par n'importe qui, très similaire à un PR Core. Les
  participants qui ont un résultat correspondant pourraient être interprétés comme des ACKs. Si
  quelqu'un voit quelque chose d'étrange dans le résultat ou s'il n'a tout simplement pas obtenu de
  correspondance, il peut demander que les données brutes soient partagées pour enquêter
  davantage."

  Si le processus est finalement jugé acceptable (peut-être avec des raffinements supplémentaires), il
  est possible que les futures versions de Bitcoin Core puissent être livrées avec des ASMaps et la
  fonctionnalité activée par défaut, améliorant la résistance aux attaques par éclipse.

## Modifications apportées aux services et aux logiciels clients

*Dans cette rubrique mensuelle, nous mettons en évidence les mises à jour
intéressantes des portefeuilles et services Bitcoin.*

- **Annonce du protocole de coordination multipartie NWC :**
  [Nostr Wallet Connect (NWC)][nwc blog] est un protocole de coordination pour faciliter les
  communications dans des cas d'utilisation interactifs impliquant plusieurs parties. Bien que
  l'accent initial de NWC soit mis sur Lightning, des protocoles interactifs comme [joinpools][topic
  joinpools], [Ark][topic ark], [DLCs][topic dlc], ou les schémas de [multisignature][topic
  multisignature] pourraient éventuellement bénéficier de ce protocole.

- **Mutiny Wallet v0.5.7 publié :**
  La version [Mutiny Wallet][mutiny github] ajoute le support de [payjoin][topic payjoin]
  et améliore les fonctionnalités NWC et LSP.

- **Service de regroupement de transactions GroupHug :**
  [GroupHug][grouphug github] est un service de [regroupement][scaling payment batching] utilisant les
  [PSBT][topic psbt], avec des [limitations][grouphug blog].

- **Boltz annonce les échanges taproot :**
  L'échange non-custodial Boltz a [annoncé][boltz blog] une mise à niveau
  de leur protocole d'échange atomique pour utiliser [taproot][topic
  taproot], [signatures schnorr][topic schnorr signatures], et [MuSig2][topic musig].

## Mises à jour et versions candidates

*Nouvelles versions et versions candidates pour les principaux projets
d'infrastructure Bitcoin. Veuillez envisager de passer aux nouvelles
versions ou d'aider à tester les versions candidates.*

- [Core Lightning 24.02rc1][] est un candidat à la sortie pour la prochaine version majeure de ce
  nœud LN populaire.

## Changements notables dans le code et la documentation

_Changements notables cette semaine dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning
repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Interface de Portefeuille Matériel (HWI)][hwi
repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Propositions d'Amélioration de Bitcoin (BIPs)][bips
repo], [Lightning BOLTs][bolts repo],
[Inquisition Bitcoin][bitcoin inquisition repo], et [BINANAs][binana repo]._

- [Bitcoin Core #27877][] met à jour le portefeuille de Bitcoin Core avec une nouvelle stratégie de
  [sélection de pièces][topic coin selection], CoinGrinder (voir le
  [Bulletin #283][news283 coingrinder]). Cette stratégie est destinée à
  être utilisée lorsque les taux de frais estimés sont élevés par rapport à leur base de long terme,
  permettant au portefeuille de créer des transactions plus légères tout de suite (avec
  la conséquence qu'il pourrait avoir besoin de créer des transactions plus lourdes à un
  moment ultérieur, en espérant que le taux de frais soit plus bas).

- [BOLTs #851][] ajoute le support pour le [double financement][topic dual funding] à
  la spécification LN ainsi que le support pour le protocole de construction de transaction
  interactive. La construction interactive permet
  à deux nœuds d'échanger des préférences et des détails UTXO qui leur permettent de
  construire une transaction de financement ensemble. Le financement double permet à une
  transaction d'inclure des entrées de l'une ou des deux parties. Par exemple, Alice peut vouloir
  ouvrir un canal avec Bob. Avant ce
  changement de spécification, Alice devait fournir tout le financement pour le
  canal. Maintenant, en utilisant une implémentation qui supporte le financement dual, Alice peut
  ouvrir un canal avec Bob dont il fournit tout le
  financement ou pour lequel chacun contribue. Cela peut être combiné
  avec le [protocole expérimental d'annonces de liquidité][topic liquidity advertisements], qui n'a
  pas encore été ajouté à la spécification.

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 15:00" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="1551,27877,851" %}
[news283 coingrinder]: /fr/newsletters/2024/01/03/#nouvelles-strategies-de-selection-de-pieces
[news52 asmap]: /en/newsletters/2019/06/26/#differentiating-peers-based-on-asn-instead-of-address-prefix
[news83 asmap]: /en/newsletters/2020/02/05/#bitcoin-core-16702
[jahr asmap]: https://delvingbitcoin.org/t/asmap-creation-process/548
[systèmes autonomes]: https://en.wikipedia.org/wiki/Autonomous_system_(Internet)
[daftuar feerate rule]: https://delvingbitcoin.org/t/mempool-incentive-compatibility/553#feerate-rule-9
[news288 rbfr]: /fr/newsletters/2024/02/07/#proposition-de-remplacement-par-feerate-pour-echapper-au-pinning
[daftuar incompatible]: https://delvingbitcoin.org/t/mempool-incentive-compatibility/553#using-feerate-diagrams-as-an-rbf-policy-tool-13
[daftuar incentive]: https://delvingbitcoin.org/t/mempool-incentive-compatibility/553
[news285 64bit]: /fr/newsletters/2024/01/17/#proposition-de-soft-fork-pour-l-arithmetique-sur-64-bits
[dnssec]: https://en.wikipedia.org/wiki/Domain_Name_System_Security_Extensions
[corallo dns]: https://delvingbitcoin.org/t/human-readable-bitcoin-payment-instructions/542/
[dns bip]: https://github.com/TheBlueMatt/bips/blob/d46a29ff4b4ac27210bc81474ae18e4802141324/bip-XXXX.mediawiki
[dns bolt]: https://github.com/lightning/bolts/pull/1136
[dns blip]: https://github.com/lightning/blips/pull/32
[dnssec-prover]: https://github.com/TheBlueMatt/dnssec-prover
[dns demo]: http://http-dns-prover.as397444.net/
[news278 dns]: /fr/newsletters/2023/11/22/#adresses-ln-compatibles-avec-les-offres
[news166 tluv]: /en/newsletters/2021/09/15/#amount-introspection
[64bit discuss]: https://delvingbitcoin.org/t/64-bit-arithmetic-soft-fork/397
[stewart inout]: https://delvingbitcoin.org/t/op-inout-amount/549
[thunderbiscuit ecash]: https://delvingbitcoin.org/t/building-intuition-for-the-cashu-blind-signature-scheme/506
[schéma de signature aveugle]: https://en.wikipedia.org/wiki/Blind_signature
[chaumian ecash]: https://en.wikipedia.org/wiki/Ecash
[openalias]: https://openalias.org/
[cashu]: https://github.com/cashubtc/nuts
[bip inout]: https://github.com/Christewart/bips/blob/92c108136a0400b3a2fd66ea6c291ec317ee4a01/bip-op-inout-amount.mediawiki
[mempool series]: /fr/blog/waiting-for-confirmation/
[Core Lightning 24.02rc1]: https://github.com/ElementsProject/lightning/releases/tag/v24.02rc1
[nwc blog]: https://blog.getalby.com/scaling-bitcoin-apps/
[mutiny github]: https://github.com/MutinyWallet/mutiny-web
[grouphug blog]: https://peachbitcoin.com/blog/group-hug/
[grouphug github]: https://github.com/Peach2Peach/groupHug
[boltz blog]: https://blog.boltz.exchange/p/introducing-taproot-swaps-putting
