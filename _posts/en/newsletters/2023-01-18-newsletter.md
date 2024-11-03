---
title: 'Bitcoin Optech Newsletter #234'
permalink: /en/newsletters/2023/01/18/
name: 2023-01-18-newsletter
slug: 2023-01-18-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a proposal for new vault-specific
opcodes and includes our regular sections with summaries of interesting
updates to clients and services, announcements of new releases and
release candidates, and descriptions of notable changes to popular
Bitcoin infrastructure software.

## News

- **Proposal for new vault-specific opcodes:** James O'Beirne
  [posted][obeirne op_vault] to the Bitcoin-Dev mailing list a
  [proposal][obeirne paper] for a soft fork to add two new opcodes,
  `OP_VAULT` and `OP_UNVAULT`.

  - `OP_VAULT` would accept three parameters: a commitment to a
    highly trusted spending path, a [delay period][topic timelocks], and a commitment to
    a less trusted spending path.

  - `OP_UNVAULT` would also accept three parameters.  When used for
    the vaults O'Beirne envisions, these would be the same commitment
    to a highly trusted spending path, the same delay period, and a
    commitment to one or more outputs to include in a later
    transaction.

  To create a [vault][topic vaults], Alice chooses a highly trusted
  spending path, such as a multisig requiring she access several
  separate signing devices or cold wallets stored in separate
  locations.  She also chooses a less trusted spending path, such as a
  single signature from her regular hot wallet.  Finally, she chooses
  a delay period specified using the same data type as [BIP68][],
  which allows specifying times as short as a few minutes up to about
  a year.  With her parameters selected, Alice creates a normal
  Bitcoin address for receiving funds to her vault, with that address
  committing to a script using `OP_VAULT`.

  To spend funds previously received to her vault address, Alice would start by
  determining the outputs she ultimately wanted to pay (e.g. send a
  payment to Bob and return any change back to her vault).  In typical
  usage, Alice would fulfill the conditions of her less trusted
  spending path, such as providing a signature from her hot wallet,
  to create a transaction that pays all the vaulted funds to a single
  output.  That output contains `OP_UNVAULT` with the same parameters
  for the highly trusted spending path and delay.  The third parameter
  is a commitment to the outputs Alice ultimately wants to pay.  Alice
  finishes constructing the transaction---including attaching fees
  using [fee sponsorship][topic fee sponsorship], a type of [anchor
  output][topic anchor outputs], or another mechanism.

  Alice broadcasts her transaction and it is later included in a
  block.  This allows anyone to observe that an unvaulting attempt is
  in progress.  Alice's software detects that this is a spend of her
  vaulted funds and verifies that the third parameter of the
  `OP_UNVAULT` output of the confirmed transaction matches exactly the
  commitment Alice created earlier.  Assuming it matches, Alice now
  waits for the delay period to complete, after which Alice can
  broadcast a transaction that spends from the `OP_UNVAULT` UTXO to the
  outputs she committed to earlier (e.g. Bob and a change output).
  This would be a successful spend of Alice's funds using her less
  trusted path, e.g. using just her hot wallet.

  However, imagine that Alice's software sees the confirmed unvaulting
  attempt and doesn't recognize it.  In this case, her software has the
  opportunity during the delay period to freeze the funds.  It creates
  a transaction spending the `OP_UNVAULT` output to the highly trusted
  address which was the subject of the previous commitments.  As long
  as this freezing transaction confirms before the delay period ends,
  Alice's funds are secured against the compromise of her less trusted
  spending path.  After the funds have been transferred to Alice's
  highly trusted spending path, Alice can spend them at any time by
  satisfying the conditions of that path (e.g. using her cold
  wallets).

  Beyond proposing the new opcodes, O'Beirne also describes the
  motivation for vaults and analyzes other vault proposals, including
  those that are available on Bitcoin now using presigned transactions
  and those that would depend on other soft fork [covenant][topic
  covenants] proposals.  Several described advantages of the `OP_VAULT`
  proposal include:

  - *Smaller witnesses:* flexible covenant proposals, such as those
    using the proposed [OP_CHECKSIGFROMSTACK][topic
    op_checksigfromstack], would require that transaction witnesses
    for unvaulting transactions include copies of a significant amount
    of the data included elsewhere in the transaction, bloating the
    size and fee cost of those transactions.  `OP_VAULT` requires much
    less script and witness data to be included onchain.

  - *Fewer steps for spending:* less flexible covenant proposals and
    vaults available today based on presigned transactions require
    withdrawing funds to a predetermined address before they can be sent
    to an ultimate destination.  Such proposals also generally require that
    each received output be spent in a separate transaction from other
    received outputs, preventing the use of [payment batching][topic
    payment batching].  This increases the number of transactions
    involved, which also bloats the size and cost of spending.

    `OP_VAULT` requires fewer transactions when spending a single
    output in typical cases and it also supports batching when
    spending or freezing multiple outputs, potentially saving a large
    amount of space and allowing vaults to receive many more
    transactions before their outputs would need to be consolidated
    for safety.

  In discussion of the idea, Greg Sanders proposed (as [summarized by
  O'Beirne][obeirne scripthash]) a slightly different construction which
  "would allow all outputs in vault lifecycles to be [P2TR][topic
  taproot], for example, which would conceal the operation of the
  vault---a very nice feature".

  Separately, Anthony Towns [notes][towns op_vault] that the proposal
  allows the vault user to freeze their funds at any time just by
  spending the funds to the address for the highly trusted spending
  path, allowing the user to unfreeze their funds later.  This
  benefits the vault owner because they don't need to access any
  specially-secured key material, such as a cold wallet, in order to
  block a theft attempt.  However, any third party who learns the
  address can also freeze the user's funds (although they'll have to
  pay a transaction fee to do so), creating an inconvenience for the
  user.  Given that many lightweight wallets disclose their addresses
  to third parties in order to locate their onchain transactions,
  vaults built on those wallets might unintentionally give third
  parties the ability to inconvenience vault users.  Towns suggests an
  alternative construction for the freezing condition that would
  require providing an additional piece of non-private information in
  order to initiate a freezing, preserving the benefits of the scheme
  but also reducing the risk that a wallet would unnecessarily give
  third parties the ability to freeze funds and inconvenience the user.  Towns
  also suggests a possible improvement in batching support and
  contemplates taproot support.

  Several replies also mentioned that `OP_UNVAULT` can provide many of
  the features of the [OP_CHECKTEMPLATEVERIFY][topic
  op_checktemplateverify] (CTV) proposal, including the benefits to
  [DLCs][topic dlc] previously described in [Newsletter #185][news185
  ctv-dlc], although at greater onchain cost than directly using CTV.

  Discussion was still active as of this writing. {% assign timestamp="1:48" %}

