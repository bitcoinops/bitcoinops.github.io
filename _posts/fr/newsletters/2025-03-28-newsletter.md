---
title: 'Bulletin Hebdomadaire Bitcoin Optech #347'
permalink: /fr/newsletters/2025/03/28/
name: 2025-03-28-newsletter-fr
slug: 2025-03-28-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine décrit une proposition permettant au LN de supporter des frais initiaux
et de rétention basés sur des sorties brûlables, résume la discussion concernant les testnets 3 et 4
(incluant une proposition de hard fork), et annonce un plan pour commencer à relayer certaines
transactions contenant des annexes taproot. Sont également incluses nos sections régulières résumant
des questions et réponses sélectionnées du Bitcoin Stack Exchange, annonçant de nouvelles versions
et versions candidates, et décrivant des changements notables dans des projets d'infrastructure
Bitcoin populaires.

## Nouvelles

- **Frais initiaux et de rétention du LN utilisant des sorties brûlables :** John Law a [publié][law
  fees] sur Delving Bitcoin le résumé d'un [document][law fee paper] qu'il a écrit concernant un
  protocole que les nœuds peuvent utiliser pour facturer deux types supplémentaires de frais pour le
  transfert de paiements. Un _frais initial_ serait payé par le dépensier final pour compenser les
  d'allocations concurrentes disponibles dans un canal pour faire respecter les [HTLCs][topic htlc]).
  Des _frais de rétention_ seront payés par tout nœud qui retarde le règlement d'un HTLC ; le montant de
  ces frais augmenterait avec la longueur du retard jusqu'à ce que le montant maximum soit atteint au
  moment de l'expiration de l'HTLC. Son post et son document citent plusieurs discussions antérieures
  sur les frais initiaux et de rétention, telles que celles résumées dans les Bulletins [#86][news86
  reverse upfront], [#119][news119 trusted upfront], [#120][news120 upfront], [#122][news122
  bi-directional], [#136][news136 more fee], et [#263][news263 dos philosophy].

  Le protocole proposé s'appuie sur les idées du protocole de _résolution de paiement offchain_
  (OPR) de Law (voir le [Bulletin #329][news329 opr]), qui fait en sorte que chaque co-propriétaire de
  canal alloue 100% du montant des fonds en jeu (donc 200% au total) à une _sortie brûlable_ que l'un
  d'eux peut détruire unilatéralement. Les fonds en jeu dans ce cas sont les frais initiaux plus les
  frais de rétention maximum. Si les deux parties sont plus tard satisfaites que le protocole a été
  correctement suivi, par exemple que tous les frais ont été correctement payés, elles retirent la
  sortie brûlable des futures versions de leurs transactions offchain. Si l'une des parties n'est
  pas satisfaite, elles ferment le canal et détruisent les fonds brûlables. Bien que la partie
  insatisfaite perde des fonds dans ce cas, l'autre partie également, empêchant l'une ou l'autre des
  parties de bénéficier d'une violation du protocole.

  Law décrit le protocole comme une solution pour les [attaques de blocage de canal][topic channel
  jamming attacks], une faiblesse dans le LN décrite pour la première fois [il y a presque une
  décennie][russell loop] qui permet à un attaquant de prévenir presque sans coût l'utilisation par
  d'autres nœuds de certains ou de tous leurs fonds. Dans une [réponse][harding fee], il a été noté
  que l'ajout de frais de rétention pourrait rendre les [factures de rétention][topic hold invoices]
  plus durables pour le réseau.

- **Discussion sur les testnets 3 et 4 :** Sjors Provoost a [publié][provoost testnet3]
  sur la liste de diffusion Bitcoin-Dev pour demander si quelqu'un utilisait encore testnet3
  maintenant que testnet4 était disponible depuis environ six mois (voir le [Bulletin #315][news315
  testnet4]). Andres Schildbach a [répondu][schildbach testnet3] avec l'intention de continuer à
  utiliser testnet3 dans la version testnet de son portefeuille populaire pendant au moins un an.
  Olaoluwa Osuntokun a [noté][osuntokun testnet3] que testnet3 a récemment été beaucoup plus stable
  que testnet4. Il a illustré son point en incluant des captures d'écran des arbres de blocs pour les
  deux testnets prises depuis le site web [Fork.Observer][]. Ci-dessous, trouvez notre propre capture
  d'écran montrant l'état de testnet4 au moment de la rédaction :

  ![Fork Monitor montrant l'arbre des blocs sur testnet4 le 2025-03-25](/img/posts/2025-03-fork-monitor-testnet3.png)

  Après le post d'Osuntokun, Antoine Poinsot a commencé un [fil séparé][poinsot testnet4] pour se
  concentrer sur les problèmes de testnet4. Il dit que les problèmes de testnet4 sont une
  conséquence de la règle de réinitialisation de la difficulté. Cette règle, qui s'applique uniquement
  au testnet, permet à un bloc d'être valide avec une difficulté minimale si son temps d'en-tête est 20
  minutes plus tard que son bloc parent. Provoost donne plus de [détails][provoost testnet4] sur le
  problème. Poinsot propose un hard fork de testnet4 pour supprimer la règle. Mark Erhardt
  [suggère][erhardt testnet4] une date pour le fork : le 08-01-2026.

- **Plan pour relayer certains annexes de taproot :** Peter Todd a [annoncé][todd annex] à la liste
  de diffusion Bitcoin-Dev son plan pour mettre à jour son nœud basé sur Bitcoin Core, Libre Relay,
  pour commencer à relayer les transactions contenant des [annexes][topic annex] taproot si elles
  suivent des règles particulières :

  - _Préfixe 0x00 :_ "toutes les annexes non vides commencent par l'octet 0x00, pour les distinguer
    des annexes [futures] pertinentes pour le consensus."

  - _Tout ou rien :_ "Toutes les inputs ont une annexe. Cela garantit que l'utilisation de l'annexe est
    sur une base volontaire, prévenant les attaques de [fixation de transaction][topic transaction
    pinning] dans les protocoles multi-parties."

  Le plan est basé sur une [pull request][bitcoin core #27926] de 2023 par Joost Jager, qui était
  elle-même basée sur une discussion précédente commencée par Jager (voir le [Bulletin #255][news255
  annex]). Dans les mots de Jager, la précédente pull request "limit[ait] également la taille maximale
  des données d'annexe non structurées à 256 octets [...] protégeant quelque peu les participants
  d'une transaction multi-parties qui utilise l'annexe contre l'inflation de l'annexe." La version de
  Todd n'inclut pas cette règle ; il croit que "l'exigence d'opter pour l'utilisation de l'annexe
  devrait être suffisante". Si ce n'est pas le cas, il décrit un changement de relais supplémentaire
  qui pourrait prévenir l'épinglage de contrepartie.

  À l'heure actuelle, personne dans le fil de discussion actuel de la liste de diffusion n'a décrit
  comment ils s'attendent à ce que l'annexe soit utilisée.

## Questions et réponses sélectionnées de Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] est l'un des premiers endroits où les contributeurs d'Optech
cherchent des réponses à leurs questions---ou quand nous avons quelques moments libres pour aider
les utilisateurs curieux ou confus. Dans
cette rubrique mensuelle, nous mettons en lumière certaines des questions et
réponses les plus votées postées depuis notre dernière mise à jour.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Pourquoi l'engagement de témoin est-il optionnel ?]({{bse}}125948)
  Pieter Wuille et Antoine Poinsot expliquent le [BIP30][] "Transactions dupliquées",
  [BIP34][] "Bloc v2, Hauteur dans Coinbase", et les considérations de nettoyage de consensus autour
  du [problème du bloc 1,983,702][topic duplicate transactions] et comment rendre l'engagement
  de témoin obligatoire résoudrait le problème.

- [Toutes les transactions valides par consensus de 64 octets peuvent-elles être (par une tierce partie) altérées pour changer leur taille ?]({{bse}}125971)
  Sjors Provoost explore des idées pour altérer toute [transaction de 64 octets][news27
  64tx] qui serait invalide par consensus si le soft fork de nettoyage de consensus était activé.
  Vojtěch Strnad argumente
  que toutes les transactions de 64 octets ne peuvent pas être mutées par une tierce partie,
  mais il resterait encore que le résultat d'une transaction de 64 octets
  serait soit non sécurisé (dépensable par n'importe qui) soit prouvablement
  non dépensable (par exemple, un `OP_RETURN`).

- [Combien de temps faut-il pour qu'une transaction se propage à travers le réseau ?]({{bse}}125776)
  Sr_gi souligne qu'un seul nœud ne peut pas mesurer les temps de propagation des transactions à
  l'échelle du réseau et que plusieurs nœuds à travers le réseau Bitcoin seraient nécessaires pour
  mesurer et estimer les temps de propagation. Il pointe vers un
  [site web][dsn kit] géré par le Groupe de Recherche sur les Systèmes Décentralisés et les Services
  Réseau au KIT qui mesure, entre autres, les temps de propagation des transactions qui montre "qu'une
  transaction prend environ ~7 secondes pour atteindre 50% du réseau, et environ ~17 secondes pour
  atteindre 90%".

- [Utilité de l'estimation des frais à long terme]({{bse}}124227)
  Abubakar Sadiq Ismail cherche des retours de la part de projets, protocoles, ou utilisateurs
  qui se fient aux estimations de frais à long terme pour son travail sur [l'estimation des
  frais][topic fee estimation].

- [Pourquoi utilise-t-on deux sorties d'ancrage dans le LN ?]({{bse}}125883)
  Instagibbs fournit un contexte historique pour les [sorties d'ancrage][topic anchor
  outputs] actuellement utilisées dans Lightning et souligne qu'avec les changements dans
  les politiques de [Bitcoin Core dans la version 28.0][28.0 wallet guide], une mise à jour est prévue
  pour [les engagements v3][topic v3 commitments].

- [Pourquoi n'y a-t-il pas de BIP dans la plage des 2xx ?]({{bse}}125914)
  Michael Folkson souligne que les numéros de BIP 200-299 ont été à un certain moment
  réservés pour les BIP liés à Lightning.

- [Pourquoi Bech32 n'utilise-t-il pas le caractère "b" ?]({{bse}}125902)
  Bordalix répond que la similarité visuelle entre "B" et "8" était la raison
  ne permettant pas le "B" dans les formats d'adresse [bech32 et bech32m][topic bech32]. Il fournit
  également des informations supplémentaires autour de bech32.

- [Implémentation de référence pour la détection et la correction d'erreurs Bech32]({{bse}}125961)
  Pieter Wuille note que bech32 peut détecter jusqu'à quatre erreurs dans le codage d'adresse
  et corriger deux erreurs de substitution.

- [Comment dépenser/brûler de la poussière en toute sécurité ?]({{bse}}125702)
  Murch énumère les choses à considérer lors de l'envoi de [poussière][topic
  uneconomical outputs] hors d'un portefeuille existant.

- [Comment est construite la transaction de remboursement dans les Engagements Révocables Asymétriques ?]({{bse}}125905)
  Biel Castellarnau parcourt les exemples de transactions d'engagement du livre Mastering Bitcoin.

- [Quelles applications utilisent ZMQ avec Bitcoin Core ?]({{bse}}125920)
  Sjors Provoost recherche des utilisateurs des services ZMQ de Bitcoin Core dans le cadre
  de l'investigation si [IPC][news320 ipc] pourrait remplacer ces usages.

## Mises à jour et versions candidates

_Nouvelles mises à jour et versions candidates pour des projets d'infrastructure Bitcoin populaires.
Veuillez envisager de passer aux nouvelles versions ou d'aider à tester
les versions candidates._

- [Bitcoin Core 29.0rc2][] est une version candidate pour la prochaine mise-à-jour majeure
  du nœud complet prédominant du réseau. Veuillez consulter le
  [guide de test de la version 29][bcc29 testing guide].

- [LND 0.19.0-beta.rc1][] est une version candidate pour ce nœud LN populaire.
  L'une des principales améliorations qui pourrait probablement nécessiter des tests
  est le nouveau bumping de frais basé sur RBF pour les fermetures coopératives décrit
  ci-dessous dans la section des changements de code notables.

## Changements de code et de documentation notables

_Changements récents notables dans [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Interface de Portefeuille Matériel (HWI)][hwi
repo], [Rust Bitcoin][rust bitcoin repo], [Serveur BTCPay][btcpay server repo], [BDK][bdk repo],
[Propositions d'Amélioration de Bitcoin (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Inquisition Bitcoin][bitcoin inquisition
repo], et [BINANAs][binana repo]._

- [Bitcoin Core #31603][] met à jour le parseur `ParsePubkeyInner` pour rejeter les clés publiques
  avec des espaces blancs au début ou à la fin, alignant le comportement de parsing avec le projet
  [rust-miniscript][rust miniscript]. Il n'aurait pas dû être possible d'ajouter accidentellement des
  espaces blancs auparavant en raison de la protection du checksum du descripteur. Les commandes RPC
  `getdescriptorinfo` et `importdescriptors` renvoient désormais une erreur si le fragment de clé
  publique d'un [descripteur][topic descriptors] contient de tels espaces blancs.

- [Eclair #3044][] augmente le nombre minimum par défaut de confirmations pour la sécurité des
  canaux contre les réorganisations de blocs de 6 à 8. Il supprime également l'échelle de cette valeur
  basée sur le montant du financement du canal parce que la capacité du canal peut être modifiée de
  manière significative lors du [splicing][topic splicing], convaincant le nœud
  d'accepter un faible nombre de confirmations pour ce qui est en réalité une grande
  montant d'argent en jeu.

- [Eclair #3026][] ajoute le support pour les portefeuilles Bitcoin Core utilisant des adresses
  [Pay-to-Taproot (P2TR)][topic taproot], y compris les portefeuilles en observation gérés par Eclair,
  comme base pour l'implémentation de [canaux taproot simples][topic simple taproot channels]. Les
  scripts P2WPKH sont toujours nécessaires pour certaines transactions de fermeture mutuelle, même
  lors de l'utilisation d'un portefeuille P2TR.

- [LDK #3649][] ajoute le support pour payer les Prestataires de Services Lightning (LSPs) avec des
  [offres BOLT12][topic offers] en ajoutant les champs nécessaires. Auparavant, seules les options de
  paiement [BOLT11][] et onchain étaient activées. Cela a également été proposé dans le [BLIPs #59][].

- [LDK #3665][] augmente la limite de taille de facture [BOLT11][] de 1 023 octets à 7 089 octets
  pour correspondre à la limite de LND, qui est basée sur le nombre maximum d'octets pouvant tenir sur
  un code QR. L'auteur du PR argue que les codes QR compatibles avec le codage utilisé dans une
  facture BOLT11 sont en réalité limités à 4 296 caractères, mais la valeur de 7 089 est choisie pour
  LDK parce que "la cohérence à l'échelle du système est probablement plus importante."

- [LND #8453][], [#9559][lnd #9559], [#9575][lnd #9575], [#9568][lnd #9568], et [LND #9610][]
  introduisent un flux de fermeture coopérative [RBF][topic rbf] basé sur [BOLTs #1205][] (voir
  le [Bulletin #342][news342 closev2]) qui permet à l'un ou l'autre des pairs d'augmenter le taux de
  frais en utilisant les fonds de leur propre canal. Auparavant, les pairs devaient parfois convaincre
  leur contrepartie de payer pour les augmentations de frais, ce qui se soldait souvent par des
  tentatives échouées. Pour activer cette fonctionnalité, le drapeau de configuration
  `protocol.rbf-coop-close` doit être défini.

- [BIPs #1792][] met à jour [BIP119][] qui spécifie [OP_CHECKTEMPLATEVERIFY][topic
  op_checktemplateverify] en révisant le langage pour une meilleure clarté, en supprimant la logique
  d'activation, en renommant Eltoo en [LN-Symmetry][topic eltoo], et en ajoutant des mentions de
  nouvelles propositions de [covenant][topic covenants] et de projets comme [Ark][topic ark] qui
  utilisent `OP_CTV`.

- [BIPs #1782][] reformate la section de spécification de [BIP94][], qui décrit les règles de
  consensus de [testnet4][topic testnet], pour une meilleure clarté et lisibilité.

{% include snippets/recap-ad.md when="2025-04-01 15:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="31603,3044,3026,3649,3665,9610,1792,1782,27926,8453,9559,9575,9568,1205,59" %}
[bitcoin core 29.0rc2]: https://bitcoincore.org/bin/bitcoin-core-29.0/
[bcc29 testing guide]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/29.0-Release-Candidate-Testing-Guide
[lnd 0.19.0-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.19.0-beta.rc1
[news255 annex]: /fr/newsletters/2023/06/14/#discussion-sur-les-annexes-a-taproot
[news315 testnet4]: /fr/newsletters/2024/08/09/#bitcoin-core-29775
[fork.observer]: https://fork.observer/
[law fees]: https://delvingbitcoin.org/t/fee-based-spam-prevention-for-lightning/1524/
[law fee paper]: https://github.com/JohnLaw2/ln-spam-prevention
[news329 opr]: /fr/newsletters/2024/11/15/#protocole-de-resolution-de-paiement-offchain-base-sur-mad-opr
[harding fee]: https://delvingbitcoin.org/t/fee-based-spam-prevention-for-lightning/1524/4
[provoost testnet3]: https://mailing-list.bitcoindevs.xyz/bitcoindev/9FAA7EEC-BD22-491E-B21B-732AEA15F556@sprovoost.nl/
[schildbach testnet3]: https://mailing-list.bitcoindevs.xyz/bitcoindev/7c28f8e9-d221-4633-8b71-53b4db07fa78@schildbach.de/
[osuntokun testnet3]: https://groups.google.com/g/bitcoindev/c/jYBlh24OB-Y/m/vbensqcZAwAJ
[poinsot testnet4]: https://mailing-list.bitcoindevs.xyz/bitcoindev/hU75DurC5XToqizyA-vOKmVtmzd3uZGDKOyXuE_ogE6eQ8tPCrvX__S08fG_nrW5CjH6IUx7EPrq8KwM5KFy9ltbFBJZQCHR2ThoimRbMqU=@protonmail.com/
[provoost testnet4]: https://mailing-list.bitcoindevs.xyz/bitcoindev/2064B7F4-B23A-44B0-A361-0EC4187D8E71@sprovoost.nl/
[erhardt testnet4]: https://mailing-list.bitcoindevs.xyz/bitcoindev/7c6800f0-7b77-4aca-a4f9-2506a2410b29@murch.one/
[todd annex]: https://mailing-list.bitcoindevs.xyz/bitcoindev/Z9tg-NbTNnYciSOh@petertodd.org/
[russell loop]: https://diyhpl.us/~bryan/irc/bitcoin/bitcoin-dev/linuxfoundation-pipermail/lightning-dev/2015-August/000135.txt
[news263 dos philosophy]: /fr/newsletters/2023/08/09/#philosophie-de-conception-de-la-protection-contre-les-attaques-par-deni-de-service-dos
[news136 more fee]: /en/newsletters/2021/02/17/#renewed-discussion-about-bidirectional-upfront-ln-fees
[news122 bi-directional]: /en/newsletters/2020/11/04/#bi-directional-upfront-fees-for-ln
[news86 reverse upfront]: /en/newsletters/2020/02/26/#reverse-up-front-payments
[news119 trusted upfront]: /en/newsletters/2020/10/14/#trusted-upfront-payment
[news120 upfront]: /en/newsletters/2020/10/21/#more-ln-upfront-fees-discussion
[news342 closev2]: /fr/newsletters/2025/02/21/#bolts-1205
[rust miniscript]: https://github.com/rust-bitcoin/rust-miniscript
[dsn kit]: https://www.dsn.kastel.kit.edu/bitcoin/#propdelaytx
[28.0 wallet guide]: /fr/bitcoin-core-28-wallet-integration-guide/
[news320 ipc]: /fr/newsletters/2024/09/13/#bitcoin-core-30509
[news27 64tx]: /en/newsletters/2018/12/28/#cve-2017-12842
