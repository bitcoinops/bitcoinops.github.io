---
title: 'Bulletin Hebdomadaire Bitcoin Optech #286'
permalink: /fr/newsletters/2024/01/24/
name: 2024-01-24-newsletter-fr
slug: 2024-01-24-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---

Le bulletin de cette semaine annonce une défaillance de consensus corrigée dans les anciennes versions de btcd, décrit les changements
proposés à LN pour le relais de transaction v3 et les ancres éphémères, et annonce un nouveau référentiel pour les spécifications liées
à Bitcoin. Sont également incluses nos sections régulières avec des annonces de mises à jour et versions candidates, ainsi que les
changements apportés aux principaux logiciels d'infrastructure Bitcoin.

## Nouvelles

- **Divulgation de la défaillance de consensus corrigée dans btcd :** Niklas Gögge a utilisé Delving Bitcoin pour [annoncer][gogge btcd]
  une défaillance de consensus dans les anciennes versions de btcd qu'il avait précédemment [divulguée de manière responsable][topic
  responsible disclosures]. Les [verrous temporels][topic timelocks] relatifs ont été [ajoutés à Bitcoin][topic soft fork activation]
  lors d'une mise à jour logicielle en ajoutant une signification imposée par consensus aux numéros de séquence des entrées de
  transaction. Afin de garantir que toutes les transactions pré-signées créées avant la mise à jour ne deviennent pas invalides,
  les verrous temporels relatifs s'appliquent uniquement aux transactions avec des numéros de version supérieurs ou égaux à 2, permettant
  aux transactions avec la version par défaut originale (version 1) de rester valides avec n'importe quelles entrées. Cependant, dans le
  logiciel Bitcoin original, les numéros de version sont des entiers signés, ce qui signifie que des versions négatives sont possibles.
  La section _implémentation de référence_ de [BIP68][] note que "les versions 2 et supérieures" doivent s'appliquer au numéro de version
  [converti][] d'un entier signé en un entier non signé, garantissant que les règles s'appliquent à toute transaction qui n'est pas de
  version 0 ou 1.

  Gögge a découvert que btcd n'implémentait pas cette conversion d'entiers signés en entiers non signés, il était donc possible de
  construire une transaction avec un numéro de version négatif que Bitcoin Core exigerait de suivre les règles de BIP68 mais pas btcd.
  Dans ce cas, un nœud pourrait rejeter la transaction (et tout bloc qui la contient) et l'autre nœud pourrait l'accepter (et son
  bloc), ce qui entraînerait une division de la chaîne. Un attaquant pourrait utiliser cela pour tromper l'opérateur d'un nœud btcd
  (ou un logiciel connecté à un nœud btcd) en acceptant des bitcoins invalides.

  Le bogue a été divulgué en privé aux mainteneurs de btcd qui l'ont corrigé dans la récente version 0.24.0. Il est fortement
  recommandé à tous ceux qui utilisent btcd pour l'application du consensus de procéder à la mise à niveau. De plus, Chris Stewart a
  [répondu][stewart bitcoin-s] au fil de discussion de Delving Bitcoin avec un correctif pour la même défaillance dans la bibliothèque
  bitcoin-s. Les auteurs de tout code pouvant être utilisé pour valider les verrous temporels relatifs de BIP68 sont invités à vérifier
  le code pour la même faille.

