---
title: 'Bulletin Hebdomadaire Bitcoin Optech #313'
permalink: /fr/newsletters/2024/07/26/
name: 2024-07-26-newsletter-fr
slug: 2024-07-26-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine résume une vaste discussion sur le relai gratuit et les
améliorations du bumping de frais dans Bitcoin Core. Sont également incluses nos
rubriques habituelles avec des questions et réponses populaires
de la communauté Bitcoin Stack Exchange, des annonces de nouvelles versions et de
versions candidates, ainsi que les changements apportés aux principaux logiciels d'infrastructure Bitcoin.

## Nouvelles

- **Discussion variée sur le relai gratuit et les améliorations du bumping de frais :** Peter Todd
  a [posté][todd fr-rbf] sur la liste de diffusion Bitcoin-Dev un résumé d'une attaque de relai
  gratuit qu'il avait précédemment [divulguée de manière responsable][topic responsible disclosures]
  aux développeurs de Bitcoin Core. Cela a mené à une discussion complexe sur de multiples problèmes
  et améliorations proposées. Voilà quelques-uns des thèmes abordés :

  - *Attaques de relai gratuit :* le [relai gratuit][topic free relay] se produit lorsqu'un nœud
    complet relaye des transactions non confirmées sans que le montant des revenus de frais dans son
    mempool n'augmente d'au moins le taux de relai minimum (par défaut, 1 sat/vbyte). Le relai gratuit
    coûte souvent de l'argent, donc il n'est pas techniquement gratuit, mais le coût est bien inférieur
    à ce que les utilisateurs honnêtes paient pour le relai.

    Le relai gratuit permet à un attaquant d'augmenter considérablement la bande passante utilisée par
    les nœuds de relais, ce qui peut réduire le nombre de nœuds de relais. Si le nombre de nœuds de
    relais exploités indépendamment devient trop faible, ceux qui effectuent la dépense envoient essentiellement des
    transactions directement aux mineurs, ce qui présente les mêmes risques de centralisation que les
    [frais hors bande][topic out-of-band fees].

    L'attaque décrite par Todd exploite les différences de politique de mempool entre les mineurs et les
    utilisateurs. De nombreux mineurs semblent activer le [full-RBF][topic rbf] mais Bitcoin Core ne
    l'active pas par défaut (voir le [Bulletin #263][news263 full-rbf]). Cela permet à un attaquant de
    créer différentes versions d'une transaction qui seront traitées différemment par les mineurs
    full-RBF et les nœuds de relais non-full-RBF. Les nœuds de relais peuvent finir par relayer
    plusieurs versions d'une transaction qui ont peu de chances de se confirmer, gaspillant ainsi la
    bande passante des nœuds de relais.

    Les attaques de relai gratuit ne permettent pas directement aux attaquants de voler les fonds
    d'autres utilisateurs, bien qu'une attaque soudaine ou prolongée puisse être utilisée pour perturber
    le réseau et faciliter d'autres types d'attaques. À notre connaissance, aucune attaque de relai
    gratuit perturbatrice n'a jamais été réalisée.

  - *Relai gratuit et replace-by-feerate :* Peter Todd a précédemment proposé deux formes de
    replace-by-feerate (RBFR) ; voir le [Bulletin #288][news288 rbfr]. Une critique du RBFR était qu'il
    permettait le relai gratuit. Une quantité similaire de relai gratuit est déjà possible à travers
    l'attaque qu'il a décrite cette semaine et des attaques similaires, donc il a argumenté que les
    préoccupations concernant le relai gratuit ne devraient pas bloquer l'ajout d'une fonctionnalité
    utile pour atténuer les [attaques par épinglage de transaction][topic transaction pinning].

    Une [réponse][harding rbfr fundamental] a argumenté que le relai gratuit créé par le RBFR était
    fondamental à sa conception, mais d'autres problèmes de relai gratuit dans la conception de Bitcoin
    Core pourraient être solutionnables. Todd [n'était pas d'accord][todd unsolvable].

  - *Utilité de TRUC :* Peter Todd a argumenté que [TRUC][topic v3 transaction relay] était une
    "mauvaise proposition". Il avait précédemment critiqué le protocole (voir le [Bulletin #283][news283
    truc pin]) et spécifiquement critiqué la spécification de TRUC, [BIP431][], qui exploite les
    inquiétudes concernant le relai gratuit pour plaider en faveur de TRUC plutôt que sa propre
    proposition RBFR.

    Cependant, BIP431 argumente également contre des versions de RBFR, telles que le RBFR en une seule
    fois de Todd, qui dépendent du paiement d'un taux de frais suffisamment élevé pour qu'il devienne
    l'une des transactions les plus rentables à miner dans les prochains blocs, décrit comme entrant
    dans la partie supérieure du mempool. Todd et d'autres ont convenu que cela serait beaucoup plus
    facile à réaliser une fois que Bitcoin Core commencera à utiliser le [cluster de mempool][topic cluster
    mempool], bien que Todd ait également suggéré des méthodes alternatives disponibles dès maintenant.
    TRUC n'a pas besoin d'informations sur la partie supérieure du mempool, donc il ne dépend pas du
    cluster de mempool ou des alternatives.

    Une forme plus longue de cette critique a été résumée dans le [Bulletin #288][news288 rbfr], avec des
    recherches ultérieures (résumées dans le [Bulletin #290][news290 rbf]) illustrant à quel point il est
    difficile pour tout ensemble de règles de remplacement de transactions de toujours faire un choix
    qui améliorera la rentabilité des mineurs. Par rapport à RBFR, TRUC ne change pas les règles de
    remplacement de Bitcoin Core (sauf pour toujours permettre que les remplacements soient considérés
    pour les transactions TRUC), donc cela ne devrait pas aggraver les problèmes existants avec la
    compatibilité des incitations au remplacement.

  - *Chemin vers un cluster de mempool :* comme décrit dans le [Bulletin #285][news285 cluster cpfp-co], la
    proposition de [cluster de mempool][topic cluster mempool] nécessite de désactiver [CPFP
    carve-out][topic cpfp carve out] (CPFP-CO), qui est actuellement utilisé par les [soreties
    d'ancrage][topic anchor outputs] de LN pour protéger une grande quantité d'argent dans les canaux de
    paiement. En combinaison avec [le relai par paquet][topic package relay] (spécifiquement le paquet
    Replace By Fee), le RBFR en une seule fois pourrait être capable de remplacer CPFP-CO sans
    nécessiter de changements dans aucun logiciel LN qui augmente déjà à plusieurs reprises les frais de
    ses dépenses de sortie d'ancrage par RBF. Cependant, le RBFR en une seule fois dépend de l'apprentissage
    des taux de frais du haut-mempool de quelque chose comme le cluster de mempool, donc à la fois RBFR et
    le cluster de mempool devraient être déployés simultanément ou une méthode alternative pour déterminer les
    taux de frais du haut-mempool devrait être utilisée.

    En comparaison, TRUC fournit également une alternative à CPFP-CO, mais c'est une fonctionnalité
    facultative. Tout le logiciel LN devrait être mis à niveau pour supporter TRUC et tous les canaux
    existants devraient subir une [mise à niveau de l'engagement du canal][topic channel commitment
    upgrades]. Cela pourrait prendre un temps significatif et CPFP-CO ne pourrait pas être désactivé
    tant qu'il n'y aurait pas de preuves solides que tous les utilisateurs de LN ont été mis à niveau.
    Jusqu'à ce que CPFP-CO soit désactivé, le cluster de mempool ne pourrait pas être déployé en toute
    sécurité à grande échelle.

    Comme mentionné dans les précédents bulletins Optech [#286][news286 imbued], [#287][news287
    sibling], et [#289][news289 imbued], une adoption lente de TRUC et une disponibilité rapide de
    cluster de mempool pourraient être abordées à travers _TRUC imbued_, qui appliquerait automatiquement
    TRUC et l'[éviction de frères et sœurs][topic kindred rbf] vers des transactions d'engagement de style ancrage LN.
    Plusieurs développeurs LN et contributeurs à la proposition TRUC imbued [ont dit][teinurier
    hacky] qu'ils préféreraient éviter ce résultat---mettre à jour explicitement vers TRUC est meilleur
    à bien des égards, et il y a plusieurs autres raisons pour les développeurs LN de travailler sur des
    mécanismes de mise à niveau de canal---mais il semble plausible que TRUC imbued puisse être
    considéré à nouveau si le développement du cluster de mempool devance celui des mises à niveau
    d'engagement LN.

    Bien que TRUC imbued et l'adoption généralisée de TRUC opt-in permettent de désactiver CPFP-CO et
    rendent ainsi possible le déploiement de cluster de mempool, aucun système TRUC ne dépend de cluster
    de mempool ou d'autres nouvelles méthodes de calcul de la compatibilité des incitations
    transactionnelles. Cela facilite l'analyse de TRUC indépendamment de cluster de mempool que celle de
    RBFR.

  À la date de rédaction de ce texte, la discussion sur la liste de diffusion est en cours.

## Questions et réponses sélectionnées de Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] est l'un des premiers endroits où les contributeurs Optech
cherchent des réponses à leurs questions---ou quand nous avons quelques moments libres pour aider
les utilisateurs curieux ou confus. Dans cette rubrique mensuelle, nous mettons en lumière certaines
des questions et réponses les plus votées publiées depuis notre dernière mise à jour.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Pourquoi est-il nécessaire de restructurer le mempool avec le cluster de mempool ?]({{bse}}123682)
  Murch explique les problèmes avec la structure actuelle du mempool de Bitcoin Core, comment le cluster
  de mempool aborde ces problèmes, et comment le [cluster de mempool][topic cluster mempool] peut être déployé
  dans Bitcoin Core.

- [Le DEFAULT_MAX_PEER_CONNECTIONS pour Bitcoin Core est de 125 ou 130 ?]({{bse}}123645)
  Lightlike clarifie que bien que le nombre maximum de connexions de pairs automatiques soit de 125
  dans Bitcoin Core, un opérateur de nœud peut ajouter jusqu'à 8 connexions supplémentaires
  manuellement.

- [Pourquoi les développeurs de protocole travaillent-ils à maximiser les revenus des mineurs ?]({{bse}}123679)
  David A. Harding liste plusieurs avantages à pouvoir prédire quelles transactions entrent dans un
  bloc en supposant que les mineurs maximiseront les revenus des frais, notant "Cela permet à ceux
  qui effectuent une dépense de faire des estimations de taux de frais raisonnables, aux nœuds de relais bénévoles de
  fonctionner avec une quantité modeste de bande passante et de mémoire, et aux petits mineurs
  décentralisés de gagner autant de revenus de frais que les grands mineurs".

- [Y a-t-il un incitatif économique à utiliser P2WSH plutôt que P2TR ?]({{bse}}123500)
  Vojtěch Strnad souligne que bien que certaines utilisations de P2WSH puissent être moins chères que
  les sorties P2TR, la plupart des cas d'utilisation de P2WSH, comme le multisig et LN,
  bénéficieraient des frais réduits permis par la dissimulation des chemins de script inutilisés dans
  [taproot][topic taproot] et l'utilisation de [signatures schnorr][topic schnorr signatures] pour
  systèmes de regroupement de clés comme [MuSig2][topic musig] et FROST.

- [Combien de blocs par seconde peuvent être créés de manière durable en utilisant une attaque par distorsion temporelle ?]({{bse}}123698)
  Murch calcule que dans le contexte d'une [attaque par distorsion temporelle][topic time warp],
  "Un attaquant serait capable de maintenir une cadence de 6 blocs par seconde sans
  augmenter la difficulté."

- [pkh() imbriqué dans tr() est-il autorisé ?]({{bse}}123568)
  Pieter Wuille souligne que, selon [BIP386][], "Descripteurs de Script de Sortie tr()",
  `pkh()` imbriqué dans `tr()` n'est pas un descripteur valide, mais que
  sous [BIP379][] "Miniscript" une telle construction est autorisée et qu'il appartient
  au développeur d'application de décider quels BIP spécifiques ils suivent.

- [Un bloc de plus d'une semaine peut-il être considéré comme une extrémité de chaîne valide ?]({{bse}}123671)
  Murch conclut qu'une telle extrémité de chaîne pourrait être considérée comme valide, mais que le
  nœud resterait dans l'état "initialblockdownload" tant que l"extrémité de chaîne est à plus de 24 heures
  dans le passé selon l'heure locale du nœud.

- [Modification de tx médiée par SIGHASH_ANYONECANPAY]({{bse}}123429)
  Murch explique les défis de l'utilisation de `SIGHASH_ALL | SIGHASH_ANYONECANPAY` dans
  un schéma de financement participatif on chain et comment [SIGHASH_ANYPREVOUT][topic
  sighash_anyprevout] pourrait aider.

- [Pourquoi la règle RBF n°3 existe-t-elle ?]({{bse}}123595)
  Antoine Poinsot confirme que la règle [RBF][topic rbf] n°4 (la transaction de remplacement paie des
  frais supplémentaires par rapport aux frais absolus de la transaction originale)
  est plus stricte que la règle n°3 (le remplacement paie des frais absolus d'au moins la somme
  payée par la transaction originale) et note que la raison de ces deux règles similaires dans la
  documentation vient des deux vérifications séparées dans le code.

## Mises à jour et versions candidates

*Nouvelles sorties et candidats à la sortie pour les projets d'infrastructure Bitcoin populaires.
Veuillez envisager de passer aux nouvelles sorties ou d'aider à tester
les candidats à la sortie.*

- [BDK 1.0.0-beta.1][] est un candidat à la sortie pour "la première version bêta de
  `bdk_wallet` avec une API stable 1.0.0".

## Changements notables de code et de documentation

_Changements récents notables dans [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Interface de Portefeuille Matériel (HWI)][hwi
repo], [Rust Bitcoin][rust bitcoin repo], [Serveur BTCPay][btcpay server repo], [BDK][bdk repo],
[Propositions d'Amélioration de Bitcoin (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition repo] et [BINANAs][binana
repo]._

- [Bitcoin Core #30320][] met à jour le comportement [assumeUTXO][topic assumeutxo] pour éviter de
  charger un instantané s'il n'est pas un ascendant de l'en-tête actuel le plus à jour `m_best_header`
  et synchronise à la place comme un nœud régulier. Si l'instantané devient plus tard un ascendant de
  l'en-tête le plus à jour en raison d'une réorganisation de la chaîne, le chargement de l'instantané
  assumeUTXO reprend.

- [Bitcoin Core #29523][] ajoute une option `max_tx_weight` aux commandes RPC de financement de
  transaction `fundrawtransaction`, `walletcreatefundedpsbt` et `send`. Cela garantit que le poids de
  la transaction résultante ne dépasse pas la limite spécifiée, ce qui peut être bénéfique pour les
  tentatives futures de [RBF][topic rbf] ou pour des protocoles de transaction spécifiques. Si non
  défini, le `MAX_STANDARD_TX_WEIGHT` de 400 000 unités de poids (100 000 vbytes) est utilisé comme
  valeur par défaut.

- [Core Lightning #7461][] ajoute le support pour que les nœuds auto-récupèrent et auto-payent les
  [offres BOLT12][topic offers] et les factures, ce qui peut simplifier le code de gestion de compte
  qui appelle CLN en arrière-plan comme décrit dans le [Bulletin #262][cln self-pay]. Le PR permet
  également aux nœuds de payer une facture même si le nœud lui-même est la tête du [chemin
  aveuglé][topic rv routing]. De plus, les nœuds non annoncés (ceux sans [canaux non annoncés][topic
  unannounced channels]) peuvent maintenant créer des offres en ajoutant automatiquement un chemin
  aveuglé dont l'avant-dernier saut est l'un de leurs pairs de canal.

- [Eclair #2881][] supprime le support pour les nouveaux canaux entrants `static_remote_key`, tout
  en maintenant le support pour ceux existants et pour les nouveaux canaux sortants qui utilisent
  cette option. Les nœuds devraient utiliser les [sorties d'ancrage][topic anchor outputs] à la place, car
  les nouveaux canaux entrants `static_remote_key` sont désormais considérés comme obsolètes.

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="30320,29523,7461,2881" %}
{% include linkers/issues.md v=2 issues="30320,29523,7461,2881" %}
[BDK 1.0.0-beta.1]: https://github.com/bitcoindevkit/bdk/releases/tag/v1.0.0-beta.1
[news263 full-rbf]: /fr/newsletters/2023/08/09/#full-rbf-par-defaut
[news288 rbfr]: /fr/newsletters/2024/02/07/#proposition-de-remplacement-par-feerate-pour-echapper-au-pinning
[news283 truc pin]: /fr/newsletters/2024/01/03/#couts-d-epinglage-des-transactions-v3
[news288 rbfr]: /fr/newsletters/2024/02/07/#proposition-de-remplacement-par-feerate-pour-echapper-au-pinning
[news290 rbf]: /fr/newsletters/2024/02/21/#le-simple-remplacement-par-taux-de-frais-ne-garantit-pas-la-compatibilite-des-incitations
[news285 cluster cpfp-co]: /fr/newsletters/2024/01/17/#la-suppression-du-decoupage-cpfp-est-necessaire
[news286 imbued]: /fr/newsletters/2024/01/24/#logique-imbriquee-v3
[news287 sibling]: /fr/newsletters/2024/01/31/#remplacement-par-frais-de-parente
[news289 imbued]: /fr/newsletters/2024/02/14/#que-se-serait-il-passe-si-les-regles-v3-avaient-ete-appliquees-aux-sorties-d-ancrage-il-y-a-un-an
[todd fr-rbf]: https://mailing-list.bitcoindevs.xyz/bitcoindev/Zpk7EYgmlgPP3Y9D@petertodd.org/
[harding rbfr fundamental]: https://mailing-list.bitcoindevs.xyz/bitcoindev/d57a02a84e756dbda03161c9034b9231@dtrt.org/
[todd unsolvable]: https://mailing-list.bitcoindevs.xyz/bitcoindev/Zp1utYduhnWf4oA4@petertodd.org/
[teinurier hacky]: https://github.com/bitcoin/bitcoin/issues/29319#issuecomment-1968709925
[daftuar prefer not]: https://github.com/bitcoin/bitcoin/issues/29319#issuecomment-1968709925
[cln self-pay]: /fr/newsletters/2023/08/02/#core-lightning-6399
