---
title: 'Bulletin Hebdomadaire Bitcoin Optech #311'
permalink: /fr/newsletters/2024/07/12/
name: 2024-07-12-newsletter-fr
slug: 2024-07-12-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine comporte nos sections habituelles avec le résumé d'une réunion du Bitcoin Core PR Review Club,
il annonce les mises à jour et les versions candidates, et présente les changements
apportés aux principaux logiciels d'infrastructure Bitcoin.

## Nouvelles

*Aucune nouvelle significative cette semaine n'a été trouvée dans nos [sources][]. Pour
le plaisir, vous voudrez peut-être consulter une [transaction intéressante][] récente.*

## Bitcoin Core PR Review Club

*Dans cette section mensuelle, nous résumons une réunion récente du [Bitcoin Core PR Review
Club][], en soulignant certaines des questions et réponses importantes. Cliquez sur une question
ci-dessous pour voir un résumé de la réponse de
la réunion.*

[Testnet4 incluant la correction de l'ajustement de la difficulté PoW][review club 29775] est
un PR de [Fabian Jahr][gh fjahr] qui introduit Testnet4 comme un nouveau réseau de test pour
remplacer Testnet3 et corrige simultanément les bugs de longue date de l'ajustement de la difficulté
et du time warp. Il est le résultat d'une
[discussion sur la liste de diffusion][ml testnet4] et est accompagné d'une
[proposition de BIP][bip testnet4].

{% include functions/details-list.md
  q0="Mis à part les changements de consensus, quelles différences voyez-vous
  entre Testnet 4 et Testnet 3, particulièrement les paramètres de la chaîne ?"
  a0="Les hauteurs de déploiement des soft forks passés sont toutes fixées à 1, ce qui
  signifie qu'ils sont actifs dès le début. Testnet4 utilise également un
  port différent (`48333`) et un messagestart différent, et il a un nouveau
  message de bloc genesis."
  a0link="https://bitcoincore.reviews/29775#l-29"

  q1="Comment fonctionne la règle d'exception de 20 minutes dans Testnet 3 ? Comment cela conduit-il
  au bug de tempête de blocs ?"
  a1="Si le timestamp d'un nouveau bloc est de plus de 20 minutes supérieur au timestamp
  du bloc précédent, il est autorisé à avoir une difficulté de preuve de travail minimale. Le bloc
  suivant est soumis à la \"vraie\"
  difficulté à nouveau, à moins qu'il ne tombe également sous la règle d'exception de 20 minutes.
  Cette exception est faite pour permettre à la chaîne de progresser dans un
  environnement de hashrate très variable. En raison d'un bug dans l'implémentation
  de `GetNextWorkRequired()`, la difficulté est en fait
  réinitialisée (au lieu d'être simplement abaissée temporairement pour juste un bloc) lorsque le
  dernier bloc d'une période de difficulté est un bloc de difficulté minimale."
  a1link="https://bitcoincore.reviews/29775#l-47"

  q2="Pourquoi la correction du time warp a-t-elle été incluse dans le PR ? Comment fonctionne la
  correction du time warp ?"
  a2="Une attaque [time warp][topic time warp] permet à un attaquant de
  modifier significativement le taux de production des blocs, il est donc logique de
  corriger cela en même temps que le bug de difficulté minimale. Comme cela fait également partie
  du [soft fork de nettoyage du consensus][topic consensus cleanup],
  tester d'abord la correction dans Testnet4 fournit des retours précoces utiles.
  Ce PR corrige le bug du time warp en vérifiant que le premier bloc d'une
  nouvelle époque de difficulté n'est pas antérieur de plus de 2 heures au dernier bloc
  de l'époque précédente."
  a2link="https://bitcoincore.reviews/29775#l-68"

  q3="Quel est le message dans le bloc Genesis sur Testnet 3 ?"
  a3="Testnet 3, ainsi que tous les autres réseaux (précédant Testnet 4), ont le même message de bloc
  genesis bien connu : \"The Times 03/Jan/2009 Chancellor on brink of second bailout for banks\".
  Testnet4 est le premier réseau à avoir son propre message de bloc genesis, qui inclut le hash d'un
  bloc mainnet récent (actuellement
  `000000000000000000001ebd58c244970b3aa9d783bb001011fbe8ea8e98e00e`) pour fournir des garanties
  solides qu'aucun pré-minage sur cette chaîne Testnet 4 n'a eu lieu avant que ce bloc mainnet ne soit
  miné."
  a3link="https://bitcoincore.reviews/29775#l-17"
%}

## Mises à jour et versions candidates

*Nouvelles versions et candidats à la version pour des projets d'infrastructure Bitcoin populaires.
Veuillez envisager de mettre à niveau vers les nouvelles versions ou d'aider à tester les candidats
à la version.*

- [Bitcoin Core 26.2][] est une version de maintenance de la série de versions plus ancienne de
  Bitcoin Core. Nous recommandons à ceux qui sont sur la version 26.1 ou antérieure et qui ne peuvent
  ou ne veulent pas mettre à niveau vers la dernière version (27.1) de passer à cette version de
  maintenance.

- [LND v0.18.2-beta][] est une version mineure pour corriger un bug affectant les utilisateurs des
  versions antérieures du backend btcd.

## Changements notables dans le code et la documentation

_Changements récents notables dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core
lightning repo], [Eclair][eclair repo], [LDK][ldk repo], [LND][lnd repo],
[libsecp256k1][libsecp256k1 repo], [Hardware Wallet Interface (HWI)][hwi repo], [Rust Bitcoin][rust
bitcoin repo], [BTCPay Server][btcpay server repo], [BDK][bdk repo], [Propositions d'Amélioration de
Bitcoin (BIPs)][bips repo], [Lightning BOLTs][bolts repo], [Lightning BLIPs][blips repo],
[Inquisition Bitcoin][bitcoin inquisition repo], et [BINANAs][binana repo]._

- [Rust Bitcoin #2949][] ajoute une nouvelle méthode `is_standard_op_return()` pour valider les
  sorties OP_RETURN contre les règles de standardisation actuelles, permettant aux programmeurs de
  tester si les données OP_RETURN dépassent la taille maximale de 80 octets appliquée par Bitcoin
  Core. Les programmeurs qui ne sont pas préoccupés par le dépassement de la limite par défaut
  actuelle de Bitcoin Core peuvent continuer à utiliser la fonction existante de Rust Bitcoin
  `is_op_return`.

- [BDK #1487][] introduit le support pour des fonctions de tri d'entrées et de sorties
  personnalisées en ajoutant une variante `Custom` à l'énumération `TxOrdering`, pour améliorer la
  flexibilité dans la construction de transactions. Le support explicite de [BIP69][] est retiré car
  il peut ne pas fournir la confidentialité souhaitée en raison de son faible taux d'adoption (voir
  les bulletins [#19][news19 bip69] et [#151][news151 bip69]), mais les utilisateurs peuvent toujours
  créer des transactions conformes à BIP69 en mettant en œuvre un tri personnalisé approprié.

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="2949,1487" %}
[bitcoin core 26.2]: https://bitcoincore.org/bin/bitcoin-core-26.2/
[sources]: /en/internal/sources/
[transaction intéressante]: https://stacker.news/items/600187
[LND v0.18.2-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.18.2-beta
[news19 bip69]: /en/newsletters/2018/10/30/#bip69-discussion
[news151 bip69]: /en/newsletters/2021/06/02/#bolts-872
[gh fjahr]: https://github.com/fjahr
[review club 29775]: https://bitcoincore.reviews/29775
[ml testnet4]: https://groups.google.com/g/bitcoindev/c/9bL00vRj7OU
[bip testnet4]: https://github.com/bitcoin/bips/pull/1601
