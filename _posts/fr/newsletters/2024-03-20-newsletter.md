---
title: 'Bulletin Hebdomadaire Bitcoin Optech #294'
permalink: /fr/newsletters/2024/03/20/
name: 2024-03-20-newsletter-fr
slug: 2024-03-20-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine annonce un projet de création d'un proxy BIP324 pour les clients
légers et résume les discussions autour d'une proposition de langage BTC Lisp. Sont également incluses nos sections
régulières décrivant les mises à jour des clients et services, avec les annonces de nouvelles versions et les changements
apportés aux principaux logiciels d'infrastructure Bitcoin.

## Actualités

- **Proxy BIP324 pour clients légers :** Sebastian Falbesoner a [publié][falbesoner bip324] sur
  Delving Bitcoin pour annoncer un proxy TCP pour la traduction entre la version 1 (v1) du protocole
  P2P Bitcoin et le [protocole v2][topic v2 p2p transport] défini dans le [BIP324][]. Ceci est
  particulièrement destiné à permettre aux portefeuilles clients légers écrits pour v1 de tirer
  avantage du chiffrement du trafic de v2.

  Les clients légers annoncent typiquement uniquement les transactions appartenant à leurs propres
  portefeuilles, donc toute personne capable d'intercepter une connexion v1 non chiffrée peut
  raisonnablement conclure qu'une transaction envoyée par un client léger appartient à quelqu'un
  utilisant l'adresse IP d'origine. Lorsque le chiffrement v2 est utilisé, seuls les nœuds complets
  recevant la transaction seront capables d'identifier définitivement qu'elle provient de l'adresse IP
  du client léger, en supposant qu'aucune des connexions du client léger ne soit sujette à une attaque
  de l'homme du milieu (ce qui est possible à détecter dans certains cas et contre lequel les [mises à
  jour ultérieures][topic countersign] peuvent se défendre automatiquement).

  Le travail initial de Falbesoner rassemble les fonctions BIP324 écrites en Python pour la suite de
  tests de Bitcoin Core, ce qui résulte en un proxy qui est "terriblement lent et vulnérable aux
  attaques par canal auxiliaire [et] il n'est pas recommandé de l'utiliser pour autre chose que des
  tests pour le moment". Cependant, il travaille sur la réécriture du proxy en Rust et pourrait
  également rendre certaines ou toutes ses fonctions disponibles sous forme de bibliothèque pour les
  clients légers ou d'autres logiciels souhaitant supporter nativement le protocole P2P Bitcoin v2.

