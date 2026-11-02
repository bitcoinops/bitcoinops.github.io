---
title: 'Bulletin Hebdomadaire Bitcoin Optech #44'
permalink: /fr/newsletters/2019/04/30/
name: 2019-04-30-newsletter-fr
slug: 2019-04-30-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine connaît une autre semaine d'actualités calme, mais contient tout de même nos sections régulières sur la prise
en charge de l'envoi vers bech32, des questions et réponses sélectionnées de Bitcoin Stack Exchange, ainsi que des changements notables dans
des projets populaires d'infrastructure Bitcoin.

{% include references.md %}

## Mesures à prendre

*Aucune au moment de la rédaction.* Note : si l'équipe de publication de Bitcoin Core est satisfaite qu'aucun problème bloquant n'a été
trouvé dans la quatrième [version candidate][0.18.0] distribuée la semaine dernière, elle a l'intention de marquer la version finale pour la
version 0.18.0 au moment où ce bulletin est publié. Si cela se produit, nous fournirons une couverture détaillée de la publication dans le
bulletin de la semaine prochaine. Mais ne nous attendez pas si vous prévoyez de mettre à niveau---tout ce que vous devez savoir sur la
nouvelle version est expliqué dans ses notes de version, qui seront publiées avec ou liées dans le cadre des diverses annonces de
publication sur différentes plateformes telles que [BitcoinCore.org][].

## Nouvelles

*Aucune cette semaine. Nous espérons que tout le monde profite d'un beau printemps, automne, ou d'une saison sèche agréable.*

## Bech32 sending support

*Semaine 7 sur 24. Jusqu'au deuxième anniversaire du verrouillage du soft fork segwit le 24 août 2019, le bulletin Optech contiendra cette
section hebdomadaire qui fournit des informations pour aider les développeurs et les organisations à mettre en œuvre la prise en charge de
l'envoi vers bech32---la capacité de payer des adresses segwit natives. Cela [ne nécessite pas d'implémenter segwit][bech32 series]
vous-même, mais permet bien aux personnes que vous payez d' accéder à l'ensemble des multiples avantages de segwit.*

{% comment %}<!-- weekly reminder for harding: check Bech32 Adoption
wiki page for changes -->{% endcomment %}

{% include specials/bech32/07-altbech32.md %}

