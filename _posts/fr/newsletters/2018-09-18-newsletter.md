---
title: 'Bulletin Hebdomadaire Bitcoin Optech #13'
permalink: /fr/newsletters/2018/09/18/
name: 2018-09-18-newsletter-fr
slug: 2018-09-18-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine comprend des éléments d'action liés à la publication de sécurité de Bitcoin Core 0.16.3 et de Bitcoin Core
0.17RC4, au BIP322 nouvellement proposé, et au prochain atelier parisien d'Optech ; un lien vers la version 0.6.1 de C-Lightning, plus
d'informations sur BIP322, et quelques détails sur la proposition Bustapay ; ainsi que de brèves descriptions de fusions notables dans des
projets populaires d'infrastructure Bitcoin.

## Action items

- **Mettez à niveau vers Bitcoin Core 0.16.3 pour corriger une vulnérabilité de déni de service :** un bogue introduit dans Bitcoin Core
  0.14.0 et affectant toutes les versions suivantes jusqu'à 0.16.2 provoquera le plantage de Bitcoin Core lorsqu'il tente de valider un bloc
  contenant une transaction qui tente de dépenser la même entrée deux fois. De tels blocs seraient invalides et ne peuvent donc être créés
  que par des mineurs prêts à perdre le revenu autorisé provenant de la création d'un bloc (au moins 12.5 XBT ou 80 000 USD).

  Des correctifs pour les branches [master][dup txin master] et [0.16][dup txin 0.16] ont été soumis hier à l'examen public, la version
  0.16.3 a été étiquetée en contenant le correctif, et les binaires seront disponibles au [téléchargement][core download] dès qu'un nombre
  suffisant de contributeurs bien connus auront reproduit la compilation déterministe---probablement plus tard aujourd'hui (mardi). Une mise
  à niveau immédiate est fortement recommandée.

- **Consacrez du temps au test de Bitcoin Core 0.17RC4 :** Bitcoin Core va bientôt téléverser les [binaires][bcc 0.17] pour la version
  candidate (RC) 4 de 0.17 contenant le même correctif pour la vulnérabilité DoS décrite ci-dessus. Tous les testeurs des précédentes
  versions candidates devraient mettre à niveau. Les tests sont grandement appréciés et peuvent aider à garantir la qualité de la version
  finale.

- **Examinez la proposition BIP322 pour la signature générique de messages :** ce BIP [récemment proposé][BIP322 proposal] permettra aux
  utilisateurs de créer des messages signés pour tous les types d'adresses Bitcoin actuellement utilisés, y compris P2PKH, P2SH,
  P2SH-wrapped segwit, P2WPKH et P2WSH. Il a le potentiel de devenir une norme de l'industrie qui sera implémentée par presque tous les
  portefeuilles et pourra être utilisée par de nombreux services (tels que les places de marché pair à pair) ainsi que pour le support
  client, donc Optech encourage à allouer du temps d'ingénierie pour s'assurer que la proposition est compatible avec les besoins de votre
  organisation. Voir la section Nouvelles ci-dessous pour des détails supplémentaires.

- **[Atelier parisien d'Optech][workshop] les 12-13 novembre :** les entreprises membres devraient [nous envoyer un e-mail][optech email]
  pour réserver des places pour vos ingénieurs. Les sujets prévus incluent une comparaison de deux méthodes pour augmenter les frais de
  transaction, une discussion sur les transactions Bitcoin partiellement signées ([BIP174][]), une introduction aux descripteurs de scripts
  de sortie, des suggestions pour l'intégration de portefeuilles Lightning Network, et des approches pour une sélection efficace des pièces
  (y compris la consolidation de sorties).

## Nouvelles

- **C-Lightning 0.6.1 publié :** cette mise à jour mineure apporte plusieurs améliorations, notamment « moins de paiements bloqués, un
  meilleur routage, moins de fermetures intempestives, et plusieurs bogues agaçants corrigés. » L'[annonce de publication][c-lightning
  0.6.1] contient des détails et des liens de téléchargement.

