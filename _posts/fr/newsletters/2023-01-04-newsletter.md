---
title: 'Bitcoin Optech Newsletter #232'
permalink: /fr/newsletters/2023/01/04/
name: 2023-01-04-newsletter-fr
slug: 2023-01-04-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Cette semaine le bulletin d'information met en garde les utilisateurs de
Bitcoin Knots contre une compromission de la clé de signature de la version,
annonce la publication de deux forks logiciels de Bitcoin Core et résume la
suite de la discussion sur les politiques de remplacement par des frais. Vous
trouverez également nos sections habituelles avec les annonces de nouvelles
versions de logiciels et de versions candidates, ainsi que des descriptions
de changements significatifs dans les logiciels d'infrastructure
Bitcoin les plus répandus.

## Nouvelles

- **La clé de signature de Bitcoin Knots est compromise:** le responsable de
  l'implémentation de nœuds Bitcoin Knots a annoncé la compromission de la clé
  PGP qu'il utilise pour signer les versions de Knots. Il dit : "ne téléchargez
  pas Bitcoin Knots et ne lui faites pas confiance jusqu'à ce que ce problème
  soit résolu. Si vous l'avez déjà fait au cours des derniers mois, envisagez
  de fermer ce système pour le moment."

  <!-- https://web.archive.org/web/20230103220745/https://twitter.com/LukeDashjr/status/1609763079423655938 -->

  Les autres implémentations de nœuds complets ne sont pas affectées.

- **Forks logiciels de Bitcoin Core:** Le mois dernier, deux ensembles
  de correctifs ont été publiés pour compléter Bitcoin Core :

    - *Bitcoin Inquisition :* Anthony Towns a [annoncé][towns bci] à
      la liste de diffusion Bitcoin-Dev une version de [Bitcoin Inquisition][],
      un fork logiciel de Bitcoin Core conçu pour être utilisé sur le [signet][topic signet]
      par défaut pour tester les soft forks proposés et d'autres changements
      de protocole importants. Cette version contient le support des propositions
      [SIGHASH_ANYPREVOUT][topic sighash_anyprevout] et [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify].
      Le courriel de Towns comprend également des informations supplémentaires
      qui seront utiles à toute personne participant aux tests de signet.

    - *Noeud d'appairage Full-RBF :* Peter Todd [a annoncé][todd rbf node]
      un patch sur Bitcoin Core 24.0.1 qui active un [bit de service full-RBF][]
      lorsqu'il annonce son adresse réseau à d'autres nœuds, mais seulement
      si le nœud est configuré avec `mempoolfullrbf` activé. Les nœuds qui
      exécutent le correctif se connectent également à un maximum de quatre
      pairs supplémentaires qui avaient annoncé qu'ils prenaient en charge
      full-RBF. Peter Todd note que Bitcoin Knots, une autre implémentation
      de nœuds complets, annonce également le bit de service, bien qu'il ne
      contienne pas de code pour se connecter spécifiquement à des nœuds
      annonçant le support de full-RBF. Le correctif est basé sur le Bitcoin
      Core PR [#25600] [bitcoin core #25600].

- **Suite de la discussion autour de RBF :** Dans la discussion en cours
  sur l'activation de [full-RBF][topic rbf] sur le réseau principal,
  plusieurs discussions parallèles ont eu lieu le mois dernier sur la
  liste de diffusion :

    - *Noeuds Full-RBF :* Peter Todd a sondé les nœuds complets qui
      annonçaient qu'ils exécutaient Bitcoin Core 24.x et acceptaient
      les connexions entrantes sur une adresse IPv4.  Il a constaté][todd probe]
      qu'environ 17 % d'entre eux relayaient un remplacement complet
      de RBF : une transaction qui remplaçait une transaction qui ne
      contenait pas le signal [BIP125][]. Cela suggère que ces noeuds
      fonctionnaient avec l'option de configuration `mempoolfullrbf`
      définie sur `true`, même si l'option est définie par défaut
      sur `false`.

    - *Réexamen du RBF-FSS:*  Daniel Lipshitz [a posté][lipshitz fss]
      sur la liste de diffusion Bitcoin-Dev une idée pour un type de
      remplacement de transaction appelé First Seen Safe (FSS) où le
      remplacement paierait aux sorties originales au moins les mêmes
      montants que la transaction originale, assurant que le mécanisme
      de remplacement ne pourrait pas être utilisé pour voler le récepteur
      de la transaction originale. Yuval Kogman a [répondu][kogman fss]
      avec un lien vers une [version antérieure][rbf-fss] de la même idée
      postée en 2015 par Peter Todd. Dans une réponse [ultérieure][todd fss],
      Todd a décrit plusieurs façons dont l'idée est beaucoup moins
      préférable que l'opt-in ou le RBF complet.

    - *Motivation du Full-RBF :* Anthony Towns [a répondu][towns rbfm] à
      un fil de discussion sur la motivation de divers groupes à effectuer
      des full-RBF. Towns analyse ce que la rationalité économique
      signifie---et ne signifie pas---dans le contexte de la sélection des
      transactions des mineurs. Les mineurs optimisant leurs profits à très
      court terme préféreraient naturellement le full-RBF. Cependant, Towns
      note que les mineurs qui ont fait un investissement à long terme dans
      l'équipement minier pourraient plutôt préférer optimiser les revenus
      des frais sur plusieurs blocs, et cela pourrait ne pas toujours favoriser
      le full-RBF. Il suggère trois scénarios possibles à considérer.

