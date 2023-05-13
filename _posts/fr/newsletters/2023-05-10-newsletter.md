---
title: 'Bulletin Hebdomadaire Bitcoin Optech #250'
permalink: /fr/newsletters/2023/05/10/
name: 2023-05-10-newsletter-fr
slug: 2023-05-10-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine résume un article sur le protocole PoWswap
et comprend nos sections habituelles avec le résumé d'une réunion du Bitcoin
Core PR Review Club, des annonces de nouvelles versions et de versions
candidates, et des descriptions des principaux changements apportés aux
logiciels d'infrastructure Bitcoin les plus répandus. Nous avons également
inclus une courte section célébrant les cinq ans de Bitcoin Optech et
notre 250e bulletin.

## Nouvelles

- **Article sur le protocole PoWswap :** Thomas Hartman a [posté][hartman
  powswap] sur la liste de diffusion Bitcoin-Dev un [article][hnr powswap]
  qu'il a écrit avec Gleb Naumenko et Antoine Riard sur le protocole [PoWSwap][]
  proposé pour la première fois par Jeremy Rubin.  Powswap permet la création
  de contrats exécutoires sur la chaîne liés au changement du taux de hachage.
  L'idée de base tire parti de la relation entre le temps et la production de
  blocs, renforcée par le protocole, ainsi que de la possibilité d'exprimer
  les blocages temporels en temps ou en blocs.  Prenons l'exemple du script
  suivant :

  ```
  OP_IF
    <Alice's key> OP_CHECKSIGVERIFY <time> OP_CHECKLOCKTIMEVERIFY
  OP_ELSE
    <Bob's key> OP_CHECKSIGVERIFY <height> OP_CHECKLOCKTIMEVERIFY
  OP_ENDIF
  ```

  Imaginons que l'heure actuelle soit _t_ et que la hauteur de bloc actuelle
  soit _x_. Si les blocs sont produits en moyenne à 10 minutes d'intervalle,
  alors si nous fixons `<time>` à _t + 1000 minutes_ et `<height>` à _x + 50_,
    nous nous attendons à ce que Bob puisse passer la sortie contrôlée par le
    script ci-dessus en moyenne 500 minutes avant qu'Alice puisse le dépenser.
    Cependant, si le taux de production de blocs devait soudainement plus que
    doubler, Alice pourrait être en mesure de dépenser la production avant Bob.

  Plusieurs applications sont envisagées pour ce type de contrat :

  - *Assurance contre l'augmentation du hashrate :* les mineurs doivent acheter
    leur équipement avant de connaître avec certitude le montant des revenus
    qu'il générera. Par exemple, un mineur qui achète suffisamment d'équipement
    pour recevoir 1 % du total actuel des récompenses du réseau peut être surpris
    de constater que d'autres mineurs ont également acheté suffisamment
    d'équipement pour doubler le hashrate total du réseau, laissant le mineur
    avec 0,5 % de la récompense au lieu de 1 %.  Avec PoWSwap, le mineur peut
    conclure un contrat sans confiance avec quelqu'un qui est prêt à le payer
    si le hashrate augmente avant une certaine date, compensant ainsi la baisse
    inattendue des revenus du mineur. En échange, le mineur verse à cette
    personne une prime initiale ou accepte de lui verser un montant plus élevé
    si le hashrate à l'échelle du réseau reste inchangé ou diminue.

  - *Assurance contre la baisse du hashrate :* une grande variété de problèmes
    liés à Bitcoin entraînerait une diminution significative du taux de hachage
    à l'échelle du réseau. Le hashrate diminuerait si des mineurs étaient fermés
    par des parties puissantes, ou si une quantité importante de [fee sniping][topic fee sniping]
    commençait à se produire soudainement parmi les mineurs établis, ou si la
    valeur des BTC pour les mineurs diminuait soudainement. Les détenteurs de
    BTC qui souhaitent s'assurer contre de telles situations peuvent conclure
    des contrats sans confiance avec des mineurs ou des tiers.

  - *Contrats de taux de change :* en général, si le pouvoir d'achat des BTC
    augmente, les mineurs sont prêts à augmenter la quantité de hashrate qu'ils
    fournissent (pour augmenter les récompenses qu'ils reçoivent). Si le pouvoir
    d'achat diminue, le hashrate diminue. De nombreuses personnes peuvent être
    intéressées par des contrats sans confiance liés au futur pouvoir d'achat
    du bitcoin.

  Bien que l'idée de PoWSwap circule depuis plusieurs années, le document fournit
  plus de détails et d'analyses que nous n'en avions vus jusqu'à présent.

## Mises à jour et versions candidates

*Nouvelles versions et versions candidates pour les principaux projets
d'infrastructure Bitcoin. Veuillez envisager de passer aux nouvelles
versions ou d'aider à tester les versions candidates.*

- [Core Lightning 23.05rc2][] est une version candidate de la prochaine
  version de l'implémentation du LN.

- [Bitcoin Core 24.1rc2][] est une version candidate pour une version
  de maintenance de la version actuelle de Bitcoin Core.

- [Bitcoin Core 25.0rc1][] est une version candidate de la prochaine
  version majeure de Bitcoin Core.

## Bitcoin Core PR Review Club

*Dans cette section mensuelle, nous résumons une récente réunion du
[Bitcoin Core PR Review Club][] en soulignant certaines des questions
et réponses importantes. Cliquez sur une question ci-dessous pour voir
un résumé de la réponse de la réunion.*

[Ajout de getprioritisationmap, suppression d'une entrée mapDeltas lorsque delta==0][review club 27501]
est un PR de Gloria Zhao (glozow) qui améliore la fonctionnalité
de Bitcoin Core permettant aux mineurs de modifier les frais de mempool
effectifs, et donc la priorité minière (plus élevée ou plus basse), de
certaines transactions (voir la [prioritisetransaction RPC][]).
L'augmentation (si elle est positive) ou la diminution (si elle est
négative) des frais est appelée _fee delta_. Les valeurs de priorisation
des transactions sont conservées sur disque dans le fichier `mempool.dat`
et sont restaurées au redémarrage du noeud.

L'une des raisons pour lesquelles un mineur peut donner la priorité à
une transaction est de tenir compte d'un paiement de frais de transaction
hors bande ; la transaction concernée sera traitée comme si elle avait
des frais plus élevés lorsqu'il s'agira de choisir les transactions à
inclure dans le modèle de bloc du mineur.

La PR ajoute une nouvelle RPC, `getprioritisationmap`, qui retourne
l'ensemble des transactions priorisées. La PR supprime également les
entrées de priorisation inutiles, qui peuvent survenir si l'utilisateur
remet les deltas à zéro.

{% include functions/details-list.md
  q0="Qu'est-ce que la structure de données [mapDeltas][] et pourquoi est-elle nécessaire ?"
  a0="C'est là que sont stockées les valeurs de priorité par transaction.
      Ces valeurs affectent les décisions locales d'extraction et d'éviction,
      ainsi que les calculs des taux d'ancêtres et de descendants."
  a0link="https://bitcoincore.reviews/27501#l-26"

  q1="La hiérarchisation des transactions affecte-t-elle l'algorithme d'estimation des frais ?"
  a1="L'estimation des frais doit prédire avec précision les décisions
      attendues des mineurs (dans ce cas, _d'autres_ mineurs), et ces
      mineurs n'ont pas les mêmes priorités que nous, puisqu'elles sont
      locales."
  a1link="https://bitcoincore.reviews/27501#l-31"

  q2="Comment une entrée est-elle ajoutée à `mapDeltas` ? Quand est-elle supprimée ?"
  a2="Il est ajouté par la RPC `prioritisetransaction`, et aussi quand
      le noeud redémarre, à cause d'une entrée dans `mempool.dat`. Ils
      sont supprimés lorsqu'un bloc contenant la transaction est ajouté
      à la chaîne, ou lorsque la transaction est [remplacée][topic rbf]."
  a2link="https://bitcoincore.reviews/27501#l-34"

  q3="Pourquoi ne pas supprimer l'entrée d'une transaction dans `mapDeltas`
      lorsqu'elle quitte le mempool (parce que, par exemple, elle a expiré ou
      a été expulsée parce que le feerate est tombé en dessous du feerate minimum) ?"
  a3="La transaction peut revenir dans le mempool. Si son entrée `mapDeltas`
      avait été supprimée, l'utilisateur devrait redonner la priorité à la transaction."
  a3link="https://bitcoincore.reviews/27501#l-84"

  q4="Si une transaction est retirée de `mapDeltas` parce qu'elle est incluse
      dans un bloc, mais que le bloc est ensuite réorgé, la priorité de la transaction
      ne devra-t-elle pas être rétablie ?"
  a4="Oui, mais les réorganisations devraient être rares. En outre, le paiement hors
      bande peut en fait prendre la forme d'une transaction en bitcoins, et il peut
      donc être nécessaire de la refaire également."
  a4link="https://bitcoincore.reviews/27501#l-90"

  q5="Pourquoi devrions-nous autoriser la priorisation d'une transaction qui n'est
      pas présente dans le pool de mémoire ?"
  a5="Parce que la transaction peut ne pas être dans le mempool _yet_.
      Et il se peut même qu'elle ne soit pas en mesure d'entrer dans le
      pool de mémoire en premier lieu sur la base de ses propres frais
      (sans la priorisation)."
  a5link="https://bitcoincore.reviews/27501#l-89"

  q6="Quel est le problème si nous ne nettoyons pas `mapDeltas` ?"
  a6="Le principal problème est l'allocation de mémoire inutile."
  a6link="https://bitcoincore.reviews/27501#l-107"

  q7="Quand le fichier `mempool.dat` (y compris `mapDeltas`) est-il écrit
      de la mémoire vers le disque ?"
  a7="Lors d'un arrêt complet, et en exécutant la commande RPC `savemempool`."
  a7link="https://bitcoincore.reviews/27501#l-114"

  q8="Sans le PR, comment les mineurs peuvent-ils nettoyer les `mapDeltas`
      (c'est-à-dire supprimer les entrées dont la valeur de priorité est nulle) ?"
  a8="Le seul moyen est de redémarrer le nœud, puisque les
      priorisations à valeur nulle ne sont pas chargées dans
      `mapDeltas` lors du redémarrage. Avec le PR, l'entrée
      `mapDeltas` est supprimée dès que sa valeur est fixée
      à zéro. Ceci a l'effet bénéfique supplémentaire que les
      priorisations à valeur nulle ne sont pas écrites sur le disque."
  a8link="https://bitcoincore.reviews/27501#l-127"
%}

## Changements notables dans le code et la documentation

*Changements notables cette semaine dans [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo], et
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [Bitcoin Core #26094][] ajoute les champs block hash et height à `getbalances`,
  `gettransaction`, et `getwalletinfo`. Ces appels RPC verrouillent l'état de la
  chaîne pour s'assurer qu'ils sont à jour avec le dernier bloc et ils bénéficient
  donc de l'inclusion du hash et de la hauteur du bloc dans la réponse.

- [Bitcoin Core #27195][] permet de supprimer tous les récepteurs externes d'une
  transaction qui est [remplacée][topic rbf] en utilisant la RPC `bumpfee` du
  portefeuille interne de Bitcoin Core. L'utilisateur fait cela en faisant en
  sorte que la seule sortie de la transaction de remplacement paie sa propre
  adresse. Si la transaction de remplacement est confirmée, cela empêche les
  destinataires originaux d'être payés, ce qui est parfois décrit comme
  "l'annulation" d'un paiement Bitcoin.

- [Eclair #1783][] ajoute une API `cpfpbumpfees` pour [CPFP][topic cpfp]
  l'augmentation des frais d'une ou plusieurs transactions. Le PR met également
  à jour la liste des [paramètres recommandés][eclair bitcoin.conf] pour
  l'exécution de Bitcoin Core afin de s'assurer que la création d'une transaction
  avec majoration des frais est une option viable.

- [LND #7568][] ajoute la possibilité de définir des bits de caractéristiques
  LN supplémentaires lors du démarrage du nœud. Il supprime également la
  possibilité de désactiver tout bit de caractéristique codé en dur ou défini
  pendant l'exécution (mais des bits supplémentaires peuvent toujours être
  ajoutés et désactivés ultérieurement). Une mise à jour de la proposition
  connexe dans [BLIPs #24][] note que les bits de caractéristique personnalisés
  [BOLT11][] sont limités à une valeur exprimée maximale de 5114.

- [LDK #2044][] apporte plusieurs modifications à la suggestion d'itinéraire
  de LDK pour les factures [BOLT11][], le mécanisme qu'un nœud LN récepteur
  peut utiliser pour suggérer des itinéraires à utiliser par un nœud utilisateur.
  Avec cette fusion, seuls trois canaux sont suggérés, la prise en charge des
  nœuds fantômes de LDK est améliorée (voir [Newsletter #188][news188 phantom]),
  et les trois canaux choisis le sont pour des raisons d'efficacité et de
  confidentialité. La discussion sur le PR inclut [plusieurs][carman hints]
  [commentaires perspicaces][corallo hints] sur les implications pour la vie
  privée de la fourniture d'indications d'itinéraires.

## Célébration de la lettre d'information Optech #250

Bitcoin Optech a été fondé, en partie, pour "faciliter l'amélioration des
relations entre les entreprises et la communauté open source". Cette lettre
d'information hebdomadaire a été lancée pour donner aux cadres et aux
développeurs des entreprises utilisant Bitcoin un meilleur aperçu de ce que
la communauté open source est en train de construire.  En tant que tel, nous
nous sommes d'abord concentrés sur la documentation des travaux susceptibles
d'affecter les entreprises.

Nous avons rapidement découvert que les lecteurs professionnels n'étaient
pas les seuls à être intéressés par ces informations. De nombreux contributeurs
aux projets Bitcoin n'avaient pas le temps de lire toutes les discussions sur
les listes de diffusion relatives au développement du protocole ou de surveiller
les changements majeurs dans d'autres projets. Ils appréciaient que quelqu'un
les informe des développements qu'ils pourraient trouver intéressants ou qui
pourraient affecter leur travail.

Depuis près de cinq ans, nous avons le plaisir de fournir ce service. Nous avons
essayé d'élargir cette simple mission en proposant également un guide de
[compatibilité des technologies du portefeuille][compatibility matrix], un
index de plus de 100 [sujets d'intérêt][topics], et un [podcast][podcast] de
discussion hebdomadaire avec des invités qui incluent de nombreux contributeurs
dont nous avons eu le privilège d'écrire sur leurs travaux.

Rien de tout cela ne serait possible sans nos nombreux contributeurs qui, au cours
de l'année écoulée, ont été les suivants :
<!-- alphabetical -->
Adam Jonas,
Copinmalin,
David A. Harding,
Gloria Zhao,
Jiri Jakes,
Jon Atack,
Larry Ruane,
Mark "Murch" Erhardt,
Mike Schmidt,
nechteme,
Patrick Schwegler,
Shashwat Vangani,
Shigeyuki Azuchi,
Vojtěch Strnad,
Zhiwei "Jeffrey" Hu,
et plusieurs autres personnes qui ont apporté des contributions spéciales à des sujets particuliers.

Nous sommes également éternellement reconnaissants à nos [sponsors fondateurs][]
Wences Casares, John Pfeffer et Alex Morcos, ainsi qu'à nos nombreux
[soutiens financiers][].

Nous vous remercions de votre lecture.  Nous espérons que vous continuerez à le faire
lorsque nous publierons les 250 prochains bulletins d'information.

{% include references.md %}
{% include linkers/issues.md v=2 issues="26094,27195,1783,7568,24,2044" %}
[Core Lightning 23.05rc2]: https://github.com/ElementsProject/lightning/releases/tag/v23.05rc2
[bitcoin core 24.1rc2]: https://bitcoincore.org/bin/bitcoin-core-24.1/
[bitcoin core 25.0rc1]: https://bitcoincore.org/bin/bitcoin-core-25.0/
[eclair bitcoin.conf]: https://github.com/ACINQ/eclair/pull/1783/files#diff-b335630551682c19a781afebcf4d07bf978fb1f8ac04c6bf87428ed5106870f5
[carman hints]: https://github.com/lightningdevkit/rust-lightning/pull/2044#issuecomment-1448840896
[corallo hints]: https://github.com/lightningdevkit/rust-lightning/pull/2044#issuecomment-1461049958
[hartman powswap]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-May/021605.html
[hnr powswap]: https://raw.githubusercontent.com/blockrate-binaries/paper/master/blockrate-binaries-paper.pdf
[powswap]: https://powswap.com/
[news188 phantom]: /fr/newsletters/2022/02/23/#ldk-1199
[founding sponsors]: /about/#founding-sponsors
[financial supporters]: /#members
[review club 27501]: https://bitcoincore.reviews/27501
[prioritisetransaction rpc]: https://developer.bitcoin.org/reference/rpc/prioritisetransaction.html
[mapDeltas]: https://github.com/bitcoin/bitcoin/blob/fc06881f13495154c888a64a38c7d538baf00435/src/txmempool.h#L450
