---
title: 'Bulletin Hebdomadaire Bitcoin Optech #297'
permalink: /fr/newsletters/2024/04/10/
name: 2024-04-10-newsletter-fr
slug: 2024-04-10-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine annonce un nouveau langage spécifique à un domaine (DSL) pour tester
les protocoles de contrat, résume une discussion sur la modification des responsabilités des
éditeurs de BIP, et décrit des propositions pour réinitialiser et modifier le testnet. Sont
également incluses nos sections habituelles avec le résumé d'une réunion du Bitcoin Core PR Review Club,
des annonces de mises à jour et versions candidates, ainsi que les changements
apportés aux principaux logiciels d'infrastructure Bitcoin.

## Nouvelles

- **DSL pour expérimenter avec les contrats :** Kulpreet Singh a [publié][singh dsl] sur Delving
  Bitcoin à propos d'un langage spécifique à un domaine (DSL) sur lequel il travaille pour Bitcoin. Le
  langage facilite la spécification des opérations qui devraient être effectuées dans le cadre d'un
  protocole de contrat. Cela peut permettre d'exécuter rapidement le contrat dans un environnement de
  test pour s'assurer qu'il se comporte comme prévu, permettant une itération rapide sur de nouvelles
  idées pour les contrats et fournissant une base par rapport à laquelle un logiciel complet peut être
  développé plus tard.

  Robin Linus a [répondu][linus dsl] avec un lien vers un projet quelque peu similaire permettant à un
  langage de niveau supérieur de décrire un protocole de contrat qui sera compilé pour les opérations
  nécessaires et le code de bas niveau pour exécuter ce protocole. Ce travail est réalisé dans le
  cadre de l'amélioration de [BitVM][topic acc].

- **Mise à jour de BIP2 :** Tim Ruffing a [posté][ruffing bip2] sur la liste de diffusion
  Bitcoin-Dev à propos de la mise à jour de [BIP2][], qui spécifie le processus actuel pour ajouter de
  nouveaux BIP et mettre à jour les BIP existants. Ruffing a soulevé plusieurs problèmes du processus actuel
  notamment :

  - *Évaluation et discrétion éditoriale :* quels efforts les éditeurs de BIP devraient-ils être tenus
    de déployer pour s'assurer que les nouveaux BIP sont de haute qualité et centrés sur Bitcoin ?
    Séparément, quelle latitude devraient-ils avoir pour pouvoir rejeter de nouveaux BIPs ? Ruffing et
    plusieurs autres ont mentionné qu'ils préféreraient minimiser les exigences et privilèges
    éditoriaux, peut-être en ne dépendant des éditeurs de BIP que pour lutter contre les abus systémiques
    (par exemple, le spam massif). Bien sûr, les éditeurs de BIP, comme tout autre membre de la
    communauté, seraient en mesure de suggérer volontairement des améliorations à toute proposition de
    BIP qu'ils trouvent intéressante.

  - *Licences :* certaines licences autorisées pour les BIP sont conçues pour le logiciel et peuvent
    ne pas avoir de sens pour la documentation.

  - *Commentaires :* en tant que changement par rapport à [BIP1][], BIP2 a tenté de fournir un espace
    pour les retours de la communauté sur chaque BIP. Cela n'a pas été largement utilisé et les
    résultats ont été controversés.

  L'idée de mettre à jour BIP2 était encore en discussion au moment de la rédaction de cet article.

  Dans une autre discussion liée à ce sujet, la nomination et le plaidoyer pour de nouveaux éditeurs de
  BIP mentionnés dans [le bulletin de la semaine dernière][news296 editors] ont été
  [prolongés][erhardt editors] jusqu'à la fin de journée UTC le vendredi 19 avril. Il est espéré que
  les nouveaux éditeurs recevront l'accès à la fusion d'ici la fin de journée du lundi suivant.

