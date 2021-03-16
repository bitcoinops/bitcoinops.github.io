---
title: 'Bitcoin Optech Newsletter #140'
permalink: /en/newsletters/2021/03/17/
name: 2021-03-17-newsletter
slug: 2021-03-17-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a discussion about rescuing lost LN
funding transactions and includes our regular sections with
announcements of releases, release candidates, and notable changes to
popular Bitcoin infrastructure software.

## News

- **Rescuing lost LN funding transactions:** LN funding transactions are
  not safe in the presence of transaction malleability.  Segwit
  eliminated third-party malleability as a concern for most
  transactions, <!-- by "most", I mean everything signed SIGHASH_ALL -->
  but it doesn't address the case where the creator of a transaction
  mutates its txid themselves, such as by fee bumping the funding
  transaction using [Replace-by-Fee][topic rbf] (RBF).  If a txid
  mutation happens, then the pre-signed refund transaction is not valid,
  so the user can't get their funds back.  Additionally, the remote node
  may not automatically see the funding transaction and so may not be
  able to help the funder get their money back.

    This week, Rusty Russell [posted][russell funding rescue] to the
    Lightning-Dev mailing list about a quick and experimental feature he
    implemented in C-Lightning to help a user with this problem recover
    their funds.  He also described alternative solutions for related
    problems as well as the impact of the [proposed][bolts #851] channel
    dual-funding protocol on this problem.  Christian Decker also
    [posted][decker funding rescue] a [proposed change][bolts #854] to
    the LN specification to help facilitate funding recovery efforts.
    As LN software adds support for funding channels from external
    wallets (e.g. C-Lightning as described in [Newsletter #51][news51
    cl2672] and LND in [Newsletter #92][news92 lnd4079]), developers may
    want to give this type of failure scenarios more attention.

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [HWI 2.0.0][hwi 2.0.0] is the release for the next major
  version of HWI.  Among other improvements, it contains support for
  multisig on the BitBox02, improved documentation, and support for
  paying `OP_RETURN` outputs with a Trezor.

- [Rust-Lightning 0.0.13][] is the latest release for this LN library
  containing improvements aimed at forward compatibility with [multipath
  payments][topic multipath payments] and future script upgrades such as
  [taproot][topic taproot].

- [BTCPay Server 1.0.7.0][] is the latest release for this self-hosted
  payment processing software.  Notable improvements include a more
  featureful and visually appealing wallet setup wizard, the ability to
  import wallets created using Specter, and more efficient QR codes for [bech32
  addresses][topic bech32].

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[Rust-Lightning][rust-lightning repo], [libsecp256k1][libsecp256k1
repo], [Hardware Wallet Interface (HWI)][hwi repo],
[Rust Bitcoin][rust bitcoin repo], [BTCPay Server][btcpay server repo],
[Bitcoin Improvement Proposals (BIPs)][bips repo], and [Lightning
BOLTs][bolts repo].*

- [Bitcoin Core #21007][] adds a new `-daemonwait` configuration option. It has
  been possible to run Bitcoin Core as a background daemon process since early
  versions by starting the program with the `-daemon` configuration option.
  The `-daemon` option causes the program to immediately start the daemon process
  in the background. The new `-daemonwait` option
  is similar, but only puts the daemon process in the background after initialization
  is complete. This allows the user or parent process to more easily know
  whether the daemon started successfully by observing the program's output or
  exit code.

- [C-Lightning #4404][] allows the `keysend` RPC (see [Newsletter
  #107][news107 keysend]) to send messages even to nodes that don't
  explicitly signal that they support the feature.  As
  [discussed][fromknecht keysend], the signal was never standardized and
  the procedure implemented by LND didn't depend on signaling, so this
  change should allow C-Lightning to send to roughly the same set of
  nodes that LND can address.

- [C-Lightning #4410][] brings the experimental implementation for
  dual-funded channels in line with the most recent [draft
  specification][bolts #851] changes.  Most notably, the use of Proof of
  Discrete Log Equivalency (PODLE) has been dropped, at least
  temporarily (see [Newsletter #83][news83 podle] for original
  discussion of PODLEs and [Newsletter #131][news131 podle] for
  discussion about alternatives).  Subsequent to this merge, a [new
  PR][c-lightning #4427] was opened that will make experimenting with
  dual-funding more accessible by eliminating the need to compile
  C-Lightning with special build flags (although a special configuration
  option will still be required).

- [LND #5083][] allows a [PSBT][topic psbt] to be read from a file
  rather than by reading the standard input (stdin) file descriptor.
  Some terminals have a [limit][lnd #5080] on the number of characters
  that can be added to stdin simultaneously (i.e. pasted), which made
  PSBTs over 4096 base64 characters (equivalent to 3.072 bytes of binary) <!-- PSBTs are base64 encoded,
  base64 provides 6 bits per character, so 4096 * 6 / 8 = 3072 = 3 KiB
  --> unusable.  Especially now that several hardware wallets require
  PSBTs include previous transactions for segwit spends (see [Newsletter
  #101][news101 segwit overpayment]), it's common to create PSBTs over 3
  KiB in size.

- [LND #5033][] adds an `updatechanstatus` RPC that can advertise that a
  channel has been disabled (similar to your node going offline) or that
  it's been re-enabled (similar to your node coming back online).

- [Rust-Lightning #826][] increases the maximum allowed `OP_CHECKSEQUENCEVERIFY`
  delay to 2,016 blocks for the output paying the node that is
  unilaterally closing the channel.  This fixes an interoperability
  issue when opening channels with LND, which may request a delay
  up to 2016 blocks, larger than the previous Rust-Lightning maximum of
  1008 blocks.

- [HWI #488][] implements a breaking change in how the
  `displayaddress` command handles multisig addresses when used with the
  `--desc` option for [output script descriptors][topic descriptors].
  Previously, HWI applied [BIP67][] lexicographic key sorting
  automatically based on what the device involved used (e.g. applying
  BIP67 for Coldcard devices, not applying it for Trezor devices).  The
  way this was implemented created problems when the user explicitly
  specified the `sortedmulti` descriptor option that implements BIP67
  key sorting.  After this change, users of descriptors need to specify
  `sortedmulti` for devices that require lexicographic key sorting or
  `multi` for those that don't.

{% include references.md %}
{% include linkers/issues.md issues="21007,4404,854,4410,4427,5083,5080,5033,826,488,851" %}
[hwi 2.0.0]: https://github.com/bitcoin-core/HWI/releases/tag/2.0.0
[rust-lightning 0.0.13]: https://github.com/rust-bitcoin/rust-lightning/releases/tag/v0.0.13
[btcpay server 1.0.7.0]: https://github.com/btcpayserver/btcpayserver/releases/tag/v1.0.7.0
[news51 cl2672]: /en/newsletters/2019/06/19/#c-lightning-2672
[news92 lnd4079]: /en/newsletters/2020/04/08/#lnd-4079
[russell funding rescue]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-March/002981.html
[decker funding rescue]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-March/002982.html
[news107 keysend]: /en/newsletters/2020/07/22/#c-lightning-3792
[fromknecht keysend]: https://github.com/ElementsProject/lightning/issues/4299#issuecomment-781606865
[news83 podle]: /en/newsletters/2020/02/05/#interactive-construction-of-ln-funding-transactions
[news131 podle]: /en/newsletters/2021/01/13/#ln-dual-funding-anti-utxo-probing
[news101 segwit overpayment]: /en/newsletters/2020/06/10/#fee-overpayment-attack-on-multi-input-segwit-transactions
