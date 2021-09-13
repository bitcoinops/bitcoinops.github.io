---
title: 'Bitcoin Optech Newsletter #166'
permalink: /en/newsletters/2021/09/15/
name: 2021-09-15-newsletter
slug: 2021-09-15-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a new proposal for a covenant opcode
and summarizes a request for feedback on implementing regular reorgs on
signet.  Also included are our regular sections with ideas for preparing
for taproot activation, a list of new releases and release candidates,
and descriptions of popular Bitcoin infrastructure software.

## News

- **Covenant opcode proposal:** Anthony Towns posted to the Bitcoin-Dev
  mailing list the [overview][towns overview] of an idea for a covenant
  opcode, plus a more [technically detailed][towns detailed] message
  describing how the opcode (and some other tapscript changes) would
  work.

    In short, a new `OP_TAPLEAF_UPDATE_VERIFY` opcode (TLUV) takes
    information about the taproot input being spent, makes modifications
    described in a tapscript, and requires that the result be equivalent
    to the scriptPubKey in the output in the same position as the input.
    This allows TLUV to constrain where the bitcoins can be spent (the
    definition of a [covenant][topic covenants]), similar to other
    proposed opcodes such as [OP_CHECKSIGFROMSTACK][topic
    op_checksigfromstack] (CSFS) and [OP_CHECKTEMPLATEVERIFY][topic
    op_checktemplateverify] (CTV).  Where it differs from previous
    proposals are the modifications it allows the creator of the
    tapscript to make:

    - **Internal key tweak:** every taproot address commits to an
      internal key that can be used to spend with just a signature.  In order to
      use a tapscript (including TLUV), the current internal key needs
      to be revealed.  TLUV allows specifying a tweak to be added to
      that key.  For example, if the internal key is an aggregation of
      keys `A+B+C`, key `C` can be removed by specifying a tweak of `-C`
      or key `X` can be added by specifying a tweak of `X`.  TLUV
      computes the modified internal key and ensures that is what the
      same-position output will pay.

      One powerful use of this described in Towns's email is the ability
      to more effectively create a [joinpool][], a single UTXO shared by
      multiple users who each control a portion of the UTXO's funds but
      don't have to reveal that ownership publicly onchain (nor reveal
      how many owners the UTXO has).  If all pool members sign together,
      they can spend their funds in highly fungible transactions.  If
      there's any disagreement, each pool member can use a transaction
      to exit the pool with all their funds (minus an onchain
      transaction fee).

      It's possible to create a joinpool using just presigned
      transactions today, but this requires creating an exponentially
      increasing number of signatures if we want each member of the pool
      to be able to leave individually without the cooperation of the
      other members.  CTV has a similar problem where exiting a pool
      might require creating multiple transactions that affect multiple
      other users.  TLUV allows any single member to exit at any time
      without requiring anything be presigned or affecting any other
      users, beyond revealing that one member has left the joinpool.

    - **Merkle tree tweak:** taproot addresses can also commit to the
      merkle root for a tree of tapscripts, and it'll be one of those
      tapscripts in the transaction input that will be executing the
      TLUV opcode.  TLUV allows that script to specify how that part of
      the merkle tree should be modified.  For example, the currently
      executed node (tapleaf) can be removed from the tree (e.g. someone
      exiting a joinpool) or replaced with a tapleaf paying a different
      tapscript.  TLUV computes the modified merkle root and ensures
      that is what the same-position output will pay.

      Towns's email describes how this can be used to implement Bryan
      Bishop's 2019 [vault][topic vaults] design (see [Newsletter
      #59][news59 vaults]).  Alice creates two keypairs, one for her
      less secure hot wallet and one for her more secure cold wallet.
      The cold wallet key becomes the taproot internal key, allowing it
      to spend the funds any time.  The hot wallet key is used with TLUV
      to only allow spending to a modification of the merkle tree that
      includes a time delay before a second spend from the hot wallet
      key may be sent.

      That means Alice can start a spend of all her funds with her hot
      key, but she has to create an onchain transaction for that and
      then wait for the time delay (e.g.  1 day) to complete before she
      can truly spend her funds to an arbitrary address.  If someone
      else is using Alice's hot key to start the spending process, Alice
      can use her cold key to move the funds to a safe address.

    - **Amount introspection:** in addition to TLUV, a second opcode
      would be added that pushes to the script execution stack the
      bitcoin value of the input and its corresponding output.  This
      allows math and comparison opcodes to restrict the amount that can
      be spent.

      In the case of a joinpool, this would be used to ensure a
      departing member could only withdraw their own funds.  In a vault,
      this could be used to set a periodic withdrawal limit, e.g. 1 BTC
      per day.

    As of this writing, the proposal was still receiving initial
    feedback on the mailing list.  We'll summarize any notable comments
    in a future newsletter.

