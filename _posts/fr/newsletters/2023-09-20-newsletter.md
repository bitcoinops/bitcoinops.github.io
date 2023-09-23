---
title: 'Bulletin Hebdomadaire Bitcoin Optech #269'
permalink: /fr/newsletters/2023/09/20/
name: 2023-09-20-newsletter-fr
slug: 2023-09-20-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine partage l'annonce d'un prochain événement autour de la recherche et inclut nos sections régulières
décrivant les mises à jour des clients et des services, les nouvelles versions et les versions candidates, ainsi que les changements
apportés aux principaux logiciels d'infrastructure Bitcoin.

## Nouvelles

- **Événement journée de recherche sur Bitcoin :** Sergi Delgado Segura et Clara Shikhelman ont [publié][ds brd] sur les listes
  de diffusion Bitcoin-Dev et Lightning-Dev pour annoncer un événement intitulé _Bitcoin Research Day_ qui se tiendra à New York
  le 27 octobre. Il s'agira d'un événement en personne avec des présentations de plusieurs chercheurs bien connus dans le domaine
  de Bitcoin. Les réservations sont nécessaires et quelques créneaux de présentation courts (5 minutes) étaient encore disponibles
  au moment de la publication.

## Modifications apportées aux services et aux logiciels clients

*Dans cette rubrique mensuelle, nous mettons en évidence les mises à jour
intéressantes des portefeuilles et services Bitcoin.*

- **Sortie de Bitcoin-like Script Symbolic Tracer (B'SST) :** [B'SST][] est un outil d'analyse de scripts Bitcoin et Elements qui
  fournit des informations sur les scripts, y compris les "conditions que le script impose, les échecs possibles, les valeurs
  possibles pour les données".

- **Démo du vérificateur de chaîne d'en-têtes STARK :** Le projet [ZeroSync][news222 zerosync] a annoncé une [démonstration][zerosync demo]
  et un [dépôt][zerosync code] utilisant les STARK pour prouver et vérifier une chaîne d'en-têtes de blocs Bitcoin.

- **Sortie de JoinMarket v0.9.10 :** La version [v0.9.10][joinmarket v0.9.10] ajoute la prise en charge de [RBF][topic rbf] pour
  les transactions non-[coinjoin][topic coinjoin] et des mises à jour d'estimation des frais, entre autres améliorations.

- **BitBox ajoute miniscript :** Le [dernier micrologiciel BitBox02][bitbox blog] ajoute la prise en charge de
  [miniscript][topic miniscript] en plus d'une correction de sécurité et d'améliorations de convivialité.

- **Machankura annonce une fonctionnalité de regroupement additive :** Le fournisseur de services Bitcoin [Machankura][] a
  [annoncé][machankura tweet] une fonctionnalité bêta qui prend en charge le regroupement [additif][] en utilisant RBF dans un
  portefeuille [taproot][topic taproot] qui a une condition de dépense FROST [threshold][topic threshold signature].

- **Outil de simulation SimLN Lightning :** [SimLN][] est un outil de simulation pour les chercheurs LN et les développeurs de
  protocoles/applications qui génèrent une activité de paiement LN réaliste. SimLN prend en charge LND et CLN, avec des travaux
  en cours sur Eclair et LDK-Node.

## Mises à jour et versions candidates

*Nouvelles versions et versions candidates pour les principaux projets d’infrastructure
Bitcoin. Veuillez envisager de passer aux nouvelles versions ou d’aider à tester
les versions candidates.*

- [Core Lightning 23.08.1][] est une version de maintenance qui inclut plusieurs corrections de bugs.

- [LND v0.17.0-beta.rc4][] est une version candidate pour la prochaine version majeure de cette implémentation populaire de nœud LN.
  Une nouvelle fonctionnalité expérimentale majeure prévue pour cette version, qui pourrait bénéficier de tests, est la prise en charge
  des "canaux simples taproot".

## Changements notables dans le code et la documentation

