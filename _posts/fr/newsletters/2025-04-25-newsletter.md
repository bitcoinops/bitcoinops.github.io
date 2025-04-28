---
title: 'Bulletin Hebdomadaire Bitcoin Optech #351'
permalink: /fr/newsletters/2025/04/25/
name: 2025-04-25-newsletter-fr
slug: 2025-04-25-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulettin de cette semaine annonce un nouveau protocole de signature agrégée compatible avec
secp256k1 et décrit un schéma de sauvegarde standardisé pour les descripteurs de portefeuille. Sont
également incluses nos sections régulières résumant les récentes questions et réponses de Bitcoin
Stack Exchange, annoncant de nouvelles versions et de candidats à la publication, et les résumés des modifications
notables apportées aux logiciels d'infrastructure Bitcoin populaires.

## Nouvelles

- **Signatures agrégées interactives compatibles avec secp256k1 :** Jonas Nick, Tim Ruffing, Yannick
  Seurin [ont posté][nrs dahlias] sur la liste de diffusion Bitcoin-Dev pour annoncer un
  [article][dahlias paper] qu'ils ont écrit sur la création de signatures agrégées de 64 octets
  compatibles avec les primitives cryptographiques déjà utilisées par Bitcoin. Les signatures agrégées
  sont la condition cryptographique pour l'[agrégation de signatures entre entrées][topic cisa]
  (CISA), une fonctionnalité proposée pour Bitcoin qui pourrait réduire la taille des transactions
  avec plusieurs entrées, ce qui réduirait le coût de nombreux types de dépenses, y compris les
  dépenses améliorant la confidentialité à travers les [coinjoins][topic coinjoin] et [payjoins][topic
  payjoin].

  En plus d'un schéma de signature agrégée comme le schéma DahLIAS proposé par les auteurs, l'ajout du
  support pour CISA à Bitcoin nécessiterait un changement de consensus et des interactions possibles
  entre l'agrégation de signatures et d'autres changements de consensus proposés qui peuvent
  nécessiter une étude plus approfondie.

- **Sauvegarde standardisée pour les descripteurs de portefeuille :** Salvatore Ingala [a
  posté][ingala backdes] sur Delving Bitcoin un résumé des différents compromis liés à la sauvegarde
  des [descripteurs][topic descriptors] de portefeuille et un schéma proposé qui devrait être utile
  pour de nombreux types de portefeuilles, y compris ceux utilisant des scripts complexes. Son schéma
  chiffre les descripteurs en utilisant un secret de 32 octets généré de manière déterministe. Pour
  chaque clé publique (ou clé publique étendue) dans le descripteur, une copie du secret est xorée
  avec une variante de la clé publique, créant _n_ chiffrements secrets de 32 octets pour _n_ clés
  publiques. Quiconque connaît l'une des clés publiques utilisées dans le descripteur peut la xor avec
  le chiffrement secret de 32 octets pour obtenir le secret de 32 octets qui peut déchiffrer le
  descripteur. Ce schéma simple et efficace permet à quiconque de stocker de nombreuses copies
  chiffrées d'un descripteur sur plusieurs supports et emplacements réseau, puis d'utiliser leur
  [graine de portefeuille BIP32][topic bip32] pour générer leur xpub, qu'ils peuvent utiliser pour
  déchiffrer le descripteur s'ils perdent jamais leurs données de portefeuille.

## Questions et réponses sélectionnées du Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] est l'un des premiers endroits où les contributeurs d'Optech
cherchent des réponses à leurs questions - ou quand nous avons quelques moments libres pour aider
les utilisateurs curieux ou confus. Dans cette rubrique mensuelle, nous mettons en lumière certaines
des questions et réponses les mieux votées postées depuis notre dernière mise à jour.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Praticité des signatures Schnorr semi-agrégées ?]({{bse}}125982) Fjahr discute pourquoi des
  signatures indépendantes, non agrégées, ne sont pas nécessaires pour valider une signature
  semi-agrégée dans l'[agrégation de signature inter-entrées (CISA)][topic cisa] et pourquoi les
  signatures non agrégées peuvent en fait poser problème.

- [Quelle est la plus grande taille de payload OP_RETURN jamais créée ?]({{bse}}126131) Vojtěch
  Strnad [lie][op_return tx] à une transaction du [meta-protocole][topic client-side validation] Runes
  avec 79 870 octets comme le plus grand `OP_RETURN`.

- [Explication hors-LN du pay-to-anchor ?]({{bse}}126098) Murch détaille la logique et la structure
  des scripts de sortie [pay-to-anchor (P2A)][topic ephemeral anchors].

