---
title: 'Bulletin Hebdomadaire Bitcoin Optech #18'
permalink: /fr/newsletters/2018/10/23/
name: 2018-10-23-newsletter-fr
slug: 2018-10-23-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine contient un avertissement concernant la communication avec des nœuds Bitcoin via RPC sur des connexions non
chiffrées, des liens vers deux nouveaux articles sur la création rapide de clés et de signatures ECDSA multipartites qui pourraient réduire
les frais de transaction pour les utilisateurs de multisig, et répertorie quelques fusions notables de projets populaires d'infrastructure
Bitcoin.

## Actions requises

- **Fermez les ports RPC ouverts sur les nœuds :** environ 13 % des nœuds Bitcoin semblent avoir leurs ports RPC ouverts sur des connexions
  publiques non chiffrées, mettant les utilisateurs de ces nœuds en danger. Voir l’élément d’actualité complet ci-dessous pour plus de
  détails sur le risque et les solutions recommandées.

## Nouvelles

- **Plus de 1 100 nœuds à l’écoute ont des ports RPC ouverts :** Il a été récemment mentionné dans le salon IRC #bitcoin-core-dev que de
  nombreux nœuds Bitcoin sur le réseau avaient leur port RPC ouvert. Optech a [enquêté][port scan summary] et a constaté qu’environ 1 100
  des 8 400 nœuds à l’écoute avec une adresse IPv4 avaient bien le port 8332 ouvert (13,2 %).

  Cela peut indiquer que de nombreux opérateurs de nœuds ignorent que la communication RPC sur Internet est complètement non sécurisée par
  défaut et expose votre nœud à de multiples attaques qui pourraient vous coûter de l’argent même si vous avez désactivé le portefeuille sur
  votre nœud. La communication RPC n’est pas chiffrée, donc tout espion observant ne serait-ce qu’une seule requête vers votre serveur peut
  voler vos identifiants d’authentification et les utiliser pour exécuter des commandes qui vident votre portefeuille (si vous en avez un),
  tromper votre nœud pour qu’il utilise une bifurcation de la chaîne de blocs avec presque aucune sécurité de preuve de travail, écraser des
  fichiers arbitraires sur votre système de fichiers, ou causer d’autres dommages. Même si vous ne vous connectez jamais à votre nœud via
  Internet, avoir un port RPC ouvert comporte le risque qu’un attaquant devine vos identifiants de connexion.

  Par défaut, les nœuds n’acceptent pas les connexions RPC depuis un autre ordinateur---vous devez activer une option de configuration pour
  autoriser les connexions RPC. Pour déterminer si vous avez activé cette fonctionnalité, vérifiez dans votre fichier de configuration
  Bitcoin et vos paramètres de démarrage la présence du paramètre `rpcallowip`. Si cette option est présente, vous devriez la supprimer et
  redémarrer votre nœud à moins d’avoir une bonne raison de croire que toutes les connexions RPC à votre nœud sont chiffrées ou sont
  limitées à un réseau privé de confiance. Si vous souhaitez tester votre nœud à distance pour détecter un port RPC ouvert, vous pouvez
  exécuter la commande [nmap][] suivante après avoir remplacé *ADDRESS* par l’adresse IP de votre nœud :

  ```
  nmap -Pn -p 8332 ADDRESS
  ```

  Si le résultat dans le champ *state* est « open », vous devriez suivre les instructions ci-dessus pour supprimer le paramètre
  `rpcallowip`. Si le résultat est soit « closed » soit « filtered », votre nœud est sûr à moins que vous n’ayez défini un port RPC
  personnalisé ou activé autrement une configuration personnalisée.

  Une [PR][Bitcoin Core #14532] a été ouverte pour Bitcoin Core afin de rendre plus difficile pour les utilisateurs de configurer leur nœud
  de cette façon et d’afficher des avertissements supplémentaires lors de l’activation d’un tel comportement.

- **Deux articles publiés sur l’ECDSA multipartite rapide :** dans l’ECDSA multipartite, deux parties ou plus peuvent créer en coopération
  (mais sans confiance) une seule clé publique qui exige également que les parties coopèrent pour créer une seule signature valide pour
  cette clé publique. Si les parties s’accordent avant de créer la clé publique, elles peuvent aussi rendre possible qu’un sous-ensemble
  d’entre elles seulement signe, par ex. 2 sur 3 d’entre elles doivent coopérer pour signer. Cela peut être beaucoup plus efficace que le
  multisig actuel de Bitcoin, qui nécessite de placer *k* signatures et *n* clés publiques dans les transactions pour une sécurité k-sur-n,
  alors que l’ECDSA multipartite ne nécessiterait toujours qu’une seule signature et une seule clé publique pour n’importe quels *k* ou *n*.
  Les techniques sous-jacentes à l’ECDSA multipartite peuvent également être utilisées avec des scriptless scripts comme décrit dans le
  [Bulletin #16][news16 mpecdsa].

  Mieux encore, ces avantages sont immédiatement disponibles pour quiconque les implémente, car la prise en charge actuelle de l’ECDSA par
  le protocole Bitcoin signifie qu’il prend également en charge les schémas multipartites ECDSA purs. Aucun changement n’est nécessaire aux
  règles de consensus, au protocole P2P, aux formats d’adresse, ni à aucune autre ressource partagée. Tout ce dont vous avez besoin, ce sont
  de deux portefeuilles ou plus qui implémentent la génération de clés et la signature ECDSA multipartites. Cela peut rendre le schéma
  attrayant pour les services existants qui bénéficient de la sécurité supplémentaire du multisig Bitcoin mais perdent à devoir payer des
  frais de transaction supplémentaires pour les clés publiques et signatures supplémentaires.

  Il faudra probablement du temps pour que les experts examinent ces articles, évaluent leurs propriétés de sécurité et envisagent de les
  implémenter---et certains experts sont déjà occupés à travailler sur l’implémentation d’une proposition de modification du consensus pour
  permettre un schéma de signature Schnorr qui peut simplifier la génération de clés publiques et de signatures multipartites et aussi
  fournir de multiples autres avantages.

  - [Fast Multiparty Threshold ECDSA with Fast Trustless Setup][mpecdsa goldfeder] par Rosario Gennaro et Steven Goldfeder

  - [Fast Secure Multiparty ECDSA with Practical Distributed Key Generation and Applications to Cryptocurrency Custody][mpecdsa lindell] par
    Yehuda Lindell, Ariel Nof, et Samuel Ranellucci

[mpecdsa goldfeder]: http://stevengoldfeder.com/papers/GG18.pdf
[mpecdsa lindell]: https://eprint.iacr.org/2018/987.pdf

## Fusions notables

*Changements de code notables cette semaine dans [Bitcoin Core][bitcoin core repo], [LND][lnd repo], [C-lightning][core lightning repo], et
[libsecp256k1][libsecp256k1 repo].*

- [Bitcoin Core #14291][] : Pour une utilisation avec le mode multiwallet de Bitcoin Core, un nouveau RPC `listwalletdir` peut lister tous
  les portefeuilles disponibles dans le répertoire des portefeuilles.

- [Bitcoin Core #14424][] : Corrige une régression probable dans la 0.17.0 pour les portefeuilles en surveillance seule qui obligent les
  utilisateurs à importer leurs clés publiques pour les scripts multisig (plutôt que simplement importer le script) afin que Bitcoin Core
  tente de dépenser le script en utilisant des RPC tels que [fundrawtransaction][rpc fundrawtransaction] avec l’indicateur
  `includeWatching`. Cette PR a été marquée pour rétroportage vers la 0.17.1 dès que le travail sur celle-ci commencera. Une solution de
  contournement pour les utilisateurs de la 0.17.0 est décrite dans [Bitcoin Core #14415][].

- [LND #1978][], [#2062][LND #2062], [#2063][LND #2063] : de nouvelles fonctions pour créer des transactions de sweep ont été ajoutées,
  remplaçant des fonctions de l’UTXO Nursery qui est « dédiée à l’incubation des sorties verrouillées dans le temps ». Ces nouvelles
  fonctions acceptent une liste de sorties, génèrent une transaction pour elles avec des frais appropriés qui reviennent vers le même
  portefeuille (pas une adresse réutilisée), et signent la transaction. Les transactions de sweep définissent nLockTime à la hauteur
  actuelle de la chaîne de blocs, implémentant la même technique anti-fee sniping adoptée par d’autres portefeuilles tels que Bitcoin Core
  et GreenAddress, aidant à décourager les réorganisations de chaîne et permettant aux transactions de sweep de LND de se fondre parmi les
  transactions de ces autres portefeuilles.

- [LND #2051][] : garantit qu’un attaquant qui choisit de verrouiller ses fonds pendant une très longue période (jusqu’à environ 10 000 ans)
  ne peut pas amener votre nœud à verrouiller la même quantité de vos fonds pendant la même durée. Avec ce correctif, votre nœud rejettera
  les requêtes d’un attaquant visant à verrouiller ses fonds et vos fonds pour une période de plus de 5 000 blocs (environ 5 semaines).

- [C-Lightning #2033][] : fournit un nouveau RPC `listforwards` qui liste les paiements relayés (paiements effectués dans des canaux de
  paiement passant par votre nœud), y compris des informations sur le montant des frais que vous avez gagnés en faisant partie du chemin de
  relais. De plus, le RPC `getstats` renvoie maintenant un nouveau champ, `msatoshis_fees_collected`, contenant le montant total des frais
  que vous avez gagnés.

- [Libsecp256k1 #354][] : permet aux appelants des fonctions ECDH d’utiliser une fonction de hachage personnalisée. Le protocole de
  consensus Bitcoin n’utilise pas ECDH, mais il est utilisé ailleurs avec les mêmes paramètres de courbe que Bitcoin dans des schémas
  décrits dans les BIP [47][BIP47], [75][BIP75], et [151][BIP151] (ancien brouillon) ; les BOLT Lightning [4][BOLT4] et [8][BOLT8] ; et
  divers autres usages comme [Bitmessage][], les sidechains [ElementsProject][] utilisant des transactions et des actifs confidentiels, et
  certains smart contracts Ethereum. Certains de ces schémas ne peuvent pas utiliser la fonction de hachage par défaut utilisée par
  libsecp256k1, donc cette PR fusionnée permet de passer un pointeur vers une fonction de hachage personnalisée qui sera utilisée à la place
  de la valeur par défaut et qui permet de transmettre des données arbitraires à cette fonction.

{% include references.md %}
{% include linkers/issues.md issues="14291,14424,1978,2062,2063,2051,2033,354,14415,14532" %}

[bitmessage]: https://bitmessage.org/wiki/Encryption
[elementsproject]: https://elementsproject.org/
[port scan summary]: https://gist.github.com/harding/bf6115a567e80ba5e737242b91c97db2
[nmap]: https://nmap.org/download.html
[news16 mpecdsa]: /fr/newsletters/2018/10/09/#ecdsa-multipartite-pour-des-canaux-de-paiement-lightning-network-sans-script
