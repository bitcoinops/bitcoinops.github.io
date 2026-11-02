---
title: 'Bulletin Hebdomadaire Bitcoin Optech #36'
permalink: /fr/newsletters/2019/03/05/
name: 2019-03-05-newsletter-fr
slug: 2019-03-05-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine renvoie à l'annonce de la mise à niveau de C-Lightning 0.7, signale une interruption de service pour la liste
de diffusion Bitcoin-Dev, et décrit un soft fork proposé pour éliminer plusieurs anciens problèmes du protocole de consensus de Bitcoin.
Sont également inclus des résumés de commits notables dans des projets populaires d'infrastructure Bitcoin.

## Mesures à prendre

- **Mettre à niveau vers C-Lightning 0.7 :** la fonctionnalité la plus notable de cette nouvelle version majeure est un système de plugins
  qui permet à votre code de fournir des RPC personnalisées ou de s'exécuter sur des événements internes de `lightningd`. La version met
  également en œuvre des améliorations du protocole et plusieurs corrections de bugs. Voir l'[annonce de publication][cl 0.7] pour les
  détails et envisagez la [mise à niveau][cl upgrade].

## Nouvelles

- **Panne de la liste de diffusion Bitcoin-Dev :** les e-mails envoyés à la liste de diffusion Bitcoin-Dev ne sont pas relayés aux lecteurs.
  Les administrateurs de la liste tentent de résoudre le problème et étudient également des fournisseurs de liste alternatifs. Les autres
  listes liées à Bitcoin hébergées par la Linux Foundation (comme la liste Lightning-Dev) ne semblent pas souffrir du même problème. Les
  prochains bulletins d'Optech mentionneront toute action que les abonnés à la liste devront entreprendre afin de continuer à recevoir les
  discussions sur le protocole.

