---
title: 'Bulletin Hebdomadaire Bitcoin Optech #33'
permalink: /fr/newsletters/2019/02/12/
name: 2019-02-12-newsletter-fr
slug: 2019-02-12-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine annonce la toute dernière version de LND, décrit brièvement un outil pour générer des preuves de possession de
bitcoins, et renvoie vers une étude d'Optech sur l'utilisabilité de Replace-by-Fee. Sont également inclus des résumés de changements de code
notables dans des projets populaires de l'infrastructure Bitcoin.

## Action items

- **Mettez à niveau vers LND 0.5.2 :** cette [version][lnd release] mineure corrige des bogues liés à la stabilité et améliore la
  compatibilité avec d'autres logiciels LN.

## Nouvelles

- **Publication d'un outil pour générer et vérifier des preuves de possession de bitcoins :** Blockstream a [publié][reserve audit tool] un
  outil qui aide les dépositaires de bitcoins, tels que les plateformes d'échange, à prouver qu'ils contrôlent un certain nombre de bitcoins
  sans créer de transaction onchain. L'outil fonctionne en créant une transaction presque valide qui contient toutes les mêmes informations
  qu'une transaction valide contiendrait---prouvant que le créateur de la transaction avait accès à toutes les informations nécessaires pour
  créer une dépense (par ex. les clés privées). L'outil est écrit dans le langage de programmation Rust et utilise le format de transaction
  Bitcoin partiellement signée BIP174 (PSBT) de plus en plus populaire pour l'interopérabilité avec Bitcoin Core et d'autres outils Bitcoin.
  Les projets futurs pour l'outil incluent des améliorations de confidentialité.

- **Publication d'une étude sur l'utilisabilité de RBF :** alors que seulement environ 6 % des transactions confirmées en 2018 signalaient
  le support de l'option Replace-by-Fee (RBF) [BIP125][] opt-in, le contributeur d'Optech Mike Schmidt a entrepris [un examen][rbf report]
  de près de deux douzaines de portefeuilles Bitcoin populaires, d'explorateurs de blocs et d'autres services afin de voir comment ils
  géraient soit l'envoi, soit la réception de transactions RBF (y compris les augmentations de frais). Son rapport fournit des exemples
  visuels, bons comme mauvais, de la façon dont de nombreux systèmes gèrent les transactions RBF. Les exemples de problèmes ne visent pas à
  critiquer les développeurs pionniers de ces systèmes, mais à aider tous les développeurs Bitcoin à apprendre à maîtriser la puissante
  capacité de gestion des frais que fournit RBF. Sur la base des exemples recueillis, le rapport se conclut par un résumé de recommandations
  pour les développeurs.

## Changements notables dans le code

*Changements de code notables cette semaine dans [Bitcoin Core][bitcoin core repo], [LND][lnd repo], [C-Lightning][c-lightning repo],
[Eclair][eclair repo], et [libsecp256k1][libsecp256k1 repo].*

