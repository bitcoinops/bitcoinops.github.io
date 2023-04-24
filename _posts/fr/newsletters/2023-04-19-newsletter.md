---
title: 'Bulletin Hebdomadaire Bitcoin Optech #247'
permalink: /fr/newsletters/2023/04/19/
name: 2023-04-19-newsletter-fr
slug: 2023-04-19-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine fait le point sur le développement du protocole RGB
et comprend nos sections habituelles qui résument les mises à jour récentes des
clients et des services, annoncent les nouvelles versions et les versions candidates,
et décrit les principaux changements apportés aux logiciels d'infrastructure
Bitcoin les plus répandus.

## Nouvelles

- **Mise à jour RGB :** Maxim Orlovsky a [posté][orlovsky rgb] sur la liste
  de diffusion Bitcoin-Dev une mise à jour sur l'état du développement de RGB.
  RGB est un protocole qui utilise les transactions Bitcoin pour effectuer
  des mises à jour d'état dans les contrats hors chaîne. Un exemple simple
  implique la création et le transfert de jetons, bien que RGB soit conçu
  pour des objectifs plus larges que le simple transfert de jetons.

  - Hors chaîne, Alice crée un contrat dont l'état initial attribue
    1 000 tokens à une certaine UTXO qu'elle contrôle.

  - Bob veut 400 des jetons.  Alice lui donne une copie du contrat original
    ainsi qu'une transaction qui dépense son UTXO en une nouvelle sortie.
    Cette sortie contient un engagement non public envers le nouvel état du
    contrat. Le nouvel état du contrat spécifie la distribution des montants
    (400 pour Bob ; 600 pour Alice) et les identifiants des deux sorties qui
    contrôleront ces montants.  Alice diffuse la transaction. La sécurité de
    ce transfert de jetons contre la double dépense est maintenant égale à
    celle de la transaction Bitcoin d'Alice, c'est-à-dire que lorsque sa
    transaction a six confirmations, le transfert de jetons sera sécurisé
    contre une fourche jusqu'à six blocs.

      Les sorties qui contrôlent les montants ne doivent pas nécessairement
      être des sorties de la transaction contenant l'engagement (bien que
      cela soit autorisé). Cela élimine la possibilité d'utiliser l'analyse
      des transactions sur la chaîne pour suivre les transferts basés sur le
      RGB. Les jetons auraient pu être transférés à n'importe quelle UTXO
      existante---ou à n'importe quelle UTXO dont le destinataire sait
      qu'elle existera à l'avenir (par exemple, une dépense présignée de
      son portefeuille froid qui pourrait ne pas apparaître sur la chaîne
      pendant des années). La valeur en bitcoins des différentes sorties
      et leurs autres caractéristiques n'ont aucune importance pour le
      protocole RGB, même si Alice et Bob voudront s'assurer qu'elles
      sont faciles à dépenser.

  - Plus tard, Carole souhaite acheter 100 tokens à Bob dans le cadre
    d'un échange atomique en utilisant une seule transaction onchain.
    Elle génère un PSBT non signé qui finance la transaction à partir
    de ses entrées, paie Bob en bitcoins via une sortie, et se renvoie
    la monnaie en bitcoins avec une seconde sortie. L'une de ces sorties
    engage également les montants et les identifiants UTXO où elle
    recevra ses jetons et où Bob recevra sa monnaie.

      Bob fournit à Carole le contrat original et l'engagement qu'Alice
      a créé précédemment et qui prouve que Bob contrôle désormais 400
      jetons. Bob n'a pas besoin de savoir ce qu'Alice a fait des 600
      jetons restants et Alice n'intervient pas dans l'échange entre Bob
      et Carole. Ce système garantit à la fois la confidentialité et
      l'évolutivité. Bob met à jour la PSBT avec une entrée signée pour
      l'UTXO contrôlant les jetons.

      Carol vérifie le contrat original et l'historique des précédentes
      mises à jour de l'État.  Elle s'assure également que tous les autres
      éléments de la PSBT sont corrects. Elle appose sa signature et
      diffuse la transaction.

  Bien que chacun des exemples de transfert ci-dessus ait été effectué sur
  la chaîne, il est facile de modifier le protocole pour qu'il fonctionne
  hors chaîne. Carol donne à Dan une copie du contrat ainsi que l'historique
  des mises à jour de l'état qui lui ont permis de recevoir 100 jetons.
  Elle et Dan se coordonnent ensuite pour créer une sortie qui reçoit les
  100 tokens et qui nécessite les signatures des deux pour être dépensée.
  Hors chaîne, ils transfèrent les jetons dans les deux sens en générant
  de nombreuses versions différentes d'une transaction qui dépense la sortie
  multi-signature, chaque dépense hors chaîne engageant la distribution
  des jetons et les identifiants des sorties qui recevront ces jetons.
  Enfin, l'un d'entre eux diffuse l'une des transactions de dépense,
  mettant l'état sur la chaîne.

  Les sorties auxquelles les jetons ont été attribués peuvent être affectées
  par un script Bitcoin qui détermine qui contrôlera en dernier ressort les
  jetons. Par exemple, ils peuvent payer un script [HTLC][topic htlc] qui
  donne à Carole la possibilité de dépenser les jetons à tout moment si elle
  peut fournir une pré-image et sa signature, ou qui donne à Dan la possibilité
  de dépenser les jetons avec sa seule signature après l'expiration d'un délai.
  Cela permet aux jetons d'être utilisés dans des paiements hors chaîne transmis,
  tels que ceux utilisés dans LN.

  Dans une [réponse][tenga rgb] au fil de discussion, Federico Tenga a fait
  un lien vers un [nœud LN][rgb-lightning-sample] basé sur RGB et basé sur
  une fourche de [LDK][ldk repo] et le nœud [LDK sample][ldk-sample] de ce projet.
  En suivant les liens de ce projet, nous avons trouvé des [informations
  complémentaires][rgb.info ln] utiles sur la compatibilité LN. De plus amples
  informations sur le protocole RGB sont disponibles sur un [site web][rgb.tech]
  hébergé par l'association LNP/BP.

  Dans le billet de cette semaine, Orlovsky a annoncé la [release][rgb blog] de
  RGB v0.10. Plus important encore, la nouvelle version n'est pas compatible avec
  les contrats créés pour les versions précédentes (mais il n'y a pas de contrats
  commerciaux RGB connus sur le réseau principal). La nouvelle conception est
  destinée à permettre à tous les nouveaux contrats d'être mis à jour au fil du
  temps pour tenir compte des changements futurs dans le protocole. Un certain
  nombre d'autres améliorations ont également été mises en œuvre, et une feuille
  de route pour l'ajout de fonctionnalités supplémentaires est présentée.

  À l'heure où nous écrivons ces lignes, l'annonce a fait l'objet de quelques
  discussions sur la liste de diffusion.