- **Format générique de message signé BIP322 :** depuis 2011, les utilisateurs de nombreux portefeuilles ont la possibilité de signer un
  message arbitraire en utilisant la clé publique associée à une adresse P2PKH dans leur portefeuille. Cependant, il n'existe pas de moyen
  standardisé pour les utilisateurs de faire de même avec une adresse P2SH ou avec n'importe lequel des différents types d'adresses segwit
  (bien qu'il existe certaines [méthodes non standard][trezor p2wpkh message signing] implémentées avec des fonctionnalités limitées).
  Reprenant une discussion de la liste de diffusion Bitcoin-Dev datant de plusieurs mois, Karl-Johan Alm a [proposé][BIP322 proposal] un BIP
  qui pourrait fonctionner pour n'importe quelle adresse (bien qu'il ne soit pas encore décrit comment cela fonctionnerait pour les adresses
  P2SH ou P2WSH impliquant un verrouillage temporel OP_CLTV ou OP_CSV).

  Le mécanisme de base est que le ou les dépensiers autorisés pour une adresse génèrent des scriptSigs et des données witness (y compris
  leurs signatures) de manière très similaire à ce qu'ils feraient s'ils dépensaient les fonds---sauf qu'au lieu de signer la transaction de
  dépense, ils signent leur message arbitraire à la place (plus quelques données supplémentaires prédéterminées pour s'assurer qu'ils ne
  peuvent pas être piégés pour signer une transaction réelle). Le logiciel du vérificateur valide ensuite ces informations de la même
  manière qu'il le ferait pour déterminer si une transaction de dépense était valide. Cela permet au mécanisme de signature de messages
  d'être exactement aussi flexible que les scripts Bitcoin eux-mêmes.

  Actuellement, la discussion semble être la plus active sur la [pull request][BIP322 PR] de la proposition BIP.

- **Discussion sur Bustapay :** alternative simplifiée au protocole proposé Pay-to-Endpoint (P2EP) [décrit dans le bulletin n°8][news8
  news], Bustapay offre une meilleure confidentialité à la fois pour les dépensiers et les destinataires---et permet également aux
  destinataires d'accepter des paiements sans augmenter le nombre de leurs sorties dépensables, une forme de consolidation automatique
  d'UTXO. Bien que [proposée][bustapay proposal] à la liste de diffusion Bitcoin-Dev il y a quelques semaines, plusieurs aspects de la
  proposition ont été [discutés][bustapay sjors] cette semaine.

  Bien que P2EP et Bustapay puissent finir par n'être implémentés que par un petit nombre de portefeuilles et de services similaires au
  protocole de paiement [BIP70][], il est également possible qu'ils finissent par être adoptés aussi largement que la prise en charge par
  les portefeuilles des gestionnaires d'URI [BIP21][]. Même s'ils ne connaissent pas une adoption générale, leur avantage en matière de
  confidentialité signifie qu'ils pourraient finir par être bien déployés parmi des utilisateurs de niche. Dans tous les cas, il peut être
  utile de consacrer du temps d'ingénierie au suivi des propositions et des implémentations de preuve de concept afin de garantir que votre
  organisation puisse facilement les adopter si cela est souhaitable.

## Notable commits

*Fusions notables cette semaine dans [Bitcoin Core][bitcoin core repo], [LND][lnd repo], et [C-lightning][core lightning repo]. Rappel : les
nouvelles fusions dans Bitcoin Core sont effectuées sur sa branche de développement master et il est peu probable qu'elles fassent partie de
la prochaine version 0.17---vous devrez probablement attendre la version 0.18 dans environ six mois à partir de maintenant.*

