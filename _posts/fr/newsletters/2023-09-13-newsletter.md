---
title: 'Bulletin Hebdomadaire Bitcoin Optech #268'
permalink: /fr/newsletters/2023/09/13/
name: 2023-09-13-newsletter-fr
slug: 2023-09-13-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Cette semaine, la newsletter propose des liens vers des spécifications
préliminaires concernant les actifs taproot et décrit un résumé de
plusieurs protocoles de messagerie alternatifs pour LN qui peuvent
aider à permettre l'utilisation de PTLC. Sont également incluses nos sections régulières concernant les questions et
réponses populaires sur le Bitcoin Stack Exchange, les nouvelles versions et
les versions candidates, et les changements apportés aux principaux logiciels
de l'infrastructure Bitcoin.

## Nouvelles

- **Spécifications pour les actifs taproot :** Olaoluwa Osuntokun a
  publié séparément sur les listes de diffusion Bitcoin-Dev et
  Lightning-Dev à propos du _protocole de validation côté client des
  actifs taproot_ [client-side validation protocol][topic client-side
  validation]. Sur la liste de diffusion Bitcoin-Dev, il a
  [annoncé][osuntokun bips] sept BIP préliminaires, soit un de plus
  que dans l'annonce initiale du protocole, alors connu sous le nom de
  _Taro_ (voir [Newsletter #195][news195 taro]). Sur la liste de
  diffusion Lightning-Dev, il a [annoncé][osuntokun blip post] un
  [projet de BLIP][osuntokun blip] pour dépenser et recevoir des actifs
  taproot en utilisant LN, avec le protocole basé sur la fonctionnalité
  expérimentale "simple taproot channels" prévue pour être publiée dans
  LND 0.17.0-beta.

    Notez que, malgré son nom, Taproot Assets ne fait pas partie du
    protocole Bitcoin et ne modifie en aucun cas le protocole de
    consensus. Il utilise des capacités existantes pour fournir de
    nouvelles fonctionnalités aux utilisateurs qui optent pour son
    protocole client.

    Aucune des spécifications n'a fait l'objet de discussion sur la
    liste de diffusion à ce jour.

- **Changements de messagerie LN pour les PTLC :** alors que la
  première implémentation LN avec une prise en charge expérimentale des
  canaux utilisant [P2TR][topic taproot] et [MuSig2][topic musig] devrait
  être publiée prochainement, Greg Sanders a [publié][sanders post] sur
  la liste de diffusion Lightning-Dev un [résumé][sanders ptlc] de
  plusieurs changements précédemment discutés concernant les messages LN
  pour leur permettre de prendre en charge l'envoi de paiements avec des
  [PTLC][topic ptlc] au lieu des [HTLC][topic htlc]. Pour la plupart
  des approches, les modifications apportées aux messages ne semblent
  pas importantes ou intrusives, mais nous notons que la plupart des
  implémentations continueront probablement d'utiliser un ensemble de
  messages pour gérer la transmission des HTLC hérités tout en offrant
  des messages améliorés pour prendre en charge la transmission des PTLC,
  créant ainsi deux chemins différents qui devront être maintenus
  simultanément jusqu'à ce que les HTLC soient progressivement
  éliminés. Si certaines implémentations ajoutent une prise en charge
  expérimentale des PTLC avant que les messages ne soient normalisés,
  alors les implémentations pourraient même être tenues de prendre en
  charge trois protocoles ou plus simultanément, au détriment de tous.

    Le résumé de Sanders n'a reçu aucun commentaire à ce jour.

## Bitcoin Core PR Review Club

*Dans cette section mensuelle, nous résumons une récente réunion du
[Bitcoin Core PR Review Club][] en soulignant certaines des questions
et réponses importantes. Cliquez sur une question ci-dessous pour voir
un résumé de la réponse de la réunion.*

[Transport abstraction][review club 28165] est un PR récemment fusionné par Pieter Wuille (sipa) qui introduit une abstraction de
_transport_ (classe d'interface). Les dérivations concrètes de cette classe convertissent les messages d'envoi et de réception (déjà
sérialisés) d'une connexion (par pair) au format filaire et vice versa. Cela peut être considéré comme la mise en œuvre d'un niveau plus
profond de sérialisation et de désérialisation. Ces classes ne réalisent pas l'envoi et la réception réels.

Le PR dérive deux classes concrètes de la classe `Transport`, `V1Transport` (ce que nous avons aujourd'hui) et `V2Transport` (chiffré sur
le fil). Ce PR fait partie du [BIP324][topic v2 p2p transport] et du [projet][v2 p2p tracking pr] _Protocole de transport chiffré P2P
Version 2_.

{% include functions/details-list.md
  q0="Quelle est la distinction entre [*net*][net] et [*net_processing*][net_processing] ?"
  a0="*Net* se situe au bas de la pile de réseau et gère
       la communication de bas niveau entre les pairs, tandis que *net_processing*
       se construit au-dessus de la couche *net* et gère le traitement
       et la validation des messages de la couche *net*."
  a0link="https://bitcoincore.reviews/28165#l-22"

  q1="Plus concrètement, citez des exemples de classes ou de fonctions que nous associerions à *net_processing*,
      et, en contraste, à *net* ?"
  a1="*net_processing* : `PeerManager`, `ProcessMessage`.
      *net* : `CNode`, `ReceiveMsgBytes`, `CConnMan`."
  a1link="https://bitcoincore.reviews/28165#l-25"

%}

## Mises à jour et versions candidates

*Nouvelles versions et versions candidates pour les principaux projets d’infrastructure Bitcoin.
 Veuillez envisager de passer aux nouvelles versions ou d’aider à tester les versions candidates.*

- [LND v0.17.0-beta.rc2][] est un candidat à la version pour la prochaine version majeure
  de cette implémentation populaire de nœud LN. Une nouvelle fonctionnalité expérimentale majeure
  prévue pour cette version, qui pourrait bénéficier de tests, est la prise en charge des "canaux taproot simples".

## Changements notables dans le code et la documentation

*Changements notables cette semaine dans [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Interface de portefeuille matériel (HWI)][hwi repo],
[Rust Bitcoin][rust bitcoin repo], [Serveur BTCPay][btcpay server repo], [BDK][bdk repo],
[Propositions d'amélioration de Bitcoin (BIP)][bips repo], [Lightning BOLTs][bolts repo] et
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [Bitcoin Core #26567][] met à jour le portefeuille pour estimer le poids d'une
  entrée signée à partir du [descripteur][topic descriptors] au lieu de faire un essai de signature.
  Cette approche réussira même pour des descripteurs [miniscript][topic miniscript] plus complexes,
  où l'approche de l'essai à sec était insuffisante.

{% include references.md %}
{% include linkers/issues.md v=2 issues="26567" %}[LND v0.17.0-beta.rc2]: https://github.com/lightningnetwork/lnd/releases/tag/v0.17.0-beta.rc2
[net]: https://github.com/bitcoin/bitcoin/blob/master/src/net.h
[net_processing]: https://github.com/bitcoin/bitcoin/blob/master/src/net_processing.h
[news195 taro]: /en/newsletters/2022/04/13/#transferable-token-scheme
[osuntokun bips]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-September/021938.html
[osuntokun blip post]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-September/004089.html
[osuntokun blip]: https://github.com/lightning/blips/pull/29
[review club 28165]: https://bitcoincore.reviews/28165
[sanders post]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-September/004088.html
[sanders ptlc]: https://gist.github.com/instagibbs/1d02d0251640c250ceea1c66665ec163
[v2 p2p tracking pr]: https://github.com/bitcoin/bitcoin/issues/27634