- **Proposition de soft fork de nettoyage :** Matt Corallo a ouvert une [pull request Bitcoin Core][Bitcoin Core #15482] et a tenté
  d'envoyer un [BIP proposé][BIP-cleanup] à la liste de diffusion Bitcoin-Dev pour un potentiel soft fork visant à éliminer plusieurs cas
  limites qui pourraient permettre à quelqu'un d'attaquer le réseau Bitcoin ou ses utilisateurs. Les vulnérabilités sont publiquement
  connues depuis des années et on pense que de véritables attaques auraient soit été trop coûteuses pour être rentables, soit auraient pu
  être traitées suffisamment rapidement pour ne pas menacer la viabilité de Bitcoin. Néanmoins, il serait préférable de corriger les
  vulnérabilités de manière proactive plutôt que réactive.

  Optech résume la proposition dans les points suivants, mais nous reconnaissons que de nombreux lecteurs ne seront pas familiers avec les
  détails de concepts tels que `OP_CODESEPARATOR`, `FindAndDelete()`, les attaques time warp et les vulnérabilités des arbres de merkle,
  nous avons donc également inclus une annexe à ce bulletin qui fournit un contexte supplémentaire sur ces sujets.

  - **Empêcher l'utilisation de `OP_CODESEPARATOR` et `FindAndDelete()` dans les transactions legacy :** personne n'est connu pour utiliser
    ces deux fonctionnalités de Bitcoin dans les transactions Bitcoin legacy (non-segwit), mais un attaquant peut en abuser pour augmenter
    considérablement la quantité de travail de calcul nécessaire à la vérification d'une transaction non standard, en créant des blocs dont
    la vérification pourrait prendre une demi-heure ou plus. La plupart des lecteurs n'auront probablement jamais entendu parler de l'une ou
    l'autre de ces fonctionnalités parce qu'aucune d'elles ne permet un comportement utile connu qui ne puisse être accompli autrement, mais
    toute personne ayant encore besoin de `OP_CODESEPARATOR` peut utiliser la version segwit de [BIP143][], qui a été implémentée d'une
    manière qui évite l'explosion du coût de calcul. Les transactions utilisant ces fonctionnalités n'ont pas été minées ni relayées par
    défaut depuis Bitcoin Core 0.16.1, publié en juin 2018.

{% comment %}<!--
      ## How long until all bitcoins are released by a timewarp
      ## There are 26 retarget periods per year, about 100 years of subsidy left: 2600
      ## Calculate in days
      In [7]: x = 0 ...: for i in range(2600): ...: x += 14*(0.25**i) ...: print(x) ...: 18.666666666666668 -->{% endcomment %}

  - **Corriger l'attaque time warp :** cette attaque permet à des mineurs contrôlant une majorité du hashrate de maintenir ou de diminuer la
    difficulté de minage même lorsque le hashrate total du réseau est stable ou en augmentation, leur permettant de produire des blocs plus
    rapidement que ne le prévoit le protocole. L'augmentation de la production de blocs accélérerait la libération de la subvention de bloc
    de Bitcoin, libérant potentiellement tous les bitcoins restants dans les trois semaines suivant le début de l'attaque. Cependant, la
    préparation de l'attaque serait publiquement visible pendant au moins une semaine avant d'avoir un quelconque effet, si bien que sa
    correction n'a pas eu une priorité élevée en l'absence d'un cartel de mineurs essayant de la réaliser. Le soft fork proposé corrige le
    problème en exigeant que le premier bloc d'une nouvelle période de difficulté ait un horodatage qui ne soit pas antérieur de plus de 600
    secondes au dernier bloc de la période précédente. Voir aussi le [Bulletin #10][le bulletin #10] où nous mentionnons une discussion sur
    la liste de diffusion à ce sujet.

  - **Interdire l'utilisation d'opcodes non-push dans scriptSig :** depuis le [correctif][1opreturn fix] de juillet 2010 pour une
    vulnérabilité critique de sécurité, chaque `sciptSig` est évalué jusqu'à ne contenir que des éléments de données avant d'être combiné
    avec le `scriptPubKey` d'une pièce pour la vérification du script. Cela a éliminé presque toute raison d'utiliser un opcode ne poussant
    pas de données dans `scriptSig` (l'exception étant qu'il pourrait être légèrement plus efficace pour placer des éléments de données
    dupliqués ou permutés sur la pile). Cependant, comme Bitcoin autorise encore techniquement des opcodes non-push dans `scriptSig`, cela
    pourrait être exploité par un attaquant pour augmenter la quantité de travail nécessaire à la vérification d'une transaction incluse
    dans un bloc. Interdire l'utilisation d'opcodes non-push dans `scriptSig` est la politique de relais et de minage par défaut depuis 2011
    et cela a été interdit par conception pour les paiements envoyés à [BIP16][] P2SH et [BIP141][] segwit.

  - **Limiter les sighash legacy et BIP143 à l'ensemble actuellement défini :** vous prouvez qu'une transaction est une dépense autorisée de
    vos bitcoins en générant une signature numérique qui s'engage sur un hachage de la transaction de dépense. Cependant, pour permettre une
    flexibilité supplémentaire, Bitcoin vous autorise à utiliser un *type de hachage de signature* d'un octet pour indiquer exactement
    quelles parties de la transaction (et des données associées) sont incluses dans le hachage. Seules 6 des 256 valeurs possibles pour cet
    octet ont une signification définie jusqu'à présent---si vous utilisez toute autre valeur, votre signature s'engage sur presque
    exactement les mêmes données que celles utilisées pour `SIGHASH_ALL`. La seule différence est que le hachage de signature doit s'engager
    sur son propre drapeau sighash, qui sera différent pour des données par ailleurs équivalentes et ce qui complique la mise en cache.
    Depuis l'adoption de [BIP141][] segwit, tous les nouveaux types de sighash devraient être introduits à l'aide de nouvelles versions de
    témoin, donc supprimer la possibilité de spécifier des types de sighash non définis permet une meilleure mise en cache pour réduire la
    charge des nœuds.

  - **Interdire les transactions de 64 octets ou moins :** les éléments dérivés (nœuds) dans les arbres de merkle de Bitcoin sont formés en
    combinant deux condensats de hachage de 32 octets en un seul blob binaire de 64 octets puis en le hachant. Cependant, l'identifiant de
    transaction (txid) d'une transaction de 64 octets est également produit en hachant un blob binaire de 64 octets exactement de la même
    manière. Cela peut permettre à une transaction de se faire passer pour une paire de hachages, ou à une paire de hachages de se faire
    passer pour une transaction, créant des vulnérabilités pour les preuves merkle de Bitcoin et les preuves SPV. Comme il n'existe aucune
    manière connue de dépenser des bitcoins en toute sécurité avec une transaction de 64 octets ou moins, le soft fork proposé interdirait
    l'inclusion de telles transactions dans les blocs.

  La proposition prévoit d'utiliser le mécanisme d'activation [BIP9][], avec un signalement commençant le 1er août 2019 et se terminant un
  an plus tard si la proposition n'est pas activée. Comme il s'agit toujours d'une proposition, elle devra être évaluée par des experts du
  protocole, implémentée dans un nœud complet (voir la [PR][Bitcoin Core #15482] de Corallo), et volontairement adoptée par les utilisateurs
  afin d'être appliquée.

## Changements notables dans le code et la documentation

*Changements notables cette semaine dans [Bitcoin Core][bitcoin core repo], [LND][lnd repo], [C-Lightning][c-lightning repo],
[Eclair][eclair repo], [libsecp256k1][libsecp256k1 repo], et [Bitcoin Improvement Proposals (BIPs)][bips repo].*

- [Bitcoin Core #15471][] supprime l'avertissement affiché dans l'interface graphique et via RPC au sujet de « versions de blocs inconnues
  en cours de minage ». Cet avertissement était destiné à informer les utilisateurs que les mineurs et les utilisateurs pouvaient coordonner
  l'activation d'un soft fork à l'aide des versionbits de [BIP9][], permettant à l'utilisateur voyant l'avertissement de mettre à niveau son
  nœud pour comprendre et appliquer les nouvelles règles de consensus lors de leur activation. Cependant, les mineurs ont de plus en plus
  utilisé overt ASICBoost qui implique l'utilisation de certains bits de version comme nonce, comme proposé dans [BIP320][], ce qui
  déclenche ce message de manière intempestive. Cette fusion supprime simplement l'avertissement qui n'aidait plus les utilisateurs. La
  question de savoir si le projet adoptera BIP320, mettra en œuvre un système d'avertissement plus sophistiqué, ou tentera d'utiliser une
  solution entièrement différente pour le signalement de futurs soft forks (comme le signalement via la transaction de génération
  (coinbase)) n'a pas été décidée.

- [C-Lightning #2382][] renomme la RPC `listpayments` en `listsendpays`. La commande liste l'état de tous les paiements que vous avez
  envoyés, mais le nom précédent prêtait à confusion chez les personnes qui s'attendaient à ce qu'elle liste aussi les paiements reçus. Une
  nouvelle RPC `listpays` est également fournie. À l'heure actuelle, elle fournit essentiellement les mêmes informations que `listsendpays`,
  mais lorsque les paiements multipath seront implémentés, elle regroupera toutes les parties du paiement dans un seul objet JSON.

  La même PR permet également à la RPC `sendpay` de prendre un champ `bolt11` qui sera enregistré et renvoyé à l'utilisateur s'il exécute
  plus tard les RPC `listpay`, `listsendpays`, ou `waitsendpay`.

## Annexe : contexte du nettoyage du consensus

Les sous-sections suivantes tentent de fournir un certain contexte sur le fonctionnement actuel du protocole Bitcoin en lien avec le soft
fork de nettoyage.

### L'attaque time warp

{% comment %}<!--
#!/bin/bash

_median() { if [ $# -ne 11 ] then echo ERROR: wrong number of timestamps specified exit fi echo "$@" | sed 's/ /\n/g' | sort -n | numaverage
-M }
## Basic idea
_median 1 2 3 4 5 6 7 8 9 10 11

## Initial state
_median 1 1 1 1 1 1 2 2 2 2 2

## Immediately after a stamp of 12
_median 1 1 1 1 1 2 2 2 2 2 12

## Point before next num needs to be 4
_median 1 2 2 2 2 2 12 3 3 3 3

## Point before the next num needs to 5
_median 2 12 3 3 3 3 3 4 4 4 4

## End of this 11-block set beginning with "12"
_median 12 3 3 3 3 3 4 4 4 4 5

-->{% endcomment %}

Les règles de consensus implémentées dans Bitcoin 0.1 et toutes les versions ultérieures exigent qu'un bloc ait un horodatage supérieur à la
médiane des 11 blocs précédents. Ainsi, si les blocs précédents avaient des horodatages de {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11}, le bloc
suivant doit contenir un horodatage de 7 ou plus (mais 12 serait un choix naturel).

Cependant, que se passerait-il si les mineurs créaient des horodatages de {1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2} ? Alors le bloc suivant pourrait
contenir un horodatage de 2 ou plus. Mais que se passerait-il si vous mettiez malgré tout un horodatage de 12 ? Alors la séquence suivante
de blocs avec des horodatages augmentant au minimum ressemblerait à : {12, 3, 3, 3, 3, 3, 4, 4, 4, 4, 5}. Du point de vue de quelqu'un qui
regarde cette séquence, on aurait l'impression que vous avez effectué un saut temporel vers le passé. Vous pourriez répéter cette astuce
aussi longtemps que vous le souhaiteriez pour insérer occasionnellement un bloc avec un horodatage élevé dans une séquence de blocs qui
minimise par ailleurs les augmentations d'horodatage.

Cela est notable parce que les règles de consensus de Bitcoin 0.1 que nous continuons à utiliser ajustent également la difficulté en ne
regardant que les horodatages du premier et du dernier blocs d'une période de réajustement de 2 016 blocs---pas ceux des blocs
intermédiaires. Ainsi, si des mineurs utilisent la technique ci-dessus pour préparer une séquence de blocs à faible horodatage, ils peuvent
donner au premier bloc de la période un horodatage faible (disons il y a 8 semaines) et au dernier bloc de la période un horodatage actuel
afin que l'algorithme de consensus pense que ces deux blocs ont été minés à 8 semaines d'intervalle---ce qui amène l'algorithme à réduire la
difficulté à 1/4 de sa valeur actuelle (la réduction maximale autorisée lors d'un seul ajustement de difficulté).

En répétant cette astuce encore et encore, les mineurs pourraient finalement réduire la difficulté à sa valeur minimale absolue---bien qu'il
soit facile de croire que Bitcoin deviendrait inutile avant qu'ils ne terminent, car des milliers de blocs seraient produits par seconde et
le reste de sa subvention de 21 millions de BTC serait épuisé. Une partie de ce qui empêche actuellement cette attaque est que les mineurs
devraient publier des blocs avec des horodatages augmentant au minimum pendant une grande partie d'une période normale de réajustement de
deux semaines avant de pouvoir commencer à créer des périodes de réajustement plus courtes. Cela donnerait, espérons-le, aux développeurs
Bitcoin le temps de créer un correctif simple (comme celui proposé) et aux utilisateurs le temps de l'implémenter au moyen de mises à niveau
d'urgence de leurs nœuds.

Le soft fork proposé fonctionne en exigeant que le premier bloc d'une nouvelle période de réajustement ait un horodatage qui ne soit pas
antérieur de plus de 600 secondes à celui de son bloc précédent (le dernier bloc de la période précédente). Cela signifie que les mineurs ne
peuvent définir un horodatage artificiellement bas pour le premier bloc d'une période de réajustement que s'ils définissent également un
horodatage artificiellement bas pour le dernier bloc de la période précédente---mais mettre un horodatage bas dans la période précédente
aurait alors *augmenté* la difficulté d'autant qu'ils pourront la réduire à la fin de la période actuelle, rendant une telle tentative pire
qu'inutile.

Cependant, s'il fallait effectivement beaucoup de temps pour miner tous les blocs d'une période de réajustement en raison d'une perte
naturelle de hashrate, la formule de réajustement fonctionnerait toujours comme prévu pour abaisser la difficulté.

La plupart des mineurs utilisant des logiciels actuels suivront probablement cette règle automatiquement, mais une mise à niveau sera
recommandée pour s'assurer qu'ils le fassent. Les clients légers pourraient également souhaiter appliquer cette règle au cas où les mineurs
ne l'appliqueraient pas eux-mêmes (comme cela [s'est produit en 2015][4 july fork], provoquant un fork temporaire de 6 blocs suivi de
plusieurs forks plus courts).

Plus d'informations :

- [Article sur la fiabilité des horodatages Bitcoin][lopp timestamp] par Jameson Lopp

- [Proposition d'utiliser timewarp pour éliminer le besoin de hard forks][Friedenbach proposal] par Mark Friedenbach ; voir aussi notre
  résumé dans le [Bulletin #16][le bulletin #16] - le soft fork de nettoyage proposé élimine la possibilité d'utiliser cette idée
  controversée

### Attaques sur l'arbre de merkle

Bitcoin utilise un *arbre de merkle* pour relier toutes les transactions d'un bloc à un hachage de 32 octets, appelé la *racine de merkle*,
qui est inclus dans l'en-tête du bloc. L'arbre de merkle permet à quelqu'un disposant d'un bloc complet de prouver à quelqu'un qui ne
dispose que d'une transaction que celle-ci a été incluse dans un bloc en produisant une série de hachages de 32 octets reliant la
transaction à la racine de merkle.

Cependant, les hachages de 32 octets sont utilisés par paires (64 octets de données), et une transaction Bitcoin soigneusement construite
peut également faire 64 octets, ce qui permet de convaincre l'utilisateur qu'une paire particulière de hachages est une transaction ou
inversement. Dans les deux cas, l'utilisateur peut être amené à accepter ce qui ressemble à une transaction faisant partie de la chaîne
ayant le plus de preuve de travail (PoW) mais qui ne fait en réalité pas partie de la chaîne et qui n'a jamais été vérifiée par un nœud
complet.

{% comment %}<!--
A minimal transaction:

4 version 1 number of inputs 36 outpoint 1 size of scriptSig _ scriptSig 4 sequence 1 number of outputs 8 amount 1 size of scriptPubKey _
scriptPubKey 4 nLockTime ==== 60 bytes

-->{% endcomment %}

Le soft fork proposé résout le problème en invalidant simplement toute transaction de 64 octets ou moins. Cela est raisonnable parce que les
champs requis pour une transaction consomment un minimum de 60 octets. Dans une transaction de 64 octets, cela ne laisse que 4 octets libres
dans le champ `scriptPubKey` pour sécuriser les fonds du destinataire. Il n'existe aucune manière connue de le faire en toute sécurité avec
si peu d'octets, donc les transactions de 64 octets ou moins ne peuvent avoir aucune sécurité et il n'y a aucune raison de les utiliser
autrement que pour une attaque. De telles transactions n'ont pas été relayées ou minées par les valeurs par défaut de Bitcoin Core depuis
2010, donc les mineurs n'ont pas besoin de modifier leur logiciel de sélection des transactions tant qu'ils n'ont pas changé les valeurs par
défaut codées en dur.

La règle ne s'applique qu'à la *taille dépouillée* de la transaction, c'est-à-dire la transaction sans aucune des parties segwit. Comme la
taille dépouillée minimale d'une transaction segwit est la même que celle des transactions legacy, et parce que `scriptPubKey` n'est pas un
champ bénéficiant de la remise segwit, la logique ci-dessus montre également qu'il n'existe pas de moyen sûr d'utiliser des transactions
segwit de moins de 64 octets. Les RPC de Bitcoin Core qui renvoient des données décodées sur une transaction, telles que
`getrawtransaction`, affichent la taille dépouillée dans le champ `strippedsize`.

Les transactions de génération (coinbase) des mineurs doivent inclure des données supplémentaires au-delà de ce qui est requis pour les
transactions normales, si bien que leur taille minimale est de 64 octets depuis l'activation de [BIP34][] en 2012. Le soft fork de nettoyage
proposé exige qu'elles ne soient qu'un octet plus grandes que cette taille minimale. Toute transaction de génération pour des blocs
contenant des entrées segwit---ce qui a été le cas pour presque tous les blocs depuis plus d'un an maintenant--- a une taille minimale
supérieure à 100 octets, donc tout mineur créant des blocs segwit est garanti de respecter cette règle.

Plus d'informations :

- [Description de CVE-2017-12842][cve-2017-12842 description] par Sergio Demian Lerner

- [Discussion sur la liste de diffusion][bitcoin-dev merkle tree] par divers auteurs

### Vérification des transactions legacy

En 2015, un bloc a été miné contenant une transaction de près de 1 Mo, dont la vérification a pris environ 25 secondes sur un ordinateur de
bureau contemporain. Outre sa grande taille, la transaction était ordinaire à tous points de vue, mais elle a quand même pris environ 10
fois plus de temps à vérifier qu'un bloc de taille équivalente rempli de transactions plus petites. La raison est que la vérification de
chaque entrée contenant une signature dans une transaction legacy exige la génération d'un hachage sur une partie des données de la
transaction. La transaction de près de 1 Mo contenait 5 570 entrées, nécessitant le hachage de légères variations des mêmes données 5 570
fois.

Malheureusement, le protocole Bitcoin fournit également des fonctionnalités rarement utilisées qui peuvent être exploitées pour exiger les
mêmes ajustements et re-hachages pour chaque opération différente de vérification de signature (sigop) exécutée dans chaque entrée. Comme
chaque entrée pourrait exiger des dizaines voire des centaines de sigops, cela amplifie considérablement l'effet de cette attaque.

Plus précisément, l'opcode `OP_CODESEPARATOR` exige des modifications à la manière dont une signature s'engage sur son script exécuté, mais
le fait de manière inefficace en s'engageant sur une copie séparée de grandes parties de la transaction entière (par ex. presque 1,00 Mo
dans le pire des cas chaque fois qu'une sigop est exécutée). La réimplémentation segwit de cette fonctionnalité par [BIP143][] corrige le
problème pour les utilisateurs de segwit en s'engageant directement sur le script exécuté, qui ne peut pas dépasser 10 000 octets (0,01 Mo).

Encore plus de travail peut être nécessaire si des signatures (ou des éléments qui prétendent être des signatures) sont incluses directement
dans un `scriptPubKey`, car cela amènera une opération interne `FindAndDelete()` à modifier le script exécuté et conduira à nouveau les
sigops à s'engager sur une copie séparée de presque toute la transaction. Parce qu'une signature sécurisée dans Bitcoin s'engage sur le
`scriptPubKey` qu'elle dépense, et parce qu'une signature dans un `scriptPubKey` ne peut pas s'engager sur elle-même, il n'existe aucune
raison légitime de vérifier une signature incluse dans un `scriptPubKey`. [BIP143][] segwit traite ce problème pour ses dépenses en
spécifiant simplement que `FindAndDelete()` ne doit pas être utilisé.

Enfin, le protocole Bitcoin d'origine permet également à un attaquant d'ajouter des opcodes non-push à `scriptSig` pour utiliser jusqu'à 20
000 sigops supplémentaires dans un bloc ainsi que pour effectuer d'autres opérations (comme utiliser `OP_DUP` (dupliquer)) afin d'augmenter
la quantité de travail de vérification qui doit être effectuée.

La combinaison de tous ces problèmes permet à un attaquant bien préparé de créer des blocs qui prennent longtemps à vérifier même sur un
matériel rapide. Optech ne sait pas combien de temps dure le pire cas, car les chercheurs gardent leurs scripts d'exemple privés afin
d'éviter d'armer les attaquants. Nous avons entendu de manière fiable qu'il est possible de créer des blocs qui prennent plus d'une
demi-heure à vérifier sur du matériel moderne rapide. (Avant la correction d'autres problèmes connus avec les mécanismes ci-dessus, des
tests montrent qu'il était possible de créer des blocs qui prenaient [plusieurs heures à vérifier][sdl findanddelete].) Un mineur attaquant
pourrait utiliser ces problèmes pour mener une attaque par déni de service contre les nœuds de vérification et les autres mineurs, trouvant
peut-être des moyens de tirer profit de la situation. Cependant, comme les attaques impliquent des fonctionnalités Bitcoin rarement
utilisées, toute attaque réelle serait probablement suivie d'un soft fork pour désactiver immédiatement ces fonctionnalités---garantissant
que Bitcoin reviendrait à la normale dès que le fork serait activé.

Nous n'avons aucun moyen de résoudre le problème du fait que chaque entrée legacy exige le hachage d'un ensemble légèrement différent de
données de transaction sans interdire complètement l'utilisation des signatures de transaction legacy, mais le soft fork de nettoyage du
consensus propose d'empêcher les amplifications du problème en interdisant l'utilisation de `OP_CODESEPARATOR` dans les entrées legacy, le
comportement qui déclenche `FindAndDelete()`, et la possibilité d'utiliser des opcodes ne poussant pas de données dans `scriptSig`. Beaucoup
de développeurs pensent que cela est acceptable parce qu'il n'existe aucune utilisation productive connue de ce comportement, qu'aucune
activité onchain visible ne montre que quelqu'un les utilise, et parce que les personnes qui veulent jouer avec `OP_CODESEPARATOR` peuvent
encore le faire en utilisant la version non problématique disponible dans segwit. Avec les améliorations de la mise en cache, cela pourrait
ramener la vérification des blocs dans le pire des cas à l'ordre de quelques secondes plutôt que de quelques minutes.

Plus d'informations :

- [The Megatransaction][megatransaction] par Rusty Russell - un bloc qui a pris 25 secondes à vérifier

- [Description de CVE-2013-2292][CVE-2013-2292 description] par Sergio Demian Lerner - un bloc théorique dont l'hypothèse était qu'il
  prendrait trois minutes à vérifier

- [Spéculations sur `OP_CODESEPARATOR`][todd codesep] par Peter Todd - informations sur la manière dont `OP_CODESEPARATOR` était utilisé
  avant le soft fork corrigeant le bug `1 OP_RETURN` et sur la question de savoir si Nakamoto avait envisagé de l'utiliser pour permettre la
  délégation de signature (la capacité des signataires autorisés d'une sortie à donner à quelqu'un d'autre la permission de la dépenser sans
  créer de transaction onchain)

- [<!--op-->Description du bug `1 OP_RETURN`][1return] - un bug corrigé qui permettait à n'importe qui de dépenser les bitcoins de n'importe
  qui d'autre. Qualifié de « de loin le pire problème de sécurité que Bitcoin ait jamais eu ». Le [correctif][1opreturn fix] de Satoshi
  Nakamoto pour ce bug impliquait de séparer l'évaluation de `scriptSig` du `scriptPubKey` correspondant à chaque dépense, éliminant
  pratiquement toute utilité à `OP_CODESEPARATOR` et `FindAndDelete()`

## Corrections

Une version antérieure de ce bulletin rapportait à tort qu'un drapeau sighash non défini permettait à une signature de s'engager sur
n'importe quel hachage. À la place, elle doit s'engager sur les mêmes données que l'algorithme du drapeau `SIGHASH_ALL` par défaut. Nous
remercions Russell O'Connor et Pieter Wuille d'avoir indépendamment signalé cette erreur.

{% include references.md %}
{% include linkers/issues.md issues="15482,2382,15471" %}
[bip-cleanup]: https://github.com/TheBlueMatt/bips/blob/cleanup-softfork/bip-XXXX.mediawiki
[1return]: https://bitcoin.stackexchange.com/questions/38037/what-is-the-1-return-bug
[todd codesep]: https://bitcointalk.org/index.php?topic=255145.msg2773654#msg2773654
[megatransaction]: https://rusty.ozlabs.org/?p=522
[sdl findanddelete]: https://bitslog.wordpress.com/2017/01/08/a-bitcoin-transaction-that-takes-5-hours-to-verify/
[cl 0.7]: https://blockstream.com/2019/03/01/clightning-07-now-with-more-plugins/
[cl upgrade]: https://github.com/ElementsProject/lightning/releases/tag/v0.7.0
[lopp timestamp]: https://medium.com/@lopp/bitcoin-timestamp-security-8dcfc3914da6
[friedenbach proposal]: http://freico.in/forward-blocks-scalingbitcoin-paper.pdf
[bitcoin-dev merkle tree]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-June/016091.html
[CVE-2013-2292 description]: https://bitcointalk.org/?topic=140078
[4 july fork]: https://en.bitcoin.it/wiki/July_2015_chain_forks
[CVE-2017-12842 description]: https://bitslog.wordpress.com/2018/06/09/leaf-node-weakness-in-bitcoin-merkle-tree-design/
[1opreturn fix]: https://github.com/bitcoin/bitcoin/commit/73aa262647ff9948eaf95e83236ec323347e95d0#diff-8458adcedc17d046942185cb709ff5c3R1114
[le bulletin #10]: /fr/newsletters/2018/08/28/#demandes-de-solutions-par-soft-fork-a-l-attaque-time-warp
[le bulletin #16]: /fr/newsletters/2018/10/09/#forward-blocks--augmentations-de-capacité-on-chain-sans-hard-fork
