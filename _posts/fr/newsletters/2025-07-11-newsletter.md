---
title: 'Bulletin Hebdomadaire Bitcoin Optech #362'
permalink: /fr/newsletters/2025/07/11/
name: 2025-07-11-newsletter-fr
slug: 2025-07-11-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
La newsletter de cette semaine décrit brièvement une nouvelle bibliothèque permettant de compresser
les descripteurs de script de sortie pour une utilisation dans les codes QR. Sont également incluses
nos sections régulières résumant une
réunion du Bitcoin Core PR Review Club, annonçant des mises à jour et des versions candidates,
et décrivant les changements notables dans les projets d'infrastructure Bitcoin populaires.

## Nouvelles

- **Descripteurs compressés :** Josh Doman a [publié][dorman descom] sur Delving Bitcoin pour
  annoncer une [bibliothèque][descriptor-codec] qu'il a écrite qui encode les [descripteurs de script
  de sortie][topic descriptors] dans un format binaire qui réduit leur taille d'environ 40%. Cela peut
  être particulièrement utile lorsque les descripteurs sont sauvegardés à l'aide de codes QR. Son post
  entre dans les détails de l'encodage et mentionne qu'il prévoit d'incorporer la compression dans sa
  bibliothèque de sauvegarde de descripteurs chiffrés (voir le [Bulletin #358][news358 descencrypt]).

## Bitcoin Core PR Review Club

*Dans cette section mensuelle, nous résumons une récente réunion du [Bitcoin Core PR Review Club][],
mettant en lumière certaines des questions importantes et des réponses. Cliquez
sur une question ci-dessous pour voir un résumé de la réponse donnée lors de la réunion.*

[Améliorer les limites de déni de service de TxOrphanage][review club 31829] est un PR par
[glozow][gh glozow] qui change la logique d'éviction de `TxOrphanage` pour garantir à chaque pair
les ressources pour au moins 1 paquet de taille maximale pour la résolution d'orphelins. Ces
nouvelles garanties améliorent significativement le relai de paquets opportunistes
1-parent-1-enfant [1p1c relay], surtout (mais pas seulement) dans des conditions adverses.

Le PR modifie les limites globales existantes de l'orphelinat et introduit de nouvelles limites par
pair. Ensemble, elles protègent contre une utilisation excessive de la mémoire et l'épuisement
computationnel. Le PR remplace également l'approche d'éviction aléatoire par une algorithmique,
calculant un score de DoS par pair.

_Note : le PR a subi [quelques changements significatifs][review club 31829 changes] depuis le
Review Club, le plus important étant l'utilisation d'une limite de score de latence au lieu d'une
limite d'annonce._

{% include functions/details-list.md
  q0="Pourquoi la limite actuelle de taille maximale globale de TxOrphanage de 100 transactions avec
  éviction aléatoire est-elle problématique ?"
  a0="Elle permet à un pair malveillant de submerger un nœud avec des transactions orphelines,
  finissant par causer l'éviction de toutes les transactions légitimes d'autres pairs. Cela peut être
  utilisé pour empêcher la réussite du relais de transactions opportunistes 1-parent-1-enfant, puisque
  l'enfant ne pourrait pas rester longtemps dans l'orphelinat."
  a0link="https://bitcoincore.reviews/31829#l-12"
  q1="Comment fonctionne le nouvel algorithme d'éviction à un haut niveau ?"
  a1="L'éviction n'est plus aléatoire. L'algorithme identifie le pair se comportant le « pire » basé
  sur un « score de DoS » et évince l'annonce de transaction la plus ancienne de ce pair. Cela protège
  les pairs se comportant bien de voir les enfants de leurs transactions évictés par un pair se comportant
  mal."
  a1link="https://bitcoincore.reviews/31829#l-19"
  q2="Pourquoi est-il souhaitable de permettre aux pairs de dépasser leurs limites individuelles ?"
  a2="Les pairs peuvent utiliser plus de
  ressources simplement parce qu'ils sont un
  pair utile, qui diffuse des transactions utiles telles que les CPFPs."
  a2link="https://bitcoincore.reviews/31829#l-25"
  q3="Le nouvel algorithme évince les annonces au lieu des transactions.
  Quelle est la différence et pourquoi est-ce important ?"
  a3="Une annonce est une paire composée d'une transaction et du pair qui l'a
  envoyée. En évinçant les annonces, un pair malveillant ne peut pas évincer une
  transaction qui a également été envoyée par un pair honnête."
  a3link="https://bitcoincore.reviews/31829#l-34"
  q4="Qu'est-ce que le “DoS Score” d'un pair et comment est-il calculé ?"
  a4="Le DoS score d'un pair est le maximum entre son “score de mémoire” (mémoire
  utilisée / mémoire réservée) et son “score CPU” (annonces faites /
  limite d'annonces). Utiliser un score combiné unique simplifie la logique d'éviction
  en une seule boucle qui cible le pair dépassant le plus agressivement l'une ou l'autre de ses
  limites."
  a4link="https://bitcoincore.reviews/31829#l-133"
%}

## Mises à jour et versions candidates

_Nouvelles versions et versions candidates pour des projets d'infrastructure Bitcoin populaires.
Veuillez envisager de mettre à niveau vers les nouvelles versions ou d'aider à tester les versions candidates._

- [LND v0.19.2-beta.rc2][] est un candidat à la sortie pour une version de maintenance de ce nœud LN
  populaire.

## Changements notables dans le code et la documentation

_Changements récents notables dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning
repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Interface de Portefeuille Matériel (HWI)][hwi
repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Propositions d'Amélioration de Bitcoin (BIPs)][bips
repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Inquisition Bitcoin][bitcoin inquisition repo], et [BINANAs][binana
repo]._

- [Core Lightning #8377][] renforce les exigences de parsing des factures [BOLT11][] en mandatant
  que les expéditeurs ne paient pas une facture si un [secret de paiement][topic payment secrets] est
  manquant ou si un champ obligatoire tel que p (hash de paiement), h (hash de description), ou s
  (secret), a une longueur incorrecte. Ces changements sont faits pour s'aligner sur les mises à jour
  récentes de la spécification (voir les Bulletins [#350][news350 bolts] et [#358][news358 bolts]).

- [BDK #1957][] introduit le regroupement RPC pour l'historique des transactions, les preuves de
  Merkle, et les demandes d'en-tête de bloc pour optimiser la performance de scan complet et de
  synchronisation avec un backend Electrum. Ce PR ajoute également la mise en cache des ancres pour
  sauter la revalidation de la Vérification Simple de Paiement (SPV) (voir le Bulletin [#312][news312
  spv]) pendant une synchronisation. En utilisant des données d'exemple, l'auteur a observé des
  améliorations de performance de 8,14 secondes à 2,59 secondes avec le regroupement d'appels RPC sur
  un scan complet et de 1,37 secondes à 0,85 secondes avec la mise en cache pendant une
  synchronisation.

- [BIPs #1888][] retire `H` comme marqueur de chemin renforcé de [BIP380][], ne laissant que le `h`
  canonique et l'alternative `'`. Le récent Bulletin [#360][news360 bip380] avait noté que la grammaire
  avait été clarifiée pour permettre les trois marqueurs, mais puisque peu (voire aucun) des implémentations de
  descripteur ne le supportent réellement (ni Bitcoin Core ni rust-miniscript ne le font), la spécification
  est resserrée pour l'interdire.

{% include snippets/recap-ad.md when="2025-07-15 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="8377,1957,1888" %}
[LND v0.19.2-beta.rc2]: https://github.com/lightningnetwork/lnd/releases/tag/v0.19.2-beta.rc2
[news358 descencrypt]: /fr/newsletters/2025/06/13/#bibliotheque-de-chiffrement-de-descripteur
[dorman descom]: https://delvingbitcoin.org/t/a-rust-library-to-encode-descriptors-with-a-30-40-size-reduction/1804
[descriptor-codec]: https://github.com/joshdoman/descriptor-codec
[news350 bolts]: /fr/newsletters/2025/04/18/#bolts-1242
[news358 bolts]: /fr/newsletters/2025/06/13/#bolts-1243
[news312 spv]: /fr/newsletters/2024/07/19/#bdk-1489
[news360 bip380]: /fr/newsletters/2025/06/27/#bips-1803
[review club 31829]: https://bitcoincore.reviews/31829
[gh glozow]: https://github.com/glozow
[review club 31829 changes]: https://github.com/bitcoin/bitcoin/pull/31829#issuecomment-3046495307
[1p1c relay]: /en/bitcoin-core-28-wallet-integration-guide/#one-parent-one-child-1p1c-relay
