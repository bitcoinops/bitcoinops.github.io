---
title: 'Bulletin Hebdomadaire Bitcoin Optech #305'
permalink: /fr/newsletters/2024/05/31/
name: 2024-05-31-newsletter-fr
slug: 2024-05-31-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine décrit un protocole proposé pour les clients légers concernant les
paiements silencieux, résume deux nouveaux descripteurs proposés pour taproot, et renvoie à une
discussion sur la question de savoir si des opcodes avec des fonctionnalités superposées devraient
être ajoutés lors d'un soft fork. Sont également incluses nos
rubriques habituelles avec des questions et réponses populaires
de la communauté Bitcoin Stack Exchange, des annonces de nouvelles versions et de
versions candidates, ainsi que les changements apportés aux principaux logiciels d'infrastructure Bitcoin.

## Actualités

- **Protocole client léger pour les paiements silencieux :** Setor Blagogee a [publié][blagogee
  lcsp] sur Delving Bitcoin pour décrire une ébauche de spécification d'un protocole aidant les
  clients légers à recevoir des [paiements silencieux][topic silent payments] (SP). L'ajout de
  quelques primitives cryptographiques suffit pour permettre à n'importe quel logiciel de portefeuille
  d'envoyer des SP, mais recevoir des paiements silencieux nécessite non seulement ces primitives,
  mais aussi la capacité d'accéder aux informations concernant chaque transaction onchain compatible
  avec les SP. Cela est facile pour les nœuds complets, comme Bitcoin Core, qui traitent déjà chaque
  transaction onchain, mais cela nécessite des fonctionnalités supplémentaires pour les clients légers
  qui essaient généralement de minimiser la quantité de données transactionnelles qu'ils demandent.

  Le protocole de base consiste en ce qu'un prestataire de services construise un index par bloc des
  clés publiques pouvant être utilisées avec les SP. Les clients téléchargent cet index et un [filtre
  de bloc compact][topic compact block filters] pour le même bloc. Les clients calculent leur
  ajustement local pour chaque clé (ou ensemble de clés) et déterminent si le filtre de bloc contient
  un paiement à leur propre clé correspondante. Si c'est le cas, ils téléchargent des données
  supplémentaires au niveau du bloc qui leur permettent de savoir combien ils ont reçu et comment
  dépenser ultérieurement le paiement.

- **Descripteurs taproot bruts :** Oghenovo Usiwoma a [discuté][usiwoma descriptors] sur Delving
  Bitcoin de deux nouvelles propositions de [descripteurs][topic descriptors] pour construire des
  conditions de dépense [taproot][topic taproot] :

  - `rawnode(<hash>)` prend le hash d'un nœud de l'arbre de Merkle, que ce soit pour un nœud interne
    ou pour un nœud secondaire. Cela permet à un portefeuille ou à un autre programme de scan de trouver
    des scripts de sortie particuliers sans savoir exactement quels tapscripts ils utilisent. Ce n'est
    pas entièrement fiable---un script inconnu pourrait être
    soit inexploitable, soit permettre à un tiers de dépenser des fonds---mais il peut y avoir des
    protocoles où cela fonctionne en toute sécurité.

    Anthony Towns donne un [exemple][towns descriptors] où Alice souhaite que Bob puisse hériter de son
    argent ; pour ses chemins de dépense, elle ne donne à Bob que les hashes des nœuds bruts ; pour son
    chemin d'héritage, elle lui donne un descripteur modèle (peut-être incluant un verrouillage temporel
    qui l'empêche de dépenser avant qu'une période de temps ne soit écoulée). Cela est sûr pour Bob car
    l'argent n'est pas le sien et c'est bon pour la confidentialité d'Alice car elle n'a pas besoin de
    révéler ses autres conditions de dépense à Bob à l'avance (bien que Bob puisse les apprendre des
    transactions onchain d'Alice).

  - `rawleaf(<script>,[version])` est similaire au descripteur `raw` existant
    afin d'inclure des scripts qui ne peuvent pas être exprimés en utilisant un descripteur
    basé sur un modèle. Sa principale différence réside dans le fait qu'il permet d'indiquer une version
    de tapleaf différente de celle par défaut spécifiée dans [BIP342][] pour le [tapscript][topic
    tapscript].

  Le post de Usiwoma fournit un exemple et des liens vers des discussions précédentes ainsi qu'une
  [implémentation de référence][usiwoma poc] qu'il a créée.

