---
title: 'Bitcoin Optech Newsletter #198'
permalink: /en/newsletters/2022/05/04/
name: 2022-05-04-newsletter
slug: 2022-05-04-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes a post about implementing MuSig2, relays
the responsible disclosure of a security issue affecting some older LN
implementations, discusses a proposal for measuring support for
consensus changes through transaction signaling, and examines the effect
of rate limiting on more bandwidth efficient LN gossiping.  Also
included are our regular sections summarizing new software releases and
release candidates plus notable changes to popular Bitcoin
infrastructure projects.

## News

- **MuSig2 implementation notes:** Olaoluwa Osuntokun
  [replied][osuntokun musig2] to the draft BIP for [MuSig2][topic musig]
  mentioned in [Newsletter #195][news195 musig2] with notes from the
  implementations he and others have worked on for btcd and LND:

    - *Interaction with BIP86:* keys created by a [BIP32 HD
      wallet][topic bip32] implementing [BIP86][] follow the [BIP341][]
      recommendation for creating keypath-only keys by tweaking the key
      by a hash of itself.  This helps prevent the key from being used
      in a [multisignature][topic multisignature] which could allow one
      participant to secretly include a scriptpath spending option they
      control, giving them the ability to steal all the funds.  However,
      if the multisignature participants deliberately want to include a
      scriptpath spending option, they need to share the un-tweaked
      versions of their keys with each other.

        Osuntokun recommends that BIP86 implementations return both the
        original key (internal key) and the tweaked key (output key) so that the
        calling function can use whichever one is appropriate for its
        context.

    - *Interaction with scriptpath spends:* keys meant to be used with
      scriptpath spends have a related problem: in order to use the
      scriptpath, the spender must know the internal key.  Again,
      this suggests that implementations return the internal key so
      that it's available to be used in other code that needs it.

    - *Shortcut for final signer:* Osuntokun also sought clarification
      on a section in the BIP which describes how the final signer (and
      only the final signer) can use deterministic randomness or a
      lower-quality source of randomness for generating their signature
      nonce.  Brandon Black [replied][black musig2] to describe the
      situation that had motivated the section---they had a signer that
      would have a difficult time securely managing a regular MuSig2
      signing session but which they were instead able to always use as
      the final signer.

- **Measuring user support for consensus changes:** Keagan McClelland
  [posted][mcclelland measure] to the Bitcoin-Dev mailing list a
  proposal similar to [previous proposals][bishop signal] to have
  transactions signal whether or not they [supported][topic soft fork
  activation] a particular effort to change the consensus rules.  In
  the thread, several related sentiment measurement ideas were also
  discussed, but all appeared to have problems, such as [technical
  challenges][aronesty signal parse scripts], significantly
  [reducing][grant signal chainalysis] user privacy, [favoring][tetrud
  signal favor] certain parts of the Bitcoin economy over others, or
  [penalizing][ivgi signal hodl voting] early voters over those who
  waited to participate in consensus formation.

    As on previous occasions where this topic has been discussed, it
    did not appear that any of the suggested methods would produce a
    result that would be sufficiently respected by most of the
    discussion participants when it came to informing their decisions about
    changing Bitcoin's consensus rules.

- **LN anchor outputs security issue:** Bastien Teinturier
  [posted][teinturier security] to the Lightning-Dev mailing list the
  announcement of a security issue he had previously responsibly
  disclosed to LN implementation maintainers.  The issue affected older
  versions of Core Lightning (with experimental features enabled) and
  LND.  Anyone still using the versions mentioned in Teinturier's post
  are strongly encouraged to upgrade.

    Prior to the implementation of [anchor outputs][topic anchor
    outputs], revoked [HTLC][topic HTLC] transactions only contained a
    single output, so many implementations only tried to claim that
    single output.  The new design of anchor outputs for LN allows combining
    multiple revoked HTLC outputs into a single transaction, but this
    is only safe if implementations claim all of the relevant outputs in
    the transaction.  Any funds which have not been claimed by the time
    the HTLC timelock expires may be stolen by the party who broadcast the
    revoked HTLC.  Teinturier's implementation of anchor outputs for
    Eclair allowed him to test the other LN implementations and discover
    the vulnerability.

    As with a previous attack related to anchor outputs (see [Newsletter
    #115][news115 fee stealing]), the problem appears to be related to
    adding support for signing with
    `SIGHASH_SINGLE|SIGHASH_ANYONECANPAY` while still retaining legacy
    support for signing with `SIGHASH_ALL`.

- **LN gossip rate limiting:** Alex Myers [posted][myers recon] to the
  Lightning-Dev mailing list about his research into using
  [minisketch][topic minisketch]-based set reconciliation to reduce the
  amount of bandwidth used by nodes for learning about updates to the LN
  channel graph.  His method assumes all peers have almost all of the
  same information about almost all of the same public channels.  One
  peer can then generate a minisketch from its complete graph of the
  public network and send that to all of its peers, who can use the
  minisketch to find any updates to the network since its last
  reconciliation.  This is different than the proposed use of minisketch
  for the Bitcoin P2P network via the [erlay][topic erlay] protocol
  where only updates (new unconfirmed transactions) from the last few
  seconds are sent.

    One challenge of reconciling over all public channels is that it
    requires all LN nodes keep the same information.  Any filtering that
    produces a persistent difference in the view of the channel graph
    between nodes will result in either a bandwidth overhead or a
    failure of the protocol.  Matt Corallo [suggested][corallo recon]
    that this could be addressed by applying the erlay model to LN---if
    only new information was synced, there wouldn't be a concern about
    persistent differences, although large variations in filtering rules
    could still result in wasted bandwidth or reconciliation failure.
    Myers was concerned about the amount of state tracking required by
    only sending updates---a Bitcoin Core node maintains a separate state
    for each of its peers in order to avoid resending updates
    previously sent to the node.  The alternative of reconciling
    over all channels eliminates the need for per-peer state, greatly
    simplifying the implementation of gossip management.

    The discussion about the tradeoffs implicit in each of these
    approaches was ongoing as this summary was being written.

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [BTCPay Server 1.5.1][] is a new release of this popular
  self-hosted payment processing software which includes a new main-page
  dashboard, a new [transfer processors][btcpay server #3476] feature,
  and the ability to allow pull payments and refunds to be automatically
  approved.

- [BDK 0.18.0][] is a new release of this wallet library.  It includes a
  [critical security fix][minimalif bug] from one of its dependencies,
  the rust-miniscript library.  It also includes several improvements
  and minor bug fixes.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #18554][] prevents the same Bitcoin Core wallet file
  from being used on multiple fully independent block chains by default.
  When Bitcoin Core scans a new block for transactions affecting one of
  its wallets, it records the hash of that block's header in the wallet.
  This PR checks whether the most recent recorded scan block is
  descended from the same [genesis block][] as the currently used block
  chain.  If it isn't, an error is returned unless the new
  `-walletcrosschain` configuration option is set.  This prevents a
  wallet intended for use with one network (e.g. mainnet) from being
  used with another network (e.g. testnet), reducing the risk of
  accidental money loss or privacy loss.  This only affects users of
  Bitcoin Core's internal wallet; other Bitcoin wallet software is
  unaffected.

- [Bitcoin Core #24322][] [kernel 1/n] Introduce initial `libbitcoinkernel` FIXME:glozow

- [Bitcoin Core #21726][] adds the ability to maintain a coinstats
  index even on pruned nodes.  Coinstats includes the MuHash digest of
  the UTXO state at each block, which allows validating
  [assumeUTXO][topic assumeutxo] states.  Previously this was only
  guaranteed to be available on archival full nodes---those that stored
  every block on the block chain.  This merged PR also makes the
  information available to pruned full nodes (those that delete blocks
  some time after validating them) when the `-coinstatsindex`
  configuration option is enabled.

- [BDK #557][] add OldestFirstCoinSelection FIXME:Xekyo

- [LDK #1425][] adds support for [large channels][topic large channels]
  ("wumbo channels"), which are channels which support high value payments.

- [LND #6064][] adds new `bitcoind.config` and `bitcoind.rpccookie`
  configuration options to specify non-default paths for the configuration and
  RPC cookie files.

- [LND #6361][] updates the `signrpc` method <!-- yes, "signrpc" is the
  RPC's name --> to be able to create signatures using the
  [MuSig2][topic musig] algorithm.  See the [documentation][lnd6361 doc]
  added in this merged PR for details.  Note that support for MuSig2 is
  experimental and may change, especially if there are major changes to
  the proposed BIP for MuSig2 (see [Newsletter #195][news195 musig2]).

- [BOLTs #981][] removes from the specification the ability for queries
  and results about the LN network graph to be compressed.  It is
  believed the compression wasn't being used and dropping support
  reduces the complexity and number of dependencies for LN
  implementations.

{% include references.md %}
{% include linkers/issues.md v=2 issues="18554,24322,21726,6064,557,981,6361,1425,3476" %}
[tetrud signal favor]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-April/020350.html
[ivgi signal hodl voting]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-April/020364.html
[aronesty signal parse scripts]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-April/020354.html
[grant signal chainalysis]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-April/020355.html
[bishop signal]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-April/020346.html
[news115 fee stealing]: /en/newsletters/2020/09/16/#stealing-onchain-fees-from-ln-htlcs
[osuntokun musig2]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-April/020361.html
[news195 musig2]: /en/newsletters/2022/04/13/#musig2-proposed-bip
[black musig2]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-April/020371.html
[mcclelland measure]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-April/020344.html
[teinturier security]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-April/003561.html
[myers recon]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-April/003551.html
[corallo recon]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-April/003556.html
[genesis block]: https://en.bitcoin.it/wiki/Genesis_block
[btcpay server 1.5.1]: https://github.com/btcpayserver/btcpayserver/releases/tag/v1.5.1
[minimalif bug]: https://bitcoindevkit.org/blog/miniscript-vulnerability/
[bdk 0.18.0]: https://github.com/bitcoindevkit/bdk/releases/tag/v0.18.0
[lnd6361 doc]: https://github.com/guggero/lnd/blob/93e069f3bd4cdb2198a0ff158b6f8f43a649e476/docs/musig2.md