- [Statistiques à jour sur les réorganisations de chaîne ?]({{bse}}126019) 0xb10c et Murch indiquent
  des sources de données sur les réorg, incluant le dépôt [stale-blocks][stale-blocks github], le site
  web [forkmonitor.info][], et le site web [fork.observer][].

- [Les canaux Lightning sont-ils toujours P2WSH ?]({{bse}}125967) Polespinasa note le développement
  en cours des canaux [simple taproot][topic simple taproot channels] P2TR et résume le support actuel
  à travers les implémentations Lightning.

- [Child-pays-for-parent comme défense contre un double dépense ?]({{bse}}126056) Murch liste les
  complications à utiliser une transaction enfant [CPFP][topic cpfp] à frais élevé pour inciter à une
  réorg de la blockchain en défense d'une sortie déjà confirmée et doublement dépensée.

- [Quelles valeurs CHECKTEMPLATEVERIFY hache-t-il ?]({{bse}}126133) Average-gray décrit les champs
  auxquels [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify] s'engage : nVersion, nLockTime,
  nombre d'entrées, hash des séquences, nombre de sorties, hash des sorties, indice d'entrée, et dans
  certains cas le hash de scriptSig.

- [Pourquoi les nœuds Lightning ne peuvent-ils pas choisir de révéler les soldes des canaux pour une
  meilleure efficacité de routage ?]({{bse}}125985) Rene Pickhardt explique les préoccupations
  concernant l'obsolescence et la fiabilité des données, les implications sur la vie privée, et
  renvoie à une [proposition similaire][BOLTs #780] de 2020.

- [Le post-quantique nécessite-t-il un hard fork ou un soft fork ?]({{bse}}126122) Vojtěch Strnad
  décrit une approche de la manière dont un schéma de signature [post-quantique][topic quantum
  resistance] (PQC) pourrait être [activé par soft-fork][topic soft fork activation] ainsi que comment
  un hard ou soft fork pourrait verrouiller les pièces vulnérables au quantique.

## Mises à jour et versions candidates

_Nouvelles mises-à-jours et versions candidates pour des projets d'infrastructure Bitcoin populaires.
Veuillez envisager de mettre à niveau vers les nouvelles mises-à-jour ou d'aider à tester les versions candidates._

- [LND 0.19.0-beta.rc3][] est un candidat à la sortie pour ce nœud LN populaire. L'une des
  principales améliorations qui pourrait probablement nécessiter des tests est le nouveau bumping de
  frais basé sur RBF pour les fermetures coopératives.

## Changements notables dans le code et la documentation

_Changements récents notables dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core
lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware WalletInterface (HWI)][hwi repo],
[Rust Bitcoin][rust bitcoin repo], [BTCPay Server][btcpay server repo], [BDK][bdk repo],
[Propositions d'Amélioration de Bitcoin (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Interrogatoire Bitcoin][bitcoin inquisition repo], et
[BINANAs][binana repo]._

- [Bitcoin Core #31247][] ajoute le support pour la sérialisation et l'analyse des champs
  [MuSig2][topic musig] [PSBT][topic psbt] comme spécifié dans [BIP373][] pour permettre aux
  portefeuilles de signer et dépenser des entrées [MuSig2][topic musig]. Du côté de l'entrée, cela
  consiste en un champ listant les clés publiques des participants, plus un champ de nonce public
  séparé et un champ de signature partielle séparé pour chaque signataire. Du côté de la sortie, c'est
  un champ unique listant les clés publiques des participants pour le nouveau UTXO.

- [LDK #3601][] ajoute une nouvelle énumération `LocalHTLCFailureReason` pour représenter chaque
  code d'erreur standard [BOLT4][], ainsi que quelques variantes qui fournissent des informations
  supplémentaires à l'utilisateur qui étaient précédemment supprimées pour des raisons de
  confidentialité.

{% include snippets/recap-ad.md when="2025-04-29 15:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="31247,3601,780" %}
[lnd 0.19.0-beta.rc3]: https://github.com/lightningnetwork/lnd/releases/tag/v0.19.0-beta.rc3
[nrs dahlias]: https://mailing-list.bitcoindevs.xyz/bitcoindev/be3813bf-467d-4880-9383-2a0b0223e7e5@gmail.com/
[dahlias paper]: https://eprint.iacr.org/2025/692.pdf
[ingala backdes]: https://delvingbitcoin.org/t/a-simple-backup-scheme-for-wallet-accounts/1607
[op_return tx]: https://mempool.space/tx/fd3c5762e882489a62da3ba75a04ed283543bfc15737e3d6576042810ab553bc
[stale-blocks github]: https://github.com/bitcoin-data/stale-blocks
[forkmonitor.info]: https://forkmonitor.info/nodes/btc
[fork.observer]: https://fork.observer/
