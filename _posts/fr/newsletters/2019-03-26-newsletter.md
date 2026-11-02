---
title: 'Bulletin Hebdomadaire Bitcoin Optech #39'
permalink: /fr/newsletters/2019/03/26/
name: 2019-03-26-newsletter-fr
slug: 2019-03-26-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine renvoie vers une proposition de chiffrement des communications P2P et décrit Lightning Loop, un outil et
service permettant de retirer des bitcoins d'un canal LN vers une transaction onchain. Sont également inclus des liens vers des ressources
sur l'adoption de bech32, des résumés de questions et réponses populaires de Bitcoin Stack Exchange, ainsi qu'une liste de changements de
code notables dans des projets populaires d'infrastructure Bitcoin.

{% include references.md %}

## Mesures à prendre

- **Aidez à tester Bitcoin Core 0.18.0 RC2 :** Le deuxième candidat de publication (RC) pour la prochaine version majeure de Bitcoin Core a
  été [publié][0.18.0]. Des tests sont encore nécessaires de la part des organisations et des utilisateurs expérimentés qui prévoient
  d'exécuter la nouvelle version de Bitcoin Core en production. Utilisez [ce ticket][Bitcoin Core #15555] pour signaler vos retours.

## Nouvelles

- **Proposition de transport P2P version 2 :** Jonas Schnelli a envoyé un [BIP proposé][v2 transport] à la liste de diffusion Bitcoin-Dev
  qui spécifie un algorithme devant être utilisé pour chiffrer le trafic entre pairs. Il spécifie également quelques autres changements
  mineurs à la création des messages du protocole, comme l'autorisation pour les pairs d'utiliser des identifiants courts économisant de la
  bande passante et l'élimination de la somme de contrôle basée sur SHA256 des messages, puisque le schéma de chiffrement basé sur [AEAD][]
  protège l'intégrité des données. La proposition est destinée à remplacer [BIP151][] et elle contient des liens vers une implémentation
  d'exemple pour Bitcoin Core ainsi que quelques benchmarks. Voir le [Bulletin #10][le bulletin #10] pour la discussion précédente à propos
  du chiffrement du protocole P2P.

- **Annonce de Loop :** Lightning Labs a [annoncé][loop announced] un nouvel outil et service pour faciliter les *submarine swaps*, des
  échanges atomiques basés sur HTLC de bitcoins offchain contre des bitcoins onchain. En substance, Alice envoie à Bob un paiement LN
  sécurisé par un secret qu'elle connaît, empêchant Bob de le réclamer. Bob crée ensuite un paiement onchain qu'Alice peut dépenser en
  révélant le secret. Alice attend que le paiement reçoive un nombre approprié de confirmations puis le dépense onchain vers n'importe
  quelle adresse de son choix---révélant le secret au passage. Bob voit la transaction onchain d'Alice et utilise le secret qu'elle a révélé
  pour réclamer le paiement LN qu'Alice lui avait envoyé plus tôt. Si Alice ne révèle pas le secret, le paiement onchain contient une
  condition de remboursement qui permet à Bob de le redépenser vers lui-même après l'expiration d'un timelock.

  La majeure partie du processus est sans confiance, de sorte qu'aucune des parties n'a la possibilité de voler l'autre (à condition que le
  logiciel fonctionne correctement et soit utilisé correctement). L'exception concerne la création de la transaction onchain initiale et le
  besoin éventuel pour Bob de créer une transaction de remboursement : si l'échange sans confiance n'a pas lieu, Bob ne recevra aucune
  compensation pour les frais de transaction onchain nécessaires à ces deux transactions. D'après la [documentation de Loop][loop
  documentation], leur implémentation fait envoyer par Alice à Bob un petit paiement de confiance via LN avant l'échange sans confiance
  comme acte de bonne foi et garantie que l'opération ne finira pas par coûter de l'argent à Bob.

  En permettant à Alice et Bob d'échanger des fonds onchain et offchain, tout en continuant à utiliser leurs canaux existants, Loop aide les
  utilisateurs à garder leurs canaux ouverts plus longtemps et rend concevable qu'ils puissent rester ouverts indéfiniment.

