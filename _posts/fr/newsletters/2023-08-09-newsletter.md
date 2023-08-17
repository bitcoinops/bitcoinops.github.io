---
title: 'Bulletin Hebdomadaire Bitcoin Optech #263'
permalink: /fr/newsletters/2023/08/09/
name: 2023-08-09-newsletter-fr
slug: 2023-08-09-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine met en garde contre une vulnérabilité grave dans l'utilisation de l'outil Bitcoin Explorer (bx)
de Libbitcoin, résume une discussion sur la conception de la protection contre les attaques par déni de service, annonce un
plan visant à commencer les tests et la collecte de données sur l'approbation HTLC, et décrit deux modifications proposées à
la politique de relais de transactions de Bitcoin Core. On y trouve également nos sections habituelles avec le résumé d'une
réunion du Bitcoin Core PR Review Club, des annonces de mises à jour et versions candidates, ainsi
que les changements apportés aux principaux logiciels d'infrastructure Bitcoin.

## Actions à entreprendre

- **Vulnérabilité grave de Libbitcoin Bitcoin Explorer :** si vous avez utilisé la commande `bx seed` pour créer des graines
  [BIP32][topic BIP32], des mnémoniques [BIP39][], des clés privées ou tout autre matériel sécurisé, envisagez de déplacer
  immédiatement tous les fonds vers une adresse sécurisée différente. Voir la section Nouvelles ci-dessous pour plus de détails.

## Nouvelles

