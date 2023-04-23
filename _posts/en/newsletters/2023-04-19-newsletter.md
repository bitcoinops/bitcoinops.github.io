---
title: 'Bitcoin Optech Newsletter #247'
permalink: /en/newsletters/2023/04/19/
name: 2023-04-19-newsletter
slug: 2023-04-19-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter provides an update on development of the RGB
protocol and includes our regular sections that summarize recent updates
to clients and services, announce new releases and release candidates,
and describe notable changes to popular Bitcoin infrastructure software.

## News

- **RGB update:** Maxim Orlovsky [posted][orlovsky rgb] to the
  Bitcoin-Dev mailing list with an update on the state of RGB
  development.  RGB is a protocol that uses Bitcoin transactions to
  perform state updates in offchain contracts.  A simple example
  involves the creation and transfer of tokens, although RGB is designed
  for more purposes than just token transfer.

  - Offchain, Alice creates a contract whose initial state assigns 1,000
    tokens to a certain UTXO which she controls.

  - Bob wants 400 of the tokens.  Alice gives him a copy of the original
    contract plus a transaction that spends her UTXO a new output.
    That output contains a non-public commitment to the new contract
    state.  The new contract state specifies the distribution of amounts
    (400 to Bob; 600 back to Alice) and the identifiers for two outputs
    which will control those amounts.  Alice broadcasts the transaction.
    The security of this token transfer against double spending is now
    equal to that of Alice's Bitcoin transaction, e.g.
    when her transaction has six confirmations, the token transfer will
    be secure against a fork of up to six blocks.

      The outputs which control the amounts don't need to be outputs of
      the transaction containing the commitment (though that would be
      allowed).  This eliminates the ability to use onchain transaction
      analysis to track RGB-based transfers.  The tokens could have been
      transferred to any existing UTXO---or to any UTXO that the
      receiver knows will exist in the future (e.g. a presigned spend
      from their cold wallet which may not appear onchain for years).
      The bitcoin value of the various outputs, and their other
      characteristics, are irrelevant to the RGB protocol, although
      Alice and Bob will want to ensure they're easy to spend.

  - Later, Carol wants to buy 100 tokens from Bob in an atomic swap
    using a single onchain transaction.  She generates an unsigned PSBT
    which funds the transaction
    from her inputs, pays Bob bitcoin via an output, and returns the bitcoin
    change to herself with a second output.  One of those outputs also
    commits to the amounts and UTXO identifiers where she will receive
    her tokens and Bob will receive his token change.

      Bob provides Carol with the original contract and the commitment
      Alice previously created that proves Bob now controls 400 tokens.
      Bob doesn't need to know what Alice did with her remaining 600 tokens
      and Alice has no involvement in the exchange between Bob and
      Carol.  This provides both privacy and scalability.  Bob updates
      the PSBT with a signed input for the UTXO controlling the tokens.

      Carol verifies the original contract and the history of previous
      state updates.  She also ensures that everything else in the PSBT
      is correct.  She provides her signature and broadcasts the
      transaction.

  Although each of the example transfers above was made onchain, it's
  straightforward to modify the protocol to operate offchain.  Carol
  gives Dan a copy of the contract along with the history of state
  updates leading to her receiving 100 tokens.  She and Dan then
  coordinate to create an output that receives the 100 tokens and that
  requires signatures from both of them to spend.  Offchain, they
  transfer the tokens back and forth by generating many different
  versions of a transaction that spends the multisignature output, with
  each offchain spend committing to the distribution of tokens and the
  identifiers of the outputs which will receive those tokens.  Finally,
  one of them broadcasts one of the spending transactions, putting the state
  onchain.

  The outputs to which the tokens were assigned may be encumbered by a
  Bitcoin script that determines who will ultimately control the tokens.
  For example, they may pay an [HTLC][topic htlc] script that gives
  Carol the ability to spend the tokens at any time if she can provide a
  preimage and her signature, or which gives Dan the ability to spend
  the tokens with just his signature after a time lock expires.  This
  allows the tokens to be used in forwarded offchain payments, such as
  those used in LN.

  In a [reply][tenga rgb] to the thread, Federico Tenga linked to a
  RGB-based [LN node][rgb-lightning-sample] based on a fork of [LDK][ldk
  repo] and that project's [LDK sample][ldk-sample] node.  Following
  links in that project, we found useful [additional
  information][rgb.info ln] about LN compatibility.  More information
  about the RGB protocol may be found on a [website][rgb.tech] hosted by
  the LNP/BP Association.

  In this week's post, Orlovsky announced the [release][rgb blog] of RGB v0.10.
  Most significantly, the new version is not compatible with contracts
  created for previous versions (but there are no known commercial RGB
  contracts on mainnet).  The new design is intended to allow all new
  contracts to be upgraded over time for future changes in the protocol.
  A number of other improvements have also been implemented, and a
  roadmap for adding additional features is presented.

  As of this writing, the announcement had received a modest amount of
  discussion on the mailing list. {% assign timestamp="1:12" %}

## Changes to services and client software

*In this monthly feature, we highlight interesting updates to Bitcoin
wallets and services.*

