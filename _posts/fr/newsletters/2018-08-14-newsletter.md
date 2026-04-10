---
title: 'Bulletin Hebdomadaire Bitcoin Optech #8'
permalink: /fr/newsletters/2018/08/14/
name: 2018-08-14-newsletter-fr
slug: 2018-08-14-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine comprend le tableau de bord habituel et les éléments d'action, des nouvelles sur l'importance de permettre une
divulgation responsable des bogues à la fois sécurisée et anonyme, un nouveau protocole de paiement potentiel qui peut améliorer la
confidentialité sur Bitcoin sans aucun changement des règles de consensus, la réduction d'un octet de la taille de chaque signature de
transaction, une nouvelle restriction du protocole réseau P2P, et l'abaissement des frais minimums de relais des transactions---ainsi que
quelques commits notables des projets Bitcoin Core, LND et C-Lightning.

## Action items

- **Vérifiez votre processus de divulgation responsable :** il est particulièrement important que les chercheurs puissent signaler des
  bogues de manière sécurisée (par ex. en utilisant PGP) et anonyme (par ex. en utilisant Tor). Voir la section Nouvelles ci-dessous pour
  des liens vers les détails d'une précédente divulgation responsable d'un bogue de défaillance du consensus dans la cryptomonnaie Bitcoin
  Cash qui aurait pu être utilisé pour voler des fonds sur des plateformes d'échange---même celles qui exigeaient plusieurs confirmations
  pour les transactions de dépôt---ainsi que des bonnes pratiques suggérées pour rendre les divulgations faciles.

- **Vérifiez les logiciels utilisant les messages du protocole P2P `getblocks` ou `getheaders` :** si vous utilisez un logiciel personnalisé
  qui demande des blocs en utilisant l'un ou l'autre de ces messages, assurez-vous qu'il ne fait pas ses requêtes avec plus de 101
  localisateurs. Tous les logiciels open source populaires ont déjà été testés, mais si vous avez un logiciel interne qui parle le protocole
  P2P, vous devrez peut-être le tester. Voir la section Nouvelles pour plus de détails.

## Dashboard items

{% assign img1_label = "Transactions per block, 25-block moving average, July 14, 2018 - August 13, 2018" %}

- Les [frais de transaction restent très bas][fee metrics] : toute personne pouvant attendre 10 blocs ou plus pour une confirmation peut
  raisonnablement payer le taux de frais minimum par défaut. C'est un bon moment pour [consolider des UTXOs][consolidate info].

- Le [taux de hachage BTC estimé][btc hash rate] a brièvement atteint 60 EH/s le 10 août, et présente une moyenne sur 7 jours de 48 EH/s.

- Le nombre de transactions dans chaque bloc. Cette métrique est vaguement périodique dans le sens où elle présente des pics entre environ
  13:00 et 17:00 UTC chaque jour. Le graphique ci-dessous montre une moyenne mobile sur 25 blocs du nombre de transactions. Il provient du
  tableau de bord bêta d'Optech que nous encourageons les gens à essayer et au sujet duquel nous invitons à nous faire des retours.

![{{img1_label}}](/img/posts/transactions-spikes.png) *{{img1_label}}, source : tableau de bord Optech*

## Nouvelles

- **Comment aider les chercheurs en sécurité :** le développeur Bitcoin Core et membre de la Digital Currency Initiative (DCI) Cory Fields a
  [révélé][fields post] qu'il était la source anonyme derrière la divulgation d'un bogue potentiellement destructeur pour le consensus dans
  la cryptomonnaie Bitcoin Cash. Après une expérience frustrante en essayant de signaler le bogue, il a demandé aux projets liés aux
  cryptomonnaies de faciliter la soumission de rapports de vulnérabilité anonymes et sécurisés, et sa collègue membre de la DCI Neha Narula
  a poursuivi avec [quelques recommandations][narula recs] particulièrement destinées aux mainteneurs de cryptomonnaies, mais possiblement
  aussi utiles pour les organisations utilisant des cryptomonnaies.

  Optech encourage ses entreprises membres (et tous les autres lisant ce bulletin) à réfléchir à la facilité avec laquelle un chercheur
  anonyme pourrait signaler un bogue critique à votre équipe. Une manière simple de tester votre processus pourrait être de demander à l'un
  des membres de votre équipe d'installer Tor et d'essayer réellement de soumettre un rapport de manière sécurisée en n'utilisant aucune
  information sur votre activité autre que ce qu'il peut facilement trouver sur votre site web. Si vous proposez des primes aux bogues, vous
  pouvez également souhaiter préciser que vous fournirez le même niveau de récompense à toute personne qui soumet initialement une
  divulgation signée par PGP, sous réserve que vous puissiez ensuite collecter auprès d'elle toute information dont vous pourriez avoir
  besoin pour votre conformité légale.

