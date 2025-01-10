---
title: 'Bulletin Hebdomadaire Bitcoin Optech #336'
permalink: /fr/newsletters/2025/01/10/
name: 2025-01-10-newsletter-fr
slug: 2025-01-10-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine décrit un changement potentiel dans Bitcoin Core
affectant les mineurs, résume la discussion sur la création de verrous temporels relatifs au niveau
des contrats, et discute d'une proposition pour une variante de LN-Symmetry
avec des pénalités optionnelles. Sont également incluses nos sections régulières
annoncant des mises à jour et des versions candidates, et résumant les changements notables
dans les principaux logiciels d'infrastructure Bitcoin.

## Nouvelles

- **Enquête sur le comportement des pools de minage avant de corriger un bug de Bitcoin Core :**
  Abubakar Sadiq Ismail a [posté][ismail double] sur Delving Bitcoin à propos
  d'un [bug][bitcoin core #21950] découvert en 2021 par Antoine Riard qui
  résulte en ce que les nœuds réservent 2 000 vbytes dans les modèles de bloc pour les transactions
  coinbase plutôt que les 1 000 vbytes prévus. Chaque modèle
  pourrait inclure environ cinq transactions petites supplémentaires si la
  double réservation était éliminée. Cependant, cela pourrait conduire les mineurs
  qui dépendent de la double réservation à produire des blocs invalides,
  entraînant une grande perte de revenus. Ismail a analysé les blocs passés pour
  déterminer quels pools de minage pourraient être à risque. Il a noté
  que Ocean.xyz, F2Pool et un mineur inconnu semblent utiliser
  des paramètres non par défaut, bien qu'aucun d'entre eux ne semble être à risque
  de perdre de l'argent si le bug est corrigé.

  Cependant, pour minimiser le risque, il est actuellement proposé d'introduire une
  nouvelle option de démarrage qui réserve par défaut 2 000 vbytes pour le
  coinbase. Les mineurs qui n'ont pas besoin de rétrocompatibilité peuvent facilement
  réduire la réservation à 1 000 vbytes (ou moins, s'ils ont besoin de moins).

  Jay Beddict a [relayé][beddict double] le message à la liste de diffusion Mining-Dev.

- **Verrous temporels relatifs au niveau des contrats :** Gregory Sanders
  a [posté][sanders clrt] sur Delving Bitcoin à propos de la recherche d'une solution pour
  une complication qu'il a découverte il y a environ un an (voir le [Bulletin #284][news284 deltas])
  lors de la création d'une implémentation de preuve de concept
  de [LN-Symmetry][topic eltoo]. Dans ce protocole, chaque état de canal
  peut être confirmé onchain, mais seul le dernier état confirmé avant une
  date limite peut distribuer les fonds du canal. Habituellement, les parties d'un
  canal essaieraient de confirmer uniquement le dernier état ; cependant, si
  Alice initie une nouvelle mise à jour de l'état en signant partiellement une transaction
  et en l'envoyant à Bob, seul Bob peut compléter cette transaction. Si Bob
  stagne à ce moment-là, Alice ne peut fermer un canal que dans son
  avant-dernier état. Si Bob attend que l'avant-dernier état d'Alice ait presque atteint sa date
  limite et confirme ensuite le dernier état, cela
  prendra environ deux fois plus de temps que la date limite pour que le canal
  se résolve, ce qu'on appelle le _problème de délai 2x_. Cela signifie
  que les [verrous temporels][topic timelocks] pour les [HTLCs][topic htlc] dans LN-Symmetry
  doivent être jusqu'à deux fois plus longs, ce qui facilite pour les attaquants
  d'empêcher les nœuds de transfert de gagner des revenus sur leur capital (à travers
  [les attaques de blocage de canal][topic channel jamming attacks] et autres.

  Sanders suggère de résoudre le problème avec un verrouillage temporel relatif qui s'appliquerait à
  toutes les transactions nécessaires pour régler un contrat. Si LN-Symmetry disposait d'une telle
  fonctionnalité et qu'Alice confirmait l'avant-dernier état, Bob devrait confirmer le dernier état
  avant la date limite de l'avant-dernier état. Dans un [article ultérieur][sanders tpp], Sanders
  renvoie à un protocole de canal par John Law (voir le [Bulletin #244][news244 tpp]) qui utilise deux
  verrouillages temporels relatifs au niveau de la transaction pour fournir un verrouillage temporel
  relatif au niveau du contrat sans changements de consensus. Cependant, cela ne fonctionne pas pour
  LN-Symmetry qui permet à chaque état de dépenser à partir de n'importe quel état précédent.

  Sanders esquisse une solution, mais note qu'elle a des inconvénients. Il note également comment le
  problème pourrait être résolu en utilisant la fonctionnalité `coinid` de Chia, qui semble être
  similaire à l'idée de John Law en 2021 pour les Identifiants Hérités (IIDs). Jeremy Rubin [a
  répondu][rubin muon] avec un lien vers sa proposition de l'année dernière pour les sorties _muon_
  qui doivent être dépensées dans le même bloc que la transaction qui les a créées, montrant comment
  elles pourraient contribuer à une solution. Sanders mentionne, et Anthony Towns [développe][towns
  coinid] sur, la fonctionnalité `coinid` de la blockchain Chia, montrant comment elle pourrait
  réduire les données requises à une quantité constante. Salvatore Ingala [a posté][ingala cat] sur un
  mécanisme similaire utilisant [OP_CAT][topic op_cat] qu'il a appris du développeur Rijndael, qui
  plus tard [a fourni des détails][rijndael cat]. Brandon Black [a décrit][black penalty] un type
  alternatif de solution---une variante de LN-Symmetry basée sur des pénalités---et a cité le travail
  de Daniel Roberts à ce sujet (voir le prochain article du bulletin).

- **Variante de LN-Symmetry multipartite avec des pénalités pour limiter les publications de mises à jour :**
  Daniel Roberts [a posté][roberts sympen] sur Delving Bitcoin à propos de la prévention d'une
  contrepartie malveillante de canal (Mallory) d'être capable de retarder le règlement du canal en
  diffusant délibérément de vieux états à un taux de frais plus élevé que celui qu'une contrepartie
  honnête (Bob) paie pour la confirmation de l'état final. En théorie, Bob peut relier son état final
  à l'ancien état de Mallory et les deux transactions pourraient se confirmer dans le même bloc,
  lui causant de perdre de l'argent sur les frais et à Bob de confirmer l'état final pour le même
  coût de frais qu'il était déjà prêt à payer. Cependant, si Mallory peut répétitivement empêcher Bob
  d'apprendre sur ses diffusions d'anciens états avant qu'ils ne soient confirmés, elle peut
  l'empêcher de répondre jusqu'à ce que les [HTLCs][topic htlc] dans le canal expirent et Mallory soit
  capable de voler des fonds.

  Roberts a proposé un schéma qui permet à un participant de canal de confirmer seulement un seul
  état. Si un état ultérieur est confirmé, le participant qui a soumis l'état final et tout
  participant qui n'a soumis aucun état peuvent prendre l'argent de tout participant qui a soumis des
  états périmés.

  Malheureusement, après avoir publié le schéma, Roberts a découvert et auto-divulgué un défaut
  critique dans celui-ci : similaire au _problème de retard 2x_ décrit dans le paragraphe
  précédent, le dernier parti à signer peut compléter un état qu'aucun autre parti ne peut compléter,
  donnant au signataire final un accès exclusif à l'état final actuel. Si une autre partie tente de clôturer
  dans l'état précédent, elle perdra de l'argent si le signataire final utilise l'état final.

  Roberts étudie des approches alternatives, mais le sujet a suscité une discussion intéressante sur
  l'utilité ou non d'ajouter un mécanisme de pénalité à LN-Symmetry. Gregory Sanders, dont la mise en
  œuvre antérieure de preuve de concept de LN-Symmetry l'a amené à croire qu'un mécanisme de pénalité
  est inutile (voir le [Bulletin #284][news284 sympen]), a noté que l'attaque par répétition de
  l'ancien état est similaire à une [attaque par remplacement cyclique][topic replacement cycling]. Il
  trouve "cette attaque assez faible, puisque l'attaquant peut être amené à une EV [valeur attendue]
  négative assez facilement" même si le défenseur dispose de ressources modestes et n'a aucune idée
  des transactions que les mineurs tentent de confirmer.

## Mises à jour et versions candidates

_Nouvelles versions et versions candidates pour des projets d'infrastructure Bitcoin populaires.
Veuillez envisager de mettre à niveau vers les nouvelles versions ou d'aider à tester les versions candidates._

- [Bitcoin Core 28.1][] est une version de maintenance de l'implémentation de nœud complet
  prédominante.

- [BDK 0.30.1][] est une version de maintenance pour la série de versions précédente contenant des
  corrections de bugs. Les projets sont encouragés à passer à BDK wallet 1.0.0, comme annoncé dans le
  bulletin de la semaine dernière, pour laquelle un [guide de migration][bdk migration] a été
  fourni.

- [LDK v0.1.0-beta1][] est un candidat à la sortie de cette bibliothèque pour la construction de
  portefeuilles et d'applications activés par LN.

## Changements notables dans le code et la documentation

_Changements récents notables dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core
lightning repo], [Eclair][eclair repo], [LDK][ldk repo], [LND][lnd repo],
[libsecp256k1][libsecp256k1 repo], [Hardware Wallet Interface (HWI)][hwi repo], [Rust Bitcoin][rust
bitcoin repo], [BTCPay Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement Proposals
(BIPs)][bips repo], [Lightning BOLTs][bolts repo], [Lightning BLIPs][blips repo], [Bitcoin
Inquisition][bitcoin inquisition repo], et [BINANAs][binana repo]._

- [Bitcoin Core #28121][] ajoute un nouveau champ `reject-details` à la réponse de la commande RPC
  `testmempoolaccept`, qui est inclus uniquement si la transaction serait rejetée du mempool en raison
  de violations de consensus ou de politique. Le message d'erreur est identique à celui renvoyé par
  `sendrawtransaction` si la transaction y est également rejetée.

- [BDK #1592][] introduit des Architectural Decision Records (ADRs) pour documenter les changements
  significatifs, en décrivant le problème abordé, les moteurs de décision, les alternatives
  considérées, les avantages et les inconvénients, et la décision finale. Cela permet aux nouveaux
  venus de se familiariser avec l'histoire du dépôt. Cette PR ajoute un modèle d'ADR et les deux
  premiers ADRs : l'un pour supprimer le module `persist` de `bdk_chain` et l'autre pour introduire un
  nouveau type `PersistedWallet` qui enveloppe un `BDKWallet`.

{% include snippets/recap-ad.md when="2025-01-14 15:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="28121,1592,21950" %}
[bitcoin core 28.1]: https://bitcoincore.org/bin/bitcoin-core-28.1/
[ldk v0.1.0-beta1]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.1.0-beta1
[bdk migration]: https://bitcoindevkit.github.io/book-of-bdk/getting-started/migrating/
[ismail double]: https://delvingbitcoin.org/t/analyzing-mining-pool-behavior-to-address-bitcoin-cores-double-coinbase-reservation-issue/1351
[beddict double]: https://groups.google.com/g/bitcoinminingdev/c/aM9SDXSMZDs
[sanders clrt]: https://delvingbitcoin.org/t/contract-level-relative-timelocks-or-lets-talk-about-ancestry-proofs-and-singletons/1353/
[news284 deltas]: /fr/newsletters/2024/01/10/#deltas-d-expiration
[sanders tpp]: https://delvingbitcoin.org/t/contract-level-relative-timelocks-or-lets-talk-about-ancestry-proofs-and-singletons/1353/2
[news244 tpp]: /fr/newsletters/2023/03/29/#prevenir-les-pertes-de-capitaux-grace-aux-usines-a-canaux-channel-factories-et-aux-canaux-multipartites
[rubin muon]: https://delvingbitcoin.org/t/contract-level-relative-timelocks-or-lets-talk-about-ancestry-proofs-and-singletons/1353/3
[towns coinid]: https://delvingbitcoin.org/t/contract-level-relative-timelocks-or-lets-talk-about-ancestry-proofs-and-singletons/1353/7
[ingala cat]: https://delvingbitcoin.org/t/contract-level-relative-timelocks-or-lets-talk-about-ancestry-proofs-and-singletons/1353/8
[rijndael cat]: https://delvingbitcoin.org/t/contract-level-relative-timelocks-or-lets-talk-about-ancestry-proofs-and-singletons/1353/11
[black penalty]: https://delvingbitcoin.org/t/contract-level-relative-timelocks-or-lets-talk-about-ancestry-proofs-and-singletons/1353/12
[roberts sympen]: https://delvingbitcoin.org/t/broken-multi-party-eltoo-with-bounded-settlement/1364/
[news284 sympen]: /fr/newsletters/2024/01/10/#penalites
[bdk 0.30.1]: https://github.com/bitcoindevkit/bdk/releases/tag/v0.30.1
