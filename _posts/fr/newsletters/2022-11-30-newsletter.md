---
title: 'Bitcoin Optech Newsletter #228'
permalink: /fr/newsletters/2022/11/30/
name: 2022-11-30-newsletter-fr
slug: 2022-11-30-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
La lettre d'information de cette semaine décrit une proposition visant à
permettre d'atténuer les attaques par brouillage de LN en utilisant des
jetons de réputation. Sont également inclus les résumés des modifications
apportées aux services et aux logiciels clients, des annonces de nouvelles
versions et de versions candidates, et des descriptions d'ajouts sur les
projets d'infrastructure Bitcoin populaires.

## Nouvelles

- **Proposition de références de réputation pour atténuer les attaques de brouillage LN :**
  Antoine Riard [a posté][riard credentials] sur la liste de diffusion de
  Lightning-Dev une [proposition][riard proposal] pour un nouveau système
  basé sur la réputation pour aider à empêcher les attaquants de bloquer
  temporairement les créneaux de paiement ([HTLC][topic htlc]) ou la valeur,
  empêchant ainsi les utilisateurs honnêtes de pouvoir envoyer des paiements,
  un problème appelé [attaque par brouillage de canal][topic channel jamming attacks].

    Dans le réseau LN actuel, les emprunteurs choisissent un chemin entre leur
    nœud et le nœud récepteur sur plusieurs canaux exploités par des nœuds de
    transfert indépendants. Ils créent un ensemble d'instructions sans confiance
    qui décrivent où chaque nœud de transmission doit relayer le paiement, en
    cryptant ces instructions afin que chaque nœud ne reçoive que les informations
    minimales dont il a besoin pour faire son travail.

    Riard propose que chaque nœud de transmission n'accepte les instructions de
    relais que si elles comprennent un ou plusieurs jetons d'authentification qui
    ont été précédemment émis par ce nœud de transmission. Les justificatifs
    sont protégés par une [signature aveugle][] qui empêche le nœud de transmission de
    déterminer directement par quel nœud il a été émis (empêchant le nœud de
    transmission de connaître l'identité réseau de l'expéditeur). Chaque nœud peut
    émettre des crédits selon sa propre politique, bien que Riard suggère
    plusieurs méthodes de distribution :

    - *paiement initial :* si le nœud d'Alice veut faire transiter des
      paiements par le nœud de Bob, son nœud utilise d'abord LN pour
      acheter un crédit à Bob.

    - *Réussite précédente :* si un paiement qu'Alice a envoyé par le
      biais du nœud de Bob est accepté par le destinataire final, le
      nœud de Bob peut renvoyer un jeton de crédit au nœud d'Alice---ou
      même plus de jetons que ceux utilisés précédemment, ce qui permet
      au nœud d'Alice d'envoyer davantage par le biais du nœud de Bob
      à l'avenir.

    - *Preuves de propriété UTXO ou autres alternatives :* bien que cela
      ne soit pas nécessaire pour la proposition initiale de Riard, certains
      nœuds de transmission peuvent expérimenter l'attribution de jetons de
      crédit à toute personne prouvant qu'elle possède un UTXO Bitcoin,
      peut-être avec des modificateurs qui donnent aux UTXO plus anciens
      ou de plus grande valeur plus de jetons de crédit qu'aux UTXO plus
      récents ou de plus faible valeur. Tout autre critère peut être utilisé,
      chaque nœud de transmission choisissant lui-même comment distribuer
      ses jetons de crédit.

    Clara Shikhelman, dont la propre proposition co-écrite reposant en partie sur
    la réputation locale a été décrite dans la [Newsletter #226][news226 jam],
    a répondu à [ask][shikelman credentials] que si les jetons de crédit étaient
    transférables entre utilisateurs cela pouvait conduire à la création d'un
    marché pour les jetons. Elle a également demandé comment ils fonctionneraient
    avec [les chemins aveugles][topic rv routing] où un nœud dépensier ne connaîtrait
    pas le chemin complet vers le nœud récepteur.

    Riard [a répondu][riard double spend] qu'il serait difficile de redistribuer
    les jetons de créance et de créer un marché pour eux car tout transfert
    nécessiterait de la confiance. Par exemple, si le nœud de Bob émet une nouvelle
    créance à Alice, qui essaie ensuite de vendre la créance à Carol, il n'y a aucun
    moyen sans confiance pour Alice de prouver qu'elle n'essaiera pas d'utiliser le
    jeton elle-même, même après que Carol l'ait payée.

    Pour les chemins aveugles, [il semble][harding paths] que le destinataire puisse
    fournir toutes les informations d'identification nécessaires sous forme cryptée
    sans introduire de vulnérabilité secondaire.

    Des commentaires complémentaires sur la proposition ont étés reçus sur la
    [pull request][bolts #1043] relative.

## Mises à jour et version candidate

*Nouvelles versions et versions candidates pour les principaux projets d'infrastructure Bitcoin.
Veuillez envisager de passer aux nouvelles versions ou d'aider à tester les versions candidates.*

- [LND 0.15.5-beta.rc2][] est une version candidate pour une mise à jour de
  maintenance de LND. Selon les notes de version, elle ne contient que des
  corrections de bogues mineurs.

- [Core Lightning 22.11rc3][] est une version candidate pour la prochaine
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

- [Core Lightning #5727][] commence à déprécier les identifiants numériques
  des requêtes JSON en faveur d'identifiants utilisant le type de fil. La
  [documentation][cln json ids] a été ajoutée pour décrire les avantages
  des fils d'identifiants et la façon de tirer le meilleur parti de leur
  création et de leur interprétation.

- [Eclair #2499][] permet de spécifier un itinéraire aveugle à utiliser lors
  de l'utilisation d'une [offre BOLT12][topic offers] pour demander un paiement.
  L'itinéraire peut comporter un chemin menant au nœud de l'utilisateur et
  des sauts supplémentaires le dépassant. Les sauts qui dépassent le nœud ne
  seront pas utilisés, mais ils rendront plus difficile pour l'expéditeur de
  déterminer à combien de sauts le récepteur se trouve à partir du dernier nœud
  de transmission non aveuglé de l'itinéraire.

- [LND #7122][] ajoute le support à `lncli` pour le traitement des fichiers
  binaires [PSBT][topic psbt]. Le [BIP174][] spécifie que les PSBTs peuvent
  être encodés soit en texte brut Base64 soit en binaire dans un fichier.
  Auparavant, LND supportait déjà l'importation de PSBTs encodés en Base64
  soit en texte brut soit à partir d'un fichier.

- [LDK #1852][] accepte une augmentation du taux de frais proposée par un pair
  du canal même si ce taux n'est pas assez élevé pour garder le canal ouvert
  en toute sécurité pour le moment. Si le nouveau taux de frais n'est
  pas entièrement sûr, sa valeur plus élevée signifie qu'il est plus sûr que
  ce que le noeud avait auparavant, il est donc préférable de l'accepter plutôt
  que d'essayer de fermer le canal dont le taux de frais est inférieur.
  Un futur changement de LDK pourrait fermer les canaux avec des taux de frais
  trop bas, et le travail sur des propositions comme le [relai de paquet][topic package relay]
  pourrait rendre [les sorties ancrées][topic anchor outputs] ou des techniques
  similaires suffisamment adaptables pour éliminer les préoccupations concernant
  les taux de frais actuels.

- [Libsecp256k1 #993][] inclut dans les options de construction par défaut les
  modules pour des clés supplémentaires (fonctions pour travailler avec des clés
  publiques x-only), [ECDH][], et des [signatures de schnorr][topic schnorr signatures].
  Le module de reconstruction d'une clé publique à partir d'une signature n'est
  toujours pas construit par défaut "car nous ne recommandons pas la récupération
  ECDSA pour les nouveaux protocoles. En particulier, l'API de récupération est
  susceptible d'être mal utilisée : Elle invite l'appelant à oublier de vérifier
  la clé publique (et la fonction de vérification renvoie toujours 1)."

{% include references.md %}
{% include linkers/issues.md v=2 issues="5727,2499,7122,1852,993,1043" %}
[bitcoin core 24.0]: https://bitcoincore.org/bin/bitcoin-core-24.0/
[bcc 24.0 rn]: https://github.com/bitcoin/bitcoin/blob/0ee1cfe94a1b735edc2581a05c4b12f8340ff609/doc/release-notes.md
[news222 rbf]: /fr/newsletters/2022/10/19/#option-de-remplacement-de-transaction
[news223 rbf]: /fr/newsletters/2022/10/26/#poursuite-de-la-discussion-sur-le-full-rbf
[news224 rbf]: /fr/newsletters/2022/11/02/#coherence-mempool
[lnd 0.15.5-beta.rc2]: https://github.com/lightningnetwork/lnd/releases/tag/v0.15.5-beta.rc2
[core lightning 22.11rc3]: https://github.com/ElementsProject/lightning/releases/tag/v22.11rc3
[cln json ids]: https://github.com/rustyrussell/lightning/blob/a25c5d14fe986b67178988e6ebb79610672cc829/doc/lightningd-rpc.7.md#json-ids
[riard credentials]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-November/003754.html
[riard proposal]: https://github.com/lightning/bolts/blob/80214c83190836c4f7699af9e8920769607f1a00/www-reputation-credentials-protocol.md
[signature aveugle]: https://en.wikipedia.org/wiki/Blind_signature
[news226 jam]: /fr/newsletters/2022/11/16/#document-sur-les-attaques-par-brouillage-de-canaux
[shikelman credentials]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-November/003755.html
[riard double spend]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-November/003765.html
[harding paths]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-November/003767.html
[ecdh]: https://en.wikipedia.org/wiki/Elliptic-curve_Diffie%E2%80%93Hellman
[versionnement sémantique]: https://semver.org/spec/v2.0.0.html