## Questions et réponses sélectionnées de Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] est l'un des premiers endroits où les contributeurs d'Optech cherchent des réponses à leurs
questions---ou quand nous avons quelques moments libres pour aider les utilisateurs curieux ou confus. Dans cette rubrique mensuelle, nous
mettons en lumière certaines des questions et réponses les mieux votées publiées depuis notre dernière mise à jour.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{%
endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- ["Les HTLC fonctionnent-ils pour les micropaiements ?"]({{bse}}85650) David Harding et Gregory Maxwell soulignent tous deux qu'il existe
  un risque à avoir une sortie avec un montant trop faible pour être dépensée on-chain, pendant que ce paiement est acheminé. Un
  micropaiement de moins de 546 satoshis ne serait pas relayé par le réseau Bitcoin. La mesure d'atténuation actuelle consiste pour LN à
  déplacer temporairement ces petits paiements pour qu'ils deviennent des frais de mineur au lieu d'une sortie, en s'appuyant sur la théorie
  des jeux selon laquelle si un attaquant ne peut pas voler d'argent, il ne dépensera pas d'argent pour attaquer.

- [Comment la limite de poussière de 546 satoshis a-t-elle été choisie ? Pourquoi pas 550 satoshis ?]({{bse}}86068) La politique de relais
  des transactions de Bitcoin Core fixe une limite de poussière de 546 satoshis comme montant minimum pour une sortie, ce qui semble être un
  montant particulier. Raghav Sood décrit comment 546 correspond à trois fois le coût minimum pour créer et dépenser une sortie P2PKH. Une
  référence est faite à une [discussion de 2013][dust convo].

- [Historique des transactions dans le Lightning Network.]({{bse}}85901) Un débutant en LN demande comment l'historique des transactions
  effectuées sur LN pour un utilisateur peut être sauvegardé et comment un payeur reçoit une preuve de paiement. Mark H répond qu'un
  portefeuille LN devrait sauvegarder l'historique des transactions pour un utilisateur et fournit une bonne explication de la manière dont
  un hachage de paiement fourni à un payeur aboutit à la révélation d'une préimage de paiement qui sert de preuve de paiement.

- [Comment ma clé privée peut-elle être révélée si j'utilise le même nonce lors de la génération de la signature ?]({{bse}}85638) Pieter
  Wuille fournit une réponse approfondie qui, si vous connaissez les mathématiques utilisées en cryptographie à clé publique, démontre
  comment une clé privée est révélée dans de telles circonstances.

- [Pourquoi les factures lightning expirent-elles ?]({{bse}}85981) Rene Pickhardt suppose que la raison principale serait qu'un destinataire
  recevant un volume élevé avec une capacité de stockage relativement faible pourrait manquer d'espace de stockage ou de mémoire. Une raison
  supplémentaire donnée est de fournir une certaine clôture pour avancer si un paiement n'est pas initié ou terminé plutôt que de le laisser
  en suspens. David Harding souligne que les entreprises traditionnelles mettent des dates d'expiration sur les factures pour éviter une
  obligation de livrer des biens dans le futur à un prix précédemment proposé.

- [Y a-t-il encore des mineurs ou des pools de minage qui refusent d'implémenter SegWit ?]({{bse}}86208) Mark Erhardt fournit une analyse
  approfondie démontrant que, pour l'essentiel, la réponse est « non ». Seuls 0,03 % des blocs non vides de l'année passée ne contenaient
  aucune transaction SegWit, et les deux principaux mineurs de ces quelques blocs ont démontré en 2019 qu'ils minent des blocs avec des
  transactions SegWit.

## Changements notables dans le code et la documentation

*Changements notables cette semaine dans [Bitcoin Core][bitcoin core repo], [LND][lnd repo], [C-Lightning][c-lightning repo],
[Eclair][eclair repo], [libsecp256k1][libsecp256k1 repo], et [Bitcoin Improvement Proposals (BIPs)][bips repo]. Note : sauf indication
contraire, toutes les fusions décrites pour Bitcoin Core concernent sa branche de développement master ; certaines peuvent aussi être
rétroportées vers sa version en attente de publication.*

- [Bitcoin Core #14039][] fait que Bitcoin Core rejette les transactions soumises via RPC ou reçues via le réseau P2P si elles utilisent
  l'encodage étendu de transaction de type segwit alors qu'elles n'incluent aucune entrée segwit. L'encodage étendu de transaction inclut un
  marqueur segwit, un drapeau segwit, et des champs de données witness. Les signatures incluses dans les entrées legacy ne s'engagent pas
  sur ces champs, donc l'ajout de ces champs à une transaction produit un (petit) gaspillage de bande passante dans une transaction composée
  entièrement d'entrées legacy. Pour cette raison, [BIP144][] spécifiait que les transactions qui n'ont pas besoin du format étendu
  devraient utiliser le format legacy. Auparavant, Bitcoin Core acceptait les transactions mal formatées et les normalisait en retirant les
  parties inutiles spécifiques à segwit avant de calculer leur taille (poids) ou de les relayer à d'autres pairs ; désormais il refusera
  d'accepter les transactions qui n'utilisent pas le format approprié.

- [Bitcoin Core #15846][] met à jour le nœud pour accepter des transactions dans son mempool pour relais et minage si des sorties de la
  transaction paient vers des versions d'adresse segwit 1 à 16---les versions réservées pour de futures mises à niveau du protocole.
  Auparavant, une telle transaction était rejetée. Tout argent envoyé à une adresse de version future n'est pas sécurisé (n'importe quel
  mineur peut le dépenser) tant que les utilisateurs n'appliquent pas un soft fork donnant à cette adresse une signification spéciale,
  similaire à la signification spéciale des adresses segwit version 0 pour P2WPKH et P2WSH. Cela signifie que personne ne devrait utiliser
  des adresses version 1+ aujourd'hui. Cependant, si quelqu'un crée une telle adresse et demande à un portefeuille ou service prenant en
  charge segwit de la payer, ce changement garantit que la transaction sera relayée et minée comme n'importe quelle autre transaction. (Une
  future édition de la section *bech32 sending support* de ce bulletin approfondira davantage le sujet des adresses pour les futures
  versions segwit.)

- [Eclair #950][] cesse d'envoyer des mises à jour de désactivation de canal chaque fois qu'un nœud se déconnecte, et les envoie seulement
  si quelqu'un demande au nœud d'acheminer un paiement à travers un canal dont le nœud est déconnecté. Cela évite de notifier le réseau à
  propos de canaux que personne n'essaie réellement d'utiliser. La PR apporte plusieurs autres changements mineurs à la manière dont le nœud
  gère le gossip réseau dans le but de réduire le trafic inutile.

{% include linkers/issues.md issues="14039,15846,950" %}
[0.18.0]: https://bitcoincore.org/bin/bitcoin-core-0.18.0/
[dust convo]: https://github.com/bitcoin/bitcoin/pull/2577#issuecomment-17738577
[bitcoincore.org]: https://bitcoincore.org/
[bech32 series]: /en/bech32-sending-support/
