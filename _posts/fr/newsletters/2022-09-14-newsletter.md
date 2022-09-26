---
title: 'Bitcoin Optech Newsletter #217'
permalink: /fr/newsletters/2022/09/14/
name: 2022-09-14-newsletter-fr
slug: 2022-09-14-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
La newsletter de cette semaine comprend notre section habituelle avec le
résumé d'une réunion du Bitcoin Core PR Review Club, une liste de nouvelles
mises à jour et de pré-versions des logiciels et des résumés de changements notables
apportés aux principaux projets d'infrastructures Bitcoin.


## Nouvelles

*Pas de nouvelles de grande importance cette semaine.*

## Bitcoin Core PR Review Club

*Dans cette section mensuelle, nous résumons une récente réunion du
[Bitcoin Core PR Review Club][] en soulignant certaines des questions et réponses
importantes.  Cliquez sur une question ci-dessous pour voir un résumé de la réponse
de la réunion.*

[Réduire la bande passante pendant la synchronisation initiale des en-têtes
lorsqu'un bloc est trouvé][review club 25720] est une proposition d'amélioration (Pull Request)
de Suhas Daftuar qui réduit la demande de bande passante d'un nœud lors de la synchronisation
de la blockchain avec les pairs, y compris pendant le téléchargement de blocs initial (IBD).
Une partie importante de l'éthique de Bitcoin est de minimiser les demandes de ressources
pour faire fonctionner un nœud complet de validation, y compris les ressources réseau,
afin d'encourager plus d'utilisateurs à faire fonctionner des nœuds complets.
Accélérer le temps de synchronisation favorise également cet objectif.

La synchronisation de la blockchain se fait en deux phases: premièrement, le nœud
reçoit des en-têtes de blocs de la part de ses pairs; ces en-têtes sont suffisants
pour déterminer la meilleure chaîne probable, celle qui cumule le plus de travail (proof of work).
Deuxièmement, le nœud utilise cette meilleure chaîne d'en-têtes pour demander et
télécharger les blocs complets correspondants.
Cette proposition d'amélioration (PR) n'affecte que la première phase (le téléchargement
des en-têtes).

{% include functions/details-list.md
  q0="Pourquoi les nœuds reçoivent-ils (la plupart du temps) des annonces de blocs `inv`
  pendant qu'ils effectuent la synchronisation initiale des en-têtes, même s'ils ont indiqué
  leur préférence pour les annonces d'en-têtes ([BIP 130][])?"
  a0="Un nœud n'annoncera pas de nouveau bloc à un pair en utilisant un message d'en-tête
  si le pair n'a pas précédemment envoyé un en-tête auquel le nouvel en-tête est connecté,
  et les nœuds de synchronisation n'envoient pas d'en-têtes."
  a0link="https://bitcoincore.reviews/25720#l-30"

  q1="Pourquoi gaspillons nous de la bande passante (pendant la synchronisation initiale
  des en-têtes) en ajoutant tous les pairs qui nous annoncent un bloc via un `inv`
  comme pairs de synchronisation des en-têtes ?"
  a1="Chacun de ces pairs commencera alors à nous envoyer le même flux d'en-têtes:
  les messages `inv` déclenchent un `getheaders` vers le même pair, et sa réponse `headers` déclenche
  un autre `getheaders` pour la plage d'en-têtes de bloc immédiatement suivante. Recevoir
  des en-têtes en double est inoffensif, sauf pour la bande passante supplémentaire."
  a1link="https://bitcoincore.reviews/25720#l-62"

  q2="Quelle serait votre estimation (limite inférieure / supérieure) de la quantité de bande
  passante gaspillée ?"
  a2="la limite supérieure (en bytes): `(quantité de pairs - 1) * quantité de blocs * 81`;
  la limite inférieure: zero (si aucun nouveau bloc n'arrive pendant la synchronisation des
  en-têtes ; si le pair de synchronisation et le réseau sont rapides, le téléchargement des 700k+
  en-têtes ne prendra que quelques minutes)"
  a2link="https://bitcoincore.reviews/25720#l-79"

  q3="A quoi servent les membres de CNodeState `fSyncStarted` et `m_headers_sync_timeout`,
  et `PeerManagerImpl::nSyncStarted` ?
  Si nous commençons à synchroniser les en-têtes avec les pairs qui nous annoncent un bloc
  via un `inv`, pourquoi ne pas augmenter `nSyncStarted`, mettre `fSyncStarted = true`
  et mettre à jour `m_headers_sync_timeout` ?"
  a3="`nSyncStarted` compte le nombre de pairs dont `fSyncStarted` est vrai, et ce nombre
  ne peut pas être supérieur à 1 jusqu'à ce que le noeud ait des en-têtes proches (moins d'un jour)
  de l'heure actuelle. Ce pair (arbitraire) sera notre pair initial de synchronisation d'en-têtes.
  Si ce pair est lent, le noeud l'arrête (`m_headers_sync_timeout`) et trouve un autre pair de
  synchronisation d'en-têtes 'initial'. Mais si, pendant la synchronisation des en-têtes, un noeud
  envoie un message `inv` qui annonce des blocs, alors sans ce PR, le noeud commencera à demander des
  en-têtes à ce pair aussi, _sans_ mettre son flag `fSyncStarted`. Ceci est la source des messages
  d'en-têtes redondants, et n'était probablement pas prévu, mais a l'avantage de permettre à la
  synchronisation des en-têtes de continuer même si le pair initial de synchronisation des en-têtes est
  malveillant, cassé, ou très lent. Avec ce PR, le noeud demande des en-têtes à seulement _un_ pair
  supplémentaire (plutôt qu'à tous les pairs qui ont annoncé le nouveau bloc)."
  a3link="https://bitcoincore.reviews/25720#l-102"

  q4="Une alternative à l'approche adoptée dans le PR serait d'ajouter un pair de synchronisation
  d'en-têtes supplémentaire après un délai d'attente (fixe ou aléatoire). Quel est l'avantage
  de l'approche adoptée dans le PR par rapport à cette alternative ?"
  a4="Un avantage est que les pairs qui nous annoncent un `inv` ont une plus grande probabilité
  d'être réactifs. Un autre avantage est qu'un pair qui réussit à nous envoyer le bloc `inv`
  en premier est souvent aussi un pair très rapide. Nous ne choisirons donc pas d'autre pair
  lent si, pour une raison quelconque, notre pair initial est lent."

  q4link="https://bitcoincore.reviews/25720#l-135"
%}