## Modifications des services et logiciels clients

*Dans cette rubrique mensuelle, nous soulignons les mises à jour intéressantes
des portefeuilles et des services Bitcoin.*

- **La bibliothèque des descripteurs ajoute un explorateur de blocs :**
  La [bibliothèque du portefeuille Descriptor][] est une bibliothèque de
  portefeuille basée sur les descripteurs qui s'appuie sur rust-bitcoin et
  prend en charge [miniscript][topic miniscript], [descripteurs][topic descriptors],
  [PSBT][topic psbt], et dans les dernières [versions][Descriptor Wallet v0.9.2],
  un [explorateur de blocs][topic block explorers] textuel qui analyse et
  affiche les détails étendus des [blocs de contrôle][se107154] de la racine
  de la transaction à partir des témoins d'entrée, ainsi que les descripteurs
  et les miniscripts correspondant aux scripts de la transaction.

- **Annonce de la mise à jour de la mise en œuvre de référence de Stratum v2:**
  Le projet [a publié des détails][stratum blog] sur les mises à jour, y compris
  la possibilité pour les mineurs d'un pool de sélectionner des transactions pour
  un bloc candidat. Les mineurs, les pools et les développeurs de logiciels
  d'exploitation minière sont encouragés à tester et à faire part de leurs commentaires.

- **Mise à jour de Liana 0.4 :**
  La [version 0.4][liana 0.4] de Liana ajoute la prise en charge de plusieurs chemins
  de récupération et des descripteurs supplémentaires, ce qui permet d'obtenir des
  quorums plus importants.

- **Le micrologiciel de Coldcard prend en charge des flags sighash supplémentaires :**
  La [version 5.1.2 du firmware][coldcard firmware] de Coldcard prend désormais
  en charge tous les types de [signature-hash][wiki sighash] (sighash) au-delà
  de `SIGHASH_ALL`, ce qui permet des possibilités de transactions avancées.

- **Zeus ajoute des fonctions de majoration des frais :**
  [Zeus v0.7.4][] ajoute le fee bumping, en utilisant [RBF][topic rbf] et [CPFP][topic cpfp],
  pour les transactions onchain, y compris les transactions d'ouverture et de
  fermeture du canal LN. Au départ, la majoration des frais n'est possible
  qu'avec un backend LND.

- **Annonce du serveur Electrum basé sur Utreexo :**
   [Floresta][floresta blog] est un serveur compatible avec le protocole
   Electrum qui utilise [utreexo][topic utreexo] pour réduire les besoins
   en ressources du serveur. Le logiciel supporte actuellement le réseau
   de test [signet][topic signet].

## Mises à jour et versions candidates

