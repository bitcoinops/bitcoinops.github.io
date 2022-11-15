---
title: 'Bitcoin Optech Newsletter #225'
permalink: /fr/newsletters/2022/11/09/
name: 2022-11-09-newsletter-fr
slug: 2022-11-09-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin d'information de cette semaine résume la discussion en cours sur une option
de configuration permettant d'activer la fonction full-RBF dans Bitcoin Core
et décrit un bogue affectant BTCD, LND et d'autres logiciels. Vous trouverez
également nos sections habituelles avec le résumé d'une réunion du Club Bitcoin
Core PR Review, des descriptions de mises à jour et de release candidate,
ainsi qu'un aperçu des principaux changements apportés aux logiciels
d'infrastructure Bitcoin.

## Nouvelles

- **Poursuite de la discussion sur l'activation de full-RBF :** comme mentionné dans
  les précédents bulletins---utilisateurs, fournisseurs de services,
  et développeurs de Bitcoin Core ont évalué l'inclusion de l'option de
  configuration `mempoolfullrbf` dans la branche de développement et la
  l'actuelle release candidate version 24.0. Ces précédents bulletins
  d'informations ont résumé de nombreux arguments pour et contre cette option
  [full RBF][topic rbf] ([1][news222 rbf], [2][news223 rbf], [3][news224 rbf]).
  Cette semaine, Suhas Daftuar [a posté][daftuar rbf] sur la liste de diffusion
  Bitcoin-Dev pour faire valoir que nous devrions continuer à maintenir une
  politique de relais où les remplacements sont rejetés pour les transactions
  qui n'optent pas pour le RBF (comme décrit dans le BIP 125), et de plus,
  que nous devrions supprimer le drapeau `mempoolfullrbf` de la dernière
  release candidate de Bitcoin Core et ne pas prévoir de publier un logiciel
  avec ce drapeau, à moins (ou jusqu'à ce) que les circonstances changent sur
  le réseau". Il note :

    - *Le RBF Opt-in est déjà disponible :* toute personne souhaitant
      bénéficier des avantages de RBF Opt-in devrait pouvoir y adhérer en
      utilisant le mécanisme décrit dans le [BIP125][]. Les utilisateurs ne
      seraient servis par full-RBF que s'il y avait une raison pour laquelle
      ils ne pouvaient pas utiliser le RBF.

    - *Full-RBF ne répare pas ce qui n'est pas déjà cassé par d'autres moyens :*
      Le cas possible où certains utilisateurs d'un protocole multipartie
      pourraient refuser à d'autres utilisateurs la possibilité d'utiliser
      le RBF opt-in a été précédemment [identifié][riard funny games], mais
      Daftuar note que ce protocole est vulnérable à d'autres attaques bon
      marché ou gratuites que le Full-RBF ne résoudrait pas.

    - *Full-RBF supprime des options :* "En l'absence d'autres exemples
      [de problèmes résolus par full-rbf], il ne me semble pas que full-rbf
      résolve les problèmes des utilisateurs de RBF, qui sont déjà libres
      de choisir de soumettre leurs transactions à la politique RBF du BIP 125.
      De ce point de vue, "activer full-rbf" revient en fait à retirer à
      l'utilisateur le choix de soumettre une transaction à un régime de
      politique de non-remplacement."

    - *Offrir le non-remplacement n'introduit aucun problème pour les nœuds complets :*
      En effet, il simplifie le traitement de longues chaînes de transactions.

    - *Il n'est pas toujours facile de déterminer la compatibilité des incitations :*
       Daftuar utilise la proposition pour le relais de transaction v3 (voir la
       [Newsletter #220][news220 v3tx]) comme exemple :

       > Supposons que dans quelques années quelqu'un propose d'ajouter un
       > flag "-disable_v3_transaction_enforcement" à notre logiciel, pour
       > laisser les utilisateurs décider d'éteindre cette politique de restriction
       > et traiter les transactions V3 comme des V2, pour toutes les mêmes raisons
       > que l'on pourrait soutenir aujourd'hui avec full-rbf [...]
       >
       > [Ceci] pourrait être subversif pour rendre les cas d'usage de Lightning
       > sur le travail des transactions v3 [...] nous ne devons pas permettre aux utilisateurs de
       > désactiver cette politique, car tant que cette politique est juste
       > facultative et fonctionnant pour ceux qui le souhaitent, elle ne devrait pas nuire
       > à toute personne à qui nous offrons un ensemble de règles plus strictes pour des
       > cas d'usage particuliers. Ajouter un moyen de contourner ces règles, c'est juste essayer de
       > briser le cas d'utilisation de quelqu'un d'autre, sans essayer d'en ajouter un nouveau. Nous
       > ne devrions pas brandir la "compatibilité des incitations" comme une matraque pour
       > briser des choses qui semblent fonctionner et ne pas causer
       > de préjudice à autrui.
       >
       > Je pense que c'est exactement ce qui se passe avec full-rbf.

    Daftuar termine son courriel par trois questions pour ceux qui souhaitent toujours que l'option
    `mempoolfullrbf` soit incluse dans Bitcoin Core :

    1. "Est-ce que full-rbf offre des avantages autres que la rupture
       des pratiques commerciales de zeroconf ?  Si oui, quels sont-ils ?"

    2. "Est-il raisonnable d'appliquer les règles de rbf du BIP 125 à toutes
       les transactions, si ces règles elles-mêmes ne sont pas toujours
       compatibles avec les incitations ?"

    3. "Si quelqu'un devait proposer une option de ligne de commande qui casse
       le relai de transaction v3 dans le futur, y a-t-il une base logique pour
       s'y opposer qui soit cohérente avec l'évolution vers full-rbf maintenant ?"

    À l'heure où nous écrivons ces lignes, personne n'a répondu aux questions de
    Daftuar sur la liste de diffusion, bien que deux réponses à cet ensemble de
    questions aient été publiées sur une [PR][bitcoin core #26438] du site Bitcoin Core
    que Daftuar a ouvert pour proposer de retirer l'option de configuration `mempoolfullrbf`.
    Daftuar plus tard a [clôturé][26438 close] cette PR.

    Au moment de la rédaction de cet article, nous ingnorons si quelqu'un ferait
    d'autres commentaires sur le sujet.

- **Bogue d'analyse des blocs affectant plusieurs logiciels :** comme indiqué dans
  la [Newsletter #222][news222 bug], il est apparu qu'un bogue majeur,
  affectant le nœud complet BTCD et le nœud LND, a été accidentellement
  déclenché, mettant les utilisateurs du logiciel en danger. Une mise à jour
  du logiciel a été rapidement publiée. Peu de temps après le déclenchement
  de ce bogue, Anthony Towns a [découvert][towns find] un deuxième bogue
  connexe qui ne pouvait être déclenché que par les mineurs. Towns a signalé
  le bogue au responsable de la maintenance de BTCD et LND, Olaoluwa Osuntokun,
  qui a préparé un correctif à inclure dans la prochaine mise à jour générale
  du logiciel. Le fait d'inclure le correctif de sécurité à côté d'autres
  changements pouvait cacher qu'une vulnérabilité était en train d'être corrigée
  et réduire les chances qu'elle soit exploitée. De manière responsable, Towns et
  Osuntokun ont gardé la vulnérabilité secrète jusqu'à ce que le correctif puisse
  être déployé.

    Malheureusement, le deuxième bogue connexe a été redécouvert indépendamment par
    quelqu'un qui a trouvé un mineur pour le déclencher. Ce nouveau bug a de nouveau
    affecté BTCD et LND, mais il a également affecté au moins [deux autres][liquid and rust bitcoin vulns] projets
    ou services importants. Tous les utilisateurs des systèmes affectés doivent
    procéder à une mise à jour immédiate. Nous réitérons notre conseil d'il y a trois
    semaines à toute personne utilisant un logiciel Bitcoin de s'inscrire pour
    recevoir les annonces de sécurité de l'équipe de développement de ce logiciel.

    Avec la publication de ce bulletin d'information, Optech a également ajouté une page
    spéciale où nous énumérons les noms des [personnes extraordinaires qui ont divulgués
    de manière responsable une vulnérabilité] [topic responsible disclosures] que nous avons résumé
    dans un bulletin d'information d'Optech. Il y a probablement plusieurs autres
    divulgations qui ne sont pas listées parce qu'elles n'ont pas encore été rendues
    publiques. Bien entendu, nous remercions également tous les examinateurs des
    propositions et des demandes de PR dont les efforts assidus ont permis d'éviter
    que d'innombrables bogues de sécurité ne se retrouvent dans les logiciels publiés.

## Bitcoin Core PR Review Club

*Dans cette section mensuelle, nous résumons une récente réunion du
[Bitcoin Core PR Review Club][] en soulignant certaines des questions
et réponses importantes. Cliquez sur une question ci-dessous pour voir
un résumé de la réponse de la réunion.*

[Assouplir MIN_STANDARD_TX_NONWITNESS_SIZE à 65 non-witness bytes][review club 26265]
c'est une PR de instagibbs qui assouplit les contraintes de taille de
transaction sans témoin de la politique de mempool. Elle permet aux transactions
d'être aussi réduite que 65 octets, remplaçant la politique actuelle qui exige
que les transactions soient d'au moins 85 octets. (voir la [Newsletter #222][news222 min relay size]).

Depuis cette rencontre du Review Club, cette PR a été fermée en faveur de la
PR [#26398][bitcoin core #26398], laquelle assouplit la politique
encore plus loin en interdisant _seulement_ les transactions de 64 octets.
Les mérites relatifs de ces deux politiques légèrement différentes ont été
discutés lors de la réunion.

{% include functions/details-list.md
  q0="Pourquoi la taille minimale des transactions était-elle de 82 octets ?
  Pouvez-vous décrire l'attaque ?"

  a0="Le minimum de 82-byte, qui a été introduit par la PR [#11423][bitcoin core #11423] en 2018,
  est la taille de la plus petite transaction de paiement standard. Cette
  modification a été présentée comme un nettoyage des règles de standardisation.
  Mais en réalité, le changement visait à empêcher qu'une transaction de 64 octets
  soit considérée comme standard, car cette taille permettait une [attaque par
  usurpation de paiement][] contre les clients SPV (en leur faisant croire qu'ils
  avaient reçu un paiement alors que ce n'était pas le cas). L'attaque consiste à
  tromper un client SPV en lui faisant croire qu'une transaction de 64 octets est
  un nœud interne de l'arbre merkle de la transaction, qui a également une longueur
  de 64 octets."

  a0link="https://bitcoincore.reviews/26265#l-35"

  q1="Un participant a demandé, s'il était nécessaire de corriger cette vulnérabilité
  secrètement, étant donné qu'il serait très coûteux (de l'ordre de 1 million de
  dollars US) de mener cette attaque, et qu'il semble peu probable que les gens
  utilisent des clients SPV pour des paiements de cette importance."

  a1="Il y a eu un certain accord, mais un participant a fait remarquer que
  notre intuition à ce sujet pourrait être fausse."

  a1link="https://bitcoincore.reviews/26265#l-66"

  q2="Que veut dire _non-witness size_,
  et pourquoi s'intéresser à la distinction de non-witness ?"

  a2="Nous nous soucions de la distinction non-witness car, dans le
  cadre de la mise à niveau de segwit, les données témoins sont exclues
  du calcul de la racine de merkle. Comme l'attaque exige que la
  transaction malveillante soit de 64 octets dans la construction de
  la racine de merkle (pour qu'elle ressemble à un nœud interne), nous
  devons en exclure les données témoins."

  a2link="https://bitcoincore.reviews/26265#l-62"

  q3="Pourquoi la mise en place de cette politique aide à prévenir l'attaque ?"

  a3="Etant donné que les nœuds de l'arbre de merkle interne ne peuvent
  contenir que 64 octets exactement, une transaction d'une taille différente
  ne peut être interprétée à tort comme un nœud de merkle interne."

  a3link="https://bitcoincore.reviews/26265#l-84"

  q4="Est-ce que cela élimine entièrement le vecteur d'attaque ?"

  a4="La modification des règles de normalité empêche seulement les transactions
  de 64 octets d'être acceptées dans les mempools et relayées, mais ces
  transactions peuvent toujours être valides par consensus et donc être minées
  dans un bloc. Pour cette raison, l'attaque est toujours possible, mais
  seulement avec l'aide des mineurs."

  a4link="https://bitcoincore.reviews/26265#l-84"

  q5="Pourquoi voudrions-nous changer la taille minimale des transactions à 65 octets,
  en dehors du fait qu'il n'est pas nécessaire d'obscurcir la CVE?"

  a5="Il existe des cas d'utilisation légitimes pour les transactions de moins de 82 octets.
  Un exemple mentionné est une transaction [Child Pays For Parent (CPFP)][topic cpfp] qui
  attribue une sortie parentale entière aux frais (une telle transaction aurait une seule
  entrée et une sortie `OP_RETURN` vide)."

  a5link="https://bitcoincore.reviews/26265#l-100"

  q6="Entre interdire les tailles inférieures à 65 octets et les tailles égales à 64 octets,
  quelle approche vous semble la meilleure et pourquoi ?
  Quelles sont les implications des deux approches ?"

  a6="Après quelques discussions sur le comptage des octets, il a été convenu qu'une
  transaction valide mais non standard peut être aussi petite que 60 octets : un stripped
  (non témoin) avec une seule entrée segwit native est de 41 B + 10 B en-tête +
  8 B de valeur + 1 B `OP_TRUE` ou `OP_RETURN` = 60 B."

  a6link="https://bitcoincore.reviews/26265#l-124"
%}

## Mises à jour et release candidates

*Nouvelles mises à jour et release candidates du principal logiciel d'infrastructure Bitcoin.
Prévoyez s'il vous plait de vous mettre à jour à la nouvelle version ou d'aider à tester
les pré-versions.*

- [Rust Bitcoin 0.28.2][] est une version mineure contenant des corrections
  de bogues qui pourraient "provoquer l'échec de la désérialisation de
  certaines transactions et/ou blocs spécifiques. Aucune transaction connue
  de ce type n'existe sur une blockchain publique."

- [Bitcoin Core 24.0 RC3][] est une release candidate pour la prochaine version de
  l'implémentation de nœuds complets la plus largement utilisée sur le réseau.
  Un [guide pour tester][bcc testing] est disponible.

  **Avertissement :** cette release candidate inclut l'option de configuration
  `mempoolfullrbf`qui, selon plusieurs développeurs de protocoles et
  d'applications, pourrait entraîner des problèmes pour les services marchands,
  comme décrit dans les newsletters[#222][news222 rbf] et [#223][news223 rbf].
  Optech encourage tous les services qui pourraient être affectés à évaluer
  la RC et à participer au débat public.

## Changements principaux dans le code et la documentation

*Changements notables cette semaine dans [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], et [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #26419][] ajoute un contexte aux journaux de l'interface
  de validation détaillant pourquoi une transaction est retirée du mempool.

- [Eclair #2404][] ajoute la prise en charge des alias SCID (Short Channel IDentifier)
  et des [canaux zéro-conf][topic zero-conf channels] même pour les
  engagements d'état des canaux qui n'utilisent pas les [sorties d'ancrage][topic anchor outputs].

- [Eclair #2468][] implemente [BOLTs #1032][], permettant au récepteur final
  d'un paiement ([HTLC][topic HTLC]) d'accepter un montant supérieur à celui
  qu'il a demandé et avec un délai d'expiration plus long que celui qu'il a
  demandé. Auparavant, les récepteurs basés sur Eclair adhéraient à l'exigence
  de [BOLT4][] selon laquelle le montant et le delta d'expiration devaient être
  exactement égaux au montant demandé, mais cette exactitude signifiait qu'un
  nœud de transmission pouvait sonder le prochain saut pour voir s'il était le
  récepteur final en changeant l'une ou l'autre valeur par le plus petit bit.

- [Eclair #2469][] étend le délai qu'il demande au dernier nœud de transfert
  de donner au prochain saut pour régler un paiement. Le dernier nœud d'expédition
  ne doit pas savoir qu'il est le dernier nœud d'expédition---il ne doit pas savoir
  que le prochain saut est le récepteur du paiement. Le temps de règlement
  supplémentaire implique que le prochain saut peut être un nœud de routage
  plutôt que le récepteur. La description de la PR de cette fonctionnalité
  indique que Core Lightning et LDK implémentent déjà ce comportement.
  Voir aussi la description de Eclair #2468 ci-dessus.

- [Eclair #2362][] ajoute la prise en charge de l'indicateur `dont_forward`
  pour les mises à jour de canal de [BOLTs #999][]. Les mises à jour de canal
  modifient les paramètres d'un canal et sont souvent diffusées pour informer
  les autres noeuds du réseau sur la façon d'utiliser le canal, mais lorsqu'une
  mise à jour de canal contient ce flag, elle ne doit pas être transmise aux
  autres noeuds.

- [Eclair #2441][] permet à Eclair de commencer à recevoir des messages d'erreur
  de n'importe quelle taille, enveloppés comme des oignons. [BOLT2][] recommande
  actuellement des erreurs de 256 octets, mais n'interdit pas les messages d'erreur
  plus longs et le [BOLTs #1021][] est ouvert pour encourager l'utilisation de
  messages d'erreur de 1024 octets encodés en utilisant la sémantique moderne
  Type-Length-Value (TLV) de LN.

- [LND #7100][] met à jour LND pour utiliser la dernière version de BTCD
  (en tant que bibliothèque), en corrigeant le bogue d'analyse des blocs décrit
  dans la section *nouvelles* ci-dessus.

- [LDK #1761][] ajoute un paramètre `PaymentID` aux méthodes d'envoi de paiements
  que les appelants peuvent utiliser pour empêcher l'envoi de plusieurs paiements
  identiques. De plus, LDK peut maintenant continuer à essayer de renvoyer un
  paiement indéfiniment, au lieu du comportement précédent qui consistait à cesser
  les tentatives après quelques blocs d'échecs répétés ; la méthode `abandon_payment`
  peut être utilisée pour empêcher de nouvelles tentatives.

- [LDK #1743][] fournit un nouvel événement `ChannelReady` lorsqu'un canal devient
  prêt à être utilisé. Notamment, l'événement peut être émis après qu'un canal ait
  reçu un nombre approprié de confirmations, ou il peut être émis immédiatement dans
  le cas d'un [canal zéro-conf] [topic zero-conf channels].

- [BTCPay Server #4157][] ajoute le support opt-in pour une nouvelle version de
  l'interface de caisse. Voir la PR pour les captures d'écran et les aperçus vidéo.

- [BOLTs #1032][] permet au destinataire final d'un paiement ([HTLC][topic HTLC])
  d'accepter un montant supérieur à celui qu'il a demandé et avec un délai d'expiration
  plus long que celui qu'il a demandé. Cela rend plus difficile pour un noeud de transfert
  de déterminer que le prochain saut est le récepteur en modifiant légèrement les
  paramètres d'un paiement. Voir la description de l'Eclair #2468 ci-dessus pour
  plus d'informations.

{% include references.md %}
{% include linkers/issues.md v=2 issues="26438,26419,5674,2404,2468,2469,2362,2441,7100,1761,1743,4157,1032,1021,999,26398,11423" %}
[bitcoin core 24.0 rc3]: https://bitcoincore.org/bin/bitcoin-core-24.0/
[rust bitcoin 0.28.2]: https://github.com/rust-bitcoin/rust-bitcoin/releases/tag/0.28.2
[bcc testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/24.0-Release-Candidate-Testing-Guide
[news222 rbf]: /fr/newsletters/2022/10/19/#option-de-remplacement-de-transaction
[news223 rbf]: /fr/newsletters/2022/10/26/#poursuite-de-la-discussion-sur-le-full-rbf
[news224 rbf]: /fr/newsletters/2022/11/02/#coherence-mempool
[daftuar rbf]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-October/021135.html
[riard funny games]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-May/003033.html
[news220 v3tx]: /fr/newsletters/2022/10/05/#proposition-de-nouvelle-politique-de-relai-de-transaction-concue-pour-les-penalites-sur-ln
[news222 bug]: /fr/newsletters/2022/10/19/#bug-d-analyse-de-bloc-affectant-btcd-et-lnd
[liquid and rust bitcoin vulns]: https://twitter.com/Liquid_BTC/status/1587499305664913413
[attaque par usurpation de paiement]: /en/topics/cve/#CVE-2017-12842
[towns find]: https://twitter.com/roasbeef/status/1587481219981508608
[26438 close]: https://github.com/bitcoin/bitcoin/pull/26438#issuecomment-1307715677
[review club 26265]: https://bitcoincore.reviews/26265
[news222 min relay size]: /fr/newsletters/2022/10/19/#taille-minimale-des-transactions-relayables
