---
title: 'Bulletin hebdomadaire Bitcoin Optech #239'
permalink: /fr/newsletters/2023/02/22/
name: 2023-02-22-newsletter-fr
slug: 2023-02-22-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine contient des liens vers une ébauche de BIP
pour une proposition d'opcode `OP_VAULT`, résume une discussion sur la
possibilité d'autoriser les nœuds LN à définir un drapeau de qualité de
service sur leurs canaux, relaie une demande de commentaires sur les
critères d'évaluation des nœuds voisins LN, et décrit une ébauche de BIP
pour un schéma de sauvegarde et de récupération des graines qui peut être
exécuté de manière fiable sans électronique.  Vous trouverez également
nos sections habituelles avec des résumés des questions et réponses les
plus importantes du Bitcoin StackExchange, des annonces de nouvelles
versions et de versions candidates, et descriptions de principaux
changements apportés aux logiciels d'infrastructure Bitcoin les plus répandus.

## Nouvelles

- **Projet de BIP pour OP_VAULT :** James O'Beirne a [posté][obeirne op_vault]
  sur la liste de diffusion Bitcoin-Dev un lien vers un [projet de BIP][bip op_vault]
  pour l'opcode `OP_VAULT` qu'il a précédemment proposé (voir [Bulletin
  #234][news234 vault]). Il a également annoncé qu'il allait tenter de
  faire fusionner le code avec Bitcoin Inquisition, un projet visant à
  tester les changements majeurs proposés aux règles du consensus et du
  protocole réseau de Bitcoin.

- **Indicateur de qualité de service LN :** Joost Jager [a posté][jager qos]
  sur la liste de diffusion Lightning-Dev une proposition visant à permettre
  aux noeuds de signaler qu'un canal est "hautement disponible", indiquant
  que son opérateur pense qu'il sera en mesure de transmettre les paiements
  sans échec. S'il ne parvient pas à transmettre un paiement, l'expéditeur
  peut choisir de ne pas utiliser ce nœud pour les paiements futurs pendant
  une très longue période---une durée beaucoup plus longue que celle que
  l'expéditeur peut utiliser pour les nœuds qui n'ont pas annoncé une haute
  disponibilité. Les expéditeurs qui maximisent la vitesse de paiement (plutôt
  que des frais peu élevés) choisiraient de préférence des chemins de paiement
  constitués de nœuds auto-identifiés comme hautement disponibles.

    Christian Decker [a répondu][decker qos] avec un excellent résumé des
    problèmes des systèmes de réputation, y compris les cas de réputation
    autoproclamée. L'une de ses préoccupations était que les clients typiques
    n'enverront pas assez de paiements pour rencontrer fréquemment les
    mêmes nœuds dans un grand réseau de canaux de paiement. Si les affaires
    récurrentes sont rares de toute façon, alors la menace de ne pas fournir
    temporairement des affaires récurrentes peut ne pas être efficace.

    Antoine Riard [a rappelé][riard boomerang] aux participants une approche
    alternative pour accélérer les paiements : le surpaiement avec récupération.
    Précédemment décrits comme des paiements boomerang (voir le [bulletin
    n°86][news86 boomerang]) et des trop-perçus remboursables (voir le [bulletin
    n°192][news192 pp]), un utilisateur prendrait le montant de son paiement
    plus un peu d'argent supplémentaire, le diviserait en plusieurs [parties][topic
    multipath payments], et enverrait les parties par différentes voies. Lorsqu'un
    nombre suffisant de pièces est arrivé pour payer la facture, le destinataire
    ne réclame que ces pièces et rejette toutes les pièces supplémentaires (avec
    des fonds supplémentaires) qui arrivent plus tard. Cela exige que les
    expéditeurs qui veulent des paiements rapides aient des fonds supplémentaires
    dans leur canal, mais cela fonctionne même si certains des chemins choisis
    par l'expéditeur échouent. Cela réduit la nécessité pour les utilisateurs
    d'être en mesure de trouver facilement des canaux hautement disponibles.
    Le défi de cette approche est de construire un mécanisme qui empêche les
    récepteurs de garder tout paiement excédentaire qui arrive.

- **Feedback demandé sur la notation de bon voisinage des LN :** Carla Kirk-Cohen
  et Clara Shikhelman ont [posté][ckc-cs reputation] sur la liste de diffusion
  Lightning-Dev pour demander des commentaires sur les paramètres recommandés
  pour déterminer comment un nœud devrait juger si ses contreparties de canal
  sont une bonne source de paiements transférés. Elles suggèrent plusieurs
  critères pour juger et recommandent des paramètres par défaut pour chaque
  critère, mais cherchent à obtenir des commentaires sur les choix effectués.

    Si un nœud détermine que l'un de ses pairs est un bon voisin et que
    ce voisin marque un paiement transmis comme étant approuvé par lui,
    le nœud peut donner à ce paiement l'accès à davantage de ses ressources
    qu'il ne le fait pour les paiements non qualifiés. Le nœud peut également
    approuver le paiement lorsqu'il le transmet au canal suivant. Comme
    décrit dans un article antérieur co-écrit par Shikhelman (voir [bulletin
    #226][news226 jam]), ceci fait partie d'une proposition visant à atténuer
    les [attaques par brouillage de canal][topic channel jamming attacks].

- **Proposition de BIP pour le système d'encodage des semences Codex32 :** Russell
O'Connor et Andrew Poelstra (utilisant des anagrammes de leurs noms) ont
[proposé][op codex32] un BIP pour un nouveau schéma de sauvegarde et de
restauration de graines [BIP32][]. Similaire à [SLIP39][], il permet
optionnellement de créer plusieurs parts en utilisant le [Shamir's Secret
Sharing Scheme][] (SSSS), nécessitant qu'un nombre configurable de parts
soient utilisées ensemble pour récupérer la graine. Un attaquant qui obtient
moins que le nombre seuil de parts n'apprendra rien sur la graine.
Contrairement aux codes de récupération BIP39, Electrum, Aezeed et SLIP39
qui utilisent une liste de mots, Codex32 utilise le même alphabet que les
adresses [bech32][topic bech32]. Un exemple de part de l'ébauche du BIP :

    ```text
    ms12namea320zyxwvutsrqpnmlkjhgfedcaxrpp870hkkqrm
    ```

    Le principal avantage de Codex32 par rapport à tous les systèmes
    existants est que toutes les opérations peuvent être effectuées en
    utilisant uniquement un stylo, du papier, des instructions et des
    découpes de papier. Cela inclut la génération d'une graine codée
    (le dé peut être utilisé ici), la protection de la graine avec une
    somme de contrôle, la génération de parts avec somme de contrôle,
    la vérification des sommes de contrôle et la récupération de la graine.
    Nous avons trouvé que l'idée de pouvoir vérifier manuellement les
    sommes de contrôle sur les sauvegardes de graines ou de parts était
    un concept particulièrement puissant. La seule méthode dont disposent
    actuellement les utilisateurs pour vérifier la sauvegarde d'une graine
    individuelle est de l'entrer dans un dispositif informatique de
    confiance et de voir s'il obtient les clés publiques attendues---mais
    déterminer si un dispositif est de confiance n'est souvent pas une
    procédure triviale. Pire encore, pour vérifier l'intégrité des partages
    SSSS existants (par exemple, dans SLIP39), l'utilisateur doit réunir
    chaque partage qu'il souhaite vérifier avec suffisamment d'autres
    partages pour atteindre le seuil, puis les entrer dans un dispositif
    informatique de confiance. Cela signifie que la vérification de
    l'intégrité des partages annule l'un des principaux avantages des
    partages, à savoir la possibilité de préserver la sécurité des
    informations en les répartissant entre plusieurs endroits ou personnes.
    Avec Codex32, les utilisateurs peuvent vérifier régulièrement
    l'intégrité de chaque partage individuellement en utilisant
    simplement du papier, un stylo, quelques documents imprimés
    et quelques minutes de temps.

    La discussion sur la liste de diffusion a principalement porté
    sur les différences entre Codex32 et SLIP39, qui est utilisé en
    production depuis quelques années maintenant. Nous recommandons
    à toute personne intéressée par Codex32 de consulter son [site
    Web][codex32 website] ou de regarder la [vidéo][codex32 video]
    de l'un de ses auteurs. Avec le projet de BIP, les auteurs espèrent
    que les portefeuilles commenceront à prendre en charge l'utilisation
    de graines codées en Codex32.

## Questions et réponses sélectionnées dans Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] iC'est l'un des premiers endroits où
 les collaborateurs d'Optech cherchent des réponses à leurs questions---ou
 lorsque nous avons quelques moments libres pour aider les utilisateurs curieux
 ou confus. Dans cette rubrique mensuelle, nous mettons en lumière certaines
 des questions et réponses les plus votées depuis notre dernière mise à jour.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Pourquoi les données de contrôle téléchargées pendant l'IBD sont-elles en mode prune ?]({{bse}}117057)
  Pieter Wuille note que pour les nœuds fonctionnant en [mode pruné], "les données
  de témoin qui sont à la fois (a) avant le point de supposition valide et (b)
  suffisamment enterrées pour être au-delà du point pruné, il y a en effet peu à
  gagner à les avoir". Un [projet de PR][Bitcoin Core #27050] est actuellement
  ouvert pour traiter ce problème et [un club de révision de PR][pr review 27050]
  couvrant le changement proposé.

- [Le réseau P2P de Bitcoin peut-il relayer des données compressées ?]({{bse}}116999)
  Pieter Wuille renvoie à deux discussions de listes de diffusion sur la compression
  (l'une sur la [compression spécialisée pour la synchronisation des en-têtes][] et
  l'autre sur la [compression générale basée sur LZO][]) et signale que Blockstream
  Satellite utilise un schéma de compression des transactions personnalisé.

- [Comment devient-on une graine DNS pour Bitcoin Core ?]({{bse}}116931)
  L'utilisateur Paro explique les exigences pour quelqu'un qui souhaite
  devenir une [semence DNS][news66 dns seed] pour fournir aux nouveaux
  nœuds des pairs initiaux.

- [Où puis-je me renseigner sur les sujets de recherche ouverts dans le domaine du bitcoin ?]({{bse}}116898)
  Michael Folkson fournit une variété de ressources, notamment
  [Chaincode Labs Research][] et [Bitcoin Problems][], entre autres.

- [Quelle est la taille maximale d'une transaction qui sera relayée par les nœuds bitcoin en utilisant la configuration par défaut ?]({{bse}}117277)
  Pieter Wuille souligne la règle de la politique de normalisation de 400 000
  [unités de poids][] de Bitcoin Core, note qu'elle n'est pas actuellement
  configurable et explique les avantages prévus de cette limite, notamment
  les protections contre les attaques de type DoS.

- [Comprendre comment les ordinaux fonctionnent dans Bitcoin. Qu'est-ce qui est exactement stocké sur la blockchain ?]({{bse}}117018)
  Vojtěch Strnad clarifie que les Inscriptions d'Ordinals n'utilisent pas `OP_RETURN`,
  mais incorporent des données dans une branche de script non exécutée en utilisant
  les opcodes `OP_PUSHDATAx` similaires à :

    ```
    OP_0
    OP_IF
    <data pushes>
    OP_ENDIF
    ```

- [Pourquoi le protocole ne permet-il pas aux transactions non confirmées d'expirer à une hauteur donnée ?]({{bse}}116926)
  Larry Ruane fait référence à Satoshi pour expliquer pourquoi il ne
  serait pas prudent que les transactions aient la capacité apparemment
  utile de spécifier une hauteur d'expiration, c'est-à-dire une hauteur
  après laquelle la transaction, si elle n'est pas encore minée, n'est
  plus valide (et ne peut donc pas être minée).

## Mises à jour et versions candidates

*Nouvelles versions et versions candidates pour les principaux projets
d'infrastructure Bitcoin. Veuillez envisager de passer aux nouvelles
versions ou d'aider à tester les versions candidates.*

- [BDK 0.27.1][] est une mise à jour de sécurité visant à corriger
  une vulnérabilité qui "permet parfois [...] un débordement des
  limites d'un tableau lors de la saisie de grandes chaînes dans
  la fonction printf de SQLite".  Seuls les logiciels utilisant
  la fonction optionnelle de base de données SQLite de BDK doivent
  être mis à jour. Voir le [rapport de vulnérabilité][RUSTSEC-2022-0090]
  pour plus de détails.

- [Core Lightning 23.02rc3][] est une version candidate pour une nouvelle
  version de maintenance de cette implémentation populaire de LN.

## Changements principaux dans le code et la documentation

*Changements notables cette semaine dans [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], et [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #24149][] ajoute la prise en charge de la signature
  pour les [miniscript][topic miniscript] basés sur les [sorties de
  descripteurs][topic descriptors] de P2WSH. Bitcoin Core sera en
  mesure de signer tout descripteur miniscript en entrée si toutes
  les images préalables et les clés nécessaires sont disponibles et
  si les délais sont respectés. Certaines fonctionnalités manquent
  encore pour une prise en charge complète des miniscripts dans le
  portefeuille Bitcoin Core : le portefeuille ne peut pas encore
  estimer le poids de l'entrée pour certains descripteurs avant la
  signature et ne peut pas encore signer les [PSBT][topic PSBT] dans
  certains cas marginaux. La prise en charge de Miniscript pour les
  sorties P2TR est également toujours en attente.

- [Bitcoin Core #25344][] met à jour les RPC `bumpfee` et `psbtbumpfee`
  pour créer des hausses de frais [Replace By Fee][topic rbf] (RBF).
  La mise à jour permet de spécifier des sorties pour la transaction
  de remplacement. Le remplacement peut contenir un ensemble de sorties
  différent de celui de la transaction remplacée. Ceci peut être utilisé
  pour ajouter de nouvelles sorties (par exemple, pour le [traitement
  par lots des paiements][topic payment batching] itératif) ou pour
  supprimer des sorties (par exemple, pour tenter d'annuler un paiement
  non confirmé).

- [Eclair #2596][] limite le nombre de fois qu'un pair tentant d'ouvrir
  un canal [doublement financé][topic dual funding]le canal peut faire
  sauter la transaction d'ouverture du canal par [RBF][topic rbf] avant
  que le noeud n'accepte plus aucune tentative de mise à jour. Ceci est
  motivé par le fait que le nœud a besoin de stocker des données sur
  toutes les versions possibles de la transaction d'ouverture de canal,
  donc permettre des sauts de frais illimités pourrait être un problème.
  Normalement, le nombre de dépassements de frais qui peuvent être créés
  est limité en pratique par la nécessité pour chaque remplacement de
  payer des frais de transaction supplémentaires. Toutefois, le protocole
  de double financement prévoit qu'un nœud stocke même les transactions
  à frais réduits qu'il ne peut pas valider entièrement, ce qui signifie
  qu'un attaquant pourrait créer un nombre illimité de transactions à
  frais réduits invalides qui ne seront jamais confirmées et ne lui
  coûteront jamais de frais de transaction.

- [Eclair #2595][] continue le travail du projet sur l'ajout du support
  pour le [jointage][topic splicing], dans ce cas avec des mises à jour
  des fonctions utilisées pour construire les transactions.

- [Eclair #2479][] ajoute la prise en charge du paiement des [offres][topic offers]
  dans le flux suivant : un utilisateur reçoit une offre, demande à Eclair
  destinataire, vérifie que la facture contient les paramètres attendus,
  et paie la facture.

- [LND #5988][] ajoute un nouvel estimateur de probabilité optionnel pour
  trouver des chemins de paiement. Il est en partie basé sur des recherches
  antérieures sur la recherche de chemins (voir le [Bulletin #192][news192 pp])
  avec des apports supplémentaires provenant d'autres approches.

- [Rust Bitcoin #1636][] ajoute une fonction `predict_weight()`.  L'entrée
  de la fonction est un modèle pour la transaction à construire ; la sortie
  est le poids attendu de la transaction. Ceci est particulièrement utile
  pour la gestion des frais : pour déterminer quelles entrées doivent être
  ajoutées à une transaction, le montant des frais doit être connu, mais
  pour déterminer le montant des frais, la taille de la transaction doit
  être connue. La fonction peut fournir une estimation raisonnable de la
  taille sans avoir à construire une transaction candidate.

{% include references.md %}
{% include linkers/issues.md v=2 issues="24149,25344,2596,2595,2479,5988,1636,27050" %}
[core lightning 23.02rc3]: https://github.com/ElementsProject/lightning/releases/tag/v23.02rc3
[news226 jam]: /fr/newsletters/2022/11/16/#document-sur-les-attaques-par-brouillage-de-canaux
[news86 boomerang]: /en/newsletters/2020/02/26/#boomerang-redundancy-improves-latency-and-throughput-in-payment-channel-networks
[news92 overpayments]: /en/newsletters/2022/03/23/#payment-delivery-algorithm-update
[codex32 website]: https://secretcodex32.com/
[codex32 video]: https://www.youtube.com/watch?v=kf48oPoiHX0
[news192 pp]: /en/newsletters/2022/03/23/#payment-delivery-algorithm-update
[obeirne op_vault]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-February/021465.html
[bip op_vault]: https://github.com/jamesob/bips/blob/jamesob-23-02-opvault/bip-vaults.mediawiki
[news234 vault]: /fr/newsletters/2023/01/18/#proposition-de-nouveaux-opcodes-specifiques-aux-coffre-forts
[jager qos]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-February/003842.html
[decker qos]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-February/003844.html
[riard boomerang]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-February/003852.html
[ckc-cs reputation]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-February/003857.html
[slip39]: https://github.com/satoshilabs/slips/blob/master/slip-0039.md
[shamir's secret sharing scheme]: https://en.wikipedia.org/wiki/Shamir%27s_secret_sharing
[op codex32]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-February/021469.html
[RUSTSEC-2022-0090]: https://rustsec.org/advisories/RUSTSEC-2022-0090
[bdk 0.27.1]: https://github.com/bitcoindevkit/bdk/releases/tag/v0.27.1
[prune mode]: https://bitcoin.org/en/full-node#reduce-storage
[pr review 27050]: https://bitcoincore.reviews/27050
[compression spécialisée pour la synchronisation des en-têtes]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-March/015851.html
[compression générale basée sur LZO]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2015-November/011837.html
[news66 dns seed]: /en/newsletters/2019/10/02/#bitcoin-core-15558
[Chaincode Labs Research]: https://research.chaincode.com/research-intro/
[Bitcoin Problems]: https://bitcoinproblems.org/
[unités de poids]: https://en.bitcoin.it/wiki/Weight_units