- **Changements proposés à LN pour le relais v3 et les ancres éphémères :** Bastien Teinturier a [publié][teinturier v3] sur Delving
  Bitcoin pour décrire les changements qu'il estime devoir être apportés à la spécification LN afin de tirer parti efficacement du
  [relais de transaction v3][topic v3 transaction relay] et des [ancres éphémères][topic ephemeral anchors]. Les changements semblent
  simples :

  - *Échange d'ancre :* les deux [sorties d'ancre][topic anchor outputs] actuelles de la transaction d'engagement utilisées pour garantir
    la capacité de [modification des frais CPFP][topic cpfp] en vertu de la politique de [dérogation CPFP][topic cpfp carve out] sont
    supprimées et une ancre éphémère est ajoutée à leur place.

  - *Réduction des retards :* les retards supplémentaires de 1-bloc sur la transaction d'engagement sont supprimés. Ils ont été ajoutés
    pour garantir que la dérogation CPFP fonctionnerait toujours, mais ne sont pas nécessaires dans le cadre de la politique de relais v3.

  - *Réduction de la redirection :* au lieu de dépenser la valeur de tous les [HTLC réduits][topic trimmed htlc] en frais dans la
    transaction d'engagement, la valeur combinée est ajoutée à la valeur de la sortie d'ancre, garantissant que les frais supplémentaires
    sont utilisés pour garantir la confirmation à la fois de l'engagement et de l'ancre éphémère (voir [le bulletin de la semaine
    dernière][news285 mev] pour plus de détails).

  - *Autres changements :* quelques autres changements mineurs et simplifications sont effectués.

  La discussion ultérieure a examiné plusieurs conséquences intéressantes des changements proposés, notamment :

  - *Réduction des exigences UTXO :* garantir que l'état correct du canal est enregistré on-chain devient plus facile grâce à la
    suppression du retard supplémentaire de 1-bloc. Si une partie défectueuse diffuse une transaction d'engagement révoquée, l'autre
    partie peut utiliser sa sortie principale de cet engagement pour augmenter les frais CPFP de cette transaction révoquée. Ils n'ont
    pas besoin de conserver un UTXO confirmé séparé à cette fin. Pour que cela soit sûr, la partie doit conserver un solde de réserve
    suffisant, car le minimum de 1 % spécifié dans [BOLT2][] peut ne pas suffire à couvrir les frais. Pour un nœud non transmetteur qui
    conserve une réserve suffisante, le seul moment où il a besoin d'un UTXO séparé pour des raisons de sécurité est lorsqu'il souhaite
    accepter un paiement entrant.

  - *Logique imbriquée v3 :* En réponse aux préoccupations exprimées lors de la réunion de spécification LN selon lesquelles il pourrait
    prendre beaucoup de temps à LN pour concevoir, mettre en œuvre et déployer ces changements, Gregory Sanders [a proposé][sanders
    transition] une étape intermédiaire avec un traitement spécial temporaire des transactions qui ressemblent aux transactions
    d'engagement LN actuelles de style ancre, permettant à Bitcoin Core de déployer le pool de mémoire en cluster sans être bloqué par
    le développement de LN. Lorsqu'ils auront été largement déployés et que toutes les implémentations LN auront été mises à niveau pour
    utiliser la v3, les règles spéciales temporaires pourront être abandonnées.

  - *Demande de taille maximale de l'enfant :* la proposition d'essai pour le relais v3 fixe la taille d'un enfant de transaction non
    confirmée à 1 000 vbytes. Plus cette taille est grande, plus un utilisateur honnête devra payer pour surmonter un [épinglage de
    transaction][topic transaction pinning] (voir le [Bulletin #283][news283 v3pin]). Plus la taille est petite, moins d'entrées un
    utilisateur honnête peut utiliser pour contribuer aux frais.

- **Nouveau référentiel de documentation :** Anthony Towns [a publié][towns binana] sur la liste de diffusion Bitcoin-Dev pour annoncer
  un nouveau référentiel de spécifications de protocole, _Bitcoin Inquisition Numbers And Names Authority_ ([BINANA][binana repo]).
  Quatre spécifications sont disponibles dans le référentiel au moment de la rédaction :

  - [BIN24-1][] `OP_CAT` par Ethan Heilman et Armin Sabouri. Voir la description de leur proposition de soft fork dans le
    [Bulletin #274][news274 cat].

  - [BIN24-2][] Déploiements hérétiques par Anthony Towns, décrivant l'utilisation de [Bitcoin Inquisition][bitcoin inquisition repo]
    pour les propositions de soft forks et autres modifications sur le [signet][topic signet] par défaut. Voir la description détaillée
    dans le [Bulletin #232][news232 inqui].

  - [BIN24-3][] `OP_CHECKSIGFROMSTACK` par Brandon Black, spécifiant cette [idée longtemps proposée][topic OP_CHECKSIGFROMSTACK].
    Voir la proposition de Black dans [le bulletin de la semaine dernière][news285 lnhance] pour inclure cet opcode dans le bundle
    de soft fork LNHANCE.

  - [BIN24-4][] `OP_INTERNALKEY` par Brandon Black, spécifiant un opcode pour récupérer la clé interne du taproot à partir de
    l'interpréteur de script. Cela a également été décrit dans le bulletin de la semaine dernière comme faisant partie du bundle de
    soft fork LNHANCE.

Bitcoin Optech a ajouté le référentiel BINANA à la liste des sources de documentation que nous surveillons pour les mises à jour, ce
qui inclut également les BIP, BOLT et BLIP. Les futures mises à jour peuvent être trouvées dans la section des "principaux changements
de code et de documentation".

## Modifications apportées aux services et aux logiciels clients

*Dans cette rubrique mensuelle, nous mettons en évidence les mises à jour
intéressantes des portefeuilles et services Bitcoin.*

- **Envoy 1.5 publié :**
  [Envoy 1.5][] ajoute la prise en charge de l'envoi et de la réception de [taproot][topic taproot] et modifie la manière dont les
  [sorties non rentables][topic uneconomical outputs] sont gérées, en plus des corrections de bugs et [autres mises à jour][envoy blog].

- **Liana v4.0 publié :**
  [Liana v4.0][] a été [publié][liana blog] et inclut la prise en charge de [l'augmentation des frais RBF][topic rbf], l'annulation de
  transaction en utilisant RBF, la [sélection automatique des pièces][topic coin selection] et la vérification de l'adresse du dispositif
  matériel de signature.

- **Mercury Layer annoncé :**
  [Mercury Layer][] est une [implémentation][mercury layer github] de [statechains][topic statechains] qui utilise une
  [variation][mercury blind musig] du protocole [MuSig2][topic musig] pour réaliser une signature aveugle par l'opérateur de statechain.

- **AQUA wallet annoncé :**
  [AQUA wallet][] est un portefeuille mobile [open source][aqua github] qui prend en charge Bitcoin, Lightning et la
  [sidechain][topic sidechains] Liquid.

- **Samourai Wallet annonce la fonctionnalité d'échange atomique :**
  La fonctionnalité d'échange atomique [cross-chain atomic swap][samourai gitlab swap], basée sur des [recherches précédentes][samourai
  gitlab comit], permet des échanges de pièces pair à pair entre les chaînes Bitcoin et Monero.

## Mises à jour et versions candidates

*Nouvelles versions et versions candidates pour les principaux projets
d'infrastructure Bitcoin. Veuillez envisager de passer aux nouvelles
versions ou d'aider à tester les versions candidates.*

- [LDK 0.0.120][] est une version de sécurité de cette bibliothèque pour la construction d'applications compatibles LN. Elle "corrige
  une vulnérabilité de déni de service"qui est accessible à partir d'une entrée non fiable provenant de pairs si l'option
  `UserConfig::manually_accept_inbound_channels` est activée."
  Plusieurs autres corrections de bugs et améliorations mineures sont également incluses.

- [HWI 2.4.0-rc1][] est une version candidate pour la prochaine version de ce
  package fournissant une interface commune à plusieurs périphériques de
  signature matérielle différents.

## Changements notables dans le code et la documentation

*Changements notables cette semaine dans [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Interface de Portefeuille
Matériel (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [Serveur BTCPay][btcpay server repo], [BDK][bdk repo], [Propositions
d'Amélioration Bitcoin (BIPs)][bips repo], [Lightning BOLTs][bolts repo], et
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [Bitcoin Core #29239][] met à jour le RPC `addnode` pour se connecter en utilisant le
  [protocole de transport v2][topic v2 p2p transport] lorsque le paramètre de configuration
  `-v2transport` est activé.

- [Eclair #2810][] permet aux informations chiffrées en oignon pour
  [chemin de routage en trampoline][topic trampoline payments] d'utiliser plus de 400
  octets, la taille maximale étant maintenant de 1 300 octets, selon
  [BOLT4][]. Le routage en trampoline qui nécessite moins de 400 octets est
  complété à 400 octets.

- [LDK #2791][], [#2801][ldk #2801], et [#2812][ldk #2812] complètent
  l'ajout de la prise en charge du [masquage de route][topic rv routing] et commencent
  à annoncer le bit de fonctionnalité correspondant.

- [Rust Bitcoin #2230][] ajoute une fonction pour calculer la _valeur effective_
  d'une entrée, qui est sa valeur moins le coût pour la dépenser.

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 15:00" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="29239,2810,2791,2801,2812,2230" %}
[teinturier v3]: https://delvingbitcoin.org/t/lightning-transactions-with-v3-and-ephemeral-anchors/418/
[towns binana]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2024-January/022289.html
[sanders transition]: https://delvingbitcoin.org/t/lightning-transactions-with-v3-and-ephemeral-anchors/418/2
[news283 v3pin]: /fr/newsletters/2024/01/03/#couts-d-epinglage-des-transactions-v3
[news274 cat]: /fr/newsletters/2023/10/25/#proposition-de-bip-pour-op-cat
[news232 inqui]: /fr/newsletters/2023/01/04/#bitcoin-inquisition
[news285 mev]: /fr/newsletters/2024/01/17/#discussion-sur-la-valeur-extractible-par-les-mineurs-mev-dans-les-ancres-ephemeres-non-nulles
[news285 lnhance]: /fr/newsletters/2024/01/17/#nouvelle-proposition-de-soft-fork-combinant-lnhance
[stewart bitcoin-s]: https://delvingbitcoin.org/t/disclosure-btcd-consensus-bugs-due-to-usage-of-signed-transaction-version/455/2
[gogge btcd]: https://delvingbitcoin.org/t/disclosure-btcd-consensus-bugs-due-to-usage-of-signed-transaction-version/455
[hwi 2.4.0-rc1]: https://github.com/bitcoin-core/HWI/releases/tag/2.4.0-rc.1
[ldk 0.0.120]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.0.120
[converti]: https://fr.wikipedia.org/wiki/Conversion_de_type#Conversion_explicite_de_type
[Envoy 1.5]: https://github.com/Foundation-Devices/envoy/releases/tag/v1.5.1
[envoy blog]: https://foundationdevices.com/2024/01/envoy-version-1-5-1-is-now-live/
[Liana v4.0]: https://github.com/wizardsardine/liana/releases/tag/v4.0
[liana blog]: https://www.wizardsardine.com/blog/liana-4.0-release/
[Mercury Layer]: https://mercurylayer.com/
[mercury blind musig]: https://github.com/commerceblock/mercurylayer/blob/dev/docs/blind_musig.md
[mercury layer github]: https://github.com/commerceblock/mercurylayer/tree/dev/docs
[AQUA Wallet]: https://aquawallet.io/
[aqua github]: https://github.com/AquaWallet/aqua-wallet
[samourai gitlab swap]: https://code.samourai.io/wallet/comit-swaps-java/-/blob/master/docs/SWAPS.md
[samourai gitlab comit]: https://code.samourai.io/wallet/comit-swaps-java/-/blob/master/docs/files/Atomic_Swaps_between_Bitcoin_and_Monero-COMIT.pdf
