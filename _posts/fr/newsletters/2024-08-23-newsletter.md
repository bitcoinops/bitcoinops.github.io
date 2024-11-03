---
title: 'Bulletin Hebdomadaire Bitcoin Optech #317'
permalink: /fr/newsletters/2024/08/23/
name: 2024-08-23-newsletter-fr
slug: 2024-08-23-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine résume une discussion sur un protocole anti-exfiltration qui ne
nécessite qu'un seul aller-retour de communication entre un portefeuille et un dispositif de
signature. Sont également incluses nos sections
régulières décrivant les mises à jour des clients et services, avec les annonces de nouvelles versions et les changements
apportés aux principaux logiciels d'infrastructure Bitcoin.

## Nouvelles

- **Protocole anti-exfiltration simple (mais imparfait) :** le développeur Moonsettler a
  [posté][moonsettler exfil1] sur Delving Bitcoin pour décrire un protocole [anti-exfiltration][topic
  exfiltration-resistant signing]. Le même protocole a été décrit auparavant (voir les Bulletins
  [#87][news87 exfil] et [#88][news88 exfil]), avec Pieter Wuille [citant][wuille exfil1] la
  description la plus ancienne connue de la technique pour l'anti-exfil étant un [post de
  2014][maxwell exfil] par Gregory Maxwell.

  Le protocole utilise le protocole sign-to-contract pour permettre à un portefeuille logiciel de
  contribuer à l'entropie sélectionnée par un dispositif de signature matériel d'une manière qui
  permet au portefeuille logiciel de vérifier plus tard que l'entropie a été utilisée.
  Sign-to-contract est une variation de [pay-to-contract][topic p2c] : dans pay-to-contract, la clé
  publique du destinataire est modifiée ; dans sign-to-contract, le nonce de signature de l'envoyeur
  est modifié.

  L'avantage de ce protocole, par rapport au protocole implémenté pour les dispositifs de signature
  matérielle BitBox02 et Jade (voir le [Bulletin #136][news136 exfil]), est qu'il ne nécessite qu'un
  seul aller-retour de communication entre le portefeuille logiciel et le dispositif de signature
  matériel. Cet aller-retour peut être combiné avec les autres étapes nécessaires pour signer une
  transaction single-sig ou multisig scriptée, ce qui signifie que la technique n'affecte pas les flux
  de travail des utilisateurs. La technique actuellement déployée, qui est également basée sur
  sign-to-contract, nécessite deux allers-retours ; c'est plus que nécessaire pour la plupart des
  utilisateurs aujourd'hui, bien que plusieurs allers-retours puissent être requis pour les
  utilisateurs qui passent à l'utilisation de [multisignatures sans script][topic multisignature] et
  de [signatures seuil sans script][topic threshold signature]. Pour les utilisateurs qui connectent
  leurs dispositifs de signature directement à leurs ordinateurs ou qui utilisent un protocole de
  communication sans fil interactif comme le Bluetooth, le nombre d'allers-retours n'a pas
  d'importance. Mais, pour les utilisateurs qui préfèrent garder leurs dispositifs en airgap, chaque
  aller-retour nécessite deux interventions manuelles, ce qui peut rapidement s'ajouter à une quantité
  ennuyeuse de travail lors de la signature fréquente ou de l'utilisation de plusieurs dispositifs
  pour des multisignatures scriptées.

  L'inconvénient de ce protocole a été mentionné par Maxwell dans sa description originale, il "laisse
  ouvert un [canal latéral][topic side channels] qui a un coût exponentiel par bit supplémentaire, via
  le grinding (recherche exhaustive) [...] mais il élimine les attaques évidentes et très puissantes où tout est divulgué dans
  une seule signature. C'est clairement moins bien, mais c'est seulement un protocole en deux
  mouvements, donc de nombreux endroits qui ne considéreraient pas l'utilisation d'une contre-mesure
  pourraient adopter cela gratuitement juste comme un élément d'une spécification de protocole."
  Ce protocole représente une nette amélioration par rapport à l'absence totale d'utilisation de
  l'anti-exfiltration et Pieter Wuille [note][wuille exfil2] qu'il s'agit probablement de la meilleure
  anti-exfiltration possible avec une signature en un seul tour. Cependant, Wuille préconise le
  protocole d'anti-exfiltration en deux tours déployé pour prévenir même l'exfiltration basée sur le
  grinding.

  La discussion était en cours au moment de la rédaction.

## Modifications apportées aux services et aux logiciels clients

*Dans cette rubrique mensuelle, nous mettons en lumière des mises à jour intéressantes des
portefeuilles et services Bitcoin.*

- **Annonce de Proton Wallet :**
  Proton [a annoncé][proton blog] leur Proton Wallet [open-source][proton github] avec support pour
  plusieurs portefeuilles, [bech32][topic bech32], l'envoi [batch][topic payment batching], les
  mnémoniques [BIP39][], et l'intégration avec leur service email.

- **Annonce du testnet CPUNet :**
  Un contributeur du projet de [pool][topic pooled mining] minier [braidpool][braidpool github] [a
  annoncé][cpunet post] le réseau de test [CPUNet][cpunet github]. CPUNet utilise un algorithme de
  preuve de travail modifié pour exclure les mineurs ASIC dans le but d'atteindre des taux de blocs
  plus constants que ce qui est typique du [testnet][topic testnet].

- **Lancement de Lightning.Pub :**
  [Lightning.Pub][lightningpub github] fournit des fonctionnalités de gestion de nœuds pour LND qui
  permettent un accès partagé et la coordination de la liquidité des canaux, en utilisant nostr pour
  les communications chiffrées et les identités de compte basées sur des clés.

- **Sortie de Taproot Assets v0.4.0-alpha :**
  La version [v0.4.0-alpha][taproot assets v0.4.0] prend en charge le protocole [Taproot Assets][topic
  client-side validation] sur le mainnet pour l'émission d'actifs onchain et les échanges atomiques en
  utilisant les [PSBT][topic psbt] et en routant les actifs à travers le Lightning Network.

- **Outil de benchmarking Stratum v2 publié :**
  La première version [0.1.0][sbm 0.1.0] permet de tester, de rapporter et de comparer les
  performances des protocoles Stratum v1 et Stratum v2 [protocols][topic pooled mining] dans
  différents scénarios de minage.

- **PoC de vérification STARK sur signet :**
  StarkWare [a annoncé][starkware tweet] un [vérificateur STARK][bcs github] vérifiant une preuve à
  divulgation nulle de connaissance sur le réseau de test [signet][topic signet] en utilisant l'opcode
  [OP_CAT][topic op_cat] (voir le [Bulletin #304][news304 inquisition]).

- **Sortie de SeedSigner 0.8.0 :**
  Le projet de dispositif de signature matériel Bitcoin [SeedSigner][seedsigner website] a ajouté des
  fonctionnalités de signature pour P2PKH et multisig P2SH, un support supplémentaire pour les
  [PSBTs][topic psbt], et activé par défaut le support de [taproot][topic taproot] dans la version
  [0.8.0][seedsigner 0.8.0].

- **Sortie de Floresta 0.6.0 :**
  Dans la version [0.6.0][floresta 0.6.0], Floresta ajoute le support pour les [filtres de blocs
  compacts][topic compact block filters], les preuves de fraude sur signet, et [`florestad`][floresta
  blog], un daemon pour l'intégration par les portefeuilles existants ou les applications clientes.

## Mises à jour et versions candidates

*Nouvelles versions et version candidates pour les projets d'infrastructure Bitcoin populaires.
Veuillez envisager de passer aux nouvelles versions ou d'aider à tester les candidats à la version.*

- [Core Lightning 24.08rc2][] est une version candidate pour la prochaine version majeure de
  cette implémentation populaire de nœud LN.

- [LND v0.18.3-beta.rc1][] est une version candidate pour une correction mineure de bug de cette
  implémentation populaire de nœud LN.

## Changements notables dans le code et la documentation

_Changements récents notables dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core
lightning repo], [Eclair][eclair repo], [LDK][ldk repo], [LND][lnd repo],
[libsecp256k1][libsecp256k1 repo], [Interface de Portefeuille Matériel (HWI)][hwi repo], [Rust
Bitcoin][rust bitcoin repo], [Serveur BTCPay][btcpay server repo], [BDK][bdk repo], [Propositions
d'Amélioration de Bitcoin (BIPs)][bips repo], [Lightning BOLTs][bolts repo], [Lightning BLIPs][blips
repo], [Inquisition Bitcoin][bitcoin inquisition repo], et [BINANAs][binana repo]._

- [Bitcoin Core #28553][] ajoute des paramètres de snapshot [assumeUTXO][topic assumeutxo] pour le
  bloc principal 840,000 : son hash de bloc, le nombre de transactions jusqu'à ce bloc, et le hash
  SHA256 de l'ensemble UTXO sérialisé jusqu'à ce bloc. Cela fait suite aux tests de plusieurs
  contributeurs qui ont pu reproduire le même [fichier de snapshot][] avec le checksum SHA256 attendu,
  et que le snapshot fonctionne bien une fois chargé.

- [Bitcoin Core #30246][] introduit une sous-commande `diff_addrs` à l'utilitaire `asmap-tool` pour
  permettre aux utilisateurs de comparer deux cartes de [Systèmes Autonomes][auto sys] (ASMaps) et de
  calculer des statistiques sur le nombre d'adresses de réseau de nœuds qui ont été réassignées à un
  autre Numéro de Système Autonome (ASN). Cette fonctionnalité quantifie la dégradation d'un ASMap au
  fil du temps, ce qui est une étape importante vers l'envoi éventuel d'ASMaps précalculés dans les
  versions de Bitcoin Core, et augmente davantage la résistance de Bitcoin Core aux [attaques par
  éclipse][topic eclipse attacks]. Voir le Bulletin [#290][news290 asmap].

- [Bitcoin Core GUI #824][] change l'élément de menu `Migrer le Portefeuille` d'une action unique à
  une liste de menu, permettant aux utilisateurs de migrer tout portefeuille hérité dans le répertoire
  du portefeuille, y compris les portefeuilles non chargeables. Ce changement prépare à un futur
  possible où les portefeuilles hérités pourraient ne plus être chargeables dans Bitcoin Core, avec
  les portefeuilles [descripteurs][topic descriptors] devenant la norme. Lors de la sélection d'un
  portefeuille à migrer, l'interface utilisateur demandera à l'utilisateur d'entrer le mot de passe du
  portefeuille, s'il en a un.

- [Core Lightning #7540][] améliore la formule qui calcule la probabilité d'un routage réussi à
  travers un canal dans le plugin `renepay` (voir el Bulletin [#263][news263 renepay]) en ajoutant un
  multiplicateur constant qui représente la probabilité qu'un canal choisi au hasard dans le réseau
  puisse transférer au moins 1 msat. La valeur par défaut est fixée à 0.98, mais cela pourrait être
  modifié à l'avenir après d'autres tests.

- [Core Lightning #7403][] ajoute un modificateur de paiement de filtrage de canal au plugin
  `renepay` qui désactive les canaux avec un `max_htlc` très bas. Cela peut être étendu à
  l'avenir pour filtrer les canaux qui sont indésirables pour d'autres raisons : frais de base élevés,
  faible capacité et haute latence. De plus, une nouvelle option de ligne de commande `exclude` a été
  ajoutée pour désactiver manuellement des nœuds ou des canaux.

- [LND #8943][] introduit les modèles [Alloy][alloy model] dans la base de code, en commençant par
  un modèle Alloy initial pour le mécanisme de hausse des frais [Linear Fee Function][lnd linear],
  inspiré par un correctif de bug [LND #8751][]. Alloy fournit une méthode formelle légère pour
  vérifier la correction des composants du système afin de faciliter la découverte de bugs lors de
  l'implémentation initiale. Plutôt que d'essayer de prouver qu'un modèle est toujours correct, comme
  le font les méthodes formelles complètes, Alloy opère sur une entrée d'un ensemble de paramètres et
  d'itérations limités et essaie de trouver des contre-exemples à une assertion donnée, accompagnée
  d'un visualiseur agréable. Les modèles peuvent également être utilisés pour spécifier des protocoles
  dans les systèmes P2P, ce qui les rend particulièrement bien adaptés au Lightning Network.

- [BDK #1478][] apporte plusieurs changements aux structures de requête `FullScanRequest` et
  `SyncRequest` du paquet `bdk_chain` : utilisation d'un modèle de constructeur qui sépare la
  construction et la consommation de la requête, rend le paramètre `chain_tip` optionnel pour
  permettre aux utilisateurs de se désinscrire des mises à jour `LocalChain` (utile pour ceux qui
  utilisent `bdk_esplora` sans `LocalChain`), et améliore l'ergonomie de la vérification des progrès
  de synchronisation. De plus, le paquet `bdk_esplora` est optimisé en ajoutant toujours les sorties de
  transactions précédentes à la mise à jour `TxGraph` et en réduisant le nombre d'appels API en
  utilisant le point de terminaison `/tx/:txid`.

- [BDK #1533][] active le support pour les portefeuilles à [descripteur][topic descriptors] unique
  en ajoutant la méthode `Wallet::create_single`, revenant sur une mise à jour précédente qui avait
  rendu la structure `Wallet` nécessitant un descripteur interne (de changement). La raison de ce
  changement précédent était de protéger la confidentialité des adresses de change des
  utilisateurs lorsqu'ils se fient aux serveurs Electrum ou Esplora publics, mais cela est révoqué
  pour inclure tous les cas d'utilisation.

- [BOLTs #1182][] améliore la clarté et l'exhaustivité des sections [route blinding][topic rv
  routing] et [onion messages][topic onion messages] de la spécification [BOLT4][] avec les
  changements suivants : déplace la section sur l'aveuglement de route d'un niveau vers le haut pour
  souligner son applicabilité aux paiements (et pas seulement aux messages onion), fournit plus de
  détails concrets sur le type `blinded_path` et ses exigences, élargit la description des
  responsabilités de l'auteur, divise la section du lecteur en parties séparées pour le `blinded_path`
  et les `encrypted_recipient_data`, améliore l'explication du concept de `blinded_path`, ajoute une
  recommandation d'utiliser un saut fictif, renomme `onionmsg_hop` en `blinded_path_hop`, et apporte
  d'autres changements clarifiants.

- [BLIPs #39][] ajoute [BLIP39][] pour un champ optionnel `b` dans les factures [BOLT11][] pour
  communiquer un [chemin aveugle][topic rv routing] pour payer le nœud du destinataire.
  Ceci est implémenté dans LND (voir le Bulletin [#315][news315 blinded]) et est destiné à être utilisé
  jusqu'à ce que le protocole [offers][topic offers] soit largement déployé dans le réseau.

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="28553,30246,824,7540,7403,8943,1478,1533,1182,39,8751" %}
[Core Lightning 24.08rc2]: https://github.com/ElementsProject/lightning/releases/tag/v24.08rc2
[LND v0.18.3-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.18.3-beta.rc1
[moonsettler exfil1]: https://delvingbitcoin.org/t/non-interactive-anti-exfil-airgap-compatible/1081
[wuille exfil1]: https://delvingbitcoin.org/t/non-interactive-anti-exfil-airgap-compatible/1081/3
[wuille exfil2]: https://delvingbitcoin.org/t/non-interactive-anti-exfil-airgap-compatible/1081/7
[news87 exfil]: /en/newsletters/2020/03/04/#proposal-to-standardize-an-exfiltration-resistant-nonce-protocol
[news88 exfil]: /en/newsletters/2020/03/11/#exfiltration-resistant-nonce-protocols
[maxwell exfil]: https://bitcointalk.org/index.php?topic=893898.msg9861102#msg9861102
[news136 exfil]: /en/newsletters/2021/02/17/#anti-exfiltration
[proton blog]: https://proton.me/blog/proton-wallet-launch
[proton github]: https://github.com/protonwallet/
[braidpool github]: https://github.com/braidpool/braidpool
[cpunet post]: https://x.com/BobMcElrath/status/1823370268728873411
[cpunet github]: https://github.com/braidpool/bitcoin/blob/cpunet/contrib/cpunet/README.md
[lightningpub github]: https://github.com/shocknet/Lightning.Pub
[taproot assets v0.4.0]: https://github.com/lightninglabs/taproot-assets/releases/tag/v0.4.0
[sbm 0.1.0]: https://github.com/stratum-mining/benchmarking-tool/releases/tag/0.1.0
[starkware tweet]: https://x.com/StarkWareLtd/status/1813929304209723700
[bcs github]: https://github.com/Bitcoin-Wildlife-Sanctuary/bitcoin-circle-stark
[news304 inquisition]: /fr/newsletters/2024/05/24/#bitcoin-inquisition-27-0
[seedsigner website]: https://seedsigner.com/
[seedsigner 0.8.0]: https://github.com/SeedSigner/seedsigner/releases/tag/0.8.0
[floresta 0.6.0]: https://github.com/vinteumorg/Floresta/releases/tag/0.6.0
[floresta blog]: https://medium.com/vinteum-org/floresta-update-simplifying-bitcoin-node-integration-for-wallets-6886ea7c975c
[auto sys]: https://en.wikipedia.org/wiki/Autonomous_system_(Internet)
[news290 asmap]: /fr/newsletters/2024/02/21/#amelioration-du-processus-de-creation-de-asmap-reproductible
[news263 renepay]: /fr/newsletters/2023/08/09/#core-lightning-6376
[alloy model]: https://alloytools.org/about.html
[lnd linear]: https://github.com/lightningnetwork/lnd/blob/b7c59b36a74975c4e710a02ea42959053735402e/sweep/fee_function.go#L66-L109
[news315 blinded]: /fr/newsletters/2024/08/09/#lnd-8735
[fichier de snapshot]: magnet:?xt=urn:btih:596c26cc709e213fdfec997183ff67067241440c&dn=utxo-840000.dat&tr=udp%3A%2F%2Ftracker.bitcoin.sprovoost.nl%3A6969
