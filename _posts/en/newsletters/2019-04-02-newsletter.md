---
title: 'Bitcoin Optech Newsletter #40'
permalink: /en/newsletters/2019/04/02/
name: 2019-04-02-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter notes a spike in estimated transaction fees,
describes LN trampoline payments, and publicizes Bitcoin Core's intent
to default its built-in wallet to bech32 receiving addresses in version
0.20 or earlier.  Also included are regular sections about bech32
sending support and notable code changes in popular Bitcoin
infrastructure projects.

{% include references.md %}

## Action items

- **Help test Bitcoin Core 0.18.0 RC2:** The second Release Candidate
  (RC) for the next major version of Bitcoin Core has been [released][0.18.0].
  Testing is still needed by organizations and experienced users who
  plan to run the new version of Bitcoin Core in production.  Use [this
  issue][Bitcoin Core #15555] for reporting feedback.

## Network status

- **Fee increases for fast confirmation:** after over a year of most
  Bitcoin transactions confirming rather quickly as long as they paid a
  feerate above the default minimum relay fee (except during [a brief
  exceptional period][Newsletter #22]), a modest backlog has developed
  over the previous week and raised the feerates for people who need
  their transactions to confirm within the next several blocks.
  Spenders willing to wait a bit longer can still save money.
  For example, as of this writing, Bitcoin Core's fee estimator suggests
  a fee of 0.00059060 BTC per 1,000 vbytes confirmation within 2 blocks
  but only 0.00002120 for confirmation within 50 blocks---saving over 95% for
  waiting up to an extra 8 hours.  For more information, we recommend
  [Johoe's mempool statistics][] and [P2SH.info's fee estimate
  tracker][].

## News

- **Trampoline payments for LN:** Pierre-Marie Padiou started a
  [thread][trampoline thread] on the Lightning-Dev mailing list
  suggesting that Alice could send a payment to Zed even if she didn't
  know a path to his node by first sending a payment to an intermediate
  node (Dan) and asking Dan to figure out the route the rest of the way
  to Zed.  This would especially benefit Alice if she ran a lightweight
  LN node that didn't attempt to keep track of the entire network.  For
  increased privacy, Alice could use several intermediate nodes
  rather than just one (each one receiving its own
  instructions encrypted by Alice).  A downside described in the email
  is that Alice could only make a rough guess about the required fees as
  she wouldn't know the actual path, so she'd probably end up paying
  more in fees than if she chose the route herself.

- **Bitcoin Core schedules switch to default bech32 receiving
  addresses:** since [version 0.16.0][0.16.0 segwit], Bitcoin Core's
  built-in wallet has defaulted to generating P2SH-wrapped segwit
  addresses when users want to receive payments.  These addresses are
  backwards compatible with all widely-used software.  As
  discussed in an [issue][Bitcoin Core #15560] and [the project's weekly
  meeting][core meeting segwit], starting with Bitcoin Core 0.20
  (expected about a year from now), Bitcoin Core will default to native
  segwit addresses (bech32) that provide additional fee savings and
  other benefits.  Currently, many wallets and services [already support
  sending to bech32 addresses][bech32 adoption], and if the Bitcoin Core project
  sees enough additional adoption in the next six months to warrant an
  earlier switch, it will instead default to bech32 receiving addresses
  in Bitcoin Core 0.19.  P2SH-wrapped segwit addresses will continue to be provided
  if the user requests them in the GUI or by RPC, and anyone who doesn't
  want the update will be able to configure their default address type.
  (Similarly, pioneering users who want to change their default now may
  set the `addresstype=bech32` configuration option in any Bitcoin Core
  release from 0.16.0 up.)

## Bech32 sending support

*Week 3 of 24.  Until the second anniversary of the segwit soft
fork lock-in on 24 August 2019, the Optech Newsletter will contain this
weekly section that provides information to help developers and
organizations implement bech32 sending support---the ability to pay
native segwit addresses.  This [doesn't require implementing
segwit][bech32 series] yourself, but it does allow the people you pay to
access all of segwit's multiple benefits.*

{% include specials/bech32/03-python-ref.md %}

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[LND][lnd repo], [C-Lightning][c-lightning repo], [Eclair][eclair repo],
[libsecp256k1][libsecp256k1 repo], and [Bitcoin Improvement Proposals
(BIPs)][bips repo].  Note: all merges described for Bitcoin Core are to
its master development branch; some may also be backported to the
0.18 branch for the pending 0.18.0 release.*

- [Bitcoin Core #15620][] stops the `maxtxfee` configuration
  parameter from affecting the `sendrawtransaction` and
  `testmempoolaccept` RPCs.  Previously those RPCs would default to
  rejecting a transaction paying a fee higher than the configured max.
  Now a hardcoded default of 0.1 BTC is used as the acceptable ceiling.
  The `maxtxfee` configuration parameter is still used by Bitcoin Core's
  built-in wallet; it has just been separated from node-specific RPCs.
  This change is part of a general [cleanup of wallet configuration
  options][Bitcoin Core #13044] as well as part of separating the node
  and wallet (which both used this setting before this change).

- [Bitcoin Core #15643][] changes the Python script Bitcoin Core
  developers use to merge commits so that the git merge message includes
  a list of which developers approved (ACKed) the version of a PR that
  was merged.  (This internal project change is perhaps not notable by
  itself, but one of the tool's other features---copying the full PR
  description into the merge message---makes it much easier for the
  author of this section to write these merge summaries, so he
  encourages other Bitcoin projects to investigate the advantages of
  using this tool for automatically creating better git-based
  documentation, as well as improving their security and auditability.)

- [Bitcoin Core #15519][] adds a [Poly1305][] implementation to Bitcoin
  Core but does not use it.  This is expected to be used later for an
  implementation of [P2P protocol encryption][].

- [Bitcoin Core #15637][] modifies the mempool-related RPCs (such as
  `getrawmempool`) to rename the `size` field to `vsize`.  The previous
  value was also the vsize, so the calculation has not changed.  This
  merged PR simply makes it clear that this is a vsize and not a
  stripped size.  For backwards compatibility, you can start Bitcoin
  Core with the `deprecatedrpc=size` parameter to continue using the old
  field name, although this will be removed in a future release.

- [LND #2759][] lowers the default [CLTV delta][bolt2 delta] for all channels from 144
  blocks (about 24.0 hours) to 40 blocks (about 6.7 hours).  When Alice
  wants to pay Zed through a series of routing nodes, she starts by
  giving money to Bob under the terms that either Alice can take it back
  after (say) 400 blocks or Bob can claim the money before then if he
  can provide the preimage for a particular hash (the key that opens a
  hashlock).  The 400 block delay is enforced onchain if necessary
  using `OP_CHECKLOCKTIMEVERIFY` (CLTV).  Bob then sends the money
  (minus his routing fee) to Charlie with similar terms except that the
  CLTV value is reduced from Alice's original 400 blocks by the CLTV delta of his channel with Charlie,
  reducing the value to 360 blocks. This ensures that if Charlie
  waits the maximum time to fulfil his HTLC to Bob and claim his payment
  (360 blocks), Bob still has 40 blocks to claim _his_ payment from Alice by
  fulfilling the original HTLC. If Bob's HTLC expiry time with Charlie wasn't reduced at all and
  used a 400 block delay, Bob would be at risk of losing money. Charlie could
  delay fulfilling his HTLC until 400 blocks, and Alice could then cancel her
  HTLC with Bob before Bob had time to fulfil the HTLC.

    Subsequent routers each successively subtract their delta from the value of
    the terms they give to the next node in the route.  Using a high CLTV delta
    therefore reduces the possible number of hops that can be used in a route, and
    makes a channel less attractive for use when routing payments.

- [Eclair #894][] replaces the JSON-RPC interface with an HTTP
  POST interface.  Instead of RPC commands, HTTP endpoints are used
  (e.g. the `channelstats` RPC is now `POST
  http://localhost:8080/channelstats`).  Parameters are provided to the
  endpoint using named form parameters with the same JSON syntax as
  used with RPC parameters.  Returned results are identical to before
  the change.  The old interface is still available using the
  configuration parameter `eclair.api.use-old-api=true`, but it is
  expected to be removed in a subsequent release.  See the [updated API
  documentation][eclair api docs] for details.

{% include linkers/issues.md issues="15555,15560,15620,15643,15519,15637,2759,894,13044" %}
[0.18.0]: https://bitcoincore.org/bin/bitcoin-core-0.18.0/
[poly1305]: https://en.wikipedia.org/wiki/Poly1305
[0.16.0 segwit]: https://bitcoincore.org/en/releases/0.16.0/#segwit-wallet
[eclair api docs]: https://acinq.github.io/eclair/#introduction
[johoe's mempool statistics]: https://jochen-hoenicke.de/queue/#0,1w
[p2sh.info's fee estimate tracker]: https://p2sh.info/dashboard/db/fee-estimation?orgId=1
[trampoline thread]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-March/001939.html
[core meeting segwit]: http://www.erisian.com.au/meetbot/bitcoin-core-dev/2019/bitcoin-core-dev.2019-03-28-19.01.log.html#l-83
[bech32 adoption]: https://en.bitcoin.it/wiki/Bech32_adoption
[bolt2 delta]: https://github.com/lightningnetwork/lightning-rfc/blob/master/02-peer-protocol.md#cltv_expiry_delta-selection
[p2p protocol encryption]: https://gist.github.com/jonasschnelli/c530ea8421b8d0e80c51486325587c52
[bech32 series]: /en/bech32-sending-support/