- **Signet reorg discussion:** developer 0xB10C [posted][b10c post] a
  proposal to the Bitcoin-Dev mailing list for creating periodic block
  chain reorganizations (reorgs) on [signet][topic signet].  The blocks
  that would be eventually reorged would signal on one of the
  version field's bits, allowing anyone who didn't want to track reorgs to ignore
  those blocks.  Reorgs would occur periodically, perhaps about three
  times a day, and would follow two different patterns that replicated
  what possible reorgs on mainnet would look like.

    0xB10C requested feedback and received several comments as of this
    writing.  We encourage anyone interested in testing reorgs (or
    wanting to avoid them) on signet to read the discussion and
    consider participating.

## Preparing for taproot #13: Backup and security schemes

*A weekly [series][series preparing for taproot] about how developers
and service providers can prepare for the upcoming activation of taproot
at block height {{site.trb}}.*

{% include specials/taproot/en/12-backups.md %}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [Bitcoin Core 22.0][bitcoin core 22.0] is the release
  of the next major version of this full node implementation and its
  associated wallet and other software. Major changes in this new
  version include support for [I2P][topic anonymity networks] connections,
  removal of support for [version 2 Tor][topic anonymity networks] connections,
  and enhanced support for hardware wallets.  Note that the release
  verification instructions have changed for this release, as mentioned in
  [Newsletter #162][news162 core verification].

- [BTCPay Server 1.2.3][] is a release that fixes three cross-site
  scripting (XSS) vulnerabilities that were responsibly reported.

- [Bitcoin Core 0.21.2rc2][bitcoin core 0.21.2] is a release candidate
  for a maintenance version of Bitcoin Core.  It contains several bug
  fixes and small improvements.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[Rust-Lightning][rust-lightning repo], [libsecp256k1][libsecp256k1
repo], [Hardware Wallet Interface (HWI)][hwi repo],
[Rust Bitcoin][rust bitcoin repo], [BTCPay Server][btcpay server repo],
[Bitcoin Improvement Proposals (BIPs)][bips repo], and [Lightning
BOLTs][bolts repo].*

- [Bitcoin Core #22079][] zmq: Add support to listen on IPv6 addresses FIXME:jnewbery

- [C-Lightning #4599][] implements the quick-close fee negotiation
  protocol described in [BOLTs #843][].  We [described][news165
  bolts847] the protocol in last week's newsletter but our description
  of the existing protocol it replaced was [inaccurate][russell tweet].  The
  old protocol required trial and error based negotiation over what
  feerate to use for a mutual close transaction, and did not allow
  setting a feerate higher than the current commitment transaction
  feerate.  This doesn't make sense with [anchor outputs][topic anchor
  outputs], where low-feerate commitment transactions are designed to be
  fee bumped if they get used.  The new protocol allows paying higher
  fees and uses a more efficient range-based negotiation when possible.
  [Eclair #1768][], also merged this week, implements the protocol as well.

- [Eclair #1930][] allows its path finding algorithm to be run with non-default,
  experimental parameter sets.  This can either be done automatically for a certain percentage of
  traffic or manually via the API. Metrics are recorded separately for each
  experimental parameter set and can be used to optimize for the best path
  finding parameters.

- [Eclair #1936][] allows disabling the publication of a node's Tor
  onion services address for cases where the user wants to keep that
  address private.

- [LND #5356][] adds a `BatchChannelOpen` RPC that can open multiple
  channels to different nodes in the same [batched][topic payment
  batching] onchain transaction.

- [BTCPay server #2830][] adds support for creating a [taproot][topic
  taproot]-enabled wallet that can both receive and send single-sig P2TR
  payments, as tested on [signet][topic signet].  An additional merged
  PR, [#2837][btcpay server #2837], lists the P2TR address support in
  the wallet settings but makes it unselectable until block
  {{site.trb}}.

{% include references.md %}
{% include linkers/issues.md issues="22079,4599,1930,1936,5356,2830,843,1768,2837" %}
[bitcoin core 22.0]: https://bitcoincore.org/bin/bitcoin-core-22.0/
[bitcoin core 0.21.2]: https://bitcoincore.org/bin/bitcoin-core-0.21.2/
[btcpay server 1.2.3]: https://github.com/btcpayserver/btcpayserver/releases/tag/v1.2.3
[towns overview]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-September/019419.html
[towns detailed]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-September/019420.html
[joinpool]: https://gist.github.com/harding/a30864d0315a0cebd7de3732f5bd88f0
[news59 vaults]: /en/newsletters/2019/08/14/#bitcoin-vaults-without-covenants
[b10c post]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-September/019413.html
[news165 bolts847]: /en/newsletters/2021/09/08/#bolts-847
[russell tweet]: https://twitter.com/rusty_twit/status/1435758634995105792
[news162 core verification]: /en/newsletters/2021/08/18/#bitcoin-core-22642
