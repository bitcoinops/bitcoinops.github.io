---
title: 'Bulletin Hebdomadaire Bitcoin Optech #244'
permalink: /fr/newsletters/2023/03/29/
name: 2023-03-29-newsletter-fr
slug: 2023-03-29-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine décrit une proposition visant à améliorer
l'efficacité du capital sur LN en utilisant des pénalités accordables.
Vous y trouverez également nos sections habituelles avec des résumés des
principales questions et réponses du Bitcoin Stack Exchange, des annonces
de nouvelles versions et de versions candidates, et des descriptions des
principaux changements apportés aux logiciels d'infrastructure Bitcoin
les plus répandus.

{% assign S0 = "_S<sub>0</sub>_" %}
{% assign S1 = "_S<sub>1</sub>_" %}

## Nouvelles

- **Prévenir les pertes de capitaux grâce aux usines à canaux et aux canaux multipartites :**
  John Law a [posté][law stranded post] sur la liste de diffusion Lightning-Dev
  le résumé d'un [article][law stranded paper] qu'il a écrit. Il décrit comment
  les nœuds toujours disponibles peuvent continuer à utiliser leurs fonds pour
  transmettre des paiements même lorsqu'ils partagent un canal avec un nœud
  actuellement indisponible (comme l'utilisateur d'un portefeuille LN mobile).
  Cela nécessite l'utilisation de canaux multipartites, qui se combinent bien
  avec une conception d'usines à canaux qu'il a décrite précédemment. Il réaffirme
  également un avantage connu des [usines à canaux][topic channel factories],
  à savoir la possibilité de rééquilibrer les canaux hors chaîne, ce qui peut
  également permettre une meilleure utilisation du capital. Il décrit comment
  utiliser ces deux avantages dans le contexte de son innovation précédente,
  la couche de _pénalité réglable_ pour LN. Nous résumerons les pénalités
  ajustables, montrerons comment elles peuvent être utilisées pour les canaux
  multipartites et les usines à canaux, puis nous expliquerons les nouveaux
  résultats de Law dans leur contexte.

    Alice et Bob créent (mais ne signent pas immédiatement) une transaction
    qui dépense 50 millions de sats pour chacun d'entre eux (100 millions au
    total) vers une _sortie de financement_ qui nécessitera la coopération de
    chacun d'entre eux pour être dépensée. Dans les schémas ci-dessous, les
    transactions confirmées sont représentées en grisé.

    {:.center}
    ![Alice and Bob create the funding transaction](/img/posts/2023-03-tunable-funding.dot.png)

    Ils utilisent également chacun une sortie différente qu'ils contrôlent
    individuellement pour créer (mais pas diffuser) deux _transactions d'état_,
    une pour chacun d'entre eux. La première sortie de chaque transaction
    d'état paie un montant négligeable (disons 1 000 sat) en tant qu'entrée
    d'une _transaction d'engagement_ hors chaîne verrouillée dans le temps.
    Le blocage temporel relatif empêche chaque transaction d'engagement d'être
    éligible pour une confirmation sur la chaîne jusqu'à un certain temps
    après que sa transaction d'état parente ait été confirmée sur la chaîne.
    Chacune des deux transactions d'engagement est également financée par
    des dépenses conflictuelles de la sortie de financement (ce qui signifie
    qu'une seule des transactions d'engagement peut finalement être confirmée).
    Une fois toutes les transactions enfants créées, la transaction qui crée
    la sortie de financement peut être signée et diffusée.

    {:.center}
    ![Alice and Bob create their commitment transactions](/img/posts/2023-03-tunable-commitment.dot.png)

    Chacune des transactions d'engagement paie l'état actuel du canal.
    Pour l'état initial ({{S0}}), 50 millions de sats sont remboursés à
    Alice et à Bob (par souci de simplicité, nous ignorons les frais de
    transaction). Alice ou Bob peuvent entamer le processus de fermeture
    unilatérale du canal en publiant leur version de la transaction d'état;
    après le délai imposé, ils peuvent alors publier la transaction
    d'engagement correspondante. Par exemple, Alice publie sa transaction
    d'état et sa transaction d'engagement (qui la paie ainsi que Bob);
    à ce moment-là, Bob peut simplement ne jamais dépenser sa transaction
    d'état et dépenser l'argent utilisé pour la créer à n'importe quel
    moment ultérieur, comme il le souhaite.

    {:.center}
    ![Alice spends honestly from the channel](/img/posts/2023-03-tunable-honest-spend.dot.png)

    Il existe deux autres solutions que la fermeture unilatérale du canal
    dans son état initial. Tout d'abord, Alice et Bob peuvent coopérer pour
    fermer le canal à tout moment en dépensant la sortie de la transaction
    de financement (comme cela se fait dans le protocole LN actuel).
    Deuxièmement, ils peuvent mettre à jour l'état---par exemple, en
    augmentant le solde d'Alice de 10 millions de dollars et en diminuant
    le solde de Bob du même montant. L'état {{S1}} ressemble à l'état initial
    ({{S0}}), mais pour le mettre en œuvre, l'état précédent est révoqué par
    chaque partie qui donne à l'autre un témoin[^chaîne de clés] pour dépenser
    la première sortie de leurs transactions d'état respectives pour l'état
    précédent ({{S0}}). Aucune des parties ne peut utiliser le témoin de
    l'autre car les transactions d'état {{S0}} ne contiennent pas encore
    de témoins et ne peuvent donc pas être diffusées.

    Avec plusieurs états disponibles, il est possible de fermer accidentellement
    ou délibérément le canal dans un état obsolète. Par exemple, Bob peut essayer
    de fermer la chaîne dans l'état {{S0}} où il dispose de 10 millions de satoshis
    supplémentaires. Pour ce faire, Bob signe et diffuse sa transaction d'état
    pour {{S0}}. Bob ne peut pas prendre d'autres mesures immédiatement en raison
    du blocage temporel de la transaction d'engagement. Pendant l'attente,
    Alice détecte cette tentative de diffusion d'un état périmé et utilise le
    témoin qu'il lui a précédemment donné pour dépenser la première sortie de
    sa transaction d'état, en payant une partie ou la totalité du montant de
    la pénalité en frais de transaction. Comme cette sortie est la même que
    celle dont Bob a besoin pour diffuser plus tard la transaction d'engagement
    qui lui rapporte les 10 millions de sat supplémentaires, il sera empêché
    de réclamer ces fonds si la transaction créée par Alice est confirmée.
    Lorsque Bob est bloqué, Alice est la seule à pouvoir publier unilatéralement
    le dernier état de la chaîne ; Alice et Bob peuvent également procéder à tout
    moment à une fermeture de canal coopérative.

    {:.center}
    ![Bob attempts to spend dishonestly from the channel but is blocked by Alice](/img/posts/2023-03-tunable-dishonest-spend.dot.png)

    Si Bob remarque qu'Alice tente de dépenser à partir de sa transaction
    d'état obsolète, il peut tenter d'entrer dans une guerre d'enchères Replace
    By Fee (RBF) avec Alice, mais c'est un cas où le montant de la pénalité
    _ajustable_ est particulièrement puissant : le montant de la pénalité peut
    être insignifiant (par exemple 1K sats, comme dans notre exemple) ou il
    peut être égal au montant en jeu (10M sats) ou il peut même être plus
    grand que la valeur totale de la chaîne. La décision est entièrement
    du ressort d'Alice et de Bob, qui doivent négocier entre eux lors de
    la mise à jour de l'état du canal.

    L'un des autres avantages du Tunable-Penalty Protocol (TPP) est que le
    montant de la pénalité est entièrement payé par l'utilisateur qui place
    sa transaction d'état obsolète sur la chaîne. Il n'utilise aucun des
    bitcoins de la transaction de financement partagée. Cela permet à plus
    de deux utilisateurs de partager en toute sécurité un canal TPP ; par
    exemple, nous pouvons imaginer qu'Alice, Bob, Carol et Dan partagent
    tous un canal. Chacun d'entre eux a sa propre transaction d'engagement
    financée par sa propre transaction d'état :

    {:.center}
    ![A channel between Alice, Bob, Carol, and Dan](/img/posts/2023-03-tunable-multiparty.dot.png)

    Ils peuvent opérer comme un canal multipartite, en exigeant que chaque
    état soit révoqué par chaque partie. Ils peuvent également utiliser la
    transaction de financement conjoint comme une usine à canaux, créant
    ainsi de multiples canaux entre des paires ou des multiples d'utilisateurs.
    Avant que Law ne décrive cette implication du PPT l'année dernière (voir
    [Bulletin #230][news230 tp]), on pensait que la mise en œuvre pratique
    des usines à canaux sur Bitcoin nécessiterait un mécanisme comme [eltoo][topic eltoo],
    qui requiert un changement de consensus comme [SIGHASH_ANYPREVOUT][topic
    sighash_anyprevout]. Le PPT ne nécessite pas de changement de consensus.
    Pour que le diagramme ci-dessous reste simple, nous n'avons illustré qu'un
    seul canal créé dans une usine à quatre participants ; le nombre d'états
    que les participants au canal doivent gérer est égal au nombre de participants
    à l'usine, bien que Law ait également [précédemment décrit][law factories]
    une construction alternative avec un seul état mais un coût plus élevé pour
    fermer unilatéralement.

    {:.center}
    ![A channel between Alice and Bob created from a factory by Alice, Bob, Carol, and Dan](/img/posts/2023-03-tunable-factory.dot.png)

    Un avantage des usines à canaux décrit dans son [article original][channel
    factories paper] est que les parties au sein de l'usine peuvent rééquilibrer
    leurs canaux de manière coopérative sans créer de transactions sur la chaîne.
    Par exemple, si l'usine est composée d'Alice, Bob, Carol et Dan, la valeur
    totale du canal entre Alice et Bob peut être diminuée et la valeur du canal
    entre Carol et Dan peut être augmentée du même montant en mettant à jour
    l'état de l'usine hors chaîne. Les usines de Law basées sur le TPP offrent
    le même avantage.

    Cette semaine, Law a noté que les usines à canaux ayant la capacité de fournir
    des canaux multipartites (ce qui est possible avec TPP) ont un avantage
    supplémentaire : permettre l'utilisation du capital même lorsque l'un des
    participants au canal est hors ligne. Imaginons par exemple qu'Alice et Bob
    disposent de nœuds LN dédiés qui sont presque toujours disponibles pour
    transférer des paiements, mais que Carol et Dan sont des utilisateurs
    occasionnels dont les nœuds sont souvent indisponibles. Dans une usine à
    canaux de type original, Alice dispose d'un canal avec Carol ({A,C}) et
    d'un canal avec Dan ({A,D}). Elle ne peut utiliser aucun de ses fonds dans
    ces canaux lorsque Carol et Dan sont indisponibles. Bob a le même problème
    ({B,C} et {B,D}).

    Dans une usine à canaux basée sur le TPP, Alice, Bob et Carol peuvent ouvrir
    ensemble un canal multipartite, nécessitant leur coopération à tous les trois
    pour mettre à jour son état. L'un des résultats d'une transaction d'engagement
    dans ce canal permet de payer Carole, mais l'autre résultat ne peut être dépensé
    que si Alice et Bob coopèrent. Lorsque Carole n'est pas disponible, Alice et Bob
    peuvent coopérer pour modifier la répartition de l'équilibre de leur production
    commune hors chaîne, ce qui leur permet d'effectuer ou de transmettre des paiements
    LN s'ils disposent d'autres canaux LN. Si Alice reste indisponible trop longtemps,
    l'un ou l'autre peut unilatéralement mettre le canal sur la chaîne. Les mêmes
    avantages s'appliquent si Alice et Bob partagent un canal avec Dan.

    Alice et Bob peuvent ainsi continuer à percevoir des frais de transfert même
    lorsque Carol et Dan ne sont pas disponibles, ce qui évite à ces canaux de
    paraître improductifs. La possibilité de rééquilibrer les canaux hors chaîne
    (sans frais sur la chaîne) peut également diminuer les inconvénients pour Alice
    et Bob de conserver leurs fonds dans une usine à canaux pendant une période
    plus longue. L'ensemble de ces avantages peut réduire le nombre de transactions
    onchain, augmenter la capacité de paiement totale du réseau Bitcoin et réduire
    le coût de transmission des paiements sur le réseau LN.

    À l'heure où nous écrivons ces lignes, les pénalités ajustables et les diverses
    propositions de Law pour les utiliser n'ont pas fait l'objet d'un grand débat public.

## Selection de Q&R du Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] est l'un des premiers endroits
où les collaborateurs d'Optech cherchent des réponses à leurs questions---ou
lorsque nous avons quelques moments libres pour aider les utilisateurs
curieux ou confus. Dans cette rubrique mensuelle, nous mettons en avant
certaines des questions et réponses les plus votées depuis notre dernière mise à jour.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Pourquoi le déploiement de taproot n'est-il pas intégré à Bitcoin Core ?]({{bse}}117569)
  Andrew Chow explique la raison pour laquelle l'embranchement convergent de Taproot
  n'est pas [enterré][BIP90] comme [d'autres l'ont fait][bitcoin buried deployments].

- [Quelles sont les restrictions applicables au champ "version" de l'en-tête du bloc ?]({{bse}}117530)
  Murch note une augmentation des [blocs][explorer block 779960] extraits
  à l'aide de [overt ASICBoost][topic ASICBoost], énumère les restrictions
  sur le champ de version et présente des exemples de [champs de version
  d'en-tête de bloc][FCAT block header blog].


- [Quelle est la relation entre les données de transaction et les identifiants ?]({{bse}}117453)
  Pieter Wuille explique l'ancien format de sérialisation des transactions
  couvert par l'identifiant `txid`, le format de sérialisation étendu des
  témoins couvert par les identifiants `hash` et `wtxid`, et souligne dans
  une [réponse séparée][se117577] que d'hypothétiques données de transaction
  supplémentaires seraient couvertes par l'identifiant `hash`.

- [Puis-je demander des messages tx à d'autres pairs ?]({{bse}}117546)
  L'utilisateur RedGrittyBrick indique des ressources expliquant
  les raisons pour lesquelles la [performance][wiki getdata] et la
  [confidentialité][Bitcoin Core #18861] des demandes arbitraires
  de transactions de la part des pairs ne sont pas prises en charge
  par la couche P2P de Bitcoin Core.

- [Eltoo : Le temps de verrouillage relatif du premier UTXO détermine-t-il la durée de vie du canal ?]({{bse}}117468)
  Murch confirme que le canal LN [eltoo][topic eltoo] construit dans
  l'exemple  de la question a une durée de vie limitée, mais indique
  que des mesures d'atténuation du [livre blanc eltoo][] permettent
  d'éviter que les délais n'expirent.

## Mises à jour et versions candidates

*Nouvelles versions et versions candidates pour les principaux projets d’infrastructure
Bitcoin. Veuillez envisager de passer aux nouvelles versions ou d’aider à tester
les versions candidates.*

- [Rust Bitcoin 0.30.0][] est la dernière version de cette bibliothèque
  permettant d'utiliser les structures de données liées à Bitcoin.
  Les [notes de version][rb rn] mentionnent un [nouveau site web][rust-bitcoin.org]
  et un grand nombre de changements dans l'API.

- [LND v0.16.0-beta.rc5][] est une version candidate pour une nouvelle
  version majeure de cette implémentation populaire de LN.

- [BDK 1.0.0-alpha.0][] est une version de test des principaux changements
  apportés au BDK et décrits dans [le bulletin de la semaine dernière][news243 bdk].
  Les développeurs de projets en aval sont encouragés à commencer
  les tests d'intégration.

## Changements notables dans le code et la documentation

*Changements notables cette semaine dans [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo], et
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [Bitcoin Core #27278][] commence à enregistrer par défaut lorsqu'un
  en-tête pour un nouveau bloc est reçu, sauf si le nœud est en
  téléchargement de bloc initial (IBD).  Cette mesure a été [inspirée][obeirne
  selfish] par plusieurs opérateurs de nœuds qui ont remarqué que trois
  blocs étaient arrivés très près l'un de l'autre, les deux derniers
  ayant réorganisé le premier bloc de la meilleure chaîne de blocs.
  Pour plus de clarté, nous appellerons le premier bloc _A_, le bloc
  qui l'a remplacé _A'_ et le bloc final _B_.

  Cela pourrait indiquer que les blocs A' et B ont été créés par le
  même mineur qui a délibérément retardé leur diffusion jusqu'à ce
  qu'ils entraînent le blocage d'un autre mineur, privant ainsi ce
  dernier de la récompense qu'il aurait normalement reçue du bloc A---une
  attaque connue sous le nom d'"exploitation égoïste". Il peut également
  s'agir d'une coïncidence ou d'un minage égoïste accidentel. Cependant,
  une possibilité [soulevée][sanders requests] par les développeurs au
  cours de l'enquête était que les délais n'étaient peut-être pas aussi
  proches qu'ils ne le semblaient---il est possible que Bitcoin Core
  n'ait pas demandé A' avant que B ne soit reçu, puisque A' en lui-même
  n'était pas suffisant pour déclencher une réorganisation.

  L'enregistrement du moment où les en-têtes sont reçus signifie que,
  si la situation devait se répéter à l'avenir, les opérateurs de nœuds
  seraient en mesure de déterminer quand leur nœud a appris l'existence
  de A', même s'il n'a pas choisi de le télécharger immédiatement. Cette
  journalisation peut ajouter jusqu'à deux nouvelles lignes par bloc (bien
  que les futurs PR puissent la réduire à une seule ligne), ce qui a été
  considéré comme une surcharge supplémentaire suffisamment faible pour
  aider à détecter les attaques d'extraction égoïstes et d'autres problèmes
  associés au relais de blocs critiques.

- [Bitcoin Core #26531][] ajoute des tracepoints pour surveiller les
  événements affectant le mempool en utilisant l'Extended Berkeley Packet
  Filter (eBPF) tel qu'implémenté dans les PR précédents (voir [Bulletin
  #133][news133 usdt]). Un script est également ajouté pour utiliser les
  tracepoints afin de surveiller les statistiques et l'activité du mempool
  en temps réel.

- [Core Lightning #5898][] met à jour sa dépendance sur [libwally][] vers
  une version plus récente (voir [Bulletin #238][news238 libwally]), ce qui
  permet d'ajouter le support de [taproot][topic taproot], la version 2 de
  [PSBT][topic psbt] (voir [Bulletin #128][news128 psbt2]), et affecte le
  support de LN sur les sidechains de style Elements.

- [Core Lightning #5986][] met à jour les RPC qui renvoient des valeurs
  en msats pour ne plus inclure la chaîne "msat" dans le résultat. Au lieu
  de cela, toutes les valeurs retournées sont des entiers. Ceci complète
  une dépréciation commencée il y a plusieurs versions, voir [Bulletin
  #206][news206 msat].

- [Eclair #2616][] ajoute le support des [canaux zéro-conf][topic zero-conf channels]
  opportunistes---si le pair distant envoie le message `channel_ready` avant
  le nombre attendu de confirmations, Eclair vérifiera que la transaction de
  financement a été entièrement créée par le nœud local (afin que le pair
  distant ne puisse pas faire confirmer une transaction conflictuelle) et
  autorisera alors l'utilisation du canal.

- [LDK #2024][] commence à inclure des indications d'itinéraire pour les
  canaux qui ont été ouverts mais qui sont trop immatures pour avoir été
  annoncés publiquement, comme les [canaux zéro-conf][topic zero-conf channels].

- [Rust Bitcoin #1737][] ajoute une [politique de rapport de sécurité][rb sec] pour le projet.

- [BTCPay Server #4608][] permet aux plugins d'exposer leurs fonctionnalités
  en tant qu'application dans l'interface utilisateur de BTCPay.

- [BIPs #1425][] assigne [BIP93][] au schéma codex32 pour encoder
  les graines de récupération [BIP32][] en utilisant l'algorithme SSSS
  (Shamir's Secret Sharing Scheme), une somme de contrôle et un alphabet
  de 32 caractères comme décrit dans le [Bulletin #239][news239 codex32].

- [Bitcoin Inquisition #22][] ajoute une option d'exécution `-annexcarrier`
  qui permet de pousser de 0 à 126 octets de données dans le champ annexe
  de l'entrée taproot. L'auteur du PR prévoit d'utiliser cette fonctionnalité
  pour permettre aux gens de commencer à expérimenter sur signet avec [eltoo][topic
  eltoo] en utilisant un fork de Core Lightning.

## Notes de bas de page

[^keychain]:
    Il n'est pas important pour cette vue d'ensemble de décrire ce qu'est
    le témoin, mais certains des avantages proposés dépendent des détails.
    La description originale du protocole [Tunable Penalties][] suggère de
    divulguer la clé privée utilisée pour générer la signature pour les
    dépenses de la transaction d'engagement. Il est possible de générer
    des clés privées dans une séquence où quiconque connaît une clé peut
    également dériver n'importe quelle clé ultérieure (mais pas la clé
    précédente). Cela signifie que chaque fois qu'Alice révoque un état
    ultérieur, elle peut donner à Bob une clé antérieure que Bob peut
    utiliser pour dériver n'importe quelle clé ultérieure (pour un état
    antérieur). Par exemple,

      | Channel state | Key state |
      | 0     | MAX |
      | 1     | MAX - 1 |
      | 2     | MAX - 2 |
      | x     | MAX - x |
      | MAX   | 0 |

    Cela permet à Bob de stocker toutes les informations dont il a besoin
    pour dépenser à partir d'une transaction d'état périmée dans un espace
    constant très réduit (moins de 100 octets d'après nos calculs<!---point
    de sortie du vin de la tx d'engagement @<=34 octets, clé privée @32
    octets, index de référence @<=4 octets -->). L'information peut également
    être facilement partagée avec une [tour de garde][topic watchtowers]
    (qui n'a pas besoin d'être fiable, car toute dépense réussie d'une
    transaction d'état périmée empêchera une transaction d'engagement
    périmée d'être publiée sur la chaîne. Étant donné que les fonds
    impliqués dans cette transaction d'état obsolète appartiennent
    entièrement à la partie qui est en violation du protocole, il n'y
    a aucun risque de sécurité à externaliser les informations sur les
    dépenses à partir de cette transaction).

{% include references.md %}
{% include linkers/issues.md v=2 issues="27278,26531,5898,5986,2616,2024,1737,4608,1425,22,18861" %}
[lnd v0.16.0-beta.rc5]: https://github.com/lightningnetwork/lnd/releases/tag/v0.16.0-beta.rc5
[bdk 1.0.0-alpha.0]: https://github.com/bitcoindevkit/bdk/releases/tag/v1.0.0-alpha.0
[rust bitcoin 0.30.0]: https://github.com/rust-bitcoin/rust-bitcoin/releases/tag/bitcoin-0.30.0
[news230 tp]: /en/newsletters/2022/12/14/#factory-optimized-ln-protocol-proposal
[channel factories paper]: https://tik-old.ee.ethz.ch/file//a20a865ce40d40c8f942cf206a7cba96/Scalable_Funding_Of_Blockchain_Micropayment_Networks%20(1).pdf
[law factories]: https://raw.githubusercontent.com/JohnLaw2/ln-efficient-factories/main/efficientfactories10.pdf
[news206 msat]: /en/newsletters/2022/06/29/#core-lightning-5306
[rb sec]: https://github.com/rust-bitcoin/rust-bitcoin/blob/master/SECURITY.md
[news239 codex32]: /en/newsletters/2023/02/22/#proposed-bip-for-codex32-seed-encoding-scheme
[law stranded post]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-March/003886.html
[law stranded paper]: https://github.com/JohnLaw2/ln-hierarchical-channels
[obeirne selfish]: https://twitter.com/jamesob/status/1637198454899220485
[sanders requests]: https://twitter.com/theinstagibbs/status/1637235436849442817
[news133 usdt]: /en/newsletters/2021/01/27/#bitcoin-core-19866
[libwally]: https://github.com/ElementsProject/libwally-core
[news128 psbt2]: /en/newsletters/2020/12/16/#new-psbt-version-proposed
[tunable penalties]: https://github.com/JohnLaw2/ln-tunable-penalties
[news238 libwally]: /en/newsletters/2023/02/15/#libwally-0-8-8-released
[rust-bitcoin.org]: https://rust-bitcoin.org/
[rb rn]: https://github.com/harding/rust-bitcoin/blob/bbda9599fa32936f31472620d014893fda17d8c3/bitcoin/CHANGELOG.md#030---2023-03-21-the-first-crate-smashing-release
[news243 bdk]: /en/newsletters/2023/03/22/#bdk-793
[bitcoin buried deployments]: https://github.com/bitcoin/bitcoin/blob/master/src/consensus/params.h#L19
[explorer block 779960]: https://blockstream.info/block/00000000000000000003a337a676b0101f3f7ef7dcbc01debb69f85c6da04dcf?expand
[FCAT block header blog]: https://medium.com/fcats-blockchain-incubator/understanding-the-bitcoin-blockchain-header-a2b0db06b515#b9ba
[se117577]: https://bitcoin.stackexchange.com/a/117577/87121
[wiki getdata]: https://en.bitcoin.it/wiki/Protocol_documentation#getdata
[livre blanc eltoo]: https://blockstream.com/eltoo.pdf#page=15
