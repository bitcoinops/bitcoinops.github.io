---
title: 'Bulletin Hebdomadaire Bitcoin Optech #11'
permalink: /fr/newsletters/2018/09/04/
name: 2018-09-04-newsletter-fr
slug: 2018-09-04-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine comprend un rappel vous invitant à aider à tester la version candidate de la prochaine version de Bitcoin Core,
des informations sur le développement du nouveau tableau de bord public d'Optech, des résumés de deux discussions sur la liste de diffusion
Bitcoin-Dev, et des commits notables de projets d'infrastructure Bitcoin.

## Éléments d'action

- **Consacrez du temps à tester Bitcoin Core 0.17RC2 :** Bitcoin Core a téléversé les [binaires][bcc 0.17] pour la Release Candidate (RC) 2
  de la version 0.17. Les tests sont grandement appréciés et peuvent aider à assurer la qualité de la version finale.

## Éléments du tableau de bord

- **Tableau de bord Optech :** un [article de blog][dashboard post] de Marcin Jachymiak présente le tableau de bord en direct qu'il a
  développé pour Optech pendant son stage cet été, fournissant non seulement un aperçu des informations que le tableau de bord met à votre
  disposition, mais aussi une description de la manière dont il l'a construit pour toute personne souhaitant répliquer indépendamment les
  données ou étendre autrement le tableau de bord en utilisant son propre nœud complet.

  Le reste de l'équipe Optech remercie Marcin pour son travail dévoué et sa perspicacité, et nous lui souhaitons le meilleur pour l'année à
  venir.

## Nouvelles

- **Discussion sur la réinitialisation de testnet :** le premier réseau de test public de Bitcoin a été introduit fin 2010 ; quelques mois
  plus tard, il a été réinitialisé en testnet2 ; puis de nouveau réinitialisé vers l'actuel testnet3 à la mi-2012. Aujourd'hui, testnet3
  compte plus de 1,4 million de blocs et consomme plus de 20 Go d'espace disque sur les nœuds d'archivage. Une [discussion][testnet reset] a
  été lancée sur la liste de diffusion Bitcoin-Dev au sujet d'une nouvelle réinitialisation de testnet afin de fournir une chaîne plus
  petite pour l'expérimentation. En plus de la discussion sur le fait de savoir s'il est bon ou non d'avoir une grande chaîne de test pour
  l'expérimentation, il a également été [suggéré][signed testnet] qu'un futur testnet pourrait vouloir utiliser des blocs signés au lieu de
  la preuve de travail afin de permettre à la chaîne de fonctionner de manière plus prévisible que l'actuel testnet3, qui est sujet à de
  fortes oscillations du taux de hachage. Cela permettrait aussi une gestion facile des exercices de crise sur testnet, tels que de grandes
  réorganisations de chaîne.

- **Mises à jour proposées de sighash :** avant de signer une transaction, un portefeuille Bitcoin crée un hachage cryptographique de la
  transaction non signée et de certaines autres données. Ensuite, au lieu de signer directement la transaction, le portefeuille signe ce
  hachage. Depuis l'implémentation originelle 0.1 de Bitcoin, les portefeuilles sont autorisés à retirer certaines parties de la transaction
  non signée du hachage avant de la signer, ce qui permet à ces parties de la transaction d'être modifiées par d'autres personnes telles que
  d'autres participants à un contrat multipartite.

  Dans [BIP143][], segwit a conservé tous les drapeaux de hachage de signature (sighash) originaux de Bitcoin 0.1, mais a apporté quelques
  changements mineurs (mais utiles) aux données que les portefeuilles incluent dans le hachage, ce qui a rendu plus difficile pour les
  mineurs de mener des attaques DoS contre d'autres mineurs et ce qui a facilité pour des appareils peu puissants tels que les portefeuilles
  matériels la protection des fonds des utilisateurs. Cette semaine, le co-auteur de BIP143, Johnson Lau, a [publié][sighash changes]
  quelques changements suggérés aux drapeaux sighash, y compris de nouveaux drapeaux, qui pourraient être implémentés sous forme de soft
  fork en utilisant le mécanisme de mise à jour des scripts witness fourni dans le cadre de segwit.

  {% comment %}<!-- for reference: numbers in following paragraph
  correspond to the numbered bullet points in Lau's email -->{% endcomment %}

  Si les changements sont adoptés, certains des avantages notables incluent : le fait de faciliter la participation sécurisée des
  portefeuilles matériels à des transactions de type CoinJoin <!--#1--> ainsi qu'à d'autres contrats intelligents<!--#2-->, une possible
  augmentation plus facile des frais par n'importe quelle partie individuelle dans une transaction multipartite<!--#6-->, et l'empêchement
  pour des contreparties et des tierces parties à des contrats intelligents sophistiqués de gonfler la taille des transactions multipartites
  dans le cadre d'une attaque DoS qui réduit la priorité des frais d'une transaction.<!--#8-->

## Commits notables

*Commits notables cette semaine dans [Bitcoin Core][bitcoin core repo], [LND][lnd repo], et [C-lightning][core lightning repo]. Rappel : les
nouvelles fusions dans Bitcoin Core sont effectuées sur sa branche de développement master et ont peu de chances de faire partie de la
prochaine version 0.17---vous devrez probablement attendre la version 0.18 dans environ six mois à partir de maintenant.*

{% comment %}<!-- LND only had three merges this week, none of them exciting IMO -harding -->{% endcomment %}

- [Bitcoin Core #12952][] : après avoir été déprécié pendant plusieurs versions majeures et désactivé par défaut dans la prochaine version
  0.17, le système de comptes intégré de Bitcoin Core a été supprimé de la branche de développement master. Le système de comptes a été
  ajouté fin 2010 pour permettre à une première plateforme d'échange Bitcoin de gérer ses comptes utilisateurs dans Bitcoin Core, mais il
  manquait de nombreuses fonctionnalités souhaitables pour de véritables systèmes de production (comme les mises à jour atomiques de base de
  données) et il perturbait souvent les utilisateurs ; sa suppression progressive et propre est donc un objectif depuis plusieurs années.

- [Bitcoin Core #13987][] : lorsque Bitcoin Core reçoit une transaction dont les frais par vbyte sont inférieurs à son taux de frais
  minimal, il ignore cette transaction. [BIP133][] (implémenté dans Bitcoin Core 0.13.0) permet à un nœud d'indiquer à ses pairs quel est
  son taux de frais minimal afin que ces pairs ne gaspillent pas de bande passante en envoyant des transactions qui seront ignorées. Cette
  PR fournit désormais cette information pour chaque pair dans la RPC [getpeerinfo][rpc getpeerinfo] en utilisant la nouvelle valeur
  `minfeefilter`, vous permettant de découvrir facilement les taux de frais minimaux utilisés par vos pairs.

- [C-Lightning #1887][] permet désormais de demander à lightningd de calculer un objectif de taux de frais pour vos transactions on-chain en
  passant soit "urgent", "normal", ou "slow" au paramètre `feerate`. Alternativement, vous pouvez utiliser ce paramètre pour spécifier
  manuellement un taux de frais particulier que vous souhaitez utiliser.

{% include references.md %}
{% include linkers/issues.md issues="12952,13987,1887" %}

[bcc 0.17]: https://bitcoincore.org/bin/bitcoin-core-0.17.0/
[dashboard post]: /en/dashboard-announcement/
[testnet reset]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-August/016337.html
[signed testnet]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-August/016348.html
[sighash changes]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-August/016345.html
