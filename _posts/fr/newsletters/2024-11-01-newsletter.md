---
title: 'Bulletin Hebdomadaire Bitcoin Optech #327'
permalink: /fr/newsletters/2024/11/01/
name: 2024-11-01-newsletter-fr
slug: 2024-11-01-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine décrit une proposition pour les fabriques de canaux avec arbre de
timeout et résume un projet de BIP pour les preuves d'équivalence de logarithme discret à utiliser
lors de la génération de paiements silencieux. Sont également incluses nos sections régulières avec
les annonces de nouvelles versions de logiciels et les descriptions des changements notables
apportés aux logiciels d'infrastructure Bitcoin populaires.

## Nouvelles

- **Fabriques de canaux avec arbre de timeout :** ZmnSCPxj a [publié][zmnscpxj post1] sur Delving
  Bitcoin et [discuté][deepdive] avec les contributeurs d'Optech une proposition pour une nouvelle
  conception de [fabrique de canaux][topic channel factories] multi-couches nommée _SuperScalar_.
  L'objectif de la conception est de fournir une construction qui pourrait être facilement mise en
  œuvre par un seul vendeur sans attendre de grands changements de protocole nécessitant un accord
  général. Par exemple, un fournisseur de services Lightning (LSP) qui distribue des logiciels de
  portefeuille pourrait permettre à ses utilisateurs d'ouvrir des canaux plus économiquement et de
  recevoir de la liquidité entrante sans sacrifier l'absence de confiance de LN.

  La construction globale est basée sur un _arbre de timeout_, où une _transaction de financement_
  paie à un arbre de transactions enfants pré-définies qui sont finalement dépensées hors chaîne dans
  de nombreux canaux de paiement séparés. Après un timeout configurable (par exemple, un mois),
  certaines des parties impliquées dans l'arbre de timeout abandonnent tout fonds restant dans l'arbre
  ---cela les incite à retirer ou à trouver une sécurité alternative pour ces fonds avant l'expiration,
  ce qui peut encourager l'utilisation de mécanismes hors chaîne bon marché plutôt que de publier des
  parties de l'arbre sur la chaîne. Dans les arbres de timeout précédemment décrits (voir le [Bulletin
  #270][news270 timeout trees]), les fonds des utilisateurs qui expiraient devenaient la propriété
  d'un fournisseur de services, mais ZmnSCPxj inverse cela et fait en sorte que les fonds expirés d'un
  fournisseur de services deviennent la propriété des utilisateurs---cela place le fardeau de la
  confirmation des transactions sur le fournisseur de services plutôt que sur les utilisateurs finaux.

  Les arbres de timeout utilisés nécessitent la contribution d'une signature de chaque partie
  impliquée. Cela évite le besoin de changements de consensus mais limite le nombre maximum pratique
  d'utilisateurs dans une fabrique en raison du bien connu [problème de coordination
  multi-signataires][news270 coordination].

  La plupart des feuilles de l'arbre de timeout sont des transactions de financement hors chaîne pour
  le type commun de canal utilisé aujourd'hui ([LN-Penalty][]), permettant une certaine réutilisation
  du code existant pour la gestion des canaux LN. Les contreparties dans chaque canal sont un
  utilisateur final et le fournisseur de services Lightning (LSP) qui a créé l'arbre de timeout.
  Certaines des feuilles de l'arbre peuvent également être contrôlées exclusivement par le LSP dans le
  but de rééquilibrer les fonds.

  Entre la racine et les feuilles se trouvent des [canaux de micropaiement duplex][topic duplex
  micropayment channels]. Contrairement aux canaux LN-Penalty, les canaux duplex permettent à plus de
  deux parties de partager en toute sécurité des fonds ; cependant, ils permettent également un nombre
  relativement petit de mises à jour d'état par rapport au nombre effectivement illimité de mises à
  jour de LN-Penalty. Les canaux duplex intermédiaires sont utilisés pour permettre des rééquilibrages
  impliquant le LSP et deux utilisateurs finaux ; ces rééquilibrages pourraient
  compléter de manière sécurisée à des vitesses hors chaîne, permettant à un utilisateur de recevoir
  un paiement entrant presque instantanément même s'il n'avait pas auparavant suffisamment de capacité
  dans son canal pour l'accepter.

  Dans un [article ultérieur][zmnscpxj post2], ZmnSCPxj a décrit le remplacement d'une partie d'un
  canal duplex par un canal de micropaiement [de style Spillman][spillman channel] (simplex). Cela
  serait plus efficace sur la chaîne en cas de fermeture coopérative, bien que cela serait moins
  efficace sur la chaîne en cas de fermeture unilatérale.

  La proposition a reçu une quantité modérée de discussion. L'auteur a dit que l'une des faiblesses de
  la proposition est sa complexité technique due à l'utilisation de plusieurs types de canaux
  différents plus le défi inhérent à toute conception de fabrique de canaux de gérer un état hors
  chaîne supplémentaire. Cependant, la proposition a l'avantage d'être quelque chose qui pourrait être
  mis en œuvre par une seule équipe et rendu interopérable avec le LN standard sans nécessiter de
  nombreux changements au protocole LN.