- [Bitcoin Core #14897][] introduit un ordre semi-aléatoire biaisé vers les connexions sortantes lors de la demande de transactions, rendant
  plus difficile pour les attaquants d'abuser de l'une des mesures de réduction de bande passante de Bitcoin Core. Auparavant, lorsque votre
  nœud recevait l'annonce d'une nouvelle transaction de l'un de ses pairs, il demandait cette transaction à ce pair. Pendant qu'il attendait
  que la transaction soit envoyée, il pouvait avoir reçu des annonces de la même transaction de la part de ses autres pairs. Si le premier
  pair n'avait pas envoyé la transaction dans les deux minutes, votre nœud demandait alors la transaction au deuxième pair qui l'avait
  annoncée, attendant à nouveau deux minutes avant de la demander au pair suivant. Cela permettait à un attaquant qui ouvre un grand nombre
  de connexions à votre nœud de potentiellement retarder votre réception d'une transaction d'un grand nombre d'intervalles de deux minutes.

  Si une telle attaque était menée sur l'ensemble du réseau, elle pourrait être en mesure d'empêcher certaines transactions d'atteindre les
  mineurs, compromettant possiblement la sécurité de protocoles qui dépendent d'une confirmation rapide (par ex. les canaux de paiement LN).
  Une attaque à l'échelle du réseau pourrait également rendre plus [facile][coinscope] la [cartographie][txprobe] du réseau et la
  redirection du trafic de transactions afin d'apprendre quelle adresse IP a émis une transaction.

  Avec cette PR, votre nœud ne demandera immédiatement la transaction au premier pair qui l'a annoncée que si votre nœud a initialement
  choisi d'ouvrir une connexion à ce pair (c.-à-d. un pair sortant). Si vous avez d'abord entendu parler de la transaction d'un pair qui
  s'est connecté à vous (un pair entrant), vous attendrez deux secondes avant de demander la transaction afin de donner à un pair sortant la
  possibilité de vous en informer en premier. Si le premier pair auquel vous demandez la transaction ne vous l'a pas envoyée dans la minute,
  vous la demanderez à un autre pair sélectionné aléatoirement. Si cela ne fonctionne pas non plus, vous continuerez à sélectionner
  aléatoirement des pairs auxquels demander la transaction. Cela n'élimine pas le problème, mais cela signifie que un attaquant qui veut
  retarder une transaction devra probablement exploiter un nombre bien plus grand de nœuds pour obtenir le même retard. Il est possible
  qu'une technique de réconciliation d'ensembles basée sur quelque chose comme [libminisketch][] puisse fournir une solution complète pour
  tout nœud ayant au moins un pair honnête.

- [Bitcoin Core #14491][] permet à la RPC `importmulti` d'importer des clés spécifiées à l'aide d'un [descripteur de script de
  sortie][output script descriptors]. Les clés importées de cette manière seront converties vers la structure de données actuelle du
  portefeuille, mais le plan à terme est que le portefeuille de Bitcoin Core utilise des descripteurs en interne.

- [Bitcoin Core #14667][] ajoute une nouvelle RPC `deriveaddress` qui prend un descripteur contenant un chemin de clé ainsi qu'une clé
  publique étendue et renvoie l'adresse correspondante.

- [Bitcoin Core #15226][] ajoute un paramètre `blank` à la RPC `createwallet` qui permet de créer un portefeuille sans seed HD ni aucune clé
  privée. Le portefeuille peut ensuite recevoir du matériel de clé privée ou publique (par ex. une seed HD avec `sethdseed` ou une adresse
  en mode surveillance seule avec `importaddress`). Le portefeuille peut aussi être chiffré tout en restant vierge grâce à la RPC
  `encryptwallet`. Le terme « vierge » est utilisé pour distinguer un portefeuille sans clés d'un portefeuille « vide » dont les clés ne
  contrôlent aucun bitcoin.

- [LND #2457][] ajoute une RPC `cancelinvoice` pour annuler une facture qui n'a pas encore été réglée. Si un paiement pour une facture
  annulée arrive à votre nœud, il renverra la même erreur qu'il aurait utilisée si cette facture n'avait jamais existé, empêchant le
  paiement de réussir et renvoyant tout l'argent au dépensier.

- [LND #2572][] ajoute un paramètre `outgoing_chan_id` à la commande `sendpayment`. Vous pouvez utiliser ce paramètre pour spécifier lequel
  de vos canaux doit être utilisé pour le premier saut du paiement.

- [Eclair #736][] ajoute la prise en charge à la fois de la connexion à des services cachés Tor (.onion) et du fonctionnement en tant que
  service caché. Une [documentation][eclair tor] est fournie aux utilisateurs.

{% include references.md %}
{% include linkers/issues.md issues="736,2572,2457,15226,14491,14667,14897" %}
[lnd release]: https://github.com/lightningnetwork/lnd/releases/tag/v0.5.2-beta
[coinscope]: https://www.cs.umd.edu/projects/coinscope/coinscope.pdf
[txprobe]: https://arxiv.org/pdf/1812.00942.pdf
[reserve audit tool]: https://blockstream.com/2019/02/04/standardizing-bitcoin-proof-of-reserves/
[eclair tor]: https://github.com/ACINQ/eclair/blob/master/TOR.md
[rbf report]: /en/rbf-in-the-wild/
[output script descriptors]: https://github.com/bitcoin/bitcoin/blob/master/doc/descriptors.md
