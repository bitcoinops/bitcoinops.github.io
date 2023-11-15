---
title: 'Bulletin Hebdomadaire Bitcoin Optech #260'
permalink: /fr/newsletters/2023/07/19/
name: 2023-07-19-newsletter-fr
slug: 2023-07-19-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Cette semaine, le bulletin contient la dernière entrée de notre série hebdomadaire limitée sur la politique de la mempool,
ainsi que nos sections régulières décrivant les changements notables apportés aux clients, aux services et aux principaux
logiciels d'infrastructure Bitcoin.

## Nouvelles

_Aucune actualité significative n'a été trouvée cette semaine dans les listes de diffusion Bitcoin-Dev ou Lightning-Dev._

## En attente de confirmation #10 : Impliquez-vous

_La dernière entrée de notre [série][policy series] hebdomadaire limitée  sur le relais des transactions, l'inclusion dans la mempool et la sélection des transactions minières - y compris pourquoi Bitcoin Core a une politique plus restrictive que celle autorisée par consensus et comment les portefeuilles peuvent utiliser cette politique de la manière la plus efficace._

{% include specials/policy/fr/10-impliquez-vous.md %}

Modifications apportées aux services et aux logiciels clients

*Dans cette rubrique mensuelle, nous mettons en évidence les mises à jour
intéressantes des portefeuilles et services Bitcoin.*