- **Philosophie de conception de la protection contre les attaques par déni de service (DoS) :** Anthony Towns a
  [posté][towns dos] sur la liste de diffusion Lightning-Dev en réponse à la partie des notes de la récente réunion des
  développeurs LN sur le brouillage des canaux (voir [Bulletin #261][news261 jamming]). Les notes indiquaient que "le coût
  qui dissuadera un attaquant est déraisonnable pour un utilisateur honnête, et le coût raisonnable pour un utilisateur honnête
  est trop faible [pour dissuader] un attaquant".

  Towns a suggéré une alternative à la tentative de fixer un prix pour dissuader les attaquants : faire en sorte que les coûts
  payés à la fois par les attaquants et par les utilisateurs honnêtes reflètent les coûts sous-jacents payés par les opérateurs
  de nœuds fournissant le service. Ainsi, un opérateur de nœud qui réalise un retour sur investissement raisonnable en fournissant
  des services aux utilisateurs honnêtes continuera à réaliser des bénéfices raisonnables si les attaquants commencent à utiliser
  ces services. Si les attaquants tentent de priver les utilisateurs honnêtes de services en consommant une quantité excessive
  de ressources du nœud, les nœuds fournissant ces ressources ont un incitatif---un revenu plus élevé---à augmenter les ressources
  qu'ils fournissent.

  Comme suggestion de fonctionnement de ce système, Towns a ressuscité une idée datant de plusieurs années (voir [Bulletin
  #86][news86 hold fees]) concernant une combinaison de frais d'engagement anticipé et de frais de rétention inversée qui
  seraient facturés en plus des frais habituels pour un paiement réussi. Lorsqu'un HTLC est propagé de l'émetteur Alice au
  nœud de transfert Bob, Alice paierait des frais d'engagement anticipé minimes ; la part de Bob de ces frais correspondrait
  à son coût de traitement de l'HTLC (comme la bande passante). À un moment donné après avoir accepté l'HTLC, Bob serait
  responsable de payer périodiquement des frais de rétention inversée minimes à Alice jusqu'à ce que l'HTLC soit réglé ; cela
  la compenserait pour le retard dans l'acceptation ou l'annulation de son paiement. Si Bob transfère immédiatement le paiement
  à Carol après l'avoir reçu, il lui paierait des frais d'engagement anticipé légèrement inférieurs à ceux qu'il a reçus d'Alice
  (la différence étant le montant réel qu'il a reçu en compensation) et Carol lui fournirait des frais de rétention inversée
  légèrement plus élevés (encore une fois, la différence étant sa compensation). Aussi longtemps que les nœuds de transfert ou le
  destinataire ont retardé le HTLC, les seuls coûts supplémentaires par rapport aux frais de réussite normaux seraient les petits
  frais d'engagement en avant. Cependant, si le destinataire ou l'un des sauts retardait le paiement, il serait finalement
  responsable du paiement de tous les frais de rétention inversée des nœuds en amont.

Clara Shikhelman a répondu que les frais de rétention inversée payés sur une période de temps pourraient facilement dépasser le
montant qu'un nœud gagnerait en frais de réussite pour la même quantité de capital et la même durée. Cela inciterait un nœud
malveillant à abuser du mécanisme pour collecter des frais auprès de ses contreparties. Elle a décrit certains défis auxquels un
mécanisme comme celui esquissé par Towns serait confronté, et il a répondu avec des contre-arguments et un résumé : "Je pense que
la dissuasion basée sur la monnaie pour les attaques par déni de service est encore susceptible d'être un domaine fructueux de
recherche si les gens sont intéressés, même si les travaux de mise en œuvre actuels sont axés sur des méthodes basées sur la
réputation."

- **Tests d'approbation HTLC et collecte de données :** Carla Kirk-Cohen et Clara Shikhelman ont posté sur la liste de diffusion
  Lightning-Dev pour annoncer que les développeurs associés à Eclair, Core Lightning et LND implémentaient des parties du
  protocole d'approbation HTLC afin de commencer à collecter des données à ce sujet. Pour cela, ils proposent un ensemble de
  données qui seront utiles aux nœuds de test pour les chercheurs. De nombreux champs sont destinés à avoir leurs données
  randomisées afin d'éviter de divulguer des informations qui pourraient réduire la confidentialité des dépensiers et des
  destinataires. Ils prévoient plusieurs phases de tests et exposent comment les nœuds participants agiront lors des
  différentes phases.

- **Proposition de modifications de la politique de relais par défaut de Bitcoin Core :** Peter Todd a lancé deux fils de
  discussion sur la liste de diffusion Bitcoin-Dev concernant les PR qu'il a ouvertes pour modifier la politique de relais
  par défaut de Bitcoin Core.

  - *Full RBF par défaut :* le [premier fil de discussion][todd rbf] et [la PR][bitcoin core #28132] proposent de rendre
    [full RBF][topic rbf] comme paramètre par défaut dans une version future de Bitcoin Core. Par défaut, Bitcoin Core ne relaie
    et n'accepte actuellement dans son mempool que les remplacements de transactions non confirmées si la transaction remplacée
    contient le signal [BIP125][] indiquant la possibilité de remplacement (et si la transaction originale et la transaction de
    remplacement suivent d'autres règles), appelé _opt-in RBF_. Une option de configuration, `-mempoolfullrbf`, permet aux
    opérateurs de nœuds de choisir d'accepter les remplacements de n'importe quelle transaction non confirmée, même si elle ne
    contient pas le signal BIP125, appelé _full RBF_ (voir [Newsletter #208][news208 rbf]). La proposition de Peter Todd ferait
    de full RBF le paramètre par défaut, mais permettrait aux opérateurs de nœuds de modifier leurs paramètres pour choisir
    opt-in RBF à la place.

      Peter Todd soutient que le changement est justifié car (selon ses mesures, qui ont été remises en question par Towns), un
      pourcentage significatif de la puissance de hachage minière suit apparemment les règles de full RBF et il y a suffisamment
      de nœuds de relais qui ont activé full RBF pour permettre aux remplacements non signalés d'atteindre ces mineurs. Il dit
      également qu'il n'est pas au courant d'entreprises actives qui acceptent actuellement des transactions non confirmées onchain
      comme paiement final.

- *Suppression des limites spécifiques sur les sorties `OP_RETURN` :* le [deuxième fil][todd opr] et la [PR][bitcoin core #28130]
  proposent de supprimer les limites spécifiques de Bitcoin Core sur les transactions qui ont un script de sortie qui commence
  par l'opcode `OP_RETURN` (une sortie _OP_RETURN_). Actuellement, Bitcoin Core ne relaiera pas (par défaut) ou n'acceptera pas
  dans son mempool une transaction qui a plus d'une sortie `OP_RETURN` ou une sortie `OP_RETURN` dont le script de sortie dépasse
  83 octets de taille (ce qui correspond à 80 octets de données arbitraires).

  Autoriser la relais et l'extraction minière par défaut d'une petite quantité de données dans les sorties `OP_RETURN` était
  motivé par des personnes stockant précédemment des données dans d'autres types de sorties qui devaient être stockées dans
  l'ensemble UTXO, souvent à perpétuité. Les sorties `OP_RETURN` n'ont pas besoin d'être stockées dans l'ensemble UTXO et ne
  posent donc pas autant de problèmes. Depuis lors, certaines personnes ont commencé à stocker de grandes quantités de données
  dans les témoins de transaction.

  La PR permettrait par défaut un nombre quelconque de sorties `OP_RETURN` et une quantité quelconque de données dans une sortie
  `OP_RETURN`, à condition que les transactions respectent par ailleurs les autres politiques de relais de Bitcoin Core (par
  exemple, une taille totale de transaction inférieure à 100 000 vbytes). Au moment de la rédaction de cet article, les opinions
  sur la PR étaient mitigées, certains développeurs soutenant que la politique assouplie augmenterait la quantité de données non
  financières stockées sur la chaîne de blocs, tandis que d'autres soutenaient qu'il n'y avait aucune raison d'empêcher les gens
  d'utiliser des sorties `OP_RETURN` lorsque d'autres méthodes d'ajout de données à la chaîne de blocs étaient utilisées.

- **Divulgation de sécurité de Libbitcoin Bitcoin Explorer :** plusieurs chercheurs en sécurité enquêtant sur une récente perte
  de bitcoins parmi les utilisateurs de Libbitcoin ont découvert que la commande `seed` de l'outil Bitcoin Explorer (bx) de ce
  programme ne générait que environ 4 milliards de valeurs uniques différentes. Un attaquant qui supposait que les valeurs
  étaient utilisées pour créer des clés privées ou des portefeuilles avec des chemins de dérivation particuliers (par exemple,
  en suivant BIP39) pourrait potentiellement rechercher tous les portefeuilles possibles en une journée à l'aide d'un seul
  ordinateur courant, lui donnant ainsi la possibilité de voler tous les fonds reçus sur ces clés ou portefeuilles. Un tel vol
  probable s'est produit le 12 juillet 2023 avec des pertes apparentes d'environ 30 BTC (environ 850 000 USD à l'époque).

  Plusieurs processus similaires à celui qui a probablement conduit à la perte de fonds ont été décrits dans le livre _Mastering
  Bitcoin_, sur la [page d'accueil de la documentation][bx home] de Bitcoin Explorer et dans de nombreux autres endroits de la
  documentation de Bitcoin Explorer (par exemple, [1][bx1], [2][bx2], [3][bx3]). Aucune de ces documentations n'avertissait
  clairement qu'elle était dangereuse, à l'exception de la [documentation en ligne][seed doc] de la commande `seed`.

  La recommandation d'Optech est que toute personne qui pense avoir utilisé `bx seed` pour générer des portefeuilles ou des
  adresses examine la [page de divulgation][milksad] et utilise éventuellement le service qui fournissent des tests de hachage
  de graines vulnérables. Si vous avez utilisé le même processus découvert par l'attaquant, vos bitcoins ont probablement déjà
  été volés---mais si vous avez utilisé une variation du processus, vous pourriez encore avoir une chance de déplacer vos
  bitcoins en sécurité. Si vous utilisez un portefeuille ou un autre logiciel qui pourrait utiliser Libbitcoin, veuillez
  informer les développeurs de la vulnérabilité et leur demander d'enquêter.

Nous remercions les chercheurs pour leurs efforts importants dans le cadre d'une [divulgation
responsable][topic responsible disclosures] de [CVE-2023-39910][].

## Bitcoin Core PR Review Club

*Dans cette section mensuelle, nous résumons une récente réunion du
[Bitcoin Core PR Review Club][] en soulignant certaines des questions
et réponses importantes. Cliquez sur une question ci-dessous pour voir
un résumé de la réponse de la réunion.*

[Silent Payments: Implement BIP352][review club 28122]
est un PR de josibake qui fait le premier pas pour ajouter des [paiements silencieux][topic silent payments] au portefeuille
Bitcoin Core. Ce PR ne met en œuvre que la logique de [BIP352][] et n'inclut pas de modifications du portefeuille.

{% include functions/details-list.md
  q0="Pourquoi le PR ajoute-t-il une fonction de hachage ECDH personnalisée plutôt que d'utiliser celle par défaut fournie
      par `secp256k1`?"
  a0="En réalité, nous ne voulons pas hacher le résultat ECDH ; la fonction personnalisée empêche l'application par défaut de
      `sha256` sur le résultat de l'opération ECDH. Cela est nécessaire lorsque le créateur de la transaction ne contrôle pas
      toutes les entrées. Ne pas hacher le résultat pendant ECDH permet aux participants individuels de faire ECDH avec leur
      clé privée uniquement, puis de transmettre le résultat partiel ECDH. Les résultats partiels ECDH peuvent ensuite être additionnés, et le reste du protocole peut être effectué (hachage avec le compteur, etc.)."
  a0link="https://bitcoincore.reviews/28122#l-126"

  q1="Le PR ajoute des fonctions pour encoder et décoder les adresses de paiement silencieux. Pourquoi ne pouvons-nous pas
      simplement ajouter des adresses de paiement silencieux en tant que nouvelle variante de `CTxDestination` et utiliser la classe d'encodeur existante et la fonction de décodeur ?"
  a1="Une adresse de paiement silencieux n'encode pas réellement un script de sortie spécifique ; ce n'est pas un `scriptPubKey`.
      Au lieu de cela, elle encode les clés publiques nécessaires pour _dériver_ le script de sortie réel, qui dépend également des
      entrées de votre transaction de paiement silencieux. Autrement dit, au lieu de vous donner un `scriptPubKey` à envoyer (ce
      que fait une adresse traditionnelle), une adresse de paiement silencieux vous donne des clés publiques pour faire ECDH, puis
      le protocole indique comment transformer ce secret partagé en un `scriptPubKey` que le destinataire pourra détecter et dépenser ultérieurement."
  a1link="https://bitcoincore.reviews/28122#l-153"

  q2="[BIP352][] fait référence à la version et à la compatibilité ascendante. Qu'est-ce que la compatibilité ascendante et
      pourquoi est-elle importante ?"
  a2="Cela permet (par exemple) à un portefeuille v0 de décoder et d'envoyer vers une adresse de paiement silencieux v1 (et v2,
      et ainsi de suite) (même si le portefeuille ne pourra pas générer une adresse v1). C'est important pour que les portefeuilles
      n'aient pas besoin de se mettre à jour immédiatement."
  a2link="https://bitcoincore.reviews/28122#l-170"

  q3="Que se passe-t-il si une nouvelle version souhaite intentionnellement rompre la compatibilité?"
  a3="La version v31 est réservée à une mise à niveau qui romprait la compatibilité."
  a3link="https://bitcoincore.reviews/28122#l-186"

  q4="Pourquoi est-il acceptable d'allouer seulement une version (v31) qui rompt la compatibilité?"
  a4="Nous pouvons reporter la définition de nouvelles règles sur la façon dont les versions _après_ la version de rupture
      doivent être traitées jusqu'à plus tard, lorsque cela sera nécessaire."
  a4link="https://bitcoincore.reviews/28122#l-188"

  q5="Dans `DecodeSilentAddress`, il y a une vérification de la version et de la taille des données. Que fait cette vérification
      et pourquoi est-elle importante?"
  a5="Si une nouvelle version ajoute plus de données à l'adresse, nous avons besoin d'un moyen d'obtenir uniquement les parties
      compatibles vers l'avant, c'est-à-dire que nous devons nous limiter à l'analyse des 66 premiers octets (format v0). Cela est
      important pour la compatibilité future."
  a5link="https://bitcoincore.reviews/28122#l-194"

  q6="Le nouveau code de paiements silencieux se trouve dans le répertoire du portefeuille (`src/wallet/silentpayments.cpp`).
      Est-ce un bon emplacement?
      Pouvez-vous imaginer un cas d'utilisation où nous voudrions utiliser le code de paiements silencieux en dehors du contexte
      d'un portefeuille?"
  a6="Ce n'est pas idéal si l'on souhaite implémenter un serveur sans portefeuille qui détecte les paiements silencieux (ou
      effectue des calculs connexes) au nom d'un portefeuille de paiement silencieux plus léger. On peut imaginer un cas
      d'utilisation où un nœud complet indexe les données de modification pour les transactions et les stocke dans un index pour
      que les clients légers puissent les interroger, ou sert ces données via un filtre similaire à [BIP158][]. Cependant, jusqu'à
      ce que de tels cas d'utilisation se présentent, laisser le code dans `src/wallet` offre une meilleure organisation du code."
  a6link="https://bitcoincore.reviews/28122#l-205"

  q7="La classe `Recipient` est initialisée avec deux clés privées dans le PR, la clé de dépense et la clé de balayage. Les deux
      clés sont-elles nécessaires pour le balayage?"
  a7="Non, seule la clé de balayage est nécessaire. La possibilité de balayer les paiements silencieux sans la clé de dépense peut
      être implémentée à l'avenir."
  a7link="https://bitcoincore.reviews/28122#l-217"
%}

## Mises à jour et versions candidates

*Nouvelles versions et versions candidates pour les principaux projets
d'infrastructure Bitcoin. Veuillez envisager de passer aux nouvelles
versions ou d'aider à tester les versions candidates.*

- [BDK 0.28.1][] est une version de cette bibliothèque populaire pour la création d'applications de portefeuille. Elle inclut une
  correction de bogue et ajoute un modèle pour utiliser les chemins de dérivation [BIP86][] pour [P2TR][topic taproot] dans
  les [descripteurs][topic descriptors].

## Changements notables dans le code et la documentation

*Changements notables cette semaine dans [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo], and
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [Bitcoin Core #27746][] simplifie la relation entre le stockage des blocs et les objets de l'état de la chaîne en déplaçant
  la décision de stocker ou non un bloc sur le disque vers une logique de validation indépendante de l'état de chaîne actuel.
  La décision de stocker ou non un bloc sur disque est liée aux règles de validation qui ne nécessitent pas d'état UTXO.
  Auparavant, Bitcoin Core utilisait une heuristique spécifique à l'état de la chaîne pour des raisons anti-DoS, mais avec
  [assumeUTXO][topic assumeutxo] et la possibilité de deux états de chaîne coexistants, cela a été retravaillé pour réaliser
  la séparation proposée.

- [Core Lightning #6376][] et [#6475][core lightning #6475] implémentent un plugin appelé `renepay` qui utilise Pickhardt
  Payments pour construire des [paiements multipath][topic multipath payments] optimaux (voir [Newsletter #192][news192 pp]).
  Pickhardt Payments suppose que la liquidité dans chaque canal est répartie de manière aléatoire entre 0 et la capacité totale
  dans la direction du flux. Des montants de paiement importants peuvent entraîner un échec car une route peut ne pas fournir
  une liquidité suffisante le long de celle-ci, tandis que la division d'un paiement en plusieurs parties peut entraîner un
  échec car chaque route distincte a une chance d'échec. Un paiement est alors modélisé comme un flux dans le réseau Lightning
  visant à trouver un compromis entre le nombre de parties du paiement et le montant par partie. En utilisant cette approche,
  Pickhardt Payments trouve le flux optimal qui satisfait les contraintes de capacité et d'équilibre tout en maximisant les
  chances de succès. Les réponses des tentatives de paiement incomplètes sont utilisées pour mettre à jour les distributions
  de liquidité supposées pour tous les canaux impliqués, réduisant ainsi ceux qui n'ont pas réussi à transférer, mais tenant
  également compte des montants réussis. Étant donné que l'incorporation des frais de base [BOLT7][] dans le calcul du flux
  serait difficile sur le plan informatique (voir [Newsletter #163][news163 base]), les nœuds utilisant `renepay` pour la
  planification des paiements surestimeront plutôt les frais relatifs pour les canaux avec des frais de base non nuls. Les
  paquets en oignon construits pour la livraison des paiements utilisent les frais réels.

- [Core Lightning #6466][] et [#6473][core lightning #6473] ajoutent la prise en charge de la sauvegarde et de la restauration
  du [secret maître][topic BIP32] du portefeuille au format [codex32][topic codex32] spécifié dans [BIP93][].

- [Core Lightning #6253][] et [#5675][core lightning #5675] ajoutent une implémentation expérimentale de la spécification
  provisoire [BOLTs #863][] pour [le splicing][topic splicing]. Lorsque les deux côtés d'un canal prennent en charge le splicing,
  ils peuvent intégrer des fonds dans le canal en utilisant une transaction onchain ou retirer des fonds du canal en les dépensant
  onchain. Aucune de ces opérations ne nécessite la fermeture du canal et ils peuvent continuer à envoyer, recevoir ou transférer
  des paiements en utilisant la partie du solde d'origine qui reste pendant qu'ils attendent que la transaction de splicing onchain
  se confirme à une profondeur sûre, à partir de laquelle tous les fonds intégrés dans le canal deviennent également disponibles.
  Un avantage clé du splicing est que les portefeuilles compatibles avec LN peuvent conserver la vaste gamme de fonctionnalités
  de la chaîne Lightning tout en bénéficiant de la sécurité et de la résilience de la chaîne principale. La majorité de leurs
  fonds sont stockés offchain, puis ils créent des dépenses onchain à partir de ce solde lorsque cela est demandé, permettant aux
  portefeuilles d'afficher aux utilisateurs un solde unique plutôt qu'un solde divisé entre les fonds offchain et onchain.

- [Rust Bitcoin #1945][] modifie les politiques du projet concernant la quantité de révision qu'une demande de pull nécessite
  avant d'être fusionnée s'il s'agit simplement d'une refonte. D'autres projets qui rencontrent des difficultés pour faire
  réviser des refontes ou des petits changements selon les mêmes normes élevées qu'ils appliquent aux autres demandes de pull
  pourraient vouloir examiner la nouvelle politique de Rust Bitcoin.

- [BOLTs #759][] ajoute la prise en charge des [messages en oignon][topic onion messages] à la spécification LN. Les messages
  en oignon permettent d'envoyer des messages unidirectionnels à travers le réseau. Comme les paiements (HTLC), les messages
  utilisent le chiffrement en oignon de sorte que chaque nœud de transfert ne sait que quel pair lui a envoyé le message et quel
  pair devrait recevoir le message ensuite. Les charges utiles des messages sont également chiffrées de sorte que seul le
  destinataire final puisse les lire. Contrairement aux HTLC transférés, qui sont bidirectionnels---les flux d'engagement
  descendent vers le destinataire et la préimage nécessaire pour réclamer le paiement remonte vers le dépensier---la nature
  unidirectionnelle des messages en oignon signifie que les nœuds de transfert n'ont pas besoin de stocker quoi que ce soit à
  leur sujet après que le message a été transféré, bien que certains mécanismes de protection contre les attaques par déni de
  service proposés dépendent de la conservation d'une petite quantité d'informations agrégées sur une base par pair (voir la
  [Newsletter #207][news207 onion]). La messagerie bidirectionnelle peut être réalisée en incluant un chemin de retour dans le
  message initial. Les messages en oignon utilisent les [chemins aveugles][topic rv routing], qui ont été ajoutés à la
  spécification LN il y a quelques mois (voir [Newsletter #245][news245 blinded]), et les messages en oignon sont eux-mêmes
  utilisés par le protocole [offers][topic offers] en cours de développement.

{% include references.md %}
{% include linkers/issues.md v=2 issues="27746,6376,6475,6466,6473,6253,5675,863,1945,759,28132,28130" %}
[news245 blinded]: /fr/newsletters/2023/04/05/#bolts-765
[towns dos]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-July/004020.html
[news86 hold fees]: /en/newsletters/2020/02/26/#reverse-up-front-payments
[shikhelman dos]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-July/004033.html
[towns dos2]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-August/004035.html
[kcs endorsement]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-August/004034.html
[todd rbf]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-July/021823.html
[towns rbf]: https://github.com/bitcoin/bitcoin/pull/28132#issuecomment-1657669845
[news207 onion]: /en/newsletters/2022/07/06/#onion-message-rate-limiting
[news261 jamming]: /fr/newsletters/2023/07/26/#propositions-d-attenuation-des-attaques-de-saturation-des-canaux
[todd opr]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-August/021840.html
[CVE-2023-39910]: https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2023-39910
[milksad]: https://milksad.info/
[mb milksad]: https://github.com/bitcoinbook/bitcoinbook/commit/76c5ba8000d6de20b4adaf802329b501a5d5d1db#diff-7a291d80bf434822f6a737f3e564be6a67432e2f3f12669cf0469aedf56849bbR126-R134
[bx home]: https://web.archive.org/web/20230319035342/https://github.com/libbitcoin/libbitcoin-explorer/wiki
[bx1]: https://web.archive.org/web/20210122102649/https://github.com/libbitcoin/libbitcoin-explorer/wiki/How-to-Receive-Bitcoin
[bx2]: https://web.archive.org/web/20210122102714/https://github.com/libbitcoin/libbitcoin-explorer/wiki/bx-mnemonic-new
[bx3]: https://web.archive.org/web/20210506162634/https://github.com/libbitcoin/libbitcoin-explorer/wiki/bx-hd-new
[seed doc]: https://web.archive.org/web/20210122102710/https://github.com/libbitcoin/libbitcoin-explorer/wiki/bx-seed
[news208 rbf]: /en/newsletters/2022/07/13/#bitcoin-core-25353
[bdk 0.28.1]: https://github.com/bitcoindevkit/bdk/releases/tag/v0.28.1
[review club 28122]: https://bitcoincore.reviews/28122
[bip352]: https://github.com/bitcoin/bips/pull/1458
[bip158]: https://github.com/bitcoin/bips/blob/master/bip-0158.mediawiki
[news192 pp]: /en/newsletters/2022/03/23/#payment-delivery-algorithm-update
[news163 base]: /en/newsletters/2021/08/25/#zero-base-fee-ln-discussion
