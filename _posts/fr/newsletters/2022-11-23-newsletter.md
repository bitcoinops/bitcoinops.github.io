---
title: 'Bulletin Hebdomadaire Bitcoin Optech #227'
permalink: /fr/newsletters/2022/11/23/
name: 2022-11-23-newsletter-fr
slug: 2022-11-23-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
La lettre d'information de cette semaine contient une sélection de questions
et réponses du Bitcoin Stack Exchange, sont également inclus les résumés des
modifications apportées aux services et aux logiciels clients, des annonces
de nouvelles versions et de versions candidates, et des descriptions d'ajout
sur les projets d'infrastructure Bitcoin populaires.

## Nouvelles

*Pas de nouvelles particulières cette semaine sur les listes de diffusions
Bitcoin-Dev ou Lightning-Dev.*

## Selection de Q&R du Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] est l'un des premiers endroits où les
collaborateurs d'Optech cherchent des réponses à leurs questions---ou lorsqu'ils
ont quelques moments libres, aident les utilisateurs curieux ou perdus.
Dans cette rubrique mensuelle, nous mettons en évidence certaines des questions
et réponses les plus populaires depuis notre dernière mise à jour.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Est-ce que le P2SH BIP-0016 rend certains bitcoins non utilisables ?]({{bse}}115803)
  L'utilisateur bca-0353f40e liste 6 sorties qui existaient avec le format de script P2SH,
  `OP_HASH160 OP_DATA_20 [hash_value] OP_EQUAL`, avant l'activation du [BIP16][].
  Une de ces sorties avait été dépensée selon les anciennes règles avant l'activation
  et une [exception faite][p2sh activation exception] pour ce seul bloc dans le code
  d'activation P2SH. En dehors de cette exception, l'activation s'applique depuis le bloc de
  genèse, de sorte que tous les autres UTXOs doivent satisfaire aux règles du BIP16 pour
  pouvoir être dépensés.

- [Quel logiciel a été utilisé pour faire les transactions P2PK ?]({{bse}}115962)
  Pieter Wuille note que les sorties P2PK ont été créées à l'aide du logiciel
  Bitcoin original dans les transactions coinbase ainsi que lors de l'envoi à
  l'aide de [l'adresse IP de paiement][wiki p2ip].

- [Pourquoi le txid et le wtxid sont-ils tous deux envoyés aux pairs ?]({{bse}}115907)
  Pieter Wuille fait référence au [BIP339][] et explique que si l'utilisation du wtxid
  est préférable pour le relais (en raison de la malléabilité, entre autres), certains
  pairs ne prennent pas en charge les nouveaux identifiants wtxid et les txids sont pris
  en charge pour les anciens pairs pré-BIP339 pour des raisons de rétrocompatibilité.

- [Comment puis-je créer une adresse taproot multisig ?]({{bse}}115700)
  Pieter Wuille souligne que les RPC [multisig][topic multisignature] existants de
  Bitcoin Core (comme `createmultisig` et `addmultisigaddress`) ne supporteront que les
  anciens portefeuilles et souligne qu'avec Bitcoin Core 24.0, les utilisateurs pourront
  utiliser les [descripteurs][topic descriptors] et des RPC (comme `deriveaddresses` et
  `importdescriptors`) avec le nouveau descripteur `multi_a` pour créer des scripts
  multisig compatibles avec [taproot][topic taproot].

- [Est-il possible de sauter le téléchargement du bloc initial (IBD) sur un nœud élagué ?]({{bse}}116030)
  Bien qu'il ne soit pas encore integré dans Bitcoin Core, Pieter Wuille signale
  le projet [assumeutxo][topic assumeutxo] qui permettrait à un nouveau nœud de s'amorcer
  en récupérant un ensemble UTXO qui peut être vérifié par un hachage codé en dur.

## Mises à jour et version candidate

