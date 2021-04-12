---
title: 'Bitcoin Optech Newsletter #144'
permalink: /en/newsletters/2021/04/14/
name: 2021-04-14-newsletter
slug: 2021-04-14-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes recent progress on code to activate
taproot and contains our regular sections with descriptions of a recent
Bitcoin Core PR Review Club meeting and notable changes to popular
Bitcoin infrastructure software.

## News

- **Taproot activation discussion:** since our last update on discussion
  about [activation methods][topic soft fork activation] for the
  [taproot][topic taproot] soft fork in [Newsletter #139][news139
  activation], the
  Speedy Trial proposal became the focus of attention among those
  interested in activation.  PRs were opened for two variants of it:
  [PR#21377][Bitcoin Core #21377], using a variation on [BIP9][], and
  [PR#21392][Bitcoin Core #21392], using a modification that became part
  of [BIP8][].  The main technical difference between these PRs is how
  their start and stop points were specified.  PR#21377 uses Median Time
  Past ([MTP][]); PR#21392 uses the height of the current block.

    MTP is normally roughly consistent between Bitcoin's main network
    (mainnet) and its various test networks, such as testnet, the default
    [signet][topic signet], and various independent signets.  This
    allows multiple networks to share a single set of activation
    parameters even if they have vastly different block heights,
    minimizing the work of keeping those networks' users in sync with
    mainnet's consensus changes.

    Unfortunately, MTP can be easily manipulated in small ways by a
    small number of miners and in large ways by a majority of hash rate.
    It can also revert to an earlier time even by accident during a
    block chain reorganization.  By comparison, heights can only
    decrease in extraordinary reorgs.[^height-decreasing]
    That generally allows reviewers to make the simplifying
    assumption that height will only ever increase, making it easier to
    analyze height-based activation mechanisms than MTP mechanisms.

    These tradeoffs between the two proposals, among other concerns,
    created an impasse that some developers thought was preventing either
    PR from receiving additional review and, ultimately, getting one of
    them merged into Bitcoin Core.  That impasse was resolved to the
    satisfaction of some participants in the activation discussion when
    the authors of the two PRs agreed to a compromise:

    1. To use MTP for the time when nodes begin counting blocks
       signaling for the soft fork, with counting starting at the
       beginning of the next 2,016-block retarget period after the start
       time.  This is identical to the way
       [BIP9][] versionbits and [BIP148][] UASF started counting blocks
       for the soft forks they helped activate.

    2. To also use MTP for the time when nodes stop counting block
       signaling for a soft fork that hasn't locked in yet.  However,
       in a difference from BIP9, the MTP stop time is only checked at
       the end of retarget periods where counting was performed.
       This removes the
       ability for an activation attempt to go directly from *started*
       to *failed*, simplifying analysis and guaranteeing that there
       will be at least one complete 2,016 block period where miners can
       signal for activation.

    3. To use height for the minimum activation parameter.  This further
       simplifies analysis and also remains compatible with the goal of
       allowing multiple test networks to share activation parameters.
       Even though height may differ on those networks, they can all use
       a minimum activation height of `0` to activate within the window
       defined by MTP.

    Although some discussion participants expressed their displeasure
    with the compromise proposal, its [implementation][bitcoin core
    #21377] has now received reviews or
    expressions of support from over a dozen active contributors to
    Bitcoin Core and the maintainers of two other full node
    implementations (btcd and libbitcoin).  We hope this momentum
    to activate taproot continues and we'll be able to report additional
    progress in a future newsletter.

## Bitcoin Core PR Review Club

*In this monthly section, we summarize a recent [Bitcoin Core PR Review Club][]
meeting, highlighting some of the important questions and answers.  Click on a
question below to see a summary of the answer from the meeting.*

[Introduce deploymentstatus][review club
#19438] is a PR ([#19438][Bitcoin Core #19438]) by Anthony Towns that proposes
three helper functions to make it easier to [bury future deployments without
changing all the code paths][easier burying] that check a soft fork's activation status:
`DeploymentEnabled` to test if a deployment can be active, `DeploymentActiveAt`
to check if a deployment should be enforced in the given block, and
`DeploymentActiveAfter` to know if a deployment should be enforced in the
following block. All three work with both buried deployments and version bits
deployments.

The review club discussion focused on understanding the change and its potential
benefits.

{% include functions/details-list.md
  q0="What are the advantages of a [BIP90][] buried deployment over a [BIP9][]
     version bits deployment?"
  a0="A buried deployment simplifies the deployment logic by replacing the test
     that governs enforcement with simple height checks, thereby reducing the
     technical debt associated with deployment of those consensus changes."
  a0link="https://bitcoincore.reviews/19438#l-132"

  q1="How many buried deployments are enumerated by this PR?"
  a1="Five: height in coinbase, CLTV (`CHECKLOCKTIMEVERIFY`), strict
     DER signatures, CSV (`OP_CHECKSEQUENCEVERIFY`), and segwit. They
     are listed in the `BuriedDeployment` enumerator proposed by the PR in
     [src/consensus/params.h#L14-22](https://github.com/bitcoin/bitcoin/blob/e72e062e/src/consensus/params.h#L14-L22).
     One could argue that the [Satoshi-era
     soft forks](/en/topics/soft-fork-activation/#2009-hardcoded-height-consensus-nlocktime-enforcement)
     are also buried."
  a1link="https://bitcoincore.reviews/19438#l-75"

  q2="How many version bits deployments are currently defined?"
  a2="Two: testdummy and schnorr/taproot (BIPs 340-342), enumerated in the codebase in
     [src/consensus/params.h#L25-31](https://github.com/bitcoin/bitcoin/blob/e72e062e/src/consensus/params.h#L25-L31)."
  a2link="https://bitcoincore.reviews/19438#l-96"

  q3="If the taproot soft fork is activated and we later want to bury that
     activation method, what changes would need to be made to Bitcoin Core, if
     this PR is merged?"
  a3="The main change would be greatly simplified compared to the current code:
     move the `DEPLOYMENT_TAPROOT` line from the `DeploymentPos` enumerator to the
     `BuriedDeployment` one. Most importantly, [no validation logic would need
     to be changed][burying taproot]."
  a3link="https://bitcoincore.reviews/19438#l-227"
%}

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[Rust-Lightning][rust-lightning repo], [libsecp256k1][libsecp256k1
repo], [Hardware Wallet Interface (HWI)][hwi repo],
[Rust Bitcoin][rust bitcoin repo], [BTCPay Server][btcpay server repo],
[Bitcoin Improvement Proposals (BIPs)][bips repo], and [Lightning
BOLTs][bolts repo].*

- [Bitcoin Core #21594][] adds a `network` field to the `getnodeaddresses` RPC
  to help identify nodes on various networks (i.e. IPv4, IPv6, I2P, onion).
  The author has also proposed that this lays the groundwork for a future
  patch for `getnodeaddresses` that takes an argument of a specific network
  and returns only addresses in that network.

- [Bitcoin Core #21166][] Introduce DeferredSignatureChecker and have SignatureExtractorClass subclass it FIXME:jnewbery

- [LND #5108][] channeldb+invoices: add spontaneous AMP receiving + sending via SendToRoute FIXME:dongcarl

- [LND #5047][] allows the wallet to import [BIP32][] extended public
  keys (xpubs) and use them for receiving payments to LND's onchain
  wallet.  In combination with LND's recently updated support for
  [PSBTs][topic psbt] (see [Newsletter #118][news118 lnd4389]), this
  allows LND to operate as a watch-only wallet for its non-channel
  funds.  For example, Alice can import the xpub from her cold wallet,
  deposit funds into that wallet using an address LND gives her, request
  LND open a channel, sign a PSBT opening that channel with her cold
  wallet, and then have LND automatically deposit funds back to her cold
  wallet when the channel is closed.  That last part---depositing closed
  channel funds back to a cold wallet---may require extra steps,
  particularly in the case of non-cooperatively closed channels, but
  this change brings LND most of the way towards being fully
  interoperable with PSBT-compatible cold wallets and hardware wallets.

## Footnotes

[^height-decreasing]:
    If every block on the block chain had the same individual Proof of
    Work (PoW), the valid chain with the most aggregate PoW would also
    be the longest chain---the chain whose latest block had the greatest
    height yet seen.  However, every 2,016 blocks, the Bitcoin protocol
    adjusts the amount of PoW that new blocks need to contain,
    increasing or decreasing the work needing to be proved in an attempt
    to keep the average time between blocks around 10 minutes.  That
    means it's possible for a chain with fewer blocks to have more PoW
    than a chain with more blocks.

      Bitcoin users use the chain with the most PoW---not the most
      blocks---to determine whether they've received money.  When users
      see a valid variation on that chain where some of the blocks on
      the end have been replaced by different blocks, they use that
      *reorganized* chain if it contains more PoW than their current
      chain.  Because the reorg chain may contain fewer blocks, despite
      having more cumulative PoW, it's possible for the height of the
      chain to decrease.

      Although this is a theoretical concern, it's usually not a
      practical problem.  Decreasing height is only possible when a
      reorg crosses at least one of the *retarget* boundaries between
      one set of 2,016 blocks and another set of 2,016 blocks.  It also
      requires a reorg involving a large number of blocks or
      a recent major change in the amount of PoW required
      (indicating either a recent major increase or decrease of hash rate,
      or an observable manipulation by miners).  In the context of
      [BIP8][], we don't believe a reorg that decreased height would
      have any more impact on users during an activation than a more
      typical reorg.

{% include references.md %}
{% include linkers/issues.md issues="21594,21166,5108,5047,21377,21392,19438" %}
[news118 lnd4389]: /en/newsletters/2020/10/07/#lnd-4389
[news139 activation]: /en/newsletters/2021/03/10/#taproot-activation-discussion
[mtp]: https://bitcoin.stackexchange.com/a/67622/21052
[easier burying]: https://github.com/bitcoin/bitcoin/pull/11398#issuecomment-335599326
[burying taproot]: https://bitcoincore.reviews/19438#l-230