- **Le portefeuille 10101 bêta teste la mise en commun des fonds entre les LN et les DLC :**
  10101 a annoncé un [portefeuille][10101 github] construit avec LDK et BDK qui permet aux utilisateurs de négocier des dérivés
  sans garde en utilisant des [DLCs][topic dlc] dans un [contrat hors chaîne][10101 blog2] qui peut également être utilisé pour
  envoyer, recevoir et transférer des paiements LN. Les DLC reposent sur des oracles qui utilisent des [signatures
  d'adaptateur][topic adaptor signatures] pour l'[attestation][10101 blog1] des prix.

- **LDK Node annoncé :**
  L'équipe LDK a [annoncé][ldk blog] LDK Node [v0.1.0][LDK Node v0.1.0]. LDK Node est une
  bibliothèque Rust de nœud Lightning qui utilise les bibliothèques LDK et BDK pour permettre aux développeurs
  de configurer rapidement un nœud Lightning auto-hébergé tout en offrant un degré élevé de
  personnalisation pour différents cas d'utilisation.

- **Payjoin SDK annoncé :**
  [Payjoin Dev Kit (PDK)][PDK github] a été [annoncé][PDK blog] en tant que bibliothèque Rust
  qui implémente [BIP78][] pour une utilisation dans les portefeuilles et les services souhaitant
  intégrer la fonctionnalité [payjoin][topic payjoin].

- **Annonce de la version bêta de Validating Lightning Signer (VLS) :**
  VLS permet de séparer un nœud Lightning des clés qui contrôlent ses
  fonds. Un nœud Lightning fonctionnant avec VLS routera les demandes de signature vers un
  dispositif de signature distant au lieu des clés locales. La [version bêta][VLS gitlab]
  prend en charge CLN et LDK, les règles de validation de la couche 1 et de la couche 2, les capacités de sauvegarde/récupération
  et fournit une implémentation de référence. L'annonce du [blog][VLS blog] appelle également à des tests, des demandes de fonctionnalités et des commentaires de la communauté.

- **BitGo ajoute la prise en charge de MuSig2 :**
  BitGo a [annoncé][bitgo blog] la prise en charge de [BIP327][] ([MuSig2][topic musig])
  et a pointé les frais réduits et la confidentialité supplémentaire par rapport à leurs autres
  types d'adresses pris en charge.

- **Peach ajoute la prise en charge de RBF :**
  L'application mobile [Peach Bitcoin][peach website] pour l'échange pair à pair
  a [annoncé][peach tweet] la prise en charge de l'augmentation des frais [Replace-By-Fee (RBF)][topic rbf].

- **Le portefeuille Phoenix ajoute la prise en charge du splicing :**
  ACINQ a [annoncé][acinq blog] les tests bêta de la prochaine version de leur
  portefeuille mobile Lightning Phoenix. Le portefeuille prend en charge un seul canal dynamique
  qui est rééquilibré en utilisant le [splicing][topic splicing] et
  un mécanisme similaire à la technique [swap-in-potentiam][news233 sip] (voir
  [Podcast #259][pod259 phoenix]).

- **Appel à commentaires sur le Mining Development Kit (MDK) :**
  L'équipe travaillant sur le Mining Development Kit (MDK) a [publié une mise à jour][MDK blog] sur leurs
  progrès pour développer du matériel, des logiciels et des micrologiciels pour les systèmes de minage de Bitcoin. L'article
  appelle à des commentaires de la communauté sur les cas d'utilisation, la portée et l'approche.

- **Binance ajoute la prise en charge de Lightning :**
  Binance a [annoncé][binance blog] la prise en charge de l'envoi (retraits) et
  de la réception (dépôts) en utilisant le réseau Lightning.

- **Nunchuk ajoute la prise en charge de CPFP :**
  Nunchuk a [annoncé][nunchuk blog] la prise en charge de l'augmentation des frais [Child-Pays-For-Parent
  (CPFP)][topic cpfp] pour les expéditeurs et les destinataires d'une transaction.

## Changements notables dans le code et la documentation

*Changements notables cette semaine dans [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Interface de portefeuille
matériel (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [Serveur BTCPay
][btcpay server repo], [BDK][bdk repo], [Propositions d'amélioration de Bitcoin (BIP)][bips repo], [Lightning BOLTs][bolts repo], et
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [Bitcoin Core #27411][] empêche un nœud de diffuser son adresse Tor ou
  I2P à des pairs sur d'autres réseaux (tels que IPv4 ou IPv6 simples)
  et ne diffusera pas son adresse depuis des [réseaux d'anonymat][topic anonymity networks]
  à des pairs sur Tor et I2P. Cela aide à empêcher
  quelqu'un d'associer l'adresse réseau régulière d'un nœud à l'une de ses
  adresses sur un réseau d'anonymat. CJDNS est traité différemment de
  Tor et I2P pour le moment, bien que cela puisse changer à l'avenir.

- [Core Lightning #6347][] ajoute la possibilité pour un plugin de s'abonner à
  chaque notification d'événement en utilisant le caractère générique `*`.

- [Core Lightning #6035][] ajoute la possibilité de demander une adresse [bech32m][topic bech32]
  pour recevoir des dépôts sur des scripts de sortie [P2TR][topic taproot]. Les modifications de transaction
  seront également désormais envoyées à une sortie P2TR par défaut.

- [LND #7768][] implémente les BOLT [#1032][bolts #1032] et [#1063][bolts #1063]
  (voir [Newsletter #225][news225 bolts1032]), permettant au
  destinataire final d'un paiement (HTLC) d'accepter un montant supérieur à
  celui demandé et avec un délai d'expiration plus long que celui
  demandé. Auparavant, les destinataires basés sur LND adhéraient à
  l'exigence de [BOLT4][] selon laquelle le montant et le delta d'expiration devaient être exactement égaux au montant
  demandé, mais cette exactitude permettait à un nœud de transfert de
  sonder le prochain saut pour voir s'il était le destinataire final en modifiant légèrement l'une ou l'autre valeur.

- [Libsecp256k1 #1313][] commence les tests automatiques à l'aide de versions de développement
  des compilateurs GCC et Clang, ce qui peut permettre de détecter
  des modifications qui pourraient entraîner l'exécution de certaines parties du code libsecp256k1 en
  temps variable. Un code non-constant qui fonctionne avec des clés privées
  et des nonces peut entraîner des [attaques par canaux secondaires][topic
  side channels]. Voir [Newsletter #246][news246 secp] pour une occasion
  où cela aurait pu se produire et [Newsletter #251][news251 secp] pour
  une autre occasion et une annonce selon laquelle ce type de test était
  prévu.

{% include references.md %}
{% include linkers/issues.md v=2 issues="27411,6347,6035,7768,1032,1063,1313" %}
[policy series]: /fr/blog/waiting-for-confirmation/
[news225 bolts1032]: /fr/newsletters/2022/11/09/#bolts-1032
[news246 secp]: /fr/newsletters/2023/04/12/#libsecp256k1-0-3-1
[news251 secp]: /fr/newsletters/2023/05/17/#libsecp256k1-0-3-2
[10101 github]: https://github.com/get10101/10101
[10101 blog1]: https://10101.finance/blog/dlc-to-lightning-part-1/
[10101 blog2]: https://10101.finance/blog/dlc-to-lightning-part-2
[LDK Node v0.1.0]: https://github.com/lightningdevkit/ldk-node/releases/tag/v0.1.0
[LDK blog]: https://lightningdevkit.org/blog/announcing-ldk-node
[PDK github]: https://github.com/payjoin/rust-payjoin
[PDK blog]: https://payjoindevkit.org/blog/pdk-an-sdk-for-payjoin-transactions/
[VLS gitlab]: https://gitlab.com/lightning-signer/validating-lightning-signer/-/releases/v0.9.1
[VLS blog]: https://vls.tech/posts/vls-beta/
[bitgo blog]: https://blog.bitgo.com/save-fees-with-musig2-at-bitgo-3248d690f573
[peach website]: https://peachbitcoin.com/
[peach tweet]: https://twitter.com/peachbitcoin/status/1676955956905902081
[acinq blog]: https://acinq.co/blog/phoenix-splicing-update
[news233 sip]: /fr/newsletters/2023/01/11/#engagements-d-ouvertures-non-interactifs-du-canal-ln
[MDK blog]: https://www.mining.build/update-on-the-mining-development-kit/
[binance blog]: https://www.binance.com/en/support/announcement/binance-completes-integration-of-bitcoin-btc-on-lightning-network-opens-deposits-and-withdrawals-eefbfae2c0ae472d9e1e36f1a30bf340
[nunchuk blog]: https://nunchuk.io/blog/cpfp
[pod259 phoenix]: /en/podcast/2023/07/13/#phoenix
