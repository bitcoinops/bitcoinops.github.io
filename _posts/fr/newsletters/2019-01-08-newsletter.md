---
title: 'Bulletin Hebdomadaire Bitcoin Optech #28'
permalink: /fr/newsletters/2019/01/08/
name: 2019-01-08-newsletter-fr
slug: 2019-01-08-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine annonce une nouvelle version de maintenance de Bitcoin Core, décrit la poursuite de la discussion sur de
nouveaux hachages de signature, et renvoie à une publication sur de possibles barrières économiques aux paiements LN traversant différentes
monnaies. Des descriptions de changements notables dans le code de projets populaires d'infrastructure Bitcoin sont également fournies.

## Actions à entreprendre

- **Mettre à niveau vers Bitcoin Core 0.17.1 :** cette nouvelle version [mineure][maintenance] publiée le 25 décembre rétablit certaines
  fonctionnalités précédemment dépréciées du RPC `listtransactions` et inclut des corrections de bugs ainsi que d'autres améliorations.
  Envisagez de lire les [notes de version][0.17.1 notes] et de [mettre à niveau][0.17.1 bin].

## Nouvelles

- **Poursuite de la discussion sur les sighash :** comme mentionné dans la section Nouvelles du [Bulletin #25][], les développeurs sur la
  liste de diffusion Bitcoin-Dev ont discuté de la manière dont les hachages de signature pourraient être modifiés pour donner aux
  transactions accès à de nouvelles capacités. Les sighash donnent aux dépensiers la possibilité de permettre à leurs transactions d'être
  modifiées de façons spécifiées après qu'elles sont signées---par exemple, deux personnes qui ouvrent ensemble un canal de paiement peuvent
  utiliser un type particulier de sighash pour permettre à l'une ou l'autre d'ajouter unilatéralement des frais de transaction
  supplémentaires à une transaction de fermeture de canal.

  La discussion la plus récente dans ce fil de près de 70 messages a principalement porté sur des cas limites liés à de nouveaux drapeaux de
  sighash, en particulier un `SIGHASH_NOINPUT_UNSAFE` de type BIP118. Dans le cadre de la discussion, le développeur de protocole Johnson
  Lau a décrit une [optimisation pour les canaux de paiement basés sur Eltoo][lau bip68]. A aussi été [discutée][rm codesep] la question de
  savoir si l'opcode `OP_CODESEPARATOR` devrait être désactivé dans une mise à jour du Script prenant en charge MAST (par ex. via Taproot).
  Cet opcode n'est pas couramment utilisé, mais si vous prévoyez de l'utiliser dans de futures versions de Script, vous devriez commenter
  dans le fil.

- **LN inter-chaînes comme contrat d'options :** le contributeur LN pseudonyme ZmnSCPxj a lancé un fil sur la liste de diffusion
  Lightning-Dev soulignant que des utilisateurs pourraient abuser des paiements qui traversent les monnaies pour créer des [contrats
  d'options à court terme][contrat option court terme] presque gratuits en retardant le règlement du paiement. Un [fil précédent][cjp risk] de Corné Plooy en mai 2018
  décrivait la même chose.

  Par exemple, Mallory apprend que Bob est prêt à acheminer des paiements de Bitcoin vers Litecoin, elle envoie donc un paiement depuis l'un
  de ses nœuds Bitcoin via Bob vers l'un de ses nœuds Litecoin. S'il s'agissait d'un paiement normal, elle le réglerait immédiatement en
  révélant la préimage du hachage verrouillant le paiement---mais à la place son nœud retarde pendant 24 heures en attendant que le taux de
  change évolue. Si le taux de change augmente en faveur du Litecoin, Mallory règle le paiement et reçoit aujourd'hui des litecoins au taux
  de change d'hier. Si le taux de change reste le même ou augmente en faveur du Bitcoin, Mallory fait échouer le paiement et récupère ses
  bitcoins. Comme aucuns frais ne sont facturés pour les paiements échoués, Mallory a reçu une opportunité de verrouiller temporairement le
  prix du Litecoin sans autre coût que celui de posséder les bitcoins que Mallory aurait échangés.

  Il n'existe actuellement aucun nœud LN multi-devise connu, mais la disponibilité de cette astuce signifie que de futurs nœuds de ce type
  pourraient être détournés pour la spéculation plutôt que pour l'acheminement de paiements. Si cela s'avère être un véritable problème et
  si une solution acceptable n'est pas trouvée, il se peut que les réseaux de canaux de paiement pour différentes monnaies soient isolés les
  uns des autres.

## Changements notables dans le code

*Changements notables dans le code cette semaine dans [Bitcoin Core][bitcoin core repo], [LND][lnd repo], [C-lightning][core lightning
repo], et [libsecp256k1][libsecp256k1 repo].*

- [Bitcoin Core #14565][] améliore significativement la gestion des erreurs du RPC `importmulti` et renverra un champ `warnings` pour chaque
  importation tentée avec un tableau de chaînes décrivant tout problème lié à cette importation (mais seulement s'il y a eu des problèmes).

- [Bitcoin Core #14811][] met à jour le RPC [getblocktemplate][rpc getblocktemplate] pour exiger que le drapeau segwit soit transmis. Cela
  aide à éviter que les mineurs n'utilisent accidentellement pas segwit, ce qui réduit leurs revenus de frais. Voir le [Bulletin #20][] pour
  un cas récent où cela a pu se produire avec une grande pool de minage.

- [C-Lightning #2172][] permet à `lightningd` d'être arrêté normalement même s'il fonctionne en tant que processus principal (PID 1), ce qui
  peut être utile dans des conteneurs Docker. C'est, par exemple, ainsi que le serveur open source [BTCPay][] exécute C-Lightning.

- [C-Lightning #2188][] ajoute des gestionnaires d'abonnement aux notifications qui peuvent être utilisés par des plugins, avec une prise en
  charge initiale des notifications indiquant que le nœud s'est connecté à un nouveau pair ou s'est déconnecté d'un pair existant. La
  [documentation des plugins][cl plugin event] et le [plugin d'exemple][cl helloworld.py] ont été mis à jour pour ces gestionnaires.

- [LND #2374][] augmente la taille maximale des messages gRPC que l'outil `lncli` acceptera, la faisant passer de 4 Mo à 50 Mo. Cela corrige
  un problème rencontré par certains nœuds où le RPC `describegraph` échouait parce que le réseau avait tellement grandi que les messages
  dépassaient cette limite. Les développeurs utilisant directement gRPC devront augmenter le paramètre côté client de taille maximale des
  messages---des descriptions sur la manière de faire cela ont déjà été ajoutées sous forme de commentaires à la PR pour python et nodejs.
  En fin de compte, on s'attend à ce que le réseau devienne suffisamment grand pour dépasser même ce nouveau maximum, donc les développeurs
  prévoient de remanier les RPC concernés pour gérer cette situation.

- [LND #2354][] ajoute un nouveau champ `invoicestate` et déprécie l'ancien champ `settled` dans les RPC qui obtiennent des informations sur
  les factures. Le champ settled était booléen mais le nouveau champ d'état peut prendre en charge plusieurs valeurs. Actuellement, il
  s'agit simplement de "open" ou "settled", mais des états supplémentaires sont prévus pour l'avenir.

{% include references.md %}
{% include linkers/issues.md issues="14565,14811,2172,2188,2374,2354" %}

[0.17.1 bin]: https://bitcoincore.org/bin/bitcoin-core-0.17.1/
[0.17.1 notes]: https://bitcoincore.org/en/releases/0.17.1/
[maintenance]: https://bitcoincore.org/en/lifecycle/#maintenance-releases
[lau bip68]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-December/016574.html
[rm codesep]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-December/016581.html
[contrat option court terme]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-December/001752.html
[cjp risk]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-May/001292.html
[cl plugin event]: https://github.com/ElementsProject/lightning/blob/master/doc/PLUGINS.md#event-notifications
[cl helloworld.py]: https://github.com/ElementsProject/lightning/blob/master/contrib/plugins/helloworld.py
[btcpay]: https://github.com/btcpayserver/btcpayserver
[bulletin #25]: /fr/newsletters/2018/12/11/#options-de-sighash-pour-couvrir-le-poids-des-transactions
[bulletin #20]: /fr/newsletters/2018/11/06/#reduction-temporaire-de-la-production-de-blocs-segwit
