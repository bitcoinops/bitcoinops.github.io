---
title: 'Bitcoin Optech Newsletter #134'
permalink: /en/newsletters/2021/02/03/
name: 2021-02-03-newsletter
slug: 2021-02-03-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter links to a blog post about how a small change to
the Script language after taproot activation could enable increased
contract flexibility and includes our regular sections with notable changes to
popular Bitcoin infrastructure projects.

## News

- **Replicating `OP_CHECKSIGFROMSTACK` with BIP340 and `OP_CAT`:** Andrew
  Poelstra authored a [blog post][poelstra 340cat] about implementing
  the functionality of the
  [OP_CHECKSIGFROMSTACK][topic op_checksigfromstack] (`OP_CSFS`) opcode
  from [ElementsProject.org][] on Bitcoin using the proposed [BIP340][] specification of [schnorr
  signatures][topic schnorr signatures] and an [OP_CAT][] opcode
  that was part of Bitcoin until mid-2010 (and which is often mentioned
  as a candidate for reintroduction).  Enabling CSFS-like behavior on
  Bitcoin would allow the creation of [covenants][topic covenants] and
  other advanced contracts without having to presign spending
  transactions, possibly reducing complexity and the amount of data that
  needs to be stored.  The post ends with a teaser for later posts in
  the series (links added by us):

    > "In our next posts, we’ll talk about how to use auxiliary inputs
    > to simulate [SIGHASH_NOINPUT][topic sighash_anyprevout] and enable
    > constant-sized backups for Lightning channels, and how to use
    > "value-switching" to construct [vaults][topic vaults].  In our
    > final post we’ll talk about ad-hoc extensions of
    > [Miniscript][topic miniscript], and how to develop software for
    > these constructions in a
    > maintainable way."

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[Rust-Lightning][rust-lightning repo], [libsecp256k1][libsecp256k1
repo], [Hardware Wallet Interface (HWI)][hwi repo],
[Rust Bitcoin][rust bitcoin repo], [BTCPay Server][btcpay server repo],
[Bitcoin Improvement Proposals (BIPs)][bips repo], and [Lightning
BOLTs][bolts repo].*

- [Bitcoin Core #20226][] adds a new `listdescriptors` RPC method for the
  wallet. [PR #16528][news96 descriptor wallets], included in the recent [0.21.0
  software release][news132 bitcoin core v0.21], added support for
  [descriptor][topic descriptors] wallets. This new RPC method lists
  all descriptors imported into a descriptor wallet.

- [Bitcoin Core GUI #163][] replaces the *Direction* field in the GUI peer details
  area with a *Connection Type* that displays both the direction and the type of
  peer connection. For more information, place the cursor over the Connection
  Type field name to see the tooltip shown below.

    {:.center}
    ![Illustration of GUI peer detail connection type](/img/posts/2021-02-gui-peer-connection-type.png)

- [HWI #430][] allows the `displayaddress` command to show [BIP32][] extended
  public keys (xpubs) for multisig addresses on the Trezor One.

- [HWI #415][] updates the `getkeypool` and `displayaddress` commands to
  replace the `--sh_wpkh` and `--wpkh` options with a `--addr-type`
  option that takes the address type as a parameter, e.g. `--addr-type
  sh_wpkh`.

{% include references.md %}
{% include linkers/issues.md issues="16528,20226,163,430,415" %}
[btcpay server 1.0.6.8]: https://github.com/btcpayserver/btcpayserver/releases/tag/v1.0.6.8
[poelstra 340cat]: https://medium.com/blockstream/cat-and-schnorr-tricks-i-faf1b59bd298
[news96 descriptor wallets]: /en/newsletters/2020/05/06/#bitcoin-core-16528
[news132 bitcoin core v0.21]: /en/newsletters/2021/01/20/#bitcoin-core-0-21-0
