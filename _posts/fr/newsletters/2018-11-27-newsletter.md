---
title: 'Bulletin Hebdomadaire Bitcoin Optech #23'
permalink: /fr/newsletters/2018/11/27/
name: 2018-11-27-newsletter-fr
slug: 2018-11-27-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine rappelle les augmentations potentielles de taux de frais, résume des améliorations suggérées aux indicateurs de
sighash pour accompagner BIP118 `SIGHASH_NOINPUT_UNSAFE`, et décrit brièvement une proposition visant à simplifier l’augmentation des frais
pour les transactions d’engagement LN. Sont également inclus une sélection récente de questions-réponses de Bitcoin Stack Exchange et des
descriptions de changements notables de code dans des projets populaires d’infrastructure Bitcoin.

## Éléments d'action

- **Surveiller les taux de frais :** les récentes réductions du taux de change sont probablement la cause d’une baisse modeste du hashrate
  et d’une possible augmentation du nombre de pièces se déplaçant vers ou depuis les plateformes d’échange, ce qui pourrait entraîner une
  hausse des taux de frais au cours de la semaine prochaine. À moins d’un changement nouveau et dramatique du hashrate durant la semaine
  prochaine, un ajustement de difficulté est attendu autour de dimanche, ce qui atténuera la majeure partie des récentes réductions du
  hashrate.

## Nouvelles

- **Mises à jour de sighash :** Pieter Wuille a lancé un [fil de discussion][wuille sighash] sur la liste de diffusion Bitcoin-Dev suggérant
  deux ajouts pour de futurs changements aux sighash segwit, en particulier [BIP118][] `SIGHASH_NOINPUT_UNSAFE`. Un hash de signature est la
  donnée engagée par une signature dans une transaction. Normalement, le hash engage une liste des pièces dépensées, quels scripts reçoivent
  les pièces, et certaines métadonnées---mais il est possible de ne signer que certains champs de transaction afin de permettre à d’autres
  utilisateurs de modifier vos transactions de façons spécifiques que vous pourriez juger acceptables (par ex. pour des protocoles de
  seconde couche).

  Wuille suggère deux ajouts à ce qui est haché parmi les métadonnées. Les deux seront optionnels, mais tous deux peuvent devenir le choix
  par défaut pour les portefeuilles onchain normaux. Premièrement, les frais de transaction sont inclus dans le hash afin de permettre aux
  portefeuilles matériels ou hors ligne de s’assurer qu’ils ne sont pas trompés pour envoyer des frais excessifs aux mineurs. Deuxièmement,
  le scriptPubKey des pièces dépensées est également inclus dans le hash---cela aide aussi à sécuriser les portefeuilles matériels et hors
  ligne en éliminant une ambiguïté actuelle sur le fait de savoir si le script dépensé est un scriptPubKey, un redeemScript P2SH, ou un
  witnessScript segwit.

- **Augmentation simplifiée des frais pour LN :** les fonds d’un canal de paiement sont protégés en partie par un contrat multisig qui exige
  que les deux parties signent tout état dans lequel le canal peut se fermer. Bien que cela fournisse une sécurité sans confiance, cela a un
  effet secondaire indésirable lié aux frais de transaction---les parties peuvent signer des états de canal des semaines ou des mois avant
  que le canal ne soit effectivement fermé, ce qui signifie qu’elles doivent deviner très à l’avance quels seront les frais de transaction.

  Rusty Russell a ouvert une [PR][simple commit PR] dans le dépôt BOLT et lancé un [fil de discussion][simple commit thread] sur la liste de
  diffusion pour obtenir des retours sur une proposition de modification de la construction et de la signature de certaines transactions LN
  afin de permettre à la fois l’augmentation de frais par [BIP125][] Replace-by-Fee (RBF) et l’augmentation de frais par
  Child-Pays-For-Parent (CPFP). Dans un [courriel de suivi][corallo simple commit], Matt Corallo a indiqué que la proposition dépend
  probablement de certaines modifications apportées aux méthodes et politiques que les nœuds utilisent pour relayer les transactions non
  confirmées.

## Questions et réponses sélectionnées de Bitcoin Stack Exchange

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}

*[Bitcoin Stack Exchange][bitcoin.se] est l'un des premiers endroits où les contributeurs d'Optech cherchent des réponses à leurs
questions---ou quand nous avons quelques moments libres pour aider les utilisateurs curieux ou confus. Dans cette rubrique mensuelle, nous
mettons en lumière certaines des questions et réponses les mieux votées postées depuis notre dernière mise à jour.*

- [Comment pourriez-vous créer une fausse signature pour prétendre être Satoshi ?][bse 81115] Gregory Maxwell pose et répond à une question
  sur la façon dont vous pourriez créer une valeur qui ressemble à une signature ECDSA correspondant à une clé publique arbitraire---comme
  une clé connue pour appartenir à Satoshi Nakamoto---mais sans avoir accès à la clé privée. Maxwell explique que c’est facile---si vous
  pouvez tromper les gens pour qu’ils omettent une partie de la procédure de vérification.

- [Comment chiffrer un message en utilisant une paire de clés Bitcoin ?][bse 80640] Pieter Wuille et Gregory Maxwell répondent chacun à une
  question sur l’utilisation des clés privées et publiques Bitcoin pour le chiffrement plutôt que pour leur usage typique de signature et de
  vérification. La réponse de Wuille fournit des détails sur le mécanisme permettant cela, mais les deux réponses avertissent les
  utilisateurs des dangers de tenter de réaliser du chiffrement avec des clés et des outils destinés à un usage non chiffré avec Bitcoin.