- **Discussion sur la réinitialisation et la modification du testnet :** Jameson Lopp a
  [évoqué][lopp testnet], sur la liste de diffusion Bitcoin-Dev, les problèmes avec le testnet
  public actuel de Bitcoin (testnet3) et a suggéré de le redémarrer, potentiellement avec un ensemble
  différent de règles de consensus pour des cas particuliers.

  Les versions précédentes du testnet ont dû être redémarrées lorsque certaines personnes ont commencé
  à attribuer une valeur économique aux pièces du testnet, ce qui a rendu leur acquisition gratuite
  difficile pour ceux qui souhaitaient effectuer des tests réels. Lopp a fourni des preuves que cela
  se produisait à nouveau et a également décrit le problème bien connu de l'inondation de blocs due à
  l'exploitation de l'algorithme d'ajustement de difficulté personnalisé du testnet. Plusieurs
  personnes ont discuté des changements potentiels à apporter au testnet pour résoudre ce problème et
  d'autres, bien qu'au moins un répondant ait [préféré][kim testnet] permettre la continuation des
  problèmes car cela rendait les tests intéressants.

## Bitcoin Core PR Review Club

*Dans cette section mensuelle, nous résumons une récente réunion du
[Bitcoin Core PR Review Club][] en soulignant certaines des questions
et réponses importantes. Cliquez sur une question ci-dessous pour voir
un résumé de la réponse de la réunion.*

[Implémenter des opcodes arithmétiques de 64 bits dans l'interpréteur de Script][review club 29221]
est une PR de Chris Stewart (GitHub Christewart) qui introduit de nouveaux opcodes permettant aux
utilisateurs d'effectuer des opérations arithmétiques sur des opérandes plus grands (64 bits) dans
le Script Bitcoin que ce qui est actuellement autorisé (32 bits).

Ce changement, combiné à certaines propositions de soft fork existantes comme [OP_TLUV][ml OP_TLUV]
qui permettent l'introspection des transactions, permettrait aux utilisateurs de construire une
logique de script basée sur les valeurs de sortie des transactions en satoshis, qui peuvent
facilement dépasser un entier de 32 bits.

La discussion sur l'approche, comme la question de savoir s'il faut mettre à niveau les opcodes
existants ou en introduire de nouveaux (par exemple, `OP_ADD64`), est toujours en cours.

Pour plus d'informations, consultez le (WIP) [BIP][bip 64bit arithmetic], et la [discussion][delving
64bit arithmetic] sur le forum Delving Bitcoin.

{% include functions/details-list.md q0="Que fait le paramètre `nMaxNumSize` de `CScriptNum`?"
  a0="Il représente la taille maximale (en octets) de l'élément de pile `CScriptNum` en cours
  d'évaluation. Par défaut, il est réglé sur 4 octets."
  a0link="https://bitcoincore.reviews/29221#l-34"

  q1="Quels sont les 2 opcodes qui acceptent des entrées numériques de 5 octets?"
  a1="`OP_CHECKSEQUENCEVERIFY` et `OP_CHECKLOCKTIMEVERIFY` utilisent des entiers signés pour
  représenter les horodatages. En utilisant 4 octets, cela placerait la plage supérieure des dates
  autorisées en 2038. Pour cette raison, une exception a été faite pour ces 2 opcodes basés sur le
  temps pour accepter des entrées de 5 octets. Cela est documenté [dans le code][docs 5byte
  carveout]."
  a1link="https://bitcoincore.reviews/29221#l-45"

  q2="Pourquoi le drapeau `fRequireMinimal` a-t-il été introduit dans `CScriptNum`?"
  a2="`CScriptNum` a un encodage de longueur variable. Comme décrit dans [BIP62][] (règle 4), cela
  introduit une opportunité pour la malléabilité. Par exemple, zéro peut être codé comme `OP_0`,
  `0x00`, `0x0000`, ... [Bitcoin
  Core #5065][] a corrigé cela dans les transactions standard [en exigeant][doc
  SCRIPT_VERIFY_MINIMALDATA] une représentation minimale pour les poussées de données et les éléments
  de pile qui représentent des nombres." a2link="https://bitcoincore.reviews/29221#l-57"

  q3="L'implémentation dans cette PR est-elle sécurisée contre la malléabilité ? Pourquoi ?"
  a3="L'implémentation actuelle nécessite une représentation à longueur fixe de 8 octets pour les
  opérandes d'un opcode 64 bits, la rendant sûre contre la malléabilité par ajout de zéros. La raison
  est de simplifier la logique d'implémentation, au coût d'une utilisation accrue de l'espace de bloc.
L'auteur a également exploré l'utilisation d'un encodage variable `CScriptNum` dans [une autre
branche][64bit arith cscriptnum]."
a3link="https://bitcoincore.reviews/29221#l-67" %}

## Mises à jour et versions candidates

