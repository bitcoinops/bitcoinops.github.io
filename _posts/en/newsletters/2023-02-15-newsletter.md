---
title: 'Bitcoin Optech Newsletter #238'
permalink: /en/newsletters/2023/02/15/
name: 2023-02-15-newsletter
slug: 2023-02-15-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes continued discussion about storing
data in the Bitcoin block chain, describes a hypothetical fee dilution
attack against some types of multiparty protocols, and describes how a
tapscript signature commitment can be used with different parts of the
same tree.  Also included are our regular sections with summaries of
changes to services and client software, announcements of new releases
and release candidates, and descriptions of notable changes to popular
Bitcoin infrastructure software.  We additionally provide one of our
rare recommendations for a new search engine focused on Bitcoin
technical documentation and discussion.

## News

- **Continued discussion about block chain data storage:** several
  threads on the Bitcoin-Dev mailing list this week saw continued
  discussion about storing data in the block chain.

    - *Offchain coin coloring:* Anthony Towns [posted][towns color] a
      summary of a protocol currently being used for assigning special
      meaning to certain transaction outputs, a class of techniques
      generally called *coin coloring*.  He also summarized a related
      protocol used for storing encoded binary data in Bitcoin
      transactions and associating it with particular colored coins.
      After summarizing the current state of affairs, he described a
      method for storing data using the [nostr][] message transfer
      protocol and associating it with colored coins that could be
      transferred in Bitcoin transactions.  This would have several
      advantages:

      - *Reduced costs:* no transaction fees need to be paid for data
        stored offchain.

      - *Private:* two people can exchange a colored coin without
        anyone else knowing anything about the data it references.

      - *No transaction required for creation:* data can be associated
        with an existing UTXO; there's no need to create a new UTXO.

      - *Resistant against censorship:* if the association between the data
        and the colored coin is not widely known, then transfers of
        the colored coin are just as censorship resistant as any other
        onchain Bitcoin payment.

      Considering the censorship resistant aspect, Towns argues that
      "coloured bitcoins is largely unavoidable and simply something that
      must be dealt with, rather than something we should spend time
      trying to prevent/avoid."  He compares the idea that colored coins
      might have more value than fungible bitcoins to the operation of
      Bitcoin charging transaction fees based on transaction weight
      rather than value transferred, concluding that he doesn't believe
      this necessarily leads to significantly misaligned incentives.

    - *Increasing allowed `OP_RETURN` space in standard transactions:*
      Christopher Allen [asked][allen op_return] whether it was better
      to put arbitrary data in a transaction output using `OP_RETURN` or
      the witness data of a transaction.  After some discussion, several
      participants ([1][todd or], [2][o'connor or], [3][poelstra or])
      noted that they were in favor of relaxing default transaction
      relay and mining policies to allow `OP_RETURN` outputs to store
      more than 83 bytes of arbitrary data.  They reasoned that other
      methods for storing large amounts of data are currently in use and
      there would be no additional harm from `OP_RETURN` being used
      instead.

- **Fee dilution in multiparty protocols:** Yuval Kogman
  [posted][kogman dilution] to the Bitcoin-Dev mailing list the
  description of an attack against certain multiparty protocols.
  Although the attack was [previously described][riard dilution],
  Kogman's post brought renewed attention to it.  Imagine that Mallory
  and Bob each contribute one input to a joint transaction with an
  expected size and fee, implying an expected feerate.  Bob provides a
  witness of the expected size for his input but Mallory provides a much
  larger witness than expected.  This effectively decreases the feerate
  for the transaction.  Several implications of this were discussed on
  the mailing list:

    - *Mallory gets Bob to pay her fees:* if Mallory has some ulterior
      motive for including a large witness in the block chain---for
      example, she wants to add arbitrary data---she can use part of Bob's fee to pay
      the fees for that.  For example, Bob wants to create a 1,000 vbyte
      transaction with a 10,000 satoshi fee, paying 10 sat/vbyte so it
      confirms quickly.  Mallory stuffs the transaction with 9,000
      vbytes of data Bob didn't expect, reducing its feerate to 1
      sat/vbyte.  Although Bob pays the same absolute fee in both cases,
      he doesn't get what he wanted (fast confirmation) and Mallory gets
      9,000 sats worth of data added to the block chain at no cost to
      her.

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
   opened a [pull request][bitcoin inquisition #19] to the Bitcoin
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
[todd or]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-February/021435.html
[o'connor or]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-February/021439.html
[poelstra or]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-February/021438.html
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
