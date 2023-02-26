---
title: 'Bulletin hebdomadaire Bitcoin Optech #238'
permalink: /fr/newsletters/2023/02/15/
name: 2023-02-15-newsletter-fr
slug: 2023-02-15-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine récapitule la suite des discussions sur
le stockage des données dans la chaîne de blocs Bitcoin, décrit une
attaque hypothétique de dilution des frais contre certains types de
protocoles multipartites, et décrit comment un engagement de signature
tapscript peut être utilisé avec différentes parties du même arbre.
Nous avons également inclus nos sections habituelles avec des résumés
des changements apportés aux services et aux logiciels clients, des
annonces de nouvelles versions et de versions candidates, et des
descriptions de principaux changements apportés aux logiciels
d'infrastructure Bitcoin les plus répandus. Nous fournissons en outre
l'une de nos rares recommandations pour un nouveau moteur de recherche
axé sur la documentation technique et les discussions sur Bitcoin.

## Nouvelles

- **Poursuite de la discussion sur le stockage des données de la chaîne de blocs :**
  Cette semaine, plusieurs fils de discussion sur la liste de diffusion Bitcoin-Dev
  ont vu se poursuivre les discussions sur le stockage des données dans la chaîne de blocs.

    - *Coloration des pièces hors chaîne :* Anthony Towns [a publié][towns color]
      un résumé d'un protocole actuellement utilisé pour attribuer une signification
      particulière à certains résultats de transaction, une catégorie de techniques
      généralement appelée *coin coloring*. Il a également résumé un protocole
      connexe utilisé pour stocker des données binaires codées dans les transactions
      Bitcoin et les associer à des pièces de couleur particulières. Après avoir
      résumé l'état actuel des choses, il a décrit une méthode permettant de stocker
      des données à l'aide du protocole de transfert de messages [nostr][] et de
      les associer à des pièces colorées qui pourraient être transférées dans des
      transactions Bitcoin. Cette méthode présenterait plusieurs avantages :

      - *Réduction des coûts :* aucun frais de transaction ne doit être payé pour
        les données stockées hors chaîne.

      - *Privé :* deux personnes peuvent échanger une pièce de monnaie colorée
        sans que personne d'autre ne sache rien des données qu'elle référence.

      - *Aucune transaction requise pour la création :* Les données peuvent être
        associées à un UTXO existant ; il n'est pas nécessaire de créer
        un nouvel UTXO.

      - *Résistant à la censure :* si l'association entre les données et la
        pièce colorée n'est pas largement connue, alors les transferts de la
        pièce colorée sont tout aussi résistants à la censure que n'importe
        quel autre paiement Bitcoin onchain.

      Considérant l'aspect de résistance à la censure, Towns soutient que
      "les bitcoins colorés sont largement inévitables et simplement quelque
      chose avec lequel il faut composer, plutôt que quelque chose que nous
      devrions passer du temps à essayer de prévenir/éviter." Il compare
      l'idée que les pièces colorées pourraient avoir plus de valeur que
      les bitcoins fongibles au fonctionnement du bitcoin qui facture les
      frais de transaction en fonction du poids de la transaction plutôt
      que de la valeur transférée, et conclut qu'il ne pense pas que cela
      conduise nécessairement à des incitations significativement désalignées.

    - *Augmentation de l'espace `OP_RETURN` autorisé dans les transactions standard:*
      Christopher Allen [a demandé][allen op_return] s'il était préférable
      de mettre des données arbitraires dans une sortie de transaction en
      utilisant `OP_RETURN` ou les données témoins d'une transaction. Après
      quelques discussions, plusieurs participants ([1][todd ou], [2][o'connor ou],
      [3][poelstra ou]) ont noté qu'ils étaient en faveur d'un assouplissement
      des politiques de relais de transaction et d'extraction par défaut
      pour permettre aux sorties `OP_RETURN` de stocker plus de 83 octets
      de données arbitraires. Ils ont estimé que d'autres méthodes pour
      stocker de grandes quantités de données sont actuellement utilisées
      et qu'il n'y aurait pas de préjudice supplémentaire à utiliser
      `OP_RETURN` à la place.

- **Dilution des frais dans les protocoles multipartites :** Yuval Kogman
  a [posté][kogman dilution] sur la liste de diffusion Bitcoin-Dev la
  description d'une attaque contre certains protocoles multipartites.
  Bien que l'attaque ait été [précédemment décrite][riard dilution],
  le message de Kogman a attiré de nouveau l'attention sur elle. Imaginez
  que Mallory et Bob contribuent chacun à une transaction commune avec
  une taille et des frais attendus, ce qui implique un taux d'erreur
  attendu. Bob fournit un témoin de la taille attendue pour son entrée
  mais Mallory fournit un témoin beaucoup plus grand que prévu. Cela
  diminue effectivement le taux d'erreur pour la transaction. Plusieurs
  implications de cette situation ont été discutées sur la liste de diffusion :

    - *Mallory demande à Bob de payer ses frais :* si Mallory a une
      motivation ultérieure pour inclure un grand témoin dans la chaîne
      de blocs---par exemple, elle veut ajouter des données arbitraires---elle
      peut utiliser une partie des frais de Bob pour payer les frais correspondants.
      Par exemple, Bob veut créer une transaction de 1 000 vbytes avec des frais
      de 10 000 satoshis, en payant 10 sat/vbyte pour qu'elle soit confirmée
      rapidement. Mallory bourre la transaction de 9 000 vbytes de données que
      Bob n'attendait pas, ce qui réduit son tarif à 1 sat/vbyte. Bien que Bob
      paie les mêmes frais absolus dans les deux cas, il n'obtient pas ce qu'il
      voulait (confirmation rapide) et Mallory obtient 9 000 sats de données
      ajoutées à la chaîne de blocs sans frais pour elle.

    - *Mallory peut ralentir la confirmation :* une transaction avec un taux
      de frais inférieur peut être confirmée plus lentement. Dans un protocole
      sensible au temps, cela pourrait causer un sérieux problème à Bob.
      Dans d'autres cas, Bob peut avoir besoin de faire payer la transaction,
      ce qui lui coûtera de l'argent supplémentaire.

  Kogman décrit plusieurs mesures d'atténuation dans son article, bien qu'elles
  impliquent toutes des compromis. Dans un [deuxième article][kogman dilution2],
  il indique qu'il n'a connaissance d'aucun protocole actuellement déployé
  qui soit vulnérable.

- **Malléabilité de la signature Tapscript :** en marge de la conversation
  susmentionnée sur la dilution des frais, le développeur Russell O'Connor
  [remarque][o'connor tsm] que les signatures pour un [tapscript][topic tapscript]
  peuvent être appliquées à une copie du tapscript placée ailleurs dans l'arbre
  taproot. Par exemple, le même tapscript *A* est placé à deux endroits différents
  dans un arbre taproot. Pour utiliser l'alternative plus profonde, il faudra
  placer un hachage supplémentaire de 32 octets dans les données témoins de
  la transaction de dépense.

    ```text
      *
     / \
    A   *
       / \
      A   B
    ```

   Cela signifie que même si Mallory fournit à Bob un témoin valide pour
   sa dépense de tapscript avant que Bob ne fournisse sa propre signature,
   il est toujours possible pour Mallory de diffuser une version alternative
   de la transaction avec un témoin plus important. Bob ne peut éviter
   ce problème qu'en recevant de Mallory une copie complète de son arbre
   de tapscripts.

   Dans le contexte des futures mises à jour de l'embranchement convergent
   de Bitcoin, Anthony Towns a ouvert une [issue][bitcoin inquisition #19]
   au dépôt de Bitcoin Inquisition utilisé pour tester [SIGHASH_ANYPREVOUT][topic
   sighash_anyprevout] (APO) pour envisager qu'APO s'engage à fournir des
   données supplémentaires afin d'éviter ce problème pour les utilisateurs
   de cette extension.

## Modifications apportées aux services et aux logiciels clients

*Dans cette rubrique mensuelle, nous mettons en évidence les mises à jour
intéressantes des portefeuilles et services Bitcoin.*

- **Le porte-monnaie Liana ajoute le multisig :**
  La [version 0.2][liana 0.2] de [Liana][news234 liana] ajoute le support du
  multisig à l'aide de [descripteurs][topic descriptors].

- **Sortie de la version 1.7.2 de Sparrow wallet :**
  La [version 1.7.2][sparrow 1.7.2] de Sparrow ajoute la prise en charge de
  [taproot][topic taproot], des fonctionnalités d'importation et d'exportation
  [BIP329][] (voir le [bulletin #235][news235 bip329]), ainsi que l'ajout de
  la prise en charge des dispositifs de signature matérielle.

- **La bibliothèque Bitcoinex ajoute le support de schnorr :**
  [Bitcoinex][bitcoinex github] est une bibliothèque utilitaire Bitcoin pour le
  langage de programmation fonctionnel Elixir.

- **Sortie de Libwally 0.8.8 :**
  [Libwally 0.8.8][] ajoute le support des hachages balisés [BIP340][],
  le support supplémentaire de sighash incluant [BIP118][] ([SIGHASH_ANYPREVOUT][topic
  SIGHASH_ANYPREVOUT]), et des fonctions supplémentaires [miniscript][topic miniscript],
  descripteur, et [PSBT][topic psbt].

## Optech recommande

[BitcoinSearch.xyz][] est un moteur de recherche récemment lancé pour la
documentation technique et les discussions sur le bitcoin. Il a été utilisé
pour trouver rapidement plusieurs des sources liées dans ce bulletin, ce qui
représente une grande amélioration par rapport aux méthodes plus laborieuses
que nous utilisions auparavant. Les contributions à son [code][bitcoinsearch
repos] sont les bienvenues.

## Mises à jour et versions candidates

*Nouvelles versions et versions candidates pour les principaux projets
d'infrastructure Bitcoin. Veuillez envisager de passer aux nouvelles
versions ou d'aider à tester les versions candidates.*

- [Core Lightning 23.02rc2][] est une version candidate pour une
  nouvelle version de maintenance de cette implémentation populaire de LN.

- [BTCPay Server 1.7.11][] est une nouvelle version. Depuis la dernière
  version que nous avons couverte (1.7.1), plusieurs nouvelles fonctionnalités
  ont été ajoutées et de nombreuses corrections de bogues et améliorations ont
  été apportées. En particulier, plusieurs aspects liés aux plugins et aux
  intégrations tierces ont été modifiés, un chemin de migration pour s'éloigner
  des anciennes versions de MySQL et de SQLite a été ajouté, et une vulnérabilité
  aux scripts intersites a été corrigée.

- [BDK 0.27.0][] est une mise à jour de cette bibliothèque permettant
  de créer des portefeuilles et des applications Bitcoin.

## Principaux changements de code et de documentation

*Changements notables cette semaine dans [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], et [Lightning BOLTs][bolts repo].*

- [Core Lightning #5361][] ajoute un support expérimental pour les
  sauvegardes de stockage entre pairs. Comme mentionné dans le [bulletin
  n°147][news147 backups], cela permet à un nœud de stocker un petit
  fichier de sauvegarde crypté pour ses pairs. Si un pair a besoin de
  se reconnecter plus tard, peut-être après avoir perdu des données,
  il peut demander le fichier de sauvegarde. Le pair peut utiliser une
  clé dérivée de sa graine de portefeuille pour déchiffrer le fichier
  et utiliser le contenu pour récupérer le dernier état de tous ses canaux.
  Ceci peut être vu comme une forme améliorée de [sauvegardes statiques
  de canaux][topic static channel backups]. Le PR fusionné ajoute le
  support pour créer, stocker et récupérer les sauvegardes cryptées.
  Comme indiqué dans les messages de validation, cette fonctionnalité
  n'a pas encore été entièrement spécifiée ou adoptée par d'autres
  implémentations de LN.

- [Core Lightning #5670][] et [#5956][core lightning #5956] apporte
  diverses mises à jour à son implémentation du [double financement][topic
  dual funding] sur la base des récents changements apportés à la
  [spécification][bolts #851] et des commentaires des testeurs
  d'interopérabilité. En outre, un RPC `upgradewallet` est ajouté
  pour déplacer tous les fonds dans les sorties P2SH enveloppées
  vers les sorties segwit natives, ce qui est nécessaire pour les
  ouvertures de canaux interactifs.

- [Core Lightning #5697][] ajoute un RPC `signinvoice` qui signera
  une facture [BOLT11][]. Auparavant, CLN ne signait une facture que
  lorsqu'il avait la préimage du hachage [HTLC][topic HTLC], s'assurant
  ainsi de pouvoir réclamer un paiement pour la facture. Ce RPC permet
  d'ignorer ce comportement, ce qui pourrait (par exemple) être utilisé
  pour envoyer une facture maintenant et utiliser plus tard un plugin
  pour récupérer la préimage à partir d'un autre programme. Toute personne
  utilisant ce RPC doit savoir que toute tierce partie ayant connaissance
  de la préimage d'un paiement destiné à votre noeud peut réclamer ce
  paiement avant qu'il n'arrive. Cela ne fait pas que voler votre argent
  mais, parce que vous avez signé la facture, cela génère une preuve très
  convaincante que vous avez été payé (cette preuve est si convaincante
  que de nombreux développeurs LN l'appellent *preuve de paiement*).

- [Core Lightning #5960][] ajoute une [politique de sécurité][cln security.md]
  qui inclut les adresses de contact et les clés PGP.

- [LND #7171][] met à jour le RPC `signrpc` <!--sic--> pour supporter
  le dernier [projet de BIP][musig draft bip] pour [MuSig2][topic musig].
  Le RPC crée maintenant des sessions liées à un numéro de version du
  protocole MuSig2 afin que toutes les opérations au sein d'une session
  utilisent le bon protocole. Un problème de sécurité avec une ancienne
  version du protocole MuSig2 a été mentionné dans le [bulletin #222][news222 musig2].

- [LDK #2002][] ajoute la possibilité de renvoyer automatiquement  au départ
  les [paiements spontanés][topic spontaneous payments] qui n'ont pas abouti.

- [BTCPay Server #4600][] met à jour la [sélection de pièces][topic coin selection]
  pour son implémentation de [payjoin][topic payjoin] pour essayer d'éviter de créer
  des transactions avec des *entrées inutiles*, spécifiquement une entrée qui est
  plus grande que toute sortie dans une transaction contenant plusieurs entrées.
  Cela ne se produirait pas avec un paiement ordinaire à un seul expéditeur et un
  seul destinataire : l'entrée la plus importante aurait fourni un paiement suffisant
  pour la sortie du paiement et aucune entrée supplémentaire n'aurait été ajoutée.
  Ce PR a été en partie inspiré par un [article analysant les payjoins][].

{% include references.md %}
{% include linkers/issues.md v=2 issues="5361,5670,5956,851,5697,5960,7171,2002,4541,4600" %}
[news147 backups]: /en/newsletters/2021/05/05/#closing-lost-channels-with-only-a-bip32-seed
[cln security.md]: https://github.com/ElementsProject/lightning/blob/master/SECURITY.md
[news222 musig2]: /en/newsletters/2022/10/19/#musig2-security-vulnerability
[musig draft bip]: https://github.com/jonasnick/bips/blob/musig2/bip-musig2.mediawiki
[article analysant les payjoins]: https://eprint.iacr.org/2022/589.pdf
[bitcoinsearch repos]: https://github.com/bitcoinsearch
[towns color]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-February/021396.html
[nostr]: https://github.com/nostr-protocol/nostr
[allen op_return]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-February/021387.html
[todd ou]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-February/021435.html
[o'connor ou]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-February/021439.html
[poelstra ou]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-February/021438.html
[kogman dilution]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-February/021444.html
[riard dilution]: https://gist.github.com/ariard/7e509bf2c81ea8049fd0c67978c521af#witness-malleability
[kogman dilution2]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-February/021459.html
[o'connor tsm]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-February/021452.html
[bitcoin inquisition #19]: https://github.com/bitcoin-inquisition/bitcoin/issues/19
[bitcoinsearch.xyz]: https://bitcoinsearch.xyz/
[core lightning 23.02rc2]: https://github.com/ElementsProject/lightning/releases/tag/v23.02rc2
[BTCPay Server 1.7.11]: https://github.com/btcpayserver/btcpayserver/releases/tag/v1.7.11
[bdk 0.27.0]: https://github.com/bitcoindevkit/bdk/releases/tag/v0.27.0
[news234 liana]: /en/newsletters/2023/01/18/#liana-wallet-released
[liana 0.2]: https://github.com/wizardsardine/liana/releases/tag/0.2
[sparrow 1.7.2]: https://github.com/sparrowwallet/sparrow/releases/tag/1.7.2
[news235 bip329]: /en/newsletters/2023/01/25/#bips-1383
[bitcoinex github]: https://github.com/RiverFinancial/bitcoinex
[libwally 0.8.8]: https://github.com/ElementsProject/libwally-core/releases/tag/release_0.8.8