*Changements notables cette semaine dans [Bitcoin Core][bitcoin core repo], [CoreLightning][core lightning repo], [Eclair][eclair repo],
[LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Interface Portefeuille Matériel (HWI)][hwi repo],
[Rust Bitcoin][rust bitcoin repo], [Serveur BTCPay][btcpay server repo], [BDK][bdk repo],
[Propositions d'Amélioration Bitcoin (BIPs)][bips repo], [Lightning BOLTs][bolts repo], et
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [Bitcoin Core #26152][] s'appuie sur une interface précédemment ajoutée (voir le [Bulletin #252][news252 bumpfee]) pour payer
  tout _déficit de frais_ dans les entrées sélectionnées pour être incluses dans une transaction. Un déficit de frais se produit
  lorsque le portefeuille doit sélectionner des UTXO avec des ancêtres non confirmés qui paient des frais bas. Afin que la transaction
  de l'utilisateur paie le taux de frais sélectionné par l'utilisateur, la transaction doit payer des frais suffisamment élevés pour
  payer à la fois ses ancêtres non confirmés à faible taux de frais et elle-même. En bref, ce PR garantit qu'un utilisateur qui choisit
  un taux de frais---en définissant une priorité qui affectera la confirmation de la transaction---recevra réellement cette priorité
  même si le portefeuille doit dépenser des UTXO non confirmés. Tous les autres portefeuilles que nous connaissons ne peuvent garantir
  une certaine priorité basée sur le taux de frais que s'ils ne dépensent que des UTXO confirmés. Voir également le
  [Bulletin #229][news229 bumpfee] pour un résumé d'une réunion du Bitcoin Core PR Review Club sur ce PR.

- [Bitcoin Core #28414][] met à jour le RPC `walletprocesspsbt` pour inclure une transaction sérialisée complète (en hexadécimal)
  si l'étape de traitement du portefeuille a abouti à une transaction prête à être diffusée. Cela évite à l'utilisateur d'appeler
  `finalizepsbt` sur un [PSBT][topic psbt] déjà final.

- [Bitcoin Core #28448][] déprécie le paramètre de configuration `rpcserialversion` (version de sérialisation RPC). Cette option a
  été introduite lors de la transition vers le segwit v0 pour permettre aux anciens programmes d'accéder aux blocs et aux transactions
  au format réduit (sans aucun champ segwit). À ce stade, tous les programmes devraient être mis à jour pour gérer les transactions
  segwit et cette option ne devrait plus être nécessaire, bien qu'elle puisse être temporairement réactivée en tant qu'API dépréciée,
  comme décrit dans les notes de version ajoutées par le PR.

- [Bitcoin Core #28196][] ajoute une partie substantielle du code nécessaire pour prendre en charge le [protocole de transport
  v2][topic v2 p2p transport] tel que spécifié dans [BIP324][] ainsi qu'un test de brouillage approfondi du code. Cela n'active aucune
  nouvelle fonctionnalité, mais réduit la quantité de code qui devra être ajoutée pour activer ces fonctionnalités dans les futurs PR.

- [Eclair #2743][] ajoute un RPC `bumpforceclose` qui permettra de demander manuellement au nœud de dépenser la [sortie
  d'ancrage][topic anchor outputs] d'un canal pour [augmenter les frais CPFP][topic cpfp] d'une transaction d'engagement. Les nœuds
  Eclair effectuent automatiquement une augmentation des frais lorsque cela est nécessaire, mais cela permet à un opérateur d'accéder
  manuellement à la même capacité.

- [LDK #2176][] augmente la précision avec laquelle LDK tente de deviner de manière probabiliste la quantité de liquidité disponible
  dans les canaux distants à travers lesquels il a tenté de router des paiements. La précision est descendue jusqu'à 0,01500 BTC dans
  un canal de 1,00000 BTC ; la nouvelle précision descend maintenant à environ 0,00006 BTC dans un canal de même taille. Cela peut
  légèrement augmenter le temps nécessaire pour trouver un chemin pour un paiement, mais les tests indiquent qu'il n'y a pas de
  différence majeure.

- [LDK #2413][] prend en charge l'envoi de paiements vers des [chemins masqués][topic rv routing] et permet de recevoir des paiements
  vers des chemins où un seul saut final est masqué (masqué) par le dépensier.
  [PR #2514][ldk #2514], également fusionné cette semaine, fournit un autre support pour les paiements masqués dans LDK.

- [LDK #2371][] ajoute la prise en charge de la gestion des paiements en utilisant des [offres][topic offers]. Il permet à une
  application cliente utilisant LDK d'utiliser une offre pour enregistrer son intention de payer une facture, en chronométrant la
  tentative de paiement si une offre envoyée ne se traduit jamais par une facture reçue, puis en utilisant le code existant dans LDK
  pour payer la facture (y compris les nouvelles tentatives si les premières échouent).

{% include references.md %}
{% include linkers/issues.md v=2 issues="26152,28414,28448,28196,2743,2176,2413,2514,2371" %}
[LND v0.17.0-beta.rc4]: https://github.com/lightningnetwork/lnd/releases/tag/v0.17.0-beta.rc4
[ds brd]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-September/021959.html
[news252 bumpfee]: /fr/newsletters/2023/05/24/#bitcoin-core-27021
[news229 bumpfee]: /fr/newsletters/2022/12/07/#bitcoin-core-pr-review-club
[Core Lightning 23.08.1]: https://github.com/ElementsProject/lightning/releases/tag/v23.08.1
[B'SST]: https://github.com/dgpv/bsst
[news222 zerosync]: /fr/newsletters/2022/10/19/#lancement-du-projet-zeroSsync
[zerosync demo]: https://zerosync.org/demo/
[zerosync code]: https://github.com/ZeroSync/header_chain
[joinmarket v0.9.10]: https://github.com/JoinMarket-Org/joinmarket-clientserver/releases/tag/v0.9.10
[bitbox blog]: https://bitbox.swiss/blog/bitbox-08-2023-marinelli-update/
[Machankura]: https://8333.mobi/
[machankura tweet]: https://twitter.com/machankura8333/status/1695827506794754104
[batching]: /en/payment-batching/
[SimLN]: https://github.com/bitcoin-dev-project/sim-ln