- **Aperçu de BTC Lisp :** Anthony Towns a [publié][towns lisp] sur Delving Bitcoin à propos de ses
  expériences au cours des deux dernières années créant une variante du langage [Lisp][] pour Bitcoin,
  appelée BTC Lisp. Voir les Bulletins [#293][news293 lisp] et [#191][news191 lisp] pour les
  discussions précédentes. Le post entre dans des détails significatifs ; nous encourageons toute
  personne intéressée par l'idée à le lire directement. Nous citerons brièvement ses sections
  _conclusion_ et _travaux futurs_ :

  "[BTC Lisp] peut être un peu coûteux on-chain, mais il semble que vous pouvez faire à peu près
  n'importe quoi [...] Je ne pense pas que l'implémentation d'un interpréteur Lisp ou le paquet
  d'opcodes qui devrait l'accompagner soit trop difficile [mais] c'est assez ennuyeux d'écrire du code
  Lisp sans un compilateur traduisant d'une représentation de niveau supérieur vers les opcodes de
  niveau consensus, [bien que] cela semble soluble. Ceci pourrait être poussé plus loin [en]
  implémentant un langage comme celui-ci et en le déployant sur signet/inquisition."

  Russell O'Connor, développeur du langage [Simplicity][topic simplicity] qui pourrait également un
  jour être considéré comme une alternative au langage de script de consensus, a [répondu][oconnor
  lisp] avec certaines comparaisons entre le langage Script actuel de Bitcoin, Simplicity, et Chia/BTC
  Lisp. Il conclut, "Simplicity et le clvm [Chia Lisp Virtual Machine] sont tous deux des langages de
  bas niveau destinés à être facilement évaluables par les machines, ce qui entraîne des compromis les
  rendant difficiles à lire pour les humains. Ils sont destinés à être compilés à partir de certains
  langages non critiques pour le consensus, lisibles par l'homme. Simplicity et le clvm sont
  différentes manières d'exprimer les mêmes vieilles choses : récupérer des données d'un
  environnement, regrouper des morceaux de données, exécuter des instructions conditionnelles, et
  toute une série d'opérations primitives de certains types. [...] Puisque nous voulons cette
  [séparation entre un langage de consensus de bas niveau efficace et un langage compréhensible de
  haut niveau non-consensus] de toute façon, les détails du langage de bas niveau deviennent quelque
  peu moins importants. C'est-à-dire, avec un certain effort, votre langage lisp BTC de haut niveau
  pourrait probablement être traduit/compilé en Simplicity [...] De même, où que la conception de
  [Simplicity-based] Simphony [langage non-consensus de haut niveau] finisse, elle peut probablement
  être traduite/compilée [en] votre langage lisp BTC de bas niveau, chaque paire de langues
  traducteur/compilateur offrant différentes opportunités potentielles de complexité/optimisation."

## Modifications apportées aux services et aux logiciels clients

*Dans cette rubrique mensuelle, nous mettons en évidence les mises à jour
intéressantes des portefeuilles et services Bitcoin.*

- **BitGo ajoute le support RBF :**
  Dans un [blog récent][bitgo blog], BitGo a annoncé le support du bumping de frais en utilisant
  [replace-by-fee (RBF)][topic rbf] dans leur portefeuille et API.

- **Phoenix Wallet v2.2.0 publié :**
  Avec cette version, Phoenix peut désormais supporter les [splices][topic splicing] tout en
  effectuant des paiements LN en utilisant le protocole de quiescence (voir le [Bulletin #262][news262
  eclair2680]). De plus, Phoenix a amélioré la confidentialité et les frais de la fonctionnalité de
  swap-in en utilisant leur protocole [swaproot][swaproot blog].

- **Dispositif de signature matériel Bitkey publié :**
  Le dispositif [Bitkey][bitkey website] est conçu pour être utilisé dans une configuration multisig
  2-de-3 avec un appareil mobile et une clé serveur Bitkey. Le code source du firmware et de divers
  composants est [disponible][bitkey github] sous une licence MIT modifiée par une clause Commons.

- **Envoy v1.6.0 publié :**
  La [publication][envoy blog] ajoute des fonctionnalités pour le bumping de frais des transactions
  ainsi que l'annulation des transactions, toutes deux activées en utilisant replace-by-fee (RBF).

- **VLS v0.11.0 publié :**
  La [version bêta][vls beta 3] permet plusieurs dispositifs de signature pour le même nœud Lightning,
  une fonctionnalité qu'ils appellent [tag team signing][vls blog].

- **Dispositif de signature matériel Portal annoncé :**
  Le dispositif Portal récemment annoncé fonctionne avec les smartphones en utilisant NFC, avec le
  matériel et le logiciel source [disponibles][portal github].

- **Le pool de minage Braiins ajoute le support Lightning :**
  Le pool de minage Braiins a [annoncé][braiins tweet] une bêta pour les paiements de minage via
  Lightning.

- **Ledger Bitcoin App 2.2.0 lancé :**
  La [version 2.2.0][ledger 2.2.0] ajoute le support de [miniscript][topic miniscript]
  pour [taproot][topic taproot].

## Mises à jour et versions candidates

*Nouvelles versions et versions candidates pour les principaux projets
d'infrastructure Bitcoin. Veuillez envisager de passer aux nouvelles
versions ou d'aider à tester les versions candidates.*

- [Bitcoin Core 26.1rc2][] est un candidat à la sortie pour une version de maintenance
  de l'implémentation de nœud complet prédominante du réseau.

- [Bitcoin Core 27.0rc1][] est un candidat à la sortie pour la prochaine version majeure
  de l'implémentation de nœud complet prédominante du réseau.

## Changements notables dans le code et la documentation

_Changements notables cette semaine dans [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Interface de Portefeuille Matériel (HWI)][hwi
repo], [Rust Bitcoin][rust bitcoin repo], [Serveur BTCPay][btcpay server repo], [BDK][bdk repo],
[Propositions d'Amélioration de Bitcoin (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Inquisition Bitcoin][bitcoin inquisition repo], et [BINANAs][binana
repo]._

*Note : les commits sur Bitcoin Core mentionnés ci-dessous s'appliquent à sa branche de
développement principale et donc ces changements ne seront probablement pas publiés
jusqu'à environ six mois après la sortie de la version à venir 27.*

- [Bitcoin Core #27375][] ajoute le support aux fonctionnalités `-proxy` et `-onion`
  pour utiliser des sockets de domaine Unix plutôt que des ports TCP locaux.
  Les sockets peuvent être plus rapides que les ports TCP et offrir différents compromis de sécurité.

- [Bitcoin Core #27114][] permet d'ajouter "in" et "out" au paramètre de configuration
  `whitelist` pour donner un accès spécial à des connexions _entrantes_ et _sortantes_ particulières.
  Par défaut, un pair listé dans la whitelist ne recevra un accès spécial que lorsqu'il
  se connecte au nœud local de l'utilisateur (une connexion entrante). En spécifiant "out",
  l'utilisateur peut maintenant s'assurer qu'un pair reçoit un accès spécial si le nœud local se
  connecte à lui, comme lorsque l'utilisateur appelle le RPC `addnode`.

- [Bitcoin Core #29306][] ajoute [l'éviction de frères et sœurs][topic kindred
  rbf] pour les transactions descendantes d'un [parent non confirmé v3][topic v3 transaction relay].
  Cela peut fournir une alternative satisfaisante à [CPFP carve-out][topic cpfp carve out], qui est
  actuellement utilisé par [les sorties d'ancrage LN][topic anchor outputs].
  Le relais de transactions V3, y compris l'éviction de frères et sœurs, n'est actuellement pas activé
  pour le mainnet.

- [LND #8310][] permet aux paramètres de configuration `rpcuser` et `rpcpass` (mot de passe) d'être
  récupérés depuis l'environnement système. Cela peut permettre, par exemple, de gérer un fichier
  `lnd.conf` en utilisant un système de contrôle de révision non privé sans stocker le nom
  d'utilisateur et le mot de passe privés.

- [Rust Bitcoin #2458][] ajoute le support pour la signature de [PSBTs][topic psbt] qui incluent des
  entrées taproot.

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="27375,27114,29306,8310,2458" %}
[bitcoin core 26.1rc2]: https://bitcoincore.org/bin/bitcoin-core-26.1/
[Bitcoin Core 27.0rc1]: https://bitcoincore.org/bin/bitcoin-core-27.0/test.rc1/
[lisp]: https://en.wikipedia.org/wiki/Lisp_(programming_language)
[news293 lisp]: /fr/newsletters/2024/03/13/#apercu-de-chia-lisp-pour-les-bitcoiners
[news191 lisp]: /en/newsletters/2022/03/16/#using-chia-lisp
[falbesoner bip324]: https://delvingbitcoin.org/t/bip324-proxy-easy-integration-of-v2-transport-protocol-for-light-clients-poc/678
[towns lisp]: https://delvingbitcoin.org/t/btc-lisp-as-an-alternative-to-script/682
[oconnor lisp]: https://delvingbitcoin.org/t/btc-lisp-as-an-alternative-to-script/682/7
[bitgo blog]: https://blog.bitgo.com/available-now-for-clients-bitgo-introduces-replace-by-fee-f74e2593b245
[news262 eclair2680]: /fr/newsletters/2023/08/02/#eclair-2680
[swaproot blog]: https://acinq.co/blog/phoenix-swaproot
[bitkey website]: https://bitkey.world/
[bitkey github]: https://github.com/proto-at-block/bitkey
[envoy blog]: https://foundation.xyz/2024/03/envoy-version-1-6-0-is-now-live/
[vls beta 3]: https://gitlab.com/lightning-signer/validating-lightning-signer/-/releases/v0.11.0
[vls blog]: https://vls.tech/posts/tag-team/
[portal tweet]: https://twitter.com/afilini/status/1766085500106920268
[portal github]: https://github.com/TwentyTwoHW
[braiins tweet]: https://twitter.com/BraiinsMining/status/1760319741560856983
[ledger 2.2.0]: https://github.com/LedgerHQ/app-bitcoin-new/releases/tag/2.2.0