- **Les propositions de soft fork qui se chevauchent doivent-elles être considérées comme mutuellement exclusives ?**
  Pierre Rochard [demande][rochard exclusive] si les propositions de soft forks, qui peuvent offrir beaucoup
  des mêmes fonctionnalités à un coût similaire, devraient être considérés comme mutuellement
  exclusifs, ou s'il serait judicieux d'activer plusieurs propositions et de laisser les développeurs
  utiliser l'alternative qu'ils préfèrent.

  Anthony Towns [répond][towns exclusive] à plusieurs points, suggérant que les fonctionnalités qui se
  chevauchent en elles-mêmes ne sont pas un problème, mais que les fonctionnalités qui ne sont pas
  utilisées parce que tout le monde préfère une alternative peuvent poser plusieurs problèmes. Il
  suggère à quiconque privilégie une proposition particulière de tester ses fonctionnalités dans un
  logiciel en pré-production pour se faire une idée, surtout en comparaison avec d'autres manières
  d'ajouter la fonctionnalité à Bitcoin.


## Questions et réponses sélectionnées de Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] est l'un des premiers endroits où les contributeurs d'Optech cherchent des réponses à leurs
  questions, ou lorsqu'ils ont quelques moments libres, aident les utilisateurs curieux ou confus. Dans cette rubrique
  mensuelle, nous mettons en évidence certaines des questions et réponses les plus populaires publiées depuis notre dernière mise
  à jour.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aa
nswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Quelle est la taille minimale possible d'une transaction coinbase / d'un bloc ?]({{bse}}122951)
  Antoine Poinsot explique les restrictions minimales autour de la transaction coinbase et conclut que
  le plus petit bloc Bitcoin valide possible aux hauteurs de bloc actuelles est de 145 octets.

