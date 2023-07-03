---
title: 'Bulletin Hebdomadaire Bitcoin Optech #255'
permalink: /fr/newsletters/2023/06/14/
name: 2023-06-14-newsletter-fr
slug: 2023-06-14-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine résume une discussion sur l'autorisation de relayer les transactions contenant des données dans le
champ annexe taproot et des liens vers un projet de BIP pour les paiements silencieux. Vous trouverez également une nouvelle
contribution à notre série hebdomadaire limitée sur la politique mempool, ainsi que nos sections habituelles résumant une réunion
du Bitcoin Core PR Review Club, annonçant les nouvelles versions de logiciels et les versions candidates, et décrivant les
principaux changements apportés aux logiciels d'infrastructure Bitcoin les plus répandus.

## Nouvelles

- **Discussion sur les annexes à taproot :** JJoost Jager a [posté][jager annex] sur la liste de diffusion Bitcoin-Dev
  une demande de modification du relais de transaction et de la politique de minage de Bitcoin Core afin de permettre le
  stockage de données arbitraires dans le champ annexe [taproot][topic taproot].  Ce champ est une partie optionnelle des
  données du témoin pour les transactions taproot. S'il est présent, les signatures dans taproot et [tapscript][topic tapscript]
  doivent s'engager sur ses données (ce qui rend impossible l'ajout, la suppression ou la modification par un tiers),
  mais il n'a pas d'autre objectif défini pour l'instant---il est réservé aux futures mises à jour du protocole, en particulier
  aux soft forks.

    Bien qu'il y ait eu des [propositions antérieures][riard annex] pour définir un format pour l'annexe, elles n'ont pas été
    largement acceptées et mises en œuvre. Jager a proposé deux formats ([1][jager annex], [2][jager annex2]) qui pourraient
    être utilisés pour permettre à quiconque d'ajouter des données arbitraires à l'annexe d'une manière qui ne compliquerait
    pas de manière significative les efforts de normalisation ultérieurs qui pourraient être regroupés avec un soft fork.

    Greg Sanders [a répondu][sanders annex] pour demander quelles données Jager voulait spécifiquement stocker dans
    l'annexe et a décrit sa propre utilisation de l'annexe en testant le protocole [LN-Symmetry][topic eltoo] avec la
    proposition de soft fork [SIGHASH_ANYPREVOUT][topic sighash_anyprevout] à l'aide de Bitcoin Inquisition (voir le
    [Bulletin d'information #244][news244 annex]). Sanders a également décrit un problème avec l'annexe : dans un protocole
    multipartite (comme un [coinjoin][topic coinjoin]), chaque signature n'engage que l'annexe pour l'entrée contenant
    cette signature---et non les annexes pour d'autres entrées dans la même transaction. Cela signifie que si Alice, Bob
    et Mallory signent ensemble une coinjoin, Alice et Bob n'ont aucun moyen d'empêcher Mallory de diffuser une version
    de la transaction avec une annexe importante qui retarde sa confirmation. Étant donné que Bitcoin Core et d'autres nœuds
    complets ne relaient pas actuellement les transactions contenant des annexes, ce problème ne se pose pas pour l'instant.
    Jager [a répondu][jager annex4] qu'il souhaite stocker des signatures à partir de clés éphémères pour un type de
    [coffre-fort][topic vaults] qui ne nécessite pas de soft fork, et il [a suggéré][jager annex3] que certains
    [travaux antérieurs][bitcoin core #24007] dans Bitcoin Core pourraient éventuellement résoudre le problème du relais
    des annexes dans certains protocoles multipartites.

- **Projet de BIP pour les paiements silencieux :** Josie Baker et Ruben Somsen ont [posté][bs sp] sur la liste de diffusion
  Bitcoin-Dev un projet de BIP pour les [paiements silencieux][topic silent payments], un type de code de paiement réutilisable
  qui produira une adresse unique sur la chaîne à chaque fois qu'il sera utilisé, empêchant ainsi la [liaison des
  sorties][topic output linking]. La liaison des sorties peut réduire de manière significative la vie privée des utilisateurs (y compris les
  utilisateurs qui ne sont pas directement impliqués dans une transaction). Le projet détaille les avantages de la proposition,
  ses inconvénients et la manière dont les logiciels peuvent l'utiliser efficacement.  Plusieurs commentaires intéressants ont
  déjà été postés sur le [PR][bips #1458] pour le BIP.

## En attente de confirmation #5 : Politique de protection des ressources des nœuds

_Une [série][policy series] hebdomadaire limitée sur le relais de transaction, l'inclusion dans le mempool, et la sélection des
transactions minières---y compris pourquoi Bitcoin Core a une politique plus restrictive que celle permise par le consensus et
comment les portefeuilles peuvent utiliser cette politique le plus efficacement possible._

{% include specials/policy/fr/05-dos.md %}

## Bitcoin Core PR Review Club

*Dans cette section mensuelle, nous résumons une récente réunion du
[Bitcoin Core PR Review Club][] en soulignant certaines des questions
et réponses importantes. Cliquez sur une question ci-dessous pour voir
un résumé de la réponse de la réunion.*

[Autoriser les connexions whitebind entrantes à évincer plus agressivement les pairs lorsque les slots sont
pleins][review club 27600]
est une PR de Matthew Zipkin (pinheadmz) qui améliore dans certains cas la capacité d'un opérateur de nœud à configurer
les pairs souhaités pour le nœud. Plus précisément, si l'opérateur du nœud a mis sur liste blanche un pair entrant potentiel
(par exemple, un client léger contrôlé par l'opérateur du nœud), sans cette PR, et en fonction de l'état des pairs du nœud,
il est possible que le nœud refuse la tentative de connexion de ce client léger.

Cette PR rend beaucoup plus probable la possibilité pour le pair désiré de se connecter à notre nœud. Pour ce faire,
il évince un pair entrant existant qui, sans ce PR, n'aurait pas été éligible à l'éviction.

{% include functions/details-list.md
  q0="Pourquoi cette PR ne s'applique-t-elle qu'aux demandes de pairs entrants ?"
  a0="Notre nœud _initie_ les connexions sortantes ; ce PR modifie la façon dont le nœud _réagit_ à une demande de connexion
      entrante. Les nœuds sortants peuvent être expulsés, mais cela se fait à l'aide d'un algorithme entièrement distinct."
  a0link="https://bitcoincore.reviews/27600#l-33"

  q1="Quel est l'impact du paramètre `force` de `SelectNodeToEvict()` sur la valeur de retour ?"
  a1="Spécifier `force` comme `true` assure qu'un pair entrant non `noban` est retourné, s'il existe, même s'il est autrement
      protégé contre l'expulsion.
      Sans le PR, aucun pair ne serait renvoyé s'ils sont tous exclus (protégés) de l'expulsion."
  a1link="https://bitcoincore.reviews/27600#l-70"

  q2="Comment la signature de la fonction `EraseLastKElements()` est-elle modifiée dans ce PR ?"
  a2="Elle est passée d'une fonction de retour `void` à une fonction de retour de la dernière entrée qui a été _supprimée_
      de la liste des candidats à l'éviction. (Ce nœud protégé peut être évincé si nécessaire).
      Cependant, suite à une discussion lors de la réunion du club de révision, le PR a été simplifié de telle sorte que cette
      fonction n'est plus modifiée."
  a2link="https://bitcoincore.reviews/27600#l-126"

  q3="`EraseLastKElements` était une fonction templatée, mais cette PR supprime les deux arguments template.
      Pourquoi ? Y a-t-il des inconvénients à ce changement ?"
  a3="Cette fonction était et (avec ce PR) est appelée avec des arguments de modèle uniques, il n'est donc pas nécessaire que
      la fonction soit modélisée.
      Les changements apportés par le PR à cette fonction ont été annulés, donc elle est toujours modélisée, parce que changer
      cela dépasserait le cadre du PR."
  a3link="https://bitcoincore.reviews/27600#l-126"

  q4="Supposons que nous passions un vecteur de 40 candidats à l'éviction à `SelectNodeToEvict()`.
      Avant et après cette PR, quel est le maximum théorique de noeuds Tor qui peuvent être protégés de l'éviction ?"
  a4="Avec et sans les relations publiques, le nombre serait de 34 sur 40, en supposant qu'il ne s'agisse pas de `noban` entrant."
  a4link="https://bitcoincore.reviews/27600#l-156"
%}

## Mises à jour et versions candidates

*Nouvelles versions et versions candidates pour les principaux projets
d'infrastructure Bitcoin. Veuillez envisager de passer aux nouvelles
versions ou d'aider à tester les versions candidates.*

- [Core Lightning 23.05.1][] est une version de maintenance pour cette implémentation de LN.  Ses notes de publication
  indiquent que "cette version corrige uniquement les bogues qui réparent plusieurs crashs signalés dans la nature. Il
  s'agit d'une mise à jour recommandée pour tous ceux qui utilisent la version 23.05."

## Changements notables dans le code et la documentation

*Changements notables cette semaine dans [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo], et
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [Bitcoin Core #27501][] ajoute une RPC `getprioritizedtransactions` qui renvoie une carte de tous les deltas de frais créés
  par l'utilisateur avec `prioritisetransaction`, indexés par txid. La carte indique également si chaque transaction est
  présente dans le mempool.  Voir aussi [Newsletter #250][news250 getprioritisedtransactions].

- [Core Lightning #6243][] met à jour la RPC `listconfigs` pour mettre toutes les informations de configuration dans un
  seul dictionnaire et transmet également l'état de toutes les options de configuration aux plugins redémarrés.

- [Eclair #2677][] augmente le `max_cltv` par défaut de 1 008 blocs (environ une semaine) à 2 016 blocs (environ deux semaines).
  Cela étend le nombre maximum de blocs autorisés jusqu'à ce qu'une tentative de paiement échoue. Ce changement est motivé par
  le fait que les noeuds du réseau augmentent leur fenêtre de temps réservée pour adresser un HTLC expirant (`cltv_expiry_delta`)
  en réponse à des taux élevés sur la chaîne. Des changements similaires ont été [fusionnés avec LND][lnd max_cltv] et CLN.

- [Rust bitcoin #1890][] ajoute une méthode pour compter le nombre d'opérations de signature (sigops) dans les scripts
  non-tapscript.  Le nombre de sigops est limité par bloc et le code de sélection des transactions de Bitcoin Core pour le
  minage traite les transactions avec un ratio élevé de sigops par taille (poids) comme s'il s'agissait de transactions plus
  importantes, ce qui réduit effectivement leur taux. Cela signifie qu'il peut être important pour les créateurs de transactions
  d'utiliser quelque chose comme cette nouvelle méthode pour vérifier le nombre de sigops qu'ils utilisent.

{% include references.md %}
{% include linkers/issues.md v=2 issues="27501,6243,2677,1890,1458,24007" %}
[policy series]: /fr/blog/waiting-for-confirmation/
[jager annex]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-June/021731.html
[riard annex]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-October/020991.html
[jager annex2]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-June/021756.html
[sanders annex]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-June/021736.html
[news244 annex]: /fr/newsletters/2023/03/29/#bitcoin-inquisition-22
[jager annex3]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-June/021743.html
[bs sp]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-June/021750.html
[jager annex4]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-June/021737.html
[Core Lightning 23.05.1]: https://github.com/ElementsProject/lightning/releases/tag/v23.05.1
[review club 27600]: https://bitcoincore.reviews/27600
[news250 getprioritisedtransactions]: /fr/newsletters/2023/05/10/#bitcoin-core-pr-review-club
[lnd max_cltv]: /en/newsletters/2019/10/23/#lnd-3595