## Changes to services and client software

*In this monthly feature, we highlight interesting updates to Bitcoin
wallets and services.*

- **Kraken announces sending to taproot addresses:**
  In a recent [blog post][kraken bech32m], Kraken announced they support
  withdrawing (sending) to [bech32m][topic bech32] addresses. {% assign timestamp="53:01" %}

- **Whirlpool coinjoin rust client library announced:**
  The [Samourai Whirlpool Client][whirlpool rust client] is a rust library for
  interacting with the Whirlpool [coinjoin][topic coinjoin] platform. {% assign timestamp="53:45" %}

- **Ledger supports miniscript:**
  Ledger's Bitcoin firmware v2.1.0 release for its hardware signing
  devices supports [miniscript][topic miniscript], as announced [previously][ledger miniscript]. {% assign timestamp="54:25" %}

- **Liana wallet released:**
  The first version of the Liana wallet was [announced][liana blog]. The wallet
  supports singlesig wallets with a [timelocked][topic timelocks] recovery key.
  The project's future plans include implementing [taproot][topic taproot],
  multisig wallets, and time-decaying multisig features. {% assign timestamp="55:11" %}

- **Electrum 4.3.3 released:**
  [Electrum 4.3.3][electrum 4.3.3] contains improvements for Lightning,
  [PSBTs][topic psbt], hardware signers, and the build system. {% assign timestamp="58:40" %}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [HWI 2.2.0][] is a release of this application for allowing software
  wallets to interface with hardware signing devices.  It adds support
  for [P2TR][topic taproot] keypath spends using the BitBox02 hardware
  signing device among other features and bug fixes. {% assign timestamp="1:00:04" %}

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Core Lightning #5751][] deprecates support for creating new
  P2SH-wrapped segwit addresses. {% assign timestamp="1:02:54" %}

- [BIPs #1378][] adds [BIP324][] for the [v2 encrypted P2P transport
  protocol][topic v2 p2p transport]. {% assign timestamp="1:06:23" %}

{% include references.md %}
{% include linkers/issues.md v=2 issues="5751,1378" %}
[hwi 2.2.0]: https://github.com/bitcoin-core/HWI/releases/tag/2.2.0
[obeirne op_vault]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-January/021318.html
[obeirne paper]: https://jameso.be/vaults.pdf
[obeirne scripthash]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-January/021329.html
[news185 ctv-dlc]: /en/newsletters/2022/02/02/#improving-dlc-efficiency-by-changing-script
[towns op_vault]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-January/021328.html
[kraken bech32m]: https://blog.kraken.com/post/16740/bitcoin-taproot-address-now-supported-on-kraken/
[whirlpool rust client]: https://github.com/straylight-orbit/whirlpool-client-rs
[ledger miniscript]: https://blog.ledger.com/miniscript-is-coming/
[liana blog]: https://wizardsardine.com/blog/liana-announcement/
[electrum 4.3.3]: https://github.com/spesmilo/electrum/blob/4.3.3/RELEASE-NOTES