*Nouvelles versions et versions candidates pour les principaux projets d'infrastructure Bitcoin.
Veuillez envisager de passer aux nouvelles versions ou d'aider à tester les versions candidates.*

- [LND 0.15.5-beta.rc2][] est une version candidate pour une mise à jour de
  maintenance de LND. Elle ne contient que des corrections de bogues mineurs
  selon ses notes de version prévues.

- [Core Lightning 22.11rc2][] est une version candidate pour la prochaine
  version majeure de CLN. Ce sera également la première version à utiliser
  un nouveau système de numérotation des versions, bien que les versions
  CLN continuent à utiliser le [versionnement sémantique][].

## Changements principaux dans le code et la documentation

*Changements notables cette semaine dans [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], et [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #25730][] met à jour le RPC `listunspent` avec un nouvel
  argument qui inclura dans les résultats toutes les sorties coinbase
  immatures---les sorties qui ne peuvent pas encore être dépensées parce
  que moins de 100 blocs se sont écoulés depuis leur inclusion
  dans la transaction coinbase du mineur d'un bloc.

- [LND #7082][] met à jour la manière dont les factures sans montant demandé
  sont créées afin de permettre l'inclusion d'indications d'itinéraire, qui
  peuvent aider l'émetteur qui effectue la dépense à trouver un chemin vers
  le destinataire.

- [LDK #1413][] supprime la prise en charge du format original de données
  en oignon à longueur fixe. Le format amélioré à longueur variable a été
  ajouté à la spécification il y a plus de trois ans et la prise en charge
  de l'ancienne version a déjà été supprimée de la spécification. (voir les
  [Newsletter #220][news220 bolts962]), Core Lightning ([Newsletter #193][news193
  cln5058]), LND ([Newsletter #196][news196 lnd6385]), et Eclair
  ([Newsletter #217][news217 eclair2190]).

- [HWI #637][] ajoute la prise en charge d'une mise à jour majeure prévue du
  micrologiciel lié à Bitcoin pour les dispositifs Ledger. Le travail de politique
  de gestion mentionné dans le document intitulé " Policy Management " n'est
  pas inclus dans ce PR, mais est mentionné dans sa description en tant que
  travail futur prévu dans la [Newsletter #200][news200 policy].

{% include references.md %}
{% include linkers/issues.md v=2 issues="25730,7082,1413,637" %}
[bitcoin core 24.0]: https://bitcoincore.org/bin/bitcoin-core-24.0/
[bcc 24.0 rn]: https://github.com/bitcoin/bitcoin/blob/0ee1cfe94a1b735edc2581a05c4b12f8340ff609/doc/release-notes.md
[news222 rbf]: /fr/newsletters/2022/10/19/#option-de-remplacement-de-transaction
[news223 rbf]: /fr/newsletters/2022/10/26/#poursuite-de-la-discussion-sur-le-full-rbf
[news224 rbf]: /fr/newsletters/2022/11/02/#coherence-mempool
[lnd 0.15.5-beta.rc2]: https://github.com/lightningnetwork/lnd/releases/tag/v0.15.5-beta.rc2
[core lightning 22.11rc2]: https://github.com/ElementsProject/lightning/releases/tag/v22.11rc2
[news220 bolts962]: /fr/newsletters/2022/10/05/#bolts-962
[news217 eclair2190]: /fr/newsletters/2022/09/14/#eclair-2190
[news193 cln5058]: /en/newsletters/2022/03/30/#c-lightning-5058
[news196 lnd6385]: /en/newsletters/2022/04/20/#lnd-6385
[news200 policy]: /en/newsletters/2022/05/18/#adapting-miniscript-and-output-script-descriptors-for-hardware-signing-devices
[versionnement sémantique]: https://semver.org/spec/v2.0.0.html
[wiki p2ip]: https://en.bitcoin.it/wiki/IP_transaction
[p2sh activation exception]: https://github.com/bitcoin/bitcoin/commit/ce650182f4d9847423202789856e6e5f499151f8