## Mise à jour et Pré-version

*Nouvelles mises à jour et pré-versions des projets principaux Bitcoin. Prévoyez s'il vous plait
de vous mettre à jour à la nouvelle version ou d'aider à tester les pré-versions.*

- [LDK 0.0.111][] ajoute la création, la réception et la relayage d'
  [onion messages][topic onion messages], parmi plusieurs autres nouvelles fonctionnalités
  et apporte des corrections de bogues.

## Changements notables dans le code et la documentation

*Changements notables cette semaine dans [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], et [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #25614][] construit sur [Bitcoin Core #24464][], permettant
  la possibilité d'ajouter et de tracer des journaux avec des niveaux spécifiques
  de gravité dans addrdb, addrman, banman, i2p, mempool, netbase, net, net_processing,
  timedata, et torcontrol.

- [Bitcoin Core #25768][] corrige un bogue où le portefeuille ne rediffusait
pas toujours de transactions enfants des transactions non confirmées.
Le portefeuille intégré de Bitcoin Core tente périodiquement de diffuser
ses transactions qui n'ont pas encore été confirmées. Certaines de ces
transactions peuvent dépenser les sorties d'autres transactions non confirmées.
Bitcoin Core rendait aléatoire l'ordre des transactions avant de les envoyer à une autre
partie du code qui s'attendait à recevoir des transactions parentes
non confirmées avant les transactions enfants (ou, plus généralement, tous les
ancêtres non confirmés avant tout descendant). Lorsqu'une transaction enfant
était reçue avant son parent, elle était rejetée en interne au lieu d'être rediffusée.

- [Bitcoin Core #19602][] ajoute un RPC `migratewallet` qui convertira un portefeuille
en utilisant nativement [descriptors][topic descriptors]. Cela fonctionne pour
les portefeuilles pré-HD (ceux créés avant que [BIP32][] n'existe ou n'ait été adopté
par Bitcoin Core), les portefeuilles HD et les portefeuilles de surveillance uniquement
sans clés privées (watch-only). Avant d'appeler cette RPC, lisez la [documentation][managing wallets]
et sachez qu'il existe certaines différences d'API entre les portefeuilles sans descripteurs
et ceux qui prennent en charge nativement les descripteurs.

<!-- TODO:harding to separate dual funding from interactive funding -->

- [Eclair #2406][] ajoute une option pour configurer l'implémentation expérimentale
  [interactive funding protocol][topic dual funding] pour exiger que les transactions
  d'ouverture de canal incluent uniquement les *entrées confirmées* --- entrées qui
  dépensent les sorties faisant partie d'une transaction confirmée. S'il est activé,
  cela peut empêcher un initiateur de retarder l'ouverture d'un canal en le basant
  sur une grande transaction non confirmée avec un faible taux de commission (fee rate).

- [Eclair #2190][] supprime la prise en charge du format original des données "onion"
de longueur fixe, dont la suppression de la spécification LN est également proposée
dans [BOLTs #962][].  Le format amélioré à longueur variable a été [ajouté à la
spécification][BOLTs #619] il y a plus de trois ans et les résultats de l'analyse du
réseau mentionnés dans le PR BOLTs #962 indiquent qu'il est pris en charge par tous
les nœuds sauf 5 sur plus de 17 000 annoncés publiquement.  Core Lightning a également
supprimé le support plus tôt cette année (voir [Newsletter #193][news193 cln5058]).

- [Rust Bitcoin #1196][] modifie l'ajout précédent du type  `LockTime`
(voir [Newsletter #211][news211 rb994]) pour devenir `absolute::LockTime`
et ajoute un nouveau `relative::LockTime` qui représente les "locktimes" utilisés
avec [BIP68][] and [BIP112][].

{% include references.md %}
{% include linkers/issues.md v=2 issues="25614,24464,25768,19602,2406,2190,962,619,1196" %}
[managing wallets]: https://github.com/bitcoin/bitcoin/blob/master/doc/managing-wallets.md
[news193 cln5058]: /en/newsletters/2022/03/30/#c-lightning-5058
[news211 rb994]: /en/newsletters/2022/08/03/#rust-bitcoin-994
[ldk 0.0.111]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.0.111
[review club 25720]: https://bitcoincore.reviews/25720
[BIP 130]: https://github.com/bitcoin/bips/blob/master/bip-0130.mediawiki