## Mises à jour et version candidate

*Nouvelles versions et versions candidates pour les principaux projets d'infrastructure Bitcoin.
Veuillez envisager de passer aux nouvelles versions ou d'aider à tester les versions candidates.*

- [Eclair 0.8.0][] est une version majeure de cette implémentation
  populaire de nœuds LN. Elle ajoute la prise en charge des [canaux zéro-conf][topic zero-conf channels]
  et des alias SCID (Short Channel IDentifier). Consultez ses [notes de version][eclair 0.8 rn]
  pour plus d'informations sur ces fonctionnalités et d'autres changements.

- [LDK 0.0.113][] est une nouvelle version de cette bibliothèque
  permettant de créer des portefeuilles et des applications compatibles
  avec LN.

- [BDK 0.26.0-rc.2][] est une version candidate de cette bibliothèque
  pour la création de portefeuilles.

## Changements principaux dans le code et la documentation

*Changements notables cette semaine dans [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], et [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #26265][] relaxes the minimum permitted non-witness
  serialized size of transactions in transaction relay policy from 82
bytes to 65 bytes. For example, a transaction with a single input and
single output with 4 bytes of OP\_RETURN padding, which previously
would have been rejected for being too small, could now be accepted
into the node's mempool and relayed. See [Newsletter #222][min relay
size ml] for background information and motivation for this change.

