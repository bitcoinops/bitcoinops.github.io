---
title: 'Bulletin Hebdomadaire Bitcoin Optech #328'
permalink: /fr/newsletters/2024/11/08/
name: 2024-11-08-newsletter-fr
slug: 2024-11-08-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine décrit une vulnérabilité affectant les anciennes versions de Bitcoin
Core et inclut nos sections habituelles avec le résumé d'une réunion du Bitcoin Core PR Review Club,
il annonce les mises à jour et les versions candidates, et présente les changements
apportés aux principaux logiciels d'infrastructure Bitcoin.

## Nouvelles

- **Divulgation d'une vulnérabilité affectant les versions de Bitcoin Core antérieures à 25.1 :**
  Antoine Poinsot a [annoncé][poinsot stall] à la liste de diffusion Bitcoin-Dev la divulgation (\*) finale
  de vulnérabilité précédant la nouvelle politique de divulgation de Bitcoin Core (voir le [Bulletin
  #306][news306 disclosure]). Le [rapport de vulnérabilité détaillé][stall vuln] note que les versions
  de Bitcoin Core 25.0 et antérieures étaient susceptibles à une réponse inappropriée du protocole P2P
  qui retarderait une demande de bloc jusqu'à 10 minutes. La solution a été de permettre que les blocs
  "puissent être demandés simultanément jusqu'à 3 pairs de blocs compacts à large bande 
  passante (\*), dont l'un doit être une connexion sortante." Les versions 25.1 et ultérieures incluent le
  correctif.

## Bitcoin Core PR Review Club

*Dans cette section mensuelle, nous résumons une récente réunion du [Bitcoin Core PR Review Club][],
en soulignant certaines des questions et réponses importantes. Cliquez sur une question ci-dessous
pour voir un résumé de la réponse de la réunion.*

[Ephemeral Dust][review club 30239] est une PR par [instagibbs][gh instagibbs] qui fait des
transactions avec de la poussière éphémère (\*) standard, améliorant la facilité d'utilisation
des ancres avec ou sans clé ([P2A][topic ephemeral anchors]). Cela est pertinent pour plusieurs schémas de
contrat hors chaîne, y compris ceux utilisés par le Lightning Network, [Ark][topic ark], les Arbres
de Timeout, et d'autres constructions avec de grands arbres pré-signés ou d'autres contrats
intelligents (*smart contract*) de large-N partie.

Avec les changements de politique de poussière éphémère, les transactions sans frais avec une sortie
[poussière][topic uneconomical outputs] sont autorisées dans la mempool si une transaction [enfant payant
les frais][topic cpfp] qui dépense immédiatement la sortie poussière est connue du nœud.

{% include functions/details-list.md
  q0="La poussière est-elle restreinte par le consensus ? La politique ? Les deux ?"
  a0="Les sorties dust sont uniquement restreintes par les règles de politique, elles ne sont pas
  affectées par le consensus."
  a0link="https://bitcoincore.reviews/30239#l-27"

  q1="Comment la poussière peut-elle être problématique ?"
  a1="Les sorties poussières (ou non économiques) valent moins que les frais nécessaires pour les dépenser.
  Puisqu'elles peuvent être dépensées, elles ne peuvent pas être élaguées (\*) de l'ensemble UTXO. Comme
  leur dépense est non économique, elles restent souvent non dépensées, augmentant la taille de
  l'ensemble UTXO. Un ensemble UTXO plus grand augmente les exigences en ressources pour les nœuds.
  Cependant, les UTXOs peuvent toujours être dépensées en raison d'incitations externes au-delà de leur
  valeur en satoshis, comme dans le cas des [sorties d'ancre][topic anchor outputs]."
  a1link="https://bitcoincore.reviews/30239#l-40"

  q2="Pourquoi le terme éphémère est-il significatif ? Quelles sont les règles proposées spécifique à la poussière éphémère ?"
  a2="Le terme 'éphémère' indique que la production de poussière
  est destinée à être dépensée rapidement. Les règles concernant la poussière éphémère exigent que la
  transaction parente soit sans frais et qu'elle ait exactement une transaction enfant qui dépense la
  sortie de poussière."
  a2link="https://bitcoincore.reviews/30239#l-50"

  q3="Pourquoi est-il important d'imposer une restriction de frais ?"
  a3="Un objectif clé est d'empêcher que les sorties de poussière restent non dépensées lorsqu'elles
  sont confirmées. En exigeant que la transaction parente soit sans frais, les mineurs n'ont pas
  d'incitation à miner le parent sans l'enfant. Puisque la poussière éphémère est une règle de
  politique, et non une règle de consensus, les incitations économiques jouent un rôle crucial."
  a3link="https://bitcoincore.reviews/30239#l-56"

  q4="En quoi les relais 1P1C et les transactions TRUC sont-ils pertinents pour la poussière éphémère ?"
  a4="Comme une transaction de poussière éphémère doit être sans frais, elle ne peut pas être relayée
  seule, rendant des mécanismes comme [1-parent-1-enfant (1P1C)][28.0 integration guide] essentiels.
  Les transactions TRUC (v3) sont limitées à un seul parent non confirmé, ce qui est conforme à
  l'exigence de la poussière éphémère. TRUC est actuellement le seul moyen de permettre des
  transactions avec un taux de frais inférieur au [`minrelaytxfee`][topic default minimum transaction
  relay feerates]."
  a4link="https://bitcoincore.reviews/30239#l-59"

%}

## Mises à jour et versions candidates

_Nouvelles versions et candidats à la version pour les projets d'infrastructure Bitcoin populaires.
Veuillez envisager de mettre à jour vers les nouvelles versions ou d'aider à tester les versions 
candidates ._

- [Bitcoin Core 27.2][] est une mise à jour de maintenance pour la série de versions précédente
  contenant des corrections de bugs. Tout utilisateur qui ne passera pas bientôt à la dernière
  version, [28.0][], devrait envisager de se mettre à jour au moins vers cette nouvelle version de
  maintenance.

- [Libsecp256k1 0.6.0][] est une version de cette bibliothèque d'opérations cryptographiques liées à
  Bitcoin. "Cette version ajoute un module [MuSig2][topic musig], introduit une méthode
  significativement plus robuste pour effacer les secrets de la pile, et supprime les fonctions
  `secp256k1_scratch_space` inutilisées."

## Changements notables dans le code et la documentation

_Changes récents notables dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning
repo], [Eclair][eclair repo], [LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo],
[Interface de Portefeuille Matériel (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Propositions d'Amélioration de Bitcoin (BIPs)][bips
repo], [Lightning BOLTs][bolts repo], [Lightning BLIPs][blips repo], [Inquisition Bitcoin][bitcoin
inquisition repo], et [BINANAs][binana repo]._

- [LDK #3360][] ajoute la retransmission des messages `channel_announcement` tous les six blocs
  pendant une semaine après la confirmation du canal public. Cela élimine la dépendance vis-à-vis des
  pairs pour la retransmission et assure que les canaux sont toujours visibles pour le réseau.

- [LDK #3207][] introduit le support pour inclure des demandes de facture (\*) dans les [messages
  oignon][topic onion messages] des [paiements asynchrones][topic async payments] lors du paiement de
  factures statiques [BOLT12][topic offers] en tant qu'expéditeur toujours en ligne. Ce point ne figurait
  pas dans la PR couverte par le bulletin [#321][news321 invreq]. L'inclusion des demandes de facture
  dans les oignons de paiement s'étend également aux nouvelles tentatives.
  Voir le Bulletin [#321][news321 retry].

## Lexique
Traduire est toujours un exercice compliqué surtout techniquement. Cela implique des choix (parfois arbitraires) face au nom de l'objet technique désigné. 
Je propose ici l'introduction d'une section lexique qui permettrait de noter les traductions précises utilisées dans chaque Newsletter.
*Les notes de bas de page \[\^1\] ne sont pas utilisées*. 

**divulgation**: disclosure. 
**blocs compacts à large bande**:  high-bandwidth compact block peers.
**poussière éphémère**: ephemeral dust.
**élaguées**: pruned. 
**facture**: invoice.

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 15:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="3360,3207" %}
[news306 disclosure]: /fr/newsletters/2024/06/07/#divulgation-a-venir-de-vulnerabilites-affectant-les-anciennes-versions-de-bitcoin-core
[stall vuln]: https://bitcoincore.org/en/2024/11/05/cb-stall-hindering-propagation/
[poinsot stall]: mailto:uJpfg8UeMOfVUATG4YRiGmyz5MALtZq68FCBXA6PT-BNstodivpqQfDxD1JAv5Qny_vuNr-A1m8jIDNHQLhAQt8hj8Ee9OT6ZFE5Z16O97A=@protonmail.com
[bitcoin core 27.2]: https://bitcoincore.org/en/2024/11/04/release-27.2/
[28.0]: https://bitcoincore.org/en/2024/10/02/release-28.0/
[libsecp256k1 0.6.0]: https://github.com/bitcoin-core/secp256k1/releases/tag/v0.6.0
[news321 invreq]: /fr/newsletters/2024/09/20/#ldk-3140
[news321 retry]: /fr/newsletters/2024/09/20/#ldk-3010
[review club 30239]: https://bitcoincore.reviews/30239
[gh instagibbs]: https://github.com/instagibbs
[28.0 integration guide]: /fr/bitcoin-core-28-wallet-integration-guide/
