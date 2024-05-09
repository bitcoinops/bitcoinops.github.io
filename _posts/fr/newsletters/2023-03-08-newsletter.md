---
title: 'Bulletin Hebdomadaire Bitcoin Optech #241'
permalink: /fr/newsletters/2023/03/08/
name: 2023-03-08-newsletter-fr
slug: 2023-03-08-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine décrit une proposition de conception alternative
pour `OP_VAULT` avec plusieurs avantages et annonce un nouveau podcast
hebdomadaire d'Optech. Vous y trouverez également nos sections habituelles
avec le résumé d'une réunion du Bitcoin Core PR Review Club, des annonces
de nouvelles versions de logiciels et de versions candidates, ainsi que
des descriptions de changements notables apportés aux principaux logiciels
d'infrastructure Bitcoin.

## Nouvelles

- **Conception alternative pour OP_VAULT :** Greg Sanders a [posté][sanders
  vault] sur la liste de diffusion de Bitcoin-Dev une alternative pour fournir
  les fonctionnalités de la proposition `OP_VAULT`/`OP_UNVAULT` (voir [Bulletin
  #234][news234 vault]). Cette alternative ajouterait trois opcodes au lieu de
  deux. Voici un exemple :

  - *Alice dépose des fonds dans un coffre-fort* en payant une [sortie
    P2TR][topic taproot] avec un arbre de script qui contient au moins
    deux [couches de script][topic tapscript], l'un qui peut déclencher
    le processus de dégagement différé et l'autre qui peut instantanément
    geler ses fonds, par exemple `tr(key,{trigger,freeze})`.

    - Le *déclencheur des couches de script* contient ses conditions
      d'autorisation sans confiance (telles que l'exigence d'une signature
      de son hot wallet) et un opcode `OP_TRIGGER_FORWARD`. Au moment où
      elle crée cette couche de script, elle fournit à l'opcode un paramètre
      de *délai de dépense*, par exemple un timelock relatif de 1 000 blocs
      (environ 1 semaine).

    - Le *gel de la couche de script* contient toutes les conditions
      d'autorisation qu'Alice souhaite spécifier (y compris aucune) et
      un opcode `OP_FORWARD_DESTINATION`. Au moment où elle crée ces
      couches de script, elle choisit également ses conditions d'autorisation
      sans confiance (telles que l'exigence de signatures multiples provenant
      de plusieurs portefeuilles froids et de dispositifs de signature
      matériels). Il fournit à l'opcode un engagement à respecter ces
      conditions sous la forme d'un condensé de hachage.

  - *Alice déclenche un déblocage* en dépensant la sortie reçue dans l'arbre
    de script ci-dessus (en l'utilisant comme entrée) et en choisissant la
    couche de script de déblocage (trigger). A ce moment, elle fournit deux
    paramètres supplémentaires à l'opcode `OP_TRIGGER_FORWARD`, l'index de
    la sortie qui recevra les fonds de cette entrée et un engagement basé
    sur le hachage de la façon dont elle veut être en mesure de dépenser
    les fonds plus tard. L'opcode vérifie que la sortie indiquée de cette
    transaction paie une sortie P2TR avec une arborescence de scripts similaire
    à celle qui est dépensée, sauf que la couche de script de déclenchement
    est remplacée par un script utilisant un délai relatif `OP_CHECKSEQUENCEVERIFY`
    (CSV) égal au délai spécifié précédemment (par exemple, 1000 blocs) et un
    opcode `OP_FORWARD_OUTPUTS` qui inclut le hachage de l'engagement d'Alice.
    La méthode de reconstruction de l'arbre des scripts est similaire à une
    proposition antérieure de [conditions de dépense][topic covenants],
    `OP_TAPLEAF_UPDATE_VERIFY` (voir [Bulletin #166][news166 tluv]).

  - *Alice complète le déblocage* en attendant que le verrouillage temporel
    relatif ait expiré et en dépensant la sortie du déblocage, en
    choisissant le tapleaf avec l'opcode `OP_FORWARD_OUTPUTS`. L'opcode
    vérifie que les montants des sorties de la transaction de dépense
    et le hachage du script correspondent à l'engagement pris par Alice
    lors de la transaction précédente. Dans ce cas, Alice a déposé avec
    succès des fonds dans un coffre-fort, a commencé un déblocage, a été
    forcée d'attendre au moins 1 000 blocs pour permettre à ses programmes
    de surveillance de vérifier qu'elle voulait vraiment dépenser les fonds
    pour les sorties spécifiées, et a terminé la dépense.

  - En cas de problème, *Alice gèle les fonds*. Elle peut le faire à tout
    moment à partir du moment où elle dépose des fonds dans le coffre-fort
    jusqu'à ce qu'une levée du verrouillage soit effectuée. Pour geler les fonds,
    elle choisit simplement de dépenser le script de gel à partir
    de la sortie des transactions de mise en coffre ou de déclenchement.
    Rappelons qu'Alice a explicitement placé le script de gel
    dans la transaction de mise en coffre, et notons qu'elle a été
    implicitement reportée par la transaction de déclenchement qui
    a initié le déblocage.

  L'un des avantages de cette approche par rapport à la conception
  originale de l'option `OP_VAULT` est que le script de gel peut contenir
  toutes les conditions d'autorisation qu'Alice souhaite spécifier. Dans
  la proposition `OP_VAULT`, toute personne connaissant les paramètres
  choisis par Alice pouvait dépenser ses fonds dans le script de gel.
  Ce n'était pas un problème de sécurité, mais cela pouvait être gênant.
  Dans la conception de Sanders, Alice pourrait (par exemple) exiger une
  signature d'un portefeuille très peu protégé afin d'initier un gel---ce
  qui serait peut-être assez contraignant pour empêcher la plupart des
  attaques par chantage, mais pas assez pour empêcher Alice de geler
  rapidement ses fonds en cas d'urgence.

  Plusieurs autres avantages visent à rendre le [protocole de coffre-fort][topic
  vaults] renforcé par consensus plus facile à comprendre et que sa sûreté soit plus facile à vérifier.
  Ayant lu ce qui précède, l'auteur de la proposition
  `OP_VAULT`, James O'Beirne, a répondu favorablement aux idées de Sanders.
  O'Beirne avait également des idées de changements supplémentaires que nous
  décrirons dans un prochain bulletin.

- **Nouvelle baladodiffusion d'Optech :** le récapitulatif audio hebdomadaire
  d'Optech hébergé sur Twitter Spaces est désormais disponible en podcast.
  Chaque épisode sera disponible sur toutes les plateformes de podcast
  populaires et sur le site web d'Optech en tant que transcription. Pour plus
  de détails, y compris les raisons pour lesquelles nous pensons qu'il s'agit
  d'une avancée majeure dans la mission d'Optech d'améliorer la communication
  technique du bitcoin, veuillez consulter notre [billet de blogue][podcast post].

## Bitcoin Core PR Review Club

*Dans cette section mensuelle, nous résumons une récente réunion du
[Bitcoin Core PR Review Club][] en soulignant certaines des questions
et réponses importantes. Cliquez sur une question ci-dessous pour voir
un résumé de la réponse de la réunion.*

[Bitcoin-inquisition : Logique d'activation pour tester les changements de consensus][review club bi-16]
est un PR d'Anthony Towns qui ajoute une nouvelle méthode d'activation et
de désactivation des embranchements convergents dans le projet [Bitcoin
Inquisition][], conçu pour être exécuté sur [signet][topic signet] et
utilisé pour les tests.
Ce projet a fait l'objet d'un article dans le [Bulletin d'information n° 219][newsletter #219 bi].

Plus précisément, ce PR remplace la sémantique des bits de version de bloc [BIP9][]
par ce que l'on appelle des [Déploiements hérétiques][]. Contrairement aux changements
de consensus et de relais sur le réseau principal -- qui sont difficiles et longs à
activer, nécessitant la construction minutieuse d'un consensus (humain) et un mécanisme
élaboré de [l'activation de l'embranchement convergent][topic soft fork activation] -- sur
un réseau de test, l'activation de ces changements peut être rationalisée. Le PR met
également en place un moyen de désactiver les changements qui s'avèrent être des bogues
ou non désirés, ce qui constitue un changement majeur par rapport au réseau principal.

{% include functions/details-list.md
  q0="Pourquoi voulons-nous déployer des changements consensuels qui ne sont pas fusionnés dans Bitcoin Core ? Quels sont les problèmes (s'il y en a) liés à la fusion du code dans Bitcoin Core, puis à son test sur Signet ?"
  a0="Plusieurs raisons ont été discutées. Nous ne pouvons pas exiger des utilisateurs
      du réseau principal qu'ils mettent à jour la version de Core qu'ils utilisent,
      donc même après qu'un bogue ait été corrigé, certains utilisateurs peuvent continuer
      à utiliser la version boguée. Dépendre uniquement de regtest rend l'intégration des
      tests de logiciels tiers plus difficile. Fusionner les changements de consensus dans
      un dépôt séparé est beaucoup moins risqué que de les fusionner dans Core ; l'ajout
      d'une logique d'embranchement convergent, même si elle n'est pas activée, peut
      introduire des bogues qui affectent le comportement existant."
  a0link="https://bitcoincore.reviews/bitcoin-inquisition-16#l-37"

  q1="Les déploiements hérétiques passent par une séquence d'états de machines
  à états finis similaires aux états du BIP9 (`DEFINED`, `STARTED`, `LOCKED_IN`,
  `ACTIVE`, et `FAILED`), mais avec un état supplémentaire après `ACTIVE` appelé
  `DEACTIVATING` (après lequel se trouve l'état final, `ABANDONED`). Quel est le
  but de l'état `DEACTIVATING` ?"
  a1="Cela donne aux utilisateurs une chance de retirer les fonds qu'ils pourraient
      avoir bloqués dans l'embranchement convergent. Une fois la fourche désactivée
      ou remplacée, ils pourraient ne plus être en mesure de dépenser ces fonds -- même
      s'ils peuvent être dépensés par n'importe qui ; cela ne fonctionne pas si votre
      tx est rejeté parce qu'il n'est pas standard. Le problème n'est pas tant la
      perte permanente des fonds limités du Signet, mais plutôt le fait que l'ensemble
      des UTXO pourrait devenir trop volumineux."
  a1link="https://bitcoincore.reviews/bitcoin-inquisition-16#l-92"

  q2="Pourquoi le PR supprime-t-il `min_activation_height` ?"
  a2="Nous n'avons pas besoin d'un intervalle configurable entre le verrouillage
      et l'activation dans le nouveau modèle d'état -- avec les déploiements
      hérétiques, il s'active automatiquement au début de la prochaine période
      de 432 blocs (3 jours) de la machine d'état (cette période est fixe pour
      les déploiements hérétiques)."
  a2link="https://bitcoincore.reviews/bitcoin-inquisition-16#l-126"

  q3="Pourquoi Taproot est-il noyé dans ce communiqué de presse ?"
  a3="Si vous ne l'enterrez pas, vous devrez en faire un Déploiement Hérétique,
      ce qui demande un certain effort de codage ; de plus, cela signifierait
      qu'il y aurait un dépassement de temps, mais nous voulons que Taproot ne
      dépasse jamais le temps imparti."
  a3link="https://bitcoincore.reviews/bitcoin-inquisition-16#l-147"
%}

## Mises à jour et versions candidates

*Nouvelles versions et versions candidates pour les principaux projets
d'infrastructure Bitcoin. Veuillez envisager de passer aux nouvelles
versions ou d'aider à tester les versions candidates.*

- [Core Lightning 23.02][] est une nouvelle version de cette implémentation
  populaire de LN. Elle inclut un support expérimental pour le stockage des
  données de sauvegarde par les pairs (voir [Bulletin #238][news238 peer
  storage]) et met à jour le support expérimental pour le [double financement][topic
  dual funding] et les [offres][topic offers]. Plusieurs autres améliorations
  et corrections de bogues sont également incluses.

- [LDK v0.0.114][] est une nouvelle version de la bibliothèque permettant de
  créer des portefeuilles et des applications compatibles avec le LN. Elle
  corrige plusieurs bogues liés à la sécurité et inclut la possibilité
  d'analyser les [offres][topic offers].

- [BTCPay 1.8.2][] est la dernière version de ce populaire logiciel auto-hébergé
  de traitement des paiements en bitcoins. Les notes de mise à jour de la version
  1.8.0 indiquent que "cette version apporte des formulaires de paiement personnalisés,
  des options de marque de magasin, un clavier de point de vente redessiné, de
  nouvelles icônes de notification et un étiquetage des adresses".

- [LND v0.16.0-beta.rc2][] est une version candidate pour une nouvelle
  version majeure de cette implémentation populaire de LN.

## Changements notables dans le code et la documentation

*Changements notables cette semaine dans [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], et [Lightning BOLTs][bolts repo].*

- [LND #7462][] permet la création de portefeuilles de surveillance avec signature
  à distance et l'utilisation de la fonction d'initialisation sans état.

{% include references.md %}
{% include linkers/issues.md v=2 issues="7462" %}
[core lightning 23.02]: https://github.com/ElementsProject/lightning/releases/tag/v23.02
[lnd v0.16.0-beta.rc2]: https://github.com/lightningnetwork/lnd/releases/tag/v0.16.0-beta.rc2
[LDK v0.0.114]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.0.114
[BTCPay 1.8.2]: https://github.com/btcpayserver/btcpayserver/releases/tag/v1.8.2
[podcast post]: /en/podcast-announcement/
[sanders vault]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-March/021510.html
[news234 vault]: /fr/newsletters/2023/01/18/#proposition-de-nouveaux-opcodes-specifiques-aux-coffre-forts
[news166 tluv]: /en/newsletters/2021/09/15/#covenant-opcode-proposal
[news238 peer storage]: /fr/newsletters/2023/02/15/#core-lightning-5361
[newsletter #219 bi]: /fr/newsletters/2022/09/28/#implementation-de-bitcoin-concue-pour-tester-les-soft-forks-sur-signet
[review club bi-16]: https://bitcoincore.reviews/bitcoin-inquisition-16
[bitcoin inquisition]: https://github.com/bitcoin-inquisition/bitcoin
[Déploiements hérétiques]: https://github.com/bitcoin-inquisition/bitcoin/wiki/Heretical-Deployments
[bip9]: https://github.com/bitcoin/bips/blob/master/bip-0009.mediawiki