*Nouvelles versions et versions candidates pour les principaux projets d’infrastructure
Bitcoin. Veuillez envisager de passer aux nouvelles versions ou d’aider à tester
les versions candidates.*

- [BDK 0.28.0][] est une version de maintenance de cette bibliothèque permettant
  de créer des applications compatibles avec Bitcoin.

- [Core Lightning 23.02.2][] est une version de maintenance de ce logiciel de
  nœud LN populaire qui contient plusieurs corrections de bogues.

- [Core Lightning 23.05rc1][] est une version candidate pour la prochaine
  version de ce nœud LN.

## Changements notables dans le code et la documentation

*Changements notables cette semaine dans [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo], et
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [Bitcoin Core #27358][] met à jour le script `verify.py` pour automatiser
  le processus de vérification des fichiers pour une version de Bitcoin Core.
  Un utilisateur importe les clés PGP des signataires en qui il a confiance.
  Le script télécharge la liste des fichiers dont la somme de contrôle a été
  vérifiée pour une version et les signatures des personnes qui se sont engagées
  à respecter ces sommes de contrôle. Le script vérifie ensuite au moins *k*
  des signataires de confiance qui se sont engagés à respecter ces sommes de
  contrôle, l'utilisateur pouvant choisir le nombre de *k* signataires dont
  il a besoin. Si suffisamment de signatures valides de signataires de confiance
  ont été trouvées, le script télécharge les fichiers pour que l'utilisateur
  puisse installer cette version de Bitcoin Core. Pour plus de détails, voir
  la [documentation][verify docs]. Le script n'est pas nécessaire pour utiliser
  Bitcoin Core et ne fait qu'automatiser un processus que les utilisateurs
  sont encouragés à effectuer eux-mêmes avant d'utiliser des fichiers sensibles
  à la sécurité téléchargés sur Internet.

- [Core Lightning #6120][] améliore sa logique de [remplacement de transaction][topic rbf],
y compris la mise en œuvre d'un ensemble de règles pour déterminer quand il
faut automatiquement supprimer les frais RBF d'une transaction et rediffuser
périodiquement les transactions non confirmées pour s'assurer qu'elles sont
relayées (voir [Bulletin #243][news243 rebroadcast]).

- [Eclair #2584][] ajoute la prise en charge du [splicing][topic splicing],
  à la fois les épissures qui ajoutent des fonds à un canal existant et les
  épissures qui envoient des fonds d'un canal vers une destination sur la chaîne.
  Le PR note qu'il y a quelques différences dans la mise en œuvre par rapport
  à l'actuel [projet de spécification] [bolts #863].

{% include references.md %}
{% include linkers/issues.md v=2 issues="27358,6120,2584,863" %}
[bdk 1.0.0-alpha.0]: https://github.com/bitcoindevkit/bdk/releases/tag/v1.0.0-alpha.0
[orlovsky rgb]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-April/021554.html
[tenga rgb]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-April/021558.html
[rgb-lightning-sample]: https://github.com/RGB-Tools/rgb-lightning-sample
[ldk-sample]: https://github.com/lightningdevkit/ldk-sample
[rgb.tech]: https://rgb.tech/
[rgb.info ln]: https://docs.rgb.info/lightning-network-compatibility
[verify docs]: https://github.com/theuni/bitcoin/blob/754fb6bb8125317575edec7c20b5617ad27a9bdd/contrib/verifybinaries/README.md
[news243 rebroadcast]: /fr/newsletters/2023/03/22/#lnd-7448
[rgb blog]: https://rgb.tech/blog/release-v0-10/
[bdk 0.28.0]: https://github.com/bitcoindevkit/bdk/releases/tag/v0.28.0
[Core Lightning 23.02.2]: https://github.com/ElementsProject/lightning/releases/tag/v23.02.2
[Core Lightning 23.05rc1]: https://github.com/ElementsProject/lightning/releases/tag/v23.05rc1
[bibliothèque du portefeuille Descriptor]: https://github.com/BP-WG/descriptor-wallet
[Descriptor Wallet v0.9.2]: https://github.com/BP-WG/descriptor-wallet/releases/tag/v0.9.2
[stratum blog]: https://stratumprotocol.org/blog/stratumv2-jn-announcement/
[liana 0.4]: https://wizardsardine.com/blog/liana-0.4-release/
[coldcard firmware]: https://coldcard.com/docs/upgrade
[wiki sighash]: https://en.bitcoin.it/wiki/Contract#SIGHASH_flags
[zeus v0.7.4]: https://github.com/ZeusLN/zeus/releases/tag/v0.7.4
[floresta blog]: https://medium.com/vinteum-org/introducing-floresta-an-utreexo-powered-electrum-server-implementation-60feba8e179d
[se107154]: https://bitcoin.stackexchange.com/questions/107154/what-is-the-control-block-in-taproot