- **Brouillon de BIP pour les preuves DLEQ :** Andrew Toth a [posté][toth dleq] sur la liste de
  diffusion Bitcoin-Dev un brouillon de BIP et un lien vers une [implémentation][dleq imp] pour
  générer et vérifier les preuves d'[égalité de logarithme discret][topic dleq] (DLEQ) pour la courbe
  elliptique utilisée par Bitcoin (secp256k1). Un DLEQ permet à une partie de prouver qu'elle connaît
  une clé privée sans révéler quoi que ce soit à son sujet, comme sa clé publique correspondante. Cela
  a été utilisé dans le passé pour permettre à quelqu'un de prouver qu'il possède un UTXO sans révéler
  quel UTXO (voir les Bulletins [#83][news83 podle] et [#131][news131 podle]).

  Le BIP actuel est motivé par le soutien pour les [paiements silencieux][topic silent payments] créés
  en utilisant plusieurs signataires indépendants. Si un signataire ment ou est défectueux, il est
  possible que des fonds soient perdus. Un DLEQ permet à chaque signataire de prouver qu'ils ont signé
  correctement sans révéler leurs clés privées aux autres signataires. Voir le [Bulletin #308][news308
  sp] pour une discussion précédente.

  La proposition a reçu une [réponse][gibson dleq] d'Adam Gibson, qui a précédemment implémenté un
  système de preuve DLEQ pour l'implémentation [coinjoin][topic coinjoin] de JoinMarket. Il a suggéré
  plusieurs changements qui rendraient la version du BIP de DLEQ plus flexible pour d'autres
  utilisations au-delà des paiements silencieux.

## Mises à jour et versions candidates

_Nouvelles mises à jour et versions candidates à la sortie pour des projets d'infrastructure Bitcoin populaires.
Veuillez envisager de passer aux nouvelles versions ou d'aider à tester
les versions candidates._

- [BTCPay Server 2.0.0][] est la dernière version de ce processeur de paiement auto-hébergé. Ses
  nouvelles fonctionnalités incluent "une meilleure localisation, une navigation latérale, un flux
  d'intégration amélioré, des options de marque améliorées, le support pour des fournisseurs de taux
  plugables" et plus encore. La mise à niveau comprend des changements majeurs et des migrations de
  base de données ; il est recommandé de lire l'[annonce][btcpay post] avant de mettre à niveau.

## Changements notables de code et de documentation

_Changements récents notables dans [Bitcoin Core][bitcoin core repo], [CoreLightning][core
lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Interface de Portefeuille Matériel (HWI)][hwi
repo], [Rust Bitcoin][rust bitcoin repo], [Serveur BTCPay][btcpay server repo], [BDK][bdk repo],
[Propositions d'Amélioration de Bitcoin (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Inquisition Bitcoin][bitcoin inquisition
repo], et [BINANAs][binana repo]._

- [Bitcoin Core #31130][] supprime le support Universal Plug and Play (UPnP) Internet
  Gateway Device (IGD) en abandonnant la dépendance `miniupnp`, qui avait
  une histoire de vulnérabilités de sécurité et était déjà désactivée par défaut (voir
  le Bulletin [#310][news310 upnp]). Elle est maintenant remplacée par une implémentation du Protocole
  de Contrôle de Port (PCP) avec une solution de repli du Protocole de Mappage de Port de Traduction
  d'Adresse Réseau (NAT-PMP) (voir le Bulletin [#323][news323 pcp]), qui
  permet aux nœuds d'être accessibles sans configuration manuelle, mais élimine
  les risques de sécurité associés à la dépendance `miniupnp`.

- [LDK #3007][] ajoute deux nouvelles variantes `BlindedForward` et `BlindedReceive` à
  l'énumération `OutboundTrampolinePayload` pour introduire le support des [chemins aveuglés][topic rv
  routing] dans [le routage trampoline][topic trampoline payments] comme
  base pour l'implémentation du protocole [offres][topic offers] [BOLT12][].

- [BIPs #1676][] met à jour le statut de [BIP85][] en final, car il est largement
  déployé et a dépassé le point d'introduction de changements majeurs. Cela a été proposé
  après qu'un récent changement majeur ait été fusionné puis révoqué (voir
  le Bulletin [#324][news324 bip85]).

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="31130,3007,1676" %}
[news83 podle]: /en/newsletters/2020/02/05/#podle
[news131 podle]: /en/newsletters/2021/01/13/#ln-dual-funding-anti-utxo-probing
[news308 sp]: /fr/newsletters/2024/06/21/#discussion-continue-sur-les-psbt-pour-les-paiements-silencieux
[zmnscpxj post1]: https://delvingbitcoin.org/t/superscalar-laddered-timeout-tree-structured-decker-wattenhofer-factories/1143
[deepdive]: /fr/podcast/2024/10/31/
[news270 timeout trees]: /fr/newsletters/2023/09/27/#utilisation-de-covenants-pour-ameliorer-la-scalabilite-de-ln
[zmnscpxj post2]: https://delvingbitcoin.org/t/superscalar-laddered-timeout-tree-structured-decker-wattenhofer-factories/1143/16
[spillman channel]: https://en.bitcoin.it/wiki/Payment_channels#Spillman-style_payment_channels
[toth dleq]: https://mailing-list.bitcoindevs.xyz/bitcoindev/b0f40eab-42f3-4153-8083-b455fbd17e19n@googlegroups.com/
[dleq imp]: https://github.com/BlockstreamResearch/secp256k1-zkp/blob/master/src/modules/ecdsa_adaptor/dleq_impl.h
[gibson dleq]: https://mailing-list.bitcoindevs.xyz/bitcoindev/77ad84ed-2ff8-4929-b8da-d940c95d18a7n@googlegroups.com/
[news270 coordination]: /fr/newsletters/2023/09/27/#utilisation-de-covenants-pour-ameliorer-la-scalabilite-de-ln
[ln-penalty]: https://en.bitcoin.it/wiki/Payment_channels#Poon-Dryja_payment_channels
[btcpay post]: https://blog.btcpayserver.org/btcpay-server-2-0/
[btcay server 2.0.0]: https://github.com/btcpayserver/btcpayserver/releases/tag/v2.0.0
[news310 upnp]: /fr/newsletters/2024/07/05/#execution-de-code-a-distance-due-a-un-bug-dans-miniupnpc
[news323 pcp]: /fr/newsletters/2024/10/04/#bitcoin-core-30043
[news324 bip85]: /fr/newsletters/2024/10/11/#bips-1674