- [Bitcoin Core #21576][] allows wallets using an external signer (e.g. [HWI][topic hwi]) to fee bump
  using [opt-in RBF][topic rbf] in the GUI and when using the `bumpfee` RPC.

- [Bitcoin Core #24865][] permet de restaurer la sauvegarde d'un portefeuille
  sur un nœud qui a été vidé de ses anciens blocs, à condition que le nœud
  dispose encore de tous les blocs produits après la création du portefeuille.
  Les blocs sont nécessaires pour que Bitcoin Core puisse les analyser afin
  de détecter toute transaction affectant le solde du portefeuille.
  Bitcoin Core est en mesure de déterminer l'âge du porte-monnaie car sa
  sauvegarde contient la date de création du porte-monnaie.

- [Bitcoin Core #23319][] met à jour le RPC `getrawtransaction` pour fournir
  des informations supplémentaires si le paramètre `verbose` a la valeur `2`.
  Les informations supplémentaires comprennent les frais payés par la transaction
  et des informations sur chacune des sorties des transactions précédentes
  ("prevouts") qui sont dépensées en étant utilisées comme entrées de cette
  transaction. Voir [Bulletin d'information n°172][news172 prevout] pour plus
  de détails sur la méthode utilisée pour récupérer ces informations.

- [Bitcoin Core #26628][] commence à rejeter les requêtes RPC qui incluent
  plusieurs fois le même nom de paramètre. Auparavant, le démon traitait une
  requête avec des paramètres répétés comme si elle n'avait que le dernier
  des paramètres répétés, par exemple `{"foo"="bar", "foo"="baz"}` était
  traité comme `{"foo"="baz"}`. La requête échoue alors. Lors de l'utilisation
  de `bitcoin-cli` avec des paramètres nommés, le comportement est inchangé :
  les paramètres multiples utilisant le même nom ne seront pas rejetés mais
  seul le dernier des répétés sera envoyé.

- [Eclair #2464][] ajoute la possibilité de déclencher un événement lorsqu'un
  pair distant devient prêt à traiter des paiements. Ceci est particulièrement
  utile dans le contexte des [paiements asynchrones][topic async payments] où
  le nœud local détient temporairement un paiement pour un pair distant, attend
  que le pair se connecte (ou se reconnecte), et délivre le paiement.

- [Eclair #2482][] permet d'envoyer des paiements en utilisant des [routes aveugles][topic rv routing],
  qui sont des chemins dont les derniers sauts sont choisis par le récepteur.
  Le récepteur utilise le chiffrement en oignon pour masquer les détails du saut
  et fournit ensuite les données chiffrées à l'expéditeur, ainsi que l'identité
  du premier nœud de la route aveugle. L'expéditeur construit alors un chemin
  de paiement vers ce premier nœud et inclut les détails chiffrés pour que les
  opérateurs des derniers nœuds les déchiffrent et les utilisent pour transmettre
  le paiement au récepteur. Cela permet au récepteur d'accepter un paiement sans
  révéler l'identité de son nœud ou de ses canaux à l'expéditeur, ce qui améliore
  la confidentialité.

- [LND #2208][] commence à préférer différents chemins de paiement en fonction
  de la capacité maximale d'un canal par rapport au montant à dépenser. Lorsque
  le montant à envoyer se rapproche de la capacité d'un canal, ce dernier a moins
  de chances d'être sélectionné pour un chemin. Ceci est largement similaire
  au code de recherche de chemin déjà utilisé dans Core Lightning et LDK.

- [LDK #1738][] and [#1908][ldk #1908] fournit des fonctionnalités supplémentaires
  pour le traitement des [offres][topic offers].

- [Rust Bitcoin #1467][] ajoute des méthodes pour calculer la taille en
  [unités de poids][] des entrées et sorties de la transaction.

- [Rust Bitcoin #1330][] supprime le type `PackedLockTime`, demandant au code en aval
  d'utiliser le type presque identique `absolute::LockTime`. Une différence entre
  les deux types qui doit être étudiée par toute personne mettant à jour son code
  est que `PackedLockTime` fournit une caractéristique `Ord` mais `absolute::LockTime`
  ne le fait pas (bien que le temps de verrouillage soit considéré dans le `Ord` de
  la transaction qui le contient).

- [BTCPay Server #4411][] mises à jour pour utiliser Core Lightning 22.11 (voir le
  [Bulletin d'information #229][news229 cln]). Toute personne souhaitant mettre un
  hachage de la description d'une commande dans une facture [BOLT11][] n'a plus
  besoin d'utiliser le plugin `invoiceWithDescriptionHash` mais peut définir le
  champ `description` et activer l'option `descriptionHashOnly`.

{% include references.md %}
{% include linkers/issues.md v=2 issues="26265,21576,24865,23319,26628,2464,2482,2208,1738,1908,1467,1330,4411,25600" %}
[news172 prevout]: /en/newsletters/2021/10/27/#bitcoin-core-22918
[unités de poids]: https://en.bitcoin.it/wiki/Weight_units
[towns bci]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-December/021275.html
[bitcoin inquisition]: https://github.com/bitcoin-inquisition/bitcoin
[todd probe]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-December/021296.html
[lipshitz fss]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-December/021272.html
[kogman fss]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-December/021274.html
[todd fss]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-December/021286.html
[rbf-fss]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2015-May/008248.html
[towns rbfm]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-December/021276.html
[todd rbf node]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-December/021270.html
[news229 cln]: /fr/newsletters/2022/12/07/#core-lightning-22-11
[bit de service full-RBF]: https://github.com/petertodd/bitcoin/commit/c15b8d70778238abfa751e4216a97140be6369af
[eclair 0.8.0]: https://github.com/ACINQ/eclair/releases/tag/v0.8.0
[eclair 0.8 rn]: https://github.com/ACINQ/eclair/blob/master/docs/release-notes/eclair-v0.8.0.md
[ldk 0.0.113]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.0.113
[bdk 0.26.0-rc.2]: https://github.com/bitcoindevkit/bdk/releases/tag/v0.26.0-rc.2
[min relay size ml]: /en/newsletters/2022/10/19/#taille-minimale-des-transactions-relayables
