---
title: 'Bulletin Hebdomadaire Bitcoin Optech #356'
permalink: /fr/newsletters/2025/05/30/
name: 2025-05-30-newsletter-fr
slug: 2025-05-30-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
La newsletter de cette semaine résume une discussion sur les effets possibles des échecs
attribuables sur la confidentialité du LN. Sont également inclus nos sections régulières avec des
questions et réponses sélectionnées du Bitcoin Stack Exchange, des annonces de nouvelles versions et
candidates à la sortie, ainsi que des descriptions des changements récents dans les logiciels
d'infrastructure Bitcoin populaires.

## Nouvelles

- **Les échecs attribuables réduisent-ils la confidentialité du LN ?** Carla Kirk-Cohen a
  [posté][kirkcohen af] sur Delving Bitcoin une analyse des conséquences possibles pour la
  confidentialité des dépensiers et des receveurs du LN si le réseau adopte les [échecs
  attribuables][topic attributable failures], en particulier en informant le dépensier du temps qu'il
  a fallu pour transférer un paiement à chaque saut. Citant plusieurs articles, elle décrit deux types
  d'attaques de désanonymisation :

  - Un attaquant exploitant un ou plusieurs nœuds de transfert utilise les données de temps pour
    déterminer le nombre de sauts utilisés par un paiement ([HTLC][topic htlc]), ce qui peut être
    combiné avec la connaissance de la topographie du réseau public pour réduire l'ensemble des nœuds
    qui auraient pu être le receveur.

  - Un attaquant utilise un achemineur de trafic réseau IP ([système autonome][]) pour surveiller
    passivement le trafic et combine cela avec la connaissance de la latence du réseau IP entre les
    nœuds (c'est-à-dire, leurs temps de ping) plus la connaissance de la topographie (et d'autres
    caractéristiques) du réseau Lightning public.

  Elle décrit ensuite des solutions possibles, incluant :

  - Encourager les receveurs à retarder l'acceptation d'un HTLC d'une petite quantité aléatoire pour
    prévenir les attaques de timing tentant d'identifier le nœud du receveur.

  - Encourager les dépensiers à retarder le renvoi des paiements échoués (ou des parties de
    [MPP][topic multipath payments]) d'une petite quantité aléatoire et en utilisant des chemins
    alternatifs pour prévenir les attaques de timing et d'échec tentant d'identifier le nœud du
    dépensier.

  - Augmenter la division des paiements avec MPP pour rendre plus difficile la devinette du montant
    dépensé.

  - Permettre aux dépensiers de choisir de faire acheminer leurs paiements moins rapidement, comme
    précédemment proposé (voir le [Bulletin #208][news208 slowln]). Cela pourrait être combiné avec le
    regroupement de HTLC, qui est déjà implémenté dans LND (bien que l'ajout d'un délai aléatoire
    pourrait améliorer la confidentialité).

  - Réduire la précision des horodatages des échecs attribuables pour éviter de pénaliser les nœuds de
    transfert qui ajoutent de petits délais aléatoires.

  La discussion de plusieurs participants a évalué les préoccupations et les solutions proposées plus
  en détail, ainsi que la considération d'autres attaques possibles et des atténuations.

## Questions et réponses sélectionnées de Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] est l'un des premiers endroits où les contributeurs d'Optech
cherchent des réponses à leurs questions---ou quand nous avons quelques moments libres pour aider
les utilisateurs curieux ou confus. Dans cette rubrique mensuelle, nous mettons en lumière certaines
des questions et réponses les mieux votées postées depuis notre dernière mise à jour.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Quelles transactions sont incluses dans blockreconstructionextratxn ?]({{bse}}116519) Glozow
  explique comment la structure de données extrapool (voir le [Bulletin #339][news339 extrapool]) met
  en cache les transactions rejetées et remplacées vues par le nœud et énumère les critères
  d'exclusion et d'éviction.

- [Pourquoi quelqu'un utiliserait OP_RETURN plutôt que des inscriptions, à part pour les frais?]({{bse}}126208)
  Sjors Provoost note qu'en plus d'être parfois moins cher, `OP_RETURN` peut
  également être utilisé pour des protocoles nécessitant que les données soient disponibles avant
  qu'une transaction soit dépensée, contrairement aux données de témoin qui sont révélées dans la
  transaction de dépense.

- [Pourquoi mon nœud Bitcoin ne reçoit-il pas de connexions entrantes ?]({{bse}}126338) Lightlike
  souligne qu'un nouveau nœud sur le réseau peut prendre du temps pour que son adresse soit largement
  diffusée sur le réseau P2P et que les nœuds n'annonceront pas leur adresse tant que l'IBD n'est pas
  terminée.

- [Comment configurer mon nœud pour filtrer les transactions de plus de 400 octets ?]({{bse}}126347)
  Antoine Poinsot confirme qu'il n'existe pas d'option de configuration dans Bitcoin Core pour
  personnaliser la taille maximale standard d'une transaction. Il explique que les utilisateurs
  souhaitant personnaliser cette valeur peuvent mettre à jour leur code source, mais met en garde
  contre les inconvénients potentiels des valeurs maximales plus grandes ou plus petites.

- [Que signifie un nœud "non routable publiquement" dans le P2P de Bitcoin Core ?]({{bse}}126225)
  Pieter Wuille et Vasil Dimov fournissent des exemples de connexions P2P, telles que [Tor][topic
  anonymity networks], qui ne peuvent pas être routées sur l'internet global et qui apparaissent dans
  la sortie `netinfo` de Bitcoin Core dans le seau "npr".

- [Pourquoi un nœud ne relayerait-il jamais une transaction ?]({{bse}}127391) Pieter Wuille énumère les
  avantages du relais de transactions pour un opérateur de nœud : la confidentialité lors du relais de
  vos propres transactions depuis votre nœud, une propagation de bloc plus rapide si l'utilisateur
  fait de l'extraction, et une amélioration de la décentralisation du réseau avec des coûts
  incrémentiels minimaux au-delà du simple relais de blocs.

- [Le minage égoïste est-il toujours une option avec les blocs compacts et FIBRE ?]({{bse}}49515)
  Antoine Poinsot répond à une question de 2016 en notant, "Oui, le minage égoïste est toujours une
  optimisation possible même avec une amélioration de la propagation des blocs. Il n'est pas correct
  de conclure que le minage égoïste est maintenant seulement une attaque théorique". Il pointe
  également vers une [simulation de minage][miningsimulation github] qu'il a créée.

## Mises à jour et versions candidates

_Nouvelles mises à jour et versions candidates pour des projets d'infrastructure Bitcoin populaires.
Veuillez envisager de passer aux nouvelles versions ou d'aider à tester
les versions candidates._

- [Core Lightning 25.05rc1][] est un candidat à la sortie pour la prochaine version majeure de cette
  implémentation populaire de nœud LN.

- [LDK 0.1.3][] et [0.1.4][ldk 0.1.4] sont des sorties de cette bibliothèque populaire pour la
  construction d'applications activées par LN. La version 0.1.3, taguée
  comme une publication sur GitHub cette semaine mais datée du mois dernier, inclut le correctif pour
  une attaque par déni de service. La version 0.1.4, la dernière publication, "corrige une
  vulnérabilité de vol de fonds dans des cas extrêmement rares". Ces deux versions incluent également
  d'autres corrections de bugs.

## Changements de code et de documentation notables

_Changements récents notables dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core
lightning repo], [Eclair][eclair repo], [LDK][ldk repo], [LND][lnd repo],
[libsecp256k1][libsecp256k1 repo], [Hardware Wallet Interface (HWI)][hwi repo], [Rust Bitcoin][rust
bitcoin repo], [BTCPay Server][btcpay server repo], [BDK][bdk repo], [Propositions d'Amélioration de
Bitcoin (BIPs)][bips repo], [Lightning BOLTs][bolts repo], [Lightning BLIPs][blips repo],
[Inquisition Bitcoin][bitcoin inquisition repo], et [BINANAs][binana repo]._

- [Bitcoin Core #31622][] ajoute un champ de type de hachage de signature (sighash) à [PSBTs][topic
  psbt] quand il est différent de `SIGHASH_DEFAULT` ou `SIGHASH_ALL`. Le support de [MuSig2][topic
  musig] nécessite que tout le monde signe avec le même type de sighash, donc ce champ doit être
  présent dans le PSBT. De plus, la commande RPC `descriptorprocesspsbt` est mise à jour pour utiliser
  la fonction `SignPSBTInput`, qui assure que le type de sighash du PSBT correspond à celui fourni
  dans le CLI, le cas échéant.

- [Eclair #3065][] ajoute le support pour les échecs attribuables (voir le Bulletin [#224][news224
  failures]) tel que spécifié dans [BOLTs #1044][]. Il est désactivé par défaut car la spécification
  n'est pas finalisée, mais peut être activé avec le paramètre
  `eclair.features.option_attributable_failure = optional`. La compatibilité croisée avec LDK a été
  testée avec succès, voir le Bulletin [#349][news349 failures] pour plus d'informations sur
  l'implémentation de LDK et le fonctionnement de ce protocole.

- [LDK #3796][] renforce les vérifications du solde du canal pour que les financeurs aient
  suffisamment de fonds pour couvrir les frais de transaction d'engagement, les deux [sorties
  d'ancrage][topic anchor outputs] de 330 sat, et la réserve du canal. Auparavant, les
  financeurs pouvaient puiser dans les fonds de réserve du canal pour couvrir les deux ancrages.

- [BIPs #1760][] fusionne [BIP53][] qui spécifie une règle de soft-fork de consensus interdisant les
  transactions de 64 octets (mesurées sans les données de témoin) pour prévenir un type de
  [vulnérabilité de l'arbre de Merkle][topic merkle tree vulnerabilities] exploitable contre les
  clients SPV. Cette PR propose une solution similaire à l'une des corrections incluses dans le
  [consensus cleanup softfork][topic consensus cleanup].

- [BIPs #1850][] revient sur une mise à jour antérieure de [BIP48][] qui réservait la valeur de type
  de script 3 pour les dérivations [taproot][topic taproot] (P2TR) (voir
  le Bulletin [#353][news353 bip48]). Cela est dû au fait que [tapscript][topic tapscript] manque de
  `OP_CHECKMULTISIG`, donc le script de sortie référencé dans [BIP67][] (sur lequel [BIP48][] repose)
  ne peut pas être exprimé dans P2TR. Cette PR marque également le statut de [BIP48][] comme `Final`,
  reflétant que son but était de définir l'utilisation industrielle des chemins de dérivation de
  [portefeuille HD][topic bip32] `m/48'` lorsque le BIP a été introduit, plutôt que de prescrire un
  nouveau comportement.

- [BIPs #1793][] fusionne [BIP443][] qui propose l'opcode [OP_CHECKCONTRACTVERIFY][topic matt]
  (OP_CCV) qui permet de vérifier qu'une clé publique (tant des sorties que des entrées) s'engage sur
  un morceau de données arbitraire. Voir le Bulletin [#348][news348 op_ccv] pour plus d'informations
  sur cette proposition de [covenant][topic covenants].

{% include references.md %}
{% include linkers/issues.md v=2 issues="31622,3065,3796,1760,1850,1793,1044" %}
[Core Lightning 25.05rc1]: https://github.com/ElementsProject/lightning/releases/tag/v25.05rc1
[ldk 0.1.3]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.1.3
[ldk 0.1.4]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.1.4
[news208 slowln]: /en/newsletters/2022/07/13/#allowing-deliberately-slow-ln-payment-forwarding
[autonomous system]: https://en.wikipedia.org/wiki/Autonomous_system_(Internet)
[kirkcohen af]: https://delvingbitcoin.org/t/latency-and-privacy-in-lightning/1723
[news224 failures]: /fr/newsletters/2022/11/02/#attribution-de-l-echec-du-routage-ln
[news349 failures]: /fr/newsletters/2025/04/11/#ldk-2256
[news353 bip48]: /fr/newsletters/2025/05/09/#bips-1835
[news348 op_ccv]: /fr/newsletters/2025/04/04/#semantique-de-op-checkcontractverify
[news339 extrapool]: /fr/newsletters/2025/01/31/statistiques-mises-a-jour-sur-la-reconstruction-de-blocs-compacts
[miningsimulation github]: https://github.com/darosior/miningsimulation