- **Idée de Pay-to-End-Point (P2EP) proposée :** des billets de blog de [Adam Ficsor][nopara73 p2ep] (nopara73) de zkSNACKs et de [Matthew
  Haywood][blockstream p2ep] de Blockstream décrivent une nouvelle idée pour améliorer la confidentialité des utilisateurs de Bitcoin sans
  apporter le moindre changement au protocole de consensus. L'idée de base est que les dépensiers contactent un serveur contrôlé par le
  destinataire lorsqu'ils tentent d'effectuer un paiement (similaire au protocole de paiement [BIP70][]), fournissent une transaction signée
  normale comme preuve qu'ils sont disposés à payer, puis reçoivent les informations nécessaires pour effectuer plusieurs transactions de
  type CoinJoin avec le destinataire. Si l'une des transactions de type CoinJoin est utilisée, cela peut amener les entreprises d'analyse de
  chaîne de blocs à penser qu'une entrée ajoutée à la transaction par le destinataire était une entrée appartenant au dépensier, ou (si P2EP
  est largement utilisé) simplement rendre l'analyse de chaîne de blocs moins fiable en général.

  Si les discussions se poursuivent positivement et qu'une proposition spécifique est adoptée, plusieurs portefeuilles axés sur la
  confidentialité envisagent d'ajouter la prise en charge des dépenses P2EP et [BTCPay Server](https://github.com/btcpayserver/btcpayserver)
  envisage d'ajouter la prise en charge de la réception P2EP.

- **Le portefeuille Bitcoin Core commencera à ne créer que des signatures low-R :** le format DER utilisé pour encoder les signatures
  Bitcoin nécessite l'ajout d'un octet supplémentaire entier à une signature simplement pour indiquer quand la valeur R de la signature se
  trouve dans la moitié supérieure de la courbe elliptique utilisée pour Bitcoin. La valeur R est dérivée aléatoirement, donc la moitié de
  toutes les signatures ont cet octet supplémentaire.

  Fusionnée cette semaine, la PR Bitcoin Core [#13666][Bitcoin Core #13666] génère plusieurs signatures pour chaque transaction (si
  nécessaire) en utilisant un nonce incrémental jusqu'à ce qu'une signature soit trouvée avec une valeur low-R qui ne nécessite pas cet
  octet supplémentaire. En procédant ainsi, les transactions Bitcoin Core économiseront un octet toutes les deux signatures (en moyenne). Si
  tous les portefeuilles faisaient cela, cela pourrait économiser jusqu'à plusieurs milliers d'octets (ou jusqu'à quelques milliers de
  vbytes) par bloc complet typique, augmentant la capacité de la chaîne de blocs jusqu'à quelques milliers de transactions par jour. Le coût
  est que Bitcoin Core mettra deux fois plus de temps pour générer une signature moyenne et que cela réduit l'entropie (l'aléa) des
  signatures générées de 1 bit, aucun de ces deux points n'étant significatif. Cela peut aussi rendre les transactions créées par Bitcoin
  Core un peu plus faciles à identifier si aucun autre portefeuille n'adopte ce changement.

  Notez que ce changement n'affecte en aucune façon les autres logiciels (sauf que d'autres portefeuilles pourront utiliser la capacité
  supplémentaire de la chaîne de blocs). C'est purement une fonctionnalité intégrée au portefeuille Bitcoin Core et non quelque chose qui
  sera imposé par le protocole.