- [Bitcoin Core #14054][] : cette PR empêche le nœud d'envoyer par défaut des [messages de rejet][p2p reject] du protocole pair à pair
  [BIP61][]. Ces messages ont été implémentés pour permettre plus facilement aux développeurs de clients légers d'obtenir des retours sur
  les problèmes de connexion et de relais de transactions. Cependant, il n'existe aucune obligation (ni aucun moyen d'imposer) que les nœuds
  envoient un message de rejet ou un message de rejet exact, si bien que ces messages finissent sans doute seulement par gaspiller de la
  bande passante.

  Il est recommandé que les développeurs connectent leurs clients de test à leurs propres nœuds et inspectent les journaux de leurs nœuds à
  la recherche de messages d'erreur en cas de problèmes (peut-être après avoir activé la journalisation de débogage). Les utilisateurs qui
  ont encore besoin d'envoyer des messages `reject` peuvent utiliser l'option de configuration `-enablebip61`, bien qu'il soit possible que
  les messages `reject` soient complètement supprimés dans une version postérieure à 0.18.

- [Bitcoin Core #7965][] : ce problème de longue date suivait la suppression du code dans le composant libbitcoin_server pour gérer le fait
  que le portefeuille soit compilé ou non. Le problème a finalement été clos cette semaine par la fusion de [Bitcoin Core #14168][]. Ce
  problème, ainsi qu'un certain nombre d'autres problèmes tels que [Bitcoin Core #10973][] (Refactor: separate wallet from node) et [Bitcoin
  Core #14180][] (Run all tests even if wallet is not compiled) font partie d'un effort de long terme visant à désenchevêtrer le code du
  portefeuille du code du serveur. Cela procure un certain nombre d'avantages, notamment une maintenance du code plus facile, de meilleures
  possibilités de tester des composants individuels, et potentiellement un logiciel plus sûr si le composant portefeuille est déplacé dans
  son propre processus.

- [LND #1843][] : une option de configuration destinée uniquement aux tests (`--noencryptwallet`) a été renommée en `--noseedbackup`, a été
  marquée comme obsolète, et son texte d'aide a été mis à jour et changé en texte d'avertissement majoritairement en majuscules. Les
  développeurs craignent que des utilisateurs ordinaires n'activent cette option sans se rendre compte qu'elle les place à une seule panne
  de perdre définitivement de l'argent.

- [LND #1516][] : grâce à des mises à jour du démon Tor en amont, ce correctif permet à LND de créer et configurer automatiquement des
  services onion v3 en plus de son automatisation v2 existante. Pour que l'automatisation fonctionne, les utilisateurs doivent déjà avoir
  Tor installé et exécuté comme service.

- [C-Lightning #1860][] : pour les tests, un proxy RPC est maintenant utilisé pour simplifier la simulation des réponses à divers appels
  RPC, ce qui facilite le test de la gestion par lightningd de choses telles que les estimations de frais et les plantages de bitcoind.

{% include references.md %}
{% include linkers/issues.md issues="14054,1843,1516,7965,14168,10973,14180,1860" %}

[bcc 0.17]: https://bitcoincore.org/bin/bitcoin-core-0.17.0/
[workshop]: /en/workshops
[news8 news]: /fr/newsletters/2018/08/14/#idee-de-pay-to-end-point-p2ep-proposee
[c-lightning 0.6.1]: https://github.com/ElementsProject/lightning/releases/tag/v0.6.1
[BIP322 proposal]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-September/016393.html
[BIP322 PR]: https://github.com/bitcoin/bips/pull/725
[trezor p2wpkh message signing]: https://github.com/trezor/trezor-mcu/issues/169
[bustapay proposal]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-August/016340.html
[bustapay sjors]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-September/016383.html
[p2p reject]: https://btcinformation.org/en/developer-reference#reject
[dup txin master]: https://github.com/bitcoin/bitcoin/pull/14247
[dup txin 0.16]: https://github.com/bitcoin/bitcoin/pull/14249
[core download]: https://bitcoincore.org/en/download
