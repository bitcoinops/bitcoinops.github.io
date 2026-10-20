---
title: 'Bulletin Hebdomadaire Bitcoin Optech #390'
permalink: /fr/newsletters/2026/01/30/
name: 2026-01-30-newsletter-fr
slug: 2026-01-30-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
La newsletter de cette semaine résume une approche plus efficace des circuits embrouillés et inclut
un lien vers une mise à jour de LN-Symmetry.
Sont également incluses nos sections régulières résumant les récentes questions et réponses de Bitcoin
Stack Exchange, annoncant de nouvelles versions et des candidats à la publication, ainsi que les
résumés des modifications notables apportées aux logiciels d'infrastructure Bitcoin populaires.

## Nouvelles

- **Argo : un schéma de circuits embrouillés avec un calcul offchain plus efficace** :
  Robin Linus a [posté][delving rl garbled] sur Delving Bitcoin à propos d'un nouveau
  [document][iacr le ytl garbled] de Liam Eagen et Ying Tong Lai décrivant une
  technique qui permettra une efficacité 1000 fois supérieure pour les [verrous embrouillés][news359
  rl garbled]. La nouvelle technique utilise un MAC (code d'authentification de message) qui
  encode les fils d'un circuit embrouillé en points de courbe elliptique (EC). Le
  MAC est conçu pour être homomorphe, permettant à de nombreuses opérations au sein du circuit
  embrouillé d'être représentées directement comme des opérations sur des points EC.
  L'amélioration clé est que Argo fonctionne sur des circuits _arithmétiques_, par opposition
  aux circuits binaires. Avec un circuit binaire, des millions de portes binaires sont nécessaires
  pour représenter une multiplication de point de courbe, tandis qu'avec ce circuit arithmétique,
  vous avez besoin d'une seule porte arithmétique. Le document actuel est le premier de plusieurs
  éléments nécessaires pour appliquer cette technique à des constructions similaires à
  [BitVM][topic acc] sur Bitcoin.

- **Mise à jour LN-Symmetry** : Gregory Sanders a [posté][symmetry update]
  une mise à jour sur Delving Bitcoin concernant ses travaux précédents sur [LN-Symmetry][topic eltoo]
  (voir le [Bulletin #284][news284 ln sym]).

  Sanders a rebasé son travail précédent de preuve de concept sur les
  [spécifications BOLTs][bolts fork] et l'[implémentation CLN][cln fork] avec les dernières mises à
  jour. L'implémentation mise à jour fonctionne désormais sur [Bitcoin Inquisition][bitcoin inquisition
  repo] 29.x sur [signet][topic signet] avec [TRUC][topic v3 transaction relay],
  [poussière éphémère, P2A][topic ephemeral anchors], et le [relais de paquets][topic package relay]
  1p1c.
  Elle prend en charge la fermeture coopérative des canaux, corrige un crash qui empêchait le nœud de
  redémarrer correctement, et élargit la couverture des tests. Sanders a demandé à d'autres développeurs de
  tester son nouveau concept sur signet avec Bitcoin Inquisition.

  Sanders a également exploité les capacités LLM pour migrer son travail de APO à
  OP_TEMPLATEHASH+OP_CSFS+IK (voir le [Bulletin #365][news365 op proposal]), a modifié un
  [brouillon BOLT][bolt th] et créé une [implémentation basée sur CLN][cln th].
  Cependant, Sanders a ajouté que puisque OP_TEMPLATEHASH n'est pas encore actif sur Bitcoin
  Inquisition, cette mise à jour ne peut être testée qu'en regtest.

## Questions et réponses sélectionnées de Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] est l'un des premiers endroits où les contributeurs d'Optech
cherchent des réponses à leurs questions---ou quand nous avons quelques moments libres pour aider
les utilisateurs curieux ou confus. Dans cette rubrique mensuelle, nous mettons en lumière certaines
des questions et réponses les mieux votées postées depuis notre dernière mise à jour.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Qu'est-ce qui est stocké dans dbcache et avec quelle priorité ?]({{bse}}130376)
  Murch décrit le but de la structure de données `dbcache` comme un cache en mémoire pour un
  sous-ensemble de l'ensemble complet des UTXO et détaille son comportement.

- [Peut-on réaliser un coinjoin dans Shielded CSV ?]({{bse}}130364)
  Jonas Nick souligne que le protocole Shielded CSV ne supporte pas actuellement les [coinjoins][topic
  coinjoin], mais que les protocoles de [validation côté client][topic client-side validation]
  n'excluent pas intrinsèquement une telle fonctionnalité.

- [Dans Bitcoin Core, comment utiliser Tor uniquement pour la diffusion de nouvelles transactions?]({{bse}}99442)
  Vasil Dimov répond à cette question plus ancienne en indiquant qu'avec la nouvelle option
  `privatebroadcast` (voir le [Bulletin #388][news388 private broadcast]), Bitcoin Core peut diffuser
  des transactions via des connexions de [réseaux de confidentialité][topic anonymity networks]
  éphémères.

- [Algorithme Brassard-Høyer-Tapp (BHT) et Bitcoin (BIP360)]({{bse}}130431)
  L'utilisateur bca-0353f40e explique que la capacité d'une attaque par collision sur les adresses
  [multisignature][topic multisignature] en utilisant l'algorithme [quantique][topic quantum resistance]
  Brassard-Høyer-Tapp (BHT) pour diminuer la sécurité de SHA256 n'affecterait pas les
  adresses créées avant cette capacité.

- [Pourquoi BitHash alterne-t-il entre sha256 et ripmed160 ?]({{bse}}130373)
  Sjors Provoost expose la logique derrière la fonction BitHash de [BitVM3][topic acc], une fonction
  de hachage conçue pour le langage Script de Bitcoin.

## Mises à jour et versions candidates

_Nouvelles versions et versions candidates pour des projets d'infrastructure Bitcoin populaires.
Veuillez envisager de mettre à niveau vers les nouvelles versions ou d'aider à tester les versions candidates._

- [Libsecp256k1 0.7.1][] est une version de maintenance de cette bibliothèque pour les opérations
  cryptographiques liées à Bitcoin qui inclut une amélioration de sécurité augmentant le nombre de cas
  où la bibliothèque tente d'effacer les secrets de la pile. Elle introduit également un nouveau cadre
  de tests unitaires et quelques changements dans le système de construction.

## Changements notables dans le code et la documentation

_Changements notables récents dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core
lightning repo], [Eclair][eclair repo], [LDK][ldk repo], [LND][lnd repo],
[libsecp256k1][libsecp256k1 repo], [Interface de Portefeuille Matériel (HWI)][hwi repo], [Rust
Bitcoin][rust bitcoin repo], [Serveur BTCPay][btcpay server repo], [BDK][bdk repo], [Propositions
d'Amélioration de Bitcoin (BIPs)][bips repo], [Lightning BOLTs][bolts repo], [Lightning BLIPs][blips
repo], [Inquisition Bitcoin][bitcoin inquisition repo], et [BINANAs][binana repo]._

- [Bitcoin Core #33822][] ajoute le support de l'en-tête de bloc à l'interface API
  `libbitcoinkernel` (voir le [Bulletin #380][news380 kernel]). Un nouveau
  type `btck_BlockHeader` et ses méthodes associées permettent de créer, copier et détruire des
  en-têtes, ainsi que de récupérer des champs d'en-tête tels que le hash, le hash précédent, le
  timestamp, la cible de difficulté, la version et le nonce. Une nouvelle méthode
  `btck_chainstate_manager_process_block_header()` valide et traite les en-têtes de bloc sans
  nécessiter le bloc complet, et `btck_chainstate_manager_get_best_entry()` retourne l'entrée de
  l'arbre de blocs avec la preuve de travail cumulative la plus importante.

- [Bitcoin Core #34269][] interdit la création ou la restauration de portefeuilles sans nom lors de
  l'utilisation des RPC `createwallet` et `restorewallet`, ainsi que des commandes `create` et
  `createfromdump` de l'outil portefeuille (voir les Bulletins [#45][news45 wallettool] et
  [#130][news130 wallettool]). Bien que l'interface graphique imposait déjà cette restriction, les RPC
  et les fonctions sous-jacentes ne le faisaient pas. La migration de portefeuille peut toujours
  restaurer des portefeuilles sans nom. Voir le [Bulletin #387][news387 unnamed] pour un bug lié aux
  portefeuilles sans nom.

- [Core Lightning #8850][] supprime plusieurs fonctionnalités obsolètes :
  `option_anchors_zero_fee_htlc_tx`, renommé en `option_anchors` pour refléter les changements sur
  [les sorties d'ancrage][topic anchor outputs], le RPC `decodepay` (remplacé par `decode`), les
  champs `tx` et `txid` dans la réponse de la commande `close` (remplacés par `txs` et `txids`), et
  `estimatefeesv1`, le format de réponse original utilisé par le plugin `bcli` pour retourner
  [les estimations de frais][topic fee estimation].

- [LDK #4349][] ajoute une validation pour le padding [bech32][topic bech32] lors de l'analyse des
  [offres BOLT12][topic offers], comme spécifié dans [BIP173][]. Auparavant, LDK acceptait les offres
  avec un padding invalide, tandis que d'autres implémentations, telles que Lightning-KMP et Eclair,
  les rejetaient correctement. Une nouvelle variante d'erreur `InvalidPadding` est ajoutée à
  l'énumération `Bolt12ParseError`.

- [Rust Bitcoin #5470][] ajoute une validation au décodeur pour rejeter les transactions sans
  sorties, car les transactions Bitcoin valides doivent avoir au moins une sortie.

- [Rust Bitcoin #5443][] ajoute une validation sur le décodeur pour rejeter les transactions où la
  somme des valeurs de sortie dépasse `MAX_MONEY` (21 millions de bitcoins). Cette vérification est
  liée à [CVE-2010-5139][topic cves], une vulnérabilité historique où un attaquant pourrait créer des
  transactions avec des valeurs de sortie extrêmement élevées.

- [BDK #2037][] ajoute la méthode `median_time_past()` pour calculer le temps médian passé (MTP)
  pour les structures `CheckPoint`. Le MTP, défini dans [BIP113][], est le timestamp médian des 11
  blocs précédents et est utilisé pour valider [les verrous temporels][topic timelocks]. Voir
  le [Bulletin #372][news372 mtp] pour les travaux précédents permettant cela.

- [BIPs #2076][] ajoute [BIP434][] qui définit un message de fonctionnalité P2P qui permettrait aux
  pairs d'annoncer et de négocier le support de nouvelles fonctionnalités. L'idée généralise le
  mécanisme de [BIP339][] (voir le [Bulletin #87][news87 negotiation]) mais au lieu de nécessiter un
  nouveau type de message pour chaque fonctionnalité, [BIP434][]
  fournit un message unique et réutilisable pour annoncer et négocier plusieurs mises à niveau P2P.
  Cela profite à divers cas d'utilisation P2P proposés, incluant le [partage de modèles][news366 template].
  Voir le [Bulletin #386][news386 feature] pour la discussion sur la liste de diffusion.

- [BIPs #1500][] ajoute [BIP346][] qui définit l'opcode `OP_TXHASH` pour [tapscript][topic
  tapscript] qui pousse sur la pile un digest de hash de parties spécifiées de la transaction de
  dépense. Cela peut être utilisé pour créer des [covenants][topic covenants] et réduire
  l'interactivité dans les protocoles multi-parties. L'opcode généralise
  [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify] et, combiné avec [OP_CHECKSIGFROMSTACK][topic
  op_checksigfromstack], peut émuler [SIGHASH_ANYPREVOUT][topic sighash_anyprevout]. Voir les
  Bulletins [#185][news185 txhash] et [#272][news272 txhash] pour les discussions précédentes.

{% include snippets/recap-ad.md when="2026-02-03 17:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="33822,34269,8850,4349,5470,5443,2037,2076,1500" %}
[news359 rl garbled]: /fr/newsletters/2025/06/20/#ameliorations-des-contrats-de-style-bitvm
[news369 le garbled]: /fr/newsletters/2025/08/29/#verrous-chiffres-pour-les-contrats-de-calcul-responsables
[delving rl garbled]: https://delvingbitcoin.org/t/argo-a-garbled-circuits-scheme-for-1000x-more-efficient-off-chain-computation/2210
[iacr le ytl garbled]: https://eprint.iacr.org/2026/049.pdf
[symmetry update]: https://delvingbitcoin.org/t/ln-symmetry-project-recap/359/17
[news284 ln sym]: /fr/newsletters/2024/01/10/#implementation-de-recherche-ln-symmetry
[bolts fork]: https://github.com/instagibbs/bolts/tree/eltoo_trucd
[cln fork]: https://github.com/instagibbs/lightning/tree/2026-01-eltoo_rebased
[news365 op proposal]: /fr/newsletters/2025/08/01/#proposition-de-op-templatehash-natif-a-taproot
[news388 private broadcast]: /fr/newsletters/2026/01/16/#bitcoin-core-29415
[bolt th]: https://github.com/instagibbs/bolts/tree/2026-01-eltoo_th
[cln th]: https://github.com/instagibbs/lightning/commits/2026-01-eltoo_templatehash
[Libsecp256k1 0.7.1]: https://github.com/bitcoin-core/secp256k1/releases/tag/v0.7.1
[news380 kernel]: /fr/newsletters/2025/11/14/#bitcoin-core-30595
[news45 wallettool]: /en/newsletters/2019/05/07/#new-wallet-tool
[news130 wallettool]: /en/newsletters/2021/01/06/#bitcoin-core-19137
[news387 unnamed]: /fr/newsletters/2026/01/09/#bug-de-migration-de-portefeuille-bitcoin-core
[news372 mtp]: /fr/newsletters/2025/09/19/#bdk-1582
[news87 negotiation]: /en/newsletters/2020/03/04/#improving-feature-negotiation-between-full-nodes-at-startup
[news386 feature]: /fr/newsletters/2026/01/02/#negociation-de-fonctionnalites-entre-pairs
[news366 template]: /fr/newsletters/2025/08/08/#partage-de-modele-de-bloc-entre-pairs-pour-attenuer-les-problemes-lies-aux-politiques-de-mempool-divergentes
[news185 txhash]: /en/newsletters/2022/02/02/#composable-alternatives-to-ctv-and-apo
[news272 txhash]: /fr/newsletters/2023/10/11/#specification-pour-op-txhash-proposee