*Nouvelles versions et versions candidates pour les principaux projets
d'infrastructure Bitcoin. Veuillez envisager de passer aux nouvelles
versions ou d'aider à tester les versions candidates.*

- [HWI 3.0.0][] est une sortie de la prochaine version de ce paquet fournissant une interface
  commune à plusieurs dispositifs de signature matérielle différents. Le seul changement significatif
  dans cette sortie est que les portefeuilles matériels émulés ne seront plus détectés automatiquement ;
  voir la description de [HWI #729][] ci-dessous pour plus de détails.

- [Core Lightning 24.02.2][] est une sortie de maintenance qui corrige "une [petite
  incompatibilité][core lightning #7174]" entre l'implémentation par Core Lightning et celle par LDK
  d'une partie particulière du protocole de gossip LN.

- [Bitcoin Core 27.0rc1][] est un candidat à la sortie pour la prochaine version majeure de
  l'implémentation de nœud complet prédominante du réseau. Les testeurs sont encouragés à examiner la
  liste des [sujets de test suggérés][bcc testing].

## Changements notables dans le code et la documentation

_Changements notables cette semaine dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core
lightning repo], [Eclair][eclair repo], [LDK][ldk repo], [LND][lnd repo],
[libsecp256k1][libsecp256k1 repo], [Interface de Portefeuille Matériel (HWI)][hwi repo], [Rust
Bitcoin][rust bitcoin repo], [Serveur BTCPay][btcpay server repo], [BDK][bdk repo], [Propositions
d'Amélioration de Bitcoin (BIPs)][bips repo], [Lightning BOLTs][bolts repo], [Inquisition
Bitcoin][bitcoin inquisition repo], et [BINANAs][binana repo]._

*Note : les commits sur Bitcoin Core mentionnés ci-dessous s'appliquent à sa branche de
développement principale et donc ces changements ne seront probablement pas publiés avant environ
six mois après la sortie de la version à venir 27.*