- **Descriptor wallet library adds block explorer:**
  [Descriptor wallet library][] is a rust descriptor-based wallet library that
  builds upon rust-bitcoin and supports [miniscript][topic
  miniscript], [descriptors][topic descriptors], [PSBTs][topic psbt], and in
  recent [releases][Descriptor Wallet v0.9.2], a text-based [block
  explorer][topic block explorers] that parses and displays extended details of
  taproot [control blocks][se107154] from transaction input witnesses, as well as
  descriptors and miniscripts matching the transaction scripts. {% assign timestamp="36:02" %}

- **Stratum v2 reference implementation update announced:**
  The project [posted details][stratum blog] about the updates including the
  ability for miners in a pool to select transactions for a candidate block.
  Miners, pools, and mining firmware developers are encouraged to test and
  provide feedback. {% assign timestamp="38:02" %}

- **Liana 0.4 released:**
  Liana's [0.4 release][liana 0.4] adds support for multiple recovery paths and additional
  descriptors, enabling larger quorums. {% assign timestamp="42:35" %}

- **Coldcard firmware supports additional sighash flags:**
  Coldcard's [version 5.1.2 firmware][coldcard firmware] now supports all
  [signature-hash][wiki sighash] (sighash) types beyond `SIGHASH_ALL`, enabling
  advanced transacting possibilities. {% assign timestamp="46:12" %}

- **Zeus adds fee bumping features:**
  [Zeus v0.7.4][] adds fee bumping, utilizing [RBF][topic rbf] and [CPFP][topic
  cpfp], for onchain transactions including LN channel opening and LN channel
  closing transactions. Fee bumping is initially just supported with an LND backend. {% assign timestamp="45:09" %}

- **Utreexo-based Electrum Server announced:**
   [Floresta][floresta blog] is an Electrum protocol-compatible server that uses [utreexo][topic
   utreexo] to decrease the server's resource requirements. The software
   currently supports the [signet][topic signet] test network. {% assign timestamp="48:12" %}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [BDK 0.28.0][] is a maintenance release of this library for building
  Bitcoin-enabled applications. {% assign timestamp="53:08" %}

- [Core Lightning 23.02.2][] is a maintenance release of this popular LN
  node software that contains several bug fixes. {% assign timestamp="55:01" %}

- [Core Lightning 23.05rc1][] is a release candidate for the next
  version of this LN node. {% assign timestamp="55:40" %}

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo], and
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [Bitcoin Core #27358][] updates the `verify.py` script to automate the
  process of verifying the files for a Bitcoin Core release.  A user
  imports the PGP keys of signers they trust.  The script downloads the
  list of checksummed files for a release and the signatures of people
  who have committed to those checksums.  The script then verifies at
  least *k* of the trusted signers committed to those checksums, where
  the user can choose how many *k* signers they need.  If sufficient
  valid signatures from trusted signers were found, the script downloads
  the files so the user can install that version of Bitcoin Core.  For
  additional details, see the [documentation][verify docs].  The script
  is not required to use Bitcoin Core and does nothing but automate a
  process that users are encouraged to perform themselves before using
  security-sensitive files downloaded from the internet. {% assign timestamp="56:57" %}

- [Core Lightning #6120][] improves its [transaction replacement][topic
  rbf] logic, including implementing a set of rules for when to
  automatically RBF fee bump a transaction and periodically
  rebroadcasting unconfirmed transactions to ensure they're relayed (see
  [Newsletter #243][news243 rebroadcast]). {% assign timestamp="1:01:14" %}

- [Eclair #2584][] adds support for [splicing][topic splicing], both
  splice-ins which add funds to an existing channel and splice-outs
  which sends funds from a channel to an onchain destination.  The PR
  notes that there are some differences in the implementation from the
  current [draft specification][bolts #863]. {% assign timestamp="1:04:54" %}

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
[news243 rebroadcast]: /en/newsletters/2023/03/22/#lnd-7448
[rgb blog]: https://rgb.tech/blog/release-v0-10/
[bdk 0.28.0]: https://github.com/bitcoindevkit/bdk/releases/tag/v0.28.0
[Core Lightning 23.02.2]: https://github.com/ElementsProject/lightning/releases/tag/v23.02.2
[Core Lightning 23.05rc1]: https://github.com/ElementsProject/lightning/releases/tag/v23.05rc1
[Descriptor wallet library]: https://github.com/BP-WG/descriptor-wallet
[Descriptor Wallet v0.9.2]: https://github.com/BP-WG/descriptor-wallet/releases/tag/v0.9.2
[stratum blog]: https://stratumprotocol.org/blog/stratumv2-jn-announcement/
[liana 0.4]: https://wizardsardine.com/blog/liana-0.4-release/
[coldcard firmware]: https://coldcard.com/docs/upgrade
[wiki sighash]: https://en.bitcoin.it/wiki/Contract#SIGHASH_flags
[zeus v0.7.4]: https://github.com/ZeusLN/zeus/releases/tag/v0.7.4
[floresta blog]: https://medium.com/vinteum-org/introducing-floresta-an-utreexo-powered-electrum-server-implementation-60feba8e179d
[se107154]: https://bitcoin.stackexchange.com/questions/107154/what-is-the-control-block-in-taproot
