---
title: 'Bulletin Hebdomadaire Bitcoin Optech #42'
permalink: /fr/newsletters/2019/04/16/
name: 2019-04-16-newsletter-fr
slug: 2019-04-16-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine demande de tester les dernières versions candidates de Bitcoin Core et LND, décrit comment aider les gens à
accepter des paiements vers des adresses bech32 peut réduire les frais, et liste les changements notables dans le code de projets Bitcoin
populaires.

{% include references.md %}

## Mesures à prendre

- **Aidez à tester les versions candidates de Bitcoin Core 0.18.0 :** la troisième RC de Bitcoin Core pour sa prochaine version majeure est
  [disponible][0.18.0] et une quatrième est en préparation. Les tests sont grandement appréciés. Veuillez utiliser [ce ticket][Bitcoin Core
  #15555] pour signaler vos retours.

- **Aidez à tester LND 0.6-beta RC4 :** des [versions candidates][lnd releases] pour la prochaine version majeure de LND sont en cours de
  publication. Les tests par les organisations et les utilisateurs expérimentés du LN sont encouragés afin de détecter toute régression ou
  problème sérieux qui pourrait affecter les utilisateurs de la version finale. [Ouvrez un nouveau ticket][lnd issue] si vous découvrez des
  problèmes.

## Nouvelles

*Aucune nouvelle technique notable cette semaine. (Remarque : lorsque nous, chez Optech, avons commencé ce bulletin, nous avons décidé
d'éviter de remplir les bulletins courts avec des articles de remplissage et d'autres informations inutiles, donc la longueur du bulletin
varie en fonction de la quantité réelle de nouvelles techniques significatives chaque semaine. Vous nous avez probablement déjà vus publier
un bulletin occasionnellement très long ; cette semaine, vous voyez l'inverse.)*

## Support d'envoi Bech32

*Semaine 5 sur 24. Jusqu'au deuxième anniversaire du verrouillage du soft fork segwit le 24 août 2019, le bulletin Optech contiendra cette
section hebdomadaire qui fournit des informations pour aider les développeurs et les organisations à implémenter la prise en charge de
l'envoi vers bech32---la capacité de payer des adresses segwit natives. Cela [ne nécessite pas d'implémenter segwit][bech32 series]
vous-même, mais cela permet aux personnes que vous payez de bénéficier de tous les multiples avantages de segwit.*

{% include specials/bech32/05-fee-savings.md %}

## Changements notables dans le code et la documentation

*Changements notables cette semaine dans [Bitcoin Core][bitcoin core repo], [LND][lnd repo], [C-Lightning][c-lightning repo],
[Eclair][eclair repo], [libsecp256k1][libsecp256k1 repo], et [Bitcoin Improvement Proposals (BIPs)][bips repo]. Remarque : toutes les
fusions décrites pour Bitcoin Core et LND concernent leurs branches de développement master ; certaines peuvent aussi être rétroportées vers
leurs versions en attente de publication.*

- [Bitcoin Core #15711][] génère par défaut des adresses bech32 dans l' interface graphique. L'utilisateur peut toujours générer une adresse
  segwit encapsulée dans P2SH en décochant une case sur l'écran de demande de paiement au cas où il aurait besoin de recevoir de l'argent
  d'un service qui ne fournit pas encore la prise en charge de l'envoi vers bech32. Le comportement par défaut de bitcoind consistant à
  générer des adresses segwit encapsulées dans P2SH n'est pas modifié.

- [C-Lightning #2506][] ajoute un paramètre de configuration `min-capacity-sat` pour rejeter les demandes d'ouverture de canal en dessous
  d'une certaine valeur. Cela remplace un minimum codé en dur de 0.00001 BTC précédemment présent dans le code.

- [LND #2933][] ajoute un document décrivant les actuelles [options de sauvegarde et de récupération de LND][lnd recover].

- [C-Lightning #2540][] ajoute un hook de facture appelé chaque fois qu'un « paiement valide pour une facture impayée est arrivé ». Parmi
  d'autres tâches pouvant être effectuées lorsqu'un paiement est reçu, cela peut être utilisé par un plugin pour implémenter des « hold
  invoices » comme cela a été précédemment implémenté dans LND (voir notre description de [LND #2022][] dans le [Bulletin #38][le bulletin #38]).

- [C-Lightning #2554][] modifie l'expiration par défaut des factures d'une heure à une semaine. C'est la durée après laquelle le nœud
  rejettera automatiquement les tentatives de paiement de la facture. Les services qui veulent minimiser le risque de taux de change devront
  passer une valeur `expiry` plus faible lors de l'utilisation de la RPC `invoice`.

{% include linkers/issues.md issues="15555,15711,2933,2908,2540,2554,2506,2022" %}
[0.18.0]: https://bitcoincore.org/bin/bitcoin-core-0.18.0/
[lnd releases]: https://github.com/lightningnetwork/lnd/releases
[bech32 easy]: /fr/newsletters/2019/03/19/#prise-en-charge-de-lenvoi-vers-bech32
[lnd issue]: https://github.com/lightningnetwork/lnd/issues/new
[lnd recover]: https://github.com/lightningnetwork/lnd/blob/master/docs/recovery.md
[bech32 series]: /en/bech32-sending-support/
[le bulletin #38]: /fr/newsletters/2019/03/19/#lnd-2022