- **Abaissement des frais minimums de relais en deux étapes :** comme mentionné dans le [Bulletin n°3][news3 lower relay], les développeurs
  de Bitcoin Core [envisagent][Bitcoin Core #13922] d'abaisser les frais minimums de relais pour les transactions. Comme ce changement
  affecte les portefeuilles, les nœuds de relais et les mineurs en même temps---mais qu'ils ne se mettent pas tous à jour selon le même
  calendrier---évaluer et tester le changement s'est avéré plus difficile qu'on ne pourrait s'y attendre pour un simple changement de
  quelques variables.

  Le plan actuellement discuté consiste à abaisser d'abord les frais par défaut pour les nœuds de relais et les mineurs, à attendre de voir
  si cela reçoit une adoption suffisante pour que des transactions ayant actuellement des frais inférieurs au niveau par défaut soient
  minées, puis à abaisser dans une version ultérieure les frais minimums utilisés par le portefeuille. Nous publierons de futures mises à
  jour dans ce bulletin sur la manière dont votre organisation peut aider à utiliser et encourager l'adoption de frais minimums de relais
  plus bas.

- **Changement du protocole P2P pour restreindre les localisateurs :** les messages [getblocks][p2p getblocks] et [getheaders][p2p
  getheaders] permettent à un nœud de demander des informations sur des blocs qu'il n'a pas vus en envoyant à un autre nœud une liste des
  blocs qu'il a vus. Le nœud receveur utilise la liste pour trouver le dernier bloc que les deux nœuds ont en commun et envoie des
  informations sur les blocs suivants.

  Selon un [email][bd locators] publié sur la liste de diffusion bitcoin-dev par Gregory Maxwell, l'utilisateur Bitcoin Talk Coinr8d
  craignait que le nœud demandeur puisse envoyer jusqu'à 32 MiB de hachages de blocs au nœud receveur, amenant celui-ci à dépenser beaucoup
  d'E/S à chercher des blocs qu'il n'avait pas. Cependant, les tests de Maxwell n'ont pas trouvé que cela constituait un problème
  significatif. Malgré cela, Maxwell a proposé de limiter le nombre de localisateurs autorisés dans ces messages. Le développeur de
  Libbitcoin Eric Voskuil a indiqué que son logiciel imposait déjà une limite et qu'il connaissait un programme (BitcoinJ) qui dépassait
  légèrement la limite proposée par Maxwell.

  La PR ensuite fusionnée [Bitcoin Core #13907][] de Maxwell a fixé la limite à la valeur maximale demandée par BitcoinJ. Si vous avez
  connaissance d'un logiciel demandant plus de 101 éléments en utilisant les messages P2P `getblocks` ou `getheaders`, veuillez écrire sur
  la liste de diffusion bitcoin-dev ou contacter quelqu'un d'Optech.

- **Discussion sur le BIP Schnorr :** une [discussion][schnorr discuss] entre experts au sujet de l'algorithme de génération des signatures
  Schnorr la semaine dernière sur la liste de diffusion bitcoin-dev s'est résolue sans aucun besoin de modifier le BIP proposé. Cela
  pourrait accroître la confiance dans le fait que les paramètres du BIP proposé ont été judicieusement choisis.

## Notable commits

*Commits notables cette semaine dans [Bitcoin Core][bitcoin core repo], [LND][lnd repo] et [C-lightning][core lightning repo]. N'inclut pas
Bitcoin Core
#13907 ou #13666 décrites ci-dessus. Remarque : l'essentiel des changements
dans les trois projets cette semaine semblait être des améliorations de leur code de tests automatisés ; nous ne les décrivons pas dans ce
bulletin, mais nous sommes sûrs que les utilisateurs et les développeurs apprécient grandement ce travail.*

- [Bitcoin Core #13925][] : augmente le nombre maximal de descripteurs de fichiers que la base de données interne de Bitcoin Core peut
  utiliser, ce qui peut permettre à davantage de descripteurs de fichiers d'être utilisés pour les connexions réseau. Si vous avez modifié
  Bitcoin Core pour accepter plus de 117 connexions entrantes, vous pourriez constater une augmentation supplémentaire du nombre de
  connexions après une mise à niveau incluant cette fusion. (Remarque : nous ne recommandons pas d'augmenter la valeur par défaut sauf si
  vous avez un besoin particulier.)

- [LND #1644][] : les frais saisis par l'utilisateur en satoshis par vbyte sont maintenant automatiquement convertis pour utiliser des
  satoshis par kiloweight (1 000 vbytes) comme défini dans le [protocole][BOLT2].

- [C-Lightning #1811][] : un nœud payeur n'enverra plus un engagement HTLC (paiement) à un autre nœud à moins d'avoir eu des nouvelles de ce
  nœud au cours des 30 dernières secondes. Si nécessaire, il enverra un ping au nœud destinataire avant d'envoyer l'engagement. Cela aide le
  nœud payeur à abandonner un paiement plus tôt dans le processus si ce paiement était de toute façon voué à échouer à cause d'une
  interruption réseau.

  Sont également incluses diverses autres améliorations modérées du code de reconnexion aux pairs déconnectés, y compris le backoff
  exponentiel et l'ajout de hasard au temps de reconnexion.

{% include references.md %}
{% include linkers/issues.md issues="13922,13907,13925,1644,13666,1811" %}

[news3 lower relay]: /fr/newsletters/2018/07/10/#discussion-min-fee-discussion-sur-les-frais-minimums-de-relais
[BOLT2]: https://github.com/lightningnetwork/lightning-rfc/blob/master/02-peer-protocol.md
[fields post]: https://medium.com/mit-media-lab-digital-currency-initiative/http-coryfields-com-cash-48a99b85aad4
[narula recs]: https://medium.com/mit-media-lab-digital-currency-initiative/reducing-the-risk-of-catastrophic-cryptocurrency-bugs-dcdd493c7569
[nopara73 p2ep]: https://medium.com/@nopara73/pay-to-endpoint-56eb05d3cac6
[blockstream p2ep]: https://blockstream.com/2018/08/08/improving-privacy-using-pay-to-endpoint.html
[p2p getblocks]: https://bitcoin.org/en/developer-reference#getblocks
[p2p getheaders]: https://bitcoin.org/en/developer-reference#getheaders
[bd locators]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-August/016285.html
[schnorr discuss]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-August/016278.html
[fee metrics]: https://statoshi.info/dashboard/db/fee-estimates
[consolidate info]: https://en.bitcoin.it/wiki/Techniques_to_reduce_transaction_fees#Consolidation
[btc hash rate]: https://fork.lol/pow/hashrate