- [Qu’est-ce que l’épinglage de transaction ?][bse 80804] John Newbery pose et répond à une question sur le terme *transaction pinning*. Sa
  définition décrit une manière de rendre prohibitivement coûteuse l’augmentation des frais même d’une petite transaction signalant l’option
  Replace-by-Fee (RBF). (L’épinglage de transaction peut créer des problèmes pour des protocoles comme LN où la sécurité dépend de la
  confirmation de certaines transactions dans un certain délai.)

- [Qu’est-ce qui rend efficace la vérification par lot des signatures Schnorr ?][bse 80702] Pieter Wuille fournit une explication simple de
  la façon dont il est possible d’effectuer simultanément plusieurs opérations de multiplication sur une courbe elliptique. Cela peut être
  significativement plus rapide que d’effectuer une seule multiplication en série, permettant de vérifier plusieurs signatures ensemble plus
  rapidement qu’elles ne pourraient l’être individuellement.

## Changements notables dans le code

*Changements notables dans le code cette semaine dans [Bitcoin Core][bitcoin core repo], [LND][lnd repo], [C-lightning][core lightning
repo], et [libsecp256k1][libsecp256k1 repo].*

- [Bitcoin Core #14708][] affiche un avertissement lorsque des noms de section non reconnus sont utilisés dans le fichier de configuration
  `bitcoin.conf`. Par exemple, si vous créez le fichier de configuration suivant en utilisant le nom `testnet` au lieu du nom correct
  `test`, Bitcoin Core ignorait auparavant silencieusement les options testnet. Cette PR fusionnée conduit désormais à l’affichage d’un avis
  : « Warning: Section [testnet] is not recognized. »

  ```toml
  [testnet]
  txindex = 1
  ```
- [C-Lightning #2087][] ajoute de nouveaux champs aux résultats du RPC `getinfo` pour le nombre de pairs du nœud, le nombre de canaux en
  attente, le nombre de canaux actifs, et le nombre de canaux inactifs. Cela correspond désormais aux informations affichées par le RPC
  `getinfo` de LND.

- [C-Lightning #2096][] retire le texte préfixé `lightning:` d’une facture [BOLT11][] avant de tenter de la traiter. Ce texte est parfois
  ajouté afin que les portefeuilles LN puissent s’enregistrer comme gestionnaires d’URI. Le texte de préfixe sera retiré s’il est
  entièrement en minuscules ou entièrement en majuscules (mais pas en casse mixte) conformément à la spécification bech32 de [BIP173][].

- [C-Lightning #2081][] et [#2092][c-lightning #2092] corrigent un problème lié à l’exécution de plusieurs commandes RPC en parallèle. Comme
  changement visible par l’utilisateur, `lightningd` ajoute désormais une double fin de ligne (`\n\n`) au lieu d’une simple fin de ligne à
  la sortie finale d’un RPC. Comme de simples fins de ligne peuvent être utilisées ailleurs dans la sortie RPC, terminer par une double fin
  de ligne permet à un analyseur non JSON de trouver facilement la fin des résultats d’un appel RPC et le début des résultats d’un appel
  suivant lorsque la même socket est utilisée pour les deux.

- [Bitcoin Core #14756][] ajoute la capacité pour le script `rpcauth.py` de accepter un mot de passe sur stdin plutôt qu’en paramètre de
  ligne de commande qui pourrait être stocké dans l’historique du shell. Ce script est la méthode préférée pour générer des identifiants de
  connexion pour l’accès RPC lorsqu’on n’utilise pas `bitcoin-cli` en tant que même utilisateur ayant démarré le démon `bitcoind`.

- [Bitcoin Core #14532][] modifie les paramètres utilisés pour lier le port RPC de Bitcoin Core à autre chose que la valeur par défaut
  (localhost). Auparavant, utiliser l’option de configuration `-rpcallowip` amenait Bitcoin Core à écouter sur toutes les interfaces (tout
  en n’acceptant toujours que les connexions des adresses IP autorisées) ; désormais, l’option de configuration `-rpcbind` doit également
  être passée afin de spécifier les adresses d’écoute. De nouveaux avertissements sont affichés pour des configurations improbables et pour
  avertir les utilisateurs du danger d’écouter sur des réseaux non fiables. On espère que ce changement contribuera à réduire le nombre de
  nœuds à l’écoute de connexions RPC sur des interfaces publiques, dont le danger a été décrit dans la section *Nouvelles* du [bulletin #18][].

- [C-Lightning #2095][] applique les montants maximaux de [BOLT2][] pour la valeur des canaux et des paiements après qu’il a été découvert
  que C-Lightning ne respectait pas ces limites. Un changement futur prendra probablement en charge un bit wumbo optionnel (bit jumbo) qui
  permet au nœud de négocier des canaux et montants de paiement extra-larges.

{% include references.md %}
{% include linkers/issues.md issues="14708,2087,2096,2081,2092,14756,14532,2095" %}

{% assign bse = "https://bitcoin.stackexchange.com/a/" %}
[bse 81115]: {{bse}}81115
[bse 80640]: {{bse}}80640
[bse 80804]: {{bse}}80804
[bse 80702]: {{bse}}80702

[wuille sighash]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-November/016488.html
[simple commit PR]: https://github.com/lightningnetwork/lightning-rfc/pull/513
[simple commit thread]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-November/001643.html
[corallo simple commit]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-November/001666.html
[bulletin #18]: /fr/newsletters/2018/10/23/#plus-de-1-100-noeuds-a-l-ecoute-ont-des-ports-rpc-ouverts