- [Comprendre l'encodage des nombres dans Script, CScriptNum]({{bse}}122939)
  Antoine Poinsot décrit comment CScriptNum représente les entiers dans le Script de Bitcoin, fournit
  quelques exemples d'encodages et renvoie à deux implémentations de sérialisation.

- [Existe-t-il un moyen de rendre public une adresse de portefeuille BTC tout en cachant le nombre de BTC qu'elle contient ?]({{bse}}122786)
  Vojtěch Strnad souligne que les adresses de paiement réutilisables [silent payment][topic silent
  payments] permettent de publier un identifiant de paiement public sans que les observateurs puissent
  associer les transactions qui y sont payées.

- [Tester l'augmentation des taux de frais en regtest]({{bse}}122837)
  En regtest, Ava Chow recommande d'utiliser le cadre de test de Bitcoin Core et de régler
  `-maxmempool` sur une valeur faible et `-datacarriersize` sur une valeur élevée afin de simuler des
  environnements à taux de frais élevés.

- [Pourquoi mon pair P2P_V2 est-il connecté via une connexion v1 ?]({{bse}}122774)
  Pieter Wuille suppose que des informations obsolètes sur l'adresse du pair sont la cause pour
  laquelle un utilisateur voit un pair qui supporte le BIP324 [transport chiffré][topic v2 p2p transport]
  connecté avec une connexion non chiffrée v1.

- [Une transaction P2PKH est-elle envoyée au hash de la clé non compressée ou de la clé compressée ?]({{bse}}122875)
  Pieter Wuille note que les clés publiques compressées et non compressées peuvent être utilisées,
  résultant en des adresses P2PKH distinctes, et ajoute que P2WPKH n'autorise que les clés publiques
  compressées par politique et que P2TR utilise des [clés publiques X-only][topic X-only public
  keys].

- [Quelles sont les différentes manières de diffuser un bloc sur le réseau Bitcoin ?]({{bse}}122953)
  Pieter Wuille décrit 4 façons d'annoncer des blocs sur le réseau P2P : en utilisant [BIP130][],
  [BIP152][], en envoyant des [messages `block` non sollicités][], et l'ancien flux de messages
  `inv` / `getdata` / `block`.

## Mises à jour et versions candidates

*Nouvelles versions et versions candidates pour les principaux projets d’infrastructure
Bitcoin. Veuillez envisager de passer aux nouvelles versions ou d’aider à tester
les versions candidates.*

- [LND v0.18.0-beta][] est la dernière version majeure de cette implémentation populaire de nœud LN.
  Selon ses [notes de version][lnd rn], un support expérimental est ajouté pour les _frais de routage
  entrants_ (voir le [Bulletin #297][news297 inbound]), le cheminement pour les [chemins masqués][topic
  rv routing] est maintenant disponible, les [watchtowers][topic watchtowers] prennent désormais en
  charge les [canaux taproot simples][topic simple taproot channels], et l'envoi d'informations de
  débogage cryptées est maintenant rationalisé (voir le [Bulletin #285][news285 encdebug]), avec de
  nombreuses autres fonctionnalités également ajoutées et de nombreux bugs corrigés.

- [Core Lightning 24.05rc2][] est un candidat à la version pour la prochaine version majeure de
  cette implémentation populaire de nœud LN.

## Changements notables de code et de documentation

_Changes récents notables dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning
repo], [Eclair][eclair repo], [LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo],
[Hardware Wallet Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement Proposals (BIPs)][bips repo],
[Lightning BOLTs][bolts repo], [Bitcoin Inquisition][bitcoin inquisition repo], et [BINANAs][binana
repo]._

- [Bitcoin Core #29612][] met à jour le format de sérialisation de la sortie de dump de l'ensemble
  UTXO via le RPC `dumptxoutset`. Cela résulte en une optimisation de l'espace de 17,4%. Le RPC
  `loadtxoutset` attend maintenant le nouveau format lors du chargement du fichier de dump de
  l'ensemble UTXO ; l'ancien format n'est plus pris en charge. Voir les Bulletins [#178][news178
  txoutset] et [#72][news72 txoutset] pour les références précédentes à `dumptxoutset`.

- [Bitcoin Core #27064][] change le répertoire de données par défaut sur Windows de
  `C:\Users\Username\AppData\Roaming\Bitcoin` à `C:\Users\Username\AppData\Local\Bitcoin` uniquement
  pour les nouvelles installations.

- [Bitcoin Core #29873][] introduit une limite de poids de données de 10 kvB pour les transactions
  [Topologically Restricted Until Confirmation (TRUC)][topic v3 transaction relay] (transactions v3)
  afin de réduire le coût potentiel de mitigation contre
  les attaques de [transaction par épinglage][topic transaction pinning], améliorent l'efficacité de la
  construction de modèles de blocs et imposent des limites de mémoire plus strictes sur certaines
  structures de données. Les transactions V3 sont un sous-ensemble de transactions standard avec des
  règles supplémentaires conçues pour permettre le remplacement de transactions tout en minimisant le
  coût à surmonter les attaques de type transaction-pinning. Voir les Bulletins [#289][news289 v3] et
  [#296][news296 v3] pour plus d'informations sur les transactions v3.

- [Bitcoin Core #30062][] ajoute deux nouveaux champs, `mapped_as` et `source_mapped_as`, à la
  commande RPC `getrawaddrman`, qui retourne des informations sur les adresses réseau des nœuds pairs.
  Les nouveaux champs renvoient le Numéro de Système Autonome (ASN) associé au pair et à sa source,
  pour fournir des informations approximatives sur les FAI qui contrôlent quelles adresses IP et
  augmenter la résistance de Bitcoin Core aux attaques par [éclipse][topic eclipse attacks]. Voir les
  Bulletins [#52][news52 asmap], [#83][news83 asmap], [#101][news101 asmap], [#290][news290 asmap].

- [Bitcoin Core #26606][] introduit `BerkeleyRODatabase`, une implémentation indépendante d'un
  analyseur de fichiers de base de données Berkeley (BDB) qui offre un accès en lecture seule aux
  fichiers BDB. Les données de portefeuille héritées peuvent maintenant être extraites sans nécessiter
  la lourde bibliothèque BDB, facilitant ainsi la migration vers les portefeuilles
  [descripteurs][topic descriptors]. La commande `dump` de `wallettool` est modifiée pour utiliser
  `BerkeleyRODatabase`.

- [BOLTs #1092][] nettoie la spécification du Lightning Network (LN) en supprimant les
  fonctionnalités inutilisées et non plus supportées `initial_routing_sync` et
  `option_anchor_outputs`. Trois fonctionnalités sont désormais supposées être présentes dans tous les
  nœuds : `var_onion_optin` pour les [messages en onion][topic onion messages] de taille variable afin de
  relayer des données arbitraires à des sauts spécifiques, `option_data_loss_protect` pour que les
  nœuds envoient des informations sur leur dernier état de canal lorsqu'ils se reconnectent, et
  `option_static_remotekey` pour permettre à un nœud de demander que chaque mise à jour de canal
  s'engage à envoyer les fonds non-[HTLC][topic htlc] du nœud à la même adresse. La fonctionnalité
  `gossip_queries` pour les requêtes de gossip spécifiques est modifiée de sorte qu'un nœud qui ne la
  supporte pas ne sera pas interrogé par d'autres nœuds. Voir le Bulletin [#259][news259 cleanup].

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when="2024-06-04 14:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="29612,27064,29873,30062,26606,1092" %}
[lnd v0.18.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.18.0-beta
[blagogee lcsp]: https://delvingbitcoin.org/t/silent-payments-light-client-protocol/891/
[usiwoma descriptors]: https://delvingbitcoin.org/t/tr-rawnode-and-rawleaf-support/901/
[towns descriptors]: https://delvingbitcoin.org/t/tr-rawnode-and-rawleaf-support/901/6
[usiwoma poc]: https://github.com/Eunovo/bitcoin/tree/wip-tr-raw-nodes
[rochard exclusive]: https://delvingbitcoin.org/t/mutual-exclusiveness-of-op-codes/890/3
[towns exclusive]: https://delvingbitcoin.org/t/mutual-exclusiveness-of-op-codes/890/3
[lnd rn]: https://github.com/lightningnetwork/lnd/blob/master/docs/release-notes/release-notes-0.18.0.md
[core lightning 24.05rc2]: https://github.com/ElementsProject/lightning/releases/tag/v24.05rc2
[news297 inbound]: /fr/newsletters/2024/04/10/#lnd-6703
[news285 encdebug]: /fr/newsletters/2024/01/17/#lnd-8188
[messages `block` non sollicités]: https://developer.bitcoin.org/devguide/p2p_network.html#block-broadcasting
[news72 txoutset]: /en/newsletters/2019/11/13/#bitcoin-core-16899
[news178 txoutset]: /en/newsletters/2021/12/08/#bitcoin-core-23155
[news289 v3]: /fr/newsletters/2024/02/14/#bitcoin-core-28948
[news296 v3]: /fr/newsletters/2024/04/03/#bitcoin-core-29242
[news52 asmap]: /en/newsletters/2019/06/26/#differentiating-peers-based-on-asn-instead-of-address-prefix
[news83 asmap]: /en/newsletters/2020/02/05/#bitcoin-core-16702
[news101 asmap]: /en/newsletters/2020/06/10/#bitcoin-core-0-20-0
[news290 asmap]: /fr/newsletters/2024/02/21/#amelioration-du-processus-de-creation-de-asmap-reproductible
[news259 cleanup]: /fr/newsletters/2023/07/12/#proposition-de-nettoyage-de-la-specification-ln