- [Bitcoin Core #29648][] supprime libconsensus après qu'il ait été précédemment déprécié (voir le
  [Bulletin #288][news288 libconsensus]). Libconsensus était une tentative de rendre la logique de
  consensus de Bitcoin Core utilisable dans d'autres logiciels. Cependant, la bibliothèque n'a pas vu
  d'adoption significative et elle est devenue un fardeau pour la maintenance de Bitcoin Core.

- [Bitcoin Core #29130][] ajoute deux nouveaux RPC. Le premier générera un [descripteur][topic
  descriptors] pour un utilisateur basé sur les paramètres qu'ils souhaitent et ajoutera ensuite ce
  descripteur à leur portefeuille. Par exemple, la commande suivante
  ajoutera le support de [taproot][topic taproot] à un ancien portefeuille créé sans ce support :

  ```
  bitcoin-cli --rpcwallet=mywallet createwalletdescriptor bech32m
  ```

  La seconde RPC est `gethdkeys` (obtenir les clés [HD][topic bip32]), qui retournera chaque xpub
  utilisé par le portefeuille et (optionnellement) chaque xpriv. Lorsqu'un portefeuille contient
  plusieurs xpubs, celui à utiliser peut être indiqué lors de l'appel à `createwalletdescriptor`.

- [LND #8159][] et [#8160][lnd #8160] ajoutent un support expérimental (désactivé par défaut) pour
  l'envoi de paiements vers des [routes masquées][topic rv routing]. Un [PR de suivi][lnd #8485]
  devrait ajouter une gestion complète des erreurs pour les paiements masqués échoués.

- [LND #8515][] met à jour plusieurs RPC pour accepter le nom de la [stratégie de sélection de
  pièces][topic coin selection] à utiliser. Voir le [Bulletin #292][news292 lndcs] pour les
  améliorations précédentes de la flexibilité de la sélection de pièces de LND sur laquelle ce PR se
  base.

- [LND #6703][] et [#6934][lnd #6934] ajoutent le support des frais de routage entrants. Un nœud
  peut déjà annoncer le coût qu'il facturera pour transférer un paiement via un canal sortant
  particulier. Par exemple, Carol pourrait annoncer qu'elle ne transférera les paiements à son pair de
  canal Dan que si les paiements lui offrent 0,1 % de leur valeur. Si cela réduit le nombre moyen de
  satoshis (sats) par minute que Carol transfère à Dan en dessous de la quantité moyenne qu'il lui
  transfère, éventuellement tout le solde du canal finira du côté de Carol, empêchant Dan de pouvoir
  transférer plus de paiements vers elle, réduisant ainsi le potentiel de revenus de chacun. Pour
  éviter cela, Carol pourrait baisser ses frais de transfert sortant vers Dan à 0,05 %. De même, si
  les frais de transfert sortant plus bas de Carol vers Dan résultent en elle transférant plus de sats
  par minute à lui qu'il ne lui en transfère, tout le solde pourrait finir de son côté du canal,
  empêchant également des transferts supplémentaires et la génération de revenus ; dans ce cas, Carol
  peut augmenter ses frais de transfert sortant.

  Cependant, les frais sortants ne s'appliquent qu'aux canaux sortants. Carol propose de facturer le
  même tarif quel que soit le canal par lequel elle reçoit le paiement ; par exemple, elle facture le
  même taux qu'elle reçoive le paiement de l'un de ses pairs de canal Alice ou Bob :

  ```
  Alice -> Carol -> Dan
  Bob -> Carol -> Dan
  ```

  Cela a du sens puisque le protocole de base LN ne rémunère pas Carol pour avoir reçu une demande de
  transfert d'Alice ou de Bob. Alice et Bob peuvent fixer des frais sortants pour leurs canaux vers
  Carol, et c'est à eux de fixer des frais qui aident à maintenir les canaux liquides. De même, Carol
  peut ajuster ses frais pour les paiements sortants vers Alice et Bob (par exemple, `Dan -> Carol ->
  Bob`) pour aider à gérer la liquidité.

  Cependant, Carol peut vouloir plus de contrôle sur les politiques qui l'affectent. Par exemple, si
  le nœud d'Alice est mal géré, elle pourrait fréquemment transférer des paiements à Carol sans que
  beaucoup de gens veuillent ensuite transférer des paiements de Carol à Alice. Cela finirait
  éventuellement avec tout les fonds dans leur canal finissant du côté de Carol,
  empêchant ainsi tout paiement ultérieur dans
  cette direction. Avant ce PR, Carol ne pouvait rien faire à ce sujet, sauf fermer son canal avec
  Alice avant qu'il ne gaspille trop la valeur du capital de Carol.

  Avec ce PR, Carol peut désormais également facturer des _frais de transfert entrant_ spécifiques à
  chaque canal. Par exemple, elle pourrait facturer des frais élevés pour les paiements arrivant en
  entrée du nœud problématique d'Alice, mais des frais plus bas pour les paiements provenant du nœud
  hautement liquide de Bob. Les frais entrants initiaux sont censés être toujours négatifs pour être
  compatibles avec les anciens nœuds qui ne comprennent pas les frais entrants ; par exemple, Carol
  pourrait offrir une remise de 10 % sur les paiements transférés par Bob et une remise de 0 % sur les
  paiements transférés par Alice.

  Les frais sont évalués simultanément avec les frais sortants. Par exemple, lorsque Alice propose un
  paiement à Carol pour le transférer à Dan, Carol calcule le frais original `dan_outbound`, calcule
  le nouveau frais `alice_inbound`, et s'assure que le paiement transféré lui offre au moins la somme
  des deux. Sinon, elle rejette le [HTLC][topic htlc]. Étant donné que les frais entrants initiaux
  sont toujours censés être négatifs, Carol ne rejettera aucun paiement qui paie des frais sortants
  suffisants, mais tout nœud qui est maintenant conscient des frais entrants pourrait être en mesure
  de recevoir une remise.

  Les frais de routage entrants ont été [proposés][bolts #835] il y a environ trois ans,
  [discutés][jager inbound] sur la liste de diffusion Lightning-Dev il y a environ deux ans, et
  documentés dans le brouillon [BLIPs #18][] également il y a environ deux ans. Depuis sa proposition
  initiale, plusieurs mainteneurs d'implémentations LN autres que LND s'y sont opposés. Certains s'y
  sont opposés par [principe][teinturier bolts835] ; d'autres ont critiqué sa conception comme étant
  [trop spécifique à LND][corallo overly specific] plutôt qu'une mise à niveau locale et générique qui
  peut immédiatement utiliser des frais de transfert entrants positifs et ne nécessite pas l'annonce
  globale de détails de frais supplémentaires pour chaque canal. Une approche alternative est proposée
  dans le brouillon [BLIPs #22][]. Nous ne connaissons qu'un seul mainteneur d'une implémentation
  non-LND [indiquant][corallo free money] qu'ils adopteront la méthode de LND---et seulement dans les
  cas où des frais de transfert entrants négatifs sont proposés, car c'est "de l'argent gratuit pour
  nos utilisateurs."

- [Rust Bitcoin #2652][] modifie quelle clé publique est retournée par l'API lors de la signature
  d'une entrée [taproot][topic taproot] dans le cadre du traitement d'un [PSBT][topic psbt].
  Auparavant, l'API retournait la clé publique pour la clé privée de signature. Cependant, le PR note
  que "il est courant de penser que la clé interne est celle qui signe même si cela n'est pas
  techniquement vrai. Nous avons également la clé interne dans le PSBT." Avec la fusion de ce PR,
  l'API retourne maintenant la clé interne.

- [HWI #729][] arrête d'automatiquement énumérer et utiliser les émulateurs de dispositifs. Les
  émulateurs sont principalement utilisés par les développeurs de HWI et les portefeuilles matériels,
  mais tenter de les détecter automatiquement peut causer des problèmes pour les utilisateurs
  réguliers. Les développeurs qui souhaitent travailler avec
  les émulateurs doivent désormais passer une option supplémentaire `--emulators`.

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 16:00" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="729,29648,29130,8159,8160,8485,8515,6703,6934,835,18,22,2652,7174,5065" %}
[bcc testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/27.0-Release-Candidate-Testing-Guide
[Bitcoin Core 27.0rc1]: https://bitcoincore.org/bin/bitcoin-core-27.0/test.rc1/
[HWI 3.0.0]: https://github.com/bitcoin-core/HWI/releases/tag/3.0.0
[Core Lightning 24.02.2]: https://github.com/ElementsProject/lightning/releases/tag/v24.02.2
[news292 lndcs]: /fr/newsletters/2024/03/06/#lnd-8378
[news288 libconsensus]: /fr/newsletters/2024/02/07/#bitcoin-core-29189
[teinturier bolts835]: https://github.com/lightning/bolts/issues/835#issuecomment-764779287
[corallo free money]: https://github.com/lightning/blips/pull/18#issuecomment-1304319234
[corallo overly specific]: https://github.com/lightningnetwork/lnd/pull/6703#issuecomment-1374694283
[jager inbound]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-July/003643.html
[singh dsl]: https://delvingbitcoin.org/t/dsl-for-experimenting-with-contracts/748
[linus dsl]: https://delvingbitcoin.org/t/dsl-for-experimenting-with-contracts/748/4
[ruffing bip2]: https://gnusha.org/pi/bitcoindev/59fa94cea6f70e02b1ce0da07ae230670730171c.camel@timruffing.de/
[news296 editors]: /fr/newsletters/2024/04/03/#choisir-de-nouveaux-editeurs-bip
[erhardt editors]: https://gnusha.org/pi/bitcoindev/c304a456-b15f-4544-8f86-d4a17fb0aa8c@murch.one/
[lopp testnet]: https://gnusha.org/pi/bitcoindev/CADL_X_eXjbRFROuJU0b336vPVy5Q2RJvhcx64NSNPH-3fDCUfw@mail.gmail.com/
[kim testnet]: https://gnusha.org/pi/bitcoindev/950b875a-e430-4bd8-870d-f9a9fab2493an@googlegroups.com/
[review club 29221]: https://bitcoincore.reviews/29221
[delving 64bit arithmetic]: https://delvingbitcoin.org/t/64-bit-arithmetic-soft-fork/397
[bip 64bit arithmetic]: https://github.com/bitcoin/bips/pull/1538
[64bit arith cscriptnum]: https://github.com/Christewart/bitcoin/tree/64bit-arith-cscriptnum
[docs 5byte carveout]: https://github.com/bitcoin/bitcoin/blob/3206e45412ded0e70c1f15ba66c2ba3b4426f27f/src/script/interpreter.cpp#L531-L544
[doc SCRIPT_VERIFY_MINIMALDATA]: https://github.com/bitcoin/bitcoin/blob/3206e45412ded0e70c1f15ba66c2ba3b4426f27f/src/script/interpreter.h#L69-L73
[ml OP_TLUV]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-September/019419.html