- **Annonce du groupe de développeurs Square Crypto :** le PDG de Square a [annoncé sur Twitter][sqcrypto announced] qu'ils formaient un
  groupe pour employer plusieurs contributeurs à des projets Bitcoin open source, y compris des développeurs et un designer. Voir leur
  annonce pour les instructions de candidature. (Note : Square est également un membre sponsor d'Optech.)

## Prise en charge de l'envoi vers bech32

*Semaine 2 sur 24. À partir de maintenant et jusqu'au deuxième anniversaire du verrouillage du soft fork segwit, le 24 août 2019, le
Bulletin Optech contiendra cette section hebdomadaire qui fournit des informations pour aider les développeurs et les organisations à
implémenter la prise en charge de l'envoi vers bech32---la capacité de payer des adresses segwit natives. Cela [ne nécessite pas
d'implémenter segwit][bech32 series] vous-même, mais permet aux personnes que vous payez d'accéder à l'ensemble des multiples avantages de
segwit.*

{% include specials/bech32/02-stats.md %}

## Questions et réponses sélectionnées de Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] est l'un des premiers endroits où les contributeurs d'Optech cherchent des réponses à leurs
questions---ou quand nous avons quelques moments libres pour aider les utilisateurs curieux ou confus. Dans cette rubrique mensuelle, nous
mettons en lumière certaines des questions et réponses les mieux votées publiées depuis notre dernière mise à jour.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- Plusieurs questions sur la sécurité du transport LN : Rene Pickhardt a posé plusieurs questions sur le chiffrement utilisé pour
  communiquer les messages LN, telles que [pourquoi la longueur des messages est-elle chiffrée ?]({{bse}}85259) et [qu'a de spécial
  ChaCha20-Poly1305 ?]({{bse}}84953). Les réponses à ces questions peuvent être particulièrement intéressantes dans le contexte du BIP
  proposé pour un protocole de transport chiffré P2P de Bitcoin, dont il est prévu qu'il utilise le même chiffrement.

- Plusieurs questions sur les signatures basées sur Schnorr : Pickhardt a également posé plusieurs questions sur [BIP-Schnorr][],
  [Taproot][], et les plans visant à rendre ces fonctionnalités disponibles pour les transactions Bitcoin. Voir [est-ce que Schnorr
  permettra une seule signature par bloc ?]({{bse}}85213) et [est-ce que MuSig a la même sécurité que le multisig Bitcoin actuel
  ?]({{bse}}85101).

- [Comment les paramètres de la courbe secp256k1 ont-ils été choisis ?]({{bse}}85387) C'est la courbe elliptique utilisée dans Bitcoin.
  Certains paramètres de courbe jouent un rôle important dans la sécurité, il est donc utile de savoir si ces paramètres ont été choisis
  judicieusement. D'autres paramètres importent peu pour la sécurité, mais leur histoire peut quand même être intéressante. Dans sa réponse,
  Gregory Maxwell fournit l'historique qu'il a appris jusqu'à présent, une explication de pourquoi les questions encore ouvertes n'affectent
  pas la sécurité, et pourquoi il se pourrait que nous n'apprenions jamais davantage sur l'origine de certains paramètres de courbe.

- [Quelles adresses devrais-je prendre en charge lors du développement d'un portefeuille ?]({{bse}}84978) Un développeur demande s'il
  devrait prendre en charge à la fois les adresses P2PKH (`1foo...`) et les adresses segwit encapsulées dans P2SH (`3bar...`), ou s'il est
  sûr de simplement fournir l'adresse P2SH. Andrew Chow répond que la seule adresse P2SH suffit. Gregory Maxwell complète cela en disant
  que, si le développeur décidait d'afficher deux adresses, une meilleure combinaison serait l'adresse segwit encapsulée dans P2SH et une
  adresse segwit native (bech32) (`bc1baz...`).

## Changements notables dans le code et la documentation

*Changements notables cette semaine dans [Bitcoin Core][bitcoin core repo], [LND][lnd repo], [C-Lightning][c-lightning repo],
[Eclair][eclair repo], [libsecp256k1][libsecp256k1 repo], et les [Bitcoin Improvement Proposals (BIPs)][bips repo].*

- [Bitcoin Core #10973][] fait en sorte que le composant portefeuille intégré de Bitcoin Core accède aux informations sur la chaîne de blocs
  via une interface bien définie plutôt qu'en accédant directement aux fonctions et variables du composant nœud. Aucun changement visible
  pour l'utilisateur n'est associé à cette mise à jour, mais la fusion est notable car c'est la dernière d'un ensemble de refactorisations
  fondamentales qui devraient faciliter de futurs changements permettant d'exécuter le nœud et le portefeuille/l'interface graphique dans
  des processus séparés (voir [Bitcoin Core #10102][] pour une approche de cela), tout en améliorant également la modularité de la base de
  code de Bitcoin Core et en permettant des tests de composants plus ciblés. En plus de poser les bases de changements majeurs à venir,
  cette PR est notable pour être restée ouverte pendant plus d'un an et demi, avoir reçu près de 200 commentaires de revue de code et
  réponses, et avoir nécessité plus de 150 mises à jour et rebases. Optech remercie l'auteur de la PR, Russell Yanofsky, pour son incroyable
  dévouement à mener cette PR jusqu'à sa fusion.

- [Bitcoin Core #15617][] omet d'envoyer des messages `addr` contenant les adresses IP de pairs que le nœud a actuellement sur sa liste de
  bannissement. Cela empêche votre nœud d'informer d'autres nœuds de pairs qu'il a trouvés abusifs.

- [Bitcoin Core #13541][] modifie la RPC `sendrawtransaction` pour remplacer le paramètre `allowhighfees` par un paramètre `maxfeerate`. Le
  paramètre précédent, s'il était défini à true, envoyait la transaction même si les frais totaux dépassaient le montant défini par l'option
  de configuration `maxtxfee` (par défaut : 0.1 BTC). Le nouveau paramètre prend un taux de frais et rejettera la transaction si son taux de
  frais est supérieur à la valeur fournie (indépendamment du réglage de `maxtxfee`). Si aucune valeur n'est fournie, il n'enverra la
  transaction que si ses frais sont inférieurs au total `maxtxfee`.

- [LND #2765][] change la manière dont le nœud LN réagit aux violations de canal (tentatives de vol). Auparavant, si une tentative de
  violation était détectée, le nœud créait une transaction de remédiation de violation pour collecter tous les fonds associés à ce canal.
  Cependant, lorsque les utilisateurs commenceront à utiliser des watchtowers, la watchtower pourra créer une transaction de remédiation de
  violation sans inclure tous les fonds possibles. (Cela ne signifie pas que la watchtower est malveillante : votre nœud n'a peut-être
  simplement pas eu l'occasion de dire à la watchtower quels étaient les derniers engagements qu'il avait acceptés.) Cette PR met à jour la
  logique utilisée pour générer la transaction de remédiation de violation afin qu'elle ne collecte que les fonds qui n'ont pas été
  collectés par des transactions de remédiation de violation antérieures, permettant la récupération de tous les fonds que la watchtower n'a
  pas collectés.

- [LND #2691][] augmente la valeur par défaut d'anticipation d'adresses lors de la récupération de 250 à 2 500. C'est le nombre de clés
  dérivées d'une seed HD que le portefeuille utilise lorsqu'il réexamine la chaîne de blocs à la recherche de vos fonds. Auparavant, si
  votre nœud distribuait plus de 250 adresses ou clés publiques sans qu'aucune d'entre elles ne soit utilisée, votre nœud ne trouvait pas
  votre solde complet lors de son premier rescannage, vous obligeant à lancer des tentatives supplémentaires. Désormais, il faudrait
  distribuer plus de 2 500 adresses avant qu'une nouvelle itération puisse devenir nécessaire. Une version antérieure de cette PR voulait
  fixer cette valeur à 25 000, mais des inquiétudes existaient quant au fait que cela ralentirait considérablement le rescannage avec
  l'implémentation Neutrino de BIP158, donc la valeur a été réduite jusqu'à ce qu'il puisse être montré que les gens avaient besoin d'une
  valeur aussi élevée. (Note : vérifier des adresses par rapport à un filtre BIP158 est en soi très rapide ; le problème est que toute
  correspondance nécessite le téléchargement et l'analyse du bloc associé---même s'il s'agit d'une fausse correspondance positive. Plus vous
  vérifiez d'adresses, plus le nombre attendu de faux positifs est élevé, donc l'analyse devient plus lente et nécessite plus de bande
  passante.)

- [C-Lightning #2470][] modifie la RPC `setchannelfee` récemment ajoutée de sorte que "all" puisse être passé à la place de l'identifiant
  d'un nœud spécifique afin de définir les frais de routage pour tous les canaux.

- [Eclair #826][] met à jour Eclair pour être compatible avec Bitcoin Core 0.17 et la future 0.18, abandonnant la prise en charge de 0.16.

{% include linkers/issues.md issues="10973,15617,13541,2765,2691,2470,826,15555,10102" %}
[0.18.0]: https://bitcoincore.org/bin/bitcoin-core-0.18.0/
[aead]: https://en.wikipedia.org/wiki/Authenticated_encryption
[loop announced]: https://blog.lightning.engineering/posts/2019/03/20/loop.html
[loop documentation]: https://github.com/lightninglabs/loop/blob/master/docs/architecture.md
[sqcrypto announced]: https://twitter.com/jack/status/1108487911802966017
[taproot]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-January/015614.html
[v2 transport]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-March/016806.html
[bech32 series]: /en/bech32-sending-support/
[le bulletin #10]: /fr/newsletters/2018/08/28/#pr-ouverte-pour-le-support-initial-de-bip151
