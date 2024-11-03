---
title: 'Bitcoin Optech Newsletter #193'
permalink: /en/newsletters/2022/03/30/
name: 2022-03-30-newsletter
slug: 2022-03-30-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a proposal for Bitcoin Core to allow
replacing transaction witnesses in its mempool and summarizes continued
discussion about updating the LN gossip protocol.  Also included are our
regular sections with selected questions and answers from the Bitcoin
Stack Exchange, announcements of new releases and release candidates,
and descriptions of notable changes to popular Bitcoin infrastructure
projects.

## News

- **Transaction witness replacement:** Larry Ruane [asked][ruane witrep]
  the Bitcoin-Dev mailing list for information and opinions about
  allowing a transaction to be replaced by the same transaction with the
  same txid but a smaller witness (and, thus, a different wtxid).  Ruane
  sought information about any applications that currently create
  transactions with witnesses that can change in size (e.g. from using a
  [taproot][topic taproot] scriptpath spend to a keypath spend) without
  there being a corresponding change in the other transaction details
  (e.g. output addresses or amounts).

  If there are current or proposed applications that would benefit
  from being able to replace witnesses, Ruane also seeks feedback on
  how much the witness should need to shrink in order to allow
  replacement.  The more shrinkage required, the fewer replacements
  are possible---limiting the amount of node bandwidth that could be
  wasted in the worst case by an attacker.  But requiring more
  shrinkage would also prevent applications from accessing small or
  moderate savings through witness replacement.

- **Continued discussion about updated LN gossip protocol:** as reported
  in [Newsletter #188][news188 gossip], LN protocol developers are
  discussing how to revise the LN gossip protocol used to advertise
  information about available payment channels.  In particular, this
  week saw two active threads:

  - *Major update:* in [response][osuntokun gossip1.1] to Rusty
    Russell's [major update][russell gossip2] proposal from last month,
    Olaoluwa Osuntokun repeatedly expressed concern with an aspect of
    the proposal that would introduce plausible deniability in the
    link between onchain funds and a specific LN channel.  That
    capability would also make it easier for non-LN users to advertise
    the existence of channels that might not actually exist, which
    could degrade the ability of a spender to find a working path
    across the network to the node receiving the funds.

  - *Minor update:* Osuntokun [posted][osuntokun gossip2] a separate
    proposal for a much smaller update to the gossip protocol aimed
    mainly at allowing taproot-based channels.  The proposal uses
    [MuSig2][topic musig] to allow a single signature to prove
    authorization related to all four public keys involved (two node
    identifier keys, two channel-spending keys) and would likely
    require that the channel setup transaction be spendable using
    MuSig2.

    He also suggested that it might be useful to add an SPV partial
    merkle branch proof to the channel announcement message.  This
    would prove that the channel setup transaction was included in a
    block, eliminating lightweight clients from having to download
    the entire block containing the transaction in order to verify
    its existence.

## Selected Q&A from Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] is one of the first places Optech
contributors look for answers to their questions---or when we have a
few spare moments to help curious or confused users.  In
this monthly feature, we highlight some of the top-voted questions and
answers posted since our last update.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [What are the advantages or disadvantages to address reuse?]({{bse}}112955)
  RedGrittyBrick and Pieter Wuille list the downsides of address reuse including
  privacy and debatable concerns around pubkey exposure. Wuille goes on to note
  that while generating new addresses has no incremental financial costs, it
  does add complexity to wallet software, backups, and usability.

- [What is a block-relay-only connection and what is it used for?]({{bse}}112828)
  User vnprc describes block-relay-only connections as peers that relay block information
  but not transactions or network addresses of potential peers. These connections
  help protect against partition (also known as [eclipse][topic eclipse attacks])
  attacks by making it more difficult to determine Bitcoin's network topology
  graph. vnprc goes on to describe anchor connections, a block-relay-only connection
  that persists after a node restarts, further resisting eclipse attacks.

- [Is timestamping needed for anything except difficulty adjustment?]({{bse}}112929)
  Pieter Wuille explains the restrictions involving a block header's `nTime`
  timestamp field (must be greater than the [Median Time Past (MTP)][news146
  mtp] and no more than two hours in the future) and notes that the block's
  timestamp is used for [difficulty][wiki difficulty] calculation and
  transaction [timelocks][topic timelocks].

- [How are attempts to spend from a timelocked UTXO rejected?]({{bse}}112989)
  Pieter Wuille differentiates between locktimes for a transaction using the transaction's
  `nLockTime` field and timelocks enforced using Script's [`OP_CHECKLOCKTIMEVERIFY`][BIP65] opcode.

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [BDK 0.17.0][] is a release of this library for building Bitcoin
  wallets.  Improvements in this version should make it easier
  to derive addresses even when the wallet is offline.

- [Bitcoin Core 23.0 RC2][] is a release candidate for the next major
  version of this predominant full node software.  The [draft release
  notes][bcc23 rn] list multiple improvements that advanced users and
  system administrators are encouraged to [test][test guide] before the final release.

- [LND 0.14.3-beta.rc1][] is a release candidate with several bug fixes
  for this popular LN node software.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [C-Lightning #5078][] allows the node to effectively use multiple
  channels to the same peer, including routing payments over a different
  channel (but same peer) than specified in a routing message when the
  alternative channel would be a better choice.

- [C-Lightning #5103][] adds a new `setchannel` command that configures
  a specific channel's routing fees, minimum payment amount, and maximum
  payment amount.  This supersedes the `setchannelfee` command, which is
  now deprecated.

- [C-Lightning #5058][] removes support for the original fixed-length
  onion data format, which is also proposed for removal from the
  LN specification in [BOLTs #962][].  The upgraded variable-length
  format was [added to the specification][bolts #619] almost three years
  ago and network scanning results mentioned in the BOLTs #962 PR
  indicate that it is supported by all but 5 out of over 17,000
  publicly advertised nodes.

- [LND #5476][] updates the `GetTransactions` and
  `SubscribeTransactions` RPC results with additional information about
  the outputs being created, including the amount and script being paid
  and whether or not the address (script) belongs to the internal
  wallet.

- [LND #6232][] adds a configuration setting that can require all
  [HTLCs][topic htlc] be processed by a plugin registered on the HTLC
  interceptor hook.  This ensures that no HTLCs are accepted or rejected
  before an HTLC interceptor has time to register itself.  The HTLC
  interceptor allows calling an external program to examine an HTLC
  (payment) and determine whether it should be accepted or rejected.

{% include references.md %}
{% include linkers/issues.md v=1 issues="5078,5103,5058,962,619,5476,6232" %}
[bitcoin core 23.0 rc2]: https://bitcoincore.org/bin/bitcoin-core-23.0/
[bdk 0.17.0]: https://github.com/bitcoindevkit/bdk/releases/tag/v0.17.0
[lnd 0.14.3-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.14.3-beta.rc1
[bcc23 rn]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/23.0-Release-Notes-draft
[ruane witrep]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-March/020167.html
[osuntokun gossip2]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-March/003526.html
[osuntokun gossip1.1]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-March/003527.html
[news188 gossip]: /en/newsletters/2022/02/23/#updated-ln-gossip-proposal
[russell gossip2]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-February/003470.html
[test guide]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/23.0-Release-Candidate-Testing-Guide
[wiki difficulty]: https://en.bitcoin.it/wiki/Difficulty
[news146 mtp]: /en/newsletters/2021/04/28/#what-are-the-different-contexts-where-mtp-is-used-in-bitcoin
