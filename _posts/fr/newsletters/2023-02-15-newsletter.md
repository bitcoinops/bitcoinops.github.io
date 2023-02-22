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
      Par exemple, Bob veut créer une transaction de 1 000 vbyte avec des frais
      de 10 000 satoshi, en payant 10 sat/vbyte pour qu'elle soit confirmée
      rapidement. Mallory bourre la transaction de 9 000 vbytes de données que
      Bob n'attendait pas, ce qui réduit son tarif à 1 sat/vbyte. Bien que Bob
      paie les mêmes frais absolus dans les deux cas, il n'obtient pas ce qu'il
      voulait (confirmation rapide) et Mallory obtient 9 000 sats de données
      ajoutées à la chaîne de blocs sans frais pour elle.

    - *Mallory can slow confirmation:* a transaction with a lower 
      feerate may confirm more slowly.  In a time-sensitive protocol, this
      could cause a serious problem for Bob.  In other cases, Bob might
      need to fee bump the transaction, which will cost him additional
      money.

  Kogman describes several mitigations in his post, although all of them
  involve tradeoffs.  In a [second post][kogman dilution2], he notes
  that he's unaware of any currently deployed protocol that's
  vulnerable.

- **Tapscript signature malleability:** in an aside to the above-mentioned
  conversation about fee dilution, developer Russell O'Connor
  [noted][o'connor tsm] that signatures for a [tapscript][topic
  tapscript] can be applied to a copy of the tapscript placed elsewhere
  in the taproot tree.  For example, the same tapscript *A* is placed in
  two different places in a taproot tree.  To use the deeper alternative
  will require placing an additional 32 byte hash in the witness data of
  the spending transaction.

    ```text
      *
     / \
    A   *
       / \
      A   B
    ```

   That means that even if Mallory provides Bob with a valid witness for
   her tapscript spend before Bob provides his own signature, it's
   still possible for Mallory to broadcast an alternative version of the
   transaction with a larger witness.  Bob can only prevent this issue
   by receiving from Mallory a complete copy of her tree of tapscripts.

   In the context of future soft fork upgrades to Bitcoin, Anthony Towns
   opened an [issue][bitcoin inquisition #19] to the Bitcoin
   Inquisition repository being used to test [SIGHASH_ANYPREVOUT][topic
   sighash_anyprevout] (APO) to consider having APO commit to additional
   data to prevent this issue for users of that extension.

## Changes to services and client software

*In this monthly feature, we highlight interesting updates to Bitcoin
wallets and services.*

- **Liana wallet adds multisig:**
  [Liana][news234 liana]'s [0.2 release][liana 0.2] adds multisig support using
  [descriptors][topic descriptors].

- **Sparrow wallet 1.7.2 released:**
  Sparrow's [1.7.2 release][sparrow 1.7.2] adds [taproot][topic taproot]
  support, [BIP329][] import and export features (see [Newsletter #235][news235
  bip329]), and additional support for hardware signing devices.

- **Bitcoinex library adds schnorr support:**
  [Bitcoinex][bitcoinex github] is a Bitcoin utility library for the Elixir functional programming language.

- **Libwally 0.8.8 released:**
  [Libwally 0.8.8][] adds [BIP340][] tagged hash support, additional sighash
  support including [BIP118][] ([SIGHASH_ANYPREVOUT][topic SIGHASH_ANYPREVOUT]), and
  additional [miniscript][topic miniscript], descriptor, and [PSBT][topic psbt] functions.

## Optech Recommends

[BitcoinSearch.xyz][] is a recently-launched search engine for Bitcoin
technical documentation and discussions.  It was used to quickly find
several of the sources linked in this newsletter, a vast improvement
over other more laborious methods we've previously used.  Contributions
to its [code][bitcoinsearch repos] are welcome.

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [Core Lightning 23.02rc2][] is a release candidate for a new
  maintenance version of this popular LN implementation.

- [BTCPay Server 1.7.11][] is a new release.  Since the last release we
  covered (1.7.1), several new features have been added and many bug
  fixes and improvements have been made.  Especially notable, several
  aspects related to plugins and third-party integrations have been
  changed, a migration path away from legacy MySQL and SQLite has been
  added, and a cross-site scripting vulnerability has been fixed.

- [BDK 0.27.0][] is an update to this library for building Bitcoin
  wallets and applications.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Core Lightning #5361][] adds experimental support for peer storage
  backups.  As last mentioned in [Newsletter #147][news147 backups],
  this allows a node to store a small encrypted backup file for its
  peers.  If a peer later needs to reconnect, perhaps after losing data,
  it can request the backup file.  The peer can use a key derived from
  its wallet seed to decrypt the file and use the contents to recover
  the latest state of all of its channels.  This can be seen as an
  enhanced form of [static channel backups][topic static channel
  backups].  The merged PR adds support for creating, storing, and retrieving
  the encrypted backups.  As noted in the commit messages, the feature
  hasn't yet been fully specified or adopted by other LN
  implementations.

- [Core Lightning #5670][] and [#5956][core lightning #5956] make
  various updates to its implementation of [dual funding][topic dual
  funding] based on both recent changes to the [specification][bolts
  #851] and comments from interoperability testers.  Additionally, an
  `upgradewallet` RPC is added to move all funds in P2SH-wrapped outputs
  to native segwit outputs, which is required for interactive channel
  opens.

- [Core Lightning #5697][] adds a `signinvoice` RPC that will sign a
  [BOLT11][] invoice.  Previously, CLN would only sign an invoice when
  it had the preimage for the [HTLC][topic HTLC] hash, ensuring it would
  be able to claim a payment to the invoice.  This RPC can override
  that behavior, which could (for example) be used to send an invoice
  now and later use a plugin to retrieve the preimage from another
  program.  Anyone using this RPC should be aware that any third party
  that has prior knowledge of the preimage for a payment intended for
  your node can claim that payment before it arrives.  That not only
  steals your money but, because you signed the invoice, generates very
  convincing evidence that you were paid (this evidence is so convincing
  that many LN developers call it *proof of payment*).

- [Core Lightning #5960][] adds a [security policy][cln security.md]
  that includes contact addresses and PGP keys.

- [LND #7171][] upgrades the `signrpc` RPC <!--sic--> to support the
  latest [draft BIP][musig draft bip] for [MuSig2][topic musig].  The RPC now creates
  sessions linked to a MuSig2 protocol version number so that all
  operations within a session will use the correct protocol.  A
  security issue with an older version of the MuSig2 protocol was
  mentioned in [Newsletter #222][news222 musig2].

- [LDK #2002][] adds support for automatically resending [spontaneous
  payments][topic spontaneous payments] that don't initially succeed.

- [BTCPay Server #4600][] updates the [coin selection][topic coin selection] for its [payjoin][topic payjoin]
  implementation to try to avoid creating transactions with *unnecessary
  inputs*, specifically an input that is larger than any output in a
  transaction containing multiple inputs.  That would not happen with a
  regular single-spender, single-receiver payment: the largest input
  would have provided sufficient payment for the payment output and no
  additional inputs would have been added.
  This PR was partly inspired by a [paper analyzing payjoins][].

{% include references.md %}
{% include linkers/issues.md v=2 issues="5361,5670,5956,851,5697,5960,7171,2002,4541,4600" %}
[news147 backups]: /en/newsletters/2021/05/05/#closing-lost-channels-with-only-a-bip32-seed
[cln security.md]: https://github.com/ElementsProject/lightning/blob/master/SECURITY.md
[news222 musig2]: /en/newsletters/2022/10/19/#musig2-security-vulnerability
[musig draft bip]: https://github.com/jonasnick/bips/blob/musig2/bip-musig2.mediawiki
[paper analyzing payjoins]: https://eprint.iacr.org/2022/589.pdf
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
